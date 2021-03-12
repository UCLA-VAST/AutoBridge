#! /usr/bin/python3.6
import sys
sys.path.append('../../../src')
import graph
from formator import FormatTLP
import collections
import os
import subprocess

DDR_loc_2d_x = collections.defaultdict(dict)
DDR_loc_2d_y = collections.defaultdict(dict)

DDR_loc_2d_y['jacobi2d_kernel_control_s_axi_U'] = 0
DDR_loc_2d_y['load_0'] = 0
DDR_loc_2d_x['load_0'] = 0

DDR_loc_2d_y['store_0'] = 3
DDR_loc_2d_x['store_0'] = 0

DDR_enable = [1, 0, 0, 1]
max_usage_ratio_2d = [ [0.6, 0.6], [0.6, 0.6], [0.6, 0.6], [0.6, 0.6] ]

relay_station_count = lambda x : 2 * x # how many levels of relay stations to add for x-unit of crossing
relay_station_template = 'reg' # 'fifo' or 'reg' or 'reg_srl_fifo'
constraint_edge = True # whether to add constraints to rs and FIFO
constraint_marked_edge = True

board_name = 'u250'
#######################################


i=2

target_dir = f'./autobridge_impl{i}'
tlp_path = f'./tapa_result'
top_name = 'jacobi2d_kernel'

rpt_path = f'{tlp_path}/report'
hls_sche_path = f'{tlp_path}/report'
hdl_path = f'{tlp_path}/hdl'
top_hdl_path = f'{hdl_path}/{top_name}_{top_name}.v'

# check = input(f'''
# Please confirm:
# the source project directory is: 
#   {tlp_path}
# the target directory is: 
#   {target_dir}
# The target directory will first be *** REMOVED ***
# (Y/n):  
# ''')

# if (check != 'Y'):
#   exit

formator = FormatTLP(
  rpt_path = rpt_path,
  hls_sche_path = hls_sche_path,
  top_hdl_path = top_hdl_path,
  top_name = top_name,
  DDR_loc_2d_x = DDR_loc_2d_x, 
  DDR_loc_2d_y = DDR_loc_2d_y, 
  DDR_enable = DDR_enable,
  max_usage_ratio_2d = max_usage_ratio_2d,
  board_name = board_name,
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


################

if (os.path.isdir(f'{target_dir}/tapa_result')):
  #target_dir = f'{target_dir}_dup'
  subprocess.run(['rm', '-rf', f'{target_dir}/tapa_result'])

subprocess.run(['mkdir', f'{target_dir}/'])
subprocess.run(['cp', '-r', tlp_path, f'{target_dir}/'])
subprocess.run(['cp', os.path.realpath(__file__), f'{target_dir}/archived_source.txt'])
subprocess.run(['chmod', '+w', '-R', f'{target_dir}'])
subprocess.run(['cp', 'constraint.tcl', target_dir])
subprocess.run(['cp', f'{top_name}_{top_name}.v', f'{target_dir}/tapa_result/hdl'])
subprocess.run(['rm', f'{target_dir}/tapa_result/hdl/relay_station.v'])

if (relay_station_template == 'fifo'):
  subprocess.run(['rm', f'{target_dir}/tapa_result/hdl/fifo_srl.v'])
