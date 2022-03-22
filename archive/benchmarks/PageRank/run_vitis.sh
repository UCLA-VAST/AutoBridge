#!/bin/bash
src_dir=$(pwd)
TOP=PageRank
PLATFORM=xilinx_u280_xdma_201920_3
XO="${src_dir}/PageRank_FP1.xo"
STRATEGY="EarlyBlockPlacement"
output_dir="$(pwd)/vitis_run"


CONSTRAINT="${src_dir}/constraint_ref.tcl"
if [ ! -f "$CONSTRAINT" ]; then
    echo "no constraint file found"
    exit
fi

echo "Strategy: ${STRATEGY}"
echo "Platform: ${PLATFORM}"
echo "Top: ${TOP}"

set -x

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
  --connectivity.sp ${TOP}.edges_0:HBM[0] \
  --connectivity.sp ${TOP}.edges_1:HBM[3] \
  --connectivity.sp ${TOP}.edges_2:HBM[6] \
  --connectivity.sp ${TOP}.edges_3:HBM[9] \
  --connectivity.sp ${TOP}.edges_4:HBM[12] \
  --connectivity.sp ${TOP}.edges_5:HBM[15] \
  --connectivity.sp ${TOP}.edges_6:HBM[18] \
  --connectivity.sp ${TOP}.edges_7:HBM[21] \
  --connectivity.sp ${TOP}.updates_0:HBM[2] \
  --connectivity.sp ${TOP}.updates_1:HBM[5] \
  --connectivity.sp ${TOP}.updates_2:HBM[8] \
  --connectivity.sp ${TOP}.updates_3:HBM[11] \
  --connectivity.sp ${TOP}.updates_4:HBM[14] \
  --connectivity.sp ${TOP}.updates_5:HBM[17] \
  --connectivity.sp ${TOP}.updates_6:HBM[20] \
  --connectivity.sp ${TOP}.updates_7:HBM[23] \
  --connectivity.sp ${TOP}.metadata:PLRAM[0] \
  --connectivity.sp ${TOP}.degrees:HBM[24] \
  --connectivity.sp ${TOP}.rankings:HBM[26] \
  --connectivity.sp ${TOP}.tmps:HBM[27] \
  --kernel_frequency 250 \
  --vivado.prop run.impl_1.STEPS.PLACE_DESIGN.ARGS.DIRECTIVE=$STRATEGY \
  --vivado.prop run.impl_1.STEPS.OPT_DESIGN.TCL.PRE=$CONSTRAINT
