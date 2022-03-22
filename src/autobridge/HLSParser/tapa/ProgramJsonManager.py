import collections


class ProgramJsonManager:

  def __init__(self, fifo_section, v_name_to_v_module, v_module_to_area):
    self.fifo_section = fifo_section
    self.v_name_to_v_module = v_name_to_v_module
    self.v_module_to_area = v_module_to_area
    self.vertex_total_area = collections.defaultdict(int)
    for v_name, v_module in self.v_name_to_v_module.items():
      for item, count in self.v_module_to_area[v_module].items():
        self.vertex_total_area[item] += count

  def getFIFOSection(self):
    return self.fifo_section

  def getVNameToModule(self):
    return self.v_name_to_v_module

  def getAreaOfModule(self, v_module):
    return self.v_module_to_area[v_module]

  def getVertexTotalArea(self):
    return self.vertex_total_area
