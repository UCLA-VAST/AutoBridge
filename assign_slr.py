#!/usr/bin/python3.6

import collections
from mip import *
from graph import *
from typing import List
import format_tlp
import format_hls

def assign_slr(vertices : List, topology : List, formator):
  
  SLR_CNT = formator.SLR_CNT

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
    m += mod_p == xsum(mod_x[loc] * loc for loc in range(formator.SLR_CNT))

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
      cmd += f'<= {int(formator.SLR_AREA[item] * formator.max_usage_ratio)}'

      exec(cmd)

  # [constraint] DDR location constraint
  for v, mod_p in mods_p.items():
    if (v.name in formator.DDR_loc):
      m += mod_p == formator.DDR_loc[v.name]
  
  # run
  m.write('sample.lp')
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

  for e in topology:
    if (e.src.slr_loc != e.dst.slr_loc):
      print(f'{e.name}: {e.src.name} @ {e.src.slr_loc} --> {e.dst.name} @ {e.dst.slr_loc} ')
