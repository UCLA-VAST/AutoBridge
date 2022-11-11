import logging

from typing import Dict, List, Tuple, DefaultDict
from collections import defaultdict

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


def _get_total_resources(
    resources: Dict[int, Dict[int, Dict[str, int]]]
) -> Dict[str, int]:
  total = {r: 0 for r in RESOURCE_TYPES}
  for x, y_to_r_to_val in resources.items():
    for y, r_to_val in y_to_r_to_val.items():
      for r, val in r_to_val.items():
        total[r] += val
  return total


def _get_slot_weight(
    resources: Dict[int, Dict[int, Dict[str, int]]]
) -> DefaultDict[int, DefaultDict[int, Dict[str, float]]]:
  """area of current slot over the total area"""
  total_resource = _get_total_resources(resources)
  slot_to_weight: DefaultDict[int, DefaultDict[int, Dict[str, float]]] = defaultdict(lambda: defaultdict(dict))
  for x, y_to_r_to_val in resources.items():
    for y, r_to_val in y_to_r_to_val.items():
      for r, val in r_to_val.items():
        slot_to_weight[x][y][r] = val / total_resource[r]
  return slot_to_weight


def floorplan_core(
  vertices: List[Vertex],
  grouping_constraints: List[List[Vertex]],
  pre_assignments: Dict[Vertex, Tuple[int, int]],
  num_row: int,
  num_col: int,
  resources: Dict[int, Dict[int, Dict[str, int]]],
  resource_weight: Dict[str, int],
  max_search_time: int,
  usage_penalty_weight: int,
  variance_penalty_weight: int,
) -> Dict[Vertex, Tuple[int, int]]:
  """
  resources[x][y][t] => the number of available resource of type t in slot (x,y)
  FIXME: currently use v.getVertexAndInboundFIFOArea() to get area.
  Should treat a FIFO as a vertex
  """
  # safety check
  assert all(resources[x][y] for y in range(num_row) for x in range(num_col))

  m = mip.Model()

  # create a binary decision var for each slot for each vertex
  # v_to_x_to_y_to_var[v][x][y] is true if vertex v is assigned to (x,y)
  v_to_x_to_y_to_var: DefaultDict[Vertex, DefaultDict[int, Dict[int, mip.Var]]] = defaultdict(lambda: defaultdict(dict))
  v_to_all_vars: DefaultDict[Vertex, List[VarInfo]] = defaultdict(list) # all decision vars of a vertex
  for v in vertices:
    for y in range(num_row):
      for x in range(num_col):
        var = m.add_var(var_type=mip.BINARY)
        v_to_all_vars[v].append(VarInfo(var, x, y))
        v_to_x_to_y_to_var[v][x][y] = var

  # each vertex is only assigned to one slot
  for v, vars in v_to_all_vars.items():
    m.add_constr(mip.xsum(var.var for var in vars) == 1)

  # represent the index of each vertex
  v_to_indices: Dict[Vertex, Coordinate] = {}
  for v, vars in v_to_all_vars.items():
    x_coor = m.add_var(var_type=mip.INTEGER)
    y_coor = m.add_var(var_type=mip.INTEGER)
    m += mip.xsum(var.var * var.x for var in vars) == x_coor  # type: ignore
    m += mip.xsum(var.var * var.y for var in vars) == y_coor  # type: ignore
    v_to_indices[v] = Coordinate(x_coor, y_coor)

  # pre assignemnts
  for v, coordinates in pre_assignments.items():
    coor_vars = v_to_indices[v]
    m += coor_vars.x == coordinates[0]
    m += coor_vars.y == coordinates[1]

  # group constraints. Set the coordinates of all vertices to be the same
  # as the first vertex in the group
  for group in grouping_constraints:
    for i in range(1, len(group)):
      m += v_to_indices[group[0]].x == v_to_indices[group[i]].x
      m += v_to_indices[group[0]].y == v_to_indices[group[i]].y

  # distance of each edge
  edges = get_all_edges(vertices)
  edge_to_length = {e: m.add_var(var_type=mip.INTEGER) for e in edges}
  length_y = lambda e : v_to_indices[e.src].y - v_to_indices[e.dst].y
  length_x = lambda e : v_to_indices[e.src].x - v_to_indices[e.dst].x

  # unknown of the signs of length y and length x
  for e, length in edge_to_length.items():
    m += length >= length_y(e) + length_x(e)
    m += length >= -length_y(e) + length_x(e)
    m += length >= length_y(e) - length_x(e)
    m += length >= -length_y(e) - length_x(e)

  # total wirelength
  total_wirelength = m.add_var(mip.INTEGER)
  m += total_wirelength == mip.xsum(e.width * length for e, length in edge_to_length.items())  # type: ignore

  # used resource / total resource in each slot
  coor_to_usage_ratio: DefaultDict[int, DefaultDict[int, Dict[str, mip.LinExpr]]] = defaultdict(lambda: defaultdict(dict))
  for y_coor in range(num_row):
    for x_coor in range(num_col):
      for r in RESOURCE_TYPES:
        total_usage_var = m.add_var(var_type=mip.CONTINUOUS)
        m += total_usage_var == mip.xsum(
          # FIXME: should treat a FIFO as an vertex as well. Edge should be pure wires
          v.getVertexAndInboundFIFOArea()[r] * x_to_y_to_var[x_coor][y_coor]  # type: ignore
            for v, x_to_y_to_var in v_to_x_to_y_to_var.items()
        )
        coor_to_usage_ratio[x_coor][y_coor][r] = total_usage_var / resources[x_coor][y_coor][r]  # type: ignore

  # resource penalty. use the actual resource subtracted by the used resource
  # the weight of each slot is determined by its area over the total area
  # also multiplied by an optional weight for each resource type
  slot_to_weight = _get_slot_weight(resources)
  usage_penalty_var = m.add_var(mip.CONTINUOUS)
  m += usage_penalty_var == mip.xsum(
    resource_weight[r] * slot_to_weight[x_coor][y_coor][r] * # type: ignore
      coor_to_usage_ratio[x_coor][y_coor][r]
      for y_coor in range(num_row)
        for x_coor in range(num_col)
          for r in RESOURCE_TYPES
  )

  # subtract the most used slots by the least used slots
  resource_to_usage_var: Dict[str, Tuple[mip.Var, mip.Var]] = {}
  for r in RESOURCE_TYPES:
    min_usage = m.add_var(mip.CONTINUOUS)
    max_usage = m.add_var(mip.CONTINUOUS)
    for y_coor in range(num_row):
      for x_coor in range(num_col):
        m += min_usage <= coor_to_usage_ratio[x_coor][y_coor][r]
        m += max_usage >= coor_to_usage_ratio[x_coor][y_coor][r]
    resource_to_usage_var[r] = (min_usage, max_usage)

  m.objective = mip.minimize(
    total_wirelength +
    usage_penalty_var * usage_penalty_weight +   # type: ignore
    mip.xsum(
      (max_usage - min_usage) * variance_penalty_weight  # type: ignore
        for type, (min_usage, max_usage) in resource_to_usage_var.items()
    )
  )

  status = m.optimize(max_seconds=max_search_time) # type: ignore

  # get results
  v_to_coor: Dict[Vertex, Tuple[int, int]] = {}

  if status in (mip.OptimizationStatus.OPTIMAL, mip.OptimizationStatus.FEASIBLE):
    for v, coor in v_to_indices.items():
      v_to_coor[v] = (int(coor.x.x), int(coor.y.x))  # type: ignore

    # show metrics
    for x, y_to_type_to_ratio in coor_to_usage_ratio.items():
      for y, type_to_ratio in y_to_type_to_ratio.items():
        _logger.info(f'usage ratio of slot ({x}, {y}):')
        for type, ratio in type_to_ratio.items():
          total = resources[x][y][type]
          val = round(ratio.x, 4)  # type: ignore
          _logger.info(f'  {type}: {val} of {total}')

    _logger.info(f'total wirelength: {total_wirelength.x}')
    _logger.info(f'resource usage penalty: {usage_penalty_var.x}, weight: {usage_penalty_weight}')
    for type, (min_usage, max_usage) in resource_to_usage_var.items():
      _logger.info(f'{type} max_usage: {max_usage.x}, min_usage: {min_usage.x}, weight: {variance_penalty_weight}')

  else:
    _logger.warning(f'failed to find a solution')

  return v_to_coor


