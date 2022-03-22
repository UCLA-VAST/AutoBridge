from typing import Dict, List

from autobridge.Opt.DataflowGraph import Vertex, Edge
from autobridge.Opt.GlobalRouting import GlobalRouting
from autobridge.Opt.Slot import Slot
from autobridge.Opt.Floorplan import Floorplanner
from autobridge.Device.DeviceManager import DeviceBase

VITIS_HIERARCHY_ADDRESS = 'pfm_top_i/dynamic_region/.*/inst'


def get_used_slots(floorplan, global_router) -> List[Slot]:
  """
  (1) at least one vertex is assigned
  or (2) at least one pipeline registers is assigned 
  """
  vertex_slot = list(floorplan.getSlotToVertices().keys())
  
  pipeline_reg_slot = []
  for e_list in floorplan.getSlotToEdges().values():
    for e in e_list:
      if e.pipeline_level == 0:
        continue

      pipeline_reg_slot += global_router.e_name2path[e.name]  # exclude src and dst

  all_slot_list = list(set(vertex_slot + pipeline_reg_slot))

  return all_slot_list
  

def create_pblocks(slot_list: List[Slot], board: DeviceBase) -> List[str]:
  tcl = []
  for slot in slot_list:
    tcl += board.getSlotPblockTcl(slot)
    
  return tcl


def gen_constraints_for_vertices(s2v: Dict[Slot, List[Vertex]]) -> List[str]:
  tcl = []
  for slot, v_list in s2v.items():
    assert v_list
    tcl.append(f'add_cells_to_pblock {slot.getRTLModuleName()} [ get_cells -regexp {{ ')
    for v in v_list:
      tcl.append(f'  {VITIS_HIERARCHY_ADDRESS}/{v.name}')
    tcl.append(f'}} ]')

  return tcl


def gen_constraints_for_almost_full_fifos(s2e: Dict[Slot, List[Edge]]) -> List[str]:
  tcl = []
  for slot, e_list in s2e.items():
    almost_full_fifo_edges = [e for e in e_list if e.pipeline_level == 0]
    if almost_full_fifo_edges:
      tcl.append(f'add_cells_to_pblock {slot.getRTLModuleName()} [ get_cells -regexp {{ ')
      for e in almost_full_fifo_edges:
        tcl.append(f'  {VITIS_HIERARCHY_ADDRESS}/{e.name}')
      tcl.append(f'}} ]')

  return tcl


def gen_constraints_for_relay_stations(
    s2e: Dict[Slot, List[Edge]],
    v2s: Dict[Vertex, Slot],
    global_router: GlobalRouting,
) -> List[str]:
  """
  assign each pipeline stage of the relay station to one slot
  """
  tcl = []
  for e_list in s2e.values():
    for e in e_list:
      if e.pipeline_level == 0:
        continue

      slot_path = global_router.e_name2path[e.name]  # exclude src and dst
      slot_path_with_src_and_dst = [ v2s[e.src], *slot_path, v2s[e.dst] ]

      slot_crossing_num = len(slot_path) + 1
      assert e.pipeline_level == slot_crossing_num * 2, 'check if the pipeline policy has changed'

      for i in range(slot_crossing_num):
        tcl.append(f'add_cells_to_pblock {slot_path_with_src_and_dst[i].getRTLModuleName()} [get_cells -regexp {{ {VITIS_HIERARCHY_ADDRESS}/{e.name}/inst.*{2*i}.*unit }}]')
        tcl.append(f'add_cells_to_pblock {slot_path_with_src_and_dst[i+1].getRTLModuleName()} [get_cells -regexp {{ {VITIS_HIERARCHY_ADDRESS}/{e.name}/inst.*{2*i+1}.*unit }}]')

      # always constrain that the final fifo_unit is at the same slot with the dst vertex
      # should be redundant
      tcl.append(f'add_cells_to_pblock {slot_path_with_src_and_dst[-1].getRTLModuleName()} [get_cells -regexp {{ {VITIS_HIERARCHY_ADDRESS}/{e.name}/inst.*fifo_unit }}]')

  return tcl


def generate_floorplan_constraints(floorplan: Floorplanner, global_router: GlobalRouting):
  tcl = []

  tcl += ['write_checkpoint before_applying_floorplan_constriants.dcp']

  slot_list = get_used_slots(floorplan, global_router)
  
  tcl += create_pblocks(slot_list, floorplan.board)

  tcl += gen_constraints_for_vertices(floorplan.getSlotToVertices())

  tcl += gen_constraints_for_almost_full_fifos(floorplan.getSlotToEdges())

  tcl += gen_constraints_for_relay_stations(floorplan.getSlotToEdges(), floorplan.getVertexToSlot(), global_router)

  open('constraint.tcl', 'w').write('\n'.join(tcl))