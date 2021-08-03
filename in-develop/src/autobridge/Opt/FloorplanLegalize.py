import logging
from collections import defaultdict
from typing import Dict, List, Tuple
from mip import Model, minimize, BINARY, xsum, OptimizationStatus, Var

from autobridge.Opt.DataflowGraph import Vertex
from autobridge.Opt.Slot import Slot

RESOURCE_TYPES = ['BRAM', 'DSP', 'FF', 'LUT', 'URAM']
RESOURCE_USAGE_LIMIT = 0.7


def _createILPVars(
    m: Model, v_list: List[Vertex], s_list: List[Slot]
) -> Tuple[Dict[Vertex, Dict[Slot, Var]], Dict[Slot, Dict[Vertex, Var]]]:
  """
  for each vertex, for each slot, create a binary var if the vertex is assigned to the slot
  """
  logging.info('Creating ILP variables...')
  v_to_s_to_var = defaultdict(dict)
  s_to_v_to_var = defaultdict(dict)
  for v in v_list:
    for s in s_list:
      v_to_s_to_var[v][s] = m.add_var(var_type=BINARY)
      s_to_v_to_var[s][v] = v_to_s_to_var[v][s]

  return v_to_s_to_var, s_to_v_to_var


def _addAreaConstrains(m: Model, s_to_v_to_var: Dict[Slot, Dict[Vertex, Var]]) -> None:
  """
  limit the capacity of each slot
  """
  logging.info('Adding area constraints...')
  for r in RESOURCE_TYPES:
    for s, v_to_var in s_to_v_to_var.items():
      capacity = s.area[r] * RESOURCE_USAGE_LIMIT
      m += xsum(v.area[r] * var for v, var in v_to_var.items()) <= capacity


def _addUniqueConstrains(m: Model, v_to_s_to_var: Dict[Vertex, Dict[Slot, Var]]) -> None:
  """
  each vertex is assigned to one slot
  """
  logging.info('Adding constraints that each Vertex is assigned to one slot...')
  for v, s_to_var in v_to_s_to_var.items():
    m += xsum(var for var in s_to_var.values()) == 1


def _getVToSToCost(
    v_list: List[Vertex], s_list: List[Slot], orig_v2s: Dict[Vertex, Slot]
) -> Dict[Vertex, Dict[Slot, int]]:
  """
  cost for assigning a vertex to a slot
  Define the cost as the distance from the original location * the total wire length
  """
  logging.info('Generating cost...')
  v_to_s_to_cost = defaultdict(dict)
  for v in v_list:
    for s in s_list:
      orig_s = orig_v2s[v]
      v_to_s_to_cost[v][s] = orig_s.getDistance(s) * v.getTotalWireWidth()

  return v_to_s_to_cost


def _addObjective(
    m: Model, 
    v_to_s_to_cost: Dict[Vertex, Dict[Slot, int]], 
    v_to_s_to_var: Dict[Vertex, Dict[Slot, Var]]
) -> None:
  """
  minimize the cost
  """
  logging.info('Adding objective...')
  cost_var_pair_list: List[Tuple[int, Var]] = []
  for v, s_to_var in v_to_s_to_var.items():
    for s, var in s_to_var.items():
      cost = v_to_s_to_cost[v][s]
      cost_var_pair_list.append((cost, var))

  m.objective = minimize(xsum(cost * var for cost, var in cost_var_pair_list))


def _addGroupingConstraints(
    m: Model,
    grouping_list: List[List[Vertex]],
    v_to_s_to_var: Dict[Vertex, Dict[Slot, Var]],
    s_list: List[Slot]
) -> None:
  logging.info('Add grouping constraints...')

  for grouping in grouping_list:
    for i in range(1, len(grouping)):
      v1 = grouping[0]
      v2 = grouping[i]
      logging.info(f'Grouping {v1.name} and {v2.name}')
      for s in s_list:
        m += v_to_s_to_var[v1][s] == v_to_s_to_var[v2][s]


def _getILPResults(
    v_to_s_to_var: Dict[Vertex, Dict[Slot, int]]
) -> Tuple[ Dict[Vertex, Slot], Dict[Slot, List[Vertex]] ]:
  """
  extract which modules is assigned to which slots
  """
  logging.info('Extracting ILP results...')
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


def _logResults(
    new_s2v: Dict[Slot, List[Vertex]], 
    new_v2s: Dict[Vertex, Slot], 
    orig_v2s: Dict[Vertex, Slot]
) -> None:
  """
  analyze and log the new floorplan results
  """
  for s, v_list in new_s2v.items():
    logging.info(f'Slot {s.getRTLModuleName()}:')
    for r in RESOURCE_TYPES:
      capacity = s.area[r]
      usage = sum(v.area[r] for v in v_list)
      logging.info(f'  [{r}]: {usage} / {capacity} = {round(usage/capacity, 5)} ')

  # log which vertices are re-placed
  for v, s in new_v2s.items():
    orig_s = orig_v2s[v]
    if s != orig_s:
      logging.info(f'Vertex {v.name} is moved {orig_s.getDistance(s)} units from {orig_s.getRTLModuleName()} to {s.getRTLModuleName()}')


def legalizeFloorplanResults(
    orig_v2s: Dict[Vertex, Slot],
    grouping_list: List[ List[Vertex] ]
) -> Tuple[ Dict[Slot, List[Vertex]], Dict[Vertex, Slot] ]:
  """
  adjust the floorplanning to satisfy the area requirement
  """
  logging.info('Begin legalizing the floorplan results...')
  logging.info(f'Target resource usage limit: {RESOURCE_USAGE_LIMIT}')

  m = Model()

  v_list = list(orig_v2s.keys())
  s_list = list(set(orig_v2s.values()))

  v_to_s_to_var, s_to_v_to_var = _createILPVars(m, v_list, s_list)
  v_to_s_to_cost = _getVToSToCost(v_list, s_list, orig_v2s)

  _addAreaConstrains(m, s_to_v_to_var)

  _addUniqueConstrains(m, v_to_s_to_var)

  _addGroupingConstraints(m, grouping_list, v_to_s_to_var, s_list)

  _addObjective(m, v_to_s_to_cost, v_to_s_to_var)

  m.write('floorplan_legalization.lp')

  status = m.optimize()
  assert status == OptimizationStatus.OPTIMAL

  new_v2s, new_s2v = _getILPResults(v_to_s_to_var)

  _logResults(new_s2v, new_v2s, orig_v2s)

  logging.info('Finish legalizing the floorplan results.')

  return new_s2v, new_v2s