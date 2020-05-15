#! /usr/bin/python3.6

import collections
import re
import pyverilog.vparser.ast as ast

class U250:
  SLR_CNT = 4
  SLR_AREA = {}
  SLR_AREA['BRAM'] = 1344
  SLR_AREA['DSP'] = 3072
  SLR_AREA['FF'] = 864000
  SLR_AREA['LUT'] = 432000

class U280:
  SLR_CNT = 3
  SLR_AREA = {}
  SLR_AREA['BRAM'] = 1344
  SLR_AREA['DSP'] = 3008
  SLR_AREA['FF'] = 869120
  SLR_AREA['LUT'] = 434560

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
      DDR_loc_2d_x, 
      DDR_loc_2d_y, 
      DDR_enable,
      max_usage_ratio_2d,
      column,
      board_name,
      coorinate_expansion_ratio,
      max_width_threshold,
      NUM_PER_SLR_HORIZONTAL,
      horizontal_cross_weight,
      target_dir,
      relay_station_count,
      relay_station_template,
      constraint_edge,
      constraint_marked_edge):
    self.rpt_path = rpt_path
    self.hls_sche_path = hls_sche_path
    self.top_hdl_path = top_hdl_path
    self.top_name = top_name
    self.DDR_loc_2d_x = DDR_loc_2d_x
    self.DDR_loc_2d_y = DDR_loc_2d_y
    self.DDR_enable = DDR_enable
    self.max_usage_ratio_2d = max_usage_ratio_2d
    self.column = column
    self.board_name = board_name
    self.coorinate_expansion_ratio = coorinate_expansion_ratio
    self.max_width_threshold = max_width_threshold
    self.NUM_PER_SLR_HORIZONTAL = NUM_PER_SLR_HORIZONTAL
    self.horizontal_cross_weight = horizontal_cross_weight
    self.target_dir = target_dir
    self.relay_station_count = relay_station_count
    self.relay_station_template = relay_station_template
    self.constraint_edge = constraint_edge
    self.constraint_marked_edge = constraint_marked_edge

    if (board_name == 'u250'):
      self.SLR_CNT = U250.SLR_CNT
      self.SLR_AREA = U250.SLR_AREA
    elif (board_name == 'u280'):
      self.SLR_CNT = U280.SLR_CNT
      self.SLR_AREA = U280.SLR_AREA
    
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

  def isInstanceList(self, node):
    return isinstance(node, ast.InstanceList)

class FormatTLP(FormatHLS):

  fifo_type = ['fifo', 'relay_station']

  # Control_Control.v -> Control.verbose.sched.rpt
  def getScheFile(self, mod_type:str):
    filter = ['s_axi', 'm_axi', 'async_mmap']
    if( any(w in mod_type for w in filter)):
      return ''

    former = mod_type[:int(len(mod_type)/2)]
    latter = mod_type[int(len(mod_type)/2)+1:]
    # print(former, latter)
    assert(former == latter)
    return f'{self.hls_sche_path}/{former}.verbose.sched.rpt'
    
  # module name : Control_0 -> rpt name: Control_csynth.rpt
  def getRptFile(self, v):
    mod_name = v.name
    if (re.search('_\d+[ ]*$', mod_name)):
      mod_name = re.sub('_\d+[ ]*$', '', mod_name)
    return f'{self.rpt_path}/{mod_name}_csynth.rpt'
    
  def isFIFO(self, node):
    return 'fifo' in node.module or 'relay_station' in node.module





