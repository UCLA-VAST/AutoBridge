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

  # reigster the ap_dones from each module instance
  # hold the signal unless reset
  for v_name in ap_done_module_list:
    slot = v_name_to_s[v_name]
    pipeline_def.append(f'wire ap_done_{v_name};')
    pipeline_def.append(f'(* keep = "true" *) reg ap_done_{v_name}_q0;')
    pipeline_def.append(f'always @ (posedge ap_clk) ap_done_{v_name}_q0 <= (ap_done_{v_name} | ap_done_{v_name}_q0) & (!ap_rst_{slot.getRTLModuleName()});')
  pipeline_def.append(f'\n')
 
  # get the union ap_done from each slot
  # note that some modules dont have ap_done
  s_to_v_name_list = defaultdict(list)
  for v_name in ap_done_module_list:
    slot = v_name_to_s[v_name]
    s_to_v_name_list[slot].append(v_name)

  for slot, v_name_list in s_to_v_name_list.items():
    pipeline_def.append(f'(* keep = "true" *) reg ap_done_{slot.getRTLModuleName()}_q0;')
    pipeline_def.append(f'(* keep = "true" *) reg ap_done_{slot.getRTLModuleName()}_q1;')
    pipeline_def.append(f'(* keep = "true" *) reg ap_done_{slot.getRTLModuleName()}_q2;')
    pipeline_def.append(f'always @ (posedge ap_clk) ap_done_{slot.getRTLModuleName()}_q0 <= ' + ' & '.join([f'ap_done_{v_name}_q0' for v_name in v_name_list]) + ';')
    pipeline_def.append(f'always @ (posedge ap_clk) ap_done_{slot.getRTLModuleName()}_q1 <= ap_done_{slot.getRTLModuleName()}_q0;')
    pipeline_def.append(f'always @ (posedge ap_clk) ap_done_{slot.getRTLModuleName()}_q2 <= ap_done_{slot.getRTLModuleName()}_q1;')
    pipeline_def.append(f'\n')

  # get the final ap_done
  pipeline_def.append(f'(* keep = "true" *) reg ap_done_final;')
  pipeline_def.append(f'assign ap_done = ap_done_final;')  # for compatibility with HLS simulation
  pipeline_def.append(f'always @ (posedge ap_clk) ap_done_final <= ' + ' & '.join([f'ap_done_{slot.getRTLModuleName()}_q2' for slot in s_to_v_name_list.keys()]) + ';')
  pipeline_def.append(f'\n')
  pipeline_def.append(f'// ----- end of pipelining the ap_done signal -----\n')

  # add indentation
  pipeline_def = ['  ' + stmt for stmt in pipeline_def]
  
  return pipeline_def


