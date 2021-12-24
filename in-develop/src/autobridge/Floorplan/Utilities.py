from collections import defaultdict
import enum
from typing import Dict, List, Literal
from autobridge.Opt.DataflowGraph import Vertex, Edge
from autobridge.Opt.Slot import Slot

RESOURCE_TYPES = ['BRAM', 'DSP', 'FF', 'LUT', 'URAM']


# partition directions
class Dir(enum.Enum):
  horizontal = 1
  vertical = 2


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
  first_visit = set()

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
  inter_edges = get_inter_edges()
  return [e for e in get_all_edges() if e not in inter_edges]
