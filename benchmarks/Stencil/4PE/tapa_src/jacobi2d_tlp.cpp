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

void load(tlp::ostream<ap_uint<BURST_WIDTH> > &to, tlp::mmap< ap_uint<BURST_WIDTH> > from, int data_num)
{
load_epoch:
    for(int i = 0; i < data_num; ++i)
    {
#pragma HLS pipeline II=1
        to.write(from[i]);
    }
}

void store(tlp::mmap< ap_uint<BURST_WIDTH> > to, tlp::istream< ap_uint<BURST_WIDTH> > &from, int data_num)
{
store_epoch:
    for(int i = 0; i < data_num; ++i)
    {
#pragma HLS pipeline II=1
        to[i] = from.read();
    }
}

void compute(
    tlp::ostream<ap_uint<BURST_WIDTH> >& to_chan_0_bank_0,
    tlp::ostream<ap_uint<BURST_WIDTH> >& to_chan_0_bank_1,
    tlp::ostream<ap_uint<BURST_WIDTH> >& to_chan_0_bank_2,
    tlp::ostream<ap_uint<BURST_WIDTH> >& to_chan_0_bank_3,
    tlp::istream<ap_uint<BURST_WIDTH> >& from_chan_0_bank_0,
    tlp::istream<ap_uint<BURST_WIDTH> >& from_chan_0_bank_1,
    tlp::istream<ap_uint<BURST_WIDTH> >& from_chan_0_bank_2,
    tlp::istream<ap_uint<BURST_WIDTH> >& from_chan_0_bank_3,
    int64_t coalesced_data_num,
    int64_t tile_data_num,
    int32_t tile_num_dim_0,
    int32_t input_size_dim_0,
    int32_t input_size_dim_1)
{
    int32_t tile_index_dim_0 = 0;

    // reuse chains for t1
    float FF_t1_chan_0[2];
    float FIFO_125_t1_chan_0[126][125];
    float FIFO_124_t1_chan_0[2][124];
#pragma HLS array_partition variable=FF_t1_chan_0 complete
#pragma HLS resource variable=FF_t1_chan_0 latency=1
#pragma HLS array_partition variable=FIFO_125_t1_chan_0 complete dim=1
#pragma HLS array_partition variable=FIFO_124_t1_chan_0 complete dim=1

    uint8_t FIFO_125_t1_ptr = 0;
    uint8_t FIFO_124_t1_ptr = 0;

    // points aliases for t1
    float points_from_t1_to_t0_chan_0[UNROLL_FACTOR][5];
    //    points_from_t1_to_t0_chan_x[UNROLL_FACTOR][0] <=> t1[x](1, 0)
    //    points_from_t1_to_t0_chan_x[UNROLL_FACTOR][1] <=> t1[x](0, 1)
    //    points_from_t1_to_t0_chan_x[UNROLL_FACTOR][2] <=> t1[x](1, 1)
    //    points_from_t1_to_t0_chan_x[UNROLL_FACTOR][3] <=> t1[x](2, 1)
    //    points_from_t1_to_t0_chan_x[UNROLL_FACTOR][4] <=> t1[x](1, 2)
#pragma HLS array_partition variable=points_from_t1_to_t0_chan_0 complete dim=0

    // input buffer
    float buffer_t1_chan_0[UNROLL_FACTOR];
#pragma HLS array_partition variable=buffer_t1_chan_0 complete dim=0
#pragma HLS resource variable=buffer_t1_chan_0 latency=1

    // intermediate buffer for t1
    // output buffer
    float buffer_t0_chan_0[UNROLL_FACTOR];
#pragma HLS array_partition variable=buffer_t0_chan_0 complete dim=0
#pragma HLS resource variable=buffer_t0_chan_0 latency=1

    // produce output
compute_epoch:
    for(int32_t epoch = 0; epoch < coalesced_data_num*1; ++epoch)
    {
#pragma HLS dependence variable=FF_t1_chan_0 inter false
#pragma HLS dependence variable=FIFO_125_t1_chan_0 inter false
#pragma HLS dependence variable=FIFO_124_t1_chan_0 inter false
#pragma HLS pipeline II=1
        {
            ap_uint<BURST_WIDTH> tmp_chan_0_bank_0, tmp_chan_0_bank_1, tmp_chan_0_bank_2, tmp_chan_0_bank_3;
            tmp_chan_0_bank_0 = from_chan_0_bank_0.read();
            tmp_chan_0_bank_1 = from_chan_0_bank_1.read();
            tmp_chan_0_bank_2 = from_chan_0_bank_2.read();
            tmp_chan_0_bank_3 = from_chan_0_bank_3.read();
load_coalesced:
            for(int j = 0; j < BURST_WIDTH/32; ++j)
            {
#pragma HLS unroll
                uint32_t raw_bits_chan_0_bank_0 = tmp_chan_0_bank_0((j+1)*32-1, j*32);
                buffer_t1_chan_0[BURST_WIDTH/32*4*0+j*4+0] = *(float*)(&raw_bits_chan_0_bank_0);
                uint32_t raw_bits_chan_0_bank_1 = tmp_chan_0_bank_1((j+1)*32-1, j*32);
                buffer_t1_chan_0[BURST_WIDTH/32*4*0+j*4+1] = *(float*)(&raw_bits_chan_0_bank_1);
                uint32_t raw_bits_chan_0_bank_2 = tmp_chan_0_bank_2((j+1)*32-1, j*32);
                buffer_t1_chan_0[BURST_WIDTH/32*4*0+j*4+2] = *(float*)(&raw_bits_chan_0_bank_2);
                uint32_t raw_bits_chan_0_bank_3 = tmp_chan_0_bank_3((j+1)*32-1, j*32);
                buffer_t1_chan_0[BURST_WIDTH/32*4*0+j*4+3] = *(float*)(&raw_bits_chan_0_bank_3);
            }
        }

        float& FIFO_125_t1_chan_0_fifo_0 = FIFO_125_t1_chan_0[0][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_1 = FIFO_125_t1_chan_0[1][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_2 = FIFO_125_t1_chan_0[2][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_3 = FIFO_125_t1_chan_0[3][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_4 = FIFO_125_t1_chan_0[4][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_5 = FIFO_125_t1_chan_0[5][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_6 = FIFO_125_t1_chan_0[6][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_7 = FIFO_125_t1_chan_0[7][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_8 = FIFO_125_t1_chan_0[8][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_9 = FIFO_125_t1_chan_0[9][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_10 = FIFO_125_t1_chan_0[10][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_11 = FIFO_125_t1_chan_0[11][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_12 = FIFO_125_t1_chan_0[12][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_13 = FIFO_125_t1_chan_0[13][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_14 = FIFO_125_t1_chan_0[14][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_15 = FIFO_125_t1_chan_0[15][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_16 = FIFO_125_t1_chan_0[16][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_17 = FIFO_125_t1_chan_0[17][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_18 = FIFO_125_t1_chan_0[18][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_19 = FIFO_125_t1_chan_0[19][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_20 = FIFO_125_t1_chan_0[20][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_21 = FIFO_125_t1_chan_0[21][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_22 = FIFO_125_t1_chan_0[22][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_23 = FIFO_125_t1_chan_0[23][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_24 = FIFO_125_t1_chan_0[24][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_25 = FIFO_125_t1_chan_0[25][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_26 = FIFO_125_t1_chan_0[26][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_27 = FIFO_125_t1_chan_0[27][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_28 = FIFO_125_t1_chan_0[28][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_29 = FIFO_125_t1_chan_0[29][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_30 = FIFO_125_t1_chan_0[30][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_31 = FIFO_125_t1_chan_0[31][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_32 = FIFO_125_t1_chan_0[32][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_33 = FIFO_125_t1_chan_0[33][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_34 = FIFO_125_t1_chan_0[34][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_35 = FIFO_125_t1_chan_0[35][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_36 = FIFO_125_t1_chan_0[36][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_37 = FIFO_125_t1_chan_0[37][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_38 = FIFO_125_t1_chan_0[38][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_39 = FIFO_125_t1_chan_0[39][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_40 = FIFO_125_t1_chan_0[40][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_41 = FIFO_125_t1_chan_0[41][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_42 = FIFO_125_t1_chan_0[42][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_43 = FIFO_125_t1_chan_0[43][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_44 = FIFO_125_t1_chan_0[44][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_45 = FIFO_125_t1_chan_0[45][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_46 = FIFO_125_t1_chan_0[46][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_47 = FIFO_125_t1_chan_0[47][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_48 = FIFO_125_t1_chan_0[48][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_49 = FIFO_125_t1_chan_0[49][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_50 = FIFO_125_t1_chan_0[50][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_51 = FIFO_125_t1_chan_0[51][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_52 = FIFO_125_t1_chan_0[52][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_53 = FIFO_125_t1_chan_0[53][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_54 = FIFO_125_t1_chan_0[54][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_55 = FIFO_125_t1_chan_0[55][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_56 = FIFO_125_t1_chan_0[56][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_57 = FIFO_125_t1_chan_0[57][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_58 = FIFO_125_t1_chan_0[58][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_59 = FIFO_125_t1_chan_0[59][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_60 = FIFO_125_t1_chan_0[60][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_61 = FIFO_125_t1_chan_0[61][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_62 = FIFO_125_t1_chan_0[62][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_63 = FIFO_125_t1_chan_0[63][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_64 = FIFO_125_t1_chan_0[64][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_65 = FIFO_125_t1_chan_0[65][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_66 = FIFO_125_t1_chan_0[66][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_67 = FIFO_125_t1_chan_0[67][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_68 = FIFO_125_t1_chan_0[68][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_69 = FIFO_125_t1_chan_0[69][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_70 = FIFO_125_t1_chan_0[70][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_71 = FIFO_125_t1_chan_0[71][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_72 = FIFO_125_t1_chan_0[72][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_73 = FIFO_125_t1_chan_0[73][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_74 = FIFO_125_t1_chan_0[74][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_75 = FIFO_125_t1_chan_0[75][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_76 = FIFO_125_t1_chan_0[76][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_77 = FIFO_125_t1_chan_0[77][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_78 = FIFO_125_t1_chan_0[78][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_79 = FIFO_125_t1_chan_0[79][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_80 = FIFO_125_t1_chan_0[80][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_81 = FIFO_125_t1_chan_0[81][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_82 = FIFO_125_t1_chan_0[82][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_83 = FIFO_125_t1_chan_0[83][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_84 = FIFO_125_t1_chan_0[84][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_85 = FIFO_125_t1_chan_0[85][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_86 = FIFO_125_t1_chan_0[86][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_87 = FIFO_125_t1_chan_0[87][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_88 = FIFO_125_t1_chan_0[88][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_89 = FIFO_125_t1_chan_0[89][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_90 = FIFO_125_t1_chan_0[90][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_91 = FIFO_125_t1_chan_0[91][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_92 = FIFO_125_t1_chan_0[92][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_93 = FIFO_125_t1_chan_0[93][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_94 = FIFO_125_t1_chan_0[94][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_95 = FIFO_125_t1_chan_0[95][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_96 = FIFO_125_t1_chan_0[96][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_97 = FIFO_125_t1_chan_0[97][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_98 = FIFO_125_t1_chan_0[98][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_99 = FIFO_125_t1_chan_0[99][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_100 = FIFO_125_t1_chan_0[100][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_101 = FIFO_125_t1_chan_0[101][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_102 = FIFO_125_t1_chan_0[102][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_103 = FIFO_125_t1_chan_0[103][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_104 = FIFO_125_t1_chan_0[104][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_105 = FIFO_125_t1_chan_0[105][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_106 = FIFO_125_t1_chan_0[106][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_107 = FIFO_125_t1_chan_0[107][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_108 = FIFO_125_t1_chan_0[108][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_109 = FIFO_125_t1_chan_0[109][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_110 = FIFO_125_t1_chan_0[110][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_111 = FIFO_125_t1_chan_0[111][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_112 = FIFO_125_t1_chan_0[112][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_113 = FIFO_125_t1_chan_0[113][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_114 = FIFO_125_t1_chan_0[114][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_115 = FIFO_125_t1_chan_0[115][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_116 = FIFO_125_t1_chan_0[116][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_117 = FIFO_125_t1_chan_0[117][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_118 = FIFO_125_t1_chan_0[118][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_119 = FIFO_125_t1_chan_0[119][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_120 = FIFO_125_t1_chan_0[120][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_121 = FIFO_125_t1_chan_0[121][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_122 = FIFO_125_t1_chan_0[122][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_123 = FIFO_125_t1_chan_0[123][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_124 = FIFO_125_t1_chan_0[124][FIFO_125_t1_ptr];
        float& FIFO_125_t1_chan_0_fifo_125 = FIFO_125_t1_chan_0[125][FIFO_125_t1_ptr];
        float& FIFO_124_t1_chan_0_fifo_0 = FIFO_124_t1_chan_0[0][FIFO_124_t1_ptr];
        float& FIFO_124_t1_chan_0_fifo_1 = FIFO_124_t1_chan_0[1][FIFO_124_t1_ptr];

        points_from_t1_to_t0_chan_0[0][4] = buffer_t1_chan_0[0]; // t1[0](1, 2) @ unroll_index=0
        points_from_t1_to_t0_chan_0[1][4] = buffer_t1_chan_0[1]; // t1[0](1, 2) @ unroll_index=1
        points_from_t1_to_t0_chan_0[2][4] = buffer_t1_chan_0[2]; // t1[0](1, 2) @ unroll_index=2
        points_from_t1_to_t0_chan_0[3][4] = buffer_t1_chan_0[3]; // t1[0](1, 2) @ unroll_index=3
        points_from_t1_to_t0_chan_0[4][4] = buffer_t1_chan_0[4]; // t1[0](1, 2) @ unroll_index=4
        points_from_t1_to_t0_chan_0[5][4] = buffer_t1_chan_0[5]; // t1[0](1, 2) @ unroll_index=5
        points_from_t1_to_t0_chan_0[6][4] = buffer_t1_chan_0[6]; // t1[0](1, 2) @ unroll_index=6
        points_from_t1_to_t0_chan_0[7][4] = buffer_t1_chan_0[7]; // t1[0](1, 2) @ unroll_index=7
        points_from_t1_to_t0_chan_0[8][4] = buffer_t1_chan_0[8]; // t1[0](1, 2) @ unroll_index=8
        points_from_t1_to_t0_chan_0[9][4] = buffer_t1_chan_0[9]; // t1[0](1, 2) @ unroll_index=9
        points_from_t1_to_t0_chan_0[10][4] = buffer_t1_chan_0[10]; // t1[0](1, 2) @ unroll_index=10
        points_from_t1_to_t0_chan_0[11][4] = buffer_t1_chan_0[11]; // t1[0](1, 2) @ unroll_index=11
        points_from_t1_to_t0_chan_0[12][4] = buffer_t1_chan_0[12]; // t1[0](1, 2) @ unroll_index=12
        points_from_t1_to_t0_chan_0[13][4] = buffer_t1_chan_0[13]; // t1[0](1, 2) @ unroll_index=13
        points_from_t1_to_t0_chan_0[14][4] = buffer_t1_chan_0[14]; // t1[0](1, 2) @ unroll_index=14
        points_from_t1_to_t0_chan_0[15][4] = buffer_t1_chan_0[15]; // t1[0](1, 2) @ unroll_index=15
        points_from_t1_to_t0_chan_0[16][4] = buffer_t1_chan_0[16]; // t1[0](1, 2) @ unroll_index=16
        points_from_t1_to_t0_chan_0[17][4] = buffer_t1_chan_0[17]; // t1[0](1, 2) @ unroll_index=17
        points_from_t1_to_t0_chan_0[18][4] = buffer_t1_chan_0[18]; // t1[0](1, 2) @ unroll_index=18
        points_from_t1_to_t0_chan_0[19][4] = buffer_t1_chan_0[19]; // t1[0](1, 2) @ unroll_index=19
        points_from_t1_to_t0_chan_0[20][4] = buffer_t1_chan_0[20]; // t1[0](1, 2) @ unroll_index=20
        points_from_t1_to_t0_chan_0[21][4] = buffer_t1_chan_0[21]; // t1[0](1, 2) @ unroll_index=21
        points_from_t1_to_t0_chan_0[22][4] = buffer_t1_chan_0[22]; // t1[0](1, 2) @ unroll_index=22
        points_from_t1_to_t0_chan_0[23][4] = buffer_t1_chan_0[23]; // t1[0](1, 2) @ unroll_index=23
        points_from_t1_to_t0_chan_0[24][4] = buffer_t1_chan_0[24]; // t1[0](1, 2) @ unroll_index=24
        points_from_t1_to_t0_chan_0[25][4] = buffer_t1_chan_0[25]; // t1[0](1, 2) @ unroll_index=25
        points_from_t1_to_t0_chan_0[26][4] = buffer_t1_chan_0[26]; // t1[0](1, 2) @ unroll_index=26
        points_from_t1_to_t0_chan_0[27][4] = buffer_t1_chan_0[27]; // t1[0](1, 2) @ unroll_index=27
        points_from_t1_to_t0_chan_0[28][4] = buffer_t1_chan_0[28]; // t1[0](1, 2) @ unroll_index=28
        points_from_t1_to_t0_chan_0[29][4] = buffer_t1_chan_0[29]; // t1[0](1, 2) @ unroll_index=29
        points_from_t1_to_t0_chan_0[30][4] = buffer_t1_chan_0[30]; // t1[0](1, 2) @ unroll_index=30
        points_from_t1_to_t0_chan_0[31][4] = buffer_t1_chan_0[31]; // t1[0](1, 2) @ unroll_index=31
        points_from_t1_to_t0_chan_0[32][4] = buffer_t1_chan_0[32]; // t1[0](1, 2) @ unroll_index=32
        points_from_t1_to_t0_chan_0[33][4] = buffer_t1_chan_0[33]; // t1[0](1, 2) @ unroll_index=33
        points_from_t1_to_t0_chan_0[34][4] = buffer_t1_chan_0[34]; // t1[0](1, 2) @ unroll_index=34
        points_from_t1_to_t0_chan_0[35][4] = buffer_t1_chan_0[35]; // t1[0](1, 2) @ unroll_index=35
        points_from_t1_to_t0_chan_0[36][4] = buffer_t1_chan_0[36]; // t1[0](1, 2) @ unroll_index=36
        points_from_t1_to_t0_chan_0[37][4] = buffer_t1_chan_0[37]; // t1[0](1, 2) @ unroll_index=37
        points_from_t1_to_t0_chan_0[38][4] = buffer_t1_chan_0[38]; // t1[0](1, 2) @ unroll_index=38
        points_from_t1_to_t0_chan_0[39][4] = buffer_t1_chan_0[39]; // t1[0](1, 2) @ unroll_index=39
        points_from_t1_to_t0_chan_0[40][4] = buffer_t1_chan_0[40]; // t1[0](1, 2) @ unroll_index=40
        points_from_t1_to_t0_chan_0[41][4] = buffer_t1_chan_0[41]; // t1[0](1, 2) @ unroll_index=41
        points_from_t1_to_t0_chan_0[42][4] = buffer_t1_chan_0[42]; // t1[0](1, 2) @ unroll_index=42
        points_from_t1_to_t0_chan_0[43][4] = buffer_t1_chan_0[43]; // t1[0](1, 2) @ unroll_index=43
        points_from_t1_to_t0_chan_0[44][4] = buffer_t1_chan_0[44]; // t1[0](1, 2) @ unroll_index=44
        points_from_t1_to_t0_chan_0[45][4] = buffer_t1_chan_0[45]; // t1[0](1, 2) @ unroll_index=45
        points_from_t1_to_t0_chan_0[46][4] = buffer_t1_chan_0[46]; // t1[0](1, 2) @ unroll_index=46
        points_from_t1_to_t0_chan_0[47][4] = buffer_t1_chan_0[47]; // t1[0](1, 2) @ unroll_index=47
        points_from_t1_to_t0_chan_0[48][4] = buffer_t1_chan_0[48]; // t1[0](1, 2) @ unroll_index=48
        points_from_t1_to_t0_chan_0[49][4] = buffer_t1_chan_0[49]; // t1[0](1, 2) @ unroll_index=49
        points_from_t1_to_t0_chan_0[50][4] = buffer_t1_chan_0[50]; // t1[0](1, 2) @ unroll_index=50
        points_from_t1_to_t0_chan_0[51][4] = buffer_t1_chan_0[51]; // t1[0](1, 2) @ unroll_index=51
        points_from_t1_to_t0_chan_0[52][4] = buffer_t1_chan_0[52]; // t1[0](1, 2) @ unroll_index=52
        points_from_t1_to_t0_chan_0[53][4] = buffer_t1_chan_0[53]; // t1[0](1, 2) @ unroll_index=53
        points_from_t1_to_t0_chan_0[54][4] = buffer_t1_chan_0[54]; // t1[0](1, 2) @ unroll_index=54
        points_from_t1_to_t0_chan_0[55][4] = buffer_t1_chan_0[55]; // t1[0](1, 2) @ unroll_index=55
        points_from_t1_to_t0_chan_0[56][4] = buffer_t1_chan_0[56]; // t1[0](1, 2) @ unroll_index=56
        points_from_t1_to_t0_chan_0[57][4] = buffer_t1_chan_0[57]; // t1[0](1, 2) @ unroll_index=57
        points_from_t1_to_t0_chan_0[58][4] = buffer_t1_chan_0[58]; // t1[0](1, 2) @ unroll_index=58
        points_from_t1_to_t0_chan_0[59][4] = buffer_t1_chan_0[59]; // t1[0](1, 2) @ unroll_index=59
        points_from_t1_to_t0_chan_0[60][4] = buffer_t1_chan_0[60]; // t1[0](1, 2) @ unroll_index=60
        points_from_t1_to_t0_chan_0[61][4] = buffer_t1_chan_0[61]; // t1[0](1, 2) @ unroll_index=61
        points_from_t1_to_t0_chan_0[62][4] = buffer_t1_chan_0[62]; // t1[0](1, 2) @ unroll_index=62
        points_from_t1_to_t0_chan_0[63][4] = buffer_t1_chan_0[63]; // t1[0](1, 2) @ unroll_index=63
        points_from_t1_to_t0_chan_0[0][2] = FF_t1_chan_0[0]; // t1[0](1, 1) @ unroll_index=0
        points_from_t1_to_t0_chan_0[1][1] = FF_t1_chan_0[0]; // t1[0](0, 1) @ unroll_index=1
        points_from_t1_to_t0_chan_0[0][1] = FF_t1_chan_0[1]; // t1[0](0, 1) @ unroll_index=0
        points_from_t1_to_t0_chan_0[62][3] = FIFO_125_t1_chan_0_fifo_0; // t1[0](2, 1) @ unroll_index=62
        points_from_t1_to_t0_chan_0[63][2] = FIFO_125_t1_chan_0_fifo_0; // t1[0](1, 1) @ unroll_index=63
        points_from_t1_to_t0_chan_0[61][3] = FIFO_125_t1_chan_0_fifo_1; // t1[0](2, 1) @ unroll_index=61
        points_from_t1_to_t0_chan_0[62][2] = FIFO_125_t1_chan_0_fifo_1; // t1[0](1, 1) @ unroll_index=62
        points_from_t1_to_t0_chan_0[63][1] = FIFO_125_t1_chan_0_fifo_1; // t1[0](0, 1) @ unroll_index=63
        points_from_t1_to_t0_chan_0[60][3] = FIFO_125_t1_chan_0_fifo_2; // t1[0](2, 1) @ unroll_index=60
        points_from_t1_to_t0_chan_0[61][2] = FIFO_125_t1_chan_0_fifo_2; // t1[0](1, 1) @ unroll_index=61
        points_from_t1_to_t0_chan_0[62][1] = FIFO_125_t1_chan_0_fifo_2; // t1[0](0, 1) @ unroll_index=62
        points_from_t1_to_t0_chan_0[59][3] = FIFO_125_t1_chan_0_fifo_3; // t1[0](2, 1) @ unroll_index=59
        points_from_t1_to_t0_chan_0[60][2] = FIFO_125_t1_chan_0_fifo_3; // t1[0](1, 1) @ unroll_index=60
        points_from_t1_to_t0_chan_0[61][1] = FIFO_125_t1_chan_0_fifo_3; // t1[0](0, 1) @ unroll_index=61
        points_from_t1_to_t0_chan_0[58][3] = FIFO_125_t1_chan_0_fifo_4; // t1[0](2, 1) @ unroll_index=58
        points_from_t1_to_t0_chan_0[59][2] = FIFO_125_t1_chan_0_fifo_4; // t1[0](1, 1) @ unroll_index=59
        points_from_t1_to_t0_chan_0[60][1] = FIFO_125_t1_chan_0_fifo_4; // t1[0](0, 1) @ unroll_index=60
        points_from_t1_to_t0_chan_0[57][3] = FIFO_125_t1_chan_0_fifo_5; // t1[0](2, 1) @ unroll_index=57
        points_from_t1_to_t0_chan_0[58][2] = FIFO_125_t1_chan_0_fifo_5; // t1[0](1, 1) @ unroll_index=58
        points_from_t1_to_t0_chan_0[59][1] = FIFO_125_t1_chan_0_fifo_5; // t1[0](0, 1) @ unroll_index=59
        points_from_t1_to_t0_chan_0[56][3] = FIFO_125_t1_chan_0_fifo_6; // t1[0](2, 1) @ unroll_index=56
        points_from_t1_to_t0_chan_0[57][2] = FIFO_125_t1_chan_0_fifo_6; // t1[0](1, 1) @ unroll_index=57
        points_from_t1_to_t0_chan_0[58][1] = FIFO_125_t1_chan_0_fifo_6; // t1[0](0, 1) @ unroll_index=58
        points_from_t1_to_t0_chan_0[56][2] = FIFO_125_t1_chan_0_fifo_7; // t1[0](1, 1) @ unroll_index=56
        points_from_t1_to_t0_chan_0[57][1] = FIFO_125_t1_chan_0_fifo_7; // t1[0](0, 1) @ unroll_index=57
        points_from_t1_to_t0_chan_0[55][3] = FIFO_125_t1_chan_0_fifo_7; // t1[0](2, 1) @ unroll_index=55
        points_from_t1_to_t0_chan_0[56][1] = FIFO_125_t1_chan_0_fifo_8; // t1[0](0, 1) @ unroll_index=56
        points_from_t1_to_t0_chan_0[54][3] = FIFO_125_t1_chan_0_fifo_8; // t1[0](2, 1) @ unroll_index=54
        points_from_t1_to_t0_chan_0[55][2] = FIFO_125_t1_chan_0_fifo_8; // t1[0](1, 1) @ unroll_index=55
        points_from_t1_to_t0_chan_0[53][3] = FIFO_125_t1_chan_0_fifo_9; // t1[0](2, 1) @ unroll_index=53
        points_from_t1_to_t0_chan_0[54][2] = FIFO_125_t1_chan_0_fifo_9; // t1[0](1, 1) @ unroll_index=54
        points_from_t1_to_t0_chan_0[55][1] = FIFO_125_t1_chan_0_fifo_9; // t1[0](0, 1) @ unroll_index=55
        points_from_t1_to_t0_chan_0[52][3] = FIFO_125_t1_chan_0_fifo_10; // t1[0](2, 1) @ unroll_index=52
        points_from_t1_to_t0_chan_0[53][2] = FIFO_125_t1_chan_0_fifo_10; // t1[0](1, 1) @ unroll_index=53
        points_from_t1_to_t0_chan_0[54][1] = FIFO_125_t1_chan_0_fifo_10; // t1[0](0, 1) @ unroll_index=54
        points_from_t1_to_t0_chan_0[51][3] = FIFO_125_t1_chan_0_fifo_11; // t1[0](2, 1) @ unroll_index=51
        points_from_t1_to_t0_chan_0[52][2] = FIFO_125_t1_chan_0_fifo_11; // t1[0](1, 1) @ unroll_index=52
        points_from_t1_to_t0_chan_0[53][1] = FIFO_125_t1_chan_0_fifo_11; // t1[0](0, 1) @ unroll_index=53
        points_from_t1_to_t0_chan_0[50][3] = FIFO_125_t1_chan_0_fifo_12; // t1[0](2, 1) @ unroll_index=50
        points_from_t1_to_t0_chan_0[51][2] = FIFO_125_t1_chan_0_fifo_12; // t1[0](1, 1) @ unroll_index=51
        points_from_t1_to_t0_chan_0[52][1] = FIFO_125_t1_chan_0_fifo_12; // t1[0](0, 1) @ unroll_index=52
        points_from_t1_to_t0_chan_0[49][3] = FIFO_125_t1_chan_0_fifo_13; // t1[0](2, 1) @ unroll_index=49
        points_from_t1_to_t0_chan_0[50][2] = FIFO_125_t1_chan_0_fifo_13; // t1[0](1, 1) @ unroll_index=50
        points_from_t1_to_t0_chan_0[51][1] = FIFO_125_t1_chan_0_fifo_13; // t1[0](0, 1) @ unroll_index=51
        points_from_t1_to_t0_chan_0[48][3] = FIFO_125_t1_chan_0_fifo_14; // t1[0](2, 1) @ unroll_index=48
        points_from_t1_to_t0_chan_0[49][2] = FIFO_125_t1_chan_0_fifo_14; // t1[0](1, 1) @ unroll_index=49
        points_from_t1_to_t0_chan_0[50][1] = FIFO_125_t1_chan_0_fifo_14; // t1[0](0, 1) @ unroll_index=50
        points_from_t1_to_t0_chan_0[48][2] = FIFO_125_t1_chan_0_fifo_15; // t1[0](1, 1) @ unroll_index=48
        points_from_t1_to_t0_chan_0[49][1] = FIFO_125_t1_chan_0_fifo_15; // t1[0](0, 1) @ unroll_index=49
        points_from_t1_to_t0_chan_0[47][3] = FIFO_125_t1_chan_0_fifo_15; // t1[0](2, 1) @ unroll_index=47
        points_from_t1_to_t0_chan_0[48][1] = FIFO_125_t1_chan_0_fifo_16; // t1[0](0, 1) @ unroll_index=48
        points_from_t1_to_t0_chan_0[46][3] = FIFO_125_t1_chan_0_fifo_16; // t1[0](2, 1) @ unroll_index=46
        points_from_t1_to_t0_chan_0[47][2] = FIFO_125_t1_chan_0_fifo_16; // t1[0](1, 1) @ unroll_index=47
        points_from_t1_to_t0_chan_0[45][3] = FIFO_125_t1_chan_0_fifo_17; // t1[0](2, 1) @ unroll_index=45
        points_from_t1_to_t0_chan_0[46][2] = FIFO_125_t1_chan_0_fifo_17; // t1[0](1, 1) @ unroll_index=46
        points_from_t1_to_t0_chan_0[47][1] = FIFO_125_t1_chan_0_fifo_17; // t1[0](0, 1) @ unroll_index=47
        points_from_t1_to_t0_chan_0[44][3] = FIFO_125_t1_chan_0_fifo_18; // t1[0](2, 1) @ unroll_index=44
        points_from_t1_to_t0_chan_0[45][2] = FIFO_125_t1_chan_0_fifo_18; // t1[0](1, 1) @ unroll_index=45
        points_from_t1_to_t0_chan_0[46][1] = FIFO_125_t1_chan_0_fifo_18; // t1[0](0, 1) @ unroll_index=46
        points_from_t1_to_t0_chan_0[43][3] = FIFO_125_t1_chan_0_fifo_19; // t1[0](2, 1) @ unroll_index=43
        points_from_t1_to_t0_chan_0[44][2] = FIFO_125_t1_chan_0_fifo_19; // t1[0](1, 1) @ unroll_index=44
        points_from_t1_to_t0_chan_0[45][1] = FIFO_125_t1_chan_0_fifo_19; // t1[0](0, 1) @ unroll_index=45
        points_from_t1_to_t0_chan_0[42][3] = FIFO_125_t1_chan_0_fifo_20; // t1[0](2, 1) @ unroll_index=42
        points_from_t1_to_t0_chan_0[43][2] = FIFO_125_t1_chan_0_fifo_20; // t1[0](1, 1) @ unroll_index=43
        points_from_t1_to_t0_chan_0[44][1] = FIFO_125_t1_chan_0_fifo_20; // t1[0](0, 1) @ unroll_index=44
        points_from_t1_to_t0_chan_0[41][3] = FIFO_125_t1_chan_0_fifo_21; // t1[0](2, 1) @ unroll_index=41
        points_from_t1_to_t0_chan_0[42][2] = FIFO_125_t1_chan_0_fifo_21; // t1[0](1, 1) @ unroll_index=42
        points_from_t1_to_t0_chan_0[43][1] = FIFO_125_t1_chan_0_fifo_21; // t1[0](0, 1) @ unroll_index=43
        points_from_t1_to_t0_chan_0[40][3] = FIFO_125_t1_chan_0_fifo_22; // t1[0](2, 1) @ unroll_index=40
        points_from_t1_to_t0_chan_0[41][2] = FIFO_125_t1_chan_0_fifo_22; // t1[0](1, 1) @ unroll_index=41
        points_from_t1_to_t0_chan_0[42][1] = FIFO_125_t1_chan_0_fifo_22; // t1[0](0, 1) @ unroll_index=42
        points_from_t1_to_t0_chan_0[40][2] = FIFO_125_t1_chan_0_fifo_23; // t1[0](1, 1) @ unroll_index=40
        points_from_t1_to_t0_chan_0[41][1] = FIFO_125_t1_chan_0_fifo_23; // t1[0](0, 1) @ unroll_index=41
        points_from_t1_to_t0_chan_0[39][3] = FIFO_125_t1_chan_0_fifo_23; // t1[0](2, 1) @ unroll_index=39
        points_from_t1_to_t0_chan_0[40][1] = FIFO_125_t1_chan_0_fifo_24; // t1[0](0, 1) @ unroll_index=40
        points_from_t1_to_t0_chan_0[38][3] = FIFO_125_t1_chan_0_fifo_24; // t1[0](2, 1) @ unroll_index=38
        points_from_t1_to_t0_chan_0[39][2] = FIFO_125_t1_chan_0_fifo_24; // t1[0](1, 1) @ unroll_index=39
        points_from_t1_to_t0_chan_0[37][3] = FIFO_125_t1_chan_0_fifo_25; // t1[0](2, 1) @ unroll_index=37
        points_from_t1_to_t0_chan_0[38][2] = FIFO_125_t1_chan_0_fifo_25; // t1[0](1, 1) @ unroll_index=38
        points_from_t1_to_t0_chan_0[39][1] = FIFO_125_t1_chan_0_fifo_25; // t1[0](0, 1) @ unroll_index=39
        points_from_t1_to_t0_chan_0[36][3] = FIFO_125_t1_chan_0_fifo_26; // t1[0](2, 1) @ unroll_index=36
        points_from_t1_to_t0_chan_0[37][2] = FIFO_125_t1_chan_0_fifo_26; // t1[0](1, 1) @ unroll_index=37
        points_from_t1_to_t0_chan_0[38][1] = FIFO_125_t1_chan_0_fifo_26; // t1[0](0, 1) @ unroll_index=38
        points_from_t1_to_t0_chan_0[35][3] = FIFO_125_t1_chan_0_fifo_27; // t1[0](2, 1) @ unroll_index=35
        points_from_t1_to_t0_chan_0[36][2] = FIFO_125_t1_chan_0_fifo_27; // t1[0](1, 1) @ unroll_index=36
        points_from_t1_to_t0_chan_0[37][1] = FIFO_125_t1_chan_0_fifo_27; // t1[0](0, 1) @ unroll_index=37
        points_from_t1_to_t0_chan_0[34][3] = FIFO_125_t1_chan_0_fifo_28; // t1[0](2, 1) @ unroll_index=34
        points_from_t1_to_t0_chan_0[35][2] = FIFO_125_t1_chan_0_fifo_28; // t1[0](1, 1) @ unroll_index=35
        points_from_t1_to_t0_chan_0[36][1] = FIFO_125_t1_chan_0_fifo_28; // t1[0](0, 1) @ unroll_index=36
        points_from_t1_to_t0_chan_0[33][3] = FIFO_125_t1_chan_0_fifo_29; // t1[0](2, 1) @ unroll_index=33
        points_from_t1_to_t0_chan_0[34][2] = FIFO_125_t1_chan_0_fifo_29; // t1[0](1, 1) @ unroll_index=34
        points_from_t1_to_t0_chan_0[35][1] = FIFO_125_t1_chan_0_fifo_29; // t1[0](0, 1) @ unroll_index=35
        points_from_t1_to_t0_chan_0[32][3] = FIFO_125_t1_chan_0_fifo_30; // t1[0](2, 1) @ unroll_index=32
        points_from_t1_to_t0_chan_0[33][2] = FIFO_125_t1_chan_0_fifo_30; // t1[0](1, 1) @ unroll_index=33
        points_from_t1_to_t0_chan_0[34][1] = FIFO_125_t1_chan_0_fifo_30; // t1[0](0, 1) @ unroll_index=34
        points_from_t1_to_t0_chan_0[32][2] = FIFO_125_t1_chan_0_fifo_31; // t1[0](1, 1) @ unroll_index=32
        points_from_t1_to_t0_chan_0[33][1] = FIFO_125_t1_chan_0_fifo_31; // t1[0](0, 1) @ unroll_index=33
        points_from_t1_to_t0_chan_0[31][3] = FIFO_125_t1_chan_0_fifo_31; // t1[0](2, 1) @ unroll_index=31
        points_from_t1_to_t0_chan_0[32][1] = FIFO_125_t1_chan_0_fifo_32; // t1[0](0, 1) @ unroll_index=32
        points_from_t1_to_t0_chan_0[30][3] = FIFO_125_t1_chan_0_fifo_32; // t1[0](2, 1) @ unroll_index=30
        points_from_t1_to_t0_chan_0[31][2] = FIFO_125_t1_chan_0_fifo_32; // t1[0](1, 1) @ unroll_index=31
        points_from_t1_to_t0_chan_0[29][3] = FIFO_125_t1_chan_0_fifo_33; // t1[0](2, 1) @ unroll_index=29
        points_from_t1_to_t0_chan_0[30][2] = FIFO_125_t1_chan_0_fifo_33; // t1[0](1, 1) @ unroll_index=30
        points_from_t1_to_t0_chan_0[31][1] = FIFO_125_t1_chan_0_fifo_33; // t1[0](0, 1) @ unroll_index=31
        points_from_t1_to_t0_chan_0[28][3] = FIFO_125_t1_chan_0_fifo_34; // t1[0](2, 1) @ unroll_index=28
        points_from_t1_to_t0_chan_0[29][2] = FIFO_125_t1_chan_0_fifo_34; // t1[0](1, 1) @ unroll_index=29
        points_from_t1_to_t0_chan_0[30][1] = FIFO_125_t1_chan_0_fifo_34; // t1[0](0, 1) @ unroll_index=30
        points_from_t1_to_t0_chan_0[27][3] = FIFO_125_t1_chan_0_fifo_35; // t1[0](2, 1) @ unroll_index=27
        points_from_t1_to_t0_chan_0[28][2] = FIFO_125_t1_chan_0_fifo_35; // t1[0](1, 1) @ unroll_index=28
        points_from_t1_to_t0_chan_0[29][1] = FIFO_125_t1_chan_0_fifo_35; // t1[0](0, 1) @ unroll_index=29
        points_from_t1_to_t0_chan_0[26][3] = FIFO_125_t1_chan_0_fifo_36; // t1[0](2, 1) @ unroll_index=26
        points_from_t1_to_t0_chan_0[27][2] = FIFO_125_t1_chan_0_fifo_36; // t1[0](1, 1) @ unroll_index=27
        points_from_t1_to_t0_chan_0[28][1] = FIFO_125_t1_chan_0_fifo_36; // t1[0](0, 1) @ unroll_index=28
        points_from_t1_to_t0_chan_0[25][3] = FIFO_125_t1_chan_0_fifo_37; // t1[0](2, 1) @ unroll_index=25
        points_from_t1_to_t0_chan_0[26][2] = FIFO_125_t1_chan_0_fifo_37; // t1[0](1, 1) @ unroll_index=26
        points_from_t1_to_t0_chan_0[27][1] = FIFO_125_t1_chan_0_fifo_37; // t1[0](0, 1) @ unroll_index=27
        points_from_t1_to_t0_chan_0[24][3] = FIFO_125_t1_chan_0_fifo_38; // t1[0](2, 1) @ unroll_index=24
        points_from_t1_to_t0_chan_0[25][2] = FIFO_125_t1_chan_0_fifo_38; // t1[0](1, 1) @ unroll_index=25
        points_from_t1_to_t0_chan_0[26][1] = FIFO_125_t1_chan_0_fifo_38; // t1[0](0, 1) @ unroll_index=26
        points_from_t1_to_t0_chan_0[24][2] = FIFO_125_t1_chan_0_fifo_39; // t1[0](1, 1) @ unroll_index=24
        points_from_t1_to_t0_chan_0[25][1] = FIFO_125_t1_chan_0_fifo_39; // t1[0](0, 1) @ unroll_index=25
        points_from_t1_to_t0_chan_0[23][3] = FIFO_125_t1_chan_0_fifo_39; // t1[0](2, 1) @ unroll_index=23
        points_from_t1_to_t0_chan_0[24][1] = FIFO_125_t1_chan_0_fifo_40; // t1[0](0, 1) @ unroll_index=24
        points_from_t1_to_t0_chan_0[22][3] = FIFO_125_t1_chan_0_fifo_40; // t1[0](2, 1) @ unroll_index=22
        points_from_t1_to_t0_chan_0[23][2] = FIFO_125_t1_chan_0_fifo_40; // t1[0](1, 1) @ unroll_index=23
        points_from_t1_to_t0_chan_0[21][3] = FIFO_125_t1_chan_0_fifo_41; // t1[0](2, 1) @ unroll_index=21
        points_from_t1_to_t0_chan_0[22][2] = FIFO_125_t1_chan_0_fifo_41; // t1[0](1, 1) @ unroll_index=22
        points_from_t1_to_t0_chan_0[23][1] = FIFO_125_t1_chan_0_fifo_41; // t1[0](0, 1) @ unroll_index=23
        points_from_t1_to_t0_chan_0[20][3] = FIFO_125_t1_chan_0_fifo_42; // t1[0](2, 1) @ unroll_index=20
        points_from_t1_to_t0_chan_0[21][2] = FIFO_125_t1_chan_0_fifo_42; // t1[0](1, 1) @ unroll_index=21
        points_from_t1_to_t0_chan_0[22][1] = FIFO_125_t1_chan_0_fifo_42; // t1[0](0, 1) @ unroll_index=22
        points_from_t1_to_t0_chan_0[19][3] = FIFO_125_t1_chan_0_fifo_43; // t1[0](2, 1) @ unroll_index=19
        points_from_t1_to_t0_chan_0[20][2] = FIFO_125_t1_chan_0_fifo_43; // t1[0](1, 1) @ unroll_index=20
        points_from_t1_to_t0_chan_0[21][1] = FIFO_125_t1_chan_0_fifo_43; // t1[0](0, 1) @ unroll_index=21
        points_from_t1_to_t0_chan_0[18][3] = FIFO_125_t1_chan_0_fifo_44; // t1[0](2, 1) @ unroll_index=18
        points_from_t1_to_t0_chan_0[19][2] = FIFO_125_t1_chan_0_fifo_44; // t1[0](1, 1) @ unroll_index=19
        points_from_t1_to_t0_chan_0[20][1] = FIFO_125_t1_chan_0_fifo_44; // t1[0](0, 1) @ unroll_index=20
        points_from_t1_to_t0_chan_0[17][3] = FIFO_125_t1_chan_0_fifo_45; // t1[0](2, 1) @ unroll_index=17
        points_from_t1_to_t0_chan_0[18][2] = FIFO_125_t1_chan_0_fifo_45; // t1[0](1, 1) @ unroll_index=18
        points_from_t1_to_t0_chan_0[19][1] = FIFO_125_t1_chan_0_fifo_45; // t1[0](0, 1) @ unroll_index=19
        points_from_t1_to_t0_chan_0[16][3] = FIFO_125_t1_chan_0_fifo_46; // t1[0](2, 1) @ unroll_index=16
        points_from_t1_to_t0_chan_0[17][2] = FIFO_125_t1_chan_0_fifo_46; // t1[0](1, 1) @ unroll_index=17
        points_from_t1_to_t0_chan_0[18][1] = FIFO_125_t1_chan_0_fifo_46; // t1[0](0, 1) @ unroll_index=18
        points_from_t1_to_t0_chan_0[16][2] = FIFO_125_t1_chan_0_fifo_47; // t1[0](1, 1) @ unroll_index=16
        points_from_t1_to_t0_chan_0[17][1] = FIFO_125_t1_chan_0_fifo_47; // t1[0](0, 1) @ unroll_index=17
        points_from_t1_to_t0_chan_0[15][3] = FIFO_125_t1_chan_0_fifo_47; // t1[0](2, 1) @ unroll_index=15
        points_from_t1_to_t0_chan_0[16][1] = FIFO_125_t1_chan_0_fifo_48; // t1[0](0, 1) @ unroll_index=16
        points_from_t1_to_t0_chan_0[14][3] = FIFO_125_t1_chan_0_fifo_48; // t1[0](2, 1) @ unroll_index=14
        points_from_t1_to_t0_chan_0[15][2] = FIFO_125_t1_chan_0_fifo_48; // t1[0](1, 1) @ unroll_index=15
        points_from_t1_to_t0_chan_0[13][3] = FIFO_125_t1_chan_0_fifo_49; // t1[0](2, 1) @ unroll_index=13
        points_from_t1_to_t0_chan_0[14][2] = FIFO_125_t1_chan_0_fifo_49; // t1[0](1, 1) @ unroll_index=14
        points_from_t1_to_t0_chan_0[15][1] = FIFO_125_t1_chan_0_fifo_49; // t1[0](0, 1) @ unroll_index=15
        points_from_t1_to_t0_chan_0[12][3] = FIFO_125_t1_chan_0_fifo_50; // t1[0](2, 1) @ unroll_index=12
        points_from_t1_to_t0_chan_0[13][2] = FIFO_125_t1_chan_0_fifo_50; // t1[0](1, 1) @ unroll_index=13
        points_from_t1_to_t0_chan_0[14][1] = FIFO_125_t1_chan_0_fifo_50; // t1[0](0, 1) @ unroll_index=14
        points_from_t1_to_t0_chan_0[11][3] = FIFO_125_t1_chan_0_fifo_51; // t1[0](2, 1) @ unroll_index=11
        points_from_t1_to_t0_chan_0[12][2] = FIFO_125_t1_chan_0_fifo_51; // t1[0](1, 1) @ unroll_index=12
        points_from_t1_to_t0_chan_0[13][1] = FIFO_125_t1_chan_0_fifo_51; // t1[0](0, 1) @ unroll_index=13
        points_from_t1_to_t0_chan_0[10][3] = FIFO_125_t1_chan_0_fifo_52; // t1[0](2, 1) @ unroll_index=10
        points_from_t1_to_t0_chan_0[11][2] = FIFO_125_t1_chan_0_fifo_52; // t1[0](1, 1) @ unroll_index=11
        points_from_t1_to_t0_chan_0[12][1] = FIFO_125_t1_chan_0_fifo_52; // t1[0](0, 1) @ unroll_index=12
        points_from_t1_to_t0_chan_0[9][3] = FIFO_125_t1_chan_0_fifo_53; // t1[0](2, 1) @ unroll_index=9
        points_from_t1_to_t0_chan_0[10][2] = FIFO_125_t1_chan_0_fifo_53; // t1[0](1, 1) @ unroll_index=10
        points_from_t1_to_t0_chan_0[11][1] = FIFO_125_t1_chan_0_fifo_53; // t1[0](0, 1) @ unroll_index=11
        points_from_t1_to_t0_chan_0[8][3] = FIFO_125_t1_chan_0_fifo_54; // t1[0](2, 1) @ unroll_index=8
        points_from_t1_to_t0_chan_0[9][2] = FIFO_125_t1_chan_0_fifo_54; // t1[0](1, 1) @ unroll_index=9
        points_from_t1_to_t0_chan_0[10][1] = FIFO_125_t1_chan_0_fifo_54; // t1[0](0, 1) @ unroll_index=10
        points_from_t1_to_t0_chan_0[8][2] = FIFO_125_t1_chan_0_fifo_55; // t1[0](1, 1) @ unroll_index=8
        points_from_t1_to_t0_chan_0[9][1] = FIFO_125_t1_chan_0_fifo_55; // t1[0](0, 1) @ unroll_index=9
        points_from_t1_to_t0_chan_0[7][3] = FIFO_125_t1_chan_0_fifo_55; // t1[0](2, 1) @ unroll_index=7
        points_from_t1_to_t0_chan_0[8][1] = FIFO_125_t1_chan_0_fifo_56; // t1[0](0, 1) @ unroll_index=8
        points_from_t1_to_t0_chan_0[6][3] = FIFO_125_t1_chan_0_fifo_56; // t1[0](2, 1) @ unroll_index=6
        points_from_t1_to_t0_chan_0[7][2] = FIFO_125_t1_chan_0_fifo_56; // t1[0](1, 1) @ unroll_index=7
        points_from_t1_to_t0_chan_0[5][3] = FIFO_125_t1_chan_0_fifo_57; // t1[0](2, 1) @ unroll_index=5
        points_from_t1_to_t0_chan_0[6][2] = FIFO_125_t1_chan_0_fifo_57; // t1[0](1, 1) @ unroll_index=6
        points_from_t1_to_t0_chan_0[7][1] = FIFO_125_t1_chan_0_fifo_57; // t1[0](0, 1) @ unroll_index=7
        points_from_t1_to_t0_chan_0[4][3] = FIFO_125_t1_chan_0_fifo_58; // t1[0](2, 1) @ unroll_index=4
        points_from_t1_to_t0_chan_0[5][2] = FIFO_125_t1_chan_0_fifo_58; // t1[0](1, 1) @ unroll_index=5
        points_from_t1_to_t0_chan_0[6][1] = FIFO_125_t1_chan_0_fifo_58; // t1[0](0, 1) @ unroll_index=6
        points_from_t1_to_t0_chan_0[3][3] = FIFO_125_t1_chan_0_fifo_59; // t1[0](2, 1) @ unroll_index=3
        points_from_t1_to_t0_chan_0[4][2] = FIFO_125_t1_chan_0_fifo_59; // t1[0](1, 1) @ unroll_index=4
        points_from_t1_to_t0_chan_0[5][1] = FIFO_125_t1_chan_0_fifo_59; // t1[0](0, 1) @ unroll_index=5
        points_from_t1_to_t0_chan_0[2][3] = FIFO_125_t1_chan_0_fifo_60; // t1[0](2, 1) @ unroll_index=2
        points_from_t1_to_t0_chan_0[3][2] = FIFO_125_t1_chan_0_fifo_60; // t1[0](1, 1) @ unroll_index=3
        points_from_t1_to_t0_chan_0[4][1] = FIFO_125_t1_chan_0_fifo_60; // t1[0](0, 1) @ unroll_index=4
        points_from_t1_to_t0_chan_0[1][3] = FIFO_125_t1_chan_0_fifo_61; // t1[0](2, 1) @ unroll_index=1
        points_from_t1_to_t0_chan_0[2][2] = FIFO_125_t1_chan_0_fifo_61; // t1[0](1, 1) @ unroll_index=2
        points_from_t1_to_t0_chan_0[3][1] = FIFO_125_t1_chan_0_fifo_61; // t1[0](0, 1) @ unroll_index=3
        points_from_t1_to_t0_chan_0[0][3] = FIFO_125_t1_chan_0_fifo_62; // t1[0](2, 1) @ unroll_index=0
        points_from_t1_to_t0_chan_0[1][2] = FIFO_125_t1_chan_0_fifo_62; // t1[0](1, 1) @ unroll_index=1
        points_from_t1_to_t0_chan_0[2][1] = FIFO_125_t1_chan_0_fifo_62; // t1[0](0, 1) @ unroll_index=2
        points_from_t1_to_t0_chan_0[62][0] = FIFO_125_t1_chan_0_fifo_63; // t1[0](1, 0) @ unroll_index=62
        points_from_t1_to_t0_chan_0[61][0] = FIFO_125_t1_chan_0_fifo_64; // t1[0](1, 0) @ unroll_index=61
        points_from_t1_to_t0_chan_0[60][0] = FIFO_125_t1_chan_0_fifo_65; // t1[0](1, 0) @ unroll_index=60
        points_from_t1_to_t0_chan_0[59][0] = FIFO_125_t1_chan_0_fifo_66; // t1[0](1, 0) @ unroll_index=59
        points_from_t1_to_t0_chan_0[58][0] = FIFO_125_t1_chan_0_fifo_67; // t1[0](1, 0) @ unroll_index=58
        points_from_t1_to_t0_chan_0[57][0] = FIFO_125_t1_chan_0_fifo_68; // t1[0](1, 0) @ unroll_index=57
        points_from_t1_to_t0_chan_0[56][0] = FIFO_125_t1_chan_0_fifo_69; // t1[0](1, 0) @ unroll_index=56
        points_from_t1_to_t0_chan_0[55][0] = FIFO_125_t1_chan_0_fifo_70; // t1[0](1, 0) @ unroll_index=55
        points_from_t1_to_t0_chan_0[54][0] = FIFO_125_t1_chan_0_fifo_71; // t1[0](1, 0) @ unroll_index=54
        points_from_t1_to_t0_chan_0[53][0] = FIFO_125_t1_chan_0_fifo_72; // t1[0](1, 0) @ unroll_index=53
        points_from_t1_to_t0_chan_0[52][0] = FIFO_125_t1_chan_0_fifo_73; // t1[0](1, 0) @ unroll_index=52
        points_from_t1_to_t0_chan_0[51][0] = FIFO_125_t1_chan_0_fifo_74; // t1[0](1, 0) @ unroll_index=51
        points_from_t1_to_t0_chan_0[50][0] = FIFO_125_t1_chan_0_fifo_75; // t1[0](1, 0) @ unroll_index=50
        points_from_t1_to_t0_chan_0[49][0] = FIFO_125_t1_chan_0_fifo_76; // t1[0](1, 0) @ unroll_index=49
        points_from_t1_to_t0_chan_0[48][0] = FIFO_125_t1_chan_0_fifo_77; // t1[0](1, 0) @ unroll_index=48
        points_from_t1_to_t0_chan_0[47][0] = FIFO_125_t1_chan_0_fifo_78; // t1[0](1, 0) @ unroll_index=47
        points_from_t1_to_t0_chan_0[46][0] = FIFO_125_t1_chan_0_fifo_79; // t1[0](1, 0) @ unroll_index=46
        points_from_t1_to_t0_chan_0[45][0] = FIFO_125_t1_chan_0_fifo_80; // t1[0](1, 0) @ unroll_index=45
        points_from_t1_to_t0_chan_0[44][0] = FIFO_125_t1_chan_0_fifo_81; // t1[0](1, 0) @ unroll_index=44
        points_from_t1_to_t0_chan_0[43][0] = FIFO_125_t1_chan_0_fifo_82; // t1[0](1, 0) @ unroll_index=43
        points_from_t1_to_t0_chan_0[42][0] = FIFO_125_t1_chan_0_fifo_83; // t1[0](1, 0) @ unroll_index=42
        points_from_t1_to_t0_chan_0[41][0] = FIFO_125_t1_chan_0_fifo_84; // t1[0](1, 0) @ unroll_index=41
        points_from_t1_to_t0_chan_0[40][0] = FIFO_125_t1_chan_0_fifo_85; // t1[0](1, 0) @ unroll_index=40
        points_from_t1_to_t0_chan_0[39][0] = FIFO_125_t1_chan_0_fifo_86; // t1[0](1, 0) @ unroll_index=39
        points_from_t1_to_t0_chan_0[38][0] = FIFO_125_t1_chan_0_fifo_87; // t1[0](1, 0) @ unroll_index=38
        points_from_t1_to_t0_chan_0[37][0] = FIFO_125_t1_chan_0_fifo_88; // t1[0](1, 0) @ unroll_index=37
        points_from_t1_to_t0_chan_0[36][0] = FIFO_125_t1_chan_0_fifo_89; // t1[0](1, 0) @ unroll_index=36
        points_from_t1_to_t0_chan_0[35][0] = FIFO_125_t1_chan_0_fifo_90; // t1[0](1, 0) @ unroll_index=35
        points_from_t1_to_t0_chan_0[34][0] = FIFO_125_t1_chan_0_fifo_91; // t1[0](1, 0) @ unroll_index=34
        points_from_t1_to_t0_chan_0[33][0] = FIFO_125_t1_chan_0_fifo_92; // t1[0](1, 0) @ unroll_index=33
        points_from_t1_to_t0_chan_0[32][0] = FIFO_125_t1_chan_0_fifo_93; // t1[0](1, 0) @ unroll_index=32
        points_from_t1_to_t0_chan_0[31][0] = FIFO_125_t1_chan_0_fifo_94; // t1[0](1, 0) @ unroll_index=31
        points_from_t1_to_t0_chan_0[30][0] = FIFO_125_t1_chan_0_fifo_95; // t1[0](1, 0) @ unroll_index=30
        points_from_t1_to_t0_chan_0[29][0] = FIFO_125_t1_chan_0_fifo_96; // t1[0](1, 0) @ unroll_index=29
        points_from_t1_to_t0_chan_0[28][0] = FIFO_125_t1_chan_0_fifo_97; // t1[0](1, 0) @ unroll_index=28
        points_from_t1_to_t0_chan_0[27][0] = FIFO_125_t1_chan_0_fifo_98; // t1[0](1, 0) @ unroll_index=27
        points_from_t1_to_t0_chan_0[26][0] = FIFO_125_t1_chan_0_fifo_99; // t1[0](1, 0) @ unroll_index=26
        points_from_t1_to_t0_chan_0[25][0] = FIFO_125_t1_chan_0_fifo_100; // t1[0](1, 0) @ unroll_index=25
        points_from_t1_to_t0_chan_0[24][0] = FIFO_125_t1_chan_0_fifo_101; // t1[0](1, 0) @ unroll_index=24
        points_from_t1_to_t0_chan_0[23][0] = FIFO_125_t1_chan_0_fifo_102; // t1[0](1, 0) @ unroll_index=23
        points_from_t1_to_t0_chan_0[22][0] = FIFO_125_t1_chan_0_fifo_103; // t1[0](1, 0) @ unroll_index=22
        points_from_t1_to_t0_chan_0[21][0] = FIFO_125_t1_chan_0_fifo_104; // t1[0](1, 0) @ unroll_index=21
        points_from_t1_to_t0_chan_0[20][0] = FIFO_125_t1_chan_0_fifo_105; // t1[0](1, 0) @ unroll_index=20
        points_from_t1_to_t0_chan_0[19][0] = FIFO_125_t1_chan_0_fifo_106; // t1[0](1, 0) @ unroll_index=19
        points_from_t1_to_t0_chan_0[18][0] = FIFO_125_t1_chan_0_fifo_107; // t1[0](1, 0) @ unroll_index=18
        points_from_t1_to_t0_chan_0[17][0] = FIFO_125_t1_chan_0_fifo_108; // t1[0](1, 0) @ unroll_index=17
        points_from_t1_to_t0_chan_0[16][0] = FIFO_125_t1_chan_0_fifo_109; // t1[0](1, 0) @ unroll_index=16
        points_from_t1_to_t0_chan_0[15][0] = FIFO_125_t1_chan_0_fifo_110; // t1[0](1, 0) @ unroll_index=15
        points_from_t1_to_t0_chan_0[14][0] = FIFO_125_t1_chan_0_fifo_111; // t1[0](1, 0) @ unroll_index=14
        points_from_t1_to_t0_chan_0[13][0] = FIFO_125_t1_chan_0_fifo_112; // t1[0](1, 0) @ unroll_index=13
        points_from_t1_to_t0_chan_0[12][0] = FIFO_125_t1_chan_0_fifo_113; // t1[0](1, 0) @ unroll_index=12
        points_from_t1_to_t0_chan_0[11][0] = FIFO_125_t1_chan_0_fifo_114; // t1[0](1, 0) @ unroll_index=11
        points_from_t1_to_t0_chan_0[10][0] = FIFO_125_t1_chan_0_fifo_115; // t1[0](1, 0) @ unroll_index=10
        points_from_t1_to_t0_chan_0[9][0] = FIFO_125_t1_chan_0_fifo_116; // t1[0](1, 0) @ unroll_index=9
        points_from_t1_to_t0_chan_0[8][0] = FIFO_125_t1_chan_0_fifo_117; // t1[0](1, 0) @ unroll_index=8
        points_from_t1_to_t0_chan_0[7][0] = FIFO_125_t1_chan_0_fifo_118; // t1[0](1, 0) @ unroll_index=7
        points_from_t1_to_t0_chan_0[6][0] = FIFO_125_t1_chan_0_fifo_119; // t1[0](1, 0) @ unroll_index=6
        points_from_t1_to_t0_chan_0[5][0] = FIFO_125_t1_chan_0_fifo_120; // t1[0](1, 0) @ unroll_index=5
        points_from_t1_to_t0_chan_0[4][0] = FIFO_125_t1_chan_0_fifo_121; // t1[0](1, 0) @ unroll_index=4
        points_from_t1_to_t0_chan_0[3][0] = FIFO_125_t1_chan_0_fifo_122; // t1[0](1, 0) @ unroll_index=3
        points_from_t1_to_t0_chan_0[2][0] = FIFO_125_t1_chan_0_fifo_123; // t1[0](1, 0) @ unroll_index=2
        points_from_t1_to_t0_chan_0[1][0] = FIFO_125_t1_chan_0_fifo_124; // t1[0](1, 0) @ unroll_index=1
        points_from_t1_to_t0_chan_0[0][0] = FIFO_125_t1_chan_0_fifo_125; // t1[0](1, 0) @ unroll_index=0
        points_from_t1_to_t0_chan_0[63][3] = FIFO_124_t1_chan_0_fifo_0; // t1[0](2, 1) @ unroll_index=63
        points_from_t1_to_t0_chan_0[63][0] = FIFO_124_t1_chan_0_fifo_1; // t1[0](1, 0) @ unroll_index=63

compute_t0_unrolled:
        for(int32_t unroll_index = 0; unroll_index < UNROLL_FACTOR; ++unroll_index)
        {
#pragma HLS unroll
#pragma HLS latency min=1
            float& load_t1_for_t0_chan_0_at_1_0 = points_from_t1_to_t0_chan_0[unroll_index][0];
            float& load_t1_for_t0_chan_0_at_0_1 = points_from_t1_to_t0_chan_0[unroll_index][1];
            float& load_t1_for_t0_chan_0_at_1_1 = points_from_t1_to_t0_chan_0[unroll_index][2];
            float& load_t1_for_t0_chan_0_at_2_1 = points_from_t1_to_t0_chan_0[unroll_index][3];
            float& load_t1_for_t0_chan_0_at_1_2 = points_from_t1_to_t0_chan_0[unroll_index][4];

            float result_chan_0;
            float assign_0 = load_t1_for_t0_chan_0_at_1_2;
            float assign_1 = load_t1_for_t0_chan_0_at_2_1;
            float assign_2[1];
#pragma HLS resource variable=assign_2 latency=1 core=RAM_2P_LUTRAM
            {
#pragma HLS latency min=1
                assign_2[0] = assign_0 + assign_1;
            }
            float assign_3 = assign_2[0];
            float assign_4 = load_t1_for_t0_chan_0_at_1_1;
            float assign_5[1];
#pragma HLS resource variable=assign_5 latency=1 core=RAM_2P_LUTRAM
            {
#pragma HLS latency min=1
                assign_5[0] = assign_3 + assign_4;
            }
            float assign_6 = assign_5[0];
            float assign_7 = load_t1_for_t0_chan_0_at_1_0;
            float assign_8[1];
#pragma HLS resource variable=assign_8 latency=1 core=RAM_2P_LUTRAM
            {
#pragma HLS latency min=1
                assign_8[0] = assign_6 + assign_7;
            }
            float assign_9 = assign_8[0];
            float assign_10 = load_t1_for_t0_chan_0_at_0_1;
            float assign_11[1];
#pragma HLS resource variable=assign_11 latency=1 core=RAM_2P_LUTRAM
            {
#pragma HLS latency min=1
                assign_11[0] = assign_9 + assign_10;
            }
            float assign_12 = assign_11[0];
            float assign_13 = (assign_12);
            float assign_14 = 0.2f;
            float assign_15[1];
#pragma HLS resource variable=assign_15 latency=1 core=RAM_2P_LUTRAM
            {
#pragma HLS latency min=10
                assign_15[0] = assign_13 * assign_14;
            }
            float assign_16 = assign_15[0];
            result_chan_0 = assign_16;

            buffer_t0_chan_0[unroll_index] = result_chan_0;
        } // unroll_index

        // move reuse chain 0 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[125][FIFO_125_t1_ptr] = FF_t1_chan_0[0];
        }
        {
#pragma HLS latency min=1
            FF_t1_chan_0[0] = FIFO_124_t1_chan_0_fifo_0;
        }
        {
#pragma HLS latency min=1
            FIFO_124_t1_chan_0[0][FIFO_124_t1_ptr] = buffer_t1_chan_0[0];
        }

        // move reuse chain 1 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[124][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_62;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[62][FIFO_125_t1_ptr] = buffer_t1_chan_0[1];
        }

        // move reuse chain 2 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[123][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_61;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[61][FIFO_125_t1_ptr] = buffer_t1_chan_0[2];
        }

        // move reuse chain 3 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[122][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_60;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[60][FIFO_125_t1_ptr] = buffer_t1_chan_0[3];
        }

        // move reuse chain 4 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[121][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_59;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[59][FIFO_125_t1_ptr] = buffer_t1_chan_0[4];
        }

        // move reuse chain 5 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[120][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_58;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[58][FIFO_125_t1_ptr] = buffer_t1_chan_0[5];
        }

        // move reuse chain 6 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[119][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_57;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[57][FIFO_125_t1_ptr] = buffer_t1_chan_0[6];
        }

        // move reuse chain 7 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[118][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_56;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[56][FIFO_125_t1_ptr] = buffer_t1_chan_0[7];
        }

        // move reuse chain 8 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[117][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_55;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[55][FIFO_125_t1_ptr] = buffer_t1_chan_0[8];
        }

        // move reuse chain 9 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[116][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_54;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[54][FIFO_125_t1_ptr] = buffer_t1_chan_0[9];
        }

        // move reuse chain 10 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[115][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_53;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[53][FIFO_125_t1_ptr] = buffer_t1_chan_0[10];
        }

        // move reuse chain 11 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[114][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_52;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[52][FIFO_125_t1_ptr] = buffer_t1_chan_0[11];
        }

        // move reuse chain 12 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[113][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_51;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[51][FIFO_125_t1_ptr] = buffer_t1_chan_0[12];
        }

        // move reuse chain 13 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[112][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_50;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[50][FIFO_125_t1_ptr] = buffer_t1_chan_0[13];
        }

        // move reuse chain 14 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[111][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_49;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[49][FIFO_125_t1_ptr] = buffer_t1_chan_0[14];
        }

        // move reuse chain 15 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[110][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_48;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[48][FIFO_125_t1_ptr] = buffer_t1_chan_0[15];
        }

        // move reuse chain 16 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[109][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_47;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[47][FIFO_125_t1_ptr] = buffer_t1_chan_0[16];
        }

        // move reuse chain 17 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[108][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_46;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[46][FIFO_125_t1_ptr] = buffer_t1_chan_0[17];
        }

        // move reuse chain 18 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[107][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_45;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[45][FIFO_125_t1_ptr] = buffer_t1_chan_0[18];
        }

        // move reuse chain 19 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[106][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_44;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[44][FIFO_125_t1_ptr] = buffer_t1_chan_0[19];
        }

        // move reuse chain 20 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[105][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_43;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[43][FIFO_125_t1_ptr] = buffer_t1_chan_0[20];
        }

        // move reuse chain 21 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[104][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_42;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[42][FIFO_125_t1_ptr] = buffer_t1_chan_0[21];
        }

        // move reuse chain 22 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[103][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_41;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[41][FIFO_125_t1_ptr] = buffer_t1_chan_0[22];
        }

        // move reuse chain 23 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[102][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_40;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[40][FIFO_125_t1_ptr] = buffer_t1_chan_0[23];
        }

        // move reuse chain 24 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[101][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_39;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[39][FIFO_125_t1_ptr] = buffer_t1_chan_0[24];
        }

        // move reuse chain 25 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[100][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_38;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[38][FIFO_125_t1_ptr] = buffer_t1_chan_0[25];
        }

        // move reuse chain 26 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[99][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_37;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[37][FIFO_125_t1_ptr] = buffer_t1_chan_0[26];
        }

        // move reuse chain 27 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[98][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_36;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[36][FIFO_125_t1_ptr] = buffer_t1_chan_0[27];
        }

        // move reuse chain 28 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[97][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_35;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[35][FIFO_125_t1_ptr] = buffer_t1_chan_0[28];
        }

        // move reuse chain 29 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[96][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_34;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[34][FIFO_125_t1_ptr] = buffer_t1_chan_0[29];
        }

        // move reuse chain 30 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[95][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_33;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[33][FIFO_125_t1_ptr] = buffer_t1_chan_0[30];
        }

        // move reuse chain 31 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[94][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_32;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[32][FIFO_125_t1_ptr] = buffer_t1_chan_0[31];
        }

        // move reuse chain 32 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[93][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_31;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[31][FIFO_125_t1_ptr] = buffer_t1_chan_0[32];
        }

        // move reuse chain 33 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[92][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_30;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[30][FIFO_125_t1_ptr] = buffer_t1_chan_0[33];
        }

        // move reuse chain 34 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[91][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_29;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[29][FIFO_125_t1_ptr] = buffer_t1_chan_0[34];
        }

        // move reuse chain 35 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[90][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_28;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[28][FIFO_125_t1_ptr] = buffer_t1_chan_0[35];
        }

        // move reuse chain 36 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[89][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_27;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[27][FIFO_125_t1_ptr] = buffer_t1_chan_0[36];
        }

        // move reuse chain 37 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[88][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_26;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[26][FIFO_125_t1_ptr] = buffer_t1_chan_0[37];
        }

        // move reuse chain 38 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[87][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_25;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[25][FIFO_125_t1_ptr] = buffer_t1_chan_0[38];
        }

        // move reuse chain 39 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[86][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_24;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[24][FIFO_125_t1_ptr] = buffer_t1_chan_0[39];
        }

        // move reuse chain 40 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[85][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_23;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[23][FIFO_125_t1_ptr] = buffer_t1_chan_0[40];
        }

        // move reuse chain 41 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[84][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_22;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[22][FIFO_125_t1_ptr] = buffer_t1_chan_0[41];
        }

        // move reuse chain 42 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[83][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_21;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[21][FIFO_125_t1_ptr] = buffer_t1_chan_0[42];
        }

        // move reuse chain 43 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[82][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_20;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[20][FIFO_125_t1_ptr] = buffer_t1_chan_0[43];
        }

        // move reuse chain 44 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[81][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_19;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[19][FIFO_125_t1_ptr] = buffer_t1_chan_0[44];
        }

        // move reuse chain 45 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[80][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_18;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[18][FIFO_125_t1_ptr] = buffer_t1_chan_0[45];
        }

        // move reuse chain 46 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[79][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_17;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[17][FIFO_125_t1_ptr] = buffer_t1_chan_0[46];
        }

        // move reuse chain 47 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[78][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_16;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[16][FIFO_125_t1_ptr] = buffer_t1_chan_0[47];
        }

        // move reuse chain 48 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[77][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_15;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[15][FIFO_125_t1_ptr] = buffer_t1_chan_0[48];
        }

        // move reuse chain 49 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[76][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_14;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[14][FIFO_125_t1_ptr] = buffer_t1_chan_0[49];
        }

        // move reuse chain 50 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[75][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_13;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[13][FIFO_125_t1_ptr] = buffer_t1_chan_0[50];
        }

        // move reuse chain 51 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[74][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_12;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[12][FIFO_125_t1_ptr] = buffer_t1_chan_0[51];
        }

        // move reuse chain 52 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[73][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_11;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[11][FIFO_125_t1_ptr] = buffer_t1_chan_0[52];
        }

        // move reuse chain 53 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[72][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_10;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[10][FIFO_125_t1_ptr] = buffer_t1_chan_0[53];
        }

        // move reuse chain 54 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[71][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_9;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[9][FIFO_125_t1_ptr] = buffer_t1_chan_0[54];
        }

        // move reuse chain 55 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[70][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_8;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[8][FIFO_125_t1_ptr] = buffer_t1_chan_0[55];
        }

        // move reuse chain 56 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[69][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_7;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[7][FIFO_125_t1_ptr] = buffer_t1_chan_0[56];
        }

        // move reuse chain 57 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[68][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_6;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[6][FIFO_125_t1_ptr] = buffer_t1_chan_0[57];
        }

        // move reuse chain 58 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[67][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_5;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[5][FIFO_125_t1_ptr] = buffer_t1_chan_0[58];
        }

        // move reuse chain 59 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[66][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_4;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[4][FIFO_125_t1_ptr] = buffer_t1_chan_0[59];
        }

        // move reuse chain 60 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[65][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_3;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[3][FIFO_125_t1_ptr] = buffer_t1_chan_0[60];
        }

        // move reuse chain 61 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[64][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_2;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[2][FIFO_125_t1_ptr] = buffer_t1_chan_0[61];
        }

        // move reuse chain 62 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[63][FIFO_125_t1_ptr] = FIFO_125_t1_chan_0_fifo_1;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[1][FIFO_125_t1_ptr] = buffer_t1_chan_0[62];
        }

        // move reuse chain 63 for buffer t1
        {
#pragma HLS latency min=1
            FIFO_124_t1_chan_0[1][FIFO_124_t1_ptr] = FF_t1_chan_0[1];
        }
        {
#pragma HLS latency min=1
            FF_t1_chan_0[1] = FIFO_125_t1_chan_0_fifo_0;
        }
        {
#pragma HLS latency min=1
            FIFO_125_t1_chan_0[0][FIFO_125_t1_ptr] = buffer_t1_chan_0[63];
        }

        // move FIFO ptrs for buffer t1
        {
#pragma HLS latency min=1
            FIFO_125_t1_ptr = FIFO_125_t1_ptr==uint8_t(125-1) ? 0 : FIFO_125_t1_ptr+1;
        }
        {
#pragma HLS latency min=1
            FIFO_124_t1_ptr = FIFO_124_t1_ptr==uint8_t(124-1) ? 0 : FIFO_124_t1_ptr+1;
        }
        {
            ap_uint<BURST_WIDTH> tmp_chan_0_bank_0, tmp_chan_0_bank_1, tmp_chan_0_bank_2, tmp_chan_0_bank_3;
store_coalesced:
            for(int j = 0; j < BURST_WIDTH/32; ++j)
            {
#pragma HLS unroll
                float raw_bits_chan_0_bank_0 = buffer_t0_chan_0[BURST_WIDTH/32*4*0+j*4+0];
                tmp_chan_0_bank_0((j+1)*32-1, j*32) = *(uint32_t*)(&raw_bits_chan_0_bank_0);
                float raw_bits_chan_0_bank_1 = buffer_t0_chan_0[BURST_WIDTH/32*4*0+j*4+1];
                tmp_chan_0_bank_1((j+1)*32-1, j*32) = *(uint32_t*)(&raw_bits_chan_0_bank_1);
                float raw_bits_chan_0_bank_2 = buffer_t0_chan_0[BURST_WIDTH/32*4*0+j*4+2];
                tmp_chan_0_bank_2((j+1)*32-1, j*32) = *(uint32_t*)(&raw_bits_chan_0_bank_2);
                float raw_bits_chan_0_bank_3 = buffer_t0_chan_0[BURST_WIDTH/32*4*0+j*4+3];
                tmp_chan_0_bank_3((j+1)*32-1, j*32) = *(uint32_t*)(&raw_bits_chan_0_bank_3);
            }
            to_chan_0_bank_0.write(tmp_chan_0_bank_0);
            to_chan_0_bank_1.write(tmp_chan_0_bank_1);
            to_chan_0_bank_2.write(tmp_chan_0_bank_2);
            to_chan_0_bank_3.write(tmp_chan_0_bank_3);
        }
    }
}


void jacobi2d_kernel(
    tlp::mmap<ap_uint<BURST_WIDTH> > var_output_0_0,
    tlp::mmap<ap_uint<BURST_WIDTH> > var_output_0_1,
    tlp::mmap<ap_uint<BURST_WIDTH> > var_output_0_2,
    tlp::mmap<ap_uint<BURST_WIDTH> > var_output_0_3,
    tlp::mmap<ap_uint<BURST_WIDTH> > var_input_0_0,
    tlp::mmap<ap_uint<BURST_WIDTH> > var_input_0_1,
    tlp::mmap<ap_uint<BURST_WIDTH> > var_input_0_2,
    tlp::mmap<ap_uint<BURST_WIDTH> > var_input_0_3,
    int64_t coalesced_data_num,
    int64_t tile_data_num,
    int32_t tile_num_dim_0,
    int32_t input_size_dim_0,
    int32_t input_size_dim_1)
{

    tlp::stream<ap_uint<BURST_WIDTH>, 32 >  input_stream_0_0( "input_stream_0_0");
    tlp::stream<ap_uint<BURST_WIDTH>, 32 >  input_stream_0_1( "input_stream_0_1");
    tlp::stream<ap_uint<BURST_WIDTH>, 32 >  input_stream_0_2( "input_stream_0_2");
    tlp::stream<ap_uint<BURST_WIDTH>, 32 >  input_stream_0_3( "input_stream_0_3");
    tlp::stream<ap_uint<BURST_WIDTH>, 32 > output_stream_0_0("output_stream_0_0");
    tlp::stream<ap_uint<BURST_WIDTH>, 32 > output_stream_0_1("output_stream_0_1");
    tlp::stream<ap_uint<BURST_WIDTH>, 32 > output_stream_0_2("output_stream_0_2");
    tlp::stream<ap_uint<BURST_WIDTH>, 32 > output_stream_0_3("output_stream_0_3");

    tlp::stream<ap_uint<BURST_WIDTH>, 32 > output_stream_1_0("output_stream_1_0");
    tlp::stream<ap_uint<BURST_WIDTH>, 32 > output_stream_1_1("output_stream_1_1");
    tlp::stream<ap_uint<BURST_WIDTH>, 32 > output_stream_1_2("output_stream_1_2");
    tlp::stream<ap_uint<BURST_WIDTH>, 32 > output_stream_1_3("output_stream_1_3");

    tlp::stream<ap_uint<BURST_WIDTH>, 32 > output_stream_2_0("output_stream_2_0");
    tlp::stream<ap_uint<BURST_WIDTH>, 32 > output_stream_2_1("output_stream_2_1");
    tlp::stream<ap_uint<BURST_WIDTH>, 32 > output_stream_2_2("output_stream_2_2");
    tlp::stream<ap_uint<BURST_WIDTH>, 32 > output_stream_2_3("output_stream_2_3");

    tlp::stream<ap_uint<BURST_WIDTH>, 32 > output_stream_3_0("output_stream_3_0");
    tlp::stream<ap_uint<BURST_WIDTH>, 32 > output_stream_3_1("output_stream_3_1");
    tlp::stream<ap_uint<BURST_WIDTH>, 32 > output_stream_3_2("output_stream_3_2");
    tlp::stream<ap_uint<BURST_WIDTH>, 32 > output_stream_3_3("output_stream_3_3");

    tlp::task()
      .invoke<0>( load, input_stream_0_0, var_input_0_0, coalesced_data_num)
      .invoke<0>( load, input_stream_0_1, var_input_0_1, coalesced_data_num)
      .invoke<0>( load, input_stream_0_2, var_input_0_2, coalesced_data_num)
      .invoke<0>( load, input_stream_0_3, var_input_0_3, coalesced_data_num)
      .invoke<0>( compute, output_stream_0_0, output_stream_0_1, output_stream_0_2, output_stream_0_3, input_stream_0_0, input_stream_0_1, input_stream_0_2, input_stream_0_3, coalesced_data_num, tile_data_num, tile_num_dim_0, input_size_dim_0, input_size_dim_1)
      .invoke<0>( compute, output_stream_1_0, output_stream_1_1, output_stream_1_2, output_stream_1_3, output_stream_0_0, output_stream_0_1, output_stream_0_2, output_stream_0_3, coalesced_data_num, tile_data_num, tile_num_dim_0, input_size_dim_0, input_size_dim_1)
      .invoke<0>( compute, output_stream_2_0, output_stream_2_1, output_stream_2_2, output_stream_2_3, output_stream_1_0, output_stream_1_1, output_stream_1_2, output_stream_1_3, coalesced_data_num, tile_data_num, tile_num_dim_0, input_size_dim_0, input_size_dim_1)
      .invoke<0>( compute, output_stream_3_0, output_stream_3_1, output_stream_3_2, output_stream_3_3, output_stream_2_0, output_stream_2_1, output_stream_2_2, output_stream_2_3, coalesced_data_num, tile_data_num, tile_num_dim_0, input_size_dim_0, input_size_dim_1)
      .invoke<0>( store, var_output_0_0, output_stream_3_0, coalesced_data_num)
      .invoke<0>( store, var_output_0_1, output_stream_3_1, coalesced_data_num)
      .invoke<0>( store, var_output_0_2, output_stream_3_2, coalesced_data_num)
      .invoke<0>( store, var_output_0_3, output_stream_3_3, coalesced_data_num)
    ;
}

