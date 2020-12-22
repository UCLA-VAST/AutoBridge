#include "kernel_kernel.h"
/* Module Definition */
void A_IO_L3_in(float *A, hls::stream<float> &fifo_A_local_out){
#pragma HLS INLINE OFF
  /* Variable Declaration */
  /* Variable Declaration */

  // array
  // io_L3
  // io_L2
  for (int c1 = 0; c1 <= 23; c1 += 1) {
    // io_L1
    // pe
    for (int c2 = 0; c2 <= 23; c2 += 1) {
      // access_coalesce
      // hls_pipeline
    {
      float fifo_data;
      fifo_data = A[c2 * 24 + c1];
      fifo_A_local_out.write(fifo_data);
    }
    }
  }
}
/* Module Definition */

/* Module Definition */
template<int p0>
void A_IO_L2_in(hls::stream<float> &fifo_A_in, hls::stream<float> &fifo_A_out, hls::stream<float> &fifo_A_local_out){
#pragma HLS INLINE OFF
  /* Variable Declaration */
  /* Variable Declaration */

  if (p0 == 0) {
    // array
    // io_L3
    // io_L2
    for (int c1 = 0; c1 <= 23; c1 += 1) {
      // io_L1
      for (int c2 = 0; c2 <= 23; c2 += 1) {
        // access_coalesce
        // hls_pipeline
        float fifo_data;
        fifo_data = fifo_A_in.read();
        fifo_A_local_out.write(fifo_data);
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
template<int p0>
void A_IO_L2_in_boundary(hls::stream<float> &fifo_A_in, hls::stream<float> &fifo_A_local_out){
#pragma HLS INLINE OFF
  /* Variable Declaration */
  /* Variable Declaration */

  if (p0 == 0) {
    // array
    // io_L3
    // io_L2
    for (int c1 = 0; c1 <= 23; c1 += 1) {
      // io_L1
      for (int c2 = 0; c2 <= 23; c2 += 1) {
        // access_coalesce
        // hls_pipeline
        float fifo_data;
        fifo_data = fifo_A_in.read();
        fifo_A_local_out.write(fifo_data);
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
template<int p0, int p1>
void A_IO_L1_in_intra_trans(float local_A[24][1], hls::stream<float> &fifo_A_local_out, bool intra_trans_en)
{
#pragma HLS INLINE
  /* Variable Declaration */
  /* Variable Declaration */

  if (!intra_trans_en) return;


  if (p0 == 0) {
    // array
    // io_L3
    // io_L2
    // io_L1
    // pe
    for (int c2 = 0; c2 <= 23; c2 += 1) {
      // hls_pipeline
      // hls_pipeline
      float fifo_data;
      fifo_data = local_A[c2][0];
      fifo_A_local_out.write(fifo_data);
    }
  }
}
/* Module Definition */

/* Module Definition */
template<int p0, int p1>
void A_IO_L1_in_inter_trans(float local_A[24][1], hls::stream<float> &fifo_A_in, hls::stream<float> &fifo_A_out, bool inter_trans_en)
{
#pragma HLS INLINE
  /* Variable Declaration */
  /* Variable Declaration */

  if (!inter_trans_en) return;

  for (int c1 = p1; c1 <= 23; c1 += 1) {
    // io_L1
    if (c1 == p1) {
      for (int c2 = 0; c2 <= 23; c2 += 1) {
        // access_coalesce
        // hls_pipeline
        float fifo_data;
        fifo_data = fifo_A_in.read();
        local_A[c2][0] = fifo_data;
      }
    } else {
      for (int c2 = 0; c2 <= 23; c2 += 1) {
        // access_coalesce
        // hls_pipeline
        float fifo_data;
        fifo_data = fifo_A_in.read();
        fifo_A_out.write(fifo_data);
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
template<int p0, int p1>
void A_IO_L1_in_inter_trans_boundary(float local_A[24][1], hls::stream<float> &fifo_A_in, bool inter_trans_en)
{
#pragma HLS INLINE
  /* Variable Declaration */
  /* Variable Declaration */

  if (!inter_trans_en) return;

  for (int c1 = p1; c1 <= 23; c1 += 1)
    if (c1 == p1) {
      // io_L1
      for (int c2 = 0; c2 <= 23; c2 += 1) {
        // access_coalesce
        // hls_pipeline
        float fifo_data;
        fifo_data = fifo_A_in.read();
        local_A[c2][0] = fifo_data;
      }
    }
}
/* Module Definition */

/* Module Definition */
template<int p0, int p1>
void A_IO_L1_in(hls::stream<float> &fifo_A_in, hls::stream<float> &fifo_A_out, hls::stream<float> &fifo_A_local_out){
#pragma HLS INLINE OFF
  /* Variable Declaration */
  float local_A_ping[24][1];
  #pragma HLS ARRAY_PARTITION variable=local_A_ping dim=0 complete
  float local_A_pong[24][1];
  #pragma HLS ARRAY_PARTITION variable=local_A_pong dim=0 complete
  bool arb = 0;
  bool inter_trans_en = 1;
  bool intra_trans_en = 0;
  /* Variable Declaration */

  {
    if (p0 == 0) {
      // array
      // io_L3
      // io_L2
      {
        if (arb == 0) {
          A_IO_L1_in_inter_trans<p0, p1>(
            /* array */ local_A_pong, 
            /* fifo */ fifo_A_in, 
            /* fifo */ fifo_A_out, 
            /* enable */ inter_trans_en
          );
          A_IO_L1_in_intra_trans<p0, p1>(
            /* array */ local_A_ping, 
            /* fifo */ fifo_A_local_out, 
            /* enable */ intra_trans_en
          );
        } else {
          A_IO_L1_in_inter_trans<p0, p1>(
            /* array */ local_A_ping, 
            /* fifo */ fifo_A_in, 
            /* fifo */ fifo_A_out, 
            /* enable */ inter_trans_en
          );
          A_IO_L1_in_intra_trans<p0, p1>(
            /* array */ local_A_pong, 
            /* fifo */ fifo_A_local_out, 
            /* enable */ intra_trans_en
          );
        }
        intra_trans_en = 1;
        arb = !arb;
      }
    }
    if (arb == 0) {
      A_IO_L1_in_intra_trans<p0, p1>(
        /* array */ local_A_ping, 
        /* fifo */ fifo_A_local_out, 
        /* enable */ intra_trans_en
      );
    } else {
      A_IO_L1_in_intra_trans<p0, p1>(
        /* array */ local_A_pong, 
        /* fifo */ fifo_A_local_out, 
        /* enable */ intra_trans_en
      );
    }
  }
}
/* Module Definition */

/* Module Definition */
template<int p0, int p1>
void A_IO_L1_in_boundary(hls::stream<float> &fifo_A_in, hls::stream<float> &fifo_A_local_out){
#pragma HLS INLINE OFF
  /* Variable Declaration */
  float local_A_ping[24][1];
  #pragma HLS ARRAY_PARTITION variable=local_A_ping dim=0 complete
  float local_A_pong[24][1];
  #pragma HLS ARRAY_PARTITION variable=local_A_pong dim=0 complete
  bool arb = 0;
  bool inter_trans_en = 1;
  bool intra_trans_en = 0;
  /* Variable Declaration */

  {
    if (p0 == 0) {
      // array
      // io_L3
      // io_L2
      {
        if (arb == 0) {
          A_IO_L1_in_inter_trans_boundary<p0, p1>(
            /* array */ local_A_pong, 
            /* fifo */ fifo_A_in, 
            /* enable */ inter_trans_en
          );
          A_IO_L1_in_intra_trans<p0, p1>(
            /* array */ local_A_ping, 
            /* fifo */ fifo_A_local_out, 
            /* enable */ intra_trans_en
          );
        } else {
          A_IO_L1_in_inter_trans_boundary<p0, p1>(
            /* array */ local_A_ping, 
            /* fifo */ fifo_A_in, 
            /* enable */ inter_trans_en
          );
          A_IO_L1_in_intra_trans<p0, p1>(
            /* array */ local_A_pong, 
            /* fifo */ fifo_A_local_out, 
            /* enable */ intra_trans_en
          );
        }
        intra_trans_en = 1;
        arb = !arb;
      }
    }
    if (arb == 0) {
      A_IO_L1_in_intra_trans<p0, p1>(
        /* array */ local_A_ping, 
        /* fifo */ fifo_A_local_out, 
        /* enable */ intra_trans_en
      );
    } else {
      A_IO_L1_in_intra_trans<p0, p1>(
        /* array */ local_A_pong, 
        /* fifo */ fifo_A_local_out, 
        /* enable */ intra_trans_en
      );
    }
  }
}
/* Module Definition */

/* Module Definition */
template<int p0, int p1>
void PE(hls::stream<float> &fifo_V_in, hls::stream<float> &fifo_V_out, hls::stream<float> &fifo_U_tmp_1_in, hls::stream<float> &fifo_U_tmp_1_out, hls::stream<float> &fifo_A_in, hls::stream<float> &fifo_L_drain_out, hls::stream<float> &fifo_U_drain_out){
#pragma HLS INLINE OFF
  /* Variable Declaration */
  float local_prev_V[24][1];
  #pragma HLS ARRAY_PARTITION variable=local_prev_V dim=0 complete
  float local_V[24][1];
  #pragma HLS ARRAY_PARTITION variable=local_V dim=0 complete
  float local_U_tmp[24][2];
  #pragma HLS ARRAY_PARTITION variable=local_U_tmp dim=0 complete
  float local_L_tmp[24][1];
  #pragma HLS ARRAY_PARTITION variable=local_L_tmp dim=0 complete
  float local_A[1][1];
  #pragma HLS ARRAY_PARTITION variable=local_A dim=0 complete
  float local_L[1][1];
  #pragma HLS ARRAY_PARTITION variable=local_L dim=0 complete
  float local_U[1][1];
  #pragma HLS ARRAY_PARTITION variable=local_U dim=0 complete
  /* Variable Declaration */

  // array
  // pe
  for (int c2 = p0; c2 <= 23; c2 += 1) {
    // hls_pipeline
    {
      if (p0 == 0) {
        local_A[0][0] = fifo_A_in.read();
        local_prev_V[c2][0] = local_A[0][0];
      } else {
        local_V[-p0 + c2][0] = fifo_V_in.read();
        local_prev_V[-p0 + c2][0] = local_V[-p0 + c2][0];
      }
      if (p1 == p0) {
        local_U_tmp[-p0 + c2][1] = local_prev_V[-p0 + c2][0];
        if (p0 <= 22)
          fifo_U_tmp_1_out.write(local_U_tmp[-p0 + c2][1]);
        local_U[0][0] = local_U_tmp[-p0 + c2][1];
        fifo_U_drain_out.write(local_U[0][0]);
      } else {
        local_U_tmp[-p0 + c2][0] = fifo_U_tmp_1_in.read();
        local_U_tmp[-p0 + c2][1] = local_U_tmp[-p0 + c2][0];
        if (p1 <= 22)
          fifo_U_tmp_1_out.write(local_U_tmp[-p0 + c2][1]);
        if (c2 == p0) {
          local_L_tmp[0][0] = (local_prev_V[0][0] / local_U_tmp[0][1]);
          local_L[0][0] = local_L_tmp[0][0];
          fifo_L_drain_out.write(local_L[0][0]);
        } else {
          local_L_tmp[-p0 + c2][0] = local_L_tmp[-p0 + c2 - 1][0];
        }
        local_V[-p0 + c2][0] = (local_prev_V[-p0 + c2][0] - (local_L_tmp[-p0 + c2][0] * local_U_tmp[-p0 + c2][1]));
        if (c2 >= p0 + 1)
          fifo_V_out.write(local_V[-p0 + c2][0]);
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
template<int p0, int p1>
void PE_wrapper(hls::stream<float> &fifo_V_in, hls::stream<float> &fifo_V_out, hls::stream<float> &fifo_U_tmp_1_in, hls::stream<float> &fifo_U_tmp_1_out, hls::stream<float> &fifo_A_in, hls::stream<float> &fifo_L_drain_out, hls::stream<float> &fifo_U_drain_out)
{
  PE<p0, p1>(
    /* fifo */ fifo_V_in, 
    /* fifo */ fifo_V_out, 
    /* fifo */ fifo_U_tmp_1_in, 
    /* fifo */ fifo_U_tmp_1_out, 
    /* fifo */ fifo_A_in, 
    /* fifo */ fifo_L_drain_out, 
    /* fifo */ fifo_U_drain_out);
}
/* Module Definition */

/* Module Definition */
template<int p0, int p1>
void L_drain_IO_L1_out_intra_trans(float local_L[1][1], hls::stream<float> &fifo_L_drain_local_in)
{
#pragma HLS INLINE
  /* Variable Declaration */
  /* Variable Declaration */


  if (p1 >= p0 + 1) {
    // array
    // io_L3
    // io_L2
    // io_L1
    // pe
    // hls_pipeline
    // hls_pipeline
    float fifo_data;
    fifo_data = fifo_L_drain_local_in.read();
    local_L[0][0] = fifo_data;
  }
}
/* Module Definition */

/* Module Definition */
template<int p0, int p1>
void L_drain_IO_L1_out_inter_trans(float local_L[1][1], hls::stream<float> &fifo_L_drain_in, hls::stream<float> &fifo_L_drain_out)
{
#pragma HLS INLINE
  /* Variable Declaration */
  /* Variable Declaration */

  for (int c1 = max(p0 + 1, p1); c1 <= 23; c1 += 1) {
    // io_L1
    if (c1 == p1) {
      // access_coalesce
      // hls_pipeline
      float fifo_data;
      fifo_data = local_L[0][0];
      fifo_L_drain_out.write(fifo_data);
    } else {
      // access_coalesce
      // hls_pipeline
      float fifo_data;
      fifo_data = fifo_L_drain_in.read();
      fifo_L_drain_out.write(fifo_data);
    }
  }
}
/* Module Definition */

/* Module Definition */
template<int p0, int p1>
void L_drain_IO_L1_out_inter_trans_boundary(float local_L[1][1], hls::stream<float> &fifo_L_drain_out)
{
#pragma HLS INLINE
  /* Variable Declaration */
  /* Variable Declaration */

  for (int c1 = max(p0 + 1, p1); c1 <= 23; c1 += 1)
    if (c1 == p1) {
      // io_L1
      // access_coalesce
      // hls_pipeline
      float fifo_data;
      fifo_data = local_L[0][0];
      fifo_L_drain_out.write(fifo_data);
    }
}
/* Module Definition */

/* Module Definition */
template<int p0, int p1>
void L_drain_IO_L1_out(hls::stream<float> &fifo_L_drain_in, hls::stream<float> &fifo_L_drain_out, hls::stream<float> &fifo_L_drain_local_in){
#pragma HLS INLINE OFF
  /* Variable Declaration */
  float local_L[1][1];
  #pragma HLS ARRAY_PARTITION variable=local_L dim=0 complete
  /* Variable Declaration */

  if (p0 <= 22) {
    // array
    // io_L3
    // io_L2
    L_drain_IO_L1_out_intra_trans<p0, p1>(
      /* array */ local_L, 
      /* fifo */ fifo_L_drain_local_in
    );
    L_drain_IO_L1_out_inter_trans<p0, p1>(
      /* array */ local_L, 
      /* fifo */ fifo_L_drain_in, 
      /* fifo */ fifo_L_drain_out
    );
  }
}
/* Module Definition */

/* Module Definition */
template<int p0, int p1>
void L_drain_IO_L1_out_boundary(hls::stream<float> &fifo_L_drain_out, hls::stream<float> &fifo_L_drain_local_in){
#pragma HLS INLINE OFF
  /* Variable Declaration */
  float local_L[1][1];
  #pragma HLS ARRAY_PARTITION variable=local_L dim=0 complete
  /* Variable Declaration */

  if (p0 <= 22) {
    // array
    // io_L3
    // io_L2
    L_drain_IO_L1_out_intra_trans<p0, p1>(
      /* array */ local_L, 
      /* fifo */ fifo_L_drain_local_in
    );
    L_drain_IO_L1_out_inter_trans_boundary<p0, p1>(
      /* array */ local_L, 
      /* fifo */ fifo_L_drain_out
    );
  }
}
/* Module Definition */

/* Module Definition */
template<int p0>
void L_drain_IO_L2_out(hls::stream<float> &fifo_L_drain_in, hls::stream<float> &fifo_L_drain_out, hls::stream<float> &fifo_L_drain_local_in){
#pragma HLS INLINE OFF
  /* Variable Declaration */
  /* Variable Declaration */

  // array
  // io_L3
  for (int c0 = p0; c0 <= 22; c0 += 1) {
    // io_L2
    if (c0 == p0) {
      for (int c1 = p0 + 1; c1 <= 23; c1 += 1) {
        // io_L1
        // access_coalesce
        // hls_pipeline
        float fifo_data;
        fifo_data = fifo_L_drain_local_in.read();
        fifo_L_drain_out.write(fifo_data);
      }
    } else {
      for (int c1 = c0 + 1; c1 <= 23; c1 += 1) {
        // io_L1
        // access_coalesce
        // hls_pipeline
        float fifo_data;
        fifo_data = fifo_L_drain_in.read();
        fifo_L_drain_out.write(fifo_data);
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
template<int p0>
void L_drain_IO_L2_out_boundary(hls::stream<float> &fifo_L_drain_out, hls::stream<float> &fifo_L_drain_local_in){
#pragma HLS INLINE OFF
  /* Variable Declaration */
  /* Variable Declaration */

  // array
  // io_L3
  for (int c0 = p0; c0 <= 22; c0 += 1)
    if (c0 == p0) {
      // io_L2
      for (int c1 = p0 + 1; c1 <= 23; c1 += 1) {
        // io_L1
        // access_coalesce
        // hls_pipeline
        float fifo_data;
        fifo_data = fifo_L_drain_local_in.read();
        fifo_L_drain_out.write(fifo_data);
      }
    }
}
/* Module Definition */

/* Module Definition */
void L_drain_IO_L3_out(float *L, hls::stream<float> &fifo_L_drain_local_in){
#pragma HLS INLINE OFF
  /* Variable Declaration */
  /* Variable Declaration */

  // array
  // io_L3
  for (int c0 = 0; c0 <= 22; c0 += 1) {
    // io_L2
    for (int c1 = c0 + 1; c1 <= 23; c1 += 1) {
      // io_L1
      // pe
      // access_coalesce
      // hls_pipeline
    {
      float fifo_data;
      fifo_data = fifo_L_drain_local_in.read();
      L[c0 * 24 + c1] = fifo_data;
    }
    }
  }
}
/* Module Definition */

/* Module Definition */
template<int p0, int p1>
void U_drain_IO_L1_out_intra_trans(float local_U[1][24], hls::stream<float> &fifo_U_drain_local_in)
{
#pragma HLS INLINE
  /* Variable Declaration */
  /* Variable Declaration */


  if (p1 == p0) {
    // array
    // io_L3
    // io_L2
    // io_L1
    // pe
    for (int c2 = p0; c2 <= 23; c2 += 1) {
      // hls_pipeline
      // hls_pipeline
      float fifo_data;
      fifo_data = fifo_U_drain_local_in.read();
      local_U[0][-p0 + c2] = fifo_data;
    }
  }
}
/* Module Definition */

/* Module Definition */
template<int p0, int p1>
void U_drain_IO_L1_out_inter_trans(float local_U[1][24], hls::stream<float> &fifo_U_drain_in, hls::stream<float> &fifo_U_drain_out)
{
#pragma HLS INLINE
  /* Variable Declaration */
  /* Variable Declaration */

  // io_L1
  if (p1 == p0) {
    // access_coalesce
    for (int c3 = 0; c3 <= -p0 + 23; c3 += 1) {
      // hls_pipeline
      float fifo_data;
      fifo_data = local_U[0][c3];
      fifo_U_drain_out.write(fifo_data);
    }
  } else {
    // access_coalesce
    for (int c3 = 0; c3 <= -p0 + 23; c3 += 1) {
      // hls_pipeline
      float fifo_data;
      fifo_data = fifo_U_drain_in.read();
      fifo_U_drain_out.write(fifo_data);
    }
  }
}
/* Module Definition */

/* Module Definition */
template<int p0, int p1>
void U_drain_IO_L1_out_inter_trans_boundary(float local_U[1][24], hls::stream<float> &fifo_U_drain_out)
{
#pragma HLS INLINE
  /* Variable Declaration */
  /* Variable Declaration */

  // io_L1
  // access_coalesce
  for (int c3 = 0; c3 <= -p0 + 23; c3 += 1) {
    // hls_pipeline
    float fifo_data;
    fifo_data = local_U[0][c3];
    fifo_U_drain_out.write(fifo_data);
  }
}
/* Module Definition */

/* Module Definition */
template<int p0, int p1>
void U_drain_IO_L1_out(hls::stream<float> &fifo_U_drain_in, hls::stream<float> &fifo_U_drain_out, hls::stream<float> &fifo_U_drain_local_in){
#pragma HLS INLINE OFF
  /* Variable Declaration */
  float local_U[1][24];
  #pragma HLS ARRAY_PARTITION variable=local_U dim=0 complete
  /* Variable Declaration */

  // array
  // io_L3
  // io_L2
  U_drain_IO_L1_out_intra_trans<p0, p1>(
    /* array */ local_U, 
    /* fifo */ fifo_U_drain_local_in
  );
  U_drain_IO_L1_out_inter_trans<p0, p1>(
    /* array */ local_U, 
    /* fifo */ fifo_U_drain_in, 
    /* fifo */ fifo_U_drain_out
  );
}
/* Module Definition */

/* Module Definition */
template<int p0, int p1>
void U_drain_IO_L1_out_boundary(hls::stream<float> &fifo_U_drain_out, hls::stream<float> &fifo_U_drain_local_in){
#pragma HLS INLINE OFF
  /* Variable Declaration */
  float local_U[1][24];
  #pragma HLS ARRAY_PARTITION variable=local_U dim=0 complete
  /* Variable Declaration */

  // array
  // io_L3
  // io_L2
  U_drain_IO_L1_out_intra_trans<p0, p1>(
    /* array */ local_U, 
    /* fifo */ fifo_U_drain_local_in
  );
  U_drain_IO_L1_out_inter_trans_boundary<p0, p1>(
    /* array */ local_U, 
    /* fifo */ fifo_U_drain_out
  );
}
/* Module Definition */

/* Module Definition */
template<int p0>
void U_drain_IO_L2_out(hls::stream<float> &fifo_U_drain_in, hls::stream<float> &fifo_U_drain_out, hls::stream<float> &fifo_U_drain_local_in){
#pragma HLS INLINE OFF
  /* Variable Declaration */
  /* Variable Declaration */

  // array
  // io_L3
  for (int c0 = p0; c0 <= 23; c0 += 1) {
    // io_L2
    if (c0 == p0) {
      // io_L1
      // access_coalesce
      for (int c3 = 0; c3 <= -p0 + 23; c3 += 1) {
        // hls_pipeline
        float fifo_data;
        fifo_data = fifo_U_drain_local_in.read();
        fifo_U_drain_out.write(fifo_data);
      }
    } else {
      // io_L1
      // access_coalesce
      for (int c3 = 0; c3 <= -c0 + 23; c3 += 1) {
        // hls_pipeline
        float fifo_data;
        fifo_data = fifo_U_drain_in.read();
        fifo_U_drain_out.write(fifo_data);
      }
    }
  }
}
/* Module Definition */

/* Module Definition */
template<int p0>
void U_drain_IO_L2_out_boundary(hls::stream<float> &fifo_U_drain_out, hls::stream<float> &fifo_U_drain_local_in){
#pragma HLS INLINE OFF
  /* Variable Declaration */
  /* Variable Declaration */

  // array
  // io_L3
  for (int c0 = p0; c0 <= 23; c0 += 1)
    if (c0 == p0) {
      // io_L2
      // io_L1
      // access_coalesce
      for (int c3 = 0; c3 <= -p0 + 23; c3 += 1) {
        // hls_pipeline
        float fifo_data;
        fifo_data = fifo_U_drain_local_in.read();
        fifo_U_drain_out.write(fifo_data);
      }
    }
}
/* Module Definition */

/* Module Definition */
void U_drain_IO_L3_out(float *U, hls::stream<float> &fifo_U_drain_local_in){
#pragma HLS INLINE OFF
  /* Variable Declaration */
  /* Variable Declaration */

  // array
  // io_L3
  for (int c0 = 0; c0 <= 23; c0 += 1) {
    // io_L2
    // io_L1
    // pe
    // access_coalesce
    for (int c3 = 0; c3 <= -c0 + 23; c3 += 1) {
      // hls_pipeline
    {
      float fifo_data;
      fifo_data = fifo_U_drain_local_in.read();
      U[c0 * 24 + (c0 + c3)] = fifo_data;
    }
    }
  }
}
/* Module Definition */

