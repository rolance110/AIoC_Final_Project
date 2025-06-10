// `include "../../include/define.svh" //fixme 模擬時需要註解掉
module adder_tree_32 (
    input  logic [15:0] in [31:0],
    output logic [31:0] sum
);
    logic [31:0] lvl1 [15:0];
    logic [31:0] lvl2 [7:0];
    logic [31:0] lvl3 [3:0];
    logic [31:0] lvl4 [1:0];

    assign lvl1[ 0] = in[ 0] + in[ 1];
    assign lvl1[ 1] = in[ 2] + in[ 3];
    assign lvl1[ 2] = in[ 4] + in[ 5];
    assign lvl1[ 3] = in[ 6] + in[ 7];
    assign lvl1[ 4] = in[ 8] + in[ 9];
    assign lvl1[ 5] = in[10] + in[11];
    assign lvl1[ 6] = in[12] + in[13];
    assign lvl1[ 7] = in[14] + in[15];
    assign lvl1[ 8] = in[16] + in[17];
    assign lvl1[ 9] = in[18] + in[19];
    assign lvl1[10] = in[20] + in[21];
    assign lvl1[11] = in[22] + in[23];
    assign lvl1[12] = in[24] + in[25];
    assign lvl1[13] = in[26] + in[27];
    assign lvl1[14] = in[28] + in[29];
    assign lvl1[15] = in[30] + in[31];

    assign lvl2[0] = lvl1[0] + lvl1[1];
    assign lvl2[1] = lvl1[2] + lvl1[3];
    assign lvl2[2] = lvl1[4] + lvl1[5];
    assign lvl2[3] = lvl1[6] + lvl1[7];
    assign lvl2[4] = lvl1[8] + lvl1[9];
    assign lvl2[5] = lvl1[10] + lvl1[11];
    assign lvl2[6] = lvl1[12] + lvl1[13];
    assign lvl2[7] = lvl1[14] + lvl1[15];

    assign lvl3[0] = lvl2[0] + lvl2[1];
    assign lvl3[1] = lvl2[2] + lvl2[3];
    assign lvl3[2] = lvl2[4] + lvl2[5];
    assign lvl3[3] = lvl2[6] + lvl2[7];

    assign lvl4[0] = lvl3[0] + lvl3[1];
    assign lvl4[1] = lvl3[2] + lvl3[3];

    assign sum = lvl4[0] + lvl4[1];
endmodule

module reducer (
    input  logic               clk,
    input  logic               rst_n,

    input  logic [1:0]         layer_type,
    input  logic               ipsum_add_en,

    input  logic [15:0]        mul_out_matrix [31:0][31:0],
    input  logic [15:0]        ipsum_out      [31:0],

    output logic [15:0]        final_psum     [31:0]
);
    logic [31:0] stage1_row [31:0];
    logic [31:0] stage2_row [9:0];

    // Stage 1: adder tree per row
    genvar g;
    generate
        for (g = 0; g < 32; g++) begin : gen_row_adder
            adder_tree_32 u_adder_tree_32 (
                .in(mul_out_matrix[g]),
                .sum(stage1_row[g])
            );
        end
    endgenerate

    // Stage 2: 每 3 row 相加成為一組
    always_comb begin
        stage2_row[0] = stage1_row[0] + stage1_row[1] + stage1_row[2];
        stage2_row[1] = stage1_row[3] + stage1_row[4] + stage1_row[5];
        stage2_row[2] = stage1_row[6] + stage1_row[7] + stage1_row[8];
        stage2_row[3] = stage1_row[9] + stage1_row[10] + stage1_row[11];
        stage2_row[4] = stage1_row[12] + stage1_row[13] + stage1_row[14];
        stage2_row[5] = stage1_row[15] + stage1_row[16] + stage1_row[17];
        stage2_row[6] = stage1_row[18] + stage1_row[19] + stage1_row[20];
        stage2_row[7] = stage1_row[21] + stage1_row[22] + stage1_row[23];
        stage2_row[8] = stage1_row[24] + stage1_row[25] + stage1_row[26];
        stage2_row[9] = stage1_row[27] + stage1_row[28] + stage1_row[29];
    end

    // Stage 3: Mux + ipsum
