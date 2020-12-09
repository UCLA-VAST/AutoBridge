OUTPUT_DIR=./output

# name of the top function
TOP=YOUR_TOP_NAME

# choose the target device
PLATFORM=xilinx_u250_xdma_201830_2 
#PLATFORM=xilinx_u280_xdma_201920_3 

XO=YOUR_XO_NAME

# For different approaches see UG904-vivado-implementation
STRATEGY="Default" 
#STRATEGY="EarlyBlockPlacement" 

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
  --connectivity.sp ${TOP}_1.PORT_NAME_1:DDR[0] \ # change according to your design
  --connectivity.sp ${TOP}_1.PORT_NAME_2:DDR[1] \ # change according to your design
  --connectivity.sp ${TOP}_1.PORT_NAME_3:DDR[2] \ # change according to your design
  --connectivity.sp ${TOP}_1.PORT_NAME_4:DDR[3] \ # change according to your design
  --kernel_frequency 330 \
  --vivado.prop run.impl_1.STEPS.PLACE_DESIGN.ARGS.DIRECTIVE=$STRATEGY \
  --vivado.prop run.impl_1.STEPS.OPT_DESIGN.TCL.PRE=$CONSTRAINT