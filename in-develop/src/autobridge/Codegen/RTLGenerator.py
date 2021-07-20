import os
import re
from typing import Dict


from autobridge.Codegen.relay_station_template import reg_based_relay_station_template
from autobridge.Opt.DataflowGraph import Edge


def _getModifiedLine(fifo_name: str, latency: int, edge: Edge) -> str:
    '''
    Description: 
    This is a helper function which provides a modified line to generateModifiedRTL(..)
        Example of the changes made by this function: 
        Line before modification: kernel0_fifo_w64_d2_A A_V_c_U(...
        Line after modification: relay_station #(.DATA_WIDTH(64), .ADDR_WIDTH(2), .DEPTH(2), .LEVEL(1)) A_V_c_U(...

    Arguments: 
        fifo_name -> this is the name of the fifo which is being replaced by the relay_template
        latency -> this is the latency of the edge as calculated by the latency balancing step
        edge -> this is an Edge type object as defined in Autobridge/in-develop/src/Opt/DataflowGraph.py
    '''

    new_line = f'''relay_station 
#(.DATA_WIDTH({edge.width}), 
.ADDR_WIDTH({edge.addr_width}), 
.DEPTH({edge.depth}), 
.LEVEL({latency})) 
{fifo_name}(\n'''

    return new_line


def replaceFIFOByRelayStation(input_rtl_path: str, e_name2lat: Dict[str, int], get_name_to_edge_map: Dict[str, Edge]) -> list:
    '''
    Description:
        This function takes the input RTL and updates all FIFOs to relay_templates based on the latency_balancing step
        
    Arguments:
        input_rtl_path -> this is the path of the input RTL which needs to be modified
        e_name2lat -> this is a dictionary which contains the mapping between edges and their respective latencies
        get_name_to_edge_map -> this is a dictionary which contains the mapping between the edges and their respective edge names as defined in Autobridge/in-develop/src/Opt/DataflowGraph.py
    '''

    # open and read the input RTL
    input_rtl = open(input_rtl_path, 'r')
    lines = input_rtl.readlines()
    for i in range(len(lines)):
        line = lines[i]
        # check if this is a fifo instance
        if re.search('fifo_w\d+_d\d+', line):
            # extract the fifo name
            fifo_name = re.search('(fifo_w\d+_d\d+_\w) (\w+)', line).group(2)
            # obtain the modified line (fifo -> relay_station)
            lines[i] = _getModifiedLine(fifo_name, e_name2lat[fifo_name], get_name_to_edge_map[fifo_name])

    # create a temporary directory to store the new RTL for further processing provided the directory does not exist
    if not os.path.exists('../temp'):
        os.makedirs('../temp')
    # open a new file in the temporary directory
    fifo2relay_rtl_file = open('../temp/modified_fifo2relay.v', 'w+')
    # write contents of the new RTL 
    fifo2relay_rtl_file.write(''.join(lines))
    # add the relay_station template code to the RTL
    fifo2relay_rtl_file.write(reg_based_relay_station_template)
    
    return fifo2relay_rtl_file.readlines()
