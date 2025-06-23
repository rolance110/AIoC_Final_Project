/*===========================================================================
    Module: L2C_init_fifo_pe
    Description: 初始化所有 FIFO 與 PE 狀態，設定 base_addr 與 reset FIFO
        1. [31:0] fifo_reset_o: 給 96 個 FIFO 的 reset 訊號
        2. 設置 96 個 FIFO 的 base address    
            * [31:0] ifmap_fifo_base_addr_o [31:0]
            * [31:0] ipsum_fifo_base_addr_o [31:0]
            * [31:0] opsum_fifo_base_addr_o [31:0]
===========================================================================*/
// `include "../../../include/define.svh"
`ifndef DEFINE_LD
`define DEFINE_LD

`define ZERO_ZONE 32'h8000_0000 // Bit width for activation

`define POINTWISE 2'd0 // Bit width for activation
`define DEPTHWISE 2'd1 // Bit width for activation
`define STANDARD 2'd2 // Bit width for activation
`define LINEAR 2'd3 // Bit width for activation

`endif // DEFINE_LD
module L2C_init_fifo_pe #(
    parameter int NUM_FIFO = 96
)(
    input  logic         clk,
    input  logic         rst_n,
    input  logic         init_fifo_pe_state_i,           // 啟動初始化
    input  logic [31:0]  ifmap_glb_base_addr_i, // 各 FIFO base address 由上層配置
    input  logic [31:0]  ipsum_glb_base_addr_i, // 各 FIFO base address 由上層配置
    input  logic [31:0]  opsum_glb_base_addr_i, // 各 FIFO base address 由上層配置
    input  logic [31:0]  bias_glb_base_addr_i, 
    input logic is_bias_i, // 判斷現在 ipsum_fifo 是要輸入 bias or ipsum 

    //* For 3x3 convolution pad
    input logic [31:0] output_row_cnt_i,
    input logic n_tile_is_first_i, // 是否為第一個 tile
    input logic n_tile_is_last_i, // 是否為最後一個 tile
    
    //* Form Tile_Scheduler
    // require by every module
    input logic [1:0] layer_type_i,
    // ifmap base addr require
    input logic [31:0] tile_n_i,
    input logic [7:0] in_C_i,
    input logic [1:0] pad_R_i,
    input logic [1:0] pad_L_i,
    // ofmap base addr require
    input logic [31:0] On_real_i,
    input logic [7:0] out_C_i,


    output logic [31:0] ifmap_fifo_base_addr_o [31:0],
    output logic [31:0] ipsum_fifo_base_addr_o [31:0],
    output logic [31:0] opsum_fifo_base_addr_o [31:0],

    output logic ifmap_fifo_reset_o, // reset signal for all ifmap FIFO
    output logic ipsum_fifo_reset_o, // reset signal for all ipsum FIFO
    output logic opsum_fifo_reset_o  // reset signal for all opsum FIFO
);

always_comb begin
    if(init_fifo_pe_state_i)begin
        ifmap_fifo_reset_o = 1'b1;
        ipsum_fifo_reset_o = 1'b1;
        opsum_fifo_reset_o = 1'b1;
    end
    else begin
        ifmap_fifo_reset_o = 1'b0;
        ipsum_fifo_reset_o = 1'b0;
        opsum_fifo_reset_o = 1'b0;
    end
end



