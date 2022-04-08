import logging

from typing import Dict, List, Callable, Optional, Tuple
from mip import Model, Var, minimize, xsum, BINARY, INTEGER, OptimizationStatus
from itertools import product

from autobridge.Floorplan.Utilities import *
from autobridge.Floorplan.ILPUtilities import *
from autobridge.Opt.DataflowGraph import Vertex, Edge
from autobridge.Opt.Slot import Slot
from autobridge.Opt.SlotManager import SlotManager, Dir
from autobridge.util import get_mip_model_silent

_logger = logging.getLogger('autobridge')


def four_way_partition(
  init_v2s: Dict[Vertex, Slot],
  grouping_constraints: List[List[Vertex]],
  pre_assignments: Dict[Vertex, Slot],
  slot_manager: SlotManager,
  max_usage_ratio: float,
  slr_width_limit: int,
  max_search_time: int,
) -> Dict[Vertex, Slot]:

  m = get_mip_model_silent()

  v_list = list(init_v2s.keys())

  # two variables could determine the location of a module
  # y = y1 *2 + y2  (four slots)
  v2var_y1, v2var_y2 = dict(), dict()
  for v in v_list:
    v2var_y1[v] = m.add_var(var_type=BINARY, name=f'{v.name}_y1')
    v2var_y2[v] = m.add_var(var_type=BINARY, name=f'{v.name}_y2')

  func_get_slot_by_idx = _get_slot_by_idx_closure(slot_manager)
  slot_to_idx = _get_slot_to_idx(func_get_slot_by_idx)

  _add_area_constraints(m, v_list, v2var_y1=v2var_y1, v2var_y2=v2var_y2,
    func_get_slot_by_idx=func_get_slot_by_idx, max_usage_ratio=max_usage_ratio)

  add_slr_0_1_crossing_constraint(m, v_list, v2var_y1, v2var_y2, slr_width_limit)
  add_slr_1_2_crossing_constraint(m, v_list, v2var_y1, slr_width_limit)
  add_slr_2_3_crossing_constraint(m, v_list, v2var_y1, v2var_y2, slr_width_limit)

  _add_pre_assignment(m, v_list, slot_to_idx, pre_assignments, v2var_y1=v2var_y1, v2var_y2=v2var_y2)

  _add_grouping_constraints(m, grouping_constraints, v2var_y1=v2var_y1, v2var_y2=v2var_y2)

  _add_opt_goal(m, v_list, v2var_y1=v2var_y1, v2var_y2=v2var_y2)

  _logger.debug(f'Start ILP solver with max usage ratio {max_usage_ratio} and max search time {max_search_time}s')
  m.optimize(max_seconds=max_search_time)

  next_v2s = _get_results(m, v_list, func_get_slot_by_idx, v2var_y1=v2var_y1, v2var_y2=v2var_y2)

  return next_v2s


def _get_slot_by_idx_closure(
  slot_manager: SlotManager
) -> Callable[[int, int], Slot]:
  # slot_group = [slot_00, slot_01, \
  #               slot_10, slot_11, \

  # must not change order!
  partition_order = [Dir.horizontal, Dir.horizontal]
  all_leaf_slots = slot_manager.getLeafSlotsAfterPartition(partition_order)

  def func_get_slot_by_idx(y1, y2):
    idx = y1 * 2 + y2
    return all_leaf_slots[idx]

  return func_get_slot_by_idx


def _get_slot_to_idx(
  func_get_slot_by_idx: Callable[[int, int], Slot],
) -> Dict[Slot, Tuple[int, int]]:
  """
  given a slot, get (y1, y2) in a tuple
  """
  slot_to_idx = {}
  for y1, y2 in product(range(2), range(2)):
    slot_to_idx[func_get_slot_by_idx(y1, y2)] = (y1, y2)
  return slot_to_idx


