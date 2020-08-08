#!/usr/bin/python3.6

import collections
from mip import *
#from graph import *
from typing import List, Callable, Dict
import os
import re

def addUserConstraint(m, mods_p, formator):
  # [constraint] DDR location constraint
  for v, mod_p in mods_p.items():
    if (v.name in formator.DDR_loc_2d_x):
      print(f'[AssignSLR] user specified module {v.name} to be in X {formator.DDR_loc_2d_x[v.name]}')
      m += mod_p['X'] == formator.DDR_loc_2d_x[v.name]
    if (v.name in formator.DDR_loc_2d_y):
      print(f'[AssignSLR] user specified module {v.name} to be in Y {formator.DDR_loc_2d_y[v.name]}')
      m += mod_p['Y'] == formator.DDR_loc_2d_y[v.name]
  
  # assert that user specified modules are valid
  for mod in formator.DDR_loc_2d_x.keys():
    if not any(v.name == mod for v in mods_p.keys()):
      print(f'[AssignSLR] CRITICAL WARNING: user specified module {mod} does not exist')
      exit()
  for mod in formator.DDR_loc_2d_y.keys():
    if not any(v.name == mod for v in mods_p.keys()):
      print(f'[AssignSLR] CRITICAL WARNING: user specified module {mod} does not exist')
      exit()

#
# Multi-column SLR assignment problem
#
def assignSLR(vertices : List, edges : List, formator):

  column = formator.column
  SLR_CNT = formator.SLR_CNT

  # initialize model
  m = Model()

  # [var] if a module belongs to an SLR
  # FIXME: when there are modules of the same name there will be bug
  # append an vertex id to make names unique
  mods_x = {} # str -> [mip_var]
  for i, v in enumerate(vertices):
    new_mod_x = [ [m.add_var(var_type=BINARY, name=f'{v.name}_{i}_x_{y}_{x}') for x in range(column[y]) ]  for y in range(SLR_CNT)] 
    mods_x[v.name] = new_mod_x # m[y][x] *** first index the y dimension

  # [var] the location of a module
  mods_p = {} # Vertex -> mip_var
  for i, v in enumerate(vertices): 
    new_mod_p = {'Y' : m.add_var(var_type=INTEGER, name=f'{v.name}_{i}_p_y'), 'X' : m.add_var(var_type=INTEGER, name=f'{v.name}_{i}_p_x') }
    mods_p[v] = new_mod_p
  
  # [var] distance of each edge
  d_x = [m.add_var(var_type=INTEGER, name=f'd_x_{e.name}_{i}') for i, e in enumerate(edges)]
  d_y = [m.add_var(var_type=INTEGER, name=f'd_y_{e.name}_{i}') for i, e in enumerate(edges)]

  # [goal] 
  m.objective = minimize(xsum(d_x[i] * edge.width for i, edge in enumerate(edges) ) + \
                         xsum(d_y[i] * edge.width for i, edge in enumerate(edges) )  )

  # [constraint] only assign to 1 SLR
  for mod_x in mods_x.values():
    m += xsum(mod_x[y][x] for y in range(SLR_CNT) for x in range(column[y]) )  == 1

  # [constraint] auxiliary varaible p
  # |   R0  |
  # |-------|  [obsolete]
  # | R1|R2 |
  # |-------|
  # the x coordinates of R1 and R2 are 0 and 2 respectively
  # the x of R0 is ** 1 ** so that it is of equatal distance to all other regions 
  # the y coordinates of R0 - R2 is 2, 0, 0 correspondingly.
  # we can apply some weights if we prefer h/v crossing
  for mod_x, mod_p in zip(mods_x.values(), mods_p.values()):
    m += mod_p['X'] == xsum(mod_x[y][x] * x for y in range(SLR_CNT) for x in range(column[y]) )
    m += mod_p['Y'] == xsum(mod_x[y][x] * y for y in range(SLR_CNT) for x in range(column[y]) )

  # [constraint] auxiliary variable d
  for d_x_i, d_y_i, e in zip(d_x, d_y, edges):
    if (e.width < formator.max_width_threshold):
      m += d_x_i >= (mods_p[e.src]['X'] - mods_p[e.dst]['X']) * e.width * formator.horizontal_cross_weight
      m += d_x_i >= (mods_p[e.dst]['X'] - mods_p[e.src]['X']) * e.width * formator.horizontal_cross_weight
      m += d_y_i >= (mods_p[e.src]['Y'] - mods_p[e.dst]['Y']) * e.width
      m += d_y_i >= (mods_p[e.dst]['Y'] - mods_p[e.src]['Y']) * e.width

  # [constraint] edges too wide should not be split
  for d_x_i, d_y_i, e in zip(d_x, d_y, edges):
    if (e.width > formator.max_width_threshold):
      m += mods_p[e.src]['X'] == mods_p[e.dst]['X']
      m += mods_p[e.src]['Y'] == mods_p[e.dst]['Y']

  # [constraint] area
  for item in ['BRAM', 'DSP', 'FF', 'LUT']:
    for y in range(SLR_CNT):
      for x in range(column[y]):
        cmd = 'm += 0'
        for v in vertices:
          cmd += f' + mods_x["{v.name}"][{y}][{x}] * {getattr(v.area, item)}'
        cmd += f'<= {int(formator.SLR_AREA[item][x] * formator.max_usage_ratio_2d[y][x])}, "{item}_SLR_{y}_sub_{x}_of_{column[y]}"'
        exec(cmd)

  addUserConstraint(m, mods_p, formator)

  # run
  m.write('assignment.lp')
  m.optimize(max_seconds=formator.max_search_time)

  writeBackAssignResult(vertices, edges, formator, mods_p)

  showAssignResult(vertices, edges, formator)


