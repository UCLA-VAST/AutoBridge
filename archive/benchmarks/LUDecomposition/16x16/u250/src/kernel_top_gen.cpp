#include <isl/printer.h>
#include "kernel_top_gen.h"
void top_generate(FILE *f)
{
  FILE *fd = fopen("./autosa.tmp/output/resource_est/design_info.dat", "w");
  int fifo_cnt;
  isl_ctx *ctx = isl_ctx_alloc();
  isl_printer *p = isl_printer_to_file(ctx, f);

  p = isl_printer_start_line(p);
  p = isl_printer_print_str(p, "void kernel0(float *A, float *L, float *U)");
  p = isl_printer_end_line(p);
  p = isl_printer_start_line(p);
  p = isl_printer_print_str(p, "{");
  p = isl_printer_end_line(p);
  p = isl_printer_start_line(p);
  p = isl_printer_print_str(p, "#pragma HLS INTERFACE m_axi port=A offset=slave bundle=gmem_A");
  p = isl_printer_end_line(p);
  p = isl_printer_start_line(p);
  p = isl_printer_print_str(p, "#pragma HLS INTERFACE m_axi port=L offset=slave bundle=gmem_L");
  p = isl_printer_end_line(p);
  p = isl_printer_start_line(p);
  p = isl_printer_print_str(p, "#pragma HLS INTERFACE m_axi port=U offset=slave bundle=gmem_U");
  p = isl_printer_end_line(p);
  p = isl_printer_start_line(p);
  p = isl_printer_print_str(p, "#pragma HLS INTERFACE s_axilite port=A bundle=control");
  p = isl_printer_end_line(p);
  p = isl_printer_start_line(p);
  p = isl_printer_print_str(p, "#pragma HLS INTERFACE s_axilite port=L bundle=control");
  p = isl_printer_end_line(p);
  p = isl_printer_start_line(p);
  p = isl_printer_print_str(p, "#pragma HLS INTERFACE s_axilite port=U bundle=control");
  p = isl_printer_end_line(p);
  p = isl_printer_start_line(p);
  p = isl_printer_print_str(p, "#pragma HLS INTERFACE s_axilite port=return bundle=control");
  p = isl_printer_end_line(p);
  p = isl_printer_end_line(p);
  p = isl_printer_start_line(p);
  p = isl_printer_print_str(p, "#pragma HLS DATAFLOW");
  p = isl_printer_end_line(p);
  p = isl_printer_end_line(p);
  p = isl_printer_indent(p, 2);
  p = isl_printer_start_line(p);
  p = isl_printer_print_str(p, "/* FIFO Declaration */");
  p = isl_printer_end_line(p);

  fifo_cnt = 0;
  // array
  // io_L3
  for (int c0 = 0; c0 <= 15; c0 += 1) {
    {
      // Count channel number
      fifo_cnt++;
      // Print channel declarations of module: A_IO_L2_in
      p = isl_printer_start_line(p);
      p = isl_printer_print_str(p, "/* A_IO_L2_in fifo */ hls::stream<float> fifo_A_A_IO_L2_in");
      p = isl_printer_print_str(p, "_");
      p = isl_printer_print_int(p, c0);
      p = isl_printer_print_str(p, ";");
      p = isl_printer_end_line(p);
      p = isl_printer_start_line(p);
      p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_A_A_IO_L2_in");
      p = isl_printer_print_str(p, "_");
      p = isl_printer_print_int(p, c0);
      p = isl_printer_print_str(p, " depth=2");
      p = isl_printer_end_line(p);
    }
    if (c0 == 15)
      {
        // Count channel number
        fifo_cnt++;
        // Print channel declarations of module: A_IO_L2_in
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* A_IO_L2_in fifo */ hls::stream<float> fifo_A_A_IO_L2_in");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0 + 1);
        p = isl_printer_print_str(p, ";");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_A_A_IO_L2_in");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0 + 1);
        p = isl_printer_print_str(p, " depth=2");
        p = isl_printer_end_line(p);
      }
  }
  fprintf(fd, "fifo:fifo_A_A_IO_L2_in:%d:4\n", fifo_cnt);

  fifo_cnt = 0;
  // array
  // io_L3
  for (int c0 = 0; c0 <= 15; c0 += 1) {
    // io_L2
    for (int c1 = c0; c1 <= 15; c1 += 1) {
      {
        // Count channel number
        fifo_cnt++;
        // Print channel declarations of module: A_IO_L1_in
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* A_IO_L1_in fifo */ hls::stream<float> fifo_A_A_IO_L1_in");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_print_str(p, ";");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_A_A_IO_L1_in");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_print_str(p, " depth=2");
        p = isl_printer_end_line(p);
      }
      if (c1 == 15)
        {
          // Count channel number
          fifo_cnt++;
          // Print channel declarations of module: A_IO_L1_in
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "/* A_IO_L1_in fifo */ hls::stream<float> fifo_A_A_IO_L1_in");
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c0);
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c1 + 1);
          p = isl_printer_print_str(p, ";");
          p = isl_printer_end_line(p);
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_A_A_IO_L1_in");
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c0);
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c1 + 1);
          p = isl_printer_print_str(p, " depth=2");
          p = isl_printer_end_line(p);
        }
    }
  }
  fprintf(fd, "fifo:fifo_A_A_IO_L1_in:%d:4\n", fifo_cnt);

  fifo_cnt = 0;
  // array
  for (int c0 = 0; c0 <= 15; c0 += 1)
    for (int c1 = 0; c1 <= c0; c1 += 1) {
      // io_L1
      {
        {
          // Count channel number
          fifo_cnt++;
          // Print channel declarations of module: PE
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "/* PE fifo */ hls::stream<float> fifo_V_PE");
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c1);
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c0);
          p = isl_printer_print_str(p, ";");
          p = isl_printer_end_line(p);
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_V_PE");
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c1);
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c0);
          p = isl_printer_print_str(p, " depth=2");
          p = isl_printer_end_line(p);
        }
        if (c1 == c0)
          {
            // Count channel number
            fifo_cnt++;
            // Print channel declarations of module: PE
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* PE fifo */ hls::stream<float> fifo_V_PE");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c1 + 1);
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, ";");
            p = isl_printer_end_line(p);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_V_PE");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c1 + 1);
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, " depth=2");
            p = isl_printer_end_line(p);
          }
      }
    }
  fprintf(fd, "fifo:fifo_V_PE:%d:4\n", fifo_cnt);

  fifo_cnt = 0;
  // array
  for (int c0 = 0; c0 <= 15; c0 += 1)
    for (int c1 = c0; c1 <= 15; c1 += 1) {
      // io_L1
      {
        {
          // Count channel number
          fifo_cnt++;
          // Print channel declarations of module: PE
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "/* PE fifo */ hls::stream<float> fifo_U_tmp_1_PE");
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c0);
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c1);
          p = isl_printer_print_str(p, ";");
          p = isl_printer_end_line(p);
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_U_tmp_1_PE");
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c0);
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c1);
          p = isl_printer_print_str(p, " depth=2");
          p = isl_printer_end_line(p);
        }
        if (c1 == 15)
          {
            // Count channel number
            fifo_cnt++;
            // Print channel declarations of module: PE
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* PE fifo */ hls::stream<float> fifo_U_tmp_1_PE");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c1 + 1);
            p = isl_printer_print_str(p, ";");
            p = isl_printer_end_line(p);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_U_tmp_1_PE");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c1 + 1);
            p = isl_printer_print_str(p, " depth=2");
            p = isl_printer_end_line(p);
          }
      }
    }
  fprintf(fd, "fifo:fifo_U_tmp_1_PE:%d:4\n", fifo_cnt);

  fifo_cnt = 0;
  // array
  for (int c0 = 0; c0 <= 15; c0 += 1)
    for (int c1 = c0; c1 <= 15; c1 += 1) {
      // io_L1
      {
        // Count channel number
        fifo_cnt++;
        // Print channel declarations of module: PE
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* PE fifo */ hls::stream<float> fifo_A_PE");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_print_str(p, ";");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_A_PE");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_print_str(p, " depth=2");
        p = isl_printer_end_line(p);
      }
    }
  fprintf(fd, "fifo:fifo_A_PE:%d:4\n", fifo_cnt);

  fifo_cnt = 0;
  // array
  for (int c0 = 0; c0 <= 15; c0 += 1)
    for (int c1 = c0; c1 <= 15; c1 += 1) {
      // io_L1
      {
        // Count channel number
        fifo_cnt++;
        // Print channel declarations of module: PE
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* PE fifo */ hls::stream<float> fifo_L_drain_PE");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_print_str(p, ";");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_L_drain_PE");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_print_str(p, " depth=2");
        p = isl_printer_end_line(p);
      }
    }
  fprintf(fd, "fifo:fifo_L_drain_PE:%d:4\n", fifo_cnt);

  fifo_cnt = 0;
  // array
  for (int c0 = 0; c0 <= 15; c0 += 1)
    for (int c1 = c0; c1 <= 15; c1 += 1) {
      // io_L1
      {
        // Count channel number
        fifo_cnt++;
        // Print channel declarations of module: PE
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* PE fifo */ hls::stream<float> fifo_U_drain_PE");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_print_str(p, ";");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_U_drain_PE");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_print_str(p, " depth=2");
        p = isl_printer_end_line(p);
      }
    }
  fprintf(fd, "fifo:fifo_U_drain_PE:%d:4\n", fifo_cnt);

  fifo_cnt = 0;
  // array
  // io_L3
  for (int c0 = 0; c0 <= 15; c0 += 1) {
    // io_L2
    for (int c1 = c0; c1 <= 15; c1 += 1) {
      {
        // Count channel number
        fifo_cnt++;
        // Print channel declarations of module: L_drain_IO_L1_out
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* L_drain_IO_L1_out fifo */ hls::stream<float> fifo_L_drain_L_drain_IO_L1_out");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_print_str(p, ";");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_L_drain_L_drain_IO_L1_out");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_print_str(p, " depth=2");
        p = isl_printer_end_line(p);
      }
      if (c1 == 15)
        {
          // Count channel number
          fifo_cnt++;
          // Print channel declarations of module: L_drain_IO_L1_out
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "/* L_drain_IO_L1_out fifo */ hls::stream<float> fifo_L_drain_L_drain_IO_L1_out");
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c0);
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c1 + 1);
          p = isl_printer_print_str(p, ";");
          p = isl_printer_end_line(p);
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_L_drain_L_drain_IO_L1_out");
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c0);
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c1 + 1);
          p = isl_printer_print_str(p, " depth=2");
          p = isl_printer_end_line(p);
        }
    }
  }
  fprintf(fd, "fifo:fifo_L_drain_L_drain_IO_L1_out:%d:4\n", fifo_cnt);

  fifo_cnt = 0;
  // array
  // io_L3
  for (int c0 = 0; c0 <= 15; c0 += 1) {
    {
      // Count channel number
      fifo_cnt++;
      // Print channel declarations of module: L_drain_IO_L2_out
      p = isl_printer_start_line(p);
      p = isl_printer_print_str(p, "/* L_drain_IO_L2_out fifo */ hls::stream<float> fifo_L_drain_L_drain_IO_L2_out");
      p = isl_printer_print_str(p, "_");
      p = isl_printer_print_int(p, c0);
      p = isl_printer_print_str(p, ";");
      p = isl_printer_end_line(p);
      p = isl_printer_start_line(p);
      p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_L_drain_L_drain_IO_L2_out");
      p = isl_printer_print_str(p, "_");
      p = isl_printer_print_int(p, c0);
      p = isl_printer_print_str(p, " depth=2");
      p = isl_printer_end_line(p);
    }
    if (c0 == 15)
      {
        // Count channel number
        fifo_cnt++;
        // Print channel declarations of module: L_drain_IO_L2_out
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* L_drain_IO_L2_out fifo */ hls::stream<float> fifo_L_drain_L_drain_IO_L2_out");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0 + 1);
        p = isl_printer_print_str(p, ";");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_L_drain_L_drain_IO_L2_out");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0 + 1);
        p = isl_printer_print_str(p, " depth=2");
        p = isl_printer_end_line(p);
      }
  }
  fprintf(fd, "fifo:fifo_L_drain_L_drain_IO_L2_out:%d:4\n", fifo_cnt);

  fifo_cnt = 0;
  // array
  // io_L3
  for (int c0 = 0; c0 <= 15; c0 += 1) {
    // io_L2
    for (int c1 = c0; c1 <= 15; c1 += 1) {
      {
        // Count channel number
        fifo_cnt++;
        // Print channel declarations of module: U_drain_IO_L1_out
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* U_drain_IO_L1_out fifo */ hls::stream<float> fifo_U_drain_U_drain_IO_L1_out");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_print_str(p, ";");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_U_drain_U_drain_IO_L1_out");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_print_str(p, " depth=2");
        p = isl_printer_end_line(p);
      }
      if (c1 == 15)
        {
          // Count channel number
          fifo_cnt++;
          // Print channel declarations of module: U_drain_IO_L1_out
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "/* U_drain_IO_L1_out fifo */ hls::stream<float> fifo_U_drain_U_drain_IO_L1_out");
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c0);
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c1 + 1);
          p = isl_printer_print_str(p, ";");
          p = isl_printer_end_line(p);
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_U_drain_U_drain_IO_L1_out");
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c0);
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c1 + 1);
          p = isl_printer_print_str(p, " depth=2");
          p = isl_printer_end_line(p);
        }
    }
  }
  fprintf(fd, "fifo:fifo_U_drain_U_drain_IO_L1_out:%d:4\n", fifo_cnt);

  fifo_cnt = 0;
  // array
  // io_L3
  for (int c0 = 0; c0 <= 15; c0 += 1) {
    {
      // Count channel number
      fifo_cnt++;
      // Print channel declarations of module: U_drain_IO_L2_out
      p = isl_printer_start_line(p);
      p = isl_printer_print_str(p, "/* U_drain_IO_L2_out fifo */ hls::stream<float> fifo_U_drain_U_drain_IO_L2_out");
      p = isl_printer_print_str(p, "_");
      p = isl_printer_print_int(p, c0);
      p = isl_printer_print_str(p, ";");
      p = isl_printer_end_line(p);
      p = isl_printer_start_line(p);
      p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_U_drain_U_drain_IO_L2_out");
      p = isl_printer_print_str(p, "_");
      p = isl_printer_print_int(p, c0);
      p = isl_printer_print_str(p, " depth=2");
      p = isl_printer_end_line(p);
    }
    if (c0 == 15)
      {
        // Count channel number
        fifo_cnt++;
        // Print channel declarations of module: U_drain_IO_L2_out
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* U_drain_IO_L2_out fifo */ hls::stream<float> fifo_U_drain_U_drain_IO_L2_out");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0 + 1);
        p = isl_printer_print_str(p, ";");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "#pragma HLS STREAM variable=fifo_U_drain_U_drain_IO_L2_out");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0 + 1);
        p = isl_printer_print_str(p, " depth=2");
        p = isl_printer_end_line(p);
      }
  }
  fprintf(fd, "fifo:fifo_U_drain_U_drain_IO_L2_out:%d:4\n", fifo_cnt);

  p = isl_printer_start_line(p);
  p = isl_printer_print_str(p, "/* FIFO Declaration */");
  p = isl_printer_end_line(p);
  p = isl_printer_end_line(p);
  int A_IO_L3_in_cnt = 0;
  int A_IO_L2_in_cnt = 0;
  int A_IO_L2_in_boundary_cnt = 0;
  int A_IO_L1_in_intra_trans_cnt = 0;
  int A_IO_L1_in_inter_trans_cnt = 0;
  int A_IO_L1_in_inter_trans_boundary_cnt = 0;
  int A_IO_L1_in_cnt = 0;
  int A_IO_L1_in_boundary_cnt = 0;
  int PE_cnt = 0;
  int L_drain_IO_L1_out_intra_trans_cnt = 0;
  int L_drain_IO_L1_out_inter_trans_cnt = 0;
  int L_drain_IO_L1_out_inter_trans_boundary_cnt = 0;
  int L_drain_IO_L1_out_cnt = 0;
  int L_drain_IO_L1_out_boundary_cnt = 0;
  int L_drain_IO_L2_out_cnt = 0;
  int L_drain_IO_L2_out_boundary_cnt = 0;
  int L_drain_IO_L3_out_cnt = 0;
  int U_drain_IO_L1_out_intra_trans_cnt = 0;
  int U_drain_IO_L1_out_inter_trans_cnt = 0;
  int U_drain_IO_L1_out_inter_trans_boundary_cnt = 0;
  int U_drain_IO_L1_out_cnt = 0;
  int U_drain_IO_L1_out_boundary_cnt = 0;
  int U_drain_IO_L2_out_cnt = 0;
  int U_drain_IO_L2_out_boundary_cnt = 0;
  int U_drain_IO_L3_out_cnt = 0;
  // array
  // io_L3
  {
    {
      // Count module number
      A_IO_L3_in_cnt++;
      p = isl_printer_start_line(p);
      p = isl_printer_print_str(p, "/* Module Call */");
      p = isl_printer_end_line(p);
      // Print calls of module: A_IO_L3_in
      p = isl_printer_start_line(p);
      p = isl_printer_print_str(p, "A_IO_L3_in");
      p = isl_printer_print_str(p, "(");
      p = isl_printer_end_line(p);
      p = isl_printer_indent(p, 2);
      p = isl_printer_start_line(p);
      p = isl_printer_print_str(p, "/* array */ A");
    }
    for (int c0 = 0; c0 <= 15; c0 += 1)
      if (c0 == 0)
        {
          p = isl_printer_print_str(p, ",");
          p = isl_printer_end_line(p);
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "/* fifo */ ");
          p = isl_printer_print_str(p, "fifo_A_A_IO_L2_in");
          p = isl_printer_print_str(p, "_0");
          p = isl_printer_end_line(p);
          p = isl_printer_indent(p, -2);
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, ");");
          p = isl_printer_end_line(p);
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "/* Module Call */");
          p = isl_printer_end_line(p);
          p = isl_printer_end_line(p);
        }
  }
  // array
  // io_L3
  for (int c0 = 0; c0 <= 15; c0 += 1)
    if (c0 == 0) {
      // io_L2
      {
        {
          // Count module number
          A_IO_L2_in_boundary_cnt++;
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "/* Module Call */");
          p = isl_printer_end_line(p);
          // Print calls of module: A_IO_L2_in_boundary
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "A_IO_L2_in_boundary");
          p = isl_printer_print_str(p, "<");
          p = isl_printer_print_int(p, c0);
          p = isl_printer_print_str(p, ">");
          p = isl_printer_print_str(p, "(");
          p = isl_printer_end_line(p);
          p = isl_printer_indent(p, 2);
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "/* fifo */ ");
          p = isl_printer_print_str(p, "fifo_A_A_IO_L2_in");
          p = isl_printer_print_str(p, "_");
          p = isl_printer_print_int(p, c0);
        }
        for (int c1 = 0; c1 <= 15; c1 += 1)
          if (c1 == 0)
            {
              p = isl_printer_print_str(p, ",");
              p = isl_printer_end_line(p);
              p = isl_printer_start_line(p);
              p = isl_printer_print_str(p, "/* fifo */ ");
              p = isl_printer_print_str(p, "fifo_A_A_IO_L1_in");
              p = isl_printer_print_str(p, "_");
              p = isl_printer_print_int(p, c0);
              p = isl_printer_print_str(p, "_0");
              p = isl_printer_end_line(p);
              p = isl_printer_indent(p, -2);
              p = isl_printer_start_line(p);
              p = isl_printer_print_str(p, ");");
              p = isl_printer_end_line(p);
              p = isl_printer_start_line(p);
              p = isl_printer_print_str(p, "/* Module Call */");
              p = isl_printer_end_line(p);
              p = isl_printer_end_line(p);
            }
      }
    }
  // array
  // io_L3
  for (int c0 = 0; c0 <= 15; c0 += 1)
    if (c0 == 0) {
      // io_L2
      for (int c1 = 0; c1 <= 15; c1 += 1) {
        // io_L1
        if (c1 <= 14) {
          {
            // Count module number
            A_IO_L1_in_cnt++;
            A_IO_L1_in_intra_trans_cnt++;
            A_IO_L1_in_inter_trans_cnt++;
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* Module Call */");
            p = isl_printer_end_line(p);
            // Print calls of module: A_IO_L1_in
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "A_IO_L1_in");
            p = isl_printer_print_str(p, "<");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, ", ");
            p = isl_printer_print_int(p, c1);
            p = isl_printer_print_str(p, ">");
            p = isl_printer_print_str(p, "(");
            p = isl_printer_end_line(p);
            p = isl_printer_indent(p, 2);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* fifo */ ");
            p = isl_printer_print_str(p, "fifo_A_A_IO_L1_in");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c1);
            p = isl_printer_print_str(p, ",");
            p = isl_printer_end_line(p);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* fifo */ ");
            p = isl_printer_print_str(p, "fifo_A_A_IO_L1_in");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c1 + 1);
          }
          {
            p = isl_printer_print_str(p, ",");
            p = isl_printer_end_line(p);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* fifo */ ");
            p = isl_printer_print_str(p, "fifo_A_PE");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, 0);
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c1);
            p = isl_printer_end_line(p);
            p = isl_printer_indent(p, -2);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, ");");
            p = isl_printer_end_line(p);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* Module Call */");
            p = isl_printer_end_line(p);
            p = isl_printer_end_line(p);
          }
        } else {
          {
            // Count module number
            A_IO_L1_in_boundary_cnt++;
            A_IO_L1_in_intra_trans_cnt++;
            A_IO_L1_in_inter_trans_boundary_cnt++;
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* Module Call */");
            p = isl_printer_end_line(p);
            // Print calls of module: A_IO_L1_in_boundary
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "A_IO_L1_in_boundary");
            p = isl_printer_print_str(p, "<");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, ", ");
            p = isl_printer_print_int(p, c1);
            p = isl_printer_print_str(p, ">");
            p = isl_printer_print_str(p, "(");
            p = isl_printer_end_line(p);
            p = isl_printer_indent(p, 2);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* fifo */ ");
            p = isl_printer_print_str(p, "fifo_A_A_IO_L1_in");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c1);
          }
          {
            p = isl_printer_print_str(p, ",");
            p = isl_printer_end_line(p);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* fifo */ ");
            p = isl_printer_print_str(p, "fifo_A_PE");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, 0);
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, 15);
            p = isl_printer_end_line(p);
            p = isl_printer_indent(p, -2);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, ");");
            p = isl_printer_end_line(p);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* Module Call */");
            p = isl_printer_end_line(p);
            p = isl_printer_end_line(p);
          }
        }
      }
    }
  // array
  for (int c0 = 0; c0 <= 15; c0 += 1)
    for (int c1 = c0; c1 <= 15; c1 += 1)
      {
        // Count module number
        PE_cnt++;
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* Module Call */");
        p = isl_printer_end_line(p);
        // Print calls of module: PE
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "PE_wrapper");
        p = isl_printer_print_str(p, "<");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, ", ");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_print_str(p, ">");
        p = isl_printer_print_str(p, "(");
        p = isl_printer_end_line(p);
        p = isl_printer_indent(p, 2);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* fifo */ ");
        p = isl_printer_print_str(p, "fifo_V_PE");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_print_str(p, ",");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* fifo */ ");
        p = isl_printer_print_str(p, "fifo_V_PE");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0 + 1);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_print_str(p, ",");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* fifo */ ");
        p = isl_printer_print_str(p, "fifo_U_tmp_1_PE");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_print_str(p, ",");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* fifo */ ");
        p = isl_printer_print_str(p, "fifo_U_tmp_1_PE");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1 + 1);
        p = isl_printer_print_str(p, ",");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* fifo */ ");
        p = isl_printer_print_str(p, "fifo_A_PE");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_print_str(p, ",");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* fifo */ ");
        p = isl_printer_print_str(p, "fifo_L_drain_PE");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_print_str(p, ",");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* fifo */ ");
        p = isl_printer_print_str(p, "fifo_U_drain_PE");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c1);
        p = isl_printer_end_line(p);
        p = isl_printer_indent(p, -2);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, ");");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* Module Call */");
        p = isl_printer_end_line(p);
        p = isl_printer_end_line(p);
      }
  // array
  // io_L3
  for (int c0 = 0; c0 <= 15; c0 += 1)
    if (c0 <= 14) {
      // io_L2
      for (int c1 = c0; c1 <= 15; c1 += 1) {
        // io_L1
        if (c1 <= 14) {
          {
            // Count module number
            L_drain_IO_L1_out_cnt++;
            L_drain_IO_L1_out_intra_trans_cnt++;
            L_drain_IO_L1_out_inter_trans_cnt++;
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* Module Call */");
            p = isl_printer_end_line(p);
            // Print calls of module: L_drain_IO_L1_out
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "L_drain_IO_L1_out");
            p = isl_printer_print_str(p, "<");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, ", ");
            p = isl_printer_print_int(p, c1);
            p = isl_printer_print_str(p, ">");
            p = isl_printer_print_str(p, "(");
            p = isl_printer_end_line(p);
            p = isl_printer_indent(p, 2);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* fifo */ ");
            p = isl_printer_print_str(p, "fifo_L_drain_L_drain_IO_L1_out");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c1 + 1);
            p = isl_printer_print_str(p, ",");
            p = isl_printer_end_line(p);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* fifo */ ");
            p = isl_printer_print_str(p, "fifo_L_drain_L_drain_IO_L1_out");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c1);
          }
          {
            p = isl_printer_print_str(p, ",");
            p = isl_printer_end_line(p);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* fifo */ ");
            p = isl_printer_print_str(p, "fifo_L_drain_PE");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c1);
            p = isl_printer_end_line(p);
            p = isl_printer_indent(p, -2);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, ");");
            p = isl_printer_end_line(p);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* Module Call */");
            p = isl_printer_end_line(p);
            p = isl_printer_end_line(p);
          }
        } else {
          {
            // Count module number
            L_drain_IO_L1_out_boundary_cnt++;
            L_drain_IO_L1_out_intra_trans_cnt++;
            L_drain_IO_L1_out_inter_trans_boundary_cnt++;
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* Module Call */");
            p = isl_printer_end_line(p);
            // Print calls of module: L_drain_IO_L1_out_boundary
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "L_drain_IO_L1_out_boundary");
            p = isl_printer_print_str(p, "<");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, ", ");
            p = isl_printer_print_int(p, c1);
            p = isl_printer_print_str(p, ">");
            p = isl_printer_print_str(p, "(");
            p = isl_printer_end_line(p);
            p = isl_printer_indent(p, 2);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* fifo */ ");
            p = isl_printer_print_str(p, "fifo_L_drain_L_drain_IO_L1_out");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c1);
          }
          {
            p = isl_printer_print_str(p, ",");
            p = isl_printer_end_line(p);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* fifo */ ");
            p = isl_printer_print_str(p, "fifo_L_drain_PE");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, 15);
            p = isl_printer_end_line(p);
            p = isl_printer_indent(p, -2);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, ");");
            p = isl_printer_end_line(p);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* Module Call */");
            p = isl_printer_end_line(p);
            p = isl_printer_end_line(p);
          }
        }
      }
    }
  // array
  // io_L3
  for (int c0 = 0; c0 <= 15; c0 += 1)
    if (c0 <= 14) {
      // io_L2
      {
        if (c0 <= 13) {
          {
            // Count module number
            L_drain_IO_L2_out_cnt++;
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* Module Call */");
            p = isl_printer_end_line(p);
            // Print calls of module: L_drain_IO_L2_out
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "L_drain_IO_L2_out");
            p = isl_printer_print_str(p, "<");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, ">");
            p = isl_printer_print_str(p, "(");
            p = isl_printer_end_line(p);
            p = isl_printer_indent(p, 2);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* fifo */ ");
            p = isl_printer_print_str(p, "fifo_L_drain_L_drain_IO_L2_out");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0 + 1);
            p = isl_printer_print_str(p, ",");
            p = isl_printer_end_line(p);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* fifo */ ");
            p = isl_printer_print_str(p, "fifo_L_drain_L_drain_IO_L2_out");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0);
          }
          for (int c1 = c0; c1 <= 15; c1 += 1)
            if (c1 == c0)
              {
                p = isl_printer_print_str(p, ",");
                p = isl_printer_end_line(p);
                p = isl_printer_start_line(p);
                p = isl_printer_print_str(p, "/* fifo */ ");
                p = isl_printer_print_str(p, "fifo_L_drain_L_drain_IO_L1_out");
                p = isl_printer_print_str(p, "_");
                p = isl_printer_print_int(p, c0);
                p = isl_printer_print_str(p, "_");
                p = isl_printer_print_int(p, c1);
                p = isl_printer_end_line(p);
                p = isl_printer_indent(p, -2);
                p = isl_printer_start_line(p);
                p = isl_printer_print_str(p, ");");
                p = isl_printer_end_line(p);
                p = isl_printer_start_line(p);
                p = isl_printer_print_str(p, "/* Module Call */");
                p = isl_printer_end_line(p);
                p = isl_printer_end_line(p);
              }
        } else {
          {
            // Count module number
            L_drain_IO_L2_out_boundary_cnt++;
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* Module Call */");
            p = isl_printer_end_line(p);
            // Print calls of module: L_drain_IO_L2_out_boundary
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "L_drain_IO_L2_out_boundary");
            p = isl_printer_print_str(p, "<");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, ">");
            p = isl_printer_print_str(p, "(");
            p = isl_printer_end_line(p);
            p = isl_printer_indent(p, 2);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* fifo */ ");
            p = isl_printer_print_str(p, "fifo_L_drain_L_drain_IO_L2_out");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0);
          }
          for (int c1 = 14; c1 <= 15; c1 += 1)
            if (c1 == 14)
              {
                p = isl_printer_print_str(p, ",");
                p = isl_printer_end_line(p);
                p = isl_printer_start_line(p);
                p = isl_printer_print_str(p, "/* fifo */ ");
                p = isl_printer_print_str(p, "fifo_L_drain_L_drain_IO_L1_out");
                p = isl_printer_print_str(p, "_");
                p = isl_printer_print_int(p, c0);
                p = isl_printer_print_str(p, "_14");
                p = isl_printer_end_line(p);
                p = isl_printer_indent(p, -2);
                p = isl_printer_start_line(p);
                p = isl_printer_print_str(p, ");");
                p = isl_printer_end_line(p);
                p = isl_printer_start_line(p);
                p = isl_printer_print_str(p, "/* Module Call */");
                p = isl_printer_end_line(p);
                p = isl_printer_end_line(p);
              }
        }
      }
    }
  // array
  // io_L3
  {
    {
      // Count module number
      L_drain_IO_L3_out_cnt++;
      p = isl_printer_start_line(p);
      p = isl_printer_print_str(p, "/* Module Call */");
      p = isl_printer_end_line(p);
      // Print calls of module: L_drain_IO_L3_out
      p = isl_printer_start_line(p);
      p = isl_printer_print_str(p, "L_drain_IO_L3_out");
      p = isl_printer_print_str(p, "(");
      p = isl_printer_end_line(p);
      p = isl_printer_indent(p, 2);
      p = isl_printer_start_line(p);
      p = isl_printer_print_str(p, "/* array */ L");
    }
    for (int c0 = 0; c0 <= 15; c0 += 1)
      if (c0 == 0)
        {
          p = isl_printer_print_str(p, ",");
          p = isl_printer_end_line(p);
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "/* fifo */ ");
          p = isl_printer_print_str(p, "fifo_L_drain_L_drain_IO_L2_out");
          p = isl_printer_print_str(p, "_0");
          p = isl_printer_end_line(p);
          p = isl_printer_indent(p, -2);
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, ");");
          p = isl_printer_end_line(p);
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "/* Module Call */");
          p = isl_printer_end_line(p);
          p = isl_printer_end_line(p);
        }
  }
  // array
  // io_L3
  for (int c0 = 0; c0 <= 15; c0 += 1) {
    // io_L2
    for (int c1 = c0; c1 <= 15; c1 += 1)
      if (c1 == c0) {
        // io_L1
        {
          {
            // Count module number
            U_drain_IO_L1_out_boundary_cnt++;
            U_drain_IO_L1_out_intra_trans_cnt++;
            U_drain_IO_L1_out_inter_trans_boundary_cnt++;
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* Module Call */");
            p = isl_printer_end_line(p);
            // Print calls of module: U_drain_IO_L1_out_boundary
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "U_drain_IO_L1_out_boundary");
            p = isl_printer_print_str(p, "<");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, ", ");
            p = isl_printer_print_int(p, c1);
            p = isl_printer_print_str(p, ">");
            p = isl_printer_print_str(p, "(");
            p = isl_printer_end_line(p);
            p = isl_printer_indent(p, 2);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* fifo */ ");
            p = isl_printer_print_str(p, "fifo_U_drain_U_drain_IO_L1_out");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c1);
          }
          {
            p = isl_printer_print_str(p, ",");
            p = isl_printer_end_line(p);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* fifo */ ");
            p = isl_printer_print_str(p, "fifo_U_drain_PE");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_end_line(p);
            p = isl_printer_indent(p, -2);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, ");");
            p = isl_printer_end_line(p);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* Module Call */");
            p = isl_printer_end_line(p);
            p = isl_printer_end_line(p);
          }
        }
      }
  }
  // array
  // io_L3
  for (int c0 = 0; c0 <= 15; c0 += 1) {
    // io_L2
    if (c0 <= 14) {
      {
        // Count module number
        U_drain_IO_L2_out_cnt++;
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* Module Call */");
        p = isl_printer_end_line(p);
        // Print calls of module: U_drain_IO_L2_out
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "U_drain_IO_L2_out");
        p = isl_printer_print_str(p, "<");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, ">");
        p = isl_printer_print_str(p, "(");
        p = isl_printer_end_line(p);
        p = isl_printer_indent(p, 2);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* fifo */ ");
        p = isl_printer_print_str(p, "fifo_U_drain_U_drain_IO_L2_out");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0 + 1);
        p = isl_printer_print_str(p, ",");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* fifo */ ");
        p = isl_printer_print_str(p, "fifo_U_drain_U_drain_IO_L2_out");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
      }
      for (int c1 = c0; c1 <= 15; c1 += 1)
        if (c1 == c0)
          {
            p = isl_printer_print_str(p, ",");
            p = isl_printer_end_line(p);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* fifo */ ");
            p = isl_printer_print_str(p, "fifo_U_drain_U_drain_IO_L1_out");
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c0);
            p = isl_printer_print_str(p, "_");
            p = isl_printer_print_int(p, c1);
            p = isl_printer_end_line(p);
            p = isl_printer_indent(p, -2);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, ");");
            p = isl_printer_end_line(p);
            p = isl_printer_start_line(p);
            p = isl_printer_print_str(p, "/* Module Call */");
            p = isl_printer_end_line(p);
            p = isl_printer_end_line(p);
          }
    } else {
      {
        // Count module number
        U_drain_IO_L2_out_boundary_cnt++;
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* Module Call */");
        p = isl_printer_end_line(p);
        // Print calls of module: U_drain_IO_L2_out_boundary
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "U_drain_IO_L2_out_boundary");
        p = isl_printer_print_str(p, "<");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, ">");
        p = isl_printer_print_str(p, "(");
        p = isl_printer_end_line(p);
        p = isl_printer_indent(p, 2);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* fifo */ ");
        p = isl_printer_print_str(p, "fifo_U_drain_U_drain_IO_L2_out");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
      }
      {
        p = isl_printer_print_str(p, ",");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* fifo */ ");
        p = isl_printer_print_str(p, "fifo_U_drain_U_drain_IO_L1_out");
        p = isl_printer_print_str(p, "_");
        p = isl_printer_print_int(p, c0);
        p = isl_printer_print_str(p, "_15");
        p = isl_printer_end_line(p);
        p = isl_printer_indent(p, -2);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, ");");
        p = isl_printer_end_line(p);
        p = isl_printer_start_line(p);
        p = isl_printer_print_str(p, "/* Module Call */");
        p = isl_printer_end_line(p);
        p = isl_printer_end_line(p);
      }
    }
  }
  // array
  // io_L3
  {
    {
      // Count module number
      U_drain_IO_L3_out_cnt++;
      p = isl_printer_start_line(p);
      p = isl_printer_print_str(p, "/* Module Call */");
      p = isl_printer_end_line(p);
      // Print calls of module: U_drain_IO_L3_out
      p = isl_printer_start_line(p);
      p = isl_printer_print_str(p, "U_drain_IO_L3_out");
      p = isl_printer_print_str(p, "(");
      p = isl_printer_end_line(p);
      p = isl_printer_indent(p, 2);
      p = isl_printer_start_line(p);
      p = isl_printer_print_str(p, "/* array */ U");
    }
    for (int c0 = 0; c0 <= 15; c0 += 1)
      if (c0 == 0)
        {
          p = isl_printer_print_str(p, ",");
          p = isl_printer_end_line(p);
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "/* fifo */ ");
          p = isl_printer_print_str(p, "fifo_U_drain_U_drain_IO_L2_out");
          p = isl_printer_print_str(p, "_0");
          p = isl_printer_end_line(p);
          p = isl_printer_indent(p, -2);
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, ");");
          p = isl_printer_end_line(p);
          p = isl_printer_start_line(p);
          p = isl_printer_print_str(p, "/* Module Call */");
          p = isl_printer_end_line(p);
          p = isl_printer_end_line(p);
        }
  }
  fprintf(fd, "module:A_IO_L3_in:%d\n", A_IO_L3_in_cnt);
  fprintf(fd, "module:A_IO_L2_in:%d\n", A_IO_L2_in_cnt);
  fprintf(fd, "module:A_IO_L2_in_boundary:%d\n", A_IO_L2_in_boundary_cnt);
  fprintf(fd, "module:A_IO_L1_in_intra_trans:%d\n", A_IO_L1_in_intra_trans_cnt);
  fprintf(fd, "module:A_IO_L1_in_inter_trans:%d\n", A_IO_L1_in_inter_trans_cnt);
  fprintf(fd, "module:A_IO_L1_in_inter_trans_boundary:%d\n", A_IO_L1_in_inter_trans_boundary_cnt);
  fprintf(fd, "module:A_IO_L1_in:%d\n", A_IO_L1_in_cnt);
  fprintf(fd, "module:A_IO_L1_in_boundary:%d\n", A_IO_L1_in_boundary_cnt);
  fprintf(fd, "module:PE:%d\n", PE_cnt);
  fprintf(fd, "module:L_drain_IO_L1_out_intra_trans:%d\n", L_drain_IO_L1_out_intra_trans_cnt);
  fprintf(fd, "module:L_drain_IO_L1_out_inter_trans:%d\n", L_drain_IO_L1_out_inter_trans_cnt);
  fprintf(fd, "module:L_drain_IO_L1_out_inter_trans_boundary:%d\n", L_drain_IO_L1_out_inter_trans_boundary_cnt);
  fprintf(fd, "module:L_drain_IO_L1_out:%d\n", L_drain_IO_L1_out_cnt);
  fprintf(fd, "module:L_drain_IO_L1_out_boundary:%d\n", L_drain_IO_L1_out_boundary_cnt);
  fprintf(fd, "module:L_drain_IO_L2_out:%d\n", L_drain_IO_L2_out_cnt);
  fprintf(fd, "module:L_drain_IO_L2_out_boundary:%d\n", L_drain_IO_L2_out_boundary_cnt);
  fprintf(fd, "module:L_drain_IO_L3_out:%d\n", L_drain_IO_L3_out_cnt);
  fprintf(fd, "module:U_drain_IO_L1_out_intra_trans:%d\n", U_drain_IO_L1_out_intra_trans_cnt);
  fprintf(fd, "module:U_drain_IO_L1_out_inter_trans:%d\n", U_drain_IO_L1_out_inter_trans_cnt);
  fprintf(fd, "module:U_drain_IO_L1_out_inter_trans_boundary:%d\n", U_drain_IO_L1_out_inter_trans_boundary_cnt);
  fprintf(fd, "module:U_drain_IO_L1_out:%d\n", U_drain_IO_L1_out_cnt);
  fprintf(fd, "module:U_drain_IO_L1_out_boundary:%d\n", U_drain_IO_L1_out_boundary_cnt);
  fprintf(fd, "module:U_drain_IO_L2_out:%d\n", U_drain_IO_L2_out_cnt);
  fprintf(fd, "module:U_drain_IO_L2_out_boundary:%d\n", U_drain_IO_L2_out_boundary_cnt);
  fprintf(fd, "module:U_drain_IO_L3_out:%d\n", U_drain_IO_L3_out_cnt);

  p = isl_printer_indent(p, -2);
  p = isl_printer_start_line(p);
  p = isl_printer_print_str(p, "}");
  p = isl_printer_end_line(p);

  fclose(fd);
  isl_printer_free(p);
  isl_ctx_free(ctx);
}

int main()
{
  FILE *f = fopen("./autosa.tmp/output/src/top.cpp", "w");
  top_generate(f);
}
