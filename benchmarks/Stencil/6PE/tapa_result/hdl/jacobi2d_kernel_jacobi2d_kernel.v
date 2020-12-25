`timescale 1 ns / 1 ps 

(* CORE_GENERATION_INFO = "jacobi2d_kernel_jacobi2d_kernel,hls_ip_2019_2,{HLS_INPUT_TYPE=cxx,HLS_INPUT_FLOAT=0,HLS_INPUT_FIXED=0,HLS_INPUT_PART=xcu250-figd2104-2L-e,HLS_INPUT_CLOCK=3.330000,HLS_INPUT_ARCH=others,HLS_SYN_CLOCK=1.000000,HLS_SYN_LAT=1,HLS_SYN_TPT=none,HLS_SYN_MEM=0,HLS_SYN_DSP=0,HLS_SYN_FF=432,HLS_SYN_LUT=759,HLS_VERSION=2019_2}" *)


module jacobi2d_kernel
(
  ap_clk,
  ap_rst_n,
  s_axi_control_AWVALID,
  s_axi_control_AWREADY,
  s_axi_control_AWADDR,
  s_axi_control_WVALID,
  s_axi_control_WREADY,
  s_axi_control_WDATA,
  s_axi_control_WSTRB,
  s_axi_control_ARVALID,
  s_axi_control_ARREADY,
  s_axi_control_ARADDR,
  s_axi_control_RVALID,
  s_axi_control_RREADY,
  s_axi_control_RDATA,
  s_axi_control_RRESP,
  s_axi_control_BVALID,
  s_axi_control_BREADY,
  s_axi_control_BRESP,
  interrupt,
  m_axi_var_input_0_0_ARADDR,
  m_axi_var_input_0_0_ARBURST,
  m_axi_var_input_0_0_ARCACHE,
  m_axi_var_input_0_0_ARID,
  m_axi_var_input_0_0_ARLEN,
  m_axi_var_input_0_0_ARLOCK,
  m_axi_var_input_0_0_ARPROT,
  m_axi_var_input_0_0_ARQOS,
  m_axi_var_input_0_0_ARREADY,
  m_axi_var_input_0_0_ARREGION,
  m_axi_var_input_0_0_ARSIZE,
  m_axi_var_input_0_0_ARUSER,
  m_axi_var_input_0_0_ARVALID,
  m_axi_var_input_0_0_AWADDR,
  m_axi_var_input_0_0_AWBURST,
  m_axi_var_input_0_0_AWCACHE,
  m_axi_var_input_0_0_AWID,
  m_axi_var_input_0_0_AWLEN,
  m_axi_var_input_0_0_AWLOCK,
  m_axi_var_input_0_0_AWPROT,
  m_axi_var_input_0_0_AWQOS,
  m_axi_var_input_0_0_AWREADY,
  m_axi_var_input_0_0_AWREGION,
  m_axi_var_input_0_0_AWSIZE,
  m_axi_var_input_0_0_AWUSER,
  m_axi_var_input_0_0_AWVALID,
  m_axi_var_input_0_0_BID,
  m_axi_var_input_0_0_BREADY,
  m_axi_var_input_0_0_BRESP,
  m_axi_var_input_0_0_BUSER,
  m_axi_var_input_0_0_BVALID,
  m_axi_var_input_0_0_RDATA,
  m_axi_var_input_0_0_RID,
  m_axi_var_input_0_0_RLAST,
  m_axi_var_input_0_0_RREADY,
  m_axi_var_input_0_0_RRESP,
  m_axi_var_input_0_0_RUSER,
  m_axi_var_input_0_0_RVALID,
  m_axi_var_input_0_0_WDATA,
  m_axi_var_input_0_0_WID,
  m_axi_var_input_0_0_WLAST,
  m_axi_var_input_0_0_WREADY,
  m_axi_var_input_0_0_WSTRB,
  m_axi_var_input_0_0_WUSER,
  m_axi_var_input_0_0_WVALID,
  m_axi_var_output_0_0_ARADDR,
  m_axi_var_output_0_0_ARBURST,
  m_axi_var_output_0_0_ARCACHE,
  m_axi_var_output_0_0_ARID,
  m_axi_var_output_0_0_ARLEN,
  m_axi_var_output_0_0_ARLOCK,
  m_axi_var_output_0_0_ARPROT,
  m_axi_var_output_0_0_ARQOS,
  m_axi_var_output_0_0_ARREADY,
  m_axi_var_output_0_0_ARREGION,
  m_axi_var_output_0_0_ARSIZE,
  m_axi_var_output_0_0_ARUSER,
  m_axi_var_output_0_0_ARVALID,
  m_axi_var_output_0_0_AWADDR,
  m_axi_var_output_0_0_AWBURST,
  m_axi_var_output_0_0_AWCACHE,
  m_axi_var_output_0_0_AWID,
  m_axi_var_output_0_0_AWLEN,
  m_axi_var_output_0_0_AWLOCK,
  m_axi_var_output_0_0_AWPROT,
  m_axi_var_output_0_0_AWQOS,
  m_axi_var_output_0_0_AWREADY,
  m_axi_var_output_0_0_AWREGION,
  m_axi_var_output_0_0_AWSIZE,
  m_axi_var_output_0_0_AWUSER,
  m_axi_var_output_0_0_AWVALID,
  m_axi_var_output_0_0_BID,
  m_axi_var_output_0_0_BREADY,
  m_axi_var_output_0_0_BRESP,
  m_axi_var_output_0_0_BUSER,
  m_axi_var_output_0_0_BVALID,
  m_axi_var_output_0_0_RDATA,
  m_axi_var_output_0_0_RID,
  m_axi_var_output_0_0_RLAST,
  m_axi_var_output_0_0_RREADY,
  m_axi_var_output_0_0_RRESP,
  m_axi_var_output_0_0_RUSER,
  m_axi_var_output_0_0_RVALID,
  m_axi_var_output_0_0_WDATA,
  m_axi_var_output_0_0_WID,
  m_axi_var_output_0_0_WLAST,
  m_axi_var_output_0_0_WREADY,
  m_axi_var_output_0_0_WSTRB,
  m_axi_var_output_0_0_WUSER,
  m_axi_var_output_0_0_WVALID
);

  parameter C_S_AXI_CONTROL_DATA_WIDTH = 32;
  parameter C_S_AXI_CONTROL_ADDR_WIDTH = 7;
  parameter C_S_AXI_DATA_WIDTH = 32;
  parameter C_S_AXI_CONTROL_WSTRB_WIDTH = 32 / 8;
  parameter C_S_AXI_WSTRB_WIDTH = 32 / 8;
  input ap_clk;
  input ap_rst_n;
  input s_axi_control_AWVALID;
  output s_axi_control_AWREADY;
  input [C_S_AXI_CONTROL_ADDR_WIDTH-1:0] s_axi_control_AWADDR;
  input s_axi_control_WVALID;
  output s_axi_control_WREADY;
  input [C_S_AXI_CONTROL_DATA_WIDTH-1:0] s_axi_control_WDATA;
  input [C_S_AXI_CONTROL_WSTRB_WIDTH-1:0] s_axi_control_WSTRB;
  input s_axi_control_ARVALID;
  output s_axi_control_ARREADY;
  input [C_S_AXI_CONTROL_ADDR_WIDTH-1:0] s_axi_control_ARADDR;
  output s_axi_control_RVALID;
  input s_axi_control_RREADY;
  output [C_S_AXI_CONTROL_DATA_WIDTH-1:0] s_axi_control_RDATA;
  output [1:0] s_axi_control_RRESP;
  output s_axi_control_BVALID;
  input s_axi_control_BREADY;
  output [1:0] s_axi_control_BRESP;
  output interrupt;
  output [63:0] m_axi_var_input_0_0_ARADDR;
  output [1:0] m_axi_var_input_0_0_ARBURST;
  output [3:0] m_axi_var_input_0_0_ARCACHE;
  output [0:0] m_axi_var_input_0_0_ARID;
  output [7:0] m_axi_var_input_0_0_ARLEN;
  output m_axi_var_input_0_0_ARLOCK;
  output [2:0] m_axi_var_input_0_0_ARPROT;
  output [3:0] m_axi_var_input_0_0_ARQOS;
  input m_axi_var_input_0_0_ARREADY;
  output [3:0] m_axi_var_input_0_0_ARREGION;
  output [2:0] m_axi_var_input_0_0_ARSIZE;
  output m_axi_var_input_0_0_ARUSER;
  output m_axi_var_input_0_0_ARVALID;
  output [63:0] m_axi_var_input_0_0_AWADDR;
  output [1:0] m_axi_var_input_0_0_AWBURST;
  output [3:0] m_axi_var_input_0_0_AWCACHE;
  output [0:0] m_axi_var_input_0_0_AWID;
  output [7:0] m_axi_var_input_0_0_AWLEN;
  output m_axi_var_input_0_0_AWLOCK;
  output [2:0] m_axi_var_input_0_0_AWPROT;
  output [3:0] m_axi_var_input_0_0_AWQOS;
  input m_axi_var_input_0_0_AWREADY;
  output [3:0] m_axi_var_input_0_0_AWREGION;
  output [2:0] m_axi_var_input_0_0_AWSIZE;
  output m_axi_var_input_0_0_AWUSER;
  output m_axi_var_input_0_0_AWVALID;
  input [0:0] m_axi_var_input_0_0_BID;
  output m_axi_var_input_0_0_BREADY;
  input [1:0] m_axi_var_input_0_0_BRESP;
  input m_axi_var_input_0_0_BUSER;
  input m_axi_var_input_0_0_BVALID;
  input [511:0] m_axi_var_input_0_0_RDATA;
  input [0:0] m_axi_var_input_0_0_RID;
  input m_axi_var_input_0_0_RLAST;
  output m_axi_var_input_0_0_RREADY;
  input [1:0] m_axi_var_input_0_0_RRESP;
  input m_axi_var_input_0_0_RUSER;
  input m_axi_var_input_0_0_RVALID;
  output [511:0] m_axi_var_input_0_0_WDATA;
  output [0:0] m_axi_var_input_0_0_WID;
  output m_axi_var_input_0_0_WLAST;
  input m_axi_var_input_0_0_WREADY;
  output [63:0] m_axi_var_input_0_0_WSTRB;
  output m_axi_var_input_0_0_WUSER;
  output m_axi_var_input_0_0_WVALID;
  output [63:0] m_axi_var_output_0_0_ARADDR;
  output [1:0] m_axi_var_output_0_0_ARBURST;
  output [3:0] m_axi_var_output_0_0_ARCACHE;
  output [0:0] m_axi_var_output_0_0_ARID;
  output [7:0] m_axi_var_output_0_0_ARLEN;
  output m_axi_var_output_0_0_ARLOCK;
  output [2:0] m_axi_var_output_0_0_ARPROT;
  output [3:0] m_axi_var_output_0_0_ARQOS;
  input m_axi_var_output_0_0_ARREADY;
  output [3:0] m_axi_var_output_0_0_ARREGION;
  output [2:0] m_axi_var_output_0_0_ARSIZE;
  output m_axi_var_output_0_0_ARUSER;
  output m_axi_var_output_0_0_ARVALID;
  output [63:0] m_axi_var_output_0_0_AWADDR;
  output [1:0] m_axi_var_output_0_0_AWBURST;
  output [3:0] m_axi_var_output_0_0_AWCACHE;
  output [0:0] m_axi_var_output_0_0_AWID;
  output [7:0] m_axi_var_output_0_0_AWLEN;
  output m_axi_var_output_0_0_AWLOCK;
  output [2:0] m_axi_var_output_0_0_AWPROT;
  output [3:0] m_axi_var_output_0_0_AWQOS;
  input m_axi_var_output_0_0_AWREADY;
  output [3:0] m_axi_var_output_0_0_AWREGION;
  output [2:0] m_axi_var_output_0_0_AWSIZE;
  output m_axi_var_output_0_0_AWUSER;
  output m_axi_var_output_0_0_AWVALID;
  input [0:0] m_axi_var_output_0_0_BID;
  output m_axi_var_output_0_0_BREADY;
  input [1:0] m_axi_var_output_0_0_BRESP;
  input m_axi_var_output_0_0_BUSER;
  input m_axi_var_output_0_0_BVALID;
  input [511:0] m_axi_var_output_0_0_RDATA;
  input [0:0] m_axi_var_output_0_0_RID;
  input m_axi_var_output_0_0_RLAST;
  output m_axi_var_output_0_0_RREADY;
  input [1:0] m_axi_var_output_0_0_RRESP;
  input m_axi_var_output_0_0_RUSER;
  input m_axi_var_output_0_0_RVALID;
  output [511:0] m_axi_var_output_0_0_WDATA;
  output [0:0] m_axi_var_output_0_0_WID;
  output m_axi_var_output_0_0_WLAST;
  input m_axi_var_output_0_0_WREADY;
  output [63:0] m_axi_var_output_0_0_WSTRB;
  output m_axi_var_output_0_0_WUSER;
  output m_axi_var_output_0_0_WVALID;
  wire ap_start;
  wire [63:0] var_output_0_0;
  wire [63:0] var_input_0_0;
  wire [63:0] coalesced_data_num;
  wire [63:0] tile_data_num;
  wire [31:0] tile_num_dim_0;
  wire [31:0] input_size_dim_0;
  wire [31:0] input_size_dim_1;
  wire ap_rst_n_inv;
  wire ap_done;
  wire ap_idle;
  wire ap_ready;
  wire ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg ap_rst_n__q3;
  wire [512:0] input_stream_0_0__dout;
  wire input_stream_0_0__empty_n;
  wire input_stream_0_0__read;
  wire [512:0] input_stream_0_0__din;
  wire input_stream_0_0__full_n;
  wire input_stream_0_0__write;
  wire input_stream_0_0__rst__q0;
  (* dont_touch = "yes" *)
  reg input_stream_0_0__rst__q1;
  (* dont_touch = "yes" *)
  reg input_stream_0_0__rst__q2;
  (* dont_touch = "yes" *)
  reg input_stream_0_0__rst__q3;
  wire [512:0] input_stream_0_1__dout;
  wire input_stream_0_1__empty_n;
  wire input_stream_0_1__read;
  wire [512:0] input_stream_0_1__din;
  wire input_stream_0_1__full_n;
  wire input_stream_0_1__write;
  wire input_stream_0_1__rst__q0;
  (* dont_touch = "yes" *)
  reg input_stream_0_1__rst__q1;
  (* dont_touch = "yes" *)
  reg input_stream_0_1__rst__q2;
  (* dont_touch = "yes" *)
  reg input_stream_0_1__rst__q3;
  wire [512:0] input_stream_0_2__dout;
  wire input_stream_0_2__empty_n;
  wire input_stream_0_2__read;
  wire [512:0] input_stream_0_2__din;
  wire input_stream_0_2__full_n;
  wire input_stream_0_2__write;
  wire input_stream_0_2__rst__q0;
  (* dont_touch = "yes" *)
  reg input_stream_0_2__rst__q1;
  (* dont_touch = "yes" *)
  reg input_stream_0_2__rst__q2;
  (* dont_touch = "yes" *)
  reg input_stream_0_2__rst__q3;
  wire [512:0] input_stream_0_3__dout;
  wire input_stream_0_3__empty_n;
  wire input_stream_0_3__read;
  wire [512:0] input_stream_0_3__din;
  wire input_stream_0_3__full_n;
  wire input_stream_0_3__write;
  wire input_stream_0_3__rst__q0;
  (* dont_touch = "yes" *)
  reg input_stream_0_3__rst__q1;
  (* dont_touch = "yes" *)
  reg input_stream_0_3__rst__q2;
  (* dont_touch = "yes" *)
  reg input_stream_0_3__rst__q3;
  wire [512:0] output_stream_0_0__dout;
  wire output_stream_0_0__empty_n;
  wire output_stream_0_0__read;
  wire [512:0] output_stream_0_0__din;
  wire output_stream_0_0__full_n;
  wire output_stream_0_0__write;
  wire output_stream_0_0__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_0_0__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_0_0__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_0_0__rst__q3;
  wire [512:0] output_stream_0_1__dout;
  wire output_stream_0_1__empty_n;
  wire output_stream_0_1__read;
  wire [512:0] output_stream_0_1__din;
  wire output_stream_0_1__full_n;
  wire output_stream_0_1__write;
  wire output_stream_0_1__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_0_1__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_0_1__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_0_1__rst__q3;
  wire [512:0] output_stream_0_2__dout;
  wire output_stream_0_2__empty_n;
  wire output_stream_0_2__read;
  wire [512:0] output_stream_0_2__din;
  wire output_stream_0_2__full_n;
  wire output_stream_0_2__write;
  wire output_stream_0_2__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_0_2__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_0_2__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_0_2__rst__q3;
  wire [512:0] output_stream_0_3__dout;
  wire output_stream_0_3__empty_n;
  wire output_stream_0_3__read;
  wire [512:0] output_stream_0_3__din;
  wire output_stream_0_3__full_n;
  wire output_stream_0_3__write;
  wire output_stream_0_3__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_0_3__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_0_3__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_0_3__rst__q3;
  wire [512:0] output_stream_1_0__dout;
  wire output_stream_1_0__empty_n;
  wire output_stream_1_0__read;
  wire [512:0] output_stream_1_0__din;
  wire output_stream_1_0__full_n;
  wire output_stream_1_0__write;
  wire output_stream_1_0__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_1_0__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_1_0__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_1_0__rst__q3;
  wire [512:0] output_stream_1_1__dout;
  wire output_stream_1_1__empty_n;
  wire output_stream_1_1__read;
  wire [512:0] output_stream_1_1__din;
  wire output_stream_1_1__full_n;
  wire output_stream_1_1__write;
  wire output_stream_1_1__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_1_1__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_1_1__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_1_1__rst__q3;
  wire [512:0] output_stream_1_2__dout;
  wire output_stream_1_2__empty_n;
  wire output_stream_1_2__read;
  wire [512:0] output_stream_1_2__din;
  wire output_stream_1_2__full_n;
  wire output_stream_1_2__write;
  wire output_stream_1_2__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_1_2__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_1_2__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_1_2__rst__q3;
  wire [512:0] output_stream_1_3__dout;
  wire output_stream_1_3__empty_n;
  wire output_stream_1_3__read;
  wire [512:0] output_stream_1_3__din;
  wire output_stream_1_3__full_n;
  wire output_stream_1_3__write;
  wire output_stream_1_3__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_1_3__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_1_3__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_1_3__rst__q3;
  wire [512:0] output_stream_2_0__dout;
  wire output_stream_2_0__empty_n;
  wire output_stream_2_0__read;
  wire [512:0] output_stream_2_0__din;
  wire output_stream_2_0__full_n;
  wire output_stream_2_0__write;
  wire output_stream_2_0__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_2_0__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_2_0__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_2_0__rst__q3;
  wire [512:0] output_stream_2_1__dout;
  wire output_stream_2_1__empty_n;
  wire output_stream_2_1__read;
  wire [512:0] output_stream_2_1__din;
  wire output_stream_2_1__full_n;
  wire output_stream_2_1__write;
  wire output_stream_2_1__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_2_1__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_2_1__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_2_1__rst__q3;
  wire [512:0] output_stream_2_2__dout;
  wire output_stream_2_2__empty_n;
  wire output_stream_2_2__read;
  wire [512:0] output_stream_2_2__din;
  wire output_stream_2_2__full_n;
  wire output_stream_2_2__write;
  wire output_stream_2_2__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_2_2__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_2_2__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_2_2__rst__q3;
  wire [512:0] output_stream_2_3__dout;
  wire output_stream_2_3__empty_n;
  wire output_stream_2_3__read;
  wire [512:0] output_stream_2_3__din;
  wire output_stream_2_3__full_n;
  wire output_stream_2_3__write;
  wire output_stream_2_3__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_2_3__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_2_3__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_2_3__rst__q3;
  wire [512:0] output_stream_3_0__dout;
  wire output_stream_3_0__empty_n;
  wire output_stream_3_0__read;
  wire [512:0] output_stream_3_0__din;
  wire output_stream_3_0__full_n;
  wire output_stream_3_0__write;
  wire output_stream_3_0__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_3_0__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_3_0__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_3_0__rst__q3;
  wire [512:0] output_stream_3_1__dout;
  wire output_stream_3_1__empty_n;
  wire output_stream_3_1__read;
  wire [512:0] output_stream_3_1__din;
  wire output_stream_3_1__full_n;
  wire output_stream_3_1__write;
  wire output_stream_3_1__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_3_1__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_3_1__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_3_1__rst__q3;
  wire [512:0] output_stream_3_2__dout;
  wire output_stream_3_2__empty_n;
  wire output_stream_3_2__read;
  wire [512:0] output_stream_3_2__din;
  wire output_stream_3_2__full_n;
  wire output_stream_3_2__write;
  wire output_stream_3_2__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_3_2__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_3_2__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_3_2__rst__q3;
  wire [512:0] output_stream_3_3__dout;
  wire output_stream_3_3__empty_n;
  wire output_stream_3_3__read;
  wire [512:0] output_stream_3_3__din;
  wire output_stream_3_3__full_n;
  wire output_stream_3_3__write;
  wire output_stream_3_3__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_3_3__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_3_3__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_3_3__rst__q3;
  wire [512:0] output_stream_4_0__dout;
  wire output_stream_4_0__empty_n;
  wire output_stream_4_0__read;
  wire [512:0] output_stream_4_0__din;
  wire output_stream_4_0__full_n;
  wire output_stream_4_0__write;
  wire output_stream_4_0__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_4_0__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_4_0__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_4_0__rst__q3;
  wire [512:0] output_stream_4_1__dout;
  wire output_stream_4_1__empty_n;
  wire output_stream_4_1__read;
  wire [512:0] output_stream_4_1__din;
  wire output_stream_4_1__full_n;
  wire output_stream_4_1__write;
  wire output_stream_4_1__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_4_1__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_4_1__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_4_1__rst__q3;
  wire [512:0] output_stream_4_2__dout;
  wire output_stream_4_2__empty_n;
  wire output_stream_4_2__read;
  wire [512:0] output_stream_4_2__din;
  wire output_stream_4_2__full_n;
  wire output_stream_4_2__write;
  wire output_stream_4_2__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_4_2__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_4_2__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_4_2__rst__q3;
  wire [512:0] output_stream_4_3__dout;
  wire output_stream_4_3__empty_n;
  wire output_stream_4_3__read;
  wire [512:0] output_stream_4_3__din;
  wire output_stream_4_3__full_n;
  wire output_stream_4_3__write;
  wire output_stream_4_3__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_4_3__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_4_3__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_4_3__rst__q3;
  wire [512:0] output_stream_5_0__dout;
  wire output_stream_5_0__empty_n;
  wire output_stream_5_0__read;
  wire [512:0] output_stream_5_0__din;
  wire output_stream_5_0__full_n;
  wire output_stream_5_0__write;
  wire output_stream_5_0__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_5_0__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_5_0__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_5_0__rst__q3;
  wire [512:0] output_stream_5_1__dout;
  wire output_stream_5_1__empty_n;
  wire output_stream_5_1__read;
  wire [512:0] output_stream_5_1__din;
  wire output_stream_5_1__full_n;
  wire output_stream_5_1__write;
  wire output_stream_5_1__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_5_1__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_5_1__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_5_1__rst__q3;
  wire [512:0] output_stream_5_2__dout;
  wire output_stream_5_2__empty_n;
  wire output_stream_5_2__read;
  wire [512:0] output_stream_5_2__din;
  wire output_stream_5_2__full_n;
  wire output_stream_5_2__write;
  wire output_stream_5_2__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_5_2__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_5_2__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_5_2__rst__q3;
  wire [512:0] output_stream_5_3__dout;
  wire output_stream_5_3__empty_n;
  wire output_stream_5_3__read;
  wire [512:0] output_stream_5_3__din;
  wire output_stream_5_3__full_n;
  wire output_stream_5_3__write;
  wire output_stream_5_3__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_5_3__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_5_3__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_5_3__rst__q3;
  wire [63:0] compute_0___coalesced_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_0___coalesced_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_0___coalesced_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_0___coalesced_data_num__q3;
  wire [31:0] compute_0___input_size_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___input_size_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___input_size_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___input_size_dim_0__q3;
  wire [31:0] compute_0___input_size_dim_1__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___input_size_dim_1__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___input_size_dim_1__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___input_size_dim_1__q3;
  wire [63:0] compute_0___tile_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_0___tile_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_0___tile_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_0___tile_data_num__q3;
  wire [31:0] compute_0___tile_num_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___tile_num_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___tile_num_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___tile_num_dim_0__q3;
  wire compute_0__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg compute_0__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg compute_0__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg compute_0__ap_rst_n__q3;
  wire compute_0__is_done__q0;
  (* dont_touch = "yes" *)
  reg compute_0__is_done__q1;
  (* dont_touch = "yes" *)
  reg compute_0__is_done__q2;
  (* dont_touch = "yes" *)
  reg compute_0__is_done__q3;
  wire compute_0__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg compute_0__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg compute_0__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg compute_0__ap_start_global__q3;
  wire compute_0__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg compute_0__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg compute_0__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg compute_0__ap_done_global__q3;
  wire compute_0__ap_start;
  reg [1:0] compute_0__state;
  wire compute_0__ap_done;
  wire compute_0__ap_idle;
  wire compute_0__ap_ready;
  wire [63:0] compute_1___coalesced_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_1___coalesced_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_1___coalesced_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_1___coalesced_data_num__q3;
  wire [31:0] compute_1___input_size_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___input_size_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___input_size_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___input_size_dim_0__q3;
  wire [31:0] compute_1___input_size_dim_1__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___input_size_dim_1__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___input_size_dim_1__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___input_size_dim_1__q3;
  wire [63:0] compute_1___tile_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_1___tile_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_1___tile_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_1___tile_data_num__q3;
  wire [31:0] compute_1___tile_num_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___tile_num_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___tile_num_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___tile_num_dim_0__q3;
  wire compute_1__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg compute_1__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg compute_1__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg compute_1__ap_rst_n__q3;
  wire compute_1__is_done__q0;
  (* dont_touch = "yes" *)
  reg compute_1__is_done__q1;
  (* dont_touch = "yes" *)
  reg compute_1__is_done__q2;
  (* dont_touch = "yes" *)
  reg compute_1__is_done__q3;
  wire compute_1__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg compute_1__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg compute_1__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg compute_1__ap_start_global__q3;
  wire compute_1__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg compute_1__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg compute_1__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg compute_1__ap_done_global__q3;
  wire compute_1__ap_start;
  reg [1:0] compute_1__state;
  wire compute_1__ap_done;
  wire compute_1__ap_idle;
  wire compute_1__ap_ready;
  wire [63:0] compute_2___coalesced_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_2___coalesced_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_2___coalesced_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_2___coalesced_data_num__q3;
  wire [31:0] compute_2___input_size_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___input_size_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___input_size_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___input_size_dim_0__q3;
  wire [31:0] compute_2___input_size_dim_1__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___input_size_dim_1__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___input_size_dim_1__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___input_size_dim_1__q3;
  wire [63:0] compute_2___tile_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_2___tile_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_2___tile_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_2___tile_data_num__q3;
  wire [31:0] compute_2___tile_num_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___tile_num_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___tile_num_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___tile_num_dim_0__q3;
  wire compute_2__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg compute_2__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg compute_2__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg compute_2__ap_rst_n__q3;
  wire compute_2__is_done__q0;
  (* dont_touch = "yes" *)
  reg compute_2__is_done__q1;
  (* dont_touch = "yes" *)
  reg compute_2__is_done__q2;
  (* dont_touch = "yes" *)
  reg compute_2__is_done__q3;
  wire compute_2__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg compute_2__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg compute_2__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg compute_2__ap_start_global__q3;
  wire compute_2__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg compute_2__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg compute_2__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg compute_2__ap_done_global__q3;
  wire compute_2__ap_start;
  reg [1:0] compute_2__state;
  wire compute_2__ap_done;
  wire compute_2__ap_idle;
  wire compute_2__ap_ready;
  wire [63:0] compute_3___coalesced_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_3___coalesced_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_3___coalesced_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_3___coalesced_data_num__q3;
  wire [31:0] compute_3___input_size_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___input_size_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___input_size_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___input_size_dim_0__q3;
  wire [31:0] compute_3___input_size_dim_1__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___input_size_dim_1__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___input_size_dim_1__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___input_size_dim_1__q3;
  wire [63:0] compute_3___tile_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_3___tile_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_3___tile_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_3___tile_data_num__q3;
  wire [31:0] compute_3___tile_num_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___tile_num_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___tile_num_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___tile_num_dim_0__q3;
  wire compute_3__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg compute_3__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg compute_3__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg compute_3__ap_rst_n__q3;
  wire compute_3__is_done__q0;
  (* dont_touch = "yes" *)
  reg compute_3__is_done__q1;
  (* dont_touch = "yes" *)
  reg compute_3__is_done__q2;
  (* dont_touch = "yes" *)
  reg compute_3__is_done__q3;
  wire compute_3__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg compute_3__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg compute_3__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg compute_3__ap_start_global__q3;
  wire compute_3__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg compute_3__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg compute_3__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg compute_3__ap_done_global__q3;
  wire compute_3__ap_start;
  reg [1:0] compute_3__state;
  wire compute_3__ap_done;
  wire compute_3__ap_idle;
  wire compute_3__ap_ready;
  wire [63:0] compute_4___coalesced_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_4___coalesced_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_4___coalesced_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_4___coalesced_data_num__q3;
  wire [31:0] compute_4___input_size_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___input_size_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___input_size_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___input_size_dim_0__q3;
  wire [31:0] compute_4___input_size_dim_1__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___input_size_dim_1__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___input_size_dim_1__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___input_size_dim_1__q3;
  wire [63:0] compute_4___tile_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_4___tile_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_4___tile_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_4___tile_data_num__q3;
  wire [31:0] compute_4___tile_num_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___tile_num_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___tile_num_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___tile_num_dim_0__q3;
  wire compute_4__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg compute_4__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg compute_4__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg compute_4__ap_rst_n__q3;
  wire compute_4__is_done__q0;
  (* dont_touch = "yes" *)
  reg compute_4__is_done__q1;
  (* dont_touch = "yes" *)
  reg compute_4__is_done__q2;
  (* dont_touch = "yes" *)
  reg compute_4__is_done__q3;
  wire compute_4__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg compute_4__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg compute_4__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg compute_4__ap_start_global__q3;
  wire compute_4__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg compute_4__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg compute_4__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg compute_4__ap_done_global__q3;
  wire compute_4__ap_start;
  reg [1:0] compute_4__state;
  wire compute_4__ap_done;
  wire compute_4__ap_idle;
  wire compute_4__ap_ready;
  wire [63:0] compute_5___coalesced_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_5___coalesced_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_5___coalesced_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_5___coalesced_data_num__q3;
  wire [31:0] compute_5___input_size_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___input_size_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___input_size_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___input_size_dim_0__q3;
  wire [31:0] compute_5___input_size_dim_1__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___input_size_dim_1__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___input_size_dim_1__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___input_size_dim_1__q3;
  wire [63:0] compute_5___tile_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_5___tile_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_5___tile_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_5___tile_data_num__q3;
  wire [31:0] compute_5___tile_num_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___tile_num_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___tile_num_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___tile_num_dim_0__q3;
  wire compute_5__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg compute_5__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg compute_5__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg compute_5__ap_rst_n__q3;
  wire compute_5__is_done__q0;
  (* dont_touch = "yes" *)
  reg compute_5__is_done__q1;
  (* dont_touch = "yes" *)
  reg compute_5__is_done__q2;
  (* dont_touch = "yes" *)
  reg compute_5__is_done__q3;
  wire compute_5__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg compute_5__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg compute_5__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg compute_5__ap_start_global__q3;
  wire compute_5__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg compute_5__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg compute_5__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg compute_5__ap_done_global__q3;
  wire compute_5__ap_start;
  reg [1:0] compute_5__state;
  wire compute_5__ap_done;
  wire compute_5__ap_idle;
  wire compute_5__ap_ready;
  wire [63:0] load_0___coalesced_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] load_0___coalesced_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] load_0___coalesced_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] load_0___coalesced_data_num__q3;
  wire [63:0] var_input_0_0__q0;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_0__q1;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_0__q2;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_0__q3;
  wire load_0__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg load_0__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg load_0__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg load_0__ap_rst_n__q3;
  wire load_0__is_done__q0;
  (* dont_touch = "yes" *)
  reg load_0__is_done__q1;
  (* dont_touch = "yes" *)
  reg load_0__is_done__q2;
  (* dont_touch = "yes" *)
  reg load_0__is_done__q3;
  wire load_0__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg load_0__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg load_0__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg load_0__ap_start_global__q3;
  wire load_0__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg load_0__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg load_0__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg load_0__ap_done_global__q3;
  wire load_0__ap_start;
  reg [1:0] load_0__state;
  wire load_0__ap_done;
  wire load_0__ap_idle;
  wire load_0__ap_ready;
  wire [63:0] store_0___coalesced_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] store_0___coalesced_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] store_0___coalesced_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] store_0___coalesced_data_num__q3;
  wire [63:0] var_output_0_0__q0;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_0__q1;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_0__q2;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_0__q3;
  wire store_0__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg store_0__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg store_0__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg store_0__ap_rst_n__q3;
  wire store_0__is_done__q0;
  (* dont_touch = "yes" *)
  reg store_0__is_done__q1;
  (* dont_touch = "yes" *)
  reg store_0__is_done__q2;
  (* dont_touch = "yes" *)
  reg store_0__is_done__q3;
  wire store_0__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg store_0__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg store_0__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg store_0__ap_start_global__q3;
  wire store_0__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg store_0__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg store_0__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg store_0__ap_done_global__q3;
  wire store_0__ap_start;
  reg [1:0] store_0__state;
  wire store_0__ap_done;
  wire store_0__ap_idle;
  wire store_0__ap_ready;
  reg [1:0] tlp_state;
  reg [1:0] countdown;
  wire ap_start__q0;
  (* dont_touch = "yes" *)
  reg ap_start__q1;
  (* dont_touch = "yes" *)
  reg ap_start__q2;
  (* dont_touch = "yes" *)
  reg ap_start__q3;
  wire ap_done__q0;
  (* dont_touch = "yes" *)
  reg ap_done__q1;
  (* dont_touch = "yes" *)
  reg ap_done__q2;
  (* dont_touch = "yes" *)
  reg ap_done__q3;

  jacobi2d_kernel_jacobi2d_kernel_control_s_axi
  #(
    .C_S_AXI_ADDR_WIDTH(C_S_AXI_CONTROL_ADDR_WIDTH),
    .C_S_AXI_DATA_WIDTH(C_S_AXI_CONTROL_DATA_WIDTH)
  )
  jacobi2d_kernel_control_s_axi_U
  (
    .AWVALID(s_axi_control_AWVALID),
    .AWREADY(s_axi_control_AWREADY),
    .AWADDR(s_axi_control_AWADDR),
    .WVALID(s_axi_control_WVALID),
    .WREADY(s_axi_control_WREADY),
    .WDATA(s_axi_control_WDATA),
    .WSTRB(s_axi_control_WSTRB),
    .ARVALID(s_axi_control_ARVALID),
    .ARREADY(s_axi_control_ARREADY),
    .ARADDR(s_axi_control_ARADDR),
    .RVALID(s_axi_control_RVALID),
    .RREADY(s_axi_control_RREADY),
    .RDATA(s_axi_control_RDATA),
    .RRESP(s_axi_control_RRESP),
    .BVALID(s_axi_control_BVALID),
    .BREADY(s_axi_control_BREADY),
    .BRESP(s_axi_control_BRESP),
    .ACLK(ap_clk),
    .ARESET(ap_rst_n_inv),
    .ACLK_EN(1'b1),
    .ap_start(ap_start),
    .interrupt(interrupt),
    .ap_ready(ap_ready),
    .ap_done(ap_done),
    .ap_idle(ap_idle),
    .var_output_0_0(var_output_0_0),
    .var_input_0_0(var_input_0_0),
    .coalesced_data_num(coalesced_data_num),
    .tile_data_num(tile_data_num),
    .tile_num_dim_0(tile_num_dim_0),
    .input_size_dim_0(input_size_dim_0),
    .input_size_dim_1(input_size_dim_1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  input_stream_0_0
  (
    .clk(ap_clk),
    .reset(input_stream_0_0__rst__q3),
    .if_dout(input_stream_0_0__dout),
    .if_empty_n(input_stream_0_0__empty_n),
    .if_read(input_stream_0_0__read),
    .if_read_ce(1'b1),
    .if_din(input_stream_0_0__din),
    .if_full_n(input_stream_0_0__full_n),
    .if_write(input_stream_0_0__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  input_stream_0_1
  (
    .clk(ap_clk),
    .reset(input_stream_0_1__rst__q3),
    .if_dout(input_stream_0_1__dout),
    .if_empty_n(input_stream_0_1__empty_n),
    .if_read(input_stream_0_1__read),
    .if_read_ce(1'b1),
    .if_din(input_stream_0_1__din),
    .if_full_n(input_stream_0_1__full_n),
    .if_write(input_stream_0_1__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  input_stream_0_2
  (
    .clk(ap_clk),
    .reset(input_stream_0_2__rst__q3),
    .if_dout(input_stream_0_2__dout),
    .if_empty_n(input_stream_0_2__empty_n),
    .if_read(input_stream_0_2__read),
    .if_read_ce(1'b1),
    .if_din(input_stream_0_2__din),
    .if_full_n(input_stream_0_2__full_n),
    .if_write(input_stream_0_2__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  input_stream_0_3
  (
    .clk(ap_clk),
    .reset(input_stream_0_3__rst__q3),
    .if_dout(input_stream_0_3__dout),
    .if_empty_n(input_stream_0_3__empty_n),
    .if_read(input_stream_0_3__read),
    .if_read_ce(1'b1),
    .if_din(input_stream_0_3__din),
    .if_full_n(input_stream_0_3__full_n),
    .if_write(input_stream_0_3__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_0_0
  (
    .clk(ap_clk),
    .reset(output_stream_0_0__rst__q3),
    .if_dout(output_stream_0_0__dout),
    .if_empty_n(output_stream_0_0__empty_n),
    .if_read(output_stream_0_0__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_0_0__din),
    .if_full_n(output_stream_0_0__full_n),
    .if_write(output_stream_0_0__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_0_1
  (
    .clk(ap_clk),
    .reset(output_stream_0_1__rst__q3),
    .if_dout(output_stream_0_1__dout),
    .if_empty_n(output_stream_0_1__empty_n),
    .if_read(output_stream_0_1__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_0_1__din),
    .if_full_n(output_stream_0_1__full_n),
    .if_write(output_stream_0_1__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_0_2
  (
    .clk(ap_clk),
    .reset(output_stream_0_2__rst__q3),
    .if_dout(output_stream_0_2__dout),
    .if_empty_n(output_stream_0_2__empty_n),
    .if_read(output_stream_0_2__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_0_2__din),
    .if_full_n(output_stream_0_2__full_n),
    .if_write(output_stream_0_2__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_0_3
  (
    .clk(ap_clk),
    .reset(output_stream_0_3__rst__q3),
    .if_dout(output_stream_0_3__dout),
    .if_empty_n(output_stream_0_3__empty_n),
    .if_read(output_stream_0_3__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_0_3__din),
    .if_full_n(output_stream_0_3__full_n),
    .if_write(output_stream_0_3__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_1_0
  (
    .clk(ap_clk),
    .reset(output_stream_1_0__rst__q3),
    .if_dout(output_stream_1_0__dout),
    .if_empty_n(output_stream_1_0__empty_n),
    .if_read(output_stream_1_0__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_1_0__din),
    .if_full_n(output_stream_1_0__full_n),
    .if_write(output_stream_1_0__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_1_1
  (
    .clk(ap_clk),
    .reset(output_stream_1_1__rst__q3),
    .if_dout(output_stream_1_1__dout),
    .if_empty_n(output_stream_1_1__empty_n),
    .if_read(output_stream_1_1__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_1_1__din),
    .if_full_n(output_stream_1_1__full_n),
    .if_write(output_stream_1_1__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_1_2
  (
    .clk(ap_clk),
    .reset(output_stream_1_2__rst__q3),
    .if_dout(output_stream_1_2__dout),
    .if_empty_n(output_stream_1_2__empty_n),
    .if_read(output_stream_1_2__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_1_2__din),
    .if_full_n(output_stream_1_2__full_n),
    .if_write(output_stream_1_2__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_1_3
  (
    .clk(ap_clk),
    .reset(output_stream_1_3__rst__q3),
    .if_dout(output_stream_1_3__dout),
    .if_empty_n(output_stream_1_3__empty_n),
    .if_read(output_stream_1_3__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_1_3__din),
    .if_full_n(output_stream_1_3__full_n),
    .if_write(output_stream_1_3__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_2_0
  (
    .clk(ap_clk),
    .reset(output_stream_2_0__rst__q3),
    .if_dout(output_stream_2_0__dout),
    .if_empty_n(output_stream_2_0__empty_n),
    .if_read(output_stream_2_0__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_2_0__din),
    .if_full_n(output_stream_2_0__full_n),
    .if_write(output_stream_2_0__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_2_1
  (
    .clk(ap_clk),
    .reset(output_stream_2_1__rst__q3),
    .if_dout(output_stream_2_1__dout),
    .if_empty_n(output_stream_2_1__empty_n),
    .if_read(output_stream_2_1__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_2_1__din),
    .if_full_n(output_stream_2_1__full_n),
    .if_write(output_stream_2_1__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_2_2
  (
    .clk(ap_clk),
    .reset(output_stream_2_2__rst__q3),
    .if_dout(output_stream_2_2__dout),
    .if_empty_n(output_stream_2_2__empty_n),
    .if_read(output_stream_2_2__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_2_2__din),
    .if_full_n(output_stream_2_2__full_n),
    .if_write(output_stream_2_2__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_2_3
  (
    .clk(ap_clk),
    .reset(output_stream_2_3__rst__q3),
    .if_dout(output_stream_2_3__dout),
    .if_empty_n(output_stream_2_3__empty_n),
    .if_read(output_stream_2_3__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_2_3__din),
    .if_full_n(output_stream_2_3__full_n),
    .if_write(output_stream_2_3__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_3_0
  (
    .clk(ap_clk),
    .reset(output_stream_3_0__rst__q3),
    .if_dout(output_stream_3_0__dout),
    .if_empty_n(output_stream_3_0__empty_n),
    .if_read(output_stream_3_0__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_3_0__din),
    .if_full_n(output_stream_3_0__full_n),
    .if_write(output_stream_3_0__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_3_1
  (
    .clk(ap_clk),
    .reset(output_stream_3_1__rst__q3),
    .if_dout(output_stream_3_1__dout),
    .if_empty_n(output_stream_3_1__empty_n),
    .if_read(output_stream_3_1__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_3_1__din),
    .if_full_n(output_stream_3_1__full_n),
    .if_write(output_stream_3_1__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_3_2
  (
    .clk(ap_clk),
    .reset(output_stream_3_2__rst__q3),
    .if_dout(output_stream_3_2__dout),
    .if_empty_n(output_stream_3_2__empty_n),
    .if_read(output_stream_3_2__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_3_2__din),
    .if_full_n(output_stream_3_2__full_n),
    .if_write(output_stream_3_2__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_3_3
  (
    .clk(ap_clk),
    .reset(output_stream_3_3__rst__q3),
    .if_dout(output_stream_3_3__dout),
    .if_empty_n(output_stream_3_3__empty_n),
    .if_read(output_stream_3_3__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_3_3__din),
    .if_full_n(output_stream_3_3__full_n),
    .if_write(output_stream_3_3__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_4_0
  (
    .clk(ap_clk),
    .reset(output_stream_4_0__rst__q3),
    .if_dout(output_stream_4_0__dout),
    .if_empty_n(output_stream_4_0__empty_n),
    .if_read(output_stream_4_0__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_4_0__din),
    .if_full_n(output_stream_4_0__full_n),
    .if_write(output_stream_4_0__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_4_1
  (
    .clk(ap_clk),
    .reset(output_stream_4_1__rst__q3),
    .if_dout(output_stream_4_1__dout),
    .if_empty_n(output_stream_4_1__empty_n),
    .if_read(output_stream_4_1__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_4_1__din),
    .if_full_n(output_stream_4_1__full_n),
    .if_write(output_stream_4_1__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_4_2
  (
    .clk(ap_clk),
    .reset(output_stream_4_2__rst__q3),
    .if_dout(output_stream_4_2__dout),
    .if_empty_n(output_stream_4_2__empty_n),
    .if_read(output_stream_4_2__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_4_2__din),
    .if_full_n(output_stream_4_2__full_n),
    .if_write(output_stream_4_2__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_4_3
  (
    .clk(ap_clk),
    .reset(output_stream_4_3__rst__q3),
    .if_dout(output_stream_4_3__dout),
    .if_empty_n(output_stream_4_3__empty_n),
    .if_read(output_stream_4_3__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_4_3__din),
    .if_full_n(output_stream_4_3__full_n),
    .if_write(output_stream_4_3__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_5_0
  (
    .clk(ap_clk),
    .reset(output_stream_5_0__rst__q3),
    .if_dout(output_stream_5_0__dout),
    .if_empty_n(output_stream_5_0__empty_n),
    .if_read(output_stream_5_0__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_5_0__din),
    .if_full_n(output_stream_5_0__full_n),
    .if_write(output_stream_5_0__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_5_1
  (
    .clk(ap_clk),
    .reset(output_stream_5_1__rst__q3),
    .if_dout(output_stream_5_1__dout),
    .if_empty_n(output_stream_5_1__empty_n),
    .if_read(output_stream_5_1__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_5_1__din),
    .if_full_n(output_stream_5_1__full_n),
    .if_write(output_stream_5_1__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_5_2
  (
    .clk(ap_clk),
    .reset(output_stream_5_2__rst__q3),
    .if_dout(output_stream_5_2__dout),
    .if_empty_n(output_stream_5_2__empty_n),
    .if_read(output_stream_5_2__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_5_2__din),
    .if_full_n(output_stream_5_2__full_n),
    .if_write(output_stream_5_2__write),
    .if_write_ce(1'b1)
  );


  fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_5_3
  (
    .clk(ap_clk),
    .reset(output_stream_5_3__rst__q3),
    .if_dout(output_stream_5_3__dout),
    .if_empty_n(output_stream_5_3__empty_n),
    .if_read(output_stream_5_3__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_5_3__din),
    .if_full_n(output_stream_5_3__full_n),
    .if_write(output_stream_5_3__write),
    .if_write_ce(1'b1)
  );


  compute_compute
  compute_0
  (
    .ap_clk(ap_clk),
    .ap_rst_n(compute_0__ap_rst_n__q3),
    .ap_start(compute_0__ap_start),
    .ap_done(compute_0__ap_done),
    .ap_idle(compute_0__ap_idle),
    .ap_ready(compute_0__ap_ready),
    .coalesced_data_num(compute_0___coalesced_data_num__q3),
    .input_size_dim_0(compute_0___input_size_dim_0__q3),
    .input_size_dim_1(compute_0___input_size_dim_1__q3),
    .from_chan_0_bank_0_fifo_V_dout(input_stream_0_0__dout),
    .from_chan_0_bank_0_fifo_V_empty_n(input_stream_0_0__empty_n),
    .from_chan_0_bank_0_fifo_V_read(input_stream_0_0__read),
    .from_chan_0_bank_0_peek_val(input_stream_0_0__dout),
    .from_chan_0_bank_1_fifo_V_dout(input_stream_0_1__dout),
    .from_chan_0_bank_1_fifo_V_empty_n(input_stream_0_1__empty_n),
    .from_chan_0_bank_1_fifo_V_read(input_stream_0_1__read),
    .from_chan_0_bank_1_peek_val(input_stream_0_1__dout),
    .from_chan_0_bank_2_fifo_V_dout(input_stream_0_2__dout),
    .from_chan_0_bank_2_fifo_V_empty_n(input_stream_0_2__empty_n),
    .from_chan_0_bank_2_fifo_V_read(input_stream_0_2__read),
    .from_chan_0_bank_2_peek_val(input_stream_0_2__dout),
    .from_chan_0_bank_3_fifo_V_dout(input_stream_0_3__dout),
    .from_chan_0_bank_3_fifo_V_empty_n(input_stream_0_3__empty_n),
    .from_chan_0_bank_3_fifo_V_read(input_stream_0_3__read),
    .from_chan_0_bank_3_peek_val(input_stream_0_3__dout),
    .to_chan_0_bank_0_fifo_V_din(output_stream_0_0__din),
    .to_chan_0_bank_0_fifo_V_full_n(output_stream_0_0__full_n),
    .to_chan_0_bank_0_fifo_V_write(output_stream_0_0__write),
    .to_chan_0_bank_1_fifo_V_din(output_stream_0_1__din),
    .to_chan_0_bank_1_fifo_V_full_n(output_stream_0_1__full_n),
    .to_chan_0_bank_1_fifo_V_write(output_stream_0_1__write),
    .to_chan_0_bank_2_fifo_V_din(output_stream_0_2__din),
    .to_chan_0_bank_2_fifo_V_full_n(output_stream_0_2__full_n),
    .to_chan_0_bank_2_fifo_V_write(output_stream_0_2__write),
    .to_chan_0_bank_3_fifo_V_din(output_stream_0_3__din),
    .to_chan_0_bank_3_fifo_V_full_n(output_stream_0_3__full_n),
    .to_chan_0_bank_3_fifo_V_write(output_stream_0_3__write),
    .tile_data_num(compute_0___tile_data_num__q3),
    .tile_num_dim_0(compute_0___tile_num_dim_0__q3)
  );


  compute_compute
  compute_1
  (
    .ap_clk(ap_clk),
    .ap_rst_n(compute_1__ap_rst_n__q3),
    .ap_start(compute_1__ap_start),
    .ap_done(compute_1__ap_done),
    .ap_idle(compute_1__ap_idle),
    .ap_ready(compute_1__ap_ready),
    .coalesced_data_num(compute_1___coalesced_data_num__q3),
    .input_size_dim_0(compute_1___input_size_dim_0__q3),
    .input_size_dim_1(compute_1___input_size_dim_1__q3),
    .from_chan_0_bank_0_fifo_V_dout(output_stream_0_0__dout),
    .from_chan_0_bank_0_fifo_V_empty_n(output_stream_0_0__empty_n),
    .from_chan_0_bank_0_fifo_V_read(output_stream_0_0__read),
    .from_chan_0_bank_0_peek_val(output_stream_0_0__dout),
    .from_chan_0_bank_1_fifo_V_dout(output_stream_0_1__dout),
    .from_chan_0_bank_1_fifo_V_empty_n(output_stream_0_1__empty_n),
    .from_chan_0_bank_1_fifo_V_read(output_stream_0_1__read),
    .from_chan_0_bank_1_peek_val(output_stream_0_1__dout),
    .from_chan_0_bank_2_fifo_V_dout(output_stream_0_2__dout),
    .from_chan_0_bank_2_fifo_V_empty_n(output_stream_0_2__empty_n),
    .from_chan_0_bank_2_fifo_V_read(output_stream_0_2__read),
    .from_chan_0_bank_2_peek_val(output_stream_0_2__dout),
    .from_chan_0_bank_3_fifo_V_dout(output_stream_0_3__dout),
    .from_chan_0_bank_3_fifo_V_empty_n(output_stream_0_3__empty_n),
    .from_chan_0_bank_3_fifo_V_read(output_stream_0_3__read),
    .from_chan_0_bank_3_peek_val(output_stream_0_3__dout),
    .to_chan_0_bank_0_fifo_V_din(output_stream_1_0__din),
    .to_chan_0_bank_0_fifo_V_full_n(output_stream_1_0__full_n),
    .to_chan_0_bank_0_fifo_V_write(output_stream_1_0__write),
    .to_chan_0_bank_1_fifo_V_din(output_stream_1_1__din),
    .to_chan_0_bank_1_fifo_V_full_n(output_stream_1_1__full_n),
    .to_chan_0_bank_1_fifo_V_write(output_stream_1_1__write),
    .to_chan_0_bank_2_fifo_V_din(output_stream_1_2__din),
    .to_chan_0_bank_2_fifo_V_full_n(output_stream_1_2__full_n),
    .to_chan_0_bank_2_fifo_V_write(output_stream_1_2__write),
    .to_chan_0_bank_3_fifo_V_din(output_stream_1_3__din),
    .to_chan_0_bank_3_fifo_V_full_n(output_stream_1_3__full_n),
    .to_chan_0_bank_3_fifo_V_write(output_stream_1_3__write),
    .tile_data_num(compute_1___tile_data_num__q3),
    .tile_num_dim_0(compute_1___tile_num_dim_0__q3)
  );


  compute_compute
  compute_2
  (
    .ap_clk(ap_clk),
    .ap_rst_n(compute_2__ap_rst_n__q3),
    .ap_start(compute_2__ap_start),
    .ap_done(compute_2__ap_done),
    .ap_idle(compute_2__ap_idle),
    .ap_ready(compute_2__ap_ready),
    .coalesced_data_num(compute_2___coalesced_data_num__q3),
    .input_size_dim_0(compute_2___input_size_dim_0__q3),
    .input_size_dim_1(compute_2___input_size_dim_1__q3),
    .from_chan_0_bank_0_fifo_V_dout(output_stream_1_0__dout),
    .from_chan_0_bank_0_fifo_V_empty_n(output_stream_1_0__empty_n),
    .from_chan_0_bank_0_fifo_V_read(output_stream_1_0__read),
    .from_chan_0_bank_0_peek_val(output_stream_1_0__dout),
    .from_chan_0_bank_1_fifo_V_dout(output_stream_1_1__dout),
    .from_chan_0_bank_1_fifo_V_empty_n(output_stream_1_1__empty_n),
    .from_chan_0_bank_1_fifo_V_read(output_stream_1_1__read),
    .from_chan_0_bank_1_peek_val(output_stream_1_1__dout),
    .from_chan_0_bank_2_fifo_V_dout(output_stream_1_2__dout),
    .from_chan_0_bank_2_fifo_V_empty_n(output_stream_1_2__empty_n),
    .from_chan_0_bank_2_fifo_V_read(output_stream_1_2__read),
    .from_chan_0_bank_2_peek_val(output_stream_1_2__dout),
    .from_chan_0_bank_3_fifo_V_dout(output_stream_1_3__dout),
    .from_chan_0_bank_3_fifo_V_empty_n(output_stream_1_3__empty_n),
    .from_chan_0_bank_3_fifo_V_read(output_stream_1_3__read),
    .from_chan_0_bank_3_peek_val(output_stream_1_3__dout),
    .to_chan_0_bank_0_fifo_V_din(output_stream_2_0__din),
    .to_chan_0_bank_0_fifo_V_full_n(output_stream_2_0__full_n),
    .to_chan_0_bank_0_fifo_V_write(output_stream_2_0__write),
    .to_chan_0_bank_1_fifo_V_din(output_stream_2_1__din),
    .to_chan_0_bank_1_fifo_V_full_n(output_stream_2_1__full_n),
    .to_chan_0_bank_1_fifo_V_write(output_stream_2_1__write),
    .to_chan_0_bank_2_fifo_V_din(output_stream_2_2__din),
    .to_chan_0_bank_2_fifo_V_full_n(output_stream_2_2__full_n),
    .to_chan_0_bank_2_fifo_V_write(output_stream_2_2__write),
    .to_chan_0_bank_3_fifo_V_din(output_stream_2_3__din),
    .to_chan_0_bank_3_fifo_V_full_n(output_stream_2_3__full_n),
    .to_chan_0_bank_3_fifo_V_write(output_stream_2_3__write),
    .tile_data_num(compute_2___tile_data_num__q3),
    .tile_num_dim_0(compute_2___tile_num_dim_0__q3)
  );


  compute_compute
  compute_3
  (
    .ap_clk(ap_clk),
    .ap_rst_n(compute_3__ap_rst_n__q3),
    .ap_start(compute_3__ap_start),
    .ap_done(compute_3__ap_done),
    .ap_idle(compute_3__ap_idle),
    .ap_ready(compute_3__ap_ready),
    .coalesced_data_num(compute_3___coalesced_data_num__q3),
    .input_size_dim_0(compute_3___input_size_dim_0__q3),
    .input_size_dim_1(compute_3___input_size_dim_1__q3),
    .from_chan_0_bank_0_fifo_V_dout(output_stream_2_0__dout),
    .from_chan_0_bank_0_fifo_V_empty_n(output_stream_2_0__empty_n),
    .from_chan_0_bank_0_fifo_V_read(output_stream_2_0__read),
    .from_chan_0_bank_0_peek_val(output_stream_2_0__dout),
    .from_chan_0_bank_1_fifo_V_dout(output_stream_2_1__dout),
    .from_chan_0_bank_1_fifo_V_empty_n(output_stream_2_1__empty_n),
    .from_chan_0_bank_1_fifo_V_read(output_stream_2_1__read),
    .from_chan_0_bank_1_peek_val(output_stream_2_1__dout),
    .from_chan_0_bank_2_fifo_V_dout(output_stream_2_2__dout),
    .from_chan_0_bank_2_fifo_V_empty_n(output_stream_2_2__empty_n),
    .from_chan_0_bank_2_fifo_V_read(output_stream_2_2__read),
    .from_chan_0_bank_2_peek_val(output_stream_2_2__dout),
    .from_chan_0_bank_3_fifo_V_dout(output_stream_2_3__dout),
    .from_chan_0_bank_3_fifo_V_empty_n(output_stream_2_3__empty_n),
    .from_chan_0_bank_3_fifo_V_read(output_stream_2_3__read),
    .from_chan_0_bank_3_peek_val(output_stream_2_3__dout),
    .to_chan_0_bank_0_fifo_V_din(output_stream_3_0__din),
    .to_chan_0_bank_0_fifo_V_full_n(output_stream_3_0__full_n),
    .to_chan_0_bank_0_fifo_V_write(output_stream_3_0__write),
    .to_chan_0_bank_1_fifo_V_din(output_stream_3_1__din),
    .to_chan_0_bank_1_fifo_V_full_n(output_stream_3_1__full_n),
    .to_chan_0_bank_1_fifo_V_write(output_stream_3_1__write),
    .to_chan_0_bank_2_fifo_V_din(output_stream_3_2__din),
    .to_chan_0_bank_2_fifo_V_full_n(output_stream_3_2__full_n),
    .to_chan_0_bank_2_fifo_V_write(output_stream_3_2__write),
    .to_chan_0_bank_3_fifo_V_din(output_stream_3_3__din),
    .to_chan_0_bank_3_fifo_V_full_n(output_stream_3_3__full_n),
    .to_chan_0_bank_3_fifo_V_write(output_stream_3_3__write),
    .tile_data_num(compute_3___tile_data_num__q3),
    .tile_num_dim_0(compute_3___tile_num_dim_0__q3)
  );


  compute_compute
  compute_4
  (
    .ap_clk(ap_clk),
    .ap_rst_n(compute_4__ap_rst_n__q3),
    .ap_start(compute_4__ap_start),
    .ap_done(compute_4__ap_done),
    .ap_idle(compute_4__ap_idle),
    .ap_ready(compute_4__ap_ready),
    .coalesced_data_num(compute_4___coalesced_data_num__q3),
    .input_size_dim_0(compute_4___input_size_dim_0__q3),
    .input_size_dim_1(compute_4___input_size_dim_1__q3),
    .from_chan_0_bank_0_fifo_V_dout(output_stream_3_0__dout),
    .from_chan_0_bank_0_fifo_V_empty_n(output_stream_3_0__empty_n),
    .from_chan_0_bank_0_fifo_V_read(output_stream_3_0__read),
    .from_chan_0_bank_0_peek_val(output_stream_3_0__dout),
    .from_chan_0_bank_1_fifo_V_dout(output_stream_3_1__dout),
    .from_chan_0_bank_1_fifo_V_empty_n(output_stream_3_1__empty_n),
    .from_chan_0_bank_1_fifo_V_read(output_stream_3_1__read),
    .from_chan_0_bank_1_peek_val(output_stream_3_1__dout),
    .from_chan_0_bank_2_fifo_V_dout(output_stream_3_2__dout),
    .from_chan_0_bank_2_fifo_V_empty_n(output_stream_3_2__empty_n),
    .from_chan_0_bank_2_fifo_V_read(output_stream_3_2__read),
    .from_chan_0_bank_2_peek_val(output_stream_3_2__dout),
    .from_chan_0_bank_3_fifo_V_dout(output_stream_3_3__dout),
    .from_chan_0_bank_3_fifo_V_empty_n(output_stream_3_3__empty_n),
    .from_chan_0_bank_3_fifo_V_read(output_stream_3_3__read),
    .from_chan_0_bank_3_peek_val(output_stream_3_3__dout),
    .to_chan_0_bank_0_fifo_V_din(output_stream_4_0__din),
    .to_chan_0_bank_0_fifo_V_full_n(output_stream_4_0__full_n),
    .to_chan_0_bank_0_fifo_V_write(output_stream_4_0__write),
    .to_chan_0_bank_1_fifo_V_din(output_stream_4_1__din),
    .to_chan_0_bank_1_fifo_V_full_n(output_stream_4_1__full_n),
    .to_chan_0_bank_1_fifo_V_write(output_stream_4_1__write),
    .to_chan_0_bank_2_fifo_V_din(output_stream_4_2__din),
    .to_chan_0_bank_2_fifo_V_full_n(output_stream_4_2__full_n),
    .to_chan_0_bank_2_fifo_V_write(output_stream_4_2__write),
    .to_chan_0_bank_3_fifo_V_din(output_stream_4_3__din),
    .to_chan_0_bank_3_fifo_V_full_n(output_stream_4_3__full_n),
    .to_chan_0_bank_3_fifo_V_write(output_stream_4_3__write),
    .tile_data_num(compute_4___tile_data_num__q3),
    .tile_num_dim_0(compute_4___tile_num_dim_0__q3)
  );


  compute_compute
  compute_5
  (
    .ap_clk(ap_clk),
    .ap_rst_n(compute_5__ap_rst_n__q3),
    .ap_start(compute_5__ap_start),
    .ap_done(compute_5__ap_done),
    .ap_idle(compute_5__ap_idle),
    .ap_ready(compute_5__ap_ready),
    .coalesced_data_num(compute_5___coalesced_data_num__q3),
    .input_size_dim_0(compute_5___input_size_dim_0__q3),
    .input_size_dim_1(compute_5___input_size_dim_1__q3),
    .from_chan_0_bank_0_fifo_V_dout(output_stream_4_0__dout),
    .from_chan_0_bank_0_fifo_V_empty_n(output_stream_4_0__empty_n),
    .from_chan_0_bank_0_fifo_V_read(output_stream_4_0__read),
    .from_chan_0_bank_0_peek_val(output_stream_4_0__dout),
    .from_chan_0_bank_1_fifo_V_dout(output_stream_4_1__dout),
    .from_chan_0_bank_1_fifo_V_empty_n(output_stream_4_1__empty_n),
    .from_chan_0_bank_1_fifo_V_read(output_stream_4_1__read),
    .from_chan_0_bank_1_peek_val(output_stream_4_1__dout),
    .from_chan_0_bank_2_fifo_V_dout(output_stream_4_2__dout),
    .from_chan_0_bank_2_fifo_V_empty_n(output_stream_4_2__empty_n),
    .from_chan_0_bank_2_fifo_V_read(output_stream_4_2__read),
    .from_chan_0_bank_2_peek_val(output_stream_4_2__dout),
    .from_chan_0_bank_3_fifo_V_dout(output_stream_4_3__dout),
    .from_chan_0_bank_3_fifo_V_empty_n(output_stream_4_3__empty_n),
    .from_chan_0_bank_3_fifo_V_read(output_stream_4_3__read),
    .from_chan_0_bank_3_peek_val(output_stream_4_3__dout),
    .to_chan_0_bank_0_fifo_V_din(output_stream_5_0__din),
    .to_chan_0_bank_0_fifo_V_full_n(output_stream_5_0__full_n),
    .to_chan_0_bank_0_fifo_V_write(output_stream_5_0__write),
    .to_chan_0_bank_1_fifo_V_din(output_stream_5_1__din),
    .to_chan_0_bank_1_fifo_V_full_n(output_stream_5_1__full_n),
    .to_chan_0_bank_1_fifo_V_write(output_stream_5_1__write),
    .to_chan_0_bank_2_fifo_V_din(output_stream_5_2__din),
    .to_chan_0_bank_2_fifo_V_full_n(output_stream_5_2__full_n),
    .to_chan_0_bank_2_fifo_V_write(output_stream_5_2__write),
    .to_chan_0_bank_3_fifo_V_din(output_stream_5_3__din),
    .to_chan_0_bank_3_fifo_V_full_n(output_stream_5_3__full_n),
    .to_chan_0_bank_3_fifo_V_write(output_stream_5_3__write),
    .tile_data_num(compute_5___tile_data_num__q3),
    .tile_num_dim_0(compute_5___tile_num_dim_0__q3)
  );


  load_load
  load_0
  (
    .ap_clk(ap_clk),
    .ap_rst_n(load_0__ap_rst_n__q3),
    .ap_start(load_0__ap_start),
    .ap_done(load_0__ap_done),
    .ap_idle(load_0__ap_idle),
    .ap_ready(load_0__ap_ready),
    .data_num(load_0___coalesced_data_num__q3),
    .sink_0_fifo_V_din(input_stream_0_0__din),
    .sink_0_fifo_V_full_n(input_stream_0_0__full_n),
    .sink_0_fifo_V_write(input_stream_0_0__write),
    .sink_1_fifo_V_din(input_stream_0_1__din),
    .sink_1_fifo_V_full_n(input_stream_0_1__full_n),
    .sink_1_fifo_V_write(input_stream_0_1__write),
    .sink_2_fifo_V_din(input_stream_0_2__din),
    .sink_2_fifo_V_full_n(input_stream_0_2__full_n),
    .sink_2_fifo_V_write(input_stream_0_2__write),
    .sink_3_fifo_V_din(input_stream_0_3__din),
    .sink_3_fifo_V_full_n(input_stream_0_3__full_n),
    .sink_3_fifo_V_write(input_stream_0_3__write),
    .m_axi_source_ARADDR(m_axi_var_input_0_0_ARADDR),
    .m_axi_source_ARBURST(m_axi_var_input_0_0_ARBURST),
    .m_axi_source_ARCACHE(m_axi_var_input_0_0_ARCACHE),
    .m_axi_source_ARID(m_axi_var_input_0_0_ARID),
    .m_axi_source_ARLEN(m_axi_var_input_0_0_ARLEN),
    .m_axi_source_ARLOCK(m_axi_var_input_0_0_ARLOCK),
    .m_axi_source_ARPROT(m_axi_var_input_0_0_ARPROT),
    .m_axi_source_ARQOS(m_axi_var_input_0_0_ARQOS),
    .m_axi_source_ARREADY(m_axi_var_input_0_0_ARREADY),
    .m_axi_source_ARREGION(m_axi_var_input_0_0_ARREGION),
    .m_axi_source_ARSIZE(m_axi_var_input_0_0_ARSIZE),
    .m_axi_source_ARUSER(m_axi_var_input_0_0_ARUSER),
    .m_axi_source_ARVALID(m_axi_var_input_0_0_ARVALID),
    .m_axi_source_AWADDR(m_axi_var_input_0_0_AWADDR),
    .m_axi_source_AWBURST(m_axi_var_input_0_0_AWBURST),
    .m_axi_source_AWCACHE(m_axi_var_input_0_0_AWCACHE),
    .m_axi_source_AWID(m_axi_var_input_0_0_AWID),
    .m_axi_source_AWLEN(m_axi_var_input_0_0_AWLEN),
    .m_axi_source_AWLOCK(m_axi_var_input_0_0_AWLOCK),
    .m_axi_source_AWPROT(m_axi_var_input_0_0_AWPROT),
    .m_axi_source_AWQOS(m_axi_var_input_0_0_AWQOS),
    .m_axi_source_AWREADY(m_axi_var_input_0_0_AWREADY),
    .m_axi_source_AWREGION(m_axi_var_input_0_0_AWREGION),
    .m_axi_source_AWSIZE(m_axi_var_input_0_0_AWSIZE),
    .m_axi_source_AWUSER(m_axi_var_input_0_0_AWUSER),
    .m_axi_source_AWVALID(m_axi_var_input_0_0_AWVALID),
    .m_axi_source_BID(m_axi_var_input_0_0_BID),
    .m_axi_source_BREADY(m_axi_var_input_0_0_BREADY),
    .m_axi_source_BRESP(m_axi_var_input_0_0_BRESP),
    .m_axi_source_BUSER(m_axi_var_input_0_0_BUSER),
    .m_axi_source_BVALID(m_axi_var_input_0_0_BVALID),
    .m_axi_source_RDATA(m_axi_var_input_0_0_RDATA),
    .m_axi_source_RID(m_axi_var_input_0_0_RID),
    .m_axi_source_RLAST(m_axi_var_input_0_0_RLAST),
    .m_axi_source_RREADY(m_axi_var_input_0_0_RREADY),
    .m_axi_source_RRESP(m_axi_var_input_0_0_RRESP),
    .m_axi_source_RUSER(m_axi_var_input_0_0_RUSER),
    .m_axi_source_RVALID(m_axi_var_input_0_0_RVALID),
    .m_axi_source_WDATA(m_axi_var_input_0_0_WDATA),
    .m_axi_source_WID(m_axi_var_input_0_0_WID),
    .m_axi_source_WLAST(m_axi_var_input_0_0_WLAST),
    .m_axi_source_WREADY(m_axi_var_input_0_0_WREADY),
    .m_axi_source_WSTRB(m_axi_var_input_0_0_WSTRB),
    .m_axi_source_WUSER(m_axi_var_input_0_0_WUSER),
    .m_axi_source_WVALID(m_axi_var_input_0_0_WVALID),
    .source_V(var_input_0_0__q3)
  );


  store_store
  store_0
  (
    .ap_clk(ap_clk),
    .ap_rst_n(store_0__ap_rst_n__q3),
    .ap_start(store_0__ap_start),
    .ap_done(store_0__ap_done),
    .ap_idle(store_0__ap_idle),
    .ap_ready(store_0__ap_ready),
    .data_num(store_0___coalesced_data_num__q3),
    .source_0_fifo_V_dout(output_stream_5_0__dout),
    .source_0_fifo_V_empty_n(output_stream_5_0__empty_n),
    .source_0_fifo_V_read(output_stream_5_0__read),
    .source_0_peek_val(output_stream_5_0__dout),
    .source_1_fifo_V_dout(output_stream_5_1__dout),
    .source_1_fifo_V_empty_n(output_stream_5_1__empty_n),
    .source_1_fifo_V_read(output_stream_5_1__read),
    .source_1_peek_val(output_stream_5_1__dout),
    .source_2_fifo_V_dout(output_stream_5_2__dout),
    .source_2_fifo_V_empty_n(output_stream_5_2__empty_n),
    .source_2_fifo_V_read(output_stream_5_2__read),
    .source_2_peek_val(output_stream_5_2__dout),
    .source_3_fifo_V_dout(output_stream_5_3__dout),
    .source_3_fifo_V_empty_n(output_stream_5_3__empty_n),
    .source_3_fifo_V_read(output_stream_5_3__read),
    .source_3_peek_val(output_stream_5_3__dout),
    .m_axi_sink_ARADDR(m_axi_var_output_0_0_ARADDR),
    .m_axi_sink_ARBURST(m_axi_var_output_0_0_ARBURST),
    .m_axi_sink_ARCACHE(m_axi_var_output_0_0_ARCACHE),
    .m_axi_sink_ARID(m_axi_var_output_0_0_ARID),
    .m_axi_sink_ARLEN(m_axi_var_output_0_0_ARLEN),
    .m_axi_sink_ARLOCK(m_axi_var_output_0_0_ARLOCK),
    .m_axi_sink_ARPROT(m_axi_var_output_0_0_ARPROT),
    .m_axi_sink_ARQOS(m_axi_var_output_0_0_ARQOS),
    .m_axi_sink_ARREADY(m_axi_var_output_0_0_ARREADY),
    .m_axi_sink_ARREGION(m_axi_var_output_0_0_ARREGION),
    .m_axi_sink_ARSIZE(m_axi_var_output_0_0_ARSIZE),
    .m_axi_sink_ARUSER(m_axi_var_output_0_0_ARUSER),
    .m_axi_sink_ARVALID(m_axi_var_output_0_0_ARVALID),
    .m_axi_sink_AWADDR(m_axi_var_output_0_0_AWADDR),
    .m_axi_sink_AWBURST(m_axi_var_output_0_0_AWBURST),
    .m_axi_sink_AWCACHE(m_axi_var_output_0_0_AWCACHE),
    .m_axi_sink_AWID(m_axi_var_output_0_0_AWID),
    .m_axi_sink_AWLEN(m_axi_var_output_0_0_AWLEN),
    .m_axi_sink_AWLOCK(m_axi_var_output_0_0_AWLOCK),
    .m_axi_sink_AWPROT(m_axi_var_output_0_0_AWPROT),
    .m_axi_sink_AWQOS(m_axi_var_output_0_0_AWQOS),
    .m_axi_sink_AWREADY(m_axi_var_output_0_0_AWREADY),
    .m_axi_sink_AWREGION(m_axi_var_output_0_0_AWREGION),
    .m_axi_sink_AWSIZE(m_axi_var_output_0_0_AWSIZE),
    .m_axi_sink_AWUSER(m_axi_var_output_0_0_AWUSER),
    .m_axi_sink_AWVALID(m_axi_var_output_0_0_AWVALID),
    .m_axi_sink_BID(m_axi_var_output_0_0_BID),
    .m_axi_sink_BREADY(m_axi_var_output_0_0_BREADY),
    .m_axi_sink_BRESP(m_axi_var_output_0_0_BRESP),
    .m_axi_sink_BUSER(m_axi_var_output_0_0_BUSER),
    .m_axi_sink_BVALID(m_axi_var_output_0_0_BVALID),
    .m_axi_sink_RDATA(m_axi_var_output_0_0_RDATA),
    .m_axi_sink_RID(m_axi_var_output_0_0_RID),
    .m_axi_sink_RLAST(m_axi_var_output_0_0_RLAST),
    .m_axi_sink_RREADY(m_axi_var_output_0_0_RREADY),
    .m_axi_sink_RRESP(m_axi_var_output_0_0_RRESP),
    .m_axi_sink_RUSER(m_axi_var_output_0_0_RUSER),
    .m_axi_sink_RVALID(m_axi_var_output_0_0_RVALID),
    .m_axi_sink_WDATA(m_axi_var_output_0_0_WDATA),
    .m_axi_sink_WID(m_axi_var_output_0_0_WID),
    .m_axi_sink_WLAST(m_axi_var_output_0_0_WLAST),
    .m_axi_sink_WREADY(m_axi_var_output_0_0_WREADY),
    .m_axi_sink_WSTRB(m_axi_var_output_0_0_WSTRB),
    .m_axi_sink_WUSER(m_axi_var_output_0_0_WUSER),
    .m_axi_sink_WVALID(m_axi_var_output_0_0_WVALID),
    .sink_V(var_output_0_0__q3)
  );


  always @(posedge ap_clk) begin
    ap_rst_n__q1 <= ap_rst_n__q0;
    ap_rst_n__q2 <= ap_rst_n__q1;
    ap_rst_n__q3 <= ap_rst_n__q2;
  end

  assign ap_rst_n__q0 = ap_rst_n;
  assign ap_rst_n_inv = (~ap_rst_n__q3);

  always @(posedge ap_clk) begin
    input_stream_0_0__rst__q1 <= input_stream_0_0__rst__q0;
    input_stream_0_0__rst__q2 <= input_stream_0_0__rst__q1;
    input_stream_0_0__rst__q3 <= input_stream_0_0__rst__q2;
  end

  assign input_stream_0_0__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(input_stream_0_0__read == 1'b1) begin
      $display("DEBUG: R: \033[97m input_stream_0_0\033[0m -> \033[90mcompute_0        \033[0m %h", input_stream_0_0__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(input_stream_0_0__write == 1'b1) begin
      $display("DEBUG: W: \033[90m           load_0\033[0m -> \033[97minput_stream_0_0 \033[0m %h", input_stream_0_0__din);
    end 
  end


  always @(posedge ap_clk) begin
    input_stream_0_1__rst__q1 <= input_stream_0_1__rst__q0;
    input_stream_0_1__rst__q2 <= input_stream_0_1__rst__q1;
    input_stream_0_1__rst__q3 <= input_stream_0_1__rst__q2;
  end

  assign input_stream_0_1__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(input_stream_0_1__read == 1'b1) begin
      $display("DEBUG: R: \033[97m input_stream_0_1\033[0m -> \033[90mcompute_0        \033[0m %h", input_stream_0_1__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(input_stream_0_1__write == 1'b1) begin
      $display("DEBUG: W: \033[90m           load_0\033[0m -> \033[97minput_stream_0_1 \033[0m %h", input_stream_0_1__din);
    end 
  end


  always @(posedge ap_clk) begin
    input_stream_0_2__rst__q1 <= input_stream_0_2__rst__q0;
    input_stream_0_2__rst__q2 <= input_stream_0_2__rst__q1;
    input_stream_0_2__rst__q3 <= input_stream_0_2__rst__q2;
  end

  assign input_stream_0_2__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(input_stream_0_2__read == 1'b1) begin
      $display("DEBUG: R: \033[97m input_stream_0_2\033[0m -> \033[90mcompute_0        \033[0m %h", input_stream_0_2__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(input_stream_0_2__write == 1'b1) begin
      $display("DEBUG: W: \033[90m           load_0\033[0m -> \033[97minput_stream_0_2 \033[0m %h", input_stream_0_2__din);
    end 
  end


  always @(posedge ap_clk) begin
    input_stream_0_3__rst__q1 <= input_stream_0_3__rst__q0;
    input_stream_0_3__rst__q2 <= input_stream_0_3__rst__q1;
    input_stream_0_3__rst__q3 <= input_stream_0_3__rst__q2;
  end

  assign input_stream_0_3__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(input_stream_0_3__read == 1'b1) begin
      $display("DEBUG: R: \033[97m input_stream_0_3\033[0m -> \033[90mcompute_0        \033[0m %h", input_stream_0_3__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(input_stream_0_3__write == 1'b1) begin
      $display("DEBUG: W: \033[90m           load_0\033[0m -> \033[97minput_stream_0_3 \033[0m %h", input_stream_0_3__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_0_0__rst__q1 <= output_stream_0_0__rst__q0;
    output_stream_0_0__rst__q2 <= output_stream_0_0__rst__q1;
    output_stream_0_0__rst__q3 <= output_stream_0_0__rst__q2;
  end

  assign output_stream_0_0__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_0_0__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_0_0\033[0m -> \033[90mcompute_1        \033[0m %h", output_stream_0_0__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_0_0__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_0\033[0m -> \033[97moutput_stream_0_0\033[0m %h", output_stream_0_0__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_0_1__rst__q1 <= output_stream_0_1__rst__q0;
    output_stream_0_1__rst__q2 <= output_stream_0_1__rst__q1;
    output_stream_0_1__rst__q3 <= output_stream_0_1__rst__q2;
  end

  assign output_stream_0_1__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_0_1__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_0_1\033[0m -> \033[90mcompute_1        \033[0m %h", output_stream_0_1__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_0_1__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_0\033[0m -> \033[97moutput_stream_0_1\033[0m %h", output_stream_0_1__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_0_2__rst__q1 <= output_stream_0_2__rst__q0;
    output_stream_0_2__rst__q2 <= output_stream_0_2__rst__q1;
    output_stream_0_2__rst__q3 <= output_stream_0_2__rst__q2;
  end

  assign output_stream_0_2__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_0_2__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_0_2\033[0m -> \033[90mcompute_1        \033[0m %h", output_stream_0_2__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_0_2__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_0\033[0m -> \033[97moutput_stream_0_2\033[0m %h", output_stream_0_2__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_0_3__rst__q1 <= output_stream_0_3__rst__q0;
    output_stream_0_3__rst__q2 <= output_stream_0_3__rst__q1;
    output_stream_0_3__rst__q3 <= output_stream_0_3__rst__q2;
  end

  assign output_stream_0_3__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_0_3__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_0_3\033[0m -> \033[90mcompute_1        \033[0m %h", output_stream_0_3__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_0_3__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_0\033[0m -> \033[97moutput_stream_0_3\033[0m %h", output_stream_0_3__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_1_0__rst__q1 <= output_stream_1_0__rst__q0;
    output_stream_1_0__rst__q2 <= output_stream_1_0__rst__q1;
    output_stream_1_0__rst__q3 <= output_stream_1_0__rst__q2;
  end

  assign output_stream_1_0__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_1_0__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_1_0\033[0m -> \033[90mcompute_2        \033[0m %h", output_stream_1_0__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_1_0__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_1\033[0m -> \033[97moutput_stream_1_0\033[0m %h", output_stream_1_0__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_1_1__rst__q1 <= output_stream_1_1__rst__q0;
    output_stream_1_1__rst__q2 <= output_stream_1_1__rst__q1;
    output_stream_1_1__rst__q3 <= output_stream_1_1__rst__q2;
  end

  assign output_stream_1_1__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_1_1__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_1_1\033[0m -> \033[90mcompute_2        \033[0m %h", output_stream_1_1__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_1_1__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_1\033[0m -> \033[97moutput_stream_1_1\033[0m %h", output_stream_1_1__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_1_2__rst__q1 <= output_stream_1_2__rst__q0;
    output_stream_1_2__rst__q2 <= output_stream_1_2__rst__q1;
    output_stream_1_2__rst__q3 <= output_stream_1_2__rst__q2;
  end

  assign output_stream_1_2__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_1_2__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_1_2\033[0m -> \033[90mcompute_2        \033[0m %h", output_stream_1_2__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_1_2__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_1\033[0m -> \033[97moutput_stream_1_2\033[0m %h", output_stream_1_2__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_1_3__rst__q1 <= output_stream_1_3__rst__q0;
    output_stream_1_3__rst__q2 <= output_stream_1_3__rst__q1;
    output_stream_1_3__rst__q3 <= output_stream_1_3__rst__q2;
  end

  assign output_stream_1_3__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_1_3__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_1_3\033[0m -> \033[90mcompute_2        \033[0m %h", output_stream_1_3__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_1_3__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_1\033[0m -> \033[97moutput_stream_1_3\033[0m %h", output_stream_1_3__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_2_0__rst__q1 <= output_stream_2_0__rst__q0;
    output_stream_2_0__rst__q2 <= output_stream_2_0__rst__q1;
    output_stream_2_0__rst__q3 <= output_stream_2_0__rst__q2;
  end

  assign output_stream_2_0__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_2_0__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_2_0\033[0m -> \033[90mcompute_3        \033[0m %h", output_stream_2_0__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_2_0__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_2\033[0m -> \033[97moutput_stream_2_0\033[0m %h", output_stream_2_0__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_2_1__rst__q1 <= output_stream_2_1__rst__q0;
    output_stream_2_1__rst__q2 <= output_stream_2_1__rst__q1;
    output_stream_2_1__rst__q3 <= output_stream_2_1__rst__q2;
  end

  assign output_stream_2_1__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_2_1__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_2_1\033[0m -> \033[90mcompute_3        \033[0m %h", output_stream_2_1__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_2_1__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_2\033[0m -> \033[97moutput_stream_2_1\033[0m %h", output_stream_2_1__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_2_2__rst__q1 <= output_stream_2_2__rst__q0;
    output_stream_2_2__rst__q2 <= output_stream_2_2__rst__q1;
    output_stream_2_2__rst__q3 <= output_stream_2_2__rst__q2;
  end

  assign output_stream_2_2__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_2_2__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_2_2\033[0m -> \033[90mcompute_3        \033[0m %h", output_stream_2_2__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_2_2__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_2\033[0m -> \033[97moutput_stream_2_2\033[0m %h", output_stream_2_2__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_2_3__rst__q1 <= output_stream_2_3__rst__q0;
    output_stream_2_3__rst__q2 <= output_stream_2_3__rst__q1;
    output_stream_2_3__rst__q3 <= output_stream_2_3__rst__q2;
  end

  assign output_stream_2_3__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_2_3__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_2_3\033[0m -> \033[90mcompute_3        \033[0m %h", output_stream_2_3__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_2_3__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_2\033[0m -> \033[97moutput_stream_2_3\033[0m %h", output_stream_2_3__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_3_0__rst__q1 <= output_stream_3_0__rst__q0;
    output_stream_3_0__rst__q2 <= output_stream_3_0__rst__q1;
    output_stream_3_0__rst__q3 <= output_stream_3_0__rst__q2;
  end

  assign output_stream_3_0__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_3_0__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_3_0\033[0m -> \033[90mcompute_4        \033[0m %h", output_stream_3_0__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_3_0__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_3\033[0m -> \033[97moutput_stream_3_0\033[0m %h", output_stream_3_0__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_3_1__rst__q1 <= output_stream_3_1__rst__q0;
    output_stream_3_1__rst__q2 <= output_stream_3_1__rst__q1;
    output_stream_3_1__rst__q3 <= output_stream_3_1__rst__q2;
  end

  assign output_stream_3_1__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_3_1__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_3_1\033[0m -> \033[90mcompute_4        \033[0m %h", output_stream_3_1__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_3_1__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_3\033[0m -> \033[97moutput_stream_3_1\033[0m %h", output_stream_3_1__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_3_2__rst__q1 <= output_stream_3_2__rst__q0;
    output_stream_3_2__rst__q2 <= output_stream_3_2__rst__q1;
    output_stream_3_2__rst__q3 <= output_stream_3_2__rst__q2;
  end

  assign output_stream_3_2__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_3_2__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_3_2\033[0m -> \033[90mcompute_4        \033[0m %h", output_stream_3_2__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_3_2__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_3\033[0m -> \033[97moutput_stream_3_2\033[0m %h", output_stream_3_2__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_3_3__rst__q1 <= output_stream_3_3__rst__q0;
    output_stream_3_3__rst__q2 <= output_stream_3_3__rst__q1;
    output_stream_3_3__rst__q3 <= output_stream_3_3__rst__q2;
  end

  assign output_stream_3_3__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_3_3__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_3_3\033[0m -> \033[90mcompute_4        \033[0m %h", output_stream_3_3__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_3_3__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_3\033[0m -> \033[97moutput_stream_3_3\033[0m %h", output_stream_3_3__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_4_0__rst__q1 <= output_stream_4_0__rst__q0;
    output_stream_4_0__rst__q2 <= output_stream_4_0__rst__q1;
    output_stream_4_0__rst__q3 <= output_stream_4_0__rst__q2;
  end

  assign output_stream_4_0__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_4_0__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_4_0\033[0m -> \033[90mcompute_5        \033[0m %h", output_stream_4_0__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_4_0__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_4\033[0m -> \033[97moutput_stream_4_0\033[0m %h", output_stream_4_0__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_4_1__rst__q1 <= output_stream_4_1__rst__q0;
    output_stream_4_1__rst__q2 <= output_stream_4_1__rst__q1;
    output_stream_4_1__rst__q3 <= output_stream_4_1__rst__q2;
  end

  assign output_stream_4_1__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_4_1__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_4_1\033[0m -> \033[90mcompute_5        \033[0m %h", output_stream_4_1__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_4_1__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_4\033[0m -> \033[97moutput_stream_4_1\033[0m %h", output_stream_4_1__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_4_2__rst__q1 <= output_stream_4_2__rst__q0;
    output_stream_4_2__rst__q2 <= output_stream_4_2__rst__q1;
    output_stream_4_2__rst__q3 <= output_stream_4_2__rst__q2;
  end

  assign output_stream_4_2__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_4_2__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_4_2\033[0m -> \033[90mcompute_5        \033[0m %h", output_stream_4_2__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_4_2__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_4\033[0m -> \033[97moutput_stream_4_2\033[0m %h", output_stream_4_2__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_4_3__rst__q1 <= output_stream_4_3__rst__q0;
    output_stream_4_3__rst__q2 <= output_stream_4_3__rst__q1;
    output_stream_4_3__rst__q3 <= output_stream_4_3__rst__q2;
  end

  assign output_stream_4_3__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_4_3__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_4_3\033[0m -> \033[90mcompute_5        \033[0m %h", output_stream_4_3__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_4_3__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_4\033[0m -> \033[97moutput_stream_4_3\033[0m %h", output_stream_4_3__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_5_0__rst__q1 <= output_stream_5_0__rst__q0;
    output_stream_5_0__rst__q2 <= output_stream_5_0__rst__q1;
    output_stream_5_0__rst__q3 <= output_stream_5_0__rst__q2;
  end

  assign output_stream_5_0__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_5_0__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_5_0\033[0m -> \033[90mstore_0          \033[0m %h", output_stream_5_0__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_5_0__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_5\033[0m -> \033[97moutput_stream_5_0\033[0m %h", output_stream_5_0__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_5_1__rst__q1 <= output_stream_5_1__rst__q0;
    output_stream_5_1__rst__q2 <= output_stream_5_1__rst__q1;
    output_stream_5_1__rst__q3 <= output_stream_5_1__rst__q2;
  end

  assign output_stream_5_1__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_5_1__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_5_1\033[0m -> \033[90mstore_0          \033[0m %h", output_stream_5_1__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_5_1__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_5\033[0m -> \033[97moutput_stream_5_1\033[0m %h", output_stream_5_1__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_5_2__rst__q1 <= output_stream_5_2__rst__q0;
    output_stream_5_2__rst__q2 <= output_stream_5_2__rst__q1;
    output_stream_5_2__rst__q3 <= output_stream_5_2__rst__q2;
  end

  assign output_stream_5_2__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_5_2__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_5_2\033[0m -> \033[90mstore_0          \033[0m %h", output_stream_5_2__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_5_2__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_5\033[0m -> \033[97moutput_stream_5_2\033[0m %h", output_stream_5_2__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_5_3__rst__q1 <= output_stream_5_3__rst__q0;
    output_stream_5_3__rst__q2 <= output_stream_5_3__rst__q1;
    output_stream_5_3__rst__q3 <= output_stream_5_3__rst__q2;
  end

  assign output_stream_5_3__rst__q0 = (~ap_rst_n);

  always @(posedge ap_clk) begin
    if(output_stream_5_3__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_5_3\033[0m -> \033[90mstore_0          \033[0m %h", output_stream_5_3__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_5_3__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_5\033[0m -> \033[97moutput_stream_5_3\033[0m %h", output_stream_5_3__din);
    end 
  end


  always @(posedge ap_clk) begin
    compute_0___coalesced_data_num__q1 <= compute_0___coalesced_data_num__q0;
    compute_0___coalesced_data_num__q2 <= compute_0___coalesced_data_num__q1;
    compute_0___coalesced_data_num__q3 <= compute_0___coalesced_data_num__q2;
  end

  assign compute_0___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    compute_0___input_size_dim_0__q1 <= compute_0___input_size_dim_0__q0;
    compute_0___input_size_dim_0__q2 <= compute_0___input_size_dim_0__q1;
    compute_0___input_size_dim_0__q3 <= compute_0___input_size_dim_0__q2;
  end

  assign compute_0___input_size_dim_0__q0 = input_size_dim_0;

  always @(posedge ap_clk) begin
    compute_0___input_size_dim_1__q1 <= compute_0___input_size_dim_1__q0;
    compute_0___input_size_dim_1__q2 <= compute_0___input_size_dim_1__q1;
    compute_0___input_size_dim_1__q3 <= compute_0___input_size_dim_1__q2;
  end

  assign compute_0___input_size_dim_1__q0 = input_size_dim_1;

  always @(posedge ap_clk) begin
    compute_0___tile_data_num__q1 <= compute_0___tile_data_num__q0;
    compute_0___tile_data_num__q2 <= compute_0___tile_data_num__q1;
    compute_0___tile_data_num__q3 <= compute_0___tile_data_num__q2;
  end

  assign compute_0___tile_data_num__q0 = tile_data_num;

  always @(posedge ap_clk) begin
    compute_0___tile_num_dim_0__q1 <= compute_0___tile_num_dim_0__q0;
    compute_0___tile_num_dim_0__q2 <= compute_0___tile_num_dim_0__q1;
    compute_0___tile_num_dim_0__q3 <= compute_0___tile_num_dim_0__q2;
  end

  assign compute_0___tile_num_dim_0__q0 = tile_num_dim_0;

  always @(posedge ap_clk) begin
    compute_0__ap_rst_n__q1 <= compute_0__ap_rst_n__q0;
    compute_0__ap_rst_n__q2 <= compute_0__ap_rst_n__q1;
    compute_0__ap_rst_n__q3 <= compute_0__ap_rst_n__q2;
  end

  assign compute_0__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    compute_0__is_done__q1 <= compute_0__is_done__q0;
    compute_0__is_done__q2 <= compute_0__is_done__q1;
    compute_0__is_done__q3 <= compute_0__is_done__q2;
  end

  assign compute_0__is_done__q0 = (compute_0__state == 2'b10);

  always @(posedge ap_clk) begin
    compute_0__ap_start_global__q1 <= compute_0__ap_start_global__q0;
    compute_0__ap_start_global__q2 <= compute_0__ap_start_global__q1;
    compute_0__ap_start_global__q3 <= compute_0__ap_start_global__q2;
  end

  assign compute_0__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    compute_0__ap_done_global__q1 <= compute_0__ap_done_global__q0;
    compute_0__ap_done_global__q2 <= compute_0__ap_done_global__q1;
    compute_0__ap_done_global__q3 <= compute_0__ap_done_global__q2;
  end

  assign compute_0__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~compute_0__ap_rst_n__q3) begin
      compute_0__state <= 2'b00;
    end else begin
      if(compute_0__state == 2'b00) begin
        if(compute_0__ap_start_global__q3) begin
          compute_0__state <= 2'b01;
        end 
      end 
      if(compute_0__state == 2'b01) begin
        if(compute_0__ap_ready) begin
          if(compute_0__ap_done) begin
            compute_0__state <= 2'b10;
          end else begin
            compute_0__state <= 2'b11;
          end
        end 
      end 
      if(compute_0__state == 2'b11) begin
        if(compute_0__ap_done) begin
          compute_0__state <= 2'b10;
        end 
      end 
      if(compute_0__state == 2'b10) begin
        if(compute_0__ap_done_global__q3) begin
          compute_0__state <= 2'b00;
        end 
      end 
    end
  end

  assign compute_0__ap_start = (compute_0__state == 2'b01);

  always @(posedge ap_clk) begin
    compute_1___coalesced_data_num__q1 <= compute_1___coalesced_data_num__q0;
    compute_1___coalesced_data_num__q2 <= compute_1___coalesced_data_num__q1;
    compute_1___coalesced_data_num__q3 <= compute_1___coalesced_data_num__q2;
  end

  assign compute_1___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    compute_1___input_size_dim_0__q1 <= compute_1___input_size_dim_0__q0;
    compute_1___input_size_dim_0__q2 <= compute_1___input_size_dim_0__q1;
    compute_1___input_size_dim_0__q3 <= compute_1___input_size_dim_0__q2;
  end

  assign compute_1___input_size_dim_0__q0 = input_size_dim_0;

  always @(posedge ap_clk) begin
    compute_1___input_size_dim_1__q1 <= compute_1___input_size_dim_1__q0;
    compute_1___input_size_dim_1__q2 <= compute_1___input_size_dim_1__q1;
    compute_1___input_size_dim_1__q3 <= compute_1___input_size_dim_1__q2;
  end

  assign compute_1___input_size_dim_1__q0 = input_size_dim_1;

  always @(posedge ap_clk) begin
    compute_1___tile_data_num__q1 <= compute_1___tile_data_num__q0;
    compute_1___tile_data_num__q2 <= compute_1___tile_data_num__q1;
    compute_1___tile_data_num__q3 <= compute_1___tile_data_num__q2;
  end

  assign compute_1___tile_data_num__q0 = tile_data_num;

  always @(posedge ap_clk) begin
    compute_1___tile_num_dim_0__q1 <= compute_1___tile_num_dim_0__q0;
    compute_1___tile_num_dim_0__q2 <= compute_1___tile_num_dim_0__q1;
    compute_1___tile_num_dim_0__q3 <= compute_1___tile_num_dim_0__q2;
  end

  assign compute_1___tile_num_dim_0__q0 = tile_num_dim_0;

  always @(posedge ap_clk) begin
    compute_1__ap_rst_n__q1 <= compute_1__ap_rst_n__q0;
    compute_1__ap_rst_n__q2 <= compute_1__ap_rst_n__q1;
    compute_1__ap_rst_n__q3 <= compute_1__ap_rst_n__q2;
  end

  assign compute_1__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    compute_1__is_done__q1 <= compute_1__is_done__q0;
    compute_1__is_done__q2 <= compute_1__is_done__q1;
    compute_1__is_done__q3 <= compute_1__is_done__q2;
  end

  assign compute_1__is_done__q0 = (compute_1__state == 2'b10);

  always @(posedge ap_clk) begin
    compute_1__ap_start_global__q1 <= compute_1__ap_start_global__q0;
    compute_1__ap_start_global__q2 <= compute_1__ap_start_global__q1;
    compute_1__ap_start_global__q3 <= compute_1__ap_start_global__q2;
  end

  assign compute_1__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    compute_1__ap_done_global__q1 <= compute_1__ap_done_global__q0;
    compute_1__ap_done_global__q2 <= compute_1__ap_done_global__q1;
    compute_1__ap_done_global__q3 <= compute_1__ap_done_global__q2;
  end

  assign compute_1__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~compute_1__ap_rst_n__q3) begin
      compute_1__state <= 2'b00;
    end else begin
      if(compute_1__state == 2'b00) begin
        if(compute_1__ap_start_global__q3) begin
          compute_1__state <= 2'b01;
        end 
      end 
      if(compute_1__state == 2'b01) begin
        if(compute_1__ap_ready) begin
          if(compute_1__ap_done) begin
            compute_1__state <= 2'b10;
          end else begin
            compute_1__state <= 2'b11;
          end
        end 
      end 
      if(compute_1__state == 2'b11) begin
        if(compute_1__ap_done) begin
          compute_1__state <= 2'b10;
        end 
      end 
      if(compute_1__state == 2'b10) begin
        if(compute_1__ap_done_global__q3) begin
          compute_1__state <= 2'b00;
        end 
      end 
    end
  end

  assign compute_1__ap_start = (compute_1__state == 2'b01);

  always @(posedge ap_clk) begin
    compute_2___coalesced_data_num__q1 <= compute_2___coalesced_data_num__q0;
    compute_2___coalesced_data_num__q2 <= compute_2___coalesced_data_num__q1;
    compute_2___coalesced_data_num__q3 <= compute_2___coalesced_data_num__q2;
  end

  assign compute_2___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    compute_2___input_size_dim_0__q1 <= compute_2___input_size_dim_0__q0;
    compute_2___input_size_dim_0__q2 <= compute_2___input_size_dim_0__q1;
    compute_2___input_size_dim_0__q3 <= compute_2___input_size_dim_0__q2;
  end

  assign compute_2___input_size_dim_0__q0 = input_size_dim_0;

  always @(posedge ap_clk) begin
    compute_2___input_size_dim_1__q1 <= compute_2___input_size_dim_1__q0;
    compute_2___input_size_dim_1__q2 <= compute_2___input_size_dim_1__q1;
    compute_2___input_size_dim_1__q3 <= compute_2___input_size_dim_1__q2;
  end

  assign compute_2___input_size_dim_1__q0 = input_size_dim_1;

  always @(posedge ap_clk) begin
    compute_2___tile_data_num__q1 <= compute_2___tile_data_num__q0;
    compute_2___tile_data_num__q2 <= compute_2___tile_data_num__q1;
    compute_2___tile_data_num__q3 <= compute_2___tile_data_num__q2;
  end

  assign compute_2___tile_data_num__q0 = tile_data_num;

  always @(posedge ap_clk) begin
    compute_2___tile_num_dim_0__q1 <= compute_2___tile_num_dim_0__q0;
    compute_2___tile_num_dim_0__q2 <= compute_2___tile_num_dim_0__q1;
    compute_2___tile_num_dim_0__q3 <= compute_2___tile_num_dim_0__q2;
  end

  assign compute_2___tile_num_dim_0__q0 = tile_num_dim_0;

  always @(posedge ap_clk) begin
    compute_2__ap_rst_n__q1 <= compute_2__ap_rst_n__q0;
    compute_2__ap_rst_n__q2 <= compute_2__ap_rst_n__q1;
    compute_2__ap_rst_n__q3 <= compute_2__ap_rst_n__q2;
  end

  assign compute_2__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    compute_2__is_done__q1 <= compute_2__is_done__q0;
    compute_2__is_done__q2 <= compute_2__is_done__q1;
    compute_2__is_done__q3 <= compute_2__is_done__q2;
  end

  assign compute_2__is_done__q0 = (compute_2__state == 2'b10);

  always @(posedge ap_clk) begin
    compute_2__ap_start_global__q1 <= compute_2__ap_start_global__q0;
    compute_2__ap_start_global__q2 <= compute_2__ap_start_global__q1;
    compute_2__ap_start_global__q3 <= compute_2__ap_start_global__q2;
  end

  assign compute_2__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    compute_2__ap_done_global__q1 <= compute_2__ap_done_global__q0;
    compute_2__ap_done_global__q2 <= compute_2__ap_done_global__q1;
    compute_2__ap_done_global__q3 <= compute_2__ap_done_global__q2;
  end

  assign compute_2__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~compute_2__ap_rst_n__q3) begin
      compute_2__state <= 2'b00;
    end else begin
      if(compute_2__state == 2'b00) begin
        if(compute_2__ap_start_global__q3) begin
          compute_2__state <= 2'b01;
        end 
      end 
      if(compute_2__state == 2'b01) begin
        if(compute_2__ap_ready) begin
          if(compute_2__ap_done) begin
            compute_2__state <= 2'b10;
          end else begin
            compute_2__state <= 2'b11;
          end
        end 
      end 
      if(compute_2__state == 2'b11) begin
        if(compute_2__ap_done) begin
          compute_2__state <= 2'b10;
        end 
      end 
      if(compute_2__state == 2'b10) begin
        if(compute_2__ap_done_global__q3) begin
          compute_2__state <= 2'b00;
        end 
      end 
    end
  end

  assign compute_2__ap_start = (compute_2__state == 2'b01);

  always @(posedge ap_clk) begin
    compute_3___coalesced_data_num__q1 <= compute_3___coalesced_data_num__q0;
    compute_3___coalesced_data_num__q2 <= compute_3___coalesced_data_num__q1;
    compute_3___coalesced_data_num__q3 <= compute_3___coalesced_data_num__q2;
  end

  assign compute_3___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    compute_3___input_size_dim_0__q1 <= compute_3___input_size_dim_0__q0;
    compute_3___input_size_dim_0__q2 <= compute_3___input_size_dim_0__q1;
    compute_3___input_size_dim_0__q3 <= compute_3___input_size_dim_0__q2;
  end

  assign compute_3___input_size_dim_0__q0 = input_size_dim_0;

  always @(posedge ap_clk) begin
    compute_3___input_size_dim_1__q1 <= compute_3___input_size_dim_1__q0;
    compute_3___input_size_dim_1__q2 <= compute_3___input_size_dim_1__q1;
    compute_3___input_size_dim_1__q3 <= compute_3___input_size_dim_1__q2;
  end

  assign compute_3___input_size_dim_1__q0 = input_size_dim_1;

  always @(posedge ap_clk) begin
    compute_3___tile_data_num__q1 <= compute_3___tile_data_num__q0;
    compute_3___tile_data_num__q2 <= compute_3___tile_data_num__q1;
    compute_3___tile_data_num__q3 <= compute_3___tile_data_num__q2;
  end

  assign compute_3___tile_data_num__q0 = tile_data_num;

  always @(posedge ap_clk) begin
    compute_3___tile_num_dim_0__q1 <= compute_3___tile_num_dim_0__q0;
    compute_3___tile_num_dim_0__q2 <= compute_3___tile_num_dim_0__q1;
    compute_3___tile_num_dim_0__q3 <= compute_3___tile_num_dim_0__q2;
  end

  assign compute_3___tile_num_dim_0__q0 = tile_num_dim_0;

  always @(posedge ap_clk) begin
    compute_3__ap_rst_n__q1 <= compute_3__ap_rst_n__q0;
    compute_3__ap_rst_n__q2 <= compute_3__ap_rst_n__q1;
    compute_3__ap_rst_n__q3 <= compute_3__ap_rst_n__q2;
  end

  assign compute_3__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    compute_3__is_done__q1 <= compute_3__is_done__q0;
    compute_3__is_done__q2 <= compute_3__is_done__q1;
    compute_3__is_done__q3 <= compute_3__is_done__q2;
  end

  assign compute_3__is_done__q0 = (compute_3__state == 2'b10);

  always @(posedge ap_clk) begin
    compute_3__ap_start_global__q1 <= compute_3__ap_start_global__q0;
    compute_3__ap_start_global__q2 <= compute_3__ap_start_global__q1;
    compute_3__ap_start_global__q3 <= compute_3__ap_start_global__q2;
  end

  assign compute_3__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    compute_3__ap_done_global__q1 <= compute_3__ap_done_global__q0;
    compute_3__ap_done_global__q2 <= compute_3__ap_done_global__q1;
    compute_3__ap_done_global__q3 <= compute_3__ap_done_global__q2;
  end

  assign compute_3__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~compute_3__ap_rst_n__q3) begin
      compute_3__state <= 2'b00;
    end else begin
      if(compute_3__state == 2'b00) begin
        if(compute_3__ap_start_global__q3) begin
          compute_3__state <= 2'b01;
        end 
      end 
      if(compute_3__state == 2'b01) begin
        if(compute_3__ap_ready) begin
          if(compute_3__ap_done) begin
            compute_3__state <= 2'b10;
          end else begin
            compute_3__state <= 2'b11;
          end
        end 
      end 
      if(compute_3__state == 2'b11) begin
        if(compute_3__ap_done) begin
          compute_3__state <= 2'b10;
        end 
      end 
      if(compute_3__state == 2'b10) begin
        if(compute_3__ap_done_global__q3) begin
          compute_3__state <= 2'b00;
        end 
      end 
    end
  end

  assign compute_3__ap_start = (compute_3__state == 2'b01);

  always @(posedge ap_clk) begin
    compute_4___coalesced_data_num__q1 <= compute_4___coalesced_data_num__q0;
    compute_4___coalesced_data_num__q2 <= compute_4___coalesced_data_num__q1;
    compute_4___coalesced_data_num__q3 <= compute_4___coalesced_data_num__q2;
  end

  assign compute_4___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    compute_4___input_size_dim_0__q1 <= compute_4___input_size_dim_0__q0;
    compute_4___input_size_dim_0__q2 <= compute_4___input_size_dim_0__q1;
    compute_4___input_size_dim_0__q3 <= compute_4___input_size_dim_0__q2;
  end

  assign compute_4___input_size_dim_0__q0 = input_size_dim_0;

  always @(posedge ap_clk) begin
    compute_4___input_size_dim_1__q1 <= compute_4___input_size_dim_1__q0;
    compute_4___input_size_dim_1__q2 <= compute_4___input_size_dim_1__q1;
    compute_4___input_size_dim_1__q3 <= compute_4___input_size_dim_1__q2;
  end

  assign compute_4___input_size_dim_1__q0 = input_size_dim_1;

  always @(posedge ap_clk) begin
    compute_4___tile_data_num__q1 <= compute_4___tile_data_num__q0;
    compute_4___tile_data_num__q2 <= compute_4___tile_data_num__q1;
    compute_4___tile_data_num__q3 <= compute_4___tile_data_num__q2;
  end

  assign compute_4___tile_data_num__q0 = tile_data_num;

  always @(posedge ap_clk) begin
    compute_4___tile_num_dim_0__q1 <= compute_4___tile_num_dim_0__q0;
    compute_4___tile_num_dim_0__q2 <= compute_4___tile_num_dim_0__q1;
    compute_4___tile_num_dim_0__q3 <= compute_4___tile_num_dim_0__q2;
  end

  assign compute_4___tile_num_dim_0__q0 = tile_num_dim_0;

  always @(posedge ap_clk) begin
    compute_4__ap_rst_n__q1 <= compute_4__ap_rst_n__q0;
    compute_4__ap_rst_n__q2 <= compute_4__ap_rst_n__q1;
    compute_4__ap_rst_n__q3 <= compute_4__ap_rst_n__q2;
  end

  assign compute_4__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    compute_4__is_done__q1 <= compute_4__is_done__q0;
    compute_4__is_done__q2 <= compute_4__is_done__q1;
    compute_4__is_done__q3 <= compute_4__is_done__q2;
  end

  assign compute_4__is_done__q0 = (compute_4__state == 2'b10);

  always @(posedge ap_clk) begin
    compute_4__ap_start_global__q1 <= compute_4__ap_start_global__q0;
    compute_4__ap_start_global__q2 <= compute_4__ap_start_global__q1;
    compute_4__ap_start_global__q3 <= compute_4__ap_start_global__q2;
  end

  assign compute_4__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    compute_4__ap_done_global__q1 <= compute_4__ap_done_global__q0;
    compute_4__ap_done_global__q2 <= compute_4__ap_done_global__q1;
    compute_4__ap_done_global__q3 <= compute_4__ap_done_global__q2;
  end

  assign compute_4__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~compute_4__ap_rst_n__q3) begin
      compute_4__state <= 2'b00;
    end else begin
      if(compute_4__state == 2'b00) begin
        if(compute_4__ap_start_global__q3) begin
          compute_4__state <= 2'b01;
        end 
      end 
      if(compute_4__state == 2'b01) begin
        if(compute_4__ap_ready) begin
          if(compute_4__ap_done) begin
            compute_4__state <= 2'b10;
          end else begin
            compute_4__state <= 2'b11;
          end
        end 
      end 
      if(compute_4__state == 2'b11) begin
        if(compute_4__ap_done) begin
          compute_4__state <= 2'b10;
        end 
      end 
      if(compute_4__state == 2'b10) begin
        if(compute_4__ap_done_global__q3) begin
          compute_4__state <= 2'b00;
        end 
      end 
    end
  end

  assign compute_4__ap_start = (compute_4__state == 2'b01);

  always @(posedge ap_clk) begin
    compute_5___coalesced_data_num__q1 <= compute_5___coalesced_data_num__q0;
    compute_5___coalesced_data_num__q2 <= compute_5___coalesced_data_num__q1;
    compute_5___coalesced_data_num__q3 <= compute_5___coalesced_data_num__q2;
  end

  assign compute_5___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    compute_5___input_size_dim_0__q1 <= compute_5___input_size_dim_0__q0;
    compute_5___input_size_dim_0__q2 <= compute_5___input_size_dim_0__q1;
    compute_5___input_size_dim_0__q3 <= compute_5___input_size_dim_0__q2;
  end

  assign compute_5___input_size_dim_0__q0 = input_size_dim_0;

  always @(posedge ap_clk) begin
    compute_5___input_size_dim_1__q1 <= compute_5___input_size_dim_1__q0;
    compute_5___input_size_dim_1__q2 <= compute_5___input_size_dim_1__q1;
    compute_5___input_size_dim_1__q3 <= compute_5___input_size_dim_1__q2;
  end

  assign compute_5___input_size_dim_1__q0 = input_size_dim_1;

  always @(posedge ap_clk) begin
    compute_5___tile_data_num__q1 <= compute_5___tile_data_num__q0;
    compute_5___tile_data_num__q2 <= compute_5___tile_data_num__q1;
    compute_5___tile_data_num__q3 <= compute_5___tile_data_num__q2;
  end

  assign compute_5___tile_data_num__q0 = tile_data_num;

  always @(posedge ap_clk) begin
    compute_5___tile_num_dim_0__q1 <= compute_5___tile_num_dim_0__q0;
    compute_5___tile_num_dim_0__q2 <= compute_5___tile_num_dim_0__q1;
    compute_5___tile_num_dim_0__q3 <= compute_5___tile_num_dim_0__q2;
  end

  assign compute_5___tile_num_dim_0__q0 = tile_num_dim_0;

  always @(posedge ap_clk) begin
    compute_5__ap_rst_n__q1 <= compute_5__ap_rst_n__q0;
    compute_5__ap_rst_n__q2 <= compute_5__ap_rst_n__q1;
    compute_5__ap_rst_n__q3 <= compute_5__ap_rst_n__q2;
  end

  assign compute_5__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    compute_5__is_done__q1 <= compute_5__is_done__q0;
    compute_5__is_done__q2 <= compute_5__is_done__q1;
    compute_5__is_done__q3 <= compute_5__is_done__q2;
  end

  assign compute_5__is_done__q0 = (compute_5__state == 2'b10);

  always @(posedge ap_clk) begin
    compute_5__ap_start_global__q1 <= compute_5__ap_start_global__q0;
    compute_5__ap_start_global__q2 <= compute_5__ap_start_global__q1;
    compute_5__ap_start_global__q3 <= compute_5__ap_start_global__q2;
  end

  assign compute_5__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    compute_5__ap_done_global__q1 <= compute_5__ap_done_global__q0;
    compute_5__ap_done_global__q2 <= compute_5__ap_done_global__q1;
    compute_5__ap_done_global__q3 <= compute_5__ap_done_global__q2;
  end

  assign compute_5__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~compute_5__ap_rst_n__q3) begin
      compute_5__state <= 2'b00;
    end else begin
      if(compute_5__state == 2'b00) begin
        if(compute_5__ap_start_global__q3) begin
          compute_5__state <= 2'b01;
        end 
      end 
      if(compute_5__state == 2'b01) begin
        if(compute_5__ap_ready) begin
          if(compute_5__ap_done) begin
            compute_5__state <= 2'b10;
          end else begin
            compute_5__state <= 2'b11;
          end
        end 
      end 
      if(compute_5__state == 2'b11) begin
        if(compute_5__ap_done) begin
          compute_5__state <= 2'b10;
        end 
      end 
      if(compute_5__state == 2'b10) begin
        if(compute_5__ap_done_global__q3) begin
          compute_5__state <= 2'b00;
        end 
      end 
    end
  end

  assign compute_5__ap_start = (compute_5__state == 2'b01);

  always @(posedge ap_clk) begin
    load_0___coalesced_data_num__q1 <= load_0___coalesced_data_num__q0;
    load_0___coalesced_data_num__q2 <= load_0___coalesced_data_num__q1;
    load_0___coalesced_data_num__q3 <= load_0___coalesced_data_num__q2;
  end

  assign load_0___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    var_input_0_0__q1 <= var_input_0_0__q0;
    var_input_0_0__q2 <= var_input_0_0__q1;
    var_input_0_0__q3 <= var_input_0_0__q2;
  end

  assign var_input_0_0__q0 = var_input_0_0;

  always @(posedge ap_clk) begin
    load_0__ap_rst_n__q1 <= load_0__ap_rst_n__q0;
    load_0__ap_rst_n__q2 <= load_0__ap_rst_n__q1;
    load_0__ap_rst_n__q3 <= load_0__ap_rst_n__q2;
  end

  assign load_0__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    load_0__is_done__q1 <= load_0__is_done__q0;
    load_0__is_done__q2 <= load_0__is_done__q1;
    load_0__is_done__q3 <= load_0__is_done__q2;
  end

  assign load_0__is_done__q0 = (load_0__state == 2'b10);

  always @(posedge ap_clk) begin
    load_0__ap_start_global__q1 <= load_0__ap_start_global__q0;
    load_0__ap_start_global__q2 <= load_0__ap_start_global__q1;
    load_0__ap_start_global__q3 <= load_0__ap_start_global__q2;
  end

  assign load_0__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    load_0__ap_done_global__q1 <= load_0__ap_done_global__q0;
    load_0__ap_done_global__q2 <= load_0__ap_done_global__q1;
    load_0__ap_done_global__q3 <= load_0__ap_done_global__q2;
  end

  assign load_0__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~load_0__ap_rst_n__q3) begin
      load_0__state <= 2'b00;
    end else begin
      if(load_0__state == 2'b00) begin
        if(load_0__ap_start_global__q3) begin
          load_0__state <= 2'b01;
        end 
      end 
      if(load_0__state == 2'b01) begin
        if(load_0__ap_ready) begin
          if(load_0__ap_done) begin
            load_0__state <= 2'b10;
          end else begin
            load_0__state <= 2'b11;
          end
        end 
      end 
      if(load_0__state == 2'b11) begin
        if(load_0__ap_done) begin
          load_0__state <= 2'b10;
        end 
      end 
      if(load_0__state == 2'b10) begin
        if(load_0__ap_done_global__q3) begin
          load_0__state <= 2'b00;
        end 
      end 
    end
  end

  assign load_0__ap_start = (load_0__state == 2'b01);

  always @(posedge ap_clk) begin
    store_0___coalesced_data_num__q1 <= store_0___coalesced_data_num__q0;
    store_0___coalesced_data_num__q2 <= store_0___coalesced_data_num__q1;
    store_0___coalesced_data_num__q3 <= store_0___coalesced_data_num__q2;
  end

  assign store_0___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    var_output_0_0__q1 <= var_output_0_0__q0;
    var_output_0_0__q2 <= var_output_0_0__q1;
    var_output_0_0__q3 <= var_output_0_0__q2;
  end

  assign var_output_0_0__q0 = var_output_0_0;

  always @(posedge ap_clk) begin
    store_0__ap_rst_n__q1 <= store_0__ap_rst_n__q0;
    store_0__ap_rst_n__q2 <= store_0__ap_rst_n__q1;
    store_0__ap_rst_n__q3 <= store_0__ap_rst_n__q2;
  end

  assign store_0__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    store_0__is_done__q1 <= store_0__is_done__q0;
    store_0__is_done__q2 <= store_0__is_done__q1;
    store_0__is_done__q3 <= store_0__is_done__q2;
  end

  assign store_0__is_done__q0 = (store_0__state == 2'b10);

  always @(posedge ap_clk) begin
    store_0__ap_start_global__q1 <= store_0__ap_start_global__q0;
    store_0__ap_start_global__q2 <= store_0__ap_start_global__q1;
    store_0__ap_start_global__q3 <= store_0__ap_start_global__q2;
  end

  assign store_0__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    store_0__ap_done_global__q1 <= store_0__ap_done_global__q0;
    store_0__ap_done_global__q2 <= store_0__ap_done_global__q1;
    store_0__ap_done_global__q3 <= store_0__ap_done_global__q2;
  end

  assign store_0__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~store_0__ap_rst_n__q3) begin
      store_0__state <= 2'b00;
    end else begin
      if(store_0__state == 2'b00) begin
        if(store_0__ap_start_global__q3) begin
          store_0__state <= 2'b01;
        end 
      end 
      if(store_0__state == 2'b01) begin
        if(store_0__ap_ready) begin
          if(store_0__ap_done) begin
            store_0__state <= 2'b10;
          end else begin
            store_0__state <= 2'b11;
          end
        end 
      end 
      if(store_0__state == 2'b11) begin
        if(store_0__ap_done) begin
          store_0__state <= 2'b10;
        end 
      end 
      if(store_0__state == 2'b10) begin
        if(store_0__ap_done_global__q3) begin
          store_0__state <= 2'b00;
        end 
      end 
    end
  end

  assign store_0__ap_start = (store_0__state == 2'b01);

  always @(posedge ap_clk) begin
    if(ap_rst_n_inv) begin
      tlp_state <= 2'b00;
    end else begin
      begin
        if(tlp_state == 2'b00) begin
          if(ap_start__q3) begin
            tlp_state <= 2'b01;
          end 
        end 
        if(tlp_state == 2'b01) begin
          if(compute_0__is_done__q3 && compute_1__is_done__q3 && compute_2__is_done__q3 && compute_3__is_done__q3 && compute_4__is_done__q3 && compute_5__is_done__q3 && load_0__is_done__q3 && store_0__is_done__q3) begin
            tlp_state <= 2'b10;
          end 
        end 
        if(tlp_state == 2'b10) begin
          begin
            tlp_state <= 2'b11;
            countdown <= 2'd2;
          end
        end 
        if(tlp_state == 2'b11) begin
          if(countdown == 2'd0) begin
            tlp_state <= 2'b00;
          end else begin
            countdown <= (countdown - 2'd1);
          end
        end 
      end
    end
  end

  assign ap_idle = (tlp_state == 2'b00);
  assign ap_done = ap_done__q3;
  assign ap_ready = ap_done__q0;

  always @(posedge ap_clk) begin
    ap_start__q1 <= ap_start__q0;
    ap_start__q2 <= ap_start__q1;
    ap_start__q3 <= ap_start__q2;
  end

  assign ap_start__q0 = ap_start;

  always @(posedge ap_clk) begin
    ap_done__q1 <= ap_done__q0;
    ap_done__q2 <= ap_done__q1;
    ap_done__q3 <= ap_done__q2;
  end

  assign ap_done__q0 = (tlp_state == 2'b10);

endmodule

