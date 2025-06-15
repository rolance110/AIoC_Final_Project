// `include "../../../include/define.svh"
module weight_load_controller(
    input logic clk,
    input logic rst_n,
    input logic weight_load_state_i,
    input logic [1:0] layer_type_i, // 00: conv, 01: dwconv, 10: fc, 11: pool
    input logic [31:0] weight_GLB_base_addr_i, // base address of weight in GLB

//* to GLB
    output logic [3:0] weight_load_WEB_o, // read enable to GLB (1 = write, 0 = read)
    output logic [31:0] weight_addr_o, // (count by byte) address  to GLB
    output logic [1:0] weight_load_byte_type_o,
//* to PE
    output logic w_load_en_matrix_o [31:0][31:0],

    output logic weight_load_done_o 
);

logic [31:0] weight_num; // total number of weights to load 
logic [31:0] weight_read_cnt; // counter for loaded weights



// weight_load_WEB_o
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        weight_load_WEB_o <= 4'b0000; // default read mode
    else if (weight_load_state_i)
        weight_load_WEB_o <= 4'b0000; // when start loading weight, set to read mode
end

always_comb begin
    case(layer_type_i)
        `POINTWISE: begin
            weight_num = 32'd1024; // 32*32 = 1024 weights for pointwise
        end
        `DEPTHWISE: begin
            weight_num = 32'd90; // 3*3*10 = 90 weights for depthwise
        end
        `STANDARD: begin
            weight_num = 32'd900; // 3*3*10*10 = 900 weights for standard conv
        end
        `LINEAR: begin
            weight_num = 32'd1024; // 32*32 = 1024 weights for linear layer
        end
        default: weight_num = 32'd0; // default to 0 for unsupported layer types
    endcase
end

/*
    weight_state            |  0  |  1  |  1  |  1  |  1  |  1  |  1  |  1  |    1   |   1    |  0  |
    weight_read_cnt         |  0  |  0  |  1  |  2  |  3  |  .......  |num-1|   num  | finish |
    weight_addr_o           |  x  |  x  |  B  | B+1 | B+2 | ......... | B+31| B_last |
    weight_load_byte_type_o |     |  x  |  x  |  B  | B+1 | B+2 |
    w_load_en_matrix_o      |     |     |     | 1   |  1  |  1  | ... | 1   |    1   |   1    |
    weight_data             |     |     |  D1 |  D2 |  D3 |  D4 | ... | ... | ...    | D_last |

    weight_load_done_o      |
*/

// weight_read_cnt
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        weight_read_cnt <= 32'd0;
    else if (weight_load_state_i)
        weight_read_cnt <= weight_read_cnt + 32'd1; // increment counter until all weights are loaded
    else
        weight_read_cnt <= 32'd0; // reset counter when not loading weights
end

// weight_addr_o
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        weight_addr_o <= 32'd0;
    else if(weight_read_cnt==32'd0) // reset base address
        weight_addr_o <= weight_GLB_base_addr_i;
    else if (weight_load_state_i)
        weight_addr_o <= weight_addr_o + 32'd1; // increment counter until all weights are loaded
    else
        weight_addr_o <= 32'd0; // reset counter when not loading weights
end

always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        weight_load_byte_type_o <= 2'b00;
    else begin
        case(weight_addr_o[1:0])
            2'b00: weight_load_byte_type_o <= `LOAD_1BYTE; // load first byte
            2'b01: weight_load_byte_type_o <= `LOAD_2BYTE; // load second byte
            2'b10: weight_load_byte_type_o <= `LOAD_3BYTE; // load third byte
            2'b11: weight_load_byte_type_o <= `LOAD_4BYTE; // load fourth byte
            default: weight_load_byte_type_o <= 2'b00; // default to first byte for any other count
        endcase
    end
end

integer i, j;
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 32; i = i + 1)
            for (j = 0; j < 32; j = j + 1)
                w_load_en_matrix_o[i][j] <= 1'b0;
    end 
    else if (weight_load_state_i) begin
        case(layer_type_i)
        `POINTWISE:begin// 0 -> 1 -> 2
            for (i = 0; i < 32; i = i + 1) begin
                for (j = 0; j < 32; j = j + 1) begin
                    if (weight_read_cnt == (i * 32 + j + 1 + 1)) // +1 is wait for SRAM read delay 1 cycle
                        w_load_en_matrix_o[i][j] <= 1'b1;
                    else
                        w_load_en_matrix_o[i][j] <= 1'b0;
                end
            end
        end
        // `DEPTHWISE: begin // 0 -> 1 -> 2

        // end
        default: begin // for other layer types, set all to 0
            for (i = 0; i < 32; i = i + 1) begin
                for (j = 0; j < 32; j = j + 1) begin
                    w_load_en_matrix_o[i][j] <= 1'b0;
                end
            end
        end
        endcase
    end
end



always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        weight_load_done_o <= 1'b0;
    else if (weight_read_cnt == weight_num)
        weight_load_done_o <= 1'b1; // set finish flag when all weights are loaded
    else
        weight_load_done_o <= 1'b0; // reset after 1 clock cycle
end

endmodule