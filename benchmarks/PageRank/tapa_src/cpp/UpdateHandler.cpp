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




void UpdateHandler(Pid num_partitions,
                   // from Control
                   tlp::istream<Eid>& update_config_q,
                   tlp::istream<bool>& update_phase_q,
                   // to Control
                   tlp::ostream<NumUpdates>& num_updates_out_q,
                   // from ProcElem via UpdateRouter
                   tlp::istream<UpdateReq>& update_req_q,
                   tlp::istream<UpdateVecPacket>& update_in_q,
                   // to ProcElem via UpdateReorderer
                   tlp::ostream<UpdateVec>& update_out_q,
                   // to and from UpdateMem
                   tlp::ostream<uint64_t>& updates_read_addr_q,
                   tlp::istream<UpdateVec>& updates_read_data_q,
                   tlp::ostream<uint64_t>& updates_write_addr_q,
                   tlp::ostream<UpdateVec>& updates_write_data_q) {
#pragma HLS data_pack variable = update_config_q.fifo
#pragma HLS data_pack variable = update_config_q.peek_val
#pragma HLS data_pack variable = update_phase_q.fifo
#pragma HLS data_pack variable = update_phase_q.peek_val
#pragma HLS data_pack variable = num_updates_out_q.fifo
#pragma HLS data_pack variable = update_req_q.fifo
#pragma HLS data_pack variable = update_req_q.peek_val
#pragma HLS data_pack variable = update_in_q.fifo
#pragma HLS data_pack variable = update_in_q.peek_val
#pragma HLS data_pack variable = update_out_q.fifo
#pragma HLS data_pack variable = updates_read_addr_q.fifo
#pragma HLS data_pack variable = updates_read_data_q.fifo
#pragma HLS data_pack variable = updates_read_data_q.peek_val
#pragma HLS data_pack variable = updates_write_addr_q.fifo
#pragma HLS data_pack variable = updates_write_data_q.fifo


  // HLS crashes without this...
  update_config_q.open();
  update_phase_q.open();
#ifdef __SYNTHESIS__
  ap_wait();
#endif  // __SYNTEHSIS__
  update_in_q.open();
#ifdef __SYNTHESIS__
  ap_wait();
#endif  // __SYNTEHSIS__
  update_out_q.close();

  // Memory offsets of each update partition.
  Eid update_offsets[RoundUp<kNumPes>(kMaxNumPartitions) / kNumPes];
#pragma HLS resource variable = update_offsets latency = 4
  // Number of updates of each update partition in memory.
  Eid num_updates[RoundUp<kNumPes>(kMaxNumPartitions) / kNumPes];

num_updates_init:
  for (Pid i = 0; i < RoundUp<kNumPes>(num_partitions) / kNumPes; ++i) {
#pragma HLS pipeline II = 1
    num_updates[i] = 0;
  }

  // Initialization; needed only once per execution.
  int update_offset_idx = 0;
update_offset_init:
  TLP_WHILE_NOT_EOS(update_config_q) {
#pragma HLS pipeline II = 1
    update_offsets[update_offset_idx] = update_config_q.read(nullptr);
    ++update_offset_idx;
  }
  update_config_q.open();

update_phases:
  TLP_WHILE_NOT_EOS(update_phase_q) {
    const auto phase = update_phase_q.read();
    VLOG_F(5, recv) << "Phase: " << phase;
    if (phase == TaskReq::kScatter) {
      // kScatter lasts until update_phase_q is non-empty.
      Pid last_last_pid = Pid(-1);
      Pid last_pid = Pid(-1);
      Eid last_update_idx = Eid(-1);
    update_writes:
      TLP_WHILE_NOT_EOS(update_in_q) {
#pragma HLS pipeline II = 1
#pragma HLS dependence variable = num_updates inter true distance = 2
        const auto peek_pid = update_in_q.peek(nullptr).addr;
        if (peek_pid != last_pid && peek_pid == last_last_pid) {
          // insert bubble
          last_last_pid = Pid(-1);
        } else {
          const auto update_with_pid = update_in_q.read(nullptr);
          VLOG_F(5, recv) << "UpdateWithPid: " << update_with_pid;
          const Pid pid = update_with_pid.addr;
          const UpdateVec& update_v = update_with_pid.payload;

          // number of updates already written to current partition, not
          // including the current update
          Eid update_idx;
          if (last_pid != pid) {
#pragma HLS latency min = 1 max = 1
            update_idx = num_updates[pid / kNumPes];
            if (last_pid != Pid(-1)) {
              num_updates[last_pid / kNumPes] =
                  RoundUp<kUpdateVecLen>(last_update_idx);
            }
          } else {
            update_idx = last_update_idx;
          }

          // set for next iteration
          last_last_pid = last_pid;
          last_pid = pid;
          last_update_idx = update_idx + kUpdateVecLen;

          Eid update_offset = update_offsets[pid / kNumPes] + update_idx;
          updates_write_addr_q.write(update_offset / kUpdateVecLen);
          updates_write_data_q.write(update_v);
        }
      }
      if (last_pid != Pid(-1)) {
        num_updates[last_pid / kNumPes] =
            RoundUp<kUpdateVecLen>(last_update_idx);
      }
      update_in_q.open();
#ifdef __SYNTHESIS__
      ap_wait_n(1);
#endif  // __SYNTHESIS__
    send_num_updates:
      for (Pid i = 0; i < RoundUp<kNumPes>(num_partitions) / kNumPes; ++i) {
#pragma HLS pipeline II = 1
        // TODO: store relevant partitions only
        VLOG_F(5, send) << "num_updates[" << i << "]: " << num_updates[i];
        num_updates_out_q.write({i, num_updates[i]});
        num_updates[i] = 0;  // Reset for the next scatter phase.
      }
    } else {
      // Gather phase.
    recv_update_reqs:
      for (UpdateReq update_req; update_phase_q.empty();) {
        if (update_req_q.try_read(update_req)) {
          const auto pid = update_req.pid;
          const auto num_updates_pid = update_req.num_updates;
          VLOG_F(5, recv) << "UpdateReq: " << update_req;

          bool valid = false;
          UpdateVec update_v;
        update_reads:
          for (Eid i_rd = 0, i_wr = 0; i_rd < num_updates_pid;) {
#pragma HLS pipeline II = 1
            auto read_addr = update_offsets[pid / kNumPes] + i_wr;
            if (i_wr < num_updates_pid &&
                updates_read_addr_q.try_write(read_addr / kUpdateVecLen)) {
              VLOG_F(5, req)
                  << "UpdateVec[" << read_addr / kUpdateVecLen << "]";
              i_wr += kUpdateVecLen;
            }

            if (valid || (valid = updates_read_data_q.try_read(update_v))) {
              if (update_out_q.try_write(update_v)) {
                VLOG_F(5, send) << "Update: " << update_v;
                i_rd += kUpdateVecLen;
                valid = false;
              }
            }
          }
          update_out_q.close();
        }
      }
    }
  }
  VLOG_F(3, info) << "done";
  update_phase_q.open();
}




