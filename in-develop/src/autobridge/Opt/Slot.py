#! /usr/bin/python3.6
import logging
from collections import defaultdict
from typing import Dict, Iterable, Iterator, List, Union
import re
import json

class Slot:
  def __init__(self, board, pblock : str):
    self.board = board

    assert 'COARSE_' not in pblock
    
    match = re.search(r'^CLOCKREGION_X(\d+)Y(\d+)[ ]*:[ ]*CLOCKREGION_X(\d+)Y(\d+)$', pblock)
    if not match:
      match = re.search(r'^CR_X(\d+)Y(\d+)[ ]*_To_[ ]*CR_X(\d+)Y(\d+)$', pblock)
    assert match, f'incorrect pblock {pblock}'

    # DO NOT convert CR coordinate to boundary intersect coordinates
    # stick to vivado convention
    self.down_left_x = int(match.group(1))
    self.down_left_y = int(match.group(2))
    self.up_right_x =  int(match.group(3))
    self.up_right_y =  int(match.group(4))

    assert self.down_left_x < 100
    assert self.down_left_y < 100
    assert self.up_right_x < 100
    assert self.up_right_y < 100

    self.area = self.board.getArea(f'CLOCKREGION_X{self.down_left_x}Y{self.down_left_y}:CLOCKREGION_X{self.up_right_x}Y{self.up_right_y}')

  def getName(self):
    # need to convert back to CR coordinates
    return f'CLOCKREGION_X{self.down_left_x}Y{self.down_left_y}:CLOCKREGION_X{self.up_right_x}Y{self.up_right_y}'

  @property
  def name(self):
    return f'CR_X{self.down_left_x}Y{self.down_left_y}_To_CR_X{self.up_right_x}Y{self.up_right_y}'

  def getOrigUpRightX(self):
    return self.up_right_x
  def getOrigUpRightY(self):
    return self.up_right_y
  def getOrigDownLeftX(self):
    return self.down_left_x
  def getOrigDownLeftY(self):
    return self.down_left_y

  def getRTLModuleName(self):
    return f'CR_X{self.down_left_x}Y{self.down_left_y}_To_CR_X{self.up_right_x}Y{self.up_right_y}'

  def __key(self):
    return (str(self.down_left_x).zfill(3),
          str(self.down_left_y).zfill(3),
          str(self.up_right_x).zfill(3),
          str(self.up_right_y).zfill(3))

  def __hash__(self):
    return hash(self.__key())

  def __eq__(self, other):
    if isinstance(other, Slot):
      return self.__key() == other.__key()
    assert False, 'comparing Slot to a different class'

  def getArea(self):
    return self.area
  
  # use the middle point as the position of the slot. Check the results have no fractional part
  # biased towards the larger side
  def getPositionX(self):
    return int((self.down_left_x + self.up_right_x + 1) / 2)

  # biased towards the ceiling side
  def getPositionY(self):
    return int((self.down_left_y + self.up_right_y + 1) / 2)

  def getLenX(self):
    return self.up_right_x - self.down_left_x + 1

  def getLenY(self):
    return self.up_right_y - self.down_left_y + 1
  
  # 1/4 from the lower end
  def getQuarterPositionX(self):
    return int(self.down_left_x + (self.up_right_x - self.down_left_x + 1) / 4)

  def getQuarterPositionY(self):
    return int(self.down_left_y + (self.up_right_y - self.down_left_y + 1) / 4)

  def getHalfLenX(self):
    return int((self.up_right_x - self.down_left_x + 1) / 2)

  def getHalfLenY(self):
    return int((self.up_right_y - self.down_left_y + 1) / 2)

  #                  |-------| u_r_x, u_r_y
  #                  |       |
  #                  |  up   |
  #                  |       |
  #                  |-------| u_r_x, mid_y   
  #                  |       |
  #                  |  bot  |
  #                  |       |
  #   d_l_x, d_l_y   |-------|
  def getBottomChildSlotName(self):
    assert self.down_left_x != self.up_right_x or \
      self.down_left_y != self.up_right_y, 'Cannot split a single CR'

    mid_y = self.getPositionY()
    down_left_cr = f'CLOCKREGION_X{self.down_left_x }Y{self.down_left_y}'
    up_right_cr  = f'CLOCKREGION_X{self.up_right_x}Y{mid_y-1}'
    return f'{down_left_cr}:{up_right_cr}'
  
  def getUpChildSlotName(self):
    assert self.down_left_x != self.up_right_x or \
      self.down_left_y != self.up_right_y, 'Cannot split a single CR'

    mid_y = self.getPositionY()
    down_left_cr = f'CLOCKREGION_X{self.down_left_x }Y{mid_y}'
    up_right_cr  = f'CLOCKREGION_X{self.up_right_x}Y{self.up_right_y}'
    return f'{down_left_cr}:{up_right_cr}'

  #                  mid_x, u_r_y
  #               |---------|---------| u_r_x, u_r_y
  #               |         |         |
  #               |  L      |      R  |
  #               |         |         |
  #  d_l_x, d_l_y |---------|---------|
  #                    mid_x, d_l_y
  #     
  def getLeftChildSlotName(self):
    assert self.down_left_x != self.up_right_x or \
      self.down_left_y != self.up_right_y, 'Cannot split a single CR'

    mid_x = self.getPositionX()
    down_left_cr = f'CLOCKREGION_X{self.down_left_x}Y{self.down_left_y}'
    up_right_cr  = f'CLOCKREGION_X{mid_x - 1       }Y{self.up_right_y}'
    return f'{down_left_cr}:{up_right_cr}'

  def getRightChildSlotName(self):
    assert self.down_left_x != self.up_right_x or \
      self.down_left_y != self.up_right_y, 'Cannot split a single CR'

    mid_x = self.getPositionX()
    down_left_cr = f'CLOCKREGION_X{mid_x            }Y{self.down_left_y}'
    up_right_cr  = f'CLOCKREGION_X{self.up_right_x}Y{self.up_right_y}'
    return f'{down_left_cr}:{up_right_cr}'

  def containsChildSlot(self, target) -> bool:
    return target.down_left_x >= self.down_left_x \
      and  target.down_left_y >= self.down_left_y \
      and  target.up_right_x  <= self.up_right_x  \
      and  target.up_right_y  <= self.up_right_y  

  def getNeighborSlotName(self, dir):
    """get the neighbor slot at the given direction of the equal size"""
    len_x = self.up_right_x - self.down_left_x + 1
    len_y = self.up_right_y - self.down_left_y + 1

    if dir == 'UP':
      return f'CLOCKREGION_X{self.down_left_x}Y{self.down_left_y+len_y}:CLOCKREGION_X{self.up_right_x}Y{self.up_right_y+len_y}'
    elif dir == 'DOWN':
      return f'CLOCKREGION_X{self.down_left_x}Y{self.down_left_y-len_y}:CLOCKREGION_X{self.up_right_x}Y{self.up_right_y-len_y}'
    elif dir == 'RIGHT':
      return f'CLOCKREGION_X{self.down_left_x+len_x}Y{self.down_left_y}:CLOCKREGION_X{self.up_right_x+len_x}Y{self.up_right_y}'
    elif dir == 'LEFT':
      return f'CLOCKREGION_X{self.down_left_x-len_x}Y{self.down_left_y}:CLOCKREGION_X{self.up_right_x-len_x}Y{self.up_right_y}'
    else: assert False

  def getSLR(self):
    """ return which SRL the slot is in, starting from 0 """
    num_rows_per_slr = self.board.CR_NUM_VERTICAL_PER_SLR
    for i in range(self.board.SLR_NUM):
      if self.down_left_y >= i * num_rows_per_slr \
         and self.up_right_y <= (i+1) * num_rows_per_slr - 1:
        return i
    
    assert False, f'the current slot {self.getName()} is beyond 1 SLR'
    return None

  def getBoundarySegmentName(self, dir):
    if dir == 'UP':
      return f'Boundary_X{self.down_left_x}Y{self.up_right_y+1}_To_X{self.up_right_x+1}Y{self.up_right_y+1}'
    elif dir == 'DOWN':
      return f'Boundary_X{self.down_left_x}Y{self.down_left_y}_To_X{self.up_right_x+1}Y{self.down_left_y}'
    elif dir == 'RIGHT':
      return f'Boundary_X{self.up_right_x+1}Y{self.down_left_y}_To_X{self.up_right_x+1}Y{self.up_right_y+1}'
    elif dir == 'LEFT':
      return f'Boundary_X{self.down_left_x}Y{self.down_left_y}_To_X{self.down_left_x}Y{self.up_right_y+1}'
    else:
      assert False

  def getDistance(self, other: 'Slot') -> int:
    """
    get the manhatten dist from another slot
    """
    dist_x = abs(self.getPositionX() - other.getPositionX()) 
    dist_y = abs(self.getPositionY() - other.getPositionY())
    return dist_x + dist_y

  def isNeightbor(self, other: 'Slot') -> bool:
    return self.isToTheLeftOf(other) \
        or self.isToTheRightOf(other) \
        or self.isAbove(other) \
        or self.isBelow(other) \

  #------------- For TAPA ------------- #
  def isToTheLeftOf(self, other: 'Slot') -> bool:
    return (self.down_left_y == other.down_left_y and
            self.up_right_y == other.up_right_y and
            self.up_right_x+1 == other.down_left_x)

  def isToTheRightOf(self, other: 'Slot') -> bool:
    return other.isToTheLeftOf(self)

  def isAbove(self, other: 'Slot') -> bool:
    return (self.down_left_x == other.down_left_x and
            self.up_right_x == other.up_right_x and
            self.down_left_y == other.up_right_y+1)

  def isBelow(self, other: 'Slot') -> bool:
    return other.isAbove(self)

  @property
  def pblock_name(self) -> str:
    return self.getRTLModuleName()

  @property
  def pblock_tcl(self) -> str:
    """ 
    remove the overlaps with vitis IPs 
    must start with a leading '\n', or the tapa side will error
    """
    return '\n' + f'# begin defining a slot\n' + '\n'.join(self.board.getSlotPblockTcl(self)) + '\n'
  #------------------------------------ #

