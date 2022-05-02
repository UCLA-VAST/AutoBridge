import copy
from typing import List, Dict

import autobridge.Floorplan.Utilities as util
import autobridge.Floorplan as autobridge_floorplan
from autobridge.Device.DeviceManager import DeviceManager
from autobridge.HLSParser.tapa.DataflowGraphTapa import DataflowGraphTapa
from autobridge.HLSParser.tapa.ProgramJsonManager import ProgramJsonManager
from autobridge.Opt.DataflowGraph import Edge, Vertex
from autobridge.Opt.Slot import Slot
from autobridge.Opt.SlotManager import SlotManager
from autobridge.Route.global_route import ILPRouter
from autobridge.util import *
from autobridge.analyze import analyze_result, analyze_input, is_device_supported

def annotate_floorplan(config: Dict) -> Dict:
  cli_logger = set_general_logger(config)

  print_start(config)

  init_logging(config)

  if not is_device_supported(config):
    return config

  analyze_input(config)

  board = DeviceManager(
      board_name=get_board_num(config),
      ddr_list=get_ddr_list(config),
      is_vitis_enabled=True,
  ).getBoard()
  program_json_manager = ProgramJsonManager(
      config['edges'],
      get_vertex_section(config),
      get_area_section(config),
  )
  graph = DataflowGraphTapa(program_json_manager)
  slot_manager = SlotManager(board)

  # which modules must be assigned to the same slot
  grouping_constraints: List[List[str]] = config.get('grouping_constraints', [])

  # process optional module pre-assignment constraints
  module_floorplan = config['floorplan_pre_assignments']
  pre_assignment = {}
  for region, module_group in module_floorplan.items():
    for mod_name in module_group:
      pre_assignment[mod_name] = region

  kwargs = get_floorplan_params(config)

  # generate floorplan
  v2s, slot_list = autobridge_floorplan.get_floorplan(
    graph,
    slot_manager,
    grouping_constraints,
    pre_assignment,
    **kwargs,
  )

  # if floorplan failed
  if v2s is None:
    cli_logger.critical('\n*** CRITICAL WARNING: AutoBridge fails to find a solution. Please refer to the log for details.\n')
    config['floorplan_status'] = 'FAILED'
    print_end()
    return config

  slot_to_usage = util.get_slot_utilization(v2s)

  # route the FIFO pipelines
  router = ILPRouter(
    list(graph.edges.values()),
    v2s,
    slot_to_usage,
    slot_list,
  )
  fifo_to_path: Dict[Edge, List[Slot]] = router.route_design()

  annotated_config = get_annotated_config(v2s, fifo_to_path, slot_to_usage, config)

  analyze_result(annotated_config)

  print_end()

  return annotated_config

def get_floorplan_params(config) -> Dict:
  kwargs = {}
  params = (
    'floorplan_strategy',
    'floorplan_opt_priority',
    'floorplan_opt_priority',
    'min_area_limit',
    'max_area_limit',
    'min_slr_width_limit',
    'max_slr_width_limit',
    'max_search_time',
  )
  for param in params:
    if param in config:
      kwargs[param] = config[param]

  return kwargs

def get_ddr_list(config) -> List[int]:
  """ extract which ddrs are enabled
  """
  ddr_set = set()
  for v_name, properties in config['vertices'].items():
    if properties['category'] == 'PORT_VERTEX':
      if properties['port_cat'] == 'DDR':
        ddr_set.add(properties['port_id'])
  return list(ddr_set)

def get_board_num(config) -> str:
  device_num = config['part_num']
  if device_num == 'xcu250-figd2104-2L-e':
    return 'U250'
  elif device_num == 'xcu280-fsvh2892-2L-e':
    return 'U280'
  else:
    raise NotImplementedError(f'unsupported device {device_num}')

def get_vertex_section(config) -> Dict[str, str]:
  return {v_name: properties['module'] for v_name, properties in config['vertices'].items()}

def get_area_section(config) -> Dict[str, Dict[str, int]]:
  return {properties['module']: properties['area'] for v_name, properties in config['vertices'].items()}

def get_annotated_config(
    v2s: Dict[Vertex, Slot],
    fifo_to_path: Dict[Edge, List[Slot]],
    slot_to_usage: Dict[Slot, Dict[str, float]],
    config_orig: Dict,
) -> Dict:
  config = copy.deepcopy(config_orig)
  for v, s in v2s.items():
    config['vertices'][v.name]['floorplan_region'] = s.getRTLModuleName()
    config['vertices'][v.name]['SLR'] = s.getSLR()

  slot_list = list(set(v2s.values()))
  config['floorplan_region_pblock_tcl'] = {s.getRTLModuleName(): s.pblock_tcl for s in slot_list}

  for fifo, path in fifo_to_path.items():
    config['edges'][fifo.name]['path'] = [s.name for s in path]

  config['slot_resource_usage'] = {s.getRTLModuleName(): usage for s, usage in slot_to_usage.items()}
  config['floorplan_status'] = 'SUCCEED'

  # record important floorplan metrics
  config['actual_slr_width_usage'] = util.get_actual_slr_crossing_limit(v2s)
  config['actual_area_usage'] = util.get_actual_area_limit(v2s)

  return config
