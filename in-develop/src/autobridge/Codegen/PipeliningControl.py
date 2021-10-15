#! /usr/bin/python3.6

import pyverilog.vparser.ast as ast

from typing import List


def pipeline_ap_rst(node, v_name_to_s, e_name_to_s):
  """
  update the signal connected to the module instances
  """
  if (not isinstance(node, ast.InstanceList)):
    return

  mod_name = node.instances[0].name
  curr_port_list = node.instances[0].portlist
  for portarg in curr_port_list:
    if ('ap_rst' in portarg.portname or 'reset' in portarg.portname or 'RESET' in portarg.portname):
      if 'relay_station' in node.instances[0].module or 'fifo' in node.instances[0].module:
        slot = e_name_to_s[mod_name]
      else:
        slot = v_name_to_s[mod_name]

      assert 'ap_rst_n' not in portarg.portname
      portarg.argname.name = f'ap_rst_{slot.getRTLModuleName()}'


def get_ap_rst_pipeline_rtl(slot_list, pipeline_level = 4) -> List[str]:
  """
  instantiate the pipeline registers
  """
  rtl = []
  for slot in slot_list:
    for i in range(pipeline_level):
      rtl.append(f'(* keep = "true" *) reg ap_rst_n_inv_{slot.getRTLModuleName()}_q{i};')
    
    rtl.append(f'always @ (posedge ap_clk) begin')
    rtl.append(f'  ap_rst_n_inv_{slot.getRTLModuleName()}_q0 <= ~ap_rst_n;')
    for i in range(1, pipeline_level):
      rtl.append(f'  ap_rst_n_inv_{slot.getRTLModuleName()}_q{i} <= ap_rst_n_inv_{slot.getRTLModuleName()}_q{i-1};')
    rtl.append(f'end')

    rtl.append(f'wire ap_rst_n_inv_{slot.getRTLModuleName()} = ap_rst_n_inv_{slot.getRTLModuleName()}_q{pipeline_level-1};')

  return rtl


def pipeline_ap_start(node, v_name_to_s):
  if (not isinstance(node, ast.InstanceList)):
    return

  mod_name = node.instances[0].name
  curr_port_list = node.instances[0].portlist
  for portarg in curr_port_list:
    if portarg.portname == 'ap_start':
      # handle the original ap_start from the s_axi_control
      if portarg.argname.name == 'ap_start':
        assert 's_axi' in mod_name
        portarg.argname.name = 'ap_start_orig'
        continue

      slot = v_name_to_s[mod_name]
      portarg.argname.name = f'ap_start_{slot.getRTLModuleName()}'


def pipeline_ap_done(node):
  if (not isinstance(node, ast.InstanceList)):
    return

  mod_name = node.instances[0].name
  curr_port_list = node.instances[0].portlist
  for portarg in curr_port_list:
    if portarg.portname == 'ap_done':
      # handle the original ap_start from the s_axi_control
      if portarg.argname.name == 'ap_done':
        assert 's_axi' in mod_name
        portarg.argname.name = 'ap_done_final'
        continue

      portarg.argname.name = f'ap_done_{mod_name}'
      return


def collect_all_ap_done_signals(node, ap_done_module_list: List[str]):
  if (not isinstance(node, ast.InstanceList)):
    return

  mod_name = node.instances[0].name
  curr_port_list = node.instances[0].portlist
  for portarg in curr_port_list:
    if portarg.portname == 'ap_done':
      # handle the original ap_start from the s_axi_control
      if 's_axi' in mod_name:
        continue

      ap_done_module_list.append(mod_name)
      return


def make_ap_ready_equal_to_ap_done(node):
  if (not isinstance(node, ast.InstanceList)):
    return

  curr_port_list = node.instances[0].portlist
  for portarg in curr_port_list:
    if portarg.portname == 'ap_ready':
      if portarg.argname.name == 'ap_ready':
        portarg.argname.name = 'ap_done_final'
      else:
        portarg.argname.name = ''


def make_ap_idle_equal_to_ap_done(node):
  if (not isinstance(node, ast.InstanceList)):
    return

  curr_port_list = node.instances[0].portlist
  for portarg in curr_port_list:
    if portarg.portname == 'ap_idle':
      if portarg.argname.name == 'ap_idle':
        portarg.argname.name = 'ap_done_final'
      else:
        portarg.argname.name = ''


def fix_ap_continue_to_ap_done(node):
  if (not isinstance(node, ast.InstanceList)):
    return

  curr_port_list = node.instances[0].portlist
  mod_name = node.instances[0].name

  for portarg in curr_port_list:
    if portarg.portname == 'ap_continue':
      portarg.argname.name = f'ap_done_{mod_name}'