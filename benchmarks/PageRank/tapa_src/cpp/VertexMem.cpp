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



void VertexMem(tlp::istream<VertexReq>& scatter_req_q,
               tlp::istreams<VertexReq, kNumPesR0 + 1>& vertex_req_q,
               tlp::istreams<VertexAttrVec, kNumPesR0 + 1>& vertex_in_q,
               tlp::ostreams<VertexAttrVec, kNumPesR0 + 1>& vertex_out_q,
               tlp::async_mmap<FloatVec>& degrees,
               tlp::async_mmap<FloatVec>& rankings,
               tlp::async_mmap<FloatVec>& tmps) {
#pragma HLS data_pack variable = vertex_req_q._[0].fifo
#pragma HLS data_pack variable = vertex_req_q._[0].peek_val
#pragma HLS array_partition variable = vertex_req_q._[0].peek_val complete
#pragma HLS data_pack variable = vertex_in_q._[0].fifo
#pragma HLS data_pack variable = vertex_in_q._[0].peek_val
#pragma HLS array_partition variable = vertex_in_q._[0].peek_val complete
#pragma HLS data_pack variable = vertex_out_q._[0].fifo
#pragma HLS data_pack variable = scatter_req_q.fifo
#pragma HLS data_pack variable = scatter_req_q.peek_val


  constexpr int N = kNumPesR0 + 1;
  for (;;) {
    // Prioritize scatter phase broadcast.
    VertexReq scatter_req;
    if (scatter_req_q.try_read(scatter_req)) {
      auto req = tlp::reg(scatter_req);
      // Scatter phase
      //   Send tmp to PEs.
      FloatVec resp;
      VertexAttrVec tmp_out;
      bool valid = false;
      bool ready[N] = {};
    vertices_scatter:
      for (Vid i_req = 0, i_resp = 0; i_resp < req.length;) {
#pragma HLS pipeline II = 1
        // Send requests.
        if (i_req < req.length &&
            i_req < i_resp + kEstimatedLatency * kVertexVecLen &&
            tmps.read_addr_try_write((req.offset + i_req) / kVertexVecLen)) {
          i_req += kVertexVecLen;
        }

        // Handle responses.
        if (!valid) valid = tmps.read_data_try_read(resp);
        for (int i = 0; i < kVertexVecLen; ++i) {
#pragma HLS unroll
          tmp_out.set(i, VertexAttrKernel{0.f, resp[i]});
        }
        if (valid) {
          for (int pe = 0; pe < N; ++pe) {
#pragma HLS pipeline II = 1
#pragma HLS unroll
            if (!ready[pe]) ready[pe] = vertex_out_q[pe].try_write(tmp_out);
          }
          if (All(ready)) {
            i_resp += kVertexVecLen;
            valid = false;
            MemSet(ready, false);
          }
        }
      }
    } else {
      VertexReq req;
      bool done = false;
      for (int pe = 0; pe < N; ++pe) {
#pragma HLS unroll
        if (!done && vertex_req_q[pe].try_read(req)) {
          done |= true;
          // Gather phase
          //   Send degree and ranking to PEs.
          //   Recv tmp and ranking from PEs.

          FloatVec resp_degree;
          FloatVec resp_ranking;

          // valid_xx: resp_xx is valid
          bool valid_degree = false;
          bool valid_ranking = false;

          // xx_ready_oo: write_xx has been written.
          bool addr_ready_tmp = false;
          bool data_ready_tmp = false;
          bool addr_ready_ranking = false;
          bool data_ready_ranking = false;

        vertices_gather:
          for (Vid i_rd_req_degree = 0, i_rd_req_ranking = 0, i_rd_resp = 0,
                   i_wr = 0;
               i_wr < req.length;) {
#pragma HLS pipeline II = 1
            // Send read requests.
            if (i_rd_req_degree < req.length &&
                i_rd_req_degree <
                    i_rd_resp + kEstimatedLatency * kVertexVecLen &&
                degrees.read_addr_try_write((req.offset + i_rd_req_degree) /
                                            kVertexVecLen)) {
              i_rd_req_degree += kVertexVecLen;
            }
            if (i_rd_req_ranking < req.length &&
                i_rd_req_ranking <
                    i_rd_resp + kEstimatedLatency * kVertexVecLen &&
                rankings.read_addr_try_write((req.offset + i_rd_req_ranking) /
                                             kVertexVecLen)) {
              i_rd_req_ranking += kVertexVecLen;
            }

            // Handle read responses.
            if (i_rd_resp < req.length) {
              if (!valid_degree)
                valid_degree = degrees.read_data_try_read(resp_degree);
              if (!valid_ranking)
                valid_ranking = rankings.read_data_try_read(resp_ranking);
              VertexAttrVec vertex_attr_out;
              for (int i = 0; i < kVertexVecLen; ++i) {
#pragma HLS unroll
                vertex_attr_out.set(
                    i, VertexAttrKernel{resp_ranking[i], resp_degree[i]});
              }
              if (valid_degree && valid_ranking &&
                  vertex_out_q[pe].try_write(vertex_attr_out)) {
                i_rd_resp += kVertexVecLen;
                valid_degree = false;
                valid_ranking = false;
              }
            }

            // Write to DRAM.
            if (!vertex_in_q[pe].empty()) {
              auto v = vertex_in_q[pe].peek(nullptr);
              FloatVec ranking_out;
              FloatVec tmp_out;
              for (int i = 0; i < kVertexVecLen; ++i) {
#pragma HLS unroll
                ranking_out.set(i, v[i].ranking);
                tmp_out.set(i, v[i].tmp);
              }
              uint64_t addr = (req.offset + i_wr) / kVertexVecLen;
              if (!addr_ready_ranking)
                addr_ready_ranking = rankings.write_addr_try_write(addr);
              if (!data_ready_ranking)
                data_ready_ranking = rankings.write_data_try_write(ranking_out);
              if (!addr_ready_tmp)
                addr_ready_tmp = tmps.write_addr_try_write(addr);
              if (!data_ready_tmp)
                data_ready_tmp = tmps.write_data_try_write(tmp_out);
              if (addr_ready_ranking && data_ready_ranking && addr_ready_tmp &&
                  data_ready_tmp) {
                vertex_in_q[pe].read(nullptr);
                addr_ready_ranking = false;
                data_ready_ranking = false;
                addr_ready_tmp = false;
                data_ready_tmp = false;
                i_wr += kVertexVecLen;
              }
            }
          }
        }
      }
    }
  }
}

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









