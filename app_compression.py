#! /usr/bin/python3.6

import graph
from format_hls import FormatHLS
import collections
import os

# fifo 128
solution_path = f'/home/einsx7/pr/application/Compression/hls/deflate_orig_backup/solution'
# fifo 2048
#solution_path = f'/home/einsx7/pr/application/Compression/0511_fifo2048/deflate/solution'

top_name = 'deflate'
rpt_path = f'{solution_path}/syn/report'
hls_sche_path = f'{solution_path}/.autopilot/db'
hdl_path = f'{solution_path}/syn/verilog'

# Control_Control.v
# use list according to the api of pyverilog
top_hdl_path = f'{hdl_path}/{top_name}_{top_name}.v'
print(top_hdl_path)
DDR_loc = collections.defaultdict(dict)
DDR_loc['feed9_U0'] = 0
DDR_loc['export_data_U0'] = 1

DDR_loc_2d_x = collections.defaultdict(dict)
DDR_loc_2d_y = collections.defaultdict(dict)

DDR_loc_2d_y['feed9_U0'] = 0
DDR_loc_2d_y['export_data_U0'] = 1
DDR_loc_2d_x['feed9_U0'] = 0
DDR_loc_2d_x['export_data_U0'] = 1

# only the DDRs in SLR0 and SLR1 are enabled
DDR_enable = [1, 1, 0, 0]

max_usage_ratio = 0.6

# F1
# SLR_CNT = 3
# BRAM_SLR = 1440
# DSP_SLR = 2280
# FF_SLR = 788160
# LUT_SLR = 394080 

# u250
SLR_CNT = 4
SLR_AREA = {}
SLR_AREA['BRAM'] = 1344
SLR_AREA['DSP'] = 3072
SLR_AREA['FF'] = 864000
SLR_AREA['LUT'] = 432000

# u280
# SLR_CNT = 3
# SLR_AREA = {}
# SLR_AREA['BRAM'] = 1344
# SLR_AREA['DSP'] = 3008
# SLR_AREA['FF'] = 869120
# SLR_AREA['LUT'] = 434560

# the DDR controllers in SLR 0 and SLR 1 are instantiated, so split the two SLR
column = [2, 2, 2, 2]

#t = lambda x, y : 0.8 if x == 0 and y < 2 else 0.8 if x == 0 else 0.4
#max_usage_ratio_2d = [ [ t(x, y) for y in range(SLR_CNT)] for x in range(column) ]

# the right half of SLR0 and SLR1 contains the DDR controller and the static region, which takes away half the resources
max_usage_ratio_2d = [ [0.8, 0.4], [0.67, 0.4], [0.8, 0.8], [0.8, 0.8] ]

# to handle situation like this
# |   R0  |
# |-------|
# | R1|R2 |
# |-------|
# the x of R1 and R2 is originally 0 and 1
# now we set it to 0 and 2, and R0 to 1
# we avoid assigning 0.5 to R0, which will make the situation Mixed ILP
coorinate_expansion_ratio = 2

NUM_PER_SLR_HORIZONTAL = 4
max_width_threshold = 10000

target_dir = '/home/einsx7/pr/application/Compression/0512_FP3_EarlyBlockPlacement'
check = input(f'Please confirm the target directory is: \n{target_dir}\n(Y/n):  ')
if (check != 'Y'):
  exit
  
if (not os.path.isdir(f'{target_dir}/{top_name}')):
  print('Please place the HLS project under the target directory')
  exit

horizontal_cross_weight = 0.7

formator = FormatHLS()
formator.init_dataflow(
  rpt_path,
  hls_sche_path,
  top_hdl_path,
  top_name,
  DDR_loc, DDR_loc_2d_x, DDR_loc_2d_y, DDR_enable,
  max_usage_ratio, max_usage_ratio_2d,
  SLR_CNT,column,
  SLR_AREA,
  'u250',
  coorinate_expansion_ratio,
  max_width_threshold,
  NUM_PER_SLR_HORIZONTAL,
  horizontal_cross_weight,
  target_dir)

g = graph.Graph(formator)
