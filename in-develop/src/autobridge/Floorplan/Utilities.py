import logging

from collections import defaultdict
from typing import Dict, List, Set
from autobridge.Opt.DataflowGraph import Vertex, Edge
from autobridge.Opt.Slot import Slot

RESOURCE_TYPES = ['BRAM', 'DSP', 'FF', 'LUT', 'URAM']

_logger = logging.getLogger().getChild(__name__)


def invert_v2s(curr_v2s: Dict[Vertex, Slot]) -> Dict[Slot, List[Vertex]]:
  s2v = defaultdict(list)
  for v, s in curr_v2s.items():
    s2v[s].append(v)
  return dict(s2v)


def get_all_edges(v_group: List[Vertex]) -> List[Edge]:
  """
  """
  return list(set([e for v in v_group for e in v.getEdges()]))


def get_inter_edges(v_group: List[Vertex]) -> List[Edge]:
  """
  get edges such that either src or sink is among v_group
  """
  first_visit: Set[Edge] = set()

  # if an edge is visited twice, then it is entirely within the target slots
  # if an edge is visited only once, then it is between the target slots and the remaining slots
  for e in get_all_edges(v_group):
    if e in first_visit:
      first_visit.remove(e)
    else:
      first_visit.add(e)

  inter_edges = list(first_visit)

  return inter_edges


def get_intra_edges(v_group: List[Vertex]) -> List[Edge]:
  """
  get edges whose src and sink are all among v_group
  """
  inter_edges = get_inter_edges(v_group)
  return [e for e in get_all_edges(v_group) if e not in inter_edges]


def log_resource_utilization(
    v2s: Dict[Vertex, Slot], 
) -> None:
  """
  analyze and log the new floorplan results
  """
  s2v = invert_v2s(v2s)
  for s, v_list in s2v.items():
    _logger.info(f'Slot {s.getRTLModuleName()}:')
    for r in RESOURCE_TYPES:
      capacity = s.area[r]
      usage = sum(v.area[r] for v in v_list)
      _logger.info(f'  [{r.ljust(4, " ")}]: {round(usage/capacity*100, 1)}% ({usage} / {capacity})')