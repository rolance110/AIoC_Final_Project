`ifndef DEFINE_LD
`define DEFINE_LD

`define POINTWISE 2'd0 // Bit width for activation
`define DEPTHWISE 2'd1 // Bit width for activation
`define STANDARD 2'd2 // Bit width for activation
`define LINEAR 2'd3 // Bit width for activation

`endif // DEFINE_LD
module ipsum_fifo_ctrl (
    input  logic        clk,
    input  logic        rst_n,

    //* busy
    input logic fifo_glb_busy_i, // FIFO <=> GLB 是否忙碌

    // From L2 Controller
    input  logic        ipsum_fifo_reset_i, // Reset FIFO
    input  logic        ipsum_need_pop_i,   // 新任務觸發
    input  logic [31:0]  ipsum_pop_num_i,    // 本次需 pop 幾次

    //* mask
    input logic          ipsum_fifo_mask_i,


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


    //* for PE array move 
    output logic  ipsum_is_POP_state_o,
    input logic pe_array_move_i, // PE array move enable


    // 完成訊號
    output logic        ipsum_fifo_done_o
);

logic [31:0] pop_num_buf;

    // 直接將輸入連接到輸出
    
typedef enum logic [1:0] {
    IDLE,
    CAN_POP,
    PUSH,
    WAIT
} state_t;

state_t ip_cs, ip_ns;
logic [15:0] read_ptr;
logic [31:0]  pop_cnt;
logic        refill_mode;

// 狀態記憶
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        ip_cs <= IDLE;
    else
        ip_cs <= ip_ns;
end

// 狀態轉移
always_comb begin
    unique case (ip_cs)
        IDLE: begin
            if (ipsum_need_pop_i && !ipsum_fifo_empty_i)
                ip_ns = CAN_POP;
            else if (ipsum_need_pop_i)
                ip_ns = PUSH;
            else
                ip_ns = IDLE;
        end
        CAN_POP: begin
            if (ipsum_fifo_empty_i)
                ip_ns = PUSH;
            else if (pop_cnt == (pop_num_buf-31'd1))
                ip_ns = IDLE;
            else if(fifo_glb_busy_i)
                ip_ns = WAIT;
            else
                ip_ns = CAN_POP;
        end
        PUSH: begin
            if(fifo_glb_busy_i && ipsum_fifo_full_i)
                ip_ns = WAIT;
            else if (ipsum_fifo_full_i)
                ip_ns = CAN_POP;
            else
                ip_ns = PUSH;
        end
        WAIT: begin
            if (!fifo_glb_busy_i)
                ip_ns = CAN_POP;
            else
                ip_ns = WAIT;
        end
        default: ip_ns = IDLE;
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pop_num_buf <= 31'd0;
    else if (ipsum_need_pop_i)
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
    else if (ip_cs == IDLE || ip_cs == CAN_POP)
        req_cnt <= 3'd0; // Reset request count in IDLE state
    else if (ipsum_permit_push_i)
        req_cnt <= req_cnt + 3'd1; // 0 1 2 3 4 4 4 0 0
end

// Arbiter Request
assign ipsum_read_req_o = (ip_cs == PUSH) && !ipsum_fifo_full_i && (req_cnt < 3'd4); // 4 data

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

// CAN_POP 控制
assign ipsum_fifo_pop_o = (ip_cs == CAN_POP) && !ipsum_fifo_empty_i && pe_array_move_i && ipsum_fifo_mask_i;

// pop count 累加
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n || ip_cs == IDLE)
        pop_cnt <= 32'd0;
    else if (ipsum_fifo_pop_o)
        pop_cnt <= pop_cnt + 32'd1;
end

// 完成條件
assign ipsum_fifo_done_o = (ip_cs == IDLE);
assign ipsum_is_POP_state_o = (ip_cs == CAN_POP);
endmodule
