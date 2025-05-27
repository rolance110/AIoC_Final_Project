`define COL_NUM 32

module Vertical_Buffer(
    input clk,
    input reset,
    input [`COL_NUM*8 - 1 : 0] ifmap_in,
    input ifmap_en,//用來決定是否要關掉，直到所有PE算完，在切換到下一個layer的ifmap

    output logic [`COL_NUM*8 - 1 : 0] ifmap_out
);

// 32 independent FIFOs, each 8-bit wide, depth = 4
logic [7:0] fifo [0:`COL_NUM-1][0:3];

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
      end else begin
        fifo[col][0] <= (ifmap_en) ? ifmap_in[col*8 +: 8] : 8'd0;
        fifo[col][1] <= fifo[col][0];
        fifo[col][2] <= fifo[col][1];
        fifo[col][3] <= fifo[col][2];
      end
    end

    // oldest entry out
    assign ifmap_out[col*8 +: 8] = fifo[col][3];
  end
endgenerate


endmodule