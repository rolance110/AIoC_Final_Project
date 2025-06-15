module ifmap_fifo_ctrl (
    input  logic        clk,
    input  logic        rst_n,

    // From L2 Controller
    input  logic        ifmap_fifo_reset_i, // Reset FIFO
    input  logic        ifmap_need_pop_i,   // 新任務觸發
    input  logic [31:0]  ifmap_pop_num_i,    // 本次需 pop 幾次

    // From Arbiter
    input  logic        ifmap_permit_push_i,

    // FIFO 狀態
    input  logic        ifmap_fifo_full_i,
    input  logic        ifmap_fifo_empty_i,

    // GLB 控制
    input  logic [31:0] ifmap_glb_base_addr_i,
    input  logic [31:0] ifmap_glb_read_data_i,

    // FIFO 寫入端

    output logic        ifmap_fifo_reset_o, // FIFO 重置輸出
    output logic        ifmap_fifo_push_en_o,
    output logic [31:0] ifmap_fifo_push_data_o,
    output logic        ifmap_fifo_push_mod_o,

    // FIFO 讀出端
    output logic        ifmap_fifo_pop_en_o,

    // Arbiter
    output logic        ifmap_glb_read_req_o,
    output logic [31:0] ifmap_glb_read_addr_o,

    // 完成訊號
    output logic        ifmap_fifo_done_o
);

logic [31:0] pop_num_buf;

    // 直接將輸入連接到輸出
assign ifmap_fifo_reset_o = ifmap_fifo_reset_i; // 直接將輸入連接到輸出
    
typedef enum logic [1:0] {
    IDLE,
    POP,
    PUSH
} state_t;

state_t cs, ns;
logic [15:0] read_ptr;
logic [4:0]  pop_cnt;
logic        refill_mode;

// 狀態記憶
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cs <= IDLE;
    else
        cs <= ns;
end

// 狀態轉移
always_comb begin
    unique case (cs)
        IDLE: begin
            if (ifmap_need_pop_i)
                ns = POP;
            else
                ns = IDLE;
        end
        POP: begin
            if (pop_cnt == (pop_num_buf-31'd1))
                ns = IDLE;
            else if (ifmap_fifo_empty_i)
                ns = PUSH;
            else
                ns = POP;
        end
        PUSH: begin
            if (ifmap_fifo_full_i)
                ns = POP;
            else
                ns = PUSH;
        end
        default: ns = IDLE;
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pop_num_buf <= 31'd0;
    else if (cs == IDLE)
        pop_num_buf <= ifmap_pop_num_i;
end

    // 讀取地址管理
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n || ifmap_fifo_reset_i)
        read_ptr <= 16'd0;
    else if (ifmap_fifo_push_en_o)
        read_ptr <= read_ptr + 16'd1;
end
 
assign ifmap_glb_read_addr_o = ifmap_glb_base_addr_i + read_ptr;

// Arbiter Request
assign ifmap_glb_read_req_o = (cs == PUSH) && !ifmap_fifo_full_i;

// PUSH 控制
assign ifmap_fifo_push_en_o   = (cs == PUSH) && ifmap_permit_push_i && !ifmap_fifo_full_i;
assign ifmap_fifo_push_data_o = ifmap_glb_read_data_i;
assign ifmap_fifo_push_mod_o  = 1'b0; //fixme: 預設只支援單 byte push（可自行加 burst 條件）

// POP 控制
assign ifmap_fifo_pop_en_o = (cs == POP) && !ifmap_fifo_empty_i;

// pop count 累加
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n || cs == IDLE)
        pop_cnt <= 5'd0;
    else if (ifmap_fifo_pop_en_o)
        pop_cnt <= pop_cnt + 5'd1;
end

// 完成條件
assign ifmap_fifo_done_o = (cs == IDLE);

endmodule
