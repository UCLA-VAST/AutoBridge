#! /usr/bin/python3.6

import graph
import format
import collections

tlp_path = '/home/einsx7/pr/application/PageRank/HBM_try1/PageRank.xilinx_u280_xdma_201920_3.hw.xo.tlp'
top_name = 'PageRank'
rpt_path = f'{tlp_path}/report'
hls_sche_path = f'{tlp_path}/report'
hdl_path = f'{tlp_path}/hdl'

# Control_Control.v
# use list according to the api of pyverilog
top_hdl_path = f'{hdl_path}/{top_name}_{top_name}.v'

DDR_loc = collections.defaultdict(dict)
DDR_loc['UpdateMem_0'] = 0
DDR_loc['UpdateMem_1'] = 0
DDR_loc['UpdateMem_2'] = 0
DDR_loc['UpdateMem_3'] = 0
DDR_loc['UpdateMem_4'] = 0
DDR_loc['UpdateMem_5'] = 0
DDR_loc['UpdateMem_6'] = 0
DDR_loc['UpdateMem_7'] = 0
DDR_loc['EdgeMem_0'] = 0
DDR_loc['EdgeMem_1'] = 0
DDR_loc['EdgeMem_2'] = 0
DDR_loc['EdgeMem_3'] = 0
DDR_loc['EdgeMem_4'] = 0
DDR_loc['EdgeMem_5'] = 0
DDR_loc['EdgeMem_6'] = 0
DDR_loc['EdgeMem_7'] = 0
DDR_loc['VertexMem_0'] = 0
DDR_loc['PageRank_control_s_axi_U'] = 0
DDR_loc['edges_0__m_axi'] = 0
DDR_loc['edges_1__m_axi'] = 0
DDR_loc['edges_2__m_axi'] = 0
DDR_loc['edges_3__m_axi'] = 0
DDR_loc['edges_4__m_axi'] = 0
DDR_loc['edges_5__m_axi'] = 0
DDR_loc['edges_6__m_axi'] = 0
DDR_loc['edges_7__m_axi'] = 0
DDR_loc['updates_0__m_axi'] = 0
DDR_loc['updates_1__m_axi'] = 0
DDR_loc['updates_2__m_axi'] = 0
DDR_loc['updates_3__m_axi'] = 0
DDR_loc['updates_4__m_axi'] = 0
DDR_loc['updates_5__m_axi'] = 0
DDR_loc['updates_6__m_axi'] = 0
DDR_loc['updates_7__m_axi'] = 0
DDR_loc['degrees__m_axi'] = 0
DDR_loc['rankings__m_axi'] = 0
DDR_loc['tmps__m_axi'] = 0

max_usage_ratio = 0.75

# F1
# SLR_CNT = 3
# BRAM_SLR = 1440
# DSP_SLR = 2280
# FF_SLR = 788160
# LUT_SLR = 394080 

# u250
# SLR_CNT = 4
# BRAM_SLR = 1344
# DSP_SLR = 3072
# FF_SLR = 864000
# LUT_SLR = 432000 

# u280
SLR_CNT = 3
SLR_AREA = {}
SLR_AREA['BRAM'] = 1344
SLR_AREA['DSP'] = 3008
SLR_AREA['FF'] = 869120
SLR_AREA['LUT'] = 434560

formator = format.FormatTLP(
  rpt_path,
  hls_sche_path,
  top_hdl_path,
  top_name,
  DDR_loc,
  max_usage_ratio,
  SLR_CNT,
  SLR_AREA)

g = graph.Graph(formator)
