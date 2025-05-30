`define COL_NUM 32

module Vertical_Buffer(
    input clk,
    input reset,
    input store_ifmap_f,//儲存ifmap的信號，跟切換FSM的時間相同
    input [`COL_NUM - 1 : 0] ifmap_in,
    //input [`COL_NUM - 1 : 0] col_en,//用來決定是否要關掉，直到所有PE算完，在切換到下一個layer的ifmap
    input ifmap_out_f,//開始輸出FIFO內容的signal,在compute的時候開始拉為1，總共維持四個cycle

    output logic [`COL_NUM*8 - 1 : 0] ifmap_out
);

// 32 independent FIFOs, each 8-bit wide, depth = 4
logic [7:0] fifo [0:`COL_NUM-1][0:3];
logic [4:0] cnt;

always_ff @(posedge clk or negedge reset) begin
  if(reset)
    cnt <= 5'd0;
  else if(store_ifmap_f) begin
    if(cnt == 5'd31)
      cnt <= 5'd31;
    else
      cnt <= cnt + 5'd1;
  end
  else
    cnt <= 5'd0;
end

genvar col;

generate
  for (col = 0; col < `COL_NUM; col = col + 1) begin : COL_FIFO
    // shift-register style FIFO: on each cycle
    //  - fifo[col][0] takes new ifmap_in
    //  - fifo[col][i] takes previous fifo[col][i-1]
    // output = fifo[col][3] (oldest)
    always_ff @(posedge clk or posedge reset) begin
      if (reset) begin
        fifo[col][0] <= 8'd0;
        fifo[col][1] <= 8'd0;
        fifo[col][2] <= 8'd0;
        fifo[col][3] <= 8'd0;
      end 
      else if(store_ifmap_f && (col == cnt))begin
        fifo[col][0] <= ifmap_in[31:24];
        fifo[col][1] <= ifmap_in[23:16];
        fifo[col][2] <= ifmap_in[15:8];
        fifo[col][3] <= ifmap_in[7:0];
      end
      else if(ifmap_out_f) begin
        fifo[col][0] <= 8'd0;
        fifo[col][1] <= fifo[col][0];
        fifo[col][2] <= fifo[col][1];
        fifo[col][3] <= fifo[col][2];
      end
    end

    assign ifmap_out[col*8 +: 8] = fifo[col][3];

  end
endgenerate


endmodule