from autobridge.util import get_cli_logger

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

def analyze_result(config) -> None:
  check_port_binding(config)
  