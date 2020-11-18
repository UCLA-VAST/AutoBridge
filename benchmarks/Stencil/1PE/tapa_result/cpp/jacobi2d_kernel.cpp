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








extern "C" {

void jacobi2d_kernel(
    uint64_t var_output_0_0,
    uint64_t var_output_0_1,
    uint64_t var_output_0_2,
    uint64_t var_output_0_3,
    uint64_t var_input_0_0,
    uint64_t var_input_0_1,
    uint64_t var_input_0_2,
    uint64_t var_input_0_3,
    int64_t coalesced_data_num,
    int64_t tile_data_num,
    int32_t tile_num_dim_0,
    int32_t input_size_dim_0,
    int32_t input_size_dim_1)
{
#pragma HLS interface s_axilite port = var_output_0_0 bundle = control
#pragma HLS interface s_axilite port = var_output_0_1 bundle = control
#pragma HLS interface s_axilite port = var_output_0_2 bundle = control
#pragma HLS interface s_axilite port = var_output_0_3 bundle = control
#pragma HLS interface s_axilite port = var_input_0_0 bundle = control
#pragma HLS interface s_axilite port = var_input_0_1 bundle = control
#pragma HLS interface s_axilite port = var_input_0_2 bundle = control
#pragma HLS interface s_axilite port = var_input_0_3 bundle = control
#pragma HLS interface s_axilite port = coalesced_data_num bundle = control
#pragma HLS interface s_axilite port = tile_data_num bundle = control
#pragma HLS interface s_axilite port = tile_num_dim_0 bundle = control
#pragma HLS interface s_axilite port = input_size_dim_0 bundle = control
#pragma HLS interface s_axilite port = input_size_dim_1 bundle = control
#pragma HLS interface s_axilite port = return bundle = control

{ auto val = reinterpret_cast<volatile uint8_t&>(var_output_0_0); }
{ auto val = reinterpret_cast<volatile uint8_t&>(var_output_0_1); }
{ auto val = reinterpret_cast<volatile uint8_t&>(var_output_0_2); }
{ auto val = reinterpret_cast<volatile uint8_t&>(var_output_0_3); }
{ auto val = reinterpret_cast<volatile uint8_t&>(var_input_0_0); }
{ auto val = reinterpret_cast<volatile uint8_t&>(var_input_0_1); }
{ auto val = reinterpret_cast<volatile uint8_t&>(var_input_0_2); }
{ auto val = reinterpret_cast<volatile uint8_t&>(var_input_0_3); }
{ auto val = reinterpret_cast<volatile uint8_t&>(coalesced_data_num); }
{ auto val = reinterpret_cast<volatile uint8_t&>(tile_data_num); }
{ auto val = reinterpret_cast<volatile uint8_t&>(tile_num_dim_0); }
{ auto val = reinterpret_cast<volatile uint8_t&>(input_size_dim_0); }
{ auto val = reinterpret_cast<volatile uint8_t&>(input_size_dim_1); }
}


}  // extern "C"