// ifmap_glb_base_addr_i
integer i, j, k, r, t;
integer n;
always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i=0; i<32; i++)begin
            ifmap_fifo_base_addr_o[i] <= 32'd0;
        end
    end
    else if(layer_type_i == `POINTWISE && init_fifo_pe_state_i)begin
    // input channel 0
        ifmap_fifo_base_addr_o[0] <= ifmap_glb_base_addr_i;
    // input channel 1
        ifmap_fifo_base_addr_o[1] <= ifmap_glb_base_addr_i + tile_n_i;
    // input channel 2
        ifmap_fifo_base_addr_o[2] <= ifmap_glb_base_addr_i + 2*tile_n_i;
    // input channel 3
        ifmap_fifo_base_addr_o[3] <= ifmap_glb_base_addr_i + 3*tile_n_i;
    // input channel 4
        ifmap_fifo_base_addr_o[4] <= ifmap_glb_base_addr_i + 4*tile_n_i;
    // input channel 5
        ifmap_fifo_base_addr_o[5] <= ifmap_glb_base_addr_i + 5*tile_n_i;
    // input channel 6
        ifmap_fifo_base_addr_o[6] <= ifmap_glb_base_addr_i + 6*tile_n_i;
    // input channel 7
        ifmap_fifo_base_addr_o[7] <= ifmap_glb_base_addr_i + 7*tile_n_i;
    // input channel 8
        ifmap_fifo_base_addr_o[8] <= ifmap_glb_base_addr_i + 8*tile_n_i;
    // input channel 9
        ifmap_fifo_base_addr_o[9] <= ifmap_glb_base_addr_i + 9*tile_n_i;
    // input channel 10
        ifmap_fifo_base_addr_o[10] <= ifmap_glb_base_addr_i + 10*tile_n_i;
    // input channel 11
        ifmap_fifo_base_addr_o[11] <= ifmap_glb_base_addr_i + 11*tile_n_i;
    // input channel 12
        ifmap_fifo_base_addr_o[12] <= ifmap_glb_base_addr_i + 12*tile_n_i;
    // input channel 13
        ifmap_fifo_base_addr_o[13] <= ifmap_glb_base_addr_i + 13*tile_n_i;
    // input channel 14
        ifmap_fifo_base_addr_o[14] <= ifmap_glb_base_addr_i + 14*tile_n_i;
    // input channel 15
        ifmap_fifo_base_addr_o[15] <= ifmap_glb_base_addr_i + 15*tile_n_i;
    // input channel 16
        ifmap_fifo_base_addr_o[16] <= ifmap_glb_base_addr_i + 16*tile_n_i;
    // input channel 17
        ifmap_fifo_base_addr_o[17] <= ifmap_glb_base_addr_i + 17*tile_n_i;
    // input channel 18
        ifmap_fifo_base_addr_o[18] <= ifmap_glb_base_addr_i + 18*tile_n_i;
    // input channel 19
        ifmap_fifo_base_addr_o[19] <= ifmap_glb_base_addr_i + 19*tile_n_i;
    // input channel 20
        ifmap_fifo_base_addr_o[20] <= ifmap_glb_base_addr_i + 20*tile_n_i;
    // input channel 21
        ifmap_fifo_base_addr_o[21] <= ifmap_glb_base_addr_i + 21*tile_n_i;
    // input channel 22
        ifmap_fifo_base_addr_o[22] <= ifmap_glb_base_addr_i + 22*tile_n_i;
    // input channel 23
        ifmap_fifo_base_addr_o[23] <= ifmap_glb_base_addr_i + 23*tile_n_i;
    // input channel 24
        ifmap_fifo_base_addr_o[24] <= ifmap_glb_base_addr_i + 24*tile_n_i;
    // input channel 25
        ifmap_fifo_base_addr_o[25] <= ifmap_glb_base_addr_i + 25*tile_n_i;
    // input channel 26
        ifmap_fifo_base_addr_o[26] <= ifmap_glb_base_addr_i + 26*tile_n_i;
    // input channel 27
        ifmap_fifo_base_addr_o[27] <= ifmap_glb_base_addr_i + 27*tile_n_i;
    // input channel 28
        ifmap_fifo_base_addr_o[28] <= ifmap_glb_base_addr_i + 28*tile_n_i;
    // input channel 29
        ifmap_fifo_base_addr_o[29] <= ifmap_glb_base_addr_i + 29*tile_n_i;
    // input channel 30
        ifmap_fifo_base_addr_o[30] <= ifmap_glb_base_addr_i + 30*tile_n_i;
    // input channel 31
        ifmap_fifo_base_addr_o[31] <= ifmap_glb_base_addr_i + 31*tile_n_i;
    end
    else if(layer_type_i == `DEPTHWISE && init_fifo_pe_state_i && n_tile_is_first_i)begin
        if(output_row_cnt_i == 32'd0) begin
        // input channel 1
            ifmap_fifo_base_addr_o[0] <= `ZERO_ZONE;
            ifmap_fifo_base_addr_o[1] <= ifmap_glb_base_addr_i;
            ifmap_fifo_base_addr_o[2] <= ifmap_glb_base_addr_i + (in_C_i);
        // input channel 2
            ifmap_fifo_base_addr_o[3] <= `ZERO_ZONE;
            ifmap_fifo_base_addr_o[4] <= ifmap_glb_base_addr_i + tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[5] <= ifmap_glb_base_addr_i + tile_n_i*(in_C_i) + (in_C_i);
        // input channel 3 
            ifmap_fifo_base_addr_o[6] <= `ZERO_ZONE;
            ifmap_fifo_base_addr_o[7] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[8] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_C_i) + (in_C_i);
        // input channel 4
            ifmap_fifo_base_addr_o[9]  <= `ZERO_ZONE;
            ifmap_fifo_base_addr_o[10] <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[11] <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_C_i) + (in_C_i);
        // input channel 5
            ifmap_fifo_base_addr_o[12] <= `ZERO_ZONE;
            ifmap_fifo_base_addr_o[13] <= ifmap_glb_base_addr_i + 4*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[14] <= ifmap_glb_base_addr_i + 4*tile_n_i*(in_C_i) + (in_C_i);
        // input channel 6
            ifmap_fifo_base_addr_o[15] <= `ZERO_ZONE;
            ifmap_fifo_base_addr_o[16] <= ifmap_glb_base_addr_i + 5*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[17] <= ifmap_glb_base_addr_i + 5*tile_n_i*(in_C_i) + (in_C_i);
        // input channel 7
            ifmap_fifo_base_addr_o[18] <= `ZERO_ZONE;
            ifmap_fifo_base_addr_o[19] <= ifmap_glb_base_addr_i + 6*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[20] <= ifmap_glb_base_addr_i + 6*tile_n_i*(in_C_i) + (in_C_i);
        // input channel 8
            ifmap_fifo_base_addr_o[21] <= `ZERO_ZONE;
            ifmap_fifo_base_addr_o[22] <= ifmap_glb_base_addr_i + 7*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[23] <= ifmap_glb_base_addr_i + 7*tile_n_i*(in_C_i) + (in_C_i);
        // input channel 9
            ifmap_fifo_base_addr_o[24] <= `ZERO_ZONE;
            ifmap_fifo_base_addr_o[25] <= ifmap_glb_base_addr_i + 8*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[26] <= ifmap_glb_base_addr_i + 8*tile_n_i*(in_C_i) + (in_C_i);
        // input channel 10
            ifmap_fifo_base_addr_o[27] <= `ZERO_ZONE;
            ifmap_fifo_base_addr_o[28] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[29] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_C_i) + (in_C_i);
        end
        else if(output_row_cnt_i == 32'd1) begin
        // input channel 1
            ifmap_fifo_base_addr_o[0] <= ifmap_glb_base_addr_i;
            ifmap_fifo_base_addr_o[1] <= ifmap_glb_base_addr_i + (in_C_i);
            ifmap_fifo_base_addr_o[2] <= ifmap_glb_base_addr_i + 2*(in_C_i);
        // input channel 2
            ifmap_fifo_base_addr_o[3] <= ifmap_glb_base_addr_i + tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[4] <= ifmap_glb_base_addr_i + tile_n_i*(in_C_i) + (in_C_i);
            ifmap_fifo_base_addr_o[5] <= ifmap_glb_base_addr_i + tile_n_i*(in_C_i) + 2*(in_C_i);
        // input channel 3
            ifmap_fifo_base_addr_o[6] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[7] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_C_i) + (in_C_i);
            ifmap_fifo_base_addr_o[8] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_C_i) + 2*(in_C_i);
        // input channel 4
            ifmap_fifo_base_addr_o[9]  <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[10] <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_C_i) + (in_C_i);
            ifmap_fifo_base_addr_o[11] <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_C_i) + 2*(in_C_i);
        // input channel 5
            ifmap_fifo_base_addr_o[12] <= ifmap_glb_base_addr_i + 4*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[13] <= ifmap_glb_base_addr_i + 4*tile_n_i*(in_C_i) + (in_C_i);
            ifmap_fifo_base_addr_o[14] <= ifmap_glb_base_addr_i + 4*tile_n_i*(in_C_i) + 2*(in_C_i);
        // input channel 6
            ifmap_fifo_base_addr_o[15] <= ifmap_glb_base_addr_i + 5*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[16] <= ifmap_glb_base_addr_i + 5*tile_n_i*(in_C_i) + (in_C_i);
            ifmap_fifo_base_addr_o[17] <= ifmap_glb_base_addr_i + 5*tile_n_i*(in_C_i) + 2*(in_C_i);
        // input channel 7
            ifmap_fifo_base_addr_o[18] <= ifmap_glb_base_addr_i + 6*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[19] <= ifmap_glb_base_addr_i + 6*tile_n_i*(in_C_i) + (in_C_i);
            ifmap_fifo_base_addr_o[20] <= ifmap_glb_base_addr_i + 6*tile_n_i*(in_C_i) + 2*(in_C_i);
        // input channel 8
            ifmap_fifo_base_addr_o[21] <= ifmap_glb_base_addr_i + 7*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[22] <= ifmap_glb_base_addr_i + 7*tile_n_i*(in_C_i) + (in_C_i);
            ifmap_fifo_base_addr_o[23] <= ifmap_glb_base_addr_i + 7*tile_n_i*(in_C_i) + 2*(in_C_i);
        // input channel 9
            ifmap_fifo_base_addr_o[24] <= ifmap_glb_base_addr_i + 8*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[25] <= ifmap_glb_base_addr_i + 8*tile_n_i*(in_C_i) + (in_C_i);
            ifmap_fifo_base_addr_o[26] <= ifmap_glb_base_addr_i + 8*tile_n_i*(in_C_i) + 2*(in_C_i);
        // input channel 10
            ifmap_fifo_base_addr_o[27] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[28] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_C_i) + (in_C_i);
            ifmap_fifo_base_addr_o[29] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_C_i) + 2*(in_C_i);
        end
        else if(output_row_cnt_i > 32'd1) begin
        // input channel 1
            ifmap_fifo_base_addr_o[0] <= ifmap_fifo_base_addr_o[1];
            ifmap_fifo_base_addr_o[1] <= ifmap_fifo_base_addr_o[2];
            ifmap_fifo_base_addr_o[2] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        // input channel 2
            ifmap_fifo_base_addr_o[3] <= ifmap_fifo_base_addr_o[4];
            ifmap_fifo_base_addr_o[4] <= ifmap_fifo_base_addr_o[5];
            ifmap_fifo_base_addr_o[5] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        // input channel 3
            ifmap_fifo_base_addr_o[6] <= ifmap_fifo_base_addr_o[7];
            ifmap_fifo_base_addr_o[7] <= ifmap_fifo_base_addr_o[8];
            ifmap_fifo_base_addr_o[8] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        // input channel 4
            ifmap_fifo_base_addr_o[9]  <= ifmap_fifo_base_addr_o[10];
            ifmap_fifo_base_addr_o[10] <= ifmap_fifo_base_addr_o[11];
            ifmap_fifo_base_addr_o[11] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        // input channel 5
            ifmap_fifo_base_addr_o[12] <= ifmap_fifo_base_addr_o[13];
            ifmap_fifo_base_addr_o[13] <= ifmap_fifo_base_addr_o[14];
            ifmap_fifo_base_addr_o[14] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        // input channel 6
            ifmap_fifo_base_addr_o[15] <= ifmap_fifo_base_addr_o[16];
            ifmap_fifo_base_addr_o[16] <= ifmap_fifo_base_addr_o[17];
            ifmap_fifo_base_addr_o[17] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        // input channel 7
            ifmap_fifo_base_addr_o[18] <= ifmap_fifo_base_addr_o[19];
            ifmap_fifo_base_addr_o[19] <= ifmap_fifo_base_addr_o[20];
            ifmap_fifo_base_addr_o[20] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        // input channel 8
            ifmap_fifo_base_addr_o[21] <= ifmap_fifo_base_addr_o[22];
            ifmap_fifo_base_addr_o[22] <= ifmap_fifo_base_addr_o[23];
            ifmap_fifo_base_addr_o[23] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        // input channel 9
            ifmap_fifo_base_addr_o[24] <= ifmap_fifo_base_addr_o[25];
            ifmap_fifo_base_addr_o[25] <= ifmap_fifo_base_addr_o[26];
            ifmap_fifo_base_addr_o[26] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        // input channel 10
            ifmap_fifo_base_addr_o[27] <= ifmap_fifo_base_addr_o[28];
            ifmap_fifo_base_addr_o[28] <= ifmap_fifo_base_addr_o[29];
            ifmap_fifo_base_addr_o[29] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        end
    end
    // else if(layer_type_i == `DEPTHWISE && init_fifo_pe_state_i && n_tile_is_last_i)begin
    // end
    else if(layer_type_i == `DEPTHWISE && init_fifo_pe_state_i)begin //todo: not first & not last
            if(output_row_cnt_i == 32'd0) begin
        // input channel 1
            ifmap_fifo_base_addr_o[0] <= ifmap_glb_base_addr_i;
            ifmap_fifo_base_addr_o[1] <= ifmap_glb_base_addr_i + (in_C_i);
            ifmap_fifo_base_addr_o[2] <= ifmap_glb_base_addr_i + 2*(in_C_i);
        // input channel 2
            ifmap_fifo_base_addr_o[3] <= ifmap_glb_base_addr_i + tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[4] <= ifmap_glb_base_addr_i + tile_n_i*(in_C_i) + (in_C_i);
            ifmap_fifo_base_addr_o[5] <= ifmap_glb_base_addr_i + tile_n_i*(in_C_i) + 2*(in_C_i);
        // input channel 3
            ifmap_fifo_base_addr_o[6] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[7] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_C_i) + (in_C_i);
            ifmap_fifo_base_addr_o[8] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_C_i) + 2*(in_C_i);
        // input channel 4
            ifmap_fifo_base_addr_o[9]  <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[10] <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_C_i) + (in_C_i);
            ifmap_fifo_base_addr_o[11] <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_C_i) + 2*(in_C_i);
        // input channel 5
            ifmap_fifo_base_addr_o[12] <= ifmap_glb_base_addr_i + 4*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[13] <= ifmap_glb_base_addr_i + 4*tile_n_i*(in_C_i) + (in_C_i);
            ifmap_fifo_base_addr_o[14] <= ifmap_glb_base_addr_i + 4*tile_n_i*(in_C_i) + 2*(in_C_i);
        // input channel 6
            ifmap_fifo_base_addr_o[15] <= ifmap_glb_base_addr_i + 5*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[16] <= ifmap_glb_base_addr_i + 5*tile_n_i*(in_C_i) + (in_C_i);
            ifmap_fifo_base_addr_o[17] <= ifmap_glb_base_addr_i + 5*tile_n_i*(in_C_i) + 2*(in_C_i);
        // input channel 7
            ifmap_fifo_base_addr_o[18] <= ifmap_glb_base_addr_i + 6*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[19] <= ifmap_glb_base_addr_i + 6*tile_n_i*(in_C_i) + (in_C_i);
            ifmap_fifo_base_addr_o[20] <= ifmap_glb_base_addr_i + 6*tile_n_i*(in_C_i) + 2*(in_C_i);
        // input channel 8
            ifmap_fifo_base_addr_o[21] <= ifmap_glb_base_addr_i + 7*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[22] <= ifmap_glb_base_addr_i + 7*tile_n_i*(in_C_i) + (in_C_i);
            ifmap_fifo_base_addr_o[23] <= ifmap_glb_base_addr_i + 7*tile_n_i*(in_C_i) + 2*(in_C_i);
        // input channel 9
            ifmap_fifo_base_addr_o[24] <= ifmap_glb_base_addr_i + 8*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[25] <= ifmap_glb_base_addr_i + 8*tile_n_i*(in_C_i) + (in_C_i);
            ifmap_fifo_base_addr_o[26] <= ifmap_glb_base_addr_i + 8*tile_n_i*(in_C_i) + 2*(in_C_i);
        // input channel 10
            ifmap_fifo_base_addr_o[27] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_C_i);
            ifmap_fifo_base_addr_o[28] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_C_i) + (in_C_i);
            ifmap_fifo_base_addr_o[29] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_C_i) + 2*(in_C_i);
        end
        else if(output_row_cnt_i > 32'd0) begin
        // input channel 1
            ifmap_fifo_base_addr_o[0] <= ifmap_fifo_base_addr_o[1];
            ifmap_fifo_base_addr_o[1] <= ifmap_fifo_base_addr_o[2];
            ifmap_fifo_base_addr_o[2] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        // input channel 2
            ifmap_fifo_base_addr_o[3] <= ifmap_fifo_base_addr_o[4];
            ifmap_fifo_base_addr_o[4] <= ifmap_fifo_base_addr_o[5];
            ifmap_fifo_base_addr_o[5] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        // input channel 3
            ifmap_fifo_base_addr_o[6] <= ifmap_fifo_base_addr_o[7];
            ifmap_fifo_base_addr_o[7] <= ifmap_fifo_base_addr_o[8];
            ifmap_fifo_base_addr_o[8] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        // input channel 4
            ifmap_fifo_base_addr_o[9]  <= ifmap_fifo_base_addr_o[10];
            ifmap_fifo_base_addr_o[10] <= ifmap_fifo_base_addr_o[11];
            ifmap_fifo_base_addr_o[11] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        // input channel 5
            ifmap_fifo_base_addr_o[12] <= ifmap_fifo_base_addr_o[13];
            ifmap_fifo_base_addr_o[13] <= ifmap_fifo_base_addr_o[14];
            ifmap_fifo_base_addr_o[14] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        // input channel 6
            ifmap_fifo_base_addr_o[15] <= ifmap_fifo_base_addr_o[16];
            ifmap_fifo_base_addr_o[16] <= ifmap_fifo_base_addr_o[17];
            ifmap_fifo_base_addr_o[17] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        // input channel 7
            ifmap_fifo_base_addr_o[18] <= ifmap_fifo_base_addr_o[19];
            ifmap_fifo_base_addr_o[19] <= ifmap_fifo_base_addr_o[20];
            ifmap_fifo_base_addr_o[20] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        // input channel 8
            ifmap_fifo_base_addr_o[21] <= ifmap_fifo_base_addr_o[22];
            ifmap_fifo_base_addr_o[22] <= ifmap_fifo_base_addr_o[23];
            ifmap_fifo_base_addr_o[23] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        // input channel 9
            ifmap_fifo_base_addr_o[24] <= ifmap_fifo_base_addr_o[25];
            ifmap_fifo_base_addr_o[25] <= ifmap_fifo_base_addr_o[26];
            ifmap_fifo_base_addr_o[26] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        // input channel 10
            ifmap_fifo_base_addr_o[27] <= ifmap_fifo_base_addr_o[28];
            ifmap_fifo_base_addr_o[28] <= ifmap_fifo_base_addr_o[29];
            ifmap_fifo_base_addr_o[29] <= ifmap_glb_base_addr_i + (output_row_cnt_i+32'd1)*(in_C_i);
        end

    end

end
integer i1, i2;
// ipsum_glb_base_addr_i
logic [31:0] ipsum_glb_base_addr_i_sel;
assign ipsum_glb_base_addr_i_sel = is_bias_i ? bias_glb_base_addr_i : ipsum_glb_base_addr_i;
always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i1=0; i1<32; i1++)begin
            ipsum_fifo_base_addr_o[i1] <= 32'd0;
        end
    end
    else if (layer_type_i == `POINTWISE && init_fifo_pe_state_i) begin
        for (i1 = 0; i1 < 32; i1++) begin
            ipsum_fifo_base_addr_o[i1] <= ipsum_glb_base_addr_i + i1 * On_real_i*2;
        end
    end
    // else if(layer_type_i == `POINTWISE && init_fifo_pe_state_i)begin
    // // output channel 0
    //     ipsum_fifo_base_addr_o[0] <= ipsum_glb_base_addr_i;
    // // output channel 1
    //     ipsum_fifo_base_addr_o[1] <= ipsum_glb_base_addr_i + On_real_i*2;
    // // output channel 2
    //     ipsum_fifo_base_addr_o[2] <= ipsum_glb_base_addr_i + 2*On_real_i*2;
    // // output channel 3
    //     ipsum_fifo_base_addr_o[3] <= ipsum_glb_base_addr_i + 3*On_real_i*2;
    // // output channel 4
    //     ipsum_fifo_base_addr_o[4] <= ipsum_glb_base_addr_i + 4*On_real_i*2;
    // // output channel 5
    //     ipsum_fifo_base_addr_o[5] <= ipsum_glb_base_addr_i + 5*On_real_i*2;
    // // output channel 31
    //     ipsum_fifo_base_addr_o[31] <= ipsum_glb_base_addr_i + 31*On_real_i*2;
    // end
    else if(layer_type_i == `DEPTHWISE && init_fifo_pe_state_i)begin
    // output channel 0
        ipsum_fifo_base_addr_o[0] <= ipsum_glb_base_addr_i; // row1
        ipsum_fifo_base_addr_o[1] <= ipsum_glb_base_addr_i + in_C_i; // row2
        ipsum_fifo_base_addr_o[2] <= ipsum_glb_base_addr_i + 2*in_C_i; // row3
    // output channel 1
        ipsum_fifo_base_addr_o[3] <= ipsum_glb_base_addr_i + tile_n_i*in_C_i; // row1
        ipsum_fifo_base_addr_o[4] <= ipsum_glb_base_addr_i + tile_n_i*in_C_i + in_C_i; // row2
        ipsum_fifo_base_addr_o[5] <= ipsum_glb_base_addr_i + tile_n_i*in_C_i + 2*in_C_i; // row3
    // output channel 2
        ipsum_fifo_base_addr_o[6] <= ipsum_glb_base_addr_i + 2*tile_n_i*in_C_i;
        ipsum_fifo_base_addr_o[7] <= ipsum_glb_base_addr_i + 2*tile_n_i*in_C_i + in_C_i;
        ipsum_fifo_base_addr_o[8] <= ipsum_glb_base_addr_i + 2*tile_n_i*in_C_i + 2*in_C_i;
    // output channel 3
        ipsum_fifo_base_addr_o[9]  <= ipsum_glb_base_addr_i + 3*tile_n_i*in_C_i;
        ipsum_fifo_base_addr_o[10] <= ipsum_glb_base_addr_i + 3*tile_n_i*in_C_i + in_C_i;
        ipsum_fifo_base_addr_o[11] <= ipsum_glb_base_addr_i + 3*tile_n_i*in_C_i + 2*in_C_i; 
    // output channel 9
        ipsum_fifo_base_addr_o[27]  <= ipsum_glb_base_addr_i + 9*tile_n_i*in_C_i;
        ipsum_fifo_base_addr_o[28] <= ipsum_glb_base_addr_i + 9*tile_n_i*in_C_i + in_C_i;
        ipsum_fifo_base_addr_o[29] <= ipsum_glb_base_addr_i + 9*tile_n_i*in_C_i + 2*in_C_i;       
    end
end

integer j1, j2;

// opsum_glb_base_addr_i
always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(j1=0; j1<32; j1++)begin
            opsum_fifo_base_addr_o[j1] <= 32'd0;
        end
    end
    else if(layer_type_i == `POINTWISE && init_fifo_pe_state_i)begin
    // output channel 0
        opsum_fifo_base_addr_o[0] <= opsum_glb_base_addr_i;
    // output channel 1
        opsum_fifo_base_addr_o[1] <= opsum_glb_base_addr_i + On_real_i*2;
    // output channel 2
        opsum_fifo_base_addr_o[2] <= opsum_glb_base_addr_i + 2*On_real_i*2;
    // output channel 3
        opsum_fifo_base_addr_o[3] <= opsum_glb_base_addr_i + 3*On_real_i*2;
    // output channel 4
        opsum_fifo_base_addr_o[4] <= opsum_glb_base_addr_i + 4*On_real_i*2;
    // output channel 5
        opsum_fifo_base_addr_o[5] <= opsum_glb_base_addr_i + 5*On_real_i*2;
    // output channel 6
        opsum_fifo_base_addr_o[6] <= opsum_glb_base_addr_i + 6*On_real_i*2;
    // output channel 7
        opsum_fifo_base_addr_o[7] <= opsum_glb_base_addr_i + 7*On_real_i*2;
    // output channel 8
        opsum_fifo_base_addr_o[8] <= opsum_glb_base_addr_i + 8*On_real_i*2;
    // output channel 9
        opsum_fifo_base_addr_o[9] <= opsum_glb_base_addr_i + 9*On_real_i*2;
    // output channel 10
        opsum_fifo_base_addr_o[10] <= opsum_glb_base_addr_i + 10*On_real_i*2;
    // output channel 11
        opsum_fifo_base_addr_o[11] <= opsum_glb_base_addr_i + 11*On_real_i*2;
    // output channel 12
        opsum_fifo_base_addr_o[12] <= opsum_glb_base_addr_i + 12*On_real_i*2;
    // output channel 13
        opsum_fifo_base_addr_o[13] <= opsum_glb_base_addr_i +    13*On_real_i*2;
    // output channel 14
        opsum_fifo_base_addr_o[14] <= opsum_glb_base_addr_i +    14*On_real_i*2;
    // output channel 15
        opsum_fifo_base_addr_o[15] <= opsum_glb_base_addr_i +    15*On_real_i*2;
    // output channel 16
        opsum_fifo_base_addr_o[16] <= opsum_glb_base_addr_i +    16*On_real_i*2;
    // output channel 17        
        opsum_fifo_base_addr_o[17] <= opsum_glb_base_addr_i + 17*On_real_i*2;
    // output channel 18
        opsum_fifo_base_addr_o[18] <= opsum_glb_base_addr_i + 18*On_real_i*2;
    // output channel 19
        opsum_fifo_base_addr_o[19] <= opsum_glb_base_addr_i + 19*On_real_i*2;
    // output channel 20
        opsum_fifo_base_addr_o[20] <= opsum_glb_base_addr_i + 20*On_real_i*2;
    // output channel 21
        opsum_fifo_base_addr_o[21] <= opsum_glb_base_addr_i + 21*On_real_i*2;
    // output channel 22
        opsum_fifo_base_addr_o[22] <= opsum_glb_base_addr_i + 22*On_real_i*2;
    // output channel 23
        opsum_fifo_base_addr_o[23] <= opsum_glb_base_addr_i +    23*On_real_i*2;
    // output channel 24
        opsum_fifo_base_addr_o[24] <= opsum_glb_base_addr_i + 24*On_real_i*2;
    // output channel 25
        opsum_fifo_base_addr_o[25] <= opsum_glb_base_addr_i + 25*On_real_i*2;
    // output channel 26
        opsum_fifo_base_addr_o[26] <= opsum_glb_base_addr_i + 26*On_real_i*2;
    // output channel 27
        opsum_fifo_base_addr_o[27] <= opsum_glb_base_addr_i + 27*On_real_i*2;
    // output channel 28
        opsum_fifo_base_addr_o[28] <= opsum_glb_base_addr_i + 28*On_real_i*2;
    // output channel 29    
        opsum_fifo_base_addr_o[29] <= opsum_glb_base_addr_i + 29*On_real_i*2;
    // output channel 30
        opsum_fifo_base_addr_o[30] <= opsum_glb_base_addr_i + 30*On_real_i*2;
    // output channel 31
        opsum_fifo_base_addr_o[31] <= opsum_glb_base_addr_i + 31*On_real_i*2;
    end
    else if(layer_type_i == `DEPTHWISE && init_fifo_pe_state_i)begin
    // output channel 0
        opsum_fifo_base_addr_o[0] <= opsum_glb_base_addr_i; // row1
        opsum_fifo_base_addr_o[1] <= opsum_glb_base_addr_i + in_C_i; // row2
        opsum_fifo_base_addr_o[2] <= opsum_glb_base_addr_i + 2*in_C_i; // row3
    // output channel 1
        opsum_fifo_base_addr_o[3] <= opsum_glb_base_addr_i + On_real_i*in_C_i; // row1
        opsum_fifo_base_addr_o[4] <= opsum_glb_base_addr_i + On_real_i*in_C_i + in_C_i; // row2
        opsum_fifo_base_addr_o[5] <= opsum_glb_base_addr_i + On_real_i*in_C_i + 2*in_C_i; // row3
    // output channel 2
        opsum_fifo_base_addr_o[6] <= opsum_glb_base_addr_i + 2*On_real_i*in_C_i;
        opsum_fifo_base_addr_o[7] <= opsum_glb_base_addr_i + 2*On_real_i*in_C_i + in_C_i;
        opsum_fifo_base_addr_o[8] <= opsum_glb_base_addr_i + 2*On_real_i*in_C_i + 2*in_C_i;
    // output channel 3
        opsum_fifo_base_addr_o[9]  <= opsum_glb_base_addr_i + 3*On_real_i*in_C_i;
        opsum_fifo_base_addr_o[10] <= opsum_glb_base_addr_i + 3*On_real_i*in_C_i + in_C_i;
        opsum_fifo_base_addr_o[11] <= opsum_glb_base_addr_i + 3*On_real_i*in_C_i + 2*in_C_i; 
    // output channel 9
        opsum_fifo_base_addr_o[27]  <= opsum_glb_base_addr_i + 9*On_real_i*in_C_i;
        opsum_fifo_base_addr_o[28] <= opsum_glb_base_addr_i + 9*On_real_i*in_C_i + in_C_i;
        opsum_fifo_base_addr_o[29] <= opsum_glb_base_addr_i + 9*On_real_i*in_C_i + 2*in_C_i;       
    end
end





endmodule
