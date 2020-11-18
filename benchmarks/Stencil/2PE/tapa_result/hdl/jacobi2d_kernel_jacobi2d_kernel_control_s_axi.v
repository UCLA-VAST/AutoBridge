// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
`timescale 1ns/1ps
module jacobi2d_kernel_jacobi2d_kernel_control_s_axi
#(parameter
    C_S_AXI_ADDR_WIDTH = 8,
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
    output wire [63:0]                   var_output_0_0,
    output wire [63:0]                   var_output_0_1,
    output wire [63:0]                   var_output_0_2,
    output wire [63:0]                   var_output_0_3,
    output wire [63:0]                   var_input_0_0,
    output wire [63:0]                   var_input_0_1,
    output wire [63:0]                   var_input_0_2,
    output wire [63:0]                   var_input_0_3,
    output wire [63:0]                   coalesced_data_num,
    output wire [63:0]                   tile_data_num,
    output wire [31:0]                   tile_num_dim_0,
    output wire [31:0]                   input_size_dim_0,
    output wire [31:0]                   input_size_dim_1
);
//------------------------Address Info-------------------
// 0x00 : Control signals
//        bit 0  - ap_start (Read/Write/COH)
//        bit 1  - ap_done (Read/COR)
//        bit 2  - ap_idle (Read)
//        bit 3  - ap_ready (Read)
//        bit 7  - auto_restart (Read/Write)
//        others - reserved
// 0x04 : Global Interrupt Enable Register
//        bit 0  - Global Interrupt Enable (Read/Write)
//        others - reserved
// 0x08 : IP Interrupt Enable Register (Read/Write)
//        bit 0  - Channel 0 (ap_done)
//        bit 1  - Channel 1 (ap_ready)
//        others - reserved
// 0x0c : IP Interrupt Status Register (Read/TOW)
//        bit 0  - Channel 0 (ap_done)
//        bit 1  - Channel 1 (ap_ready)
//        others - reserved
// 0x10 : Data signal of var_output_0_0
//        bit 31~0 - var_output_0_0[31:0] (Read/Write)
// 0x14 : Data signal of var_output_0_0
//        bit 31~0 - var_output_0_0[63:32] (Read/Write)
// 0x18 : reserved
// 0x1c : Data signal of var_output_0_1
//        bit 31~0 - var_output_0_1[31:0] (Read/Write)
// 0x20 : Data signal of var_output_0_1
//        bit 31~0 - var_output_0_1[63:32] (Read/Write)
// 0x24 : reserved
// 0x28 : Data signal of var_output_0_2
//        bit 31~0 - var_output_0_2[31:0] (Read/Write)
// 0x2c : Data signal of var_output_0_2
//        bit 31~0 - var_output_0_2[63:32] (Read/Write)
// 0x30 : reserved
// 0x34 : Data signal of var_output_0_3
//        bit 31~0 - var_output_0_3[31:0] (Read/Write)
// 0x38 : Data signal of var_output_0_3
//        bit 31~0 - var_output_0_3[63:32] (Read/Write)
// 0x3c : reserved
// 0x40 : Data signal of var_input_0_0
//        bit 31~0 - var_input_0_0[31:0] (Read/Write)
// 0x44 : Data signal of var_input_0_0
//        bit 31~0 - var_input_0_0[63:32] (Read/Write)
// 0x48 : reserved
// 0x4c : Data signal of var_input_0_1
//        bit 31~0 - var_input_0_1[31:0] (Read/Write)
// 0x50 : Data signal of var_input_0_1
//        bit 31~0 - var_input_0_1[63:32] (Read/Write)
// 0x54 : reserved
// 0x58 : Data signal of var_input_0_2
//        bit 31~0 - var_input_0_2[31:0] (Read/Write)
// 0x5c : Data signal of var_input_0_2
//        bit 31~0 - var_input_0_2[63:32] (Read/Write)
// 0x60 : reserved
// 0x64 : Data signal of var_input_0_3
//        bit 31~0 - var_input_0_3[31:0] (Read/Write)
// 0x68 : Data signal of var_input_0_3
//        bit 31~0 - var_input_0_3[63:32] (Read/Write)
// 0x6c : reserved
// 0x70 : Data signal of coalesced_data_num
//        bit 31~0 - coalesced_data_num[31:0] (Read/Write)
// 0x74 : Data signal of coalesced_data_num
//        bit 31~0 - coalesced_data_num[63:32] (Read/Write)
// 0x78 : reserved
// 0x7c : Data signal of tile_data_num
//        bit 31~0 - tile_data_num[31:0] (Read/Write)
// 0x80 : Data signal of tile_data_num
//        bit 31~0 - tile_data_num[63:32] (Read/Write)
// 0x84 : reserved
// 0x88 : Data signal of tile_num_dim_0
//        bit 31~0 - tile_num_dim_0[31:0] (Read/Write)
// 0x8c : reserved
// 0x90 : Data signal of input_size_dim_0
//        bit 31~0 - input_size_dim_0[31:0] (Read/Write)
// 0x94 : reserved
// 0x98 : Data signal of input_size_dim_1
//        bit 31~0 - input_size_dim_1[31:0] (Read/Write)
// 0x9c : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

//------------------------Parameter----------------------
localparam
    ADDR_AP_CTRL                   = 8'h00,
    ADDR_GIE                       = 8'h04,
    ADDR_IER                       = 8'h08,
    ADDR_ISR                       = 8'h0c,
    ADDR_VAR_OUTPUT_0_0_DATA_0     = 8'h10,
    ADDR_VAR_OUTPUT_0_0_DATA_1     = 8'h14,
    ADDR_VAR_OUTPUT_0_0_CTRL       = 8'h18,
    ADDR_VAR_OUTPUT_0_1_DATA_0     = 8'h1c,
    ADDR_VAR_OUTPUT_0_1_DATA_1     = 8'h20,
    ADDR_VAR_OUTPUT_0_1_CTRL       = 8'h24,
    ADDR_VAR_OUTPUT_0_2_DATA_0     = 8'h28,
    ADDR_VAR_OUTPUT_0_2_DATA_1     = 8'h2c,
    ADDR_VAR_OUTPUT_0_2_CTRL       = 8'h30,
    ADDR_VAR_OUTPUT_0_3_DATA_0     = 8'h34,
    ADDR_VAR_OUTPUT_0_3_DATA_1     = 8'h38,
    ADDR_VAR_OUTPUT_0_3_CTRL       = 8'h3c,
    ADDR_VAR_INPUT_0_0_DATA_0      = 8'h40,
    ADDR_VAR_INPUT_0_0_DATA_1      = 8'h44,
    ADDR_VAR_INPUT_0_0_CTRL        = 8'h48,
    ADDR_VAR_INPUT_0_1_DATA_0      = 8'h4c,
    ADDR_VAR_INPUT_0_1_DATA_1      = 8'h50,
    ADDR_VAR_INPUT_0_1_CTRL        = 8'h54,
    ADDR_VAR_INPUT_0_2_DATA_0      = 8'h58,
    ADDR_VAR_INPUT_0_2_DATA_1      = 8'h5c,
    ADDR_VAR_INPUT_0_2_CTRL        = 8'h60,
    ADDR_VAR_INPUT_0_3_DATA_0      = 8'h64,
    ADDR_VAR_INPUT_0_3_DATA_1      = 8'h68,
    ADDR_VAR_INPUT_0_3_CTRL        = 8'h6c,
    ADDR_COALESCED_DATA_NUM_DATA_0 = 8'h70,
    ADDR_COALESCED_DATA_NUM_DATA_1 = 8'h74,
    ADDR_COALESCED_DATA_NUM_CTRL   = 8'h78,
    ADDR_TILE_DATA_NUM_DATA_0      = 8'h7c,
    ADDR_TILE_DATA_NUM_DATA_1      = 8'h80,
    ADDR_TILE_DATA_NUM_CTRL        = 8'h84,
    ADDR_TILE_NUM_DIM_0_DATA_0     = 8'h88,
    ADDR_TILE_NUM_DIM_0_CTRL       = 8'h8c,
    ADDR_INPUT_SIZE_DIM_0_DATA_0   = 8'h90,
    ADDR_INPUT_SIZE_DIM_0_CTRL     = 8'h94,
    ADDR_INPUT_SIZE_DIM_1_DATA_0   = 8'h98,
    ADDR_INPUT_SIZE_DIM_1_CTRL     = 8'h9c,
    WRIDLE                         = 2'd0,
    WRDATA                         = 2'd1,
    WRRESP                         = 2'd2,
    WRRESET                        = 2'd3,
    RDIDLE                         = 2'd0,
    RDDATA                         = 2'd1,
    RDRESET                        = 2'd2,
    ADDR_BITS         = 8;

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
    reg  [63:0]                   int_var_output_0_0 = 'b0;
    reg  [63:0]                   int_var_output_0_1 = 'b0;
    reg  [63:0]                   int_var_output_0_2 = 'b0;
    reg  [63:0]                   int_var_output_0_3 = 'b0;
    reg  [63:0]                   int_var_input_0_0 = 'b0;
    reg  [63:0]                   int_var_input_0_1 = 'b0;
    reg  [63:0]                   int_var_input_0_2 = 'b0;
    reg  [63:0]                   int_var_input_0_3 = 'b0;
    reg  [63:0]                   int_coalesced_data_num = 'b0;
    reg  [63:0]                   int_tile_data_num = 'b0;
    reg  [31:0]                   int_tile_num_dim_0 = 'b0;
    reg  [31:0]                   int_input_size_dim_0 = 'b0;
    reg  [31:0]                   int_input_size_dim_1 = 'b0;

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
                ADDR_VAR_OUTPUT_0_0_DATA_0: begin
                    rdata <= int_var_output_0_0[31:0];
                end
                ADDR_VAR_OUTPUT_0_0_DATA_1: begin
                    rdata <= int_var_output_0_0[63:32];
                end
                ADDR_VAR_OUTPUT_0_1_DATA_0: begin
                    rdata <= int_var_output_0_1[31:0];
                end
                ADDR_VAR_OUTPUT_0_1_DATA_1: begin
                    rdata <= int_var_output_0_1[63:32];
                end
                ADDR_VAR_OUTPUT_0_2_DATA_0: begin
                    rdata <= int_var_output_0_2[31:0];
                end
                ADDR_VAR_OUTPUT_0_2_DATA_1: begin
                    rdata <= int_var_output_0_2[63:32];
                end
                ADDR_VAR_OUTPUT_0_3_DATA_0: begin
                    rdata <= int_var_output_0_3[31:0];
                end
                ADDR_VAR_OUTPUT_0_3_DATA_1: begin
                    rdata <= int_var_output_0_3[63:32];
                end
                ADDR_VAR_INPUT_0_0_DATA_0: begin
                    rdata <= int_var_input_0_0[31:0];
                end
                ADDR_VAR_INPUT_0_0_DATA_1: begin
                    rdata <= int_var_input_0_0[63:32];
                end
                ADDR_VAR_INPUT_0_1_DATA_0: begin
                    rdata <= int_var_input_0_1[31:0];
                end
                ADDR_VAR_INPUT_0_1_DATA_1: begin
                    rdata <= int_var_input_0_1[63:32];
                end
                ADDR_VAR_INPUT_0_2_DATA_0: begin
                    rdata <= int_var_input_0_2[31:0];
                end
                ADDR_VAR_INPUT_0_2_DATA_1: begin
                    rdata <= int_var_input_0_2[63:32];
                end
                ADDR_VAR_INPUT_0_3_DATA_0: begin
                    rdata <= int_var_input_0_3[31:0];
                end
                ADDR_VAR_INPUT_0_3_DATA_1: begin
                    rdata <= int_var_input_0_3[63:32];
                end
                ADDR_COALESCED_DATA_NUM_DATA_0: begin
                    rdata <= int_coalesced_data_num[31:0];
                end
                ADDR_COALESCED_DATA_NUM_DATA_1: begin
                    rdata <= int_coalesced_data_num[63:32];
                end
                ADDR_TILE_DATA_NUM_DATA_0: begin
                    rdata <= int_tile_data_num[31:0];
                end
                ADDR_TILE_DATA_NUM_DATA_1: begin
                    rdata <= int_tile_data_num[63:32];
                end
                ADDR_TILE_NUM_DIM_0_DATA_0: begin
                    rdata <= int_tile_num_dim_0[31:0];
                end
                ADDR_INPUT_SIZE_DIM_0_DATA_0: begin
                    rdata <= int_input_size_dim_0[31:0];
                end
                ADDR_INPUT_SIZE_DIM_1_DATA_0: begin
                    rdata <= int_input_size_dim_1[31:0];
                end
            endcase
        end
    end
end


//------------------------Register logic-----------------
assign interrupt          = int_gie & (|int_isr);
assign ap_start           = int_ap_start;
assign var_output_0_0     = int_var_output_0_0;
assign var_output_0_1     = int_var_output_0_1;
assign var_output_0_2     = int_var_output_0_2;
assign var_output_0_3     = int_var_output_0_3;
assign var_input_0_0      = int_var_input_0_0;
assign var_input_0_1      = int_var_input_0_1;
assign var_input_0_2      = int_var_input_0_2;
assign var_input_0_3      = int_var_input_0_3;
assign coalesced_data_num = int_coalesced_data_num;
assign tile_data_num      = int_tile_data_num;
assign tile_num_dim_0     = int_tile_num_dim_0;
assign input_size_dim_0   = int_input_size_dim_0;
assign input_size_dim_1   = int_input_size_dim_1;
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

// int_var_output_0_0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_var_output_0_0[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_VAR_OUTPUT_0_0_DATA_0)
            int_var_output_0_0[31:0] <= (WDATA[31:0] & wmask) | (int_var_output_0_0[31:0] & ~wmask);
    end
end

// int_var_output_0_0[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_var_output_0_0[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_VAR_OUTPUT_0_0_DATA_1)
            int_var_output_0_0[63:32] <= (WDATA[31:0] & wmask) | (int_var_output_0_0[63:32] & ~wmask);
    end
end

// int_var_output_0_1[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_var_output_0_1[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_VAR_OUTPUT_0_1_DATA_0)
            int_var_output_0_1[31:0] <= (WDATA[31:0] & wmask) | (int_var_output_0_1[31:0] & ~wmask);
    end
end

// int_var_output_0_1[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_var_output_0_1[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_VAR_OUTPUT_0_1_DATA_1)
            int_var_output_0_1[63:32] <= (WDATA[31:0] & wmask) | (int_var_output_0_1[63:32] & ~wmask);
    end
end

// int_var_output_0_2[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_var_output_0_2[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_VAR_OUTPUT_0_2_DATA_0)
            int_var_output_0_2[31:0] <= (WDATA[31:0] & wmask) | (int_var_output_0_2[31:0] & ~wmask);
    end
end

// int_var_output_0_2[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_var_output_0_2[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_VAR_OUTPUT_0_2_DATA_1)
            int_var_output_0_2[63:32] <= (WDATA[31:0] & wmask) | (int_var_output_0_2[63:32] & ~wmask);
    end
end

// int_var_output_0_3[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_var_output_0_3[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_VAR_OUTPUT_0_3_DATA_0)
            int_var_output_0_3[31:0] <= (WDATA[31:0] & wmask) | (int_var_output_0_3[31:0] & ~wmask);
    end
end

// int_var_output_0_3[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_var_output_0_3[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_VAR_OUTPUT_0_3_DATA_1)
            int_var_output_0_3[63:32] <= (WDATA[31:0] & wmask) | (int_var_output_0_3[63:32] & ~wmask);
    end
end

// int_var_input_0_0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_var_input_0_0[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_VAR_INPUT_0_0_DATA_0)
            int_var_input_0_0[31:0] <= (WDATA[31:0] & wmask) | (int_var_input_0_0[31:0] & ~wmask);
    end
end

// int_var_input_0_0[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_var_input_0_0[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_VAR_INPUT_0_0_DATA_1)
            int_var_input_0_0[63:32] <= (WDATA[31:0] & wmask) | (int_var_input_0_0[63:32] & ~wmask);
    end
end

// int_var_input_0_1[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_var_input_0_1[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_VAR_INPUT_0_1_DATA_0)
            int_var_input_0_1[31:0] <= (WDATA[31:0] & wmask) | (int_var_input_0_1[31:0] & ~wmask);
    end
end

// int_var_input_0_1[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_var_input_0_1[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_VAR_INPUT_0_1_DATA_1)
            int_var_input_0_1[63:32] <= (WDATA[31:0] & wmask) | (int_var_input_0_1[63:32] & ~wmask);
    end
end

// int_var_input_0_2[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_var_input_0_2[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_VAR_INPUT_0_2_DATA_0)
            int_var_input_0_2[31:0] <= (WDATA[31:0] & wmask) | (int_var_input_0_2[31:0] & ~wmask);
    end
end

// int_var_input_0_2[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_var_input_0_2[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_VAR_INPUT_0_2_DATA_1)
            int_var_input_0_2[63:32] <= (WDATA[31:0] & wmask) | (int_var_input_0_2[63:32] & ~wmask);
    end
end

// int_var_input_0_3[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_var_input_0_3[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_VAR_INPUT_0_3_DATA_0)
            int_var_input_0_3[31:0] <= (WDATA[31:0] & wmask) | (int_var_input_0_3[31:0] & ~wmask);
    end
end

// int_var_input_0_3[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_var_input_0_3[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_VAR_INPUT_0_3_DATA_1)
            int_var_input_0_3[63:32] <= (WDATA[31:0] & wmask) | (int_var_input_0_3[63:32] & ~wmask);
    end
end

// int_coalesced_data_num[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_coalesced_data_num[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_COALESCED_DATA_NUM_DATA_0)
            int_coalesced_data_num[31:0] <= (WDATA[31:0] & wmask) | (int_coalesced_data_num[31:0] & ~wmask);
    end
end

// int_coalesced_data_num[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_coalesced_data_num[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_COALESCED_DATA_NUM_DATA_1)
            int_coalesced_data_num[63:32] <= (WDATA[31:0] & wmask) | (int_coalesced_data_num[63:32] & ~wmask);
    end
end

// int_tile_data_num[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_tile_data_num[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_TILE_DATA_NUM_DATA_0)
            int_tile_data_num[31:0] <= (WDATA[31:0] & wmask) | (int_tile_data_num[31:0] & ~wmask);
    end
end

// int_tile_data_num[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_tile_data_num[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_TILE_DATA_NUM_DATA_1)
            int_tile_data_num[63:32] <= (WDATA[31:0] & wmask) | (int_tile_data_num[63:32] & ~wmask);
    end
end

// int_tile_num_dim_0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_tile_num_dim_0[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_TILE_NUM_DIM_0_DATA_0)
            int_tile_num_dim_0[31:0] <= (WDATA[31:0] & wmask) | (int_tile_num_dim_0[31:0] & ~wmask);
    end
end

// int_input_size_dim_0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_input_size_dim_0[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_INPUT_SIZE_DIM_0_DATA_0)
            int_input_size_dim_0[31:0] <= (WDATA[31:0] & wmask) | (int_input_size_dim_0[31:0] & ~wmask);
    end
end

// int_input_size_dim_1[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_input_size_dim_1[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_INPUT_SIZE_DIM_1_DATA_0)
            int_input_size_dim_1[31:0] <= (WDATA[31:0] & wmask) | (int_input_size_dim_1[31:0] & ~wmask);
    end
end


//------------------------Memory logic-------------------

endmodule
