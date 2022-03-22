import re

from typing import List
from collections import defaultdict
from autobridge.Opt.Slot import Slot


class DeviceBase:
  NAME = 'Base'
  CR_AREA = None
  CR_NUM_VERTICAL = None
  FPGA_PART_NAME = None
  
  def __init__(self, ddr_list=[], is_vitis_enabled=True):
    self.ddr_list = ddr_list
    self.pre_existing_area = self._getVitisRegions(ddr_list, is_vitis_enabled)

  def _getCRPblockIntersect(self, cr_pblock1, cr_pblock2):
    """
    get the overlapped part of two pblocks of clock regions
    """
    assert re.search(r'CLOCKREGION_X\d+Y\d+:CLOCKREGION_X\d+Y\d+', cr_pblock1), cr_pblock1
    assert re.search(r'CLOCKREGION_X\d+Y\d+:CLOCKREGION_X\d+Y\d+', cr_pblock2), cr_pblock2
    pblock1_DL_x, pblock1_DL_y, pblock1_UR_x, pblock1_UR_y = \
      [int(val) for val in re.findall(r'[XY](\d+)', cr_pblock1)] # DownLeft & UpRight    
    pblock2_DL_x, pblock2_DL_y, pblock2_UR_x, pblock2_UR_y = \
      [int(val) for val in re.findall(r'[XY](\d+)', cr_pblock2)] # DownLeft & UpRight  
    
    intersect_DL_x = max(pblock1_DL_x, pblock2_DL_x)
    intersect_DL_y = max(pblock1_DL_y, pblock2_DL_y)
    intersect_UR_x = min(pblock1_UR_x, pblock2_UR_x)
    intersect_UR_y = min(pblock1_UR_y, pblock2_UR_y)

    if intersect_DL_x <= intersect_UR_x and intersect_DL_y <= intersect_UR_y:
      overlap_pblock = f'CLOCKREGION_X{intersect_DL_x}Y{intersect_DL_y}:CLOCKREGION_X{intersect_UR_x}Y{intersect_UR_y}'
    else:
      overlap_pblock = None

    return overlap_pblock

  def _getPblockArea(self, pblock_def):
    """
    get the total resources in the specified pblock
    Note that if a slot is outside the range of the device, we return an area of 0
    """
    assert re.search(r'CLOCKREGION_X\d+Y\d+:CLOCKREGION_X\d+Y\d+', pblock_def), f'unexpected format of the slot name {pblock_def}'
    DL_x, DL_y, UR_x, UR_y = [int(val) for val in re.findall(r'[XY](\d+)', pblock_def)] # DownLeft & UpRight

    # treat the pseudo SLR with 0 area
    UR_y = min(self.CR_NUM_VERTICAL-1, UR_y) 

    area = {
      'BRAM' : 0,
      'DSP' : 0,
      'FF' : 0,
      'LUT' : 0,
      'URAM' : 0
    }
    
    if DL_y > self.CR_NUM_VERTICAL-1:
      return area 

    for item in ['BRAM', 'DSP', 'FF', 'LUT', 'URAM']:
      # the total area of one row
      area[item] = sum(self.CR_AREA[i][j][item] for i in range(DL_x, UR_x + 1) for j in range(DL_y, UR_y+1))

    return area

  def getArea(self, slot_pblock):
    """
    get the resources available to user. Exclude any pre-exising IPs
    """
    slot_user_area = self._getPblockArea(slot_pblock)
    for ip_pblock in self.pre_existing_area:
      overlap_pblock = self._getCRPblockIntersect(slot_pblock, ip_pblock)
      if overlap_pblock:
        overlap_area = self._getPblockArea(overlap_pblock)
        for item in slot_user_area.keys():
          slot_user_area[item] -= overlap_area[item]
    return slot_user_area

  def getSlotPblockTcl(self, slot: Slot) -> List[str]:
    """
    remove the overlaps with vitis IPs
    If the slot is an SLR-level slot, then do not remove the DDR region in the middle
    """
    tcl = []
    pblock_name = slot.getRTLModuleName()
    pblock_def = slot.getName()

    tcl.append(f'create_pblock {pblock_name}')
    tcl.append(f'resize_pblock {pblock_name} -add {pblock_def}')
    tcl.append(f'# remove the reserved clock regions for the Vitis infra')
    tcl.append(f'resize_pblock {pblock_name} -remove {self.VITIS_REGION}')

    # exclude the DDR region if the DDR region is at the boundary of the slot
    for ddr in self.ddr_list:
      ddr_pblock = self.DDR_TO_CLOCK_REGIONS[ddr]
      ddr_slot = Slot(slot.board, ddr_pblock)
      if slot.down_left_x == ddr_slot.down_left_x or slot.up_right_x == ddr_slot.up_right_x:
        if slot.containsChildSlot(ddr_slot):
          if self.getDDRSlolenRegion(ddr):
            tcl.append(f'# exclude the area for DDR {ddr}')
            tcl.append(f'resize_pblock {pblock_name} -remove {self.DDR_TO_CLOCK_REGIONS[ddr]}')
            tcl.append(f'resize_pblock {pblock_name} -add {{ {self.getDDRSlolenRegion(ddr)} }}')

    return tcl

  def getDDRSlolenRegion(self, ddr: int) -> str:
    return ''

  DDR_TO_CLOCK_REGIONS = {}

  def getDDRPblock(self, ddr):
    return self.DDR_TO_CLOCK_REGIONS[ddr]


