module ipsum_fifo_ctrl (
    input  logic        clk,
    input  logic        rst_n,

    // From L2 Controller
    input  logic        ipsum_fifo_reset_i, // Reset FIFO
    input  logic        ipsum_need_pop_i,   // 新任務觸發
    input  logic [31:0]  ipsum_pop_num_i,    // 本次需 pop 幾次

    // From Arbiter
    input  logic        ipsum_permit_push_i,

    // FIFO 狀態
    input  logic        ipsum_fifo_full_i,
    input  logic        ipsum_fifo_empty_i,

    // GLB 控制
    input  logic [31:0] ipsum_fifo_base_addr_i,
    input  logic [31:0] ipsum_glb_read_data_i,

    // FIFO 寫入端

    output logic        ipsum_fifo_push_o,
    output logic [31:0] ipsum_fifo_push_data_o,
    output logic        ipsum_fifo_push_mod_o,

    // FIFO 讀出端
    output logic        ipsum_fifo_pop_o,

    // Arbiter
    output logic        ipsum_read_req_o,
    output logic [31:0] ipsum_glb_read_addr_o,

    // 完成訊號
    output logic        ipsum_fifo_done_o
);

logic [31:0] pop_num_buf;

    // 直接將輸入連接到輸出
    
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
            if (ipsum_need_pop_i && !ipsum_fifo_empty_i)
                ns = POP;
            else if (ipsum_need_pop_i)
                ns = PUSH;
            else
                ns = IDLE;
        end
        POP: begin
            if (ipsum_fifo_empty_i)
                ns = PUSH;
            else if (pop_cnt == (pop_num_buf-31'd1))
                ns = IDLE;
            else
                ns = POP;
        end
        PUSH: begin
            if (ipsum_fifo_full_i)
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
        pop_num_buf <= ipsum_pop_num_i;
end

    // 讀取地址管理
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n || ipsum_fifo_reset_i)
        read_ptr <= 16'd0;
    else if (ipsum_permit_push_i)
        read_ptr <= read_ptr + 16'd2; // half word push (2 bytes)
end
 
assign ipsum_glb_read_addr_o = ipsum_fifo_base_addr_i + read_ptr;

logic [2:0] req_cnt;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        req_cnt <= 3'd0;
    else if (cs == IDLE || cs == POP)
        req_cnt <= 3'd0; // Reset request count in IDLE state
    else if (ipsum_permit_push_i)
        req_cnt <= req_cnt + 3'd1; // 0 1 2 3 4 4 4 0 0
end

// Arbiter Request
assign ipsum_read_req_o = (cs == PUSH) && !ipsum_fifo_full_i && (req_cnt < 3'd2); // 2 data

// PUSH 控制
// (permit, addr) |-> (en, data)
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        ipsum_fifo_push_o <= 1'b0;
    else if(ipsum_permit_push_i && !ipsum_fifo_full_i)
        ipsum_fifo_push_o <= 1'b1;
    else
        ipsum_fifo_push_o <= 1'b0;
end

logic [1:0] ipsum_glb_load_byte_type_o;

always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        ipsum_glb_load_byte_type_o <= 2'b00;
    else begin
        case(ipsum_glb_read_addr_o[1])
            1'b0: ipsum_glb_load_byte_type_o <= `LOAD_1BYTE; // load first half word
            1'b1: ipsum_glb_load_byte_type_o <= `LOAD_2BYTE; // load second half word
            default: ipsum_glb_load_byte_type_o <= 1'b0; // default to first byte for any other count
        endcase
    end
end

always_comb begin
    if(ipsum_fifo_push_mod_o == 1'b0)
        case (ipsum_glb_load_byte_type_o)
            `LOAD_1BYTE: ipsum_fifo_push_data_o = {16'd0,ipsum_glb_read_data_i[15:0]}; // load first half word
            `LOAD_2BYTE: ipsum_fifo_push_data_o = {16'd0,ipsum_glb_read_data_i[31:16]}; // load second half word
            default: ipsum_fifo_push_data_o = 32'h00; // default to first byte for any other count
        endcase
    else // burst mod
        ipsum_fifo_push_data_o = ipsum_glb_read_data_i;
end







assign ipsum_fifo_push_mod_o  = 1'b0; //fixme: 預設只支援單 byte push（可自行加 burst 條件）

// POP 控制
assign ipsum_fifo_pop_o = (cs == POP) && !ipsum_fifo_empty_i;

// pop count 累加
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n || cs == IDLE)
        pop_cnt <= 5'd0;
    else if (ipsum_fifo_pop_o)
        pop_cnt <= pop_cnt + 5'd1;
end

// 完成條件
assign ipsum_fifo_done_o = (cs == IDLE);

endmodule
