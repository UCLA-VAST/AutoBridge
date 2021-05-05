from collections import defaultdict
from autobridge.Opt.Slot import Slot
import re

# TODO: calibrate resource when DDRs are enabled
class DeviceU250:
  NAME = 'U250'

  FPGA_PART_NAME = 'xcu250-figd2104-2L-e'
  # SLR level
  SLR_NUM = 4

  SLR_AREA = defaultdict(lambda: defaultdict(list))
  SLR_AREA['BRAM'][0] = 768
  SLR_AREA['DSP'][0] = 1536
  SLR_AREA['FF'][0] = 433920
  SLR_AREA['LUT'][0] = 216960

  SLR_AREA['BRAM'][1] = 384
  SLR_AREA['DSP'][1] = 1344
  SLR_AREA['FF'][1] = 329280
  SLR_AREA['LUT'][1] = 164640

  SLR_AREA_DDR = defaultdict(lambda: defaultdict(list))
  SLR_AREA_DDR['BRAM'][0] = 768
  SLR_AREA_DDR['DSP'][0] = 1536
  SLR_AREA_DDR['FF'][0] = 433920
  SLR_AREA_DDR['LUT'][0] = 216960

  SLR_AREA_DDR['BRAM'][1] = 288
  SLR_AREA_DDR['DSP'][1] = 1152
  SLR_AREA_DDR['FF'][1] = 245760
  SLR_AREA_DDR['LUT'][1] = 122800

  LAGUNA_PER_CR = 480
  
  @staticmethod
  def getLagunaPositionY():
    return [3, 4, 7, 8, 11, 12]

  CR_NUM_HORIZONTAL = 8  
  CR_NUM_VERTICAL = 16  
  CR_NUM_VERTICAL_PER_SLR = 4 # each die has 4 CRs vertically
  
  # to be compatible with U280
  ACTUAL_SLR_NUM = 4
  ACTUAL_CR_NUM_VERTICAL = 16

  # Clock Region level
  CR_AREA = [defaultdict(defaultdict) for i in range(CR_NUM_HORIZONTAL)]
  CR_AREA[0]['BRAM'] = 48
  CR_AREA[0]['DSP'] = 96
  CR_AREA[0]['FF'] = 27840
  CR_AREA[0]['LUT'] = 13920
  CR_AREA[0]['URAM'] = 0

  CR_AREA[1]['BRAM'] = 48
  CR_AREA[1]['DSP'] = 96
  CR_AREA[1]['FF'] = 23040
  CR_AREA[1]['LUT'] = 11520
  CR_AREA[1]['URAM'] = 16

  CR_AREA[2]['BRAM'] = 72
  CR_AREA[2]['DSP'] = 120
  CR_AREA[2]['FF'] = 34560
  CR_AREA[2]['LUT'] = 17280
  CR_AREA[2]['URAM'] = 0

  CR_AREA[3]['BRAM'] = 24
  CR_AREA[3]['DSP'] = 72
  CR_AREA[3]['FF'] = 19200
  CR_AREA[3]['LUT'] = 9600
  CR_AREA[3]['URAM'] = 16

  CR_AREA[4]['BRAM'] = 48
  CR_AREA[4]['DSP'] = 96
  CR_AREA[4]['FF'] = 25920
  CR_AREA[4]['LUT'] = 12960
  CR_AREA[4]['URAM'] = 16

  CR_AREA[5]['BRAM'] = 24
  CR_AREA[5]['DSP'] = 120
  CR_AREA[5]['FF'] = 26880
  CR_AREA[5]['LUT'] = 13440
  CR_AREA[5]['URAM'] = 16

  CR_AREA[6]['BRAM'] = 24
  CR_AREA[6]['DSP'] = 120
  CR_AREA[6]['FF'] = 26880
  CR_AREA[6]['LUT'] = 13440
  CR_AREA[6]['URAM'] = 16

  # CR_AREA[7]['BRAM'] = 48
  # CR_AREA[7]['DSP'] = 48
  # CR_AREA[7]['FF'] = 24000
  # CR_AREA[7]['LUT'] = 12000
  # CR_AREA[7]['URAM'] = 0

  # consumed by Vitis IP
  CR_AREA[7]['BRAM'] = 0
  CR_AREA[7]['DSP'] = 0
  CR_AREA[7]['FF'] = 0
  CR_AREA[7]['LUT'] = 0
  CR_AREA[7]['URAM'] = 0

  TOTAL_AREA = {}
  TOTAL_AREA['BRAM'] = 5376
  TOTAL_AREA['DSP'] = 12288
  TOTAL_AREA['FF'] = 3456000
  TOTAL_AREA['LUT'] = 1728000
  TOTAL_AREA['URAM'] = 1280

  # FIXME: getArea is duplicated in U250 and U280
  # Remember to change "DeviceU250" to "DeviceU280"
  @staticmethod
  def getArea(pblock_def):
    assert re.search(r'CLOCKREGION_X\d+Y\d+:CLOCKREGION_X\d+Y\d+', pblock_def) \
        or re.search(r'^CR_X(\d+)Y(\d+)[ ]*_To_[ ]*CR_X(\d+)Y(\d+)$', pblock_def) , f'unexpected format of the slot name {pblock_def}'
    DL_x, DL_y, UR_x, UR_y = [int(val) for val in re.findall(r'[XY](\d+)', pblock_def)] # DownLeft & UpRight

    # treat the pseudo SLR with 0 area
    UR_y = min(DeviceU250.ACTUAL_CR_NUM_VERTICAL-1, UR_y) 

    area = {}
    for item in ['BRAM', 'DSP', 'FF', 'LUT', 'URAM']:
      area[item] = 0

    if DL_y > DeviceU250.ACTUAL_CR_NUM_VERTICAL-1:
      return area 

    for item in ['BRAM', 'DSP', 'FF', 'LUT', 'URAM']:
      # the total area of one row
      for i in range(DL_x, UR_x+1): # note the +1 here
        area[item] += DeviceU250.CR_AREA[i][item]
      
      # how many rows
      assert UR_y >= DL_y
      area[item] *= (UR_y - DL_y + 1)

    return area

  @staticmethod
  def getAllLagunaRange():
    return 'LAGUNA_X0Y0:LAGUNA_X31Y839'

  @staticmethod
  def __getBufferRegionOfSLRCrossingSlotPair(slot1, slot2):
    assert slot1.down_left_x == slot2.down_left_x
    assert slot1.up_right_x == slot2.up_right_x

    laguna_num_per_CR = 4
    laguna_down_left_x = slot1.down_left_x * laguna_num_per_CR
    laguna_up_right_x = (slot1.up_right_x + 1) * laguna_num_per_CR - 1

    from_slr = min(slot1.getSLR(), slot2.getSLR())
    to_slr = max(slot1.getSLR(), slot2.getSLR())

    if from_slr == 0 and to_slr == 1:
      laguna_down_left_y = 120
      laguna_up_right_y = 359
    elif from_slr == 1 and to_slr == 2:
      laguna_down_left_y = 360
      laguna_up_right_y = 599
    elif from_slr == 2 and to_slr == 3:
      laguna_down_left_y = 600
      laguna_up_right_y = 839    
    else:
      assert False

    laguna_region = f' LAGUNA_X{laguna_down_left_x}Y{laguna_down_left_y}:LAGUNA_X{laguna_up_right_x}Y{laguna_up_right_y} '
    slice_around_laguna = DeviceU250.__getSliceAroundLagunaSides(laguna_down_left_x, laguna_down_left_y, laguna_up_right_x, laguna_up_right_y)

    return laguna_region + '\n' + slice_around_laguna

  @staticmethod
  def __getSliceAroundLagunaSides(laguna_down_left_x, laguna_down_left_y, laguna_up_right_x, laguna_up_right_y):
    # note that each laguna column actually spans 2 in X dimension.
    # e.g. LAGUNA_X0Y... and LAGUNA_X1Y... are in the same physical column
    start_from_ith_laguna_column = int((laguna_down_left_x+1) / 2) # round to floor
    end_at_jth_laguna_column = int((laguna_up_right_x+1) / 2)

    idx_of_left_side_slice_of_laguna_column = (
      7,
      18,
      36,
      49,
      62,
      84,
      96,
      110,
      123,
      138,
      151,
      163,
      181,
      193,
      213,
      224
    )

    SLICE_around_laguna = []

    # note that there is no +1
    # the last laguna column is X31 -> (31+1)/2 = 16 -> the last index should be 15
    for i in range(start_from_ith_laguna_column, end_at_jth_laguna_column): 
      # two columns of SLICEs to the left and to the right of the laguna columns
      # note that the index of SLICE jumps 1 because of the laguna column, so it should be +2 here
      # although only 2 columns of SLICEs are included
      idx_SLICE_to_the_left = idx_of_left_side_slice_of_laguna_column[i]
      idx_SLICE_to_the_right = idx_SLICE_to_the_left + 2

      # note that the Y coordinate of laguna and SLICE is the same
      SLICE_around_laguna.append(f'SLICE_X{idx_SLICE_to_the_left}Y{laguna_down_left_y}:SLICE_X{idx_SLICE_to_the_right}Y{laguna_up_right_y}')
    return '\n'.join(SLICE_around_laguna)

  @staticmethod
  def getBufferRegionBetweenSlotPair(slot_name1, slot_name2, col_width_each_side, row_width_each_side):
    """
    Given a pair of neighbor slots, return the tight buffer region in between
    to help constrain the anchor placement  
    For cross-SLR pairs, return the included laguna sites along with the neighbor SLICEs
    """

    idx_1st_col_CR_X = [0] * 9
    idx_1st_col_CR_X[0] = 0 # index of the first SLICE column in the 0-th CR column
    idx_1st_col_CR_X[1] = 31 # index of the first SLICE column in the 1-th CR column
    idx_1st_col_CR_X[2] = 57 # 2-th CR column
    idx_1st_col_CR_X[3] = 95 # 3-th CR column
    idx_1st_col_CR_X[4] = 117 # 4-th CR column
    idx_1st_col_CR_X[5] = 146 # 5-th CR column
    idx_1st_col_CR_X[6] = 176 # 6-th CR column    
    idx_1st_col_CR_X[7] = 206 # 7-th CR column    
    idx_1st_col_CR_X[8] = 233 # pseudo 8-th CR column. There are 232 columns in total 

    Slot_SLICE_height = 120 # 2x2 slot
    CR_SLICE_height = 60
    
    slot1 = Slot(DeviceU250, slot_name1)
    slot2 = Slot(DeviceU250, slot_name2)

    if slot1.isToTheLeftOf(slot2) or slot1.isToTheRightOf(slot2):
      orient = 'HORIZONTAL'
    elif slot1.isAbove(slot2) or slot1.isBelow(slot2):
      orient = 'VERTICAL'
    else:
      assert False

    if orient == 'HORIZONTAL':
      y_range_beg = slot1.down_left_y * CR_SLICE_height
      y_range_end = y_range_beg + Slot_SLICE_height - 1  # 2x2 slot
      mid_SLICE_col_idx = idx_1st_col_CR_X[max(slot1.down_left_x, slot2.down_left_x)]
      x_range_beg = mid_SLICE_col_idx - col_width_each_side
      x_range_end = mid_SLICE_col_idx + col_width_each_side - 1
      return f'SLICE_X{x_range_beg}Y{y_range_beg}:SLICE_X{x_range_end}Y{y_range_end} '
    
    elif orient == 'VERTICAL':
      # the buffer region for cross-SLR vertical pairs should only include the buffer around laguna sites
      if slot1.getSLR() != slot2.getSLR():
        return DeviceU250.__getBufferRegionOfSLRCrossingSlotPair(slot1, slot2)
        
      # non-slr-crossing pair
      x_range_beg = idx_1st_col_CR_X[slot1.down_left_x]
      x_range_end = idx_1st_col_CR_X[slot1.up_right_x+1] - 1
      mid_SLICE_row_idx = max(slot1.down_left_y, slot2.down_left_y) *  CR_SLICE_height
      y_range_beg = mid_SLICE_row_idx - row_width_each_side
      y_range_end = mid_SLICE_row_idx + row_width_each_side - 1
      slice_buffer_region = f'SLICE_X{x_range_beg}Y{y_range_beg}:SLICE_X{x_range_end}Y{y_range_end} '

      return slice_buffer_region

    else:
      assert False

  @staticmethod
  def getSLICEVacentRegion(col_width, row_width):
    """
    create a buffer region among 2x2 slots
    use the concise clockregion-based pblock subtract this buffer region
    """

    # for each slot, get the index of the first and the last SLICE column
    idx_1st_col_Slot_X = [0] * 4
    idx_last_col_Slot_X = [0] * 4

    idx_1st_col_Slot_X[0] = 0 # index of the first SLICE column in the 0-th CR column
    idx_1st_col_Slot_X[1] = 57 # 2-th CR column
    idx_1st_col_Slot_X[2] = 117 # 4-th CR column
    idx_1st_col_Slot_X[3] = 176 # 6-th CR column

    idx_last_col_Slot_X[3] = 232 # index of the last SLICE column in the 7-th CR column
    idx_last_col_Slot_X[2] = idx_1st_col_Slot_X[3] - 1 # 5-th CR column
    idx_last_col_Slot_X[1] = idx_1st_col_Slot_X[2] - 1 # 3-th CR column
    idx_last_col_Slot_X[0] = idx_1st_col_Slot_X[1] - 1 # 1-th CR column

    # each CR has 60 SLICE vertically, each slot 120
    CR_SLICE_height = 60
    Slot_SLICE_height = 120 # 2x2 slot

    last_row_idx = 959 # Y index of the highest SLICE
    last_col_idx = 232 # X index of the rightest SLICE

    # the vertical columns of the buffer region
    col_buffer_region_pblock = []
    for i in range(4):
      # the left side buffer of a slot
      col_buffer_region_pblock.append(f'SLICE_X{idx_1st_col_Slot_X[i]}Y0:SLICE_X{idx_1st_col_Slot_X[i]+col_width-1}Y959')
      
      # the right side buffer of a slot
      col_buffer_region_pblock.append(f'SLICE_X{idx_last_col_Slot_X[i] - col_width + 1}Y0:SLICE_X{idx_last_col_Slot_X[i]}Y959')

    # exclude the region for the left and right device boundaries
    col_buffer_region_pblock[0] = '' # the leftest slot does not need left side buffer
    col_buffer_region_pblock[-1] = '' # the rightest slot does not need right side buffer

    # the horizontal rows of the buffer region
    # exclude the region for the up and down device boundaries & die boundaries
    row_buffer_region_pblock = []
    for i in range(8):
      if i % 2 == 1: # only need buffer at the down side
        row_buffer_region_pblock.append(f'SLICE_X0Y{i * 120}:SLICE_X232Y{i * 120 + row_width - 1} ')
      else: # only need buffer at the up side
        row_buffer_region_pblock.append(f'SLICE_X0Y{(i+1) * 120 - row_width}:SLICE_X232Y{(i+1) * 120 - 1} ')

    return '\n'.join(col_buffer_region_pblock) + '\n'.join(row_buffer_region_pblock)

