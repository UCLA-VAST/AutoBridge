# Note

- Please apply `#pragma HLS dataflow disable_start_propagation` in your top function.
- Please use `extern "C" { YOUR_TOP_FUNC }` to wrap both the declaration and definition of your top function.
- The top function should only include the definition of FIFOs and the instantiation of other functions. 