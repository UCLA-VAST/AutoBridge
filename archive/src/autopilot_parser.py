#! /usr/bin/python3.6

import re
import collections
import json

class bcolors:
  HEADER = '\033[95m'
  OKBLUE = '\033[94m'
  OKGREEN = '\033[92m'
  WARNING = '\033[93m'
  FAIL = '\033[91m'
  ENDC = '\033[0m'
  BOLD = '\033[1m'
  UNDERLINE = '\033[4m'

#
# sample format as follows:
# * Pipeline : 5
#   Pipeline-0 : II = 1, D = 3, States = { 19 20 21 }
#   Pipeline-1 : II = 1, D = 3, States = { 30 31 32 }
#   Pipeline-2 : II = 1, D = 1, States = { 51 }
#   Pipeline-3 : II = 1, D = 4, States = { 53 54 55 56 }
#   Pipeline-4 : II = 8, D = 8, States = { 138 139 140 142 141 143 144 145 }
#
# return: map stage number to pipeline ID
#
def getPipeline(sche_path):
  try:
    rpt = open(sche_path, 'r')
  except IOError:
    print(f'[getPipeline]: no report for {sche_path}')
    return {}

  stage_pp = {}
  for line in rpt:
    match = re.search('\* Pipeline : (\d)+', line)
    if (match):
      pp_num = int(match.group(1))
      for i in range(pp_num):
        pp = re.search('Pipeline-\d+ : II = \d+, D = \d+, States = {([ \d]+)}', rpt.readline())
        domain = list(map(int, pp.group(1).split()))
        for d in domain:
          stage_pp[d] = i
      break
  
  return stage_pp

#
# extract all sentences of one stage
#
def getStage(sche_path):
  try:
    rpt = open(sche_path, 'r')
  except IOError:
    name = sche_path.split('/')
    name = name[len(name)-1]
    print(f'[getStage] no report for {name}')
    return {}

  line = rpt.readline()
  while (line):
    match = re.search('^State (\d+)', line)
    if (match):
      stage_id = int(match.group(1))
      block = ''
    
      stmt = rpt.readline()
      while (stmt != ''):
        if (re.search('^State (\d+)', stmt)):
          rpt.seek(rpt.tell() - len(stmt))
          break
        else:
          block += stmt
          stmt = rpt.readline()
      yield block
    line = rpt.readline()

#
# extract all sentences of one stage, but with the newline
# return stage id, list of instructions
#
def getStageWithNewline(sche_path):
  try:
    rpt = open(sche_path, 'r')
  except IOError:
    name = sche_path.split('/')
    name = name[len(name)-1]
    print(f'[getStageWithNewline] no report for {name}')
    return {}

  line = rpt.readline()
  while (line):
    match = re.search('^State (\d+)', line)
    if (match):
      stage_id = int(match.group(1))
      block = []
    
      stmt = rpt.readline()
      while (stmt != ''):
        if (re.search('^State (\d+)', stmt)):
          rpt.seek(rpt.tell() - len(stmt))
          break
        else:
          block.append(stmt)
          stmt = rpt.readline()
      # print(f'[getStageWithNewline] extract block:\n{block}')
      yield stage_id, block
    line = rpt.readline()

#
# get the grouping of all ap_fifo interfaces
# two ap_fifos are in the same group if they are accessed in the same pipeline
# input: the autopilot schedule report; the formal names of all ap_fifo interfaces
# output: mapping from pipeline id to all ap_fifos used in this pipeline
#
def getGrouping(sche_path:str, formal_names):
  dir_names = sche_path.split('/')
  module_name = dir_names[len(dir_names)-1]  
  
  try:
    rpt = open(sche_path, 'r')
  except IOError:
    print(f'[getGrouping] no report for {module_name}')
    return {}, {}

  # map stage ID -> pp ID
  # stage ID starts from 1
  stage_pp = getPipeline(sche_path)

  # map pipeline ID -> all the FIFOs used in this pipeline
  pp_to_formal = collections.defaultdict(set)

  # extract used FIFOs in this stage
  def getFIFO(stage_with_newline, formal_names):
    curr_fifo = set()
    for line in stage_with_newline:
      # print(f'[getFIFO] inspect line: {line}') #if 'ap_fifo' in line else 0
      for name in formal_names:
        if ('ap_fifo.' in line and name in line):
          curr_fifo.add(name)
    return curr_fifo

  for stage_id, stage_with_newline in getStageWithNewline(sche_path):
    if (stage_id in stage_pp):
      pp_num = stage_pp[stage_id]
      pp_to_formal[pp_num].update(getFIFO(stage_with_newline, formal_names)) 
      # print(f'[getGrouping] in pipeline {pp_num} find fifo: ', pp_to_formal[pp_num])

  # inverse index
  formal_to_pp = {}
  for pp_num, fifos in pp_to_formal.items():
    for fifo in fifos:
      formal_to_pp[fifo] = pp_num

  #print(json.dumps(pp_to_formal, indent=2, sort_keys=True))
  print(f'[getGrouping] grouping results for {bcolors.WARNING}{module_name}:{bcolors.ENDC}')
  for i in pp_to_formal:
    print('\t', i, pp_to_formal[i])
  return formal_to_pp, pp_to_formal

