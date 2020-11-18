
(* CORE_GENERATION_INFO = "jacobi2d_kernel_jacobi2d_kernel,hls_ip_2019_2,{HLS_INPUT_TYPE=cxx,HLS_INPUT_FLOAT=0,HLS_INPUT_FIXED=0,HLS_INPUT_PART=xcu280-fsvh2892-2L-e,HLS_INPUT_CLOCK=3.330000,HLS_INPUT_ARCH=others,HLS_SYN_CLOCK=1.000000,HLS_SYN_LAT=1,HLS_SYN_TPT=none,HLS_SYN_MEM=0,HLS_SYN_DSP=0,HLS_SYN_FF=852,HLS_SYN_LUT=1527,HLS_VERSION=2019_2}" *)


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
  m_axi_var_input_0_1_ARADDR,
  m_axi_var_input_0_1_ARBURST,
  m_axi_var_input_0_1_ARCACHE,
  m_axi_var_input_0_1_ARID,
  m_axi_var_input_0_1_ARLEN,
  m_axi_var_input_0_1_ARLOCK,
  m_axi_var_input_0_1_ARPROT,
  m_axi_var_input_0_1_ARQOS,
  m_axi_var_input_0_1_ARREADY,
  m_axi_var_input_0_1_ARREGION,
  m_axi_var_input_0_1_ARSIZE,
  m_axi_var_input_0_1_ARUSER,
  m_axi_var_input_0_1_ARVALID,
  m_axi_var_input_0_1_AWADDR,
  m_axi_var_input_0_1_AWBURST,
  m_axi_var_input_0_1_AWCACHE,
  m_axi_var_input_0_1_AWID,
  m_axi_var_input_0_1_AWLEN,
  m_axi_var_input_0_1_AWLOCK,
  m_axi_var_input_0_1_AWPROT,
  m_axi_var_input_0_1_AWQOS,
  m_axi_var_input_0_1_AWREADY,
  m_axi_var_input_0_1_AWREGION,
  m_axi_var_input_0_1_AWSIZE,
  m_axi_var_input_0_1_AWUSER,
  m_axi_var_input_0_1_AWVALID,
  m_axi_var_input_0_1_BID,
  m_axi_var_input_0_1_BREADY,
  m_axi_var_input_0_1_BRESP,
  m_axi_var_input_0_1_BUSER,
  m_axi_var_input_0_1_BVALID,
  m_axi_var_input_0_1_RDATA,
  m_axi_var_input_0_1_RID,
  m_axi_var_input_0_1_RLAST,
  m_axi_var_input_0_1_RREADY,
  m_axi_var_input_0_1_RRESP,
  m_axi_var_input_0_1_RUSER,
  m_axi_var_input_0_1_RVALID,
  m_axi_var_input_0_1_WDATA,
  m_axi_var_input_0_1_WID,
  m_axi_var_input_0_1_WLAST,
  m_axi_var_input_0_1_WREADY,
  m_axi_var_input_0_1_WSTRB,
  m_axi_var_input_0_1_WUSER,
  m_axi_var_input_0_1_WVALID,
  m_axi_var_input_0_2_ARADDR,
  m_axi_var_input_0_2_ARBURST,
  m_axi_var_input_0_2_ARCACHE,
  m_axi_var_input_0_2_ARID,
  m_axi_var_input_0_2_ARLEN,
  m_axi_var_input_0_2_ARLOCK,
  m_axi_var_input_0_2_ARPROT,
  m_axi_var_input_0_2_ARQOS,
  m_axi_var_input_0_2_ARREADY,
  m_axi_var_input_0_2_ARREGION,
  m_axi_var_input_0_2_ARSIZE,
  m_axi_var_input_0_2_ARUSER,
  m_axi_var_input_0_2_ARVALID,
  m_axi_var_input_0_2_AWADDR,
  m_axi_var_input_0_2_AWBURST,
  m_axi_var_input_0_2_AWCACHE,
  m_axi_var_input_0_2_AWID,
  m_axi_var_input_0_2_AWLEN,
  m_axi_var_input_0_2_AWLOCK,
  m_axi_var_input_0_2_AWPROT,
  m_axi_var_input_0_2_AWQOS,
  m_axi_var_input_0_2_AWREADY,
  m_axi_var_input_0_2_AWREGION,
  m_axi_var_input_0_2_AWSIZE,
  m_axi_var_input_0_2_AWUSER,
  m_axi_var_input_0_2_AWVALID,
  m_axi_var_input_0_2_BID,
  m_axi_var_input_0_2_BREADY,
  m_axi_var_input_0_2_BRESP,
  m_axi_var_input_0_2_BUSER,
  m_axi_var_input_0_2_BVALID,
  m_axi_var_input_0_2_RDATA,
  m_axi_var_input_0_2_RID,
  m_axi_var_input_0_2_RLAST,
  m_axi_var_input_0_2_RREADY,
  m_axi_var_input_0_2_RRESP,
  m_axi_var_input_0_2_RUSER,
  m_axi_var_input_0_2_RVALID,
  m_axi_var_input_0_2_WDATA,
  m_axi_var_input_0_2_WID,
  m_axi_var_input_0_2_WLAST,
  m_axi_var_input_0_2_WREADY,
  m_axi_var_input_0_2_WSTRB,
  m_axi_var_input_0_2_WUSER,
  m_axi_var_input_0_2_WVALID,
  m_axi_var_input_0_3_ARADDR,
  m_axi_var_input_0_3_ARBURST,
  m_axi_var_input_0_3_ARCACHE,
  m_axi_var_input_0_3_ARID,
  m_axi_var_input_0_3_ARLEN,
  m_axi_var_input_0_3_ARLOCK,
  m_axi_var_input_0_3_ARPROT,
  m_axi_var_input_0_3_ARQOS,
  m_axi_var_input_0_3_ARREADY,
  m_axi_var_input_0_3_ARREGION,
  m_axi_var_input_0_3_ARSIZE,
  m_axi_var_input_0_3_ARUSER,
  m_axi_var_input_0_3_ARVALID,
  m_axi_var_input_0_3_AWADDR,
  m_axi_var_input_0_3_AWBURST,
  m_axi_var_input_0_3_AWCACHE,
  m_axi_var_input_0_3_AWID,
  m_axi_var_input_0_3_AWLEN,
  m_axi_var_input_0_3_AWLOCK,
  m_axi_var_input_0_3_AWPROT,
  m_axi_var_input_0_3_AWQOS,
  m_axi_var_input_0_3_AWREADY,
  m_axi_var_input_0_3_AWREGION,
  m_axi_var_input_0_3_AWSIZE,
  m_axi_var_input_0_3_AWUSER,
  m_axi_var_input_0_3_AWVALID,
  m_axi_var_input_0_3_BID,
  m_axi_var_input_0_3_BREADY,
  m_axi_var_input_0_3_BRESP,
  m_axi_var_input_0_3_BUSER,
  m_axi_var_input_0_3_BVALID,
  m_axi_var_input_0_3_RDATA,
  m_axi_var_input_0_3_RID,
  m_axi_var_input_0_3_RLAST,
  m_axi_var_input_0_3_RREADY,
  m_axi_var_input_0_3_RRESP,
  m_axi_var_input_0_3_RUSER,
  m_axi_var_input_0_3_RVALID,
  m_axi_var_input_0_3_WDATA,
  m_axi_var_input_0_3_WID,
  m_axi_var_input_0_3_WLAST,
  m_axi_var_input_0_3_WREADY,
  m_axi_var_input_0_3_WSTRB,
  m_axi_var_input_0_3_WUSER,
  m_axi_var_input_0_3_WVALID,
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
  m_axi_var_output_0_0_WVALID,
  m_axi_var_output_0_1_ARADDR,
  m_axi_var_output_0_1_ARBURST,
  m_axi_var_output_0_1_ARCACHE,
  m_axi_var_output_0_1_ARID,
  m_axi_var_output_0_1_ARLEN,
  m_axi_var_output_0_1_ARLOCK,
  m_axi_var_output_0_1_ARPROT,
  m_axi_var_output_0_1_ARQOS,
  m_axi_var_output_0_1_ARREADY,
  m_axi_var_output_0_1_ARREGION,
  m_axi_var_output_0_1_ARSIZE,
  m_axi_var_output_0_1_ARUSER,
  m_axi_var_output_0_1_ARVALID,
  m_axi_var_output_0_1_AWADDR,
  m_axi_var_output_0_1_AWBURST,
  m_axi_var_output_0_1_AWCACHE,
  m_axi_var_output_0_1_AWID,
  m_axi_var_output_0_1_AWLEN,
  m_axi_var_output_0_1_AWLOCK,
  m_axi_var_output_0_1_AWPROT,
  m_axi_var_output_0_1_AWQOS,
  m_axi_var_output_0_1_AWREADY,
  m_axi_var_output_0_1_AWREGION,
  m_axi_var_output_0_1_AWSIZE,
  m_axi_var_output_0_1_AWUSER,
  m_axi_var_output_0_1_AWVALID,
  m_axi_var_output_0_1_BID,
  m_axi_var_output_0_1_BREADY,
  m_axi_var_output_0_1_BRESP,
  m_axi_var_output_0_1_BUSER,
  m_axi_var_output_0_1_BVALID,
  m_axi_var_output_0_1_RDATA,
  m_axi_var_output_0_1_RID,
  m_axi_var_output_0_1_RLAST,
  m_axi_var_output_0_1_RREADY,
  m_axi_var_output_0_1_RRESP,
  m_axi_var_output_0_1_RUSER,
  m_axi_var_output_0_1_RVALID,
  m_axi_var_output_0_1_WDATA,
  m_axi_var_output_0_1_WID,
  m_axi_var_output_0_1_WLAST,
  m_axi_var_output_0_1_WREADY,
  m_axi_var_output_0_1_WSTRB,
  m_axi_var_output_0_1_WUSER,
  m_axi_var_output_0_1_WVALID,
  m_axi_var_output_0_2_ARADDR,
  m_axi_var_output_0_2_ARBURST,
  m_axi_var_output_0_2_ARCACHE,
  m_axi_var_output_0_2_ARID,
  m_axi_var_output_0_2_ARLEN,
  m_axi_var_output_0_2_ARLOCK,
  m_axi_var_output_0_2_ARPROT,
  m_axi_var_output_0_2_ARQOS,
  m_axi_var_output_0_2_ARREADY,
  m_axi_var_output_0_2_ARREGION,
  m_axi_var_output_0_2_ARSIZE,
  m_axi_var_output_0_2_ARUSER,
  m_axi_var_output_0_2_ARVALID,
  m_axi_var_output_0_2_AWADDR,
  m_axi_var_output_0_2_AWBURST,
  m_axi_var_output_0_2_AWCACHE,
  m_axi_var_output_0_2_AWID,
  m_axi_var_output_0_2_AWLEN,
  m_axi_var_output_0_2_AWLOCK,
  m_axi_var_output_0_2_AWPROT,
  m_axi_var_output_0_2_AWQOS,
  m_axi_var_output_0_2_AWREADY,
  m_axi_var_output_0_2_AWREGION,
  m_axi_var_output_0_2_AWSIZE,
  m_axi_var_output_0_2_AWUSER,
  m_axi_var_output_0_2_AWVALID,
  m_axi_var_output_0_2_BID,
  m_axi_var_output_0_2_BREADY,
  m_axi_var_output_0_2_BRESP,
  m_axi_var_output_0_2_BUSER,
  m_axi_var_output_0_2_BVALID,
  m_axi_var_output_0_2_RDATA,
  m_axi_var_output_0_2_RID,
  m_axi_var_output_0_2_RLAST,
  m_axi_var_output_0_2_RREADY,
  m_axi_var_output_0_2_RRESP,
  m_axi_var_output_0_2_RUSER,
  m_axi_var_output_0_2_RVALID,
  m_axi_var_output_0_2_WDATA,
  m_axi_var_output_0_2_WID,
  m_axi_var_output_0_2_WLAST,
  m_axi_var_output_0_2_WREADY,
  m_axi_var_output_0_2_WSTRB,
  m_axi_var_output_0_2_WUSER,
  m_axi_var_output_0_2_WVALID,
  m_axi_var_output_0_3_ARADDR,
  m_axi_var_output_0_3_ARBURST,
  m_axi_var_output_0_3_ARCACHE,
  m_axi_var_output_0_3_ARID,
  m_axi_var_output_0_3_ARLEN,
  m_axi_var_output_0_3_ARLOCK,
  m_axi_var_output_0_3_ARPROT,
  m_axi_var_output_0_3_ARQOS,
  m_axi_var_output_0_3_ARREADY,
  m_axi_var_output_0_3_ARREGION,
  m_axi_var_output_0_3_ARSIZE,
  m_axi_var_output_0_3_ARUSER,
  m_axi_var_output_0_3_ARVALID,
  m_axi_var_output_0_3_AWADDR,
  m_axi_var_output_0_3_AWBURST,
  m_axi_var_output_0_3_AWCACHE,
  m_axi_var_output_0_3_AWID,
  m_axi_var_output_0_3_AWLEN,
  m_axi_var_output_0_3_AWLOCK,
  m_axi_var_output_0_3_AWPROT,
  m_axi_var_output_0_3_AWQOS,
  m_axi_var_output_0_3_AWREADY,
  m_axi_var_output_0_3_AWREGION,
  m_axi_var_output_0_3_AWSIZE,
  m_axi_var_output_0_3_AWUSER,
  m_axi_var_output_0_3_AWVALID,
  m_axi_var_output_0_3_BID,
  m_axi_var_output_0_3_BREADY,
  m_axi_var_output_0_3_BRESP,
  m_axi_var_output_0_3_BUSER,
  m_axi_var_output_0_3_BVALID,
  m_axi_var_output_0_3_RDATA,
  m_axi_var_output_0_3_RID,
  m_axi_var_output_0_3_RLAST,
  m_axi_var_output_0_3_RREADY,
  m_axi_var_output_0_3_RRESP,
  m_axi_var_output_0_3_RUSER,
  m_axi_var_output_0_3_RVALID,
  m_axi_var_output_0_3_WDATA,
  m_axi_var_output_0_3_WID,
  m_axi_var_output_0_3_WLAST,
  m_axi_var_output_0_3_WREADY,
  m_axi_var_output_0_3_WSTRB,
  m_axi_var_output_0_3_WUSER,
  m_axi_var_output_0_3_WVALID
);

  parameter C_S_AXI_CONTROL_DATA_WIDTH = 32;
  parameter C_S_AXI_CONTROL_ADDR_WIDTH = 8;
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
  output [63:0] m_axi_var_input_0_1_ARADDR;
  output [1:0] m_axi_var_input_0_1_ARBURST;
  output [3:0] m_axi_var_input_0_1_ARCACHE;
  output [0:0] m_axi_var_input_0_1_ARID;
  output [7:0] m_axi_var_input_0_1_ARLEN;
  output m_axi_var_input_0_1_ARLOCK;
  output [2:0] m_axi_var_input_0_1_ARPROT;
  output [3:0] m_axi_var_input_0_1_ARQOS;
  input m_axi_var_input_0_1_ARREADY;
  output [3:0] m_axi_var_input_0_1_ARREGION;
  output [2:0] m_axi_var_input_0_1_ARSIZE;
  output m_axi_var_input_0_1_ARUSER;
  output m_axi_var_input_0_1_ARVALID;
  output [63:0] m_axi_var_input_0_1_AWADDR;
  output [1:0] m_axi_var_input_0_1_AWBURST;
  output [3:0] m_axi_var_input_0_1_AWCACHE;
  output [0:0] m_axi_var_input_0_1_AWID;
  output [7:0] m_axi_var_input_0_1_AWLEN;
  output m_axi_var_input_0_1_AWLOCK;
  output [2:0] m_axi_var_input_0_1_AWPROT;
  output [3:0] m_axi_var_input_0_1_AWQOS;
  input m_axi_var_input_0_1_AWREADY;
  output [3:0] m_axi_var_input_0_1_AWREGION;
  output [2:0] m_axi_var_input_0_1_AWSIZE;
  output m_axi_var_input_0_1_AWUSER;
  output m_axi_var_input_0_1_AWVALID;
  input [0:0] m_axi_var_input_0_1_BID;
  output m_axi_var_input_0_1_BREADY;
  input [1:0] m_axi_var_input_0_1_BRESP;
  input m_axi_var_input_0_1_BUSER;
  input m_axi_var_input_0_1_BVALID;
  input [511:0] m_axi_var_input_0_1_RDATA;
  input [0:0] m_axi_var_input_0_1_RID;
  input m_axi_var_input_0_1_RLAST;
  output m_axi_var_input_0_1_RREADY;
  input [1:0] m_axi_var_input_0_1_RRESP;
  input m_axi_var_input_0_1_RUSER;
  input m_axi_var_input_0_1_RVALID;
  output [511:0] m_axi_var_input_0_1_WDATA;
  output [0:0] m_axi_var_input_0_1_WID;
  output m_axi_var_input_0_1_WLAST;
  input m_axi_var_input_0_1_WREADY;
  output [63:0] m_axi_var_input_0_1_WSTRB;
  output m_axi_var_input_0_1_WUSER;
  output m_axi_var_input_0_1_WVALID;
  output [63:0] m_axi_var_input_0_2_ARADDR;
  output [1:0] m_axi_var_input_0_2_ARBURST;
  output [3:0] m_axi_var_input_0_2_ARCACHE;
  output [0:0] m_axi_var_input_0_2_ARID;
  output [7:0] m_axi_var_input_0_2_ARLEN;
  output m_axi_var_input_0_2_ARLOCK;
  output [2:0] m_axi_var_input_0_2_ARPROT;
  output [3:0] m_axi_var_input_0_2_ARQOS;
  input m_axi_var_input_0_2_ARREADY;
  output [3:0] m_axi_var_input_0_2_ARREGION;
  output [2:0] m_axi_var_input_0_2_ARSIZE;
  output m_axi_var_input_0_2_ARUSER;
  output m_axi_var_input_0_2_ARVALID;
  output [63:0] m_axi_var_input_0_2_AWADDR;
  output [1:0] m_axi_var_input_0_2_AWBURST;
  output [3:0] m_axi_var_input_0_2_AWCACHE;
  output [0:0] m_axi_var_input_0_2_AWID;
  output [7:0] m_axi_var_input_0_2_AWLEN;
  output m_axi_var_input_0_2_AWLOCK;
  output [2:0] m_axi_var_input_0_2_AWPROT;
  output [3:0] m_axi_var_input_0_2_AWQOS;
  input m_axi_var_input_0_2_AWREADY;
  output [3:0] m_axi_var_input_0_2_AWREGION;
  output [2:0] m_axi_var_input_0_2_AWSIZE;
  output m_axi_var_input_0_2_AWUSER;
  output m_axi_var_input_0_2_AWVALID;
  input [0:0] m_axi_var_input_0_2_BID;
  output m_axi_var_input_0_2_BREADY;
  input [1:0] m_axi_var_input_0_2_BRESP;
  input m_axi_var_input_0_2_BUSER;
  input m_axi_var_input_0_2_BVALID;
  input [511:0] m_axi_var_input_0_2_RDATA;
  input [0:0] m_axi_var_input_0_2_RID;
  input m_axi_var_input_0_2_RLAST;
  output m_axi_var_input_0_2_RREADY;
  input [1:0] m_axi_var_input_0_2_RRESP;
  input m_axi_var_input_0_2_RUSER;
  input m_axi_var_input_0_2_RVALID;
  output [511:0] m_axi_var_input_0_2_WDATA;
  output [0:0] m_axi_var_input_0_2_WID;
  output m_axi_var_input_0_2_WLAST;
  input m_axi_var_input_0_2_WREADY;
  output [63:0] m_axi_var_input_0_2_WSTRB;
  output m_axi_var_input_0_2_WUSER;
  output m_axi_var_input_0_2_WVALID;
  output [63:0] m_axi_var_input_0_3_ARADDR;
  output [1:0] m_axi_var_input_0_3_ARBURST;
  output [3:0] m_axi_var_input_0_3_ARCACHE;
  output [0:0] m_axi_var_input_0_3_ARID;
  output [7:0] m_axi_var_input_0_3_ARLEN;
  output m_axi_var_input_0_3_ARLOCK;
  output [2:0] m_axi_var_input_0_3_ARPROT;
  output [3:0] m_axi_var_input_0_3_ARQOS;
  input m_axi_var_input_0_3_ARREADY;
  output [3:0] m_axi_var_input_0_3_ARREGION;
  output [2:0] m_axi_var_input_0_3_ARSIZE;
  output m_axi_var_input_0_3_ARUSER;
  output m_axi_var_input_0_3_ARVALID;
  output [63:0] m_axi_var_input_0_3_AWADDR;
  output [1:0] m_axi_var_input_0_3_AWBURST;
  output [3:0] m_axi_var_input_0_3_AWCACHE;
  output [0:0] m_axi_var_input_0_3_AWID;
  output [7:0] m_axi_var_input_0_3_AWLEN;
  output m_axi_var_input_0_3_AWLOCK;
  output [2:0] m_axi_var_input_0_3_AWPROT;
  output [3:0] m_axi_var_input_0_3_AWQOS;
  input m_axi_var_input_0_3_AWREADY;
  output [3:0] m_axi_var_input_0_3_AWREGION;
  output [2:0] m_axi_var_input_0_3_AWSIZE;
  output m_axi_var_input_0_3_AWUSER;
  output m_axi_var_input_0_3_AWVALID;
  input [0:0] m_axi_var_input_0_3_BID;
  output m_axi_var_input_0_3_BREADY;
  input [1:0] m_axi_var_input_0_3_BRESP;
  input m_axi_var_input_0_3_BUSER;
  input m_axi_var_input_0_3_BVALID;
  input [511:0] m_axi_var_input_0_3_RDATA;
  input [0:0] m_axi_var_input_0_3_RID;
  input m_axi_var_input_0_3_RLAST;
  output m_axi_var_input_0_3_RREADY;
  input [1:0] m_axi_var_input_0_3_RRESP;
  input m_axi_var_input_0_3_RUSER;
  input m_axi_var_input_0_3_RVALID;
  output [511:0] m_axi_var_input_0_3_WDATA;
  output [0:0] m_axi_var_input_0_3_WID;
  output m_axi_var_input_0_3_WLAST;
  input m_axi_var_input_0_3_WREADY;
  output [63:0] m_axi_var_input_0_3_WSTRB;
  output m_axi_var_input_0_3_WUSER;
  output m_axi_var_input_0_3_WVALID;
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
  output [63:0] m_axi_var_output_0_1_ARADDR;
  output [1:0] m_axi_var_output_0_1_ARBURST;
  output [3:0] m_axi_var_output_0_1_ARCACHE;
  output [0:0] m_axi_var_output_0_1_ARID;
  output [7:0] m_axi_var_output_0_1_ARLEN;
  output m_axi_var_output_0_1_ARLOCK;
  output [2:0] m_axi_var_output_0_1_ARPROT;
  output [3:0] m_axi_var_output_0_1_ARQOS;
  input m_axi_var_output_0_1_ARREADY;
  output [3:0] m_axi_var_output_0_1_ARREGION;
  output [2:0] m_axi_var_output_0_1_ARSIZE;
  output m_axi_var_output_0_1_ARUSER;
  output m_axi_var_output_0_1_ARVALID;
  output [63:0] m_axi_var_output_0_1_AWADDR;
  output [1:0] m_axi_var_output_0_1_AWBURST;
  output [3:0] m_axi_var_output_0_1_AWCACHE;
  output [0:0] m_axi_var_output_0_1_AWID;
  output [7:0] m_axi_var_output_0_1_AWLEN;
  output m_axi_var_output_0_1_AWLOCK;
  output [2:0] m_axi_var_output_0_1_AWPROT;
  output [3:0] m_axi_var_output_0_1_AWQOS;
  input m_axi_var_output_0_1_AWREADY;
  output [3:0] m_axi_var_output_0_1_AWREGION;
  output [2:0] m_axi_var_output_0_1_AWSIZE;
  output m_axi_var_output_0_1_AWUSER;
  output m_axi_var_output_0_1_AWVALID;
  input [0:0] m_axi_var_output_0_1_BID;
  output m_axi_var_output_0_1_BREADY;
  input [1:0] m_axi_var_output_0_1_BRESP;
  input m_axi_var_output_0_1_BUSER;
  input m_axi_var_output_0_1_BVALID;
  input [511:0] m_axi_var_output_0_1_RDATA;
  input [0:0] m_axi_var_output_0_1_RID;
  input m_axi_var_output_0_1_RLAST;
  output m_axi_var_output_0_1_RREADY;
  input [1:0] m_axi_var_output_0_1_RRESP;
  input m_axi_var_output_0_1_RUSER;
  input m_axi_var_output_0_1_RVALID;
  output [511:0] m_axi_var_output_0_1_WDATA;
  output [0:0] m_axi_var_output_0_1_WID;
  output m_axi_var_output_0_1_WLAST;
  input m_axi_var_output_0_1_WREADY;
  output [63:0] m_axi_var_output_0_1_WSTRB;
  output m_axi_var_output_0_1_WUSER;
  output m_axi_var_output_0_1_WVALID;
  output [63:0] m_axi_var_output_0_2_ARADDR;
  output [1:0] m_axi_var_output_0_2_ARBURST;
  output [3:0] m_axi_var_output_0_2_ARCACHE;
  output [0:0] m_axi_var_output_0_2_ARID;
  output [7:0] m_axi_var_output_0_2_ARLEN;
  output m_axi_var_output_0_2_ARLOCK;
  output [2:0] m_axi_var_output_0_2_ARPROT;
  output [3:0] m_axi_var_output_0_2_ARQOS;
  input m_axi_var_output_0_2_ARREADY;
  output [3:0] m_axi_var_output_0_2_ARREGION;
  output [2:0] m_axi_var_output_0_2_ARSIZE;
  output m_axi_var_output_0_2_ARUSER;
  output m_axi_var_output_0_2_ARVALID;
  output [63:0] m_axi_var_output_0_2_AWADDR;
  output [1:0] m_axi_var_output_0_2_AWBURST;
  output [3:0] m_axi_var_output_0_2_AWCACHE;
  output [0:0] m_axi_var_output_0_2_AWID;
  output [7:0] m_axi_var_output_0_2_AWLEN;
  output m_axi_var_output_0_2_AWLOCK;
  output [2:0] m_axi_var_output_0_2_AWPROT;
  output [3:0] m_axi_var_output_0_2_AWQOS;
  input m_axi_var_output_0_2_AWREADY;
  output [3:0] m_axi_var_output_0_2_AWREGION;
  output [2:0] m_axi_var_output_0_2_AWSIZE;
  output m_axi_var_output_0_2_AWUSER;
  output m_axi_var_output_0_2_AWVALID;
  input [0:0] m_axi_var_output_0_2_BID;
  output m_axi_var_output_0_2_BREADY;
  input [1:0] m_axi_var_output_0_2_BRESP;
  input m_axi_var_output_0_2_BUSER;
  input m_axi_var_output_0_2_BVALID;
  input [511:0] m_axi_var_output_0_2_RDATA;
  input [0:0] m_axi_var_output_0_2_RID;
  input m_axi_var_output_0_2_RLAST;
  output m_axi_var_output_0_2_RREADY;
  input [1:0] m_axi_var_output_0_2_RRESP;
  input m_axi_var_output_0_2_RUSER;
  input m_axi_var_output_0_2_RVALID;
  output [511:0] m_axi_var_output_0_2_WDATA;
  output [0:0] m_axi_var_output_0_2_WID;
  output m_axi_var_output_0_2_WLAST;
  input m_axi_var_output_0_2_WREADY;
  output [63:0] m_axi_var_output_0_2_WSTRB;
  output m_axi_var_output_0_2_WUSER;
  output m_axi_var_output_0_2_WVALID;
  output [63:0] m_axi_var_output_0_3_ARADDR;
  output [1:0] m_axi_var_output_0_3_ARBURST;
  output [3:0] m_axi_var_output_0_3_ARCACHE;
  output [0:0] m_axi_var_output_0_3_ARID;
  output [7:0] m_axi_var_output_0_3_ARLEN;
  output m_axi_var_output_0_3_ARLOCK;
  output [2:0] m_axi_var_output_0_3_ARPROT;
  output [3:0] m_axi_var_output_0_3_ARQOS;
  input m_axi_var_output_0_3_ARREADY;
  output [3:0] m_axi_var_output_0_3_ARREGION;
  output [2:0] m_axi_var_output_0_3_ARSIZE;
  output m_axi_var_output_0_3_ARUSER;
  output m_axi_var_output_0_3_ARVALID;
  output [63:0] m_axi_var_output_0_3_AWADDR;
  output [1:0] m_axi_var_output_0_3_AWBURST;
  output [3:0] m_axi_var_output_0_3_AWCACHE;
  output [0:0] m_axi_var_output_0_3_AWID;
  output [7:0] m_axi_var_output_0_3_AWLEN;
  output m_axi_var_output_0_3_AWLOCK;
  output [2:0] m_axi_var_output_0_3_AWPROT;
  output [3:0] m_axi_var_output_0_3_AWQOS;
  input m_axi_var_output_0_3_AWREADY;
  output [3:0] m_axi_var_output_0_3_AWREGION;
  output [2:0] m_axi_var_output_0_3_AWSIZE;
  output m_axi_var_output_0_3_AWUSER;
  output m_axi_var_output_0_3_AWVALID;
  input [0:0] m_axi_var_output_0_3_BID;
  output m_axi_var_output_0_3_BREADY;
  input [1:0] m_axi_var_output_0_3_BRESP;
  input m_axi_var_output_0_3_BUSER;
  input m_axi_var_output_0_3_BVALID;
  input [511:0] m_axi_var_output_0_3_RDATA;
  input [0:0] m_axi_var_output_0_3_RID;
  input m_axi_var_output_0_3_RLAST;
  output m_axi_var_output_0_3_RREADY;
  input [1:0] m_axi_var_output_0_3_RRESP;
  input m_axi_var_output_0_3_RUSER;
  input m_axi_var_output_0_3_RVALID;
  output [511:0] m_axi_var_output_0_3_WDATA;
  output [0:0] m_axi_var_output_0_3_WID;
  output m_axi_var_output_0_3_WLAST;
  input m_axi_var_output_0_3_WREADY;
  output [63:0] m_axi_var_output_0_3_WSTRB;
  output m_axi_var_output_0_3_WUSER;
  output m_axi_var_output_0_3_WVALID;
  wire ap_start;
  wire [63:0] var_output_0_0;
  wire [63:0] var_output_0_1;
  wire [63:0] var_output_0_2;
  wire [63:0] var_output_0_3;
  wire [63:0] var_input_0_0;
  wire [63:0] var_input_0_1;
  wire [63:0] var_input_0_2;
  wire [63:0] var_input_0_3;
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
  (* dont_touch = "yes" *)
  reg ap_rst_n__q4;
  (* dont_touch = "yes" *)
  reg ap_rst_n__q5;
  (* dont_touch = "yes" *)
  reg ap_rst_n__q6;
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
  (* dont_touch = "yes" *)
  reg input_stream_0_0__rst__q4;
  (* dont_touch = "yes" *)
  reg input_stream_0_0__rst__q5;
  (* dont_touch = "yes" *)
  reg input_stream_0_0__rst__q6;
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
  (* dont_touch = "yes" *)
  reg input_stream_0_1__rst__q4;
  (* dont_touch = "yes" *)
  reg input_stream_0_1__rst__q5;
  (* dont_touch = "yes" *)
  reg input_stream_0_1__rst__q6;
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
  (* dont_touch = "yes" *)
  reg input_stream_0_2__rst__q4;
  (* dont_touch = "yes" *)
  reg input_stream_0_2__rst__q5;
  (* dont_touch = "yes" *)
  reg input_stream_0_2__rst__q6;
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
  (* dont_touch = "yes" *)
  reg input_stream_0_3__rst__q4;
  (* dont_touch = "yes" *)
  reg input_stream_0_3__rst__q5;
  (* dont_touch = "yes" *)
  reg input_stream_0_3__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_0_0__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_0_0__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_0_0__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_0_1__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_0_1__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_0_1__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_0_2__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_0_2__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_0_2__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_0_3__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_0_3__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_0_3__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_1_0__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_1_0__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_1_0__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_1_1__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_1_1__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_1_1__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_1_2__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_1_2__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_1_2__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_1_3__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_1_3__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_1_3__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_2_0__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_2_0__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_2_0__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_2_1__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_2_1__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_2_1__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_2_2__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_2_2__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_2_2__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_2_3__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_2_3__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_2_3__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_3_0__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_3_0__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_3_0__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_3_1__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_3_1__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_3_1__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_3_2__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_3_2__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_3_2__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_3_3__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_3_3__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_3_3__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_4_0__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_4_0__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_4_0__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_4_1__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_4_1__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_4_1__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_4_2__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_4_2__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_4_2__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_4_3__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_4_3__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_4_3__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_5_0__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_5_0__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_5_0__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_5_1__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_5_1__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_5_1__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_5_2__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_5_2__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_5_2__rst__q6;
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
  (* dont_touch = "yes" *)
  reg output_stream_5_3__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_5_3__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_5_3__rst__q6;
  wire [512:0] output_stream_6_0__dout;
  wire output_stream_6_0__empty_n;
  wire output_stream_6_0__read;
  wire [512:0] output_stream_6_0__din;
  wire output_stream_6_0__full_n;
  wire output_stream_6_0__write;
  wire output_stream_6_0__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_6_0__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_6_0__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_6_0__rst__q3;
  (* dont_touch = "yes" *)
  reg output_stream_6_0__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_6_0__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_6_0__rst__q6;
  wire [512:0] output_stream_6_1__dout;
  wire output_stream_6_1__empty_n;
  wire output_stream_6_1__read;
  wire [512:0] output_stream_6_1__din;
  wire output_stream_6_1__full_n;
  wire output_stream_6_1__write;
  wire output_stream_6_1__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_6_1__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_6_1__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_6_1__rst__q3;
  (* dont_touch = "yes" *)
  reg output_stream_6_1__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_6_1__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_6_1__rst__q6;
  wire [512:0] output_stream_6_2__dout;
  wire output_stream_6_2__empty_n;
  wire output_stream_6_2__read;
  wire [512:0] output_stream_6_2__din;
  wire output_stream_6_2__full_n;
  wire output_stream_6_2__write;
  wire output_stream_6_2__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_6_2__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_6_2__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_6_2__rst__q3;
  (* dont_touch = "yes" *)
  reg output_stream_6_2__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_6_2__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_6_2__rst__q6;
  wire [512:0] output_stream_6_3__dout;
  wire output_stream_6_3__empty_n;
  wire output_stream_6_3__read;
  wire [512:0] output_stream_6_3__din;
  wire output_stream_6_3__full_n;
  wire output_stream_6_3__write;
  wire output_stream_6_3__rst__q0;
  (* dont_touch = "yes" *)
  reg output_stream_6_3__rst__q1;
  (* dont_touch = "yes" *)
  reg output_stream_6_3__rst__q2;
  (* dont_touch = "yes" *)
  reg output_stream_6_3__rst__q3;
  (* dont_touch = "yes" *)
  reg output_stream_6_3__rst__q4;
  (* dont_touch = "yes" *)
  reg output_stream_6_3__rst__q5;
  (* dont_touch = "yes" *)
  reg output_stream_6_3__rst__q6;
  wire [63:0] compute_0___coalesced_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_0___coalesced_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_0___coalesced_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_0___coalesced_data_num__q3;
  (* dont_touch = "yes" *)
  reg [63:0] compute_0___coalesced_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] compute_0___coalesced_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] compute_0___coalesced_data_num__q6;
  wire [31:0] compute_0___input_size_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___input_size_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___input_size_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___input_size_dim_0__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___input_size_dim_0__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___input_size_dim_0__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___input_size_dim_0__q6;
  wire [31:0] compute_0___input_size_dim_1__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___input_size_dim_1__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___input_size_dim_1__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___input_size_dim_1__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___input_size_dim_1__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___input_size_dim_1__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___input_size_dim_1__q6;
  wire [63:0] compute_0___tile_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_0___tile_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_0___tile_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_0___tile_data_num__q3;
  (* dont_touch = "yes" *)
  reg [63:0] compute_0___tile_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] compute_0___tile_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] compute_0___tile_data_num__q6;
  wire [31:0] compute_0___tile_num_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___tile_num_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___tile_num_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___tile_num_dim_0__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___tile_num_dim_0__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___tile_num_dim_0__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_0___tile_num_dim_0__q6;
  wire compute_0__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg compute_0__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg compute_0__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg compute_0__ap_rst_n__q3;
  (* dont_touch = "yes" *)
  reg compute_0__ap_rst_n__q4;
  (* dont_touch = "yes" *)
  reg compute_0__ap_rst_n__q5;
  (* dont_touch = "yes" *)
  reg compute_0__ap_rst_n__q6;
  wire compute_0__is_done__q0;
  (* dont_touch = "yes" *)
  reg compute_0__is_done__q1;
  (* dont_touch = "yes" *)
  reg compute_0__is_done__q2;
  (* dont_touch = "yes" *)
  reg compute_0__is_done__q3;
  (* dont_touch = "yes" *)
  reg compute_0__is_done__q4;
  (* dont_touch = "yes" *)
  reg compute_0__is_done__q5;
  (* dont_touch = "yes" *)
  reg compute_0__is_done__q6;
  wire compute_0__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg compute_0__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg compute_0__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg compute_0__ap_start_global__q3;
  (* dont_touch = "yes" *)
  reg compute_0__ap_start_global__q4;
  (* dont_touch = "yes" *)
  reg compute_0__ap_start_global__q5;
  (* dont_touch = "yes" *)
  reg compute_0__ap_start_global__q6;
  wire compute_0__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg compute_0__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg compute_0__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg compute_0__ap_done_global__q3;
  (* dont_touch = "yes" *)
  reg compute_0__ap_done_global__q4;
  (* dont_touch = "yes" *)
  reg compute_0__ap_done_global__q5;
  (* dont_touch = "yes" *)
  reg compute_0__ap_done_global__q6;
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
  (* dont_touch = "yes" *)
  reg [63:0] compute_1___coalesced_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] compute_1___coalesced_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] compute_1___coalesced_data_num__q6;
  wire [31:0] compute_1___input_size_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___input_size_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___input_size_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___input_size_dim_0__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___input_size_dim_0__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___input_size_dim_0__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___input_size_dim_0__q6;
  wire [31:0] compute_1___input_size_dim_1__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___input_size_dim_1__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___input_size_dim_1__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___input_size_dim_1__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___input_size_dim_1__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___input_size_dim_1__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___input_size_dim_1__q6;
  wire [63:0] compute_1___tile_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_1___tile_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_1___tile_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_1___tile_data_num__q3;
  (* dont_touch = "yes" *)
  reg [63:0] compute_1___tile_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] compute_1___tile_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] compute_1___tile_data_num__q6;
  wire [31:0] compute_1___tile_num_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___tile_num_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___tile_num_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___tile_num_dim_0__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___tile_num_dim_0__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___tile_num_dim_0__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_1___tile_num_dim_0__q6;
  wire compute_1__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg compute_1__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg compute_1__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg compute_1__ap_rst_n__q3;
  (* dont_touch = "yes" *)
  reg compute_1__ap_rst_n__q4;
  (* dont_touch = "yes" *)
  reg compute_1__ap_rst_n__q5;
  (* dont_touch = "yes" *)
  reg compute_1__ap_rst_n__q6;
  wire compute_1__is_done__q0;
  (* dont_touch = "yes" *)
  reg compute_1__is_done__q1;
  (* dont_touch = "yes" *)
  reg compute_1__is_done__q2;
  (* dont_touch = "yes" *)
  reg compute_1__is_done__q3;
  (* dont_touch = "yes" *)
  reg compute_1__is_done__q4;
  (* dont_touch = "yes" *)
  reg compute_1__is_done__q5;
  (* dont_touch = "yes" *)
  reg compute_1__is_done__q6;
  wire compute_1__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg compute_1__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg compute_1__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg compute_1__ap_start_global__q3;
  (* dont_touch = "yes" *)
  reg compute_1__ap_start_global__q4;
  (* dont_touch = "yes" *)
  reg compute_1__ap_start_global__q5;
  (* dont_touch = "yes" *)
  reg compute_1__ap_start_global__q6;
  wire compute_1__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg compute_1__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg compute_1__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg compute_1__ap_done_global__q3;
  (* dont_touch = "yes" *)
  reg compute_1__ap_done_global__q4;
  (* dont_touch = "yes" *)
  reg compute_1__ap_done_global__q5;
  (* dont_touch = "yes" *)
  reg compute_1__ap_done_global__q6;
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
  (* dont_touch = "yes" *)
  reg [63:0] compute_2___coalesced_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] compute_2___coalesced_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] compute_2___coalesced_data_num__q6;
  wire [31:0] compute_2___input_size_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___input_size_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___input_size_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___input_size_dim_0__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___input_size_dim_0__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___input_size_dim_0__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___input_size_dim_0__q6;
  wire [31:0] compute_2___input_size_dim_1__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___input_size_dim_1__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___input_size_dim_1__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___input_size_dim_1__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___input_size_dim_1__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___input_size_dim_1__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___input_size_dim_1__q6;
  wire [63:0] compute_2___tile_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_2___tile_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_2___tile_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_2___tile_data_num__q3;
  (* dont_touch = "yes" *)
  reg [63:0] compute_2___tile_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] compute_2___tile_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] compute_2___tile_data_num__q6;
  wire [31:0] compute_2___tile_num_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___tile_num_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___tile_num_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___tile_num_dim_0__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___tile_num_dim_0__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___tile_num_dim_0__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_2___tile_num_dim_0__q6;
  wire compute_2__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg compute_2__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg compute_2__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg compute_2__ap_rst_n__q3;
  (* dont_touch = "yes" *)
  reg compute_2__ap_rst_n__q4;
  (* dont_touch = "yes" *)
  reg compute_2__ap_rst_n__q5;
  (* dont_touch = "yes" *)
  reg compute_2__ap_rst_n__q6;
  wire compute_2__is_done__q0;
  (* dont_touch = "yes" *)
  reg compute_2__is_done__q1;
  (* dont_touch = "yes" *)
  reg compute_2__is_done__q2;
  (* dont_touch = "yes" *)
  reg compute_2__is_done__q3;
  (* dont_touch = "yes" *)
  reg compute_2__is_done__q4;
  (* dont_touch = "yes" *)
  reg compute_2__is_done__q5;
  (* dont_touch = "yes" *)
  reg compute_2__is_done__q6;
  wire compute_2__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg compute_2__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg compute_2__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg compute_2__ap_start_global__q3;
  (* dont_touch = "yes" *)
  reg compute_2__ap_start_global__q4;
  (* dont_touch = "yes" *)
  reg compute_2__ap_start_global__q5;
  (* dont_touch = "yes" *)
  reg compute_2__ap_start_global__q6;
  wire compute_2__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg compute_2__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg compute_2__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg compute_2__ap_done_global__q3;
  (* dont_touch = "yes" *)
  reg compute_2__ap_done_global__q4;
  (* dont_touch = "yes" *)
  reg compute_2__ap_done_global__q5;
  (* dont_touch = "yes" *)
  reg compute_2__ap_done_global__q6;
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
  (* dont_touch = "yes" *)
  reg [63:0] compute_3___coalesced_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] compute_3___coalesced_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] compute_3___coalesced_data_num__q6;
  wire [31:0] compute_3___input_size_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___input_size_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___input_size_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___input_size_dim_0__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___input_size_dim_0__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___input_size_dim_0__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___input_size_dim_0__q6;
  wire [31:0] compute_3___input_size_dim_1__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___input_size_dim_1__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___input_size_dim_1__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___input_size_dim_1__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___input_size_dim_1__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___input_size_dim_1__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___input_size_dim_1__q6;
  wire [63:0] compute_3___tile_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_3___tile_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_3___tile_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_3___tile_data_num__q3;
  (* dont_touch = "yes" *)
  reg [63:0] compute_3___tile_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] compute_3___tile_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] compute_3___tile_data_num__q6;
  wire [31:0] compute_3___tile_num_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___tile_num_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___tile_num_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___tile_num_dim_0__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___tile_num_dim_0__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___tile_num_dim_0__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_3___tile_num_dim_0__q6;
  wire compute_3__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg compute_3__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg compute_3__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg compute_3__ap_rst_n__q3;
  (* dont_touch = "yes" *)
  reg compute_3__ap_rst_n__q4;
  (* dont_touch = "yes" *)
  reg compute_3__ap_rst_n__q5;
  (* dont_touch = "yes" *)
  reg compute_3__ap_rst_n__q6;
  wire compute_3__is_done__q0;
  (* dont_touch = "yes" *)
  reg compute_3__is_done__q1;
  (* dont_touch = "yes" *)
  reg compute_3__is_done__q2;
  (* dont_touch = "yes" *)
  reg compute_3__is_done__q3;
  (* dont_touch = "yes" *)
  reg compute_3__is_done__q4;
  (* dont_touch = "yes" *)
  reg compute_3__is_done__q5;
  (* dont_touch = "yes" *)
  reg compute_3__is_done__q6;
  wire compute_3__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg compute_3__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg compute_3__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg compute_3__ap_start_global__q3;
  (* dont_touch = "yes" *)
  reg compute_3__ap_start_global__q4;
  (* dont_touch = "yes" *)
  reg compute_3__ap_start_global__q5;
  (* dont_touch = "yes" *)
  reg compute_3__ap_start_global__q6;
  wire compute_3__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg compute_3__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg compute_3__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg compute_3__ap_done_global__q3;
  (* dont_touch = "yes" *)
  reg compute_3__ap_done_global__q4;
  (* dont_touch = "yes" *)
  reg compute_3__ap_done_global__q5;
  (* dont_touch = "yes" *)
  reg compute_3__ap_done_global__q6;
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
  (* dont_touch = "yes" *)
  reg [63:0] compute_4___coalesced_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] compute_4___coalesced_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] compute_4___coalesced_data_num__q6;
  wire [31:0] compute_4___input_size_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___input_size_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___input_size_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___input_size_dim_0__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___input_size_dim_0__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___input_size_dim_0__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___input_size_dim_0__q6;
  wire [31:0] compute_4___input_size_dim_1__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___input_size_dim_1__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___input_size_dim_1__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___input_size_dim_1__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___input_size_dim_1__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___input_size_dim_1__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___input_size_dim_1__q6;
  wire [63:0] compute_4___tile_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_4___tile_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_4___tile_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_4___tile_data_num__q3;
  (* dont_touch = "yes" *)
  reg [63:0] compute_4___tile_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] compute_4___tile_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] compute_4___tile_data_num__q6;
  wire [31:0] compute_4___tile_num_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___tile_num_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___tile_num_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___tile_num_dim_0__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___tile_num_dim_0__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___tile_num_dim_0__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_4___tile_num_dim_0__q6;
  wire compute_4__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg compute_4__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg compute_4__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg compute_4__ap_rst_n__q3;
  (* dont_touch = "yes" *)
  reg compute_4__ap_rst_n__q4;
  (* dont_touch = "yes" *)
  reg compute_4__ap_rst_n__q5;
  (* dont_touch = "yes" *)
  reg compute_4__ap_rst_n__q6;
  wire compute_4__is_done__q0;
  (* dont_touch = "yes" *)
  reg compute_4__is_done__q1;
  (* dont_touch = "yes" *)
  reg compute_4__is_done__q2;
  (* dont_touch = "yes" *)
  reg compute_4__is_done__q3;
  (* dont_touch = "yes" *)
  reg compute_4__is_done__q4;
  (* dont_touch = "yes" *)
  reg compute_4__is_done__q5;
  (* dont_touch = "yes" *)
  reg compute_4__is_done__q6;
  wire compute_4__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg compute_4__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg compute_4__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg compute_4__ap_start_global__q3;
  (* dont_touch = "yes" *)
  reg compute_4__ap_start_global__q4;
  (* dont_touch = "yes" *)
  reg compute_4__ap_start_global__q5;
  (* dont_touch = "yes" *)
  reg compute_4__ap_start_global__q6;
  wire compute_4__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg compute_4__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg compute_4__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg compute_4__ap_done_global__q3;
  (* dont_touch = "yes" *)
  reg compute_4__ap_done_global__q4;
  (* dont_touch = "yes" *)
  reg compute_4__ap_done_global__q5;
  (* dont_touch = "yes" *)
  reg compute_4__ap_done_global__q6;
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
  (* dont_touch = "yes" *)
  reg [63:0] compute_5___coalesced_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] compute_5___coalesced_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] compute_5___coalesced_data_num__q6;
  wire [31:0] compute_5___input_size_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___input_size_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___input_size_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___input_size_dim_0__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___input_size_dim_0__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___input_size_dim_0__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___input_size_dim_0__q6;
  wire [31:0] compute_5___input_size_dim_1__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___input_size_dim_1__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___input_size_dim_1__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___input_size_dim_1__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___input_size_dim_1__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___input_size_dim_1__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___input_size_dim_1__q6;
  wire [63:0] compute_5___tile_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_5___tile_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_5___tile_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_5___tile_data_num__q3;
  (* dont_touch = "yes" *)
  reg [63:0] compute_5___tile_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] compute_5___tile_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] compute_5___tile_data_num__q6;
  wire [31:0] compute_5___tile_num_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___tile_num_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___tile_num_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___tile_num_dim_0__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___tile_num_dim_0__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___tile_num_dim_0__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_5___tile_num_dim_0__q6;
  wire compute_5__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg compute_5__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg compute_5__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg compute_5__ap_rst_n__q3;
  (* dont_touch = "yes" *)
  reg compute_5__ap_rst_n__q4;
  (* dont_touch = "yes" *)
  reg compute_5__ap_rst_n__q5;
  (* dont_touch = "yes" *)
  reg compute_5__ap_rst_n__q6;
  wire compute_5__is_done__q0;
  (* dont_touch = "yes" *)
  reg compute_5__is_done__q1;
  (* dont_touch = "yes" *)
  reg compute_5__is_done__q2;
  (* dont_touch = "yes" *)
  reg compute_5__is_done__q3;
  (* dont_touch = "yes" *)
  reg compute_5__is_done__q4;
  (* dont_touch = "yes" *)
  reg compute_5__is_done__q5;
  (* dont_touch = "yes" *)
  reg compute_5__is_done__q6;
  wire compute_5__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg compute_5__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg compute_5__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg compute_5__ap_start_global__q3;
  (* dont_touch = "yes" *)
  reg compute_5__ap_start_global__q4;
  (* dont_touch = "yes" *)
  reg compute_5__ap_start_global__q5;
  (* dont_touch = "yes" *)
  reg compute_5__ap_start_global__q6;
  wire compute_5__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg compute_5__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg compute_5__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg compute_5__ap_done_global__q3;
  (* dont_touch = "yes" *)
  reg compute_5__ap_done_global__q4;
  (* dont_touch = "yes" *)
  reg compute_5__ap_done_global__q5;
  (* dont_touch = "yes" *)
  reg compute_5__ap_done_global__q6;
  wire compute_5__ap_start;
  reg [1:0] compute_5__state;
  wire compute_5__ap_done;
  wire compute_5__ap_idle;
  wire compute_5__ap_ready;
  wire [63:0] compute_6___coalesced_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_6___coalesced_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_6___coalesced_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_6___coalesced_data_num__q3;
  (* dont_touch = "yes" *)
  reg [63:0] compute_6___coalesced_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] compute_6___coalesced_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] compute_6___coalesced_data_num__q6;
  wire [31:0] compute_6___input_size_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_6___input_size_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_6___input_size_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_6___input_size_dim_0__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_6___input_size_dim_0__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_6___input_size_dim_0__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_6___input_size_dim_0__q6;
  wire [31:0] compute_6___input_size_dim_1__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_6___input_size_dim_1__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_6___input_size_dim_1__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_6___input_size_dim_1__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_6___input_size_dim_1__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_6___input_size_dim_1__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_6___input_size_dim_1__q6;
  wire [63:0] compute_6___tile_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] compute_6___tile_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] compute_6___tile_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] compute_6___tile_data_num__q3;
  (* dont_touch = "yes" *)
  reg [63:0] compute_6___tile_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] compute_6___tile_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] compute_6___tile_data_num__q6;
  wire [31:0] compute_6___tile_num_dim_0__q0;
  (* dont_touch = "yes" *)
  reg [31:0] compute_6___tile_num_dim_0__q1;
  (* dont_touch = "yes" *)
  reg [31:0] compute_6___tile_num_dim_0__q2;
  (* dont_touch = "yes" *)
  reg [31:0] compute_6___tile_num_dim_0__q3;
  (* dont_touch = "yes" *)
  reg [31:0] compute_6___tile_num_dim_0__q4;
  (* dont_touch = "yes" *)
  reg [31:0] compute_6___tile_num_dim_0__q5;
  (* dont_touch = "yes" *)
  reg [31:0] compute_6___tile_num_dim_0__q6;
  wire compute_6__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg compute_6__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg compute_6__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg compute_6__ap_rst_n__q3;
  (* dont_touch = "yes" *)
  reg compute_6__ap_rst_n__q4;
  (* dont_touch = "yes" *)
  reg compute_6__ap_rst_n__q5;
  (* dont_touch = "yes" *)
  reg compute_6__ap_rst_n__q6;
  wire compute_6__is_done__q0;
  (* dont_touch = "yes" *)
  reg compute_6__is_done__q1;
  (* dont_touch = "yes" *)
  reg compute_6__is_done__q2;
  (* dont_touch = "yes" *)
  reg compute_6__is_done__q3;
  (* dont_touch = "yes" *)
  reg compute_6__is_done__q4;
  (* dont_touch = "yes" *)
  reg compute_6__is_done__q5;
  (* dont_touch = "yes" *)
  reg compute_6__is_done__q6;
  wire compute_6__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg compute_6__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg compute_6__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg compute_6__ap_start_global__q3;
  (* dont_touch = "yes" *)
  reg compute_6__ap_start_global__q4;
  (* dont_touch = "yes" *)
  reg compute_6__ap_start_global__q5;
  (* dont_touch = "yes" *)
  reg compute_6__ap_start_global__q6;
  wire compute_6__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg compute_6__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg compute_6__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg compute_6__ap_done_global__q3;
  (* dont_touch = "yes" *)
  reg compute_6__ap_done_global__q4;
  (* dont_touch = "yes" *)
  reg compute_6__ap_done_global__q5;
  (* dont_touch = "yes" *)
  reg compute_6__ap_done_global__q6;
  wire compute_6__ap_start;
  reg [1:0] compute_6__state;
  wire compute_6__ap_done;
  wire compute_6__ap_idle;
  wire compute_6__ap_ready;
  wire [63:0] load_0___coalesced_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] load_0___coalesced_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] load_0___coalesced_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] load_0___coalesced_data_num__q3;
  (* dont_touch = "yes" *)
  reg [63:0] load_0___coalesced_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] load_0___coalesced_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] load_0___coalesced_data_num__q6;
  wire [63:0] var_input_0_0__q0;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_0__q1;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_0__q2;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_0__q3;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_0__q4;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_0__q5;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_0__q6;
  wire load_0__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg load_0__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg load_0__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg load_0__ap_rst_n__q3;
  (* dont_touch = "yes" *)
  reg load_0__ap_rst_n__q4;
  (* dont_touch = "yes" *)
  reg load_0__ap_rst_n__q5;
  (* dont_touch = "yes" *)
  reg load_0__ap_rst_n__q6;
  wire load_0__is_done__q0;
  (* dont_touch = "yes" *)
  reg load_0__is_done__q1;
  (* dont_touch = "yes" *)
  reg load_0__is_done__q2;
  (* dont_touch = "yes" *)
  reg load_0__is_done__q3;
  (* dont_touch = "yes" *)
  reg load_0__is_done__q4;
  (* dont_touch = "yes" *)
  reg load_0__is_done__q5;
  (* dont_touch = "yes" *)
  reg load_0__is_done__q6;
  wire load_0__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg load_0__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg load_0__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg load_0__ap_start_global__q3;
  (* dont_touch = "yes" *)
  reg load_0__ap_start_global__q4;
  (* dont_touch = "yes" *)
  reg load_0__ap_start_global__q5;
  (* dont_touch = "yes" *)
  reg load_0__ap_start_global__q6;
  wire load_0__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg load_0__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg load_0__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg load_0__ap_done_global__q3;
  (* dont_touch = "yes" *)
  reg load_0__ap_done_global__q4;
  (* dont_touch = "yes" *)
  reg load_0__ap_done_global__q5;
  (* dont_touch = "yes" *)
  reg load_0__ap_done_global__q6;
  wire load_0__ap_start;
  reg [1:0] load_0__state;
  wire load_0__ap_done;
  wire load_0__ap_idle;
  wire load_0__ap_ready;
  wire [63:0] load_1___coalesced_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] load_1___coalesced_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] load_1___coalesced_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] load_1___coalesced_data_num__q3;
  (* dont_touch = "yes" *)
  reg [63:0] load_1___coalesced_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] load_1___coalesced_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] load_1___coalesced_data_num__q6;
  wire [63:0] var_input_0_1__q0;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_1__q1;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_1__q2;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_1__q3;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_1__q4;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_1__q5;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_1__q6;
  wire load_1__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg load_1__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg load_1__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg load_1__ap_rst_n__q3;
  (* dont_touch = "yes" *)
  reg load_1__ap_rst_n__q4;
  (* dont_touch = "yes" *)
  reg load_1__ap_rst_n__q5;
  (* dont_touch = "yes" *)
  reg load_1__ap_rst_n__q6;
  wire load_1__is_done__q0;
  (* dont_touch = "yes" *)
  reg load_1__is_done__q1;
  (* dont_touch = "yes" *)
  reg load_1__is_done__q2;
  (* dont_touch = "yes" *)
  reg load_1__is_done__q3;
  (* dont_touch = "yes" *)
  reg load_1__is_done__q4;
  (* dont_touch = "yes" *)
  reg load_1__is_done__q5;
  (* dont_touch = "yes" *)
  reg load_1__is_done__q6;
  wire load_1__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg load_1__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg load_1__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg load_1__ap_start_global__q3;
  (* dont_touch = "yes" *)
  reg load_1__ap_start_global__q4;
  (* dont_touch = "yes" *)
  reg load_1__ap_start_global__q5;
  (* dont_touch = "yes" *)
  reg load_1__ap_start_global__q6;
  wire load_1__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg load_1__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg load_1__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg load_1__ap_done_global__q3;
  (* dont_touch = "yes" *)
  reg load_1__ap_done_global__q4;
  (* dont_touch = "yes" *)
  reg load_1__ap_done_global__q5;
  (* dont_touch = "yes" *)
  reg load_1__ap_done_global__q6;
  wire load_1__ap_start;
  reg [1:0] load_1__state;
  wire load_1__ap_done;
  wire load_1__ap_idle;
  wire load_1__ap_ready;
  wire [63:0] load_2___coalesced_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] load_2___coalesced_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] load_2___coalesced_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] load_2___coalesced_data_num__q3;
  (* dont_touch = "yes" *)
  reg [63:0] load_2___coalesced_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] load_2___coalesced_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] load_2___coalesced_data_num__q6;
  wire [63:0] var_input_0_2__q0;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_2__q1;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_2__q2;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_2__q3;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_2__q4;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_2__q5;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_2__q6;
  wire load_2__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg load_2__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg load_2__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg load_2__ap_rst_n__q3;
  (* dont_touch = "yes" *)
  reg load_2__ap_rst_n__q4;
  (* dont_touch = "yes" *)
  reg load_2__ap_rst_n__q5;
  (* dont_touch = "yes" *)
  reg load_2__ap_rst_n__q6;
  wire load_2__is_done__q0;
  (* dont_touch = "yes" *)
  reg load_2__is_done__q1;
  (* dont_touch = "yes" *)
  reg load_2__is_done__q2;
  (* dont_touch = "yes" *)
  reg load_2__is_done__q3;
  (* dont_touch = "yes" *)
  reg load_2__is_done__q4;
  (* dont_touch = "yes" *)
  reg load_2__is_done__q5;
  (* dont_touch = "yes" *)
  reg load_2__is_done__q6;
  wire load_2__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg load_2__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg load_2__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg load_2__ap_start_global__q3;
  (* dont_touch = "yes" *)
  reg load_2__ap_start_global__q4;
  (* dont_touch = "yes" *)
  reg load_2__ap_start_global__q5;
  (* dont_touch = "yes" *)
  reg load_2__ap_start_global__q6;
  wire load_2__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg load_2__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg load_2__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg load_2__ap_done_global__q3;
  (* dont_touch = "yes" *)
  reg load_2__ap_done_global__q4;
  (* dont_touch = "yes" *)
  reg load_2__ap_done_global__q5;
  (* dont_touch = "yes" *)
  reg load_2__ap_done_global__q6;
  wire load_2__ap_start;
  reg [1:0] load_2__state;
  wire load_2__ap_done;
  wire load_2__ap_idle;
  wire load_2__ap_ready;
  wire [63:0] load_3___coalesced_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] load_3___coalesced_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] load_3___coalesced_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] load_3___coalesced_data_num__q3;
  (* dont_touch = "yes" *)
  reg [63:0] load_3___coalesced_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] load_3___coalesced_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] load_3___coalesced_data_num__q6;
  wire [63:0] var_input_0_3__q0;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_3__q1;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_3__q2;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_3__q3;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_3__q4;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_3__q5;
  (* dont_touch = "yes" *)
  reg [63:0] var_input_0_3__q6;
  wire load_3__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg load_3__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg load_3__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg load_3__ap_rst_n__q3;
  (* dont_touch = "yes" *)
  reg load_3__ap_rst_n__q4;
  (* dont_touch = "yes" *)
  reg load_3__ap_rst_n__q5;
  (* dont_touch = "yes" *)
  reg load_3__ap_rst_n__q6;
  wire load_3__is_done__q0;
  (* dont_touch = "yes" *)
  reg load_3__is_done__q1;
  (* dont_touch = "yes" *)
  reg load_3__is_done__q2;
  (* dont_touch = "yes" *)
  reg load_3__is_done__q3;
  (* dont_touch = "yes" *)
  reg load_3__is_done__q4;
  (* dont_touch = "yes" *)
  reg load_3__is_done__q5;
  (* dont_touch = "yes" *)
  reg load_3__is_done__q6;
  wire load_3__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg load_3__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg load_3__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg load_3__ap_start_global__q3;
  (* dont_touch = "yes" *)
  reg load_3__ap_start_global__q4;
  (* dont_touch = "yes" *)
  reg load_3__ap_start_global__q5;
  (* dont_touch = "yes" *)
  reg load_3__ap_start_global__q6;
  wire load_3__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg load_3__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg load_3__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg load_3__ap_done_global__q3;
  (* dont_touch = "yes" *)
  reg load_3__ap_done_global__q4;
  (* dont_touch = "yes" *)
  reg load_3__ap_done_global__q5;
  (* dont_touch = "yes" *)
  reg load_3__ap_done_global__q6;
  wire load_3__ap_start;
  reg [1:0] load_3__state;
  wire load_3__ap_done;
  wire load_3__ap_idle;
  wire load_3__ap_ready;
  wire [63:0] store_0___coalesced_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] store_0___coalesced_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] store_0___coalesced_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] store_0___coalesced_data_num__q3;
  (* dont_touch = "yes" *)
  reg [63:0] store_0___coalesced_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] store_0___coalesced_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] store_0___coalesced_data_num__q6;
  wire [63:0] var_output_0_0__q0;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_0__q1;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_0__q2;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_0__q3;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_0__q4;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_0__q5;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_0__q6;
  wire store_0__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg store_0__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg store_0__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg store_0__ap_rst_n__q3;
  (* dont_touch = "yes" *)
  reg store_0__ap_rst_n__q4;
  (* dont_touch = "yes" *)
  reg store_0__ap_rst_n__q5;
  (* dont_touch = "yes" *)
  reg store_0__ap_rst_n__q6;
  wire store_0__is_done__q0;
  (* dont_touch = "yes" *)
  reg store_0__is_done__q1;
  (* dont_touch = "yes" *)
  reg store_0__is_done__q2;
  (* dont_touch = "yes" *)
  reg store_0__is_done__q3;
  (* dont_touch = "yes" *)
  reg store_0__is_done__q4;
  (* dont_touch = "yes" *)
  reg store_0__is_done__q5;
  (* dont_touch = "yes" *)
  reg store_0__is_done__q6;
  wire store_0__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg store_0__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg store_0__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg store_0__ap_start_global__q3;
  (* dont_touch = "yes" *)
  reg store_0__ap_start_global__q4;
  (* dont_touch = "yes" *)
  reg store_0__ap_start_global__q5;
  (* dont_touch = "yes" *)
  reg store_0__ap_start_global__q6;
  wire store_0__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg store_0__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg store_0__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg store_0__ap_done_global__q3;
  (* dont_touch = "yes" *)
  reg store_0__ap_done_global__q4;
  (* dont_touch = "yes" *)
  reg store_0__ap_done_global__q5;
  (* dont_touch = "yes" *)
  reg store_0__ap_done_global__q6;
  wire store_0__ap_start;
  reg [1:0] store_0__state;
  wire store_0__ap_done;
  wire store_0__ap_idle;
  wire store_0__ap_ready;
  wire [63:0] store_1___coalesced_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] store_1___coalesced_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] store_1___coalesced_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] store_1___coalesced_data_num__q3;
  (* dont_touch = "yes" *)
  reg [63:0] store_1___coalesced_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] store_1___coalesced_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] store_1___coalesced_data_num__q6;
  wire [63:0] var_output_0_1__q0;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_1__q1;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_1__q2;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_1__q3;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_1__q4;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_1__q5;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_1__q6;
  wire store_1__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg store_1__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg store_1__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg store_1__ap_rst_n__q3;
  (* dont_touch = "yes" *)
  reg store_1__ap_rst_n__q4;
  (* dont_touch = "yes" *)
  reg store_1__ap_rst_n__q5;
  (* dont_touch = "yes" *)
  reg store_1__ap_rst_n__q6;
  wire store_1__is_done__q0;
  (* dont_touch = "yes" *)
  reg store_1__is_done__q1;
  (* dont_touch = "yes" *)
  reg store_1__is_done__q2;
  (* dont_touch = "yes" *)
  reg store_1__is_done__q3;
  (* dont_touch = "yes" *)
  reg store_1__is_done__q4;
  (* dont_touch = "yes" *)
  reg store_1__is_done__q5;
  (* dont_touch = "yes" *)
  reg store_1__is_done__q6;
  wire store_1__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg store_1__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg store_1__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg store_1__ap_start_global__q3;
  (* dont_touch = "yes" *)
  reg store_1__ap_start_global__q4;
  (* dont_touch = "yes" *)
  reg store_1__ap_start_global__q5;
  (* dont_touch = "yes" *)
  reg store_1__ap_start_global__q6;
  wire store_1__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg store_1__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg store_1__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg store_1__ap_done_global__q3;
  (* dont_touch = "yes" *)
  reg store_1__ap_done_global__q4;
  (* dont_touch = "yes" *)
  reg store_1__ap_done_global__q5;
  (* dont_touch = "yes" *)
  reg store_1__ap_done_global__q6;
  wire store_1__ap_start;
  reg [1:0] store_1__state;
  wire store_1__ap_done;
  wire store_1__ap_idle;
  wire store_1__ap_ready;
  wire [63:0] store_2___coalesced_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] store_2___coalesced_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] store_2___coalesced_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] store_2___coalesced_data_num__q3;
  (* dont_touch = "yes" *)
  reg [63:0] store_2___coalesced_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] store_2___coalesced_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] store_2___coalesced_data_num__q6;
  wire [63:0] var_output_0_2__q0;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_2__q1;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_2__q2;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_2__q3;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_2__q4;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_2__q5;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_2__q6;
  wire store_2__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg store_2__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg store_2__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg store_2__ap_rst_n__q3;
  (* dont_touch = "yes" *)
  reg store_2__ap_rst_n__q4;
  (* dont_touch = "yes" *)
  reg store_2__ap_rst_n__q5;
  (* dont_touch = "yes" *)
  reg store_2__ap_rst_n__q6;
  wire store_2__is_done__q0;
  (* dont_touch = "yes" *)
  reg store_2__is_done__q1;
  (* dont_touch = "yes" *)
  reg store_2__is_done__q2;
  (* dont_touch = "yes" *)
  reg store_2__is_done__q3;
  (* dont_touch = "yes" *)
  reg store_2__is_done__q4;
  (* dont_touch = "yes" *)
  reg store_2__is_done__q5;
  (* dont_touch = "yes" *)
  reg store_2__is_done__q6;
  wire store_2__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg store_2__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg store_2__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg store_2__ap_start_global__q3;
  (* dont_touch = "yes" *)
  reg store_2__ap_start_global__q4;
  (* dont_touch = "yes" *)
  reg store_2__ap_start_global__q5;
  (* dont_touch = "yes" *)
  reg store_2__ap_start_global__q6;
  wire store_2__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg store_2__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg store_2__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg store_2__ap_done_global__q3;
  (* dont_touch = "yes" *)
  reg store_2__ap_done_global__q4;
  (* dont_touch = "yes" *)
  reg store_2__ap_done_global__q5;
  (* dont_touch = "yes" *)
  reg store_2__ap_done_global__q6;
  wire store_2__ap_start;
  reg [1:0] store_2__state;
  wire store_2__ap_done;
  wire store_2__ap_idle;
  wire store_2__ap_ready;
  wire [63:0] store_3___coalesced_data_num__q0;
  (* dont_touch = "yes" *)
  reg [63:0] store_3___coalesced_data_num__q1;
  (* dont_touch = "yes" *)
  reg [63:0] store_3___coalesced_data_num__q2;
  (* dont_touch = "yes" *)
  reg [63:0] store_3___coalesced_data_num__q3;
  (* dont_touch = "yes" *)
  reg [63:0] store_3___coalesced_data_num__q4;
  (* dont_touch = "yes" *)
  reg [63:0] store_3___coalesced_data_num__q5;
  (* dont_touch = "yes" *)
  reg [63:0] store_3___coalesced_data_num__q6;
  wire [63:0] var_output_0_3__q0;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_3__q1;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_3__q2;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_3__q3;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_3__q4;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_3__q5;
  (* dont_touch = "yes" *)
  reg [63:0] var_output_0_3__q6;
  wire store_3__ap_rst_n__q0;
  (* dont_touch = "yes" *)
  reg store_3__ap_rst_n__q1;
  (* dont_touch = "yes" *)
  reg store_3__ap_rst_n__q2;
  (* dont_touch = "yes" *)
  reg store_3__ap_rst_n__q3;
  (* dont_touch = "yes" *)
  reg store_3__ap_rst_n__q4;
  (* dont_touch = "yes" *)
  reg store_3__ap_rst_n__q5;
  (* dont_touch = "yes" *)
  reg store_3__ap_rst_n__q6;
  wire store_3__is_done__q0;
  (* dont_touch = "yes" *)
  reg store_3__is_done__q1;
  (* dont_touch = "yes" *)
  reg store_3__is_done__q2;
  (* dont_touch = "yes" *)
  reg store_3__is_done__q3;
  (* dont_touch = "yes" *)
  reg store_3__is_done__q4;
  (* dont_touch = "yes" *)
  reg store_3__is_done__q5;
  (* dont_touch = "yes" *)
  reg store_3__is_done__q6;
  wire store_3__ap_start_global__q0;
  (* dont_touch = "yes" *)
  reg store_3__ap_start_global__q1;
  (* dont_touch = "yes" *)
  reg store_3__ap_start_global__q2;
  (* dont_touch = "yes" *)
  reg store_3__ap_start_global__q3;
  (* dont_touch = "yes" *)
  reg store_3__ap_start_global__q4;
  (* dont_touch = "yes" *)
  reg store_3__ap_start_global__q5;
  (* dont_touch = "yes" *)
  reg store_3__ap_start_global__q6;
  wire store_3__ap_done_global__q0;
  (* dont_touch = "yes" *)
  reg store_3__ap_done_global__q1;
  (* dont_touch = "yes" *)
  reg store_3__ap_done_global__q2;
  (* dont_touch = "yes" *)
  reg store_3__ap_done_global__q3;
  (* dont_touch = "yes" *)
  reg store_3__ap_done_global__q4;
  (* dont_touch = "yes" *)
  reg store_3__ap_done_global__q5;
  (* dont_touch = "yes" *)
  reg store_3__ap_done_global__q6;
  wire store_3__ap_start;
  reg [1:0] store_3__state;
  wire store_3__ap_done;
  wire store_3__ap_idle;
  wire store_3__ap_ready;
  reg [1:0] tlp_state;
  reg [1:0] countdown;
  wire ap_start__q0;
  (* dont_touch = "yes" *)
  reg ap_start__q1;
  (* dont_touch = "yes" *)
  reg ap_start__q2;
  (* dont_touch = "yes" *)
  reg ap_start__q3;
  (* dont_touch = "yes" *)
  reg ap_start__q4;
  (* dont_touch = "yes" *)
  reg ap_start__q5;
  (* dont_touch = "yes" *)
  reg ap_start__q6;
  wire ap_done__q0;
  (* dont_touch = "yes" *)
  reg ap_done__q1;
  (* dont_touch = "yes" *)
  reg ap_done__q2;
  (* dont_touch = "yes" *)
  reg ap_done__q3;
  (* dont_touch = "yes" *)
  reg ap_done__q4;
  (* dont_touch = "yes" *)
  reg ap_done__q5;
  (* dont_touch = "yes" *)
  reg ap_done__q6;

  (* keep_hierarchy = "yes" *) jacobi2d_kernel_jacobi2d_kernel_control_s_axi
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
    .var_output_0_1(var_output_0_1),
    .var_output_0_2(var_output_0_2),
    .var_output_0_3(var_output_0_3),
    .var_input_0_0(var_input_0_0),
    .var_input_0_1(var_input_0_1),
    .var_input_0_2(var_input_0_2),
    .var_input_0_3(var_input_0_3),
    .coalesced_data_num(coalesced_data_num),
    .tile_data_num(tile_data_num),
    .tile_num_dim_0(tile_num_dim_0),
    .input_size_dim_0(input_size_dim_0),
    .input_size_dim_1(input_size_dim_1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  input_stream_0_0
  (
    .clk(ap_clk),
    .reset(input_stream_0_0__rst__q6),
    .if_dout(input_stream_0_0__dout),
    .if_empty_n(input_stream_0_0__empty_n),
    .if_read(input_stream_0_0__read),
    .if_read_ce(1'b1),
    .if_din(input_stream_0_0__din),
    .if_full_n(input_stream_0_0__full_n),
    .if_write(input_stream_0_0__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  input_stream_0_1
  (
    .clk(ap_clk),
    .reset(input_stream_0_1__rst__q6),
    .if_dout(input_stream_0_1__dout),
    .if_empty_n(input_stream_0_1__empty_n),
    .if_read(input_stream_0_1__read),
    .if_read_ce(1'b1),
    .if_din(input_stream_0_1__din),
    .if_full_n(input_stream_0_1__full_n),
    .if_write(input_stream_0_1__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  input_stream_0_2
  (
    .clk(ap_clk),
    .reset(input_stream_0_2__rst__q6),
    .if_dout(input_stream_0_2__dout),
    .if_empty_n(input_stream_0_2__empty_n),
    .if_read(input_stream_0_2__read),
    .if_read_ce(1'b1),
    .if_din(input_stream_0_2__din),
    .if_full_n(input_stream_0_2__full_n),
    .if_write(input_stream_0_2__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  input_stream_0_3
  (
    .clk(ap_clk),
    .reset(input_stream_0_3__rst__q6),
    .if_dout(input_stream_0_3__dout),
    .if_empty_n(input_stream_0_3__empty_n),
    .if_read(input_stream_0_3__read),
    .if_read_ce(1'b1),
    .if_din(input_stream_0_3__din),
    .if_full_n(input_stream_0_3__full_n),
    .if_write(input_stream_0_3__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_0_0
  (
    .clk(ap_clk),
    .reset(output_stream_0_0__rst__q6),
    .if_dout(output_stream_0_0__dout),
    .if_empty_n(output_stream_0_0__empty_n),
    .if_read(output_stream_0_0__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_0_0__din),
    .if_full_n(output_stream_0_0__full_n),
    .if_write(output_stream_0_0__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_0_1
  (
    .clk(ap_clk),
    .reset(output_stream_0_1__rst__q6),
    .if_dout(output_stream_0_1__dout),
    .if_empty_n(output_stream_0_1__empty_n),
    .if_read(output_stream_0_1__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_0_1__din),
    .if_full_n(output_stream_0_1__full_n),
    .if_write(output_stream_0_1__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_0_2
  (
    .clk(ap_clk),
    .reset(output_stream_0_2__rst__q6),
    .if_dout(output_stream_0_2__dout),
    .if_empty_n(output_stream_0_2__empty_n),
    .if_read(output_stream_0_2__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_0_2__din),
    .if_full_n(output_stream_0_2__full_n),
    .if_write(output_stream_0_2__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_0_3
  (
    .clk(ap_clk),
    .reset(output_stream_0_3__rst__q6),
    .if_dout(output_stream_0_3__dout),
    .if_empty_n(output_stream_0_3__empty_n),
    .if_read(output_stream_0_3__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_0_3__din),
    .if_full_n(output_stream_0_3__full_n),
    .if_write(output_stream_0_3__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  output_stream_1_0
  (
    .clk(ap_clk),
    .reset(output_stream_1_0__rst__q6),
    .if_dout(output_stream_1_0__dout),
    .if_empty_n(output_stream_1_0__empty_n),
    .if_read(output_stream_1_0__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_1_0__din),
    .if_full_n(output_stream_1_0__full_n),
    .if_write(output_stream_1_0__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  output_stream_1_1
  (
    .clk(ap_clk),
    .reset(output_stream_1_1__rst__q6),
    .if_dout(output_stream_1_1__dout),
    .if_empty_n(output_stream_1_1__empty_n),
    .if_read(output_stream_1_1__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_1_1__din),
    .if_full_n(output_stream_1_1__full_n),
    .if_write(output_stream_1_1__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  output_stream_1_2
  (
    .clk(ap_clk),
    .reset(output_stream_1_2__rst__q6),
    .if_dout(output_stream_1_2__dout),
    .if_empty_n(output_stream_1_2__empty_n),
    .if_read(output_stream_1_2__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_1_2__din),
    .if_full_n(output_stream_1_2__full_n),
    .if_write(output_stream_1_2__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  output_stream_1_3
  (
    .clk(ap_clk),
    .reset(output_stream_1_3__rst__q6),
    .if_dout(output_stream_1_3__dout),
    .if_empty_n(output_stream_1_3__empty_n),
    .if_read(output_stream_1_3__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_1_3__din),
    .if_full_n(output_stream_1_3__full_n),
    .if_write(output_stream_1_3__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_2_0
  (
    .clk(ap_clk),
    .reset(output_stream_2_0__rst__q6),
    .if_dout(output_stream_2_0__dout),
    .if_empty_n(output_stream_2_0__empty_n),
    .if_read(output_stream_2_0__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_2_0__din),
    .if_full_n(output_stream_2_0__full_n),
    .if_write(output_stream_2_0__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_2_1
  (
    .clk(ap_clk),
    .reset(output_stream_2_1__rst__q6),
    .if_dout(output_stream_2_1__dout),
    .if_empty_n(output_stream_2_1__empty_n),
    .if_read(output_stream_2_1__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_2_1__din),
    .if_full_n(output_stream_2_1__full_n),
    .if_write(output_stream_2_1__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_2_2
  (
    .clk(ap_clk),
    .reset(output_stream_2_2__rst__q6),
    .if_dout(output_stream_2_2__dout),
    .if_empty_n(output_stream_2_2__empty_n),
    .if_read(output_stream_2_2__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_2_2__din),
    .if_full_n(output_stream_2_2__full_n),
    .if_write(output_stream_2_2__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_2_3
  (
    .clk(ap_clk),
    .reset(output_stream_2_3__rst__q6),
    .if_dout(output_stream_2_3__dout),
    .if_empty_n(output_stream_2_3__empty_n),
    .if_read(output_stream_2_3__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_2_3__din),
    .if_full_n(output_stream_2_3__full_n),
    .if_write(output_stream_2_3__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  output_stream_3_0
  (
    .clk(ap_clk),
    .reset(output_stream_3_0__rst__q6),
    .if_dout(output_stream_3_0__dout),
    .if_empty_n(output_stream_3_0__empty_n),
    .if_read(output_stream_3_0__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_3_0__din),
    .if_full_n(output_stream_3_0__full_n),
    .if_write(output_stream_3_0__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  output_stream_3_1
  (
    .clk(ap_clk),
    .reset(output_stream_3_1__rst__q6),
    .if_dout(output_stream_3_1__dout),
    .if_empty_n(output_stream_3_1__empty_n),
    .if_read(output_stream_3_1__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_3_1__din),
    .if_full_n(output_stream_3_1__full_n),
    .if_write(output_stream_3_1__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  output_stream_3_2
  (
    .clk(ap_clk),
    .reset(output_stream_3_2__rst__q6),
    .if_dout(output_stream_3_2__dout),
    .if_empty_n(output_stream_3_2__empty_n),
    .if_read(output_stream_3_2__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_3_2__din),
    .if_full_n(output_stream_3_2__full_n),
    .if_write(output_stream_3_2__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  output_stream_3_3
  (
    .clk(ap_clk),
    .reset(output_stream_3_3__rst__q6),
    .if_dout(output_stream_3_3__dout),
    .if_empty_n(output_stream_3_3__empty_n),
    .if_read(output_stream_3_3__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_3_3__din),
    .if_full_n(output_stream_3_3__full_n),
    .if_write(output_stream_3_3__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  output_stream_4_0
  (
    .clk(ap_clk),
    .reset(output_stream_4_0__rst__q6),
    .if_dout(output_stream_4_0__dout),
    .if_empty_n(output_stream_4_0__empty_n),
    .if_read(output_stream_4_0__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_4_0__din),
    .if_full_n(output_stream_4_0__full_n),
    .if_write(output_stream_4_0__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  output_stream_4_1
  (
    .clk(ap_clk),
    .reset(output_stream_4_1__rst__q6),
    .if_dout(output_stream_4_1__dout),
    .if_empty_n(output_stream_4_1__empty_n),
    .if_read(output_stream_4_1__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_4_1__din),
    .if_full_n(output_stream_4_1__full_n),
    .if_write(output_stream_4_1__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  output_stream_4_2
  (
    .clk(ap_clk),
    .reset(output_stream_4_2__rst__q6),
    .if_dout(output_stream_4_2__dout),
    .if_empty_n(output_stream_4_2__empty_n),
    .if_read(output_stream_4_2__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_4_2__din),
    .if_full_n(output_stream_4_2__full_n),
    .if_write(output_stream_4_2__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  output_stream_4_3
  (
    .clk(ap_clk),
    .reset(output_stream_4_3__rst__q6),
    .if_dout(output_stream_4_3__dout),
    .if_empty_n(output_stream_4_3__empty_n),
    .if_read(output_stream_4_3__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_4_3__din),
    .if_full_n(output_stream_4_3__full_n),
    .if_write(output_stream_4_3__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  output_stream_5_0
  (
    .clk(ap_clk),
    .reset(output_stream_5_0__rst__q6),
    .if_dout(output_stream_5_0__dout),
    .if_empty_n(output_stream_5_0__empty_n),
    .if_read(output_stream_5_0__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_5_0__din),
    .if_full_n(output_stream_5_0__full_n),
    .if_write(output_stream_5_0__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  output_stream_5_1
  (
    .clk(ap_clk),
    .reset(output_stream_5_1__rst__q6),
    .if_dout(output_stream_5_1__dout),
    .if_empty_n(output_stream_5_1__empty_n),
    .if_read(output_stream_5_1__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_5_1__din),
    .if_full_n(output_stream_5_1__full_n),
    .if_write(output_stream_5_1__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  output_stream_5_2
  (
    .clk(ap_clk),
    .reset(output_stream_5_2__rst__q6),
    .if_dout(output_stream_5_2__dout),
    .if_empty_n(output_stream_5_2__empty_n),
    .if_read(output_stream_5_2__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_5_2__din),
    .if_full_n(output_stream_5_2__full_n),
    .if_write(output_stream_5_2__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) relay_station
  #(
    .DATA_WIDTH(513),
    .DEPTH(32),
    .ADDR_WIDTH(6),
    .LEVEL(2)
  )
  output_stream_5_3
  (
    .clk(ap_clk),
    .reset(output_stream_5_3__rst__q6),
    .if_dout(output_stream_5_3__dout),
    .if_empty_n(output_stream_5_3__empty_n),
    .if_read(output_stream_5_3__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_5_3__din),
    .if_full_n(output_stream_5_3__full_n),
    .if_write(output_stream_5_3__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_6_0
  (
    .clk(ap_clk),
    .reset(output_stream_6_0__rst__q6),
    .if_dout(output_stream_6_0__dout),
    .if_empty_n(output_stream_6_0__empty_n),
    .if_read(output_stream_6_0__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_6_0__din),
    .if_full_n(output_stream_6_0__full_n),
    .if_write(output_stream_6_0__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_6_1
  (
    .clk(ap_clk),
    .reset(output_stream_6_1__rst__q6),
    .if_dout(output_stream_6_1__dout),
    .if_empty_n(output_stream_6_1__empty_n),
    .if_read(output_stream_6_1__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_6_1__din),
    .if_full_n(output_stream_6_1__full_n),
    .if_write(output_stream_6_1__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_6_2
  (
    .clk(ap_clk),
    .reset(output_stream_6_2__rst__q6),
    .if_dout(output_stream_6_2__dout),
    .if_empty_n(output_stream_6_2__empty_n),
    .if_read(output_stream_6_2__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_6_2__din),
    .if_full_n(output_stream_6_2__full_n),
    .if_write(output_stream_6_2__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) fifo
  #(
    .DATA_WIDTH(513),
    .ADDR_WIDTH(5),
    .DEPTH(32)
  )
  output_stream_6_3
  (
    .clk(ap_clk),
    .reset(output_stream_6_3__rst__q6),
    .if_dout(output_stream_6_3__dout),
    .if_empty_n(output_stream_6_3__empty_n),
    .if_read(output_stream_6_3__read),
    .if_read_ce(1'b1),
    .if_din(output_stream_6_3__din),
    .if_full_n(output_stream_6_3__full_n),
    .if_write(output_stream_6_3__write),
    .if_write_ce(1'b1)
  );


  (* keep_hierarchy = "yes" *) compute_compute
  compute_0
  (
    .ap_clk(ap_clk),
    .ap_rst_n(compute_0__ap_rst_n__q6),
    .ap_start(compute_0__ap_start),
    .ap_done(compute_0__ap_done),
    .ap_idle(compute_0__ap_idle),
    .ap_ready(compute_0__ap_ready),
    .coalesced_data_num(compute_0___coalesced_data_num__q6),
    .input_size_dim_0(compute_0___input_size_dim_0__q6),
    .input_size_dim_1(compute_0___input_size_dim_1__q6),
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
    .tile_data_num(compute_0___tile_data_num__q6),
    .tile_num_dim_0(compute_0___tile_num_dim_0__q6)
  );


  (* keep_hierarchy = "yes" *) compute_compute
  compute_1
  (
    .ap_clk(ap_clk),
    .ap_rst_n(compute_1__ap_rst_n__q6),
    .ap_start(compute_1__ap_start),
    .ap_done(compute_1__ap_done),
    .ap_idle(compute_1__ap_idle),
    .ap_ready(compute_1__ap_ready),
    .coalesced_data_num(compute_1___coalesced_data_num__q6),
    .input_size_dim_0(compute_1___input_size_dim_0__q6),
    .input_size_dim_1(compute_1___input_size_dim_1__q6),
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
    .tile_data_num(compute_1___tile_data_num__q6),
    .tile_num_dim_0(compute_1___tile_num_dim_0__q6)
  );


  (* keep_hierarchy = "yes" *) compute_compute
  compute_2
  (
    .ap_clk(ap_clk),
    .ap_rst_n(compute_2__ap_rst_n__q6),
    .ap_start(compute_2__ap_start),
    .ap_done(compute_2__ap_done),
    .ap_idle(compute_2__ap_idle),
    .ap_ready(compute_2__ap_ready),
    .coalesced_data_num(compute_2___coalesced_data_num__q6),
    .input_size_dim_0(compute_2___input_size_dim_0__q6),
    .input_size_dim_1(compute_2___input_size_dim_1__q6),
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
    .tile_data_num(compute_2___tile_data_num__q6),
    .tile_num_dim_0(compute_2___tile_num_dim_0__q6)
  );


  (* keep_hierarchy = "yes" *) compute_compute
  compute_3
  (
    .ap_clk(ap_clk),
    .ap_rst_n(compute_3__ap_rst_n__q6),
    .ap_start(compute_3__ap_start),
    .ap_done(compute_3__ap_done),
    .ap_idle(compute_3__ap_idle),
    .ap_ready(compute_3__ap_ready),
    .coalesced_data_num(compute_3___coalesced_data_num__q6),
    .input_size_dim_0(compute_3___input_size_dim_0__q6),
    .input_size_dim_1(compute_3___input_size_dim_1__q6),
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
    .tile_data_num(compute_3___tile_data_num__q6),
    .tile_num_dim_0(compute_3___tile_num_dim_0__q6)
  );


  (* keep_hierarchy = "yes" *) compute_compute
  compute_4
  (
    .ap_clk(ap_clk),
    .ap_rst_n(compute_4__ap_rst_n__q6),
    .ap_start(compute_4__ap_start),
    .ap_done(compute_4__ap_done),
    .ap_idle(compute_4__ap_idle),
    .ap_ready(compute_4__ap_ready),
    .coalesced_data_num(compute_4___coalesced_data_num__q6),
    .input_size_dim_0(compute_4___input_size_dim_0__q6),
    .input_size_dim_1(compute_4___input_size_dim_1__q6),
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
    .tile_data_num(compute_4___tile_data_num__q6),
    .tile_num_dim_0(compute_4___tile_num_dim_0__q6)
  );


  (* keep_hierarchy = "yes" *) compute_compute
  compute_5
  (
    .ap_clk(ap_clk),
    .ap_rst_n(compute_5__ap_rst_n__q6),
    .ap_start(compute_5__ap_start),
    .ap_done(compute_5__ap_done),
    .ap_idle(compute_5__ap_idle),
    .ap_ready(compute_5__ap_ready),
    .coalesced_data_num(compute_5___coalesced_data_num__q6),
    .input_size_dim_0(compute_5___input_size_dim_0__q6),
    .input_size_dim_1(compute_5___input_size_dim_1__q6),
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
    .tile_data_num(compute_5___tile_data_num__q6),
    .tile_num_dim_0(compute_5___tile_num_dim_0__q6)
  );


  (* keep_hierarchy = "yes" *) compute_compute
  compute_6
  (
    .ap_clk(ap_clk),
    .ap_rst_n(compute_6__ap_rst_n__q6),
    .ap_start(compute_6__ap_start),
    .ap_done(compute_6__ap_done),
    .ap_idle(compute_6__ap_idle),
    .ap_ready(compute_6__ap_ready),
    .coalesced_data_num(compute_6___coalesced_data_num__q6),
    .input_size_dim_0(compute_6___input_size_dim_0__q6),
    .input_size_dim_1(compute_6___input_size_dim_1__q6),
    .from_chan_0_bank_0_fifo_V_dout(output_stream_5_0__dout),
    .from_chan_0_bank_0_fifo_V_empty_n(output_stream_5_0__empty_n),
    .from_chan_0_bank_0_fifo_V_read(output_stream_5_0__read),
    .from_chan_0_bank_0_peek_val(output_stream_5_0__dout),
    .from_chan_0_bank_1_fifo_V_dout(output_stream_5_1__dout),
    .from_chan_0_bank_1_fifo_V_empty_n(output_stream_5_1__empty_n),
    .from_chan_0_bank_1_fifo_V_read(output_stream_5_1__read),
    .from_chan_0_bank_1_peek_val(output_stream_5_1__dout),
    .from_chan_0_bank_2_fifo_V_dout(output_stream_5_2__dout),
    .from_chan_0_bank_2_fifo_V_empty_n(output_stream_5_2__empty_n),
    .from_chan_0_bank_2_fifo_V_read(output_stream_5_2__read),
    .from_chan_0_bank_2_peek_val(output_stream_5_2__dout),
    .from_chan_0_bank_3_fifo_V_dout(output_stream_5_3__dout),
    .from_chan_0_bank_3_fifo_V_empty_n(output_stream_5_3__empty_n),
    .from_chan_0_bank_3_fifo_V_read(output_stream_5_3__read),
    .from_chan_0_bank_3_peek_val(output_stream_5_3__dout),
    .to_chan_0_bank_0_fifo_V_din(output_stream_6_0__din),
    .to_chan_0_bank_0_fifo_V_full_n(output_stream_6_0__full_n),
    .to_chan_0_bank_0_fifo_V_write(output_stream_6_0__write),
    .to_chan_0_bank_1_fifo_V_din(output_stream_6_1__din),
    .to_chan_0_bank_1_fifo_V_full_n(output_stream_6_1__full_n),
    .to_chan_0_bank_1_fifo_V_write(output_stream_6_1__write),
    .to_chan_0_bank_2_fifo_V_din(output_stream_6_2__din),
    .to_chan_0_bank_2_fifo_V_full_n(output_stream_6_2__full_n),
    .to_chan_0_bank_2_fifo_V_write(output_stream_6_2__write),
    .to_chan_0_bank_3_fifo_V_din(output_stream_6_3__din),
    .to_chan_0_bank_3_fifo_V_full_n(output_stream_6_3__full_n),
    .to_chan_0_bank_3_fifo_V_write(output_stream_6_3__write),
    .tile_data_num(compute_6___tile_data_num__q6),
    .tile_num_dim_0(compute_6___tile_num_dim_0__q6)
  );


  (* keep_hierarchy = "yes" *) load_load
  load_0
  (
    .ap_clk(ap_clk),
    .ap_rst_n(load_0__ap_rst_n__q6),
    .ap_start(load_0__ap_start),
    .ap_done(load_0__ap_done),
    .ap_idle(load_0__ap_idle),
    .ap_ready(load_0__ap_ready),
    .data_num(load_0___coalesced_data_num__q6),
    .to_fifo_V_din(input_stream_0_0__din),
    .to_fifo_V_full_n(input_stream_0_0__full_n),
    .to_fifo_V_write(input_stream_0_0__write),
    .m_axi_from_ARADDR(m_axi_var_input_0_0_ARADDR),
    .m_axi_from_ARBURST(m_axi_var_input_0_0_ARBURST),
    .m_axi_from_ARCACHE(m_axi_var_input_0_0_ARCACHE),
    .m_axi_from_ARID(m_axi_var_input_0_0_ARID),
    .m_axi_from_ARLEN(m_axi_var_input_0_0_ARLEN),
    .m_axi_from_ARLOCK(m_axi_var_input_0_0_ARLOCK),
    .m_axi_from_ARPROT(m_axi_var_input_0_0_ARPROT),
    .m_axi_from_ARQOS(m_axi_var_input_0_0_ARQOS),
    .m_axi_from_ARREADY(m_axi_var_input_0_0_ARREADY),
    .m_axi_from_ARREGION(m_axi_var_input_0_0_ARREGION),
    .m_axi_from_ARSIZE(m_axi_var_input_0_0_ARSIZE),
    .m_axi_from_ARUSER(m_axi_var_input_0_0_ARUSER),
    .m_axi_from_ARVALID(m_axi_var_input_0_0_ARVALID),
    .m_axi_from_AWADDR(m_axi_var_input_0_0_AWADDR),
    .m_axi_from_AWBURST(m_axi_var_input_0_0_AWBURST),
    .m_axi_from_AWCACHE(m_axi_var_input_0_0_AWCACHE),
    .m_axi_from_AWID(m_axi_var_input_0_0_AWID),
    .m_axi_from_AWLEN(m_axi_var_input_0_0_AWLEN),
    .m_axi_from_AWLOCK(m_axi_var_input_0_0_AWLOCK),
    .m_axi_from_AWPROT(m_axi_var_input_0_0_AWPROT),
    .m_axi_from_AWQOS(m_axi_var_input_0_0_AWQOS),
    .m_axi_from_AWREADY(m_axi_var_input_0_0_AWREADY),
    .m_axi_from_AWREGION(m_axi_var_input_0_0_AWREGION),
    .m_axi_from_AWSIZE(m_axi_var_input_0_0_AWSIZE),
    .m_axi_from_AWUSER(m_axi_var_input_0_0_AWUSER),
    .m_axi_from_AWVALID(m_axi_var_input_0_0_AWVALID),
    .m_axi_from_BID(m_axi_var_input_0_0_BID),
    .m_axi_from_BREADY(m_axi_var_input_0_0_BREADY),
    .m_axi_from_BRESP(m_axi_var_input_0_0_BRESP),
    .m_axi_from_BUSER(m_axi_var_input_0_0_BUSER),
    .m_axi_from_BVALID(m_axi_var_input_0_0_BVALID),
    .m_axi_from_RDATA(m_axi_var_input_0_0_RDATA),
    .m_axi_from_RID(m_axi_var_input_0_0_RID),
    .m_axi_from_RLAST(m_axi_var_input_0_0_RLAST),
    .m_axi_from_RREADY(m_axi_var_input_0_0_RREADY),
    .m_axi_from_RRESP(m_axi_var_input_0_0_RRESP),
    .m_axi_from_RUSER(m_axi_var_input_0_0_RUSER),
    .m_axi_from_RVALID(m_axi_var_input_0_0_RVALID),
    .m_axi_from_WDATA(m_axi_var_input_0_0_WDATA),
    .m_axi_from_WID(m_axi_var_input_0_0_WID),
    .m_axi_from_WLAST(m_axi_var_input_0_0_WLAST),
    .m_axi_from_WREADY(m_axi_var_input_0_0_WREADY),
    .m_axi_from_WSTRB(m_axi_var_input_0_0_WSTRB),
    .m_axi_from_WUSER(m_axi_var_input_0_0_WUSER),
    .m_axi_from_WVALID(m_axi_var_input_0_0_WVALID),
    .from_V(var_input_0_0__q6)
  );


  (* keep_hierarchy = "yes" *) load_load
  load_1
  (
    .ap_clk(ap_clk),
    .ap_rst_n(load_1__ap_rst_n__q6),
    .ap_start(load_1__ap_start),
    .ap_done(load_1__ap_done),
    .ap_idle(load_1__ap_idle),
    .ap_ready(load_1__ap_ready),
    .data_num(load_1___coalesced_data_num__q6),
    .to_fifo_V_din(input_stream_0_1__din),
    .to_fifo_V_full_n(input_stream_0_1__full_n),
    .to_fifo_V_write(input_stream_0_1__write),
    .m_axi_from_ARADDR(m_axi_var_input_0_1_ARADDR),
    .m_axi_from_ARBURST(m_axi_var_input_0_1_ARBURST),
    .m_axi_from_ARCACHE(m_axi_var_input_0_1_ARCACHE),
    .m_axi_from_ARID(m_axi_var_input_0_1_ARID),
    .m_axi_from_ARLEN(m_axi_var_input_0_1_ARLEN),
    .m_axi_from_ARLOCK(m_axi_var_input_0_1_ARLOCK),
    .m_axi_from_ARPROT(m_axi_var_input_0_1_ARPROT),
    .m_axi_from_ARQOS(m_axi_var_input_0_1_ARQOS),
    .m_axi_from_ARREADY(m_axi_var_input_0_1_ARREADY),
    .m_axi_from_ARREGION(m_axi_var_input_0_1_ARREGION),
    .m_axi_from_ARSIZE(m_axi_var_input_0_1_ARSIZE),
    .m_axi_from_ARUSER(m_axi_var_input_0_1_ARUSER),
    .m_axi_from_ARVALID(m_axi_var_input_0_1_ARVALID),
    .m_axi_from_AWADDR(m_axi_var_input_0_1_AWADDR),
    .m_axi_from_AWBURST(m_axi_var_input_0_1_AWBURST),
    .m_axi_from_AWCACHE(m_axi_var_input_0_1_AWCACHE),
    .m_axi_from_AWID(m_axi_var_input_0_1_AWID),
    .m_axi_from_AWLEN(m_axi_var_input_0_1_AWLEN),
    .m_axi_from_AWLOCK(m_axi_var_input_0_1_AWLOCK),
    .m_axi_from_AWPROT(m_axi_var_input_0_1_AWPROT),
    .m_axi_from_AWQOS(m_axi_var_input_0_1_AWQOS),
    .m_axi_from_AWREADY(m_axi_var_input_0_1_AWREADY),
    .m_axi_from_AWREGION(m_axi_var_input_0_1_AWREGION),
    .m_axi_from_AWSIZE(m_axi_var_input_0_1_AWSIZE),
    .m_axi_from_AWUSER(m_axi_var_input_0_1_AWUSER),
    .m_axi_from_AWVALID(m_axi_var_input_0_1_AWVALID),
    .m_axi_from_BID(m_axi_var_input_0_1_BID),
    .m_axi_from_BREADY(m_axi_var_input_0_1_BREADY),
    .m_axi_from_BRESP(m_axi_var_input_0_1_BRESP),
    .m_axi_from_BUSER(m_axi_var_input_0_1_BUSER),
    .m_axi_from_BVALID(m_axi_var_input_0_1_BVALID),
    .m_axi_from_RDATA(m_axi_var_input_0_1_RDATA),
    .m_axi_from_RID(m_axi_var_input_0_1_RID),
    .m_axi_from_RLAST(m_axi_var_input_0_1_RLAST),
    .m_axi_from_RREADY(m_axi_var_input_0_1_RREADY),
    .m_axi_from_RRESP(m_axi_var_input_0_1_RRESP),
    .m_axi_from_RUSER(m_axi_var_input_0_1_RUSER),
    .m_axi_from_RVALID(m_axi_var_input_0_1_RVALID),
    .m_axi_from_WDATA(m_axi_var_input_0_1_WDATA),
    .m_axi_from_WID(m_axi_var_input_0_1_WID),
    .m_axi_from_WLAST(m_axi_var_input_0_1_WLAST),
    .m_axi_from_WREADY(m_axi_var_input_0_1_WREADY),
    .m_axi_from_WSTRB(m_axi_var_input_0_1_WSTRB),
    .m_axi_from_WUSER(m_axi_var_input_0_1_WUSER),
    .m_axi_from_WVALID(m_axi_var_input_0_1_WVALID),
    .from_V(var_input_0_1__q6)
  );


  (* keep_hierarchy = "yes" *) load_load
  load_2
  (
    .ap_clk(ap_clk),
    .ap_rst_n(load_2__ap_rst_n__q6),
    .ap_start(load_2__ap_start),
    .ap_done(load_2__ap_done),
    .ap_idle(load_2__ap_idle),
    .ap_ready(load_2__ap_ready),
    .data_num(load_2___coalesced_data_num__q6),
    .to_fifo_V_din(input_stream_0_2__din),
    .to_fifo_V_full_n(input_stream_0_2__full_n),
    .to_fifo_V_write(input_stream_0_2__write),
    .m_axi_from_ARADDR(m_axi_var_input_0_2_ARADDR),
    .m_axi_from_ARBURST(m_axi_var_input_0_2_ARBURST),
    .m_axi_from_ARCACHE(m_axi_var_input_0_2_ARCACHE),
    .m_axi_from_ARID(m_axi_var_input_0_2_ARID),
    .m_axi_from_ARLEN(m_axi_var_input_0_2_ARLEN),
    .m_axi_from_ARLOCK(m_axi_var_input_0_2_ARLOCK),
    .m_axi_from_ARPROT(m_axi_var_input_0_2_ARPROT),
    .m_axi_from_ARQOS(m_axi_var_input_0_2_ARQOS),
    .m_axi_from_ARREADY(m_axi_var_input_0_2_ARREADY),
    .m_axi_from_ARREGION(m_axi_var_input_0_2_ARREGION),
    .m_axi_from_ARSIZE(m_axi_var_input_0_2_ARSIZE),
    .m_axi_from_ARUSER(m_axi_var_input_0_2_ARUSER),
    .m_axi_from_ARVALID(m_axi_var_input_0_2_ARVALID),
    .m_axi_from_AWADDR(m_axi_var_input_0_2_AWADDR),
    .m_axi_from_AWBURST(m_axi_var_input_0_2_AWBURST),
    .m_axi_from_AWCACHE(m_axi_var_input_0_2_AWCACHE),
    .m_axi_from_AWID(m_axi_var_input_0_2_AWID),
    .m_axi_from_AWLEN(m_axi_var_input_0_2_AWLEN),
    .m_axi_from_AWLOCK(m_axi_var_input_0_2_AWLOCK),
    .m_axi_from_AWPROT(m_axi_var_input_0_2_AWPROT),
    .m_axi_from_AWQOS(m_axi_var_input_0_2_AWQOS),
    .m_axi_from_AWREADY(m_axi_var_input_0_2_AWREADY),
    .m_axi_from_AWREGION(m_axi_var_input_0_2_AWREGION),
    .m_axi_from_AWSIZE(m_axi_var_input_0_2_AWSIZE),
    .m_axi_from_AWUSER(m_axi_var_input_0_2_AWUSER),
    .m_axi_from_AWVALID(m_axi_var_input_0_2_AWVALID),
    .m_axi_from_BID(m_axi_var_input_0_2_BID),
    .m_axi_from_BREADY(m_axi_var_input_0_2_BREADY),
    .m_axi_from_BRESP(m_axi_var_input_0_2_BRESP),
    .m_axi_from_BUSER(m_axi_var_input_0_2_BUSER),
    .m_axi_from_BVALID(m_axi_var_input_0_2_BVALID),
    .m_axi_from_RDATA(m_axi_var_input_0_2_RDATA),
    .m_axi_from_RID(m_axi_var_input_0_2_RID),
    .m_axi_from_RLAST(m_axi_var_input_0_2_RLAST),
    .m_axi_from_RREADY(m_axi_var_input_0_2_RREADY),
    .m_axi_from_RRESP(m_axi_var_input_0_2_RRESP),
    .m_axi_from_RUSER(m_axi_var_input_0_2_RUSER),
    .m_axi_from_RVALID(m_axi_var_input_0_2_RVALID),
    .m_axi_from_WDATA(m_axi_var_input_0_2_WDATA),
    .m_axi_from_WID(m_axi_var_input_0_2_WID),
    .m_axi_from_WLAST(m_axi_var_input_0_2_WLAST),
    .m_axi_from_WREADY(m_axi_var_input_0_2_WREADY),
    .m_axi_from_WSTRB(m_axi_var_input_0_2_WSTRB),
    .m_axi_from_WUSER(m_axi_var_input_0_2_WUSER),
    .m_axi_from_WVALID(m_axi_var_input_0_2_WVALID),
    .from_V(var_input_0_2__q6)
  );


  (* keep_hierarchy = "yes" *) load_load
  load_3
  (
    .ap_clk(ap_clk),
    .ap_rst_n(load_3__ap_rst_n__q6),
    .ap_start(load_3__ap_start),
    .ap_done(load_3__ap_done),
    .ap_idle(load_3__ap_idle),
    .ap_ready(load_3__ap_ready),
    .data_num(load_3___coalesced_data_num__q6),
    .to_fifo_V_din(input_stream_0_3__din),
    .to_fifo_V_full_n(input_stream_0_3__full_n),
    .to_fifo_V_write(input_stream_0_3__write),
    .m_axi_from_ARADDR(m_axi_var_input_0_3_ARADDR),
    .m_axi_from_ARBURST(m_axi_var_input_0_3_ARBURST),
    .m_axi_from_ARCACHE(m_axi_var_input_0_3_ARCACHE),
    .m_axi_from_ARID(m_axi_var_input_0_3_ARID),
    .m_axi_from_ARLEN(m_axi_var_input_0_3_ARLEN),
    .m_axi_from_ARLOCK(m_axi_var_input_0_3_ARLOCK),
    .m_axi_from_ARPROT(m_axi_var_input_0_3_ARPROT),
    .m_axi_from_ARQOS(m_axi_var_input_0_3_ARQOS),
    .m_axi_from_ARREADY(m_axi_var_input_0_3_ARREADY),
    .m_axi_from_ARREGION(m_axi_var_input_0_3_ARREGION),
    .m_axi_from_ARSIZE(m_axi_var_input_0_3_ARSIZE),
    .m_axi_from_ARUSER(m_axi_var_input_0_3_ARUSER),
    .m_axi_from_ARVALID(m_axi_var_input_0_3_ARVALID),
    .m_axi_from_AWADDR(m_axi_var_input_0_3_AWADDR),
    .m_axi_from_AWBURST(m_axi_var_input_0_3_AWBURST),
    .m_axi_from_AWCACHE(m_axi_var_input_0_3_AWCACHE),
    .m_axi_from_AWID(m_axi_var_input_0_3_AWID),
    .m_axi_from_AWLEN(m_axi_var_input_0_3_AWLEN),
    .m_axi_from_AWLOCK(m_axi_var_input_0_3_AWLOCK),
    .m_axi_from_AWPROT(m_axi_var_input_0_3_AWPROT),
    .m_axi_from_AWQOS(m_axi_var_input_0_3_AWQOS),
    .m_axi_from_AWREADY(m_axi_var_input_0_3_AWREADY),
    .m_axi_from_AWREGION(m_axi_var_input_0_3_AWREGION),
    .m_axi_from_AWSIZE(m_axi_var_input_0_3_AWSIZE),
    .m_axi_from_AWUSER(m_axi_var_input_0_3_AWUSER),
    .m_axi_from_AWVALID(m_axi_var_input_0_3_AWVALID),
    .m_axi_from_BID(m_axi_var_input_0_3_BID),
    .m_axi_from_BREADY(m_axi_var_input_0_3_BREADY),
    .m_axi_from_BRESP(m_axi_var_input_0_3_BRESP),
    .m_axi_from_BUSER(m_axi_var_input_0_3_BUSER),
    .m_axi_from_BVALID(m_axi_var_input_0_3_BVALID),
    .m_axi_from_RDATA(m_axi_var_input_0_3_RDATA),
    .m_axi_from_RID(m_axi_var_input_0_3_RID),
    .m_axi_from_RLAST(m_axi_var_input_0_3_RLAST),
    .m_axi_from_RREADY(m_axi_var_input_0_3_RREADY),
    .m_axi_from_RRESP(m_axi_var_input_0_3_RRESP),
    .m_axi_from_RUSER(m_axi_var_input_0_3_RUSER),
    .m_axi_from_RVALID(m_axi_var_input_0_3_RVALID),
    .m_axi_from_WDATA(m_axi_var_input_0_3_WDATA),
    .m_axi_from_WID(m_axi_var_input_0_3_WID),
    .m_axi_from_WLAST(m_axi_var_input_0_3_WLAST),
    .m_axi_from_WREADY(m_axi_var_input_0_3_WREADY),
    .m_axi_from_WSTRB(m_axi_var_input_0_3_WSTRB),
    .m_axi_from_WUSER(m_axi_var_input_0_3_WUSER),
    .m_axi_from_WVALID(m_axi_var_input_0_3_WVALID),
    .from_V(var_input_0_3__q6)
  );


  (* keep_hierarchy = "yes" *) store_store
  store_0
  (
    .ap_clk(ap_clk),
    .ap_rst_n(store_0__ap_rst_n__q6),
    .ap_start(store_0__ap_start),
    .ap_done(store_0__ap_done),
    .ap_idle(store_0__ap_idle),
    .ap_ready(store_0__ap_ready),
    .data_num(store_0___coalesced_data_num__q6),
    .from_fifo_V_dout(output_stream_6_0__dout),
    .from_fifo_V_empty_n(output_stream_6_0__empty_n),
    .from_fifo_V_read(output_stream_6_0__read),
    .from_peek_val(output_stream_6_0__dout),
    .m_axi_to_ARADDR(m_axi_var_output_0_0_ARADDR),
    .m_axi_to_ARBURST(m_axi_var_output_0_0_ARBURST),
    .m_axi_to_ARCACHE(m_axi_var_output_0_0_ARCACHE),
    .m_axi_to_ARID(m_axi_var_output_0_0_ARID),
    .m_axi_to_ARLEN(m_axi_var_output_0_0_ARLEN),
    .m_axi_to_ARLOCK(m_axi_var_output_0_0_ARLOCK),
    .m_axi_to_ARPROT(m_axi_var_output_0_0_ARPROT),
    .m_axi_to_ARQOS(m_axi_var_output_0_0_ARQOS),
    .m_axi_to_ARREADY(m_axi_var_output_0_0_ARREADY),
    .m_axi_to_ARREGION(m_axi_var_output_0_0_ARREGION),
    .m_axi_to_ARSIZE(m_axi_var_output_0_0_ARSIZE),
    .m_axi_to_ARUSER(m_axi_var_output_0_0_ARUSER),
    .m_axi_to_ARVALID(m_axi_var_output_0_0_ARVALID),
    .m_axi_to_AWADDR(m_axi_var_output_0_0_AWADDR),
    .m_axi_to_AWBURST(m_axi_var_output_0_0_AWBURST),
    .m_axi_to_AWCACHE(m_axi_var_output_0_0_AWCACHE),
    .m_axi_to_AWID(m_axi_var_output_0_0_AWID),
    .m_axi_to_AWLEN(m_axi_var_output_0_0_AWLEN),
    .m_axi_to_AWLOCK(m_axi_var_output_0_0_AWLOCK),
    .m_axi_to_AWPROT(m_axi_var_output_0_0_AWPROT),
    .m_axi_to_AWQOS(m_axi_var_output_0_0_AWQOS),
    .m_axi_to_AWREADY(m_axi_var_output_0_0_AWREADY),
    .m_axi_to_AWREGION(m_axi_var_output_0_0_AWREGION),
    .m_axi_to_AWSIZE(m_axi_var_output_0_0_AWSIZE),
    .m_axi_to_AWUSER(m_axi_var_output_0_0_AWUSER),
    .m_axi_to_AWVALID(m_axi_var_output_0_0_AWVALID),
    .m_axi_to_BID(m_axi_var_output_0_0_BID),
    .m_axi_to_BREADY(m_axi_var_output_0_0_BREADY),
    .m_axi_to_BRESP(m_axi_var_output_0_0_BRESP),
    .m_axi_to_BUSER(m_axi_var_output_0_0_BUSER),
    .m_axi_to_BVALID(m_axi_var_output_0_0_BVALID),
    .m_axi_to_RDATA(m_axi_var_output_0_0_RDATA),
    .m_axi_to_RID(m_axi_var_output_0_0_RID),
    .m_axi_to_RLAST(m_axi_var_output_0_0_RLAST),
    .m_axi_to_RREADY(m_axi_var_output_0_0_RREADY),
    .m_axi_to_RRESP(m_axi_var_output_0_0_RRESP),
    .m_axi_to_RUSER(m_axi_var_output_0_0_RUSER),
    .m_axi_to_RVALID(m_axi_var_output_0_0_RVALID),
    .m_axi_to_WDATA(m_axi_var_output_0_0_WDATA),
    .m_axi_to_WID(m_axi_var_output_0_0_WID),
    .m_axi_to_WLAST(m_axi_var_output_0_0_WLAST),
    .m_axi_to_WREADY(m_axi_var_output_0_0_WREADY),
    .m_axi_to_WSTRB(m_axi_var_output_0_0_WSTRB),
    .m_axi_to_WUSER(m_axi_var_output_0_0_WUSER),
    .m_axi_to_WVALID(m_axi_var_output_0_0_WVALID),
    .to_offset(var_output_0_0__q6)
  );


  (* keep_hierarchy = "yes" *) store_store
  store_1
  (
    .ap_clk(ap_clk),
    .ap_rst_n(store_1__ap_rst_n__q6),
    .ap_start(store_1__ap_start),
    .ap_done(store_1__ap_done),
    .ap_idle(store_1__ap_idle),
    .ap_ready(store_1__ap_ready),
    .data_num(store_1___coalesced_data_num__q6),
    .from_fifo_V_dout(output_stream_6_1__dout),
    .from_fifo_V_empty_n(output_stream_6_1__empty_n),
    .from_fifo_V_read(output_stream_6_1__read),
    .from_peek_val(output_stream_6_1__dout),
    .m_axi_to_ARADDR(m_axi_var_output_0_1_ARADDR),
    .m_axi_to_ARBURST(m_axi_var_output_0_1_ARBURST),
    .m_axi_to_ARCACHE(m_axi_var_output_0_1_ARCACHE),
    .m_axi_to_ARID(m_axi_var_output_0_1_ARID),
    .m_axi_to_ARLEN(m_axi_var_output_0_1_ARLEN),
    .m_axi_to_ARLOCK(m_axi_var_output_0_1_ARLOCK),
    .m_axi_to_ARPROT(m_axi_var_output_0_1_ARPROT),
    .m_axi_to_ARQOS(m_axi_var_output_0_1_ARQOS),
    .m_axi_to_ARREADY(m_axi_var_output_0_1_ARREADY),
    .m_axi_to_ARREGION(m_axi_var_output_0_1_ARREGION),
    .m_axi_to_ARSIZE(m_axi_var_output_0_1_ARSIZE),
    .m_axi_to_ARUSER(m_axi_var_output_0_1_ARUSER),
    .m_axi_to_ARVALID(m_axi_var_output_0_1_ARVALID),
    .m_axi_to_AWADDR(m_axi_var_output_0_1_AWADDR),
    .m_axi_to_AWBURST(m_axi_var_output_0_1_AWBURST),
    .m_axi_to_AWCACHE(m_axi_var_output_0_1_AWCACHE),
    .m_axi_to_AWID(m_axi_var_output_0_1_AWID),
    .m_axi_to_AWLEN(m_axi_var_output_0_1_AWLEN),
    .m_axi_to_AWLOCK(m_axi_var_output_0_1_AWLOCK),
    .m_axi_to_AWPROT(m_axi_var_output_0_1_AWPROT),
    .m_axi_to_AWQOS(m_axi_var_output_0_1_AWQOS),
    .m_axi_to_AWREADY(m_axi_var_output_0_1_AWREADY),
    .m_axi_to_AWREGION(m_axi_var_output_0_1_AWREGION),
    .m_axi_to_AWSIZE(m_axi_var_output_0_1_AWSIZE),
    .m_axi_to_AWUSER(m_axi_var_output_0_1_AWUSER),
    .m_axi_to_AWVALID(m_axi_var_output_0_1_AWVALID),
    .m_axi_to_BID(m_axi_var_output_0_1_BID),
    .m_axi_to_BREADY(m_axi_var_output_0_1_BREADY),
    .m_axi_to_BRESP(m_axi_var_output_0_1_BRESP),
    .m_axi_to_BUSER(m_axi_var_output_0_1_BUSER),
    .m_axi_to_BVALID(m_axi_var_output_0_1_BVALID),
    .m_axi_to_RDATA(m_axi_var_output_0_1_RDATA),
    .m_axi_to_RID(m_axi_var_output_0_1_RID),
    .m_axi_to_RLAST(m_axi_var_output_0_1_RLAST),
    .m_axi_to_RREADY(m_axi_var_output_0_1_RREADY),
    .m_axi_to_RRESP(m_axi_var_output_0_1_RRESP),
    .m_axi_to_RUSER(m_axi_var_output_0_1_RUSER),
    .m_axi_to_RVALID(m_axi_var_output_0_1_RVALID),
    .m_axi_to_WDATA(m_axi_var_output_0_1_WDATA),
    .m_axi_to_WID(m_axi_var_output_0_1_WID),
    .m_axi_to_WLAST(m_axi_var_output_0_1_WLAST),
    .m_axi_to_WREADY(m_axi_var_output_0_1_WREADY),
    .m_axi_to_WSTRB(m_axi_var_output_0_1_WSTRB),
    .m_axi_to_WUSER(m_axi_var_output_0_1_WUSER),
    .m_axi_to_WVALID(m_axi_var_output_0_1_WVALID),
    .to_offset(var_output_0_1__q6)
  );


  (* keep_hierarchy = "yes" *) store_store
  store_2
  (
    .ap_clk(ap_clk),
    .ap_rst_n(store_2__ap_rst_n__q6),
    .ap_start(store_2__ap_start),
    .ap_done(store_2__ap_done),
    .ap_idle(store_2__ap_idle),
    .ap_ready(store_2__ap_ready),
    .data_num(store_2___coalesced_data_num__q6),
    .from_fifo_V_dout(output_stream_6_2__dout),
    .from_fifo_V_empty_n(output_stream_6_2__empty_n),
    .from_fifo_V_read(output_stream_6_2__read),
    .from_peek_val(output_stream_6_2__dout),
    .m_axi_to_ARADDR(m_axi_var_output_0_2_ARADDR),
    .m_axi_to_ARBURST(m_axi_var_output_0_2_ARBURST),
    .m_axi_to_ARCACHE(m_axi_var_output_0_2_ARCACHE),
    .m_axi_to_ARID(m_axi_var_output_0_2_ARID),
    .m_axi_to_ARLEN(m_axi_var_output_0_2_ARLEN),
    .m_axi_to_ARLOCK(m_axi_var_output_0_2_ARLOCK),
    .m_axi_to_ARPROT(m_axi_var_output_0_2_ARPROT),
    .m_axi_to_ARQOS(m_axi_var_output_0_2_ARQOS),
    .m_axi_to_ARREADY(m_axi_var_output_0_2_ARREADY),
    .m_axi_to_ARREGION(m_axi_var_output_0_2_ARREGION),
    .m_axi_to_ARSIZE(m_axi_var_output_0_2_ARSIZE),
    .m_axi_to_ARUSER(m_axi_var_output_0_2_ARUSER),
    .m_axi_to_ARVALID(m_axi_var_output_0_2_ARVALID),
    .m_axi_to_AWADDR(m_axi_var_output_0_2_AWADDR),
    .m_axi_to_AWBURST(m_axi_var_output_0_2_AWBURST),
    .m_axi_to_AWCACHE(m_axi_var_output_0_2_AWCACHE),
    .m_axi_to_AWID(m_axi_var_output_0_2_AWID),
    .m_axi_to_AWLEN(m_axi_var_output_0_2_AWLEN),
    .m_axi_to_AWLOCK(m_axi_var_output_0_2_AWLOCK),
    .m_axi_to_AWPROT(m_axi_var_output_0_2_AWPROT),
    .m_axi_to_AWQOS(m_axi_var_output_0_2_AWQOS),
    .m_axi_to_AWREADY(m_axi_var_output_0_2_AWREADY),
    .m_axi_to_AWREGION(m_axi_var_output_0_2_AWREGION),
    .m_axi_to_AWSIZE(m_axi_var_output_0_2_AWSIZE),
    .m_axi_to_AWUSER(m_axi_var_output_0_2_AWUSER),
    .m_axi_to_AWVALID(m_axi_var_output_0_2_AWVALID),
    .m_axi_to_BID(m_axi_var_output_0_2_BID),
    .m_axi_to_BREADY(m_axi_var_output_0_2_BREADY),
    .m_axi_to_BRESP(m_axi_var_output_0_2_BRESP),
    .m_axi_to_BUSER(m_axi_var_output_0_2_BUSER),
    .m_axi_to_BVALID(m_axi_var_output_0_2_BVALID),
    .m_axi_to_RDATA(m_axi_var_output_0_2_RDATA),
    .m_axi_to_RID(m_axi_var_output_0_2_RID),
    .m_axi_to_RLAST(m_axi_var_output_0_2_RLAST),
    .m_axi_to_RREADY(m_axi_var_output_0_2_RREADY),
    .m_axi_to_RRESP(m_axi_var_output_0_2_RRESP),
    .m_axi_to_RUSER(m_axi_var_output_0_2_RUSER),
    .m_axi_to_RVALID(m_axi_var_output_0_2_RVALID),
    .m_axi_to_WDATA(m_axi_var_output_0_2_WDATA),
    .m_axi_to_WID(m_axi_var_output_0_2_WID),
    .m_axi_to_WLAST(m_axi_var_output_0_2_WLAST),
    .m_axi_to_WREADY(m_axi_var_output_0_2_WREADY),
    .m_axi_to_WSTRB(m_axi_var_output_0_2_WSTRB),
    .m_axi_to_WUSER(m_axi_var_output_0_2_WUSER),
    .m_axi_to_WVALID(m_axi_var_output_0_2_WVALID),
    .to_offset(var_output_0_2__q6)
  );


  (* keep_hierarchy = "yes" *) store_store
  store_3
  (
    .ap_clk(ap_clk),
    .ap_rst_n(store_3__ap_rst_n__q6),
    .ap_start(store_3__ap_start),
    .ap_done(store_3__ap_done),
    .ap_idle(store_3__ap_idle),
    .ap_ready(store_3__ap_ready),
    .data_num(store_3___coalesced_data_num__q6),
    .from_fifo_V_dout(output_stream_6_3__dout),
    .from_fifo_V_empty_n(output_stream_6_3__empty_n),
    .from_fifo_V_read(output_stream_6_3__read),
    .from_peek_val(output_stream_6_3__dout),
    .m_axi_to_ARADDR(m_axi_var_output_0_3_ARADDR),
    .m_axi_to_ARBURST(m_axi_var_output_0_3_ARBURST),
    .m_axi_to_ARCACHE(m_axi_var_output_0_3_ARCACHE),
    .m_axi_to_ARID(m_axi_var_output_0_3_ARID),
    .m_axi_to_ARLEN(m_axi_var_output_0_3_ARLEN),
    .m_axi_to_ARLOCK(m_axi_var_output_0_3_ARLOCK),
    .m_axi_to_ARPROT(m_axi_var_output_0_3_ARPROT),
    .m_axi_to_ARQOS(m_axi_var_output_0_3_ARQOS),
    .m_axi_to_ARREADY(m_axi_var_output_0_3_ARREADY),
    .m_axi_to_ARREGION(m_axi_var_output_0_3_ARREGION),
    .m_axi_to_ARSIZE(m_axi_var_output_0_3_ARSIZE),
    .m_axi_to_ARUSER(m_axi_var_output_0_3_ARUSER),
    .m_axi_to_ARVALID(m_axi_var_output_0_3_ARVALID),
    .m_axi_to_AWADDR(m_axi_var_output_0_3_AWADDR),
    .m_axi_to_AWBURST(m_axi_var_output_0_3_AWBURST),
    .m_axi_to_AWCACHE(m_axi_var_output_0_3_AWCACHE),
    .m_axi_to_AWID(m_axi_var_output_0_3_AWID),
    .m_axi_to_AWLEN(m_axi_var_output_0_3_AWLEN),
    .m_axi_to_AWLOCK(m_axi_var_output_0_3_AWLOCK),
    .m_axi_to_AWPROT(m_axi_var_output_0_3_AWPROT),
    .m_axi_to_AWQOS(m_axi_var_output_0_3_AWQOS),
    .m_axi_to_AWREADY(m_axi_var_output_0_3_AWREADY),
    .m_axi_to_AWREGION(m_axi_var_output_0_3_AWREGION),
    .m_axi_to_AWSIZE(m_axi_var_output_0_3_AWSIZE),
    .m_axi_to_AWUSER(m_axi_var_output_0_3_AWUSER),
    .m_axi_to_AWVALID(m_axi_var_output_0_3_AWVALID),
    .m_axi_to_BID(m_axi_var_output_0_3_BID),
    .m_axi_to_BREADY(m_axi_var_output_0_3_BREADY),
    .m_axi_to_BRESP(m_axi_var_output_0_3_BRESP),
    .m_axi_to_BUSER(m_axi_var_output_0_3_BUSER),
    .m_axi_to_BVALID(m_axi_var_output_0_3_BVALID),
    .m_axi_to_RDATA(m_axi_var_output_0_3_RDATA),
    .m_axi_to_RID(m_axi_var_output_0_3_RID),
    .m_axi_to_RLAST(m_axi_var_output_0_3_RLAST),
    .m_axi_to_RREADY(m_axi_var_output_0_3_RREADY),
    .m_axi_to_RRESP(m_axi_var_output_0_3_RRESP),
    .m_axi_to_RUSER(m_axi_var_output_0_3_RUSER),
    .m_axi_to_RVALID(m_axi_var_output_0_3_RVALID),
    .m_axi_to_WDATA(m_axi_var_output_0_3_WDATA),
    .m_axi_to_WID(m_axi_var_output_0_3_WID),
    .m_axi_to_WLAST(m_axi_var_output_0_3_WLAST),
    .m_axi_to_WREADY(m_axi_var_output_0_3_WREADY),
    .m_axi_to_WSTRB(m_axi_var_output_0_3_WSTRB),
    .m_axi_to_WUSER(m_axi_var_output_0_3_WUSER),
    .m_axi_to_WVALID(m_axi_var_output_0_3_WVALID),
    .to_offset(var_output_0_3__q6)
  );


  always @(posedge ap_clk) begin
    ap_rst_n__q1 <= ap_rst_n__q0;
    ap_rst_n__q2 <= ap_rst_n__q1;
    ap_rst_n__q6 <= ap_rst_n__q5;
    ap_rst_n__q5 <= ap_rst_n__q4;
    ap_rst_n__q4 <= ap_rst_n__q3;
    ap_rst_n__q3 <= ap_rst_n__q2;
  end

  assign ap_rst_n__q0 = ap_rst_n;
  assign ap_rst_n_inv = ~ap_rst_n__q6;

  always @(posedge ap_clk) begin
    input_stream_0_0__rst__q1 <= input_stream_0_0__rst__q0;
    input_stream_0_0__rst__q2 <= input_stream_0_0__rst__q1;
    input_stream_0_0__rst__q6 <= input_stream_0_0__rst__q5;
    input_stream_0_0__rst__q5 <= input_stream_0_0__rst__q4;
    input_stream_0_0__rst__q4 <= input_stream_0_0__rst__q3;
    input_stream_0_0__rst__q3 <= input_stream_0_0__rst__q2;
  end

  assign input_stream_0_0__rst__q0 = ~ap_rst_n;

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
    input_stream_0_1__rst__q6 <= input_stream_0_1__rst__q5;
    input_stream_0_1__rst__q5 <= input_stream_0_1__rst__q4;
    input_stream_0_1__rst__q4 <= input_stream_0_1__rst__q3;
    input_stream_0_1__rst__q3 <= input_stream_0_1__rst__q2;
  end

  assign input_stream_0_1__rst__q0 = ~ap_rst_n;

  always @(posedge ap_clk) begin
    if(input_stream_0_1__read == 1'b1) begin
      $display("DEBUG: R: \033[97m input_stream_0_1\033[0m -> \033[90mcompute_0        \033[0m %h", input_stream_0_1__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(input_stream_0_1__write == 1'b1) begin
      $display("DEBUG: W: \033[90m           load_1\033[0m -> \033[97minput_stream_0_1 \033[0m %h", input_stream_0_1__din);
    end 
  end


  always @(posedge ap_clk) begin
    input_stream_0_2__rst__q1 <= input_stream_0_2__rst__q0;
    input_stream_0_2__rst__q2 <= input_stream_0_2__rst__q1;
    input_stream_0_2__rst__q6 <= input_stream_0_2__rst__q5;
    input_stream_0_2__rst__q5 <= input_stream_0_2__rst__q4;
    input_stream_0_2__rst__q4 <= input_stream_0_2__rst__q3;
    input_stream_0_2__rst__q3 <= input_stream_0_2__rst__q2;
  end

  assign input_stream_0_2__rst__q0 = ~ap_rst_n;

  always @(posedge ap_clk) begin
    if(input_stream_0_2__read == 1'b1) begin
      $display("DEBUG: R: \033[97m input_stream_0_2\033[0m -> \033[90mcompute_0        \033[0m %h", input_stream_0_2__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(input_stream_0_2__write == 1'b1) begin
      $display("DEBUG: W: \033[90m           load_2\033[0m -> \033[97minput_stream_0_2 \033[0m %h", input_stream_0_2__din);
    end 
  end


  always @(posedge ap_clk) begin
    input_stream_0_3__rst__q1 <= input_stream_0_3__rst__q0;
    input_stream_0_3__rst__q2 <= input_stream_0_3__rst__q1;
    input_stream_0_3__rst__q6 <= input_stream_0_3__rst__q5;
    input_stream_0_3__rst__q5 <= input_stream_0_3__rst__q4;
    input_stream_0_3__rst__q4 <= input_stream_0_3__rst__q3;
    input_stream_0_3__rst__q3 <= input_stream_0_3__rst__q2;
  end

  assign input_stream_0_3__rst__q0 = ~ap_rst_n;

  always @(posedge ap_clk) begin
    if(input_stream_0_3__read == 1'b1) begin
      $display("DEBUG: R: \033[97m input_stream_0_3\033[0m -> \033[90mcompute_0        \033[0m %h", input_stream_0_3__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(input_stream_0_3__write == 1'b1) begin
      $display("DEBUG: W: \033[90m           load_3\033[0m -> \033[97minput_stream_0_3 \033[0m %h", input_stream_0_3__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_0_0__rst__q1 <= output_stream_0_0__rst__q0;
    output_stream_0_0__rst__q2 <= output_stream_0_0__rst__q1;
    output_stream_0_0__rst__q6 <= output_stream_0_0__rst__q5;
    output_stream_0_0__rst__q5 <= output_stream_0_0__rst__q4;
    output_stream_0_0__rst__q4 <= output_stream_0_0__rst__q3;
    output_stream_0_0__rst__q3 <= output_stream_0_0__rst__q2;
  end

  assign output_stream_0_0__rst__q0 = ~ap_rst_n;

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
    output_stream_0_1__rst__q6 <= output_stream_0_1__rst__q5;
    output_stream_0_1__rst__q5 <= output_stream_0_1__rst__q4;
    output_stream_0_1__rst__q4 <= output_stream_0_1__rst__q3;
    output_stream_0_1__rst__q3 <= output_stream_0_1__rst__q2;
  end

  assign output_stream_0_1__rst__q0 = ~ap_rst_n;

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
    output_stream_0_2__rst__q6 <= output_stream_0_2__rst__q5;
    output_stream_0_2__rst__q5 <= output_stream_0_2__rst__q4;
    output_stream_0_2__rst__q4 <= output_stream_0_2__rst__q3;
    output_stream_0_2__rst__q3 <= output_stream_0_2__rst__q2;
  end

  assign output_stream_0_2__rst__q0 = ~ap_rst_n;

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
    output_stream_0_3__rst__q6 <= output_stream_0_3__rst__q5;
    output_stream_0_3__rst__q5 <= output_stream_0_3__rst__q4;
    output_stream_0_3__rst__q4 <= output_stream_0_3__rst__q3;
    output_stream_0_3__rst__q3 <= output_stream_0_3__rst__q2;
  end

  assign output_stream_0_3__rst__q0 = ~ap_rst_n;

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
    output_stream_1_0__rst__q6 <= output_stream_1_0__rst__q5;
    output_stream_1_0__rst__q5 <= output_stream_1_0__rst__q4;
    output_stream_1_0__rst__q4 <= output_stream_1_0__rst__q3;
    output_stream_1_0__rst__q3 <= output_stream_1_0__rst__q2;
  end

  assign output_stream_1_0__rst__q0 = ~ap_rst_n;

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
    output_stream_1_1__rst__q6 <= output_stream_1_1__rst__q5;
    output_stream_1_1__rst__q5 <= output_stream_1_1__rst__q4;
    output_stream_1_1__rst__q4 <= output_stream_1_1__rst__q3;
    output_stream_1_1__rst__q3 <= output_stream_1_1__rst__q2;
  end

  assign output_stream_1_1__rst__q0 = ~ap_rst_n;

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
    output_stream_1_2__rst__q6 <= output_stream_1_2__rst__q5;
    output_stream_1_2__rst__q5 <= output_stream_1_2__rst__q4;
    output_stream_1_2__rst__q4 <= output_stream_1_2__rst__q3;
    output_stream_1_2__rst__q3 <= output_stream_1_2__rst__q2;
  end

  assign output_stream_1_2__rst__q0 = ~ap_rst_n;

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
    output_stream_1_3__rst__q6 <= output_stream_1_3__rst__q5;
    output_stream_1_3__rst__q5 <= output_stream_1_3__rst__q4;
    output_stream_1_3__rst__q4 <= output_stream_1_3__rst__q3;
    output_stream_1_3__rst__q3 <= output_stream_1_3__rst__q2;
  end

  assign output_stream_1_3__rst__q0 = ~ap_rst_n;

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
    output_stream_2_0__rst__q6 <= output_stream_2_0__rst__q5;
    output_stream_2_0__rst__q5 <= output_stream_2_0__rst__q4;
    output_stream_2_0__rst__q4 <= output_stream_2_0__rst__q3;
    output_stream_2_0__rst__q3 <= output_stream_2_0__rst__q2;
  end

  assign output_stream_2_0__rst__q0 = ~ap_rst_n;

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
    output_stream_2_1__rst__q6 <= output_stream_2_1__rst__q5;
    output_stream_2_1__rst__q5 <= output_stream_2_1__rst__q4;
    output_stream_2_1__rst__q4 <= output_stream_2_1__rst__q3;
    output_stream_2_1__rst__q3 <= output_stream_2_1__rst__q2;
  end

  assign output_stream_2_1__rst__q0 = ~ap_rst_n;

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
    output_stream_2_2__rst__q6 <= output_stream_2_2__rst__q5;
    output_stream_2_2__rst__q5 <= output_stream_2_2__rst__q4;
    output_stream_2_2__rst__q4 <= output_stream_2_2__rst__q3;
    output_stream_2_2__rst__q3 <= output_stream_2_2__rst__q2;
  end

  assign output_stream_2_2__rst__q0 = ~ap_rst_n;

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
    output_stream_2_3__rst__q6 <= output_stream_2_3__rst__q5;
    output_stream_2_3__rst__q5 <= output_stream_2_3__rst__q4;
    output_stream_2_3__rst__q4 <= output_stream_2_3__rst__q3;
    output_stream_2_3__rst__q3 <= output_stream_2_3__rst__q2;
  end

  assign output_stream_2_3__rst__q0 = ~ap_rst_n;

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
    output_stream_3_0__rst__q6 <= output_stream_3_0__rst__q5;
    output_stream_3_0__rst__q5 <= output_stream_3_0__rst__q4;
    output_stream_3_0__rst__q4 <= output_stream_3_0__rst__q3;
    output_stream_3_0__rst__q3 <= output_stream_3_0__rst__q2;
  end

  assign output_stream_3_0__rst__q0 = ~ap_rst_n;

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
    output_stream_3_1__rst__q6 <= output_stream_3_1__rst__q5;
    output_stream_3_1__rst__q5 <= output_stream_3_1__rst__q4;
    output_stream_3_1__rst__q4 <= output_stream_3_1__rst__q3;
    output_stream_3_1__rst__q3 <= output_stream_3_1__rst__q2;
  end

  assign output_stream_3_1__rst__q0 = ~ap_rst_n;

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
    output_stream_3_2__rst__q6 <= output_stream_3_2__rst__q5;
    output_stream_3_2__rst__q5 <= output_stream_3_2__rst__q4;
    output_stream_3_2__rst__q4 <= output_stream_3_2__rst__q3;
    output_stream_3_2__rst__q3 <= output_stream_3_2__rst__q2;
  end

  assign output_stream_3_2__rst__q0 = ~ap_rst_n;

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
    output_stream_3_3__rst__q6 <= output_stream_3_3__rst__q5;
    output_stream_3_3__rst__q5 <= output_stream_3_3__rst__q4;
    output_stream_3_3__rst__q4 <= output_stream_3_3__rst__q3;
    output_stream_3_3__rst__q3 <= output_stream_3_3__rst__q2;
  end

  assign output_stream_3_3__rst__q0 = ~ap_rst_n;

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
    output_stream_4_0__rst__q6 <= output_stream_4_0__rst__q5;
    output_stream_4_0__rst__q5 <= output_stream_4_0__rst__q4;
    output_stream_4_0__rst__q4 <= output_stream_4_0__rst__q3;
    output_stream_4_0__rst__q3 <= output_stream_4_0__rst__q2;
  end

  assign output_stream_4_0__rst__q0 = ~ap_rst_n;

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
    output_stream_4_1__rst__q6 <= output_stream_4_1__rst__q5;
    output_stream_4_1__rst__q5 <= output_stream_4_1__rst__q4;
    output_stream_4_1__rst__q4 <= output_stream_4_1__rst__q3;
    output_stream_4_1__rst__q3 <= output_stream_4_1__rst__q2;
  end

  assign output_stream_4_1__rst__q0 = ~ap_rst_n;

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
    output_stream_4_2__rst__q6 <= output_stream_4_2__rst__q5;
    output_stream_4_2__rst__q5 <= output_stream_4_2__rst__q4;
    output_stream_4_2__rst__q4 <= output_stream_4_2__rst__q3;
    output_stream_4_2__rst__q3 <= output_stream_4_2__rst__q2;
  end

  assign output_stream_4_2__rst__q0 = ~ap_rst_n;

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
    output_stream_4_3__rst__q6 <= output_stream_4_3__rst__q5;
    output_stream_4_3__rst__q5 <= output_stream_4_3__rst__q4;
    output_stream_4_3__rst__q4 <= output_stream_4_3__rst__q3;
    output_stream_4_3__rst__q3 <= output_stream_4_3__rst__q2;
  end

  assign output_stream_4_3__rst__q0 = ~ap_rst_n;

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
    output_stream_5_0__rst__q6 <= output_stream_5_0__rst__q5;
    output_stream_5_0__rst__q5 <= output_stream_5_0__rst__q4;
    output_stream_5_0__rst__q4 <= output_stream_5_0__rst__q3;
    output_stream_5_0__rst__q3 <= output_stream_5_0__rst__q2;
  end

  assign output_stream_5_0__rst__q0 = ~ap_rst_n;

  always @(posedge ap_clk) begin
    if(output_stream_5_0__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_5_0\033[0m -> \033[90mcompute_6        \033[0m %h", output_stream_5_0__dout);
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
    output_stream_5_1__rst__q6 <= output_stream_5_1__rst__q5;
    output_stream_5_1__rst__q5 <= output_stream_5_1__rst__q4;
    output_stream_5_1__rst__q4 <= output_stream_5_1__rst__q3;
    output_stream_5_1__rst__q3 <= output_stream_5_1__rst__q2;
  end

  assign output_stream_5_1__rst__q0 = ~ap_rst_n;

  always @(posedge ap_clk) begin
    if(output_stream_5_1__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_5_1\033[0m -> \033[90mcompute_6        \033[0m %h", output_stream_5_1__dout);
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
    output_stream_5_2__rst__q6 <= output_stream_5_2__rst__q5;
    output_stream_5_2__rst__q5 <= output_stream_5_2__rst__q4;
    output_stream_5_2__rst__q4 <= output_stream_5_2__rst__q3;
    output_stream_5_2__rst__q3 <= output_stream_5_2__rst__q2;
  end

  assign output_stream_5_2__rst__q0 = ~ap_rst_n;

  always @(posedge ap_clk) begin
    if(output_stream_5_2__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_5_2\033[0m -> \033[90mcompute_6        \033[0m %h", output_stream_5_2__dout);
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
    output_stream_5_3__rst__q6 <= output_stream_5_3__rst__q5;
    output_stream_5_3__rst__q5 <= output_stream_5_3__rst__q4;
    output_stream_5_3__rst__q4 <= output_stream_5_3__rst__q3;
    output_stream_5_3__rst__q3 <= output_stream_5_3__rst__q2;
  end

  assign output_stream_5_3__rst__q0 = ~ap_rst_n;

  always @(posedge ap_clk) begin
    if(output_stream_5_3__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_5_3\033[0m -> \033[90mcompute_6        \033[0m %h", output_stream_5_3__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_5_3__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_5\033[0m -> \033[97moutput_stream_5_3\033[0m %h", output_stream_5_3__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_6_0__rst__q1 <= output_stream_6_0__rst__q0;
    output_stream_6_0__rst__q2 <= output_stream_6_0__rst__q1;
    output_stream_6_0__rst__q6 <= output_stream_6_0__rst__q5;
    output_stream_6_0__rst__q5 <= output_stream_6_0__rst__q4;
    output_stream_6_0__rst__q4 <= output_stream_6_0__rst__q3;
    output_stream_6_0__rst__q3 <= output_stream_6_0__rst__q2;
  end

  assign output_stream_6_0__rst__q0 = ~ap_rst_n;

  always @(posedge ap_clk) begin
    if(output_stream_6_0__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_6_0\033[0m -> \033[90mstore_0          \033[0m %h", output_stream_6_0__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_6_0__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_6\033[0m -> \033[97moutput_stream_6_0\033[0m %h", output_stream_6_0__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_6_1__rst__q1 <= output_stream_6_1__rst__q0;
    output_stream_6_1__rst__q2 <= output_stream_6_1__rst__q1;
    output_stream_6_1__rst__q6 <= output_stream_6_1__rst__q5;
    output_stream_6_1__rst__q5 <= output_stream_6_1__rst__q4;
    output_stream_6_1__rst__q4 <= output_stream_6_1__rst__q3;
    output_stream_6_1__rst__q3 <= output_stream_6_1__rst__q2;
  end

  assign output_stream_6_1__rst__q0 = ~ap_rst_n;

  always @(posedge ap_clk) begin
    if(output_stream_6_1__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_6_1\033[0m -> \033[90mstore_1          \033[0m %h", output_stream_6_1__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_6_1__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_6\033[0m -> \033[97moutput_stream_6_1\033[0m %h", output_stream_6_1__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_6_2__rst__q1 <= output_stream_6_2__rst__q0;
    output_stream_6_2__rst__q2 <= output_stream_6_2__rst__q1;
    output_stream_6_2__rst__q6 <= output_stream_6_2__rst__q5;
    output_stream_6_2__rst__q5 <= output_stream_6_2__rst__q4;
    output_stream_6_2__rst__q4 <= output_stream_6_2__rst__q3;
    output_stream_6_2__rst__q3 <= output_stream_6_2__rst__q2;
  end

  assign output_stream_6_2__rst__q0 = ~ap_rst_n;

  always @(posedge ap_clk) begin
    if(output_stream_6_2__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_6_2\033[0m -> \033[90mstore_2          \033[0m %h", output_stream_6_2__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_6_2__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_6\033[0m -> \033[97moutput_stream_6_2\033[0m %h", output_stream_6_2__din);
    end 
  end


  always @(posedge ap_clk) begin
    output_stream_6_3__rst__q1 <= output_stream_6_3__rst__q0;
    output_stream_6_3__rst__q2 <= output_stream_6_3__rst__q1;
    output_stream_6_3__rst__q6 <= output_stream_6_3__rst__q5;
    output_stream_6_3__rst__q5 <= output_stream_6_3__rst__q4;
    output_stream_6_3__rst__q4 <= output_stream_6_3__rst__q3;
    output_stream_6_3__rst__q3 <= output_stream_6_3__rst__q2;
  end

  assign output_stream_6_3__rst__q0 = ~ap_rst_n;

  always @(posedge ap_clk) begin
    if(output_stream_6_3__read == 1'b1) begin
      $display("DEBUG: R: \033[97moutput_stream_6_3\033[0m -> \033[90mstore_3          \033[0m %h", output_stream_6_3__dout);
    end 
  end


  always @(posedge ap_clk) begin
    if(output_stream_6_3__write == 1'b1) begin
      $display("DEBUG: W: \033[90m        compute_6\033[0m -> \033[97moutput_stream_6_3\033[0m %h", output_stream_6_3__din);
    end 
  end


  always @(posedge ap_clk) begin
    compute_0___coalesced_data_num__q1 <= compute_0___coalesced_data_num__q0;
    compute_0___coalesced_data_num__q2 <= compute_0___coalesced_data_num__q1;
    compute_0___coalesced_data_num__q6 <= compute_0___coalesced_data_num__q5;
    compute_0___coalesced_data_num__q5 <= compute_0___coalesced_data_num__q4;
    compute_0___coalesced_data_num__q4 <= compute_0___coalesced_data_num__q3;
    compute_0___coalesced_data_num__q3 <= compute_0___coalesced_data_num__q2;
  end

  assign compute_0___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    compute_0___input_size_dim_0__q1 <= compute_0___input_size_dim_0__q0;
    compute_0___input_size_dim_0__q2 <= compute_0___input_size_dim_0__q1;
    compute_0___input_size_dim_0__q6 <= compute_0___input_size_dim_0__q5;
    compute_0___input_size_dim_0__q5 <= compute_0___input_size_dim_0__q4;
    compute_0___input_size_dim_0__q4 <= compute_0___input_size_dim_0__q3;
    compute_0___input_size_dim_0__q3 <= compute_0___input_size_dim_0__q2;
  end

  assign compute_0___input_size_dim_0__q0 = input_size_dim_0;

  always @(posedge ap_clk) begin
    compute_0___input_size_dim_1__q1 <= compute_0___input_size_dim_1__q0;
    compute_0___input_size_dim_1__q2 <= compute_0___input_size_dim_1__q1;
    compute_0___input_size_dim_1__q6 <= compute_0___input_size_dim_1__q5;
    compute_0___input_size_dim_1__q5 <= compute_0___input_size_dim_1__q4;
    compute_0___input_size_dim_1__q4 <= compute_0___input_size_dim_1__q3;
    compute_0___input_size_dim_1__q3 <= compute_0___input_size_dim_1__q2;
  end

  assign compute_0___input_size_dim_1__q0 = input_size_dim_1;

  always @(posedge ap_clk) begin
    compute_0___tile_data_num__q1 <= compute_0___tile_data_num__q0;
    compute_0___tile_data_num__q2 <= compute_0___tile_data_num__q1;
    compute_0___tile_data_num__q6 <= compute_0___tile_data_num__q5;
    compute_0___tile_data_num__q5 <= compute_0___tile_data_num__q4;
    compute_0___tile_data_num__q4 <= compute_0___tile_data_num__q3;
    compute_0___tile_data_num__q3 <= compute_0___tile_data_num__q2;
  end

  assign compute_0___tile_data_num__q0 = tile_data_num;

  always @(posedge ap_clk) begin
    compute_0___tile_num_dim_0__q1 <= compute_0___tile_num_dim_0__q0;
    compute_0___tile_num_dim_0__q2 <= compute_0___tile_num_dim_0__q1;
    compute_0___tile_num_dim_0__q6 <= compute_0___tile_num_dim_0__q5;
    compute_0___tile_num_dim_0__q5 <= compute_0___tile_num_dim_0__q4;
    compute_0___tile_num_dim_0__q4 <= compute_0___tile_num_dim_0__q3;
    compute_0___tile_num_dim_0__q3 <= compute_0___tile_num_dim_0__q2;
  end

  assign compute_0___tile_num_dim_0__q0 = tile_num_dim_0;

  always @(posedge ap_clk) begin
    compute_0__ap_rst_n__q1 <= compute_0__ap_rst_n__q0;
    compute_0__ap_rst_n__q2 <= compute_0__ap_rst_n__q1;
    compute_0__ap_rst_n__q6 <= compute_0__ap_rst_n__q5;
    compute_0__ap_rst_n__q5 <= compute_0__ap_rst_n__q4;
    compute_0__ap_rst_n__q4 <= compute_0__ap_rst_n__q3;
    compute_0__ap_rst_n__q3 <= compute_0__ap_rst_n__q2;
  end

  assign compute_0__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    compute_0__is_done__q1 <= compute_0__is_done__q0;
    compute_0__is_done__q2 <= compute_0__is_done__q1;
    compute_0__is_done__q6 <= compute_0__is_done__q5;
    compute_0__is_done__q5 <= compute_0__is_done__q4;
    compute_0__is_done__q4 <= compute_0__is_done__q3;
    compute_0__is_done__q3 <= compute_0__is_done__q2;
  end

  assign compute_0__is_done__q0 = compute_0__state == 2'b10;

  always @(posedge ap_clk) begin
    compute_0__ap_start_global__q1 <= compute_0__ap_start_global__q0;
    compute_0__ap_start_global__q2 <= compute_0__ap_start_global__q1;
    compute_0__ap_start_global__q6 <= compute_0__ap_start_global__q5;
    compute_0__ap_start_global__q5 <= compute_0__ap_start_global__q4;
    compute_0__ap_start_global__q4 <= compute_0__ap_start_global__q3;
    compute_0__ap_start_global__q3 <= compute_0__ap_start_global__q2;
  end

  assign compute_0__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    compute_0__ap_done_global__q1 <= compute_0__ap_done_global__q0;
    compute_0__ap_done_global__q2 <= compute_0__ap_done_global__q1;
    compute_0__ap_done_global__q6 <= compute_0__ap_done_global__q5;
    compute_0__ap_done_global__q5 <= compute_0__ap_done_global__q4;
    compute_0__ap_done_global__q4 <= compute_0__ap_done_global__q3;
    compute_0__ap_done_global__q3 <= compute_0__ap_done_global__q2;
  end

  assign compute_0__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~compute_0__ap_rst_n__q6) begin
      compute_0__state <= 2'b00;
    end else begin
      if(compute_0__state == 2'b00) begin
        if(compute_0__ap_start_global__q6) begin
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
        if(compute_0__ap_done_global__q6) begin
          compute_0__state <= 2'b00;
        end 
      end 
    end
  end

  assign compute_0__ap_start = compute_0__state == 2'b01;

  always @(posedge ap_clk) begin
    compute_1___coalesced_data_num__q1 <= compute_1___coalesced_data_num__q0;
    compute_1___coalesced_data_num__q2 <= compute_1___coalesced_data_num__q1;
    compute_1___coalesced_data_num__q6 <= compute_1___coalesced_data_num__q5;
    compute_1___coalesced_data_num__q5 <= compute_1___coalesced_data_num__q4;
    compute_1___coalesced_data_num__q4 <= compute_1___coalesced_data_num__q3;
    compute_1___coalesced_data_num__q3 <= compute_1___coalesced_data_num__q2;
  end

  assign compute_1___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    compute_1___input_size_dim_0__q1 <= compute_1___input_size_dim_0__q0;
    compute_1___input_size_dim_0__q2 <= compute_1___input_size_dim_0__q1;
    compute_1___input_size_dim_0__q6 <= compute_1___input_size_dim_0__q5;
    compute_1___input_size_dim_0__q5 <= compute_1___input_size_dim_0__q4;
    compute_1___input_size_dim_0__q4 <= compute_1___input_size_dim_0__q3;
    compute_1___input_size_dim_0__q3 <= compute_1___input_size_dim_0__q2;
  end

  assign compute_1___input_size_dim_0__q0 = input_size_dim_0;

  always @(posedge ap_clk) begin
    compute_1___input_size_dim_1__q1 <= compute_1___input_size_dim_1__q0;
    compute_1___input_size_dim_1__q2 <= compute_1___input_size_dim_1__q1;
    compute_1___input_size_dim_1__q6 <= compute_1___input_size_dim_1__q5;
    compute_1___input_size_dim_1__q5 <= compute_1___input_size_dim_1__q4;
    compute_1___input_size_dim_1__q4 <= compute_1___input_size_dim_1__q3;
    compute_1___input_size_dim_1__q3 <= compute_1___input_size_dim_1__q2;
  end

  assign compute_1___input_size_dim_1__q0 = input_size_dim_1;

  always @(posedge ap_clk) begin
    compute_1___tile_data_num__q1 <= compute_1___tile_data_num__q0;
    compute_1___tile_data_num__q2 <= compute_1___tile_data_num__q1;
    compute_1___tile_data_num__q6 <= compute_1___tile_data_num__q5;
    compute_1___tile_data_num__q5 <= compute_1___tile_data_num__q4;
    compute_1___tile_data_num__q4 <= compute_1___tile_data_num__q3;
    compute_1___tile_data_num__q3 <= compute_1___tile_data_num__q2;
  end

  assign compute_1___tile_data_num__q0 = tile_data_num;

  always @(posedge ap_clk) begin
    compute_1___tile_num_dim_0__q1 <= compute_1___tile_num_dim_0__q0;
    compute_1___tile_num_dim_0__q2 <= compute_1___tile_num_dim_0__q1;
    compute_1___tile_num_dim_0__q6 <= compute_1___tile_num_dim_0__q5;
    compute_1___tile_num_dim_0__q5 <= compute_1___tile_num_dim_0__q4;
    compute_1___tile_num_dim_0__q4 <= compute_1___tile_num_dim_0__q3;
    compute_1___tile_num_dim_0__q3 <= compute_1___tile_num_dim_0__q2;
  end

  assign compute_1___tile_num_dim_0__q0 = tile_num_dim_0;

  always @(posedge ap_clk) begin
    compute_1__ap_rst_n__q1 <= compute_1__ap_rst_n__q0;
    compute_1__ap_rst_n__q2 <= compute_1__ap_rst_n__q1;
    compute_1__ap_rst_n__q6 <= compute_1__ap_rst_n__q5;
    compute_1__ap_rst_n__q5 <= compute_1__ap_rst_n__q4;
    compute_1__ap_rst_n__q4 <= compute_1__ap_rst_n__q3;
    compute_1__ap_rst_n__q3 <= compute_1__ap_rst_n__q2;
  end

  assign compute_1__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    compute_1__is_done__q1 <= compute_1__is_done__q0;
    compute_1__is_done__q2 <= compute_1__is_done__q1;
    compute_1__is_done__q6 <= compute_1__is_done__q5;
    compute_1__is_done__q5 <= compute_1__is_done__q4;
    compute_1__is_done__q4 <= compute_1__is_done__q3;
    compute_1__is_done__q3 <= compute_1__is_done__q2;
  end

  assign compute_1__is_done__q0 = compute_1__state == 2'b10;

  always @(posedge ap_clk) begin
    compute_1__ap_start_global__q1 <= compute_1__ap_start_global__q0;
    compute_1__ap_start_global__q2 <= compute_1__ap_start_global__q1;
    compute_1__ap_start_global__q6 <= compute_1__ap_start_global__q5;
    compute_1__ap_start_global__q5 <= compute_1__ap_start_global__q4;
    compute_1__ap_start_global__q4 <= compute_1__ap_start_global__q3;
    compute_1__ap_start_global__q3 <= compute_1__ap_start_global__q2;
  end

  assign compute_1__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    compute_1__ap_done_global__q1 <= compute_1__ap_done_global__q0;
    compute_1__ap_done_global__q2 <= compute_1__ap_done_global__q1;
    compute_1__ap_done_global__q6 <= compute_1__ap_done_global__q5;
    compute_1__ap_done_global__q5 <= compute_1__ap_done_global__q4;
    compute_1__ap_done_global__q4 <= compute_1__ap_done_global__q3;
    compute_1__ap_done_global__q3 <= compute_1__ap_done_global__q2;
  end

  assign compute_1__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~compute_1__ap_rst_n__q6) begin
      compute_1__state <= 2'b00;
    end else begin
      if(compute_1__state == 2'b00) begin
        if(compute_1__ap_start_global__q6) begin
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
        if(compute_1__ap_done_global__q6) begin
          compute_1__state <= 2'b00;
        end 
      end 
    end
  end

  assign compute_1__ap_start = compute_1__state == 2'b01;

  always @(posedge ap_clk) begin
    compute_2___coalesced_data_num__q1 <= compute_2___coalesced_data_num__q0;
    compute_2___coalesced_data_num__q2 <= compute_2___coalesced_data_num__q1;
    compute_2___coalesced_data_num__q6 <= compute_2___coalesced_data_num__q5;
    compute_2___coalesced_data_num__q5 <= compute_2___coalesced_data_num__q4;
    compute_2___coalesced_data_num__q4 <= compute_2___coalesced_data_num__q3;
    compute_2___coalesced_data_num__q3 <= compute_2___coalesced_data_num__q2;
  end

  assign compute_2___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    compute_2___input_size_dim_0__q1 <= compute_2___input_size_dim_0__q0;
    compute_2___input_size_dim_0__q2 <= compute_2___input_size_dim_0__q1;
    compute_2___input_size_dim_0__q6 <= compute_2___input_size_dim_0__q5;
    compute_2___input_size_dim_0__q5 <= compute_2___input_size_dim_0__q4;
    compute_2___input_size_dim_0__q4 <= compute_2___input_size_dim_0__q3;
    compute_2___input_size_dim_0__q3 <= compute_2___input_size_dim_0__q2;
  end

  assign compute_2___input_size_dim_0__q0 = input_size_dim_0;

  always @(posedge ap_clk) begin
    compute_2___input_size_dim_1__q1 <= compute_2___input_size_dim_1__q0;
    compute_2___input_size_dim_1__q2 <= compute_2___input_size_dim_1__q1;
    compute_2___input_size_dim_1__q6 <= compute_2___input_size_dim_1__q5;
    compute_2___input_size_dim_1__q5 <= compute_2___input_size_dim_1__q4;
    compute_2___input_size_dim_1__q4 <= compute_2___input_size_dim_1__q3;
    compute_2___input_size_dim_1__q3 <= compute_2___input_size_dim_1__q2;
  end

  assign compute_2___input_size_dim_1__q0 = input_size_dim_1;

  always @(posedge ap_clk) begin
    compute_2___tile_data_num__q1 <= compute_2___tile_data_num__q0;
    compute_2___tile_data_num__q2 <= compute_2___tile_data_num__q1;
    compute_2___tile_data_num__q6 <= compute_2___tile_data_num__q5;
    compute_2___tile_data_num__q5 <= compute_2___tile_data_num__q4;
    compute_2___tile_data_num__q4 <= compute_2___tile_data_num__q3;
    compute_2___tile_data_num__q3 <= compute_2___tile_data_num__q2;
  end

  assign compute_2___tile_data_num__q0 = tile_data_num;

  always @(posedge ap_clk) begin
    compute_2___tile_num_dim_0__q1 <= compute_2___tile_num_dim_0__q0;
    compute_2___tile_num_dim_0__q2 <= compute_2___tile_num_dim_0__q1;
    compute_2___tile_num_dim_0__q6 <= compute_2___tile_num_dim_0__q5;
    compute_2___tile_num_dim_0__q5 <= compute_2___tile_num_dim_0__q4;
    compute_2___tile_num_dim_0__q4 <= compute_2___tile_num_dim_0__q3;
    compute_2___tile_num_dim_0__q3 <= compute_2___tile_num_dim_0__q2;
  end

  assign compute_2___tile_num_dim_0__q0 = tile_num_dim_0;

  always @(posedge ap_clk) begin
    compute_2__ap_rst_n__q1 <= compute_2__ap_rst_n__q0;
    compute_2__ap_rst_n__q2 <= compute_2__ap_rst_n__q1;
    compute_2__ap_rst_n__q6 <= compute_2__ap_rst_n__q5;
    compute_2__ap_rst_n__q5 <= compute_2__ap_rst_n__q4;
    compute_2__ap_rst_n__q4 <= compute_2__ap_rst_n__q3;
    compute_2__ap_rst_n__q3 <= compute_2__ap_rst_n__q2;
  end

  assign compute_2__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    compute_2__is_done__q1 <= compute_2__is_done__q0;
    compute_2__is_done__q2 <= compute_2__is_done__q1;
    compute_2__is_done__q6 <= compute_2__is_done__q5;
    compute_2__is_done__q5 <= compute_2__is_done__q4;
    compute_2__is_done__q4 <= compute_2__is_done__q3;
    compute_2__is_done__q3 <= compute_2__is_done__q2;
  end

  assign compute_2__is_done__q0 = compute_2__state == 2'b10;

  always @(posedge ap_clk) begin
    compute_2__ap_start_global__q1 <= compute_2__ap_start_global__q0;
    compute_2__ap_start_global__q2 <= compute_2__ap_start_global__q1;
    compute_2__ap_start_global__q6 <= compute_2__ap_start_global__q5;
    compute_2__ap_start_global__q5 <= compute_2__ap_start_global__q4;
    compute_2__ap_start_global__q4 <= compute_2__ap_start_global__q3;
    compute_2__ap_start_global__q3 <= compute_2__ap_start_global__q2;
  end

  assign compute_2__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    compute_2__ap_done_global__q1 <= compute_2__ap_done_global__q0;
    compute_2__ap_done_global__q2 <= compute_2__ap_done_global__q1;
    compute_2__ap_done_global__q6 <= compute_2__ap_done_global__q5;
    compute_2__ap_done_global__q5 <= compute_2__ap_done_global__q4;
    compute_2__ap_done_global__q4 <= compute_2__ap_done_global__q3;
    compute_2__ap_done_global__q3 <= compute_2__ap_done_global__q2;
  end

  assign compute_2__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~compute_2__ap_rst_n__q6) begin
      compute_2__state <= 2'b00;
    end else begin
      if(compute_2__state == 2'b00) begin
        if(compute_2__ap_start_global__q6) begin
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
        if(compute_2__ap_done_global__q6) begin
          compute_2__state <= 2'b00;
        end 
      end 
    end
  end

  assign compute_2__ap_start = compute_2__state == 2'b01;

  always @(posedge ap_clk) begin
    compute_3___coalesced_data_num__q1 <= compute_3___coalesced_data_num__q0;
    compute_3___coalesced_data_num__q2 <= compute_3___coalesced_data_num__q1;
    compute_3___coalesced_data_num__q6 <= compute_3___coalesced_data_num__q5;
    compute_3___coalesced_data_num__q5 <= compute_3___coalesced_data_num__q4;
    compute_3___coalesced_data_num__q4 <= compute_3___coalesced_data_num__q3;
    compute_3___coalesced_data_num__q3 <= compute_3___coalesced_data_num__q2;
  end

  assign compute_3___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    compute_3___input_size_dim_0__q1 <= compute_3___input_size_dim_0__q0;
    compute_3___input_size_dim_0__q2 <= compute_3___input_size_dim_0__q1;
    compute_3___input_size_dim_0__q6 <= compute_3___input_size_dim_0__q5;
    compute_3___input_size_dim_0__q5 <= compute_3___input_size_dim_0__q4;
    compute_3___input_size_dim_0__q4 <= compute_3___input_size_dim_0__q3;
    compute_3___input_size_dim_0__q3 <= compute_3___input_size_dim_0__q2;
  end

  assign compute_3___input_size_dim_0__q0 = input_size_dim_0;

  always @(posedge ap_clk) begin
    compute_3___input_size_dim_1__q1 <= compute_3___input_size_dim_1__q0;
    compute_3___input_size_dim_1__q2 <= compute_3___input_size_dim_1__q1;
    compute_3___input_size_dim_1__q6 <= compute_3___input_size_dim_1__q5;
    compute_3___input_size_dim_1__q5 <= compute_3___input_size_dim_1__q4;
    compute_3___input_size_dim_1__q4 <= compute_3___input_size_dim_1__q3;
    compute_3___input_size_dim_1__q3 <= compute_3___input_size_dim_1__q2;
  end

  assign compute_3___input_size_dim_1__q0 = input_size_dim_1;

  always @(posedge ap_clk) begin
    compute_3___tile_data_num__q1 <= compute_3___tile_data_num__q0;
    compute_3___tile_data_num__q2 <= compute_3___tile_data_num__q1;
    compute_3___tile_data_num__q6 <= compute_3___tile_data_num__q5;
    compute_3___tile_data_num__q5 <= compute_3___tile_data_num__q4;
    compute_3___tile_data_num__q4 <= compute_3___tile_data_num__q3;
    compute_3___tile_data_num__q3 <= compute_3___tile_data_num__q2;
  end

  assign compute_3___tile_data_num__q0 = tile_data_num;

  always @(posedge ap_clk) begin
    compute_3___tile_num_dim_0__q1 <= compute_3___tile_num_dim_0__q0;
    compute_3___tile_num_dim_0__q2 <= compute_3___tile_num_dim_0__q1;
    compute_3___tile_num_dim_0__q6 <= compute_3___tile_num_dim_0__q5;
    compute_3___tile_num_dim_0__q5 <= compute_3___tile_num_dim_0__q4;
    compute_3___tile_num_dim_0__q4 <= compute_3___tile_num_dim_0__q3;
    compute_3___tile_num_dim_0__q3 <= compute_3___tile_num_dim_0__q2;
  end

  assign compute_3___tile_num_dim_0__q0 = tile_num_dim_0;

  always @(posedge ap_clk) begin
    compute_3__ap_rst_n__q1 <= compute_3__ap_rst_n__q0;
    compute_3__ap_rst_n__q2 <= compute_3__ap_rst_n__q1;
    compute_3__ap_rst_n__q6 <= compute_3__ap_rst_n__q5;
    compute_3__ap_rst_n__q5 <= compute_3__ap_rst_n__q4;
    compute_3__ap_rst_n__q4 <= compute_3__ap_rst_n__q3;
    compute_3__ap_rst_n__q3 <= compute_3__ap_rst_n__q2;
  end

  assign compute_3__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    compute_3__is_done__q1 <= compute_3__is_done__q0;
    compute_3__is_done__q2 <= compute_3__is_done__q1;
    compute_3__is_done__q6 <= compute_3__is_done__q5;
    compute_3__is_done__q5 <= compute_3__is_done__q4;
    compute_3__is_done__q4 <= compute_3__is_done__q3;
    compute_3__is_done__q3 <= compute_3__is_done__q2;
  end

  assign compute_3__is_done__q0 = compute_3__state == 2'b10;

  always @(posedge ap_clk) begin
    compute_3__ap_start_global__q1 <= compute_3__ap_start_global__q0;
    compute_3__ap_start_global__q2 <= compute_3__ap_start_global__q1;
    compute_3__ap_start_global__q6 <= compute_3__ap_start_global__q5;
    compute_3__ap_start_global__q5 <= compute_3__ap_start_global__q4;
    compute_3__ap_start_global__q4 <= compute_3__ap_start_global__q3;
    compute_3__ap_start_global__q3 <= compute_3__ap_start_global__q2;
  end

  assign compute_3__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    compute_3__ap_done_global__q1 <= compute_3__ap_done_global__q0;
    compute_3__ap_done_global__q2 <= compute_3__ap_done_global__q1;
    compute_3__ap_done_global__q6 <= compute_3__ap_done_global__q5;
    compute_3__ap_done_global__q5 <= compute_3__ap_done_global__q4;
    compute_3__ap_done_global__q4 <= compute_3__ap_done_global__q3;
    compute_3__ap_done_global__q3 <= compute_3__ap_done_global__q2;
  end

  assign compute_3__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~compute_3__ap_rst_n__q6) begin
      compute_3__state <= 2'b00;
    end else begin
      if(compute_3__state == 2'b00) begin
        if(compute_3__ap_start_global__q6) begin
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
        if(compute_3__ap_done_global__q6) begin
          compute_3__state <= 2'b00;
        end 
      end 
    end
  end

  assign compute_3__ap_start = compute_3__state == 2'b01;

  always @(posedge ap_clk) begin
    compute_4___coalesced_data_num__q1 <= compute_4___coalesced_data_num__q0;
    compute_4___coalesced_data_num__q2 <= compute_4___coalesced_data_num__q1;
    compute_4___coalesced_data_num__q6 <= compute_4___coalesced_data_num__q5;
    compute_4___coalesced_data_num__q5 <= compute_4___coalesced_data_num__q4;
    compute_4___coalesced_data_num__q4 <= compute_4___coalesced_data_num__q3;
    compute_4___coalesced_data_num__q3 <= compute_4___coalesced_data_num__q2;
  end

  assign compute_4___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    compute_4___input_size_dim_0__q1 <= compute_4___input_size_dim_0__q0;
    compute_4___input_size_dim_0__q2 <= compute_4___input_size_dim_0__q1;
    compute_4___input_size_dim_0__q6 <= compute_4___input_size_dim_0__q5;
    compute_4___input_size_dim_0__q5 <= compute_4___input_size_dim_0__q4;
    compute_4___input_size_dim_0__q4 <= compute_4___input_size_dim_0__q3;
    compute_4___input_size_dim_0__q3 <= compute_4___input_size_dim_0__q2;
  end

  assign compute_4___input_size_dim_0__q0 = input_size_dim_0;

  always @(posedge ap_clk) begin
    compute_4___input_size_dim_1__q1 <= compute_4___input_size_dim_1__q0;
    compute_4___input_size_dim_1__q2 <= compute_4___input_size_dim_1__q1;
    compute_4___input_size_dim_1__q6 <= compute_4___input_size_dim_1__q5;
    compute_4___input_size_dim_1__q5 <= compute_4___input_size_dim_1__q4;
    compute_4___input_size_dim_1__q4 <= compute_4___input_size_dim_1__q3;
    compute_4___input_size_dim_1__q3 <= compute_4___input_size_dim_1__q2;
  end

  assign compute_4___input_size_dim_1__q0 = input_size_dim_1;

  always @(posedge ap_clk) begin
    compute_4___tile_data_num__q1 <= compute_4___tile_data_num__q0;
    compute_4___tile_data_num__q2 <= compute_4___tile_data_num__q1;
    compute_4___tile_data_num__q6 <= compute_4___tile_data_num__q5;
    compute_4___tile_data_num__q5 <= compute_4___tile_data_num__q4;
    compute_4___tile_data_num__q4 <= compute_4___tile_data_num__q3;
    compute_4___tile_data_num__q3 <= compute_4___tile_data_num__q2;
  end

  assign compute_4___tile_data_num__q0 = tile_data_num;

  always @(posedge ap_clk) begin
    compute_4___tile_num_dim_0__q1 <= compute_4___tile_num_dim_0__q0;
    compute_4___tile_num_dim_0__q2 <= compute_4___tile_num_dim_0__q1;
    compute_4___tile_num_dim_0__q6 <= compute_4___tile_num_dim_0__q5;
    compute_4___tile_num_dim_0__q5 <= compute_4___tile_num_dim_0__q4;
    compute_4___tile_num_dim_0__q4 <= compute_4___tile_num_dim_0__q3;
    compute_4___tile_num_dim_0__q3 <= compute_4___tile_num_dim_0__q2;
  end

  assign compute_4___tile_num_dim_0__q0 = tile_num_dim_0;

  always @(posedge ap_clk) begin
    compute_4__ap_rst_n__q1 <= compute_4__ap_rst_n__q0;
    compute_4__ap_rst_n__q2 <= compute_4__ap_rst_n__q1;
    compute_4__ap_rst_n__q6 <= compute_4__ap_rst_n__q5;
    compute_4__ap_rst_n__q5 <= compute_4__ap_rst_n__q4;
    compute_4__ap_rst_n__q4 <= compute_4__ap_rst_n__q3;
    compute_4__ap_rst_n__q3 <= compute_4__ap_rst_n__q2;
  end

  assign compute_4__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    compute_4__is_done__q1 <= compute_4__is_done__q0;
    compute_4__is_done__q2 <= compute_4__is_done__q1;
    compute_4__is_done__q6 <= compute_4__is_done__q5;
    compute_4__is_done__q5 <= compute_4__is_done__q4;
    compute_4__is_done__q4 <= compute_4__is_done__q3;
    compute_4__is_done__q3 <= compute_4__is_done__q2;
  end

  assign compute_4__is_done__q0 = compute_4__state == 2'b10;

  always @(posedge ap_clk) begin
    compute_4__ap_start_global__q1 <= compute_4__ap_start_global__q0;
    compute_4__ap_start_global__q2 <= compute_4__ap_start_global__q1;
    compute_4__ap_start_global__q6 <= compute_4__ap_start_global__q5;
    compute_4__ap_start_global__q5 <= compute_4__ap_start_global__q4;
    compute_4__ap_start_global__q4 <= compute_4__ap_start_global__q3;
    compute_4__ap_start_global__q3 <= compute_4__ap_start_global__q2;
  end

  assign compute_4__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    compute_4__ap_done_global__q1 <= compute_4__ap_done_global__q0;
    compute_4__ap_done_global__q2 <= compute_4__ap_done_global__q1;
    compute_4__ap_done_global__q6 <= compute_4__ap_done_global__q5;
    compute_4__ap_done_global__q5 <= compute_4__ap_done_global__q4;
    compute_4__ap_done_global__q4 <= compute_4__ap_done_global__q3;
    compute_4__ap_done_global__q3 <= compute_4__ap_done_global__q2;
  end

  assign compute_4__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~compute_4__ap_rst_n__q6) begin
      compute_4__state <= 2'b00;
    end else begin
      if(compute_4__state == 2'b00) begin
        if(compute_4__ap_start_global__q6) begin
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
        if(compute_4__ap_done_global__q6) begin
          compute_4__state <= 2'b00;
        end 
      end 
    end
  end

  assign compute_4__ap_start = compute_4__state == 2'b01;

  always @(posedge ap_clk) begin
    compute_5___coalesced_data_num__q1 <= compute_5___coalesced_data_num__q0;
    compute_5___coalesced_data_num__q2 <= compute_5___coalesced_data_num__q1;
    compute_5___coalesced_data_num__q6 <= compute_5___coalesced_data_num__q5;
    compute_5___coalesced_data_num__q5 <= compute_5___coalesced_data_num__q4;
    compute_5___coalesced_data_num__q4 <= compute_5___coalesced_data_num__q3;
    compute_5___coalesced_data_num__q3 <= compute_5___coalesced_data_num__q2;
  end

  assign compute_5___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    compute_5___input_size_dim_0__q1 <= compute_5___input_size_dim_0__q0;
    compute_5___input_size_dim_0__q2 <= compute_5___input_size_dim_0__q1;
    compute_5___input_size_dim_0__q6 <= compute_5___input_size_dim_0__q5;
    compute_5___input_size_dim_0__q5 <= compute_5___input_size_dim_0__q4;
    compute_5___input_size_dim_0__q4 <= compute_5___input_size_dim_0__q3;
    compute_5___input_size_dim_0__q3 <= compute_5___input_size_dim_0__q2;
  end

  assign compute_5___input_size_dim_0__q0 = input_size_dim_0;

  always @(posedge ap_clk) begin
    compute_5___input_size_dim_1__q1 <= compute_5___input_size_dim_1__q0;
    compute_5___input_size_dim_1__q2 <= compute_5___input_size_dim_1__q1;
    compute_5___input_size_dim_1__q6 <= compute_5___input_size_dim_1__q5;
    compute_5___input_size_dim_1__q5 <= compute_5___input_size_dim_1__q4;
    compute_5___input_size_dim_1__q4 <= compute_5___input_size_dim_1__q3;
    compute_5___input_size_dim_1__q3 <= compute_5___input_size_dim_1__q2;
  end

  assign compute_5___input_size_dim_1__q0 = input_size_dim_1;

  always @(posedge ap_clk) begin
    compute_5___tile_data_num__q1 <= compute_5___tile_data_num__q0;
    compute_5___tile_data_num__q2 <= compute_5___tile_data_num__q1;
    compute_5___tile_data_num__q6 <= compute_5___tile_data_num__q5;
    compute_5___tile_data_num__q5 <= compute_5___tile_data_num__q4;
    compute_5___tile_data_num__q4 <= compute_5___tile_data_num__q3;
    compute_5___tile_data_num__q3 <= compute_5___tile_data_num__q2;
  end

  assign compute_5___tile_data_num__q0 = tile_data_num;

  always @(posedge ap_clk) begin
    compute_5___tile_num_dim_0__q1 <= compute_5___tile_num_dim_0__q0;
    compute_5___tile_num_dim_0__q2 <= compute_5___tile_num_dim_0__q1;
    compute_5___tile_num_dim_0__q6 <= compute_5___tile_num_dim_0__q5;
    compute_5___tile_num_dim_0__q5 <= compute_5___tile_num_dim_0__q4;
    compute_5___tile_num_dim_0__q4 <= compute_5___tile_num_dim_0__q3;
    compute_5___tile_num_dim_0__q3 <= compute_5___tile_num_dim_0__q2;
  end

  assign compute_5___tile_num_dim_0__q0 = tile_num_dim_0;

  always @(posedge ap_clk) begin
    compute_5__ap_rst_n__q1 <= compute_5__ap_rst_n__q0;
    compute_5__ap_rst_n__q2 <= compute_5__ap_rst_n__q1;
    compute_5__ap_rst_n__q6 <= compute_5__ap_rst_n__q5;
    compute_5__ap_rst_n__q5 <= compute_5__ap_rst_n__q4;
    compute_5__ap_rst_n__q4 <= compute_5__ap_rst_n__q3;
    compute_5__ap_rst_n__q3 <= compute_5__ap_rst_n__q2;
  end

  assign compute_5__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    compute_5__is_done__q1 <= compute_5__is_done__q0;
    compute_5__is_done__q2 <= compute_5__is_done__q1;
    compute_5__is_done__q6 <= compute_5__is_done__q5;
    compute_5__is_done__q5 <= compute_5__is_done__q4;
    compute_5__is_done__q4 <= compute_5__is_done__q3;
    compute_5__is_done__q3 <= compute_5__is_done__q2;
  end

  assign compute_5__is_done__q0 = compute_5__state == 2'b10;

  always @(posedge ap_clk) begin
    compute_5__ap_start_global__q1 <= compute_5__ap_start_global__q0;
    compute_5__ap_start_global__q2 <= compute_5__ap_start_global__q1;
    compute_5__ap_start_global__q6 <= compute_5__ap_start_global__q5;
    compute_5__ap_start_global__q5 <= compute_5__ap_start_global__q4;
    compute_5__ap_start_global__q4 <= compute_5__ap_start_global__q3;
    compute_5__ap_start_global__q3 <= compute_5__ap_start_global__q2;
  end

  assign compute_5__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    compute_5__ap_done_global__q1 <= compute_5__ap_done_global__q0;
    compute_5__ap_done_global__q2 <= compute_5__ap_done_global__q1;
    compute_5__ap_done_global__q6 <= compute_5__ap_done_global__q5;
    compute_5__ap_done_global__q5 <= compute_5__ap_done_global__q4;
    compute_5__ap_done_global__q4 <= compute_5__ap_done_global__q3;
    compute_5__ap_done_global__q3 <= compute_5__ap_done_global__q2;
  end

  assign compute_5__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~compute_5__ap_rst_n__q6) begin
      compute_5__state <= 2'b00;
    end else begin
      if(compute_5__state == 2'b00) begin
        if(compute_5__ap_start_global__q6) begin
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
        if(compute_5__ap_done_global__q6) begin
          compute_5__state <= 2'b00;
        end 
      end 
    end
  end

  assign compute_5__ap_start = compute_5__state == 2'b01;

  always @(posedge ap_clk) begin
    compute_6___coalesced_data_num__q1 <= compute_6___coalesced_data_num__q0;
    compute_6___coalesced_data_num__q2 <= compute_6___coalesced_data_num__q1;
    compute_6___coalesced_data_num__q6 <= compute_6___coalesced_data_num__q5;
    compute_6___coalesced_data_num__q5 <= compute_6___coalesced_data_num__q4;
    compute_6___coalesced_data_num__q4 <= compute_6___coalesced_data_num__q3;
    compute_6___coalesced_data_num__q3 <= compute_6___coalesced_data_num__q2;
  end

  assign compute_6___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    compute_6___input_size_dim_0__q1 <= compute_6___input_size_dim_0__q0;
    compute_6___input_size_dim_0__q2 <= compute_6___input_size_dim_0__q1;
    compute_6___input_size_dim_0__q6 <= compute_6___input_size_dim_0__q5;
    compute_6___input_size_dim_0__q5 <= compute_6___input_size_dim_0__q4;
    compute_6___input_size_dim_0__q4 <= compute_6___input_size_dim_0__q3;
    compute_6___input_size_dim_0__q3 <= compute_6___input_size_dim_0__q2;
  end

  assign compute_6___input_size_dim_0__q0 = input_size_dim_0;

  always @(posedge ap_clk) begin
    compute_6___input_size_dim_1__q1 <= compute_6___input_size_dim_1__q0;
    compute_6___input_size_dim_1__q2 <= compute_6___input_size_dim_1__q1;
    compute_6___input_size_dim_1__q6 <= compute_6___input_size_dim_1__q5;
    compute_6___input_size_dim_1__q5 <= compute_6___input_size_dim_1__q4;
    compute_6___input_size_dim_1__q4 <= compute_6___input_size_dim_1__q3;
    compute_6___input_size_dim_1__q3 <= compute_6___input_size_dim_1__q2;
  end

  assign compute_6___input_size_dim_1__q0 = input_size_dim_1;

  always @(posedge ap_clk) begin
    compute_6___tile_data_num__q1 <= compute_6___tile_data_num__q0;
    compute_6___tile_data_num__q2 <= compute_6___tile_data_num__q1;
    compute_6___tile_data_num__q6 <= compute_6___tile_data_num__q5;
    compute_6___tile_data_num__q5 <= compute_6___tile_data_num__q4;
    compute_6___tile_data_num__q4 <= compute_6___tile_data_num__q3;
    compute_6___tile_data_num__q3 <= compute_6___tile_data_num__q2;
  end

  assign compute_6___tile_data_num__q0 = tile_data_num;

  always @(posedge ap_clk) begin
    compute_6___tile_num_dim_0__q1 <= compute_6___tile_num_dim_0__q0;
    compute_6___tile_num_dim_0__q2 <= compute_6___tile_num_dim_0__q1;
    compute_6___tile_num_dim_0__q6 <= compute_6___tile_num_dim_0__q5;
    compute_6___tile_num_dim_0__q5 <= compute_6___tile_num_dim_0__q4;
    compute_6___tile_num_dim_0__q4 <= compute_6___tile_num_dim_0__q3;
    compute_6___tile_num_dim_0__q3 <= compute_6___tile_num_dim_0__q2;
  end

  assign compute_6___tile_num_dim_0__q0 = tile_num_dim_0;

  always @(posedge ap_clk) begin
    compute_6__ap_rst_n__q1 <= compute_6__ap_rst_n__q0;
    compute_6__ap_rst_n__q2 <= compute_6__ap_rst_n__q1;
    compute_6__ap_rst_n__q6 <= compute_6__ap_rst_n__q5;
    compute_6__ap_rst_n__q5 <= compute_6__ap_rst_n__q4;
    compute_6__ap_rst_n__q4 <= compute_6__ap_rst_n__q3;
    compute_6__ap_rst_n__q3 <= compute_6__ap_rst_n__q2;
  end

  assign compute_6__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    compute_6__is_done__q1 <= compute_6__is_done__q0;
    compute_6__is_done__q2 <= compute_6__is_done__q1;
    compute_6__is_done__q6 <= compute_6__is_done__q5;
    compute_6__is_done__q5 <= compute_6__is_done__q4;
    compute_6__is_done__q4 <= compute_6__is_done__q3;
    compute_6__is_done__q3 <= compute_6__is_done__q2;
  end

  assign compute_6__is_done__q0 = compute_6__state == 2'b10;

  always @(posedge ap_clk) begin
    compute_6__ap_start_global__q1 <= compute_6__ap_start_global__q0;
    compute_6__ap_start_global__q2 <= compute_6__ap_start_global__q1;
    compute_6__ap_start_global__q6 <= compute_6__ap_start_global__q5;
    compute_6__ap_start_global__q5 <= compute_6__ap_start_global__q4;
    compute_6__ap_start_global__q4 <= compute_6__ap_start_global__q3;
    compute_6__ap_start_global__q3 <= compute_6__ap_start_global__q2;
  end

  assign compute_6__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    compute_6__ap_done_global__q1 <= compute_6__ap_done_global__q0;
    compute_6__ap_done_global__q2 <= compute_6__ap_done_global__q1;
    compute_6__ap_done_global__q6 <= compute_6__ap_done_global__q5;
    compute_6__ap_done_global__q5 <= compute_6__ap_done_global__q4;
    compute_6__ap_done_global__q4 <= compute_6__ap_done_global__q3;
    compute_6__ap_done_global__q3 <= compute_6__ap_done_global__q2;
  end

  assign compute_6__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~compute_6__ap_rst_n__q6) begin
      compute_6__state <= 2'b00;
    end else begin
      if(compute_6__state == 2'b00) begin
        if(compute_6__ap_start_global__q6) begin
          compute_6__state <= 2'b01;
        end 
      end 
      if(compute_6__state == 2'b01) begin
        if(compute_6__ap_ready) begin
          if(compute_6__ap_done) begin
            compute_6__state <= 2'b10;
          end else begin
            compute_6__state <= 2'b11;
          end
        end 
      end 
      if(compute_6__state == 2'b11) begin
        if(compute_6__ap_done) begin
          compute_6__state <= 2'b10;
        end 
      end 
      if(compute_6__state == 2'b10) begin
        if(compute_6__ap_done_global__q6) begin
          compute_6__state <= 2'b00;
        end 
      end 
    end
  end

  assign compute_6__ap_start = compute_6__state == 2'b01;

  always @(posedge ap_clk) begin
    load_0___coalesced_data_num__q1 <= load_0___coalesced_data_num__q0;
    load_0___coalesced_data_num__q2 <= load_0___coalesced_data_num__q1;
    load_0___coalesced_data_num__q6 <= load_0___coalesced_data_num__q5;
    load_0___coalesced_data_num__q5 <= load_0___coalesced_data_num__q4;
    load_0___coalesced_data_num__q4 <= load_0___coalesced_data_num__q3;
    load_0___coalesced_data_num__q3 <= load_0___coalesced_data_num__q2;
  end

  assign load_0___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    var_input_0_0__q1 <= var_input_0_0__q0;
    var_input_0_0__q2 <= var_input_0_0__q1;
    var_input_0_0__q6 <= var_input_0_0__q5;
    var_input_0_0__q5 <= var_input_0_0__q4;
    var_input_0_0__q4 <= var_input_0_0__q3;
    var_input_0_0__q3 <= var_input_0_0__q2;
  end

  assign var_input_0_0__q0 = var_input_0_0;

  always @(posedge ap_clk) begin
    load_0__ap_rst_n__q1 <= load_0__ap_rst_n__q0;
    load_0__ap_rst_n__q2 <= load_0__ap_rst_n__q1;
    load_0__ap_rst_n__q6 <= load_0__ap_rst_n__q5;
    load_0__ap_rst_n__q5 <= load_0__ap_rst_n__q4;
    load_0__ap_rst_n__q4 <= load_0__ap_rst_n__q3;
    load_0__ap_rst_n__q3 <= load_0__ap_rst_n__q2;
  end

  assign load_0__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    load_0__is_done__q1 <= load_0__is_done__q0;
    load_0__is_done__q2 <= load_0__is_done__q1;
    load_0__is_done__q6 <= load_0__is_done__q5;
    load_0__is_done__q5 <= load_0__is_done__q4;
    load_0__is_done__q4 <= load_0__is_done__q3;
    load_0__is_done__q3 <= load_0__is_done__q2;
  end

  assign load_0__is_done__q0 = load_0__state == 2'b10;

  always @(posedge ap_clk) begin
    load_0__ap_start_global__q1 <= load_0__ap_start_global__q0;
    load_0__ap_start_global__q2 <= load_0__ap_start_global__q1;
    load_0__ap_start_global__q6 <= load_0__ap_start_global__q5;
    load_0__ap_start_global__q5 <= load_0__ap_start_global__q4;
    load_0__ap_start_global__q4 <= load_0__ap_start_global__q3;
    load_0__ap_start_global__q3 <= load_0__ap_start_global__q2;
  end

  assign load_0__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    load_0__ap_done_global__q1 <= load_0__ap_done_global__q0;
    load_0__ap_done_global__q2 <= load_0__ap_done_global__q1;
    load_0__ap_done_global__q6 <= load_0__ap_done_global__q5;
    load_0__ap_done_global__q5 <= load_0__ap_done_global__q4;
    load_0__ap_done_global__q4 <= load_0__ap_done_global__q3;
    load_0__ap_done_global__q3 <= load_0__ap_done_global__q2;
  end

  assign load_0__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~load_0__ap_rst_n__q6) begin
      load_0__state <= 2'b00;
    end else begin
      if(load_0__state == 2'b00) begin
        if(load_0__ap_start_global__q6) begin
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
        if(load_0__ap_done_global__q6) begin
          load_0__state <= 2'b00;
        end 
      end 
    end
  end

  assign load_0__ap_start = load_0__state == 2'b01;

  always @(posedge ap_clk) begin
    load_1___coalesced_data_num__q1 <= load_1___coalesced_data_num__q0;
    load_1___coalesced_data_num__q2 <= load_1___coalesced_data_num__q1;
    load_1___coalesced_data_num__q6 <= load_1___coalesced_data_num__q5;
    load_1___coalesced_data_num__q5 <= load_1___coalesced_data_num__q4;
    load_1___coalesced_data_num__q4 <= load_1___coalesced_data_num__q3;
    load_1___coalesced_data_num__q3 <= load_1___coalesced_data_num__q2;
  end

  assign load_1___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    var_input_0_1__q1 <= var_input_0_1__q0;
    var_input_0_1__q2 <= var_input_0_1__q1;
    var_input_0_1__q6 <= var_input_0_1__q5;
    var_input_0_1__q5 <= var_input_0_1__q4;
    var_input_0_1__q4 <= var_input_0_1__q3;
    var_input_0_1__q3 <= var_input_0_1__q2;
  end

  assign var_input_0_1__q0 = var_input_0_1;

  always @(posedge ap_clk) begin
    load_1__ap_rst_n__q1 <= load_1__ap_rst_n__q0;
    load_1__ap_rst_n__q2 <= load_1__ap_rst_n__q1;
    load_1__ap_rst_n__q6 <= load_1__ap_rst_n__q5;
    load_1__ap_rst_n__q5 <= load_1__ap_rst_n__q4;
    load_1__ap_rst_n__q4 <= load_1__ap_rst_n__q3;
    load_1__ap_rst_n__q3 <= load_1__ap_rst_n__q2;
  end

  assign load_1__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    load_1__is_done__q1 <= load_1__is_done__q0;
    load_1__is_done__q2 <= load_1__is_done__q1;
    load_1__is_done__q6 <= load_1__is_done__q5;
    load_1__is_done__q5 <= load_1__is_done__q4;
    load_1__is_done__q4 <= load_1__is_done__q3;
    load_1__is_done__q3 <= load_1__is_done__q2;
  end

  assign load_1__is_done__q0 = load_1__state == 2'b10;

  always @(posedge ap_clk) begin
    load_1__ap_start_global__q1 <= load_1__ap_start_global__q0;
    load_1__ap_start_global__q2 <= load_1__ap_start_global__q1;
    load_1__ap_start_global__q6 <= load_1__ap_start_global__q5;
    load_1__ap_start_global__q5 <= load_1__ap_start_global__q4;
    load_1__ap_start_global__q4 <= load_1__ap_start_global__q3;
    load_1__ap_start_global__q3 <= load_1__ap_start_global__q2;
  end

  assign load_1__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    load_1__ap_done_global__q1 <= load_1__ap_done_global__q0;
    load_1__ap_done_global__q2 <= load_1__ap_done_global__q1;
    load_1__ap_done_global__q6 <= load_1__ap_done_global__q5;
    load_1__ap_done_global__q5 <= load_1__ap_done_global__q4;
    load_1__ap_done_global__q4 <= load_1__ap_done_global__q3;
    load_1__ap_done_global__q3 <= load_1__ap_done_global__q2;
  end

  assign load_1__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~load_1__ap_rst_n__q6) begin
      load_1__state <= 2'b00;
    end else begin
      if(load_1__state == 2'b00) begin
        if(load_1__ap_start_global__q6) begin
          load_1__state <= 2'b01;
        end 
      end 
      if(load_1__state == 2'b01) begin
        if(load_1__ap_ready) begin
          if(load_1__ap_done) begin
            load_1__state <= 2'b10;
          end else begin
            load_1__state <= 2'b11;
          end
        end 
      end 
      if(load_1__state == 2'b11) begin
        if(load_1__ap_done) begin
          load_1__state <= 2'b10;
        end 
      end 
      if(load_1__state == 2'b10) begin
        if(load_1__ap_done_global__q6) begin
          load_1__state <= 2'b00;
        end 
      end 
    end
  end

  assign load_1__ap_start = load_1__state == 2'b01;

  always @(posedge ap_clk) begin
    load_2___coalesced_data_num__q1 <= load_2___coalesced_data_num__q0;
    load_2___coalesced_data_num__q2 <= load_2___coalesced_data_num__q1;
    load_2___coalesced_data_num__q6 <= load_2___coalesced_data_num__q5;
    load_2___coalesced_data_num__q5 <= load_2___coalesced_data_num__q4;
    load_2___coalesced_data_num__q4 <= load_2___coalesced_data_num__q3;
    load_2___coalesced_data_num__q3 <= load_2___coalesced_data_num__q2;
  end

  assign load_2___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    var_input_0_2__q1 <= var_input_0_2__q0;
    var_input_0_2__q2 <= var_input_0_2__q1;
    var_input_0_2__q6 <= var_input_0_2__q5;
    var_input_0_2__q5 <= var_input_0_2__q4;
    var_input_0_2__q4 <= var_input_0_2__q3;
    var_input_0_2__q3 <= var_input_0_2__q2;
  end

  assign var_input_0_2__q0 = var_input_0_2;

  always @(posedge ap_clk) begin
    load_2__ap_rst_n__q1 <= load_2__ap_rst_n__q0;
    load_2__ap_rst_n__q2 <= load_2__ap_rst_n__q1;
    load_2__ap_rst_n__q6 <= load_2__ap_rst_n__q5;
    load_2__ap_rst_n__q5 <= load_2__ap_rst_n__q4;
    load_2__ap_rst_n__q4 <= load_2__ap_rst_n__q3;
    load_2__ap_rst_n__q3 <= load_2__ap_rst_n__q2;
  end

  assign load_2__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    load_2__is_done__q1 <= load_2__is_done__q0;
    load_2__is_done__q2 <= load_2__is_done__q1;
    load_2__is_done__q6 <= load_2__is_done__q5;
    load_2__is_done__q5 <= load_2__is_done__q4;
    load_2__is_done__q4 <= load_2__is_done__q3;
    load_2__is_done__q3 <= load_2__is_done__q2;
  end

  assign load_2__is_done__q0 = load_2__state == 2'b10;

  always @(posedge ap_clk) begin
    load_2__ap_start_global__q1 <= load_2__ap_start_global__q0;
    load_2__ap_start_global__q2 <= load_2__ap_start_global__q1;
    load_2__ap_start_global__q6 <= load_2__ap_start_global__q5;
    load_2__ap_start_global__q5 <= load_2__ap_start_global__q4;
    load_2__ap_start_global__q4 <= load_2__ap_start_global__q3;
    load_2__ap_start_global__q3 <= load_2__ap_start_global__q2;
  end

  assign load_2__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    load_2__ap_done_global__q1 <= load_2__ap_done_global__q0;
    load_2__ap_done_global__q2 <= load_2__ap_done_global__q1;
    load_2__ap_done_global__q6 <= load_2__ap_done_global__q5;
    load_2__ap_done_global__q5 <= load_2__ap_done_global__q4;
    load_2__ap_done_global__q4 <= load_2__ap_done_global__q3;
    load_2__ap_done_global__q3 <= load_2__ap_done_global__q2;
  end

  assign load_2__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~load_2__ap_rst_n__q6) begin
      load_2__state <= 2'b00;
    end else begin
      if(load_2__state == 2'b00) begin
        if(load_2__ap_start_global__q6) begin
          load_2__state <= 2'b01;
        end 
      end 
      if(load_2__state == 2'b01) begin
        if(load_2__ap_ready) begin
          if(load_2__ap_done) begin
            load_2__state <= 2'b10;
          end else begin
            load_2__state <= 2'b11;
          end
        end 
      end 
      if(load_2__state == 2'b11) begin
        if(load_2__ap_done) begin
          load_2__state <= 2'b10;
        end 
      end 
      if(load_2__state == 2'b10) begin
        if(load_2__ap_done_global__q6) begin
          load_2__state <= 2'b00;
        end 
      end 
    end
  end

  assign load_2__ap_start = load_2__state == 2'b01;

  always @(posedge ap_clk) begin
    load_3___coalesced_data_num__q1 <= load_3___coalesced_data_num__q0;
    load_3___coalesced_data_num__q2 <= load_3___coalesced_data_num__q1;
    load_3___coalesced_data_num__q6 <= load_3___coalesced_data_num__q5;
    load_3___coalesced_data_num__q5 <= load_3___coalesced_data_num__q4;
    load_3___coalesced_data_num__q4 <= load_3___coalesced_data_num__q3;
    load_3___coalesced_data_num__q3 <= load_3___coalesced_data_num__q2;
  end

  assign load_3___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    var_input_0_3__q1 <= var_input_0_3__q0;
    var_input_0_3__q2 <= var_input_0_3__q1;
    var_input_0_3__q6 <= var_input_0_3__q5;
    var_input_0_3__q5 <= var_input_0_3__q4;
    var_input_0_3__q4 <= var_input_0_3__q3;
    var_input_0_3__q3 <= var_input_0_3__q2;
  end

  assign var_input_0_3__q0 = var_input_0_3;

  always @(posedge ap_clk) begin
    load_3__ap_rst_n__q1 <= load_3__ap_rst_n__q0;
    load_3__ap_rst_n__q2 <= load_3__ap_rst_n__q1;
    load_3__ap_rst_n__q6 <= load_3__ap_rst_n__q5;
    load_3__ap_rst_n__q5 <= load_3__ap_rst_n__q4;
    load_3__ap_rst_n__q4 <= load_3__ap_rst_n__q3;
    load_3__ap_rst_n__q3 <= load_3__ap_rst_n__q2;
  end

  assign load_3__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    load_3__is_done__q1 <= load_3__is_done__q0;
    load_3__is_done__q2 <= load_3__is_done__q1;
    load_3__is_done__q6 <= load_3__is_done__q5;
    load_3__is_done__q5 <= load_3__is_done__q4;
    load_3__is_done__q4 <= load_3__is_done__q3;
    load_3__is_done__q3 <= load_3__is_done__q2;
  end

  assign load_3__is_done__q0 = load_3__state == 2'b10;

  always @(posedge ap_clk) begin
    load_3__ap_start_global__q1 <= load_3__ap_start_global__q0;
    load_3__ap_start_global__q2 <= load_3__ap_start_global__q1;
    load_3__ap_start_global__q6 <= load_3__ap_start_global__q5;
    load_3__ap_start_global__q5 <= load_3__ap_start_global__q4;
    load_3__ap_start_global__q4 <= load_3__ap_start_global__q3;
    load_3__ap_start_global__q3 <= load_3__ap_start_global__q2;
  end

  assign load_3__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    load_3__ap_done_global__q1 <= load_3__ap_done_global__q0;
    load_3__ap_done_global__q2 <= load_3__ap_done_global__q1;
    load_3__ap_done_global__q6 <= load_3__ap_done_global__q5;
    load_3__ap_done_global__q5 <= load_3__ap_done_global__q4;
    load_3__ap_done_global__q4 <= load_3__ap_done_global__q3;
    load_3__ap_done_global__q3 <= load_3__ap_done_global__q2;
  end

  assign load_3__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~load_3__ap_rst_n__q6) begin
      load_3__state <= 2'b00;
    end else begin
      if(load_3__state == 2'b00) begin
        if(load_3__ap_start_global__q6) begin
          load_3__state <= 2'b01;
        end 
      end 
      if(load_3__state == 2'b01) begin
        if(load_3__ap_ready) begin
          if(load_3__ap_done) begin
            load_3__state <= 2'b10;
          end else begin
            load_3__state <= 2'b11;
          end
        end 
      end 
      if(load_3__state == 2'b11) begin
        if(load_3__ap_done) begin
          load_3__state <= 2'b10;
        end 
      end 
      if(load_3__state == 2'b10) begin
        if(load_3__ap_done_global__q6) begin
          load_3__state <= 2'b00;
        end 
      end 
    end
  end

  assign load_3__ap_start = load_3__state == 2'b01;

  always @(posedge ap_clk) begin
    store_0___coalesced_data_num__q1 <= store_0___coalesced_data_num__q0;
    store_0___coalesced_data_num__q2 <= store_0___coalesced_data_num__q1;
    store_0___coalesced_data_num__q6 <= store_0___coalesced_data_num__q5;
    store_0___coalesced_data_num__q5 <= store_0___coalesced_data_num__q4;
    store_0___coalesced_data_num__q4 <= store_0___coalesced_data_num__q3;
    store_0___coalesced_data_num__q3 <= store_0___coalesced_data_num__q2;
  end

  assign store_0___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    var_output_0_0__q1 <= var_output_0_0__q0;
    var_output_0_0__q2 <= var_output_0_0__q1;
    var_output_0_0__q6 <= var_output_0_0__q5;
    var_output_0_0__q5 <= var_output_0_0__q4;
    var_output_0_0__q4 <= var_output_0_0__q3;
    var_output_0_0__q3 <= var_output_0_0__q2;
  end

  assign var_output_0_0__q0 = var_output_0_0;

  always @(posedge ap_clk) begin
    store_0__ap_rst_n__q1 <= store_0__ap_rst_n__q0;
    store_0__ap_rst_n__q2 <= store_0__ap_rst_n__q1;
    store_0__ap_rst_n__q6 <= store_0__ap_rst_n__q5;
    store_0__ap_rst_n__q5 <= store_0__ap_rst_n__q4;
    store_0__ap_rst_n__q4 <= store_0__ap_rst_n__q3;
    store_0__ap_rst_n__q3 <= store_0__ap_rst_n__q2;
  end

  assign store_0__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    store_0__is_done__q1 <= store_0__is_done__q0;
    store_0__is_done__q2 <= store_0__is_done__q1;
    store_0__is_done__q6 <= store_0__is_done__q5;
    store_0__is_done__q5 <= store_0__is_done__q4;
    store_0__is_done__q4 <= store_0__is_done__q3;
    store_0__is_done__q3 <= store_0__is_done__q2;
  end

  assign store_0__is_done__q0 = store_0__state == 2'b10;

  always @(posedge ap_clk) begin
    store_0__ap_start_global__q1 <= store_0__ap_start_global__q0;
    store_0__ap_start_global__q2 <= store_0__ap_start_global__q1;
    store_0__ap_start_global__q6 <= store_0__ap_start_global__q5;
    store_0__ap_start_global__q5 <= store_0__ap_start_global__q4;
    store_0__ap_start_global__q4 <= store_0__ap_start_global__q3;
    store_0__ap_start_global__q3 <= store_0__ap_start_global__q2;
  end

  assign store_0__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    store_0__ap_done_global__q1 <= store_0__ap_done_global__q0;
    store_0__ap_done_global__q2 <= store_0__ap_done_global__q1;
    store_0__ap_done_global__q6 <= store_0__ap_done_global__q5;
    store_0__ap_done_global__q5 <= store_0__ap_done_global__q4;
    store_0__ap_done_global__q4 <= store_0__ap_done_global__q3;
    store_0__ap_done_global__q3 <= store_0__ap_done_global__q2;
  end

  assign store_0__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~store_0__ap_rst_n__q6) begin
      store_0__state <= 2'b00;
    end else begin
      if(store_0__state == 2'b00) begin
        if(store_0__ap_start_global__q6) begin
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
        if(store_0__ap_done_global__q6) begin
          store_0__state <= 2'b00;
        end 
      end 
    end
  end

  assign store_0__ap_start = store_0__state == 2'b01;

  always @(posedge ap_clk) begin
    store_1___coalesced_data_num__q1 <= store_1___coalesced_data_num__q0;
    store_1___coalesced_data_num__q2 <= store_1___coalesced_data_num__q1;
    store_1___coalesced_data_num__q6 <= store_1___coalesced_data_num__q5;
    store_1___coalesced_data_num__q5 <= store_1___coalesced_data_num__q4;
    store_1___coalesced_data_num__q4 <= store_1___coalesced_data_num__q3;
    store_1___coalesced_data_num__q3 <= store_1___coalesced_data_num__q2;
  end

  assign store_1___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    var_output_0_1__q1 <= var_output_0_1__q0;
    var_output_0_1__q2 <= var_output_0_1__q1;
    var_output_0_1__q6 <= var_output_0_1__q5;
    var_output_0_1__q5 <= var_output_0_1__q4;
    var_output_0_1__q4 <= var_output_0_1__q3;
    var_output_0_1__q3 <= var_output_0_1__q2;
  end

  assign var_output_0_1__q0 = var_output_0_1;

  always @(posedge ap_clk) begin
    store_1__ap_rst_n__q1 <= store_1__ap_rst_n__q0;
    store_1__ap_rst_n__q2 <= store_1__ap_rst_n__q1;
    store_1__ap_rst_n__q6 <= store_1__ap_rst_n__q5;
    store_1__ap_rst_n__q5 <= store_1__ap_rst_n__q4;
    store_1__ap_rst_n__q4 <= store_1__ap_rst_n__q3;
    store_1__ap_rst_n__q3 <= store_1__ap_rst_n__q2;
  end

  assign store_1__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    store_1__is_done__q1 <= store_1__is_done__q0;
    store_1__is_done__q2 <= store_1__is_done__q1;
    store_1__is_done__q6 <= store_1__is_done__q5;
    store_1__is_done__q5 <= store_1__is_done__q4;
    store_1__is_done__q4 <= store_1__is_done__q3;
    store_1__is_done__q3 <= store_1__is_done__q2;
  end

  assign store_1__is_done__q0 = store_1__state == 2'b10;

  always @(posedge ap_clk) begin
    store_1__ap_start_global__q1 <= store_1__ap_start_global__q0;
    store_1__ap_start_global__q2 <= store_1__ap_start_global__q1;
    store_1__ap_start_global__q6 <= store_1__ap_start_global__q5;
    store_1__ap_start_global__q5 <= store_1__ap_start_global__q4;
    store_1__ap_start_global__q4 <= store_1__ap_start_global__q3;
    store_1__ap_start_global__q3 <= store_1__ap_start_global__q2;
  end

  assign store_1__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    store_1__ap_done_global__q1 <= store_1__ap_done_global__q0;
    store_1__ap_done_global__q2 <= store_1__ap_done_global__q1;
    store_1__ap_done_global__q6 <= store_1__ap_done_global__q5;
    store_1__ap_done_global__q5 <= store_1__ap_done_global__q4;
    store_1__ap_done_global__q4 <= store_1__ap_done_global__q3;
    store_1__ap_done_global__q3 <= store_1__ap_done_global__q2;
  end

  assign store_1__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~store_1__ap_rst_n__q6) begin
      store_1__state <= 2'b00;
    end else begin
      if(store_1__state == 2'b00) begin
        if(store_1__ap_start_global__q6) begin
          store_1__state <= 2'b01;
        end 
      end 
      if(store_1__state == 2'b01) begin
        if(store_1__ap_ready) begin
          if(store_1__ap_done) begin
            store_1__state <= 2'b10;
          end else begin
            store_1__state <= 2'b11;
          end
        end 
      end 
      if(store_1__state == 2'b11) begin
        if(store_1__ap_done) begin
          store_1__state <= 2'b10;
        end 
      end 
      if(store_1__state == 2'b10) begin
        if(store_1__ap_done_global__q6) begin
          store_1__state <= 2'b00;
        end 
      end 
    end
  end

  assign store_1__ap_start = store_1__state == 2'b01;

  always @(posedge ap_clk) begin
    store_2___coalesced_data_num__q1 <= store_2___coalesced_data_num__q0;
    store_2___coalesced_data_num__q2 <= store_2___coalesced_data_num__q1;
    store_2___coalesced_data_num__q6 <= store_2___coalesced_data_num__q5;
    store_2___coalesced_data_num__q5 <= store_2___coalesced_data_num__q4;
    store_2___coalesced_data_num__q4 <= store_2___coalesced_data_num__q3;
    store_2___coalesced_data_num__q3 <= store_2___coalesced_data_num__q2;
  end

  assign store_2___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    var_output_0_2__q1 <= var_output_0_2__q0;
    var_output_0_2__q2 <= var_output_0_2__q1;
    var_output_0_2__q6 <= var_output_0_2__q5;
    var_output_0_2__q5 <= var_output_0_2__q4;
    var_output_0_2__q4 <= var_output_0_2__q3;
    var_output_0_2__q3 <= var_output_0_2__q2;
  end

  assign var_output_0_2__q0 = var_output_0_2;

  always @(posedge ap_clk) begin
    store_2__ap_rst_n__q1 <= store_2__ap_rst_n__q0;
    store_2__ap_rst_n__q2 <= store_2__ap_rst_n__q1;
    store_2__ap_rst_n__q6 <= store_2__ap_rst_n__q5;
    store_2__ap_rst_n__q5 <= store_2__ap_rst_n__q4;
    store_2__ap_rst_n__q4 <= store_2__ap_rst_n__q3;
    store_2__ap_rst_n__q3 <= store_2__ap_rst_n__q2;
  end

  assign store_2__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    store_2__is_done__q1 <= store_2__is_done__q0;
    store_2__is_done__q2 <= store_2__is_done__q1;
    store_2__is_done__q6 <= store_2__is_done__q5;
    store_2__is_done__q5 <= store_2__is_done__q4;
    store_2__is_done__q4 <= store_2__is_done__q3;
    store_2__is_done__q3 <= store_2__is_done__q2;
  end

  assign store_2__is_done__q0 = store_2__state == 2'b10;

  always @(posedge ap_clk) begin
    store_2__ap_start_global__q1 <= store_2__ap_start_global__q0;
    store_2__ap_start_global__q2 <= store_2__ap_start_global__q1;
    store_2__ap_start_global__q6 <= store_2__ap_start_global__q5;
    store_2__ap_start_global__q5 <= store_2__ap_start_global__q4;
    store_2__ap_start_global__q4 <= store_2__ap_start_global__q3;
    store_2__ap_start_global__q3 <= store_2__ap_start_global__q2;
  end

  assign store_2__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    store_2__ap_done_global__q1 <= store_2__ap_done_global__q0;
    store_2__ap_done_global__q2 <= store_2__ap_done_global__q1;
    store_2__ap_done_global__q6 <= store_2__ap_done_global__q5;
    store_2__ap_done_global__q5 <= store_2__ap_done_global__q4;
    store_2__ap_done_global__q4 <= store_2__ap_done_global__q3;
    store_2__ap_done_global__q3 <= store_2__ap_done_global__q2;
  end

  assign store_2__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~store_2__ap_rst_n__q6) begin
      store_2__state <= 2'b00;
    end else begin
      if(store_2__state == 2'b00) begin
        if(store_2__ap_start_global__q6) begin
          store_2__state <= 2'b01;
        end 
      end 
      if(store_2__state == 2'b01) begin
        if(store_2__ap_ready) begin
          if(store_2__ap_done) begin
            store_2__state <= 2'b10;
          end else begin
            store_2__state <= 2'b11;
          end
        end 
      end 
      if(store_2__state == 2'b11) begin
        if(store_2__ap_done) begin
          store_2__state <= 2'b10;
        end 
      end 
      if(store_2__state == 2'b10) begin
        if(store_2__ap_done_global__q6) begin
          store_2__state <= 2'b00;
        end 
      end 
    end
  end

  assign store_2__ap_start = store_2__state == 2'b01;

  always @(posedge ap_clk) begin
    store_3___coalesced_data_num__q1 <= store_3___coalesced_data_num__q0;
    store_3___coalesced_data_num__q2 <= store_3___coalesced_data_num__q1;
    store_3___coalesced_data_num__q6 <= store_3___coalesced_data_num__q5;
    store_3___coalesced_data_num__q5 <= store_3___coalesced_data_num__q4;
    store_3___coalesced_data_num__q4 <= store_3___coalesced_data_num__q3;
    store_3___coalesced_data_num__q3 <= store_3___coalesced_data_num__q2;
  end

  assign store_3___coalesced_data_num__q0 = coalesced_data_num;

  always @(posedge ap_clk) begin
    var_output_0_3__q1 <= var_output_0_3__q0;
    var_output_0_3__q2 <= var_output_0_3__q1;
    var_output_0_3__q6 <= var_output_0_3__q5;
    var_output_0_3__q5 <= var_output_0_3__q4;
    var_output_0_3__q4 <= var_output_0_3__q3;
    var_output_0_3__q3 <= var_output_0_3__q2;
  end

  assign var_output_0_3__q0 = var_output_0_3;

  always @(posedge ap_clk) begin
    store_3__ap_rst_n__q1 <= store_3__ap_rst_n__q0;
    store_3__ap_rst_n__q2 <= store_3__ap_rst_n__q1;
    store_3__ap_rst_n__q6 <= store_3__ap_rst_n__q5;
    store_3__ap_rst_n__q5 <= store_3__ap_rst_n__q4;
    store_3__ap_rst_n__q4 <= store_3__ap_rst_n__q3;
    store_3__ap_rst_n__q3 <= store_3__ap_rst_n__q2;
  end

  assign store_3__ap_rst_n__q0 = ap_rst_n;

  always @(posedge ap_clk) begin
    store_3__is_done__q1 <= store_3__is_done__q0;
    store_3__is_done__q2 <= store_3__is_done__q1;
    store_3__is_done__q6 <= store_3__is_done__q5;
    store_3__is_done__q5 <= store_3__is_done__q4;
    store_3__is_done__q4 <= store_3__is_done__q3;
    store_3__is_done__q3 <= store_3__is_done__q2;
  end

  assign store_3__is_done__q0 = store_3__state == 2'b10;

  always @(posedge ap_clk) begin
    store_3__ap_start_global__q1 <= store_3__ap_start_global__q0;
    store_3__ap_start_global__q2 <= store_3__ap_start_global__q1;
    store_3__ap_start_global__q6 <= store_3__ap_start_global__q5;
    store_3__ap_start_global__q5 <= store_3__ap_start_global__q4;
    store_3__ap_start_global__q4 <= store_3__ap_start_global__q3;
    store_3__ap_start_global__q3 <= store_3__ap_start_global__q2;
  end

  assign store_3__ap_start_global__q0 = ap_start__q0;

  always @(posedge ap_clk) begin
    store_3__ap_done_global__q1 <= store_3__ap_done_global__q0;
    store_3__ap_done_global__q2 <= store_3__ap_done_global__q1;
    store_3__ap_done_global__q6 <= store_3__ap_done_global__q5;
    store_3__ap_done_global__q5 <= store_3__ap_done_global__q4;
    store_3__ap_done_global__q4 <= store_3__ap_done_global__q3;
    store_3__ap_done_global__q3 <= store_3__ap_done_global__q2;
  end

  assign store_3__ap_done_global__q0 = ap_done__q0;

  always @(posedge ap_clk) begin
    if(~store_3__ap_rst_n__q6) begin
      store_3__state <= 2'b00;
    end else begin
      if(store_3__state == 2'b00) begin
        if(store_3__ap_start_global__q6) begin
          store_3__state <= 2'b01;
        end 
      end 
      if(store_3__state == 2'b01) begin
        if(store_3__ap_ready) begin
          if(store_3__ap_done) begin
            store_3__state <= 2'b10;
          end else begin
            store_3__state <= 2'b11;
          end
        end 
      end 
      if(store_3__state == 2'b11) begin
        if(store_3__ap_done) begin
          store_3__state <= 2'b10;
        end 
      end 
      if(store_3__state == 2'b10) begin
        if(store_3__ap_done_global__q6) begin
          store_3__state <= 2'b00;
        end 
      end 
    end
  end

  assign store_3__ap_start = store_3__state == 2'b01;

  always @(posedge ap_clk) begin
    if(ap_rst_n_inv) begin
      tlp_state <= 2'b00;
    end else begin
      begin
        if(tlp_state == 2'b00) begin
          if(ap_start__q6) begin
            tlp_state <= 2'b01;
          end 
        end 
        if(tlp_state == 2'b01) begin
          if(compute_0__is_done__q3 && compute_1__is_done__q3 && compute_2__is_done__q3 && compute_3__is_done__q3 && compute_4__is_done__q3 && compute_5__is_done__q3 && compute_6__is_done__q3 && load_0__is_done__q3 && load_1__is_done__q3 && load_2__is_done__q3 && load_3__is_done__q3 && store_0__is_done__q3 && store_1__is_done__q3 && store_2__is_done__q3 && store_3__is_done__q6) begin
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
            countdown <= countdown - 2'd1;
          end
        end 
      end
    end
  end

  assign ap_idle = tlp_state == 2'b00;
  assign ap_done = ap_done__q6;
  assign ap_ready = ap_done__q0;

  always @(posedge ap_clk) begin
    ap_start__q1 <= ap_start__q0;
    ap_start__q2 <= ap_start__q1;
    ap_start__q6 <= ap_start__q5;
    ap_start__q5 <= ap_start__q4;
    ap_start__q4 <= ap_start__q3;
    ap_start__q3 <= ap_start__q2;
  end

  assign ap_start__q0 = ap_start;

  always @(posedge ap_clk) begin
    ap_done__q1 <= ap_done__q0;
    ap_done__q2 <= ap_done__q1;
    ap_done__q6 <= ap_done__q5;
    ap_done__q5 <= ap_done__q4;
    ap_done__q4 <= ap_done__q3;
    ap_done__q3 <= ap_done__q2;
  end

  assign ap_done__q0 = tlp_state == 2'b10;

endmodule



// first-word fall-through (FWFT) FIFO that is friendly for floorplanning
module relay_station #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5,
    parameter DEPTH      = 2,
    parameter LEVEL      = 2
) (
  input wire clk,
  input wire reset,

  // write
  output wire                  if_full_n,
  input  wire                  if_write_ce,
  input  wire                  if_write,
  input  wire [DATA_WIDTH-1:0] if_din,

  // read
  output wire                  if_empty_n,
  input  wire                  if_read_ce,
  input  wire                  if_read,
  output wire [DATA_WIDTH-1:0] if_dout
);

  (* dont_touch = "yes" *) wire                  full_n  [LEVEL:0];
  (* dont_touch = "yes" *) wire                  empty_n [LEVEL:0];
  (* dont_touch = "yes" *) wire [DATA_WIDTH-1:0] data    [LEVEL:0];

  // both full_n and write are registered, thus one level of relay_station cause two additional latency for the almost full fifo
  parameter GRACE_PERIOD = LEVEL * 2;
  parameter REAL_DEPTH = GRACE_PERIOD + DEPTH + 1;
  parameter REAL_ADDR_WIDTH  = $clog2(REAL_DEPTH);

  genvar i;
  for (i = 0; i < LEVEL; i = i + 1) begin : inst
    if (i < LEVEL - 1) begin
      fifo_reg #(
        .DATA_WIDTH(DATA_WIDTH)
      ) reg_unit (
        .clk(clk),
        .reset(reset),

        // connect to fifo[i+1]
        .if_empty_n(empty_n[i+1]),
        .if_read_ce(if_read_ce),
        .if_read   (full_n[i+1]),
        .if_dout   (data[i+1]),

        // connect to fifo[i-1]
        .if_full_n  (full_n[i]),
        .if_write_ce(if_write_ce),
        .if_write   (empty_n[i]),
        .if_din     (data[i])
      );

    end else begin
      (* keep = "true" *) fifo_almost_full #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(REAL_ADDR_WIDTH),
        .DEPTH(REAL_DEPTH),
        .GRACE_PERIOD(GRACE_PERIOD)
      ) fifo_unit (
        .clk(clk),
        .reset(reset),

        // connect to fifo[i+1]
        .if_empty_n(empty_n[i+1]),
        .if_read_ce(if_read_ce),
        .if_read   (full_n[i+1]),
        .if_dout   (data[i+1]),

        // connect to fifo[i-1]
        .if_full_n  (full_n[i]),
        .if_write_ce(if_write_ce),
        .if_write   (empty_n[i]),
        .if_din     (data[i])
      );
    end
  end

  // write
  assign if_full_n  = full_n[0];  // output
  assign empty_n[0] = if_write;   // input
  assign data[0]    = if_din;     // input

  // read
  assign if_empty_n    = empty_n[LEVEL];  // output
  assign full_n[LEVEL] = if_read;         // input
  assign if_dout       = data[LEVEL];     // output

endmodule   // relay_station

/////////////////////////////////////////////////////////////

module fifo_reg #(
  parameter DATA_WIDTH = 32
) (
  input wire clk,
  input wire reset,

  // write
  (* dont_touch = "yes" *) output reg                  if_full_n,
  input  wire                  if_write_ce,
  input  wire                  if_write,
  input  wire [DATA_WIDTH-1:0] if_din,

  // read
  (* dont_touch = "yes" *) output reg                  if_empty_n,
  input  wire                  if_read_ce,
  input  wire                  if_read,
  (* dont_touch = "yes" *) output reg [DATA_WIDTH-1:0] if_dout
);

  always @ (posedge clk) begin
    if_dout <= if_din;
    if_empty_n <= if_write;
    if_full_n <= if_read;
  end

endmodule

/////////////////////////////////////////////////////////////////

// first-word fall-through (FWFT) FIFO
// if its capacity > THRESHOLD bits, it uses block RAM, otherwise it will uses
// shift register LUT
module fifo_almost_full #(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 5,
  parameter DEPTH      = 32,
  parameter THRESHOLD  = 18432,
  parameter GRACE_PERIOD = 2
) (
  input wire clk,
  input wire reset,

  // write
  output wire                  if_full_n,
  input  wire                  if_write_ce,
  input  wire                  if_write,
  input  wire [DATA_WIDTH-1:0] if_din,

  // read
  output wire                  if_empty_n,
  input  wire                  if_read_ce,
  input  wire                  if_read,
  output wire [DATA_WIDTH-1:0] if_dout
);

generate
  if (DATA_WIDTH * DEPTH > THRESHOLD) begin : bram
    fifo_bram_almost_full #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH),
      .DEPTH     (DEPTH),
      .GRACE_PERIOD(GRACE_PERIOD) /*********/
    ) unit (
      .clk  (clk),
      .reset(reset),

      .if_full_n  (if_full_n),
      .if_write_ce(if_write_ce),
      .if_write   (if_write),
      .if_din     (if_din),

      .if_empty_n(if_empty_n),
      .if_read_ce(if_read_ce),
      .if_read   (if_read),
      .if_dout   (if_dout)
    );
  end else begin : srl
    fifo_srl_almost_full #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH),
      .DEPTH     (DEPTH),
      .GRACE_PERIOD(GRACE_PERIOD) /*********/
    ) unit (
      .clk  (clk),
      .reset(reset),

      .if_full_n  (if_full_n),
      .if_write_ce(if_write_ce),
      .if_write   (if_write),
      .if_din     (if_din),

      .if_empty_n(if_empty_n),
      .if_read_ce(if_read_ce),
      .if_read   (if_read),
      .if_dout   (if_dout)
    );
  end
endgenerate

endmodule  // fifo

/////////////////////////////////////////////////////////////////

module fifo_srl_almost_full (
    clk,
    reset,
    if_empty_n,
    if_read_ce,
    if_read,
    if_dout,
    if_full_n,
    if_write_ce,
    if_write,
    if_din);

parameter MEM_STYLE   = "shiftreg";
parameter DATA_WIDTH  = 32'd32;
parameter ADDR_WIDTH  = 32'd4;
parameter DEPTH       = 5'd16;

/*******************************************/
parameter GRACE_PERIOD = 2;
/*******************************************/

input clk;
input reset;
output if_empty_n;
input if_read_ce;
input if_read;
output[DATA_WIDTH - 1:0] if_dout;
output if_full_n;
input if_write_ce;
input if_write;
input[DATA_WIDTH - 1:0] if_din;

wire[ADDR_WIDTH - 1:0] shiftReg_addr ;
wire[DATA_WIDTH - 1:0] shiftReg_data, shiftReg_q;
wire                     shiftReg_ce;
reg[ADDR_WIDTH:0] mOutPtr = ~{(ADDR_WIDTH+1){1'b0}};
reg internal_empty_n = 0, internal_full_n = 1;

assign if_empty_n = internal_empty_n;

/*******************************************/
// assign if_full_n = internal_full_n;
wire almost_full = mOutPtr >= DEPTH - 1 - GRACE_PERIOD;
assign if_full_n = ~almost_full;
/*******************************************/

assign shiftReg_data = if_din;
assign if_dout = shiftReg_q;

always @ (posedge clk) begin
    if (reset == 1'b1)
    begin
        mOutPtr <= ~{ADDR_WIDTH+1{1'b0}};
        internal_empty_n <= 1'b0;
        internal_full_n <= 1'b1;
    end
    else begin
        if (((if_read & if_read_ce) == 1 & internal_empty_n == 1) && 
            ((if_write & if_write_ce) == 0 | internal_full_n == 0))
        begin
            mOutPtr <= mOutPtr - 5'd1;
            if (mOutPtr == 0)
                internal_empty_n <= 1'b0;
            internal_full_n <= 1'b1;
        end 
        else if (((if_read & if_read_ce) == 0 | internal_empty_n == 0) && 
            ((if_write & if_write_ce) == 1 & internal_full_n == 1))
        begin
            mOutPtr <= mOutPtr + 5'd1;
            internal_empty_n <= 1'b1;
            if (mOutPtr == DEPTH - 5'd2)
                internal_full_n <= 1'b0;
        end 
    end
end

assign shiftReg_addr = mOutPtr[ADDR_WIDTH] == 1'b0 ? mOutPtr[ADDR_WIDTH-1:0]:{ADDR_WIDTH{1'b0}};
assign shiftReg_ce = (if_write & if_write_ce) & internal_full_n;

fifo_srl_almost_full_internal 
#(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .DEPTH(DEPTH))
U_fifo_w32_d16_A_ram (
    .clk(clk),
    .data(shiftReg_data),
    .ce(shiftReg_ce),
    .a(shiftReg_addr),
    .q(shiftReg_q));

endmodule  

module fifo_srl_almost_full_internal (
    clk,
    data,
    ce,
    a,
    q);

parameter DATA_WIDTH = 32'd32;
parameter ADDR_WIDTH = 32'd4;
parameter DEPTH = 5'd16;

input clk;
input [DATA_WIDTH-1:0] data;
input ce;
input [ADDR_WIDTH-1:0] a;
output [DATA_WIDTH-1:0] q;

reg[DATA_WIDTH-1:0] SRL_SIG [0:DEPTH-1];
integer i;

always @ (posedge clk)
    begin
        if (ce)
        begin
            for (i=0;i<DEPTH-1;i=i+1)
                SRL_SIG[i+1] <= SRL_SIG[i];
            SRL_SIG[0] <= data;
        end
    end

assign q = SRL_SIG[a];

endmodule

///////////////////////////////////////////////////////////

// first-word fall-through (FWFT) FIFO using block RAM
// based on HLS generated code
module fifo_bram_almost_full #(
  parameter MEM_STYLE  = "block",
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 5,
  parameter DEPTH      = 32,
  parameter GRACE_PERIOD = 2
) (
  input wire clk,
  input wire reset,

  // write
  output wire                  if_full_n,
  input  wire                  if_write_ce,
  input  wire                  if_write,
  input  wire [DATA_WIDTH-1:0] if_din,

  // read
  output wire                  if_empty_n,
  input  wire                  if_read_ce,
  input  wire                  if_read,
  output wire [DATA_WIDTH-1:0] if_dout
);

(* ram_style = MEM_STYLE *)
reg  [DATA_WIDTH-1:0] mem[0:DEPTH-1];
reg  [DATA_WIDTH-1:0] q_buf;
reg  [ADDR_WIDTH-1:0] waddr;
reg  [ADDR_WIDTH-1:0] raddr;
wire [ADDR_WIDTH-1:0] wnext;
wire [ADDR_WIDTH-1:0] rnext;
wire                  push;
wire                  pop;
reg  [ADDR_WIDTH-1:0] used;
reg                   full_n;
reg                   empty_n;
reg  [DATA_WIDTH-1:0] q_tmp;
reg                   show_ahead;
reg  [DATA_WIDTH-1:0] dout_buf;
reg                   dout_valid;

localparam DepthM1 = DEPTH[ADDR_WIDTH-1:0] - 1'd1;

/**************************************/
wire almost_full = (used >= DEPTH - 1 - GRACE_PERIOD);
//assign if_full_n  = full_n;
assign if_full_n  = ~almost_full;
/**************************************/

assign if_empty_n = dout_valid;
assign if_dout    = dout_buf;
assign push       = full_n & if_write_ce & if_write;
assign pop        = empty_n & if_read_ce & (~dout_valid | if_read);
assign wnext      = !push              ? waddr              :
                    (waddr == DepthM1) ? {ADDR_WIDTH{1'b0}} : waddr + 1'd1;
assign rnext      = !pop               ? raddr              :
                    (raddr == DepthM1) ? {ADDR_WIDTH{1'b0}} : raddr + 1'd1;



// waddr
always @(posedge clk) begin
  if (reset)
    waddr <= {ADDR_WIDTH{1'b0}};
  else
    waddr <= wnext;
end

// raddr
always @(posedge clk) begin
  if (reset)
    raddr <= {ADDR_WIDTH{1'b0}};
  else
    raddr <= rnext;
end

// used
always @(posedge clk) begin
  if (reset)
    used <= {ADDR_WIDTH{1'b0}};
  else if (push && !pop)
    used <= used + 1'b1;
  else if (!push && pop)
    used <= used - 1'b1;
end

// full_n
always @(posedge clk) begin
  if (reset)
    full_n <= 1'b1;
  else if (push && !pop)
    full_n <= (used != DepthM1);
  else if (!push && pop)
    full_n <= 1'b1;
end

// empty_n
always @(posedge clk) begin
  if (reset)
    empty_n <= 1'b0;
  else if (push && !pop)
    empty_n <= 1'b1;
  else if (!push && pop)
    empty_n <= (used != {{(ADDR_WIDTH-1){1'b0}},1'b1});
end

// mem
always @(posedge clk) begin
  if (push)
    mem[waddr] <= if_din;
end

// q_buf
always @(posedge clk) begin
  q_buf <= mem[rnext];
end

// q_tmp
always @(posedge clk) begin
  if (reset)
    q_tmp <= {DATA_WIDTH{1'b0}};
  else if (push)
    q_tmp <= if_din;
end

// show_ahead
always @(posedge clk) begin
  if (reset)
    show_ahead <= 1'b0;
  else if (push && used == {{(ADDR_WIDTH-1){1'b0}},pop})
    show_ahead <= 1'b1;
  else
    show_ahead <= 1'b0;
end

// dout_buf
always @(posedge clk) begin
  if (reset)
    dout_buf <= {DATA_WIDTH{1'b0}};
  else if (pop)
    dout_buf <= show_ahead? q_tmp : q_buf;
end

// dout_valid
always @(posedge clk) begin
  if (reset)
    dout_valid <= 1'b0;
  else if (pop)
    dout_valid <= 1'b1;
  else if (if_read_ce & if_read)
    dout_valid <= 1'b0;
end

endmodule  // fifo_bram



