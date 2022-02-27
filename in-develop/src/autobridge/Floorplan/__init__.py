import logging
import logging.handlers
import os

from typing import Dict, List
from autobridge.Floorplan.EightWayPartition import eight_way_partition
from autobridge.Floorplan.IterativeBipartion import iterative_bipartition
from autobridge.Floorplan.Utilities import print_pre_assignment, print_vertex_areas
from autobridge.Opt.DataflowGraph import Vertex, DataflowGraph
from autobridge.Opt.Slot import Slot
from autobridge.Opt.SlotManager import SlotManager, Dir

log_file = 'tapa-autobridge.log'
handler = logging.handlers.RotatingFileHandler(log_file, mode='w', backupCount=5)
if os.path.exists(log_file):
  handler.doRollover()

handlers = [handler, logging.StreamHandler()]
logging.basicConfig(level = logging.INFO, handlers = handlers)
_logger = logging.getLogger().getChild(__name__)


def get_floorplan(
  graph: DataflowGraph,
  slot_manager: SlotManager,
  grouping_constraints_in_str: List[List[str]],
  pre_assignments_in_str: Dict[str, str],
  partition_order_in_str: List[str] = ['HORIZONTAL', 'HORIZONTAL', 'VERTICAL'],
  ref_usage_ratio: float = 0.7,
  threshold_for_iterative: int = 100,
) -> Dict[Vertex, Slot]:
  """
  main entrance of the floorplan part
  """
  # get initial v2s
  init_slot = slot_manager.getInitialSlot()
  init_v2s = {v : init_slot for v in graph.getAllVertices()}

  # get grouping constraints of Vertex
  grouping_constraints: List[List[Vertex]] = [
    [graph.getVertex(v_name) for v_name in v_name_group]
      for v_name_group in grouping_constraints_in_str
  ]

  _logger.info(f'The following modules are grouped to the same location:')
  for grouping in grouping_constraints_in_str:
    _logger.info(grouping)

  # get pre_assignment in Vertex
  pre_assignments = { graph.getVertex(v_name) : slot_manager.createSlot(pblock) 
    for v_name, pblock in pre_assignments_in_str.items() 
  }

  def _get_dir(dir_in_str: str) -> Dir:
    if dir_in_str == 'HORIZONTAL':
      return Dir.horizontal
    elif dir_in_str == 'VERTICAL':
      return Dir.vertical
    else:
      _logger.error(f'unknown partition direction {dir_in_str}')
      assert False

  partition_order = [_get_dir(dir_in_str) for dir_in_str in partition_order_in_str]

  print_pre_assignment(pre_assignments)

  # choose floorplan method
  num_vertices = len(graph.getAllVertices())
  v2s: Dict[Vertex, Slot] = {}
  if num_vertices < threshold_for_iterative:
    _logger.info(f'There are {num_vertices} vertices in the design, use eight way partition')
    v2s = eight_way_partition(init_v2s, slot_manager, grouping_constraints, pre_assignments, ref_usage_ratio)
    if v2s:
      return v2s
    else:
      _logger.warning(f'Please check if any function in the design is too large:')
      print_vertex_areas(list(init_v2s.keys()))
  
  _logger.info(f'Use iterative bi-partition because eight-way partition failed or there are too many vertices ({num_vertices})')
  v2s = iterative_bipartition(init_v2s, slot_manager, grouping_constraints, pre_assignments, partition_order, ref_usage_ratio)
  
  return v2s