class DeviceU280:
  NAME = 'U280'
  FPGA_PART_NAME = 'xcu280-fsvh2892-2L-e'
  
  SLR_AREA = defaultdict(lambda: defaultdict(list))
  SLR_AREA['BRAM'][0] = 768
  SLR_AREA['DSP'][0] = 1536
  SLR_AREA['FF'][0] = 433920
  SLR_AREA['LUT'][0] = 216960  
  
  SLR_AREA['BRAM'][1] = 384
  SLR_AREA['DSP'][1] = 1344
  SLR_AREA['FF'][1] = 330240
  SLR_AREA['LUT'][1] = 165120  

  LAGUNA_PER_CR = 480
  
  @staticmethod
  def getLagunaPositionY():
    return [3, 4, 7, 8, 11, 12]

  SLR_NUM = 4 # add a pseudo SLR at the top with area 0
  CR_NUM_HORIZONTAL = 8
  CR_NUM_VERTICAL = 16
  CR_NUM_VERTICAL_PER_SLR = 4 # each die has 4 CRs vertically

  ACTUAL_SLR_NUM = 3 # in reality there are only 3 SLRs
  ACTUAL_CR_NUM_VERTICAL = 12

  TOTAL_AREA = {}
  TOTAL_AREA['BRAM'] = 4032
  TOTAL_AREA['DSP'] = 9024
  TOTAL_AREA['FF'] = 2607360
  TOTAL_AREA['LUT'] = 1303680
  TOTAL_AREA['URAM'] = 960

  # Clock Region level
  CR_AREA = [defaultdict(defaultdict) for i in range(CR_NUM_HORIZONTAL)]
  CR_AREA[0]['BRAM'] = 48
  CR_AREA[0]['DSP']  = 72
  CR_AREA[0]['FF']   = 29760
  CR_AREA[0]['LUT']  = 14880
  CR_AREA[0]['URAM'] = 0

  CR_AREA[1]['BRAM'] = 48
  CR_AREA[1]['DSP']  = 72
  CR_AREA[1]['FF']   = 24960
  CR_AREA[1]['LUT']  = 12480
  CR_AREA[1]['URAM'] = 16

  CR_AREA[2]['BRAM'] = 72
  CR_AREA[2]['DSP']  = 90
  CR_AREA[2]['FF']   = 36480
  CR_AREA[2]['LUT']  = 18240
  CR_AREA[2]['URAM'] = 0

  CR_AREA[3]['BRAM'] = 24
  CR_AREA[3]['DSP']  = 54
  CR_AREA[3]['FF']   = 21120
  CR_AREA[3]['LUT']  = 10560
  CR_AREA[3]['URAM'] = 16

  CR_AREA[4]['BRAM'] = 48
  CR_AREA[4]['DSP']  = 72
  CR_AREA[4]['FF']   = 27840
  CR_AREA[4]['LUT']  = 13920
  CR_AREA[4]['URAM'] = 16

  CR_AREA[5]['BRAM'] = 24
  CR_AREA[5]['DSP']  = 90
  CR_AREA[5]['FF']   = 28800
  CR_AREA[5]['LUT']  = 14400
  CR_AREA[5]['URAM'] = 16

  CR_AREA[6]['BRAM'] = 24
  CR_AREA[6]['DSP']  = 90
  CR_AREA[6]['FF']   = 28800
  CR_AREA[6]['LUT']  = 14400
  CR_AREA[6]['URAM'] = 16

  # CR_AREA[7]['BRAM'] = 48
  # CR_AREA[7]['DSP']  = 36
  # CR_AREA[7]['FF']   = 25920
  # CR_AREA[7]['LUT']  = 12960
  # CR_AREA[7]['URAM'] = 0

  # consumed by Vitis IP
  CR_AREA[7]['BRAM'] = 0
  CR_AREA[7]['DSP']  = 0
  CR_AREA[7]['FF']   = 0
  CR_AREA[7]['LUT']  = 0
  CR_AREA[7]['URAM'] = 0

  # TODO: getArea is duplicated in U250 and U280
  @staticmethod
  def getArea(pblock_def):
    assert re.search(r'CLOCKREGION_X\d+Y\d+:CLOCKREGION_X\d+Y\d+', pblock_def), f'unexpected format of the slot name {pblock_def}'
    DL_x, DL_y, UR_x, UR_y = [int(val) for val in re.findall(r'[XY](\d+)', pblock_def)] # DownLeft & UpRight

    # treat the pseudo SLR with 0 area
    UR_y = min(DeviceU280.ACTUAL_CR_NUM_VERTICAL-1, UR_y) 

    area = {}
    for item in ['BRAM', 'DSP', 'FF', 'LUT', 'URAM']:
      area[item] = 0

    if DL_y > DeviceU280.ACTUAL_CR_NUM_VERTICAL-1:
      return area 

    for item in ['BRAM', 'DSP', 'FF', 'LUT', 'URAM']:
      # the total area of one row
      for i in range(DL_x, UR_x+1): # note the +1 here
        area[item] += DeviceU280.CR_AREA[i][item]
      
      # how many rows
      assert UR_y >= DL_y
      area[item] *= (UR_y - DL_y + 1)

    return area

class DeviceManager:
  def __init__(self, board_name):
    if board_name == 'U250':
      self.board = DeviceU250
    elif board_name == 'U280':
      self.board = DeviceU280
    else:
      assert False, f'unsupported device: {board_name}'

  def getBoard(self):
    return self.board