def assignSLRDivideConquer(vertices : List, edges : List, formator):
  # first do all the vertical splits, then do all the horizontal splits
  # d = d0 * 2 + d1

  # #####################################
  # for i in range(13):
  #   for j in range(16):
  #     formator.DDR_loc_2d_y[f'PE_wrapper_{i}_{j}_U0'] = int(j / 4)
  #     formator.DDR_loc_2d_x[f'PE_wrapper_{i}_{j}_U0'] = 0 if i < 8 else 1
  # #####################################

  splitHalfHelper(formator, vertices, edges)

  splitQuarterHelper(formator, vertices, edges)

  splitHorizontalHelper(formator, vertices, edges)

  commitSLRAssignment(formator, vertices, edges)

  showAssignResult(vertices, edges, formator)

  # exit()

def commitSLRAssignment(formator, vertices, edges):
  for v in vertices:
    v.slr_loc = int( v.vertical_cut[0] * 2 + v.vertical_cut[1] )
    v.slr_sub_loc = int( v.horizontal_cut[0] )

  for e in edges:
    e.mark = e.src.slr_loc != e.dst.slr_loc or e.src.slr_sub_loc != e.dst.slr_sub_loc

  for e in edges:
    if (e.mark):
      step_v = abs(e.src.slr_loc - e.dst.slr_loc)
      step_h = abs(e.src.slr_sub_loc - e.dst.slr_sub_loc)
      e.latency = int( formator.relay_station_count(step_v + step_h) )

def splitHorizontalHelper(formator, vertices, edges):
  # after two vertical cut, do the horizontal cut
  area_horizontal = defaultdict(lambda : defaultdict(dict))

  relax_ratio = formator.max_usage_ratio_delta

  for item in ['BRAM', 'DSP', 'FF', 'LUT']:
    for slr in range(len(formator.column)):
      for sub_slr in range(2):
        area_horizontal[slr][sub_slr][item] =  formator.SLR_AREA[item][sub_slr] * (formator.max_usage_ratio_2d[slr][sub_slr] + relax_ratio)
        print(f'[splitHorizontalHelper] area_horizontal[{slr}][{sub_slr}][{item}] = {area_horizontal[slr][sub_slr][item]}')

  loc_func_horizontal = lambda mod_x : mod_x 

  user_constraint_horizontal = defaultdict()
  for name, loc_x in formator.DDR_loc_2d_x.items():
    user_constraint_horizontal[name] = loc_x == 1

  results = splitHorizontal(formator, vertices, edges, area_horizontal, loc_func_horizontal, user_constraint_horizontal)

  for v, loc in results.items():
    print(f'{v.name}\t{v.vertical_cut[0] * 2 + v.vertical_cut[1]}\t{loc}')
    v.horizontal_cut.append(loc)


