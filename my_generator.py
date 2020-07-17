from collections import defaultdict
import pyverilog.vparser.ast as ast
from pyverilog.ast_code_generator.codegen import ASTCodeGenerator
from typing import Dict
import relay_station_template
from formator import FormatHLS
import math
import subprocess

def initPblocksU250(formator, tcl):
  NUM_PER_SLR_HORIZONTAL = 4
  for y in range(formator.SLR_CNT):
    if (formator.column[y] == 2):
      # column X4 is DDR; X7 is static region
      # if the DDR is not instantiated, add X4 to the right half
      # adding X4Y0 to the left half seems to violate PR DRC rules
      if (formator.DDR_enable[y] == False):
        # right_half_start = 5 if formator.DDR_enable[y] == 1 else 4
        right_half_start = 4
        tcl.write(f'''
          startgroup
            create_pblock pblock_X{0}_Y{y}
            resize_pblock pblock_X{0}_Y{y} -add CLOCKREGION_X0Y{0+y*NUM_PER_SLR_HORIZONTAL}:CLOCKREGION_X3Y{3+y*NUM_PER_SLR_HORIZONTAL}
          endgroup

          startgroup
            create_pblock pblock_X{1}_Y{y}
            resize_pblock pblock_X{1}_Y{y} -add CLOCKREGION_X{right_half_start}Y{0+y*NUM_PER_SLR_HORIZONTAL}:CLOCKREGION_X6Y{3+y*NUM_PER_SLR_HORIZONTAL}
          endgroup
        ''')
      else:
        print(f'[initPblocksU250] steal 2 DSP columns from the DDR region')
        getRange = lambda height, y : (height * y, height * (y+1) - 1)
        SLICE_height = getRange(240, y)
        DSP48E2_height = getRange(96, y)
        RAMB18_height = getRange(96, y)
        RAMB36_height = getRange(48, y)
        URAM288_height = getRange(64, y)
        tcl.write(f'''
          startgroup
            create_pblock pblock_X{0}_Y{y}
            resize_pblock pblock_X{0}_Y{y} -add CLOCKREGION_X0Y{0+y*NUM_PER_SLR_HORIZONTAL}:CLOCKREGION_X3Y{3+y*NUM_PER_SLR_HORIZONTAL}
          endgroup

          startgroup 
            create_pblock pblock_X1_Y{y}
            resize_pblock pblock_X1_Y{y} -add {{
              SLICE_X140Y{SLICE_height[0]}:SLICE_X205Y{SLICE_height[1]}
              DSP48E2_X18Y{DSP48E2_height[0]}:DSP48E2_X29Y{DSP48E2_height[1]} 
              RAMB18_X9Y{RAMB18_height[0]}:RAMB18_X11Y{RAMB18_height[1]} 
              RAMB36_X9Y{RAMB36_height[0]}:RAMB36_X11Y{RAMB36_height[1]} 
              URAM288_X3Y{URAM288_height[0]}:URAM288_X4Y{URAM288_height[1]}
            }}
          endgroup
        ''')
