#!/usr/bin/python3.6

import collections
from mip import *
#from graph import *
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
  coorinate_expansion_ratio = formator.coorinate_expansion_ratio
  SLR_CNT = formator.SLR_CNT

  # initialize model
  m = Model()

  # [var] if a module belongs to an SLR
  # FIXME: when there are modules of the same name there will be bug
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
  d_x = [m.add_var(var_type=INTEGER, name=f'd_x_{e.name}_{i}') for i, e in enumerate(topology)]
  d_y = [m.add_var(var_type=INTEGER, name=f'd_y_{e.name}_{i}') for i, e in enumerate(topology)]

  # [goal] 
  m.objective = minimize(xsum(d_x[i] * edge.width for i, edge in enumerate(topology) ) + \
                         xsum(d_y[i] * edge.width for i, edge in enumerate(topology) )  )

  # [constraint] only assign to 1 SLR
  for mod_x in mods_x.values():
    m += xsum(mod_x[y][x] for y in range(SLR_CNT) for x in range(column[y]) )  == 1

  # [constraint] auxiliary varaible p
  # |   R0  |
  # |-------|
  # | R1|R2 |
  # |-------|
  # the x coordinates of R1 and R2 are 0 and 2 respectively
  # the x of R0 is ** 1 ** so that it is of equatal distance to all other regions 
  # the y coordinates of R0 - R2 is 2, 0, 0 correspondingly.
  # we can apply some weights if we prefer h/v crossing
  for mod_x, mod_p in zip(mods_x.values(), mods_p.values()):
    m += mod_p['X'] == xsum(mod_x[y][x] * x * coorinate_expansion_ratio if column[y] == 2 else \
                            mod_x[y][x] * coorinate_expansion_ratio/2 \
                              for y in range(SLR_CNT) for x in range(column[y]) )
    m += mod_p['Y'] == xsum(mod_x[y][x] * y * coorinate_expansion_ratio \
                              for y in range(SLR_CNT) for x in range(column[y]) )

  # [constraint] auxiliary variable d
  for d_x_i, d_y_i, e in zip(d_x, d_y, topology):
    if (e.width < formator.max_width_threshold):
      m += d_x_i >= (mods_p[e.src]['X'] - mods_p[e.dst]['X']) * e.width
      m += d_x_i >= (mods_p[e.dst]['X'] - mods_p[e.src]['X']) * e.width
      m += d_y_i >= (mods_p[e.src]['Y'] - mods_p[e.dst]['Y']) * e.width
      m += d_y_i >= (mods_p[e.dst]['Y'] - mods_p[e.src]['Y']) * e.width

  # [constraint] edges too wide should not be split
  for d_x_i, d_y_i, e in zip(d_x, d_y, topology):
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
        cmd += f'<= {int(formator.SLR_AREA[item] / column[y] * formator.max_usage_ratio_2d[y][x])}, "{item}_SLR_{y}_sub_{x}_of_{column[y]}"'

        exec(cmd)

  # [constraint] DDR location constraint
  for v, mod_p in mods_p.items():
    if (v.name in formator.DDR_loc_2d_x):
      m += mod_p['X'] == formator.DDR_loc_2d_x[v.name] * coorinate_expansion_ratio
    if (v.name in formator.DDR_loc_2d_y):
      m += mod_p['Y'] == formator.DDR_loc_2d_y[v.name] * coorinate_expansion_ratio
  
  # run
  m.write('sample.lp')
  m.optimize(max_seconds=120)

  for v in vertices:
    v.slr_loc = mods_p[v]['Y'].x / coorinate_expansion_ratio
    if(mods_p[v]['X'].x == coorinate_expansion_ratio/2):
      v.slr_sub_loc = 0.5
    else:
      v.slr_sub_loc = mods_p[v]['X'].x / coorinate_expansion_ratio

  for e in topology:
    e.mark = mods_p[e.src]['X'].x != mods_p[e.dst]['X'].x or mods_p[e.src]['Y'].x != mods_p[e.dst]['Y'].x

  ###################################

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
        
      print(f'\n    BRAM usage: {sum(int(v[0]) for v in all)} / {formator.SLR_AREA["BRAM"] / column[y]} = { (sum(int(v[0]) for v in all)) / (formator.SLR_AREA["BRAM"] / column[y]) }')
      print(f'    DSP usage: {sum(int(v[1]) for v in all)} / {formator.SLR_AREA["DSP"] / column[y]} = { (sum(int(v[1]) for v in all)) / (formator.SLR_AREA["DSP"] / column[y]) }')
      print(f'    FF usage: {sum(int(v[2]) for v in all)} / {formator.SLR_AREA["FF"] / column[y]} = { (sum(int(v[2]) for v in all)) / (formator.SLR_AREA["FF"] / column[y]) }')
      print(f'    LUT usage: {sum(int(v[3]) for v in all)} / {formator.SLR_AREA["LUT"] / column[y]} = { (sum(int(v[3]) for v in all)) / (formator.SLR_AREA["LUT"] / column[y]) }\n')


  for e in topology:
    if (e.mark):
      print(f'{e.name}: {e.src.name} @ {e.src.slr_loc, e.src.slr_sub_loc} --> {e.dst.name} @ {e.dst.slr_loc, e.dst.slr_sub_loc} ')

