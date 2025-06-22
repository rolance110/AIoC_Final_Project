`include "../include/define.svh"

module top(
    input                        clk,                // Clock
    input                        rst,                // Reset

    input                        PASS_START,          // 1clk Pulse：收到後可開始向 GLB 抓值
    input   [1:0]                pass_layer_type,     // 
    input   [`BYTE_CNT_WIDTH-1:0] pass_tile_n,         // 一次 DRAM→GLB 要搬入的 Ifmap bytes 總數
    input   [`FLAG_WIDTH-1:0]     pass_flags,          // Flags 控制：bit[0]=bias_en, bit[1]=relu_en, bit[2]=skip_en, … 

    input   [`ADDR_WIDTH-1:0] BASE_IFMAP,         // GLB 中「此層 Ifmap 資料」的起始位址
    input   [`ADDR_WIDTH-1:0] BASE_WEIGHT,        // GLB 中「此層 Weight 資料」的起始位址
    input   [`ADDR_WIDTH-1:0] BASE_OPSUM,         // GLB 中「此層 PSUM (Partial/Final) 資料」的起始位址
    input   [`ADDR_WIDTH-1:0] BASE_BIAS,          // GLB 中「此層 Bias 資料」的起始位址

    input   [6:0]           out_C,              // 輸出圖片 column 數量 (width)
    input   [6:0]           out_R,              // 輸出圖片 row    數量 (height)


    input                    glb_read_valid,     // GLB 回應：「此筆 glb_read_data 有效」
    input   [`DATA_WIDTH-1:0] glb_read_data,      // GLB 回傳的資料 (4×8bit Ifmap/Weight Pack，或 1×Bias)
    output logic [`ADDR_WIDTH-1:0] glb_read_addr,
    output logic                    glb_read_ready,

    output logic [`ADDR_WIDTH-1:0] glb_write_addr,
    output logic [`DATA_WIDTH-1:0] glb_write_data,
    output logic                   glb_write_valid,
    output logic                   WEB,
    output logic [31:0]            BWEB,


    input                     glb_write_ready,    // 1clk 脈衝：開始一次 GLB Write 交易

    input logic [6:0] tile_K_o,
    input logic [5:0] tile_D, // 記得接真實的

    // input logic [6:0] tile_K_out,   // Token Engine ↔ PE
    input logic [7:0] in_C, //輸入特徵圖 Width column
    input logic [7:0] in_R, //輸入特徵圖 Height row
    input [1:0] stride
    output logic pass_done
);

    logic   [`DATA_WIDTH-1:0]  pe_psum_data;       // PSUM Buffer pop 出的累加結果
    logic                     pe_psum_valid;      // PSUM Buffer 回：pe_psum_data 有效
    logic pe_weight_ready;
    logic pe_ifmap_ready;
    logic pe_bias_ready;

    /* =========================================================
     * 2. GLB Read / Write 介面（Token Engine ↔ GLB）
     * =======================================================*/


    /* =========================================================
     * 3. Token ↔ PE Array 介面
     * =======================================================*/
    logic [`DATA_WIDTH-1:0] token_data;

    logic                   pe_weight_valid;
    logic                   pe_ifmap_valid;   // 修正命名 (ifmap)
    logic                   pe_bias_valid;

    logic                   pe_psum_ready;    // 給 PSUM Buffer 的回覆

    /* =========================================================
     * 4. 其他控制訊號（Token Engine 產生 → PE）
     * =======================================================*/
    logic [5:0] col_en;
    logic [5:0] row_en;

    logic [1:0] compute_num;
    logic       change_row;

    logic [1:0] compute_num0;
    logic [1:0] compute_num1;
    logic [1:0] compute_num2;
    logic [1:0] compute_num3;
    logic [1:0] compute_num4;
    logic [1:0] compute_num5;
    logic [1:0] compute_num6;
    logic [1:0] compute_num7;
    logic [1:0] compute_num8;
    logic [1:0] compute_num9;

    logic DW_PW_sel, dw_stride;

always_comb begin
    DW_PW_sel = 1'd1; // 假設使用 PW 模
    dw_stride = 1'd0;//stride = 1
end

    /* =========================================================
     * 5. Pass Done Flag
     * =======================================================*/
token_engine token_engine(
    .clk(clk),
    .rst(rst),
    .PASS_START(PASS_START),
    .pass_layer_type(pass_layer_type),
    .pass_tile_n(pass_tile_n),
    .pass_flags(pass_flags),
    .BASE_IFMAP(BASE_IFMAP),
    .BASE_WEIGHT(BASE_WEIGHT),
    .BASE_OPSUM(BASE_OPSUM),
    .BASE_BIAS(BASE_BIAS),
    .out_C(out_C),
    .out_R(out_R),

    // GLB read/write interface
    .glb_read_addr(glb_read_addr),
    .glb_read_ready(glb_read_ready),
    .glb_read_valid(glb_read_valid),
    .glb_read_data(glb_read_data),
    .glb_write_addr(glb_write_addr),
    .glb_write_data(glb_write_data),
    .glb_write_ready(glb_write_ready),
    .glb_write_valid(glb_write_valid),
    .WEB(WEB),
    .BWEB(BWEB),

    // PE Array interface
    .token_data(token_data),
    .pe_weight_valid(pe_weight_valid),
    .pe_weight_ready(pe_weight_ready),
    .pe_ifamp_valid(pe_ifmap_valid),
    .pe_ifmap_ready(pe_ifmap_ready),
    .pe_bias_valid(pe_bias_valid),
    .pe_bias_ready(pe_bias_ready),
    .pe_psum_ready(pe_psum_ready),
    .pe_psum_valid(pe_psum_valid),
    .pe_psum_data(pe_psum_data),

    .tile_K_o(tile_K_o),
    .tile_D(tile_D),
    .col_en(col_en),
    .row_en(row_en),

    .compute_num(compute_num),
    .change_row(change_row),
    .in_C(in_C),
    .in_R(in_R),
    .stride(stride),

    .compute_num0(compute_num0),
    .compute_num1(compute_num1),
    .compute_num2(compute_num2),
    .compute_num3(compute_num3),
    .compute_num4(compute_num4),
    .compute_num5(compute_num5),
    .compute_num6(compute_num6),
    .compute_num7(compute_num7),
    .compute_num8(compute_num8),
    .compute_num9(compute_num9),

    // Pass done signal
    .pass_done(pass_done)
);

conv_unit conv_unit(
    .clk(clk),
    .reset(rst),
    .ready_w(pe_weight_ready),
    .valid_w(pe_weight_valid),
    .ready_if(pe_ifmap_ready),
    .valid_if(pe_ifmap_valid),
    .ready_ip(pe_bias_ready),
    .valid_ip(pe_bias_valid),
    .valid_op(pe_psum_valid),
    .ready_op(pe_psum_ready),
    .DW_PW_sel(DW_PW_sel),
    .data_in(token_data),
    .data_out(pe_psum_data),
    .col_en(col_en),
    .row_en(row_en),
    .dw_input_num(compute_num),
    .dw_row_end(change_row),
    .dw_stride(dw_stride)
);

endmodule
