// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
`timescale 1ns/1ps
module PageRank_PageRank_control_s_axi
#(parameter
    C_S_AXI_ADDR_WIDTH = 9,
    C_S_AXI_DATA_WIDTH = 32
)(
    input  wire                          ACLK,
    input  wire                          ARESET,
    input  wire                          ACLK_EN,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] AWADDR,
    input  wire                          AWVALID,
    output wire                          AWREADY,
    input  wire [C_S_AXI_DATA_WIDTH-1:0] WDATA,
    input  wire [C_S_AXI_DATA_WIDTH/8-1:0] WSTRB,
    input  wire                          WVALID,
    output wire                          WREADY,
    output wire [1:0]                    BRESP,
    output wire                          BVALID,
    input  wire                          BREADY,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] ARADDR,
    input  wire                          ARVALID,
    output wire                          ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1:0] RDATA,
    output wire [1:0]                    RRESP,
    output wire                          RVALID,
    input  wire                          RREADY,
    output wire                          interrupt,
    output wire                          ap_start,
    input  wire                          ap_done,
    input  wire                          ap_ready,
    input  wire                          ap_idle,
    output wire [15:0]                   num_partitions,
    output wire [63:0]                   metadata,
    output wire [63:0]                   degrees,
    output wire [63:0]                   rankings,
    output wire [63:0]                   tmps,
    output wire [63:0]                   edges_0,
    output wire [63:0]                   edges_1,
    output wire [63:0]                   edges_2,
    output wire [63:0]                   edges_3,
    output wire [63:0]                   edges_4,
    output wire [63:0]                   edges_5,
    output wire [63:0]                   edges_6,
    output wire [63:0]                   edges_7,
    output wire [63:0]                   updates_0,
    output wire [63:0]                   updates_1,
    output wire [63:0]                   updates_2,
    output wire [63:0]                   updates_3,
    output wire [63:0]                   updates_4,
    output wire [63:0]                   updates_5,
    output wire [63:0]                   updates_6,
    output wire [63:0]                   updates_7
);
//------------------------Address Info-------------------
// 0x000 : Control signals
//         bit 0  - ap_start (Read/Write/COH)
//         bit 1  - ap_done (Read/COR)
//         bit 2  - ap_idle (Read)
//         bit 3  - ap_ready (Read)
//         bit 7  - auto_restart (Read/Write)
//         others - reserved
// 0x004 : Global Interrupt Enable Register
//         bit 0  - Global Interrupt Enable (Read/Write)
//         others - reserved
// 0x008 : IP Interrupt Enable Register (Read/Write)
//         bit 0  - Channel 0 (ap_done)
//         bit 1  - Channel 1 (ap_ready)
//         others - reserved
// 0x00c : IP Interrupt Status Register (Read/TOW)
//         bit 0  - Channel 0 (ap_done)
//         bit 1  - Channel 1 (ap_ready)
//         others - reserved
// 0x010 : Data signal of num_partitions
//         bit 15~0 - num_partitions[15:0] (Read/Write)
//         others   - reserved
// 0x014 : reserved
// 0x018 : Data signal of metadata
//         bit 31~0 - metadata[31:0] (Read/Write)
// 0x01c : Data signal of metadata
//         bit 31~0 - metadata[63:32] (Read/Write)
// 0x020 : reserved
// 0x024 : Data signal of degrees
//         bit 31~0 - degrees[31:0] (Read/Write)
// 0x028 : Data signal of degrees
//         bit 31~0 - degrees[63:32] (Read/Write)
// 0x02c : reserved
// 0x030 : Data signal of rankings
//         bit 31~0 - rankings[31:0] (Read/Write)
// 0x034 : Data signal of rankings
//         bit 31~0 - rankings[63:32] (Read/Write)
// 0x038 : reserved
// 0x03c : Data signal of tmps
//         bit 31~0 - tmps[31:0] (Read/Write)
// 0x040 : Data signal of tmps
//         bit 31~0 - tmps[63:32] (Read/Write)
// 0x044 : reserved
// 0x048 : Data signal of edges_0
//         bit 31~0 - edges_0[31:0] (Read/Write)
// 0x04c : Data signal of edges_0
//         bit 31~0 - edges_0[63:32] (Read/Write)
// 0x050 : reserved
// 0x054 : Data signal of edges_1
//         bit 31~0 - edges_1[31:0] (Read/Write)
// 0x058 : Data signal of edges_1
//         bit 31~0 - edges_1[63:32] (Read/Write)
// 0x05c : reserved
// 0x060 : Data signal of edges_2
//         bit 31~0 - edges_2[31:0] (Read/Write)
// 0x064 : Data signal of edges_2
//         bit 31~0 - edges_2[63:32] (Read/Write)
// 0x068 : reserved
// 0x06c : Data signal of edges_3
//         bit 31~0 - edges_3[31:0] (Read/Write)
// 0x070 : Data signal of edges_3
//         bit 31~0 - edges_3[63:32] (Read/Write)
// 0x074 : reserved
// 0x078 : Data signal of edges_4
//         bit 31~0 - edges_4[31:0] (Read/Write)
// 0x07c : Data signal of edges_4
//         bit 31~0 - edges_4[63:32] (Read/Write)
// 0x080 : reserved
// 0x084 : Data signal of edges_5
//         bit 31~0 - edges_5[31:0] (Read/Write)
// 0x088 : Data signal of edges_5
//         bit 31~0 - edges_5[63:32] (Read/Write)
// 0x08c : reserved
// 0x090 : Data signal of edges_6
//         bit 31~0 - edges_6[31:0] (Read/Write)
// 0x094 : Data signal of edges_6
//         bit 31~0 - edges_6[63:32] (Read/Write)
// 0x098 : reserved
// 0x09c : Data signal of edges_7
//         bit 31~0 - edges_7[31:0] (Read/Write)
// 0x0a0 : Data signal of edges_7
//         bit 31~0 - edges_7[63:32] (Read/Write)
// 0x0a4 : reserved
// 0x0a8 : Data signal of updates_0
//         bit 31~0 - updates_0[31:0] (Read/Write)
// 0x0ac : Data signal of updates_0
//         bit 31~0 - updates_0[63:32] (Read/Write)
// 0x0b0 : reserved
// 0x0b4 : Data signal of updates_1
//         bit 31~0 - updates_1[31:0] (Read/Write)
// 0x0b8 : Data signal of updates_1
//         bit 31~0 - updates_1[63:32] (Read/Write)
// 0x0bc : reserved
// 0x0c0 : Data signal of updates_2
//         bit 31~0 - updates_2[31:0] (Read/Write)
// 0x0c4 : Data signal of updates_2
//         bit 31~0 - updates_2[63:32] (Read/Write)
// 0x0c8 : reserved
// 0x0cc : Data signal of updates_3
//         bit 31~0 - updates_3[31:0] (Read/Write)
// 0x0d0 : Data signal of updates_3
//         bit 31~0 - updates_3[63:32] (Read/Write)
// 0x0d4 : reserved
// 0x0d8 : Data signal of updates_4
//         bit 31~0 - updates_4[31:0] (Read/Write)
// 0x0dc : Data signal of updates_4
//         bit 31~0 - updates_4[63:32] (Read/Write)
// 0x0e0 : reserved
// 0x0e4 : Data signal of updates_5
//         bit 31~0 - updates_5[31:0] (Read/Write)
// 0x0e8 : Data signal of updates_5
//         bit 31~0 - updates_5[63:32] (Read/Write)
// 0x0ec : reserved
// 0x0f0 : Data signal of updates_6
//         bit 31~0 - updates_6[31:0] (Read/Write)
// 0x0f4 : Data signal of updates_6
//         bit 31~0 - updates_6[63:32] (Read/Write)
// 0x0f8 : reserved
// 0x0fc : Data signal of updates_7
//         bit 31~0 - updates_7[31:0] (Read/Write)
// 0x100 : Data signal of updates_7
//         bit 31~0 - updates_7[63:32] (Read/Write)
// 0x104 : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

//------------------------Parameter----------------------
localparam
    ADDR_AP_CTRL               = 9'h000,
    ADDR_GIE                   = 9'h004,
    ADDR_IER                   = 9'h008,
    ADDR_ISR                   = 9'h00c,
    ADDR_NUM_PARTITIONS_DATA_0 = 9'h010,
    ADDR_NUM_PARTITIONS_CTRL   = 9'h014,
    ADDR_METADATA_DATA_0       = 9'h018,
    ADDR_METADATA_DATA_1       = 9'h01c,
    ADDR_METADATA_CTRL         = 9'h020,
    ADDR_DEGREES_DATA_0        = 9'h024,
    ADDR_DEGREES_DATA_1        = 9'h028,
    ADDR_DEGREES_CTRL          = 9'h02c,
    ADDR_RANKINGS_DATA_0       = 9'h030,
    ADDR_RANKINGS_DATA_1       = 9'h034,
    ADDR_RANKINGS_CTRL         = 9'h038,
    ADDR_TMPS_DATA_0           = 9'h03c,
    ADDR_TMPS_DATA_1           = 9'h040,
    ADDR_TMPS_CTRL             = 9'h044,
    ADDR_EDGES_0_DATA_0        = 9'h048,
    ADDR_EDGES_0_DATA_1        = 9'h04c,
    ADDR_EDGES_0_CTRL          = 9'h050,
    ADDR_EDGES_1_DATA_0        = 9'h054,
    ADDR_EDGES_1_DATA_1        = 9'h058,
    ADDR_EDGES_1_CTRL          = 9'h05c,
    ADDR_EDGES_2_DATA_0        = 9'h060,
    ADDR_EDGES_2_DATA_1        = 9'h064,
    ADDR_EDGES_2_CTRL          = 9'h068,
    ADDR_EDGES_3_DATA_0        = 9'h06c,
    ADDR_EDGES_3_DATA_1        = 9'h070,
    ADDR_EDGES_3_CTRL          = 9'h074,
    ADDR_EDGES_4_DATA_0        = 9'h078,
    ADDR_EDGES_4_DATA_1        = 9'h07c,
    ADDR_EDGES_4_CTRL          = 9'h080,
    ADDR_EDGES_5_DATA_0        = 9'h084,
    ADDR_EDGES_5_DATA_1        = 9'h088,
    ADDR_EDGES_5_CTRL          = 9'h08c,
    ADDR_EDGES_6_DATA_0        = 9'h090,
    ADDR_EDGES_6_DATA_1        = 9'h094,
    ADDR_EDGES_6_CTRL          = 9'h098,
    ADDR_EDGES_7_DATA_0        = 9'h09c,
    ADDR_EDGES_7_DATA_1        = 9'h0a0,
    ADDR_EDGES_7_CTRL          = 9'h0a4,
    ADDR_UPDATES_0_DATA_0      = 9'h0a8,
    ADDR_UPDATES_0_DATA_1      = 9'h0ac,
    ADDR_UPDATES_0_CTRL        = 9'h0b0,
    ADDR_UPDATES_1_DATA_0      = 9'h0b4,
    ADDR_UPDATES_1_DATA_1      = 9'h0b8,
    ADDR_UPDATES_1_CTRL        = 9'h0bc,
    ADDR_UPDATES_2_DATA_0      = 9'h0c0,
    ADDR_UPDATES_2_DATA_1      = 9'h0c4,
    ADDR_UPDATES_2_CTRL        = 9'h0c8,
    ADDR_UPDATES_3_DATA_0      = 9'h0cc,
    ADDR_UPDATES_3_DATA_1      = 9'h0d0,
    ADDR_UPDATES_3_CTRL        = 9'h0d4,
    ADDR_UPDATES_4_DATA_0      = 9'h0d8,
    ADDR_UPDATES_4_DATA_1      = 9'h0dc,
    ADDR_UPDATES_4_CTRL        = 9'h0e0,
    ADDR_UPDATES_5_DATA_0      = 9'h0e4,
    ADDR_UPDATES_5_DATA_1      = 9'h0e8,
    ADDR_UPDATES_5_CTRL        = 9'h0ec,
    ADDR_UPDATES_6_DATA_0      = 9'h0f0,
    ADDR_UPDATES_6_DATA_1      = 9'h0f4,
    ADDR_UPDATES_6_CTRL        = 9'h0f8,
    ADDR_UPDATES_7_DATA_0      = 9'h0fc,
    ADDR_UPDATES_7_DATA_1      = 9'h100,
    ADDR_UPDATES_7_CTRL        = 9'h104,
    WRIDLE                     = 2'd0,
    WRDATA                     = 2'd1,
    WRRESP                     = 2'd2,
    WRRESET                    = 2'd3,
    RDIDLE                     = 2'd0,
    RDDATA                     = 2'd1,
    RDRESET                    = 2'd2,
    ADDR_BITS         = 9;

//------------------------Local signal-------------------
    reg  [1:0]                    wstate = WRRESET;
    reg  [1:0]                    wnext;
    reg  [ADDR_BITS-1:0]          waddr;
    wire [31:0]                   wmask;
    wire                          aw_hs;
    wire                          w_hs;
    reg  [1:0]                    rstate = RDRESET;
    reg  [1:0]                    rnext;
    reg  [31:0]                   rdata;
    wire                          ar_hs;
    wire [ADDR_BITS-1:0]          raddr;
    // internal registers
    reg                           int_ap_idle;
    reg                           int_ap_ready;
    reg                           int_ap_done = 1'b0;
    reg                           int_ap_start = 1'b0;
    reg                           int_auto_restart = 1'b0;
    reg                           int_gie = 1'b0;
    reg  [1:0]                    int_ier = 2'b0;
    reg  [1:0]                    int_isr = 2'b0;
    reg  [15:0]                   int_num_partitions = 'b0;
    reg  [63:0]                   int_metadata = 'b0;
    reg  [63:0]                   int_degrees = 'b0;
    reg  [63:0]                   int_rankings = 'b0;
    reg  [63:0]                   int_tmps = 'b0;
    reg  [63:0]                   int_edges_0 = 'b0;
    reg  [63:0]                   int_edges_1 = 'b0;
    reg  [63:0]                   int_edges_2 = 'b0;
    reg  [63:0]                   int_edges_3 = 'b0;
    reg  [63:0]                   int_edges_4 = 'b0;
    reg  [63:0]                   int_edges_5 = 'b0;
    reg  [63:0]                   int_edges_6 = 'b0;
    reg  [63:0]                   int_edges_7 = 'b0;
    reg  [63:0]                   int_updates_0 = 'b0;
    reg  [63:0]                   int_updates_1 = 'b0;
    reg  [63:0]                   int_updates_2 = 'b0;
    reg  [63:0]                   int_updates_3 = 'b0;
    reg  [63:0]                   int_updates_4 = 'b0;
    reg  [63:0]                   int_updates_5 = 'b0;
    reg  [63:0]                   int_updates_6 = 'b0;
    reg  [63:0]                   int_updates_7 = 'b0;

//------------------------Instantiation------------------

//------------------------AXI write fsm------------------
assign AWREADY = (wstate == WRIDLE);
assign WREADY  = (wstate == WRDATA);
assign BRESP   = 2'b00;  // OKAY
assign BVALID  = (wstate == WRRESP);
assign wmask   = { {8{WSTRB[3]}}, {8{WSTRB[2]}}, {8{WSTRB[1]}}, {8{WSTRB[0]}} };
assign aw_hs   = AWVALID & AWREADY;
assign w_hs    = WVALID & WREADY;

// wstate
always @(posedge ACLK) begin
    if (ARESET)
        wstate <= WRRESET;
    else if (ACLK_EN)
        wstate <= wnext;
end

// wnext
always @(*) begin
    case (wstate)
        WRIDLE:
            if (AWVALID)
                wnext = WRDATA;
            else
                wnext = WRIDLE;
        WRDATA:
            if (WVALID)
                wnext = WRRESP;
            else
                wnext = WRDATA;
        WRRESP:
            if (BREADY)
                wnext = WRIDLE;
            else
                wnext = WRRESP;
        default:
            wnext = WRIDLE;
    endcase
end

// waddr
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (aw_hs)
            waddr <= AWADDR[ADDR_BITS-1:0];
    end
end

//------------------------AXI read fsm-------------------
assign ARREADY = (rstate == RDIDLE);
assign RDATA   = rdata;
assign RRESP   = 2'b00;  // OKAY
assign RVALID  = (rstate == RDDATA);
assign ar_hs   = ARVALID & ARREADY;
assign raddr   = ARADDR[ADDR_BITS-1:0];

// rstate
always @(posedge ACLK) begin
    if (ARESET)
        rstate <= RDRESET;
    else if (ACLK_EN)
        rstate <= rnext;
end

// rnext
always @(*) begin
    case (rstate)
        RDIDLE:
            if (ARVALID)
                rnext = RDDATA;
            else
                rnext = RDIDLE;
        RDDATA:
            if (RREADY & RVALID)
                rnext = RDIDLE;
            else
                rnext = RDDATA;
        default:
            rnext = RDIDLE;
    endcase
end

// rdata
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (ar_hs) begin
            rdata <= 1'b0;
            case (raddr)
                ADDR_AP_CTRL: begin
                    rdata[0] <= int_ap_start;
                    rdata[1] <= int_ap_done;
                    rdata[2] <= int_ap_idle;
                    rdata[3] <= int_ap_ready;
                    rdata[7] <= int_auto_restart;
                end
                ADDR_GIE: begin
                    rdata <= int_gie;
                end
                ADDR_IER: begin
                    rdata <= int_ier;
                end
                ADDR_ISR: begin
                    rdata <= int_isr;
                end
                ADDR_NUM_PARTITIONS_DATA_0: begin
                    rdata <= int_num_partitions[15:0];
                end
                ADDR_METADATA_DATA_0: begin
                    rdata <= int_metadata[31:0];
                end
                ADDR_METADATA_DATA_1: begin
                    rdata <= int_metadata[63:32];
                end
                ADDR_DEGREES_DATA_0: begin
                    rdata <= int_degrees[31:0];
                end
                ADDR_DEGREES_DATA_1: begin
                    rdata <= int_degrees[63:32];
                end
                ADDR_RANKINGS_DATA_0: begin
                    rdata <= int_rankings[31:0];
                end
                ADDR_RANKINGS_DATA_1: begin
                    rdata <= int_rankings[63:32];
                end
                ADDR_TMPS_DATA_0: begin
                    rdata <= int_tmps[31:0];
                end
                ADDR_TMPS_DATA_1: begin
                    rdata <= int_tmps[63:32];
                end
                ADDR_EDGES_0_DATA_0: begin
                    rdata <= int_edges_0[31:0];
                end
                ADDR_EDGES_0_DATA_1: begin
                    rdata <= int_edges_0[63:32];
                end
                ADDR_EDGES_1_DATA_0: begin
                    rdata <= int_edges_1[31:0];
                end
                ADDR_EDGES_1_DATA_1: begin
                    rdata <= int_edges_1[63:32];
                end
                ADDR_EDGES_2_DATA_0: begin
                    rdata <= int_edges_2[31:0];
                end
                ADDR_EDGES_2_DATA_1: begin
                    rdata <= int_edges_2[63:32];
                end
                ADDR_EDGES_3_DATA_0: begin
                    rdata <= int_edges_3[31:0];
                end
                ADDR_EDGES_3_DATA_1: begin
                    rdata <= int_edges_3[63:32];
                end
                ADDR_EDGES_4_DATA_0: begin
                    rdata <= int_edges_4[31:0];
                end
                ADDR_EDGES_4_DATA_1: begin
                    rdata <= int_edges_4[63:32];
                end
                ADDR_EDGES_5_DATA_0: begin
                    rdata <= int_edges_5[31:0];
                end
                ADDR_EDGES_5_DATA_1: begin
                    rdata <= int_edges_5[63:32];
                end
                ADDR_EDGES_6_DATA_0: begin
                    rdata <= int_edges_6[31:0];
                end
                ADDR_EDGES_6_DATA_1: begin
                    rdata <= int_edges_6[63:32];
                end
                ADDR_EDGES_7_DATA_0: begin
                    rdata <= int_edges_7[31:0];
                end
                ADDR_EDGES_7_DATA_1: begin
                    rdata <= int_edges_7[63:32];
                end
                ADDR_UPDATES_0_DATA_0: begin
                    rdata <= int_updates_0[31:0];
                end
                ADDR_UPDATES_0_DATA_1: begin
                    rdata <= int_updates_0[63:32];
                end
                ADDR_UPDATES_1_DATA_0: begin
                    rdata <= int_updates_1[31:0];
                end
                ADDR_UPDATES_1_DATA_1: begin
                    rdata <= int_updates_1[63:32];
                end
                ADDR_UPDATES_2_DATA_0: begin
                    rdata <= int_updates_2[31:0];
                end
                ADDR_UPDATES_2_DATA_1: begin
                    rdata <= int_updates_2[63:32];
                end
                ADDR_UPDATES_3_DATA_0: begin
                    rdata <= int_updates_3[31:0];
                end
                ADDR_UPDATES_3_DATA_1: begin
                    rdata <= int_updates_3[63:32];
                end
                ADDR_UPDATES_4_DATA_0: begin
                    rdata <= int_updates_4[31:0];
                end
                ADDR_UPDATES_4_DATA_1: begin
                    rdata <= int_updates_4[63:32];
                end
                ADDR_UPDATES_5_DATA_0: begin
                    rdata <= int_updates_5[31:0];
                end
                ADDR_UPDATES_5_DATA_1: begin
                    rdata <= int_updates_5[63:32];
                end
                ADDR_UPDATES_6_DATA_0: begin
                    rdata <= int_updates_6[31:0];
                end
                ADDR_UPDATES_6_DATA_1: begin
                    rdata <= int_updates_6[63:32];
                end
                ADDR_UPDATES_7_DATA_0: begin
                    rdata <= int_updates_7[31:0];
                end
                ADDR_UPDATES_7_DATA_1: begin
                    rdata <= int_updates_7[63:32];
                end
            endcase
        end
    end
end


//------------------------Register logic-----------------
assign interrupt      = int_gie & (|int_isr);
assign ap_start       = int_ap_start;
assign num_partitions = int_num_partitions;
assign metadata       = int_metadata;
assign degrees        = int_degrees;
assign rankings       = int_rankings;
assign tmps           = int_tmps;
assign edges_0        = int_edges_0;
assign edges_1        = int_edges_1;
assign edges_2        = int_edges_2;
assign edges_3        = int_edges_3;
assign edges_4        = int_edges_4;
assign edges_5        = int_edges_5;
assign edges_6        = int_edges_6;
assign edges_7        = int_edges_7;
assign updates_0      = int_updates_0;
assign updates_1      = int_updates_1;
assign updates_2      = int_updates_2;
assign updates_3      = int_updates_3;
assign updates_4      = int_updates_4;
assign updates_5      = int_updates_5;
assign updates_6      = int_updates_6;
assign updates_7      = int_updates_7;
// int_ap_start
always @(posedge ACLK) begin
    if (ARESET)
        int_ap_start <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AP_CTRL && WSTRB[0] && WDATA[0])
            int_ap_start <= 1'b1;
        else if (ap_ready)
            int_ap_start <= int_auto_restart; // clear on handshake/auto restart
    end
end

// int_ap_done
always @(posedge ACLK) begin
    if (ARESET)
        int_ap_done <= 1'b0;
    else if (ACLK_EN) begin
        if (ap_done)
            int_ap_done <= 1'b1;
        else if (ar_hs && raddr == ADDR_AP_CTRL)
            int_ap_done <= 1'b0; // clear on read
    end
end

// int_ap_idle
always @(posedge ACLK) begin
    if (ARESET)
        int_ap_idle <= 1'b0;
    else if (ACLK_EN) begin
            int_ap_idle <= ap_idle;
    end
end

// int_ap_ready
always @(posedge ACLK) begin
    if (ARESET)
        int_ap_ready <= 1'b0;
    else if (ACLK_EN) begin
            int_ap_ready <= ap_ready;
    end
end

// int_auto_restart
always @(posedge ACLK) begin
    if (ARESET)
        int_auto_restart <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AP_CTRL && WSTRB[0])
            int_auto_restart <=  WDATA[7];
    end
end

// int_gie
always @(posedge ACLK) begin
    if (ARESET)
        int_gie <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_GIE && WSTRB[0])
            int_gie <= WDATA[0];
    end
end

// int_ier
always @(posedge ACLK) begin
    if (ARESET)
        int_ier <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_IER && WSTRB[0])
            int_ier <= WDATA[1:0];
    end
end

// int_isr[0]
always @(posedge ACLK) begin
    if (ARESET)
        int_isr[0] <= 1'b0;
    else if (ACLK_EN) begin
        if (int_ier[0] & ap_done)
            int_isr[0] <= 1'b1;
        else if (w_hs && waddr == ADDR_ISR && WSTRB[0])
            int_isr[0] <= int_isr[0] ^ WDATA[0]; // toggle on write
    end
end

// int_isr[1]
always @(posedge ACLK) begin
    if (ARESET)
        int_isr[1] <= 1'b0;
    else if (ACLK_EN) begin
        if (int_ier[1] & ap_ready)
            int_isr[1] <= 1'b1;
        else if (w_hs && waddr == ADDR_ISR && WSTRB[0])
            int_isr[1] <= int_isr[1] ^ WDATA[1]; // toggle on write
    end
end

// int_num_partitions[15:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_num_partitions[15:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_NUM_PARTITIONS_DATA_0)
            int_num_partitions[15:0] <= (WDATA[31:0] & wmask) | (int_num_partitions[15:0] & ~wmask);
    end
end

// int_metadata[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_metadata[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_METADATA_DATA_0)
            int_metadata[31:0] <= (WDATA[31:0] & wmask) | (int_metadata[31:0] & ~wmask);
    end
end

// int_metadata[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_metadata[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_METADATA_DATA_1)
            int_metadata[63:32] <= (WDATA[31:0] & wmask) | (int_metadata[63:32] & ~wmask);
    end
end

// int_degrees[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_degrees[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_DEGREES_DATA_0)
            int_degrees[31:0] <= (WDATA[31:0] & wmask) | (int_degrees[31:0] & ~wmask);
    end
end

// int_degrees[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_degrees[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_DEGREES_DATA_1)
            int_degrees[63:32] <= (WDATA[31:0] & wmask) | (int_degrees[63:32] & ~wmask);
    end
end

// int_rankings[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_rankings[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_RANKINGS_DATA_0)
            int_rankings[31:0] <= (WDATA[31:0] & wmask) | (int_rankings[31:0] & ~wmask);
    end
end

// int_rankings[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_rankings[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_RANKINGS_DATA_1)
            int_rankings[63:32] <= (WDATA[31:0] & wmask) | (int_rankings[63:32] & ~wmask);
    end
end

// int_tmps[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_tmps[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_TMPS_DATA_0)
            int_tmps[31:0] <= (WDATA[31:0] & wmask) | (int_tmps[31:0] & ~wmask);
    end
end

// int_tmps[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_tmps[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_TMPS_DATA_1)
            int_tmps[63:32] <= (WDATA[31:0] & wmask) | (int_tmps[63:32] & ~wmask);
    end
end

// int_edges_0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_edges_0[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_EDGES_0_DATA_0)
            int_edges_0[31:0] <= (WDATA[31:0] & wmask) | (int_edges_0[31:0] & ~wmask);
    end
end

// int_edges_0[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_edges_0[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_EDGES_0_DATA_1)
            int_edges_0[63:32] <= (WDATA[31:0] & wmask) | (int_edges_0[63:32] & ~wmask);
    end
end

// int_edges_1[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_edges_1[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_EDGES_1_DATA_0)
            int_edges_1[31:0] <= (WDATA[31:0] & wmask) | (int_edges_1[31:0] & ~wmask);
    end
end

// int_edges_1[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_edges_1[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_EDGES_1_DATA_1)
            int_edges_1[63:32] <= (WDATA[31:0] & wmask) | (int_edges_1[63:32] & ~wmask);
    end
end

// int_edges_2[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_edges_2[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_EDGES_2_DATA_0)
            int_edges_2[31:0] <= (WDATA[31:0] & wmask) | (int_edges_2[31:0] & ~wmask);
    end
end

// int_edges_2[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_edges_2[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_EDGES_2_DATA_1)
            int_edges_2[63:32] <= (WDATA[31:0] & wmask) | (int_edges_2[63:32] & ~wmask);
    end
end

// int_edges_3[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_edges_3[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_EDGES_3_DATA_0)
            int_edges_3[31:0] <= (WDATA[31:0] & wmask) | (int_edges_3[31:0] & ~wmask);
    end
end

// int_edges_3[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_edges_3[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_EDGES_3_DATA_1)
            int_edges_3[63:32] <= (WDATA[31:0] & wmask) | (int_edges_3[63:32] & ~wmask);
    end
end

// int_edges_4[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_edges_4[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_EDGES_4_DATA_0)
            int_edges_4[31:0] <= (WDATA[31:0] & wmask) | (int_edges_4[31:0] & ~wmask);
    end
end

// int_edges_4[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_edges_4[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_EDGES_4_DATA_1)
            int_edges_4[63:32] <= (WDATA[31:0] & wmask) | (int_edges_4[63:32] & ~wmask);
    end
end

// int_edges_5[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_edges_5[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_EDGES_5_DATA_0)
            int_edges_5[31:0] <= (WDATA[31:0] & wmask) | (int_edges_5[31:0] & ~wmask);
    end
end

// int_edges_5[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_edges_5[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_EDGES_5_DATA_1)
            int_edges_5[63:32] <= (WDATA[31:0] & wmask) | (int_edges_5[63:32] & ~wmask);
    end
end

// int_edges_6[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_edges_6[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_EDGES_6_DATA_0)
            int_edges_6[31:0] <= (WDATA[31:0] & wmask) | (int_edges_6[31:0] & ~wmask);
    end
end

// int_edges_6[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_edges_6[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_EDGES_6_DATA_1)
            int_edges_6[63:32] <= (WDATA[31:0] & wmask) | (int_edges_6[63:32] & ~wmask);
    end
end

// int_edges_7[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_edges_7[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_EDGES_7_DATA_0)
            int_edges_7[31:0] <= (WDATA[31:0] & wmask) | (int_edges_7[31:0] & ~wmask);
    end
end

// int_edges_7[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_edges_7[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_EDGES_7_DATA_1)
            int_edges_7[63:32] <= (WDATA[31:0] & wmask) | (int_edges_7[63:32] & ~wmask);
    end
end

// int_updates_0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_updates_0[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_UPDATES_0_DATA_0)
            int_updates_0[31:0] <= (WDATA[31:0] & wmask) | (int_updates_0[31:0] & ~wmask);
    end
end

// int_updates_0[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_updates_0[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_UPDATES_0_DATA_1)
            int_updates_0[63:32] <= (WDATA[31:0] & wmask) | (int_updates_0[63:32] & ~wmask);
    end
end

// int_updates_1[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_updates_1[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_UPDATES_1_DATA_0)
            int_updates_1[31:0] <= (WDATA[31:0] & wmask) | (int_updates_1[31:0] & ~wmask);
    end
end

// int_updates_1[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_updates_1[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_UPDATES_1_DATA_1)
            int_updates_1[63:32] <= (WDATA[31:0] & wmask) | (int_updates_1[63:32] & ~wmask);
    end
end

// int_updates_2[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_updates_2[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_UPDATES_2_DATA_0)
            int_updates_2[31:0] <= (WDATA[31:0] & wmask) | (int_updates_2[31:0] & ~wmask);
    end
end

// int_updates_2[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_updates_2[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_UPDATES_2_DATA_1)
            int_updates_2[63:32] <= (WDATA[31:0] & wmask) | (int_updates_2[63:32] & ~wmask);
    end
end

// int_updates_3[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_updates_3[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_UPDATES_3_DATA_0)
            int_updates_3[31:0] <= (WDATA[31:0] & wmask) | (int_updates_3[31:0] & ~wmask);
    end
end

// int_updates_3[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_updates_3[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_UPDATES_3_DATA_1)
            int_updates_3[63:32] <= (WDATA[31:0] & wmask) | (int_updates_3[63:32] & ~wmask);
    end
end

// int_updates_4[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_updates_4[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_UPDATES_4_DATA_0)
            int_updates_4[31:0] <= (WDATA[31:0] & wmask) | (int_updates_4[31:0] & ~wmask);
    end
end

// int_updates_4[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_updates_4[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_UPDATES_4_DATA_1)
            int_updates_4[63:32] <= (WDATA[31:0] & wmask) | (int_updates_4[63:32] & ~wmask);
    end
end

// int_updates_5[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_updates_5[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_UPDATES_5_DATA_0)
            int_updates_5[31:0] <= (WDATA[31:0] & wmask) | (int_updates_5[31:0] & ~wmask);
    end
end

// int_updates_5[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_updates_5[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_UPDATES_5_DATA_1)
            int_updates_5[63:32] <= (WDATA[31:0] & wmask) | (int_updates_5[63:32] & ~wmask);
    end
end

// int_updates_6[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_updates_6[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_UPDATES_6_DATA_0)
            int_updates_6[31:0] <= (WDATA[31:0] & wmask) | (int_updates_6[31:0] & ~wmask);
    end
end

// int_updates_6[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_updates_6[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_UPDATES_6_DATA_1)
            int_updates_6[63:32] <= (WDATA[31:0] & wmask) | (int_updates_6[63:32] & ~wmask);
    end
end

// int_updates_7[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_updates_7[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_UPDATES_7_DATA_0)
            int_updates_7[31:0] <= (WDATA[31:0] & wmask) | (int_updates_7[31:0] & ~wmask);
    end
end

// int_updates_7[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_updates_7[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_UPDATES_7_DATA_1)
            int_updates_7[63:32] <= (WDATA[31:0] & wmask) | (int_updates_7[63:32] & ~wmask);
    end
end


//------------------------Memory logic-------------------

endmodule
