//===========================================================================
// Module: L2C_normal_loop
// Description: 正式卷積資料流階段 (normal loop)，按 row 逐步進行 ifmap→PE→ipsum→opsum
//===========================================================================
module L2C_normal_loop(
    input logic clk,
    input logic rst_n,

    input logic normal_loop_state_i, // 啟動 normal loop
    input logic [1:0] layer_type_i,  


//* Tile Infomation
    input logic [31:0] tile_n_i, // tile 的數量

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

//========================================================
// 根據 layer_type 決定每個 FIFO 要 pop 幾次
//========================================================
integer i, j;
always_comb begin
    if (nl_cs == SET_NUM) begin
        for(j = 0; j < 32; j++)begin
            ifmap_pop_num_matrix_o[j] = 32'd1; // fixme: 代定 
        end
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
        for(j1 = 0; j1 < 32; j1++)begin
            ipsum_pop_num_matrix_o[j1] = 32'd1;// fixme: 代定
        end
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
        for(j2 = 0; j2 < 32; j2++)begin
            opsum_push_num_matrix_o[j2] = 32'd1;// fixme: 代定
        end
    end
    else begin
        for (i2 = 0; i2 < 32; i2++) begin
            opsum_push_num_matrix_o[i2]  = 32'd0;
        end
    end

end


always_comb begin
    if (nl_cs == SET_NUM) 
        ifmap_need_pop_matrix_o = 32'hFFFF_FFFF;
    else 
        ifmap_need_pop_matrix_o = 32'b0;
end

always_comb begin
    if (nl_cs == SET_NUM) 
        ipsum_need_pop_matrix_o = 32'hFFFF_FFFF;
    else 
        ipsum_need_pop_matrix_o = 32'b0;
end

always_comb begin
    if (nl_cs == SET_NUM) 
        opsum_need_push_matrix_o = 32'hFFFF_FFFF;
    else 
        opsum_need_push_matrix_o = 32'b0;
end

assign preheat_done_o = (nl_cs == DONE);

endmodule
