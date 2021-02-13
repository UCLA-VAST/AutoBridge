
# should be the same as 'target_dir' in step2-autobridge.py
AUTOBRIDGE_DIR='./autobridge'

# change according to your environment
source /opt/tools/xilinx/Vitis/2019.2/settings64.sh 

# You may need to install Gurobi @ https://www.gurobi.com/academia/academic-program-and-licenses/
# export GUROBI_HOME="/home/einsx7/pr/solver/gurobi902/linux64"
# export PATH="${PATH}:${GUROBI_HOME}/bin"
# export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
# export GRB_LICENSE_FILE=/home/einsx7/pr/solver/gurobi902/gurobi.lic

# step 1: run hls
vivado_hls -f step1-run-hls.tcl

# step 2: run vitis
./step2-autobridge.py | tee autobridge.log

# in case of pyverilog bug, run again
if [ ${PIPESTATUS[0]} -ne 0 ]; then
  echo "Detecting error, Rerun AutoBridge..."
  ./step2-autobridge.py | tee autobridge.log
fi

# step 3: pack up into the xo object using HLS
# this process needs the source files to be at the correct relative position
cp -r src ${AUTOBRIDGE_DIR}
cp src/* ${AUTOBRIDGE_DIR}
cd ${AUTOBRIDGE_DIR} && vivado_hls -f ../step3-pack-xo.tcl

# step 4: run vitis
cp ../step4-run-vitis.sh .
./step4-run-vitis.sh