import logging

from typing import Dict, List, Tuple, DefaultDict
from collections import defaultdict, namedtuple

import mip
from autobridge.util import get_mip_model_silent
from autobridge.Opt.DataflowGraph import Vertex
from autobridge.Floorplan.Utilities import get_all_edges, RESOURCE_TYPES

_logger = logging.getLogger('autobridge')


class VarInfo:
  def __init__(self, var: mip.Var, x: int, y: int):
    self.var = var
    self.x = x
    self.y = y

class Coordinate:
  def __init__(self, x: mip.Var, y: mip.Var):
    self.x = x
    self.y = y


def multi_way_partition(
  vertices: List[Vertex],
  grouping_constraints: List[List[Vertex]],
  pre_assignments: Dict[Vertex, Tuple[int, int]],
  num_row: int,
  num_col: int,
  resources: Dict[int, Dict[int, Dict[str, int]]],
  resource_weight: Dict[str, int],
  max_search_time: int,
) -> Dict[Vertex, Tuple[int, int]]:
  # safety check
  assert all(resources[x][y] for x in range(num_row) for y in range(num_col))

  m = get_mip_model_silent()

  # create a binary decision var for each slot for each vertex
  v_to_x_to_y_to_var: DefaultDict[Vertex, DefaultDict[int, Dict[int, mip.Var]]] = defaultdict(lambda: defaultdict(dict))
  v_to_all_vars: DefaultDict[Vertex, List[VarInfo]] = defaultdict(list)
  for v in vertices:
    for x in range(num_row):
      for y in range(num_col):
        var = m.add_var(var_type=mip.BINARY)
        v_to_all_vars[v].append(VarInfo(var, x, y))
        v_to_x_to_y_to_var[v][x][y] = var

  # each vertex is only assigned to one slot
  for v, vars in v_to_all_vars.items():
    m.add_constr(mip.xsum(var.var for var in vars) == 1)

  # represent the index of each vertex
  v_to_indices: Dict[Vertex, Coordinate] = {}
  for v, vars in v_to_all_vars.items():
    x_idx = m.add_var(var_type=mip.INTEGER)
    y_idx = m.add_var(var_type=mip.INTEGER)
    m += mip.xsum(var.var * var.x for var in vars) == x_idx  # type: ignore
    m += mip.xsum(var.var * var.y for var in vars) == y_idx  # type: ignore
    v_to_indices[v] = Coordinate(x_idx, y_idx)

  # pre assignemnts
  for v, coordinates in pre_assignments.items():
    idx_vars = v_to_indices[v]
    m += idx_vars.x == coordinates[0]
    m += idx_vars.y == coordinates[1]

  # group constraints
  for group in grouping_constraints:
    for i in range(1, len(group)):
      m += v_to_indices[group[0]].x == v_to_indices[group[i]].x
      m += v_to_indices[group[0]].y == v_to_indices[group[i]].y

  # distance of each edge
  edges = get_all_edges(vertices)
  edge_to_cost = {e: m.add_var(var_type=mip.INTEGER, name=f'intra_{e.name}') for e in edges}
  cost_y = lambda e : v_to_indices[e.src].y - v_to_indices[e.dst].y
  cost_x = lambda e : v_to_indices[e.src].x - v_to_indices[e.dst].x

  for e, cost in edge_to_cost.items():
    m += cost >= cost_y(e) + cost_x(e)
    m += cost >= -cost_y(e) + cost_x(e)
    m += cost >= cost_y(e) - cost_x(e)
    m += cost >= -cost_y(e) - cost_x(e)

  # total wirelength
  total_wirelength = m.add_var(mip.INTEGER)
  m += total_wirelength == mip.xsum(e.width * cost for e, cost in edge_to_cost.items())  # type: ignore

  # resource usage of each slot
  idx_to_usage: DefaultDict[int, DefaultDict[int, Dict[str, mip.Var]]] = defaultdict(lambda: defaultdict(dict))
  idx_to_balance: DefaultDict[int, DefaultDict[int, Dict[str, mip.LinExpr]]] = defaultdict(lambda: defaultdict(dict))
  for x_idx in range(num_row):
    for y_idx in range(num_col):
      for r in RESOURCE_TYPES:
        total_resource = m.add_var(var_type=mip.CONTINUOUS)
        m += total_resource == mip.xsum(
          v.getVertexAndInboundFIFOArea()[r] * x_to_y_to_var[x_idx][y_idx]  # type: ignore
            for v, x_to_y_to_var in v_to_x_to_y_to_var.items()
        )

        idx_to_usage[x_idx][y_idx][r] = total_resource
        idx_to_balance[x_idx][y_idx][r] = 1 - total_resource / resources[x_idx][y_idx][r]  # type: ignore

  # resource penalty. use the actual resource subtracted by the used resource
  total_resource_balance = m.add_var(mip.CONTINUOUS)
  m += total_resource_balance == mip.xsum(
    resource_weight[r] * idx_to_balance[x_idx][y_idx][r]  # type: ignore
      for x_idx in range(num_row)
        for y_idx in range(num_col)
          for r in RESOURCE_TYPES
  )

  # subtract the most used slots by the least used slots
  min_usage = m.add_var(mip.CONTINUOUS)
  max_usage = m.add_var(mip.CONTINUOUS)
  for x_idx in range(num_row):
    for y_idx in range(num_col):
      for r in RESOURCE_TYPES:
        m += min_usage <= idx_to_balance[x_idx][y_idx][r]
        m += max_usage >= idx_to_balance[x_idx][y_idx][r]

  m.objective = mip.minimize(total_wirelength + total_resource_balance * 50000 + (max_usage - min_usage) * 10000)  # type: ignore

  m.optimize(max_seconds=max_search_time) # type: ignore

  # get results
  v_to_coor: Dict[Vertex, Tuple[int, int]] = {}
  for v, x_to_y_to_var in v_to_x_to_y_to_var.items():
    for x, y_to_var in x_to_y_to_var.items():
      for y, var in y_to_var.items():
        if var.x and int(var.x) == 1:
          v_to_coor[v] = (x, y)
    assert v in v_to_coor

  return v_to_coor
