import logging
from typing import Dict, List, Tuple

from autobridge.Floorplan.Utilities import (
  log_resource_utilization,
  get_actual_area_limit,
  get_actual_slr_crossing_limit,
)
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

  v2s = worker(
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

  if v2s:
    log_resource_utilization(v2s)

  return v2s


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
  # use the max slr limit to find the min area limit
  curr_v2s, curr_area_limit = _binary_search_area_limit(
    init_v2s,
    slot_manager,
    grouping_constraints,
    pre_assignments,
    max_slr_width_limit,
    min_area_limit,
    max_area_limit,
    max_search_time,
    partitioner,
  )

  if not curr_v2s:
    _logger.info(f'partition failed with max_usage_ratio {max_area_limit} and slr_width_limit {max_slr_width_limit}')
    return {}

  # use this value as the upper bound in binary search
  actual_slr_width_usage = get_actual_slr_crossing_limit(curr_v2s)

  _logger.info(f'partition succeeds with max_usage_ratio {curr_area_limit} and slr_width_limit {actual_slr_width_usage}')
  return curr_v2s


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
  # use the max area to find the min slr limit
  curr_v2s, curr_slr_limit = _binary_search_slr_crossing_limit(
    init_v2s,
    slot_manager,
    grouping_constraints,
    pre_assignments,
    max_area_limit,
    min_slr_width_limit,
    max_slr_width_limit,
    max_search_time,
    partitioner,
  )

  if not curr_v2s:
    _logger.info(f'partition failed with max_usage_ratio {max_area_limit} and slr_width_limit {max_slr_width_limit}')
    return {}

  # use this value as the upper bound in binary search
  actual_area_usage = get_actual_area_limit(curr_v2s)

  _logger.info(f'partition succeeds with max_usage_ratio {actual_area_usage} and slr_width_limit {curr_slr_limit}')
  return curr_v2s


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
) -> Tuple[Dict[Vertex, Slot], int]:
  _logger.info('Binary search of slr_width_limit between %d and %d, '
               'with area_limit %f', min_slr_width_limit, max_slr_width_limit, area_limit)

  curr_best_v2s = {}

  # binary search:
  hi = max_slr_width_limit
  lo = min_slr_width_limit

  curr_min_slr_limit = None
  while (lo <= hi):
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

      # the actual area usage may be smaller than the provided limit
      actual_slr_usage = get_actual_slr_crossing_limit(v2s)
      curr_min_slr_limit = actual_slr_usage
      hi = actual_slr_usage

      _logger.info('succeed with max actual slr crossing count %d', actual_slr_usage)
    else:
      lo = curr_slr_limit

    if hi - lo < 500:
      break

  if curr_best_v2s:
    _logger.info(f'Found solution with area limit {area_limit} and slr_width_limit {curr_min_slr_limit}')

  return curr_best_v2s, curr_min_slr_limit


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
) -> Tuple[Dict[Vertex, Slot], float]:
  _logger.info('Binary search of min_area_limit between %f and %f, '
               'with slr_width_limit %d', min_area_limit, max_area_limit, slr_width_limit)

  curr_best_v2s = {}

  # binary search:
  hi = max_area_limit
  lo = min_area_limit

  curr_min_usage = None
  while (lo <= hi):
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

      # the actual area usage may be smaller than the provided limit
      actual_area_usage = get_actual_area_limit(v2s)
      curr_min_usage = actual_area_usage
      hi = actual_area_usage

      _logger.info('succeed with actual area usage %f', actual_area_usage)
    else:
      lo = curr_area_limit

    if hi - lo < 0.01:
      break

  if curr_best_v2s:
    _logger.info(f'Found solution with usage_ratio {curr_min_usage} and slr_width_limit {slr_width_limit}')

  return curr_best_v2s, curr_min_usage
