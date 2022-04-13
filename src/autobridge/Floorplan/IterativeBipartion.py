import logging

from typing import Dict, List, Optional
from autobridge.Opt.DataflowGraph import Vertex, Edge, DataflowGraph
from autobridge.Opt.Slot import Slot
from autobridge.Opt.SlotManager import SlotManager, Dir
from autobridge.Floorplan.Bipartition import Bipartition
from autobridge.Floorplan.LegalizeFloorplan import legalize_floorplan
from autobridge.Floorplan.Utilities import log_resource_utilization
_logger = logging.getLogger('autobridge')


def iterative_bipartition(
  init_v2s: Dict[Vertex, Slot],
  slot_manager: SlotManager,
  grouping_constraints: List[List[Vertex]],
  pre_assignments: Dict[Vertex, Slot],
  partition_order: List[Dir] = [Dir.horizontal, Dir.horizontal, Dir.vertical],
  ref_usage_ratio: float = 0.7,
) -> Optional[Dict[Vertex, Slot]]:
  """
  first iteratively partition the graph. Allow the usage ratio to increase in the process
  Globally adjust the floorplan in the end to meet the usage ratio
  """
  floorplaner = Bipartition(
    init_v2s,
    grouping_constraints,
    pre_assignments,
    slot_manager,
  )

  # performs multiple iteration of partitioning
  curr_v2s = {}
  for idx, split_dir in enumerate(partition_order):
    _logger.info(f'partition #{idx+1} in the direction: {split_dir}')
    curr_v2s = floorplaner.get_bipartition_adjust_ratio(split_dir, ref_usage_ratio)

    floorplaner.set_curr_v2s(curr_v2s)

    log_resource_utilization(curr_v2s)

  return curr_v2s
