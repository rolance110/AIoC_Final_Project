//===========================================================================
// Module: L2C_normal_loop
// Description: 正式卷積資料流階段 (normal loop)，按 row 逐步進行 ifmap→PE→ipsum→opsum
//===========================================================================
module L2C_normal_loop(
    input logic clk,
    input logic rst_n,

    input logic start_normal_loop_i, // 啟動 normal loop
    input logic [1:0] layer_type_i,  

//* FIFO Done
    input logic [31:0] ifmap_fifo_done_matrix_i, // 每個 ifmap FIFO 是否完成
    input logic [31:0] ipsum_fifo_done_matrix_i, // 每個 ipsum FIFO 是否完成
    input logic [31:0] opsum_fifo_done_matrix_i, // 每個 opsum FIFO 是否完成


//* L3 Controller 
    output logic [31:0] ifmap_need_pop_matrix_o, // 每個 ifmap FIFO 需要 pop 的訊號
    output logic [31:0] ifmap_pop_num_matrix_o [31:0], // 每個 ifmap FIFO 需要 pop 的數量
    
    output logic [31:0] ipsum_need_pop_matrix_o, // 每個 ipsum FIFO 需要 pop 的訊號
    output logic [31:0] ipsum_pop_num_matrix_o [31:0], // 每個 ipsum FIFO 需要 pop 的數量
    
    output logic [31:0] opsum_need_push_matrix_o // 每個 opsum FIFO 需要 push 的訊號
    // output logic [31:0] opsum_push_num_o [31:0], // opsum only need push 1 time
);


endmodule
