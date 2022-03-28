import logging

from collections import defaultdict
from typing import Dict, List, Set
from autobridge.Opt.DataflowGraph import Vertex, Edge
from autobridge.Opt.Slot import Slot
from autobridge.Opt.SlotManager import SlotManager, Dir

RESOURCE_TYPES = ['BRAM', 'DSP', 'FF', 'LUT', 'URAM']

_logger = logging.getLogger('autobridge')


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


def get_total_wirelength(
    v2s: Dict[Vertex, Slot], 
) -> int:
  e_list = get_all_edges(list(v2s.keys()))
  wire_length_list = []
  for e in e_list:
    src_slot = v2s[e.src]
    dst_slot = v2s[e.dst]
    length = abs(src_slot.getPositionY() - dst_slot.getPositionY()) + \
              abs(src_slot.getPositionX() - dst_slot.getPositionX())
    wire_length_list.append(length * e.width)
  
  return sum(wire_length_list)


def get_slot_utilization(v2s: Dict[Vertex, Slot]) -> Dict[Slot, Dict[str, float]]:
  slot_to_usage = {}
  s2v = invert_v2s(v2s)
  for s, v_list in s2v.items():
    slot_to_usage[s] = {}
    for r in RESOURCE_TYPES:
      capacity = s.area[r]
      usage = sum(v.getVertexAndInboundFIFOArea()[r] for v in v_list)
      slot_to_usage[s][r] = round(usage/capacity, 3)
  return slot_to_usage


def get_eight_way_partition_slots(slot_manager: SlotManager) -> List[Slot]:
  """ get all the eight slots after eight-way partition
  """
  partition_order = [Dir.horizontal, Dir.horizontal, Dir.vertical]
  return slot_manager.getLeafSlotsAfterPartition(partition_order)


def get_four_way_partition_slots(slot_manager: SlotManager) -> List[Slot]:
  """ get all the eight slots after eight-way partition
  """
  partition_order = [Dir.horizontal, Dir.horizontal]
  return slot_manager.getLeafSlotsAfterPartition(partition_order)


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
      usage = sum(v.getVertexAndInboundFIFOArea()[r] for v in v_list)
      _logger.info(f'  [{r.ljust(4, " ")}]: {round(usage/capacity*100, 1)}% ({usage} / {capacity})')

  for s, v_list in s2v.items():
    _logger.info(f'Slot {s.getRTLModuleName()} contains:')
    for v in v_list:
      area_info = ' '.join(f'{r}: {v.getVertexAndInboundFIFOArea()[r]}' for r in RESOURCE_TYPES)
      _logger.info(f'  {v.name}: {area_info}')

  # wire information
  _logger.info(f'total wire length: {get_total_wirelength(v2s)}')

  # SLR crossing information
  try:
    slr_crossing = [0] * (_get_slr_count(list(s2v.keys())) - 1)
    e_list = get_all_edges(list(v2s.keys()))
    for e in e_list:
      src_slr = v2s[e.src].getSLR()
      dst_slr = v2s[e.dst].getSLR()
      idx_small = min(src_slr, dst_slr)
      idx_large = max(src_slr, dst_slr)
      for i in range(idx_small, idx_large):
        slr_crossing[i] += e.width

    for i, count in enumerate(slr_crossing):
      _logger.info(f'SLR boundary {i} - {i+1} has {slr_crossing[i]} crossings')
  except:
    _logger.info(f'Skip logging SLR crossing because current slots include multiple SLRs')


def _get_slr_count(slot_list: List[Slot]) -> int:
  """
  how many SLR does the board has
  """
  slr_count_list = [slot.board.SLR_NUM for slot in slot_list]
  assert all(slr_count_list[i] == slr_count_list[0] for i in range(len(slr_count_list)))
  return slr_count_list[0]


def print_vertex_areas(v_list: List[Vertex]) -> None:
  _logger.info('The area of each vertex is listed as below.')
  _logger.info('Note that the area of each vertex includes the area of all its in-bound FIFOs.')
  for v in v_list:
    _logger.info(f'    {v.name}: ' + ' '.join(f'{r}: {v.getVertexAndInboundFIFOArea()[r]}' for r in RESOURCE_TYPES))


def print_pre_assignment(v2s: Dict[Vertex, Slot]) -> None:
  _logger.info('The pre-determined floorplanning is shown as below:')
  for v, s in v2s.items():
    _logger.info(f'    {v.name}  =>  {s.getRTLModuleName()}')


def float_range(start, stop, step) -> List[float]:
  range = []
  while start <= stop:
    range.append(start)
    start = round(start + step, 2)  
  return range