class DeviceU250(DeviceBase):
  def _getVitisRegions(self, ddr_list, is_vitis_enabled):
    assert all(ddr in [0, 1, 2, 3] for ddr in ddr_list) # u250 has 4 ddrs

    # the area used by implicit IPs
    pre_existing_area = []
    for ddr in ddr_list:
      pre_existing_area.append(self.DDR_TO_CLOCK_REGIONS[ddr])

    # the vitis platform will take away the rightmost column
    if is_vitis_enabled:
      pre_existing_area.append(self.VITIS_REGION) # the area consumed by Vitis platform
    
    return pre_existing_area

  def getDDRSlolenRegion(self, ddr: int) -> str:
    assert 0 <= ddr <= 3, ddr
    # entire sloten region is {SLICE_X144Y0:SLICE_X145Y959 DSP48E2_X19Y0:DSP48E2_X19Y383 RAMB18_X9Y0:RAMB18_X9Y383 RAMB36_X9Y0:RAMB36_X9Y191}
    return f'SLICE_X144Y{240 * ddr}:SLICE_X145Y{240 * (ddr+1) - 1} DSP48E2_X19Y{96 * ddr}:DSP48E2_X19Y{96 * (ddr+1) - 1} RAMB18_X9Y{96 * ddr}:RAMB18_X9Y{96 * (ddr+1) - 1} RAMB36_X9Y{48 * ddr}:RAMB36_X9Y{48 * (ddr+1) - 1}'

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

  CR_NUM_HORIZONTAL = 8  
  CR_NUM_VERTICAL = 16  
  CR_NUM_VERTICAL_PER_SLR = 4 # each die has 4 CRs vertically
  
  # to be compatible with U280
  ACTUAL_SLR_NUM = 4
  ACTUAL_CR_NUM_VERTICAL = 16

  # Clock Region level
  CR_AREA = defaultdict(lambda: defaultdict(dict))
  for y in range(ACTUAL_CR_NUM_VERTICAL):
    # clock regions with Laguna columns have less FF and LUT
    if y % 4 == 0 or y % 3 == 0:
      LUT_adjustment = 0
      FF_adjustment = 0
    else:
      LUT_adjustment = 960
      FF_adjustment = 1920

    CR_AREA[0][y]['BRAM'] = 48
    CR_AREA[0][y]['DSP'] = 96
    CR_AREA[0][y]['FF'] = 27840 + FF_adjustment
    CR_AREA[0][y]['LUT'] = 13920 + LUT_adjustment
    CR_AREA[0][y]['URAM'] = 0

    CR_AREA[1][y]['BRAM'] = 48
    CR_AREA[1][y]['DSP'] = 96
    CR_AREA[1][y]['FF'] = 23040 + FF_adjustment
    CR_AREA[1][y]['LUT'] = 11520 + LUT_adjustment
    CR_AREA[1][y]['URAM'] = 16

    CR_AREA[2][y]['BRAM'] = 72
    CR_AREA[2][y]['DSP'] = 120
    CR_AREA[2][y]['FF'] = 34560 + FF_adjustment
    CR_AREA[2][y]['LUT'] = 17280 + LUT_adjustment
    CR_AREA[2][y]['URAM'] = 0

    CR_AREA[3][y]['BRAM'] = 24
    CR_AREA[3][y]['DSP'] = 72
    CR_AREA[3][y]['FF'] = 19200 + FF_adjustment
    CR_AREA[3][y]['LUT'] = 9600 + LUT_adjustment
    CR_AREA[3][y]['URAM'] = 16

    CR_AREA[4][y]['BRAM'] = 48
    CR_AREA[4][y]['DSP'] = 96
    CR_AREA[4][y]['FF'] = 25920 + FF_adjustment
    CR_AREA[4][y]['LUT'] = 12960 + LUT_adjustment
    CR_AREA[4][y]['URAM'] = 16

    CR_AREA[5][y]['BRAM'] = 24
    CR_AREA[5][y]['DSP'] = 120
    CR_AREA[5][y]['FF'] = 26880 + FF_adjustment
    CR_AREA[5][y]['LUT'] = 13440 + LUT_adjustment
    CR_AREA[5][y]['URAM'] = 16

    CR_AREA[6][y]['BRAM'] = 24
    CR_AREA[6][y]['DSP'] = 120
    CR_AREA[6][y]['FF'] = 26880 + FF_adjustment
    CR_AREA[6][y]['LUT'] = 13440 + LUT_adjustment
    CR_AREA[6][y]['URAM'] = 16

    CR_AREA[7][y]['BRAM'] = 48
    CR_AREA[7][y]['DSP'] = 48
    CR_AREA[7][y]['FF'] = 24000 + FF_adjustment
    CR_AREA[7][y]['LUT'] = 12000 + LUT_adjustment
    CR_AREA[7][y]['URAM'] = 0

  TOTAL_AREA = {}
  TOTAL_AREA['BRAM'] = 5376
  TOTAL_AREA['DSP'] = 12288
  TOTAL_AREA['FF'] = 3456000
  TOTAL_AREA['LUT'] = 1728000
  TOTAL_AREA['URAM'] = 1280

  # for item in ('BRAM', 'DSP', 'FF', 'LUT', 'URAM'):
  #   assert TOTAL_AREA[item] == sum(CR_AREA[x][y][item] for x in range(8) for y in range(16))

  # note that the location of DDR 3 is not consistent with other DDRs 
  DDR_TO_CLOCK_REGIONS = {
    0: 'CLOCKREGION_X4Y1:CLOCKREGION_X4Y3',
    1: 'CLOCKREGION_X4Y5:CLOCKREGION_X4Y7',
    2: 'CLOCKREGION_X4Y9:CLOCKREGION_X4Y11',
    3: 'CLOCKREGION_X4Y12:CLOCKREGION_X4Y14'
  }

  # the rightmost column
  VITIS_REGION = 'CLOCKREGION_X7Y0:CLOCKREGION_X7Y15'


