import itertools
import logging
from bisect import bisect
from collections import defaultdict
from mip import Model, minimize, BINARY, xsum, OptimizationStatus, Var
from typing import List, Dict

from autobridge.Opt.DataflowGraph import Edge, Vertex
from autobridge.Opt.Slot import Slot
from autobridge.Device.DeviceManager import DeviceU250
from autobridge.util import get_mip_model_silent

U250_inst = DeviceU250()

_logger = logging.getLogger('autobridge')

BEND_COUNT_LIMIT = 2
VERTICAL_BOUNDARY_CAPACITY = 5280
SLR_CROSSING_BOUNDARY_CAPACITY = 5760
NON_SLR_CROSSING_HORIZONTAL_BOUNDARY = 9440


class RoutingVertex:
  def __init__(self, slot_name):
    self.slot_name = slot_name
    self.slot = Slot(U250_inst, slot_name)
    self.edges = []
    self.neighbors = set()

  def __eq__(self, other):
    return self.slot_name == other.slot_name

  def __hash__(self):
    return hash(self.slot_name)

  def get_down_left_x(self):
    return self.slot.down_left_x

  def get_down_left_y(self):
    return self.slot.down_left_y


class RoutingEdge:
  def __init__(self, v1: RoutingVertex, v2: RoutingVertex, total_wire_capacity, usable_wire_capacity):
    self.vertices = [v1, v2]
    self.total_capacity = total_wire_capacity
    self.capacity = usable_wire_capacity
    v1.edges.append(self)
    v2.edges.append(self)
    v1.neighbors.add(v2)
    v2.neighbors.add(v1)

    v_names = [v.slot_name for v in self.vertices]
    self._name = min(v_names) + '_To_' + max(v_names) # in case the order of vertices is different

  def __hash__(self):
    return hash(self._name)

  def __eq__(self, other):
    return self._name == other._name