def _add_area_constraints(
  m: Model,
  v_list: List[Vertex],
  v2var_y1: Dict[Vertex, Var],
  v2var_y2: Dict[Vertex, Var],
  func_get_slot_by_idx: Callable[[int, int], Slot],
  max_usage_ratio: float,
) -> None:

  # area constraint
  for r in RESOURCE_TYPES:
    choose = lambda x, num: x if num == 1 else (1-x)

    for y1, y2 in product(range(2), range(2)):
      # convert logic AND to linear constraints
      # prods[v] = choose_y1 AND choose_y2
      prods = { v : m.add_var(var_type=BINARY, name=f'{v.name}_choose{y1}{y2}') for v in v_list }
      for v in v_list:
        m += choose(v2var_y1[v], y1) >= prods[v]
        m += choose(v2var_y2[v], y2) >= prods[v]
        m += choose(v2var_y1[v], y1) + choose(v2var_y2[v], y2) - prods[v] <= 1

      m += xsum(  prods[v] * v.getVertexAndInboundFIFOArea()[r] for v in v_list ) \
                  <= func_get_slot_by_idx(y1, y2).getArea()[r] * max_usage_ratio


def _add_grouping_constraints(
  m: Model,
  grouping_constraints: List[List[Vertex]],
  v2var_y1: Dict[Vertex, Var],
  v2var_y2: Dict[Vertex, Var],
) -> None:
  """
  user specifies that certain Vertices must be assigned to the same slot
  """
  for grouping in grouping_constraints:
    for i in range(1, len(grouping)):
      for v2var in [v2var_y1, v2var_y2]:
        m += v2var[grouping[0]] == v2var[grouping[i]]


def _add_pre_assignment(
  m: Model,
  v_list: List[Vertex],
  slot_to_idx: Dict[Slot, Tuple[int, int]],
  pre_assignments: Dict[Vertex, Slot],
  v2var_y1: Dict[Vertex, Var],
  v2var_y2: Dict[Vertex, Var],
) -> None:
  v_set = set(v_list)
  for v, expect_slot in pre_assignments.items():
    assert v in v_set, f'ERROR: user has forced the location of a non-existing module {v.name}'
    for avail_slot in slot_to_idx.keys():
      if avail_slot.containsChildSlot(expect_slot):
        y1, y2 = slot_to_idx[avail_slot]
        m += v2var_y1[v] == y1
        m += v2var_y2[v] == y2


def _add_opt_goal(
  m: Model,
  v_list: List[Vertex],
  v2var_y1: Dict[Vertex, Var],
  v2var_y2: Dict[Vertex, Var],
) -> None:
  # add optimization goal
  all_edges = get_all_edges(v_list)
  e2cost_var = {e: m.add_var(var_type=INTEGER, name=f'intra_{e.name}') for e in all_edges}

  # we will use |(y1 * 2 + y1) - (y2 * 2 + y2)|to express the hamming distance
  pos_y = lambda v : v2var_y1[v] * 2 + v2var_y2[v]
  cost_y = lambda e : pos_y(e.src) - pos_y(e.dst)

  for e, cost_var in e2cost_var.items():
    m += cost_var >= cost_y(e)
    m += cost_var >= -cost_y(e)

  m.objective = minimize(xsum(cost_var * e.width for e, cost_var in e2cost_var.items() ) )


def _get_results(
  m: Model,
  v_list: List[Vertex],
  func_get_slot_by_idx: Callable[[int, int], Slot],
  v2var_y1: Dict[Vertex, Var],
  v2var_y2: Dict[Vertex, Var],
) -> Optional[Dict[Vertex, Slot]]:
  if m.status == OptimizationStatus.OPTIMAL:
    _logger.info(f'succeed with optimal solution')
  elif m.status == OptimizationStatus.FEASIBLE:
    _logger.info(f'finish with non-optimal solution')
  else:
    _logger.debug(f'failed')
    return {}

  # extract results
  next_v2s = {}
  for v in v_list:
    selected_slot = func_get_slot_by_idx(int(v2var_y1[v].x), int(v2var_y2[v].x))
    next_v2s[v] = selected_slot

  return next_v2s
