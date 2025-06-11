module Layer1_Controller (
    input  logic        clk,
    input  logic        rst_n,

    // 啟動／完成
    input  logic        pass_start_i,
    output logic        pass_done_o,

    // FIFO 狀態（供 FIFO_PRELOAD & PREHEAT 判斷）
    input  logic [31:0] ifmap_fifo_full,     // 32 條 ifmap
    input  logic [31:0]  ipsum_fifo_full,    // 32 條 ipsum

    // 預熱完成、行結束訊號（來自 L2 Row-Group FSM）
    input  logic        preheat_done_i,
    input  logic        row_done_i,

    // 傳給下層 L2 / Arbiter 的控制
    output logic        weight_load_state,   // INIT_WEIGHT
    output logic        fifo_preload_state,  // FIFO_PRELOAD 觸發
    output logic        preheat_state,       // 下層 PREHEAT 觸發
    output logic        normal_loop_state,   // 下層 FLOW 觸發

    output logic [1:0]  arb_mode             // 00=off,01=read_only,10=write_only,11=normal
);



typedef enum logic [2:0] {
    PASS_IDLE,
    INIT_WEIGHT,
    FIFO_PRELOAD,
    PREHEAT,
    NORMAL_LOOP,
    PASS_DONE
} L1C_t;
L1C_t L1C_cs, L1C_ns;

always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        L1C_cs <= PASS_IDLE;
    else
        L1C_cs <= L1C_ns;
end
logic load_weight_finish;
logic fifo_preload_finish;
logic preheat_finish;
logic normal_loop_finish;
logic all_row_finish;

assign weight_load_state = (L1C_cs == INIT_WEIGHT);
assign fifo_preload_state = (L1C_cs == FIFO_PRELOAD);
assign preheat_state     = (L1C_cs == PREHEAT);
assign normal_loop_state = (L1C_cs == NORMAL_LOOP);

always_comb begin
    case(L1C_cs)
        PASS_IDLE: begin
            if (pass_start_i)
                L1C_ns = INIT_WEIGHT; 
            else
                L1C_ns = PASS_IDLE;
        end
        INIT_WEIGHT: begin
            if (load_weight_finish)
                L1C_ns = FIFO_PRELOAD; 
            else
                L1C_ns = INIT_WEIGHT;
        end
        FIFO_PRELOAD: begin
            if (fifo_preload_finish)
                L1C_ns = PREHEAT;
            else
                L1C_ns = FIFO_PRELOAD;
        end

        PREHEAT: begin
            if (preheat_finish)
                L1C_ns = NORMAL_LOOP;
            else
                L1C_ns = PREHEAT;
        end

        NORMAL_LOOP: begin
            if (normal_loop_finish) begin
                if (all_row_finish)
                    L1C_ns = FIFO_PRELOAD;
                else
                    L1C_ns = PASS_IDLE;
            end 
            else
                L1C_ns = NORMAL_LOOP;
        end

        PASS_DONE: begin                
            L1C_ns = PASS_IDLE;
        end

        default: L1C_ns = PASS_IDLE; 
    endcase
end

//* arbiter mode
/*
功能：決定是否允許讀取或寫入 GLB => 避免讀寫錯誤
    00: 全部遮罩（Token-Engine 不得碰 GLB）
    01: 讀取模式（Token-Engine 讀取 GLB）
    10: 寫入模式（Token-Engine 寫入 GLB）
    11: 正常模式（Token-Engine 讀寫 GLB）
*/
    always_comb begin
        unique case(L1C_cs)
            PASS_IDLE   : arb_mode = 2'b00;   // all off
            INIT_WEIGHT : arb_mode = 2'b00;   // all off
            PASS_DONE   : arb_mode = 2'b00;   // all off
            FIFO_PRELOAD: arb_mode = 2'b01;   // read only
            PREHEAT     : arb_mode = 2'b01;   // read only
            NORMAL_LOOP : arb_mode = 2'b11;   // 讀寫模式
            default: arb_mode = 2'b00;
        endcase
    end

//* pass_done_o
assign pass_done_o = (L1C_cs == PASS_DONE);


endmodule
