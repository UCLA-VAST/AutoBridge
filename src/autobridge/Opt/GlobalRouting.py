import logging


class GlobalRouting:
  def __init__(self, floorplan, top_rtl_parser, slot_manager):
    self.floorplan = floorplan
    self.top_rtl_parser = top_rtl_parser
    self.slot_manager = slot_manager
    self.v2s = floorplan.getVertexToSlot()
    self.s2e = floorplan.getSlotToEdges()
    self.e_name2path = {} # from edge to all slots passed

    self.naiveGlobalRouting()
    self.updateEdgePipelineLevel()

  def updateEdgePipelineLevel(self):
    """
    update the pipeline_level filed based on the routing results
    """
    for e_list in self.s2e.values():
      for e in e_list:
        slot_path = []
        src_slot = self.v2s[e.src]
        dst_slot = self.v2s[e.dst]
        slot_path = self.e_name2path[e.name]

        # 2 levels of pipelining for each slot crossing
        if src_slot == dst_slot:
          e.pipeline_level = 0
        else:
          e.pipeline_level = (len(slot_path) + 1) * 2

  def naiveGlobalRouting(self):
    """
    each edge first go in the Y direction then in the X direction
    assume all slots are of the same size and are aligned
    the slot_path exclude the src slot and the dst slot
    """
    for e_list in self.s2e.values():
      for e in e_list:
        slot_path = []
        src_slot = self.v2s[e.src]
        dst_slot = self.v2s[e.dst]
        slot_path.append(src_slot)

        curr = src_slot
        len_x = src_slot.getLenX()
        len_y = src_slot.getLenY()

        # first go in X direction
        x_diff = curr.getPositionX() - dst_slot.getPositionX()
        if x_diff:
          dir = 'LEFT' if x_diff > 0 else 'RIGHT'
          for i in range(int(abs(x_diff/len_x))):
            curr = self.slot_manager.createSlotForRouting(curr.getNeighborSlotName(dir))
            slot_path.append(curr)

        y_diff = curr.getPositionY() - dst_slot.getPositionY()
        if y_diff:
          dir = 'DOWN' if y_diff > 0 else 'UP'
          for i in range(int(abs(y_diff/len_y))):
            curr = self.slot_manager.createSlotForRouting(curr.getNeighborSlotName(dir))
            slot_path.append(curr)
        
        assert curr == dst_slot
        
        slot_path = slot_path[1:-1] # exclude the src and the dst
        logging.info(f'{e.name}: {self.v2s[e.src].getName()} -> {self.v2s[e.dst].getName()} : ' + ' '.join(s.getName() for s in slot_path))
        self.e_name2path[e.name] = slot_path
