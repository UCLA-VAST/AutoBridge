#! /usr/bin/python3.6

from autobridge.HLSParser.vivado_hls.TopRTLParser import TopRTLParser
from autobridge.HLSParser.vivado_hls.HLSProjectManager import HLSProjectManager
import logging
import math

class Edge:
  def __init__(self, name:str):
    self.src : Vertex = None
    self.dst : Vertex = None
    self.width = -1
    self.depth = -1
    self.addr_width = -1
    self.name = name

    logging.debug(f'create edge {self.name} of width {self.width} and depth {self.depth}')

  def __hash__(self):
    return hash(self.name)

  def __eq__(self, other):
    return self.name == other.name

class Vertex():
  def __init__(self, type:str, name : str):
    self.in_edges = [] # stores Edge objects
    self.out_edges = []
    self.in_edge_names = [] # stores Edge objects
    self.out_edge_names = []
    self.type = type
    self.name = name
    self.id = self.type + self.name
    self.area = {} # str_name -> count

    logging.debug(f'create vertix {self.name} of type {self.type}')

  def __hash__(self):
    return hash(self.id)

  def __eq__(self, other):
    return self.id == other.id

  def getEdgeNames(self):
    return self.in_edge_names + self.out_edge_names

  def getEdges(self):
    return self.in_edges + self.out_edges
  
  def getInEdges(self):
    return self.in_edges
  
  def getOutEdges(self):
    return self.out_edges

  def getNeighborVertices(self):
    src_neighbors = [e.src for e in self.getInEdges()]
    dst_neighbors = [e.dst for e in self.getOutEdges()]
    return src_neighbors + dst_neighbors

class DataflowGraph:
  def __init__(self, hls_prj_manager : HLSProjectManager, top_rtl_parser : TopRTLParser):
    self.hls_prj_manager = hls_prj_manager
    self.top_rtl_parser = top_rtl_parser

    self.vertices = {} # name -> Vertex
    self.edges = {} # name -> Edge

    for v_node in self.top_rtl_parser.traverseVertexInAST():
      self.__initVertices(v_node)

    for e_node in self.top_rtl_parser.traverseEdgeInAST():
      self.__initEdges(e_node)

    self.__linkEdgeAndVertex()
    
    self.__checker()

    self.v_type_2_int = {} # map each vertex type to an integer
    self.v_name_2_int = {} # map each vertex instance to an integer
    self.int_2_v_type = {}
    self.int_2_v_name = {}
    self.__initVTypeToInt()
    self.__initVInstToInt()
    
  # assign an integer to v type
  def __initVTypeToInt(self):
    id = 1
    for v_node in self.vertices.values():
      if v_node.type not in self.v_type_2_int:
        self.v_type_2_int[v_node.type] = id
        self.int_2_v_type[id] = v_node.type
        logging.debug(f'{v_node.type} : {id}')
        id += 1

  # assign an integer to v name
  def __initVInstToInt(self):
    id = 1
    for v_node in self.vertices.values():
      if v_node.name not in self.v_name_2_int:
        self.v_name_2_int[v_node.name] = id
        self.int_2_v_name[id] = v_node.name
        logging.debug(f'{v_node.name} : {id}')
        id += 1
      else:
        assert False, f'Found two modules of the same name {v_node.name}'

  # note that we need to merge repetitve edges
  def getIntegerGraph(self):
    int_e_list = [ (self.v_name_2_int[e.src.name], self.v_name_2_int[e.dst.name]) \
                  for e in self.edges.values() ]
    int_e_list = list(set(int_e_list))

    int_v_labels = [ [self.v_name_2_int[v.name], self.v_type_2_int[v.type] ] \
                  for v in self.vertices.values()]
    return int_e_list, int_v_labels

  def getIntEdgeToName(self):
    int_edge2name = { (self.v_name_2_int[e.src.name], self.v_name_2_int[e.dst.name]) : e.name \
                  for e in self.edges.values() }
    return int_edge2name

  def getIntIdToVType(self):
    return self.int_2_v_type

  def getIntIdToVName(self):
    return self.int_2_v_name

  def __checker(self):
    v_name_list = [v.type + v.name for v in self.getAllVertices()]
    e_name_list = [e.name for e in self.getAllEdges()]
    assert len(v_name_list) == len(set(v_name_list)), 'Find repeated modules'
    assert len(e_name_list) == len(set(e_name_list))

  def __initVertices(self, v_node):

    v = Vertex(v_node.module, v_node.name)

    # get area
    v.area = self.hls_prj_manager.getAreaFromModuleType(v.type)
    
    v.in_edge_names = self.top_rtl_parser.getInFIFOsOfModuleInst(v.name)
    v.out_edge_names = self.top_rtl_parser.getOutFIFOsOfModuleInst(v.name)

    self.vertices[v_node.name] = v

  def __initEdges(self, e_node):

    e = Edge(e_node.name)

    # extract width
    e.width = self.top_rtl_parser.getFIFOWidthFromFIFOType(e_node.module)
    e.depth = self.top_rtl_parser.getFIFODepthFromFIFOType(e_node.module)
    e.addr_width = int(math.log2(e.depth)+1)

    self.edges[e_node.name] = e

  def __linkEdgeAndVertex(self):
    for v in self.vertices.values():
      for fifo_in_name in v.in_edge_names:
        fifo_in = self.edges[fifo_in_name]
        fifo_in.dst = v
        v.in_edges.append(fifo_in)
      for fifo_out_name in v.out_edge_names:
        fifo_out = self.edges[fifo_out_name]
        fifo_out.src = v
        v.out_edges.append(fifo_out)

  def printVertices(self):
    for v in self.vertices.values():
      logging.debug(f'{v.name}: {v.area}')
      for e in v.in_edges:
        logging.debug(f'  <- {e.name}')
      for e in v.out_edges:
        logging.debug(f'  -> {e.name}')

  def printEdges(self):
    for e in self.edges.values():
      logging.debug(f'{e.name}: {e.src.name} -> {e.dst.name}')

  def getAllVertices(self):
    return self.vertices.values()

  def getAllEdges(self):
    return self.edges.values()

  def getNameToVertexMap(self):
    return self.vertices

  def getNameToEdgeMap(self):
    return self.edges

  def getVertex(self, v_name):
    return self.vertices[v_name]