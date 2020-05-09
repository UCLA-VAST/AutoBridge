#! /usr/bin/python3.6

import graph
from format_hls import FormatHLS
import collections

solution_path = f'/home/einsx7/pr/application/Compression/hls/deflate_orig_backup/solution'
top_name = 'deflate'
rpt_path = f'{solution_path}/syn/report'
hls_sche_path = f'{solution_path}/.autopilot/db'
hdl_path = f'{solution_path}/syn/verilog'

# Control_Control.v
# use list according to the api of pyverilog
top_hdl_path = f'{hdl_path}/{top_name}_{top_name}.v'

DDR_loc = collections.defaultdict(dict)
DDR_loc['feed9_U0'] = 0
DDR_loc['export_data_U0'] = 1

DDR_loc_2d_x = collections.defaultdict(dict)
DDR_loc_2d_y = collections.defaultdict(dict)

DDR_loc_2d_y['feed9_U0'] = 0
DDR_loc_2d_y['export_data_U0'] = 1
DDR_loc_2d_x['feed9_U0'] = 0
DDR_loc_2d_x['export_data_U0'] = 0

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

column = 2

#t = lambda x, y : 0.8 if x == 0 and y < 2 else 0.8 if x == 0 else 0.4
#max_usage_ratio_2d = [ [ t(x, y) for y in range(SLR_CNT)] for x in range(column) ]
max_usage_ratio_2d = [ [ 0.8, 0.8, 0.8, 0.8], [0.4, 0.4, 0.8, 0.8] ]

horizontal_cross_penalty = 0

formator = FormatHLS(
  rpt_path,
  hls_sche_path,
  top_hdl_path,
  top_name,
  DDR_loc, DDR_loc_2d_x, DDR_loc_2d_y,
  max_usage_ratio, max_usage_ratio_2d,
  SLR_CNT,column,
  SLR_AREA,
  'u250',
  horizontal_cross_penalty)

g = graph.Graph(formator)
