`ifndef DEFINE_LD
`define DEFINE_LD

`define POINTWISE 2'd0 // Bit width for activation
`define DEPTHWISE 2'd1 // Bit width for activation
`define STANDARD 2'd2 // Bit width for activation
`define LINEAR 2'd3 // Bit width for activation

`endif // DEFINE_LD
module ifmap_fifo_ctrl (
    input  logic        clk,
    input  logic        rst_n,

    // pad
    input logic [7:0] in_C_i, // 來自 Layer Decoder 的輸入 C
    input logic [1:0] pad_R_i,
    input logic [1:0] pad_L_i,


    //* busy
    input logic fifo_glb_busy_i, // FIFO <=> GLB 是否忙碌


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
    input  logic [31:0] ifmap_fifo_base_addr_i,
    input  logic [31:0] ifmap_glb_read_data_i,

    // FIFO 寫入端

    output logic        ifmap_fifo_push_o,
    output logic [31:0] ifmap_fifo_push_data_o,
    output logic        ifmap_fifo_push_mod_o,

    // FIFO 讀出端
    output logic        ifmap_fifo_pop_o,

    // Arbiter
    output logic        ifmap_read_req_o,
    output logic [31:0] ifmap_glb_read_addr_o,


    //* for PE array move 
    output logic  ifmap_is_POP_state_o,
    input logic pe_array_move_i, // PE array move enable

    // 完成訊號
    output logic        ifmap_fifo_done_o
);

logic [31:0] pop_num_buf;

    // 直接將輸入連接到輸出
    
typedef enum logic [1:0] {
    IDLE,
    CAN_POP,
    PUSH,
    WAIT
} state_t;

state_t if_cs, if_ns;
logic [15:0] push_cnt;
logic [31:0]  pop_cnt;
logic        refill_mode;
logic right_pad;
logic left_pad;
// 狀態記憶
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        if_cs <= IDLE;
    else
        if_cs <= if_ns;
end

// 狀態轉移
always_comb begin
    unique case (if_cs)
        IDLE: begin
            if (ifmap_need_pop_i && !ifmap_fifo_empty_i)
                if_ns = CAN_POP;
            else if (ifmap_need_pop_i)
                if_ns = PUSH;
            else
                if_ns = IDLE;
        end
        CAN_POP: begin
            if (ifmap_fifo_empty_i)
                if_ns = PUSH;
            else if (pop_cnt == (pop_num_buf-31'd1))
                if_ns = IDLE;
            else if(fifo_glb_busy_i)
                if_ns = WAIT;
            else
                if_ns = CAN_POP;
        end
        PUSH: begin
            if(fifo_glb_busy_i && ifmap_fifo_full_i)
                if_ns = WAIT;
            else if (ifmap_fifo_full_i)
                if_ns = CAN_POP;
            else
                if_ns = PUSH;
        end
        WAIT: begin
            if (!fifo_glb_busy_i)
                if_ns = CAN_POP;
            else
                if_ns = WAIT;
        end
        default: if_ns = IDLE;
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pop_num_buf <= 31'd0;
    else if (ifmap_need_pop_i)
        pop_num_buf <= ifmap_pop_num_i;
end

// 讀取地址管理 // push count
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        push_cnt <= 16'd0;
    else if (ifmap_fifo_reset_i)
        push_cnt <= 16'd0;
    else if (ifmap_permit_push_i)
        push_cnt <= push_cnt + 16'd1;
end

logic [15:0] read_ptr;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        read_ptr <= 16'd0;
    else if (ifmap_fifo_reset_i)
        read_ptr <= 16'd0;
    else if(left_pad)
        read_ptr <= read_ptr;
    else if (ifmap_permit_push_i)
        read_ptr <= read_ptr + 16'd1;
end

assign ifmap_glb_read_addr_o = ifmap_fifo_base_addr_i + read_ptr;

logic [2:0] req_cnt;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        req_cnt <= 3'd0;
    else if (ifmap_fifo_reset_i)
        req_cnt <= 3'd0;
    else if (if_cs == IDLE || if_cs == CAN_POP)
        req_cnt <= 3'd0; // Reset request count in IDLE state
    else if (ifmap_permit_push_i)
        req_cnt <= req_cnt + 3'd1; // 0 1 2 3 4 4 4 0 0
end

// Arbiter Request
assign ifmap_read_req_o = (if_cs == PUSH) && !ifmap_fifo_full_i && (req_cnt < 3'd4);

// PUSH 控制
// (permit, addr) |-> (en, data)
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        ifmap_fifo_push_o <= 1'b0;
    else if(ifmap_permit_push_i && !ifmap_fifo_full_i)
        ifmap_fifo_push_o <= 1'b1;
    else
        ifmap_fifo_push_o <= 1'b0;
end

logic [1:0] ifmap_glb_load_byte_type_o;

always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        ifmap_glb_load_byte_type_o <= 2'b00;
    else begin
        case(ifmap_glb_read_addr_o[1:0])
            2'b00: ifmap_glb_load_byte_type_o <= `LOAD_1BYTE; // load first byte
            2'b01: ifmap_glb_load_byte_type_o <= `LOAD_2BYTE; // load second byte
            2'b10: ifmap_glb_load_byte_type_o <= `LOAD_3BYTE; // load third byte
            2'b11: ifmap_glb_load_byte_type_o <= `LOAD_4BYTE; // load fourth byte
            default: ifmap_glb_load_byte_type_o <= 2'b00; // default to first byte for any other count
        endcase
    end
