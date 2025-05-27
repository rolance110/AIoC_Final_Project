`define ROW_NUM 32

module Opsum_buffer(
    input clk,
    input reset,
    input [`ROW_NUM*16 - 1:0] psum_in,//from GLB

    output logic [`ROW_NUM*16 - 1:0] psum_out//send to Reducer
);
  // --------------------------------------------------
  // TODO 如果是跟ifmap同步的話，要慢一個cycle，因為在PE會慢一個cycle
  //      如果這裡沒有多慢一個cycle的話，會導致ipsum+計算結果會累積到錯誤的位子
  // --------------------------------------------------

  // 32 independent FIFOs, each 16-bit wide, depth = 4
  logic [15:0] fifo [0:`ROW_NUM-1][0:3];

  genvar r;
  generate
    for (r = 0; r < `ROW_NUM; r = r + 1) begin : ROW_FIFO
      always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
          fifo[r][0] <= 16'd0;
          fifo[r][1] <= 16'd0;
          fifo[r][2] <= 16'd0;
          fifo[r][3] <= 16'd0;
        end else begin
          // push new psum_in into stage 0 each cycle
          fifo[r][0] <= psum_in[r*16 +: 16];
          // shift through depth-4 pipeline
          fifo[r][1] <= fifo[r][0];
          fifo[r][2] <= fifo[r][1];
          fifo[r][3] <= fifo[r][2];
        end
      end

      // output the oldest entry
      assign psum_out[r*16 +: 16] = fifo[r][3];
    end
  endgenerate

endmodule