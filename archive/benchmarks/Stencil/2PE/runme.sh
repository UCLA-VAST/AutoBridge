# To run AutoBridge:
./soda_autobridge.py | tee autobridge.log

# in case of pyverilog bug, run again
if [ ${PIPESTATUS[0]} -ne 0 ]; then
  echo "Detecting error, Rerun AutoBridge..."
  ./soda_autobridge.py | tee autobridge.log
fi

# To run Vitis, we have to first package the results using the TAPA compiler. We provided the XO that has already been packaged (PageRank_FP1.xo) if you do not have TAPA already installed. 
./run_vitis.sh 2

