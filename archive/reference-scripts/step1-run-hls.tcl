open_project PROJECT_NAME
set_top TOP_FUNCTION_NAME
add_files PATH_TO_SRC_FILE
add_files -tb PATH_TO_TESTBENCH_FILE

open_solution solution

#u250
set_part xcu250-figd2104-2L-e

# u280
#set_part xcu280-fsvh2892-2L-e

# 300 MHz
create_clock -period 3.333

config_dataflow -strict_mode warning
set_clock_uncertainty 27.000000%
config_rtl -enable_maxiConservative=1
config_interface -m_axi_addr64

# to enable integration with Vitis
config_sdx -target xocc

csim_design
csynth_design
close_project
exit
