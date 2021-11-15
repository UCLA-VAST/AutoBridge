module axi_pipeline #(
  parameter
    C_M_AXI_ID_WIDTH        = 1,
    C_M_AXI_ADDR_WIDTH      = 32,
    C_M_AXI_DATA_WIDTH      = 512,
    C_M_AXI_AWUSER_WIDTH    = 1,
    C_M_AXI_ARUSER_WIDTH    = 1,
    C_M_AXI_WUSER_WIDTH     = 1,
    C_M_AXI_RUSER_WIDTH     = 1,
    C_M_AXI_BUSER_WIDTH     = 1,
    C_M_AXI_WSTRB_WIDTH     = (512 / 8),

    PIPELINE_LEVEL          = 3
) (
  input                                         ap_clk,
  input                                         ap_rst_n,

  // pipeline out
  output                                        out_AWVALID,
  input                                         out_AWREADY,
  output  [C_M_AXI_ADDR_WIDTH - 1:0]            out_AWADDR,
  output  [C_M_AXI_ID_WIDTH - 1:0]              out_AWID,
  output  [7:0]                                 out_AWLEN,
  output  [2:0]                                 out_AWSIZE,
  output  [1:0]                                 out_AWBURST,
  output  [1:0]                                 out_AWLOCK,
  output  [3:0]                                 out_AWCACHE,
  output  [2:0]                                 out_AWPROT,
  output  [3:0]                                 out_AWQOS,
  output  [3:0]                                 out_AWREGION,
  output  [C_M_AXI_AWUSER_WIDTH - 1:0]          out_AWUSER,

  output                                        out_WVALID,
  input                                         out_WREADY,
  output  [C_M_AXI_DATA_WIDTH - 1:0]            out_WDATA,
  output  [C_M_AXI_WSTRB_WIDTH - 1:0]           out_WSTRB,
  output                                        out_WLAST,
  output  [C_M_AXI_ID_WIDTH - 1:0]              out_WID,
  output  [C_M_AXI_WUSER_WIDTH - 1:0]           out_WUSER,

  output                                        out_ARVALID,
  input                                         out_ARREADY,
  output  [C_M_AXI_ADDR_WIDTH - 1:0]            out_ARADDR,
  output  [C_M_AXI_ID_WIDTH - 1:0]              out_ARID,
  output  [7:0]                                 out_ARLEN,
  output  [2:0]                                 out_ARSIZE,
  output  [1:0]                                 out_ARBURST,
  output  [1:0]                                 out_ARLOCK,
  output  [3:0]                                 out_ARCACHE,
  output  [2:0]                                 out_ARPROT,
  output  [3:0]                                 out_ARQOS,
  output  [3:0]                                 out_ARREGION,
  output  [C_M_AXI_ARUSER_WIDTH - 1:0]          out_ARUSER,

  input                                         out_RVALID,
  output                                        out_RREADY,
  input  [C_M_AXI_DATA_WIDTH - 1:0]             out_RDATA,
  input                                         out_RLAST,
  input  [C_M_AXI_ID_WIDTH - 1:0]               out_RID,
  input  [C_M_AXI_RUSER_WIDTH - 1:0]            out_RUSER,
  input  [1:0]                                  out_RRESP,

  input                                         out_BVALID,
  output                                        out_BREADY,
  input  [1:0]                                  out_BRESP,
  input  [C_M_AXI_ID_WIDTH - 1:0]               out_BID,
  input  [C_M_AXI_BUSER_WIDTH - 1:0]            out_BUSER,

  // pipeline in
  input                                         in_AWVALID,
  output                                        in_AWREADY,
  input  [C_M_AXI_ADDR_WIDTH - 1:0]             in_AWADDR,
  input  [C_M_AXI_ID_WIDTH - 1:0]               in_AWID,
  input  [7:0]                                  in_AWLEN,
  input  [2:0]                                  in_AWSIZE,
  input  [1:0]                                  in_AWBURST,
  input  [1:0]                                  in_AWLOCK,
  input  [3:0]                                  in_AWCACHE,
  input  [2:0]                                  in_AWPROT,
  input  [3:0]                                  in_AWQOS,
  input  [3:0]                                  in_AWREGION,
  input  [C_M_AXI_AWUSER_WIDTH - 1:0]           in_AWUSER,

  input                                         in_WVALID,
  output                                        in_WREADY,
  input  [C_M_AXI_DATA_WIDTH - 1:0]             in_WDATA,
  input  [C_M_AXI_WSTRB_WIDTH - 1:0]            in_WSTRB,
  input                                         in_WLAST,
  input  [C_M_AXI_ID_WIDTH - 1:0]               in_WID,
  input  [C_M_AXI_WUSER_WIDTH - 1:0]            in_WUSER,

  input                                         in_ARVALID,
  output                                        in_ARREADY,
  input  [C_M_AXI_ADDR_WIDTH - 1:0]             in_ARADDR,
  input  [C_M_AXI_ID_WIDTH - 1:0]               in_ARID,
  input  [7:0]                                  in_ARLEN,
  input  [2:0]                                  in_ARSIZE,
  input  [1:0]                                  in_ARBURST,
  input  [1:0]                                  in_ARLOCK,
  input  [3:0]                                  in_ARCACHE,
  input  [2:0]                                  in_ARPROT,
  input  [3:0]                                  in_ARQOS,
  input  [3:0]                                  in_ARREGION,
  input  [C_M_AXI_ARUSER_WIDTH - 1:0]           in_ARUSER,

  output                                        in_RVALID,
  input                                         in_RREADY,
  output  [C_M_AXI_DATA_WIDTH - 1:0]            in_RDATA,
  output                                        in_RLAST,
  output  [C_M_AXI_ID_WIDTH - 1:0]              in_RID,
  output  [C_M_AXI_RUSER_WIDTH - 1:0]           in_RUSER,
  output  [1:0]                                 in_RRESP,

  output                                        in_BVALID,
  input                                         in_BREADY,
  output  [1:0]                                 in_BRESP,
  output  [C_M_AXI_ID_WIDTH - 1:0]              in_BID,
  output  [C_M_AXI_BUSER_WIDTH - 1:0]           in_BUSER
);

  /////////////////////////////////////////////////////////////////////////

  // input                                         in_AWVALID;
  // output                                        in_AWREADY;
  // input  [C_M_AXI_ADDR_WIDTH - 1:0]             in_AWADDR;
  // input  [C_M_AXI_ID_WIDTH - 1:0]               in_AWID;
  // input  [7:0]                                  in_AWLEN;
  // input  [2:0]                                  in_AWSIZE;
  // input  [1:0]                                  in_AWBURST;
  // input  [1:0]                                  in_AWLOCK;
  // input  [3:0]                                  in_AWCACHE;
  // input  [2:0]                                  in_AWPROT;
  // input  [3:0]                                  in_AWQOS;
  // input  [3:0]                                  in_AWREGION;
  // input  [C_M_AXI_AWUSER_WIDTH - 1:0]           in_AWUSER;
  relay_station
  #(
    .DATA_WIDTH(
      C_M_AXI_ADDR_WIDTH + C_M_AXI_ID_WIDTH + 8 + 3 + 2 + 2 + 4 + 3 + 4 + 4 + C_M_AXI_AWUSER_WIDTH
    ),
    .DEPTH(2),
    .ADDR_WIDTH(1),
    .LEVEL(PIPELINE_LEVEL)
  )
  AW_pipeline
  (
    .clk        (ap_clk),
    .reset      (~ap_rst_n),
    .if_read_ce (1'b1),
    .if_write_ce(1'b1),

    .if_din     ({ in_AWADDR,  in_AWID,  in_AWLEN,  in_AWSIZE,  in_AWBURST,  in_AWLOCK,  in_AWCACHE,  in_AWPROT,  in_AWQOS,  in_AWREGION,  in_AWUSER}),
    .if_full_n  ( in_AWREADY),
    .if_write   ( in_AWVALID),

    .if_dout    ({out_AWADDR, out_AWID, out_AWLEN, out_AWSIZE, out_AWBURST, out_AWLOCK, out_AWCACHE, out_AWPROT, out_AWQOS, out_AWREGION, out_AWUSER}),
    .if_empty_n (out_AWVALID),
    .if_read    (out_AWREADY)
  );

  /////////////////////////////////////////////////////////////////////////

  // input                                         in_WVALID;
  // output                                        in_WREADY;
  // input  [C_M_AXI_DATA_WIDTH - 1:0]             in_WDATA;
  // input  [C_M_AXI_WSTRB_WIDTH - 1:0]            in_WSTRB;
  // input                                         in_WLAST;
  // input  [C_M_AXI_ID_WIDTH - 1:0]               in_WID;
  // input  [C_M_AXI_WUSER_WIDTH - 1:0]            in_WUSER;
  relay_station
  #(
    .DATA_WIDTH(
      C_M_AXI_DATA_WIDTH + C_M_AXI_WSTRB_WIDTH + 1 + C_M_AXI_ID_WIDTH + C_M_AXI_WUSER_WIDTH
    ),
    .DEPTH(2),
    .ADDR_WIDTH(1),
    .LEVEL(PIPELINE_LEVEL)
  )
  W_pipeline
  (
    .clk        (ap_clk),
    .reset      (~ap_rst_n),
    .if_read_ce (1'b1),
    .if_write_ce(1'b1),

    .if_din     ({in_WDATA,  in_WSTRB,  in_WLAST,  in_WID,  in_WUSER}),
    .if_full_n  ( in_WREADY),
    .if_write   ( in_WVALID),

    .if_dout    ({out_WDATA, out_WSTRB, out_WLAST, out_WID, out_WUSER}),
    .if_empty_n (out_WVALID),
    .if_read    (out_WREADY)
  );

  /////////////////////////////////////////////////////////////////////////

  // input                                         in_ARVALID;
  // output                                        in_ARREADY;
  // input  [C_M_AXI_ADDR_WIDTH - 1:0]             in_ARADDR;
  // input  [C_M_AXI_ID_WIDTH - 1:0]               in_ARID;
  // input  [7:0]                                  in_ARLEN;
  // input  [2:0]                                  in_ARSIZE;
  // input  [1:0]                                  in_ARBURST;
  // input  [1:0]                                  in_ARLOCK;
  // input  [3:0]                                  in_ARCACHE;
  // input  [2:0]                                  in_ARPROT;
  // input  [3:0]                                  in_ARQOS;
  // input  [3:0]                                  in_ARREGION;
  // input  [C_M_AXI_ARUSER_WIDTH - 1:0]           in_ARUSER;
  relay_station
  #(
    .DATA_WIDTH(
      C_M_AXI_ADDR_WIDTH + C_M_AXI_ID_WIDTH + 8 + 3 + 2 + 2 + 4 + 3 + 4 + 4 + C_M_AXI_ARUSER_WIDTH
    ),
    .DEPTH(2),
    .ADDR_WIDTH(1),
    .LEVEL(PIPELINE_LEVEL)
  )
  AR_pipeline
  (
    .clk        (ap_clk),
    .reset      (~ap_rst_n),
    .if_read_ce (1'b1),
    .if_write_ce(1'b1),

    .if_din     ({ in_ARADDR,  in_ARID,  in_ARLEN,  in_ARSIZE,  in_ARBURST,  in_ARLOCK,  in_ARCACHE,  in_ARPROT,  in_ARQOS,  in_ARREGION,  in_ARUSER}),
    .if_full_n  ( in_ARREADY),
    .if_write   ( in_ARVALID),

    .if_dout    ({out_ARADDR, out_ARID, out_ARLEN, out_ARSIZE, out_ARBURST, out_ARLOCK, out_ARCACHE, out_ARPROT, out_ARQOS, out_ARREGION, out_ARUSER}),
    .if_empty_n (out_ARVALID),
    .if_read    (out_ARREADY)
  );

  /////////////////////////////////////////////////////////////////////////

  // output                                        in_RVALID;
  // input                                         in_RREADY;
  // output  [C_M_AXI_DATA_WIDTH - 1:0]            in_RDATA;
  // output                                        in_RLAST;
  // output  [C_M_AXI_ID_WIDTH - 1:0]              in_RID;
  // output  [C_M_AXI_RUSER_WIDTH - 1:0]           in_RUSER;
  // output  [1:0]                                 in_RRESP;

  // note that R channel is in reverse direction
  relay_station
  #(
    .DATA_WIDTH(
      C_M_AXI_DATA_WIDTH + 1 + C_M_AXI_ID_WIDTH + C_M_AXI_RUSER_WIDTH + 2
    ),
    .DEPTH(2),
    .ADDR_WIDTH(1),
    .LEVEL(PIPELINE_LEVEL)
  )
  R_pipeline
  (
    .clk        (ap_clk),
    .reset      (~ap_rst_n),
    .if_read_ce (1'b1),
    .if_write_ce(1'b1),

    .if_din     ({out_RDATA, out_RLAST, out_RID, out_RUSER, out_RRESP}),
    .if_full_n  ( out_RREADY),
    .if_write   ( out_RVALID),

    .if_dout    ({in_RDATA,  in_RLAST,  in_RID,  in_RUSER,  in_RRESP}),
    .if_empty_n (in_RVALID),
    .if_read    (in_RREADY)
  );

  /////////////////////////////////////////////////////////////////////////

  // output                                        in_BVALID;
  // input                                         in_BREADY;
  // output  [1:0]                                 in_BRESP;
  // output  [C_M_AXI_ID_WIDTH - 1:0]              in_BID;
  // output  [C_M_AXI_BUSER_WIDTH - 1:0]           in_BUSER;

  // note that R channel is in reverse direction
  relay_station
  #(
    .DATA_WIDTH(
      2 + C_M_AXI_ID_WIDTH + C_M_AXI_BUSER_WIDTH
    ),
    .DEPTH(2),
    .ADDR_WIDTH(1),
    .LEVEL(PIPELINE_LEVEL)
  )
  B_pipeline
  (
    .clk        (ap_clk),
    .reset      (~ap_rst_n),
    .if_read_ce (1'b1),
    .if_write_ce(1'b1),

    .if_din     ({out_BRESP,  out_BID,  out_BUSER}),
    .if_full_n  (out_BREADY),
    .if_write   (out_BVALID),

    .if_dout    ({ in_BRESP,  in_BID,  in_BUSER}),
    .if_empty_n (in_BVALID),
    .if_read    (in_BREADY)
  );

endmodule