def initPblocksU280(formator, tcl):
  NUM_PER_SLR_HORIZONTAL = 4
  for y in range(formator.SLR_CNT):
    if (formator.column[y] == 2):
      # column X4 is DDR; X7 is static region
      # if the DDR is not instantiated, add X4 to the right half
      # adding X4Y0 to the left half seems to violate PR DRC rules
      tcl.write(f'''
        startgroup
          create_pblock pblock_X{0}_Y{y}
          resize_pblock pblock_X{0}_Y{y} -add CLOCKREGION_X0Y{0+y*NUM_PER_SLR_HORIZONTAL}:CLOCKREGION_X3Y{3+y*NUM_PER_SLR_HORIZONTAL}
        endgroup
      \n''')
  tcl.write('''
    startgroup
      create_pblock pblock_X1_Y2
      resize_pblock pblock_X1_Y2 -add {SLICE_X117Y480:SLICE_X205Y719 DSP48E2_X16Y186:DSP48E2_X29Y281 LAGUNA_X16Y360:LAGUNA_X27Y599 RAMB18_X8Y192:RAMB18_X11Y287 RAMB36_X8Y96:RAMB36_X11Y143 URAM288_X2Y128:URAM288_X4Y191}
    endgroup

    startgroup
      create_pblock pblock_X1_Y1
      resize_pblock pblock_X1_Y1 -add {SLICE_X117Y240:SLICE_X205Y479 DSP48E2_X16Y90:DSP48E2_X29Y185 LAGUNA_X16Y120:LAGUNA_X27Y359 RAMB18_X8Y96:RAMB18_X11Y191 RAMB36_X8Y48:RAMB36_X11Y95 URAM288_X2Y64:URAM288_X4Y127}
    endgroup

    startgroup
      create_pblock pblock_X1_Y0
      resize_pblock pblock_X1_Y0 -add {SLICE_X117Y0:SLICE_X205Y239 DSP48E2_X16Y0:DSP48E2_X29Y89 LAGUNA_X16Y0:LAGUNA_X27Y119 RAMB18_X8Y0:RAMB18_X11Y95 RAMB36_X8Y0:RAMB36_X11Y47 URAM288_X2Y0:URAM288_X4Y63}
      resize_pblock pblock_X1_Y0 -add {SLICE_X206Y0:SLICE_X232Y59 DSP48E2_X30Y0:DSP48E2_X31Y17 PCIE4CE4_X1Y0:PCIE4CE4_X1Y0 RAMB18_X12Y0:RAMB18_X13Y23 RAMB36_X12Y0:RAMB36_X13Y11}
    endgroup
  \n''')

def output_Sub_SLRConstraint(formator, assignment, tcl):
  for y in range(formator.SLR_CNT):
    for x in range(formator.column[y]):
      names = assignment[y][x]
      
      # the command cannot take empty inputs
      if (len(names) == 0):
        continue

      # sub-SLR level
      tcl.write(f'add_cells_to_pblock [get_pblocks pblock_X{x}_Y{y}] [get_cells -regexp {{\n')
      for v in names:
        tcl.write(f'\tpfm_top_i/dynamic_region/.*/inst/{v}\n')
      tcl.write('}] -clear_locs \n')

def outputSLRConstraint(formator, assignment, tcl):
  # if the assignment is 2d dict
  try:
    for y in range(formator.SLR_CNT):
      for x in range(formator.column[y]):
        names = assignment[y][x]
        
        # the command cannot take empty inputs
        if (len(names) == 0):
          continue

        # sub-SLR level
        tcl.write(f'add_cells_to_pblock [get_pblocks pblock_dynamic_SLR{y}] [get_cells -regexp {{\n')
        for v in names:
          tcl.write(f'\tpfm_top_i/dynamic_region/.*/inst/{v}\n')
        tcl.write('}] -clear_locs \n') 

  # if the assignment is 1d dict   
  except:      
    print(' *** WARNING: encounter SLR-level assignment *** ')
    for y in range(formator.SLR_CNT):
      names = assignment[y]
      
      # the command cannot take empty inputs
      if (len(names) == 0):
        continue

      tcl.write(f'add_cells_to_pblock [get_pblocks pblock_dynamic_SLR{y}] [get_cells -regexp {{\n')
      for v in names:
        tcl.write(f'\tpfm_top_i/dynamic_region/.*/inst/{v}\n')
      tcl.write('}] -clear_locs \n')

def constraintModules(formator, vertices, tcl):
  # collect modules for each sub-SLR pblock
  assignment_v_sub = defaultdict(lambda: defaultdict(list))
  
  for v in vertices:
    # here we do not consider axi modules
    if ('_axi' not in v.name):
      assignment_v_sub[v.slr_loc][v.slr_sub_loc].append(v.name)

  # kernels assign to half-SLR granularity
  output_Sub_SLRConstraint(formator, assignment_v_sub, tcl)

  return assignment_v_sub

