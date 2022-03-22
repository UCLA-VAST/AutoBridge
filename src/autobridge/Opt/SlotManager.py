import enum
import re
import math

from typing import List
from autobridge.Opt.Slot import Slot


# partition directions
class Dir(enum.Enum):
  horizontal = 1
  vertical = 2


class SlotManager:
  def __init__(self, board):
    self.board = board
    self.pblock_to_slot = {}
    self.pblock_to_routing_slot = {}

  def _preprocessPblock(self, pblock : str) -> str:
    def _convertCoarseRegionToClockRegion(coarse_loc):
      match = re.search(r'COARSE_X(\d+)Y(\d+)', coarse_loc)
      assert match

      x = int(match.group(1))
      y = int(match.group(2))
      CR_NUM_HORIZONTAL_PER_COARSE = int(0.5 * self.board.CR_NUM_HORIZONTAL)
      CR_NUM_VERTICAL_PER_COARSE = int(self.board.CR_NUM_VERTICAL_PER_SLR)

      left_bottom_x = x * CR_NUM_HORIZONTAL_PER_COARSE
      left_bottom_y = y * CR_NUM_VERTICAL_PER_COARSE
      right_up_x = left_bottom_x + CR_NUM_HORIZONTAL_PER_COARSE - 1
      right_up_y = left_bottom_y + CR_NUM_VERTICAL_PER_COARSE - 1
      return f'CLOCKREGION_X{left_bottom_x}Y{left_bottom_y}:CLOCKREGION_X{right_up_x}Y{right_up_y}'

    if 'COARSE' in pblock:
      return _convertCoarseRegionToClockRegion(pblock)
    else:
      match = re.search(r'^CLOCKREGION_X(\d+)Y(\d+)[ ]*:[ ]*CLOCKREGION_X(\d+)Y(\d+)$', pblock)

      if not match:
        match = re.search(r'^CR_X(\d+)Y(\d+)[ ]*_To_[ ]*CR_X(\d+)Y(\d+)$', pblock)

      assert match, f'incorrect pblock {pblock}'
      return pblock

  def getAllTwoByTwoCRSlots(self):
    """
    [FIXME] a temporary fix. Get all Slots of 2x2 clock regions for U250
    """
    slot_list = []
    for x in range(0, 8, 2):
      for y in range(0, 16, 2):
        slot_list.append(Slot(self.board, f'CLOCKREGION_X{x}Y{y}:CLOCKREGION_X{x+1}Y{y+1}'))
    return slot_list

  def getLeafSlotsAfterPartition(
    self,
    partition_order: List[Dir],
  ):
    """
    generate all the final slots after a set of partition operations
    """
    init_slot = self.getInitialSlot()
    queue = [init_slot]
    for part_dir in partition_order:
      next_queue = []
      for slot in queue:
        if part_dir == Dir.horizontal:
          next_queue += self.getBottomAndUpSplit(slot)
        else:
          next_queue += self.getLeftAndRightSplit(slot)
      queue = next_queue

    return queue

  def createSlotForRouting(self, pblock : str):
    """create a Slot object for global routing purpose"""
    pblock = self._preprocessPblock(pblock)
    if pblock not in self.pblock_to_routing_slot:
      self.pblock_to_routing_slot[pblock] = Slot(self.board, pblock)
    return self.pblock_to_routing_slot[pblock]

  def createSlot(self, pblock : str):
    """create a Slot for floorplanning purpose and track the existing Slot objects"""
    pblock = self._preprocessPblock(pblock)
    if pblock not in self.pblock_to_slot:
      self.pblock_to_slot[pblock] = Slot(self.board, pblock)
    return self.pblock_to_slot[pblock]

  def getPureRoutingSlots(self):
    return [self.pblock_to_routing_slot[pblock] \
        for pblock in self.pblock_to_routing_slot.keys() \
        if pblock not in self.pblock_to_slot]

  def getComputeSlots(self):
    return self.pblock_to_slot.values()

  def removeSlotNonBlocking(self, pblock : str):
    if pblock in self.pblock_to_slot:
      self.pblock_to_slot.pop(pblock)

  # split by the middle row
  def getBottomAndUpSplit(self, slot):
    up     = self.createSlot(slot.getUpChildSlotName())
    bottom = self.createSlot(slot.getBottomChildSlotName())
    self.removeSlotNonBlocking(slot.getName())

    return bottom, up 

  # split by the middle column
  def getLeftAndRightSplit(self, slot):
    left =  self.createSlot(slot.getLeftChildSlotName())
    right = self.createSlot(slot.getRightChildSlotName())
    self.removeSlotNonBlocking(slot.getName())

    return left, right

  def partitionSlotByHalf(self, slot : Slot, dir : Dir):
    if dir == Dir.horizontal:
      return self.getBottomAndUpSplit(slot)
    elif dir == Dir.vertical:
      return self.getLeftAndRightSplit(slot)
    else:
      assert False, f'unrecognized partition direction: {dir}'

  def getInitialSlot(self):
    """
    get the initial slot for partitioning.
    Note that we expand the slot to the power of 2.
    This helps the partition process.
    The parts beyond the physical device will have 0 area
    """
    ceil_to_power_of_2 = lambda CR_NUM_VERTICAL : int(math.pow(2, math.ceil(math.log(CR_NUM_VERTICAL, 2))))
    UR_X = ceil_to_power_of_2(self.board.CR_NUM_HORIZONTAL) - 1
    UR_Y = ceil_to_power_of_2(self.board.CR_NUM_VERTICAL) - 1
    return self.createSlot(f'CLOCKREGION_X0Y0:CLOCKREGION_X{UR_X}Y{UR_Y}')

  def _haveOverlappedYRange(self, a : Slot, b : Slot):
    return min(a.getOrigUpRightY(), b.getOrigUpRightY()) > max(a.getOrigDownLeftY(), b.getOrigDownLeftY())
  
  def _haveOverlappedXRange(self, a : Slot, b : Slot):
    return min(a.getOrigUpRightX(), b.getOrigUpRightX()) > max(a.getOrigDownLeftX(), b.getOrigDownLeftX())
  
  def getLeftNeighborSlots(self, slot, potential_target_slots):
    neighbors = []
    for candidate in potential_target_slots.values():
      if candidate.getOrigUpRightX()+1 == slot.getOrigDownLeftX():
        if self._haveOverlappedYRange(candidate, slot):
          neighbors.append(candidate)
    return neighbors
  
  def getRightNeighborSlots(self, slot, potential_target_slots):
    neighbors = []
    for candidate in potential_target_slots.values():
      if slot.getOrigUpRightX()+1 == candidate.getOrigDownLeftX():
        if self._haveOverlappedYRange(candidate, slot):
          neighbors.append(candidate)
    return neighbors
  
  def getUpNeighborSlots(self, slot, potential_target_slots):
    neighbors = []
    for candidate in potential_target_slots.values():
      if slot.getOrigUpRightY()+1 == candidate.getOrigDownLeftY():
        if self._haveOverlappedXRange(candidate, slot):
          neighbors.append(candidate)
    return neighbors
  
  def getDownNeighborSlots(self, slot, potential_target_slots):
    neighbors = []
    for candidate in potential_target_slots.values():
      if candidate.getOrigUpRightY()+1 == slot.getOrigDownLeftY():
        if self._haveOverlappedXRange(candidate, slot):
          neighbors.append(candidate)
    return neighbors

  def getComputeNeighborSlots(self, slot, dir):
    potential_target_slots = self.pblock_to_slot

    if dir == 'UP':
      return self.getUpNeighborSlots(slot, potential_target_slots)
    elif dir == 'DOWN':
      return self.getDownNeighborSlots(slot, potential_target_slots)
    elif dir == 'LEFT':
      return self.getLeftNeighborSlots(slot, potential_target_slots)
    elif dir == 'RIGHT':
      return self.getRightNeighborSlots(slot, potential_target_slots)
    else:
      assert False, f'wrong direction: {dir}'

  def getActiveSlotsIncludeRouting(self):
    return {**self.pblock_to_slot, **self.pblock_to_routing_slot}.values()

  def isPureRoutingSlot(self, slot):
    slot_name = slot.getName()
    return slot_name in self.pblock_to_routing_slot and slot_name not in self.pblock_to_slot

  def getComputeSlotPairs(self):
    pairs = []
    for slot in self.pblock_to_slot.values():
      neighbors = self.getComputeNeighborSlots(slot, 'UP') + \
                  self.getComputeNeighborSlots(slot, 'RIGHT')
      pairs += [(slot, n) for n in neighbors]
    return pairs

  def getAnyNeighborSlots(self, slot, dir):
    potential_target_slots = {**self.pblock_to_slot, **self.pblock_to_routing_slot}

    if dir == 'UP':
      return self.getUpNeighborSlots(slot, potential_target_slots)
    elif dir == 'DOWN':
      return self.getDownNeighborSlots(slot, potential_target_slots)
    elif dir == 'LEFT':
      return self.getLeftNeighborSlots(slot, potential_target_slots)
    elif dir == 'RIGHT':
      return self.getRightNeighborSlots(slot, potential_target_slots)
    else:
      assert False, f'wrong direction: {dir}'

  def getAllSlotPairs(self):
    pairs = []
    for slot in self.getActiveSlotsIncludeRouting():
      neighbors = self.getAnyNeighborSlots(slot, 'UP') + \
                  self.getAnyNeighborSlots(slot, 'RIGHT')
      pairs += [(slot, n) for n in neighbors]
    return pairs