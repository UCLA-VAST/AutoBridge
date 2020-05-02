#!/usr/bin/python3.6

import collections
from mip import *
from graph import *
from typing import List
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

def assign_slr(vertices : List[Vertex], topology : List[Edge], DDR_loc):
  
  # initialize model
  m = Model()

  # [var] if a module belongs to an SLR
  mods_x = {} # str -> [mip_var]
  for v in vertices:
    new_mod_x = [m.add_var(var_type=BINARY, name=f'{v.name}_x_{loc}') for loc in range(SLR_CNT)]
    mods_x[v.name] = new_mod_x

  # [var] the location of a module
  mods_p = {} # Vertex -> mip_var
  for v in vertices: 
    new_mod_p = m.add_var(var_type=INTEGER, name=f'{v.name}_p')
    mods_p[v] = new_mod_p
  
  # [var] distance of each edge
  d = [m.add_var(var_type=INTEGER, name=f'd_{i}') for i in topology]

  # [goal] 
  m.objective = minimize(xsum(d[i] * edge.width for i, edge in enumerate(topology) ) )

  # [constraint] only assign to 1 SLR
  for mod_x in mods_x.values():
    m += xsum(mod_x[loc] for loc in range(SLR_CNT)) == 1

  # [constraint] auxiliary varaible p
  for mod_x, mod_p in zip(mods_x.values(), mods_p.values()):
    m += mod_p == xsum(mod_x[loc] * loc for loc in range(SLR_CNT))

  # [constraint] auxiliary variable d
  for d_i, top_i in zip(d, topology):
    m += d_i >= (mods_p[top_i.src] - mods_p[top_i.dst]) * top_i.width
    m += d_i >= (mods_p[top_i.dst] - mods_p[top_i.src]) * top_i.width

  # [constraint] area
  for item in ['BRAM', 'DSP', 'FF', 'LUT']:
    for loc in range(SLR_CNT):
      cmd = 'm += 0'
      for v in vertices:
        cmd += f' + mods_x["{v.name}"][{loc}] * {getattr(v.area, item)}'
      cmd += f'<= {int(SLR_AREA[item] * max_usage_ratio)}'

      exec(cmd)

  # [constraint] DDR location constraint
  for v, mod_p in mods_p.items():
    if (v.name in DDR_loc):
      m += mod_p == DDR_loc[v.name]
  
  # run
  #m.write('sample.lp')
  m.optimize()

  for v in vertices:
    v.slr_loc = mods_p[v].x

  for e in topology:
    e.mark = mods_p[e.src].x != mods_p[e.dst].x

###################################

  for loc in range(SLR_CNT):
    print(f'SLR_{loc} includes:')
    
    for v in vertices:
      if (v.slr_loc == loc):
        print(f'  {v.name}')