class RoutingPath:
  """
  a path contains the vertcies it passed through
  """

  def __init__(
      self,
      vertices: List[RoutingVertex],
      bend_count: int,
      length_limit: int,
      data_width: int,
      fifo_name: str,
      slot_to_usage: Dict[Slot, Dict[str, float]]
  ) -> None:
    """
    a fifo is an edge in the dataflow graph.
    use fifo_name to make the path unique
    """
    self.vertices = vertices
    self.bend_count = bend_count
    self.length_limit = length_limit
    self.data_width = data_width
    self.fifo_name = fifo_name
    self.slot_to_usage = slot_to_usage
    self.edges = []

    # use fifo name to make the path name unique
    self._name = self.fifo_name + '_' + '_'.join([v.slot_name for v in self.vertices])

  def __hash__(self):
    return hash(self._name)

  def __eq__(self, other):
    return self._name == other._name

  def init_edges(self):
    """
    find all edges belong to this path based on the vertices
    """
    for i in range(len(self.vertices)-1):
      curr = self.vertices[i]
      next = self.vertices[i+1]
      e_common = [fifo for fifo in curr.edges if fifo in next.edges]
      assert len(e_common) == 1
      self.edges.append(e_common[0])

  def is_bend(self, prev, curr, next) -> bool:
    """
    check if three vertices are aligned either vertically or horizontally
    """
    if prev.get_down_left_x() == curr.get_down_left_x() and \
       next.get_down_left_x() == curr.get_down_left_x():
      return False
    elif prev.get_down_left_y() == curr.get_down_left_y() and \
         next.get_down_left_y() == curr.get_down_left_y():
      return False
    else:
      return True

  def get_child_paths(self) -> List['RoutingPath']:
    """
    extend the current path for one more vertex.
    Filter out candidates if the bend count is over the limit
    """
    curr = self.vertices[-1]
    # if the path only has one vertex, set prev to curr to be compatible with bend test
    if len(self.vertices) == 1:
      prev = curr
    else:
      prev = self.vertices[-2]

    # if a path is too long, stop generating child paths
    if len(self.vertices) > self.length_limit:
      return []

    # attempt to extend one more context from the current tail
    child_paths = []
    for next in curr.neighbors:
      if next != prev: # disable u turn at the site
        new_bend_count = self.bend_count + int(self.is_bend(prev, curr, next))

        # limit on bend count
        if new_bend_count > BEND_COUNT_LIMIT:
          continue

        child_paths.append(
          RoutingPath(
            self.vertices + [next],
            new_bend_count,
            self.length_limit,
            self.data_width,
            self.fifo_name,
            self.slot_to_usage
          )
        )
    return child_paths

  def get_dest(self) -> RoutingVertex:
    """
    get the current tail vertex of the path
    """
    return self.vertices[-1]

  def print_paths(self):
    _logger.debug(f'path from {self.vertices[0].slot_name} to {self.vertices[-1].slot_name} with cost {self.get_cost()}')
    for v in self.vertices:
      _logger.debug(f' => {v.slot_name}')

  def get_length(self) -> int:
    """
    number of vertices in this path
    """
    return len(self.vertices)

  def get_slots_in_path(self) -> List[Slot]:
    """
    get all the Slot objects corresponding to the path
    """
    return [v.slot for v in self.vertices]

  def get_shortest_path_length(self):
    """
    get the manhatten distance beween the source and destination slots
    the distance is the number of slots
    """
    src = self.vertices[0]
    dst = self.vertices[-1]
    dist_x = abs(src.get_down_left_x() - dst.get_down_left_x() ) / 2
    dist_y = abs(src.get_down_left_y() - dst.get_down_left_y() ) / 2
    return dist_x + dist_y + 1

  def get_cost(self) -> float:
    """
    calculate a cost if this slot is selected.
    We want to pass through less utilized slots as much as possible
    use the sum of DSP and BRAM percentage of each slot * wire_length
    """
    dsp_costs = [self.slot_to_usage[v.slot]['DSP'] if v.slot in self.slot_to_usage else 0 for v in self.vertices]
    bram_costs = [self.slot_to_usage[v.slot]['BRAM'] if v.slot in self.slot_to_usage else 0  for v in self.vertices]
    lut_costs = [self.slot_to_usage[v.slot]['LUT'] if v.slot in self.slot_to_usage else 0  for v in self.vertices]

    cost = (sum(dsp_costs) + sum(bram_costs) + 0.7 * sum(lut_costs) + 10 * len(self.vertices)) * self.data_width

    return round(cost, 4)

  def get_src_slot_name(self) -> str:
    return self.vertices[0].slot_name

  def get_dst_slot_name(self) -> str:
    return self.vertices[-1].slot_name


