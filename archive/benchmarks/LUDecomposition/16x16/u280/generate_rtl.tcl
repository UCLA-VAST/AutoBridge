open_project kernel0
set_top kernel0
add_files "src/kernel_kernel.h"
add_files "src/kernel_kernel.cpp"
open_solution solution
set_part xcu280-fsvh2892-2L-e
create_clock -period 300.000000MHz -name default
config_dataflow -strict_mode warning
set_clock_uncertainty 27.000000%
config_rtl -enable_maxiConservative=1
config_interface -m_axi_addr64
config_sdx -target xocc
csynth_design

close_project
exit
