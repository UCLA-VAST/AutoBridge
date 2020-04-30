#!/usr/bin/python3.6

import argparse
import collections
import sys
from typing import Dict, Set
import re 
import tlp.core
import collections
from mip import *
from parse import *

max_usage_ratio = 0.75

# F1
# SLR_CNT = 3
# BRAM_SLR = 1440
# DSP_SLR = 2280
# FF_SLR = 788160
# LUT_SLR = 394080 

# u250
# SLR_CNT = 4
# BRAM_SLR = 1344
# DSP_SLR = 3072
# FF_SLR = 864000
# LUT_SLR = 432000 

# u280
SLR_CNT = 3
SLR_AREA = {}
SLR_AREA['BRAM'] = 1344
SLR_AREA['DSP'] = 3008
SLR_AREA['FF'] = 869120
SLR_AREA['LUT'] = 434560

# DDR location table
DDR_loc = collections.defaultdict(dict)

DDR_loc['UpdateMem'][0] = 0
DDR_loc['UpdateMem'][1] = 0
DDR_loc['UpdateMem'][2] = 0
DDR_loc['UpdateMem'][3] = 0
DDR_loc['UpdateMem'][4] = 0
DDR_loc['UpdateMem'][5] = 0
DDR_loc['UpdateMem'][6] = 0
DDR_loc['UpdateMem'][7] = 0

DDR_loc['EdgeMem'][0] = 0
DDR_loc['EdgeMem'][1] = 0
DDR_loc['EdgeMem'][2] = 0
DDR_loc['EdgeMem'][3] = 0
DDR_loc['EdgeMem'][4] = 0
DDR_loc['EdgeMem'][5] = 0
DDR_loc['EdgeMem'][6] = 0
DDR_loc['EdgeMem'][7] = 0

DDR_loc['VertexMem'][0] = 0

#######################################
Area = collections.namedtuple('Area', 'BRAM DSP FF LUT')

def get_area(name_set, rpt_path):
  area_table = {}
  for name in name_set:
    rpt = open(f'{rpt_path}/{name}_csynth.rpt', 'r')
    for line in rpt:
      if ('Total' in line):
        x = re.findall('\d+', line)
        area_table[name] = Area(BRAM=x[0], DSP=x[1], FF=x[2], LUT=x[3])
        break
  return area_table

def get_width(src):
  rtl = open(src, 'r')
  fifo_width = {}
  flag = 0
  width = 0
  for line in rtl:

    x = re.search('.DATA_WIDTH\(([\d]+)\)', line)
    if (x):
      flag = 1
      width = int(x.group(1))

    if (flag == 2):
      x = re.search('[\w]+', line)
      fifo_name = re.sub('_(\d+)', r'[\1]', x.group(0))
      fifo_width[fifo_name] = width
      flag = 0
      width = 0

    if (flag == 1 and re.search('^[ ]*\)[ ]*', line)):
      flag = 2
    
    # if ("tlp::stream" in line):
    #   x = re.search("<(.*),.*>(.*);", line)
    #   fifo_width[x.group(2).strip()] = type_table[x.group(1).strip()]
  return fifo_width

#################################

def main():
  parser = argparse.ArgumentParser()
  parser.add_argument('--output',
                      dest='output',
                      help='output graphviz file, default to stdout',
                      type=argparse.FileType('w'),
                      default=sys.stdout)
  parser.add_argument('--tlp',
                      help='folder for the TLP generated results')
  parser.add_argument('--top',
                      help='top modules for the TLP design')
  args = parser.parse_args()

  output = args.output
  report_path = f'{args.tlp}/report'
  top_rtl = f'{args.tlp}/hdl/{args.top}_{args.top}.v'
  program = tlp.core.Program(open(f'{args.tlp}/program.json', 'r'))
  

  fifo_width = get_width(top_rtl)


  # get all instances
  levels: Dict[str, Set[int]] = collections.defaultdict(set)
  for task in program.tasks:
    if task.is_upper:
      for fifo_name, fifo_attr in task.fifos.items():
        src_task_name, src_task_id = fifo_attr['produced_by']
        dst_task_name, dst_task_id = fifo_attr['consumed_by']
        levels[src_task_name].add(src_task_id)
        levels[dst_task_name].add(dst_task_id)

  area_table = get_area(levels.keys(), report_path)
  
  # construct topology of the graph
  topology = []
  task_fmt = '{name}_{id}_p'
  for task in program.tasks:
    if task.is_upper:
      for fifo_name, fifo_attr in task.fifos.items():
        src_task_name, src_task_id = fifo_attr['produced_by']
        dst_task_name, dst_task_id = fifo_attr['consumed_by']
        src = task_fmt.format(name=src_task_name, id=src_task_id)
        dst = task_fmt.format(name=dst_task_name, id=dst_task_id)
        #print(f'{src}, {dst}, {fifo_width[fifo_name]}, {fifo_name}')
        topology.append((src, dst, fifo_width[fifo_name]))