# FIXME: temp test code
from autobridge.Opt.Slot import Slot
from autobridge.Opt.SlotManager import SlotManager
from autobridge.Floorplan.u280_resource import resources
cli_logger = logging.getLogger('general')

def eight_way_partition_new(
  init_v2s: Dict[Vertex, Slot],
  grouping_constraints: List[List[Vertex]],
  pre_assignments: Dict[Vertex, Slot],
  slot_manager: SlotManager,
  max_usage_ratio: float,
  slr_width_limit: int,
  max_search_time: int,
  hbm_port_v_list: List[Vertex] = [],
) -> Dict[Vertex, Slot]:
  cli_logger.info('start the new floorplan testing')

  v_list = list(init_v2s.keys())

  calibrated_resources = {0: {0: {}}}
  for x, y_to_r_to_val in resources.items():
    for y, r_to_val in y_to_r_to_val.items():
      for r, val in r_to_val.items():
        calibrated_resources[x][y][r] = val * max_usage_ratio

  def get_coordinate(slot: Slot) -> Tuple[int, int]:
    if slot.down_left_x == 0 and slot.down_left_y == 0:
      return (0, 0)
    elif slot.down_left_x == 0 and slot.down_left_y == 4:
      return (0, 1)
    elif slot.down_left_x == 0 and slot.down_left_y == 8:
      return (0, 2)
    elif slot.down_left_x == 4 and slot.down_left_y == 0:
      return (1, 0)
    elif slot.down_left_x == 4 and slot.down_left_y == 4:
      return (1, 1)
    elif slot.down_left_x == 4 and slot.down_left_y == 8:
      return (1, 2)
    else:
      assert False

  def get_slot(x: int, y: int) -> Slot:
    return slot_manager.createSlot(f'CLOCKREGION_X{x*4}Y{y*4}:CLOCKREGION_X{x*4+3}Y{y*4+3}')

  pre_assignments_to_coor = {v: get_coordinate(slot) for v, slot in pre_assignments.items()}

  resource_weight = {
  "BRAM" :  1,
  "DSP"  :  1,
  "FF"   :  1,
  "LUT"  :  1,
  "URAM" :  1,
  }

  v_to_coor = floorplan_core(
    v_list,
    grouping_constraints,
    pre_assignments_to_coor,
    num_row=3,
    num_col=2,
    resources=calibrated_resources,
    resource_weight=resource_weight,
    max_search_time=max_search_time,
    usage_penalty_weight=50000,
    variance_penalty_weight=50000,
  )

  v_to_slot = {v: get_slot(x, y) for v, (x, y) in v_to_coor.items()}

  return v_to_slot