def constraintAxiModules(formator, vertices, tcl):
  # collect modules for each SRL-level pblock
  assignment_axi = defaultdict(lambda: defaultdict(list))
  for v in vertices:
    if ('_axi' in v.name):
      assignment_axi[v.slr_loc][v.slr_sub_loc].append(v.name)
  
  # in U280 the SLR0 is divided according to the two HBM banks
  if ('280' in formator.board_name):
    output_Sub_SLRConstraint(formator, assignment_axi, tcl)
  elif (formator.AssignAxiSubSLR):
    output_Sub_SLRConstraint(formator, assignment_axi, tcl)  
  else:
    outputSLRConstraint(formator, assignment_axi, tcl)

def constraintEdges(formator, edges, tcl):
  # collect edges for each pblock
  assignment_e = defaultdict(lambda: defaultdict(list))

  # first constraint non-marked edges
  for e in filter(lambda x : not x.mark, edges):
    assert(e.dst.slr_loc == e.src.slr_loc)
    assert(e.dst.slr_sub_loc == e.src.slr_sub_loc)
    assignment_e[e.dst.slr_loc][e.dst.slr_sub_loc].append(f'{e.name}')

  # constraint marked edges
  constraintMarkedEdges(formator, edges, assignment_e)

  # edges assign to sub SLR granularity
  output_Sub_SLRConstraint(formator, assignment_e, tcl)

  return assignment_e

def constraintMarkedEdges(formator, edges, assignment_e):
  # currently not support other form of rs count
  assert(formator.relay_station_count(1) == 2)
  assert(formator.relay_station_count(2) == 4)
  assert(formator.relay_station_count(3) == 6)

  # only consider marked edges
  for e in filter(lambda x: x.mark, edges):

    src_y = e.src.slr_loc
    dst_y = e.dst.slr_loc
    src_x = e.src.slr_sub_loc
    dst_x = e.dst.slr_sub_loc

    # example: src = (0, 1); dst = (1, 3)
    # then there will be six units, separated in
    # (0, 1) -> (0, 2) -> (0, 2) -> (0, 3) -> (0, 3) -> (1, 3) 
    # range_inclusive_y = [1, 2, 3]
    # range_inclusive_x = [0, 1]
    # y_crossing = 2, x_crossing = 1
    range_inclusive_y = list(range( min(src_y, dst_y), max(src_y, dst_y)+1) )
    if (src_y > dst_y):
      range_inclusive_y.reverse()

    range_inclusive_x = list(range( min(src_x, dst_x), max(src_x, dst_x)+1) )
    if (src_x > dst_x):
      range_inclusive_x.reverse()

    y_crossing = abs(src_y - dst_y)
    x_crossing = abs(src_x - dst_x)
    for i in range(y_crossing + x_crossing):
      # first travel in y direction
      if (i < y_crossing):
        curr_y = range_inclusive_y[i]
        next_y = range_inclusive_y[i+1]
        assignment_e[curr_y][src_x].append(f'{e.name}/inst.*{i*2}.*unit')
        assignment_e[next_y][src_x].append(f'{e.name}/inst.*{i*2+1}.*unit')
      
      # then travel in x direction
      else :
        i_adjust = i - y_crossing
        curr_x = range_inclusive_x[i_adjust]
        next_x = range_inclusive_x[i_adjust + 1]
        assignment_e[dst_y][curr_x].append(f'{e.name}/inst.*{i*2}.*unit')
        assignment_e[dst_y][next_x].append(f'{e.name}/inst.*{i*2+1}.*unit')

#
# remove empty pblocks in case Vivado throws mysterious error
#
def removeUnusedPblock(formator, assignment_v, assignment_e, tcl):
  for y in range(formator.SLR_CNT):
    for x in range(formator.column[y]):
      names_e = assignment_e[y][x]
      names_v = assignment_v[y][x]
      if (len(names_e) == 0 and len(names_v) == 0):
        tcl.write(f'delete_pblocks [get_pblocks pblock_X{x}_Y{y}]\n')

#
# create constraints for each regional reset signal (HLS only)
#
def constraintReset(formator, tcl):
  assignment_reset = defaultdict(lambda: defaultdict(list))
  for y in range(formator.SLR_CNT):
    for x in range(formator.column[y]):
      assignment_reset[y][x].append(f'ap_rst_n_inv_X{x}_Y{y}_reg.*')

  output_Sub_SLRConstraint(formator, assignment_reset, tcl)

