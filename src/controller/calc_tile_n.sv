/*==========================================================*
 *  Module : calc_tile_n
 *  Purpose: 計算最大 tile_n，考慮各種位元組大小參數
 *==========================================================*/
`include "../include/define.svh"

module calc_tile_n #(
    parameter int GLB_BYTES = `GLB_MAX_BYTES,  // 全局 SRAM 容量 (byte)
    parameter int BYTES_I   = `BYTES_I,          // Activation bytes
    parameter int BYTES_W   = `BYTES_W,          // Weight bytes
    parameter int BYTES_P   = `BYTES_P           // Partial-sum bytes
)(
    /* ---- Inputs ---- */

    input logic [1:0] layer_type, // 0=PW,1=DW,2=STD,3=LIN
    input logic [6:0] in_C, // Input channels
    input logic [6:0] out_C, // Output channels

    input  logic [1:0]  kH,           
    input  logic [1:0]  kW,       
    input  logic [6:0]  tile_D,       
    input  logic [6:0]  tile_K,      
    input  logic [6:0]  tile_D_f,     
    input  logic [6:0]  tile_K_f,    

    input   logic [6:0] M1, // parameter M1
    input   logic [6:0] M2, // parameter M2
    input   logic [6:0] M3, // parameter M3
    /* ---- Output ---- */
    output logic [31:0]  tile_n // max number of tiles
);

logic [31:0] n_max;
logic [31:0] tmp1, tmp2, tmp3, tmp4;

assign tmp1 = kH * kW * tile_D_f * tile_K_f * BYTES_W; // filter
assign tmp2 = tile_K * BYTES_P; // bias
assign tmp3 = M2 * M3 * tile_K * BYTES_P;
assign tmp4 = M1 * tile_D * BYTES_I + M3 * tile_K * BYTES_P;
assign n_max = (GLB_BYTES - tmp1 - tmp2 + tmp3) / tmp4; // max number of tiles

always_comb begin
    if (layer_type == `POINTWISE)
        tile_n = {n_max[31:2], 2'b0};
    else
        tile_n = n_max; // Depthwise, Standard
end

endmodule