def splitHorizontal(
    formator,
    vertices : List,
    edges : List,
    area : Dict,
    loc_func : Callable,
    user_constraint : Dict
):

  m = Model()

  mods_x = {} # str -> [mip_var]
  for i, v in enumerate(vertices):
    mods_x[v.name] = m.add_var(var_type=BINARY, name=f'{v.name}_{i}_x') 

  # d = e.src.x xor e.dst.x
  # attention here d_x is declared as binary
  d_x = [m.add_var(var_type=BINARY, name=f'd_x_{e.name}_{i}') for i, e in enumerate(edges)]
  for d_x_i, e in zip(d_x, edges):
    m += d_x_i >= loc_func(mods_x[e.src.name]) - loc_func(mods_x[e.dst.name])
    m += d_x_i >= loc_func(mods_x[e.dst.name]) - loc_func(mods_x[e.src.name])

  # area constraints
  for item in ['BRAM', 'DSP', 'FF', 'LUT']:
    for slr in range(len(formator.column)):
      # for 0-area
      cmd = 'm += 0'
      for v in vertices:
        if (v.vertical_cut[0] * 2 + v.vertical_cut[1] == slr):
          cmd += f' + (1 - mods_x["{v.name}"]) * {getattr(v.area, item)}'
      cmd += f' <= {area[slr][0][item]}'
      exec(cmd)

      # for 1-area
      cmd = 'm += 0'
      for v in vertices:
        if (v.vertical_cut[0] * 2 + v.vertical_cut[1] == slr):
          cmd += f' + (mods_x["{v.name}"]) * {getattr(v.area, item)}'
      cmd += f' <= {area[slr][1][item]}'
      exec(cmd)

  # user constraints
  for mod_name, loc in user_constraint.items():
    assert(any(v.name == mod_name for v in vertices))
    m += mods_x[mod_name] == loc

  m.objective = minimize(xsum(d_x[i] * edge.width for i, edge in enumerate(edges) ) )

  m.write('splitHorizontal.lp')
  m.optimize(max_seconds=formator.max_search_time)

  # return the results
  return dict(zip(vertices, [mods_x[v.name].x for v in vertices]))

###############################################################################

def splitQuarterHelper(formator, vertices, edges):
  # second vertical cut
  area_quarter = defaultdict(lambda: defaultdict(list))
  for item in ['BRAM', 'DSP', 'FF', 'LUT']:
    
    if (formator.board_name == 'u250'):
      for slr in range(4):
        area_quarter[slr][item] =   formator.SLR_AREA[item][0] * formator.max_usage_ratio_2d[slr][0] \
                                  + formator.SLR_AREA[item][1] * formator.max_usage_ratio_2d[slr][1]

    elif (formator.board_name == 'u280'):
      for slr in range(3):
        area_quarter[slr][item] =   formator.SLR_AREA[item][0] * formator.max_usage_ratio_2d[slr][0] \
                                  + formator.SLR_AREA[item][1] * formator.max_usage_ratio_2d[slr][1]
      area_quarter[3][item] =  0

    else :
      print(f'[splitQuarterHelper] unsupported board name {formator.board_name}')

  loc_func_quarter = lambda mod_x, v : v.vertical_cut[0] * 2 + mod_x

  user_constraint_quarter = defaultdict()
  for name, loc_y in formator.DDR_loc_2d_y.items():
    user_constraint_quarter[name] = loc_y == 1 or loc_y == 3   

  result = splitQuarter(formator, vertices, edges, area_quarter, loc_func_quarter, user_constraint_quarter)
  for v, loc in result.items():
    print(f'{v.name}\t{loc_func_quarter(loc, v)}')
    v.vertical_cut.append(loc)

