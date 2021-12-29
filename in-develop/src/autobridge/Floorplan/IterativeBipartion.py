import logging

from typing import Dict, List, Optional
from autobridge.Opt.DataflowGraph import Vertex, Edge, DataflowGraph
from autobridge.Opt.Slot import Slot
from autobridge.Opt.SlotManager import SlotManager, Dir
from autobridge.Floorplan.Bipartition import Bipartition
from autobridge.Floorplan.LegalizeFloorplan import legalize_floorplan
_logger = logging.getLogger().getChild(__name__)


def iterative_bipartition(
  init_v2s: Dict[Vertex, Slot],
  slot_manager: SlotManager,
  grouping_constraints: List[List[Vertex]],
  pre_assignments: Dict[Vertex, Slot],
  partition_order: List[Dir],
  ref_usage_ratio: float,
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
  for split_dir in partition_order:
    post_partition_v2s = floorplaner.get_bipartition_adjust_ratio(split_dir, ref_usage_ratio)
    floorplaner.set_curr_v2s(post_partition_v2s)

  # globally adjust the floorplan
  legalized_v2s = legalize_floorplan(
    post_partition_v2s, 
    slot_manager, 
    grouping_constraints, 
    pre_assignments, 
    partition_order
  )

  return legalized_v2s
