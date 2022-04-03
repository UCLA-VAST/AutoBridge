import logging

from typing import Dict, List, Optional
from mip import Model, Var, minimize, xsum, BINARY, INTEGER, OptimizationStatus

from autobridge.Floorplan.Utilities import *
from autobridge.Opt.DataflowGraph import Vertex
from autobridge.Opt.Slot import Slot
from autobridge.Opt.SlotManager import SlotManager, Dir
from autobridge.util import get_mip_model_silent

_logger = logging.getLogger('autobridge')


class Bipartition:
  def __init__(
    self,
    curr_v2s: Dict[Vertex, Slot],
    grouping_constraints: List[List[Vertex]],
    pre_assignments: Dict[Vertex, Slot],
    slot_manager: SlotManager,
  ):
    """
    grouping_constraints: which modules should be assigned to the same slot
    pre_assignment: pre-determined module -> slot mapping
    """
    self.grouping_constraints = grouping_constraints
    self.pre_assignment = pre_assignments
    self.slot_manager = slot_manager

    self.set_curr_v2s(curr_v2s)

  def set_curr_v2s(self, curr_v2s: Dict[Vertex, Slot]):
    self.curr_v2s = curr_v2s
    self.curr_s2v = invert_v2s(curr_v2s)

  def get_bipartition(
      self, 
      direction: Dir,
      max_usage_ratio: float,
      max_search_time: int,
  ) -> Optional[Dict[Vertex, Slot]]:
    """
    bi-partition all the current slots
    """
    m = get_mip_model_silent()

    v2var = self._create_ilp_vars(m)

    self._add_opt_goal(m, v2var, direction)

    # area constraints for each child slot
    self._add_area_constraints(m, v2var, direction, max_usage_ratio)

    self._add_pre_assignment(m, v2var, direction)

    self._add_grouping_constraints(m, v2var)

    m.optimize(max_seconds=max_search_time)

    next_v2s = self._get_partition_result(m, v2var, direction)
    if not next_v2s:
      _logger.debug(f'bi-partioning failed with usage ratio {max_usage_ratio}')

    return next_v2s

  def get_bipartition_adjust_ratio(
      self,
      direction: Dir,
      ref_usage_ratio: float,
      usage_ratio_delta: float = 0.02,
      max_search_time: int = 120
  ) -> Dict[Vertex, Slot]:
    """
    increase the ref_usage_ratio until succeed. Each time increment usage_ratio_delta
    and retry.
    """
    curr_usage_ratio = ref_usage_ratio

    while 1:
      _logger.debug(f'Attempt bipartition with a usage ratio of {curr_usage_ratio} and max search time {max_search_time}s')
      next_v2s = self.get_bipartition(direction, curr_usage_ratio, max_search_time)
      if not next_v2s:
        curr_usage_ratio += usage_ratio_delta
        curr_usage_ratio = round(curr_usage_ratio, 2)
      else:
        break
    _logger.info(f'Finish bipartition with a usage ratio of {curr_usage_ratio}')

    return next_v2s

  ############################################################################

  def _create_ilp_vars(self, m: Model):
    """
    create a binary var for each vertex
    the var indicates if a vertex is assigned to the up/right child slot or the down/left child slot
    """
    v2var: Dict[str, Var] = {} # str -> [mip_var]
    for v in self.curr_v2s.keys():
      v2var[v] = m.add_var(var_type=BINARY, name=f'{v.name}_x')
    return v2var

  def _add_opt_goal(
      self, 
      m: Model, 
      v2var: Dict[str, Var], 
      direction: Dir
  ) -> None:
    """
    minimize the weighted sum over all edges
    """
    edge_list = get_all_edges(list(self.curr_v2s.keys()))
    e2cost_var = {
      e: m.add_var(var_type=INTEGER, name=f'e_cost_{e.name}') for e in edge_list
    }

    def _get_loc_after_partition(v: Vertex):
      if direction == Dir.vertical:
        return self.curr_v2s[v].getQuarterPositionX() + v2var[v] * self.curr_v2s[v].getHalfLenX()
      elif direction == Dir.horizontal:
        return self.curr_v2s[v].getQuarterPositionY() + v2var[v] * self.curr_v2s[v].getHalfLenY()
      else:
        assert False

    for e, cost_var in e2cost_var.items():
      m += cost_var >= _get_loc_after_partition(e.src) - _get_loc_after_partition(e.dst)
      m += cost_var >= _get_loc_after_partition(e.dst) - _get_loc_after_partition(e.src)

    m.objective = minimize( xsum(cost_var * e.width for e, cost_var in e2cost_var.items()) )

  def _add_area_constraints(
      self, 
      m: Model, 
      v2var: Dict[str, Var], 
      direction: Dir,
      max_usage_ratio: float,
  ) -> None:
    for s, v_group in self.curr_s2v.items():
      bottom_or_left, up_or_right = self.slot_manager.partitionSlotByHalf(s, direction)

      for r in RESOURCE_TYPES:
        v_var_list = [v2var[v] for v in v_group]
        area_list = [v.getVertexAndInboundFIFOArea()[r] for v in v_group]
        I = range(len(v_group))

        # for the up/right child slot (if mod_x is assigned 1)
        m += xsum( v_var_list[i] * area_list[i] for i in I ) <= up_or_right.getArea()[r] * max_usage_ratio

        # for the down/left child slot (if mod_x is assigned 0)
        m += xsum( (1-v_var_list[i]) * area_list[i] for i in I ) <= bottom_or_left.getArea()[r] * max_usage_ratio

  def _add_pre_assignment(
      self,
      m: Model,
      v2var: Dict[str, Var], 
      direction: Dir,
  ) -> None:
    """
    user specifies that certain Vertices must be assigned to certain slots
    """
    for v, expect_slot in self.pre_assignment.items():
      curr_slot = self.curr_v2s[v]
      bottom_or_left, up_or_right = self.slot_manager.partitionSlotByHalf(curr_slot, direction)
      if bottom_or_left.containsChildSlot(expect_slot):
        _logger.debug(f'[specified assignment] {v.name} assigned to bottom/left')
        m += v2var[v] == 0
      elif up_or_right.containsChildSlot(expect_slot):
        _logger.debug(f'[specified assignment] {v.name} assigned to up/right')
        m += v2var[v] == 1
      else:
        _logger.warning(f'Potential wrong constraints from user: {v.name} -> {expect_slot.getName()}')
        assert False

  def _add_grouping_constraints(
      self, 
      m: Model,
      v2var: Dict[str, Var], 
  ) -> None:
    """
    user specifies that certain Vertices must be assigned to the same slot
    """
    for grouping in self.grouping_constraints:
      for i in range(1, len(grouping)):
        m += v2var[grouping[0]] == v2var[grouping[i]]

  def _get_partition_result(
      self,
      m: Model,
      v2var: Dict[str, Var], 
      direction: Dir,
  ) -> Optional[Dict[Vertex, Slot]]:
    """
    extract the results from the ILP solver
    """
    if m.status != OptimizationStatus.OPTIMAL and m.status != OptimizationStatus.FEASIBLE:
      return {}

    # create new mapping
    next_v2s = {}
    for s, v_group in self.curr_s2v.items():
      bottom_or_left, up_or_right = self.slot_manager.partitionSlotByHalf(s, direction)

      for v in v_group:
        # if v is assigned to 0-half in the i-th solution
        if round(v2var[v].x) == 0:
          next_v2s[v] = bottom_or_left
        # if v is assigned to 1-half in the i-th solution
        elif round(v2var[v].x) == 1:
          next_v2s[v] = up_or_right

        else:
          assert False, v2var[v].x

    return next_v2s
