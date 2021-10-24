#include <ap_int.h>
#include <hls_stream.h>

#define min(x,y) ((x < y) ? x : y)
#define max(x,y) ((x > y) ? x : y)

/* Data Type */
typedef int A_t1;
typedef int B_t1;
typedef int C_t1;
typedef ap_uint<512> A_t16;
typedef ap_uint<256> A_t8;
typedef ap_uint<512> B_t16;
typedef ap_uint<256> B_t8;
typedef ap_uint<512> C_t16;
typedef ap_uint<128> C_t4;
/* Data Type */

extern "C" {
void kernel0(A_t16 *A, B_t16 *B, C_t16 *C);
}
void A_IO_L2_in_intra_trans(int idx, A_t16 local_A[16][16], hls::stream<A_t8> &fifo_A_local_out, bool intra_trans_en);
void A_IO_L2_in_inter_trans(int idx, A_t16 local_A[16][16], hls::stream<A_t16> &fifo_A_in, hls::stream<A_t16> &fifo_A_out, bool inter_trans_en);
void A_IO_L2_in_inter_trans_boundary(int idx, A_t16 local_A[16][16], hls::stream<A_t16> &fifo_A_in, bool inter_trans_en);
void B_IO_L2_in_intra_trans(int idx, B_t16 local_B[64][16], hls::stream<B_t8> &fifo_B_local_out, bool intra_trans_en);
void B_IO_L2_in_inter_trans(int idx, B_t16 local_B[64][16], hls::stream<B_t16> &fifo_B_in, hls::stream<B_t16> &fifo_B_out, bool inter_trans_en);
void B_IO_L2_in_inter_trans_boundary(int idx, B_t16 local_B[64][16], hls::stream<B_t16> &fifo_B_in, bool inter_trans_en);
void PE_wrapper(int idx, int idy, hls::stream<A_t8> &fifo_A_in, hls::stream<A_t8> &fifo_A_out, hls::stream<B_t8> &fifo_B_in, hls::stream<B_t8> &fifo_B_out, hls::stream<int> &fifo_C_drain_out);
void C_drain_IO_L1_out_intra_trans(int idx, int idy, C_t4 local_C[16][16], hls::stream<int> &fifo_C_drain_local_in);
void C_drain_IO_L1_out_inter_trans(int idx, int idy, C_t4 local_C[16][16], hls::stream<C_t4> &fifo_C_drain_in, hls::stream<C_t4> &fifo_C_drain_out);
void C_drain_IO_L1_out_inter_trans_boundary(int idx, int idy, C_t4 local_C[16][16], hls::stream<C_t4> &fifo_C_drain_out);
void C_drain_IO_L1_out_wrapper(int idx, int idy, hls::stream<C_t4> &fifo_C_drain_in, hls::stream<C_t4> &fifo_C_drain_out, hls::stream<int> &fifo_C_drain_local_in);
void C_drain_IO_L1_out_boundary_wrapper(int idx, int idy, hls::stream<C_t4> &fifo_C_drain_out, hls::stream<int> &fifo_C_drain_local_in);