#
# Top func for generating constraints
#
def generateConstraint_2D(formator, vertices, edges):
  tcl = open('constraint.tcl', 'w')
  tcl.write('puts "applying partitioning constraints generated by the Context Sensitive HLS Solver"\n')
  tcl.write(f'write_checkpoint ./before_opt_design.dcp -force \n')

  # create sub-SLR pblocks
  if (formator.board_name == 'u250'):
    initPblocksU250(formator, tcl)
  elif (formator.board_name == 'u280'):
    initPblocksU280(formator, tcl)
  else :
    print('unsupported board!')
    exit

  assignment_v = constraintModules(formator, vertices, tcl)

  # memory units constrainted at SLR level, but not for U280
  constraintAxiModules(formator, vertices, tcl)

  if (formator.constraint_edge):
    assignment_e = constraintEdges(formator, edges, tcl)
  else :
    print('[codegen] *** WARNING: edges are not constrained *** ')
    assignment_e = defaultdict(lambda: defaultdict(list))

  # HLS generated designs need extra care with the reset signals
  if (type(formator) == FormatHLS):
    constraintReset(formator, tcl)
  else: 
    removeUnusedPblock(formator, assignment_v, assignment_e, tcl)

#########################################

#
# Top func for generating the new top rtl
#
def generateTopHdl(formator, top_mod_ast, vertices_dict: Dict, edges_dict : Dict):
  
  # specific to HLS generate design
  if (type(formator) == FormatHLS):
    level_traverse(formator, top_mod_ast, addSeparateReset, vertices_dict, edges_dict)

  # convert marked edges to relay stations
  level_traverse(formator, top_mod_ast, addRelayStation, edges_dict)
  
  # every module should be marked as keep_hierarchy to avoid hierarchy reconstruction
  level_traverse(formator, top_mod_ast, addPragmaKeepHier, edges_dict)

  # dump the new ast
  top_name = f'{formator.top_name}_{formator.top_name}.v'
  outputTopContents(formator, top_name, top_mod_ast)

  # add reset templates and remove ap_idle
  print('[codegen] *** CRITICAL WARNING: post processing of reset signals are disabled! *** ')
  # if (type(formator) == FormatHLS):
  #   postProcess(formator, top_name)

#
# dump the modifies AST along with rs templates
#
def outputTopContents(formator, top_name, top_mod_ast):
  codegen = ASTCodeGenerator()
  result = codegen.visit(top_mod_ast)

  new_top = open(f'{formator.top_name}_{formator.top_name}.v', 'w')
  new_top.write(result)

  # types of relay station
  if (formator.relay_station_template == 'fifo'):
    new_top.write(relay_station_template.relay_station_template)
  elif (formator.relay_station_template == 'reg'): 
    new_top.write(relay_station_template.reg_based_relay_station_template)
    # hls ad-hoc fifos will be replaced by the same fifo template
    if (type(formator) == FormatHLS):
      new_top.write(relay_station_template.yuze_fifo_template)
  elif (formator.relay_station_template == 'reg_srl_fifo'): 
    new_top.write(relay_station_template.reg_srl_fifo_relay_station_template)
  else:
    print('[codegen] ERROR: fifo template')
    exit

  new_top.close()

