#! /usr/bin/python3.6

import graph
from format_tlp import FormatTLP
import collections

tlp_path = '/home/einsx7/pr/application/PageRank/HBM_try1/PageRank.xilinx_u280_xdma_201920_3.hw.xo.tlp'
top_name = 'PageRank'
rpt_path = f'{tlp_path}/report'
hls_sche_path = f'{tlp_path}/report'
hdl_path = f'{tlp_path}/hdl'

# Control_Control.v
# use list according to the api of pyverilog
top_hdl_path = f'{hdl_path}/{top_name}_{top_name}.v'

DDR_loc_2d_x = collections.defaultdict(dict)
DDR_loc_2d_y = collections.defaultdict(dict)
DDR_loc_2d_y['UpdateMem_0'] = 0
DDR_loc_2d_y['UpdateMem_1'] = 0
DDR_loc_2d_y['UpdateMem_2'] = 0
DDR_loc_2d_y['UpdateMem_3'] = 0
DDR_loc_2d_y['UpdateMem_4'] = 0
DDR_loc_2d_y['UpdateMem_5'] = 0
DDR_loc_2d_y['UpdateMem_6'] = 0
DDR_loc_2d_y['UpdateMem_7'] = 0
DDR_loc_2d_y['EdgeMem_0'] = 0
DDR_loc_2d_y['EdgeMem_1'] = 0
DDR_loc_2d_y['EdgeMem_2'] = 0
DDR_loc_2d_y['EdgeMem_3'] = 0
DDR_loc_2d_y['EdgeMem_4'] = 0
DDR_loc_2d_y['EdgeMem_5'] = 0
DDR_loc_2d_y['EdgeMem_6'] = 0
DDR_loc_2d_y['EdgeMem_7'] = 0
DDR_loc_2d_y['VertexMem_0'] = 0
DDR_loc_2d_y['PageRank_control_s_axi_U'] = 0
DDR_loc_2d_y['edges_0__m_axi'] = 0
DDR_loc_2d_y['edges_1__m_axi'] = 0
DDR_loc_2d_y['edges_2__m_axi'] = 0
DDR_loc_2d_y['edges_3__m_axi'] = 0
DDR_loc_2d_y['edges_4__m_axi'] = 0
DDR_loc_2d_y['edges_5__m_axi'] = 0
DDR_loc_2d_y['edges_6__m_axi'] = 0
DDR_loc_2d_y['edges_7__m_axi'] = 0
DDR_loc_2d_y['updates_0__m_axi'] = 0
DDR_loc_2d_y['updates_1__m_axi'] = 0
DDR_loc_2d_y['updates_2__m_axi'] = 0
DDR_loc_2d_y['updates_3__m_axi'] = 0
DDR_loc_2d_y['updates_4__m_axi'] = 0
DDR_loc_2d_y['updates_5__m_axi'] = 0
DDR_loc_2d_y['updates_6__m_axi'] = 0
DDR_loc_2d_y['updates_7__m_axi'] = 0
DDR_loc_2d_y['degrees__m_axi'] = 0
DDR_loc_2d_y['rankings__m_axi'] = 0
DDR_loc_2d_y['tmps__m_axi'] = 0

DDR_loc_2d_x['UpdateMem_0'] = 0
DDR_loc_2d_x['UpdateMem_1'] = 0
DDR_loc_2d_x['UpdateMem_2'] = 0
DDR_loc_2d_x['UpdateMem_3'] = 0
DDR_loc_2d_x['UpdateMem_4'] = 0
DDR_loc_2d_x['UpdateMem_5'] = 1
DDR_loc_2d_x['UpdateMem_6'] = 1
DDR_loc_2d_x['UpdateMem_7'] = 1
DDR_loc_2d_x['EdgeMem_0'] = 0
DDR_loc_2d_x['EdgeMem_1'] = 0
DDR_loc_2d_x['EdgeMem_2'] = 0
DDR_loc_2d_x['EdgeMem_3'] = 0
DDR_loc_2d_x['EdgeMem_4'] = 0
DDR_loc_2d_x['EdgeMem_5'] = 0
DDR_loc_2d_x['EdgeMem_6'] = 1
DDR_loc_2d_x['EdgeMem_7'] = 1
# DDR_loc_2d_x['VertexMem_0'] = 0
# DDR_loc_2d_x['PageRank_control_s_axi_U'] = 0
DDR_loc_2d_x['edges_0__m_axi'] = 0
DDR_loc_2d_x['edges_1__m_axi'] = 0
DDR_loc_2d_x['edges_2__m_axi'] = 0
DDR_loc_2d_x['edges_3__m_axi'] = 0
DDR_loc_2d_x['edges_4__m_axi'] = 0
DDR_loc_2d_x['edges_5__m_axi'] = 0
DDR_loc_2d_x['edges_6__m_axi'] = 1
DDR_loc_2d_x['edges_7__m_axi'] = 1
DDR_loc_2d_x['updates_0__m_axi'] = 0
DDR_loc_2d_x['updates_1__m_axi'] = 0
DDR_loc_2d_x['updates_2__m_axi'] = 0
DDR_loc_2d_x['updates_3__m_axi'] = 0
DDR_loc_2d_x['updates_4__m_axi'] = 0
DDR_loc_2d_x['updates_5__m_axi'] = 1
DDR_loc_2d_x['updates_6__m_axi'] = 1
DDR_loc_2d_x['updates_7__m_axi'] = 1
DDR_loc_2d_x['degrees__m_axi'] = 1
DDR_loc_2d_x['rankings__m_axi'] = 1
DDR_loc_2d_x['tmps__m_axi'] = 1

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

DDR_enable = [0, 0, 0]
max_usage_ratio_2d = [ [0.9, 0.9], [1, 0.9], [1, 0.9] ]
column = [2, 2, 2]
# max_usage_ratio_2d = [ [0.75], [0.75], [0.75]]
# column = [1, 1, 1]

relay_station_count = lambda x : 2 * x # how many levels of relay stations to add for x-unit of crossing
relay_station_template = 'fifo' # 'fifo' or 'reg' or 'reg_srl_fifo'
constraint_edge = True # whether to add constraints to rs and FIFO
constraint_marked_edge = False

formator = FormatTLP(
  rpt_path,
  hls_sche_path,
  top_hdl_path,
  top_name,
  None, # DDR_loc
  DDR_loc_2d_x, 
  DDR_loc_2d_y, 
  DDR_enable,
  None, # max_usage_ratio
  max_usage_ratio_2d,
  SLR_CNT,
  column,
  SLR_AREA,
  'u280',
  coorinate_expansion_ratio = 2,
  max_width_threshold = 10000,
  NUM_PER_SLR_HORIZONTAL = 4,
  horizontal_cross_weight = 0.7,
  relay_station_count = relay_station_count,
  relay_station_template = relay_station_template,
  constraint_edge = constraint_edge,
  constraint_marked_edge = constraint_marked_edge)

g = graph.Graph(formator)
