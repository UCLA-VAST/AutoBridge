#export GUROBI_HOME=""
#export PATH="${PATH}:${GUROBI_HOME}/bin"
#export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
#export GRB_LICENSE_FILE=/home/einsx7/gurobi.lic

export VIV_VER=2020.1
# export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu
source /opt/tools/xilinx/Vitis/${VIV_VER}/settings64.sh
source /opt/xilinx/xrt/setup.sh

TOOL=vivado_hls

# step 1: run hls
${TOOL} -f step1-run-hls.tcl
cp kernel3/solution/syn/verilog/kernel3_kernel3.v kernel3_kernel3_orig.v 

# step 2: run autoparallel
cp kernel3_kernel3_orig.v kernel3/solution/syn/verilog/kernel3_kernel3.v
python3.6 -m autobridge.Flow.Manager cnn_13x8_config.json
if [ $? -ne 0 ]; then
  echo "AutoBridge Failed!"
  exit 1
fi
rm -f parse*

# step 3: verilator lint test of the generated wrappers
verilator --lint-only kernel3_kernel3.v -I./kernel3/solution/syn/verilog/ -I./ip_interface_rtl 2>&1 | grep kernel3_kernel3.v

mv kernel3_kernel3.v ./kernel3/solution/syn/verilog/

# step 4: run cosim
# ${TOOL} -f step3-cosim.tcl
# if [ $? -ne 0 ]; then
#   echo "cosim"
#   exit 1
# fi
# echo "PASS!"

${TOOL} -f step3-pack-xo.tcl
