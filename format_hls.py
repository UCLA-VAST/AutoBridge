#! /usr/bin/python3.6

import collections
import re
import pyverilog.vparser.ast as ast

class FormatHLS:
  # either xxxx__dout or xxxx_dout
  fifo_dout_format = '([^ ]*[^_])_+dout'
  fifo_din_format = '([^ ]*[^_])_+din'
  def __init__(self):
    self.rpt_path = None
    self.hls_sche_path = None
    self.top_hdl_path = None
    self.top_name = None
    self.DDR_loc = None
    self.DDR_loc_2d_x = None
    self.DDR_loc_2d_y = None
    self.DDR_enable = None
    self.max_usage_ratio = None
    self.max_usage_ratio_2d = None
    self.SLR_CNT = None
    self.column = None
    self.SLR_AREA = None   
    self.board_name = None
    self.coorinate_expansion_ratio = 2
    self.max_width_threshold = 10000
    self.NUM_PER_SLR_HORIZONTAL = 4
    self.horizontal_cross_weight = 0.7
    self.target_dir = None

  def init_dataflow(
      self,
      rpt_path,
      hls_sche_path,
      top_hdl_path,
      top_name,
      DDR_loc, DDR_loc_2d_x, DDR_loc_2d_y, DDR_enable,
      max_usage_ratio,
      max_usage_ratio_2d,
      SLR_CNT,
      column,
      SLR_AREA,
      board_name,
      coorinate_expansion_ratio,
      max_width_threshold,
      NUM_PER_SLR_HORIZONTAL,
      horizontal_cross_weight,
      target_dir):
    self.rpt_path = rpt_path
    self.hls_sche_path = hls_sche_path
    self.top_hdl_path = top_hdl_path
    self.top_name = top_name
    self.DDR_loc = DDR_loc
    self.DDR_loc_2d_x = DDR_loc_2d_x
    self.DDR_loc_2d_y = DDR_loc_2d_y
    self.DDR_enable = DDR_enable
    self.max_usage_ratio = max_usage_ratio
    self.max_usage_ratio_2d = max_usage_ratio_2d
    self.SLR_CNT = SLR_CNT
    self.column = column
    self.SLR_AREA = SLR_AREA   
    self.board_name = board_name
    self.coorinate_expansion_ratio = coorinate_expansion_ratio
    self.max_width_threshold = max_width_threshold
    self.NUM_PER_SLR_HORIZONTAL = NUM_PER_SLR_HORIZONTAL
    self.target_dir = target_dir
  
  # for non-dataflow use
  def init_taskbased(
      self,
      DDR_loc_2d_x, DDR_loc_2d_y,
      max_usage_ratio_2d,
      SLR_CNT,
      column,
      SLR_AREA,
      board_name,
      coorinate_expansion_ratio,
      max_width_threshold,
      NUM_PER_SLR_HORIZONTAL):
    self.rpt_path = None
    self.hls_sche_path = None
    self.top_hdl_path = None
    self.top_name = None
    self.DDR_loc = None
    self.DDR_loc_2d_x = DDR_loc_2d_x
    self.DDR_loc_2d_y = DDR_loc_2d_y
    self.max_usage_ratio = None
    self.max_usage_ratio_2d = max_usage_ratio_2d
    self.SLR_CNT = SLR_CNT
    self.column = column
    self.SLR_AREA = SLR_AREA   
    self.board_name = board_name
    self.coorinate_expansion_ratio = coorinate_expansion_ratio
    self.max_width_threshold = max_width_threshold
    self.NUM_PER_SLR_HORIZONTAL = NUM_PER_SLR_HORIZONTAL
    
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