#!/usr/bin/python3
import collections
import json
import logging
import sys

from autobridge.Device.DeviceManager import DeviceManager
from autobridge.HLSParser.tapa.DataflowGraphTapa import DataflowGraphTapa
from autobridge.HLSParser.tapa.ProgramJsonManager import ProgramJsonManager
from autobridge.Opt.Floorplan import Floorplanner
from autobridge.Opt.Slot import Topology
from autobridge.Opt.SlotManager import SlotManager

logging.basicConfig(
    level=logging.DEBUG,
    format=
    '%(levelname).1s%(asctime)s.%(msecs)03d %(name)s:%(lineno)d] %(message)s',
    datefmt='%m%d %H:%M:%S',
)

_logger = logging.getLogger().getChild(__name__)


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
  # floorplan.coarseGrainedFloorplan()

  if _logger.isEnabledFor(logging.INFO):
    floorplan.printFloorplan()

  # generate topology
  s2v = floorplan.getSlotToVertices()
  topology = Topology(s2v)
  return {
      slot.pblock_name:
      [v.name for v in v_group] + [topology.getTopologyOf(slot)]
      for slot, v_group in s2v.items()
  }


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
