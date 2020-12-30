#! /usr/bin/python3.6

from collections import defaultdict
import re
import pyverilog.vparser.ast as ast

class U250_old:
  SLR_CNT = 4
  SLR_AREA = {}
  SLR_AREA['BRAM'] = 1344
  SLR_AREA['DSP'] = 3072
  SLR_AREA['FF'] = 864000
  SLR_AREA['LUT'] = 432000

class U280_old:
  SLR_CNT = 3
  SLR_AREA = {}
  SLR_AREA['BRAM'] = 1344
  SLR_AREA['DSP'] = 3008
  SLR_AREA['FF'] = 869120
  SLR_AREA['LUT'] = 434560

class U250:
  SLR_CNT = 4
  SLR_AREA = defaultdict(lambda: defaultdict(list))
  SLR_AREA['BRAM'][0] = 768
  SLR_AREA['DSP'][0] = 1536
  SLR_AREA['FF'][0] = 433920
  SLR_AREA['LUT'][0] = 216960

  SLR_AREA['BRAM'][1] = 384
  SLR_AREA['DSP'][1] = 1344
  SLR_AREA['FF'][1] = 329280
  SLR_AREA['LUT'][1] = 164640

  SLR_AREA_DDR = defaultdict(lambda: defaultdict(list))
  SLR_AREA_DDR['BRAM'][0] = 768
  SLR_AREA_DDR['DSP'][0] = 1536
  SLR_AREA_DDR['FF'][0] = 433920
  SLR_AREA_DDR['LUT'][0] = 216960

  SLR_AREA_DDR['BRAM'][1] = 288
  SLR_AREA_DDR['DSP'][1] = 1152
  SLR_AREA_DDR['FF'][1] = 245760
  SLR_AREA_DDR['LUT'][1] = 122800

class U280:
  SLR_CNT = 3
  SLR_AREA = defaultdict(lambda: defaultdict(list))
  SLR_AREA['BRAM'][0] = 768
  SLR_AREA['DSP'][0] = 1536
  SLR_AREA['FF'][0] = 433920
  SLR_AREA['LUT'][0] = 216960  
  
  SLR_AREA['BRAM'][1] = 384
  SLR_AREA['DSP'][1] = 1344
  SLR_AREA['FF'][1] = 330240
  SLR_AREA['LUT'][1] = 165120  

