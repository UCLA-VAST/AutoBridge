# Requirement

- Python 3.6+
- Pyverilog
```
pip install pyverilog
```

- mip version 1.8.1

# Instruction

[issue] should use mip version 1.8.1
[issue] Sometimes the mip package complains that "multiprocessing" cannot be found, but running it the second time things will work out
[FIXME] in the divide-and-conquer approach, if a region is packed close to the max_usage_ratio, then it's possible that the next split will fail because a function is atomic and cannot be split into two sub regions. The current work-around is to increase the max_usage_ratio a little
