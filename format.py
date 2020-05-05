#! /usr/bin/python3.6

import collections
import re

print('import Format module')

class Format:
  # either xxxx__dout or xxxx_dout
  fifo_dout_format = '([^ ]*[^_])_+dout'
  fifo_din_format = '([^ ]*[^_])_+din'
  fifo_width_format = 'DATA_WIDTH'

  def __init__(self, tlp_path:str, top_name:str):
    # specific to the TLP compiler
    self.rpt_path = f'{tlp_path}/report'
    self.hls_sche_path = f'{tlp_path}/report'
    self.rtl_path = f'{tlp_path}/hdl'
    self.fifo_type = ['fifo', 'relay_station']

    # Control_Control.v
    # use list according to the api of pyverilog
    self.top_rtl_path = [f'{self.rtl_path}/{top_name}_{top_name}.v']

    # TODO: automatically parse the location from the .cfg file
    self.DDR_loc = collections.defaultdict(dict)
    self.DDR_loc['UpdateMem_0'] = 0
    self.DDR_loc['UpdateMem_1'] = 0
    self.DDR_loc['UpdateMem_2'] = 0
    self.DDR_loc['UpdateMem_3'] = 0
    self.DDR_loc['UpdateMem_4'] = 0
    self.DDR_loc['UpdateMem_5'] = 0
    self.DDR_loc['UpdateMem_6'] = 0
    self.DDR_loc['UpdateMem_7'] = 0
    self.DDR_loc['EdgeMem_0'] = 0
    self.DDR_loc['EdgeMem_1'] = 0
    self.DDR_loc['EdgeMem_2'] = 0
    self.DDR_loc['EdgeMem_3'] = 0
    self.DDR_loc['EdgeMem_4'] = 0
    self.DDR_loc['EdgeMem_5'] = 0
    self.DDR_loc['EdgeMem_6'] = 0
    self.DDR_loc['EdgeMem_7'] = 0
    self.DDR_loc['VertexMem_0'] = 0
    self.DDR_loc['PageRank_control_s_axi_U'] = 0
    self.DDR_loc['edges_0__m_axi'] = 0
    self.DDR_loc['edges_1__m_axi'] = 0
    self.DDR_loc['edges_2__m_axi'] = 0
    self.DDR_loc['edges_3__m_axi'] = 0
    self.DDR_loc['edges_4__m_axi'] = 0
    self.DDR_loc['edges_5__m_axi'] = 0
    self.DDR_loc['edges_6__m_axi'] = 0
    self.DDR_loc['edges_7__m_axi'] = 0
    self.DDR_loc['updates_0__m_axi'] = 0
    self.DDR_loc['updates_1__m_axi'] = 0
    self.DDR_loc['updates_2__m_axi'] = 0
    self.DDR_loc['updates_3__m_axi'] = 0
    self.DDR_loc['updates_4__m_axi'] = 0
    self.DDR_loc['updates_5__m_axi'] = 0
    self.DDR_loc['updates_6__m_axi'] = 0
    self.DDR_loc['updates_7__m_axi'] = 0
    self.DDR_loc['degrees__m_axi'] = 0
    self.DDR_loc['rankings__m_axi'] = 0
    self.DDR_loc['tmps__m_axi'] = 0

  def getScheFile(self, mod_type:str):
    # Control_Control.v -> Control.verbose.sched.rpt
    filter = ['s_axi', 'm_axi', 'async_mmap']
    if( any(w in mod_type for w in filter)):
      return ''

    former = mod_type[:int(len(mod_type)/2)]
    latter = mod_type[int(len(mod_type)/2)+1:]
    # print(former, latter)
    assert(former == latter)
    return f'{self.hls_sche_path}/{former}.verbose.sched.rpt'

  def getRptFile(self, mod_name:str):
    # module name : Control_0 -> rpt name: Control_csynth.rpt
    if (re.search('_\d+[ ]*$', mod_name)):
      mod_name = re.sub('_\d+[ ]*$', '', mod_name)
    return f'{self.rpt_path}/{mod_name}_csynth.rpt'

  def extractFIFOFromRaw(self, name_raw:str):
    if ('_dout' in name_raw):
      return re.search(Format.fifo_dout_format, name_raw).group(1)
    elif ('_din' in name_raw):
      return re.search(Format.fifo_din_format, name_raw).group(1)
    else:
      return None    

  # def isFIFOPortPair(self, formal:str, actual:str):
  #   if ('_dout' in formal and '_dout' in actual):
  #     return true
  #   elif ('_din' in formal and '_din' in actual):
  #     return true
  #   else:
  #     return false