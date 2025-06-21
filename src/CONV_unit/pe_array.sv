module pe_array #(
    parameter int ROW = 32,
    parameter int COL = 32
)(
    input  logic clk,
    input  logic rst_n,

    // ifmap 來源（由 ifmap_fifo 提供）
    input  logic [7:0] ifmap_row0 [31:0],       // 第一列的輸入資料

    // 權重載入控制
    input  logic [7:0]     weight_in,  // 欲載入的 weight
    input  logic           w_load_en[31:0][31:0],             // 啟用載入

    // PE enable 控制（每個 PE 可被獨立 enable）
    input  logic PE_en_matrix[31:0][31:0] ,
    input logic  PE_stall_matrix[31:0][31:0], // 每個 PE 的 stall 狀態

    // 輸出結果（給 adder tree）
    output logic [15:0] mul_out_matrix [31:0][31:0]
);
logic [7:0] ifmap_chain_in [31:0][31:0]; // 每個 PE 的 ifmap 輸入
logic [7:0] ifmap_chain_out [31:0][31:0]; // 每個 PE 的 ifmap 輸出

//.ifmap     (r == 0 ? ifmap_row0[c] : ifmap_chain_out[r-1][c]),

genvar r1, c1;
generate 
    for(r1 = 0; r1 < 32; r1++) begin : IFMAP_ROW1_CHAIN_IN
        assign ifmap_chain_in[0][r1] = ifmap_row0[r1]; // 第一行 PE 直接接收 ifmap_row0
    end
endgenerate 
generate 
    for(r1 = 1; r1 < 32; r1++) begin : IFMAP_ROW_CHAIN_IN
        for(c1 = 0; c1 < 32; c1++) begin : IFMAP_COL_CHAIN_IN
            assign ifmap_chain_in[r1][c1] = ifmap_chain_out[r1-1][c1]; // 後續行的 PE 接收上一行的輸出
        end
    end
endgenerate


genvar r, c;
generate
    for (r = 0; r < 32; r++) begin : ROW_LOOP
        for (c = 0; c < 32; c++) begin : COL_LOOP
            pe pe_inst (
                .clk       (clk),
                .rst_n     (rst_n),

                .w_in      (weight_in), // weight boardcast
                .w_load_en (w_load_en[r][c]),

                .PE_en     (PE_en_matrix[r][c]),
                .PE_stall  (PE_stall_matrix[r][c]),

                .ifmap     (ifmap_chain_in[r][c]), // 來自上一個 PE 或 ifmap_row0
                .ifmap_out (ifmap_chain_out[r][c]),
                .mul_out   (mul_out_matrix[r][c])
            );
        end
    end
endgenerate

endmodule