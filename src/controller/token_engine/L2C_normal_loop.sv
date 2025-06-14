//===========================================================================
// Module: L2_normal_loop
// Description: 正式卷積資料流階段 (normal loop)，按 row 逐步進行 ifmap→PE→ipsum→opsum
//===========================================================================
module L2_normal_loop #(
    parameter int NUM_IFMAP = 32,
    parameter int NUM_IPSUM = 32,
    parameter int NUM_OPSUM = 32
)(
    input  logic            clk,
    input  logic            rst_n,
    input  logic            start_normal_i,    // 由 L1 進入此階段
    input  logic [6:0]      out_C_i,           // ofmap Row 長度 (pixels)
    // 各 FIFO 狀態與完成旗標
    input  logic [NUM_IFMAP-1:0] ifmap_fifo_done_i,
    input  logic [NUM_IPSUM-1:0] ipsum_fifo_done_i,
    input  logic [NUM_OPSUM-1:0] opsum_fifo_done_i,

    // 控制訊號輸出至 L3
    output logic [NUM_IFMAP-1:0] ifmap_need_pop_o,
    output logic [NUM_IPSUM-1:0] ipsum_need_push_o,
    output logic [NUM_OPSUM-1:0] opsum_need_pop_o,

    // 全域 stall 控制
    output logic            pe_stall_o,

    // 行結束 / 階段結束
    output logic            row_done_o,
    output logic            normal_done_o
);

    // State encoding
    typedef enum logic [2:0] {
        IDLE,
        LOAD_IPSUM,    // 載入 ipsums
        FLOW,          // 正常 pop/push
        STORE_OPSUM,   // 儲存末尾 opsums
        DRAIN,         // 等待內部 FIFO 清空
        DONE           // 完成整個 normal loop
    } state_e;
    state_e cs, ns;

    // Row counter
    logic [6:0] row_cnt;

    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) cs <= IDLE;
        else cs <= ns;
    end

    // Next-state logic
    always_comb begin
        case (cs)
            IDLE: ns = start_normal_i ? LOAD_IPSUM : IDLE;

            LOAD_IPSUM:
                ns = (&ipsum_fifo_done_i) ? FLOW : LOAD_IPSUM;

            FLOW:
                ns = (&ifmap_fifo_done_i && &ipsum_fifo_done_i) ? STORE_OPSUM : FLOW;

            STORE_OPSUM:
                ns = (&opsum_fifo_done_i) ? DRAIN : STORE_OPSUM;

            DRAIN:
                ns = (/* all internal FIFO empty? */ 1'b1) ? DONE : DRAIN;

            DONE:
                ns = DONE;

            default: ns = IDLE;
        endcase
    end

    // Row counter update
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) row_cnt <= 0;
        else if (cs == DONE) row_cnt <= 0;
        else if (cs == DRAIN) row_cnt <= row_cnt + 1;
    end

    // Output control signals
    // 默认全部清零
    always_comb begin
        // 清空
        ifmap_need_pop_o  = '0;
        ipsum_need_push_o = '0;
        opsum_need_pop_o  = '0;
        pe_stall_o        = 1'b0;
        row_done_o        = 1'b0;
        normal_done_o     = 1'b0;

        case (cs)
            IDLE: begin
                pe_stall_o = 1'b1;  // 暫停 PE
            end

            LOAD_IPSUM: begin
                // 單次載入 ipsums
                ipsum_need_push_o = ~ipsum_fifo_done_i;
                pe_stall_o        = 1'b1;
            end

            FLOW: begin
                // 每 cycle pop ifmap & pop ipsum, push psum
                ifmap_need_pop_o  = ~ifmap_fifo_done_i;
                ipsum_need_push_o = ~ipsum_fifo_done_i;
                opsum_need_pop_o  = ~opsum_fifo_done_i;
                // 當任一 FIFO 正在忙，即 stall PE
                pe_stall_o        = |(~ifmap_fifo_done_i) || |(~ipsum_fifo_done_i) || |(~opsum_fifo_done_i);
            end

            STORE_OPSUM: begin
                // 儲存最後一筆 psum
                opsum_need_pop_o  = ~opsum_fifo_done_i;
                pe_stall_o        = 1'b1;
            end

            DRAIN: begin
                // 等待所有 FIFO empty
                pe_stall_o = 1'b0;
                row_done_o = 1'b1;  // 一行結束
            end

            DONE: begin
                normal_done_o = 1'b1;
            end
        endcase
    end

endmodule
