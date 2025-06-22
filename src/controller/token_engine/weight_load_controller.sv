`ifndef DEFINE_LD
`define DEFINE_LD

`define POINTWISE 2'd0 // Bit width for activation
`define DEPTHWISE 2'd1 // Bit width for activation
`define STANDARD 2'd2 // Bit width for activation
`define LINEAR 2'd3 // Bit width for activation

`endif // DEFINE_LD
// `include "../../../include/define.svh"
module weight_load_controller(
    input logic clk,
    input logic rst_n,
    input logic weight_load_state_i,
    input logic [1:0] layer_type_i, // 00: conv, 01: dwconv, 10: fc, 11: pool
    input logic [31:0] weight_GLB_base_addr_i, // base address of weight in GLB
    input logic [31:0] glb_read_data_i,
//* to GLB
    output logic [31:0] weight_addr_o, // (count by byte) address  to GLB
    output logic [1:0] weight_load_byte_type_o,
//* to PE
    output logic weight_load_en_matrix_o [31:0][31:0], 
    output logic weight_load_done_o,
    output logic [7:0] weight_in_o
);

logic [31:0] weight_num; // total number of weights to load 
logic [31:0] weight_read_cnt; // counter for loaded weights


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
    weight_load_en_matrix_o       |     |     |     | 1   |  1  |  1  | ... | 1   |    1   |   1    |
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

always_comb begin
    case (weight_load_byte_type_o)
        `LOAD_1BYTE: weight_in_o = glb_read_data_i[7:0]; // load first byte
        `LOAD_2BYTE: weight_in_o = glb_read_data_i[15:8]; // load second byte
        `LOAD_3BYTE: weight_in_o = glb_read_data_i[23:16]; // load third byte
        `LOAD_4BYTE: weight_in_o = glb_read_data_i[31:24]; // load fourth byte
        default: weight_in_o = 8'h00; // default to first byte for any other count
    endcase
end



integer i, j;
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 32; i = i + 1)
            for (j = 0; j < 32; j = j + 1)
                weight_load_en_matrix_o[i][j] <= 1'b0;
    end 
    else if (weight_load_state_i) begin
        case(layer_type_i)
        `POINTWISE:begin// 0 -> 1 -> 2
            for (i = 0; i < 32; i = i + 1) begin
                for (j = 0; j < 32; j = j + 1) begin
                    if (weight_read_cnt == (i * 32 + j + 1 + 1)) // +1 is wait for SRAM read delay 1 cycle
                        weight_load_en_matrix_o[i][j] <= 1'b1;
                    else
                        weight_load_en_matrix_o[i][j] <= 1'b0;
                end
            end
        end
        // `DEPTHWISE: begin // 0 -> 1 -> 2
        //     ch = (weight_read_cnt - 1) / 9; // channel index
        //     w  = (weight_read_cnt - 1) % 9; // which weight in 3x3

        //     if (ch < 32) begin
        //         for (i = 0; i < 32; i = i + 1)
        //             for (j = 0; j < 32; j = j + 1)
        //                 weight_load_en_matrix_o[i][j] <= (i == ch && j == ch && w_cycle_match) ? 1'b1 : 1'b0;
        //     end
        // end
        default: begin // for other layer types, set all to 0
            for (i = 0; i < 32; i = i + 1) begin
                for (j = 0; j < 32; j = j + 1) begin
                    weight_load_en_matrix_o[i][j] <= 1'b0;
                end
            end
        end
        endcase
    end
    else begin
        for (i = 0; i < 32; i = i + 1) begin
            for (j = 0; j < 32; j = j + 1) begin
                weight_load_en_matrix_o[i][j] <= 1'b0; // reset when not loading weights
            end
        end
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