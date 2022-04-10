import logging
from typing import Dict, List

from autobridge.Floorplan.Utilities import log_resource_utilization
from autobridge.Floorplan.EightWayPartition import eight_way_partition
from autobridge.Floorplan.FourWayPartition import four_way_partition
from autobridge.Opt.DataflowGraph import Vertex
from autobridge.Opt.Slot import Slot
from autobridge.Opt.SlotManager import SlotManager

_logger = logging.getLogger('autobridge')


def partition(
  init_v2s: Dict[Vertex, Slot],
  slot_manager: SlotManager,
  grouping_constraints: List[List[Vertex]],
  pre_assignments: Dict[Vertex, Slot],
  min_area_limit: float = 0.65,
  max_area_limit: float = 0.85,
  min_slr_width_limit: int = 10000,
  max_slr_width_limit: int = 15000,
  max_search_time: int = 600,
  partition_method: str = 'EIGHT_WAY_PARTITION',
  floorplan_opt_priority: str = 'AREA_PRIORITIZED',
) -> Dict[Vertex, Slot]:
  _logger.info('Use partition method: %s with floorplan_opt_priority %s', partition_method, floorplan_opt_priority)

  if partition_method == 'EIGHT_WAY_PARTITION':
    partitioner = eight_way_partition
  elif  partition_method == 'FOUR_WAY_PARTITION':
    partitioner = four_way_partition
  else:
    raise NotImplementedError('unrecognized floorplan method: %s', partition_method)

  if floorplan_opt_priority == 'AREA_PRIORITIZED':
    worker = partition_area_prioritized
  elif floorplan_opt_priority == 'SLR_CROSSING_PRIORITIZED':
    worker = partition_slr_crossing_prioritized
  else:
    raise NotImplementedError('unrecognized floorplan_opt_priority: %s', floorplan_opt_priority)

  return worker(
    init_v2s,
    slot_manager,
    grouping_constraints,
    pre_assignments,
    min_area_limit,
    max_area_limit,
    min_slr_width_limit,
    max_slr_width_limit,
    max_search_time,
    partitioner,
  )


def partition_area_prioritized(
  init_v2s: Dict[Vertex, Slot],
  slot_manager: SlotManager,
  grouping_constraints: List[List[Vertex]],
  pre_assignments: Dict[Vertex, Slot],
  min_area_limit: float,
  max_area_limit: float,
  min_slr_width_limit: int,
  max_slr_width_limit: int,
  max_search_time: int,
  partitioner,
) -> Dict[Vertex, Slot]:
  """
  adjust the max_usage_ratio if failed
  """
  best_v2s = {}

  # start from the largest allowed ratio and search downwards. Prune if fail.
  # for curr_max_usage in reversed(float_range(ref_usage_ratio, max_usage_ratio, 0.02)):
  lo = min_area_limit
  hi = max_area_limit
  assert lo < hi

  while (1):
    curr_area_limit = (lo + hi) / 2

    _logger.info(f'Attempt eight way partition with area limit of {curr_area_limit}')

    curr_best_v2s = _binary_search_slr_crossing_limit(
      init_v2s,
      slot_manager,
      grouping_constraints,
      pre_assignments,
      curr_area_limit,
      min_slr_width_limit,
      max_slr_width_limit,
      max_search_time,
      partitioner,
    )
    if curr_best_v2s:
      best_v2s = curr_best_v2s
      hi = curr_area_limit
    else:
      lo = curr_area_limit

    if best_v2s:
      if hi - lo < 0.03:
        break
    else:
      if hi - lo < 0.02:
        break

  if not best_v2s:
    _logger.info(f'eight way partition failed with max_usage_ratio {curr_area_limit} and slr_width_limit {max_slr_width_limit}')
    return {}

  log_resource_utilization(best_v2s)
  return best_v2s