def addRelayStation(formator, node, edges_dict):
  # only considers fifo/rs instances
  if (not formator.isFIFOInstanceList(node)):
    return 

  edge_name = formator.getFIFONameFromInstanceList(node)
  e = edges_dict[edge_name]
  
  if (e.mark):
    node.module = 'relay_station'

    width = ast.ParamArg( 'DATA_WIDTH', ast.Rvalue(ast.IntConst(str(e.width))) )
    depth = ast.ParamArg( 'DEPTH', ast.Rvalue(ast.IntConst(str(e.depth))) )
    addr_width = ast.ParamArg( 'ADDR_WIDTH', ast.Rvalue(ast.IntConst(str(e.addr_width))) )
    level = ast.ParamArg( 'LEVEL', ast.Rvalue(ast.IntConst(str( e.latency ))) )
    params = [width, depth, addr_width, level]

    node.parameterlist = params

    for c in node.instances:
      c.module = 'relay_station'
      c.parameterlist = params

    # print(f'[codegen] update rs to {edge_name} -> {node.module}')
  
  # replace the ad-hoc fifos by hls
  # add the depth used for balancing reconvergent paths
  else :
    node.module = 'fifo'
    new_depth = int(e.depth + e.additional_depth)
    new_addr_width = int(math.log2(new_depth)+1)

    width = ast.ParamArg( 'DATA_WIDTH', ast.Rvalue(ast.IntConst(str(e.width))) )
    depth = ast.ParamArg( 'DEPTH', ast.Rvalue(ast.IntConst(str(new_depth))) )
    addr_width = ast.ParamArg( 'ADDR_WIDTH', ast.Rvalue(ast.IntConst(str(new_addr_width))) )
    params = [width, depth, addr_width]

    node.parameterlist = params

    for c in node.instances:
      c.module = 'fifo'
      c.parameterlist = params

def addPragmaKeepHier(formator, node, edges):
  #non fifo modules
  if (not formator.isInstanceList(node)):
    return     

  if (formator.only_keep_rs_hierarchy):
    if ('relay_station' not in node.module):
      return
      
  node.module = f'(* keep_hierarchy = "yes" *) {node.module}'
  for c in node.instances:
    c.module = f'(* keep_hierarchy = "yes" *) {c.module}'
  
  # print(f'[codegen] add keep_hierarchy to {node.module}')

#
# separate the reset signals from HLS-generated dataflow designs
#
def addSeparateReset(formator, node, vertices_dict, edges_dict):
  if (not formator.isInstanceList(node)):
    return    

  #lambda getInstanceName = node : node.instances[0].name

  mod_name = node.instances[0].name

  slr_sub_loc = -1
  slr_loc = -1
  if (mod_name in vertices_dict):
    v = vertices_dict[mod_name]
    slr_loc = v.slr_loc
    slr_sub_loc = v.slr_sub_loc
  elif (mod_name in edges_dict):
    e = edges_dict[mod_name]
    slr_loc = e.dst.slr_loc
    slr_sub_loc = e.dst.slr_sub_loc
  else:
    print(f'[codegen] WARNING: the reset of module {mod_name} is unoptimized')
    return

  curr_port_list = node.instances[0].portlist
  for portarg in curr_port_list:
    if ('ap_rst' in portarg.portname or 'reset' in portarg.portname or 'RESET' in portarg.portname ):
      portarg.argname.name = f'{portarg.argname.name}_X{slr_sub_loc}_Y{slr_loc}'


#
# helper
#
def level_traverse(formator, node, func, *arg):
  q = [node]
  while( len(q) ):
    curr = q.pop(0)
    for c in curr.children():
      q.append(c)
    func(formator, curr, *arg)

#
# for HLS designs, generate the definition of regional resets
# and remove ap_idle
#
def postProcess(formator, target_file):

  new_file = f'{target_file}.temp'
  fp = open(target_file, 'r')
  pro = open(new_file, 'w')

  def add_template(pro):
    Q_LEVEL = 4
    for Y in range(formator.SLR_CNT):
      for X in range(formator.column[Y]):
        pro.write(f'(* keep = "true" *) reg ap_rst_n_inv_X{X}_Y{Y};\n')
        for q in range(1, Q_LEVEL):
          pro.write(f'(* keep = "true" *) reg ap_rst_n_inv_X{X}_Y{Y}_{q};\n')

    pro.write(f'always @ (posedge ap_clk) begin\n')
    for Y in range(formator.SLR_CNT):
      for X in range(formator.column[Y]):
        pro.write(f'  ap_rst_n_inv_X{X}_Y{Y} <= ap_rst_n_inv_X{X}_Y{Y}_1;\n')
        for q in range(1, Q_LEVEL-1):
          pro.write(f'  ap_rst_n_inv_X{X}_Y{Y}_{q} <= ap_rst_n_inv_X{X}_Y{Y}_{q+1};\n')
        pro.write(f'  ap_rst_n_inv_X{X}_Y{Y}_{Q_LEVEL-1} <= ~ap_rst_n;\n')
    pro.write(f'end\n')

  has_add_template = 0
  for line in fp:
    if ('wire ' in line and has_add_template == 0):
      pro.write(line)

      add_template(pro)

      has_add_template = 1
    elif ('.ap_start(' in line):
      pro.write('    .ap_start(1),\n')
    elif ('assign ap_idle =' in line ):
      pro.write('assign ap_idle = 0;\n')
    else:
      pro.write(line)

  pro.close()  

  subprocess.run(['mv', target_file, f'{target_file}.backup'])
  subprocess.run(['mv', new_file, target_file])


