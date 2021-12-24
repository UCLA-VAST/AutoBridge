import enum
import logging
import autobridge.Floorplan.Utilities as util

from typing import Dict, List
from mip import Model, Var, minimize, xsum, BINARY, INTEGER, OptimizationStatus
from autobridge.Opt.DataflowGraph import Vertex
from autobridge.Opt.Slot import Slot
from autobridge.Opt.SlotManager import SlotManager

_logger = logging.getLogger().getChild(__name__)


class Dir(enum.Enum):
  horizontal = 1
  vertical = 2


class Bipartition:
  def __init__(
    self,
    curr_v2s: Dict[Vertex, Slot],
    grouping_constraints: List[List[str]],
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

    self._set_curr_v2s(curr_v2s)

  def _set_curr_v2s(self, curr_v2s: Dict[Vertex, Slot]):
    self.curr_v2s = curr_v2s
    self.curr_s2v = util.invert_v2s(curr_v2s)

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
    edge_list = util.get_all_edges(list(self.curr_v2s.keys()))
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

      for r in util.RESOURCE_TYPES:
        v_var_list = [v2var[v] for v in v_group]
        area_list = [v.area[r] for v in v_group]
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
    v_name_to_v = {v.name : v for v in self.curr_v2s.keys()}

    for grouping in self.grouping_constraints:
      for i in range(1, len(grouping)):
        _logger.info(f'[grouping] {grouping[0]} is grouped with {grouping[i]}')
        m += v2var[v_name_to_v[grouping[0]]] == v2var[v_name_to_v[grouping[i]]]

  def _get_partition_result(
      self,
      m: Model,
      v2var: Dict[str, Var], 
      direction: Dir,
  ) -> Dict[Vertex, Slot]:
    """
    """
    if m.status != OptimizationStatus.OPTIMAL and m.status != OptimizationStatus.FEASIBLE:
      _logger.warning('2-way partioning failed!')
      return {}, {}

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

  def get_bipartition(
      self, 
      direction: Dir,
      max_usage_ratio: float,
  ) -> Dict[Vertex, Slot]:
    """
    bi-partition all the current slots
    """
    m = Model()
    if not _logger.isEnabledFor(logging.DEBUG):
      m.verbose = 0

    v2var = self._create_ilp_vars(m)

    self._add_opt_goal(m, v2var, direction)

    # area constraints for each child slot
    self._add_area_constraints(m, v2var, direction, max_usage_ratio)

    self._add_pre_assignment(m, v2var, direction)

    self._add_grouping_constraints(m, v2var)

    _logger.info('Start the ILP solver')
    m.optimize(max_seconds=self.max_search_time)

    next_v2s = self._get_partition_result(m, v2var, direction)

    return next_v2s