`ifndef DEFINE_LD
`define DEFINE_LD

`define POINTWISE 2'd0 // Bit width for activation
`define DEPTHWISE 2'd1 // Bit width for activation
`define STANDARD 2'd2 // Bit width for activation
`define LINEAR 2'd3 // Bit width for activation

`endif // DEFINE_LD

module Layer1_Controller (
    input  logic        clk,
    input  logic        rst_n,

    // 啟動／完成
    input  logic        pass_start_i,
    output logic        pass_done_o,

    //* From Layer Decoder
    input logic [1:0] layer_type_i,
    input logic [31:0] On_real_i, // 來自 L2 的 On_real


    input  logic        weight_load_done_i,
    // input  logic        init_fifo_pe_done_i, // 1 cycle
    input  logic        preheat_done_i,
    input  logic        normal_loop_done_i,



    //* For 3x3 Convolution Count Output Row
    output logic [31:0] output_row_cnt_o,

    // 傳給下層 L2 的控制
    output logic        weight_load_state_o,   // INIT_WEIGHT
    output logic        init_fifo_pe_state_o,  // INIT_FIFO_PE
    output logic        preheat_state_o,       // 下層 PREHEAT 觸發
    output logic        normal_loop_state_o  // 下層 FLOW 觸發

);



typedef enum logic [2:0] {
    PASS_IDLE,
    INIT_WEIGHT,
    INIT_FIFO_PE,
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

logic all_row_finish; // 由下層 L2 回報，所有 row 都完成
assign weight_load_state_o = (L1C_cs == INIT_WEIGHT);
assign init_fifo_pe_state_o = (L1C_cs == INIT_FIFO_PE);
assign preheat_state_o     = (L1C_cs == PREHEAT);
assign normal_loop_state_o = (L1C_cs == NORMAL_LOOP);


// output row count
logic [31:0] output_row_max; // 每次處理的 row 數量
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        output_row_cnt_o <= 32'd0;
    else if(L1C_cs == PASS_IDLE)
        output_row_cnt_o <= 32'd0;
    else if (normal_loop_done_i)
        output_row_cnt_o <= output_row_cnt_o + 32'd1;
end

always_comb begin
    if(layer_type_i == `POINTWISE)
        output_row_max = 32'd1; // Pointwise layer, 每次處理一行
    else if(layer_type_i == `LINEAR)
        output_row_max = 32'd1; // Linear layer, 每次處理一行
    else if(layer_type_i == `DEPTHWISE) 
        output_row_max = On_real_i; // Depthwise layer, 每次處理 On_real_i 行
    else if(layer_type_i == `STANDARD)
        output_row_max = On_real_i; // Standard layer, 每次處理 On_real_i 行
    else
        output_row_max = 32'd0; // 預設值，避免綁定錯誤
end


assign all_row_finish = (output_row_cnt_o == (output_row_max-32'd1)); // 當 output_row_cnt 等於 On_real_i 時，表示所有 row 都完成
always_comb begin
    case(L1C_cs)
        PASS_IDLE: begin
            if (pass_start_i)
                L1C_ns = INIT_WEIGHT; 
            else
                L1C_ns = PASS_IDLE;
        end
        INIT_WEIGHT: begin
            if (weight_load_done_i)
                L1C_ns = INIT_FIFO_PE; 
            else
                L1C_ns = INIT_WEIGHT;
        end
        INIT_FIFO_PE: begin // 1 cycle initialization pe and all fifo
            L1C_ns = PREHEAT;
        end

        PREHEAT: begin
            if (preheat_done_i)
                L1C_ns = NORMAL_LOOP;
            else
                L1C_ns = PREHEAT;
        end

        NORMAL_LOOP: begin
            if (normal_loop_done_i) begin
                if (all_row_finish)
                    L1C_ns = PASS_DONE;
                else
                    L1C_ns = INIT_FIFO_PE;
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

//* pass_done_o
assign pass_done_o = (L1C_cs == PASS_DONE);


endmodule
