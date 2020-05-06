#! /usr/bin/python3.6

import graph
from format import FormatTLP
from format_hls import FormatHLS
import collections

solution_path = f'/home/einsx7/pr/application/Compression/_x.hw.xilinx_u250_xdma_201830_2/deflate/deflate/deflate/solution'
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

formator = FormatHLS(
  rpt_path,
  hls_sche_path,
  top_hdl_path,
  top_name,
  DDR_loc,
  max_usage_ratio,
  SLR_CNT,
  SLR_AREA)

g = graph.Graph(formator)