/* Module Definition */
void A_IO_L3_in(hls::stream<A_t16> &fifo_A_in, hls::stream<A_t16> &fifo_A_local_out) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  /* Variable Declaration */

  // array
  // io_L3
  for (ap_uint<5> c3 = 0; c3 <= 12; c3 += 1) {
    // io_L2
    for (ap_uint<5> c4 = 0; c4 <= 15; c4 += 1) {
      // access_coalesce
      // access_serialize
      for (ap_uint<5> c5 = 0; c5 <= 15; c5 += 1) {
      #pragma HLS PIPELINE II=1
        {
          A_t16 in_data;
          A_t16 out_data;
          in_data = fifo_A_in.read();
          out_data = in_data;
          fifo_A_local_out.write(out_data);
        }
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
void A_IO_L3_in_serialize(A_t16 *A, hls::stream<A_t16> &fifo_A_local_out) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  /* Variable Declaration */

  for (ap_uint<13> i = 0; i < 3328; i++) {
  #pragma HLS PIPELINE II=1
    A_t16 fifo_data;
    fifo_data = A[i];
    fifo_A_local_out.write(fifo_data);
  }
}
/* Module Definition */

/* Module Definition */
void A_IO_L2_in_intra_trans(int idx, A_t16 local_A[16][16], hls::stream<A_t8> &fifo_A_local_out, bool intra_trans_en) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  int p0 = idx; // module id
  A_t8 data_split[2];
  #pragma HLS ARRAY_PARTITION variable=data_split complete
  /* Variable Declaration */

  if (!intra_trans_en) return;


  // array
  // io_L3
  // io_L2
  // io_L1
  // pe
  for (ap_uint<6> c5 = 0; c5 <= 31; c5 += 1) {
    // latency
    for (ap_uint<7> c6 = 0; c6 <= 63; c6 += 1) {
      // latency
      for (ap_uint<5> c7 = 0; c7 <= 15; c7 += 1) {
      #pragma HLS PIPELINE II=1
        // simd
        {
          A_t16 in_data;
          A_t8 out_data;
          in_data = local_A[c7][8 * c5 / 16];
          for (ap_uint<2> n = 0; n < 2; n++) {
          #pragma HLS UNROLL
            data_split[n] = in_data(255, 0);
            in_data = in_data >> 256;
          }
          int split_idx = (c5) % 2;
          out_data = data_split[split_idx];
          fifo_A_local_out.write(out_data);
        }
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
void A_IO_L2_in_inter_trans(int idx, A_t16 local_A[16][16], hls::stream<A_t16> &fifo_A_in, hls::stream<A_t16> &fifo_A_out, bool inter_trans_en) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  int p0 = idx; // module id
  /* Variable Declaration */

  if (!inter_trans_en) return;

  for (ap_uint<5> c3 = p0; c3 <= 12; c3 += 1) {
    // io_L2
    if (c3 == p0) {
      for (ap_uint<5> c4 = 0; c4 <= 15; c4 += 1) {
        // access_coalesce
        for (ap_uint<5> c5 = 0; c5 <= 15; c5 += 1) {
        #pragma HLS PIPELINE II=1
          {
            A_t16 in_data;
            A_t16 out_data;
            in_data = fifo_A_in.read();
            out_data = in_data;
            local_A[c4][c5] = out_data;
          }
        }
      }
    } else {
      for (ap_uint<5> c4 = 0; c4 <= 15; c4 += 1) {
        // access_coalesce
        for (ap_uint<5> c5 = 0; c5 <= 15; c5 += 1) {
        #pragma HLS PIPELINE II=1
          {
            A_t16 in_data;
            A_t16 out_data;
            in_data = fifo_A_in.read();
            out_data = in_data;
            fifo_A_out.write(out_data);
          }
        }
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
void A_IO_L2_in_inter_trans_boundary(int idx, A_t16 local_A[16][16], hls::stream<A_t16> &fifo_A_in, bool inter_trans_en) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  int p0 = idx; // module id
  /* Variable Declaration */

  if (!inter_trans_en) return;

  for (ap_uint<5> c3 = p0; c3 <= 12; c3 += 1)
    if (c3 == p0) {
      // io_L2
      for (ap_uint<5> c4 = 0; c4 <= 15; c4 += 1) {
        // access_coalesce
        for (ap_uint<5> c5 = 0; c5 <= 15; c5 += 1) {
        #pragma HLS PIPELINE II=1
          {
            A_t16 in_data;
            A_t16 out_data;
            in_data = fifo_A_in.read();
            out_data = in_data;
            local_A[c4][c5] = out_data;
          }
        }
      }
    }
}
/* Module Definition */

/* Module Definition */
void A_IO_L2_in(int idx, hls::stream<A_t16> &fifo_A_in, hls::stream<A_t16> &fifo_A_out, hls::stream<A_t8> &fifo_A_local_out) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  int p0 = idx; // module id
  A_t16 local_A_ping[16][16];
  #pragma HLS RESOURCE variable=local_A_ping core=RAM_2P_BRAM
  A_t16 local_A_pong[16][16];
  #pragma HLS RESOURCE variable=local_A_pong core=RAM_2P_BRAM
  bool arb = 0;
  bool inter_trans_en = 1;
  bool intra_trans_en = 0;
  /* Variable Declaration */

  {
    // array
    // io_L3
    {
      if (arb == 0) {
        A_IO_L2_in_inter_trans(
          /* module id */ idx, 
          /* array */ local_A_pong, 
          /* fifo */ fifo_A_in, 
          /* fifo */ fifo_A_out, 
          /* enable */ inter_trans_en
        );
        A_IO_L2_in_intra_trans(
          /* module id */ idx, 
          /* array */ local_A_ping, 
          /* fifo */ fifo_A_local_out, 
          /* enable */ intra_trans_en
        );
      } else {
        A_IO_L2_in_inter_trans(
          /* module id */ idx, 
          /* array */ local_A_ping, 
          /* fifo */ fifo_A_in, 
          /* fifo */ fifo_A_out, 
          /* enable */ inter_trans_en
        );
        A_IO_L2_in_intra_trans(
          /* module id */ idx, 
          /* array */ local_A_pong, 
          /* fifo */ fifo_A_local_out, 
          /* enable */ intra_trans_en
        );
      }
      intra_trans_en = 1;
      arb = !arb;
    }
    if (arb == 0) {
      A_IO_L2_in_intra_trans(
        /* module id */ idx, 
        /* array */ local_A_ping, 
        /* fifo */ fifo_A_local_out, 
        /* enable */ intra_trans_en
      );
    } else {
      A_IO_L2_in_intra_trans(
        /* module id */ idx, 
        /* array */ local_A_pong, 
        /* fifo */ fifo_A_local_out, 
        /* enable */ intra_trans_en
      );
    }
  }
}
/* Module Definition */

/* Module Definition */
void A_IO_L2_in_boundary(int idx, hls::stream<A_t16> &fifo_A_in, hls::stream<A_t8> &fifo_A_local_out) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  int p0 = idx; // module id
  A_t16 local_A_ping[16][16];
  #pragma HLS RESOURCE variable=local_A_ping core=RAM_2P_BRAM
  A_t16 local_A_pong[16][16];
  #pragma HLS RESOURCE variable=local_A_pong core=RAM_2P_BRAM
  bool arb = 0;
  bool inter_trans_en = 1;
  bool intra_trans_en = 0;
  /* Variable Declaration */

  {
    // array
    // io_L3
    {
      if (arb == 0) {
        A_IO_L2_in_inter_trans_boundary(
          /* module id */ idx, 
          /* array */ local_A_pong, 
          /* fifo */ fifo_A_in, 
          /* enable */ inter_trans_en
        );
        A_IO_L2_in_intra_trans(
          /* module id */ idx, 
          /* array */ local_A_ping, 
          /* fifo */ fifo_A_local_out, 
          /* enable */ intra_trans_en
        );
      } else {
        A_IO_L2_in_inter_trans_boundary(
          /* module id */ idx, 
          /* array */ local_A_ping, 
          /* fifo */ fifo_A_in, 
          /* enable */ inter_trans_en
        );
        A_IO_L2_in_intra_trans(
          /* module id */ idx, 
          /* array */ local_A_pong, 
          /* fifo */ fifo_A_local_out, 
          /* enable */ intra_trans_en
        );
      }
      intra_trans_en = 1;
      arb = !arb;
    }
    if (arb == 0) {
      A_IO_L2_in_intra_trans(
        /* module id */ idx, 
        /* array */ local_A_ping, 
        /* fifo */ fifo_A_local_out, 
        /* enable */ intra_trans_en
      );
    } else {
      A_IO_L2_in_intra_trans(
        /* module id */ idx, 
        /* array */ local_A_pong, 
        /* fifo */ fifo_A_local_out, 
        /* enable */ intra_trans_en
      );
    }
  }
}
/* Module Definition */

/* Module Definition */
void B_IO_L3_in(hls::stream<B_t16> &fifo_B_in, hls::stream<B_t16> &fifo_B_local_out) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  /* Variable Declaration */

  // array
  // io_L3
  for (ap_uint<4> c3 = 0; c3 <= 7; c3 += 1) {
    // io_L2
    for (ap_uint<7> c4 = 0; c4 <= 63; c4 += 1) {
      // access_coalesce
      // access_serialize
      for (ap_uint<5> c5 = 0; c5 <= 15; c5 += 1) {
      #pragma HLS PIPELINE II=1
        {
          B_t16 in_data;
          B_t16 out_data;
          in_data = fifo_B_in.read();
          out_data = in_data;
          fifo_B_local_out.write(out_data);
        }
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
void B_IO_L3_in_serialize(B_t16 *B, hls::stream<B_t16> &fifo_B_local_out) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  /* Variable Declaration */

  for (ap_uint<14> i = 0; i < 8192; i++) {
  #pragma HLS PIPELINE II=1
    B_t16 fifo_data;
    fifo_data = B[i];
    fifo_B_local_out.write(fifo_data);
  }
}
/* Module Definition */

/* Module Definition */
void B_IO_L2_in_intra_trans(int idx, B_t16 local_B[64][16], hls::stream<B_t8> &fifo_B_local_out, bool intra_trans_en) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  int p0 = idx; // module id
  B_t8 data_split[2];
  #pragma HLS ARRAY_PARTITION variable=data_split complete
  /* Variable Declaration */

  if (!intra_trans_en) return;


  // array
  // io_L3
  // io_L2
  // io_L1
  // pe
  for (ap_uint<6> c5 = 0; c5 <= 31; c5 += 1) {
    // latency
    for (ap_uint<7> c6 = 0; c6 <= 63; c6 += 1) {
      // latency
      for (ap_uint<5> c7 = 0; c7 <= 15; c7 += 1) {
      #pragma HLS PIPELINE II=1
        // simd
        {
          B_t16 in_data;
          B_t8 out_data;
          in_data = local_B[c6][8 * c5 / 16];
          for (ap_uint<2> n = 0; n < 2; n++) {
          #pragma HLS UNROLL
            data_split[n] = in_data(255, 0);
            in_data = in_data >> 256;
          }
          int split_idx = (c5) % 2;
          out_data = data_split[split_idx];
          fifo_B_local_out.write(out_data);
        }
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
void B_IO_L2_in_inter_trans(int idx, B_t16 local_B[64][16], hls::stream<B_t16> &fifo_B_in, hls::stream<B_t16> &fifo_B_out, bool inter_trans_en) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  int p0 = idx; // module id
  /* Variable Declaration */

  if (!inter_trans_en) return;

  for (ap_uint<4> c3 = p0; c3 <= 7; c3 += 1) {
    // io_L2
    if (c3 == p0) {
      for (ap_uint<7> c4 = 0; c4 <= 63; c4 += 1) {
        // access_coalesce
        for (ap_uint<5> c5 = 0; c5 <= 15; c5 += 1) {
        #pragma HLS PIPELINE II=1
          {
            B_t16 in_data;
            B_t16 out_data;
            in_data = fifo_B_in.read();
            out_data = in_data;
            local_B[c4][c5] = out_data;
          }
        }
      }
    } else {
      for (ap_uint<7> c4 = 0; c4 <= 63; c4 += 1) {
        // access_coalesce
        for (ap_uint<5> c5 = 0; c5 <= 15; c5 += 1) {
        #pragma HLS PIPELINE II=1
          {
            B_t16 in_data;
            B_t16 out_data;
            in_data = fifo_B_in.read();
            out_data = in_data;
            fifo_B_out.write(out_data);
          }
        }
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
void B_IO_L2_in_inter_trans_boundary(int idx, B_t16 local_B[64][16], hls::stream<B_t16> &fifo_B_in, bool inter_trans_en) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  int p0 = idx; // module id
  /* Variable Declaration */

  if (!inter_trans_en) return;

  for (ap_uint<4> c3 = p0; c3 <= 7; c3 += 1)
    if (c3 == p0) {
      // io_L2
      for (ap_uint<7> c4 = 0; c4 <= 63; c4 += 1) {
        // access_coalesce
        for (ap_uint<5> c5 = 0; c5 <= 15; c5 += 1) {
        #pragma HLS PIPELINE II=1
          {
            B_t16 in_data;
            B_t16 out_data;
            in_data = fifo_B_in.read();
            out_data = in_data;
            local_B[c4][c5] = out_data;
          }
        }
      }
    }
}
/* Module Definition */

/* Module Definition */
void B_IO_L2_in(int idx, hls::stream<B_t16> &fifo_B_in, hls::stream<B_t16> &fifo_B_out, hls::stream<B_t8> &fifo_B_local_out) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  int p0 = idx; // module id
  B_t16 local_B_ping[64][16];
  #pragma HLS RESOURCE variable=local_B_ping core=RAM_2P_BRAM
  B_t16 local_B_pong[64][16];
  #pragma HLS RESOURCE variable=local_B_pong core=RAM_2P_BRAM
  bool arb = 0;
  bool inter_trans_en = 1;
  bool intra_trans_en = 0;
  /* Variable Declaration */

  {
    // array
    // io_L3
    {
      if (arb == 0) {
        B_IO_L2_in_inter_trans(
          /* module id */ idx, 
          /* array */ local_B_pong, 
          /* fifo */ fifo_B_in, 
          /* fifo */ fifo_B_out, 
          /* enable */ inter_trans_en
        );
        B_IO_L2_in_intra_trans(
          /* module id */ idx, 
          /* array */ local_B_ping, 
          /* fifo */ fifo_B_local_out, 
          /* enable */ intra_trans_en
        );
      } else {
        B_IO_L2_in_inter_trans(
          /* module id */ idx, 
          /* array */ local_B_ping, 
          /* fifo */ fifo_B_in, 
          /* fifo */ fifo_B_out, 
          /* enable */ inter_trans_en
        );
        B_IO_L2_in_intra_trans(
          /* module id */ idx, 
          /* array */ local_B_pong, 
          /* fifo */ fifo_B_local_out, 
          /* enable */ intra_trans_en
        );
      }
      intra_trans_en = 1;
      arb = !arb;
    }
    if (arb == 0) {
      B_IO_L2_in_intra_trans(
        /* module id */ idx, 
        /* array */ local_B_ping, 
        /* fifo */ fifo_B_local_out, 
        /* enable */ intra_trans_en
      );
    } else {
      B_IO_L2_in_intra_trans(
        /* module id */ idx, 
        /* array */ local_B_pong, 
        /* fifo */ fifo_B_local_out, 
        /* enable */ intra_trans_en
      );
    }
  }
}
/* Module Definition */

/* Module Definition */
void B_IO_L2_in_boundary(int idx, hls::stream<B_t16> &fifo_B_in, hls::stream<B_t8> &fifo_B_local_out) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  int p0 = idx; // module id
  B_t16 local_B_ping[64][16];
  #pragma HLS RESOURCE variable=local_B_ping core=RAM_2P_BRAM
  B_t16 local_B_pong[64][16];
  #pragma HLS RESOURCE variable=local_B_pong core=RAM_2P_BRAM
  bool arb = 0;
  bool inter_trans_en = 1;
  bool intra_trans_en = 0;
  /* Variable Declaration */

  {
    // array
    // io_L3
    {
      if (arb == 0) {
        B_IO_L2_in_inter_trans_boundary(
          /* module id */ idx, 
          /* array */ local_B_pong, 
          /* fifo */ fifo_B_in, 
          /* enable */ inter_trans_en
        );
        B_IO_L2_in_intra_trans(
          /* module id */ idx, 
          /* array */ local_B_ping, 
          /* fifo */ fifo_B_local_out, 
          /* enable */ intra_trans_en
        );
      } else {
        B_IO_L2_in_inter_trans_boundary(
          /* module id */ idx, 
          /* array */ local_B_ping, 
          /* fifo */ fifo_B_in, 
          /* enable */ inter_trans_en
        );
        B_IO_L2_in_intra_trans(
          /* module id */ idx, 
          /* array */ local_B_pong, 
          /* fifo */ fifo_B_local_out, 
          /* enable */ intra_trans_en
        );
      }
      intra_trans_en = 1;
      arb = !arb;
    }
    if (arb == 0) {
      B_IO_L2_in_intra_trans(
        /* module id */ idx, 
        /* array */ local_B_ping, 
        /* fifo */ fifo_B_local_out, 
        /* enable */ intra_trans_en
      );
    } else {
      B_IO_L2_in_intra_trans(
        /* module id */ idx, 
        /* array */ local_B_pong, 
        /* fifo */ fifo_B_local_out, 
        /* enable */ intra_trans_en
      );
    }
  }
}
/* Module Definition */

/* Module Definition */
void PE(int idx, int idy, hls::stream<A_t8> &fifo_A_in, hls::stream<A_t8> &fifo_A_out, hls::stream<B_t8> &fifo_B_in, hls::stream<B_t8> &fifo_B_out, hls::stream<int> &fifo_C_drain_out) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  int p0 = idx, p1 = idy; // module id
  A_t1 local_A[1][8];
  #pragma HLS ARRAY_PARTITION variable=local_A dim=0 complete
  B_t1 local_B[1][8];
  #pragma HLS ARRAY_PARTITION variable=local_B dim=0 complete
  C_t1 local_C[16][64];
  #pragma HLS RESOURCE variable=local_C core=RAM_2P_BRAM
  /* Variable Declaration */

  // array
  // pe
  for (ap_uint<6> c5 = 0; c5 <= 31; c5 += 1) {
    // latency
    for (ap_uint<7> c6 = 0; c6 <= 63; c6 += 1) {
      // latency
      for (ap_uint<5> c7 = 0; c7 <= 15; c7 += 1) {
      #pragma HLS PIPELINE II=1
        {
          {
            A_t8 fifo_data;
            fifo_data = fifo_A_in.read();
            for (ap_uint<4> n = 0; n < 8; n++) {
            #pragma HLS UNROLL
              union {unsigned int ui; int ut;} u;
              u.ui = (unsigned int)fifo_data(31, 0);
              local_A[0][n] = u.ut;
              fifo_data = fifo_data >> 32;
            }
          }
          {
            B_t8 fifo_data;
            fifo_data = fifo_B_in.read();
            for (ap_uint<4> n = 0; n < 8; n++) {
            #pragma HLS UNROLL
              union {unsigned int ui; int ut;} u;
              u.ui = (unsigned int)fifo_data(31, 0);
              local_B[0][n] = u.ut;
              fifo_data = fifo_data >> 32;
            }
          }
          // simd
          {
            if (c5 == 0) {
              // hls_unroll
              local_C[c7][c6] = 0;
            }
            for (ap_uint<4> c8 = 0; c8 <= 7; c8 += 1) {
            #pragma HLS UNROLL
              local_C[c7][c6] = (local_C[c7][c6] + (local_A[0][c8] * local_B[0][c8]));
            }
          }
          if (c5 == 31)
            fifo_C_drain_out.write(local_C[c7][c6]);
          {
            B_t8 fifo_data;
            union {unsigned int ui; int ut;} u7, u6, u5, u4, u3, u2, u1, u0;
            u7.ut = local_B[0][7];
            u6.ut = local_B[0][6];
            u5.ut = local_B[0][5];
            u4.ut = local_B[0][4];
            u3.ut = local_B[0][3];
            u2.ut = local_B[0][2];
            u1.ut = local_B[0][1];
            u0.ut = local_B[0][0];
            fifo_data = (ap_uint<32>(u7.ui), ap_uint<32>(u6.ui), ap_uint<32>(u5.ui), ap_uint<32>(u4.ui), ap_uint<32>(u3.ui), ap_uint<32>(u2.ui), ap_uint<32>(u1.ui), ap_uint<32>(u0.ui));
            fifo_B_out.write(fifo_data);
          }
          {
            A_t8 fifo_data;
            union {unsigned int ui; int ut;} u7, u6, u5, u4, u3, u2, u1, u0;
            u7.ut = local_A[0][7];
            u6.ut = local_A[0][6];
            u5.ut = local_A[0][5];
            u4.ut = local_A[0][4];
            u3.ut = local_A[0][3];
            u2.ut = local_A[0][2];
            u1.ut = local_A[0][1];
            u0.ut = local_A[0][0];
            fifo_data = (ap_uint<32>(u7.ui), ap_uint<32>(u6.ui), ap_uint<32>(u5.ui), ap_uint<32>(u4.ui), ap_uint<32>(u3.ui), ap_uint<32>(u2.ui), ap_uint<32>(u1.ui), ap_uint<32>(u0.ui));
            fifo_A_out.write(fifo_data);
          }
        }
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
void PE_wrapper(int idx, int idy, hls::stream<A_t8> &fifo_A_in, hls::stream<A_t8> &fifo_A_out, hls::stream<B_t8> &fifo_B_in, hls::stream<B_t8> &fifo_B_out, hls::stream<int> &fifo_C_drain_out)
 {
  PE(
    /* module id */ idx, 
    /* module id */ idy, 
    /* fifo */ fifo_A_in, 
    /* fifo */ fifo_A_out, 
    /* fifo */ fifo_B_in, 
    /* fifo */ fifo_B_out, 
    /* fifo */ fifo_C_drain_out);
}
/* Module Definition */

/* Module Definition */
void A_PE_dummy_in(int idx, int idy, hls::stream<A_t8> &fifo_A_in) {
  /* Variable Declaration */
  int p0 = idx, p1 = idy; // module id
  /* Variable Declaration */

  // array
  // pe
  for (ap_uint<6> c5 = 0; c5 <= 31; c5 += 1) {
    // latency
    for (ap_uint<7> c6 = 0; c6 <= 63; c6 += 1) {
      // latency
      for (ap_uint<5> c7 = 0; c7 <= 15; c7 += 1) {
      #pragma HLS PIPELINE II=1
        A_t8 fifo_data;
        fifo_data = fifo_A_in.read();
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
void B_PE_dummy_in(int idx, int idy, hls::stream<B_t8> &fifo_B_in) {
  /* Variable Declaration */
  int p0 = idx, p1 = idy; // module id
  /* Variable Declaration */

  // array
  // pe
  for (ap_uint<6> c5 = 0; c5 <= 31; c5 += 1) {
    // latency
    for (ap_uint<7> c6 = 0; c6 <= 63; c6 += 1) {
      // latency
      for (ap_uint<5> c7 = 0; c7 <= 15; c7 += 1) {
      #pragma HLS PIPELINE II=1
        B_t8 fifo_data;
        fifo_data = fifo_B_in.read();
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
void C_drain_IO_L1_out_intra_trans(int idx, int idy, C_t4 local_C[16][16], hls::stream<int> &fifo_C_drain_local_in) {
#pragma HLS INLINE
  /* Variable Declaration */
  int p0 = idx, p1 = idy; // module id
  ap_uint<32> data_split[4];
  #pragma HLS ARRAY_PARTITION variable=data_split complete
  /* Variable Declaration */


  // io_L1
  // pe
  // latency
  for (ap_uint<7> c6 = 0; c6 <= 63; c6 += 1) {
    // latency
    for (ap_uint<5> c7 = 0; c7 <= 15; c7 += 1) {
    #pragma HLS PIPELINE II=1
      // simd
      {
        C_t1 in_data;
        C_t4 out_data;
        in_data = fifo_C_drain_local_in.read();
        int split_idx = (c6) % 4;
        out_data = local_C[c7][c6 / 4];
        for (ap_uint<3> n = 0; n < 4; n++) {
        #pragma HLS UNROLL
          data_split[n] = out_data(31, 0);
          out_data = out_data >> 32;
        }
        union {unsigned int ui; int ut;} u;
        u.ut = in_data;
        data_split[split_idx] = ap_uint<32>(u.ui);
        out_data = (data_split[3], data_split[2], data_split[1], data_split[0]);
        local_C[c7][c6 / 4] = out_data;
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
void C_drain_IO_L1_out_inter_trans(int idx, int idy, C_t4 local_C[16][16], hls::stream<C_t4> &fifo_C_drain_in, hls::stream<C_t4> &fifo_C_drain_out) {
#pragma HLS INLINE
  /* Variable Declaration */
  int p0 = idx, p1 = idy; // module id
  /* Variable Declaration */

  for (ap_uint<5> c4 = p1; c4 <= 12; c4 += 1) {
    // io_L1
    if (c4 == p1) {
      for (ap_uint<5> c5 = 0; c5 <= 15; c5 += 1) {
        // access_coalesce
        for (ap_uint<5> c6 = 0; c6 <= 15; c6 += 1) {
        #pragma HLS PIPELINE II=1
          {
            C_t4 in_data;
            C_t4 out_data;
            in_data = local_C[c5][c6];
            out_data = in_data;
            fifo_C_drain_out.write(out_data);
          }
        }
      }
    } else {
      for (ap_uint<5> c5 = 0; c5 <= 15; c5 += 1) {
        // access_coalesce
        for (ap_uint<5> c6 = 0; c6 <= 15; c6 += 1) {
        #pragma HLS PIPELINE II=1
          {
            C_t4 in_data;
            C_t4 out_data;
            in_data = fifo_C_drain_in.read();
            out_data = in_data;
            fifo_C_drain_out.write(out_data);
          }
        }
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
void C_drain_IO_L1_out_inter_trans_boundary(int idx, int idy, C_t4 local_C[16][16], hls::stream<C_t4> &fifo_C_drain_out) {
#pragma HLS INLINE
  /* Variable Declaration */
  int p0 = idx, p1 = idy; // module id
  /* Variable Declaration */

  for (ap_uint<5> c4 = p1; c4 <= 12; c4 += 1)
    if (c4 == p1) {
      // io_L1
      for (ap_uint<5> c5 = 0; c5 <= 15; c5 += 1) {
        // access_coalesce
        for (ap_uint<5> c6 = 0; c6 <= 15; c6 += 1) {
        #pragma HLS PIPELINE II=1
          {
            C_t4 in_data;
            C_t4 out_data;
            in_data = local_C[c5][c6];
            out_data = in_data;
            fifo_C_drain_out.write(out_data);
          }
        }
      }
    }
}
/* Module Definition */

/* Module Definition */
void C_drain_IO_L1_out(int idx, int idy, hls::stream<C_t4> &fifo_C_drain_in, hls::stream<C_t4> &fifo_C_drain_out, hls::stream<int> &fifo_C_drain_local_in) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  int p0 = idx, p1 = idy; // module id
  C_t4 local_C[16][16];
  #pragma HLS RESOURCE variable=local_C core=RAM_2P_BRAM
  /* Variable Declaration */

  // array
  // io_L3
  // io_L2
  C_drain_IO_L1_out_intra_trans(
    /* module id */ idx, 
    /* module id */ idy, 
    /* array */ local_C, 
    /* fifo */ fifo_C_drain_local_in
  );
  C_drain_IO_L1_out_inter_trans(
    /* module id */ idx, 
    /* module id */ idy, 
    /* array */ local_C, 
    /* fifo */ fifo_C_drain_in, 
    /* fifo */ fifo_C_drain_out
  );
}
/* Module Definition */

/* Module Definition */
void C_drain_IO_L1_out_wrapper(int idx, int idy, hls::stream<C_t4> &fifo_C_drain_in, hls::stream<C_t4> &fifo_C_drain_out, hls::stream<int> &fifo_C_drain_local_in)
 {
  C_drain_IO_L1_out(
    /* module id */ idx, 
    /* module id */ idy, 
    /* fifo */ fifo_C_drain_in, 
    /* fifo */ fifo_C_drain_out, 
    /* fifo */ fifo_C_drain_local_in);
}
/* Module Definition */

/* Module Definition */
void C_drain_IO_L1_out_boundary(int idx, int idy, hls::stream<C_t4> &fifo_C_drain_out, hls::stream<int> &fifo_C_drain_local_in) {
#pragma HLS INLINE
  /* Variable Declaration */
  int p0 = idx, p1 = idy; // module id
  C_t4 local_C[16][16];
  #pragma HLS RESOURCE variable=local_C core=RAM_2P_BRAM
  /* Variable Declaration */

  // array
  // io_L3
  // io_L2
  C_drain_IO_L1_out_intra_trans(
    /* module id */ idx, 
    /* module id */ idy, 
    /* array */ local_C, 
    /* fifo */ fifo_C_drain_local_in
  );
  C_drain_IO_L1_out_inter_trans_boundary(
    /* module id */ idx, 
    /* module id */ idy, 
    /* array */ local_C, 
    /* fifo */ fifo_C_drain_out
  );
}
/* Module Definition */

/* Module Definition */
void C_drain_IO_L1_out_boundary_wrapper(int idx, int idy, hls::stream<C_t4> &fifo_C_drain_out, hls::stream<int> &fifo_C_drain_local_in)
 {
  C_drain_IO_L1_out_boundary(
    /* module id */ idx, 
    /* module id */ idy, 
    /* fifo */ fifo_C_drain_out, 
    /* fifo */ fifo_C_drain_local_in);
}
/* Module Definition */

/* Module Definition */
void C_drain_IO_L2_out(int idx, hls::stream<C_t4> &fifo_C_drain_in, hls::stream<C_t4> &fifo_C_drain_out, hls::stream<C_t4> &fifo_C_drain_local_in) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  int p0 = idx; // module id
  /* Variable Declaration */

  // array
  // io_L3
  for (ap_uint<4> c3 = p0; c3 <= 7; c3 += 1) {
    // io_L2
    if (c3 == p0) {
      for (ap_uint<5> c4 = 0; c4 <= 12; c4 += 1) {
        // io_L1
        for (ap_uint<5> c5 = 0; c5 <= 15; c5 += 1) {
          // access_coalesce
          for (ap_uint<5> c6 = 0; c6 <= 15; c6 += 1) {
          #pragma HLS PIPELINE II=1
            {
              C_t4 in_data;
              C_t4 out_data;
              in_data = fifo_C_drain_local_in.read();
              out_data = in_data;
              fifo_C_drain_out.write(out_data);
            }
          }
        }
      }
    } else {
      for (ap_uint<5> c4 = 0; c4 <= 12; c4 += 1) {
        // io_L1
        for (ap_uint<5> c5 = 0; c5 <= 15; c5 += 1) {
          // access_coalesce
          for (ap_uint<5> c6 = 0; c6 <= 15; c6 += 1) {
          #pragma HLS PIPELINE II=1
            {
              C_t4 in_data;
              C_t4 out_data;
              in_data = fifo_C_drain_in.read();
              out_data = in_data;
              fifo_C_drain_out.write(out_data);
            }
          }
        }
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
void C_drain_IO_L2_out_boundary(int idx, hls::stream<C_t4> &fifo_C_drain_out, hls::stream<C_t4> &fifo_C_drain_local_in) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  int p0 = idx; // module id
  /* Variable Declaration */

  // array
  // io_L3
  for (ap_uint<4> c3 = p0; c3 <= 7; c3 += 1)
    if (c3 == p0) {
      // io_L2
      for (ap_uint<5> c4 = 0; c4 <= 12; c4 += 1) {
        // io_L1
        for (ap_uint<5> c5 = 0; c5 <= 15; c5 += 1) {
          // access_coalesce
          for (ap_uint<5> c6 = 0; c6 <= 15; c6 += 1) {
          #pragma HLS PIPELINE II=1
            {
              C_t4 in_data;
              C_t4 out_data;
              in_data = fifo_C_drain_local_in.read();
              out_data = in_data;
              fifo_C_drain_out.write(out_data);
            }
          }
        }
      }
    }
}
/* Module Definition */

/* Module Definition */
void C_drain_IO_L3_out(hls::stream<C_t4> &fifo_C_drain_out, hls::stream<C_t4> &fifo_C_drain_local_in) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  /* Variable Declaration */

  // array
  // io_L3
  for (ap_uint<4> c3 = 0; c3 <= 7; c3 += 1) {
    // io_L2
    for (ap_uint<5> c4 = 0; c4 <= 12; c4 += 1) {
      // io_L1
      for (ap_uint<5> c5 = 0; c5 <= 15; c5 += 1) {
        // access_coalesce
        // access_serialize
        for (ap_uint<5> c6 = 0; c6 <= 15; c6 += 1) {
        #pragma HLS PIPELINE II=1
          {
            C_t4 in_data;
            C_t4 out_data;
            in_data = fifo_C_drain_local_in.read();
            out_data = in_data;
            fifo_C_drain_out.write(out_data);
          }
        }
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
void C_drain_IO_L3_out_serialize(C_t16 *C, hls::stream<C_t4> &fifo_C_drain_local_in) {
#pragma HLS INLINE OFF
  /* Variable Declaration */
  /* Variable Declaration */

  for (ap_uint<14> i = 0; i < 6656; i++) {
  #pragma HLS PIPELINE II=1
    C_t4 fifo_data;
    C_t16 mem_data;
    C_t4 mem_data_split[4];
    #pragma HLS ARRAY_PARTITION variable=mem_data_split complete
    for (ap_uint<3> p = 0; p < 4; p++) {
      fifo_data = fifo_C_drain_local_in.read();
      mem_data_split[p] = fifo_data;
    }
    mem_data = (mem_data_split[3], mem_data_split[2], mem_data_split[1], mem_data_split[0]);
    C[i] = mem_data;
  }
}
/* Module Definition */

extern "C" {
void kernel0(A_t16 *A, B_t16 *B, C_t16 *C)
{
#pragma HLS INTERFACE m_axi port=A offset=slave bundle=gmem_A
#pragma HLS INTERFACE m_axi port=B offset=slave bundle=gmem_B
#pragma HLS INTERFACE m_axi port=C offset=slave bundle=gmem_C
#pragma HLS INTERFACE s_axilite port=A bundle=control
#pragma HLS INTERFACE s_axilite port=B bundle=control
#pragma HLS INTERFACE s_axilite port=C bundle=control
#pragma HLS INTERFACE s_axilite port=return bundle=control

#pragma HLS DATAFLOW

  /* FIFO Declaration */
  /* A_IO_L3_in_serialize fifo */ hls::stream<A_t16> fifo_A_A_IO_L3_in_serialize;
  #pragma HLS STREAM variable=fifo_A_A_IO_L3_in_serialize depth=2
  /* B_IO_L3_in_serialize fifo */ hls::stream<B_t16> fifo_B_B_IO_L3_in_serialize;
  #pragma HLS STREAM variable=fifo_B_B_IO_L3_in_serialize depth=2
  /* C_drain_IO_L3_out_serialize fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L3_out_serialize;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L3_out_serialize depth=2
  /* A_IO_L2_in fifo */ hls::stream<A_t16> fifo_A_A_IO_L2_in_0;
  #pragma HLS STREAM variable=fifo_A_A_IO_L2_in_0 depth=2
  #pragma HLS RESOURCE variable=fifo_A_A_IO_L2_in_0 core=FIFO_SRL
  /* A_IO_L2_in fifo */ hls::stream<A_t16> fifo_A_A_IO_L2_in_1;
  #pragma HLS STREAM variable=fifo_A_A_IO_L2_in_1 depth=2
  #pragma HLS RESOURCE variable=fifo_A_A_IO_L2_in_1 core=FIFO_SRL
  /* A_IO_L2_in fifo */ hls::stream<A_t16> fifo_A_A_IO_L2_in_2;
  #pragma HLS STREAM variable=fifo_A_A_IO_L2_in_2 depth=2
  #pragma HLS RESOURCE variable=fifo_A_A_IO_L2_in_2 core=FIFO_SRL
  /* A_IO_L2_in fifo */ hls::stream<A_t16> fifo_A_A_IO_L2_in_3;
  #pragma HLS STREAM variable=fifo_A_A_IO_L2_in_3 depth=2
  #pragma HLS RESOURCE variable=fifo_A_A_IO_L2_in_3 core=FIFO_SRL
  /* A_IO_L2_in fifo */ hls::stream<A_t16> fifo_A_A_IO_L2_in_4;
  #pragma HLS STREAM variable=fifo_A_A_IO_L2_in_4 depth=2
  #pragma HLS RESOURCE variable=fifo_A_A_IO_L2_in_4 core=FIFO_SRL
  /* A_IO_L2_in fifo */ hls::stream<A_t16> fifo_A_A_IO_L2_in_5;
  #pragma HLS STREAM variable=fifo_A_A_IO_L2_in_5 depth=2
  #pragma HLS RESOURCE variable=fifo_A_A_IO_L2_in_5 core=FIFO_SRL
  /* A_IO_L2_in fifo */ hls::stream<A_t16> fifo_A_A_IO_L2_in_6;
  #pragma HLS STREAM variable=fifo_A_A_IO_L2_in_6 depth=2
  #pragma HLS RESOURCE variable=fifo_A_A_IO_L2_in_6 core=FIFO_SRL
  /* A_IO_L2_in fifo */ hls::stream<A_t16> fifo_A_A_IO_L2_in_7;
  #pragma HLS STREAM variable=fifo_A_A_IO_L2_in_7 depth=2
  #pragma HLS RESOURCE variable=fifo_A_A_IO_L2_in_7 core=FIFO_SRL
  /* A_IO_L2_in fifo */ hls::stream<A_t16> fifo_A_A_IO_L2_in_8;
  #pragma HLS STREAM variable=fifo_A_A_IO_L2_in_8 depth=2
  #pragma HLS RESOURCE variable=fifo_A_A_IO_L2_in_8 core=FIFO_SRL
  /* A_IO_L2_in fifo */ hls::stream<A_t16> fifo_A_A_IO_L2_in_9;
  #pragma HLS STREAM variable=fifo_A_A_IO_L2_in_9 depth=2
  #pragma HLS RESOURCE variable=fifo_A_A_IO_L2_in_9 core=FIFO_SRL
  /* A_IO_L2_in fifo */ hls::stream<A_t16> fifo_A_A_IO_L2_in_10;
  #pragma HLS STREAM variable=fifo_A_A_IO_L2_in_10 depth=2
  #pragma HLS RESOURCE variable=fifo_A_A_IO_L2_in_10 core=FIFO_SRL
  /* A_IO_L2_in fifo */ hls::stream<A_t16> fifo_A_A_IO_L2_in_11;
  #pragma HLS STREAM variable=fifo_A_A_IO_L2_in_11 depth=2
  #pragma HLS RESOURCE variable=fifo_A_A_IO_L2_in_11 core=FIFO_SRL
  /* A_IO_L2_in fifo */ hls::stream<A_t16> fifo_A_A_IO_L2_in_12;
  #pragma HLS STREAM variable=fifo_A_A_IO_L2_in_12 depth=2
  #pragma HLS RESOURCE variable=fifo_A_A_IO_L2_in_12 core=FIFO_SRL
  /* A_IO_L2_in fifo */ hls::stream<A_t16> fifo_A_A_IO_L2_in_13;
  #pragma HLS STREAM variable=fifo_A_A_IO_L2_in_13 depth=2
  #pragma HLS RESOURCE variable=fifo_A_A_IO_L2_in_13 core=FIFO_SRL
  /* B_IO_L2_in fifo */ hls::stream<B_t16> fifo_B_B_IO_L2_in_0;
  #pragma HLS STREAM variable=fifo_B_B_IO_L2_in_0 depth=2
  #pragma HLS RESOURCE variable=fifo_B_B_IO_L2_in_0 core=FIFO_SRL
  /* B_IO_L2_in fifo */ hls::stream<B_t16> fifo_B_B_IO_L2_in_1;
  #pragma HLS STREAM variable=fifo_B_B_IO_L2_in_1 depth=2
  #pragma HLS RESOURCE variable=fifo_B_B_IO_L2_in_1 core=FIFO_SRL
  /* B_IO_L2_in fifo */ hls::stream<B_t16> fifo_B_B_IO_L2_in_2;
  #pragma HLS STREAM variable=fifo_B_B_IO_L2_in_2 depth=2
  #pragma HLS RESOURCE variable=fifo_B_B_IO_L2_in_2 core=FIFO_SRL
  /* B_IO_L2_in fifo */ hls::stream<B_t16> fifo_B_B_IO_L2_in_3;
  #pragma HLS STREAM variable=fifo_B_B_IO_L2_in_3 depth=2
  #pragma HLS RESOURCE variable=fifo_B_B_IO_L2_in_3 core=FIFO_SRL
  /* B_IO_L2_in fifo */ hls::stream<B_t16> fifo_B_B_IO_L2_in_4;
  #pragma HLS STREAM variable=fifo_B_B_IO_L2_in_4 depth=2
  #pragma HLS RESOURCE variable=fifo_B_B_IO_L2_in_4 core=FIFO_SRL
  /* B_IO_L2_in fifo */ hls::stream<B_t16> fifo_B_B_IO_L2_in_5;
  #pragma HLS STREAM variable=fifo_B_B_IO_L2_in_5 depth=2
  #pragma HLS RESOURCE variable=fifo_B_B_IO_L2_in_5 core=FIFO_SRL
  /* B_IO_L2_in fifo */ hls::stream<B_t16> fifo_B_B_IO_L2_in_6;
  #pragma HLS STREAM variable=fifo_B_B_IO_L2_in_6 depth=2
  #pragma HLS RESOURCE variable=fifo_B_B_IO_L2_in_6 core=FIFO_SRL
  /* B_IO_L2_in fifo */ hls::stream<B_t16> fifo_B_B_IO_L2_in_7;
  #pragma HLS STREAM variable=fifo_B_B_IO_L2_in_7 depth=2
  #pragma HLS RESOURCE variable=fifo_B_B_IO_L2_in_7 core=FIFO_SRL
  /* B_IO_L2_in fifo */ hls::stream<B_t16> fifo_B_B_IO_L2_in_8;
  #pragma HLS STREAM variable=fifo_B_B_IO_L2_in_8 depth=2
  #pragma HLS RESOURCE variable=fifo_B_B_IO_L2_in_8 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_0_0;
  #pragma HLS STREAM variable=fifo_A_PE_0_0 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_0_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_0_1;
  #pragma HLS STREAM variable=fifo_A_PE_0_1 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_0_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_0_2;
  #pragma HLS STREAM variable=fifo_A_PE_0_2 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_0_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_0_3;
  #pragma HLS STREAM variable=fifo_A_PE_0_3 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_0_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_0_4;
  #pragma HLS STREAM variable=fifo_A_PE_0_4 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_0_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_0_5;
  #pragma HLS STREAM variable=fifo_A_PE_0_5 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_0_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_0_6;
  #pragma HLS STREAM variable=fifo_A_PE_0_6 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_0_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_0_7;
  #pragma HLS STREAM variable=fifo_A_PE_0_7 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_0_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_0_8;
  #pragma HLS STREAM variable=fifo_A_PE_0_8 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_0_8 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_1_0;
  #pragma HLS STREAM variable=fifo_A_PE_1_0 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_1_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_1_1;
  #pragma HLS STREAM variable=fifo_A_PE_1_1 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_1_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_1_2;
  #pragma HLS STREAM variable=fifo_A_PE_1_2 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_1_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_1_3;
  #pragma HLS STREAM variable=fifo_A_PE_1_3 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_1_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_1_4;
  #pragma HLS STREAM variable=fifo_A_PE_1_4 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_1_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_1_5;
  #pragma HLS STREAM variable=fifo_A_PE_1_5 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_1_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_1_6;
  #pragma HLS STREAM variable=fifo_A_PE_1_6 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_1_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_1_7;
  #pragma HLS STREAM variable=fifo_A_PE_1_7 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_1_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_1_8;
  #pragma HLS STREAM variable=fifo_A_PE_1_8 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_1_8 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_2_0;
  #pragma HLS STREAM variable=fifo_A_PE_2_0 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_2_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_2_1;
  #pragma HLS STREAM variable=fifo_A_PE_2_1 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_2_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_2_2;
  #pragma HLS STREAM variable=fifo_A_PE_2_2 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_2_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_2_3;
  #pragma HLS STREAM variable=fifo_A_PE_2_3 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_2_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_2_4;
  #pragma HLS STREAM variable=fifo_A_PE_2_4 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_2_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_2_5;
  #pragma HLS STREAM variable=fifo_A_PE_2_5 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_2_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_2_6;
  #pragma HLS STREAM variable=fifo_A_PE_2_6 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_2_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_2_7;
  #pragma HLS STREAM variable=fifo_A_PE_2_7 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_2_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_2_8;
  #pragma HLS STREAM variable=fifo_A_PE_2_8 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_2_8 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_3_0;
  #pragma HLS STREAM variable=fifo_A_PE_3_0 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_3_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_3_1;
  #pragma HLS STREAM variable=fifo_A_PE_3_1 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_3_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_3_2;
  #pragma HLS STREAM variable=fifo_A_PE_3_2 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_3_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_3_3;
  #pragma HLS STREAM variable=fifo_A_PE_3_3 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_3_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_3_4;
  #pragma HLS STREAM variable=fifo_A_PE_3_4 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_3_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_3_5;
  #pragma HLS STREAM variable=fifo_A_PE_3_5 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_3_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_3_6;
  #pragma HLS STREAM variable=fifo_A_PE_3_6 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_3_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_3_7;
  #pragma HLS STREAM variable=fifo_A_PE_3_7 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_3_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_3_8;
  #pragma HLS STREAM variable=fifo_A_PE_3_8 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_3_8 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_4_0;
  #pragma HLS STREAM variable=fifo_A_PE_4_0 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_4_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_4_1;
  #pragma HLS STREAM variable=fifo_A_PE_4_1 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_4_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_4_2;
  #pragma HLS STREAM variable=fifo_A_PE_4_2 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_4_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_4_3;
  #pragma HLS STREAM variable=fifo_A_PE_4_3 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_4_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_4_4;
  #pragma HLS STREAM variable=fifo_A_PE_4_4 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_4_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_4_5;
  #pragma HLS STREAM variable=fifo_A_PE_4_5 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_4_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_4_6;
  #pragma HLS STREAM variable=fifo_A_PE_4_6 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_4_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_4_7;
  #pragma HLS STREAM variable=fifo_A_PE_4_7 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_4_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_4_8;
  #pragma HLS STREAM variable=fifo_A_PE_4_8 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_4_8 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_5_0;
  #pragma HLS STREAM variable=fifo_A_PE_5_0 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_5_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_5_1;
  #pragma HLS STREAM variable=fifo_A_PE_5_1 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_5_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_5_2;
  #pragma HLS STREAM variable=fifo_A_PE_5_2 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_5_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_5_3;
  #pragma HLS STREAM variable=fifo_A_PE_5_3 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_5_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_5_4;
  #pragma HLS STREAM variable=fifo_A_PE_5_4 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_5_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_5_5;
  #pragma HLS STREAM variable=fifo_A_PE_5_5 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_5_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_5_6;
  #pragma HLS STREAM variable=fifo_A_PE_5_6 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_5_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_5_7;
  #pragma HLS STREAM variable=fifo_A_PE_5_7 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_5_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_5_8;
  #pragma HLS STREAM variable=fifo_A_PE_5_8 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_5_8 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_6_0;
  #pragma HLS STREAM variable=fifo_A_PE_6_0 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_6_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_6_1;
  #pragma HLS STREAM variable=fifo_A_PE_6_1 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_6_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_6_2;
  #pragma HLS STREAM variable=fifo_A_PE_6_2 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_6_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_6_3;
  #pragma HLS STREAM variable=fifo_A_PE_6_3 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_6_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_6_4;
  #pragma HLS STREAM variable=fifo_A_PE_6_4 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_6_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_6_5;
  #pragma HLS STREAM variable=fifo_A_PE_6_5 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_6_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_6_6;
  #pragma HLS STREAM variable=fifo_A_PE_6_6 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_6_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_6_7;
  #pragma HLS STREAM variable=fifo_A_PE_6_7 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_6_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_6_8;
  #pragma HLS STREAM variable=fifo_A_PE_6_8 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_6_8 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_7_0;
  #pragma HLS STREAM variable=fifo_A_PE_7_0 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_7_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_7_1;
  #pragma HLS STREAM variable=fifo_A_PE_7_1 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_7_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_7_2;
  #pragma HLS STREAM variable=fifo_A_PE_7_2 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_7_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_7_3;
  #pragma HLS STREAM variable=fifo_A_PE_7_3 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_7_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_7_4;
  #pragma HLS STREAM variable=fifo_A_PE_7_4 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_7_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_7_5;
  #pragma HLS STREAM variable=fifo_A_PE_7_5 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_7_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_7_6;
  #pragma HLS STREAM variable=fifo_A_PE_7_6 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_7_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_7_7;
  #pragma HLS STREAM variable=fifo_A_PE_7_7 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_7_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_7_8;
  #pragma HLS STREAM variable=fifo_A_PE_7_8 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_7_8 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_8_0;
  #pragma HLS STREAM variable=fifo_A_PE_8_0 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_8_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_8_1;
  #pragma HLS STREAM variable=fifo_A_PE_8_1 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_8_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_8_2;
  #pragma HLS STREAM variable=fifo_A_PE_8_2 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_8_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_8_3;
  #pragma HLS STREAM variable=fifo_A_PE_8_3 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_8_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_8_4;
  #pragma HLS STREAM variable=fifo_A_PE_8_4 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_8_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_8_5;
  #pragma HLS STREAM variable=fifo_A_PE_8_5 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_8_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_8_6;
  #pragma HLS STREAM variable=fifo_A_PE_8_6 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_8_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_8_7;
  #pragma HLS STREAM variable=fifo_A_PE_8_7 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_8_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_8_8;
  #pragma HLS STREAM variable=fifo_A_PE_8_8 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_8_8 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_9_0;
  #pragma HLS STREAM variable=fifo_A_PE_9_0 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_9_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_9_1;
  #pragma HLS STREAM variable=fifo_A_PE_9_1 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_9_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_9_2;
  #pragma HLS STREAM variable=fifo_A_PE_9_2 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_9_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_9_3;
  #pragma HLS STREAM variable=fifo_A_PE_9_3 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_9_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_9_4;
  #pragma HLS STREAM variable=fifo_A_PE_9_4 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_9_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_9_5;
  #pragma HLS STREAM variable=fifo_A_PE_9_5 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_9_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_9_6;
  #pragma HLS STREAM variable=fifo_A_PE_9_6 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_9_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_9_7;
  #pragma HLS STREAM variable=fifo_A_PE_9_7 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_9_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_9_8;
  #pragma HLS STREAM variable=fifo_A_PE_9_8 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_9_8 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_10_0;
  #pragma HLS STREAM variable=fifo_A_PE_10_0 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_10_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_10_1;
  #pragma HLS STREAM variable=fifo_A_PE_10_1 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_10_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_10_2;
  #pragma HLS STREAM variable=fifo_A_PE_10_2 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_10_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_10_3;
  #pragma HLS STREAM variable=fifo_A_PE_10_3 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_10_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_10_4;
  #pragma HLS STREAM variable=fifo_A_PE_10_4 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_10_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_10_5;
  #pragma HLS STREAM variable=fifo_A_PE_10_5 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_10_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_10_6;
  #pragma HLS STREAM variable=fifo_A_PE_10_6 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_10_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_10_7;
  #pragma HLS STREAM variable=fifo_A_PE_10_7 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_10_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_10_8;
  #pragma HLS STREAM variable=fifo_A_PE_10_8 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_10_8 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_11_0;
  #pragma HLS STREAM variable=fifo_A_PE_11_0 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_11_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_11_1;
  #pragma HLS STREAM variable=fifo_A_PE_11_1 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_11_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_11_2;
  #pragma HLS STREAM variable=fifo_A_PE_11_2 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_11_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_11_3;
  #pragma HLS STREAM variable=fifo_A_PE_11_3 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_11_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_11_4;
  #pragma HLS STREAM variable=fifo_A_PE_11_4 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_11_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_11_5;
  #pragma HLS STREAM variable=fifo_A_PE_11_5 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_11_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_11_6;
  #pragma HLS STREAM variable=fifo_A_PE_11_6 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_11_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_11_7;
  #pragma HLS STREAM variable=fifo_A_PE_11_7 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_11_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_11_8;
  #pragma HLS STREAM variable=fifo_A_PE_11_8 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_11_8 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_12_0;
  #pragma HLS STREAM variable=fifo_A_PE_12_0 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_12_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_12_1;
  #pragma HLS STREAM variable=fifo_A_PE_12_1 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_12_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_12_2;
  #pragma HLS STREAM variable=fifo_A_PE_12_2 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_12_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_12_3;
  #pragma HLS STREAM variable=fifo_A_PE_12_3 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_12_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_12_4;
  #pragma HLS STREAM variable=fifo_A_PE_12_4 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_12_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_12_5;
  #pragma HLS STREAM variable=fifo_A_PE_12_5 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_12_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_12_6;
  #pragma HLS STREAM variable=fifo_A_PE_12_6 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_12_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_12_7;
  #pragma HLS STREAM variable=fifo_A_PE_12_7 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_12_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<A_t8> fifo_A_PE_12_8;
  #pragma HLS STREAM variable=fifo_A_PE_12_8 depth=2
  #pragma HLS RESOURCE variable=fifo_A_PE_12_8 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_0_0;
  #pragma HLS STREAM variable=fifo_B_PE_0_0 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_0_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_1_0;
  #pragma HLS STREAM variable=fifo_B_PE_1_0 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_1_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_2_0;
  #pragma HLS STREAM variable=fifo_B_PE_2_0 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_2_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_3_0;
  #pragma HLS STREAM variable=fifo_B_PE_3_0 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_3_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_4_0;
  #pragma HLS STREAM variable=fifo_B_PE_4_0 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_4_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_5_0;
  #pragma HLS STREAM variable=fifo_B_PE_5_0 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_5_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_6_0;
  #pragma HLS STREAM variable=fifo_B_PE_6_0 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_6_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_7_0;
  #pragma HLS STREAM variable=fifo_B_PE_7_0 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_7_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_8_0;
  #pragma HLS STREAM variable=fifo_B_PE_8_0 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_8_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_9_0;
  #pragma HLS STREAM variable=fifo_B_PE_9_0 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_9_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_10_0;
  #pragma HLS STREAM variable=fifo_B_PE_10_0 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_10_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_11_0;
  #pragma HLS STREAM variable=fifo_B_PE_11_0 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_11_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_12_0;
  #pragma HLS STREAM variable=fifo_B_PE_12_0 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_12_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_13_0;
  #pragma HLS STREAM variable=fifo_B_PE_13_0 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_13_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_0_1;
  #pragma HLS STREAM variable=fifo_B_PE_0_1 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_0_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_1_1;
  #pragma HLS STREAM variable=fifo_B_PE_1_1 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_1_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_2_1;
  #pragma HLS STREAM variable=fifo_B_PE_2_1 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_2_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_3_1;
  #pragma HLS STREAM variable=fifo_B_PE_3_1 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_3_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_4_1;
  #pragma HLS STREAM variable=fifo_B_PE_4_1 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_4_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_5_1;
  #pragma HLS STREAM variable=fifo_B_PE_5_1 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_5_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_6_1;
  #pragma HLS STREAM variable=fifo_B_PE_6_1 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_6_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_7_1;
  #pragma HLS STREAM variable=fifo_B_PE_7_1 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_7_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_8_1;
  #pragma HLS STREAM variable=fifo_B_PE_8_1 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_8_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_9_1;
  #pragma HLS STREAM variable=fifo_B_PE_9_1 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_9_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_10_1;
  #pragma HLS STREAM variable=fifo_B_PE_10_1 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_10_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_11_1;
  #pragma HLS STREAM variable=fifo_B_PE_11_1 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_11_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_12_1;
  #pragma HLS STREAM variable=fifo_B_PE_12_1 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_12_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_13_1;
  #pragma HLS STREAM variable=fifo_B_PE_13_1 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_13_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_0_2;
  #pragma HLS STREAM variable=fifo_B_PE_0_2 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_0_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_1_2;
  #pragma HLS STREAM variable=fifo_B_PE_1_2 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_1_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_2_2;
  #pragma HLS STREAM variable=fifo_B_PE_2_2 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_2_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_3_2;
  #pragma HLS STREAM variable=fifo_B_PE_3_2 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_3_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_4_2;
  #pragma HLS STREAM variable=fifo_B_PE_4_2 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_4_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_5_2;
  #pragma HLS STREAM variable=fifo_B_PE_5_2 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_5_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_6_2;
  #pragma HLS STREAM variable=fifo_B_PE_6_2 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_6_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_7_2;
  #pragma HLS STREAM variable=fifo_B_PE_7_2 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_7_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_8_2;
  #pragma HLS STREAM variable=fifo_B_PE_8_2 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_8_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_9_2;
  #pragma HLS STREAM variable=fifo_B_PE_9_2 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_9_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_10_2;
  #pragma HLS STREAM variable=fifo_B_PE_10_2 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_10_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_11_2;
  #pragma HLS STREAM variable=fifo_B_PE_11_2 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_11_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_12_2;
  #pragma HLS STREAM variable=fifo_B_PE_12_2 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_12_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_13_2;
  #pragma HLS STREAM variable=fifo_B_PE_13_2 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_13_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_0_3;
  #pragma HLS STREAM variable=fifo_B_PE_0_3 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_0_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_1_3;
  #pragma HLS STREAM variable=fifo_B_PE_1_3 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_1_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_2_3;
  #pragma HLS STREAM variable=fifo_B_PE_2_3 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_2_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_3_3;
  #pragma HLS STREAM variable=fifo_B_PE_3_3 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_3_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_4_3;
  #pragma HLS STREAM variable=fifo_B_PE_4_3 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_4_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_5_3;
  #pragma HLS STREAM variable=fifo_B_PE_5_3 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_5_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_6_3;
  #pragma HLS STREAM variable=fifo_B_PE_6_3 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_6_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_7_3;
  #pragma HLS STREAM variable=fifo_B_PE_7_3 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_7_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_8_3;
  #pragma HLS STREAM variable=fifo_B_PE_8_3 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_8_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_9_3;
  #pragma HLS STREAM variable=fifo_B_PE_9_3 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_9_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_10_3;
  #pragma HLS STREAM variable=fifo_B_PE_10_3 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_10_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_11_3;
  #pragma HLS STREAM variable=fifo_B_PE_11_3 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_11_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_12_3;
  #pragma HLS STREAM variable=fifo_B_PE_12_3 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_12_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_13_3;
  #pragma HLS STREAM variable=fifo_B_PE_13_3 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_13_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_0_4;
  #pragma HLS STREAM variable=fifo_B_PE_0_4 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_0_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_1_4;
  #pragma HLS STREAM variable=fifo_B_PE_1_4 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_1_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_2_4;
  #pragma HLS STREAM variable=fifo_B_PE_2_4 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_2_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_3_4;
  #pragma HLS STREAM variable=fifo_B_PE_3_4 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_3_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_4_4;
  #pragma HLS STREAM variable=fifo_B_PE_4_4 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_4_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_5_4;
  #pragma HLS STREAM variable=fifo_B_PE_5_4 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_5_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_6_4;
  #pragma HLS STREAM variable=fifo_B_PE_6_4 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_6_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_7_4;
  #pragma HLS STREAM variable=fifo_B_PE_7_4 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_7_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_8_4;
  #pragma HLS STREAM variable=fifo_B_PE_8_4 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_8_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_9_4;
  #pragma HLS STREAM variable=fifo_B_PE_9_4 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_9_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_10_4;
  #pragma HLS STREAM variable=fifo_B_PE_10_4 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_10_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_11_4;
  #pragma HLS STREAM variable=fifo_B_PE_11_4 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_11_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_12_4;
  #pragma HLS STREAM variable=fifo_B_PE_12_4 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_12_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_13_4;
  #pragma HLS STREAM variable=fifo_B_PE_13_4 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_13_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_0_5;
  #pragma HLS STREAM variable=fifo_B_PE_0_5 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_0_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_1_5;
  #pragma HLS STREAM variable=fifo_B_PE_1_5 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_1_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_2_5;
  #pragma HLS STREAM variable=fifo_B_PE_2_5 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_2_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_3_5;
  #pragma HLS STREAM variable=fifo_B_PE_3_5 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_3_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_4_5;
  #pragma HLS STREAM variable=fifo_B_PE_4_5 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_4_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_5_5;
  #pragma HLS STREAM variable=fifo_B_PE_5_5 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_5_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_6_5;
  #pragma HLS STREAM variable=fifo_B_PE_6_5 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_6_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_7_5;
  #pragma HLS STREAM variable=fifo_B_PE_7_5 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_7_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_8_5;
  #pragma HLS STREAM variable=fifo_B_PE_8_5 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_8_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_9_5;
  #pragma HLS STREAM variable=fifo_B_PE_9_5 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_9_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_10_5;
  #pragma HLS STREAM variable=fifo_B_PE_10_5 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_10_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_11_5;
  #pragma HLS STREAM variable=fifo_B_PE_11_5 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_11_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_12_5;
  #pragma HLS STREAM variable=fifo_B_PE_12_5 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_12_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_13_5;
  #pragma HLS STREAM variable=fifo_B_PE_13_5 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_13_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_0_6;
  #pragma HLS STREAM variable=fifo_B_PE_0_6 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_0_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_1_6;
  #pragma HLS STREAM variable=fifo_B_PE_1_6 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_1_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_2_6;
  #pragma HLS STREAM variable=fifo_B_PE_2_6 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_2_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_3_6;
  #pragma HLS STREAM variable=fifo_B_PE_3_6 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_3_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_4_6;
  #pragma HLS STREAM variable=fifo_B_PE_4_6 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_4_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_5_6;
  #pragma HLS STREAM variable=fifo_B_PE_5_6 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_5_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_6_6;
  #pragma HLS STREAM variable=fifo_B_PE_6_6 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_6_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_7_6;
  #pragma HLS STREAM variable=fifo_B_PE_7_6 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_7_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_8_6;
  #pragma HLS STREAM variable=fifo_B_PE_8_6 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_8_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_9_6;
  #pragma HLS STREAM variable=fifo_B_PE_9_6 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_9_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_10_6;
  #pragma HLS STREAM variable=fifo_B_PE_10_6 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_10_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_11_6;
  #pragma HLS STREAM variable=fifo_B_PE_11_6 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_11_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_12_6;
  #pragma HLS STREAM variable=fifo_B_PE_12_6 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_12_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_13_6;
  #pragma HLS STREAM variable=fifo_B_PE_13_6 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_13_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_0_7;
  #pragma HLS STREAM variable=fifo_B_PE_0_7 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_0_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_1_7;
  #pragma HLS STREAM variable=fifo_B_PE_1_7 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_1_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_2_7;
  #pragma HLS STREAM variable=fifo_B_PE_2_7 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_2_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_3_7;
  #pragma HLS STREAM variable=fifo_B_PE_3_7 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_3_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_4_7;
  #pragma HLS STREAM variable=fifo_B_PE_4_7 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_4_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_5_7;
  #pragma HLS STREAM variable=fifo_B_PE_5_7 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_5_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_6_7;
  #pragma HLS STREAM variable=fifo_B_PE_6_7 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_6_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_7_7;
  #pragma HLS STREAM variable=fifo_B_PE_7_7 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_7_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_8_7;
  #pragma HLS STREAM variable=fifo_B_PE_8_7 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_8_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_9_7;
  #pragma HLS STREAM variable=fifo_B_PE_9_7 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_9_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_10_7;
  #pragma HLS STREAM variable=fifo_B_PE_10_7 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_10_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_11_7;
  #pragma HLS STREAM variable=fifo_B_PE_11_7 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_11_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_12_7;
  #pragma HLS STREAM variable=fifo_B_PE_12_7 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_12_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<B_t8> fifo_B_PE_13_7;
  #pragma HLS STREAM variable=fifo_B_PE_13_7 depth=2
  #pragma HLS RESOURCE variable=fifo_B_PE_13_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_0_0;
  #pragma HLS STREAM variable=fifo_C_drain_PE_0_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_0_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_1_0;
  #pragma HLS STREAM variable=fifo_C_drain_PE_1_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_1_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_2_0;
  #pragma HLS STREAM variable=fifo_C_drain_PE_2_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_2_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_3_0;
  #pragma HLS STREAM variable=fifo_C_drain_PE_3_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_3_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_4_0;
  #pragma HLS STREAM variable=fifo_C_drain_PE_4_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_4_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_5_0;
  #pragma HLS STREAM variable=fifo_C_drain_PE_5_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_5_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_6_0;
  #pragma HLS STREAM variable=fifo_C_drain_PE_6_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_6_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_7_0;
  #pragma HLS STREAM variable=fifo_C_drain_PE_7_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_7_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_8_0;
  #pragma HLS STREAM variable=fifo_C_drain_PE_8_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_8_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_9_0;
  #pragma HLS STREAM variable=fifo_C_drain_PE_9_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_9_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_10_0;
  #pragma HLS STREAM variable=fifo_C_drain_PE_10_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_10_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_11_0;
  #pragma HLS STREAM variable=fifo_C_drain_PE_11_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_11_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_12_0;
  #pragma HLS STREAM variable=fifo_C_drain_PE_12_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_12_0 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_0_1;
  #pragma HLS STREAM variable=fifo_C_drain_PE_0_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_0_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_1_1;
  #pragma HLS STREAM variable=fifo_C_drain_PE_1_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_1_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_2_1;
  #pragma HLS STREAM variable=fifo_C_drain_PE_2_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_2_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_3_1;
  #pragma HLS STREAM variable=fifo_C_drain_PE_3_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_3_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_4_1;
  #pragma HLS STREAM variable=fifo_C_drain_PE_4_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_4_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_5_1;
  #pragma HLS STREAM variable=fifo_C_drain_PE_5_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_5_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_6_1;
  #pragma HLS STREAM variable=fifo_C_drain_PE_6_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_6_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_7_1;
  #pragma HLS STREAM variable=fifo_C_drain_PE_7_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_7_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_8_1;
  #pragma HLS STREAM variable=fifo_C_drain_PE_8_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_8_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_9_1;
  #pragma HLS STREAM variable=fifo_C_drain_PE_9_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_9_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_10_1;
  #pragma HLS STREAM variable=fifo_C_drain_PE_10_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_10_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_11_1;
  #pragma HLS STREAM variable=fifo_C_drain_PE_11_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_11_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_12_1;
  #pragma HLS STREAM variable=fifo_C_drain_PE_12_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_12_1 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_0_2;
  #pragma HLS STREAM variable=fifo_C_drain_PE_0_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_0_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_1_2;
  #pragma HLS STREAM variable=fifo_C_drain_PE_1_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_1_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_2_2;
  #pragma HLS STREAM variable=fifo_C_drain_PE_2_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_2_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_3_2;
  #pragma HLS STREAM variable=fifo_C_drain_PE_3_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_3_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_4_2;
  #pragma HLS STREAM variable=fifo_C_drain_PE_4_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_4_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_5_2;
  #pragma HLS STREAM variable=fifo_C_drain_PE_5_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_5_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_6_2;
  #pragma HLS STREAM variable=fifo_C_drain_PE_6_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_6_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_7_2;
  #pragma HLS STREAM variable=fifo_C_drain_PE_7_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_7_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_8_2;
  #pragma HLS STREAM variable=fifo_C_drain_PE_8_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_8_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_9_2;
  #pragma HLS STREAM variable=fifo_C_drain_PE_9_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_9_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_10_2;
  #pragma HLS STREAM variable=fifo_C_drain_PE_10_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_10_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_11_2;
  #pragma HLS STREAM variable=fifo_C_drain_PE_11_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_11_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_12_2;
  #pragma HLS STREAM variable=fifo_C_drain_PE_12_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_12_2 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_0_3;
  #pragma HLS STREAM variable=fifo_C_drain_PE_0_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_0_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_1_3;
  #pragma HLS STREAM variable=fifo_C_drain_PE_1_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_1_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_2_3;
  #pragma HLS STREAM variable=fifo_C_drain_PE_2_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_2_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_3_3;
  #pragma HLS STREAM variable=fifo_C_drain_PE_3_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_3_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_4_3;
  #pragma HLS STREAM variable=fifo_C_drain_PE_4_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_4_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_5_3;
  #pragma HLS STREAM variable=fifo_C_drain_PE_5_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_5_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_6_3;
  #pragma HLS STREAM variable=fifo_C_drain_PE_6_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_6_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_7_3;
  #pragma HLS STREAM variable=fifo_C_drain_PE_7_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_7_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_8_3;
  #pragma HLS STREAM variable=fifo_C_drain_PE_8_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_8_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_9_3;
  #pragma HLS STREAM variable=fifo_C_drain_PE_9_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_9_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_10_3;
  #pragma HLS STREAM variable=fifo_C_drain_PE_10_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_10_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_11_3;
  #pragma HLS STREAM variable=fifo_C_drain_PE_11_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_11_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_12_3;
  #pragma HLS STREAM variable=fifo_C_drain_PE_12_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_12_3 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_0_4;
  #pragma HLS STREAM variable=fifo_C_drain_PE_0_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_0_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_1_4;
  #pragma HLS STREAM variable=fifo_C_drain_PE_1_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_1_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_2_4;
  #pragma HLS STREAM variable=fifo_C_drain_PE_2_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_2_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_3_4;
  #pragma HLS STREAM variable=fifo_C_drain_PE_3_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_3_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_4_4;
  #pragma HLS STREAM variable=fifo_C_drain_PE_4_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_4_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_5_4;
  #pragma HLS STREAM variable=fifo_C_drain_PE_5_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_5_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_6_4;
  #pragma HLS STREAM variable=fifo_C_drain_PE_6_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_6_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_7_4;
  #pragma HLS STREAM variable=fifo_C_drain_PE_7_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_7_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_8_4;
  #pragma HLS STREAM variable=fifo_C_drain_PE_8_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_8_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_9_4;
  #pragma HLS STREAM variable=fifo_C_drain_PE_9_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_9_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_10_4;
  #pragma HLS STREAM variable=fifo_C_drain_PE_10_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_10_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_11_4;
  #pragma HLS STREAM variable=fifo_C_drain_PE_11_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_11_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_12_4;
  #pragma HLS STREAM variable=fifo_C_drain_PE_12_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_12_4 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_0_5;
  #pragma HLS STREAM variable=fifo_C_drain_PE_0_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_0_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_1_5;
  #pragma HLS STREAM variable=fifo_C_drain_PE_1_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_1_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_2_5;
  #pragma HLS STREAM variable=fifo_C_drain_PE_2_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_2_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_3_5;
  #pragma HLS STREAM variable=fifo_C_drain_PE_3_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_3_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_4_5;
  #pragma HLS STREAM variable=fifo_C_drain_PE_4_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_4_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_5_5;
  #pragma HLS STREAM variable=fifo_C_drain_PE_5_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_5_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_6_5;
  #pragma HLS STREAM variable=fifo_C_drain_PE_6_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_6_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_7_5;
  #pragma HLS STREAM variable=fifo_C_drain_PE_7_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_7_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_8_5;
  #pragma HLS STREAM variable=fifo_C_drain_PE_8_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_8_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_9_5;
  #pragma HLS STREAM variable=fifo_C_drain_PE_9_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_9_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_10_5;
  #pragma HLS STREAM variable=fifo_C_drain_PE_10_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_10_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_11_5;
  #pragma HLS STREAM variable=fifo_C_drain_PE_11_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_11_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_12_5;
  #pragma HLS STREAM variable=fifo_C_drain_PE_12_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_12_5 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_0_6;
  #pragma HLS STREAM variable=fifo_C_drain_PE_0_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_0_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_1_6;
  #pragma HLS STREAM variable=fifo_C_drain_PE_1_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_1_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_2_6;
  #pragma HLS STREAM variable=fifo_C_drain_PE_2_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_2_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_3_6;
  #pragma HLS STREAM variable=fifo_C_drain_PE_3_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_3_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_4_6;
  #pragma HLS STREAM variable=fifo_C_drain_PE_4_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_4_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_5_6;
  #pragma HLS STREAM variable=fifo_C_drain_PE_5_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_5_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_6_6;
  #pragma HLS STREAM variable=fifo_C_drain_PE_6_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_6_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_7_6;
  #pragma HLS STREAM variable=fifo_C_drain_PE_7_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_7_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_8_6;
  #pragma HLS STREAM variable=fifo_C_drain_PE_8_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_8_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_9_6;
  #pragma HLS STREAM variable=fifo_C_drain_PE_9_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_9_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_10_6;
  #pragma HLS STREAM variable=fifo_C_drain_PE_10_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_10_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_11_6;
  #pragma HLS STREAM variable=fifo_C_drain_PE_11_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_11_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_12_6;
  #pragma HLS STREAM variable=fifo_C_drain_PE_12_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_12_6 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_0_7;
  #pragma HLS STREAM variable=fifo_C_drain_PE_0_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_0_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_1_7;
  #pragma HLS STREAM variable=fifo_C_drain_PE_1_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_1_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_2_7;
  #pragma HLS STREAM variable=fifo_C_drain_PE_2_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_2_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_3_7;
  #pragma HLS STREAM variable=fifo_C_drain_PE_3_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_3_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_4_7;
  #pragma HLS STREAM variable=fifo_C_drain_PE_4_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_4_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_5_7;
  #pragma HLS STREAM variable=fifo_C_drain_PE_5_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_5_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_6_7;
  #pragma HLS STREAM variable=fifo_C_drain_PE_6_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_6_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_7_7;
  #pragma HLS STREAM variable=fifo_C_drain_PE_7_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_7_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_8_7;
  #pragma HLS STREAM variable=fifo_C_drain_PE_8_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_8_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_9_7;
  #pragma HLS STREAM variable=fifo_C_drain_PE_9_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_9_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_10_7;
  #pragma HLS STREAM variable=fifo_C_drain_PE_10_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_10_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_11_7;
  #pragma HLS STREAM variable=fifo_C_drain_PE_11_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_11_7 core=FIFO_SRL
  /* PE fifo */ hls::stream<int> fifo_C_drain_PE_12_7;
  #pragma HLS STREAM variable=fifo_C_drain_PE_12_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_PE_12_7 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_0_0;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_0_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_0_0 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_0_1;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_0_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_0_1 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_0_2;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_0_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_0_2 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_0_3;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_0_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_0_3 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_0_4;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_0_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_0_4 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_0_5;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_0_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_0_5 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_0_6;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_0_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_0_6 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_0_7;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_0_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_0_7 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_0_8;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_0_8 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_0_8 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_0_9;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_0_9 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_0_9 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_0_10;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_0_10 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_0_10 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_0_11;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_0_11 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_0_11 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_0_12;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_0_12 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_0_12 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_0_13;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_0_13 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_0_13 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_1_0;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_1_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_1_0 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_1_1;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_1_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_1_1 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_1_2;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_1_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_1_2 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_1_3;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_1_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_1_3 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_1_4;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_1_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_1_4 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_1_5;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_1_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_1_5 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_1_6;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_1_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_1_6 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_1_7;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_1_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_1_7 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_1_8;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_1_8 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_1_8 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_1_9;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_1_9 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_1_9 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_1_10;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_1_10 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_1_10 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_1_11;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_1_11 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_1_11 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_1_12;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_1_12 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_1_12 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_1_13;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_1_13 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_1_13 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_2_0;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_2_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_2_0 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_2_1;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_2_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_2_1 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_2_2;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_2_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_2_2 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_2_3;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_2_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_2_3 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_2_4;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_2_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_2_4 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_2_5;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_2_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_2_5 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_2_6;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_2_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_2_6 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_2_7;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_2_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_2_7 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_2_8;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_2_8 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_2_8 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_2_9;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_2_9 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_2_9 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_2_10;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_2_10 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_2_10 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_2_11;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_2_11 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_2_11 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_2_12;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_2_12 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_2_12 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_2_13;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_2_13 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_2_13 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_3_0;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_3_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_3_0 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_3_1;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_3_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_3_1 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_3_2;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_3_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_3_2 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_3_3;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_3_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_3_3 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_3_4;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_3_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_3_4 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_3_5;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_3_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_3_5 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_3_6;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_3_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_3_6 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_3_7;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_3_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_3_7 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_3_8;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_3_8 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_3_8 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_3_9;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_3_9 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_3_9 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_3_10;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_3_10 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_3_10 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_3_11;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_3_11 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_3_11 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_3_12;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_3_12 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_3_12 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_3_13;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_3_13 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_3_13 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_4_0;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_4_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_4_0 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_4_1;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_4_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_4_1 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_4_2;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_4_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_4_2 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_4_3;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_4_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_4_3 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_4_4;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_4_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_4_4 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_4_5;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_4_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_4_5 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_4_6;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_4_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_4_6 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_4_7;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_4_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_4_7 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_4_8;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_4_8 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_4_8 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_4_9;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_4_9 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_4_9 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_4_10;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_4_10 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_4_10 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_4_11;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_4_11 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_4_11 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_4_12;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_4_12 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_4_12 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_4_13;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_4_13 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_4_13 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_5_0;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_5_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_5_0 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_5_1;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_5_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_5_1 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_5_2;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_5_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_5_2 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_5_3;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_5_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_5_3 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_5_4;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_5_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_5_4 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_5_5;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_5_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_5_5 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_5_6;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_5_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_5_6 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_5_7;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_5_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_5_7 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_5_8;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_5_8 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_5_8 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_5_9;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_5_9 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_5_9 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_5_10;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_5_10 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_5_10 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_5_11;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_5_11 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_5_11 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_5_12;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_5_12 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_5_12 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_5_13;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_5_13 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_5_13 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_6_0;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_6_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_6_0 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_6_1;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_6_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_6_1 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_6_2;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_6_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_6_2 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_6_3;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_6_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_6_3 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_6_4;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_6_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_6_4 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_6_5;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_6_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_6_5 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_6_6;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_6_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_6_6 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_6_7;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_6_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_6_7 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_6_8;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_6_8 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_6_8 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_6_9;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_6_9 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_6_9 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_6_10;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_6_10 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_6_10 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_6_11;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_6_11 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_6_11 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_6_12;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_6_12 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_6_12 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_6_13;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_6_13 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_6_13 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_7_0;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_7_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_7_0 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_7_1;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_7_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_7_1 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_7_2;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_7_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_7_2 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_7_3;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_7_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_7_3 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_7_4;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_7_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_7_4 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_7_5;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_7_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_7_5 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_7_6;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_7_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_7_6 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_7_7;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_7_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_7_7 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_7_8;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_7_8 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_7_8 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_7_9;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_7_9 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_7_9 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_7_10;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_7_10 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_7_10 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_7_11;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_7_11 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_7_11 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_7_12;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_7_12 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_7_12 core=FIFO_SRL
  /* C_drain_IO_L1_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L1_out_7_13;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L1_out_7_13 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L1_out_7_13 core=FIFO_SRL
  /* C_drain_IO_L2_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L2_out_0;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L2_out_0 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L2_out_0 core=FIFO_SRL
  /* C_drain_IO_L2_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L2_out_1;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L2_out_1 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L2_out_1 core=FIFO_SRL
  /* C_drain_IO_L2_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L2_out_2;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L2_out_2 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L2_out_2 core=FIFO_SRL
  /* C_drain_IO_L2_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L2_out_3;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L2_out_3 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L2_out_3 core=FIFO_SRL
  /* C_drain_IO_L2_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L2_out_4;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L2_out_4 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L2_out_4 core=FIFO_SRL
  /* C_drain_IO_L2_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L2_out_5;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L2_out_5 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L2_out_5 core=FIFO_SRL
  /* C_drain_IO_L2_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L2_out_6;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L2_out_6 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L2_out_6 core=FIFO_SRL
  /* C_drain_IO_L2_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L2_out_7;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L2_out_7 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L2_out_7 core=FIFO_SRL
  /* C_drain_IO_L2_out fifo */ hls::stream<C_t4> fifo_C_drain_C_drain_IO_L2_out_8;
  #pragma HLS STREAM variable=fifo_C_drain_C_drain_IO_L2_out_8 depth=2
  #pragma HLS RESOURCE variable=fifo_C_drain_C_drain_IO_L2_out_8 core=FIFO_SRL
  /* FIFO Declaration */

  /* Module Call */
  A_IO_L3_in_serialize(
    /* array */ A,
    /* fifo */ fifo_A_A_IO_L3_in_serialize
  );
  /* Module Call */

  /* Module Call */
  A_IO_L3_in(
    /* fifo */ fifo_A_A_IO_L3_in_serialize,
    /* fifo */ fifo_A_A_IO_L2_in_0
  );
  /* Module Call */

  /* Module Call */
  A_IO_L2_in(
    /* module id */ 0,
    /* fifo */ fifo_A_A_IO_L2_in_0,
    /* fifo */ fifo_A_A_IO_L2_in_1,
    /* fifo */ fifo_A_PE_0_0
  );
  /* Module Call */

  /* Module Call */
  A_IO_L2_in(
    /* module id */ 1,
    /* fifo */ fifo_A_A_IO_L2_in_1,
    /* fifo */ fifo_A_A_IO_L2_in_2,
    /* fifo */ fifo_A_PE_1_0
  );
  /* Module Call */

  /* Module Call */
  A_IO_L2_in(
    /* module id */ 2,
    /* fifo */ fifo_A_A_IO_L2_in_2,
    /* fifo */ fifo_A_A_IO_L2_in_3,
    /* fifo */ fifo_A_PE_2_0
  );
  /* Module Call */

  /* Module Call */
  A_IO_L2_in(
    /* module id */ 3,
    /* fifo */ fifo_A_A_IO_L2_in_3,
    /* fifo */ fifo_A_A_IO_L2_in_4,
    /* fifo */ fifo_A_PE_3_0
  );
  /* Module Call */

  /* Module Call */
  A_IO_L2_in(
    /* module id */ 4,
    /* fifo */ fifo_A_A_IO_L2_in_4,
    /* fifo */ fifo_A_A_IO_L2_in_5,
    /* fifo */ fifo_A_PE_4_0
  );
  /* Module Call */

  /* Module Call */
  A_IO_L2_in(
    /* module id */ 5,
    /* fifo */ fifo_A_A_IO_L2_in_5,
    /* fifo */ fifo_A_A_IO_L2_in_6,
    /* fifo */ fifo_A_PE_5_0
  );
  /* Module Call */

  /* Module Call */
  A_IO_L2_in(
    /* module id */ 6,
    /* fifo */ fifo_A_A_IO_L2_in_6,
    /* fifo */ fifo_A_A_IO_L2_in_7,
    /* fifo */ fifo_A_PE_6_0
  );
  /* Module Call */

  /* Module Call */
  A_IO_L2_in(
    /* module id */ 7,
    /* fifo */ fifo_A_A_IO_L2_in_7,
    /* fifo */ fifo_A_A_IO_L2_in_8,
    /* fifo */ fifo_A_PE_7_0
  );
  /* Module Call */

  /* Module Call */
  A_IO_L2_in(
    /* module id */ 8,
    /* fifo */ fifo_A_A_IO_L2_in_8,
    /* fifo */ fifo_A_A_IO_L2_in_9,
    /* fifo */ fifo_A_PE_8_0
  );
  /* Module Call */

  /* Module Call */
  A_IO_L2_in(
    /* module id */ 9,
    /* fifo */ fifo_A_A_IO_L2_in_9,
    /* fifo */ fifo_A_A_IO_L2_in_10,
    /* fifo */ fifo_A_PE_9_0
  );
  /* Module Call */

  /* Module Call */
  A_IO_L2_in(
    /* module id */ 10,
    /* fifo */ fifo_A_A_IO_L2_in_10,
    /* fifo */ fifo_A_A_IO_L2_in_11,
    /* fifo */ fifo_A_PE_10_0
  );
  /* Module Call */

  /* Module Call */
  A_IO_L2_in(
    /* module id */ 11,
    /* fifo */ fifo_A_A_IO_L2_in_11,
    /* fifo */ fifo_A_A_IO_L2_in_12,
    /* fifo */ fifo_A_PE_11_0
  );
  /* Module Call */

  /* Module Call */
  A_IO_L2_in_boundary(
    /* module id */ 12,
    /* fifo */ fifo_A_A_IO_L2_in_12,
    /* fifo */ fifo_A_PE_12_0
  );
  /* Module Call */

  /* Module Call */
  B_IO_L3_in_serialize(
    /* array */ B,
    /* fifo */ fifo_B_B_IO_L3_in_serialize
  );
  /* Module Call */

  /* Module Call */
  B_IO_L3_in(
    /* fifo */ fifo_B_B_IO_L3_in_serialize,
    /* fifo */ fifo_B_B_IO_L2_in_0
  );
  /* Module Call */

  /* Module Call */
  B_IO_L2_in(
    /* module id */ 0,
    /* fifo */ fifo_B_B_IO_L2_in_0,
    /* fifo */ fifo_B_B_IO_L2_in_1,
    /* fifo */ fifo_B_PE_0_0
  );
  /* Module Call */

  /* Module Call */
  B_IO_L2_in(
    /* module id */ 1,
    /* fifo */ fifo_B_B_IO_L2_in_1,
    /* fifo */ fifo_B_B_IO_L2_in_2,
    /* fifo */ fifo_B_PE_0_1
  );
  /* Module Call */

  /* Module Call */
  B_IO_L2_in(
    /* module id */ 2,
    /* fifo */ fifo_B_B_IO_L2_in_2,
    /* fifo */ fifo_B_B_IO_L2_in_3,
    /* fifo */ fifo_B_PE_0_2
  );
  /* Module Call */

  /* Module Call */
  B_IO_L2_in(
    /* module id */ 3,
    /* fifo */ fifo_B_B_IO_L2_in_3,
    /* fifo */ fifo_B_B_IO_L2_in_4,
    /* fifo */ fifo_B_PE_0_3
  );
  /* Module Call */

  /* Module Call */
  B_IO_L2_in(
    /* module id */ 4,
    /* fifo */ fifo_B_B_IO_L2_in_4,
    /* fifo */ fifo_B_B_IO_L2_in_5,
    /* fifo */ fifo_B_PE_0_4
  );
  /* Module Call */

  /* Module Call */
  B_IO_L2_in(
    /* module id */ 5,
    /* fifo */ fifo_B_B_IO_L2_in_5,
    /* fifo */ fifo_B_B_IO_L2_in_6,
    /* fifo */ fifo_B_PE_0_5
  );
  /* Module Call */

  /* Module Call */
  B_IO_L2_in(
    /* module id */ 6,
    /* fifo */ fifo_B_B_IO_L2_in_6,
    /* fifo */ fifo_B_B_IO_L2_in_7,
    /* fifo */ fifo_B_PE_0_6
  );
  /* Module Call */

  /* Module Call */
  B_IO_L2_in_boundary(
    /* module id */ 7,
    /* fifo */ fifo_B_B_IO_L2_in_7,
    /* fifo */ fifo_B_PE_0_7
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 0,
    /* module id */ 0,
    /* fifo */ fifo_A_PE_0_0,
    /* fifo */ fifo_A_PE_0_1,
    /* fifo */ fifo_B_PE_0_0,
    /* fifo */ fifo_B_PE_1_0,
    /* fifo */ fifo_C_drain_PE_0_0
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 0,
    /* module id */ 1,
    /* fifo */ fifo_A_PE_0_1,
    /* fifo */ fifo_A_PE_0_2,
    /* fifo */ fifo_B_PE_0_1,
    /* fifo */ fifo_B_PE_1_1,
    /* fifo */ fifo_C_drain_PE_0_1
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 0,
    /* module id */ 2,
    /* fifo */ fifo_A_PE_0_2,
    /* fifo */ fifo_A_PE_0_3,
    /* fifo */ fifo_B_PE_0_2,
    /* fifo */ fifo_B_PE_1_2,
    /* fifo */ fifo_C_drain_PE_0_2
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 0,
    /* module id */ 3,
    /* fifo */ fifo_A_PE_0_3,
    /* fifo */ fifo_A_PE_0_4,
    /* fifo */ fifo_B_PE_0_3,
    /* fifo */ fifo_B_PE_1_3,
    /* fifo */ fifo_C_drain_PE_0_3
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 0,
    /* module id */ 4,
    /* fifo */ fifo_A_PE_0_4,
    /* fifo */ fifo_A_PE_0_5,
    /* fifo */ fifo_B_PE_0_4,
    /* fifo */ fifo_B_PE_1_4,
    /* fifo */ fifo_C_drain_PE_0_4
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 0,
    /* module id */ 5,
    /* fifo */ fifo_A_PE_0_5,
    /* fifo */ fifo_A_PE_0_6,
    /* fifo */ fifo_B_PE_0_5,
    /* fifo */ fifo_B_PE_1_5,
    /* fifo */ fifo_C_drain_PE_0_5
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 0,
    /* module id */ 6,
    /* fifo */ fifo_A_PE_0_6,
    /* fifo */ fifo_A_PE_0_7,
    /* fifo */ fifo_B_PE_0_6,
    /* fifo */ fifo_B_PE_1_6,
    /* fifo */ fifo_C_drain_PE_0_6
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 0,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_0_7,
    /* fifo */ fifo_A_PE_0_8,
    /* fifo */ fifo_B_PE_0_7,
    /* fifo */ fifo_B_PE_1_7,
    /* fifo */ fifo_C_drain_PE_0_7
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 1,
    /* module id */ 0,
    /* fifo */ fifo_A_PE_1_0,
    /* fifo */ fifo_A_PE_1_1,
    /* fifo */ fifo_B_PE_1_0,
    /* fifo */ fifo_B_PE_2_0,
    /* fifo */ fifo_C_drain_PE_1_0
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 1,
    /* module id */ 1,
    /* fifo */ fifo_A_PE_1_1,
    /* fifo */ fifo_A_PE_1_2,
    /* fifo */ fifo_B_PE_1_1,
    /* fifo */ fifo_B_PE_2_1,
    /* fifo */ fifo_C_drain_PE_1_1
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 1,
    /* module id */ 2,
    /* fifo */ fifo_A_PE_1_2,
    /* fifo */ fifo_A_PE_1_3,
    /* fifo */ fifo_B_PE_1_2,
    /* fifo */ fifo_B_PE_2_2,
    /* fifo */ fifo_C_drain_PE_1_2
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 1,
    /* module id */ 3,
    /* fifo */ fifo_A_PE_1_3,
    /* fifo */ fifo_A_PE_1_4,
    /* fifo */ fifo_B_PE_1_3,
    /* fifo */ fifo_B_PE_2_3,
    /* fifo */ fifo_C_drain_PE_1_3
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 1,
    /* module id */ 4,
    /* fifo */ fifo_A_PE_1_4,
    /* fifo */ fifo_A_PE_1_5,
    /* fifo */ fifo_B_PE_1_4,
    /* fifo */ fifo_B_PE_2_4,
    /* fifo */ fifo_C_drain_PE_1_4
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 1,
    /* module id */ 5,
    /* fifo */ fifo_A_PE_1_5,
    /* fifo */ fifo_A_PE_1_6,
    /* fifo */ fifo_B_PE_1_5,
    /* fifo */ fifo_B_PE_2_5,
    /* fifo */ fifo_C_drain_PE_1_5
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 1,
    /* module id */ 6,
    /* fifo */ fifo_A_PE_1_6,
    /* fifo */ fifo_A_PE_1_7,
    /* fifo */ fifo_B_PE_1_6,
    /* fifo */ fifo_B_PE_2_6,
    /* fifo */ fifo_C_drain_PE_1_6
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 1,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_1_7,
    /* fifo */ fifo_A_PE_1_8,
    /* fifo */ fifo_B_PE_1_7,
    /* fifo */ fifo_B_PE_2_7,
    /* fifo */ fifo_C_drain_PE_1_7
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 2,
    /* module id */ 0,
    /* fifo */ fifo_A_PE_2_0,
    /* fifo */ fifo_A_PE_2_1,
    /* fifo */ fifo_B_PE_2_0,
    /* fifo */ fifo_B_PE_3_0,
    /* fifo */ fifo_C_drain_PE_2_0
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 2,
    /* module id */ 1,
    /* fifo */ fifo_A_PE_2_1,
    /* fifo */ fifo_A_PE_2_2,
    /* fifo */ fifo_B_PE_2_1,
    /* fifo */ fifo_B_PE_3_1,
    /* fifo */ fifo_C_drain_PE_2_1
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 2,
    /* module id */ 2,
    /* fifo */ fifo_A_PE_2_2,
    /* fifo */ fifo_A_PE_2_3,
    /* fifo */ fifo_B_PE_2_2,
    /* fifo */ fifo_B_PE_3_2,
    /* fifo */ fifo_C_drain_PE_2_2
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 2,
    /* module id */ 3,
    /* fifo */ fifo_A_PE_2_3,
    /* fifo */ fifo_A_PE_2_4,
    /* fifo */ fifo_B_PE_2_3,
    /* fifo */ fifo_B_PE_3_3,
    /* fifo */ fifo_C_drain_PE_2_3
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 2,
    /* module id */ 4,
    /* fifo */ fifo_A_PE_2_4,
    /* fifo */ fifo_A_PE_2_5,
    /* fifo */ fifo_B_PE_2_4,
    /* fifo */ fifo_B_PE_3_4,
    /* fifo */ fifo_C_drain_PE_2_4
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 2,
    /* module id */ 5,
    /* fifo */ fifo_A_PE_2_5,
    /* fifo */ fifo_A_PE_2_6,
    /* fifo */ fifo_B_PE_2_5,
    /* fifo */ fifo_B_PE_3_5,
    /* fifo */ fifo_C_drain_PE_2_5
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 2,
    /* module id */ 6,
    /* fifo */ fifo_A_PE_2_6,
    /* fifo */ fifo_A_PE_2_7,
    /* fifo */ fifo_B_PE_2_6,
    /* fifo */ fifo_B_PE_3_6,
    /* fifo */ fifo_C_drain_PE_2_6
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 2,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_2_7,
    /* fifo */ fifo_A_PE_2_8,
    /* fifo */ fifo_B_PE_2_7,
    /* fifo */ fifo_B_PE_3_7,
    /* fifo */ fifo_C_drain_PE_2_7
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 3,
    /* module id */ 0,
    /* fifo */ fifo_A_PE_3_0,
    /* fifo */ fifo_A_PE_3_1,
    /* fifo */ fifo_B_PE_3_0,
    /* fifo */ fifo_B_PE_4_0,
    /* fifo */ fifo_C_drain_PE_3_0
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 3,
    /* module id */ 1,
    /* fifo */ fifo_A_PE_3_1,
    /* fifo */ fifo_A_PE_3_2,
    /* fifo */ fifo_B_PE_3_1,
    /* fifo */ fifo_B_PE_4_1,
    /* fifo */ fifo_C_drain_PE_3_1
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 3,
    /* module id */ 2,
    /* fifo */ fifo_A_PE_3_2,
    /* fifo */ fifo_A_PE_3_3,
    /* fifo */ fifo_B_PE_3_2,
    /* fifo */ fifo_B_PE_4_2,
    /* fifo */ fifo_C_drain_PE_3_2
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 3,
    /* module id */ 3,
    /* fifo */ fifo_A_PE_3_3,
    /* fifo */ fifo_A_PE_3_4,
    /* fifo */ fifo_B_PE_3_3,
    /* fifo */ fifo_B_PE_4_3,
    /* fifo */ fifo_C_drain_PE_3_3
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 3,
    /* module id */ 4,
    /* fifo */ fifo_A_PE_3_4,
    /* fifo */ fifo_A_PE_3_5,
    /* fifo */ fifo_B_PE_3_4,
    /* fifo */ fifo_B_PE_4_4,
    /* fifo */ fifo_C_drain_PE_3_4
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 3,
    /* module id */ 5,
    /* fifo */ fifo_A_PE_3_5,
    /* fifo */ fifo_A_PE_3_6,
    /* fifo */ fifo_B_PE_3_5,
    /* fifo */ fifo_B_PE_4_5,
    /* fifo */ fifo_C_drain_PE_3_5
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 3,
    /* module id */ 6,
    /* fifo */ fifo_A_PE_3_6,
    /* fifo */ fifo_A_PE_3_7,
    /* fifo */ fifo_B_PE_3_6,
    /* fifo */ fifo_B_PE_4_6,
    /* fifo */ fifo_C_drain_PE_3_6
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 3,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_3_7,
    /* fifo */ fifo_A_PE_3_8,
    /* fifo */ fifo_B_PE_3_7,
    /* fifo */ fifo_B_PE_4_7,
    /* fifo */ fifo_C_drain_PE_3_7
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 4,
    /* module id */ 0,
    /* fifo */ fifo_A_PE_4_0,
    /* fifo */ fifo_A_PE_4_1,
    /* fifo */ fifo_B_PE_4_0,
    /* fifo */ fifo_B_PE_5_0,
    /* fifo */ fifo_C_drain_PE_4_0
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 4,
    /* module id */ 1,
    /* fifo */ fifo_A_PE_4_1,
    /* fifo */ fifo_A_PE_4_2,
    /* fifo */ fifo_B_PE_4_1,
    /* fifo */ fifo_B_PE_5_1,
    /* fifo */ fifo_C_drain_PE_4_1
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 4,
    /* module id */ 2,
    /* fifo */ fifo_A_PE_4_2,
    /* fifo */ fifo_A_PE_4_3,
    /* fifo */ fifo_B_PE_4_2,
    /* fifo */ fifo_B_PE_5_2,
    /* fifo */ fifo_C_drain_PE_4_2
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 4,
    /* module id */ 3,
    /* fifo */ fifo_A_PE_4_3,
    /* fifo */ fifo_A_PE_4_4,
    /* fifo */ fifo_B_PE_4_3,
    /* fifo */ fifo_B_PE_5_3,
    /* fifo */ fifo_C_drain_PE_4_3
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 4,
    /* module id */ 4,
    /* fifo */ fifo_A_PE_4_4,
    /* fifo */ fifo_A_PE_4_5,
    /* fifo */ fifo_B_PE_4_4,
    /* fifo */ fifo_B_PE_5_4,
    /* fifo */ fifo_C_drain_PE_4_4
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 4,
    /* module id */ 5,
    /* fifo */ fifo_A_PE_4_5,
    /* fifo */ fifo_A_PE_4_6,
    /* fifo */ fifo_B_PE_4_5,
    /* fifo */ fifo_B_PE_5_5,
    /* fifo */ fifo_C_drain_PE_4_5
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 4,
    /* module id */ 6,
    /* fifo */ fifo_A_PE_4_6,
    /* fifo */ fifo_A_PE_4_7,
    /* fifo */ fifo_B_PE_4_6,
    /* fifo */ fifo_B_PE_5_6,
    /* fifo */ fifo_C_drain_PE_4_6
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 4,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_4_7,
    /* fifo */ fifo_A_PE_4_8,
    /* fifo */ fifo_B_PE_4_7,
    /* fifo */ fifo_B_PE_5_7,
    /* fifo */ fifo_C_drain_PE_4_7
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 5,
    /* module id */ 0,
    /* fifo */ fifo_A_PE_5_0,
    /* fifo */ fifo_A_PE_5_1,
    /* fifo */ fifo_B_PE_5_0,
    /* fifo */ fifo_B_PE_6_0,
    /* fifo */ fifo_C_drain_PE_5_0
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 5,
    /* module id */ 1,
    /* fifo */ fifo_A_PE_5_1,
    /* fifo */ fifo_A_PE_5_2,
    /* fifo */ fifo_B_PE_5_1,
    /* fifo */ fifo_B_PE_6_1,
    /* fifo */ fifo_C_drain_PE_5_1
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 5,
    /* module id */ 2,
    /* fifo */ fifo_A_PE_5_2,
    /* fifo */ fifo_A_PE_5_3,
    /* fifo */ fifo_B_PE_5_2,
    /* fifo */ fifo_B_PE_6_2,
    /* fifo */ fifo_C_drain_PE_5_2
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 5,
    /* module id */ 3,
    /* fifo */ fifo_A_PE_5_3,
    /* fifo */ fifo_A_PE_5_4,
    /* fifo */ fifo_B_PE_5_3,
    /* fifo */ fifo_B_PE_6_3,
    /* fifo */ fifo_C_drain_PE_5_3
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 5,
    /* module id */ 4,
    /* fifo */ fifo_A_PE_5_4,
    /* fifo */ fifo_A_PE_5_5,
    /* fifo */ fifo_B_PE_5_4,
    /* fifo */ fifo_B_PE_6_4,
    /* fifo */ fifo_C_drain_PE_5_4
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 5,
    /* module id */ 5,
    /* fifo */ fifo_A_PE_5_5,
    /* fifo */ fifo_A_PE_5_6,
    /* fifo */ fifo_B_PE_5_5,
    /* fifo */ fifo_B_PE_6_5,
    /* fifo */ fifo_C_drain_PE_5_5
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 5,
    /* module id */ 6,
    /* fifo */ fifo_A_PE_5_6,
    /* fifo */ fifo_A_PE_5_7,
    /* fifo */ fifo_B_PE_5_6,
    /* fifo */ fifo_B_PE_6_6,
    /* fifo */ fifo_C_drain_PE_5_6
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 5,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_5_7,
    /* fifo */ fifo_A_PE_5_8,
    /* fifo */ fifo_B_PE_5_7,
    /* fifo */ fifo_B_PE_6_7,
    /* fifo */ fifo_C_drain_PE_5_7
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 6,
    /* module id */ 0,
    /* fifo */ fifo_A_PE_6_0,
    /* fifo */ fifo_A_PE_6_1,
    /* fifo */ fifo_B_PE_6_0,
    /* fifo */ fifo_B_PE_7_0,
    /* fifo */ fifo_C_drain_PE_6_0
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 6,
    /* module id */ 1,
    /* fifo */ fifo_A_PE_6_1,
    /* fifo */ fifo_A_PE_6_2,
    /* fifo */ fifo_B_PE_6_1,
    /* fifo */ fifo_B_PE_7_1,
    /* fifo */ fifo_C_drain_PE_6_1
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 6,
    /* module id */ 2,
    /* fifo */ fifo_A_PE_6_2,
    /* fifo */ fifo_A_PE_6_3,
    /* fifo */ fifo_B_PE_6_2,
    /* fifo */ fifo_B_PE_7_2,
    /* fifo */ fifo_C_drain_PE_6_2
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 6,
    /* module id */ 3,
    /* fifo */ fifo_A_PE_6_3,
    /* fifo */ fifo_A_PE_6_4,
    /* fifo */ fifo_B_PE_6_3,
    /* fifo */ fifo_B_PE_7_3,
    /* fifo */ fifo_C_drain_PE_6_3
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 6,
    /* module id */ 4,
    /* fifo */ fifo_A_PE_6_4,
    /* fifo */ fifo_A_PE_6_5,
    /* fifo */ fifo_B_PE_6_4,
    /* fifo */ fifo_B_PE_7_4,
    /* fifo */ fifo_C_drain_PE_6_4
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 6,
    /* module id */ 5,
    /* fifo */ fifo_A_PE_6_5,
    /* fifo */ fifo_A_PE_6_6,
    /* fifo */ fifo_B_PE_6_5,
    /* fifo */ fifo_B_PE_7_5,
    /* fifo */ fifo_C_drain_PE_6_5
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 6,
    /* module id */ 6,
    /* fifo */ fifo_A_PE_6_6,
    /* fifo */ fifo_A_PE_6_7,
    /* fifo */ fifo_B_PE_6_6,
    /* fifo */ fifo_B_PE_7_6,
    /* fifo */ fifo_C_drain_PE_6_6
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 6,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_6_7,
    /* fifo */ fifo_A_PE_6_8,
    /* fifo */ fifo_B_PE_6_7,
    /* fifo */ fifo_B_PE_7_7,
    /* fifo */ fifo_C_drain_PE_6_7
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 7,
    /* module id */ 0,
    /* fifo */ fifo_A_PE_7_0,
    /* fifo */ fifo_A_PE_7_1,
    /* fifo */ fifo_B_PE_7_0,
    /* fifo */ fifo_B_PE_8_0,
    /* fifo */ fifo_C_drain_PE_7_0
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 7,
    /* module id */ 1,
    /* fifo */ fifo_A_PE_7_1,
    /* fifo */ fifo_A_PE_7_2,
    /* fifo */ fifo_B_PE_7_1,
    /* fifo */ fifo_B_PE_8_1,
    /* fifo */ fifo_C_drain_PE_7_1
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 7,
    /* module id */ 2,
    /* fifo */ fifo_A_PE_7_2,
    /* fifo */ fifo_A_PE_7_3,
    /* fifo */ fifo_B_PE_7_2,
    /* fifo */ fifo_B_PE_8_2,
    /* fifo */ fifo_C_drain_PE_7_2
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 7,
    /* module id */ 3,
    /* fifo */ fifo_A_PE_7_3,
    /* fifo */ fifo_A_PE_7_4,
    /* fifo */ fifo_B_PE_7_3,
    /* fifo */ fifo_B_PE_8_3,
    /* fifo */ fifo_C_drain_PE_7_3
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 7,
    /* module id */ 4,
    /* fifo */ fifo_A_PE_7_4,
    /* fifo */ fifo_A_PE_7_5,
    /* fifo */ fifo_B_PE_7_4,
    /* fifo */ fifo_B_PE_8_4,
    /* fifo */ fifo_C_drain_PE_7_4
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 7,
    /* module id */ 5,
    /* fifo */ fifo_A_PE_7_5,
    /* fifo */ fifo_A_PE_7_6,
    /* fifo */ fifo_B_PE_7_5,
    /* fifo */ fifo_B_PE_8_5,
    /* fifo */ fifo_C_drain_PE_7_5
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 7,
    /* module id */ 6,
    /* fifo */ fifo_A_PE_7_6,
    /* fifo */ fifo_A_PE_7_7,
    /* fifo */ fifo_B_PE_7_6,
    /* fifo */ fifo_B_PE_8_6,
    /* fifo */ fifo_C_drain_PE_7_6
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 7,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_7_7,
    /* fifo */ fifo_A_PE_7_8,
    /* fifo */ fifo_B_PE_7_7,
    /* fifo */ fifo_B_PE_8_7,
    /* fifo */ fifo_C_drain_PE_7_7
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 8,
    /* module id */ 0,
    /* fifo */ fifo_A_PE_8_0,
    /* fifo */ fifo_A_PE_8_1,
    /* fifo */ fifo_B_PE_8_0,
    /* fifo */ fifo_B_PE_9_0,
    /* fifo */ fifo_C_drain_PE_8_0
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 8,
    /* module id */ 1,
    /* fifo */ fifo_A_PE_8_1,
    /* fifo */ fifo_A_PE_8_2,
    /* fifo */ fifo_B_PE_8_1,
    /* fifo */ fifo_B_PE_9_1,
    /* fifo */ fifo_C_drain_PE_8_1
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 8,
    /* module id */ 2,
    /* fifo */ fifo_A_PE_8_2,
    /* fifo */ fifo_A_PE_8_3,
    /* fifo */ fifo_B_PE_8_2,
    /* fifo */ fifo_B_PE_9_2,
    /* fifo */ fifo_C_drain_PE_8_2
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 8,
    /* module id */ 3,
    /* fifo */ fifo_A_PE_8_3,
    /* fifo */ fifo_A_PE_8_4,
    /* fifo */ fifo_B_PE_8_3,
    /* fifo */ fifo_B_PE_9_3,
    /* fifo */ fifo_C_drain_PE_8_3
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 8,
    /* module id */ 4,
    /* fifo */ fifo_A_PE_8_4,
    /* fifo */ fifo_A_PE_8_5,
    /* fifo */ fifo_B_PE_8_4,
    /* fifo */ fifo_B_PE_9_4,
    /* fifo */ fifo_C_drain_PE_8_4
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 8,
    /* module id */ 5,
    /* fifo */ fifo_A_PE_8_5,
    /* fifo */ fifo_A_PE_8_6,
    /* fifo */ fifo_B_PE_8_5,
    /* fifo */ fifo_B_PE_9_5,
    /* fifo */ fifo_C_drain_PE_8_5
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 8,
    /* module id */ 6,
    /* fifo */ fifo_A_PE_8_6,
    /* fifo */ fifo_A_PE_8_7,
    /* fifo */ fifo_B_PE_8_6,
    /* fifo */ fifo_B_PE_9_6,
    /* fifo */ fifo_C_drain_PE_8_6
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 8,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_8_7,
    /* fifo */ fifo_A_PE_8_8,
    /* fifo */ fifo_B_PE_8_7,
    /* fifo */ fifo_B_PE_9_7,
    /* fifo */ fifo_C_drain_PE_8_7
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 9,
    /* module id */ 0,
    /* fifo */ fifo_A_PE_9_0,
    /* fifo */ fifo_A_PE_9_1,
    /* fifo */ fifo_B_PE_9_0,
    /* fifo */ fifo_B_PE_10_0,
    /* fifo */ fifo_C_drain_PE_9_0
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 9,
    /* module id */ 1,
    /* fifo */ fifo_A_PE_9_1,
    /* fifo */ fifo_A_PE_9_2,
    /* fifo */ fifo_B_PE_9_1,
    /* fifo */ fifo_B_PE_10_1,
    /* fifo */ fifo_C_drain_PE_9_1
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 9,
    /* module id */ 2,
    /* fifo */ fifo_A_PE_9_2,
    /* fifo */ fifo_A_PE_9_3,
    /* fifo */ fifo_B_PE_9_2,
    /* fifo */ fifo_B_PE_10_2,
    /* fifo */ fifo_C_drain_PE_9_2
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 9,
    /* module id */ 3,
    /* fifo */ fifo_A_PE_9_3,
    /* fifo */ fifo_A_PE_9_4,
    /* fifo */ fifo_B_PE_9_3,
    /* fifo */ fifo_B_PE_10_3,
    /* fifo */ fifo_C_drain_PE_9_3
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 9,
    /* module id */ 4,
    /* fifo */ fifo_A_PE_9_4,
    /* fifo */ fifo_A_PE_9_5,
    /* fifo */ fifo_B_PE_9_4,
    /* fifo */ fifo_B_PE_10_4,
    /* fifo */ fifo_C_drain_PE_9_4
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 9,
    /* module id */ 5,
    /* fifo */ fifo_A_PE_9_5,
    /* fifo */ fifo_A_PE_9_6,
    /* fifo */ fifo_B_PE_9_5,
    /* fifo */ fifo_B_PE_10_5,
    /* fifo */ fifo_C_drain_PE_9_5
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 9,
    /* module id */ 6,
    /* fifo */ fifo_A_PE_9_6,
    /* fifo */ fifo_A_PE_9_7,
    /* fifo */ fifo_B_PE_9_6,
    /* fifo */ fifo_B_PE_10_6,
    /* fifo */ fifo_C_drain_PE_9_6
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 9,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_9_7,
    /* fifo */ fifo_A_PE_9_8,
    /* fifo */ fifo_B_PE_9_7,
    /* fifo */ fifo_B_PE_10_7,
    /* fifo */ fifo_C_drain_PE_9_7
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 10,
    /* module id */ 0,
    /* fifo */ fifo_A_PE_10_0,
    /* fifo */ fifo_A_PE_10_1,
    /* fifo */ fifo_B_PE_10_0,
    /* fifo */ fifo_B_PE_11_0,
    /* fifo */ fifo_C_drain_PE_10_0
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 10,
    /* module id */ 1,
    /* fifo */ fifo_A_PE_10_1,
    /* fifo */ fifo_A_PE_10_2,
    /* fifo */ fifo_B_PE_10_1,
    /* fifo */ fifo_B_PE_11_1,
    /* fifo */ fifo_C_drain_PE_10_1
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 10,
    /* module id */ 2,
    /* fifo */ fifo_A_PE_10_2,
    /* fifo */ fifo_A_PE_10_3,
    /* fifo */ fifo_B_PE_10_2,
    /* fifo */ fifo_B_PE_11_2,
    /* fifo */ fifo_C_drain_PE_10_2
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 10,
    /* module id */ 3,
    /* fifo */ fifo_A_PE_10_3,
    /* fifo */ fifo_A_PE_10_4,
    /* fifo */ fifo_B_PE_10_3,
    /* fifo */ fifo_B_PE_11_3,
    /* fifo */ fifo_C_drain_PE_10_3
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 10,
    /* module id */ 4,
    /* fifo */ fifo_A_PE_10_4,
    /* fifo */ fifo_A_PE_10_5,
    /* fifo */ fifo_B_PE_10_4,
    /* fifo */ fifo_B_PE_11_4,
    /* fifo */ fifo_C_drain_PE_10_4
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 10,
    /* module id */ 5,
    /* fifo */ fifo_A_PE_10_5,
    /* fifo */ fifo_A_PE_10_6,
    /* fifo */ fifo_B_PE_10_5,
    /* fifo */ fifo_B_PE_11_5,
    /* fifo */ fifo_C_drain_PE_10_5
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 10,
    /* module id */ 6,
    /* fifo */ fifo_A_PE_10_6,
    /* fifo */ fifo_A_PE_10_7,
    /* fifo */ fifo_B_PE_10_6,
    /* fifo */ fifo_B_PE_11_6,
    /* fifo */ fifo_C_drain_PE_10_6
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 10,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_10_7,
    /* fifo */ fifo_A_PE_10_8,
    /* fifo */ fifo_B_PE_10_7,
    /* fifo */ fifo_B_PE_11_7,
    /* fifo */ fifo_C_drain_PE_10_7
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 11,
    /* module id */ 0,
    /* fifo */ fifo_A_PE_11_0,
    /* fifo */ fifo_A_PE_11_1,
    /* fifo */ fifo_B_PE_11_0,
    /* fifo */ fifo_B_PE_12_0,
    /* fifo */ fifo_C_drain_PE_11_0
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 11,
    /* module id */ 1,
    /* fifo */ fifo_A_PE_11_1,
    /* fifo */ fifo_A_PE_11_2,
    /* fifo */ fifo_B_PE_11_1,
    /* fifo */ fifo_B_PE_12_1,
    /* fifo */ fifo_C_drain_PE_11_1
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 11,
    /* module id */ 2,
    /* fifo */ fifo_A_PE_11_2,
    /* fifo */ fifo_A_PE_11_3,
    /* fifo */ fifo_B_PE_11_2,
    /* fifo */ fifo_B_PE_12_2,
    /* fifo */ fifo_C_drain_PE_11_2
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 11,
    /* module id */ 3,
    /* fifo */ fifo_A_PE_11_3,
    /* fifo */ fifo_A_PE_11_4,
    /* fifo */ fifo_B_PE_11_3,
    /* fifo */ fifo_B_PE_12_3,
    /* fifo */ fifo_C_drain_PE_11_3
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 11,
    /* module id */ 4,
    /* fifo */ fifo_A_PE_11_4,
    /* fifo */ fifo_A_PE_11_5,
    /* fifo */ fifo_B_PE_11_4,
    /* fifo */ fifo_B_PE_12_4,
    /* fifo */ fifo_C_drain_PE_11_4
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 11,
    /* module id */ 5,
    /* fifo */ fifo_A_PE_11_5,
    /* fifo */ fifo_A_PE_11_6,
    /* fifo */ fifo_B_PE_11_5,
    /* fifo */ fifo_B_PE_12_5,
    /* fifo */ fifo_C_drain_PE_11_5
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 11,
    /* module id */ 6,
    /* fifo */ fifo_A_PE_11_6,
    /* fifo */ fifo_A_PE_11_7,
    /* fifo */ fifo_B_PE_11_6,
    /* fifo */ fifo_B_PE_12_6,
    /* fifo */ fifo_C_drain_PE_11_6
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 11,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_11_7,
    /* fifo */ fifo_A_PE_11_8,
    /* fifo */ fifo_B_PE_11_7,
    /* fifo */ fifo_B_PE_12_7,
    /* fifo */ fifo_C_drain_PE_11_7
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 12,
    /* module id */ 0,
    /* fifo */ fifo_A_PE_12_0,
    /* fifo */ fifo_A_PE_12_1,
    /* fifo */ fifo_B_PE_12_0,
    /* fifo */ fifo_B_PE_13_0,
    /* fifo */ fifo_C_drain_PE_12_0
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 12,
    /* module id */ 1,
    /* fifo */ fifo_A_PE_12_1,
    /* fifo */ fifo_A_PE_12_2,
    /* fifo */ fifo_B_PE_12_1,
    /* fifo */ fifo_B_PE_13_1,
    /* fifo */ fifo_C_drain_PE_12_1
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 12,
    /* module id */ 2,
    /* fifo */ fifo_A_PE_12_2,
    /* fifo */ fifo_A_PE_12_3,
    /* fifo */ fifo_B_PE_12_2,
    /* fifo */ fifo_B_PE_13_2,
    /* fifo */ fifo_C_drain_PE_12_2
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 12,
    /* module id */ 3,
    /* fifo */ fifo_A_PE_12_3,
    /* fifo */ fifo_A_PE_12_4,
    /* fifo */ fifo_B_PE_12_3,
    /* fifo */ fifo_B_PE_13_3,
    /* fifo */ fifo_C_drain_PE_12_3
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 12,
    /* module id */ 4,
    /* fifo */ fifo_A_PE_12_4,
    /* fifo */ fifo_A_PE_12_5,
    /* fifo */ fifo_B_PE_12_4,
    /* fifo */ fifo_B_PE_13_4,
    /* fifo */ fifo_C_drain_PE_12_4
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 12,
    /* module id */ 5,
    /* fifo */ fifo_A_PE_12_5,
    /* fifo */ fifo_A_PE_12_6,
    /* fifo */ fifo_B_PE_12_5,
    /* fifo */ fifo_B_PE_13_5,
    /* fifo */ fifo_C_drain_PE_12_5
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 12,
    /* module id */ 6,
    /* fifo */ fifo_A_PE_12_6,
    /* fifo */ fifo_A_PE_12_7,
    /* fifo */ fifo_B_PE_12_6,
    /* fifo */ fifo_B_PE_13_6,
    /* fifo */ fifo_C_drain_PE_12_6
  );
  /* Module Call */

  /* Module Call */
  PE_wrapper(
    /* module id */ 12,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_12_7,
    /* fifo */ fifo_A_PE_12_8,
    /* fifo */ fifo_B_PE_12_7,
    /* fifo */ fifo_B_PE_13_7,
    /* fifo */ fifo_C_drain_PE_12_7
  );
  /* Module Call */

  /* Module Call */
  A_PE_dummy_in(
    /* module id */ 0,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_0_8
  );
  /* Module Call */

  /* Module Call */
  A_PE_dummy_in(
    /* module id */ 1,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_1_8
  );
  /* Module Call */

  /* Module Call */
  A_PE_dummy_in(
    /* module id */ 2,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_2_8
  );
  /* Module Call */

  /* Module Call */
  A_PE_dummy_in(
    /* module id */ 3,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_3_8
  );
  /* Module Call */

  /* Module Call */
  A_PE_dummy_in(
    /* module id */ 4,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_4_8
  );
  /* Module Call */

  /* Module Call */
  A_PE_dummy_in(
    /* module id */ 5,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_5_8
  );
  /* Module Call */

  /* Module Call */
  A_PE_dummy_in(
    /* module id */ 6,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_6_8
  );
  /* Module Call */

  /* Module Call */
  A_PE_dummy_in(
    /* module id */ 7,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_7_8
  );
  /* Module Call */

  /* Module Call */
  A_PE_dummy_in(
    /* module id */ 8,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_8_8
  );
  /* Module Call */

  /* Module Call */
  A_PE_dummy_in(
    /* module id */ 9,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_9_8
  );
  /* Module Call */

  /* Module Call */
  A_PE_dummy_in(
    /* module id */ 10,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_10_8
  );
  /* Module Call */

  /* Module Call */
  A_PE_dummy_in(
    /* module id */ 11,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_11_8
  );
  /* Module Call */

  /* Module Call */
  A_PE_dummy_in(
    /* module id */ 12,
    /* module id */ 7,
    /* fifo */ fifo_A_PE_12_8
  );
  /* Module Call */

  /* Module Call */
  B_PE_dummy_in(
    /* module id */ 12,
    /* module id */ 0,
    /* fifo */ fifo_B_PE_13_0
  );
  /* Module Call */

  /* Module Call */
  B_PE_dummy_in(
    /* module id */ 12,
    /* module id */ 1,
    /* fifo */ fifo_B_PE_13_1
  );
  /* Module Call */

  /* Module Call */
  B_PE_dummy_in(
    /* module id */ 12,
    /* module id */ 2,
    /* fifo */ fifo_B_PE_13_2
  );
  /* Module Call */

  /* Module Call */
  B_PE_dummy_in(
    /* module id */ 12,
    /* module id */ 3,
    /* fifo */ fifo_B_PE_13_3
  );
  /* Module Call */

  /* Module Call */
  B_PE_dummy_in(
    /* module id */ 12,
    /* module id */ 4,
    /* fifo */ fifo_B_PE_13_4
  );
  /* Module Call */

  /* Module Call */
  B_PE_dummy_in(
    /* module id */ 12,
    /* module id */ 5,
    /* fifo */ fifo_B_PE_13_5
  );
  /* Module Call */

  /* Module Call */
  B_PE_dummy_in(
    /* module id */ 12,
    /* module id */ 6,
    /* fifo */ fifo_B_PE_13_6
  );
  /* Module Call */

  /* Module Call */
  B_PE_dummy_in(
    /* module id */ 12,
    /* module id */ 7,
    /* fifo */ fifo_B_PE_13_7
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_boundary_wrapper(
    /* module id */ 0,
    /* module id */ 12,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_12,
    /* fifo */ fifo_C_drain_PE_12_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 0,
    /* module id */ 11,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_12,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_11,
    /* fifo */ fifo_C_drain_PE_11_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 0,
    /* module id */ 10,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_11,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_10,
    /* fifo */ fifo_C_drain_PE_10_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 0,
    /* module id */ 9,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_10,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_9,
    /* fifo */ fifo_C_drain_PE_9_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 0,
    /* module id */ 8,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_9,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_8,
    /* fifo */ fifo_C_drain_PE_8_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 0,
    /* module id */ 7,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_8,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_7,
    /* fifo */ fifo_C_drain_PE_7_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 0,
    /* module id */ 6,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_7,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_6,
    /* fifo */ fifo_C_drain_PE_6_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 0,
    /* module id */ 5,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_6,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_5,
    /* fifo */ fifo_C_drain_PE_5_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 0,
    /* module id */ 4,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_5,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_4,
    /* fifo */ fifo_C_drain_PE_4_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 0,
    /* module id */ 3,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_4,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_3,
    /* fifo */ fifo_C_drain_PE_3_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 0,
    /* module id */ 2,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_3,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_2,
    /* fifo */ fifo_C_drain_PE_2_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 0,
    /* module id */ 1,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_2,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_1,
    /* fifo */ fifo_C_drain_PE_1_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 0,
    /* module id */ 0,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_1,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_0,
    /* fifo */ fifo_C_drain_PE_0_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_boundary_wrapper(
    /* module id */ 1,
    /* module id */ 12,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_12,
    /* fifo */ fifo_C_drain_PE_12_1
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 1,
    /* module id */ 11,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_12,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_11,
    /* fifo */ fifo_C_drain_PE_11_1
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 1,
    /* module id */ 10,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_11,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_10,
    /* fifo */ fifo_C_drain_PE_10_1
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 1,
    /* module id */ 9,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_10,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_9,
    /* fifo */ fifo_C_drain_PE_9_1
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 1,
    /* module id */ 8,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_9,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_8,
    /* fifo */ fifo_C_drain_PE_8_1
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 1,
    /* module id */ 7,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_8,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_7,
    /* fifo */ fifo_C_drain_PE_7_1
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 1,
    /* module id */ 6,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_7,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_6,
    /* fifo */ fifo_C_drain_PE_6_1
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 1,
    /* module id */ 5,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_6,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_5,
    /* fifo */ fifo_C_drain_PE_5_1
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 1,
    /* module id */ 4,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_5,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_4,
    /* fifo */ fifo_C_drain_PE_4_1
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 1,
    /* module id */ 3,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_4,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_3,
    /* fifo */ fifo_C_drain_PE_3_1
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 1,
    /* module id */ 2,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_3,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_2,
    /* fifo */ fifo_C_drain_PE_2_1
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 1,
    /* module id */ 1,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_2,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_1,
    /* fifo */ fifo_C_drain_PE_1_1
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 1,
    /* module id */ 0,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_1,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_0,
    /* fifo */ fifo_C_drain_PE_0_1
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_boundary_wrapper(
    /* module id */ 2,
    /* module id */ 12,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_12,
    /* fifo */ fifo_C_drain_PE_12_2
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 2,
    /* module id */ 11,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_12,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_11,
    /* fifo */ fifo_C_drain_PE_11_2
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 2,
    /* module id */ 10,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_11,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_10,
    /* fifo */ fifo_C_drain_PE_10_2
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 2,
    /* module id */ 9,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_10,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_9,
    /* fifo */ fifo_C_drain_PE_9_2
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 2,
    /* module id */ 8,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_9,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_8,
    /* fifo */ fifo_C_drain_PE_8_2
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 2,
    /* module id */ 7,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_8,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_7,
    /* fifo */ fifo_C_drain_PE_7_2
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 2,
    /* module id */ 6,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_7,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_6,
    /* fifo */ fifo_C_drain_PE_6_2
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 2,
    /* module id */ 5,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_6,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_5,
    /* fifo */ fifo_C_drain_PE_5_2
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 2,
    /* module id */ 4,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_5,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_4,
    /* fifo */ fifo_C_drain_PE_4_2
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 2,
    /* module id */ 3,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_4,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_3,
    /* fifo */ fifo_C_drain_PE_3_2
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 2,
    /* module id */ 2,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_3,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_2,
    /* fifo */ fifo_C_drain_PE_2_2
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 2,
    /* module id */ 1,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_2,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_1,
    /* fifo */ fifo_C_drain_PE_1_2
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 2,
    /* module id */ 0,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_1,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_0,
    /* fifo */ fifo_C_drain_PE_0_2
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_boundary_wrapper(
    /* module id */ 3,
    /* module id */ 12,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_12,
    /* fifo */ fifo_C_drain_PE_12_3
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 3,
    /* module id */ 11,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_12,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_11,
    /* fifo */ fifo_C_drain_PE_11_3
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 3,
    /* module id */ 10,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_11,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_10,
    /* fifo */ fifo_C_drain_PE_10_3
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 3,
    /* module id */ 9,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_10,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_9,
    /* fifo */ fifo_C_drain_PE_9_3
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 3,
    /* module id */ 8,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_9,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_8,
    /* fifo */ fifo_C_drain_PE_8_3
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 3,
    /* module id */ 7,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_8,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_7,
    /* fifo */ fifo_C_drain_PE_7_3
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 3,
    /* module id */ 6,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_7,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_6,
    /* fifo */ fifo_C_drain_PE_6_3
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 3,
    /* module id */ 5,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_6,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_5,
    /* fifo */ fifo_C_drain_PE_5_3
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 3,
    /* module id */ 4,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_5,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_4,
    /* fifo */ fifo_C_drain_PE_4_3
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 3,
    /* module id */ 3,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_4,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_3,
    /* fifo */ fifo_C_drain_PE_3_3
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 3,
    /* module id */ 2,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_3,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_2,
    /* fifo */ fifo_C_drain_PE_2_3
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 3,
    /* module id */ 1,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_2,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_1,
    /* fifo */ fifo_C_drain_PE_1_3
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 3,
    /* module id */ 0,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_1,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_0,
    /* fifo */ fifo_C_drain_PE_0_3
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_boundary_wrapper(
    /* module id */ 4,
    /* module id */ 12,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_12,
    /* fifo */ fifo_C_drain_PE_12_4
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 4,
    /* module id */ 11,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_12,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_11,
    /* fifo */ fifo_C_drain_PE_11_4
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 4,
    /* module id */ 10,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_11,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_10,
    /* fifo */ fifo_C_drain_PE_10_4
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 4,
    /* module id */ 9,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_10,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_9,
    /* fifo */ fifo_C_drain_PE_9_4
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 4,
    /* module id */ 8,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_9,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_8,
    /* fifo */ fifo_C_drain_PE_8_4
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 4,
    /* module id */ 7,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_8,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_7,
    /* fifo */ fifo_C_drain_PE_7_4
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 4,
    /* module id */ 6,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_7,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_6,
    /* fifo */ fifo_C_drain_PE_6_4
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 4,
    /* module id */ 5,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_6,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_5,
    /* fifo */ fifo_C_drain_PE_5_4
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 4,
    /* module id */ 4,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_5,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_4,
    /* fifo */ fifo_C_drain_PE_4_4
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 4,
    /* module id */ 3,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_4,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_3,
    /* fifo */ fifo_C_drain_PE_3_4
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 4,
    /* module id */ 2,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_3,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_2,
    /* fifo */ fifo_C_drain_PE_2_4
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 4,
    /* module id */ 1,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_2,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_1,
    /* fifo */ fifo_C_drain_PE_1_4
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 4,
    /* module id */ 0,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_1,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_0,
    /* fifo */ fifo_C_drain_PE_0_4
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_boundary_wrapper(
    /* module id */ 5,
    /* module id */ 12,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_12,
    /* fifo */ fifo_C_drain_PE_12_5
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 5,
    /* module id */ 11,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_12,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_11,
    /* fifo */ fifo_C_drain_PE_11_5
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 5,
    /* module id */ 10,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_11,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_10,
    /* fifo */ fifo_C_drain_PE_10_5
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 5,
    /* module id */ 9,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_10,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_9,
    /* fifo */ fifo_C_drain_PE_9_5
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 5,
    /* module id */ 8,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_9,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_8,
    /* fifo */ fifo_C_drain_PE_8_5
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 5,
    /* module id */ 7,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_8,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_7,
    /* fifo */ fifo_C_drain_PE_7_5
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 5,
    /* module id */ 6,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_7,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_6,
    /* fifo */ fifo_C_drain_PE_6_5
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 5,
    /* module id */ 5,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_6,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_5,
    /* fifo */ fifo_C_drain_PE_5_5
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 5,
    /* module id */ 4,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_5,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_4,
    /* fifo */ fifo_C_drain_PE_4_5
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 5,
    /* module id */ 3,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_4,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_3,
    /* fifo */ fifo_C_drain_PE_3_5
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 5,
    /* module id */ 2,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_3,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_2,
    /* fifo */ fifo_C_drain_PE_2_5
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 5,
    /* module id */ 1,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_2,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_1,
    /* fifo */ fifo_C_drain_PE_1_5
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 5,
    /* module id */ 0,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_1,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_0,
    /* fifo */ fifo_C_drain_PE_0_5
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_boundary_wrapper(
    /* module id */ 6,
    /* module id */ 12,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_12,
    /* fifo */ fifo_C_drain_PE_12_6
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 6,
    /* module id */ 11,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_12,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_11,
    /* fifo */ fifo_C_drain_PE_11_6
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 6,
    /* module id */ 10,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_11,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_10,
    /* fifo */ fifo_C_drain_PE_10_6
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 6,
    /* module id */ 9,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_10,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_9,
    /* fifo */ fifo_C_drain_PE_9_6
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 6,
    /* module id */ 8,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_9,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_8,
    /* fifo */ fifo_C_drain_PE_8_6
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 6,
    /* module id */ 7,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_8,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_7,
    /* fifo */ fifo_C_drain_PE_7_6
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 6,
    /* module id */ 6,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_7,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_6,
    /* fifo */ fifo_C_drain_PE_6_6
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 6,
    /* module id */ 5,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_6,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_5,
    /* fifo */ fifo_C_drain_PE_5_6
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 6,
    /* module id */ 4,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_5,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_4,
    /* fifo */ fifo_C_drain_PE_4_6
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 6,
    /* module id */ 3,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_4,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_3,
    /* fifo */ fifo_C_drain_PE_3_6
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 6,
    /* module id */ 2,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_3,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_2,
    /* fifo */ fifo_C_drain_PE_2_6
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 6,
    /* module id */ 1,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_2,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_1,
    /* fifo */ fifo_C_drain_PE_1_6
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 6,
    /* module id */ 0,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_1,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_0,
    /* fifo */ fifo_C_drain_PE_0_6
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_boundary_wrapper(
    /* module id */ 7,
    /* module id */ 12,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_12,
    /* fifo */ fifo_C_drain_PE_12_7
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 7,
    /* module id */ 11,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_12,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_11,
    /* fifo */ fifo_C_drain_PE_11_7
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 7,
    /* module id */ 10,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_11,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_10,
    /* fifo */ fifo_C_drain_PE_10_7
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 7,
    /* module id */ 9,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_10,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_9,
    /* fifo */ fifo_C_drain_PE_9_7
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 7,
    /* module id */ 8,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_9,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_8,
    /* fifo */ fifo_C_drain_PE_8_7
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 7,
    /* module id */ 7,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_8,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_7,
    /* fifo */ fifo_C_drain_PE_7_7
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 7,
    /* module id */ 6,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_7,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_6,
    /* fifo */ fifo_C_drain_PE_6_7
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 7,
    /* module id */ 5,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_6,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_5,
    /* fifo */ fifo_C_drain_PE_5_7
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 7,
    /* module id */ 4,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_5,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_4,
    /* fifo */ fifo_C_drain_PE_4_7
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 7,
    /* module id */ 3,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_4,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_3,
    /* fifo */ fifo_C_drain_PE_3_7
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 7,
    /* module id */ 2,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_3,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_2,
    /* fifo */ fifo_C_drain_PE_2_7
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 7,
    /* module id */ 1,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_2,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_1,
    /* fifo */ fifo_C_drain_PE_1_7
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L1_out_wrapper(
    /* module id */ 7,
    /* module id */ 0,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_1,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_0,
    /* fifo */ fifo_C_drain_PE_0_7
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L2_out_boundary(
    /* module id */ 7,
    /* fifo */ fifo_C_drain_C_drain_IO_L2_out_7,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_7_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L2_out(
    /* module id */ 6,
    /* fifo */ fifo_C_drain_C_drain_IO_L2_out_7,
    /* fifo */ fifo_C_drain_C_drain_IO_L2_out_6,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_6_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L2_out(
    /* module id */ 5,
    /* fifo */ fifo_C_drain_C_drain_IO_L2_out_6,
    /* fifo */ fifo_C_drain_C_drain_IO_L2_out_5,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_5_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L2_out(
    /* module id */ 4,
    /* fifo */ fifo_C_drain_C_drain_IO_L2_out_5,
    /* fifo */ fifo_C_drain_C_drain_IO_L2_out_4,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_4_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L2_out(
    /* module id */ 3,
    /* fifo */ fifo_C_drain_C_drain_IO_L2_out_4,
    /* fifo */ fifo_C_drain_C_drain_IO_L2_out_3,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_3_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L2_out(
    /* module id */ 2,
    /* fifo */ fifo_C_drain_C_drain_IO_L2_out_3,
    /* fifo */ fifo_C_drain_C_drain_IO_L2_out_2,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_2_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L2_out(
    /* module id */ 1,
    /* fifo */ fifo_C_drain_C_drain_IO_L2_out_2,
    /* fifo */ fifo_C_drain_C_drain_IO_L2_out_1,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_1_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L2_out(
    /* module id */ 0,
    /* fifo */ fifo_C_drain_C_drain_IO_L2_out_1,
    /* fifo */ fifo_C_drain_C_drain_IO_L2_out_0,
    /* fifo */ fifo_C_drain_C_drain_IO_L1_out_0_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L3_out(
    /* fifo */ fifo_C_drain_C_drain_IO_L3_out_serialize,
    /* fifo */ fifo_C_drain_C_drain_IO_L2_out_0
  );
  /* Module Call */

  /* Module Call */
  C_drain_IO_L3_out_serialize(
    /* array */ C,
    /* fifo */ fifo_C_drain_C_drain_IO_L3_out_serialize
  );
  /* Module Call */

}
}
