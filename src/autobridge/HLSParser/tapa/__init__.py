#!/usr/bin/python3
import collections
import json
import logging
import sys
from typing import List

import autobridge.Floorplan.Utilities as util
import autobridge.Floorplan as autobridge_floorplan
from autobridge.Device.DeviceManager import DeviceManager
from autobridge.HLSParser.tapa.DataflowGraphTapa import DataflowGraphTapa
from autobridge.HLSParser.tapa.ProgramJsonManager import ProgramJsonManager
from autobridge.Opt.Floorplan import Floorplanner
from autobridge.Opt.Slot import Topology
from autobridge.Opt.SlotManager import SlotManager

logging.basicConfig(
    level=logging.DEBUG,
    format=
    '[%(levelname)s: %(name)s:%(lineno)d] %(message)s',
    datefmt='%m%d %H:%M:%S',
)

_logger = logging.getLogger('autobridge')


def get_floorplan_output_bundle(config):
  assert config['CompiledBy'] == 'TAPA'

  board = DeviceManager(
      board_name=config['Board'],
      ddr_list=config.get('DDR', []),
      is_vitis_enabled=True,
  ).getBoard()
  program_json_manager = ProgramJsonManager(
      config['Edges'],
      config['Vertices'],
      config['Area'],
  )
  graph = DataflowGraphTapa(program_json_manager)
  slot_manager = SlotManager(board)

  # which modules must be assigned to the same slot
  grouping_constraints: List[List[str]] = config.get('GroupingConstraints', [])

  # process optional module pre-assignment constraints
  module_floorplan = config['OptionalFloorplan']
  pre_assignment = {}
  for region, module_group in module_floorplan.items():
    for mod_name in module_group:
      pre_assignment[mod_name] = region

  kwargs = {}
  ref_usage_ratio = config.get('MaxUsage')
  if ref_usage_ratio is not None:
    kwargs['ref_usage_ratio'] = ref_usage_ratio

  # generate floorplan
  v2s = autobridge_floorplan.get_floorplan(graph, slot_manager, grouping_constraints, pre_assignment, **kwargs)

  s2v = util.invert_v2s(v2s)
  topology = Topology(s2v)

  return v2s, s2v, topology

def generate_constraints(config):
  """ [obsolete] """
  v2s, s2v, topology = get_floorplan_output_bundle(config)
  return {
      slot.pblock_name:
      [v.name for v in v_group] + [topology.getTopologyOf(slot)]
      for slot, v_group in s2v.items()
  }

def generate_constraints_bundle(config):
  v2s, s2v, topology = get_floorplan_output_bundle(config)
  v_name_to_s_name = {v.name: s.pblock_name for v, s in v2s.items()}
  s_name_to_v_name = {s.pblock_name: [v.name for v in v_list] for s, v_list in s2v.items()}
  topology = {slot.pblock_name: topology.getTopologyOf(slot) for slot in s2v.keys()}
  return v_name_to_s_name, s_name_to_v_name, topology



def main():
  fp = sys.stdin
  if fp.isatty():
    fp = open('SampleUserConfig.json', 'r')
  constraints = generate_constraints(json.load(fp))

  fp = sys.stdout
  if fp.isatty():
    fp = open('TapaConstraint.json', 'w')
  json.dump(constraints, fp, indent=2)


if __name__ == '__main__':
  main()
