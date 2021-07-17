''' 
modify is a helper function for generator(...) which provides the updated line
Arguments: 
    edge_name -> this is the name of the edge for which FIFO is being replaced by the relay_template
    latency -> this is the latency of the edge as calculated by the latency balancing step
    line -> this is the original line from the input RTL which needs to be updated
    edge -> this is an Edge type object as defined in Autobridge/in-develop/src/Opt/DataflowGraph.py
    
'''
def modify(edge_name: str, latency: int, line: str, edge) -> str:
    data_width = str(edge.width)
    depth = str(edge.depth)
    addr_width = str(edge.addr_width)
    latency = str(latency)
    line_components = line.split(" ")
    new_line = "relay_station #(.DATA_WIDTH(%s), .ADDR_WIDTH(%s), .DEPTH(%s), LEVEL(%s), %s" %(data_width, depth, latency, line_components[1])
    return new_line

''' 
generator function takes the input RTL and updates all FIFOs to relay_templates based on the latency_balancing step
Arguments:
    input_rtl_path -> this is the path of the input RTL which needs to be modified
    e_name2lat -> this is a dictionary which contains the mapping between edges and their respective latencies
    NameToEdgeMap -> this is a dictionary which contains the mapping between the edges and their respective edge names as defined in Autobridge/in-develop/src/Opt/DataflowGraph.py

'''
def generator(input_rtl_path: str, e_name2lat: dict, NameToEdgeMap: dict) -> None:
    new_rtl = open("new.v", "w+")
    input_rtl = open(input_rtl_path, "r")
    lines = input_rtl.readlines()
    for i in range(len(lines)):
        line = lines[i]
        if 'kernel0' in line:
            if '#' not in line:
                edge_name = line.split(" ")[0]
                logging.info(edge_name)
                logging.info(i)
                lines[i] = modify(edge_name, e_name2lat[edge_name], line, NameToEdgeMap[edge_name])
    for line in lines:
        new_rtl.write(line)
