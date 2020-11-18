#include <cassert>
#include <cstring>

#include <algorithm>

#include <tlp.h>

#include "page-rank-kernel.h"

constexpr int kMaxNumPartitions = 2048;
constexpr int kMaxPartitionSize = 1024 * 256;
constexpr int kEstimatedLatency = 50;

constexpr int kNumPesR0 = 1;
constexpr int kNumPesR1 = (kNumPes - kNumPesR0) / 2;
constexpr int kNumPesR2 = kNumPes - kNumPesR0 - kNumPesR1;





template <uint64_t N>
void VertexRouterTemplated(
    // upstream to VertexMem
    tlp::ostream<VertexReq>& mm_req_q, tlp::istream<VertexAttrVec>& mm_in_q,
    tlp::ostream<VertexAttrVec>& mm_out_q,
    // downstream to ProcElem
    tlp::istreams<VertexReq, N>& pe_req_q,
    tlp::istreams<VertexAttrVec, N>& pe_in_q,
    tlp::ostreams<VertexAttrVec, N>& pe_out_q) {
  TLP_ELEM_TYPE(pe_req_q) pe_req;
  bool pe_req_valid = false;
  bool mm_req_ready = false;

  TLP_ELEM_TYPE(mm_in_q) mm_in;
  bool mm_in_valid = false;
  bool pe_out_ready[N] = {};

  TLP_ELEM_TYPE(pe_in_q) pe_in;
  bool pe_in_valid = false;
  bool mm_out_ready = false;

  uint8_t pe = 0;
  decltype(pe_req.length) mm2pe_count = 0;
  decltype(pe_req.length) pe2mm_count = 0;

vertex_router:
  for (;;) {
#pragma HLS pipeline II = 1
    if (pe2mm_count == 0) {
      // Not processing a gather phase request.

      // Broadcast scatter phase data if any.
      if (!mm_in_valid) mm_in_valid = mm_in_q.try_read(mm_in);
      if (mm_in_valid) {
#pragma HLS latency max = 1
        for (uint64_t i = 0; i < N; ++i) {
#pragma HLS unroll
          if (!pe_out_ready[i]) pe_out_ready[i] = pe_out_q[i].try_write(mm_in);
        }
        if (All(pe_out_ready)) {
#pragma HLS latency max = 1
          VLOG_F(20, fwd) << "scatter phase data";
          mm_in_valid = false;
          MemSet(pe_out_ready, false);
        }
      }

      // Accept gather phase requests.
      for (uint64_t i = 0; i < N; ++i) {
#pragma HLS unroll
        if (!pe_req_valid && pe_req_q[i].try_read(pe_req)) {
          pe_req_valid |= true;
          pe = i;
          mm2pe_count = pe2mm_count = pe_req.length / kVertexVecLen;
        }
      }
    } else {
      // Processing a gather phase request.

      // Forward vertex attribtues from ProcElem to VertexMem.
      if (!pe_in_valid) pe_in_valid = pe_in_q[pe].try_read(pe_in);
      if (pe_in_valid) {
        if (!mm_out_ready) mm_out_ready = mm_out_q.try_write(pe_in);
        if (mm_out_ready) {
          VLOG_F(10, fwd) << "gather phase: memory <- port " << int(pe)
                          << "; remaining: " << pe2mm_count - 1;
          pe_in_valid = false;
          mm_out_ready = false;
          --pe2mm_count;
        }
      }

      // Forward vertex attribtues from VertexMem to ProcElem.
      if (!mm_in_valid) mm_in_valid = mm_in_q.try_read(mm_in);
      if (mm_in_valid && mm2pe_count > 0) {
        if (!pe_out_ready[pe]) pe_out_ready[pe] = pe_out_q[pe].try_write(mm_in);
        if (pe_out_ready[pe]) {
          VLOG_F(10, fwd) << "gather phase: memory -> port " << int(pe)
                          << "; remaining: " << mm2pe_count - 1;
          mm_in_valid = false;
          pe_out_ready[pe] = false;
          --mm2pe_count;
        }
      }

      // Forward request from ProcElem to VertexMem.
      if (pe_req_valid) {
        if (!mm_req_ready) mm_req_ready = mm_req_q.try_write(pe_req);
        if (mm_req_ready) {
          VLOG_F(9, recv) << "fulfilling request from port " << int(pe);
          pe_req_valid = false;
          mm_req_ready = false;
        }
      }
    }
  }
}