def splitQuarter(
    formator,
    vertices : List,
    edges : List,
    area : Dict,
    loc_func : Callable,
    user_constraint : Dict
):

  m = Model()

  mods_x = {} # str -> [mip_var]
  for i, v in enumerate(vertices):
    mods_x[v.name] = m.add_var(var_type=BINARY, name=f'{v.name}_{i}_x') 

  # d = e.src.x xor e.dst.x
  d_x = [m.add_var(var_type=INTEGER, name=f'd_x_{e.name}_{i}') for i, e in enumerate(edges)]
  for d_x_i, e in zip(d_x, edges):
    m += d_x_i >= loc_func(mods_x[e.src.name], e.src) - loc_func(mods_x[e.dst.name], e.dst)
    m += d_x_i >= loc_func(mods_x[e.dst.name], e.dst) - loc_func(mods_x[e.src.name], e.src)

  # area constraints
  for item in ['BRAM', 'DSP', 'FF', 'LUT']:
    # for slr 0
    cmd = 'm += 0'
    for v in vertices:
      if v.vertical_cut[0] == 0:
        cmd += f' + (1 - mods_x["{v.name}"]) * {getattr(v.area, item)}'
    cmd += f'<= {area[0][item]}'
    exec(cmd)

    # for slr 1
    cmd = 'm += 0'
    for v in vertices:
      if v.vertical_cut[0] == 0:
        cmd += f' + (mods_x["{v.name}"]) * {getattr(v.area, item)}'
    cmd += f'<= {area[1][item]}'
    exec(cmd)    

    # for slr 2
    cmd = 'm += 0'
    for v in vertices:
      if v.vertical_cut[0] == 1:
        cmd += f' + (1 - mods_x["{v.name}"]) * {getattr(v.area, item)}'
    cmd += f'<= {area[2][item]}'
    exec(cmd)

    # for slr 3
    cmd = 'm += 0'
    for v in vertices:
      if v.vertical_cut[0] == 1:    
        cmd += f' + (mods_x["{v.name}"]) * {getattr(v.area, item)}'
    cmd += f'<= {area[3][item]}'
    exec(cmd)    

  # user constraints
  for mod_name, loc in user_constraint.items():
    assert(any(v.name == mod_name for v in vertices))
    m += mods_x[mod_name] == loc

  m.objective = minimize(xsum(d_x[i] * edge.width for i, edge in enumerate(edges) ) )
  
  m.write('splitQuarter.lp')
  m.optimize(max_seconds=formator.max_search_time)

  # return the results
  return dict(zip(vertices, [mods_x[v.name].x for v in vertices]))

###############################################################################


def splitHalfHelper(formator, vertices, edges):
  # first vertical cut
  area = defaultdict(dict)
  for item in ['BRAM', 'DSP', 'FF', 'LUT']:
    area[0][item] =  formator.SLR_AREA[item][0] * formator.max_usage_ratio_2d[0][0] \
                  + formator.SLR_AREA[item][1] * formator.max_usage_ratio_2d[0][1] \
                  + formator.SLR_AREA[item][0] * formator.max_usage_ratio_2d[1][0] \
                  + formator.SLR_AREA[item][1] * formator.max_usage_ratio_2d[1][1]

    if (formator.board_name == 'u250'):
      area[1][item] = formator.SLR_AREA[item][0] * formator.max_usage_ratio_2d[2][0] \
                    + formator.SLR_AREA[item][1] * formator.max_usage_ratio_2d[2][1] \
                    + formator.SLR_AREA[item][0] * formator.max_usage_ratio_2d[3][0] \
                    + formator.SLR_AREA[item][1] * formator.max_usage_ratio_2d[3][1]
    elif (formator.board_name == 'u280'):
      area[1][item] = formator.SLR_AREA[item][0] * formator.max_usage_ratio_2d[2][0] \
                    + formator.SLR_AREA[item][1] * formator.max_usage_ratio_2d[2][1]   

    else :
      print(f'[splitHalfHelper] unsupported board name {formator.board_name}')

    print(f'[splitHalfHelper] area[0][{item}] = {area[0][item]}')
    print(f'[splitHalfHelper] area[1][{item}] = {area[1][item]}')

  loc_func = lambda mod_x, v : mod_x

  user_constraint = defaultdict()
  for name, loc_y in formator.DDR_loc_2d_y.items():
    user_constraint[name] = loc_y >= 2 

  result = splitHalf(formator, vertices, edges, area, loc_func, user_constraint)

  for v, loc in result.items():
    print(f'{v.name}\t{loc}')
    v.vertical_cut.append(loc)

