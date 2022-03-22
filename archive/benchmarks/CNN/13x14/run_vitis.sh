#!/bin/bash
src_dir=$(pwd)
TOP=kernel3
PLATFORM=xilinx_u250_xdma_201830_2
XO="${src_dir}/polysa.xo"
STRATEGY="Default"
output_dir="$(pwd)/vitis_run"


CONSTRAINT="${src_dir}/constraint.tcl"
if [ ! -f "$CONSTRAINT" ]; then
    echo "no constraint file found"
    exit
fi

env LC_ALL=C v++ \
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
  --vivado.prop run.impl_1.STEPS.OPT_DESIGN.TCL.PRE=$CONSTRAINT