def generateConstraintNonDataflow_2D(vertices, formator):
  tcl = open('constraint.tcl', 'w')
  tcl.write('puts "applying partitioning constraints generated by the Context Sensitive HLS Solver"\n')
  tcl.write(f'write_checkpoint ./before_opt_design.dcp -force \n')
  

  # create sub-SLR pblocks
  NUM_PER_SLR_HORIZONTAL = formator.NUM_PER_SLR_HORIZONTAL
  for y in range(formator.SLR_CNT):
    if (formator.column[y] == 2):
      # column X4 is DDR; X7 is static region
      # adding X4Y0 seems to violate PR DRC rules
      tcl.write(f'''
startgroup
create_pblock pblock_X{0}_Y{y}
resize_pblock pblock_X{0}_Y{y} -add CLOCKREGION_X0Y{0+y*NUM_PER_SLR_HORIZONTAL}:CLOCKREGION_X3Y{3+y*NUM_PER_SLR_HORIZONTAL}
endgroup

startgroup
create_pblock pblock_X{1}_Y{y}
resize_pblock pblock_X{1}_Y{y} -add CLOCKREGION_X5Y{0+y*NUM_PER_SLR_HORIZONTAL}:CLOCKREGION_X6Y{3+y*NUM_PER_SLR_HORIZONTAL}
endgroup
''')


  assignment_v_slr = defaultdict(list)
  
  for v in  vertices:
    if (v.isLIS):
      assignment_v_slr[v.slr_loc].append(v.name_orig + '_kernel' if v.slr_loc != v.parent.slr_loc else v.name_orig)

  for y in range(formator.SLR_CNT):
    names = assignment_v_slr[y]
    
    # the command cannot take empty inputs
    if (len(names) == 0):
      continue

    tcl.write(f'add_cells_to_pblock [get_pblocks pblock_dynamic_SLR{y}] [get_cells -hierarchical -regex {{\n')
    for v in names:
      tcl.write(f'\t(.*/)?{v}\n')
    tcl.write('}]\n')

  def postOrderTraversal(curr, prev, prev_path):
    if (not curr):
      return 

    if (curr.slr_loc != prev.slr_loc):
      curr_path = prev_path + r'(.*/)?' + curr.name_orig + r'_kernel/' 
    else:
      curr_path = prev_path + r'(.*/)?' + curr.name_orig + r'/'
    
    for c in curr.children:
      postOrderTraversal(c, curr, curr_path)

    # need to first get all children cells that already have been constrainted
    tcl.write('\nset all_children_cells [get_cells -hierarchical -regex {' + curr_path + '\[^/\]*}\n')

    if (len(curr.children)):
      tcl.write('set already_fp_cells {}\n')
      for c in curr.children:
        tcl.write('lappend already_fp_cells [get_cells -hierarchical -regex {' + curr_path + c.name_orig + '}\n')
      tcl.write('set not_fp_cells { foreach i $all_children_cells { if {[lsearch $already_fp_cells $i]==-1} {lappend not_fp_cells $i} } }\n')
      tcl.write(f'add_cells_to_pblock [get_pblocks pblock_dynamic_SLR{int(curr.slr_loc)}] $not_fp_cells\n')
    
    else :
      tcl.write(f'add_cells_to_pblock [get_pblocks pblock_dynamic_SLR{int(curr.slr_loc)}] $all_children_cells\n')
      
  # postOrderTraversal(root, root, r'(.*/)?')
  tcl.close()