class RoutingGraph:
  def __init__(
      self,
      routing_slot_list: List[Slot],
      slot_to_usage: Dict[Slot, Dict[str, float]],
      routing_usage_limit: int,
      detour_path_limit: int,
  ) -> None:
    """
    routing_slot_list: list of all slots available for routing
    Note that if a slot is empty, it may not appear in slot_to_usage
    slot_to_usage: resource utilization of each slot
    """
    self.slot_name_to_vertex = {}
    self.edges = []
    self.slot_to_usage = slot_to_usage  # resource usage of each slot
    self.routing_usage_limit = routing_usage_limit
    self.detour_path_limit = detour_path_limit
    self.routing_slot_list = routing_slot_list
    self.init_routing_graph()

  def init_routing_graph(self):
    """ FIXME: currently hardcoded for U250/U280 slr/half-slr slots
    """
    # create routing vertices
    for s in self.routing_slot_list:
      self.slot_name_to_vertex[s.name] = RoutingVertex(s.name)

    # create routing edges
    for s1, s2 in itertools.combinations(self.routing_slot_list, 2):
      if s1.isNeightbor(s2):
        # determine the capacity of passing wires
        if s1.getSLR() != s2.getSLR():
          assert s1.down_left_x == s2.down_left_x
          assert s1.up_right_x == s2.up_right_x
          num_cr = s1.up_right_x - s1.down_left_x + 1

          # exclude the vitis region and the laguna used by system interconnects
          if s1.up_right_x == 7:
            num_cr -= 1.5

          # each clock region has 2 laguna columns, each has 1440 wires
          total_capacity = num_cr * 2880

        else:
          total_capacity = (s1.up_right_y - s1.down_left_y + 1) * 3000

        v1 = self.slot_name_to_vertex[s1.name]
        v2 = self.slot_name_to_vertex[s2.name]
        e = RoutingEdge(v1, v2, total_capacity, total_capacity * self.routing_usage_limit)
        self.edges.append(e)

  def get_shortest_dist(self, src: RoutingVertex, dst: RoutingVertex):
    """
    number of slots in the path. Include source and sink
    assume 2x2 slots
    """
    dist_x = abs(src.get_down_left_x() - dst.get_down_left_x() ) / 2
    dist_y = abs(src.get_down_left_y() - dst.get_down_left_y() ) / 2
    return dist_x + dist_y + 1

  def get_all_paths(
      self,
      src_slot: str,
      dst_slot: str,
      data_width: int,
      fifo_name: str
  ) -> List[RoutingPath]:
    """
    run BFS to get all paths that satisfy the requirement
    The path include the source and destination
    """
    src = self.slot_name_to_vertex[src_slot]
    dst = self.slot_name_to_vertex[dst_slot]
    shortest_dist = self.get_shortest_dist(src, dst)

    init_path = RoutingPath(
      vertices = [src],
      bend_count = 0,
      length_limit = shortest_dist + self.detour_path_limit,
      data_width = data_width,
      fifo_name = fifo_name,
      slot_to_usage = self.slot_to_usage
    )

    queue = [init_path]

    paths = []
    while queue:
      curr_path = queue.pop(0)

      if curr_path.get_dest() != dst:
        queue += curr_path.get_child_paths()
      else:
        curr_path.init_edges()
        paths.append(curr_path)

    assert len(set(paths)) == len(paths)
    return paths