// Handles edge read requests.








extern "C" {

void PageRank(Pid num_partitions, uint64_t metadata,
              uint64_t degrees,
              uint64_t rankings,
              uint64_t tmps,
              uint64_t edges_0, uint64_t edges_1, uint64_t edges_2, uint64_t edges_3, uint64_t edges_4, uint64_t edges_5, uint64_t edges_6, uint64_t edges_7,
              uint64_t updates_0, uint64_t updates_1, uint64_t updates_2, uint64_t updates_3, uint64_t updates_4, uint64_t updates_5, uint64_t updates_6, uint64_t updates_7) {
#pragma HLS interface s_axilite port = num_partitions bundle = control
#pragma HLS interface s_axilite port = metadata bundle = control
#pragma HLS interface s_axilite port = degrees bundle = control
#pragma HLS interface s_axilite port = rankings bundle = control
#pragma HLS interface s_axilite port = tmps bundle = control
#pragma HLS interface s_axilite port = edges_0 bundle = control
#pragma HLS interface s_axilite port = edges_1 bundle = control
#pragma HLS interface s_axilite port = edges_2 bundle = control
#pragma HLS interface s_axilite port = edges_3 bundle = control
#pragma HLS interface s_axilite port = edges_4 bundle = control
#pragma HLS interface s_axilite port = edges_5 bundle = control
#pragma HLS interface s_axilite port = edges_6 bundle = control
#pragma HLS interface s_axilite port = edges_7 bundle = control
#pragma HLS interface s_axilite port = updates_0 bundle = control
#pragma HLS interface s_axilite port = updates_1 bundle = control
#pragma HLS interface s_axilite port = updates_2 bundle = control
#pragma HLS interface s_axilite port = updates_3 bundle = control
#pragma HLS interface s_axilite port = updates_4 bundle = control
#pragma HLS interface s_axilite port = updates_5 bundle = control
#pragma HLS interface s_axilite port = updates_6 bundle = control
#pragma HLS interface s_axilite port = updates_7 bundle = control
#pragma HLS interface s_axilite port = return bundle = control

{ auto val = reinterpret_cast<volatile uint8_t&>(num_partitions); }
{ auto val = reinterpret_cast<volatile uint8_t&>(metadata); }
{ auto val = reinterpret_cast<volatile uint8_t&>(degrees); }
{ auto val = reinterpret_cast<volatile uint8_t&>(rankings); }
{ auto val = reinterpret_cast<volatile uint8_t&>(tmps); }
{ auto val = reinterpret_cast<volatile uint8_t&>(edges_0); }
{ auto val = reinterpret_cast<volatile uint8_t&>(edges_1); }
{ auto val = reinterpret_cast<volatile uint8_t&>(edges_2); }
{ auto val = reinterpret_cast<volatile uint8_t&>(edges_3); }
{ auto val = reinterpret_cast<volatile uint8_t&>(edges_4); }
{ auto val = reinterpret_cast<volatile uint8_t&>(edges_5); }
{ auto val = reinterpret_cast<volatile uint8_t&>(edges_6); }
{ auto val = reinterpret_cast<volatile uint8_t&>(edges_7); }
{ auto val = reinterpret_cast<volatile uint8_t&>(updates_0); }
{ auto val = reinterpret_cast<volatile uint8_t&>(updates_1); }
{ auto val = reinterpret_cast<volatile uint8_t&>(updates_2); }
{ auto val = reinterpret_cast<volatile uint8_t&>(updates_3); }
{ auto val = reinterpret_cast<volatile uint8_t&>(updates_4); }
{ auto val = reinterpret_cast<volatile uint8_t&>(updates_5); }
{ auto val = reinterpret_cast<volatile uint8_t&>(updates_6); }
{ auto val = reinterpret_cast<volatile uint8_t&>(updates_7); }
}


}  // extern "C"

