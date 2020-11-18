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






void ProcElem(
    // from Control
    tlp::istream<TaskReq>& task_req_q,
    // to Control
    tlp::ostream<TaskResp>& task_resp_q,
    // to and from VertexMem
    tlp::ostream<VertexReq>& vertex_req_q,
    tlp::istream<VertexAttrVec>& vertex_in_q,
    tlp::ostream<VertexAttrVec>& vertex_out_q,
    // to and from EdgeMem
    tlp::ostream<Eid>& edge_req_q, tlp::istream<EdgeVec>& edge_resp_q,
    // to UpdateHandler
    tlp::ostream<UpdateReq>& update_req_q,
    // from UpdateHandler via UpdateReorderer
    tlp::istream<UpdateVec>& update_in_q,
    // to UpdateHandler via UpdateRouter
    tlp::ostream<UpdateVecPacket>& update_out_q) {
#pragma HLS data_pack variable = task_req_q.fifo
#pragma HLS data_pack variable = task_req_q.peek_val
#pragma HLS data_pack variable = task_resp_q.fifo
#pragma HLS data_pack variable = vertex_req_q.fifo
#pragma HLS data_pack variable = vertex_in_q.fifo
#pragma HLS data_pack variable = vertex_in_q.peek_val
#pragma HLS data_pack variable = vertex_out_q.fifo
#pragma HLS data_pack variable = edge_req_q.fifo
#pragma HLS data_pack variable = edge_resp_q.fifo
#pragma HLS data_pack variable = edge_resp_q.peek_val
#pragma HLS data_pack variable = update_req_q.fifo
#pragma HLS data_pack variable = update_in_q.fifo
#pragma HLS data_pack variable = update_in_q.peek_val
#pragma HLS data_pack variable = update_out_q.fifo


  // HLS crashes without this...
  task_req_q.open();
#ifdef __SYNTHESIS__
  ap_wait();
#endif  // __SYNTEHSIS__
  update_out_q.close();
#ifdef __SYNTHESIS__
  ap_wait();
#endif  // __SYNTEHSIS__
  update_in_q.open();

  decltype(VertexAttr::tmp) vertices_local[kMaxPartitionSize];
#pragma HLS array_partition variable = vertices_local cyclic factor = \
    kVertexPartitionFactor
#pragma HLS resource variable = vertices_local core = RAM_S2P_URAM

task_requests:
  TLP_WHILE_NOT_EOS(task_req_q) {
    const auto req = task_req_q.read();
    auto base_vid = req.overall_base_vid + req.vid_offset;
    VLOG_F(5, recv) << "TaskReq: " << req;
    if (req.scatter_done) {
      update_out_q.close();
    } else {
      bool active = false;
      if (req.phase == TaskReq::kScatter) {
      vertex_reads:
        for (Vid i = 0; i * kVertexVecLen < req.partition_size; ++i) {
#pragma HLS pipeline II = 1
          auto vertex_vec = vertex_in_q.read();
          for (uint64_t j = 0; j < kVertexVecLen; ++j) {
#pragma HLS unroll
            vertices_local[i * kVertexVecLen + j] = vertex_vec[j].tmp;
          }
        }

      edge_reads:
        for (Eid eid_resp = 0, eid_req = 0; eid_resp < req.num_edges;) {
#pragma HLS pipeline II = 1
          if (eid_req < req.num_edges &&
              eid_resp < eid_req + kEstimatedLatency * kEdgeVecLen &&
              edge_req_q.try_write(req.eid_offset / kEdgeVecLen +
                                   eid_req / kEdgeVecLen)) {
            eid_req += kEdgeVecLen;
          }
          EdgeVec edge_v;
          // empty edge is indicated by src == 0
          // first edge in a vector must have valid dst for routing purpose
          if (edge_resp_q.try_read(edge_v)) {
            VLOG_F(10, recv) << "Edge: " << edge_v;
            UpdateVecPacket update_v = {};
            update_v.addr =
                (edge_v[0].dst - req.overall_base_vid) / req.partition_size;
            for (int i = 0; i < kEdgeVecLen; ++i) {
#pragma HLS unroll
              const auto& edge = edge_v[i];
              if (edge.src != 0) {
                auto addr = edge.src - base_vid;
                LOG_IF(ERROR, addr % kEdgeVecLen != i)
                    << "addr " << addr << " != " << i << " mod " << kEdgeVecLen;
                addr /= kEdgeVecLen;
                // pre-compute pid for routing
                // use pre-computed src.tmp = src.ranking / src.out_degree
                auto tmp = tlp::reg(vertices_local[addr * kEdgeVecLen + i]);
                update_v.payload.set((edge.dst - base_vid) % kEdgeVecLen,
                                     {edge.dst, tmp});
              }
            }
            update_out_q.write(update_v);
            VLOG_F(5, send) << "Update: " << update_v;
            eid_resp += kEdgeVecLen;
          }
        }
      } else {
      vertex_resets:
        for (Vid i = 0; i < req.partition_size; ++i) {
#pragma HLS pipeline II = 1
#pragma HLS unroll factor = kVertexPartitionFactor
          vertices_local[i] = 0.f;
        }

        update_req_q.write({req.phase, req.pid, req.num_edges});
      update_reads:
        TLP_WHILE_NOT_EOS(update_in_q) {
#pragma HLS pipeline II = 1
#pragma HLS dependence variable = vertices_local inter true distance = \
    kVertexUpdateDepDist
          auto update_v = update_in_q.read(nullptr);
          VLOG_F(5, recv) << "Update: " << update_v;
          for (int i = 0; i < kUpdateVecLen; ++i) {
#pragma HLS unroll
            auto update = update_v[i];
            if (update.dst != 0) {
              auto addr = update.dst - base_vid;
              LOG_IF(ERROR, addr % kEdgeVecLen != i)
                  << "addr " << addr << " != " << i << " mod " << kEdgeVecLen;
#pragma HLS latency max = kVertexUpdateLatency
              addr /= kEdgeVecLen;
              vertices_local[addr * kEdgeVecLen + i] += update.delta;
            }
          }
        }
        update_in_q.open();

        vertex_req_q.write({req.vid_offset, req.partition_size});

        float max_delta = 0.f;

      vertex_writes:
        for (Vid i = 0; i * kVertexVecLen < req.partition_size; ++i) {
#pragma HLS pipeline II = 1
          VertexAttrVec vertex_vec = vertex_in_q.read();
          float delta[kVertexVecLen];
#pragma HLS array_partition variable = delta complete
          for (uint64_t j = 0; j < kVertexVecLen; ++j) {
#pragma HLS unroll
            auto vertex = vertex_vec[j];
            auto tmp = vertices_local[i * kVertexVecLen + j];
            const float new_ranking = req.init + tmp * kDampingFactor;
            delta[j] = std::abs(new_ranking - vertex.ranking);
            vertex.ranking = new_ranking;
            // pre-compute vertex.tmp = vertex.ranking / vertex.out_degree
            vertex.tmp = vertex.ranking * vertex.tmp;
            vertex_vec.set(j, vertex);
            VLOG_F(5, send) << "VertexAttr[" << j << "]: " << vertex;
          }
          max_delta = std::max(max_delta, Max(delta));
          vertex_out_q.write(vertex_vec);
        }
        active = max_delta > kConvergenceThreshold;
      }
      TaskResp resp{active};
      task_resp_q.write(resp);
    }
  }
  task_req_q.open();
}


