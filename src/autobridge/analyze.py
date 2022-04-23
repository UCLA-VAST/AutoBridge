import os
import re
from collections import defaultdict

from autobridge.util import get_cli_logger, get_work_dir
from autobridge.Floorplan.Utilities import RESOURCE_TYPES
from autobridge.dotgraph import get_dot_graph
from prettytable import PrettyTable

logger = get_cli_logger()


def get_port_info(config, port_name):
  port_vertex_name = f'PORT_VERTEX_{port_name}_external_controller'
  prop = config['vertices'][port_vertex_name]
  return prop['port_cat'], prop['port_id']

def get_hbm_port_side(port_cat, port_id):
  assert port_cat == 'HBM'
  if 0 <= port_id < 16:
    return 'LEFT'
  elif 16 <= port_id < 32:
    return 'RIGHT'
  else:
    raise NotImplementedError(f'unrecognized port_id {port_id}')

def get_oppo_side(side: str):
  side_map = {
    'LEFT': 'RIGHT',
    'RIGHT': 'LEFT',
  }
  return side_map[side]

def check_port_binding(config) -> None:
  """
  check for horizontal AXI edges in SLR 0
  Ideally, each m_axi module should be together with the physical port
  If not in the floorplan results, throw a warning
  """
  if not config['part_num'].startswith('xcu280'):
    return

  wrong_binding = False
  for name, prop in config['edges'].items():
    if prop['category'] == 'AXI_EDGE':
      if 'CR_X0Y0_To_CR_X3Y3' in prop['path'] and \
         'CR_X0Y4_To_CR_X3Y7' in prop['path']:
        port_name = prop['port_name']
        port_cat, port_id = get_port_info(config, port_name)
        hbm_side = get_hbm_port_side(port_cat, port_id)
        oppo_side = get_oppo_side(hbm_side)

        source = prop['path'][0]
        dst = prop['path'][1]
        logger.critical(
          '*** CRITICAL WARNING: '
          'The top argument %s is mapped to port %s on the %s half of SLR 0. '
          'However, its adjacent module %s is floorplaned to the %s half. ',
          port_name, f'{port_cat}[{port_id}]', hbm_side, prop['consumed_by'], oppo_side)
        wrong_binding = True

  if wrong_binding:
    logger.critical('')
    logger.critical(
      '*** CRITICAL WARNING: '
      'Consider adjusting the port binding to balance resources on the two sides of SLR 0.'
    )
    logger.critical('')

def check_resource_usage(config):
  usage = config['slot_resource_usage']

  table = PrettyTable(['Slot Name'] + [f'{r} (%)' for r in RESOURCE_TYPES])
  for s_name, type_to_usage in usage.items():
    table.add_row([s_name] + [f'{round(type_to_usage[type]*100, 1)}' for type in RESOURCE_TYPES])
  logger.info(table)
  logger.info('')

  if config.get('floorplan_strategy') == 'SLR_LEVEL_FLOORPLANNING':
    logger.info('only floorplan to SLR-level slots as requested by the user')
    return

  logger.info('The device could be partitioned into %d slots.', len(usage))

  for slot_name in usage.keys():
    if re.search('CR_X0Y\d+_To_CR_X7Y\d+', slot_name):
      logger.critical(
        '*** CRITICAL WARNING: '
        'Some tasks of the design may be too large and prohibits a more fine-grained floorplanning.'
      )
      logger.critical('')
      logger.critical(
        'Tips: (1) write smaller tasks; (2) make each task use less heterogeneous resources. '
        'E.g., using a lot of DSP / BRAM / URAM in the *same* task makes it harder to floorplan'
      )
      logger.critical('')

def check_slot_crossing(config) -> None:
  boundary_to_wire_num = defaultdict(lambda : 0)

  def get_key(slot1, slot2):
    return tuple(sorted([slot1, slot2]))

  for e, props in config['edges'].items():
    path = props['path']
    for i in range(0, len(path)-1):
      k = get_key(path[i], path[i+1])
      boundary_to_wire_num[k] += props['width']

  logger.info('')
  logger.info('The number of wires between slots are:')
  logger.info('')

  for boundary, wire_num in boundary_to_wire_num.items():
    slot1, slot2 = boundary
    logger.info('%s <--> %s : %d', slot1, slot2, wire_num)
  logger.info('')


def analyze_result(config) -> None:
  logger.info('Floorplan finishes\n')

  check_port_binding(config)
  check_resource_usage(config)
  check_slot_crossing(config)


def check_gurobi() -> None:
  if 'GUROBI_HOME' in os.environ:
    logger.info('Gurobi solver detected.')
  else:
    logger.critical('*** CRITICAL WARNING: Gurobi solver not detected. Floorplanning may take extra time. ')
    logger.critical('The Gurobi solver is much faster than the open-source solver, and it is free for academia. ')
    logger.critical('  - Register and download the Gurobi Optimizer at https://www.gurobi.com/downloads/gurobi-optimizer-eula/')
    logger.critical('  - Unzip the package to your desired directory')
    logger.critical('  - Obtain an academic license at https://www.gurobi.com/downloads/end-user-license-agreement-academic/')
    logger.critical('  - Set environment variables GUROBI_HOME and GRB_LICENSE_FILE')
    logger.critical('      export GUROBI_HOME=[WHERE-YOU-INSTALL] ')
    logger.critical('      export GRB_LICENSE_FILE=[ADDRESS-OF-YOUR-LICENSE-FILE] ')
    logger.critical('      export PATH="${PATH}:${GUROBI_HOME}/bin" ')
    logger.critical('      export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib" ')


def analyze_input(config) -> None:
  check_gurobi()

  work_dir = get_work_dir(config)
  logger.info('')
  logger.info(f'Generate task graph visualization in graphviz format: {work_dir}/task_graph.dot')
  open(f'{work_dir}/task_graph.dot', 'w').write('\n'.join(get_dot_graph(config)))


def is_device_supported(config) -> bool:
  part_num = config['part_num']
  supported_part_num_prefix = ('xcu280', 'xcu250')

  if any(part_num.startswith(prefix) for prefix in supported_part_num_prefix):
    return True
  else:
    logger.error('unsupported device %s', part_num)
    return False
