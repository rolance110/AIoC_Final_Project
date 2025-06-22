module opsum_fifo_ctrl (
    input  logic        clk,
    input  logic        rst_n,

    input logic fifo_glb_busy_i,
    // 控制來源來自 L2
    input  logic        opsum_fifo_reset_i,    // FIFO reset
    input  logic        opsum_need_push_i,      // L2 指令：請嘗試 pop 出一筆資料 (FIFO -> arbiter)
    input  logic [31:0] opsum_push_num_i,       // 本次需 push 幾筆資料

    input logic opsum_fifo_mask_i, //todo: FIFO enable mask, 1: enable, 0: disable
    
    input logic after_preheat_opsum_push_one_i,

    // Arbiter grant: 你現在可以寫入 GLB
    input  logic        opsum_permit_pop_i,

    // FIFO 狀態
    input  logic        opsum_fifo_empty_i,
    input  logic        opsum_fifo_full_i,

    // FIFO POP data input for processing => GLB write
    input  logic [31:0] opsum_fifo_pop_data_i,

    // GLB base address（由 Token Engine 統一給予）
    input  logic [31:0] opsum_glb_base_addr_i,


    // Arbiter request
    output logic        opsum_write_req_o,      // Arbiter request: 你可以 pop 資料到 GLB
    // FIFO control
    output logic        opsum_fifo_pop_o,
    output logic        opsum_fifo_pop_mod_o,
    output logic        opsum_fifo_push_o,

    // 寫入 GLB token
    output logic [31:0] opsum_glb_write_addr_o,
    output logic [3:0]  opsum_glb_write_web_o,    // 每個位元對應一個 byte 的寫入使能
    output logic [31:0] opsum_glb_write_data_o,    // pop 出的資料

    output logic opsum_is_PUSH_state_o, // opsum 是否處於 PUSH 狀態
    input logic pe_array_move_i,        //todo: PE array move enable, & mask => push_en  

    output logic opsum_fifo_done_o
);

logic pop_all_to_GLB;
logic [31:0] push_num_buf;

    // 直接將輸入連接到輸出
    
typedef enum logic [1:0] {
    IDLE,
    CAN_PUSH,
    POP,
    DONE
} state_t;

state_t op_cs, op_ns;
logic [15:0] write_ptr;
logic [31:0]  push_cnt;


// 狀態記憶
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        op_cs <= IDLE;
    else
        op_cs <= op_ns;
end

// 狀態轉移
always_comb begin
    unique case (op_cs)
        IDLE: begin
            if (opsum_need_push_i)
                op_ns = CAN_PUSH;
            else
                op_ns = IDLE;
        end
        CAN_PUSH: begin
            if (opsum_fifo_full_i)
                op_ns = POP;
            else if (push_cnt == push_num_buf)
                op_ns = POP; // push 的數量已達到要求, 把剩餘的 fifo data pop 乾淨
            else
                op_ns = CAN_PUSH;
        end
        POP: begin
            if((push_cnt >= push_num_buf) && opsum_fifo_empty_i) // fixme: PUSH -> POP 會多 push 1 次
                op_ns = DONE; // push 已經完成，且 fifo 也已經 pop 完畢
            else if (opsum_fifo_empty_i)
                op_ns = CAN_PUSH;
            else
                op_ns = POP;
        end
        DONE: begin
            if(opsum_fifo_reset_i)
                op_ns = IDLE;
            else
                op_ns = DONE; // 保持在 DONE 狀態，直到重置
        end
        default: op_ns = IDLE;
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        push_num_buf <= 31'd0;
    else if (op_cs == IDLE && opsum_need_push_i)
        push_num_buf <= opsum_push_num_i;
end


    // 讀取地址管理
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        write_ptr <= -16'd2;
    else if (opsum_fifo_pop_o)
        write_ptr <= write_ptr + 16'd2; // opsum 2 byte
end
 
assign opsum_glb_write_addr_o = opsum_glb_base_addr_i + write_ptr;

logic [2:0] req_cnt;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        req_cnt <= 3'd0;
    else if (op_cs == IDLE || op_cs == CAN_PUSH)
        req_cnt <= 3'd0; // Reset request count in IDLE state
    else if (opsum_permit_pop_i)
        req_cnt <= req_cnt + 3'd1; // 0 1 2 3 4 4 4 0 0
end

// Arbiter Request
assign opsum_write_req_o = (op_cs == POP) && !opsum_fifo_empty_i && (req_cnt < 3'd4);
// CAN_PUSH 由外部 module 控制
logic no_delay_opsum_fifo_pop_o;
logic delay_opsum_fifo_pop_o;
always_comb begin
    opsum_fifo_pop_o = (op_cs == POP) && opsum_permit_pop_i && !opsum_fifo_empty_i;
end

always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        delay_opsum_fifo_pop_o <= 1'b0;
    else
        delay_opsum_fifo_pop_o <= opsum_fifo_pop_o; // 設置 pop buffer
end



// CAN_PUSH 由外部 module 控制
assign opsum_fifo_push_o = /*(*/((op_cs == CAN_PUSH) && pe_array_move_i) /*|| ((op_cs == IDLE) && after_preheat_opsum_push_one_i))*/ && opsum_fifo_mask_i && !opsum_fifo_full_i;

logic opsum_glb_write_type_o; // 0: lower 16 bits, 1: higher 16 bits

always_comb begin
    case(opsum_glb_write_addr_o[1])
        1'b0: opsum_glb_write_type_o = 1'b0; // load lower 16 bits
        1'b1: opsum_glb_write_type_o = 1'b1; // load higher 16 bits
        default: opsum_glb_write_type_o = 1'b0;
    endcase
end

always_comb begin
    if(opsum_fifo_pop_mod_o == 1'b0)
        case (opsum_glb_write_type_o)
            1'b0: opsum_glb_write_data_o = {16'd0,opsum_fifo_pop_data_i[15:0]}; // load first byte
            1'b1: opsum_glb_write_data_o = {opsum_fifo_pop_data_i[15:0],16'd0}; // load second byte
            default: opsum_glb_write_data_o = 32'h00; // default to first byte for any other count
        endcase
    else // burst mod
        opsum_glb_write_data_o = opsum_fifo_pop_data_i;
end
//web
always_comb begin
    if(opsum_fifo_pop_mod_o == 1'b0)
        case (opsum_glb_write_type_o)
            1'b0: opsum_glb_write_web_o = 4'b0011; // load first byte
            1'b1: opsum_glb_write_web_o = 4'b1100; // load second byte
            default: opsum_glb_write_web_o = 4'b0000; // default to first byte for any other count
        endcase
    else // burst mod
        opsum_glb_write_web_o = 4'b1111;
end





assign opsum_fifo_pop_mod_o  = 1'b0; //fixme: 預設只支援單 byte push（可自行加 burst 條件）

// push count 累加
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n || op_cs == IDLE)
        push_cnt <= 32'd0;
    else if (opsum_fifo_push_o)
        push_cnt <= push_cnt + 32'd1;
end

// 完成條件
assign opsum_fifo_done_o = (op_cs == IDLE || op_cs == DONE);

assign opsum_is_PUSH_state_o = (op_cs == CAN_PUSH);
endmodule