always_comb begin
    final_psum[0]  = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[0]  + ipsum_out[0])  : stage1_row[0])
                                               : (ipsum_add_en ? (stage2_row[0]  + ipsum_out[0])  : stage2_row[0]);
    final_psum[1]  = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[1]  + ipsum_out[1])  : stage1_row[1])
                                               : (ipsum_add_en ? (stage2_row[1]  + ipsum_out[1])  : stage2_row[1]);
    final_psum[2]  = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[2]  + ipsum_out[2])  : stage1_row[2])
                                               : (ipsum_add_en ? (stage2_row[2]  + ipsum_out[2])  : stage2_row[2]);
    final_psum[3]  = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[3]  + ipsum_out[3])  : stage1_row[3])
                                               : (ipsum_add_en ? (stage2_row[3]  + ipsum_out[3])  : stage2_row[3]);
    final_psum[4]  = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[4]  + ipsum_out[4])  : stage1_row[4])
                                               : (ipsum_add_en ? (stage2_row[4]  + ipsum_out[4])  : stage2_row[4]);
    final_psum[5]  = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[5]  + ipsum_out[5])  : stage1_row[5])
                                               : (ipsum_add_en ? (stage2_row[5]  + ipsum_out[5])  : stage2_row[5]);
    final_psum[6]  = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[6]  + ipsum_out[6])  : stage1_row[6])
                                               : (ipsum_add_en ? (stage2_row[6]  + ipsum_out[6])  : stage2_row[6]);
    final_psum[7]  = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[7]  + ipsum_out[7])  : stage1_row[7])
                                               : (ipsum_add_en ? (stage2_row[7]  + ipsum_out[7])  : stage2_row[7]);
    final_psum[8]  = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[8]  + ipsum_out[8])  : stage1_row[8])
                                               : (ipsum_add_en ? (stage2_row[8]  + ipsum_out[8])  : stage2_row[8]);
    final_psum[9]  = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[9]  + ipsum_out[9])  : stage1_row[9])
                                               : (ipsum_add_en ? (stage2_row[9]  + ipsum_out[9])  : stage2_row[9]);

    // stage2_row[10]~[31] 無效，depthwise/3x3時 output 只會有10組
    final_psum[10] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[10] + ipsum_out[10]) : stage1_row[10])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[10] : 16'd0);
    final_psum[11] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[11] + ipsum_out[11]) : stage1_row[11])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[11] : 16'd0);
    final_psum[12] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[12] + ipsum_out[12]) : stage1_row[12])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[12] : 16'd0);
    final_psum[13] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[13] + ipsum_out[13]) : stage1_row[13])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[13] : 16'd0);
    final_psum[14] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[14] + ipsum_out[14]) : stage1_row[14])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[14] : 16'd0);
    final_psum[15] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[15] + ipsum_out[15]) : stage1_row[15])     
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[15] : 16'd0);
    final_psum[16] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[16] + ipsum_out[16]) : stage1_row[16])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[16] : 16'd0);       
    final_psum[17] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[17] + ipsum_out[17]) : stage1_row[17])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[17] : 16'd0);
    final_psum[18] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[18] + ipsum_out[18]) : stage1_row[18]) 
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[18] : 16'd0);
    final_psum[19] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[19] + ipsum_out[19]) : stage1_row[19])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[19] : 16'd0);
    final_psum[20] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[20] + ipsum_out[20]) : stage1_row[20])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[20] : 16'd0);
    final_psum[21] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[21] + ipsum_out[21]) : stage1_row[21])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[21] : 16'd0);
    final_psum[22] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[22] + ipsum_out[22]) : stage1_row[22])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[22] : 16'd0);
    final_psum[23] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[23] + ipsum_out[23]) : stage1_row[23])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[23] : 16'd0);
    final_psum[24] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[24] + ipsum_out[24]) : stage1_row[24])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[24] : 16'd0);
    final_psum[25] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[25] + ipsum_out[25]) : stage1_row[25])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[25] : 16'd0);
    final_psum[26] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[26] + ipsum_out[26]) : stage1_row[26])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[26] : 16'd0);
    final_psum[27] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[27] + ipsum_out[27]) : stage1_row[27])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[27] : 16'd0);
    final_psum[28] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[28] + ipsum_out[28]) : stage1_row[28])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[28] : 16'd0);
    final_psum[29] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[29] + ipsum_out[29]) : stage1_row[29])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[29] : 16'd0);
    final_psum[30] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[30] + ipsum_out[30]) : stage1_row[30])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[30] : 16'd0); 
    final_psum[31] = (layer_type == `POINTWISE) ? (ipsum_add_en ? (stage1_row[31] + ipsum_out[31]) : stage1_row[31])
                                               : (ipsum_add_en ? 16'd0                            + ipsum_out[31] : 16'd0); 
end

endmodule
