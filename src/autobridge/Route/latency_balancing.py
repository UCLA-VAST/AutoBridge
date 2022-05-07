import logging
from typing import List, Dict

from autobridge.util import get_mip_model_silent
from autobridge.Opt.DataflowGraph import Edge, Vertex
from autobridge.Opt.Slot import Slot
from autobridge.util import get_cli_logger
from mip import INTEGER, minimize, xsum, OptimizationStatus

_logger = logging.getLogger('autobridge')
cli_logger = get_cli_logger()


def get_latency(path: List[Slot]) -> int:
  """[TODO] This function should synchronize with the codegen"""
  return len(path)


def latency_balancing(graph, fifo_to_path) -> Dict[str, int]:
    name_to_edge: Dict[str, Edge] = graph.getNameToEdgeMap()
    name_to_vertex: Dict[str, Vertex] = graph.getNameToVertexMap()

    m = get_mip_model_silent()

    # map Vertex -> "arrival time"
    vertex_to_var = {}
    for name, v in name_to_vertex.items():
      vertex_to_var[v] = m.add_var(var_type=INTEGER, name=name)

    # differential constraint for each edge
    for e_name, e in name_to_edge.items():
      # +1 because each FIFO by itself has 1 unit of latency
      # in case the original design is not balanced
      # note that additional pipelining for full_n will not lead to additional latency
      # we only need to increase the grace period of almost full FIFOs by 1
      # [update]: we skip the +1 for the orginial FIFO. We only take care of our own modifications
      m += vertex_to_var[e.src] >= vertex_to_var[e.dst] + get_latency(fifo_to_path[e])

    m.objective = minimize(xsum(
      e.width * (vertex_to_var[e.src] - vertex_to_var[e.dst]) for e in name_to_edge.values()
    ))

    status = m.optimize(max_seconds=120)
    if status != OptimizationStatus.OPTIMAL and status != OptimizationStatus.FEASIBLE:
      cli_logger.warning('Failed to balance reconvergent paths at loop level. Most likely there is a loop of streams.')
      return {}

    # get result
    fifo_name_to_depth = {}
    for e_name, e in name_to_edge.items():
      e.added_depth_for_rebalance = int(vertex_to_var[e.src].x - vertex_to_var[e.dst].x) - e.pipeline_level
      fifo_name_to_depth[e_name] = e.depth + e.added_depth_for_rebalance
      assert e.added_depth_for_rebalance >= 0

    # logging
    for e_name, e in name_to_edge.items():
      _logger.info(f'{e_name}: pipeline_level: {e.pipeline_level}, original depth: {e.depth}, added_depth_for_rebalance: {e.added_depth_for_rebalance}, width: {e.width} ')

    return fifo_name_to_depth
