//===========================================================================
// Module: L2C_preheat
// Description: 控制每個 ifmap_fifo 將資料推送至對應的 PE row，達成 preheat
//===========================================================================
`include "../../../include/define.svh"
module L2C_preheat #(
    parameter int NUM_IFMAP_FIFO = 32
)(
    input  logic               clk,
    input  logic               rst_n,
    input  logic               start_preheat_i,
    input  logic [1:0]         layer_type_i,    // 00: pw, 01: dw, others: future
    input  logic [31:0] ifmap_fifo_done_i,

    output logic [31:0] ifmap_need_pop_o,
    output logic [4:0] ifmap_pop_num_o [31:0],
    output logic preheat_done_o
);

    typedef enum logic [1:0] {
        IDLE,
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
                    ns = WAIT_DONE;
                else 
                    ns = IDLE;
            end
            WAIT_DONE: begin
                if(&ifmap_fifo_done_i)
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
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 32; i++)
            ifmap_pop_num_o[i]  <= 5'd0;
    end 
    else if ((cs == WAIT_DONE) && (layer_type_i == `POINTWISE)) begin
        for(j = 0; j < 32; j++)begin
            ifmap_pop_num_o[j] <= 5'd1;
        end
    end
    else if ((cs == WAIT_DONE) && (layer_type_i == `DEPTHWISE)) begin
        ifmap_pop_num_o[0]  <= 5'd3;
        ifmap_pop_num_o[1]  <= 5'd3;
        ifmap_pop_num_o[2]  <= 5'd3;

        ifmap_pop_num_o[3]  <= 5'd6;
        ifmap_pop_num_o[4]  <= 5'd6;
        ifmap_pop_num_o[5]  <= 5'd6;

        ifmap_pop_num_o[6]  <= 5'd9;
        ifmap_pop_num_o[7]  <= 5'd9;
        ifmap_pop_num_o[8]  <= 5'd9;

        ifmap_pop_num_o[9]  <= 5'd12;
        ifmap_pop_num_o[10] <= 5'd12;
        ifmap_pop_num_o[11] <= 5'd12;

        ifmap_pop_num_o[12] <= 5'd15;
        ifmap_pop_num_o[13] <= 5'd15;
        ifmap_pop_num_o[14] <= 5'd15;

        ifmap_pop_num_o[15] <= 5'd18;
        ifmap_pop_num_o[16] <= 5'd18;
        ifmap_pop_num_o[17] <= 5'd18;

        ifmap_pop_num_o[18] <= 5'd21;
        ifmap_pop_num_o[19] <= 5'd21;
        ifmap_pop_num_o[20] <= 5'd21;

        ifmap_pop_num_o[21] <= 5'd24;
        ifmap_pop_num_o[22] <= 5'd24;
        ifmap_pop_num_o[23] <= 5'd24;

        ifmap_pop_num_o[24] <= 5'd27;
        ifmap_pop_num_o[25] <= 5'd27;
        ifmap_pop_num_o[26] <= 5'd27;   

        ifmap_pop_num_o[27] <= 5'd30;
        ifmap_pop_num_o[28] <= 5'd30;
        ifmap_pop_num_o[29] <= 5'd30;
    end
    else if (cs == DONE) begin
        for (i = 0; i < NUM_IFMAP_FIFO; i++) begin
            ifmap_pop_num_o[i]  <= 5'd0;
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) 
        ifmap_need_pop_o <= 32'd0;
    else if (cs == WAIT_DONE) 
        ifmap_need_pop_o <= 32'hFFFF_FFFF;
    else 
        ifmap_need_pop_o <= 32'b0;
end



assign preheat_done_o = (cs == DONE);

endmodule
