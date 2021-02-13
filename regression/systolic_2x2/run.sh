AUTOBRIDGE_DIR='./autobridge'

VIV_VER=2019.2 vivado_hls -f step1-run-hls.tcl

./step2-autobridge.py | tee autobridge.log

# in case of pyverilog bug, run again
if [ ${PIPESTATUS[0]} -ne 0 ]; then
  echo "AutoBridge failed!"
  exit
fi

# step 3: pack xo
cp -r src ${AUTOBRIDGE_DIR}
cp src/* ${AUTOBRIDGE_DIR}
cp step4-run-vitis.sh ${AUTOBRIDGE_DIR}
cd ${AUTOBRIDGE_DIR} && vivado_hls -f ../step3-pack-xo.tcl

# step 4: run vitis
./step4-run-vitis.sh

# step 5: run cosim
export  XCL_EMULATION_MODE=hw_emu
cd cosim
./host.exe ../autobridge/vitis_run_hw_emu/*.xclbin