#!/bin/bash
src_dir=$(pwd)
TOP=jacobi2d_kernel
PLATFORM=xilinx_u250_xdma_201830_2
ITER=$1

XO="${src_dir}/soda_jacobi2d_iter${ITER}.xo"
STRATEGY="Default"
output_dir="$(pwd)/vitis_run"


CONSTRAINT="${src_dir}/constraint_ref.tcl"
if [ ! -f "$CONSTRAINT" ]; then
    echo "no constraint file found"
    exit
fi

echo "Strategy: ${STRATEGY}"
echo "Platform: ${PLATFORM}"
echo "Top: ${TOP}"
# echo "(Y/n): "
# read check
# if [ "$check" != "Y" ]; then
#   exit
# fi

source /opt/tools/xilinx/Vitis/2019.2/settings64.sh 
env LC_ALL=C v++ \
  --link \
  --output "${output_dir}/${TOP}_${PLATFORM}.xclbin" \
  --kernel ${TOP} \
  --platform ${PLATFORM} \
  --target hw \
  --report_level 2 \
  --temp_dir "${output_dir}/${TOP}_${PLATFORM}.temp" \
  --optimize 3 \
  --connectivity.nk ${TOP}:1:${TOP} \
  --max_memory_ports ${TOP} \
  --save-temps \
  ${XO} \
  --connectivity.sp ${TOP}.var_input_0_0:DDR[0] \
  --connectivity.sp ${TOP}.var_output_0_0:DDR[3] \
  --kernel_frequency 300 \
  --vivado.prop run.impl_1.STEPS.PLACE_DESIGN.ARGS.DIRECTIVE=$STRATEGY \
  --vivado.prop run.impl_1.STEPS.OPT_DESIGN.TCL.PRE=$CONSTRAINT
