AUTOBRIDGE_DIR=kernel3_u250_autobridge_impl

# change according to your environment
source /opt/tools/xilinx/Vitis/2019.2/settings64.sh 

# You may need to install Gurobi @ https://www.gurobi.com/academia/academic-program-and-licenses/
# export GUROBI_HOME="/home/einsx7/pr/solver/gurobi902/linux64"
# export PATH="${PATH}:${GUROBI_HOME}/bin"
# export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
# export GRB_LICENSE_FILE=/home/einsx7/pr/solver/gurobi902/gurobi.lic

# step 1: run hls
vivado_hls -f generate_rtl.tcl

# step 2: run vitis
./ab_cnn_13x10.py | tee autobridge.log

# in case of pyverilog bug, run again
./ab_cnn_13x10.py | tee autobridge.log

# step 3: pack xo
cp -r src ${AUTOBRIDGE_DIR}
cp src/* ${AUTOBRIDGE_DIR}
cp run_vitis.sh ${AUTOBRIDGE_DIR}
cd ${AUTOBRIDGE_DIR} && vivado_hls -f ../pack_xo.tcl

# step 4: run vitis
./run_vitis.sh
