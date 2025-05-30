`define COL_NUM 32
`define ROW_NUM 32

module Horizontal_Buffer(
    input clk,
    input reset,
    input store_weight_f,
    input [5:0] weight_en,
    input [`ROW_NUM - 1 : 0] weight_in,//改成32bit，一個ROW weight需要8個cycle才能填滿

    output [`ROW_NUM*`COL_NUM*8 - 1 : 0] weight_out
);
// --------------------------------------------------
// TODO:
// 因為每次輸入32bit，一個ROW的weight需要8個cycle才能完成
// weight_en會說明有幾個ROW被放weight，依照外面FSM被切換的時間(不一定32ROW被填滿)
// --------------------------------------------------
// storage for each PE’s weight
logic [31:0] weight_mem [0:`ROW_NUM-1][0:7];
logic [2:0] col_cnt;
logic [5:0] row_cnt;

always_ff @(posedge clk or negedge reset) begin
    if(reset) begin
       col_cnt <= 3'd0;
       row_cnt <= 6'd0;
    end
    else if(store_weight_f) begin
        if(col_cnt == 3'd7) begin
            col_cnt <= 3'd0;
            if(row_cnt == weight_en - 6'd1)//數量相同就可以歸零
                row_cnt <= 6'd0;
            else
                row_cnt <= row_cnt + 6'd1;//不怕她爆掉，就給他在else的時候清0即可
        end
        else
            col_cnt <= col_cnt + 3'd1;
    end
    else begin
        row_cnt <= 6'd0;
        col_cnt <= 3'd0;
    end
end

always_ff @(posedge clk or negedge reset) begin
   if(reset) begin
     for(int i=0;i<32;i=i+1) begin
       for(int j=0;j<8;j=j+1) begin
         weight_mem[i][j] <= 32'd0;
       end
      end
   end
   else if(store_weight_f) begin
      weight_mem[row_cnt][col_cnt] <= weight_in;
   end
end

genvar r, c;
generate
    for(r=0;r<`ROW_NUM;r=r+1) begin : ROWS
        for(c=0;c<8;c=c+1) begin : COLS
            assign weight_out[(r*256)+(c*32) +: 32] = weight_mem[r][c];
        end
    end
endgenerate

endmodule