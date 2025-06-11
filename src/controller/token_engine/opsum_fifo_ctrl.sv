module opsum_fifo_ctrl (
    input  logic        clk,
    input  logic        rst_n,

    // 控制來源來自 L2
    input  logic        opsum_fifo_reset_i,    // FIFO reset
    input  logic        opsum_pop_web_i,       // pop 進入 GLB token 是哪個 byte
    input  logic        opsum_need_push_i,     // L2 指令：請嘗試 push 一筆資料 (reducer -> FIFO)
    input  logic        opsum_need_pop_i,      // L2 指令：請嘗試 pop 出一筆資料 (FIFO -> arbiter)

    // Arbiter grant: 你現在可以寫入 GLB
    input  logic        opsum_permit_pop_i,

    // FIFO 狀態
    input  logic        opsum_fifo_empty_i,
    input  logic        opsum_fifo_full_i,

    // GLB base address（由 Token Engine 統一給予）
    input  logic [31:0] opsum_glb_base_addr_i,

    // FIFO control
    output logic        opsum_fifo_reset_o,
    output logic        opsum_fifo_pop_en_o,
    output logic        opsum_fifo_push_en_o,

    // 寫入 GLB token
    output logic        opsum_glb_write_req_o,
    output logic [31:0] opsum_glb_write_addr_o,
    output logic [3:0]  opsum_glb_write_web_o    // 每個位元對應一個 byte 的寫入使能
);

logic pop_pending;
logic [15:0] write_ptr;

// Write 任務追蹤
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pop_pending <= 1'b0;
    else begin
        if (opsum_need_pop_i)
            pop_pending <= 1'b1;
        else if (opsum_fifo_pop_en_o)
            pop_pending <= 1'b0;
    end
end

// Address pointer（累加）
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        write_ptr <= 16'd0;
    else if (opsum_fifo_reset_i)
        write_ptr <= 16'd0;
    else if (opsum_fifo_pop_en_o)
        write_ptr <= write_ptr + 16'd1;
end

// FIFO reset 傳遞
assign opsum_fifo_reset_o = opsum_fifo_reset_i;

    
// FIFO push trigger（由 reducer 推入 FIFO）
assign opsum_fifo_push_en_o = opsum_need_push_i && !opsum_fifo_full_i;
    
// FIFO pop trigger
assign opsum_fifo_pop_en_o = pop_pending && opsum_permit_pop_i && !opsum_fifo_empty_i;

// GLB 寫入 token（排隊後送 arbiter）
assign opsum_glb_write_req_o   = pop_pending && !opsum_fifo_empty_i;
assign opsum_glb_write_addr_o  = opsum_glb_base_addr_i + write_ptr;
assign opsum_glb_write_web_o   = opsum_pop_web_i;  // 4 bytes 全寫（可改為參數化）

endmodule
