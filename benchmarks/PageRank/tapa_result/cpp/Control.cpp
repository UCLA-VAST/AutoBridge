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

void Control(Pid num_partitions, tlp::mmap<uint64_t> metadata,
             // to VertexMem
             tlp::ostream<VertexReq>& vertex_req_q,
             // to UpdateHandler
             tlp::ostreams<Eid, kNumPes>& update_config_q,
             tlp::ostreams<bool, kNumPes>& update_phase_q,
             // from UpdateHandler
             tlp::istreams<NumUpdates, kNumPes>& num_updates_q,
             // to ProcElem
             tlp::ostreams<TaskReq, kNumPes>& task_req_q,
             // from ProcElem
             tlp::istreams<TaskResp, kNumPes>& task_resp_q) {
#pragma HLS data_pack variable = update_config_q._[0].fifo
#pragma HLS data_pack variable = update_phase_q._[0].fifo
#pragma HLS data_pack variable = num_updates_q._[0].fifo
#pragma HLS data_pack variable = num_updates_q._[0].peek_val
#pragma HLS array_partition variable = num_updates_q._[0].peek_val complete
#pragma HLS data_pack variable = task_req_q._[0].fifo
#pragma HLS data_pack variable = task_resp_q._[0].fifo
#pragma HLS data_pack variable = task_resp_q._[0].peek_val
#pragma HLS array_partition variable = task_resp_q._[0].peek_val complete
#pragma HLS interface m_axi port = metadata offset = direct bundle = metadata
#pragma HLS data_pack variable = vertex_req_q.fifo
#pragma HLS data_pack variable = metadata


  // HLS crashes without this...
  for (int pe = 0; pe < kNumPes; ++pe) {
#pragma HLS pipeline II = 1
#pragma HLS unroll
    update_config_q[pe].close();
    update_phase_q[pe].close();
    task_req_q[pe].close();
  }

  // Keeps track of all partitions.
  // Vid of the 0-th vertex in each partition.
  const Vid base_vid = metadata[0];
  const Vid partition_size = metadata[1];
  const Vid total_num_vertices = partition_size * num_partitions;
  // Number of edges in each partition of each PE.
  Eid num_edges_local[kMaxNumPartitions][kNumPes];
#pragma HLS array_partition complete variable = num_edges_local dim = 2
  // Number of updates in each partition.
  Eid num_updates_local[kMaxNumPartitions];
  // Memory offset of the 0-th edge in each partition.
  Eid eid_offsets[kMaxNumPartitions][kNumPes];
#pragma HLS array_partition complete variable = eid_offsets dim = 2

  Eid eid_offset_acc[kNumPes] = {};
#pragma HLS array_partition complete variable = eid_offset_acc

load_config:
  for (Pid i = 0; i < num_partitions * kNumPes; ++i) {
#pragma HLS pipeline II = 1
    Pid pid = i / kNumPes;
    Pid pe = i % kNumPes;
    Eid num_edges_delta = metadata[i + 2];
    num_edges_local[pid][pe] = num_edges_delta;
    eid_offsets[pid][pe] = eid_offset_acc[pe];
    eid_offset_acc[pe] += num_edges_delta;
  }

  // Initialize UpdateMem, needed only once per execution.
config_update_offsets:
  for (Pid pid = 0; pid < num_partitions; ++pid) {
#pragma HLS pipeline II = 1
    auto update_offset = metadata[2 + num_partitions * kNumPes + pid];
    VLOG_F(8, info) << "update offset[" << pid << "]: " << update_offset;
    update_config_q[pid % kNumPes].write(update_offset);
  }
  // Tells UpdateHandler start to wait for phase requests.
  for (int pe = 0; pe < kNumPes; ++pe) {
#pragma HLS pipeline II = 1
#pragma HLS unroll
    update_config_q[pe].close();
  }

  bool all_done = false;
  int iter = 0;
bulk_steps:
  while (!all_done) {
    all_done = true;

    // Do the scatter phase for each partition, if active.
    // Wait until all PEs are done with the scatter phase.
    VLOG_F(5, info) << "Phase: " << TaskReq::kScatter;
    for (int pe = 0; pe < kNumPes; ++pe) {
#pragma HLS pipeline II = 1
#pragma HLS unroll
      update_phase_q[pe].write(false);
    }

  scatter:
    for (Pid pid = 0; pid < num_partitions; ++pid) {
      // Tell VertexMem to start broadcasting source vertices.
      Vid vid_offset = pid * partition_size;
      vertex_req_q.write({vid_offset, partition_size});
      for (int pe = 0; pe < kNumPes; ++pe) {
#pragma HLS pipeline II = 1
#pragma HLS unroll
        TaskReq req{
            /* phase            = */ TaskReq::kScatter,
            /* pid              = */ 0,  // unused
            /* overall_base_vid = */ base_vid,
            /* partition_size   = */ partition_size,
            /* num_edges        = */ num_edges_local[pid][pe],
            /* vid_offset       = */ vid_offset,
            /* eid_offset       = */ eid_offsets[pid][pe],
            /* init             = */ 0.f,   // unused
            /* scatter_done     = */ false  // unused
        };
        task_req_q[pe].write(req);
      }

#ifdef __SYNTHESIS__
      ap_wait();
#endif

      for (int pe = 0; pe < kNumPes; ++pe) {
#pragma HLS pipeline II = 1
#pragma HLS unroll
        task_resp_q[pe].read();
      }
    }

    // Tell PEs to tell UpdateHandlers that the scatter phase is done.
    TaskReq req = {};
    req.scatter_done = true;
    for (int pe = 0; pe < kNumPes; ++pe) {
#pragma HLS pipeline II = 1
#pragma HLS unroll
      task_req_q[pe].write(req);
    }

    // Get prepared for the gather phase.
    VLOG_F(5, info) << "Phase: " << TaskReq::kGather;
    for (int pe = 0; pe < kNumPes; ++pe) {
#pragma HLS pipeline II = 1
#pragma HLS unroll
      update_phase_q[pe].write(true);
    }

  reset_num_updates:
    for (Pid pid = 0; pid < num_partitions; ++pid) {
#pragma HLS pipeline II = 1
      num_updates_local[pid] = 0;
    }

  collect_num_updates:
    for (Pid pid_recv = 0; pid_recv < RoundUp<kNumPes>(num_partitions);) {
#pragma HLS pipeline II = 1
#pragma HLS dependence false variable = num_updates_local
      NumUpdates num_updates;
      bool done = false;
      Pid pid;
      for (int pe = 0; pe < kNumPes; ++pe) {
#pragma HLS pipeline II = 1
#pragma HLS unroll
        if (!done && num_updates_q[pe].try_read(num_updates)) {
          done |= true;
          pid = num_updates.addr * kNumPes + pe;
          ++pid_recv;
        }
      }
      if (done && pid < num_partitions) {
        VLOG_F(5, recv) << "num_updates: " << num_updates;
        num_updates_local[pid] += num_updates.payload;
      }
    }

    // updates.fence()
#ifdef __SYNTHESIS__
    ap_wait_n(80);
#endif

    // Do the gather phase for each partition.
    // Wait until all partitions are done with the gather phase.
  gather:
    for (Pid pid_send[kNumPes] = {}, pid_recv = 0; pid_recv < num_partitions;) {
#pragma HLS pipeline II = 1
      for (int pe = 0; pe < kNumPes; ++pe) {
#pragma HLS pipeline II = 1
#pragma HLS unroll
        Pid pid = pid_send[pe] * kNumPes + pe;
        if (pid < num_partitions) {
          TaskReq req{TaskReq::kGather,
                      pid,
                      base_vid,
                      partition_size,
                      num_updates_local[pid],
                      partition_size * pid,
                      0,  // eid_offset, unused
                      (1.f - kDampingFactor) / total_num_vertices,
                      false};
          if (task_req_q[pe].try_write(req)) ++pid_send[pe];
        }
      }

      TaskResp resp;
      for (int pe = 0; pe < kNumPes; ++pe) {
#pragma HLS pipeline II = 1
#pragma HLS unroll
        if (task_resp_q[pe].try_read(resp)) {
          VLOG_F(3, recv) << resp;
          if (resp.active) all_done = false;
          ++pid_recv;
        }
      }
    }
    VLOG_F(3, info) << "iter #" << iter << (all_done ? " " : " not ")
                    << "all done";
    ++iter;
  }
  // Terminates UpdateHandler.
  for (int pe = 0; pe < kNumPes; ++pe) {
#pragma HLS pipeline II = 1
#pragma HLS unroll
    update_phase_q[pe].close();
    task_req_q[pe].close();
  }

  metadata[2 + num_partitions * kNumPes + num_partitions] = iter;
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









