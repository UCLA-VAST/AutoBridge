#!/usr/bin/python3.6

import collections
from mip import *
from graph import *
from typing import List
import format_tlp
import format_hls

def assign_slr_1d(vertices : List, topology : List, formator):
  
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

#
# Multi-column SLR assignment problem
#
def assign_slr(vertices : List, topology : List, formator):

  column = formator.column
  SLR_CNT = formator.SLR_CNT
  
  # be compatible for previous code
  if (column == 1):
    assign_slr_1d(vertices, topology, formator)

  # initialize model
  m = Model()

  # [var] if a module belongs to an SLR
  mods_x = {} # str -> [mip_var]
  for v in vertices:
    new_mod_x = [ [m.add_var(var_type=BINARY, name=f'{v.name}_x_{x}_{y}') for y in range(SLR_CNT)] for x in range(column) ] 
    mods_x[v.name] = new_mod_x # m[x][y]

  # [var] the location of a module
  mods_p = {} # Vertex -> mip_var
  for v in vertices: 
    new_mod_p = (m.add_var(var_type=INTEGER, name=f'{v.name}_p_x'), m.add_var(var_type=INTEGER, name=f'{v.name}_p_y') )
    mods_p[v] = new_mod_p
  
  # [var] distance of each edge
  d_x = [m.add_var(var_type=INTEGER, name=f'd_x_{i.name}') for i in topology]
  d_y = [m.add_var(var_type=INTEGER, name=f'd_y_{i.name}') for i in topology]

  # [goal] 
  m.objective = minimize(xsum(d_x[i] * edge.width for i, edge in enumerate(topology) ) + \
                         xsum(d_y[i] * edge.width * formator.horizontal_cross_penalty for i, edge in enumerate(topology) )  )

  # [constraint] only assign to 1 SLR
  for mod_x in mods_x.values():
    m += xsum(mod_x[x][y] for y in range(SLR_CNT) for x in range(column)) == 1

  # [constraint] auxiliary varaible p
  for mod_x, mod_p in zip(mods_x.values(), mods_p.values()):
    m += mod_p[0] == xsum(mod_x[x][y] * x for y in range(SLR_CNT) for x in range(column))
    m += mod_p[1] == xsum(mod_x[x][y] * y for y in range(SLR_CNT) for x in range(column))

  # [constraint] auxiliary variable d
  for d_x_i, d_y_i, top_i in zip(d_x, d_y, topology):
    m += d_x_i >= (mods_p[top_i.src][0] - mods_p[top_i.dst][0]) * top_i.width
    m += d_x_i >= (mods_p[top_i.dst][0] - mods_p[top_i.src][0]) * top_i.width
    m += d_y_i >= (mods_p[top_i.src][1] - mods_p[top_i.dst][1]) * top_i.width
    m += d_y_i >= (mods_p[top_i.dst][1] - mods_p[top_i.src][1]) * top_i.width

  # [constraint] area
  for item in ['BRAM', 'DSP', 'FF', 'LUT']:
    for x in range(column):
      for y in range(SLR_CNT):
        cmd = 'm += 0'
        for v in vertices:
          cmd += f' + mods_x["{v.name}"][{x}][{y}] * {getattr(v.area, item)}'
        cmd += f'<= {int(formator.SLR_AREA[item] / column * formator.max_usage_ratio_2d[x][y])}'

        exec(cmd)

  # [constraint] DDR location constraint
  for v, mod_p in mods_p.items():
    if (v.name in formator.DDR_loc_2d_x):
      m += mod_p[0] == formator.DDR_loc_2d_x[v.name]
    if (v.name in formator.DDR_loc_2d_y):
      m += mod_p[1] == formator.DDR_loc_2d_y[v.name]
  
  # run
  m.write('sample.lp')
  m.optimize()

  for v in vertices:
    v.slr_loc_2d = (mods_p[v][0].x, mods_p[v][1].x)

  for e in topology:
    e.mark = mods_p[e.src][0].x != mods_p[e.dst][0].x or mods_p[e.src][1].x != mods_p[e.dst][1].x

  ###################################

  for x in range(column):
    for y in range(SLR_CNT):
      print(f'SLR_[{x}][{y}] includes:')
      
      all = []
      for v in vertices:
        if (v.slr_loc_2d[0] == x and v.slr_loc_2d[1] == y):
          print(f'  {v.name} -> {v.area}')
          all.append(v.area)
      print(f'  BRAM usage: {sum(int(v[0]) for v in all)} / {formator.SLR_AREA["BRAM"] / column} = { (sum(int(v[0]) for v in all)) / (formator.SLR_AREA["BRAM"] / column) }')
      print(f'  DSP usage: {sum(int(v[1]) for v in all)} / {formator.SLR_AREA["DSP"] / column} = { (sum(int(v[1]) for v in all)) / (formator.SLR_AREA["DSP"] / column) }')
      print(f'  FF usage: {sum(int(v[2]) for v in all)} / {formator.SLR_AREA["FF"] / column} = { (sum(int(v[2]) for v in all)) / (formator.SLR_AREA["FF"] / column) }')
      print(f'  LUT usage: {sum(int(v[3]) for v in all)} / {formator.SLR_AREA["LUT"] / column} = { (sum(int(v[3]) for v in all)) / (formator.SLR_AREA["LUT"] / column) }')

  for e in topology:
    if (e.mark):
      print(f'{e.name}: {e.src.name} @ {e.src.slr_loc_2d} --> {e.dst.name} @ {e.dst.slr_loc_2d} ')
