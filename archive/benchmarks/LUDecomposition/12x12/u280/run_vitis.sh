#!/bin/bash
src_dir=$(pwd)
TOP=kernel0
PLATFORM=xilinx_u280_xdma_201920_3
XO="${src_dir}/kernel0.xo"
STRATEGY="Default"
output_dir="$(pwd)/vitis_run_400"


CONSTRAINT="${src_dir}/constraint.tcl"
if [ ! -f "$CONSTRAINT" ]; then
    echo "no constraint file found"
    exit
fi

# VIV_VER=2019.2 vivado_hls -f pack_xo.tcl

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
  --connectivity.nk ${TOP}:1:${TOP}_1 \
  --max_memory_ports ${TOP} \
  --save-temps \
  ${XO} \
  --connectivity.sp ${TOP}_1.A:HBM[0] \
  --connectivity.sp ${TOP}_1.L:HBM[1] \
  --connectivity.sp ${TOP}_1.U:HBM[2] \
  --kernel_frequency 400 \
  --vivado.prop run.impl_1.STEPS.OPT_DESIGN.TCL.PRE=$CONSTRAINT
