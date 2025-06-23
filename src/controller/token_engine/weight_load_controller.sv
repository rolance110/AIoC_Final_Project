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
                    if (weight_read_cnt == (i * 32 + j + 1)) // +1 is wait for SRAM read delay 1 cycle
                        weight_load_en_matrix_o[i][j] <= 1'b1;
                    else
                        weight_load_en_matrix_o[i][j] <= 1'b0;
                end
            end
        end
        `DEPTHWISE: begin // 0 -> 1 -> 2
        // channel 1
            // row1
            if(weight_read_cnt == 32'd0)
                weight_load_en_matrix_o[0][0] <= 1'b1;
            else if(weight_read_cnt == 32'd1)begin
                weight_load_en_matrix_o[0][0] <= 1'b0;
                weight_load_en_matrix_o[0][1] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd2)begin
                weight_load_en_matrix_o[0][1] <= 1'b0;
                weight_load_en_matrix_o[0][2] <= 1'b1;
            end
            // row2
            else if(weight_read_cnt == 32'd3)begin
                weight_load_en_matrix_o[0][2] <= 1'b0;
                weight_load_en_matrix_o[1][0] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd4)begin
                weight_load_en_matrix_o[1][0] <= 1'b0;
                weight_load_en_matrix_o[1][1] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd5)begin  
                weight_load_en_matrix_o[1][1] <= 1'b0;
                weight_load_en_matrix_o[1][2] <= 1'b1;
            end
            // row3
            else if(weight_read_cnt == 32'd6)begin
                weight_load_en_matrix_o[1][2] <= 1'b0;
                weight_load_en_matrix_o[2][0] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd7)begin
                weight_load_en_matrix_o[2][0] <= 1'b0;
                weight_load_en_matrix_o[2][1] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd8)begin
                weight_load_en_matrix_o[2][1] <= 1'b0;
                weight_load_en_matrix_o[2][2] <= 1'b1;
            end
        // channel 2
            // row1
            else if(weight_read_cnt == 32'd9)begin
                weight_load_en_matrix_o[2][2] <= 1'b0;
                weight_load_en_matrix_o[3][3] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd10)begin
                weight_load_en_matrix_o[3][3] <= 1'b0;
                weight_load_en_matrix_o[3][4] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd11)begin
                weight_load_en_matrix_o[3][4] <= 1'b0;
                weight_load_en_matrix_o[3][5] <= 1'b1;
            end
            // row2
            else if(weight_read_cnt == 32'd12)begin
                weight_load_en_matrix_o[3][5] <= 1'b0;
                weight_load_en_matrix_o[4][3] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd13)begin
                weight_load_en_matrix_o[4][3] <= 1'b0;
                weight_load_en_matrix_o[4][4] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd14)begin
                weight_load_en_matrix_o[4][4] <= 1'b0;
                weight_load_en_matrix_o[4][5] <= 1'b1;
            end
            // row3
            else if(weight_read_cnt == 32'd15)begin
                weight_load_en_matrix_o[4][5] <= 1'b0;
                weight_load_en_matrix_o[5][3] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd16)begin
                weight_load_en_matrix_o[5][3] <= 1'b0;
                weight_load_en_matrix_o[5][4] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd17)begin
                weight_load_en_matrix_o[5][4] <= 1'b0;
                weight_load_en_matrix_o[5][5] <= 1'b1;  
            end
        // channel 3
            // row1
            else if(weight_read_cnt == 32'd18)begin
                weight_load_en_matrix_o[5][5] <= 1'b0;
                weight_load_en_matrix_o[6][6] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd19)begin
                weight_load_en_matrix_o[6][6] <= 1'b0;
                weight_load_en_matrix_o[6][7] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd20)begin
                weight_load_en_matrix_o[6][7] <= 1'b0;
                weight_load_en_matrix_o[6][8] <= 1'b1;
            end
            // row2
            else if(weight_read_cnt == 32'd21)begin
                weight_load_en_matrix_o[6][8] <= 1'b0;
                weight_load_en_matrix_o[7][6] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd22)begin
                weight_load_en_matrix_o[7][6] <= 1'b0;
                weight_load_en_matrix_o[7][7] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd23)begin
                weight_load_en_matrix_o[7][7] <= 1'b0;
                weight_load_en_matrix_o[7][8] <= 1'b1;
            end
            // row3
            else if(weight_read_cnt == 32'd24)begin
                weight_load_en_matrix_o[7][8] <= 1'b0;
                weight_load_en_matrix_o[8][6] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd25)begin
                weight_load_en_matrix_o[8][6] <= 1'b0;
                weight_load_en_matrix_o[8][7] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd26)begin
                weight_load_en_matrix_o[8][7] <= 1'b0;
                weight_load_en_matrix_o[8][8] <= 1'b1;
            end
        // channel 4
            // row1
            else if(weight_read_cnt == 32'd27)begin
                weight_load_en_matrix_o[8][8] <= 1'b0;  // last of channel 3
                weight_load_en_matrix_o[9][9] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd28)begin
                weight_load_en_matrix_o[9][9] <= 1'b0;
                weight_load_en_matrix_o[9][10] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd29)begin
                weight_load_en_matrix_o[9][10] <= 1'b0;
                weight_load_en_matrix_o[9][11] <= 1'b1;
            end
            // row2
            else if(weight_read_cnt == 32'd30)begin
                weight_load_en_matrix_o[9][11] <= 1'b0;
                weight_load_en_matrix_o[10][9] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd31)begin
                weight_load_en_matrix_o[10][9] <= 1'b0;
                weight_load_en_matrix_o[10][10] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd32)begin
                weight_load_en_matrix_o[10][10] <= 1'b0;
                weight_load_en_matrix_o[10][11] <= 1'b1;
            end
            // row3
            else if(weight_read_cnt == 32'd33)begin
                weight_load_en_matrix_o[10][11] <= 1'b0;
                weight_load_en_matrix_o[11][9] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd34)begin
                weight_load_en_matrix_o[11][9] <= 1'b0;
                weight_load_en_matrix_o[11][10] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd35)begin
                weight_load_en_matrix_o[11][10] <= 1'b0;
                weight_load_en_matrix_o[11][11] <= 1'b1;
            end
        // channel 5
            // row1
            else if(weight_read_cnt == 32'd36)begin
                weight_load_en_matrix_o[11][11] <= 1'b0;
                weight_load_en_matrix_o[12][12] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd37)begin
                weight_load_en_matrix_o[12][12] <= 1'b0;
                weight_load_en_matrix_o[12][13] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd38)begin
                weight_load_en_matrix_o[12][13] <= 1'b0;
                weight_load_en_matrix_o[12][14] <= 1'b1;
            end
            // row2
            else if(weight_read_cnt == 32'd39)begin
                weight_load_en_matrix_o[12][14] <= 1'b0;
                weight_load_en_matrix_o[13][12] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd40)begin
                weight_load_en_matrix_o[13][12] <= 1'b0;
                weight_load_en_matrix_o[13][13] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd41)begin
                weight_load_en_matrix_o[13][13] <= 1'b0;
                weight_load_en_matrix_o[13][14] <= 1'b1;
            end
            // row3
            else if(weight_read_cnt == 32'd42)begin
                weight_load_en_matrix_o[13][14] <= 1'b0;
                weight_load_en_matrix_o[14][12] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd43)begin
                weight_load_en_matrix_o[14][12] <= 1'b0;
                weight_load_en_matrix_o[14][13] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd44)begin
                weight_load_en_matrix_o[14][13] <= 1'b0;
                weight_load_en_matrix_o[14][14] <= 1'b1;
            end
        // channel 6
            // row1
            else if(weight_read_cnt == 32'd45)begin
                weight_load_en_matrix_o[14][14] <= 1'b0;
                weight_load_en_matrix_o[15][15] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd46)begin
                weight_load_en_matrix_o[15][15] <= 1'b0;
                weight_load_en_matrix_o[15][16] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd47)begin
                weight_load_en_matrix_o[15][16] <= 1'b0;
                weight_load_en_matrix_o[15][17] <= 1'b1;
            end
            // row2
            else if(weight_read_cnt == 32'd48)begin
                weight_load_en_matrix_o[15][17] <= 1'b0;
                weight_load_en_matrix_o[16][15] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd49)begin
                weight_load_en_matrix_o[16][15] <= 1'b0;
                weight_load_en_matrix_o[16][16] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd50)begin
                weight_load_en_matrix_o[16][16] <= 1'b0;
                weight_load_en_matrix_o[16][17] <= 1'b1;
            end
            // row3
            else if(weight_read_cnt == 32'd51)begin
                weight_load_en_matrix_o[16][17] <= 1'b0;
                weight_load_en_matrix_o[17][15] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd52)begin
                weight_load_en_matrix_o[17][15] <= 1'b0;
                weight_load_en_matrix_o[17][16] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd53)begin
                weight_load_en_matrix_o[17][16] <= 1'b0;
                weight_load_en_matrix_o[17][17] <= 1'b1;
            end
        // channel 7
            // row1
            else if(weight_read_cnt == 32'd54)begin
                weight_load_en_matrix_o[17][17] <= 1'b0;
                weight_load_en_matrix_o[18][18] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd55)begin
                weight_load_en_matrix_o[18][18] <= 1'b0;
                weight_load_en_matrix_o[18][19] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd56)begin
                weight_load_en_matrix_o[18][19] <= 1'b0;
                weight_load_en_matrix_o[18][20] <= 1'b1;
            end
            // row2
            else if(weight_read_cnt == 32'd57)begin
                weight_load_en_matrix_o[18][20] <= 1'b0;
                weight_load_en_matrix_o[19][18] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd58)begin
                weight_load_en_matrix_o[19][18] <= 1'b0;
                weight_load_en_matrix_o[19][19] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd59)begin
                weight_load_en_matrix_o[19][19] <= 1'b0;
                weight_load_en_matrix_o[19][20] <= 1'b1;
            end
            // row3
            else if(weight_read_cnt == 32'd60)begin
                weight_load_en_matrix_o[19][20] <= 1'b0;
                weight_load_en_matrix_o[20][18] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd61)begin
                weight_load_en_matrix_o[20][18] <= 1'b0;
                weight_load_en_matrix_o[20][19] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd62)begin
                weight_load_en_matrix_o[20][19] <= 1'b0;
                weight_load_en_matrix_o[20][20] <= 1'b1;
            end
        // channel 8
            // row1
            else if(weight_read_cnt == 32'd63)begin
                weight_load_en_matrix_o[20][20] <= 1'b0;
                weight_load_en_matrix_o[21][21] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd64)begin
                weight_load_en_matrix_o[21][21] <= 1'b0;
                weight_load_en_matrix_o[21][22] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd65)begin
                weight_load_en_matrix_o[21][22] <= 1'b0;
                weight_load_en_matrix_o[21][23] <= 1'b1;
            end
            // row2
            else if(weight_read_cnt == 32'd66)begin
                weight_load_en_matrix_o[21][23] <= 1'b0;
                weight_load_en_matrix_o[22][21] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd67)begin
                weight_load_en_matrix_o[22][21] <= 1'b0;
                weight_load_en_matrix_o[22][22] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd68)begin
                weight_load_en_matrix_o[22][22] <= 1'b0;
                weight_load_en_matrix_o[22][23] <= 1'b1;
            end
            // row3
            else if(weight_read_cnt == 32'd69)begin
                weight_load_en_matrix_o[22][23] <= 1'b0;
                weight_load_en_matrix_o[23][21] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd70)begin
                weight_load_en_matrix_o[23][21] <= 1'b0;
                weight_load_en_matrix_o[23][22] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd71)begin
                weight_load_en_matrix_o[23][22] <= 1'b0;
                weight_load_en_matrix_o[23][23] <= 1'b1;
            end
        // channel 9
            // row1
            else if(weight_read_cnt == 32'd72)begin
                weight_load_en_matrix_o[23][23] <= 1'b0;
                weight_load_en_matrix_o[24][24] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd73)begin
                weight_load_en_matrix_o[24][24] <= 1'b0;
                weight_load_en_matrix_o[24][25] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd74)begin
                weight_load_en_matrix_o[24][25] <= 1'b0;
                weight_load_en_matrix_o[24][26] <= 1'b1;
            end
            // row2
            else if(weight_read_cnt == 32'd75)begin
                weight_load_en_matrix_o[24][26] <= 1'b0;
                weight_load_en_matrix_o[25][24] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd76)begin
                weight_load_en_matrix_o[25][24] <= 1'b0;
                weight_load_en_matrix_o[25][25] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd77)begin
                weight_load_en_matrix_o[25][25] <= 1'b0;
                weight_load_en_matrix_o[25][26] <= 1'b1;
            end
            // row3
            else if(weight_read_cnt == 32'd78)begin
                weight_load_en_matrix_o[25][26] <= 1'b0;
                weight_load_en_matrix_o[26][24] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd79)begin
                weight_load_en_matrix_o[26][24] <= 1'b0;
                weight_load_en_matrix_o[26][25] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd80)begin
                weight_load_en_matrix_o[26][25] <= 1'b0;
                weight_load_en_matrix_o[26][26] <= 1'b1;
            end
        // channel 10
            // row1
            else if(weight_read_cnt == 32'd81)begin
                weight_load_en_matrix_o[26][26] <= 1'b0;
                weight_load_en_matrix_o[27][27] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd82)begin
                weight_load_en_matrix_o[27][27] <= 1'b0;
                weight_load_en_matrix_o[27][28] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd83)begin
                weight_load_en_matrix_o[27][28] <= 1'b0;
                weight_load_en_matrix_o[27][29] <= 1'b1;
            end
            // row2
            else if(weight_read_cnt == 32'd84)begin
                weight_load_en_matrix_o[27][29] <= 1'b0;
                weight_load_en_matrix_o[28][27] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd85)begin
                weight_load_en_matrix_o[28][27] <= 1'b0;
                weight_load_en_matrix_o[28][28] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd86)begin
                weight_load_en_matrix_o[28][28] <= 1'b0;
                weight_load_en_matrix_o[28][29] <= 1'b1;
            end
            // row3
            else if(weight_read_cnt == 32'd87)begin
                weight_load_en_matrix_o[28][29] <= 1'b0;
                weight_load_en_matrix_o[29][27] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd88)begin
                weight_load_en_matrix_o[29][27] <= 1'b0;
                weight_load_en_matrix_o[29][28] <= 1'b1;
            end
            else if(weight_read_cnt == 32'd89)begin
                weight_load_en_matrix_o[29][28] <= 1'b0;
                weight_load_en_matrix_o[29][29] <= 1'b1;
            end
        end
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