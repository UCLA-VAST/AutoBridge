import logging

from collections import defaultdict
from typing import Dict, List, Optional
from mip import Model
from autobridge.Opt.DataflowGraph import Vertex, Edge, DataflowGraph
from autobridge.Opt.Slot import Slot
from autobridge.Opt.SlotManager import SlotManager
from autobridge.Floorplan.Bipartition import Bipartition
from autobridge.Floorplan.Utilities import Dir

_logger = logging.getLogger().getChild(__name__)


def iterative_bipartition(
  graph: DataflowGraph,
  slot_manager: SlotManager,
  grouping_constraints_in_str: List[List[str]],
  pre_assignments_in_str: Dict[str, str],
  partition_order_in_str: List[str] = ['HORIZONTAL', 'HORIZONTAL', 'VERTICAL'],
  ref_usage_ratio: float = 0.7,
) -> Optional[Dict[Vertex, Slot]]:
  """
  first perform all needed data structure conversion
  """
  # get initial v2s
  init_slot = slot_manager.getInitialSlot()
  init_v2s = {v : init_slot for v in graph.getAllVertices()}

  # get grouping constraints of Vertex
  grouping_constraints: List[List[Vertex]] = [
    [graph.getVertex(v_name) for v_name in v_name_group]
      for v_name_group in grouping_constraints_in_str
  ]

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

  return _iterative_bipartition(
    init_v2s,
    slot_manager,
    grouping_constraints,
    pre_assignments,
    partition_order,
    ref_usage_ratio
  )


def _iterative_bipartition(
  init_v2s: Dict[Vertex, Slot],
  slot_manager: SlotManager,
  grouping_constraints: List[List[Vertex]],
  pre_assignments: Dict[Vertex, Slot],
  partition_order: List[Dir],
  ref_usage_ratio: float,
) -> Optional[Dict[Vertex, Slot]]:
  """
  """

  floorplaner = Bipartition(
    init_v2s,
    grouping_constraints,
    pre_assignments,
    slot_manager,
  )

  for split_dir in partition_order:
    next_v2s = floorplaner.get_bipartition_adjust_ratio(split_dir, ref_usage_ratio)
    floorplaner.set_curr_v2s(next_v2s)

  return next_v2s