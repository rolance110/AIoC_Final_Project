//===========================================================================
// Module: L2C_preheat
// Description: 控制每個 ifmap_fifo 將資料推送至對應的 PE row，達成 preheat
//===========================================================================
`ifndef DEFINE_LD
`define DEFINE_LD

`define POINTWISE 2'd0 // Bit width for activation
`define DEPTHWISE 2'd1 // Bit width for activation
`define STANDARD 2'd2 // Bit width for activation
`define LINEAR 2'd3 // Bit width for activation

`endif // DEFINE_LD
module L2C_preheat #(
    parameter int NUM_IFMAP_FIFO = 32
)(
    input  logic               clk,
    input  logic               rst_n,

    input logic [7:0] IC_real_i,
    input logic [7:0] OC_real_i,


    input  logic               start_preheat_i,
    input  logic [1:0]         layer_type_i,    // 00: pw, 01: dw, others: future
    input  logic [31:0] ifmap_fifo_done_matrix_i,
    input logic [31:0] ipsum_fifo_done_matrix_i,
    
    output logic [31:0] ifmap_need_pop_o,
    output logic [31:0] ifmap_pop_num_o [31:0],
    output logic [31:0] ipsum_need_pop_o,
    output logic [31:0] ipsum_pop_num_o [31:0],

    output logic after_preheat_opsum_push_one_o, // 只要有一個 opsum FIFO 可以 push，就會觸發

    output logic preheat_done_o
);

    typedef enum logic [1:0] {
        IDLE,
        SET_POP_NUM,
        WAIT_DONE,
        DONE
    } state_e;

    state_e pre_cs, pre_ns;

    //========================================================
    // 狀態轉移
    //========================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pre_cs <= IDLE;
        else
            pre_cs <= pre_ns;
    end

    always_comb begin
        case (pre_cs)
            IDLE:begin
                if(start_preheat_i)
                    pre_ns = SET_POP_NUM;
                else 
                    pre_ns = IDLE;
            end
            SET_POP_NUM: begin
                pre_ns = WAIT_DONE;
            end
            WAIT_DONE: begin
                if(&ifmap_fifo_done_matrix_i && &ipsum_fifo_done_matrix_i)
                    pre_ns = DONE;
                else
                    pre_ns = WAIT_DONE;
            end
            DONE:
                pre_ns = IDLE;
            default:
                pre_ns = IDLE;
        endcase
    end



always_comb begin
    if (pre_cs == DONE) 
        after_preheat_opsum_push_one_o = 1'b1; // 只要有一個 opsum FIFO 可以 push，就會觸發
    else 
        after_preheat_opsum_push_one_o = 1'b0;
end

//========================================================
// 根據 layer_type 決定要啟動哪幾個 FIFO ( 根據 IC_real_i 和 OC_real_i )
//========================================================
always_comb begin
    if (pre_cs == SET_POP_NUM) 
        case (layer_type_i)
            `POINTWISE: 
                ifmap_need_pop_o = (IC_real_i == 8'd0)? 32'h0: ((32'h1 << IC_real_i) - 1);   // 32'hFFFF_FFFF; // Pointwise layer, 每個 FIFO 都需要 pop
            `DEPTHWISE: 
                ifmap_need_pop_o = (IC_real_i == 8'd0)? 32'h0: ((32'h1 << (IC_real_i * 3)) - 1);// 32'h3FFF_FFFF; // Depthwise layer, 30 個 FIFO 需要 pop
            `STANDARD: 
                ifmap_need_pop_o = (IC_real_i == 8'd0)? 32'h0: ((32'h1 << (IC_real_i * 3)) - 1);//32'h3FFF_FFFF; // Standard layer, 30 個 FIFO 需要 pop
            `LINEAR: 
                ifmap_need_pop_o = (IC_real_i == 8'd0)? 32'h0: ((32'h1 << IC_real_i) - 1); // Linear layer, 每個 FIFO 都需要 pop
            default: ifmap_need_pop_o = 32'b0; // 預設值，避免綁定錯誤
        endcase
    else 
        ifmap_need_pop_o = 32'b0;
end

always_comb begin
    if (pre_cs == SET_POP_NUM) 
        case (layer_type_i)
            `POINTWISE: 
                ipsum_need_pop_o = (OC_real_i == 8'd0)? 32'h0: ((32'h1 << OC_real_i) - 1); // Pointwise layer, 每個 FIFO 都需要 pop
            `DEPTHWISE: 
                ipsum_need_pop_o = (OC_real_i == 8'd0)? 32'h0: ((32'h1 << OC_real_i) - 1); // Depthwise layer, 10 個 FIFO 需要 pop
            `STANDARD: 
                ipsum_need_pop_o = (OC_real_i == 8'd0)? 32'h0: ((32'h1 << OC_real_i) - 1); // Standard layer, 10 個 FIFO 需要 pop
            `LINEAR: 
                ipsum_need_pop_o = (OC_real_i == 8'd0)? 32'h0: ((32'h1 << OC_real_i) - 1); // Linear layer, 每個 FIFO 都需要 pop
            default: ipsum_need_pop_o = 32'b0; // 預設值，避免綁定錯誤
        endcase
    else 
        ipsum_need_pop_o = 32'b0;
end


//========================================================
// 根據 layer_type 決定每個 FIFO 要 pop 幾次
//========================================================
integer i, j;
always_comb begin
    if ((pre_cs == SET_POP_NUM) && (layer_type_i == `POINTWISE)) begin
        for (j = 0; j < 32; j = j + 1) begin
            ifmap_pop_num_o[j] = (j < IC_real_i)? 32'd1: 32'd0;
        end
    end
    else if ((pre_cs == SET_POP_NUM) && (layer_type_i == `DEPTHWISE)) begin
        // for (j = 0; j < 32; j = j + 1) begin
        //     if (j < IC_real_i * 3)
        //         ifmap_pop_num_o[j] = (((j / 3) + 1) * 3);
        //     else
        //         ifmap_pop_num_o[j] = 32'd0;
        // end
        ifmap_pop_num_o[0]  = 32'd3;
        ifmap_pop_num_o[1]  = 32'd3;
        ifmap_pop_num_o[2]  = 32'd3;

        ifmap_pop_num_o[3]  = 32'd6;
        ifmap_pop_num_o[4]  = 32'd6;
        ifmap_pop_num_o[5]  = 32'd6;

        ifmap_pop_num_o[6]  = 32'd9;
        ifmap_pop_num_o[7]  = 32'd9;
        ifmap_pop_num_o[8]  = 32'd9;

        ifmap_pop_num_o[9]  = 32'd12;
        ifmap_pop_num_o[10] = 32'd12;
        ifmap_pop_num_o[11] = 32'd12;

        ifmap_pop_num_o[12] = 32'd15;
        ifmap_pop_num_o[13] = 32'd15;
        ifmap_pop_num_o[14] = 32'd15;

        ifmap_pop_num_o[15] = 32'd18;
        ifmap_pop_num_o[16] = 32'd18;
        ifmap_pop_num_o[17] = 32'd18;

        ifmap_pop_num_o[18] = 32'd21;
        ifmap_pop_num_o[19] = 32'd21;
        ifmap_pop_num_o[20] = 32'd21;

        ifmap_pop_num_o[21] = 32'd24;
        ifmap_pop_num_o[22] = 32'd24;
        ifmap_pop_num_o[23] = 32'd24;

        ifmap_pop_num_o[24] = 32'd27;
        ifmap_pop_num_o[25] = 32'd27;
        ifmap_pop_num_o[26] = 32'd27;   

        ifmap_pop_num_o[27] = 32'd30;
        ifmap_pop_num_o[28] = 32'd30;
        ifmap_pop_num_o[29] = 32'd30;
    end
    else if ((pre_cs == SET_POP_NUM) && (layer_type_i == `STANDARD)) begin
        for (j = 0; j < 32; j = j + 1) begin
            ifmap_pop_num_o[j] = (j < IC_real_i)? 32'd3: 32'd0;
        end
    end
    else if ((pre_cs == SET_POP_NUM) && (layer_type_i == `LINEAR)) begin
        for (j = 0; j < 32; j = j + 1) begin
            ifmap_pop_num_o[j] = (j < IC_real_i)? 32'd1: 32'd0;
        end
    end
    else begin
        for (i = 0; i < NUM_IFMAP_FIFO; i++) begin
            ifmap_pop_num_o[i]  = 32'd0;
        end
    end

end

integer i1, j1;
always_comb begin
    if ((pre_cs == SET_POP_NUM)) begin
        for(j1 = 0; j1 < 32; j1++)begin
            ipsum_pop_num_o[j1] = 32'd1;
        end
    end
    else begin
        for (i1 = 0; i1 < NUM_IFMAP_FIFO; i1++) begin
            ipsum_pop_num_o[i1]  = 32'd0;
        end
    end

end




assign preheat_done_o = (pre_cs == DONE);

endmodule
