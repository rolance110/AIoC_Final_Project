// `include "../../../include/define.svh"
module pe_array_controller(
    input logic clk,
    input logic rst_n,

    input logic [1:0] layer_type_i,

    input logic preheat_state_i, 
    input logic normal_loop_state_i, 

    input logic [31:0] ifmap_fifo_pop_matrix_i,
    input logic [31:0] ipsum_fifo_pop_matrix_i,
    input logic [31:0] opsum_fifo_push_matrix_i,

    output logic PE_stall_matrix_o [31:0][31:0], // 32*32 PE array stall matrix
    output logic PE_en_matrix_o [31:0][31:0],  // 32*32 PE array enable matrix

    input logic pe_array_move_i
);

integer i, j;
integer r, t;
integer row1, col1;

// PE_stall_matix
always_comb begin
    if(preheat_state_i)begin
        for(row1=0; row1<32; row1++) begin
            for(col1=0; col1<32; col1++) begin    
                PE_stall_matrix_o[row1][col1] = ifmap_fifo_pop_matrix_i[col1];
            end
        end
    end
    else if(normal_loop_state_i) begin
        for(row1=0; row1<32; row1++) begin
            for(col1=0; col1<32; col1++) begin
                PE_stall_matrix_o[row1][col1] = pe_array_move_i; // 正常循環階段，PE stall 由 ipsum pop matrix 決定
            end
        end
    end
    else begin
        for(row1=0; row1<32; row1++) begin
            for(col1=0; col1<32; col1++) begin
                PE_stall_matrix_o[row1][col1] = 1'b0; // default
            end
        end
    end
end

always_comb begin
    if(preheat_state_i)begin
        for(i=0; i<32; i++) begin
            for(j=0; j<32; j++) begin
                PE_en_matrix_o[i][j] = 1'b1; 
            end
        end
    end
    else if(normal_loop_state_i) begin
        for(i=0; i<32; i++) begin
            for(j=0; j<32; j++) begin
                PE_en_matrix_o[i][j] = 1'b1; 
            end
        end
    end
    else begin
        for(i=0; i<32; i++) begin
            for(j=0; j<32; j++) begin
                PE_en_matrix_o[i][j] = 1'b0; // 預熱階段不需要 啟動 pe 計算
            end
        end
    end
end

endmodule