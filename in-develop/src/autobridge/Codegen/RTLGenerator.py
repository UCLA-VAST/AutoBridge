import re
from typing import Dict


from autobridge.Opt.DataflowGraph import Edge


def _getModifiedLine(edge_name: str, latency: int, line: str, edge: Edge) -> str:
    ''' 
    This is a helper function which provides the modified line to generateModifiedRTL(..)
    Arguments: 
    edge_name -> this is the name of the edge for which FIFO is being replaced by the relay_template
    latency -> this is the latency of the edge as calculated by the latency balancing step
    line -> this is the original line from the input RTL which needs to be updated
    edge -> this is an Edge type object as defined in Autobridge/in-develop/src/Opt/DataflowGraph.py
    '''
    # line_retain is the portion of the line which should be retained from the original RTL
    line_retain = line.split(' ')[1]
    new_line = f'''
    relay_station #(.DATA_WIDTH({edge.width}),
    .ADDR_WIDTH({edge.addr_width}),
    .DEPTH({edge.depth}),
    .LEVEL({latency}))
    {line_retain}'''
    return new_line


def replaceFIFOByRelayStation(input_rtl_path: str, e_name2lat: Dict[str, int], get_name_to_edge_map: Dict[str, Edge]) -> None:
    '''
    This function takes the input RTL and updates all FIFOs to relay_templates based on the latency_balancing step
    Arguments:
    input_rtl_path -> this is the path of the input RTL which needs to be modified
    e_name2lat -> this is a dictionary which contains the mapping between edges and their respective latencies
    get_name_to_edge_map -> this is a dictionary which contains the mapping between the edges and their respective edge names as defined in Autobridge/in-develop/src/Opt/DataflowGraph.py
    '''
    input_rtl = open(input_rtl_path, 'r')
    lines = input_rtl.readlines()
    for i in range(len(lines)):
        line = lines[i]
        # check if the line has a fifo instance ie. it has the form fifo_w{int}_d{int}_*
        if re.search('fifo_w\d+_d\d+', line):
            # this is a fifo instance
            # extract the name of the fifo
            fifo_name = line.split(' ')[1][:-2]
            lines[i] = _getModifiedLine(fifo_name, e_name2lat[fifo_name], line, get_name_to_edge_map[fifo_name])
    # write lines to the new rtl file
    open('../temp/modified_fifo2relay.v', 'w+').write('\n'.join(lines))
