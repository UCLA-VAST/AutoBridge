# get the original top RTL
# locate the FIFO instance of all edges
# update the FIFO type to relay station
# set the pipeline level
from typing import Dict

import pyverilog.vparser.ast as ast
from autobridge.Opt.DataflowGraph import Edge


def _is_fifo_instance_list(node):
  return isinstance(node, ast.InstanceList) and 'fifo' in node.module


def _get_fifo_name_from_instance_list(node):
  assert(len(node.instances) == 1)
  return node.instances[0].name


def convert_fifo_to_relay_station(node, edge_name_to_object: Dict[str, Edge]):
  # only considers fifo/rs instances
  if (not _is_fifo_instance_list(node)):
    return 

  edge_name = _get_fifo_name_from_instance_list(node)
  e = edge_name_to_object[edge_name]
  
  if e.latency == 0:
    return

  node.module = 'relay_station'  # pipeline the FIFO

  width = ast.ParamArg( 'DATA_WIDTH', ast.Rvalue(ast.IntConst(str(e.width))) )
  depth = ast.ParamArg( 'DEPTH', ast.Rvalue(ast.IntConst(str(e.depth))) )
  addr_width = ast.ParamArg( 'ADDR_WIDTH', ast.Rvalue(ast.IntConst(str(e.addr_width))) )
  level = ast.ParamArg( 'LEVEL', ast.Rvalue(ast.IntConst(str( e.latency ))) )

  params = [width, depth, addr_width, level]
  node.parameterlist = params

  for c in node.instances:
    c.module = 'relay_station'
    c.parameterlist = params


def add_keep_hierarcy_pragma(node):  #non fifo modules
  if (not isinstance(node, ast.InstanceList)):
    return

  # do not keep hierarchy of relay stations
  # because they are meant to be split and span long distances
  if node.module == 'relay_station':
    return
      
  node.module = f'(* keep_hierarchy = "yes" *) {node.module}'
  for c in node.instances:
    c.module = f'(* keep_hierarchy = "yes" *) {c.module}'