def splitHalf(
    formator,
    vertices : List,
    edges : List,
    area : Dict,
    loc_func : Callable,
    user_constraint : Dict
):

  m = Model()

  mods_x = {} # str -> [mip_var]
  for i, v in enumerate(vertices):
    mods_x[v.name] = m.add_var(var_type=BINARY, name=f'{v.name}_{i}_x') 

  # d = e.src.x xor e.dst.x
  d_x = [m.add_var(var_type=INTEGER, name=f'd_x_{e.name}_{i}') for i, e in enumerate(edges)]
  for d_x_i, e in zip(d_x, edges):
    assert('d_x_' not in e.name)
    m += d_x_i >= loc_func(mods_x[e.src.name], e.src) - loc_func(mods_x[e.dst.name], e.dst)
    m += d_x_i >= loc_func(mods_x[e.dst.name], e.dst) - loc_func(mods_x[e.src.name], e.src)

  # area constraints
  for item in ['BRAM', 'DSP', 'FF', 'LUT']:
    # for 1-area
    cmd = 'm += 0'
    for v in vertices:
      cmd += f' + mods_x["{v.name}"] * {getattr(v.area, item)}'
    cmd += f'<= {area[1][item]}'
    exec(cmd)

    # for 0-area
    cmd = 'm += 0'
    for v in vertices:
      cmd += f' + (1 - mods_x["{v.name}"]) * {getattr(v.area, item)}'
    cmd += f'<= {area[0][item]}'
    exec(cmd)    

  # user constraints
  for mod_name, loc in user_constraint.items():
    assert(any(v.name == mod_name for v in vertices))
    m += mods_x[mod_name] == loc

  m.objective = minimize(xsum(d_x[i] * edge.width for i, edge in enumerate(edges) ) )

  m.write('splitHalf.lp')

  m.optimize(max_seconds=formator.max_search_time)
  return dict(zip(vertices, [mods_x[v.name].x for v in vertices]))

###############################################################################

def writeBackAssignResult(vertices : List, edges : List, formator, mods_p):
  for v in vertices:
    v.slr_loc = int( mods_p[v]['Y'].x)
    v.slr_sub_loc = int( mods_p[v]['X'].x)

  for e in edges:
    e.mark = mods_p[e.src]['X'].x != mods_p[e.dst]['X'].x or mods_p[e.src]['Y'].x != mods_p[e.dst]['Y'].x

  for e in edges:
    if (e.mark):
      step_v = abs(e.src.slr_loc - e.dst.slr_loc)
      step_h = abs(e.src.slr_sub_loc - e.dst.slr_sub_loc)
      e.latency = int( formator.relay_station_count(step_v + step_h) )

def showAssignResult(vertices : List, edges : List, formator):
  column = formator.column
  SLR_CNT = formator.SLR_CNT

  for y in range(SLR_CNT):
    for x in range(column[y]):
      all = []

      if (column[y] == 2):
        print(f'SLR_[{y}] part {x} includes:\n')        
        for v in vertices:
          if (v.slr_sub_loc == x and v.slr_loc == y):
            print(f'  {v.name} -> {v.area}')
            all.append(v.area)

      elif (column[y] == 1):
        print(f'SLR_[{y}] as a whole includes:\n')
        for v in vertices:
          if (v.slr_sub_loc == 0.5 and v.slr_loc == y):
            print(f'  {v.name} -> {v.area}')
            all.append(v.area)
        
      print(f'\n    BRAM usage: {sum(int(v[0]) for v in all)} / {formator.SLR_AREA["BRAM"][x]} = { (sum(int(v[0]) for v in all)) / (formator.SLR_AREA["BRAM"][x]) }')
      print(f'    DSP usage: {sum(int(v[1]) for v in all)} / {formator.SLR_AREA["DSP"][x]} = { (sum(int(v[1]) for v in all)) / (formator.SLR_AREA["DSP"][x]) }')
      print(f'    FF usage: {sum(int(v[2]) for v in all)} / {formator.SLR_AREA["FF"][x]} = { (sum(int(v[2]) for v in all)) / (formator.SLR_AREA["FF"][x]) }')
      print(f'    LUT usage: {sum(int(v[3]) for v in all)} / {formator.SLR_AREA["LUT"][x]} = { (sum(int(v[3]) for v in all)) / (formator.SLR_AREA["LUT"][x]) }\n')


  for e in edges:
    if (e.mark):
      print(f'{e.name}: {e.src.name} @ {e.src.slr_loc, e.src.slr_sub_loc} --> {e.dst.name} @ {e.dst.slr_loc, e.dst.slr_sub_loc} ')