class DeviceU280(DeviceBase):
  def _getVitisRegions(self, ddr_list, is_vitis_enabled):
    assert all(ddr in [0, 1] for ddr in ddr_list) # u280 only has 2 ddrs on SLR0 and SLR1

    # the area used by implicit IPs
    pre_existing_area = []
    for ddr in ddr_list:
      pre_existing_area.append(f'CLOCKREGION_X4Y{4 * ddr}:CLOCKREGION_X4Y{4 * ddr + 3}')

    # the vitis platform will take away the rightmost column
    if is_vitis_enabled:
      pre_existing_area.append(self.VITIS_REGION) # the area consumed by Vitis platform
    
    return pre_existing_area

  NAME = 'U280'
  FPGA_PART_NAME = 'xcu280-fsvh2892-2L-e'

  SLR_NUM = 4 # add a pseudo SLR at the top with area 0
  CR_NUM_HORIZONTAL = 8
  CR_NUM_VERTICAL = 12
  CR_NUM_VERTICAL_PER_SLR = 4
  
  TOTAL_AREA = {}
  TOTAL_AREA['BRAM'] = 4032
  TOTAL_AREA['DSP'] = 9024
  TOTAL_AREA['FF'] = 2607360
  TOTAL_AREA['LUT'] = 1303680
  TOTAL_AREA['URAM'] = 960

  # Clock Region level
  CR_AREA = defaultdict(lambda: defaultdict(dict))

  CR_AREA[0][0 ]['FF']  = 29760    
  CR_AREA[1][0 ]['FF']  = 24960 
  CR_AREA[0][1 ]['FF']  = 29760
  CR_AREA[1][1 ]['FF']  = 24960 
  CR_AREA[0][2 ]['FF']  = 29760
  CR_AREA[1][2 ]['FF']  = 24960 
  CR_AREA[0][3 ]['FF']  = 27840
  CR_AREA[1][3 ]['FF']  = 23040 
  CR_AREA[0][4 ]['FF']  = 27840
  CR_AREA[1][4 ]['FF']  = 23040 
  CR_AREA[0][5 ]['FF']  = 29760
  CR_AREA[1][5 ]['FF']  = 24960 
  CR_AREA[0][6 ]['FF']  = 29760
  CR_AREA[1][6 ]['FF']  = 24960 
  CR_AREA[0][7 ]['FF']  = 27840
  CR_AREA[1][7 ]['FF']  = 23040 
  CR_AREA[0][8 ]['FF']  = 27840
  CR_AREA[1][8 ]['FF']  = 23040 
  CR_AREA[0][9 ]['FF']  = 29760
  CR_AREA[1][9 ]['FF']  = 24960 
  CR_AREA[0][10]['FF']  =	29760
  CR_AREA[1][10]['FF']  =	24960 
  CR_AREA[0][11]['FF']  =	27840
  CR_AREA[1][11]['FF']  =	23040 
  CR_AREA[2][0 ]['FF']  = 36480
  CR_AREA[3][0 ]['FF']  = 21120 
  CR_AREA[2][1 ]['FF']  = 36480 
  CR_AREA[3][1 ]['FF']  = 21120 
  CR_AREA[2][2 ]['FF']  = 36480 
  CR_AREA[3][2 ]['FF']  = 21120 
  CR_AREA[2][3 ]['FF']  = 34560 
  CR_AREA[3][3 ]['FF']  = 19200
  CR_AREA[2][4 ]['FF']  = 34560 
  CR_AREA[3][4 ]['FF']  = 19200
  CR_AREA[2][5 ]['FF']  = 36480 
  CR_AREA[3][5 ]['FF']  = 21120 
  CR_AREA[2][6 ]['FF']  = 36480 
  CR_AREA[3][6 ]['FF']  = 21120 
  CR_AREA[2][7 ]['FF']  = 34560 
  CR_AREA[3][7 ]['FF']  = 19200
  CR_AREA[2][8 ]['FF']  = 34560 
  CR_AREA[3][8 ]['FF']  = 19200
  CR_AREA[2][9 ]['FF']  = 36480 
  CR_AREA[3][9 ]['FF']  = 21120 
  CR_AREA[2][10]['FF']  =	36480 
  CR_AREA[3][10]['FF']  =	21120 
  CR_AREA[2][11]['FF']  =	34560 
  CR_AREA[3][11]['FF']  =	19200
  CR_AREA[4][0 ]['FF']  = 27840 
  CR_AREA[5][0 ]['FF']  = 28800 
  CR_AREA[4][1 ]['FF']  = 27840 
  CR_AREA[5][1 ]['FF']  = 28800  
  CR_AREA[4][2 ]['FF']  = 27840 
  CR_AREA[5][2 ]['FF']  = 28800  
  CR_AREA[4][3 ]['FF']  = 25920 
  CR_AREA[5][3 ]['FF']  = 26880  
  CR_AREA[4][4 ]['FF']  = 25920 
  CR_AREA[5][4 ]['FF']  = 26880  
  CR_AREA[4][5 ]['FF']  = 27840 
  CR_AREA[5][5 ]['FF']  = 28800  
  CR_AREA[4][6 ]['FF']  = 27840 
  CR_AREA[5][6 ]['FF']  = 28800  
  CR_AREA[4][7 ]['FF']  = 25920 
  CR_AREA[5][7 ]['FF']  = 26880  
  CR_AREA[4][8 ]['FF']  = 25920 
  CR_AREA[5][8 ]['FF']  = 26880  
  CR_AREA[4][9 ]['FF']  = 27840 
  CR_AREA[5][9 ]['FF']  = 28800  
  CR_AREA[4][10]['FF']  =	27840 
  CR_AREA[5][10]['FF']  =	28800  
  CR_AREA[4][11]['FF']  =	25920 
  CR_AREA[5][11]['FF']  =	26880  
  CR_AREA[6][0 ]['FF']  = 28800 
  CR_AREA[7][0 ]['FF']  = 25920
  CR_AREA[6][1 ]['FF']  = 28800  
  CR_AREA[7][1 ]['FF']  = 25920
  CR_AREA[6][2 ]['FF']  = 28800  
  CR_AREA[7][2 ]['FF']  = 25920
  CR_AREA[6][3 ]['FF']  = 26880  
  CR_AREA[7][3 ]['FF']  = 24000
  CR_AREA[6][4 ]['FF']  = 26880  
  CR_AREA[7][4 ]['FF']  = 24000
  CR_AREA[6][5 ]['FF']  = 28800  
  CR_AREA[7][5 ]['FF']  = 25920
  CR_AREA[6][6 ]['FF']  = 28800  
  CR_AREA[7][6 ]['FF']  = 25920
  CR_AREA[6][7 ]['FF']  = 26880  
  CR_AREA[7][7 ]['FF']  = 24000
  CR_AREA[6][8 ]['FF']  = 26880  
  CR_AREA[7][8 ]['FF']  = 24000
  CR_AREA[6][9 ]['FF']  = 28800  
  CR_AREA[7][9 ]['FF']  = 25920
  CR_AREA[6][10]['FF']  =	28800  
  CR_AREA[7][10]['FF']  =	25920
  CR_AREA[6][11]['FF']  =	26880  
  CR_AREA[7][11]['FF']  =	24000
      
  ################    
      
  CR_AREA[0][0 ]['LUT'] = 14880  
  CR_AREA[1][0 ]['LUT'] = 12480   
  CR_AREA[0][1 ]['LUT'] = 14880  
  CR_AREA[1][1 ]['LUT'] = 12480   
  CR_AREA[0][2 ]['LUT'] = 14880  
  CR_AREA[1][2 ]['LUT'] = 12480   
  CR_AREA[0][3 ]['LUT'] = 13920  
  CR_AREA[1][3 ]['LUT'] = 11520   
  CR_AREA[0][4 ]['LUT'] = 13920  
  CR_AREA[1][4 ]['LUT'] = 11520   
  CR_AREA[0][5 ]['LUT'] = 14880  
  CR_AREA[1][5 ]['LUT'] = 12480   
  CR_AREA[0][6 ]['LUT'] = 14880  
  CR_AREA[1][6 ]['LUT'] = 12480   
  CR_AREA[0][7 ]['LUT'] = 13920  
  CR_AREA[1][7 ]['LUT'] = 11520   
  CR_AREA[0][8 ]['LUT'] = 13920  
  CR_AREA[1][8 ]['LUT'] = 11520   
  CR_AREA[0][9 ]['LUT'] = 14880  
  CR_AREA[1][9 ]['LUT'] = 12480   
  CR_AREA[0][10]['LUT'] = 14880  
  CR_AREA[1][10]['LUT'] = 12480   
  CR_AREA[0][11]['LUT'] = 13920  
  CR_AREA[1][11]['LUT'] = 11520   
  CR_AREA[2][0 ]['LUT'] = 18240  
  CR_AREA[3][0 ]['LUT'] = 10560   
  CR_AREA[2][1 ]['LUT'] = 18240   
  CR_AREA[3][1 ]['LUT'] = 10560   
  CR_AREA[2][2 ]['LUT'] = 18240   
  CR_AREA[3][2 ]['LUT'] = 10560   
  CR_AREA[2][3 ]['LUT'] = 17280   
  CR_AREA[3][3 ]['LUT'] = 9600	  
  CR_AREA[2][4 ]['LUT'] = 17280   
  CR_AREA[3][4 ]['LUT'] = 9600	  
  CR_AREA[2][5 ]['LUT'] = 18240   
  CR_AREA[3][5 ]['LUT'] = 10560   
  CR_AREA[2][6 ]['LUT'] = 18240   
  CR_AREA[3][6 ]['LUT'] = 10560   
  CR_AREA[2][7 ]['LUT'] = 17280   
  CR_AREA[3][7 ]['LUT'] = 9600	  
  CR_AREA[2][8 ]['LUT'] = 17280   
  CR_AREA[3][8 ]['LUT'] = 9600	  
  CR_AREA[2][9 ]['LUT'] = 18240   
  CR_AREA[3][9 ]['LUT'] = 10560   
  CR_AREA[2][10]['LUT'] = 18240   
  CR_AREA[3][10]['LUT'] = 10560   
  CR_AREA[2][11]['LUT'] = 17280   
  CR_AREA[3][11]['LUT'] = 9600	  
  CR_AREA[4][0 ]['LUT'] = 13920   
  CR_AREA[5][0 ]['LUT'] = 14400   
  CR_AREA[4][1 ]['LUT'] = 13920   
  CR_AREA[5][1 ]['LUT'] = 14400    
  CR_AREA[4][2 ]['LUT'] = 13920   
  CR_AREA[5][2 ]['LUT'] = 14400    
  CR_AREA[4][3 ]['LUT'] = 12960   
  CR_AREA[5][3 ]['LUT'] = 13440    
  CR_AREA[4][4 ]['LUT'] = 12960   
  CR_AREA[5][4 ]['LUT'] = 13440    
  CR_AREA[4][5 ]['LUT'] = 13920   
  CR_AREA[5][5 ]['LUT'] = 14400    
  CR_AREA[4][6 ]['LUT'] = 13920   
  CR_AREA[5][6 ]['LUT'] = 14400    
  CR_AREA[4][7 ]['LUT'] = 12960   
  CR_AREA[5][7 ]['LUT'] = 13440    
  CR_AREA[4][8 ]['LUT'] = 12960   
  CR_AREA[5][8 ]['LUT'] = 13440    
  CR_AREA[4][9 ]['LUT'] = 13920   
  CR_AREA[5][9 ]['LUT'] = 14400    
  CR_AREA[4][10]['LUT'] = 13920   
  CR_AREA[5][10]['LUT'] = 14400    
  CR_AREA[4][11]['LUT'] = 12960   
  CR_AREA[5][11]['LUT'] = 13440    
  CR_AREA[6][0 ]['LUT'] = 14400   
  CR_AREA[7][0 ]['LUT'] = 12960  
  CR_AREA[6][1 ]['LUT'] = 14400    
  CR_AREA[7][1 ]['LUT'] = 12960  
  CR_AREA[6][2 ]['LUT'] = 14400    
  CR_AREA[7][2 ]['LUT'] = 12960  
  CR_AREA[6][3 ]['LUT'] = 13440    
  CR_AREA[7][3 ]['LUT'] = 12000  
  CR_AREA[6][4 ]['LUT'] = 13440    
  CR_AREA[7][4 ]['LUT'] = 12000  
  CR_AREA[6][5 ]['LUT'] = 14400    
  CR_AREA[7][5 ]['LUT'] = 12960  
  CR_AREA[6][6 ]['LUT'] = 14400    
  CR_AREA[7][6 ]['LUT'] = 12960  
  CR_AREA[6][7 ]['LUT'] = 13440    
  CR_AREA[7][7 ]['LUT'] = 12000  
  CR_AREA[6][8 ]['LUT'] = 13440    
  CR_AREA[7][8 ]['LUT'] = 12000  
  CR_AREA[6][9 ]['LUT'] = 14400    
  CR_AREA[7][9 ]['LUT'] = 12960  
  CR_AREA[6][10]['LUT'] = 14400    
  CR_AREA[7][10]['LUT'] = 12960  
  CR_AREA[6][11]['LUT'] = 13440    
  CR_AREA[7][11]['LUT'] = 12000  
      
  ##################    
      
  CR_AREA[0][0 ]['DSP'] =	72	   
  CR_AREA[1][0 ]['DSP'] =	72	    
  CR_AREA[0][1 ]['DSP'] =	96	   
  CR_AREA[1][1 ]['DSP'] =	96	    
  CR_AREA[0][2 ]['DSP'] =	96	   
  CR_AREA[1][2 ]['DSP'] =	96	    
  CR_AREA[0][3 ]['DSP'] =	96	   
  CR_AREA[1][3 ]['DSP'] =	96	    
  CR_AREA[0][4 ]['DSP'] =	96	   
  CR_AREA[1][4 ]['DSP'] =	96	    
  CR_AREA[0][5 ]['DSP'] =	96	   
  CR_AREA[1][5 ]['DSP'] =	96	    
  CR_AREA[0][6 ]['DSP'] =	96	   
  CR_AREA[1][6 ]['DSP'] =	96	    
  CR_AREA[0][7 ]['DSP'] =	96	   
  CR_AREA[1][7 ]['DSP'] =	96	    
  CR_AREA[0][8 ]['DSP'] =	96	   
  CR_AREA[1][8 ]['DSP'] =	96	    
  CR_AREA[0][9 ]['DSP'] =	96	   
  CR_AREA[1][9 ]['DSP'] =	96	    
  CR_AREA[0][10]['DSP'] =	96	   
  CR_AREA[1][10]['DSP'] =	96	    
  CR_AREA[0][11]['DSP'] =	96	   
  CR_AREA[1][11]['DSP'] =	96	    
  CR_AREA[2][0 ]['DSP'] =	90	   
  CR_AREA[3][0 ]['DSP'] =	54	    
  CR_AREA[2][1 ]['DSP'] =	120	   
  CR_AREA[3][1 ]['DSP'] =	72	    
  CR_AREA[2][2 ]['DSP'] =	120	   
  CR_AREA[3][2 ]['DSP'] =	72	    
  CR_AREA[2][3 ]['DSP'] =	120	   
  CR_AREA[3][3 ]['DSP'] =	72	    
  CR_AREA[2][4 ]['DSP'] =	120	   
  CR_AREA[3][4 ]['DSP'] =	72	    
  CR_AREA[2][5 ]['DSP'] =	120	   
  CR_AREA[3][5 ]['DSP'] =	72	    
  CR_AREA[2][6 ]['DSP'] =	120	   
  CR_AREA[3][6 ]['DSP'] =	72	    
  CR_AREA[2][7 ]['DSP'] =	120	   
  CR_AREA[3][7 ]['DSP'] =	72	    
  CR_AREA[2][8 ]['DSP'] =	120	   
  CR_AREA[3][8 ]['DSP'] =	72	    
  CR_AREA[2][9 ]['DSP'] =	120	   
  CR_AREA[3][9 ]['DSP'] =	72	    
  CR_AREA[2][10]['DSP'] =	120	   
  CR_AREA[3][10]['DSP'] =	72	    
  CR_AREA[2][11]['DSP'] =	120	   
  CR_AREA[3][11]['DSP'] =	72	    
  CR_AREA[4][0 ]['DSP'] =	72	    
  CR_AREA[5][0 ]['DSP'] =	90	    
  CR_AREA[4][1 ]['DSP'] =	96	    
  CR_AREA[5][1 ]['DSP'] =	120	    
  CR_AREA[4][2 ]['DSP'] =	96	    
  CR_AREA[5][2 ]['DSP'] =	120	    
  CR_AREA[4][3 ]['DSP'] =	96	    
  CR_AREA[5][3 ]['DSP'] =	120	    
  CR_AREA[4][4 ]['DSP'] =	96	    
  CR_AREA[5][4 ]['DSP'] =	120	    
  CR_AREA[4][5 ]['DSP'] =	96	    
  CR_AREA[5][5 ]['DSP'] =	120	    
  CR_AREA[4][6 ]['DSP'] =	96	    
  CR_AREA[5][6 ]['DSP'] =	120	    
  CR_AREA[4][7 ]['DSP'] =	96	    
  CR_AREA[5][7 ]['DSP'] =	120	    
  CR_AREA[4][8 ]['DSP'] =	96	    
  CR_AREA[5][8 ]['DSP'] =	120	    
  CR_AREA[4][9 ]['DSP'] =	96	    
  CR_AREA[5][9 ]['DSP'] =	120	    
  CR_AREA[4][10]['DSP'] =	96	    
  CR_AREA[5][10]['DSP'] =	120	    
  CR_AREA[4][11]['DSP'] =	96	    
  CR_AREA[5][11]['DSP'] =	120	    
  CR_AREA[6][0 ]['DSP'] =	90	    
  CR_AREA[7][0 ]['DSP'] =	36	   
  CR_AREA[6][1 ]['DSP'] =	120	    
  CR_AREA[7][1 ]['DSP'] =	48	   
  CR_AREA[6][2 ]['DSP'] =	120	    
  CR_AREA[7][2 ]['DSP'] =	48	   
  CR_AREA[6][3 ]['DSP'] =	120	    
  CR_AREA[7][3 ]['DSP'] =	48	   
  CR_AREA[6][4 ]['DSP'] =	120	    
  CR_AREA[7][4 ]['DSP'] =	48	   
  CR_AREA[6][5 ]['DSP'] =	120	    
  CR_AREA[7][5 ]['DSP'] =	48	   
  CR_AREA[6][6 ]['DSP'] =	120	    
  CR_AREA[7][6 ]['DSP'] =	48	   
  CR_AREA[6][7 ]['DSP'] =	120	    
  CR_AREA[7][7 ]['DSP'] =	48	   
  CR_AREA[6][8 ]['DSP'] =	120	    
  CR_AREA[7][8 ]['DSP'] =	48	   
  CR_AREA[6][9 ]['DSP'] =	120	    
  CR_AREA[7][9 ]['DSP'] =	48	   
  CR_AREA[6][10]['DSP'] =	120	    
  CR_AREA[7][10]['DSP'] =	48	   
  CR_AREA[6][11]['DSP'] =	120	    
  CR_AREA[7][11]['DSP'] =	48	   
      
  ##################    
      
  CR_AREA[0][0 ]['BRAM'] = 24 * 2 
  CR_AREA[1][0 ]['BRAM'] = 24 * 2  
  CR_AREA[0][1 ]['BRAM'] = 24 * 2 
  CR_AREA[1][1 ]['BRAM'] = 24 * 2  
  CR_AREA[0][2 ]['BRAM'] = 24 * 2 
  CR_AREA[1][2 ]['BRAM'] = 24 * 2  
  CR_AREA[0][3 ]['BRAM'] = 24 * 2 
  CR_AREA[1][3 ]['BRAM'] = 24 * 2  
  CR_AREA[0][4 ]['BRAM'] = 24 * 2 
  CR_AREA[1][4 ]['BRAM'] = 24 * 2  
  CR_AREA[0][5 ]['BRAM'] = 24 * 2 
  CR_AREA[1][5 ]['BRAM'] = 24 * 2  
  CR_AREA[0][6 ]['BRAM'] = 24 * 2 
  CR_AREA[1][6 ]['BRAM'] = 24 * 2  
  CR_AREA[0][7 ]['BRAM'] = 24 * 2 
  CR_AREA[1][7 ]['BRAM'] = 24 * 2  
  CR_AREA[0][8 ]['BRAM'] = 24 * 2 
  CR_AREA[1][8 ]['BRAM'] = 24 * 2  
  CR_AREA[0][9 ]['BRAM'] = 24 * 2 
  CR_AREA[1][9 ]['BRAM'] = 24 * 2  
  CR_AREA[0][10]['BRAM'] = 24 * 2 
  CR_AREA[1][10]['BRAM'] = 24 * 2  
  CR_AREA[0][11]['BRAM'] = 24 * 2 
  CR_AREA[1][11]['BRAM'] = 24 * 2  
  CR_AREA[2][0 ]['BRAM'] = 36 * 2 
  CR_AREA[3][0 ]['BRAM'] = 12 * 2  
  CR_AREA[2][1 ]['BRAM'] = 36 * 2 
  CR_AREA[3][1 ]['BRAM'] = 12 * 2  
  CR_AREA[2][2 ]['BRAM'] = 36 * 2 
  CR_AREA[3][2 ]['BRAM'] = 12 * 2  
  CR_AREA[2][3 ]['BRAM'] = 36 * 2 
  CR_AREA[3][3 ]['BRAM'] = 12 * 2  
  CR_AREA[2][4 ]['BRAM'] = 36 * 2 
  CR_AREA[3][4 ]['BRAM'] = 12 * 2  
  CR_AREA[2][5 ]['BRAM'] = 36 * 2 
  CR_AREA[3][5 ]['BRAM'] = 12 * 2  
  CR_AREA[2][6 ]['BRAM'] = 36 * 2 
  CR_AREA[3][6 ]['BRAM'] = 12 * 2  
  CR_AREA[2][7 ]['BRAM'] = 36 * 2 
  CR_AREA[3][7 ]['BRAM'] = 12 * 2  
  CR_AREA[2][8 ]['BRAM'] = 36 * 2 
  CR_AREA[3][8 ]['BRAM'] = 12 * 2  
  CR_AREA[2][9 ]['BRAM'] = 36 * 2 
  CR_AREA[3][9 ]['BRAM'] = 12 * 2  
  CR_AREA[2][10]['BRAM'] = 36 * 2 
  CR_AREA[3][10]['BRAM'] = 12 * 2  
  CR_AREA[2][11]['BRAM'] = 36 * 2 
  CR_AREA[3][11]['BRAM'] = 12 * 2  
  CR_AREA[4][0 ]['BRAM'] = 24 * 2  
  CR_AREA[5][0 ]['BRAM'] = 12 * 2  
  CR_AREA[4][1 ]['BRAM'] = 24 * 2  
  CR_AREA[5][1 ]['BRAM'] = 12 * 2  
  CR_AREA[4][2 ]['BRAM'] = 24 * 2  
  CR_AREA[5][2 ]['BRAM'] = 12 * 2  
  CR_AREA[4][3 ]['BRAM'] = 24 * 2  
  CR_AREA[5][3 ]['BRAM'] = 12 * 2  
  CR_AREA[4][4 ]['BRAM'] = 24 * 2  
  CR_AREA[5][4 ]['BRAM'] = 12 * 2  
  CR_AREA[4][5 ]['BRAM'] = 24 * 2  
  CR_AREA[5][5 ]['BRAM'] = 12 * 2  
  CR_AREA[4][6 ]['BRAM'] = 24 * 2  
  CR_AREA[5][6 ]['BRAM'] = 12 * 2  
  CR_AREA[4][7 ]['BRAM'] = 24 * 2  
  CR_AREA[5][7 ]['BRAM'] = 12 * 2  
  CR_AREA[4][8 ]['BRAM'] = 24 * 2  
  CR_AREA[5][8 ]['BRAM'] = 12 * 2  
  CR_AREA[4][9 ]['BRAM'] = 24 * 2  
  CR_AREA[5][9 ]['BRAM'] = 12 * 2  
  CR_AREA[4][10]['BRAM'] = 24 * 2  
  CR_AREA[5][10]['BRAM'] = 12 * 2  
  CR_AREA[4][11]['BRAM'] = 24 * 2  
  CR_AREA[5][11]['BRAM'] = 12 * 2  
  CR_AREA[6][0 ]['BRAM'] = 12 * 2  
  CR_AREA[7][0 ]['BRAM'] = 24 * 2 
  CR_AREA[6][1 ]['BRAM'] = 12 * 2  
  CR_AREA[7][1 ]['BRAM'] = 24 * 2 
  CR_AREA[6][2 ]['BRAM'] = 12 * 2  
  CR_AREA[7][2 ]['BRAM'] = 24 * 2 
  CR_AREA[6][3 ]['BRAM'] = 12 * 2  
  CR_AREA[7][3 ]['BRAM'] = 24 * 2 
  CR_AREA[6][4 ]['BRAM'] = 12 * 2  
  CR_AREA[7][4 ]['BRAM'] = 24 * 2 
  CR_AREA[6][5 ]['BRAM'] = 12 * 2  
  CR_AREA[7][5 ]['BRAM'] = 24 * 2 
  CR_AREA[6][6 ]['BRAM'] = 12 * 2  
  CR_AREA[7][6 ]['BRAM'] = 24 * 2 
  CR_AREA[6][7 ]['BRAM'] = 12 * 2  
  CR_AREA[7][7 ]['BRAM'] = 24 * 2 
  CR_AREA[6][8 ]['BRAM'] = 12 * 2  
  CR_AREA[7][8 ]['BRAM'] = 24 * 2 
  CR_AREA[6][9 ]['BRAM'] = 12 * 2  
  CR_AREA[7][9 ]['BRAM'] = 24 * 2 
  CR_AREA[6][10]['BRAM'] = 12 * 2  
  CR_AREA[7][10]['BRAM'] = 24 * 2 
  CR_AREA[6][11]['BRAM'] = 12 * 2  
  CR_AREA[7][11]['BRAM'] = 24 * 2 
      
  #####################    
      
  CR_AREA[0][0 ]['URAM'] = 0    
  CR_AREA[1][0 ]['URAM'] = 16    
  CR_AREA[0][1 ]['URAM'] = 0    
  CR_AREA[1][1 ]['URAM'] = 16    
  CR_AREA[0][2 ]['URAM'] = 0    
  CR_AREA[1][2 ]['URAM'] = 16    
  CR_AREA[0][3 ]['URAM'] = 0    
  CR_AREA[1][3 ]['URAM'] = 16    
  CR_AREA[0][4 ]['URAM'] = 0    
  CR_AREA[1][4 ]['URAM'] = 16    
  CR_AREA[0][5 ]['URAM'] = 0    
  CR_AREA[1][5 ]['URAM'] = 16    
  CR_AREA[0][6 ]['URAM'] = 0    
  CR_AREA[1][6 ]['URAM'] = 16    
  CR_AREA[0][7 ]['URAM'] = 0    
  CR_AREA[1][7 ]['URAM'] = 16    
  CR_AREA[0][8 ]['URAM'] = 0    
  CR_AREA[1][8 ]['URAM'] = 16    
  CR_AREA[0][9 ]['URAM'] = 0    
  CR_AREA[1][9 ]['URAM'] = 16    
  CR_AREA[0][10]['URAM'] = 0    
  CR_AREA[1][10]['URAM'] = 16    
  CR_AREA[0][11]['URAM'] = 0    
  CR_AREA[1][11]['URAM'] = 16    
  CR_AREA[2][0 ]['URAM'] = 0    
  CR_AREA[3][0 ]['URAM'] = 16    
  CR_AREA[2][1 ]['URAM'] = 0    
  CR_AREA[3][1 ]['URAM'] = 16    
  CR_AREA[2][2 ]['URAM'] = 0    
  CR_AREA[3][2 ]['URAM'] = 16    
  CR_AREA[2][3 ]['URAM'] = 0    
  CR_AREA[3][3 ]['URAM'] = 16    
  CR_AREA[2][4 ]['URAM'] = 0    
  CR_AREA[3][4 ]['URAM'] = 16    
  CR_AREA[2][5 ]['URAM'] = 0    
  CR_AREA[3][5 ]['URAM'] = 16    
  CR_AREA[2][6 ]['URAM'] = 0    
  CR_AREA[3][6 ]['URAM'] = 16    
  CR_AREA[2][7 ]['URAM'] = 0    
  CR_AREA[3][7 ]['URAM'] = 16    
  CR_AREA[2][8 ]['URAM'] = 0    
  CR_AREA[3][8 ]['URAM'] = 16    
  CR_AREA[2][9 ]['URAM'] = 0    
  CR_AREA[3][9 ]['URAM'] = 16    
  CR_AREA[2][10]['URAM'] = 0    
  CR_AREA[3][10]['URAM'] = 16    
  CR_AREA[2][11]['URAM'] = 0    
  CR_AREA[3][11]['URAM'] = 16    
  CR_AREA[4][0 ]['URAM'] = 16    
  CR_AREA[5][0 ]['URAM'] = 16    
  CR_AREA[4][1 ]['URAM'] = 16    
  CR_AREA[5][1 ]['URAM'] = 16    
  CR_AREA[4][2 ]['URAM'] = 16    
  CR_AREA[5][2 ]['URAM'] = 16    
  CR_AREA[4][3 ]['URAM'] = 16    
  CR_AREA[5][3 ]['URAM'] = 16    
  CR_AREA[4][4 ]['URAM'] = 16    
  CR_AREA[5][4 ]['URAM'] = 16    
  CR_AREA[4][5 ]['URAM'] = 16    
  CR_AREA[5][5 ]['URAM'] = 16    
  CR_AREA[4][6 ]['URAM'] = 16    
  CR_AREA[5][6 ]['URAM'] = 16    
  CR_AREA[4][7 ]['URAM'] = 16    
  CR_AREA[5][7 ]['URAM'] = 16    
  CR_AREA[4][8 ]['URAM'] = 16    
  CR_AREA[5][8 ]['URAM'] = 16    
  CR_AREA[4][9 ]['URAM'] = 16    
  CR_AREA[5][9 ]['URAM'] = 16    
  CR_AREA[4][10]['URAM'] = 16    
  CR_AREA[5][10]['URAM'] = 16    
  CR_AREA[4][11]['URAM'] = 16    
  CR_AREA[5][11]['URAM'] = 16    
  CR_AREA[6][0 ]['URAM'] = 16    
  CR_AREA[7][0 ]['URAM'] = 0    
  CR_AREA[6][1 ]['URAM'] = 16    
  CR_AREA[7][1 ]['URAM'] = 0    
  CR_AREA[6][2 ]['URAM'] = 16    
  CR_AREA[7][2 ]['URAM'] = 0    
  CR_AREA[6][3 ]['URAM'] = 16    
  CR_AREA[7][3 ]['URAM'] = 0    
  CR_AREA[6][4 ]['URAM'] = 16    
  CR_AREA[7][4 ]['URAM'] = 0    
  CR_AREA[6][5 ]['URAM'] = 16    
  CR_AREA[7][5 ]['URAM'] = 0    
  CR_AREA[6][6 ]['URAM'] = 16    
  CR_AREA[7][6 ]['URAM'] = 0    
  CR_AREA[6][7 ]['URAM'] = 16    
  CR_AREA[7][7 ]['URAM'] = 0    
  CR_AREA[6][8 ]['URAM'] = 16    
  CR_AREA[7][8 ]['URAM'] = 0    
  CR_AREA[6][9 ]['URAM'] = 16    
  CR_AREA[7][9 ]['URAM'] = 0    
  CR_AREA[6][10]['URAM'] = 16    
  CR_AREA[7][10]['URAM'] = 0    
  CR_AREA[6][11]['URAM'] = 16    
  CR_AREA[7][11]['URAM'] = 0

  # for item in ('BRAM', 'DSP', 'FF', 'LUT', 'URAM'):
  #   assert TOTAL_AREA[item] == sum(CR_AREA[x][y][item] for x in range(8) for y in range(12))

  VITIS_REGION = f'CLOCKREGION_X7Y1:CLOCKREGION_X7Y11'

  DDR_TO_CLOCK_REGIONS = {
    0: 'CLOCKREGION_X4Y1:CLOCKREGION_X4Y3',
    1: 'CLOCKREGION_X4Y5:CLOCKREGION_X4Y7',
  }

  def getDDRSlolenRegion(self, ddr: int) -> str:
    assert 0 <= ddr <= 3, ddr
    # entire sloten region is {SLICE_X144Y0:SLICE_X145Y959 DSP48E2_X19Y0:DSP48E2_X19Y383 RAMB18_X9Y0:RAMB18_X9Y383 RAMB36_X9Y0:RAMB36_X9Y191}
    return f'SLICE_X144Y{240 * ddr}:SLICE_X145Y{240 * (ddr+1) - 1} DSP48E2_X19Y{96 * ddr}:DSP48E2_X19Y{96 * (ddr+1) - 1} RAMB18_X9Y{96 * ddr}:RAMB18_X9Y{96 * (ddr+1) - 1} RAMB36_X9Y{48 * ddr}:RAMB36_X9Y{48 * (ddr+1) - 1}'


class DeviceManager:
  def __init__(self, board_name, ddr_list = [], is_vitis_enabled = False):
    if board_name == 'U250':
      self.board = DeviceU250(ddr_list, is_vitis_enabled)
    elif board_name == 'U280':
      self.board = DeviceU280(ddr_list, is_vitis_enabled)
    else:
      assert False, f'unsupported device: {board_name}'

  def getBoard(self):
    return self.board