class ILPRouter:
  def __init__(
      self,
      fifo_list: List[Edge],
      v2s: Dict[Vertex, Slot],
      slot_to_usage: Dict[Slot, Dict[str, float]],
      routing_slot_list: List[Slot],
  ) -> None:
    """
    we need to map each fifo to a set of routing edges in the routing graph
    """
    self.fifo_list = fifo_list
    self.v2s = v2s
    self.slot_to_usage = slot_to_usage
    self.routing_slot_list = routing_slot_list

    for fifo in self.fifo_list:
      src_slot_name = self.v2s[fifo.src].getRTLModuleName()
      dst_slot_name = self.v2s[fifo.dst].getRTLModuleName()
      if src_slot_name != dst_slot_name:
        _logger.info('edge %s, width %d, from %s to %s', fifo.name, fifo.width, src_slot_name, dst_slot_name)

  def get_fifo_to_candidate_paths(
      self,
      routing_usage_limit: float,
      detour_path_limit: int
  ) -> Dict[Edge, List[RoutingPath]]:
    """
    for each edge, generate the candidate paths to select from
    """
    routing_graph = RoutingGraph(self.routing_slot_list, self.slot_to_usage, routing_usage_limit, detour_path_limit)

    fifo_to_paths = {}
    for fifo in self.fifo_list:
      src_slot_name = self.v2s[fifo.src].getRTLModuleName()
      dst_slot_name = self.v2s[fifo.dst].getRTLModuleName()
      path_candidates = routing_graph.get_all_paths(
        src_slot_name, dst_slot_name, fifo.width, fifo.name
      )

      _logger.debug(f'fifo {fifo.name} has candidate paths:')
      for path in path_candidates:
        path.print_paths()

      fifo_to_paths[fifo] = path_candidates

    return fifo_to_paths

  def get_routing_edge_to_passing_paths(
      self, fifo_to_paths: Dict[Edge, List[RoutingPath]]
  ) -> Dict[RoutingEdge, List[RoutingPath]]:
    """
    for each routing edge, get all fifo and corresponding path candidates that go through it.
    """
    routing_edge_to_paths = defaultdict(list)
    for fifo, path_list in fifo_to_paths.items():
      for path in path_list:
        for routing_edge in path.edges:
          routing_edge_to_paths[routing_edge].append(path)

    return routing_edge_to_paths

  def get_path_to_var(self, m: Model, fifo_to_paths: Dict[Edge, List[RoutingPath]]):
    """
    for each fifo, for each candidate path,
    create a variable to represent if this candidate path is selected
    """
    path_to_var = {}
    for fifo, path_list in fifo_to_paths.items():
      for path in path_list:
        assert path not in path_to_var
        # weight matching model, relax the variable to continous
        path_to_var[path] = m.add_var(var_type=BINARY, lb=0, ub=1)

    return path_to_var

  def constrain_fifo_to_one_path(
      self,
      m: Model,
      fifo_to_paths: Dict[Edge, List[RoutingPath]],
      path_to_var: Dict[RoutingPath, Var]
  ) -> None:
    """
    for each fifo, only one candidate path is selected
    """
    for paths in fifo_to_paths.values():
      m += xsum([path_to_var[path] for path in paths]) == 1

  def constrain_routing_edge_capacity(
      self,
      m: Model,
      path_to_var: Dict[RoutingPath, Var],
      routing_edge_to_paths: Dict[RoutingEdge, List[RoutingPath]]
  ) -> None:
    """
    for each routing edge, limit the paths that go through a routing edge
    """
    for routing_edge, paths in routing_edge_to_paths.items():
      m += xsum(path_to_var[path] * path.data_width for path in paths) <= routing_edge.capacity

  def add_opt_goal(
      self,
      m: Model,
      fifo_to_paths: Dict[Edge, List[RoutingPath]],
      path_to_var: Dict[RoutingPath, Var]
  ) -> None:
    """
    minimize the total length * width of all selected paths
    """
    # concatenate to get all paths
    all_paths: List[RoutingPath] = sum(fifo_to_paths.values(), [])
    m.objective = minimize(
      xsum(path_to_var[path] * path.get_cost() for path in all_paths)
    )

  def analyze_routing_results(
    self,
    fifo_to_paths,
    fifo_to_selected_path,
    routing_edge_to_selected_paths
  ) -> None:
    # log the quality of the selected path
    for fifo, paths in fifo_to_paths.items():
      if len(paths) > 1:
        all_costs = [p.get_cost() for p in paths]
        all_costs.sort()
        selected_path = fifo_to_selected_path[fifo]
        rank = bisect(all_costs, selected_path.get_cost())

        rank_info = f'{fifo.name} from {selected_path.get_src_slot_name()} to {selected_path.get_dst_slot_name()} is routed with the rank {rank} / {len(all_costs)} path. '
        overall_info = f'Path cost: {selected_path.get_cost()}. All costs: {all_costs}'
        _logger.debug(rank_info + overall_info)

    # log the utilization ratio of each boundary
    for routing_edge, paths in routing_edge_to_selected_paths.items():
      total_data_width = sum([path.data_width for path in paths])
      _logger.info(f'boundary {routing_edge._name} is passed by {total_data_width} / {routing_edge.total_capacity} = {total_data_width / routing_edge.total_capacity} ')
      for path in paths:
        _logger.debug(f'  {path.fifo_name}')

  def get_routing_results(
    self,
    fifo_to_paths: Dict[Edge, List[RoutingPath]],
    path_to_var,
    routing_edge_to_paths: Dict[RoutingEdge, List[RoutingPath]]
  ) -> Dict[str, List[Slot]]:

    # get the selected paths
    fifo_to_selected_path = {}
    for fifo, paths in fifo_to_paths.items():
      for path in paths:
        val = path_to_var[path].x
        assert abs(val - round(val)) < 0.0001
        if round(val) == 1:
          fifo_to_selected_path[fifo] = path
          _logger.debug(f'fifo {fifo.name} is routed to: ')
          path.print_paths()
          if path.get_length() > path.get_shortest_path_length():
            _logger.warning(f'{fifo.name} is not routed with the shortest paths')

          break
      assert fifo in fifo_to_selected_path

    # get which paths will pass through a boundary
    routing_edge_to_selected_paths = defaultdict(list)
    for routing_edge, paths in routing_edge_to_paths.items():
      _logger.debug(f'boundary {routing_edge._name} is passed by:')
      for path in paths:
        val = path_to_var[path].x
        if round(val) == 1:
          routing_edge_to_selected_paths[routing_edge].append(path)
          _logger.debug(f'  {path.fifo_name}')

    return fifo_to_selected_path, routing_edge_to_selected_paths

  def get_fifo_to_path_exclude_src_dst(self, fifo_to_selected_path):
    e_name_to_paths = {}
    # exclude the source and destination to feed back to the outside world
    for fifo, selected_path in fifo_to_selected_path.items():
      e_name_to_paths[fifo.name] = selected_path.get_slots_in_path()[1:-1]

    return e_name_to_paths

  def route_design(
      self,
      routing_usage_limit: float = 0.6,
      detour_path_limit: int = 4
  ) -> Dict[Edge, List[Slot]]:

    while 1:
      if routing_usage_limit > 1:
        _logger.error(f'Global routing failed')
        exit(1)

      _logger.info(f'Global routing attempt with routing usage limit {routing_usage_limit}')

      m = get_mip_model_silent()

      fifo_to_paths = self.get_fifo_to_candidate_paths(routing_usage_limit, detour_path_limit)
      path_to_var = self.get_path_to_var(m, fifo_to_paths)
      routing_edge_to_paths = self.get_routing_edge_to_passing_paths(fifo_to_paths)

      _logger.info(f'there are {len(fifo_to_paths)} dataflow edges')
      _logger.info(f'there are {len(path_to_var)} potential paths to select from')

      self.constrain_fifo_to_one_path(m, fifo_to_paths, path_to_var)

      self.constrain_routing_edge_capacity(m, path_to_var, routing_edge_to_paths)

      self.add_opt_goal(m, fifo_to_paths, path_to_var)

      status = m.optimize()

      if status == OptimizationStatus.OPTIMAL:
        _logger.warning(f'Succeeded: global routing attempt with routing usage limit {routing_usage_limit}')
        break
      else:
        _logger.warning(f'Failed: global routing attempt with routing usage limit {routing_usage_limit}')
        routing_usage_limit += 0.03

    # extract results
    fifo_to_selected_path, routing_edge_to_selected_paths = \
      self.get_routing_results(fifo_to_paths, path_to_var, routing_edge_to_paths)

    # _logger and analysis
    self.analyze_routing_results(fifo_to_paths, fifo_to_selected_path, routing_edge_to_selected_paths)

    fifo_to_slots = {fifo: path.get_slots_in_path() for fifo, path in fifo_to_selected_path.items()}
    return fifo_to_slots


if __name__ == '__main__':
  routing_graph = RoutingGraph()

  # paths = routing_graph.get_all_paths('CR_X4Y0_To_CR_X5Y1', 'CR_X4Y8_To_CR_X5Y9', 10, 'test_name')
  # print(len(paths))

  paths = routing_graph.get_all_paths('CR_X4Y2_To_CR_X5Y3', 'CR_X4Y8_To_CR_X5Y9', 10, 'test_name')
  print(len(paths))

  for path in paths:
    path.print_paths()