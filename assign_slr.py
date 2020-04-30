#!/usr/bin/python3
import argparse
import collections
import sys
from typing import Dict, Set
import re 

import tlp.core

import collections

Area = collections.namedtuple('Area', 'BRAM DSP FF LUT')

max_usage_ratio = 0.75
DDR_constraint = f'''
m += UpdateMem_p[0] == 0
m += UpdateMem_p[1] == 0
m += UpdateMem_p[2] == 0
m += UpdateMem_p[3] == 0
m += UpdateMem_p[4] == 0
m += UpdateMem_p[5] == 0
m += UpdateMem_p[6] == 0
m += UpdateMem_p[7] == 0
m += EdgeMem_p[0] == 0
m += EdgeMem_p[1] == 0
m += EdgeMem_p[2] == 0
m += EdgeMem_p[3] == 0
m += EdgeMem_p[4] == 0
m += EdgeMem_p[5] == 0
m += EdgeMem_p[6] == 0
m += EdgeMem_p[7] == 0
m += VertexMem_p[0] == 0
'''
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
BRAM_SLR = 1344
DSP_SLR = 3008
FF_SLR = 869120
LUT_SLR = 434560

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
  top_rtl = f'{args.tlp}/hdl/{args.top}.v'
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

  output.write(f'''
from mip import *

SLR_CNT = {SLR_CNT}
BRAM_SLR = {BRAM_SLR}
DSP_SLR = {DSP_SLR}
FF_SLR = {FF_SLR}
LUT_SLR = {LUT_SLR} 

max_usage_ratio = {max_usage_ratio}

m = Model()

''')

  # [var] if a module belongs to an SLR
  for name, ids in levels.items():
    output.write(f'{name}_x = [ [m.add_var(var_type=BINARY, name=f\'{name}_x_{{id}}_{{j}}\') for j in range(SLR_CNT)] for id in range({len(ids)})] \n')
  output.write('\n')

  # [var]  the location of a module
  for name, ids in levels.items():  
    output.write(f'{name}_p = [ m.add_var(var_type=INTEGER, name=f\'{name}_p_{{id}}\') for id in range({len(ids)})] \n')

  # define topology
  output.write('''
topology = []
''')
  task_fmt = '{name}_p[{id}]'
  for task in program.tasks:
    if task.is_upper:
      for fifo_name, fifo_attr in task.fifos.items():
        src_task_name, src_task_id = fifo_attr['produced_by']
        dst_task_name, dst_task_id = fifo_attr['consumed_by']
        src = task_fmt.format(name=src_task_name, id=src_task_id)
        dst = task_fmt.format(name=dst_task_name, id=dst_task_id)
        print(f'{src}, {dst}, {fifo_width[fifo_name]}, {fifo_name}')
        output.write(f'topology.append(({src}, {dst}, {fifo_width[fifo_name]}))\n')

  # [var]  each fifo corresponds to a distance variable
  output.write('''
d = [m.add_var(var_type=INTEGER) for i in topology]
''')

  # [goal]  optimization goal
  output.write('''
m.objective = minimize(xsum(d[i] * topology[i][2] for i in range(len(d))) )    
''')
  output.write('\n')

  # [constraint] only assign to 1 SLR
  for name, ids in levels.items():
    for id in ids:
      output.write(f'm += xsum( {name}_x[{id}][loc] for loc in range(SLR_CNT) ) == 1\n')
  output.write('\n')

  # [constraint] auxiliary varaible p
  for name, ids in levels.items():
    for id in ids:
      output.write(f'm += {name}_p[{id}] == xsum( {name}_x[{id}][loc] * loc for loc in range(SLR_CNT)) \n')
  output.write('\n')  

  # auxiliary variable d
  output.write('''
for i in range(len(d)):
  m += d[i] >= (topology[i][0] - topology[i][1]) * topology[i][2]
  m += d[i] >= (topology[i][1] - topology[i][0]) * topology[i][2]
''')
  output.write('\n')  

  # area constraints
  output.write('''
for loc in range(SLR_CNT):''')
  for item in ['BRAM', 'DSP', 'FF', 'LUT']:
    output.write('''
  m += 0 ''') # "0" as a placeholder
    for name, ids in levels.items():
      output.write(f'+ xsum({name}_x[id][loc] * {getattr(area_table[name],item)} for id in range({len(ids)})) ')
    output.write(f'<= {item}_SLR * max_usage_ratio') 
  
  # DDR location constraint
  output.write(DDR_constraint)

  output.write('''
m.optimize()
''')

  output.write('''
for loc in range(SLR_CNT):
  print(f"\\nSLR_{loc} includes:")
''')
  for name, ids in levels.items():
    output.write(f'''
  for id in range({len(ids)}):
    if ({name}_p[id].x == loc):
      print(f'{name}_{{id}}')
''')

  output.write('''
for cross in topology:
  if (cross[0].x != cross[1].x):
    print(f'{cross[0]}:{cross[0].x} -> {cross[1]}:{cross[1].x}   {cross[2]}')
''')

if __name__ == '__main__':
  main()
