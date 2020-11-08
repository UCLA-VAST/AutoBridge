# Requirement

- Python 3.6+
- Pyverilog
```
pip install pyverilog
```

- Python mip version 1.8.1
- It is highly recommended that the user install the Gurobi solver, which is free to academia. For designs with a large number of functions and connections, Gurobi is significantly faster than the open-sourced solvers. `https://www.gurobi.com/academia/academic-program-and-licenses/`


- Xilinx Vivado HLS 2019.2
- Xilinx Vitis 2019.2
- Xilinx Alveo Accelerator Card U250, U280

# Issues

[issue] should use mip version 1.8.1

[issue] Sometimes the mip package complains that "multiprocessing" cannot be found, but running it the second time things will work out

[issue] in the divide-and-conquer approach, if a region is packed close to the max_usage_ratio, then it's possible that the next split will fail because a function is atomic and cannot be split into two sub regions. The current work-around is to increase the max_usage_ratio a little

[issue] Function names in the HLS program should not contain "fifo" or "FIFO"

# Introduction

Despite an increasing adoption of high-level synthesis (HLS) for its design productivity advantages, there remains a significant gap in  the achievable clock frequency between an HLS-generated design and an optimized handcrafted RTL. In particular, the difficulty in accurately estimating the interconnect delay at the HLS level is a key factor that limits the timing quality of the HLS outputs. Unfortunately, this problem becomes even worse when large HLS designs are implemented on the latest multi-die FPGAs, where die-crossing interconnects incur a high delay penalty.

To tackle this challenge, we propose `AutoBridge`, an automated framework that couples a `coarse-grained floorplanning` step with `pipelining` during HLS compilation. 
- First, our approach provides HLS with a view on the global physical layout of the design; this allows HLS to more easily identify and pipeline the long wires, especially those crossing the die boundaries. 
- Second, by exploiting the flexibility of HLS pipelining, the  floorplanner is able to distribute the design logic across multiple dies on the FPGA device without degrading clock frequency; this avoids the aggressive logic packing on a single die, which often results in local routing contention that eventually degrades timing. 
- Since pipelining may introduce additional latency, we further present analysis and algorithms to ensure the added latency will not hurt the overall throughput. 

Currently, AutoBridge can be seamlessly integrated into the existing CAD toolflow for Xilinx FPGAs to achieve significant frequency improvement.

# Usage

Currently AutoBridge supports two FPGA devices: the Alveo U250 and the Alveo U280. The users could customize the tool to support other FPGA boards as well.

## Inputs

To use the tool, the user needs to provide the following information:

`project_path`: Directory of the HLS project. 

`top_name`: The name of the top-level function of the HLS design

`DDR_enable`: A vector representing which DDR controllers the design will connect to. In U250 and U280, each SLR of the FPGA contains the IO bank for one DDR controller that can be instantiated. For example, 
```python
DDR_enable = [1, 0, 0, 1]
``` 
means that there are four SLRs (U250) and the DDR controller on the SLR 0 and SLR 3 (the bottom one is the 0-th) are instantiated while the SLR 1 and SLR 2 are not instantiated. This parameter will affect the floorplanning step, as we must not use the area preserved for DDR controllers.

`DDR_loc_2d_y`: A dictionary recording the y-dim location of user-specified modules. For each IO module (which will directly connect to peripheral IPs such as DMA or DDR controller) in the design, the user must explicity tell the tool which region this module should be placed, according to the location of the target peripheral IPs (which usually have fixed locations). For example, 
```python
DDR_loc_2d_y['B_IO_L3_in_wrapper_U0'] = 1
```  
means that the module (HLS function) **B_IO_L3_in_wrapper_U0** must be placed in the 1-st SLR of the FPGA.

`DDR_loc_2d_x`: A dictionary recording the x-dim location of user-specified modules. By default we split each SLR by half. For example, 
```python
DDR_loc_2d_x['B_IO_L3_in_wrapper_U0'] = 1
```  
means that the module (HLS function) must be placed in the right half (1 for the right half and 0 for the left half) of the FPGA.

`max_usage_ratio_2d`: A 2-dimensional vector specifying the maximum resource utilization ratio for each region. For example, 
```python
max_usage_ratio_2d = [ [0.85, 0.6], [0.85, 0.6], [0.85, 0.85], [0.85, 0.6] ]
```
means that there are 8 regions in total (2x4), and at most 85% of the available resource on the left half of SLR 0 can be used, 60% of the right half of SLR 0 can be used, 85% of either the right and the left half of SLR 2 can be used, etc.

## Outputs

The tool will produce:

- A new RTL file corresponding to the top HLS function that has been additionally pipelined based on the floorplanning results. 

- A `tcl` script containing the floorplanning information.

To use the results, we first pack the new RTL files into an `xo` object, then invoke the `v++` tool from Xilinx Vitis (`https://www.xilinx.com/html_docs/xilinx2020_1/vitis_doc/vitiscommandcompiler.html`). 

An example script is:

```bash
OUTPUT_DIR=./output
TOP=kernel_top # name of the top function
PLATFORM=xilinx_u250_xdma_201830_2 # or xilinx_u280_xdma_201920_3 for U280
XO="polysa.xo"
STRATEGY="Default" # Another commonly used strategy is EarlyBlockPlacement. See UG904-vivado-implementation
output_dir="$(pwd)/vitis_run"

v++ \
  --link \
  --output "${output_dir}/${TOP}_${PLATFORM}.xclbin" \
  --kernel ${TOP} \
  --platform ${PLATFORM} \
  --target hw \
  --report_level 2 \
  --temp_dir "${output_dir}/${TOP}_${PLATFORM}.temp" \
  --optimize 3 \
  --connectivity.nk ${TOP}:1:${TOP}_1 \
  --max_memory_ports ${TOP} \
  --save-temps \
  ${XO} \
  --connectivity.sp ${TOP}_1.A:DDR[0] \
  --connectivity.sp ${TOP}_1.B:DDR[1] \
  --connectivity.sp ${TOP}_1.C:DDR[3] \
  --kernel_frequency 330 \
  --vivado.prop run.impl_1.STEPS.PLACE_DESIGN.ARGS.DIRECTIVE=$STRATEGY \
  --vivado.prop run.impl_1.STEPS.OPT_DESIGN.TCL.PRE=$CONSTRAINT
```