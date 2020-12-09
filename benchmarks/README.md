The experiment results for all benchmarks in our submission to FPGA'21 are available at:
`https://ucla.box.com/s/5hpgduqrx93t2j4kx6fflw6z15oylfhu`

Currently only a subset of the source code of the benchmarks are open-sourced here, as some designs are not published yet and will be updated later.

# Restrictions

Note that the current automated flow has some restrictions on the HLS designs.
  * The HLS design should be a `dataflow` design.
  * The top function of the HLS design should only contain `function instantiations` and `FIFO instantiations`. The tool will not work on designs that have computations in their top functions. 

  * The `dataflow` pragma should come with the `disable_start_propagation` property, i.e. `#pragma HLS dataflow disable_start_propagation`.

## A Counter-Example

One such example that will NOT work with AutoBridge can be found at the Rosetta benchmark: 

  `https://github.com/cornell-zhang/rosetta/blob/master/optical-flow/src/sdsoc/optical_flow.cpp`
    
Only a slight change is needed here. In the top function `optical_flow()`, the shown part (line 447 - 463) should be wrapped into another function and be instantiated in the top function. Other than this issue, the coding style of this design is compatible with AutoBridge.

```c++
446  static frames_t buf;
447  FRAMES_CP_OUTER: for (int r=0; r<MAX_HEIGHT; r++) 
448  {
449    FRAMES_CP_INNER: for (int c=0; c<MAX_WIDTH; c++) 
450    {
451      #pragma HLS pipeline II=1
452              
453      // one wide read
454      buf = frames[r][c];
455      // assign values to the FIFOs
456      frame1_a[r][c] = ((input_t)(buf(7 ,  0)) >> 8);
457      frame2_a[r][c] = ((input_t)(buf(15,  8)) >> 8);
458      frame3_a[r][c] = ((input_t)(buf(23, 16)) >> 8);
459      frame3_b[r][c] = ((input_t)(buf(23, 16)) >> 8);
460      frame4_a[r][c] = ((input_t)(buf(31, 24)) >> 8);
461      frame5_a[r][c] = ((input_t)(buf(39, 32)) >> 8);
462    }
463  }
```

