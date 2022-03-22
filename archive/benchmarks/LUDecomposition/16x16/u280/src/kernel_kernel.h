#include <ap_int.h>
#include <hls_stream.h>

#define min(x,y) ((x < y) ? x : y)
#define max(x,y) ((x > y) ? x : y)

/* Data Type */
/* Data Type */

extern "C" {
void kernel0(float *A, float *L, float *U);
}

template<int p0, int p1>
void A_IO_L1_in_intra_trans(float local_A[16][1], hls::stream<float> &fifo_A_local_out, bool intra_trans_en);
template<int p0, int p1>
void A_IO_L1_in_inter_trans(float local_A[16][1], hls::stream<float> &fifo_A_in, hls::stream<float> &fifo_A_out, bool inter_trans_en);
template<int p0, int p1>
void A_IO_L1_in_inter_trans_boundary(float local_A[16][1], hls::stream<float> &fifo_A_in, bool inter_trans_en);
template<int p0, int p1>
void PE_wrapper(hls::stream<float> &fifo_V_in, hls::stream<float> &fifo_V_out, hls::stream<float> &fifo_U_tmp_1_in, hls::stream<float> &fifo_U_tmp_1_out, hls::stream<float> &fifo_A_in, hls::stream<float> &fifo_L_drain_out, hls::stream<float> &fifo_U_drain_out);
template<int p0, int p1>
void L_drain_IO_L1_out_intra_trans(float local_L[1][1], hls::stream<float> &fifo_L_drain_local_in);
template<int p0, int p1>
void L_drain_IO_L1_out_inter_trans(float local_L[1][1], hls::stream<float> &fifo_L_drain_in, hls::stream<float> &fifo_L_drain_out);
template<int p0, int p1>
void L_drain_IO_L1_out_inter_trans_boundary(float local_L[1][1], hls::stream<float> &fifo_L_drain_out);
template<int p0, int p1>
void U_drain_IO_L1_out_intra_trans(float local_U[1][16], hls::stream<float> &fifo_U_drain_local_in);
template<int p0, int p1>
void U_drain_IO_L1_out_inter_trans(float local_U[1][16], hls::stream<float> &fifo_U_drain_in, hls::stream<float> &fifo_U_drain_out);
template<int p0, int p1>
void U_drain_IO_L1_out_inter_trans_boundary(float local_U[1][16], hls::stream<float> &fifo_U_drain_out);
