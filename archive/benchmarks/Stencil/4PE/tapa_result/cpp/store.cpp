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



void store(
    tlp::mmap< ap_uint<BURST_WIDTH> > sink, 
    tlp::istream< ap_uint<BURST_WIDTH> > &source_0, 
    tlp::istream< ap_uint<BURST_WIDTH> > &source_1, 
    tlp::istream< ap_uint<BURST_WIDTH> > &source_2, 
    tlp::istream< ap_uint<BURST_WIDTH> > &source_3, 
    int data_num)
{
#pragma HLS interface m_axi port = sink offset = direct bundle = sink
#pragma HLS data_pack variable = source_0.fifo
#pragma HLS data_pack variable = source_0.peek_val
#pragma HLS data_pack variable = source_1.fifo
#pragma HLS data_pack variable = source_1.peek_val
#pragma HLS data_pack variable = source_2.fifo
#pragma HLS data_pack variable = source_2.peek_val
#pragma HLS data_pack variable = source_3.fifo
#pragma HLS data_pack variable = source_3.peek_val
#pragma HLS data_pack variable = sink


store_epoch:
    for(int i = 0; i < data_num; ++i)
    {
#pragma HLS pipeline II = 1
#pragma HLS pipeline II=1
        sink[i] = source_0.read() + source_1.read() + source_2.read() + source_3.read();
    }
}





