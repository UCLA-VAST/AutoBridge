#! /usr/bin/python3.6

import sys
sys.path.append('../../../src')

import graph
from formator import FormatHLS
import collections
import os
import subprocess

project_path = './kernel3_u250'
solution_path = f'{project_path}/solution/'
project_name = 'kernel3_u250'

top_name = 'kernel3'
rpt_path = f'{solution_path}/syn/report/'
hls_sche_path = f'{solution_path}/.autopilot/db/'
hdl_path = f'{solution_path}/syn/verilog/'
top_hdl_path = f'{hdl_path}/{top_name}_{top_name}.v'

DDR_loc_2d_x = collections.defaultdict(dict)
DDR_loc_2d_y = collections.defaultdict(dict)

# use DDR 0, 1, 3
DDR_loc_2d_y['A_IO_L3_in_U0'] = 0
DDR_loc_2d_y['B_IO_L3_in_U0'] = 1
DDR_loc_2d_y['C_drain_IO_L3_out_U0'] = 3

DDR_loc_2d_x['A_IO_L3_in_U0'] = 0
DDR_loc_2d_x['B_IO_L3_in_U0'] = 0
DDR_loc_2d_x['C_drain_IO_L3_out_U0'] = 0

DDR_loc_2d_y['kernel3_gmem_A_m_axi_U'] = 0
DDR_loc_2d_y['kernel3_gmem_B_m_axi_U'] = 1
DDR_loc_2d_y['kernel3_gmem_C_m_axi_U'] = 3
DDR_loc_2d_x['kernel3_gmem_A_m_axi_U'] = 0
DDR_loc_2d_x['kernel3_gmem_B_m_axi_U'] = 0
DDR_loc_2d_x['kernel3_gmem_C_m_axi_U'] = 0

DDR_loc_2d_y['kernel3_control_s_axi_U'] = 0

# only the DDRs in SLR0 and SLR1 are enabled
DDR_enable = [1, 1, 0, 1]

# the DDR controllers in SLR 0 and SLR 1 are instantiated, so split the two SLR
column = [2, 2, 2, 2]

# the right half of SLR0 and SLR1 contains the DDR controller and the static region, which takes away half the resources
max_usage_ratio_2d = [ [0.85, 0.6], [0.85, 0.6], [0.85, 0.85], [0.85, 0.6] ]

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
horizontal_cross_weight = 0.7

relay_station_count = lambda x : 2 * x # how many levels of relay stations to add for x-unit of crossing
relay_station_template = 'reg' # 'fifo' or 'reg' or 'reg_srl_fifo'
constraint_edge = True # whether to add constraints to rs and FIFO
constraint_marked_edge = True
only_keep_rs_hierarchy = False
max_search_time = 1200
board_name = 'u250'
NaiveBalance = True
#-----------------------------

target_dir = './kernel3_u250_autobridge_impl'


formator = FormatHLS(
  rpt_path = rpt_path,
  hls_sche_path = hls_sche_path,
  top_hdl_path = top_hdl_path,
  top_name = top_name,
  DDR_loc_2d_x = DDR_loc_2d_x, 
  DDR_loc_2d_y = DDR_loc_2d_y, 
  DDR_enable = DDR_enable,
  max_usage_ratio_2d = max_usage_ratio_2d,
  column = column,
  board_name = board_name,
  coorinate_expansion_ratio = 2,
  max_width_threshold = 10000,
  NUM_PER_SLR_HORIZONTAL = 4,
  horizontal_cross_weight = 0.7,
  target_dir = target_dir,
  relay_station_count = relay_station_count,
  relay_station_template = relay_station_template,
  constraint_edge = constraint_edge,
  constraint_marked_edge = constraint_marked_edge,
  only_keep_rs_hierarchy = only_keep_rs_hierarchy,
  max_search_time = max_search_time,
  NaiveBalance = NaiveBalance)

g = graph.Graph(formator)

################
print('... Copying the Vivado HLS project ...')

if (os.path.isdir(target_dir)):
  subprocess.run(['rm', '-rf', f'{target_dir}'])

subprocess.run(['mkdir', f'{target_dir}/'])
subprocess.run(['cp', '-r', project_path, f'{target_dir}/{project_name}'])
subprocess.run(['cp', os.path.realpath(__file__), f'{target_dir}/archived_source.txt'])
subprocess.run(['chmod', '+w', '-R', f'{target_dir}'])
subprocess.run(['cp', 'constraint.tcl', target_dir])
subprocess.run(['cp', 'pack_xo.tcl', target_dir])
subprocess.run(['cp', f'{top_name}_{top_name}.v', f'{target_dir}/{project_name}/solution/syn/verilog/'])