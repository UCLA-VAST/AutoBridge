#!/usr/bin/python3
import collections
import json
import logging

from autobridge.Device.DeviceManager import DeviceManager
from autobridge.HLSParser.tapa.DataflowGraphTapa import DataflowGraphTapa
from autobridge.HLSParser.tapa.ProgramJsonManager import ProgramJsonManager
from autobridge.Opt.Floorplan import Floorplanner
from autobridge.Opt.Slot import Topology
from autobridge.Opt.SlotManager import SlotManager


def generate_constraints(config):
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
  user_constraint_s2v = collections.defaultdict(list)

  # process optional module constraints
  module_floorplan = config['OptionalFloorplan']
  for region, module_group in module_floorplan.items():
    slot = slot_manager.createSlot(region)
    for mod_name in module_group:
      user_constraint_s2v[slot].append(graph.getVertex(mod_name))

  # generate floorplan
  kwargs = {}
  user_max_usage_ratio = config.get('MaxUsage')
  if user_max_usage_ratio is not None:
    kwargs['user_max_usage_ratio'] = user_max_usage_ratio
  floorplan = Floorplanner(
      graph,
      user_constraint_s2v,
      slot_manager=slot_manager,
      total_usage=program_json_manager.getVertexTotalArea(),
      board=board,
      **kwargs,
  )
  floorplan.eightWayPartition()

  # generate topology
  s2v = floorplan.getSlotToVertices()
  topology = Topology(s2v)
  return {
      slot.pblock_name:
      [v.name for v in v_group] + [topology.getTopologyOf(slot)]
      for slot, v_group in s2v.items()
  }


def main():
  logging.basicConfig(
      filename='auto-parallel.log',
      filemode='w',
      level=logging.DEBUG,
      format="[%(levelname)s: %(funcName)25s() ] %(message)s",
  )
  with open('SampleUserConfig.json', 'r') as fp:
    constraints = generate_constraints(json.load(fp))
  with open('TapaConstraint.json', 'w') as fp:
    json.dump(constraints, fp, indent=2)


if __name__ == '__main__':
  main()
