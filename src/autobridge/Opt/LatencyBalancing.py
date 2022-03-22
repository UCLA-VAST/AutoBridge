import logging
from mip import *

class LatencyBalancing:
  def __init__(self, graph, floorplan, global_router):
    logging.info('running latency balancing...')
    self.name2edge = graph.getNameToEdgeMap()
    self.name2vertex = graph.getNameToVertexMap()
    self.floorplan = floorplan
    self.global_router = global_router

    self.__rebalance()

  def __rebalance(self):
    m = Model()

    # map Vertex -> "arrival time"
    v2var = {}
    for name, v in self.name2vertex.items():
      v2var[v] = m.add_var(var_type=INTEGER, name=name)

    # differential constraint for each edge
    for e_name, e in self.name2edge.items():
      # +1 because each FIFO by itself has 1 unit of latency
      # in case the original design is not balanced
      # note that additional pipelining for full_n will not lead to additional latency
      # we only need to increase the grace period of almost full FIFOs by 1
      # [update]: we skip the +1 for the orginial FIFO. We only take care of our own modifications
      m += v2var[e.src] >= v2var[e.dst] + e.pipeline_level

    m.objective = minimize(xsum( 
      e.width * (v2var[e.src] - v2var[e.dst]) for e in self.name2edge.values() 
    ))

    status = m.optimize(max_seconds=120)
    assert status == OptimizationStatus.OPTIMAL or status == OptimizationStatus.FEASIBLE, 'Failed to balance reconvergent paths at loop level. Dependency loop detected.'

    # get result
    for e_name, e in self.name2edge.items():
      e.added_depth_for_rebalance = int(v2var[e.src].x - v2var[e.dst].x) - e.pipeline_level
      assert e.added_depth_for_rebalance >= 0

    # logging
    for e_name, e in self.name2edge.items():
      logging.info(f'{e_name}: pipeline_level: {e.pipeline_level}, added_depth_for_rebalance: {e.added_depth_for_rebalance}, width: {e.width} ')
