import logging
from mip import *

class LatencyBalancing:
  def __init__(self, graph, floorplan, global_router):
    logging.info('running latency balancing...')
    self.name2edge = graph.getNameToEdgeMap()
    self.name2vertex = graph.getNameToVertexMap()
    self.floorplan = floorplan
    self.global_router = global_router
    self.e_name2lat = {}

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
      m += v2var[e.src] >= v2var[e.dst] + self.global_router.getPipelineLevelOfEdge(e)

    m.objective = minimize(xsum( 
      e.width * (v2var[e.src] - v2var[e.dst]) for e in self.name2edge.values() 
    ))

    status = m.optimize(max_seconds=120)
    assert status == OptimizationStatus.OPTIMAL or status == OptimizationStatus.FEASIBLE, 'Failed to balance reconvergent paths at loop level. Dependency loop detected.'

    # get result
    for e_name, e in self.name2edge.items():
      e.latency = int(v2var[e.src].x - v2var[e.dst].x)
      self.e_name2lat[e_name] = e.latency

    # logging
    for e_name, e in self.name2edge.items():
      orig_lat = self.global_router.getPipelineLevelOfEdge(e)
      new_lat = self.e_name2lat[e_name]
      logging.info(f'{e_name}: latency from {orig_lat} to {new_lat}, area from {orig_lat * e.width} to {new_lat * e.width} ')

  def getLatencyofEdgeName(self, e_name : str):
    return self.e_name2lat[e_name]