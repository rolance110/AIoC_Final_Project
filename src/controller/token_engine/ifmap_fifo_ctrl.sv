module ifmap_fifo_ctrl(
    input  logic        clk,
    input  logic        rst_n,

    // 控制來源來自 L2
    input  logic        ifmap_fifo_reset_i, // FIFO reset signal
    input  logic        ifmap_need_push_i,
    input  logic        ifmap_need_pop_i,
    
    // from arbiter
    // Arbiter 拉起表示你這個 FIFO 可以存取 GLB
    input  logic        ifmap_permit_push_i,


    // from 對應的 fifo (1 fifo_ctrl to 1 fifo)
    input  logic        ifmap_fifo_full_i,
    input  logic        ifmap_fifo_empty_i,

    // GLB base address（由 Token Engine 統一給予）
    input  logic [31:0] ifmap_glb_base_addr_i,


    // to 對應的 fifo (1 fifo_ctrl to 1 fifo)
    output logic        ifmap_fifo_reset_o, // reset signal to fifo
    output logic        ifmap_fifo_push_en_o, // GLB push to fifo
    output logic        ifmap_fifo_pop_en_o,  // fifo pop to PE

    // 向 arbiter 發送要讀取的 token 
    output logic        ifmap_glb_read_req_o,
    output logic [31:0] ifmap_glb_read_addr_o
);

logic        push_pending;     // 還有 push 任務尚未完成
logic [15:0] read_ptr;         // push 資料來自的 GLB 相對偏移

assign ifmap_fifo_reset_o = ifmap_fifo_reset_i;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        push_pending <= 1'b0;
    end
    else if (ifmap_need_push_i)
        push_pending <= 1'b1;
    else if (ifmap_fifo_push_en_o) // 成功 push 後就清除
        push_pending <= 1'b0;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        read_ptr <= 16'd0;
    else if (ifmap_fifo_reset_i) // reset signal
        read_ptr <= 16'd0; // reset read pointer
    else if (ifmap_fifo_push_en_o)
        read_ptr <= read_ptr + 16'd1;
end

assign ifmap_glb_read_req_o  = push_pending && !ifmap_fifo_full_i;
assign ifmap_glb_read_addr_o = ifmap_glb_base_addr_i + read_ptr;
assign ifmap_fifo_push_en_o  = (push_pending && ifmap_permit_push_i && !ifmap_fifo_full_i);

assign ifmap_fifo_pop_en_o = ifmap_need_pop_i && !ifmap_fifo_empty_i;


endmodule