#######################################


  # initialize model
  m = Model()

  # [var] if a module belongs to an SLR
  mods_x = []
  for name, ids in levels.items():
    for id in ids:
      new_mod_x = [m.add_var(var_type=BINARY, name=f'{name}_{id}_x_{loc}') for loc in range(SLR_CNT)]
      mods_x.append(new_mod_x)

  # [var] the location of a module
  mods_p = {}
  for name, ids in levels.items(): 
    for id in ids:
      new_mod_p = m.add_var(var_type=INTEGER, name=f'{name}_{id}_p')
      mods_p[f'{name}_{id}_p'] = new_mod_p
  
  # [var] distance of each edge
  d = [m.add_var(var_type=INTEGER, name=f'd_{i}') for i in topology]

  # [goal] 
  m.objective = minimize(xsum(d[i] * topology[i][2] for i in range(len(d))) )

  # [constraint] only assign to 1 SLR
  for mod_x in mods_x:
    m += xsum(mod_x[loc] for loc in range(SLR_CNT)) == 1

  # [constraint] auxiliary varaible p
  for mod_x, mod_p in zip(mods_x, mods_p.values()):
    m += mod_p == xsum(mod_x[loc] * loc for loc in range(SLR_CNT))

  # [constraint] auxiliary variable d
  for d_i, top_i in zip(d, topology):
    m += d_i >= (mods_p[top_i[0]] - mods_p[top_i[1]]) * top_i[2]
    m += d_i >= (mods_p[top_i[1]] - mods_p[top_i[0]]) * top_i[2]

  # [constraint] area
  x_name_fmt = '{}_{}_x_{}'
  for item in ['BRAM', 'DSP', 'FF', 'LUT']:
    for loc in range(SLR_CNT):
      cmd = 'm += 0'
      for i in range(len(mods_x)):
        mod_name = parse(x_name_fmt, mods_x[i][loc].name)[0]
        usage = getattr(area_table[ mod_name ],item)
        cmd += f' + mods_x[{i}][{loc}] * {usage}'
      cmd += f'<= {int(SLR_AREA[item] * max_usage_ratio)}'
      #print(cmd)
      exec(cmd)

  # DDR location constraint
  p_name_fmt = '{}_{}_p'
  for mod_p in mods_p.values():
    mod_type, mod_id = parse(p_name_fmt, mod_p.name)
    mod_id = int(mod_id)
    if(mod_type in DDR_loc and mod_id in DDR_loc[mod_type]):
      print(f'{mod_type} {mod_id} ')
      m += mod_p == DDR_loc[mod_type][mod_id]

  # run
  #m.write('sample.lp')
  m.optimize()

###################################

  for loc in range(SLR_CNT):
    print(f'SLR_{loc} includes:')
    for mod_p in mods_p.values():
      if (mod_p.x == loc):
        mod_type, mod_id = parse(p_name_fmt, mod_p.name)
        print(f'{mod_type}[{mod_id}]')

  print('')
  for edge in topology:
    src = mods_p[edge[0]]
    dst = mods_p[edge[1]]
    if (src.x != dst.x):
      print(f'{src}:{src.x} -> {dst}:{dst.x}   {edge[2]}')

####################################

if __name__ == '__main__':
  main()
