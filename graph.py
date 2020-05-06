#! /usr/bin/python3.6

import pyverilog.vparser.ast as ast
from pyverilog.vparser.parser import parse as rtl_parse
from pyverilog.ast_code_generator.codegen import ASTCodeGenerator
import re
import json
import math
from collections import defaultdict

import autopilot_parser
from format import FormatTLP
from format_hls import FormatHLS
from assign_slr import assign_slr

class Edge:
  def __init__(self, name:str):
    self.src : Vertex = None
    self.dst : Vertex = None
    self.src_sub : Vertex = None
    self.dst_sub : Vertex = None
    self.width = -1
    self.depth = -1
    self.addr_width = -1
    self.name = name
    self.mark = False

class Vertex:
  def __init__(self, type:str, name : str):
    self.in_edges = [] # stores Edge objects
    self.out_edges = []
    self.type = type
    self.name = name
    self.upstream = [] # marked edges in the upstream
    self.downstream = []
    self.area = autopilot_parser.Area(-1, -1, -1, -1)
    self.slr_loc = -1
    self.sub_vertices = {} # pp id -> sub vertex
    self.actual_to_sub = {} # map actual edge name -> sub vertex
    print(f'*** init vertex {self.name} of type {self.type}')

  def add_in(self, edge : Edge):
    self.out_edges.append(edge)

  def add_out(self, edge : Edge):
    self.in_edges.append(edge)

