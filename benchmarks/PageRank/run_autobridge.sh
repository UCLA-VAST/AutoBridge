./ab_pagerank_u280.py | tee autobridge.log

# in case of pyverilog bug, run again
if [ ${PIPESTATUS[0]} -ne 0 ]; then
  echo "Detecting error, Rerun AutoBridge..."
  ./ab_pagerank_u280.py | tee autobridge.log
fi