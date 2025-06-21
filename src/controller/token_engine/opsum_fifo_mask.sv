module opsum_fifo_mask (
    input  logic        clk,
    input  logic        rst_n,


    input logic  [1:0]     layer_type_i, // 0: conv, 1: fc
    // 控制訊號
    input  logic        opsum_fifo_reset_i,
    input logic preheat_done_i, //* preheat 結束後 opsum 會已經 push 一次
    input  logic        normal_loop_state_i,

    input logic after_preheat_opsum_push_one_i,
    // 參數：實際要啟用的 FIFO 數量 (0～32)
    input  logic [7:0]  OC_real_i,
    // ifmap_fifo_pop 事件，只要任一位有 pop 則視為「pop 一次」
    input  logic [31:0] ifmap_fifo_pop_matrix_i,
    
    // 最終哪幾個 opsum_fifo 可以 push
    output logic [31:0] opsum_fifo_mask_o
);

    // 動態遮罩：由 reset 或 pop 事件決定要往左推開哪幾個 bit
    logic [31:0] init_mask;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            init_mask <= 32'h0;
        else if (layer_type_i == `POINTWISE)
            if (opsum_fifo_reset_i)
                init_mask <= 32'h1;               // reset 時先開啟第 0 號 FIFO
            // else if (preheat_done_i)
            //     init_mask <= 32'h3; // preheat_done_i 時，開啟前 2 個 FIFO // 改成不用 先 push 1 次
            else if (normal_loop_state_i && |ifmap_fifo_pop_matrix_i)
                init_mask <= (init_mask << 1) | 32'h1;
        else if (layer_type_i == `DEPTHWISE)
            init_mask <= 32'b00000000_00000000_00000011_11111111;// 開啟前 10 號 FIFO
    end
    // 靜態遮罩：前 OC_real_i bits 打 1，其餘 0
    logic [31:0] static_mask;
    always_comb begin
        if (OC_real_i == 0)
            static_mask = 32'h0;
        else
            static_mask = (32'h1 << OC_real_i) - 1;
    end

    // 結合動態＆靜態遮罩
    assign opsum_fifo_mask_o = (normal_loop_state_i || after_preheat_opsum_push_one_i)? (init_mask & static_mask): 32'h0;

endmodule
