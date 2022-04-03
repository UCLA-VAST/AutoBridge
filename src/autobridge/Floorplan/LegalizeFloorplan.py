import logging
from collections import defaultdict
from typing import Dict, List, Tuple, Optional
from mip import Model, minimize, BINARY, xsum, OptimizationStatus, Var

from autobridge.Floorplan.Utilities import *
from autobridge.Opt.DataflowGraph import Vertex
from autobridge.Opt.Slot import Slot
from autobridge.Opt.SlotManager import SlotManager, Dir
from autobridge.util import get_mip_model_silent

_logger = logging.getLogger('autobridge')


def _create_ilp_vars(
    m: Model, v_list: List[Vertex], s_list: List[Slot]
) -> Tuple[Dict[Vertex, Dict[Slot, Var]], Dict[Slot, Dict[Vertex, Var]]]:
  """
  for each vertex, for each slot, create a binary var if the vertex is assigned to the slot
  """
  v_to_s_to_var = defaultdict(dict)
  s_to_v_to_var = defaultdict(dict)
  for v in v_list:
    for s in s_list:
      v_to_s_to_var[v][s] = m.add_var(var_type=BINARY)
      s_to_v_to_var[s][v] = v_to_s_to_var[v][s]

  return v_to_s_to_var, s_to_v_to_var


def _add_area_constraints(
    m: Model, 
    s_to_v_to_var: Dict[Slot, Dict[Vertex, Var]],
    resource_usage_limit: int
) -> None:
  """
  limit the capacity of each slot
  """
  for r in RESOURCE_TYPES:
    for s, v_to_var in s_to_v_to_var.items():
      capacity = s.area[r] * resource_usage_limit
      m += xsum(v.getVertexAndInboundFIFOArea()[r] * var for v, var in v_to_var.items()) <= capacity


def _add_unique_assign_constraints(m: Model, v_to_s_to_var: Dict[Vertex, Dict[Slot, Var]]) -> None:
  """
  each vertex is assigned to one slot
  """
  for v, s_to_var in v_to_s_to_var.items():
    m += xsum(var for var in s_to_var.values()) == 1


def _add_pre_assignments(
    m: Model, 
    v_to_s_to_var: Dict[Vertex, Dict[Slot, Var]],
    pre_assignments: Dict[Vertex, Slot],
    all_slot_list: List[Slot],
) -> None:
  for v, target_slot in pre_assignments.items():
    for candidate in all_slot_list:
      if not candidate.containsChildSlot(target_slot):
        m += v_to_s_to_var[v][candidate] == 0


def _get_v_to_s_to_cost(
    v_list: List[Vertex], s_list: List[Slot], orig_v2s: Dict[Vertex, Slot]
) -> Dict[Vertex, Dict[Slot, int]]:
  """
  cost for assigning a vertex to a slot
  Define the cost as the distance from the original location * the total wire length
  """
  v_to_s_to_cost = defaultdict(dict)
  for v in v_list:
    for s in s_list:
      orig_s = orig_v2s[v]
      # +1 to handle the case where a module has 0 wire length
      v_to_s_to_cost[v][s] = orig_s.getDistance(s) * (v.getTotalWireWidth() + 1)

  return v_to_s_to_cost


def _add_opt_goal(
    m: Model, 
    v_to_s_to_cost: Dict[Vertex, Dict[Slot, int]], 
    v_to_s_to_var: Dict[Vertex, Dict[Slot, Var]]
) -> None:
  """
  minimize the cost
  """
  cost_var_pair_list: List[Tuple[int, Var]] = []
  for v, s_to_var in v_to_s_to_var.items():
    for s, var in s_to_var.items():
      cost = v_to_s_to_cost[v][s]
      cost_var_pair_list.append((cost, var))

  m.objective = minimize(xsum(cost * var for cost, var in cost_var_pair_list))


def _add_grouping_constraints(
    m: Model,
    grouping_list: List[List[Vertex]],
    v_to_s_to_var: Dict[Vertex, Dict[Slot, Var]],
    s_list: List[Slot]
) -> None:

  for grouping in grouping_list:
    for i in range(1, len(grouping)):
      v1 = grouping[0]
      v2 = grouping[i]
      _logger.debug(f'Grouping {v1.name} and {v2.name}')
      for s in s_list:
        m += v_to_s_to_var[v1][s] == v_to_s_to_var[v2][s]


