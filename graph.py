#! /usr/bin/python3.6
from pyverilog.vparser.parser import parse as rtl_parse
import pyverilog.vparser.ast as ast

import re
import json
import math
from collections import defaultdict
import subprocess
import os
import autopilot_parser
from assign_slr import assign_slr
import my_generator

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
    self.slr_sub_loc = -1
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

    self.dfs(top_mod_ast, set(), self.initVertices)
    self.dfs(top_mod_ast, set(), self.initEdges)
    
    # run ILP to solve the SLR assignment problem
    assign_slr(self.vertices.values(), self.edges.values(), self.formator)

    my_generator.generateConstraint_2D(self.formator, self.vertices.values(), self.edges.values())
    my_generator.generateTopHdl(self.formator, top_mod_ast, self.edges)
    
    if (self.formator.target_dir):
      verilog_dir = f'{self.formator.target_dir}/{self.formator.top_name}/solution/syn/verilog/'
      top_rtl_file = f'./{self.formator.top_name}_{self.formator.top_name}.v'
      
      if (not os.path.isfile(f'{verilog_dir}/{top_rtl_file}')):
        print('error locating HLS projects')
        print(verilog_dir)
        print(top_rtl_file)
        exit

      subprocess.run(['mv', f'./{top_rtl_file}', verilog_dir])
      subprocess.run(['mv', f'./pack_xo.tcl', self.formator.target_dir])
      subprocess.run(['mv', f'./constraint.tcl', self.formator.target_dir])

  def showVertices(self):
    for v in self.vertices.values():
      print(f'{v.name}: {v.area}')
      for e in v.in_edges:
        print(f'  <- {e.name}')
      for e in v.out_edges:
        print(f'  -> {e.name}')

  def showEdges(self):
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

  #
  # for each instance create a Vertex
  #
  def initVertices(self, node):
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
  def initEdges(self, node):
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