end


assign left_pad = push_cnt < pad_L_i;
assign right_pad = (($signed({1'b0,in_C_i} + $signed({1'b0,pad_R_i}) + $signed({1'b0,pad_L_i}) - 1) - $signed({1'b0,push_cnt}))) < $signed({1'b0, pad_R_i});

logic is_padding;
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        is_padding <= 1'b0;
    else if (ifmap_glb_read_addr_o[31] || left_pad || right_pad) // zero address is 32'h8000_0000 up
        is_padding <= 1'b1;
    else
        is_padding <= 1'b0;
end
always_comb begin
    if(is_padding)begin
        ifmap_fifo_push_data_o = 32'h00; // padding data
    end
    else if(ifmap_fifo_push_mod_o == 1'b0)
        case (ifmap_glb_load_byte_type_o)
            `LOAD_1BYTE: ifmap_fifo_push_data_o = {24'd0,ifmap_glb_read_data_i[7:0]}; // load first byte
            `LOAD_2BYTE: ifmap_fifo_push_data_o = {24'd0,ifmap_glb_read_data_i[15:8]}; // load second byte
            `LOAD_3BYTE: ifmap_fifo_push_data_o = {24'd0,ifmap_glb_read_data_i[23:16]}; // load third byte
            `LOAD_4BYTE: ifmap_fifo_push_data_o = {24'd0,ifmap_glb_read_data_i[31:24]}; // load fourth byte
            default: ifmap_fifo_push_data_o = 32'h00; // default to first byte for any other count
        endcase
    else // burst mod
        ifmap_fifo_push_data_o = ifmap_glb_read_data_i;
end







assign ifmap_fifo_push_mod_o  = 1'b0; //fixme: 預設只支援單 byte push（可自行加 burst 條件）

// CAN_POP 控制
assign ifmap_fifo_pop_o = (if_cs == CAN_POP) && !ifmap_fifo_empty_i && pe_array_move_i;

// pop count 累加
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n || if_cs == IDLE)
        pop_cnt <= 5'd0;
    else if (ifmap_fifo_reset_i)
        pop_cnt <= 32'd0;
    else if (ifmap_fifo_pop_o)
        pop_cnt <= pop_cnt + 32'd1;
end

// 完成條件
assign ifmap_fifo_done_o = (if_cs == IDLE);
assign ifmap_is_POP_state_o = (if_cs == CAN_POP);

endmodule
