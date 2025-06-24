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
    input logic [7:0] Already_Compute_Row_i,
    input logic [31:0] output_row_cnt_i,
    input logic n_tile_is_first_i, // 是否為第一個 tile
    input logic n_tile_is_last_i, // 是否為最後一個 tile
    input logic [1:0] stride_i,
    
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
    input logic [7:0] out_R_i,


    output logic [31:0] ifmap_fifo_base_addr_o [31:0],
    output logic [31:0] ipsum_fifo_base_addr_o [31:0],
    output logic [31:0] opsum_fifo_base_addr_o [31:0],

    output logic ifmap_fifo_reset_o, // reset signal for all ifmap FIFO
    output logic ipsum_fifo_reset_o, // reset signal for all ipsum FIFO
    output logic opsum_fifo_reset_o  // reset signal for all opsum FIFO
);


logic [31:0] current_compute_output_row;
assign current_compute_output_row = output_row_cnt_i + Already_Compute_Row_i;



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



//* ====================== ifmap_glb_base_addr_i ======================
integer i, j, k, r, t;
integer n;
always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i=0; i<32; i++)begin
            ifmap_fifo_base_addr_o[i] <= 32'd0;
        end
    end
    else if(layer_type_i == `POINTWISE && init_fifo_pe_state_i)begin
        ifmap_fifo_base_addr_o[0] <= ifmap_glb_base_addr_i;
        ifmap_fifo_base_addr_o[1] <= ifmap_glb_base_addr_i + tile_n_i;
        ifmap_fifo_base_addr_o[2] <= ifmap_glb_base_addr_i + 2*tile_n_i;
        ifmap_fifo_base_addr_o[3] <= ifmap_glb_base_addr_i + 3*tile_n_i;
        ifmap_fifo_base_addr_o[4] <= ifmap_glb_base_addr_i + 4*tile_n_i;
        ifmap_fifo_base_addr_o[5] <= ifmap_glb_base_addr_i + 5*tile_n_i;
        ifmap_fifo_base_addr_o[6] <= ifmap_glb_base_addr_i + 6*tile_n_i;
        ifmap_fifo_base_addr_o[7] <= ifmap_glb_base_addr_i + 7*tile_n_i;
        ifmap_fifo_base_addr_o[8] <= ifmap_glb_base_addr_i + 8*tile_n_i;
        ifmap_fifo_base_addr_o[9] <= ifmap_glb_base_addr_i + 9*tile_n_i;
        ifmap_fifo_base_addr_o[10] <= ifmap_glb_base_addr_i + 10*tile_n_i;
        ifmap_fifo_base_addr_o[11] <= ifmap_glb_base_addr_i + 11*tile_n_i;
        ifmap_fifo_base_addr_o[12] <= ifmap_glb_base_addr_i + 12*tile_n_i;
        ifmap_fifo_base_addr_o[13] <= ifmap_glb_base_addr_i + 13*tile_n_i;
        ifmap_fifo_base_addr_o[14] <= ifmap_glb_base_addr_i + 14*tile_n_i;
        ifmap_fifo_base_addr_o[15] <= ifmap_glb_base_addr_i + 15*tile_n_i;
        ifmap_fifo_base_addr_o[16] <= ifmap_glb_base_addr_i + 16*tile_n_i;
        ifmap_fifo_base_addr_o[17] <= ifmap_glb_base_addr_i + 17*tile_n_i;
        ifmap_fifo_base_addr_o[18] <= ifmap_glb_base_addr_i + 18*tile_n_i;
        ifmap_fifo_base_addr_o[19] <= ifmap_glb_base_addr_i + 19*tile_n_i;
        ifmap_fifo_base_addr_o[20] <= ifmap_glb_base_addr_i + 20*tile_n_i;
        ifmap_fifo_base_addr_o[21] <= ifmap_glb_base_addr_i + 21*tile_n_i;
        ifmap_fifo_base_addr_o[22] <= ifmap_glb_base_addr_i + 22*tile_n_i;
        ifmap_fifo_base_addr_o[23] <= ifmap_glb_base_addr_i + 23*tile_n_i;
        ifmap_fifo_base_addr_o[24] <= ifmap_glb_base_addr_i + 24*tile_n_i;
        ifmap_fifo_base_addr_o[25] <= ifmap_glb_base_addr_i + 25*tile_n_i;
        ifmap_fifo_base_addr_o[26] <= ifmap_glb_base_addr_i + 26*tile_n_i;
        ifmap_fifo_base_addr_o[27] <= ifmap_glb_base_addr_i + 27*tile_n_i;
        ifmap_fifo_base_addr_o[28] <= ifmap_glb_base_addr_i + 28*tile_n_i;
        ifmap_fifo_base_addr_o[29] <= ifmap_glb_base_addr_i + 29*tile_n_i;
        ifmap_fifo_base_addr_o[30] <= ifmap_glb_base_addr_i + 30*tile_n_i;
        ifmap_fifo_base_addr_o[31] <= ifmap_glb_base_addr_i + 31*tile_n_i;
    end
    else if(layer_type_i == `DEPTHWISE && init_fifo_pe_state_i && (stride_i == 2'd1))begin
        if(n_tile_is_first_i) begin // First Tile
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
            else if(output_row_cnt_i > 32'd1) begin // after pad row, it is regular
                for(k=0; k<31; k++)begin
                    ifmap_fifo_base_addr_o[k] <= ifmap_fifo_base_addr_o[k] + in_C_i;
                end
            end
        end
        else if(n_tile_is_last_i)begin // Last Tile
            if((output_row_cnt_i == 32'd0) && (current_compute_output_row == out_R_i) )begin // initial 
                // input channel 1 // output_row_cnt_i == 0
                ifmap_fifo_base_addr_o[0] <= ifmap_glb_base_addr_i;
                ifmap_fifo_base_addr_o[1] <= ifmap_glb_base_addr_i + in_C_i;
                ifmap_fifo_base_addr_o[2] <= `ZERO_ZONE;
                // input channel 2
                ifmap_fifo_base_addr_o[3] <= ifmap_glb_base_addr_i + tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[4] <= ifmap_glb_base_addr_i + tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[5] <= `ZERO_ZONE;
                // input channel 3 
                ifmap_fifo_base_addr_o[6] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[7] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[8] <= `ZERO_ZONE;
                // input channel 4
                ifmap_fifo_base_addr_o[9]  <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[10] <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[11] <= `ZERO_ZONE;
                // input channel 5
                ifmap_fifo_base_addr_o[12] <= ifmap_glb_base_addr_i + 4*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[13] <= ifmap_glb_base_addr_i + 4*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[14] <= `ZERO_ZONE;
                // input channel 6
                ifmap_fifo_base_addr_o[15] <= ifmap_glb_base_addr_i + 5*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[16] <= ifmap_glb_base_addr_i + 5*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[17] <= `ZERO_ZONE;
                // input channel 7
                ifmap_fifo_base_addr_o[18] <= ifmap_glb_base_addr_i + 6*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[19] <= ifmap_glb_base_addr_i + 6*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[20] <= `ZERO_ZONE;
                // input channel 8
                ifmap_fifo_base_addr_o[21] <= ifmap_glb_base_addr_i + 7*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[22] <= ifmap_glb_base_addr_i + 7*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[23] <= `ZERO_ZONE;
                // input channel 9
                ifmap_fifo_base_addr_o[24] <= ifmap_glb_base_addr_i + 8*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[25] <= ifmap_glb_base_addr_i + 8*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[26] <= `ZERO_ZONE;
                // input channel 10
                ifmap_fifo_base_addr_o[27] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[28] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[29] <= `ZERO_ZONE;
            end
            else if(output_row_cnt_i == 32'd0)begin // initial 
                // input channel 1 // output_row_cnt_i == 0
                ifmap_fifo_base_addr_o[0] <= ifmap_glb_base_addr_i;
                ifmap_fifo_base_addr_o[1] <= ifmap_glb_base_addr_i + in_C_i;
                ifmap_fifo_base_addr_o[2] <= ifmap_glb_base_addr_i + 2*in_C_i;
                // input channel 2
                ifmap_fifo_base_addr_o[3] <= ifmap_glb_base_addr_i + tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[4] <= ifmap_glb_base_addr_i + tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[5] <= ifmap_glb_base_addr_i + tile_n_i*(in_C_i) + 2*in_C_i;
                // input channel 3 
                ifmap_fifo_base_addr_o[6] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[7] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[8] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_C_i) + 2*in_C_i;
                // input channel 4
                ifmap_fifo_base_addr_o[9]  <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[10] <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[11] <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_C_i) + 2*in_C_i;
                // input channel 5
                ifmap_fifo_base_addr_o[12] <= ifmap_glb_base_addr_i + 4*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[13] <= ifmap_glb_base_addr_i + 4*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[14] <= ifmap_glb_base_addr_i + 4*tile_n_i*(in_C_i) + 2*in_C_i;
                // input channel 6
                ifmap_fifo_base_addr_o[15] <= ifmap_glb_base_addr_i + 5*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[16] <= ifmap_glb_base_addr_i + 5*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[17] <= ifmap_glb_base_addr_i + 5*tile_n_i*(in_C_i) + 2*in_C_i;
                // input channel 7
                ifmap_fifo_base_addr_o[18] <= ifmap_glb_base_addr_i + 6*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[19] <= ifmap_glb_base_addr_i + 6*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[20] <= ifmap_glb_base_addr_i + 6*tile_n_i*(in_C_i) + 2*in_C_i;
                // input channel 8
                ifmap_fifo_base_addr_o[21] <= ifmap_glb_base_addr_i + 7*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[22] <= ifmap_glb_base_addr_i + 7*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[23] <= ifmap_glb_base_addr_i + 7*tile_n_i*(in_C_i) + 2*in_C_i;
                // input channel 9
                ifmap_fifo_base_addr_o[24] <= ifmap_glb_base_addr_i + 8*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[25] <= ifmap_glb_base_addr_i + 8*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[26] <= ifmap_glb_base_addr_i + 8*tile_n_i*(in_C_i) + 2*in_C_i;
                // input channel 10
                ifmap_fifo_base_addr_o[27] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[28] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[29] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_C_i) + 2*in_C_i;
            end
            else if(current_compute_output_row == out_R_i)begin
                // input channel 1 // output_row_cnt_i == 0
                ifmap_fifo_base_addr_o[0] <= ifmap_fifo_base_addr_o[0] + in_C_i;
                ifmap_fifo_base_addr_o[1] <= ifmap_fifo_base_addr_o[1] + in_C_i;
                ifmap_fifo_base_addr_o[2] <= `ZERO_ZONE;
                // input channel 2
                ifmap_fifo_base_addr_o[3] <= ifmap_fifo_base_addr_o[3] + in_C_i;
                ifmap_fifo_base_addr_o[4] <= ifmap_fifo_base_addr_o[4] + in_C_i;
                ifmap_fifo_base_addr_o[5] <= `ZERO_ZONE;
                // input channel 3
                ifmap_fifo_base_addr_o[6] <= ifmap_fifo_base_addr_o[6] + in_C_i;
                ifmap_fifo_base_addr_o[7] <= ifmap_fifo_base_addr_o[7] + in_C_i;
                ifmap_fifo_base_addr_o[8] <= `ZERO_ZONE;
                // input channel 4
                ifmap_fifo_base_addr_o[9]  <= ifmap_fifo_base_addr_o[9] + in_C_i;
                ifmap_fifo_base_addr_o[10] <= ifmap_fifo_base_addr_o[10] + in_C_i;
                ifmap_fifo_base_addr_o[11] <= `ZERO_ZONE;
                // input channel 5
                ifmap_fifo_base_addr_o[12] <= ifmap_fifo_base_addr_o[12] + in_C_i;
                ifmap_fifo_base_addr_o[13] <= ifmap_fifo_base_addr_o[13] + in_C_i;
                ifmap_fifo_base_addr_o[14] <= `ZERO_ZONE;
                // input channel 6
                ifmap_fifo_base_addr_o[15] <= ifmap_fifo_base_addr_o[15] + in_C_i;
                ifmap_fifo_base_addr_o[16] <= ifmap_fifo_base_addr_o[16] + in_C_i;
                ifmap_fifo_base_addr_o[17] <= `ZERO_ZONE;
                // input channel 7
                ifmap_fifo_base_addr_o[18] <= ifmap_fifo_base_addr_o[18] + in_C_i;
                ifmap_fifo_base_addr_o[19] <= ifmap_fifo_base_addr_o[19] + in_C_i;
                ifmap_fifo_base_addr_o[20] <= `ZERO_ZONE;
                // input channel 8
                ifmap_fifo_base_addr_o[21] <= ifmap_fifo_base_addr_o[21] + in_C_i;
                ifmap_fifo_base_addr_o[22] <= ifmap_fifo_base_addr_o[22] + in_C_i;
                ifmap_fifo_base_addr_o[23] <= `ZERO_ZONE;
                // input channel 9
                ifmap_fifo_base_addr_o[24] <= ifmap_fifo_base_addr_o[24] + in_C_i;
                ifmap_fifo_base_addr_o[25] <= ifmap_fifo_base_addr_o[25] + in_C_i;
                ifmap_fifo_base_addr_o[26] <= `ZERO_ZONE;
                // input channel 10
                ifmap_fifo_base_addr_o[27] <= ifmap_fifo_base_addr_o[27] + in_C_i;
                ifmap_fifo_base_addr_o[28] <= ifmap_fifo_base_addr_o[28] + in_C_i;
                ifmap_fifo_base_addr_o[29] <= `ZERO_ZONE;
            end
            else begin // after initial row, it is regular
                for(k=0; k<31; k++)begin
                    ifmap_fifo_base_addr_o[k] <= ifmap_fifo_base_addr_o[k] + in_C_i;
                end
            end
        end
        else begin // Common Row
            if(output_row_cnt_i == 32'd0)begin // initial 
                // input channel 1 // output_row_cnt_i == 0
                ifmap_fifo_base_addr_o[0] <= ifmap_glb_base_addr_i;
                ifmap_fifo_base_addr_o[1] <= ifmap_glb_base_addr_i + in_C_i;
                ifmap_fifo_base_addr_o[2] <= ifmap_glb_base_addr_i + 2*in_C_i;
                // input channel 2
                ifmap_fifo_base_addr_o[3] <= ifmap_glb_base_addr_i + tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[4] <= ifmap_glb_base_addr_i + tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[5] <= ifmap_glb_base_addr_i + tile_n_i*(in_C_i) + 2*in_C_i;
                // input channel 3 
                ifmap_fifo_base_addr_o[6] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[7] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[8] <= ifmap_glb_base_addr_i + 2*tile_n_i*(in_C_i) + 2*in_C_i;
                // input channel 4
                ifmap_fifo_base_addr_o[9]  <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[10] <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[11] <= ifmap_glb_base_addr_i + 3*tile_n_i*(in_C_i) + 2*in_C_i;
                // input channel 5
                ifmap_fifo_base_addr_o[12] <= ifmap_glb_base_addr_i + 4*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[13] <= ifmap_glb_base_addr_i + 4*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[14] <= ifmap_glb_base_addr_i + 4*tile_n_i*(in_C_i) + 2*in_C_i;
                // input channel 6
                ifmap_fifo_base_addr_o[15] <= ifmap_glb_base_addr_i + 5*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[16] <= ifmap_glb_base_addr_i + 5*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[17] <= ifmap_glb_base_addr_i + 5*tile_n_i*(in_C_i) + 2*in_C_i;
                // input channel 7
                ifmap_fifo_base_addr_o[18] <= ifmap_glb_base_addr_i + 6*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[19] <= ifmap_glb_base_addr_i + 6*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[20] <= ifmap_glb_base_addr_i + 6*tile_n_i*(in_C_i) + 2*in_C_i;
                // input channel 8
                ifmap_fifo_base_addr_o[21] <= ifmap_glb_base_addr_i + 7*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[22] <= ifmap_glb_base_addr_i + 7*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[23] <= ifmap_glb_base_addr_i + 7*tile_n_i*(in_C_i) + 2*in_C_i;
                // input channel 9
                ifmap_fifo_base_addr_o[24] <= ifmap_glb_base_addr_i + 8*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[25] <= ifmap_glb_base_addr_i + 8*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[26] <= ifmap_glb_base_addr_i + 8*tile_n_i*(in_C_i) + 2*in_C_i;
                // input channel 10
                ifmap_fifo_base_addr_o[27] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_C_i);
                ifmap_fifo_base_addr_o[28] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_C_i) + in_C_i;
                ifmap_fifo_base_addr_o[29] <= ifmap_glb_base_addr_i + 9*tile_n_i*(in_C_i) + 2*in_C_i;
            end
            else begin // after initial row, it is regular
                for(k=0; k<31; k++)begin
                    ifmap_fifo_base_addr_o[k] <= ifmap_fifo_base_addr_o[k] + in_C_i;
                end
            end
        end
    end
    else if(layer_type_i == `DEPTHWISE && init_fifo_pe_state_i && (stride_i == 2'd2))begin
        if(n_tile_is_first_i) begin // First Tile
            if(output_row_cnt_i == 32'd0) begin    
                // input channel 1
                ifmap_fifo_base_addr_o[0] <= `ZERO_ZONE;
                ifmap_fifo_base_addr_o[1] <= ifmap_glb_base_addr_i;
                ifmap_fifo_base_addr_o[2] <= ifmap_glb_base_addr_i + in_C_i;
                // input channel 2
                ifmap_fifo_base_addr_o[3] <= `ZERO_ZONE;
                ifmap_fifo_base_addr_o[4] <= ifmap_glb_base_addr_i + tile_n_i*in_C_i;
                ifmap_fifo_base_addr_o[5] <= ifmap_glb_base_addr_i + tile_n_i*in_C_i + in_C_i;
                // input channel 3 
                ifmap_fifo_base_addr_o[6] <= `ZERO_ZONE;
                ifmap_fifo_base_addr_o[7] <= ifmap_glb_base_addr_i + 2*tile_n_i*in_C_i;
                ifmap_fifo_base_addr_o[8] <= ifmap_glb_base_addr_i + 2*tile_n_i*in_C_i + in_C_i;
                // input channel 4
                ifmap_fifo_base_addr_o[9]  <= `ZERO_ZONE;
                ifmap_fifo_base_addr_o[10] <= ifmap_glb_base_addr_i + 3*tile_n_i*in_C_i;
                ifmap_fifo_base_addr_o[11] <= ifmap_glb_base_addr_i + 3*tile_n_i*in_C_i + in_C_i;
                // input channel 5
                ifmap_fifo_base_addr_o[12] <= `ZERO_ZONE;
                ifmap_fifo_base_addr_o[13] <= ifmap_glb_base_addr_i + 4*tile_n_i*in_C_i;
                ifmap_fifo_base_addr_o[14] <= ifmap_glb_base_addr_i + 4*tile_n_i*in_C_i + in_C_i;
                // input channel 6
                ifmap_fifo_base_addr_o[15] <= `ZERO_ZONE;
                ifmap_fifo_base_addr_o[16] <= ifmap_glb_base_addr_i + 5*tile_n_i*in_C_i;
                ifmap_fifo_base_addr_o[17] <= ifmap_glb_base_addr_i + 5*tile_n_i*in_C_i + in_C_i;
                // input channel 7
                ifmap_fifo_base_addr_o[18] <= `ZERO_ZONE;
                ifmap_fifo_base_addr_o[19] <= ifmap_glb_base_addr_i + 6*tile_n_i*in_C_i;
                ifmap_fifo_base_addr_o[20] <= ifmap_glb_base_addr_i + 6*tile_n_i*in_C_i + in_C_i;
                // input channel 8
                ifmap_fifo_base_addr_o[21] <= `ZERO_ZONE;
                ifmap_fifo_base_addr_o[22] <= ifmap_glb_base_addr_i + 7*tile_n_i*in_C_i;
                ifmap_fifo_base_addr_o[23] <= ifmap_glb_base_addr_i + 7*tile_n_i*in_C_i + in_C_i;
                // input channel 9
                ifmap_fifo_base_addr_o[24] <= `ZERO_ZONE;
                ifmap_fifo_base_addr_o[25] <= ifmap_glb_base_addr_i + 8*tile_n_i*in_C_i;
                ifmap_fifo_base_addr_o[26] <= ifmap_glb_base_addr_i + 8*tile_n_i*in_C_i + in_C_i;
                // input channel 10
                ifmap_fifo_base_addr_o[27] <= `ZERO_ZONE;
                ifmap_fifo_base_addr_o[28] <= ifmap_glb_base_addr_i + 9*tile_n_i*in_C_i;
                ifmap_fifo_base_addr_o[29] <= ifmap_glb_base_addr_i + 9*tile_n_i*in_C_i + in_C_i;
            end
            else if(output_row_cnt_i == 32'd1) begin
                // input channel 1
                ifmap_fifo_base_addr_o[0] <= ifmap_glb_base_addr_i + 1*in_C_i;
                ifmap_fifo_base_addr_o[1] <= ifmap_glb_base_addr_i + 2*in_C_i;
                ifmap_fifo_base_addr_o[2] <= ifmap_glb_base_addr_i + 3*in_C_i;
                // input channel 2
                ifmap_fifo_base_addr_o[3] <= ifmap_glb_base_addr_i + tile_n_i*in_C_i + 1*in_C_i;
                ifmap_fifo_base_addr_o[4] <= ifmap_glb_base_addr_i + tile_n_i*in_C_i + 2*in_C_i;
                ifmap_fifo_base_addr_o[5] <= ifmap_glb_base_addr_i + tile_n_i*in_C_i + 3*in_C_i;
                // input channel 3
                ifmap_fifo_base_addr_o[6] <= ifmap_glb_base_addr_i + 2*tile_n_i*in_C_i + 1*in_C_i;
                ifmap_fifo_base_addr_o[7] <= ifmap_glb_base_addr_i + 2*tile_n_i*in_C_i + 2*in_C_i;
                ifmap_fifo_base_addr_o[8] <= ifmap_glb_base_addr_i + 2*tile_n_i*in_C_i + 3*in_C_i;
                // input channel 4
                ifmap_fifo_base_addr_o[9]  <= ifmap_glb_base_addr_i + 3*tile_n_i*in_C_i + 1*in_C_i;
                ifmap_fifo_base_addr_o[10] <= ifmap_glb_base_addr_i + 3*tile_n_i*in_C_i + 2*in_C_i;
                ifmap_fifo_base_addr_o[11] <= ifmap_glb_base_addr_i + 3*tile_n_i*in_C_i + 3*in_C_i;
                // input channel 5
                ifmap_fifo_base_addr_o[12] <= ifmap_glb_base_addr_i + 4*tile_n_i*in_C_i + 1*in_C_i;
                ifmap_fifo_base_addr_o[13] <= ifmap_glb_base_addr_i + 4*tile_n_i*in_C_i + 2*in_C_i;
                ifmap_fifo_base_addr_o[14] <= ifmap_glb_base_addr_i + 4*tile_n_i*in_C_i + 3*in_C_i;
                // input channel 6
                ifmap_fifo_base_addr_o[15] <= ifmap_glb_base_addr_i + 5*tile_n_i*in_C_i + 1*in_C_i;
                ifmap_fifo_base_addr_o[16] <= ifmap_glb_base_addr_i + 5*tile_n_i*in_C_i + 2*in_C_i;
                ifmap_fifo_base_addr_o[17] <= ifmap_glb_base_addr_i + 5*tile_n_i*in_C_i + 3*in_C_i;
                // input channel 7
                ifmap_fifo_base_addr_o[18] <= ifmap_glb_base_addr_i + 6*tile_n_i*in_C_i + 1*in_C_i;
                ifmap_fifo_base_addr_o[19] <= ifmap_glb_base_addr_i + 6*tile_n_i*in_C_i + 2*in_C_i;
                ifmap_fifo_base_addr_o[20] <= ifmap_glb_base_addr_i + 6*tile_n_i*in_C_i + 3*in_C_i;
                // input channel 8
                ifmap_fifo_base_addr_o[21] <= ifmap_glb_base_addr_i + 7*tile_n_i*in_C_i + 1*in_C_i;
                ifmap_fifo_base_addr_o[22] <= ifmap_glb_base_addr_i + 7*tile_n_i*in_C_i + 2*in_C_i;
                ifmap_fifo_base_addr_o[23] <= ifmap_glb_base_addr_i + 7*tile_n_i*in_C_i + 3*in_C_i;
                // input channel 9
                ifmap_fifo_base_addr_o[24] <= ifmap_glb_base_addr_i + 8*tile_n_i*in_C_i + 1*in_C_i;
                ifmap_fifo_base_addr_o[25] <= ifmap_glb_base_addr_i + 8*tile_n_i*in_C_i + 2*in_C_i;
                ifmap_fifo_base_addr_o[26] <= ifmap_glb_base_addr_i + 8*tile_n_i*in_C_i + 3*in_C_i;
                // input channel 10
                ifmap_fifo_base_addr_o[27] <= ifmap_glb_base_addr_i + 9*tile_n_i*in_C_i + 1*in_C_i;
                ifmap_fifo_base_addr_o[28] <= ifmap_glb_base_addr_i + 9*tile_n_i*in_C_i + 2*in_C_i;
                ifmap_fifo_base_addr_o[29] <= ifmap_glb_base_addr_i + 9*tile_n_i*in_C_i + 3*in_C_i;
            end
            else if(output_row_cnt_i > 32'd1) begin // after pad row, it is regular
                for(k=0; k<30; k=k+1)begin
                    ifmap_fifo_base_addr_o[k] <= ifmap_fifo_base_addr_o[k] + 2*in_C_i;
                end
            end
        end
        else if(n_tile_is_last_i)begin // Last Tile
            if((output_row_cnt_i == 32'd0) && (current_compute_output_row == out_R_i))begin // initial 
                // input channel 1
                ifmap_fifo_base_addr_o[0] <= ifmap_glb_base_addr_i + (out_R_i-1)*2*in_C_i;
                ifmap_fifo_base_addr_o[1] <= ifmap_glb_base_addr_i + ((out_R_i-1)*2+1)*in_C_i;
                ifmap_fifo_base_addr_o[2] <= `ZERO_ZONE;
                // input channel 2
                ifmap_fifo_base_addr_o[3] <= ifmap_glb_base_addr_i + tile_n_i*in_C_i + (out_R_i-1)*2*in_C_i;
                ifmap_fifo_base_addr_o[4] <= ifmap_glb_base_addr_i + tile_n_i*in_C_i + ((out_R_i-1)*2+1)*in_C_i;
                ifmap_fifo_base_addr_o[5] <= `ZERO_ZONE;
                // input channel 3 
                ifmap_fifo_base_addr_o[6] <= ifmap_glb_base_addr_i + 2*tile_n_i*in_C_i + (out_R_i-1)*2*in_C_i;
                ifmap_fifo_base_addr_o[7] <= ifmap_glb_base_addr_i + 2*tile_n_i*in_C_i + ((out_R_i-1)*2+1)*in_C_i;
                ifmap_fifo_base_addr_o[8] <= `ZERO_ZONE;
                // input channel 4
                ifmap_fifo_base_addr_o[9]  <= ifmap_glb_base_addr_i + 3*tile_n_i*in_C_i + (out_R_i-1)*2*in_C_i;
                ifmap_fifo_base_addr_o[10] <= ifmap_glb_base_addr_i + 3*tile_n_i*in_C_i + ((out_R_i-1)*2+1)*in_C_i;
                ifmap_fifo_base_addr_o[11] <= `ZERO_ZONE;
                // input channel 5
                ifmap_fifo_base_addr_o[12] <= ifmap_glb_base_addr_i + 4*tile_n_i*in_C_i + (out_R_i-1)*2*in_C_i;
                ifmap_fifo_base_addr_o[13] <= ifmap_glb_base_addr_i + 4*tile_n_i*in_C_i + ((out_R_i-1)*2+1)*in_C_i;
                ifmap_fifo_base_addr_o[14] <= `ZERO_ZONE;
                // input channel 6
                ifmap_fifo_base_addr_o[15] <= ifmap_glb_base_addr_i + 5*tile_n_i*in_C_i + (out_R_i-1)*2*in_C_i;
                ifmap_fifo_base_addr_o[16] <= ifmap_glb_base_addr_i + 5*tile_n_i*in_C_i + ((out_R_i-1)*2+1)*in_C_i;
                ifmap_fifo_base_addr_o[17] <= `ZERO_ZONE;
                // input channel 7
                ifmap_fifo_base_addr_o[18] <= ifmap_glb_base_addr_i + 6*tile_n_i*in_C_i + (out_R_i-1)*2*in_C_i;
                ifmap_fifo_base_addr_o[19] <= ifmap_glb_base_addr_i + 6*tile_n_i*in_C_i + ((out_R_i-1)*2+1)*in_C_i;
                ifmap_fifo_base_addr_o[20] <= `ZERO_ZONE;
                // input channel 8
                ifmap_fifo_base_addr_o[21] <= ifmap_glb_base_addr_i + 7*tile_n_i*in_C_i + (out_R_i-1)*2*in_C_i;
                ifmap_fifo_base_addr_o[22] <= ifmap_glb_base_addr_i + 7*tile_n_i*in_C_i + ((out_R_i-1)*2+1)*in_C_i;
                ifmap_fifo_base_addr_o[23] <= `ZERO_ZONE;
                // input channel 9
                ifmap_fifo_base_addr_o[24] <= ifmap_glb_base_addr_i + 8*tile_n_i*in_C_i + (out_R_i-1)*2*in_C_i;
                ifmap_fifo_base_addr_o[25] <= ifmap_glb_base_addr_i + 8*tile_n_i*in_C_i + ((out_R_i-1)*2+1)*in_C_i;
                ifmap_fifo_base_addr_o[26] <= `ZERO_ZONE;
                // input channel 10
                ifmap_fifo_base_addr_o[27] <= ifmap_glb_base_addr_i + 9*tile_n_i*in_C_i + (out_R_i-1)*2*in_C_i;
                ifmap_fifo_base_addr_o[28] <= ifmap_glb_base_addr_i + 9*tile_n_i*in_C_i + ((out_R_i-1)*2+1)*in_C_i;
                ifmap_fifo_base_addr_o[29] <= `ZERO_ZONE;
            end
            else if(output_row_cnt_i == 32'd0)begin // initial 
                // input channel 1
                ifmap_fifo_base_addr_o[0] <= ifmap_glb_base_addr_i;
                ifmap_fifo_base_addr_o[1] <= ifmap_glb_base_addr_i + in_C_i;
                ifmap_fifo_base_addr_o[2] <= ifmap_glb_base_addr_i + 2*in_C_i;
                // input channel 2
                ifmap_fifo_base_addr_o[3] <= ifmap_glb_base_addr_i + tile_n_i*in_C_i;
                ifmap_fifo_base_addr_o[4] <= ifmap_glb_base_addr_i + tile_n_i*in_C_i + in_C_i;
                ifmap_fifo_base_addr_o[5] <= ifmap_glb_base_addr_i + tile_n_i*in_C_i + 2*in_C_i;
                // input channel 3 
                ifmap_fifo_base_addr_o[6] <= ifmap_glb_base_addr_i + 2*tile_n_i*in_C_i;
                ifmap_fifo_base_addr_o[7] <= ifmap_glb_base_addr_i + 2*tile_n_i*in_C_i + in_C_i;
                ifmap_fifo_base_addr_o[8] <= ifmap_glb_base_addr_i + 2*tile_n_i*in_C_i + 2*in_C_i;
                // input channel 4
                ifmap_fifo_base_addr_o[9]  <= ifmap_glb_base_addr_i + 3*tile_n_i*in_C_i;
                ifmap_fifo_base_addr_o[10] <= ifmap_glb_base_addr_i + 3*tile_n_i*in_C_i + in_C_i;
                ifmap_fifo_base_addr_o[11] <= ifmap_glb_base_addr_i + 3*tile_n_i*in_C_i + 2*in_C_i;
                // input channel 5
                ifmap_fifo_base_addr_o[12] <= ifmap_glb_base_addr_i + 4*tile_n_i*in_C_i;
                ifmap_fifo_base_addr_o[13] <= ifmap_glb_base_addr_i + 4*tile_n_i*in_C_i + in_C_i;
                ifmap_fifo_base_addr_o[14] <= ifmap_glb_base_addr_i + 4*tile_n_i*in_C_i + 2*in_C_i;
                // input channel 6
                ifmap_fifo_base_addr_o[15] <= ifmap_glb_base_addr_i + 5*tile_n_i*in_C_i;
                ifmap_fifo_base_addr_o[16] <= ifmap_glb_base_addr_i + 5*tile_n_i*in_C_i + in_C_i;
                ifmap_fifo_base_addr_o[17] <= ifmap_glb_base_addr_i + 5*tile_n_i*in_C_i + 2*in_C_i;
                // input channel 7
                ifmap_fifo_base_addr_o[18] <= ifmap_glb_base_addr_i + 6*tile_n_i*in_C_i;
                ifmap_fifo_base_addr_o[19] <= ifmap_glb_base_addr_i + 6*tile_n_i*in_C_i + in_C_i;
                ifmap_fifo_base_addr_o[20] <= ifmap_glb_base_addr_i + 6*tile_n_i*in_C_i + 2*in_C_i;
                // input channel 8
                ifmap_fifo_base_addr_o[21] <= ifmap_glb_base_addr_i + 7*tile_n_i*in_C_i;
                ifmap_fifo_base_addr_o[22] <= ifmap_glb_base_addr_i + 7*tile_n_i*in_C_i + in_C_i;
                ifmap_fifo_base_addr_o[23] <= ifmap_glb_base_addr_i + 7*tile_n_i*in_C_i + 2*in_C_i;
                // input channel 9
                ifmap_fifo_base_addr_o[24] <= ifmap_glb_base_addr_i + 8*tile_n_i*in_C_i;
                ifmap_fifo_base_addr_o[25] <= ifmap_glb_base_addr_i + 8*tile_n_i*in_C_i + in_C_i;
                ifmap_fifo_base_addr_o[26] <= ifmap_glb_base_addr_i + 8*tile_n_i*in_C_i + 2*in_C_i;
                // input channel 10
                ifmap_fifo_base_addr_o[27] <= ifmap_glb_base_addr_i + 9*tile_n_i*in_C_i;
                ifmap_fifo_base_addr_o[28] <= ifmap_glb_base_addr_i + 9*tile_n_i*in_C_i + in_C_i;
                ifmap_fifo_base_addr_o[29] <= ifmap_glb_base_addr_i + 9*tile_n_i*in_C_i + 2*in_C_i;
            end
        end
        else if(current_compute_output_row == out_R_i)begin
            // input channel 1
            ifmap_fifo_base_addr_o[0] <= ifmap_fifo_base_addr_o[0] + 2*in_C_i;
            ifmap_fifo_base_addr_o[1] <= ifmap_fifo_base_addr_o[1] + 2*in_C_i;
            ifmap_fifo_base_addr_o[2] <= `ZERO_ZONE;
            // input channel 2
            ifmap_fifo_base_addr_o[3] <= ifmap_fifo_base_addr_o[3] + 2*in_C_i;
            ifmap_fifo_base_addr_o[4] <= ifmap_fifo_base_addr_o[4] + 2*in_C_i;
            ifmap_fifo_base_addr_o[5] <= `ZERO_ZONE;
            // input channel 3
            ifmap_fifo_base_addr_o[6] <= ifmap_fifo_base_addr_o[6] + 2*in_C_i;
            ifmap_fifo_base_addr_o[7] <= ifmap_fifo_base_addr_o[7] + 2*in_C_i;
            ifmap_fifo_base_addr_o[8] <= `ZERO_ZONE;
            // input channel 4
            ifmap_fifo_base_addr_o[9]  <= ifmap_fifo_base_addr_o[9] + 2*in_C_i;
            ifmap_fifo_base_addr_o[10] <= ifmap_fifo_base_addr_o[10] + 2*in_C_i;
            ifmap_fifo_base_addr_o[11] <= `ZERO_ZONE;
            // input channel 5
            ifmap_fifo_base_addr_o[12] <= ifmap_fifo_base_addr_o[12] + 2*in_C_i;
            ifmap_fifo_base_addr_o[13] <= ifmap_fifo_base_addr_o[13] + 2*in_C_i;
            ifmap_fifo_base_addr_o[14] <= `ZERO_ZONE;
            // input channel 6
            ifmap_fifo_base_addr_o[15] <= ifmap_fifo_base_addr_o[15] + 2*in_C_i;
            ifmap_fifo_base_addr_o[16] <= ifmap_fifo_base_addr_o[16] + 2*in_C_i;
            ifmap_fifo_base_addr_o[17] <= `ZERO_ZONE;
            // input channel 7
            ifmap_fifo_base_addr_o[18] <= ifmap_fifo_base_addr_o[18] + 2*in_C_i;
            ifmap_fifo_base_addr_o[19] <= ifmap_fifo_base_addr_o[19] + 2*in_C_i;
            ifmap_fifo_base_addr_o[20] <= `ZERO_ZONE;
            // input channel 8
            ifmap_fifo_base_addr_o[21] <= ifmap_fifo_base_addr_o[21] + 2*in_C_i;
            ifmap_fifo_base_addr_o[22] <= ifmap_fifo_base_addr_o[22] + 2*in_C_i;
            ifmap_fifo_base_addr_o[23] <= `ZERO_ZONE;
            // input channel 9
            ifmap_fifo_base_addr_o[24] <= ifmap_fifo_base_addr_o[24] + 2*in_C_i;
            ifmap_fifo_base_addr_o[25] <= ifmap_fifo_base_addr_o[25] + 2*in_C_i;
            ifmap_fifo_base_addr_o[26] <= `ZERO_ZONE;
            // input channel 10
            ifmap_fifo_base_addr_o[27] <= ifmap_fifo_base_addr_o[27] + 2*in_C_i;
            ifmap_fifo_base_addr_o[28] <= ifmap_fifo_base_addr_o[28] + 2*in_C_i;
            ifmap_fifo_base_addr_o[29] <= `ZERO_ZONE;
        end
        else begin // after initial row, it is regular
            for(k=0; k<30; k=k+1)begin
                ifmap_fifo_base_addr_o[k] <= ifmap_fifo_base_addr_o[k] + 2*in_C_i;
            end
        end
    end
end


integer i1, i2;
//* ====================== ipsum_glb_base_addr_i ======================
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
    else if(layer_type_i == `DEPTHWISE && init_fifo_pe_state_i)begin
        ipsum_fifo_base_addr_o[0] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2; // row1
        ipsum_fifo_base_addr_o[1] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (1*On_real_i*out_C_i)*2; // row1
        ipsum_fifo_base_addr_o[2] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (2*On_real_i*out_C_i)*2;
        ipsum_fifo_base_addr_o[3] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (3*On_real_i*out_C_i)*2;
        ipsum_fifo_base_addr_o[4] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (4*On_real_i*out_C_i)*2;
        ipsum_fifo_base_addr_o[5] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (5*On_real_i*out_C_i)*2;
        ipsum_fifo_base_addr_o[6] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (6*On_real_i*out_C_i)*2;
        ipsum_fifo_base_addr_o[7] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (7*On_real_i*out_C_i)*2;
        ipsum_fifo_base_addr_o[8] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (8*On_real_i*out_C_i)*2;
        ipsum_fifo_base_addr_o[9] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (9*On_real_i*out_C_i)*2;
    end
    else if(layer_type_i == `STANDARD && init_fifo_pe_state_i)begin
        ipsum_fifo_base_addr_o[0] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2; // row1
        ipsum_fifo_base_addr_o[1] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (1*On_real_i*out_C_i)*2; // row1
        ipsum_fifo_base_addr_o[2] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (2*On_real_i*out_C_i)*2;
        ipsum_fifo_base_addr_o[3] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (3*On_real_i*out_C_i)*2;
        ipsum_fifo_base_addr_o[4] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (4*On_real_i*out_C_i)*2;
        ipsum_fifo_base_addr_o[5] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (5*On_real_i*out_C_i)*2;
        ipsum_fifo_base_addr_o[6] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (6*On_real_i*out_C_i)*2;
        ipsum_fifo_base_addr_o[7] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (7*On_real_i*out_C_i)*2;
        ipsum_fifo_base_addr_o[8] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (8*On_real_i*out_C_i)*2;
        ipsum_fifo_base_addr_o[9] <= ipsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (9*On_real_i*out_C_i)*2;
    end
end

integer j1, j2;



//* ====================== opsum_glb_base_addr_i ======================
always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(j1=0; j1<32; j1++)begin
            opsum_fifo_base_addr_o[j1] <= 32'd0;
        end
    end
    else if(layer_type_i == `POINTWISE && init_fifo_pe_state_i)begin
        opsum_fifo_base_addr_o[0] <= opsum_glb_base_addr_i;
        opsum_fifo_base_addr_o[1] <= opsum_glb_base_addr_i + On_real_i*2;
        opsum_fifo_base_addr_o[2] <= opsum_glb_base_addr_i + 2*On_real_i*2;
        opsum_fifo_base_addr_o[3] <= opsum_glb_base_addr_i + 3*On_real_i*2;
        opsum_fifo_base_addr_o[4] <= opsum_glb_base_addr_i + 4*On_real_i*2;
        opsum_fifo_base_addr_o[5] <= opsum_glb_base_addr_i + 5*On_real_i*2;
        opsum_fifo_base_addr_o[6] <= opsum_glb_base_addr_i + 6*On_real_i*2;
        opsum_fifo_base_addr_o[7] <= opsum_glb_base_addr_i + 7*On_real_i*2;
        opsum_fifo_base_addr_o[8] <= opsum_glb_base_addr_i + 8*On_real_i*2;
        opsum_fifo_base_addr_o[9] <= opsum_glb_base_addr_i + 9*On_real_i*2;
        opsum_fifo_base_addr_o[10] <= opsum_glb_base_addr_i + 10*On_real_i*2;
        opsum_fifo_base_addr_o[11] <= opsum_glb_base_addr_i + 11*On_real_i*2;
        opsum_fifo_base_addr_o[12] <= opsum_glb_base_addr_i + 12*On_real_i*2;
        opsum_fifo_base_addr_o[13] <= opsum_glb_base_addr_i + 13*On_real_i*2;
        opsum_fifo_base_addr_o[14] <= opsum_glb_base_addr_i + 14*On_real_i*2;
        opsum_fifo_base_addr_o[15] <= opsum_glb_base_addr_i + 15*On_real_i*2;
        opsum_fifo_base_addr_o[16] <= opsum_glb_base_addr_i + 16*On_real_i*2;
        opsum_fifo_base_addr_o[17] <= opsum_glb_base_addr_i + 17*On_real_i*2;
        opsum_fifo_base_addr_o[18] <= opsum_glb_base_addr_i + 18*On_real_i*2;
        opsum_fifo_base_addr_o[19] <= opsum_glb_base_addr_i + 19*On_real_i*2;
        opsum_fifo_base_addr_o[20] <= opsum_glb_base_addr_i + 20*On_real_i*2;
        opsum_fifo_base_addr_o[21] <= opsum_glb_base_addr_i + 21*On_real_i*2;
        opsum_fifo_base_addr_o[22] <= opsum_glb_base_addr_i + 22*On_real_i*2;
        opsum_fifo_base_addr_o[23] <= opsum_glb_base_addr_i + 23*On_real_i*2;
        opsum_fifo_base_addr_o[24] <= opsum_glb_base_addr_i + 24*On_real_i*2;
        opsum_fifo_base_addr_o[25] <= opsum_glb_base_addr_i + 25*On_real_i*2;
        opsum_fifo_base_addr_o[26] <= opsum_glb_base_addr_i + 26*On_real_i*2;
        opsum_fifo_base_addr_o[27] <= opsum_glb_base_addr_i + 27*On_real_i*2;
        opsum_fifo_base_addr_o[28] <= opsum_glb_base_addr_i + 28*On_real_i*2;
        opsum_fifo_base_addr_o[29] <= opsum_glb_base_addr_i + 29*On_real_i*2;
        opsum_fifo_base_addr_o[30] <= opsum_glb_base_addr_i + 30*On_real_i*2;
        opsum_fifo_base_addr_o[31] <= opsum_glb_base_addr_i + 31*On_real_i*2;
    end
    else if(layer_type_i == `DEPTHWISE && init_fifo_pe_state_i)begin
        opsum_fifo_base_addr_o[0] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2; // row1
        opsum_fifo_base_addr_o[1] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (1*On_real_i*out_C_i)*2; 
        opsum_fifo_base_addr_o[2] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (2*On_real_i*out_C_i)*2;
        opsum_fifo_base_addr_o[3] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (3*On_real_i*out_C_i)*2;
        opsum_fifo_base_addr_o[4] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (4*On_real_i*out_C_i)*2;
        opsum_fifo_base_addr_o[5] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (5*On_real_i*out_C_i)*2;
        opsum_fifo_base_addr_o[6] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (6*On_real_i*out_C_i)*2;
        opsum_fifo_base_addr_o[7] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (7*On_real_i*out_C_i)*2;
        opsum_fifo_base_addr_o[8] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (8*On_real_i*out_C_i)*2;
        opsum_fifo_base_addr_o[9] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (9*On_real_i*out_C_i)*2;
    end
    else if(layer_type_i == `STANDARD && init_fifo_pe_state_i)begin
        opsum_fifo_base_addr_o[0] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2; // row1
        opsum_fifo_base_addr_o[1] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (1*On_real_i*out_C_i)*2; 
        opsum_fifo_base_addr_o[2] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (2*On_real_i*out_C_i)*2;
        opsum_fifo_base_addr_o[3] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (3*On_real_i*out_C_i)*2;
        opsum_fifo_base_addr_o[4] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (4*On_real_i*out_C_i)*2;
        opsum_fifo_base_addr_o[5] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (5*On_real_i*out_C_i)*2;
        opsum_fifo_base_addr_o[6] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (6*On_real_i*out_C_i)*2;
        opsum_fifo_base_addr_o[7] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (7*On_real_i*out_C_i)*2;
        opsum_fifo_base_addr_o[8] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (8*On_real_i*out_C_i)*2;
        opsum_fifo_base_addr_o[9] <= opsum_glb_base_addr_i + (output_row_cnt_i*out_C_i)*2 + (9*On_real_i*out_C_i)*2;
    end
end





endmodule
