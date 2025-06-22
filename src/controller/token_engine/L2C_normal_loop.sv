//===========================================================================
// Module: L2C_normal_loop
// Description: 正式卷積資料流階段 (normal loop)，按 row 逐步進行 ifmap→PE→ipsum→opsum
//===========================================================================
`ifndef DEFINE_LD
`define DEFINE_LD

`define POINTWISE 2'd0 // Bit width for activation
`define DEPTHWISE 2'd1 // Bit width for activation
`define STANDARD 2'd2 // Bit width for activation
`define LINEAR 2'd3 // Bit width for activation

`endif // DEFINE_LD
module L2C_normal_loop(
    input logic clk,
    input logic rst_n,

    input logic normal_loop_state_i, // 啟動 normal loop
    input logic [1:0] layer_type_i,  


//* Tile Infomation
    input logic [31:0] tile_n_i, // tile 的數量
    input logic [31:0] On_real_i,

    input logic [7:0] in_C_i, // input channel
    input logic [7:0] in_R_i, // input row
    input logic [1:0] pad_R_i, // padding row right
    input logic [1:0] pad_L_i, // padding row left
    input logic [7:0] out_C_i, // output channel
    input logic [7:0] out_R_i, // output row

//* FIFO Done
    input logic [31:0] ifmap_fifo_done_matrix_i, // 每個 ifmap FIFO 是否完成
    input logic [31:0] ipsum_fifo_done_matrix_i, // 每個 ipsum FIFO 是否完成
    input logic [31:0] opsum_fifo_done_matrix_i, // 每個 opsum FIFO 是否完成


//* L3 Controller 
    output logic [31:0] ifmap_need_pop_matrix_o, // 每個 ifmap FIFO 需要 pop 的訊號
    output logic [31:0] ifmap_pop_num_matrix_o [31:0], // 每個 ifmap FIFO 需要 pop 的數量
    
    output logic [31:0] ipsum_need_pop_matrix_o, // 每個 ipsum FIFO 需要 pop 的訊號
    output logic [31:0] ipsum_pop_num_matrix_o [31:0], // 每個 ipsum FIFO 需要 pop 的數量
    
    output logic [31:0] opsum_need_push_matrix_o, // 每個 opsum FIFO 需要 push 的訊號
    output logic [31:0] opsum_push_num_matrix_o [31:0], // opsum only need push 1 time

    output logic normal_loop_done_o // normal loop 完成訊號
);
    typedef enum logic [1:0] {
        IDLE,
        SET_NUM,
        WAIT_DONE,
        DONE
    } state_e;

    state_e nl_cs, nl_ns;

    //========================================================
    // 狀態轉移
    //========================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            nl_cs <= IDLE;
        else
            nl_cs <= nl_ns;
    end

    always_comb begin
        case (nl_cs)
            IDLE:begin
                if(normal_loop_state_i)
                    nl_ns = SET_NUM;
                else 
                    nl_ns = IDLE;
            end
            SET_NUM: begin
                nl_ns = WAIT_DONE;
            end
            WAIT_DONE: begin
                if(&ifmap_fifo_done_matrix_i && &ipsum_fifo_done_matrix_i && &opsum_fifo_done_matrix_i)
                    nl_ns = DONE;
                else
                    nl_ns = WAIT_DONE;
            end
            DONE:
                nl_ns = IDLE;
            default:
                nl_ns = IDLE;
        endcase
    end
assign normal_loop_done_o = (nl_cs == DONE);

//========================================================
// 根據 layer_type 決定每個 FIFO 要 pop 幾次
//========================================================
integer i, j;
logic [31:0] real_num_with_pad;
assign real_num_with_pad = in_C_i + pad_R_i + pad_L_i; // 考慮 padding 的實際數量
always_comb begin
    if (nl_cs == SET_NUM) begin
        case (layer_type_i)
            `POINTWISE: begin
                for(j = 0; j < 32; j++)begin
                    ifmap_pop_num_matrix_o[j] = tile_n_i - 32'd1; // preheat pointwise pop 1 
                end
            end
            `DEPTHWISE: begin
                ifmap_pop_num_matrix_o[0] = real_num_with_pad - 32'd3; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[1] = real_num_with_pad - 32'd3; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[2] = real_num_with_pad - 32'd3; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[3] = real_num_with_pad - 32'd6; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[4] = real_num_with_pad - 32'd6; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[5] = real_num_with_pad - 32'd6; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[6] = real_num_with_pad - 32'd9; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[7] = real_num_with_pad - 32'd9; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[8] = real_num_with_pad - 32'd9; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[9] = real_num_with_pad - 32'd12; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[10] = real_num_with_pad - 32'd12; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[11] = real_num_with_pad - 32'd12; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[12] = real_num_with_pad - 32'd15; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[13] = real_num_with_pad - 32'd15; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[14] = real_num_with_pad - 32'd15; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[15] = real_num_with_pad - 32'd18; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[16] = real_num_with_pad - 32'd18; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[17] = real_num_with_pad - 32'd18; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[18] = real_num_with_pad - 32'd21; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[19] = real_num_with_pad - 32'd21; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[20] = real_num_with_pad - 32'd21; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[21] = real_num_with_pad - 32'd24; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[22] = real_num_with_pad - 32'd24; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[23] = real_num_with_pad - 32'd24; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[24] = real_num_with_pad - 32'd27; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[25] = real_num_with_pad - 32'd27; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[26] = real_num_with_pad - 32'd27; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[27] = real_num_with_pad - 32'd30; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[28] = real_num_with_pad - 32'd30; // preheat depthwise pop all
                ifmap_pop_num_matrix_o[29] = real_num_with_pad - 32'd30; // preheat depthwise pop all
            end
            `STANDARD: begin
                for(j = 0; j < 32; j++)begin
                    ifmap_pop_num_matrix_o[j] = real_num_with_pad - 32'd3; // preheat standard pop all
                end
            end
            `LINEAR: begin
                for(j = 0; j < 32; j++)begin
                    ifmap_pop_num_matrix_o[j] = tile_n_i - 32'd1; // preheat linear pop all
                end
            end
            default: begin
                for(j = 0; j < 32; j++)begin
                    ifmap_pop_num_matrix_o[j] = 32'd0; // preheat pointwise pop 1 
                end
            end
        endcase

    end
    else begin
        for (i = 0; i < 32; i++) begin
            ifmap_pop_num_matrix_o[i]  = 32'd0; 
        end
    end

end

integer i1, j1;
always_comb begin
    if ((nl_cs == SET_NUM)) begin
        case (layer_type_i)
            `POINTWISE: begin
                ipsum_pop_num_matrix_o[0] = On_real_i - 32'd1; //* preheat pop 1
                for(j1 = 1; j1 < 32; j1++)begin
                    ipsum_pop_num_matrix_o[j1] = On_real_i;
                end
            end
            `DEPTHWISE: begin
                ipsum_pop_num_matrix_o[0] = On_real_i - 32'd1; //* preheat pop 1
                for(j1 = 1; j1 < 10; j1++)begin
                    ipsum_pop_num_matrix_o[j1] = On_real_i;
                end
            end
            `STANDARD: begin
                ipsum_pop_num_matrix_o[0] = On_real_i - 32'd1; //* preheat pop 1
                for(j1 = 1; j1 < 10; j1++)begin
                    ipsum_pop_num_matrix_o[j1] = On_real_i;
                end
            end
            `LINEAR: begin
                ipsum_pop_num_matrix_o[0] = On_real_i - 32'd1; //* preheat pop 1
                for(j1 = 1; j1 < 32; j1++)begin
                    ipsum_pop_num_matrix_o[j1] = On_real_i;
                end
            end
        endcase
    end
    else begin
        for (i1 = 0; i1 < 32; i1++) begin
            ipsum_pop_num_matrix_o[i1]  = 32'd0;
        end
    end

end

integer i2, j2;
always_comb begin
    if ((nl_cs == SET_NUM)) begin
        case (layer_type_i)
            `POINTWISE: begin
                for(j2 = 0; j2 < 32; j2++)begin
                    opsum_push_num_matrix_o[j2] = On_real_i;
                end
            end
            `DEPTHWISE: begin
                for(j2 = 0; j2 < 10; j2++)begin
                    opsum_push_num_matrix_o[j2] = out_C_i;
                end
            end
            `STANDARD: begin
                for(j2 = 0; j2 < 10; j2++)begin
                    opsum_push_num_matrix_o[j2] = out_C_i;
                end
            end
            `LINEAR: begin
                for(j2 = 0; j2 < 32; j2++)begin
                    opsum_push_num_matrix_o[j2] = On_real_i;
                end
            end
            default: begin
                for(j2 = 0; j2 < 32; j2++)begin
                    opsum_push_num_matrix_o[j2] = 32'd0;
                end
            end
        endcase

    end
    else begin
        for (i2 = 0; i2 < 32; i2++) begin
            opsum_push_num_matrix_o[i2]  = 32'd0;
        end
    end

end


always_comb begin
    if (nl_cs == SET_NUM) 
        case (layer_type_i)
            `POINTWISE: ifmap_need_pop_matrix_o = 32'hFFFF_FFFF; // preheat pointwise pop 1 
            `DEPTHWISE: ifmap_need_pop_matrix_o = 32'h3FFF_FFFF; // preheat depthwise pop all
            `STANDARD: ifmap_need_pop_matrix_o = 32'h3FFF_FFFF; // 30
            `LINEAR: ifmap_need_pop_matrix_o = 32'hFFFF_FFFF; // preheat linear pop all
            default: ifmap_need_pop_matrix_o = 32'b0; // preheat pointwise pop 1
        endcase
    else 
        ifmap_need_pop_matrix_o = 32'b0;
end

always_comb begin
    if (nl_cs == SET_NUM) 
        case (layer_type_i)
            `POINTWISE: ipsum_need_pop_matrix_o = 32'hFFFF_FFFF; // preheat pointwise pop 1 
            `DEPTHWISE: ipsum_need_pop_matrix_o = 32'h0000_000A; // 10
            `STANDARD: ipsum_need_pop_matrix_o = 32'h0000_000A; // 10
            `LINEAR: ipsum_need_pop_matrix_o = 32'hFFFFFFFF; // preheat linear pop all
            default: ipsum_need_pop_matrix_o = 32'b0; // preheat pointwise pop 1
        endcase
    else 
        ipsum_need_pop_matrix_o = 32'b0;
end

always_comb begin
    if (nl_cs == SET_NUM) 
        case (layer_type_i)
            `POINTWISE:opsum_need_push_matrix_o = 32'hFFFF_FFFF; // preheat pointwise push 1
            `DEPTHWISE: opsum_need_push_matrix_o = 32'h0000_000A; //  10 
            `STANDARD: opsum_need_push_matrix_o = 32'h0000_000A; // 
            `LINEAR: opsum_need_push_matrix_o = 32'hFFFFFFFF; // preheat linear push all
            default: opsum_need_push_matrix_o = 32'b0; // preheat pointwise push 1
        endcase
    else 
        opsum_need_push_matrix_o = 32'b0;
end


endmodule