def _binary_search_slr_crossing_limit(
  init_v2s: Dict[Vertex, Slot],
  slot_manager: SlotManager,
  grouping_constraints: List[List[Vertex]],
  pre_assignments: Dict[Vertex, Slot],
  area_limit: float,
  min_slr_width_limit: int,
  max_slr_width_limit: int,
  max_search_time: int,
  partitioner,
) -> Dict[Vertex, Slot]:

  curr_best_v2s = {}

  # binary search:
  hi = max_slr_width_limit
  lo = min_slr_width_limit
  assert lo < hi

  while (1):
    curr_slr_limit = (hi + lo) / 2
    _logger.info(f'Try slr_width_limit {curr_slr_limit}')

    v2s = partitioner(
      init_v2s,
      grouping_constraints,
      pre_assignments,
      slot_manager,
      area_limit,
      curr_slr_limit,
      max_search_time,
    )

    if v2s:
      curr_best_v2s = v2s
      curr_min_slr_limit = curr_slr_limit
      hi = curr_slr_limit
    else:
      lo = curr_slr_limit

    if curr_best_v2s:
      if hi - lo < 700:
        break
    else:
      if hi - lo < 500:
        break

  if curr_best_v2s:
    _logger.info(f'Found solution with area limit {area_limit} and slr_width_limit {curr_min_slr_limit}')

  return curr_best_v2s


def partition_slr_crossing_prioritized(
  init_v2s: Dict[Vertex, Slot],
  slot_manager: SlotManager,
  grouping_constraints: List[List[Vertex]],
  pre_assignments: Dict[Vertex, Slot],
  min_area_limit: float,
  max_area_limit: float,
  min_slr_width_limit: int,
  max_slr_width_limit: int,
  max_search_time: int,
  partitioner,
) -> Dict[Vertex, Slot]:
  """
  adjust the max_usage_ratio if failed
  """
  best_v2s = {}

  # start from the largest allowed ratio and search downwards. Prune if fail.
  # for curr_max_usage in reversed(float_range(ref_usage_ratio, max_usage_ratio, 0.02)):
  lo = min_slr_width_limit
  hi = max_slr_width_limit
  assert lo < hi

  while (1):
    curr_slr_limit = (lo + hi) / 2

    _logger.info(f'Attempt eight way partition with slr_crossing_limit {curr_slr_limit}')

    curr_best_v2s = _binary_search_area_limit(
      init_v2s,
      slot_manager,
      grouping_constraints,
      pre_assignments,
      curr_slr_limit,
      min_area_limit,
      max_area_limit,
      max_search_time,
      partitioner,
    )
    if curr_best_v2s:
      best_v2s = curr_best_v2s
      hi = curr_slr_limit
    else:
      lo = curr_slr_limit

    if best_v2s:
      if hi - lo < 700:
        break
    else:
      if hi - lo < 500:
        break

  if not best_v2s:
    _logger.info(f'eight way partition failed with area limit {max_area_limit} and slr_width_limit {curr_slr_limit}')
    return {}

  log_resource_utilization(best_v2s)
  return best_v2s


def _binary_search_area_limit(
  init_v2s: Dict[Vertex, Slot],
  slot_manager: SlotManager,
  grouping_constraints: List[List[Vertex]],
  pre_assignments: Dict[Vertex, Slot],
  slr_width_limit,
  min_area_limit,
  max_area_limit,
  max_search_time,
  partitioner,
) -> Dict[Vertex, Slot]:

  curr_best_v2s = {}

  # binary search:
  hi = max_area_limit
  lo = min_area_limit
  assert lo < hi

  while (1):
    curr_area_limit = (hi + lo) / 2
    _logger.info(f'Try area limit {curr_area_limit}')

    v2s = partitioner(
      init_v2s,
      grouping_constraints,
      pre_assignments,
      slot_manager,
      curr_area_limit,
      slr_width_limit,
      max_search_time,
    )

    if v2s:
      curr_best_v2s = v2s
      curr_min_usage = curr_area_limit
      hi = curr_area_limit
    else:
      lo = curr_area_limit

    if curr_best_v2s:
      if hi - lo < 0.015:
        break
    else:
      if hi - lo < 0.01:
        break

  if curr_best_v2s:
    _logger.info(f'Found solution with usage_ratio {curr_min_usage} and slr_width_limit {slr_width_limit}')

  return curr_best_v2s
