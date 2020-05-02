#! /usr/bin/python3.6

import re
import collections
import json

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
def getPipeline(rpt_path):
  rpt = open(rpt_path, 'r')
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
def getStage(rpt_path):
  rpt = open(rpt_path, 'r')
  
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
# get the mapping of formal names
#
def getGrouping(mod_type:str, tlp_path:str):
  rpt_path = f'{tlp_path}/report/{mod_type}.verbose.sched.rpt'

  # map stage ID -> pp ID
  # stage ID starts from 1
  stage_pp = getPipeline(rpt_path)

  # map pipeline ID -> all the FIFOs used in this pipeline
  pp_fifo = collections.defaultdict(set)

  # extract used FIFOs in this stage
  getFifoArray = lambda stage: set(re.findall('ap_fifo\.volatile[^%]*%(\w+)_fifo_V_(\d+)', stage))
  getFifo      = lambda stage: set(re.findall('ap_fifo\.volatile[^%]*%(\w+)_fifo_V[^_]', stage))

  for i, stage in enumerate(getStage(rpt_path)):
    stage_id = i+1
    if (stage_id in stage_pp):
      pp_num = stage_pp[stage_id]
      pp_fifo[pp_num].update(getFifo(stage)) 
      pp_fifo[pp_num].update(getFifoArray(stage)) 


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

  print(json.dumps(formal_to_actual, indent=2, sort_keys=True))
  return formal_to_actual

Area = collections.namedtuple('Area', 'BRAM DSP FF LUT')

def getAreaFromReport(mod_name, rpt_dir):

  if (re.search('_\d+[ ]*$', mod_name)):
    mod_name = re.sub('_\d+[ ]*$', '', mod_name)
  try:
    rpt = open(f'{rpt_dir}/{mod_name}_csynth.rpt', 'r')
  except IOError:
    print(f'no report file for {mod_name}')
    return

  for line in rpt:
    if ('Total' in line):
      x = re.findall('\d+', line)
      return Area(BRAM=x[0], DSP=x[1], FF=x[2], LUT=x[3])

##############################


# TODO: we should build the graph by parsing the RTL, which will be more useful

# mod_name = 'Control_0'
# mod_type = 'Control'
# tlp_path = '/home/einsx7/pr/application/PageRank/HBM_try1/PageRank.xilinx_u280_xdma_201920_3.hw.xo.tlp'
# top_name = 'PageRank'

# getMapping(mod_name, tlp_path, top_name)
# getGrouping(mod_type, tlp_path)