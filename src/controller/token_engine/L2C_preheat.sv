//===========================================================================
// Module: L2C_preheat
// Description: 控制每個 ifmap_fifo 將資料推送至對應的 PE row，達成 preheat
//===========================================================================
// `include "../../../include/define.svh"
module L2C_preheat #(
    parameter int NUM_IFMAP_FIFO = 32
)(
    input  logic               clk,
    input  logic               rst_n,
    input  logic               start_preheat_i,
    input  logic [1:0]         layer_type_i,    // 00: pw, 01: dw, others: future
    input  logic [31:0] ifmap_fifo_done_matrix_i,
    input logic [31:0] ipsum_fifo_done_matrix_i,
    
    output logic [31:0] ifmap_need_pop_o,
    output logic [31:0] ifmap_pop_num_o [31:0],
    output logic [31:0] ipsum_need_pop_o,
    output logic [31:0] ipsum_pop_num_o [31:0],


    output logic preheat_done_o
);

    typedef enum logic [1:0] {
        IDLE,
        SET_POP_NUM,
        WAIT_DONE,
        DONE
    } state_e;

    state_e cs, ns;

    //========================================================
    // 狀態轉移
    //========================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cs <= IDLE;
        else
            cs <= ns;
    end

    always_comb begin
        case (cs)
            IDLE:begin
                if(start_preheat_i)
                    ns = SET_POP_NUM;
                else 
                    ns = IDLE;
            end
            SET_POP_NUM: begin
                ns = WAIT_DONE;
            end
            WAIT_DONE: begin
                if(&ifmap_fifo_done_matrix_i && &ipsum_fifo_done_matrix_i)
                    ns = DONE;
                else
                    ns = WAIT_DONE;
            end
            DONE:
                ns = IDLE;
            default:
                ns = IDLE;
        endcase
    end

//========================================================
// 根據 layer_type 決定每個 FIFO 要 pop 幾次
//========================================================
integer i, j;
always_comb begin
    if ((cs == SET_POP_NUM) && (layer_type_i == `POINTWISE)) begin
        for(j = 0; j < 32; j++)begin
            ifmap_pop_num_o[j] = 32'd1;
        end
    end
    else if ((cs == SET_POP_NUM) && (layer_type_i == `DEPTHWISE)) begin
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
    else begin
        for (i = 0; i < NUM_IFMAP_FIFO; i++) begin
            ifmap_pop_num_o[i]  = 32'd0;
        end
    end

end

integer i1, j1;
always_comb begin
    if ((cs == SET_POP_NUM)) begin
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




always_comb begin
    if (cs == SET_POP_NUM) 
        ifmap_need_pop_o = 32'hFFFF_FFFF;
    else 
        ifmap_need_pop_o = 32'b0;
end

always_comb begin
    if (cs == SET_POP_NUM) 
        ipsum_need_pop_o = 32'hFFFF_FFFF;
    else 
        ipsum_need_pop_o = 32'b0;
end

assign preheat_done_o = (cs == DONE);

endmodule
