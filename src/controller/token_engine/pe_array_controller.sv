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

    input [7:0] IC_real_i,
    input [7:0] OC_real_i,

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


int row_num, col_num;

always_comb begin
    // 1. 計算需要啟用的 row/col；超過 32 時做剪裁

    if (layer_type_i == `POINTWISE) begin
        row_num = OC_real_i;
        col_num = IC_real_i;
    end else begin
        row_num = OC_real_i * 3;
        col_num = IC_real_i * 3;
    end

    // 2. 只有在 preheat 或 normal_loop 兩種狀態才打開
    for (int r = 0; r < 32; r++) begin
        for (int c = 0; c < 32; c++) begin
            if(r < row_num) begin
                if(c < col_num) begin
                    PE_en_matrix_o[r][c] = 1'b1; // 啟用
                end else begin
                    PE_en_matrix_o[r][c] = 1'b0; // 不啟
                end
            end
            else 
                PE_en_matrix_o[r][c] = 1'b0; // 不啟用
        end
    end

end


endmodule