def generateHLSPackXO(formator):
  pack_xo = open('pack_xo.tcl', 'w')
  
  if(formator.board_name == 'u250'):
    pack_xo.write(f'''
      open_project {formator.top_name}
      open_solution "solution"
      set_part {{xcu250-figd2104-2L-e}}
      create_clock -period 3.33 -name default
      config_compile -name_max_length 50  -pipeline_loops 0 -unsafe_math_optimizations
      config_dataflow -strict_mode warning
      config_sdx -target xocc
      export_design -rtl verilog -format ip_catalog -xo {formator.top_name}_tlp.xo
      exit    
    ''')
  elif(formator.board_name == 'u280'):
    pack_xo.write(f'''
      open_project {formator.top_name}
      open_solution "solution"
      set_part {{xcu280-fsvh2892-2L-e}}
      create_clock -period 3.33 -name default
      config_compile -name_max_length 50  -pipeline_loops 0 -unsafe_math_optimizations
      config_dataflow -strict_mode warning
      config_sdx -target xocc
      export_design -rtl verilog -format ip_catalog -xo {formator.top_name}_tlp.xo
      exit    
    ''')      

#########################################

def constraintModulesTaskBased(formator, vertices, tcl):
  # collect modules for each sub-SLR pblock
  assignment_v_sub = defaultdict(lambda: defaultdict(list))
  for y in range(formator.SLR_CNT):
    for x in range(formator.column[y]):
      for v in vertices:
        if (v.isLIS and v.slr_sub_loc == x and v.slr_loc == y):
          assignment_v_sub[y][x].append(v.name_orig + '_kernel')          
          # assignment_v_sub[y][x].append(v.name_orig + '_kernel' \
          #                               if v.slr_loc != v.parent.slr_loc or v.slr_sub_loc != v.parent.slr_sub_loc\
          #                               else v.name_orig)

  # kernels assign to half-SLR granularity
  for y in range(formator.SLR_CNT):
    for x in range(formator.column[y]):
      names = assignment_v_sub[y][x]
      
      # the command cannot take empty inputs
      if (len(names) == 0):
        continue

      # sub-SLR level
      tcl.write(f'add_cells_to_pblock [get_pblocks pblock_X{x}_Y{y}] [get_cells -regexp {{\n')
      for v in names:
        tcl.write(f'\tpfm_top_i/dynamic_region/.*/inst/{v}\n')
      tcl.write('}] -clear_locs \n')

  return assignment_v_sub

def generateConstraintTaskBased(formator, vertices, edges):
  tcl = open('constraint.tcl', 'w')
  tcl.write('puts "applying partitioning constraints generated by the Context Sensitive HLS Solver"\n')
  tcl.write(f'write_checkpoint ./before_opt_design.dcp -force \n')

  # create sub-SLR pblocks
  if (formator.board_name == 'u250'):
    initPblocksU250(formator, tcl)
  elif (formator.board_name == 'u280'):
    initPblocksU280(formator, tcl)
  else :
    print('unsupported board!')
    exit

  assignment_v = constraintModulesTaskBased(formator, vertices, tcl)

  if (formator.constraint_edge):
    assignment_e = constraintEdges(formator, edges, tcl)
  else :
    assignment_e = defaultdict(lambda: defaultdict(list))

  removeUnusedPblock(formator, assignment_v, assignment_e, tcl)