def reBalance(vertices : List, edges_dict : Dict, formator):
  m = Model()

  edges = edges_dict.values()

  mods_S = {} # Vertex -> mip_var
  for v in vertices:
    for sub_v in v.sub_vertices.values(): 
      new_mod_S = m.add_var(var_type=INTEGER, name=f'{sub_v.name}_S')
      mods_S[sub_v] = new_mod_S  

  for e in edges:
    if ('Mem' in e.dst.name or 'Mem' in e.src.name or \
        'Router' in e.dst.name or 'Router' in e.src.name):
      print(f'[reBalance] FIXME need to handle async_mmap')
      continue
    # if at either side the edge is not accessed in pipeline, then no worries
    if (e.name in e.dst.actual_to_sub and e.name in e.src.actual_to_sub):
      src_sub = e.src.actual_to_sub[e.name]
      dst_sub = e.dst.actual_to_sub[e.name]
      adjusted_lat = e.latency if e.latency > 1 else 0
      m += mods_S[src_sub] >= mods_S[dst_sub] + adjusted_lat

  goal = 'm.objective = minimize( 0 '
  for e in edges:
    if ('Mem' in e.dst.name or 'Mem' in e.src.name or \
        'Router' in e.dst.name or 'Router' in e.src.name):
      print(f'[reBalance] FIXME need to handle async_mmap')
      continue
    if (e.name in e.dst.actual_to_sub and e.name in e.src.actual_to_sub):
      src_sub = e.src.actual_to_sub[e.name]
      dst_sub = e.dst.actual_to_sub[e.name]
      adjusted_lat = e.latency if e.latency > 1 else 0      
      goal += f' + {e.width} * (mods_S[edges_dict["{e.name}"].src.actual_to_sub["{e.name}"]] - mods_S[edges_dict["{e.name}"].dst.actual_to_sub["{e.name}"]] - {adjusted_lat})'
  goal += ')'
  
  if (goal == 'm.objective = minimize( 0 )'):
    print(f'[rebalance] WARNING: do not detect any reconvergent paths')
    return
    
  exec(goal)

  m.write('rebalance.lp')
  m.optimize(max_seconds=120)

  ##############################

  for e in edges:
    if ('Mem' in e.dst.name or 'Mem' in e.src.name or \
        'Router' in e.dst.name or 'Router' in e.src.name):
      print(f'[reBalance] FIXME need to handle async_mmap')
      continue    
    # if at either side the edge is not accessed in pipeline, then no worries
    if (e.name in e.dst.actual_to_sub and e.name in e.src.actual_to_sub):
      src_sub = e.src.actual_to_sub[e.name]
      dst_sub = e.dst.actual_to_sub[e.name]
      adjusted_lat = e.latency if e.latency > 1 else 0

      e.additional_depth = mods_S[src_sub].x - mods_S[dst_sub].x - adjusted_lat
      if (e.additional_depth):
        print(f'[reBalance] edge {e.name} is increased by {e.additional_depth}')

# treat all ports of a module as synchronized
def reBalanceNaive(vertices : List, edges_dict : Dict, formator):
  m = Model()

  edges = edges_dict.values()

  mods_S = {} # Vertex -> mip_var
  for v in vertices:
    new_mod_S = m.add_var(var_type=INTEGER, name=f'{v.name}_S')
    mods_S[v] = new_mod_S  

  for e in edges:
    adjusted_lat = e.latency if e.latency > 1 else 0
    m += mods_S[e.src] >= mods_S[e.dst] + adjusted_lat

  goal = 'm.objective = minimize( 0 '
  for e in edges:
    adjusted_lat = e.latency if e.latency > 1 else 0      
    goal += f' + {e.width} * (mods_S[edges_dict["{e.name}"].src] - mods_S[edges_dict["{e.name}"].dst] - {adjusted_lat})'
  goal += ')'
  
  if (goal == 'm.objective = minimize( 0 )'):
    print(f'[rebalance] WARNING: do not detect any reconvergent paths')
    return
    
  exec(goal)

  m.write('rebalance.lp')
  m.optimize(max_seconds=120)

  ##############################

  for e in edges:
    adjusted_lat = e.latency if e.latency > 1 else 0

    e.additional_depth = mods_S[e.src].x - mods_S[e.dst].x - adjusted_lat
    if (e.additional_depth):
      print(f'[reBalanceNaive] edge {e.name} is increased by {e.additional_depth}')
