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

    // 完成訊號
    output logic        ifmap_fifo_done_o
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
            if (ifmap_need_pop_i && !ifmap_fifo_empty_i)
                ns = POP;
            else if (ifmap_need_pop_i)
                ns = PUSH;
            else
                ns = IDLE;
        end
        POP: begin
            if (ifmap_fifo_empty_i)
                ns = PUSH;
            else if (pop_cnt == (pop_num_buf-31'd1))
                ns = IDLE;
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
    else if (ifmap_permit_push_i)
        read_ptr <= read_ptr + 16'd1;
end
 
assign ifmap_glb_read_addr_o = ifmap_fifo_base_addr_i + read_ptr;

logic [2:0] req_cnt;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        req_cnt <= 3'd0;
    else if (cs == IDLE || cs == POP)
        req_cnt <= 3'd0; // Reset request count in IDLE state
    else if (ifmap_permit_push_i)
        req_cnt <= req_cnt + 3'd1; // 0 1 2 3 4 4 4 0 0
end

// Arbiter Request
assign ifmap_read_req_o = (cs == PUSH) && !ifmap_fifo_full_i && (req_cnt < 3'd4);

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

always_comb begin
    if(ifmap_fifo_push_mod_o == 1'b0)
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

// POP 控制
assign ifmap_fifo_pop_o = (cs == POP) && !ifmap_fifo_empty_i;

// pop count 累加
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n || cs == IDLE)
        pop_cnt <= 5'd0;
    else if (ifmap_fifo_pop_o)
        pop_cnt <= pop_cnt + 5'd1;
end

// 完成條件
assign ifmap_fifo_done_o = (cs == IDLE);

endmodule