def _get_ilp_results(
    v_to_s_to_var: Dict[Vertex, Dict[Slot, int]]
) -> Tuple[ Dict[Vertex, Slot], Dict[Slot, List[Vertex]] ]:
  """
  extract which modules is assigned to which slots
  """
  # get v2s
  new_v2s = {}
  for v, s_to_var in v_to_s_to_var.items():
    for s, var in s_to_var.items():
      if round(var.x) == 1:
        new_v2s[v] = s
        break

    assert v in new_v2s

  # get s2v
  new_s2v = defaultdict(list)
  for v, s in new_v2s.items():
    new_s2v[s].append(v)

  return new_v2s, new_s2v


def _log_results(
    new_v2s: Dict[Vertex, Slot], 
    orig_v2s: Dict[Vertex, Slot]
) -> None:
  """
  analyze and log the new floorplan results
  """
  # log which vertices are re-placed
  for v, s in new_v2s.items():
    orig_s = orig_v2s[v]
    if s != orig_s:
      _logger.debug(f'Vertex {v.name} is moved {orig_s.getDistance(s)} units from {orig_s.getRTLModuleName()} to {s.getRTLModuleName()}')


def get_legalized_v2s(
    orig_v2s: Dict[Vertex, Slot],
    grouping_list: List[ List[Vertex] ],
    all_slot_list: List[Slot],
    pre_assignments: Dict[Vertex, Slot],
    resource_usage_limit: int
) -> Dict[Vertex, Slot]:
  """
  adjust the floorplanning to satisfy the area requirement
  """
  _logger.debug(f'Begin legalizing the floorplan results, target resource usage limit: {resource_usage_limit}')

  m = get_mip_model_silent()

  v_list = list(orig_v2s.keys())
  s_list = all_slot_list

  v_to_s_to_var, s_to_v_to_var = _create_ilp_vars(m, v_list, s_list)
  v_to_s_to_cost = _get_v_to_s_to_cost(v_list, s_list, orig_v2s)

  _add_area_constraints(m, s_to_v_to_var, resource_usage_limit)

  _add_pre_assignments(m, v_to_s_to_var, pre_assignments, all_slot_list)

  _add_unique_assign_constraints(m, v_to_s_to_var)

  _add_grouping_constraints(m, grouping_list, v_to_s_to_var, s_list)

  _add_opt_goal(m, v_to_s_to_cost, v_to_s_to_var)

  status = m.optimize()
  if status != OptimizationStatus.OPTIMAL:
    _logger.debug(f'Fail to legalize the floorplan under target ratio {resource_usage_limit}')
    return {}

  new_v2s, new_s2v = _get_ilp_results(v_to_s_to_var)

  _log_results(new_v2s, orig_v2s)

  _logger.info('Finish legalizing the floorplan results.')

  return new_v2s


def legalize_floorplan(
  curr_v2s: Dict[Vertex, Slot],
  slot_manager: SlotManager,
  grouping_constraints: List[List[Vertex]],
  pre_assignments: Dict[Vertex, Slot],
  partition_order: List[Dir],
  init_usage_ratio: float = 0.7,
  limit_increase_step: float = 0.01,
  max_usage_ratio: float = 0.85,
) -> Optional[Dict[Vertex, Slot]]:
  """
  the iterative partitioning process may result in some slots being overused
  Re-assign some of the Vertices from the overused slots to the under-used slots
  """
  # if a slot is empty, it is not included in v2s
  all_leaf_slots = slot_manager.getLeafSlotsAfterPartition(partition_order)

  curr_limit = init_usage_ratio
  while 1:
    if curr_limit > max_usage_ratio:
      _logger.info(f'Fail to legalize under the cut threhold {max_usage_ratio}')
      return {}

    new_v2s = get_legalized_v2s(curr_v2s, grouping_constraints, all_leaf_slots, pre_assignments, curr_limit)
    if new_v2s:
      _logger.info(f'Legalization succeeded with target usage limit {curr_limit}')
      return new_v2s
    else:
      curr_limit += limit_increase_step