class test:
  SLR_CNT = 1
  SLR_AREA = defaultdict(lambda: defaultdict(list))
  SLR_AREA['BRAM'][0] = 768*4
  SLR_AREA['DSP'][0] = 1536*4
  SLR_AREA['FF'][0] = 433920*4
  SLR_AREA['LUT'][0] = 216960*4

  SLR_AREA['BRAM'][1] = 384*4
  SLR_AREA['DSP'][1] = 1344*4
  SLR_AREA['FF'][1] = 433920*4
  SLR_AREA['LUT'][1] = 165120*4

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
      board_name,
      coorinate_expansion_ratio=2,
      max_width_threshold=10000,
      NUM_PER_SLR_HORIZONTAL=4,
      horizontal_cross_weight=0.7,
      target_dir = './autobridge',
      relay_station_count = lambda x : 2 * x,
      relay_station_template = 'reg',
      constraint_edge = True,
      constraint_marked_edge = True,
      only_keep_rs_hierarchy = False,
      max_search_time = 600,
      NaiveBalance = False,
      AssignAxiSubSLR = False,
      max_usage_ratio_delta = 0.03,
      eight_way_partition = False):
    self.rpt_path = rpt_path
    self.hls_sche_path = hls_sche_path
    self.top_hdl_path = top_hdl_path
    self.top_name = top_name
    self.DDR_loc_2d_x = DDR_loc_2d_x
    self.DDR_loc_2d_y = DDR_loc_2d_y
    self.DDR_enable = DDR_enable
    self.max_usage_ratio_2d = max_usage_ratio_2d
    
    if board_name == 'u250':
      self.column = [2, 2, 2, 2]
    elif board_name == 'u280':
      self.column = [2, 2, 2]
    else:
      assert False, 'unsupported board'

    self.board_name = board_name
    self.eight_way_partition = eight_way_partition
    
    # [obsolete]
    self.coorinate_expansion_ratio = coorinate_expansion_ratio
    
    # maximum allowed SLR crossing
    self.max_width_threshold = max_width_threshold
    
    # how many rows (vertical height) are there in one SLR
    self.NUM_PER_SLR_HORIZONTAL = NUM_PER_SLR_HORIZONTAL
    
    # whether to treat horizontal crossing with less penalty
    self.horizontal_cross_weight = horizontal_cross_weight
    
    self.target_dir = target_dir

    # for each crossing, how many relay stations to allocate
    self.relay_station_count = relay_station_count

    # different implementations of relay station available
    self.relay_station_template = relay_station_template

    # [obsolete] whether to generate floorplan constraint for non-relay-station edges
    self.constraint_edge = constraint_edge

    # [obsolete] whether to generate floorplan constraint for relay station edges
    self.constraint_marked_edge = constraint_marked_edge

    # [obsolete] only add "keep_hierarchy" pragma to relay stations
    self.only_keep_rs_hierarchy = only_keep_rs_hierarchy

    self.max_search_time = max_search_time

    # only utilize the dataflow-process-level topology. Do not analyze the internal FSM
    self.NaiveBalance = NaiveBalance

    # whether to generate sub-slr level floorplan constraints for AXI related modules
    self.AssignAxiSubSLR = AssignAxiSubSLR

    # in iterative divide and conquer, if a region is packed too full, there is the possibility that a further divide is infeasible as a function could not be split apart
    # thus we allow some increase in the max_usage_ratio to accommodate the situation
    self.max_usage_ratio_delta = max_usage_ratio_delta 

    if (board_name == 'u250'):
      self.SLR_CNT = U250.SLR_CNT
      self.SLR_AREA = U250.SLR_AREA

      self.SLR_AREA = defaultdict(lambda: defaultdict(dict))
      for item in ['BRAM', 'DSP', 'FF', 'LUT']:
        for slr in range(len(self.column)):
          for sub_slr in range(2):
            if (self.DDR_enable[slr] == 1):
              self.SLR_AREA[item][slr][sub_slr] = U250.SLR_AREA_DDR[item][sub_slr]
            else:
              self.SLR_AREA[item][slr][sub_slr] = U250.SLR_AREA[item][sub_slr]

    elif (board_name == 'u280'):
      self.SLR_CNT = U280.SLR_CNT
      self.SLR_AREA = defaultdict(lambda: defaultdict(dict))
      for item in ['BRAM', 'DSP', 'FF', 'LUT']:
        for slr in range(len(self.column)):
          for sub_slr in range(2):
            self.SLR_AREA[item][slr][sub_slr] = U250.SLR_AREA[item][sub_slr]

    elif (board_name == 'test'):
      self.SLR_CNT = test.SLR_CNT
      self.SLR_AREA = test.SLR_AREA 
    else:
      print(f'unsupported board name: {board_name}')
      exit()
         
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
    
    if (mod_type == 'async_mmap'):
      width_acc = 0 # for async_mmap, we need to count both data width and addr width
      for paramarg in node.parameterlist:
        formal = paramarg.paramname
        actual = paramarg.argname.value

        if ( formal == 'DataWidth' or formal == 'AddrWidth'):
          width_acc += 2 * int(actual) # from and to
      
      assert(width_acc != 0)
      return width_acc  

    if ('fifo' in mod_type and node.parameterlist): # for TLP
      width_acc = 0 # for async_mmap, we need to count both data width and addr width
      for paramarg in node.parameterlist:
        formal = paramarg.paramname
        actual = paramarg.argname.value
      
        if( formal == 'DATA_WIDTH'): 
          return int(actual)

    else: # for HLS
      match = re.search('_w(\d+)_d(\d+)_', mod_type)
      if (match):
        return int(match.group(1)) # group 1
      
    print('FIFO width error')

  def extractFIFODepth(self, node):
    mod_type = node.module
    if (mod_type == 'async_mmap'):
      return 64
    
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
    return isinstance(node, ast.Instance) and 'start_for' not in node.name #and '_axi' not in node.name
  
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
    return  'fifo' in node.module or \
            'relay_station' in node.module

  def isAsyncMmap(self, node):
    return 'async_mmap' in node.module