##########################################################
##########################################################
##########################################################

  def initPblocksU250(self, tcl):
    NUM_PER_SLR_HORIZONTAL = 4
    for y in range(self.formator.SLR_CNT):
      if (self.formator.column[y] == 2):
        # column X4 is DDR; X7 is static region
        # if the DDR is not instantiated, add X4 to the right half
        # adding X4Y0 to the left half seems to violate PR DRC rules
        right_half_start = 5 if self.formator.DDR_enable[y] == 1 else 4
        tcl.write(f'''
          startgroup
          create_pblock pblock_X{0}_Y{y}
          resize_pblock pblock_X{0}_Y{y} -add CLOCKREGION_X0Y{0+y*NUM_PER_SLR_HORIZONTAL}:CLOCKREGION_X3Y{3+y*NUM_PER_SLR_HORIZONTAL}
          endgroup

          startgroup
          create_pblock pblock_X{1}_Y{y}
          resize_pblock pblock_X{1}_Y{y} -add CLOCKREGION_X{right_half_start}Y{0+y*NUM_PER_SLR_HORIZONTAL}:CLOCKREGION_X6Y{3+y*NUM_PER_SLR_HORIZONTAL}
          endgroup
        ''')

  def initPblocksU280(self, tcl):
    NUM_PER_SLR_HORIZONTAL = 4
    for y in range(self.formator.SLR_CNT):
      if (self.formator.column[y] == 2):
        # column X4 is DDR; X7 is static region
        # if the DDR is not instantiated, add X4 to the right half
        # adding X4Y0 to the left half seems to violate PR DRC rules
        tcl.write(f'''
          startgroup
          create_pblock pblock_X{0}_Y{y}
          resize_pblock pblock_X{0}_Y{y} -add CLOCKREGION_X0Y{0+y*NUM_PER_SLR_HORIZONTAL}:CLOCKREGION_X3Y{3+y*NUM_PER_SLR_HORIZONTAL}
          endgroup
        \n''')
    tcl.write('''
      startgroup
      create_pblock pblock_X1_Y2
      resize_pblock pblock_X1_Y2 -add {SLICE_X117Y480:SLICE_X205Y719 DSP48E2_X16Y186:DSP48E2_X29Y281 LAGUNA_X16Y360:LAGUNA_X27Y599 RAMB18_X8Y192:RAMB18_X11Y287 RAMB36_X8Y96:RAMB36_X11Y143 URAM288_X2Y128:URAM288_X4Y191}
      endgroup

      startgroup
      create_pblock pblock_X1_Y1
      resize_pblock pblock_X1_Y1 -add {SLICE_X117Y240:SLICE_X205Y479 DSP48E2_X16Y90:DSP48E2_X29Y185 LAGUNA_X16Y120:LAGUNA_X27Y359 RAMB18_X8Y96:RAMB18_X11Y191 RAMB36_X8Y48:RAMB36_X11Y95 URAM288_X2Y64:URAM288_X4Y127}
      endgroup

      startgroup
      create_pblock pblock_X1_Y0
      resize_pblock pblock_X1_Y0 -add {SLICE_X117Y0:SLICE_X205Y239 DSP48E2_X16Y0:DSP48E2_X29Y89 LAGUNA_X16Y0:LAGUNA_X27Y119 RAMB18_X8Y0:RAMB18_X11Y95 RAMB36_X8Y0:RAMB36_X11Y47 URAM288_X2Y0:URAM288_X4Y63}
      resize_pblock pblock_X1_Y0 -add {SLICE_X206Y0:SLICE_X232Y59 DSP48E2_X30Y0:DSP48E2_X31Y17 PCIE4CE4_X1Y0:PCIE4CE4_X1Y0 RAMB18_X12Y0:RAMB18_X13Y23 RAMB36_X12Y0:RAMB36_X13Y11}
      endgroup
    \n''')

  # sub-SLR level (default)
  def constraintModules(self, tcl):
    # collect modules for each sub-SLR pblock
    assignment_v_sub = defaultdict(lambda: defaultdict(list))
    for y in range(self.formator.SLR_CNT):
      for x in range(self.formator.column[y]):
        for v in self.vertices.values():
          if (v.slr_sub_loc == x and v.slr_loc == y):
            assignment_v_sub[y][x].append(v.name)

    # kernels assign to half-SLR granularity
    for y in range(self.formator.SLR_CNT):
      for x in range(self.formator.column[y]):
        names = assignment_v_sub[y][x]
        
        # the command cannot take empty inputs
        if (len(names) == 0):
          continue

        # sub-SLR level
        tcl.write(f'add_cells_to_pblock [get_pblocks pblock_X{x}_Y{y}] [get_cells -hierarchical -regexp {{\n')
        for v in names:
          tcl.write(f'\t(.*/)?{v}\n')
        tcl.write('}] -clear_locs \n')

    return assignment_v_sub

  def constraintModulesSLRLevel(tcl):
    # collect modules for each SRL-level pblock
    assignment_v_slr = defaultdict(list)
    for y in range(self.formator.SLR_CNT):
      for v in self.vertices.values():
        if (v.slr_sub_loc == 0.5 and v.slr_loc == y):
          assignment_v_slr[y].append(v.name)
    
    for y in range(self.formator.SLR_CNT):
      names = assignment_v_slr[y]
      
      # the command cannot take empty inputs
      if (len(names) == 0):
        continue

      tcl.write(f'add_cells_to_pblock [get_pblocks pblock_dynamic_SLR{y}] [get_cells -hierarchical -regexp {{\n')
      for v in names:
        tcl.write(f'\t(.*/)?{v}\n')
      tcl.write('}] -clear_locs \n')

  def constraintEdges(self, tcl):
    # collect edges for each pblock
    assignment_e = defaultdict(lambda: defaultdict(list))
    for y in range(self.formator.SLR_CNT):
      for x in range(self.formator.column[y]):
        for e in self.edges.values():
          if (e.mark):
            if (self.formator.constraint_marked_edge):
              if (e.dst.slr_loc == y and e.dst.slr_sub_loc == x):
                assignment_e[y][x].append(f'{e.name}/.*fifo_unit') # inst[x].fifo_unit
              elif (e.src.slr_loc == y and e.src.slr_sub_loc == x):
                assignment_e[y][x].append(f'{e.name}/inst.*0.*unit') # inst[0].reg_unit
          elif (e.dst.slr_loc == y and e.dst.slr_sub_loc == x):
            assignment_e[y][x].append(f'{e.name}')

    # edges only assign to SLR granularity
    for y in range(self.formator.SLR_CNT):
      for x in range(self.formator.column[y]):
        names = assignment_e[y][x]
        
        # the command cannot take empty inputs
        if (len(names) == 0):
          continue

        tcl.write(f'add_cells_to_pblock [get_pblocks pblock_X{x}_Y{y}] [get_cells -hierarchical -regexp {{\n')
        for v in names:
          tcl.write(f'\t(.*/)?{v}\n')
        tcl.write('}] -clear_locs \n')

    return assignment_e

  def removeUnusedPblock(self, tcl, assignment_v, assignment_e):
    for y in range(self.formator.SLR_CNT):
      for x in range(self.formator.column[y]):
        names_e = assignment_e[y][x]
        names_v = assignment_v[y][x]
        if (len(names_e) == 0 and len(names_v) == 0):
          tcl.write(f'delete_pblocks [get_pblocks pblock_X{x}_Y{y}]\n')

  def generateConstraint_2D(self):
    tcl = open('constraint.tcl', 'w')
    tcl.write('puts "applying partitioning constraints generated by the Context Sensitive HLS Solver"\n')
    tcl.write(f'write_checkpoint ./before_opt_design.dcp -force \n')

    # create sub-SLR pblocks
    if (self.formator.board_name == 'u250'):
      self.initPblocksU250(tcl)
    elif (self.formator.board_name == 'u280'):
      self.initPblocksU280(tcl)
    else :
      print('unsupported board!')
      exit

    assignment_v = self.constraintModules(tcl)

    # self.constraintModulesSLRLevel(tcl)

    if (self.formator.constraint_edge):
      assignment_e = self.constraintEdges(tcl)
    else :
      assignment_e = defaultdict(lambda: defaultdict(list))

    self.removeUnusedPblock(tcl, assignment_v, assignment_e)
  
  def generateTopHdl(self, top_mod_ast):
    track = self.level_traverse(top_mod_ast, self.addRelayStation)
    self.level_traverse(top_mod_ast, self.addPragmaKeepHier)

    codegen = ASTCodeGenerator()
    result = codegen.visit(top_mod_ast)

    new_top = open(f'{self.formator.top_name}_{self.formator.top_name}.v', 'w')
    new_top.write(result)

    # types of relay station
    if (self.formator.relay_station_template == 'fifo'):
      new_top.write(relay_station_template.relay_station_template)
    elif (self.formator.relay_station_template == 'reg'): 
      new_top.write(relay_station_template.reg_based_relay_station_template)
    elif (self.formator.relay_station_template == 'reg_srl_fifo'): 
      new_top.write(relay_station_template.reg_srl_fifo_relay_station_template)
    else:
      print('ERROR: fifo template')
      exit

    new_top.close()

    pack_xo = open('pack_xo.tcl', 'w')
    
    if(self.formator.board_name == 'u250'):
      pack_xo.write(f'''
        open_project {self.formator.top_name}
        open_solution "solution"
        set_part {{xcu250-figd2104-2L-e}}
        create_clock -period 3.33 -name default
        config_compile -name_max_length 50  -pipeline_loops 0 -unsafe_math_optimizations
        config_dataflow -strict_mode warning
        config_sdx -target xocc
        export_design -rtl verilog -format ip_catalog -xo {self.formator.top_name}_tlp.xo
        exit    
      ''')
    elif(self.formator.board_name == 'u280'):
      pack_xo.write(f'''
        open_project {self.formator.top_name}
        open_solution "solution"
        set_part {{xcu280-fsvh2892-2L-e}}
        create_clock -period 3.33 -name default
        config_compile -name_max_length 50  -pipeline_loops 0 -unsafe_math_optimizations
        config_dataflow -strict_mode warning
        config_sdx -target xocc
        export_design -rtl verilog -format ip_catalog -xo {self.formator.top_name}_tlp.xo
        exit    
      ''')      

  def addRelayStation(self, node):
    # only considers fifo/rs instances
    if (not self.formator.isFIFOInstanceList(node)):
      return 

    edge_name = self.formator.getFIFONameFromInstanceList(node)
    e = self.edges[edge_name]
    
    step_v = abs(e.src.slr_loc - e.dst.slr_loc)
    step_h = abs(e.src.slr_sub_loc - e.dst.slr_sub_loc)
    sum = step_v + step_h
    step = self.formator.relay_station_count(sum)
    
    if (e.mark):
      node.module = 'relay_station'

      width = ast.ParamArg( 'DATA_WIDTH', ast.Rvalue(ast.IntConst(str(e.width))) )
      depth = ast.ParamArg( 'DEPTH', ast.Rvalue(ast.IntConst(str(e.depth))) )
      addr_width = ast.ParamArg( 'ADDR_WIDTH', ast.Rvalue(ast.IntConst(str(e.addr_width))) )
      level = ast.ParamArg( 'LEVEL', ast.Rvalue(ast.IntConst(str(int(step)))) )
      params = [width, depth, addr_width, level]

      node.parameterlist = params

      for c in node.instances:
        c.module = 'relay_station'
        c.parameterlist = params

      print(f' ---- update rs to {edge_name} -> {node.module}')
  
  def addPragmaKeepHier(self, node):
    #non fifo modules
    if (not self.formator.isInstanceList(node)):
      return     

    node.module = f'(* keep_hierarchy = "yes" *) {node.module}'
    for c in node.instances:
      c.module = f'(* keep_hierarchy = "yes" *) {c.module}'
    
    print(f' ---- add keep_hierarchy to {node.module}')
