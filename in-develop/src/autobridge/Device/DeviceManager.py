from collections import defaultdict
from autobridge.Opt.Slot import Slot
import re

class DeviceBase:
  NAME = 'Base'
  CR_AREA = None
  CR_NUM_VERTICAL = None
  FPGA_PART_NAME = None
  
  def __init__(self, ddr_list, is_vitis_enabled):
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
      for i in range(DL_x, UR_x+1): # note the +1 here
        area[item] += self.CR_AREA[i][item]
      
      # how many rows
      assert UR_y >= DL_y
      area[item] *= (UR_y - DL_y + 1)

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

  def getSlotPblockTcl(self, slot_pblock, pblock_name):
    """
    remove the overlaps with vitis IPs
    """
    return f'''
create_pblock {pblock_name}
resize_pblock {pblock_name} -add {slot_pblock}
resize_pblock {pblock_name} -remove {{
  ''' + '\n  '.join(self.pre_existing_area) + '\n}'


class DeviceU250(DeviceBase):
  def _getVitisRegions(self, ddr_list, is_vitis_enabled):
    assert all(ddr in [0, 1, 2, 3] for ddr in ddr_list) # u250 has 4 ddrs

    # the area used by implicit IPs
    pre_existing_area = []
    for ddr in ddr_list:
      pre_existing_area.append(f'CLOCKREGION_X4Y{4 * ddr}:CLOCKREGION_X4Y{4 * ddr + 3}')

    # the vitis platform will take away the rightmost column
    if is_vitis_enabled:
      pre_existing_area.append(f'CLOCKREGION_X7Y0:CLOCKREGION_X7Y15') # the area consumed by Vitis platform
    
    return pre_existing_area


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

  CR_AREA[7]['BRAM'] = 48
  CR_AREA[7]['DSP'] = 48
  CR_AREA[7]['FF'] = 24000
  CR_AREA[7]['LUT'] = 12000
  CR_AREA[7]['URAM'] = 0

  TOTAL_AREA = {}
  TOTAL_AREA['BRAM'] = 5376
  TOTAL_AREA['DSP'] = 12288
  TOTAL_AREA['FF'] = 3456000
  TOTAL_AREA['LUT'] = 1728000
  TOTAL_AREA['URAM'] = 1280


class DeviceU280(DeviceBase):
  def _getVitisRegions(self, ddr_list, is_vitis_enabled):
    assert all(ddr in [0, 1] for ddr in ddr_list) # u280 only has 2 ddrs on SLR0 and SLR1

    # the area used by implicit IPs
    pre_existing_area = []
    for ddr in ddr_list:
      pre_existing_area.append(f'CLOCKREGION_X4Y{4 * ddr}:CLOCKREGION_X4Y{4 * ddr + 3}')

    # the vitis platform will take away the rightmost column
    if is_vitis_enabled:
      pre_existing_area.append(f'CLOCKREGION_X7Y0:CLOCKREGION_X7Y11') # the area consumed by Vitis platform
    
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

  CR_AREA[7]['BRAM'] = 48
  CR_AREA[7]['DSP']  = 36
  CR_AREA[7]['FF']   = 25920
  CR_AREA[7]['LUT']  = 12960
  CR_AREA[7]['URAM'] = 0


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