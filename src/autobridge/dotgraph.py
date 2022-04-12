from typing import List, Dict
import math

def get_port_vertices(config) -> List[str]:
  ports = []
  ports.append('  {')
  ports.append('    rank = same;')
  for v, props in config['vertices'].items():
    if props['category'] == 'PORT_VERTEX':
      ports.append(f'    "{v}" [style=filled, shape=rectangular, fillcolor="#9ACEEB"]')
  ports.append('  }')
  ports.append('')

  return ports


def get_scaled_edge_width(orig_width: int) -> float:
  return math.log(orig_width / 20, 2)


def get_edges_exclude_scala_and_async_mmap_edges(config) -> List[str]:
  dot = []

  for e, props in config['edges'].items():
    src = props['produced_by']
    dst = props['consumed_by']
    path_name = f'"{src}" -> "{dst}"'
    width = props['width']
    scaled_width = get_scaled_edge_width(width)

    cat = props['category']
    if cat == 'AXI_EDGE':
      dot.append(f'  {path_name} [dir=none, penwidth={scaled_width}, color=gold, label={width}	]')
    elif cat == 'FIFO_EDGE':
      fifo_name = props['instance']
      dot.append(f'  {path_name} [penwidth={scaled_width}, label={width}]')
    elif cat == 'SCALAR_EDGE':
      continue
    elif cat == 'ASYNC_MMAP_EDGE':
      continue
    else:
      dot.append(f'  {path_name} [penwidth={scaled_width}, label={width}]')

  dot.append('')
  return dot


def get_merged_scalar_edges(config) -> Dict:

  dot = []
  path_name_to_acc_width = {}
  for e, props in config['edges'].items():
    src = props['produced_by']
    dst = props['consumed_by']
    path_name = f'"{src}" -> "{dst}"'
    width = props['width']

    if props['category'] == 'SCALAR_EDGE':
      acc_width = path_name_to_acc_width.get(path_name, 0)
      path_name_to_acc_width[path_name] = acc_width + width

  for path_name, total_width in path_name_to_acc_width.items():
    scaled_width = get_scaled_edge_width(total_width)
    dot.append(f'  {path_name} [penwidth={scaled_width}, label={total_width}]')

  dot.append('')
  return dot


def get_dot_graph(config) -> List[str]:
  dot = []

  dot.append('digraph {')
  dot.append('  rankdir="LR";')

  dot += get_port_vertices(config)
  dot += get_edges_exclude_scala_and_async_mmap_edges(config)
  dot += get_merged_scalar_edges(config)

  dot.append('}')

  return dot
