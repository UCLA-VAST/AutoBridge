#! /usr/bin/python3.6

import collections
import re
import pyverilog.vparser.ast as ast

class FormatHLS:
  # either xxxx__dout or xxxx_dout
  fifo_dout_format = '([^ ]*[^_])_+dout'
  fifo_din_format = '([^ ]*[^_])_+din'

  def __init__(
      self,
      rpt_path,
      hls_sche_path,
      top_hdl_path,
      top_name,
      DDR_loc,
      max_usage_ratio,
      SLR_CNT,
      SLR_AREA):
    self.rpt_path = rpt_path
    self.hls_sche_path = hls_sche_path
    self.top_hdl_path = top_hdl_path
    self.top_name = top_name
    self.DDR_loc = DDR_loc
    self.max_usage_ratio = max_usage_ratio
    self.SLR_CNT = SLR_CNT
    self.SLR_AREA = SLR_AREA   

  # {top_name}_Control.v -> Control.verbose.sched.rpt
  def getScheFile(self, mod_type:str):
    former = mod_type[:len(self.top_name)+1]
    latter = mod_type[len(self.top_name)+1:]
    print(former, latter)
    assert(former == f'{self.top_name}_')
    return f'{self.hls_sche_path}/{latter}.verbose.sched.rpt'
    
  # module name : Control_0 -> rpt name: Control_csynth.rpt
  def getRptFile(self, v):
    mod_type = v.type
    former = mod_type[:len(self.top_name)+1]
    latter = mod_type[len(self.top_name)+1:]

    return f'{self.rpt_path}/{latter}_csynth.rpt'

  # xxx_dout -> xxx
  def extractFIFOFromRaw(self, name_raw:str):
    if ('_dout' in name_raw):
      return re.search(FormatHLS.fifo_dout_format, name_raw).group(1)
    elif ('_din' in name_raw):
      return re.search(FormatHLS.fifo_din_format, name_raw).group(1)
    else:
      return None    

  # fifo xxx (.DATA_WIDTH(16)) -> 16
  # fifo_w32_d2_A xxx -> 32
  def extractFIFOWidth(self, node):
    mod_type = node.module
    
    if (node.parameterlist): # for TLP
      for paramarg in node.parameterlist:
        formal = paramarg.paramname
        actual = paramarg.argname.value
        if( 'DATA_WIDTH' in formal): 
          return int(actual)

    else: # for HLS
      match = re.search('_w(\d+)_d(\d+)_', mod_type)
      if (match):
        return int(match.group(1)) # group 1
      
    print('FIFO width error')

  def extractFIFODepth(self, node):
    mod_type = node.module
    
    if (node.parameterlist): # for TLP
      for paramarg in node.parameterlist:
        formal = paramarg.paramname
        actual = paramarg.argname.value
        if( 'DEPTH' in formal): 
          return int(actual)

    else: # for HLS
      match = re.search('_w(\d+)_d(\d+)_', mod_type)
      if (match):
        return int(match.group(2)) # group 2
      
    print('FIFO depth error')

  def isFIFO(self, node):
    return 'fifo' in node.module
  
  def isValidInstance(self, node):
    return isinstance(node, ast.Instance) and 'start_for' not in node.name and '_axi' not in node.name
  
  def isFIFOInstanceList(self, node):
    return isinstance(node, ast.InstanceList) and 'fifo' in node.module
  
  def getFIFONameFromInstanceList(self, node):
    assert(len(node.instances) == 1)
    return node.instances[0].name