# For TAPA. To be replaced by GlobalRouting
class Topology:

  def __init__(self, slots: Iterable[Slot]):
    self.slots = tuple(slots)
    self.adjancency: Dict[str, Dict[str, str]] = defaultdict(dict)
    for slot1 in self.slots:
      for slot2 in self.slots:
        if slot2.isToTheLeftOf(slot1):
          self.adjancency[slot1.pblock_name]['left'] = slot2.pblock_name
        elif slot2.isToTheRightOf(slot1):
          self.adjancency[slot1.pblock_name]['right'] = slot2.pblock_name
        elif slot2.isAbove(slot1):
          self.adjancency[slot1.pblock_name]['up'] = slot2.pblock_name
        elif slot2.isBelow(slot1):
          self.adjancency[slot1.pblock_name]['down'] = slot2.pblock_name

  def getNeighborOf(self, name: str, direction: str) -> str:
    """Get neighbor of `name` on `direction`. Empty if none exists."""
    return self.adjancency.get(name, {}).get(direction, '')

  def yieldPaths(
      self,
      direction: str,
      init: List[str],
  ) -> Iterator[List[str]]:
    """Yield connections on `direction` starting from `init`.

    Arguments:
      directions: One of 'up', 'down', 'left', or 'right'.
      init: Initial connection.

    Yields:
      Connections with prefix `init` on `direction` (excluding `init` itself).
    """
    name = init[-1]
    neighbors = init[:]
    while True:
      name = self.getNeighborOf(name, direction)
      if not name:
        break
      neighbors.append(name)
      yield neighbors[:]

  def getTopologyOf(self, slot: Slot) -> Dict[str, Union[str, List[str]]]:
    # list of connections; each connection is a list starting from `slot` to the
    # slots that are connected to `slot`
    paths: List[List[str]] = []
    for direction in 'left', 'right':
      for path in self.yieldPaths(direction, [slot.pblock_name]):
        paths.append(path)
        for next_direction in 'up', 'down':
          paths.extend(self.yieldPaths(next_direction, path))
    for direction in 'up', 'down':
      for path in self.yieldPaths(direction, [slot.pblock_name]):
        paths.append(path)
        for next_direction in 'left', 'right':
          paths.extend(self.yieldPaths(next_direction, path))

    # p[-1] is the destination, p[0] is the source, neither of them is required
    # in the value
    topology: Dict[str, Union[str, List[str]]] = {p[-1]: p[1:-1] for p in paths}
    topology['tcl'] = slot.pblock_tcl
    return topology
