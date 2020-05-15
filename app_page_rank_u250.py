#! /usr/bin/python3.6

import graph
from formator import FormatTLP
import collections


DDR_loc_2d_x = collections.defaultdict(dict)
DDR_loc_2d_y = collections.defaultdict(dict)

tlp_path = '/home/einsx7/pr/application/U250_PageRank/tlp_src/tlpc_result'
top_name = 'PageRank'

rpt_path = f'{tlp_path}/report'
hls_sche_path = f'{tlp_path}/report'
hdl_path = f'{tlp_path}/hdl'
top_hdl_path = f'{hdl_path}/{top_name}_{top_name}.v'

DDR_loc_2d_y['edges_0__m_axi'] = 0
DDR_loc_2d_y['edges_1__m_axi'] = 1
DDR_loc_2d_y['edges_2__m_axi'] = 2
DDR_loc_2d_y['edges_3__m_axi'] = 3

DDR_loc_2d_y['updates_0__m_axi'] = 0
DDR_loc_2d_y['updates_1__m_axi'] = 1
DDR_loc_2d_y['updates_2__m_axi'] = 2
DDR_loc_2d_y['updates_3__m_axi'] = 3

DDR_loc_2d_y['degrees__m_axi'] = 0
DDR_loc_2d_y['rankings__m_axi'] = 0
DDR_loc_2d_y['tmps__m_axi'] = 0

DDR_enable = [1, 1, 1, 1]
max_usage_ratio_2d = [ [0.9, 0.4], [0.9, 0.4], [0.9, 0.4], [0.9, 0.4] ]
column = [2, 2, 2, 2]

relay_station_count = lambda x : 2 * x # how many levels of relay stations to add for x-unit of crossing
relay_station_template = 'fifo' # 'fifo' or 'reg' or 'reg_srl_fifo'
constraint_edge = True # whether to add constraints to rs and FIFO
constraint_marked_edge = True

formator = FormatTLP(
  rpt_path = rpt_path,
  hls_sche_path = hls_sche_path,
  top_hdl_path = top_hdl_path,
  top_name = top_name,
  DDR_loc_2d_x = DDR_loc_2d_x, 
  DDR_loc_2d_y = DDR_loc_2d_y, 
  DDR_enable = DDR_enable,
  max_usage_ratio_2d = max_usage_ratio_2d,
  column = column,
  board_name = 'u250',
  coorinate_expansion_ratio = 2,
  max_width_threshold = 10000,
  NUM_PER_SLR_HORIZONTAL = 4,
  horizontal_cross_weight = 0.7,
  target_dir = None,
  relay_station_count = relay_station_count,
  relay_station_template = relay_station_template,
  constraint_edge = constraint_edge,
  constraint_marked_edge = constraint_marked_edge)

g = graph.Graph(formator)