#
# extract a module from raw verilog file
# sample format:
# EdgeMem_EdgeMem
# EdgeMem_0
# (
#   .ap_clk(ap_clk),
#   .ap_rst_n(EdgeMem_0__ap_rst_n__q2),
#   .edges_read_data_V_data_V_read(edges_0_read_data__read)
# );
#
def module_extract(rtl_path, mod_type, mod_name):
  file = open(rtl_path, 'r')

  module_rtl = ''
  for line in file:
    line = line.rstrip('\n;')

    # match type
    if (re.search(f'^[ ]*{mod_type}[ ]*$', line)):
      module_rtl = line

    if (module_rtl):
      # match name
      if (re.search(f'[ ]*{mod_name}[ ]*$', line)):
        module_rtl += line
        # port definitions
        for m in file:
          if (not re.search(f'[ ]*);[ ]*$', line)):
            module_rtl += line
          else:
            module_rtl += '  );'
            break # end of module extraction
      else:
        module_rtl = ''
  
  return module_rtl

#
# get the mapping from formal names to actual names
# then we can get the grouping of the actual edges
# input: kernel type, id
# output: dict : formal name -> actual name
#
def getMapping(mod_name: str, tlp_path:str, top_name:str):
  rtl_path = f'{tlp_path}/hdl/{top_name}_{top_name}.v'
  file = open(rtl_path, 'r')
  
  formal_to_actual = {}

  for line in file:
    # match name
    if (re.search(f'^[ ]*{mod_name}[ ]*$', line)):
      for line in file:
        # );
        if (re.search(f'^[ ]*\);[ ]*$', line)):
          break

        # .edge_req_q_fifo_V_dout(edge_req_0__dout),
        # .edge_resp_q_fifo_V_din(edge_resp_0__din),
        match = re.search(f'\.([\w_]+)_fifo_V_d\w+\(([\w_]+)__d\w+\),', line)
        if (match):
          formal_to_actual[match.group(1)] = match.group(2)
        
        # .task_req_q_fifo_V_1_din(task_req_1__din),
        match = re.search(f'\.([\w_]+)_fifo_V_(\d+)_d\w+\(([\w_]+)__d\w+\),', line)
        if (match):
          formal_to_actual[f'{match.group(1)}[{match.group(2)}]'] = match.group(3)

  print('[getMapping]\n', json.dumps(formal_to_actual, indent=2, sort_keys=True))
  return formal_to_actual

Area = collections.namedtuple('Area', 'BRAM DSP FF LUT URAM')

def getAreaFromReport(rpt_addr:str):
  try:
    rpt = open(rpt_addr, 'r')
  except IOError:
    print(f'[getAreaFromReport] no report file at {rpt_addr}')
    return Area(0, 0, 0, 0, 0)

  for line in rpt:
    if ('Total' in line):
      x = re.findall('\d+', line)
      return Area(BRAM=x[0], DSP=x[1], FF=x[2], LUT=x[3], URAM=x[4])

##############################


# mod_name = 'Control_0'
# mod_type = 'Control'
# tlp_path = '/home/einsx7/pr/application/PageRank/HBM_try1/PageRank.xilinx_u280_xdma_201920_3.hw.xo.tlp'
# top_name = 'PageRank'

# getMapping(mod_name, tlp_path, top_name)
# getGrouping(mod_type, tlp_path)

# tlp_path = '/home/einsx7/pr/application/PageRank/HBM_try1/PageRank.xilinx_u280_xdma_201920_3.hw.xo.tlp'
# mod_type = 'ProcElem'
# getGrouping(mod_type, tlp_path)