#! /usr/bin/python3.6
import sys
from collections import defaultdict
from autobridge.HLSParser.vivado_hls.HLSProjectManager import HLSProjectManager
from autobridge.HLSParser.vivado_hls.TopRTLParser import TopRTLParser
from autobridge.Device.DeviceManager import DeviceManager
from autobridge.Opt.DataflowGraph import DataflowGraph
from autobridge.Opt.Floorplan import Floorplanner
from autobridge.Opt.GlobalRouting import GlobalRouting
from autobridge.Opt.SlotManager import SlotManager
from autobridge.Opt.LatencyBalancing import LatencyBalancing
from autobridge.Codegen.Codegen import generate_new_rtl_top
from autobridge.Codegen.FloorplanTclGeneration import generate_floorplan_constraints
import logging
import json
import re
import os

class Manager:

  def __init__(
      self,
      config_file_path):
    assert os.path.isfile(config_file_path)
    self.config = json.loads(open(config_file_path, 'r').read())
    self.basicSetup()
    self.loggingSetup()

    hls_prj_manager = HLSProjectManager(self.top_rtl_name, self.hls_prj_path, self.hls_solution_name)
    top_rtl_parser = TopRTLParser(hls_prj_manager.getTopRTLPath())
    graph = DataflowGraph(hls_prj_manager, top_rtl_parser)

    slot_manager = SlotManager(self.board)

    user_constraint_s2v = self.parseUserConstraints(graph, slot_manager)

    floorplan = self.runFloorplanning(graph, user_constraint_s2v, slot_manager, hls_prj_manager, top_rtl_parser)

    # grid routing of edges 
    global_router = GlobalRouting(floorplan, top_rtl_parser, slot_manager)

    # latency balancing
    rebalance = LatencyBalancing(graph, floorplan, global_router)

    generate_new_rtl_top(top_rtl_parser.top_module_ast, graph.getNameToEdgeMap(), top_rtl_parser.getTopModuleName(), floorplan)
    generate_floorplan_constraints(floorplan, global_router)
  
  def basicSetup(self):
    if "BundleToDDRMapping" in self.config:
      # reserve area for ddrs
      ddr_list = list(set(self.config["BundleToDDRMapping"].values()))
      assert len(ddr_list) == len(self.config["BundleToDDRMapping"].values())
      self.device_manager = DeviceManager(self.config["Board"], ddr_list, True)
    else:
      self.device_manager = DeviceManager(self.config["Board"], [], True)
    
    self.board = self.device_manager.getBoard()

    self.top_rtl_name = self.config["TopName"]
    self.hls_prj_path = os.path.abspath(self.config["HLSProjectPath"])
    self.hls_solution_name = self.config["HLSSolutionName"]
    if "LoggingLevel" in self.config:
      self.logging_level = self.config["LoggingLevel"]
    else:
      self.logging_level = "INFO"

    if "Target" in self.config:
      self.target = self.config["Target"]
    else:
      self.target = "hw"

  def loggingSetup(self):
    root = logging.getLogger()
    root.setLevel(logging.DEBUG)
    formatter = logging.Formatter("[%(levelname)s: %(funcName)25s() ] %(message)s")
    
    debug_file_handler = logging.FileHandler(filename='autobridge-debug.log', mode='w')
    debug_file_handler.setLevel(logging.DEBUG)
    info_file_handler = logging.FileHandler(filename='autobridge-info.log', mode='w')
    info_file_handler.setLevel(logging.INFO)
    stdout_handler = logging.StreamHandler(sys.stdout)
    stdout_handler.setLevel(logging.INFO)

    handlers = [debug_file_handler, info_file_handler, stdout_handler]
    for handler in handlers:
      handler.setFormatter(formatter)
      root.addHandler(handler)

  def parseUserConstraints(self, graph, slot_manager):
    user_constraint_s2v = defaultdict(list)
    
    def get_interface_module_name(bundle_name):
      top_name = self.config["TopName"]
      return f'{top_name}_{bundle_name}_m_axi_U'

    def get_s_axi_control_name():
      top_name = self.config["TopName"]
      return f'{top_name}_control_s_axi_U'

    # constrain the s_axi_control to SLR 0
    CONTROL_S_AXI_LOCATION = 0

    if "BundleToDDRMapping" in self.config:
      # properly constrain the interface modules
      board = self.device_manager.getBoard()
      for bundle, ddr in self.config["BundleToDDRMapping"].items():
        ddr_pblock = board.getDDRPblock(ddr)
        slot = slot_manager.createSlot(ddr_pblock)
        v_name = get_interface_module_name(bundle)
        try:
          v = graph.getVertex(v_name)
        except:
          logging.error(f'Naming convention of interface modules has changed!')
          exit(1)

        user_constraint_s2v[slot].append(v)
        logging.info(f'Constrain interface module {v_name} to {ddr_pblock}')

      # constrain the s_axi_control
      s_axi_slot = slot_manager.createSlot(board.getDDRPblock(CONTROL_S_AXI_LOCATION))
      try:
        s_axi_vertex = graph.getVertex(get_s_axi_control_name())
      except:
        logging.error(f'Naming convention of s_axi_control has changed!')
        exit(1)
      user_constraint_s2v[s_axi_slot].append(s_axi_vertex)
      logging.info(f'Constrain s_axi_control {v_name} to {board.getDDRPblock(CONTROL_S_AXI_LOCATION)}')

    if "Floorplan" in self.config:
      user_fp_json = self.config["Floorplan"]
      for region, v_name_group in user_fp_json.items():
        slot = slot_manager.createSlot(region)
        for v_name in v_name_group:
          user_constraint_s2v[slot].append(graph.getVertex(v_name))

    return user_constraint_s2v

  def runFloorplanning(
      self, 
      graph, 
      user_constraint_s2v, 
      slot_manager, 
      hls_prj_manager,
      top_rtl_parser,
      grouping_constraints=[]):

    grouping_constraints += top_rtl_parser.getStrictGroupingConstraints()
    
    floorplan = Floorplanner(
      graph, 
      user_constraint_s2v, 
      slot_manager=slot_manager, 
      total_usage=hls_prj_manager.getTotalArea(), 
      board=self.device_manager.getBoard(),
      user_max_usage_ratio=self.config['AreaUtilizationRatio'],
      grouping_constraints=grouping_constraints)
    
    if 'FloorplanMethod' in self.config:
      choice = self.config['FloorplanMethod']
      if choice == 'IterativeDivisionToFourCRs':
        floorplan.naiveFineGrainedFloorplan()
      elif choice == 'IterativeDivisionToHalfSLR':
        floorplan.coarseGrainedFloorplan()
      elif choice == 'IterativeDivisionToTwoCRs':
        floorplan.naiveTwoCRGranularityFloorplan()
      elif choice == 'EightWayDivisionToHalfSLR':
        floorplan.eightWayPartition()
      else:
        assert False, f'unsupported floorplan method: {choice}'
    else:
      floorplan.coarseGrainedFloorplan() # by default

    floorplan.printFloorplan()
    return floorplan

  def help(self):
    manual = {
      "Board" : "Choose between U250 and U280",
      "TopName" : "The name of the top-level function of the HLS design",
      "HLSProjectPath" : "Absolute path to the post-csynth HLS project",
      "HLSSolutionName" : "Name of the solution of the HLS project",
      "FloorplanMethod" : "Choose between IterativeDivisionToFourCRs and IterativeDivisionToHalfSLR",
      "AreaUtilizationRatio" : "Allowed resource usage in each slot",
      "Floorplan (optional)" : {
        "This is a comment" : "User could dictate the final location of given modules",
        "Region" : [
          "RTL module 1",
          "RTL module 2"
        ]
      },
      "LoggingLevel (optional)": "Choose between DEBUG, INFO, WARNING, CRITICAL, ERROR"
    }
    print(json.dumps(manual, indent=2))

if __name__ == "__main__":
  assert len(sys.argv) == 2, 'input the path to the configuration file'
  m = Manager(sys.argv[1])
    


