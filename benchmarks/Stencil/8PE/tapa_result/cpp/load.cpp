#include<float.h>
#include<math.h>
#include<stdbool.h>
#include<stddef.h>
#include<stdint.h>
#include<stdio.h>
#include<string.h>
#include "ap_int.h"
#include <tlp.h>

#define BURST_WIDTH 512
#define UNROLL_FACTOR 64
#define TILE_SIZE_DIM_0 8000
#ifndef BURST_WIDTH
#define BURST_WIDTH 512
#endif//BURST_WIDTH

#if UNROLL_FACTOR != 64
#error UNROLL_FACTOR != 64
#endif//UNROLL_FACTOR != 64
#if TILE_SIZE_DIM_0 != 8000
#error TILE_SIZE_DIM_0 != 8000
#endif//TILE_SIZE_DIM_0 != 8000
#if BURST_WIDTH != 512
#error BURST_WIDTH != 512
#endif//BURST_WIDTH != 512

void load(
    tlp::ostream<ap_uint<BURST_WIDTH> > &sink_0, 
    tlp::ostream<ap_uint<BURST_WIDTH> > &sink_1, 
    tlp::ostream<ap_uint<BURST_WIDTH> > &sink_2, 
    tlp::ostream<ap_uint<BURST_WIDTH> > &sink_3, 
    tlp::mmap< ap_uint<BURST_WIDTH> > source, 
    int data_num)
{
#pragma HLS interface m_axi port = source offset = direct bundle = source
#pragma HLS data_pack variable = sink_0.fifo
#pragma HLS data_pack variable = sink_1.fifo
#pragma HLS data_pack variable = sink_2.fifo
#pragma HLS data_pack variable = sink_3.fifo
#pragma HLS data_pack variable = source


load_epoch:
    for(int i = 0; i < data_num; ++i)
    {
#pragma HLS pipeline II = 1
#pragma HLS pipeline II=1
        sink_0.write(source[i]);
        sink_1.write(source[i]+1);
        sink_2.write(source[i]+2);
        sink_3.write(source[i]+3);
    }
}






