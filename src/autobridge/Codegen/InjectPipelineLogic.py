from collections import defaultdict
from typing import List, Dict

from autobridge.Opt.Slot import Slot


def get_ap_start_pipeline_def(slot_list: List[Slot], pipeline_level=4) -> List[str]:
  pipeline_def = []
  pipeline_def.append(f'// ----- pipelining the ap_start signal -----')
  
  pipeline_def.append(f'wire ap_start_orig;')

  for slot in slot_list:
    pipeline_def.append(f'(* keep = "true" *) reg ap_start_{slot.getRTLModuleName()};')
    for level in range(pipeline_level):
      pipeline_def.append(f'(* keep = "true" *) reg ap_start_{slot.getRTLModuleName()}_q{level};')

    pipeline_def.append(f'always @ (posedge ap_clk) begin')
    pipeline_def.append(f'  ap_start_{slot.getRTLModuleName()}_q0 <= ap_start_orig;')
    for level in range(1, pipeline_level):
      pipeline_def.append(f'  ap_start_{slot.getRTLModuleName()}_q{level} <= ap_start_{slot.getRTLModuleName()}_q{level-1};')
    pipeline_def.append(f'  ap_start_{slot.getRTLModuleName()} <= ap_start_{slot.getRTLModuleName()}_q{pipeline_level-1};')
    pipeline_def.append(f'end')

    pipeline_def.append(f'\n')

  pipeline_def.append(f'// ----- end of pipelining the ap_start signal -----\n')

  # add indentation
  pipeline_def = ['  ' + stmt for stmt in pipeline_def]
  
  return pipeline_def


def get_ap_rst_pipeline_def(slot_list: List[Slot], pipeline_level=4) -> List[str]:
  pipeline_def = []
  pipeline_def.append(f'// ----- pipelining the ap_rst signal -----')

  for slot in slot_list:
    pipeline_def.append(f'(* keep = "true" *) reg ap_rst_{slot.getRTLModuleName()};')
    for level in range(pipeline_level):
      pipeline_def.append(f'(* keep = "true" *) reg ap_rst_{slot.getRTLModuleName()}_q{level};')

    pipeline_def.append(f'always @ (posedge ap_clk) begin')
    pipeline_def.append(f'  ap_rst_{slot.getRTLModuleName()}_q0 <= !ap_rst_n;')
    for level in range(1, pipeline_level):
      pipeline_def.append(f'  ap_rst_{slot.getRTLModuleName()}_q{level} <= ap_rst_{slot.getRTLModuleName()}_q{level-1};')
    pipeline_def.append(f'  ap_rst_{slot.getRTLModuleName()} <= ap_rst_{slot.getRTLModuleName()}_q{pipeline_level-1};')
    pipeline_def.append(f'end')

    pipeline_def.append(f'\n')

  pipeline_def.append(f'// ----- end of pipelining the ap_rst_ signal -----\n')

  # add indentation
  pipeline_def = ['  ' + stmt for stmt in pipeline_def]
  
  return pipeline_def


