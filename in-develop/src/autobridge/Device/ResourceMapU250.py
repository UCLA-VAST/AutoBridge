import re

class ResourceMapU250:
  def __init__(self) -> None:
    # record the X coordinates of the SLICE to the left of the BRAM column
    self.x_of_left_slice_of_bram_u250 = [
      9, 14, 32, 54,
      58, 89, 92, 112,
      119, 143, 147, 177,
      218, 223
    ]

    # record the X coordinates of the SLICE to the left of the DSP column
    self.x_of_left_slice_of_dsp_u250 = [
      1, 16, 27, 30,
      34, 41, 52, 56,
      60, 71, 76, 87,
      94, 99, 106, 114,
      121, 128, 141, 145,
      149, 156, 161, 166,
      175, 179, 186, 191,
      196, 205, 216, 229
    ]

    # assume each DSP and BRAM takes 1 unit of width
    self.num_SLICE_column = 233
    self.calibrated_x_pos_of_slice = [
      i + \
      sum(x < i for x in self.x_of_left_slice_of_bram_u250) + \
      sum(x < i for x in self.x_of_left_slice_of_dsp_u250) \
        for i in range(self.num_SLICE_column)]

    # map from calibrated x -> orig x
    self.orig_x_pos_of_slice = {self.calibrated_x_pos_of_slice[i] : i \
                                for i in range(self.num_SLICE_column)}

    # first get the calibrated pos of the nearby SLICE, then add by 1
    self.calibrated_x_pos_of_bram = [
      self.calibrated_x_pos_of_slice[i] + 1 \
        for i in self.x_of_left_slice_of_bram_u250
    ]

    self.calibrated_x_pos_of_dsp = [
        self.calibrated_x_pos_of_slice[i] + 1 \
        for i in self.x_of_left_slice_of_dsp_u250
    ]

  def getCalibratedCoordinatesFromSiteName(self, site_name):
    type, orig_x, orig_y = re.findall(r'(.*)_X(\d+)Y(\d+)', site_name)[0]
    orig_x, orig_y = map(int, (orig_x, orig_y))
    return self.getCalibratedCoordinates(type, orig_x, orig_y)

  def getCalibratedCoordinates(self, type, orig_x, orig_y):
    if type == 'SLICE':
      return (self.calibrated_x_pos_of_slice[orig_x], orig_y)
    elif type == 'DSP48E2':
      # each DSP is 2.5X the height of a SLICE
      return (self.calibrated_x_pos_of_dsp[orig_x], orig_y * 2.5)
    elif type == 'RAMB36':
      # each RAMB36 is 5X the height
      return (self.calibrated_x_pos_of_bram[orig_x], orig_y * 5)
    elif type == 'RAMB18':
      # each RAMB18 is 2.5X the height of a SLICE
      return (self.calibrated_x_pos_of_bram[orig_x], orig_y * 2.5)
    elif type == 'LAGUNA':
      return self.getLagunaCalibratedCoordinates(orig_x, orig_y)
    else:
      assert False, f'unsupported type {type}'

  def getLagunaCalibratedCoordinates(self, orig_x, orig_y):
    calibrated_x_pos_of_laguna = [
      8, 8, 19, 19, 
      37, 37, 50, 50, 
      63, 63, 85, 85, 
      97, 97, 111, 111, 
      124, 124, 139, 139, 
      152, 152, 164, 164, 
      182, 182, 194, 194, 
      214, 214, 225, 225
    ]
    cali_x = calibrated_x_pos_of_laguna[orig_x]

    if 120 <= orig_y <= 359:
      cali_y = 180 + int( (orig_y-120) / 2)
    elif 360 <= orig_y <= 599:
      cali_y = 420 + int( (orig_y-360) / 2)
    elif 600 <= orig_y <= 839:
      cali_y = 660 + int( (orig_y-600) / 2)
    else:
      assert False

    return (cali_x, cali_y)

  def getLagunaOrigCoordinates(self, cali_x, cali_y):
    if 180 <= cali_y <= 299:
      orig_y = (cali_y - 180) * 2 + 120
    elif 420 <= cali_y <= 539:
      orig_y = (cali_y - 420) * 2 + 360
    elif 660 <= cali_y <= 779:
      orig_y = (cali_y - 660) * 2 + 600
    else:
      assert False


  def getSliceOrigXCoordinates(self, calibrated_x):
    return self.orig_x_pos_of_slice[calibrated_x]