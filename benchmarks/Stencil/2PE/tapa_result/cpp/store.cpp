#include<float.h>
#include<math.h>
#include<stdbool.h>
#include<stddef.h>
#include<stdint.h>
#include<stdio.h>
#include<string.h>
#include "ap_int.h"
#include "tlp.h"

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



void store(tlp::mmap< ap_uint<BURST_WIDTH> > to, tlp::istream< ap_uint<BURST_WIDTH> > &from, int data_num)
{
#pragma HLS interface m_axi port = to offset = direct bundle = to
#pragma HLS data_pack variable = from.fifo
#pragma HLS data_pack variable = from.peek_val
#pragma HLS data_pack variable = to


store_epoch:
    for(int i = 0; i < data_num; ++i)
    {
#pragma HLS pipeline II = 1
#pragma HLS pipeline II=1
        to[i] = from.read();
    }
}