def get_ap_done_pipeline_def(v_name_to_s: Dict[str, Slot], ap_done_module_list: List[str]) -> List[str]:
  pipeline_def = []
  pipeline_def.append(f'// ----- pipelining the ap_done signal -----')

  # get the union ap_done from each slot
  # note that some modules dont have ap_done
  s_to_v_name_list = defaultdict(list)
  for v_name in ap_done_module_list:
    slot = v_name_to_s[v_name]
    s_to_v_name_list[slot].append(v_name)

  # reigster the ap_dones from each module instance
  # hold the signal unless reset
  for v_name in ap_done_module_list:
    slot = v_name_to_s[v_name]
    pipeline_def.append(f'wire ap_done_{v_name};')
    pipeline_def.append(f'(* keep = "true" *) reg ap_done_{v_name}_q0;')
  pipeline_def.append(f'\n')

  for slot, v_name_list in s_to_v_name_list.items():
    pipeline_def.append(f'(* keep = "true" *) reg ap_done_{slot.getRTLModuleName()}_q0;')
    pipeline_def.append(f'(* keep = "true" *) reg ap_done_{slot.getRTLModuleName()}_q1;')
    pipeline_def.append(f'(* keep = "true" *) reg ap_done_{slot.getRTLModuleName()}_q2;')
  pipeline_def.append(f'\n')

  pipeline_def.append(f'(* keep = "true" *) reg ap_done_final;')
  for slot, v_name_list in s_to_v_name_list.items():
    pipeline_def.append(f'(* keep = "true" *) reg ap_done_final_{slot.getRTLModuleName()}_q0;')
    pipeline_def.append(f'(* keep = "true" *) reg ap_done_final_{slot.getRTLModuleName()}_q1;')
    pipeline_def.append(f'(* keep = "true" *) reg ap_done_final_{slot.getRTLModuleName()}_q2;')
  pipeline_def.append(f'\n')

  # get the ap_done of a slot. Reset the ap_done of each module once the slot ap_done is captured
  for v_name in ap_done_module_list:
    slot = v_name_to_s[v_name]
    pipeline_def.append(f'always @ (posedge ap_clk) ap_done_{v_name}_q0 <= (ap_done_{v_name} | ap_done_{v_name}_q0) & (!ap_rst_{slot.getRTLModuleName()}) & (!ap_done_{slot.getRTLModuleName()}_q1);')
  pipeline_def.append(f'\n')

  # get the final ap_done. Reset the ap_done of each slot once the final ap_done is captured
  for slot, v_name_list in s_to_v_name_list.items():
    pipeline_def.append(f'always @ (posedge ap_clk) ap_done_{slot.getRTLModuleName()}_q0 <= ' + ' & '.join([f'ap_done_{v_name}_q0' for v_name in v_name_list]) + ';')
    pipeline_def.append(f'always @ (posedge ap_clk) ap_done_{slot.getRTLModuleName()}_q1 <= ap_done_{slot.getRTLModuleName()}_q0;')
    pipeline_def.append(f'always @ (posedge ap_clk) ap_done_{slot.getRTLModuleName()}_q2 <= (ap_done_{slot.getRTLModuleName()}_q2 | ap_done_{slot.getRTLModuleName()}_q1) & (!ap_rst_{slot.getRTLModuleName()}) & (!ap_done_final_{slot.getRTLModuleName()}_q2);')
    pipeline_def.append(f'\n')

  # get the final ap_done
  pipeline_def.append(f'assign ap_done = ap_done_final;')  # for compatibility with HLS simulation
  pipeline_def.append(f'always @ (posedge ap_clk) ap_done_final <= ' + ' & '.join([f'ap_done_{slot.getRTLModuleName()}_q2' for slot in s_to_v_name_list.keys()]) + ';')
  pipeline_def.append(f'\n')

  # pipeline the final ap_done back to each slot to reset the slot-level ap_done
  for slot, v_name_list in s_to_v_name_list.items():
    pipeline_def.append(f'always @ (posedge ap_clk) ap_done_final_{slot.getRTLModuleName()}_q0 <= ap_done_final;')
    pipeline_def.append(f'always @ (posedge ap_clk) ap_done_final_{slot.getRTLModuleName()}_q1 <= ap_done_final_{slot.getRTLModuleName()}_q0;')
    pipeline_def.append(f'always @ (posedge ap_clk) ap_done_final_{slot.getRTLModuleName()}_q2 <= ap_done_final_{slot.getRTLModuleName()}_q1;')

  pipeline_def.append(f'// ----- end of pipelining the ap_done signal -----\n')

  # add indentation
  pipeline_def = ['  ' + stmt for stmt in pipeline_def]
  
  return pipeline_def


def remove_orig_ctrl_signal(temp_rtl_top: List[str]) -> None:
  """
  comment out all assign statement of the original control signals
  also comment out the always blocks related to the original control signals
  """
  ctrl_signals = [
    'ap_start',
    'ap_ready',
    'ap_done',
    'ap_continue',
    'ap_idle',
    'ap_sync_',
  ]

  # the always blocks are suppose to be after all module instances
  for i in range(len(temp_rtl_top)):
    if 'always' in temp_rtl_top[i] and 'ap_clk' in temp_rtl_top[i]:
      for j in range(i, len(temp_rtl_top)):
        if 'assign' in temp_rtl_top[j]:
          break
        else:
          temp_rtl_top[j] = f'//  {temp_rtl_top[j]}'
      break

  # all assign statement are after the always blocks
  for i in range(len(temp_rtl_top)):
    if 'assign' in temp_rtl_top[i]:
      assert any(ctrl_signal in temp_rtl_top[i] for ctrl_signal in ctrl_signals), temp_rtl_top[i]
      temp_rtl_top[i] = f'//  {temp_rtl_top[i]}'
