module ipsum_fifo_ctrl(
    input  logic        clk,
    input  logic        rst_n,

    // 控制來源來自 L2
    input  logic        ipsum_fifo_reset_i, // FIFO reset signal
    input  logic        ipsum_need_push_i,
    input  logic        ipsum_need_pop_i,
    
    // from arbiter
    // Arbiter 拉起表示你這個 FIFO 可以存取 GLB
    input  logic        ipsum_permit_push_i,


    // from 對應的 fifo (1 fifo_ctrl to 1 fifo)
    input  logic        ipsum_fifo_full_i,
    input  logic        ipsum_fifo_empty_i,

    // GLB base address（由 Token Engine 統一給予）
    input  logic [31:0] ipsum_glb_base_addr_i,


    // to 對應的 fifo (1 fifo_ctrl to 1 fifo)
    output logic        ipsum_fifo_reset_o, // reset signal to fifo
    output logic        ipsum_fifo_push_en_o, // GLB push to fifo
    output logic        ipsum_fifo_pop_en_o,  // fifo pop to PE

    // 向 arbiter 發送要讀取的 token 
    output logic        ipsum_glb_read_req_o,
    output logic [31:0] ipsum_glb_read_addr_o
);

// Internal state
logic        push_pending;
logic [15:0] read_ptr;

// Push 任務記憶與完成控制
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        push_pending <= 1'b0;
    else if (ipsum_need_push_i)
        push_pending <= 1'b1;
    else if (ipsum_fifo_push_en_o)
        push_pending <= 1'b0;
end

//fixme: GLB read 位址累加 (depthwise 不單純)
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        read_ptr <= 16'd0;
    else if (ipsum_fifo_reset_i)
        read_ptr <= 16'd0;
    else if (ipsum_fifo_push_en_o)
        read_ptr <= read_ptr + 16'd1;
end

// Assign 控制訊號
assign ipsum_fifo_reset_o     = ipsum_fifo_reset_i;
assign ipsum_glb_read_req_o   = push_pending && !ipsum_fifo_full_i;
assign ipsum_glb_read_addr_o  = ipsum_glb_base_addr_i + read_ptr;
assign ipsum_fifo_push_en_o   = push_pending && ipsum_permit_push_i && !ipsum_fifo_full_i;
assign ipsum_fifo_pop_en_o    = ipsum_need_pop_i && !ipsum_fifo_empty_i;


endmodule