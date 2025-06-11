`include "../../../include/define.svh"
module pe_en_controller(
    input logic clk,
    input logic rst_n,

    input logic [1:0] layer_type, // 00: conv, 01: dwconv, 10: fc, 11: pool

    input logic [31:0] ifmap_fifo_pop_en, // used to count the number of active PEs in each row

    output logic PE_en_matrix [31:0][31:0]  // 32*32 PE array enable matrix
);

logic [4:0] pe_row_active_cnt [31:0]; // active PE row count (0-31) 32 column

/*
    ifmap_fifo_pop_en[0] |  0  |  1  |  0  |  1  |  0  |  0  |
    pe_row_active_cnt[0] |  0  |  0  |  1  |  1  |  2  |  2  |
    PE_en_matrix[0][0]   |  0  |  0  |  1  |  1  |  1  |  1  |
    PE_en_matrix[0][1]   |  0  |  0  |  0  |  0  |  1  |  1  | 
*/

//（32個 ifmap_fifo） 根據 pop 次數知道有多少個 PE 被啟用
integer k;
always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        for (k = 0; k < 32; k++) begin
            pe_row_active_cnt[k] <= 5'd0; // reset all PE row active counts to 0
        end
    end 
    else begin
        for (k = 0; k < 32; k++) begin
            if (ifmap_fifo_pop_en[k]) // if FIFO pop enable is high
                pe_row_active_cnt[k] <= pe_row_active_cnt[k] + 5'd1;
        end
    end
end

// pe_en_matrix
integer i, j;
always_comb begin
    case (layer_type)
        `POINTWISE: begin
            for (i = 0; i < 32; i++) begin
                for (j = 0; j < 32; j++) begin
                    PE_en_matrix[i][j] = (pe_row_active_cnt[i] > j) ? 1'b1 : 1'b0;
                end
            end
        end
        `DEPTHWISE: begin
            for (i = 0; i < 32; i++) begin
                for (j = 0; j < 32; j++) begin
                    PE_en_matrix[i][j] = (pe_row_active_cnt[i] > j) ? 1'b1 : 1'b0;
                end
            end
        end


        default: begin
            for (i = 0; i < 32; i++) begin
                for (j = 0; j < 32; j++) begin
                    PE_en_matrix[i][j] = 1'b0;
                end
            end
        end
    endcase
end

endmodule