class Graph:

  def __init__(self, formator):
    self.flag = 0
    self.formator = formator

    # must use list to wrap up the addr
    top_mod_ast, directives = rtl_parse([self.formator.top_hdl_path]) 

    self.vertices = {} # name -> Vertex
    self.edges = {} # name -> Edge
    self.edge_to_vertex = {} # raw edge name (xxx_din & xxx_dout) -> Vertex

    self.dfs(top_mod_ast, set(), self.init_vertices)
    self.dfs(top_mod_ast, set(), self.init_edges)
    
    # run ILP to solve the SLR assignment problem
    assign_slr(self.vertices.values(), self.edges.values(), self.formator)

    self.generateConstraint()
    self.generateTopHdl(top_mod_ast)
    
  def show_vertices(self):
    for v in self.vertices.values():
      print(f'{v.name}: {v.area}')
      for e in v.in_edges:
        print(f'  <- {e.name}')
      for e in v.out_edges:
        print(f'  -> {e.name}')

  def show_edges(self):
    for e in self.edges.values():
      print(f'{e.name}: {e.src.name} -> {e.dst.name}')

  #
  # traverse the rtl and apply a function
  #
  def dfs(self, node, visited, func):
    if(node not in visited):
      visited.add(node)
    else:
      return
    
    func(node)

    for c in node.children():
      self.dfs(c, visited, func)

      try:
        if (c.name == 'in_size_c16_U'):
          c.show()
          self.flag = 1      

      except:
        pass

  def level_traverse(self, node, func):
    q = [node]
    track = None
    while( len(q) ):
      curr = q.pop(0)
      for c in curr.children():
        q.append(c)
      func(curr)

      try:
        if (curr.name == 'in_size_c16_U'):
          curr.show()
          self.flag = 1      
          track = curr
      except:
        pass  
  
    track.show()
    return track
  #
  # for each instance create a Vertex
  #
  def init_vertices(self, node):
    # for every non-fifo module instance  
    if (not self.formator.isValidInstance(node)):
      return 
    if (self.formator.isFIFO(node)):
      return 

    v = Vertex(node.module, node.name)
    
    actual_to_formal = {} # map actual FIFO name to formal FIFO name
    for portarg in node.portlist:
      # filter out constant ports
      if(not isinstance(portarg.argname, ast.Identifier)):
        continue

      formal_raw = portarg.portname
      actual_raw = portarg.argname.name

      # each fifo xxx -> xxx_din & xxx_dout, each maps to a vertex
      if (('_dout' in formal_raw and '_dout' in actual_raw) or \
          ('_din' in formal_raw and '_din' in actual_raw) ):
        
        # map raw edge name to vertices
        self.edge_to_vertex[actual_raw] = v

        # map formal to actual
        formal_strip = self.formator.extractFIFOFromRaw(formal_raw)
        actual_strip = self.formator.extractFIFOFromRaw(actual_raw)

        actual_to_formal[actual_strip] = formal_strip

    # get area
    rpt_name = self.formator.getRptFile(v)
    v.area = autopilot_parser.getAreaFromReport(rpt_name)

    # split into pseudo vertex at loop level
    sche_file = self.formator.getScheFile(v.type)
    formal_to_pp, pp_to_formal = autopilot_parser.getGrouping(sche_file) # map pp id -> fifos used in this pp
    for i, pp in pp_to_formal.items():
      v.sub_vertices[i] = (Vertex(node.module, f'{node.name}_sub_{i}'))
    
    # map edge to pseudo vertices
    # we have actual_to_formal and formal_to_pp, need to bridge them
    for actual_strip, formal_strip in actual_to_formal.items():
      # print(actual_strip, formal_strip)
      # print(json.dumps(formal_to_pp, indent=2, sort_keys=True))

      # some FIFOs are not accessed in pp loops
      if (formal_strip in formal_to_pp.keys()):
        v.actual_to_sub[actual_strip] = v.sub_vertices[formal_to_pp[formal_strip] ]

    self.vertices[node.name] = v

  #
  # for each FIFO or relay station create an Edge
  #
  def init_edges(self, node):
    # only considers fifo/rs instances
    if (not self.formator.isValidInstance(node)):
      return 
    if (not self.formator.isFIFO(node)):
      return 

    e = Edge(node.name)

    # extract width
    e.width = self.formator.extractFIFOWidth(node)
    e.depth = self.formator.extractFIFODepth(node)
    e.addr_width = int(math.log2(e.depth)+1)

    # extract wire name
    # augment vertices with edge info
    for portarg in node.portlist:
      # filter constant ports
      if(not isinstance(portarg.argname, ast.Identifier)):
        continue

      formal_raw = portarg.portname
      actual_raw = portarg.argname.name

      # set up edge
      if ('_dout' in actual_raw and '_dout' in formal_raw):
        e.dst = self.edge_to_vertex[actual_raw]
      elif ('_din' in actual_raw and '_din' in formal_raw):
        e.src = self.edge_to_vertex[actual_raw]

      # setup vertices
      if ('_dout' in actual_raw and '_dout' in formal_raw):
        e.dst.add_in(e)
      elif ('_din' in actual_raw and '_din' in formal_raw):
        e.src.add_out(e)   

      # setup sub vertices
      if ('_dout' in actual_raw and '_dout' in formal_raw):
        try:
          e.dst.actual_to_sub[e.name].add_in(e)
        except:
          print(f'non-pp edge: {e.name}')
      elif ('_din' in actual_raw and '_din' in formal_raw):
        try:
          e.src.actual_to_sub[e.name].add_out(e)         
        except:
          print(f'non-pp edge: {e.name}')

    self.edges[node.name] = e

  def generateConstraint(self):
    tcl = open('constraint.tcl', 'w')
    tcl.write('puts "applying partitioning constraints generated by the Context Sensitive HLS Solver"\n')
    assignment = defaultdict(list)
    for loc in range(self.formator.SLR_CNT):
      for v in self.vertices.values():
        if (v.slr_loc == loc):
          assignment[loc].append(v)

    for loc, vs in assignment.items():
      if (len(vs) == 0):
        continue
      
      tcl.write(f'add_cells_to_pblock [get_pblocks pblock_dynamic_SLR{loc}] [get_cells -hierarchical -regex {{\n')
      for v in vs:
        tcl.write(f'\t(.*/)?{v.name}\n')
      tcl.write('}]\n')
  
  def generateTopHdl(self, top_mod_ast):
    track = self.level_traverse(top_mod_ast, self.addRelayStation)

    top_mod_ast.show()
    codegen = ASTCodeGenerator()
    result = codegen.visit(top_mod_ast)

    top_mod_ast.show()

    new_top = open(f'{self.formator.top_name}_{self.formator.top_name}_relay_statoin.v', 'w')
    new_top.write(result)

  def addRelayStation(self, node):
    # only considers fifo/rs instances
    if (not self.formator.isFIFOInstanceList(node)):
      return 

    edge_name = self.formator.getFIFONameFromInstanceList(node)
    e = self.edges[edge_name]
    
    step = abs(e.src.slr_loc - e.dst.slr_loc)
    if (step):
      node.module = 'relay_station'

      width = ast.ParamArg( 'DATA_WIDTH', ast.Rvalue(ast.IntConst(str(e.width))) )
      depth = ast.ParamArg( 'DEPTH', ast.Rvalue(ast.IntConst(str(e.depth))) )
      addr_width = ast.ParamArg( 'ADDR_WIDTH', ast.Rvalue(ast.IntConst(str(e.addr_width))) )
      level = ast.ParamArg( 'LEVEL', ast.Rvalue(ast.IntConst(str(int(step+1)))) )
      params = [width, depth, addr_width, level]

      node.parameterlist = params

      for c in node.instances:
        c.module = 'relay_station'
        c.parameterlist = params

      #print(f' ---- update rs to {edge_name} -> {node.module}')