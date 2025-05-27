`define COL_NUM 32
`define ROW_NUM 32

module Horizontal_Buffer(
    input clk,
    input reset,
    input [`ROW_NUM - 1 : 0] weight_en,
    input [`ROW_NUM*`COL_NUM*8 - 1 : 0] weight_in,

    output logic [`ROW_NUM*`COL_NUM*8 - 1 : 0] weight_out
);
  // --------------------------------------------------
  // TODO 一次會更新同一個ROW的所有COL weights，根據enable來看哪幾個ROW需要被更新
  // --------------------------------------------------
  // storage for each PE’s weight
  logic [7:0] weight_mem [0:`ROW_NUM-1][0:`COL_NUM-1];

  genvar r, c;
  generate
    for (r = 0; r < `ROW_NUM; r = r + 1) begin : ROW_LOOP
      for (c = 0; c < `COL_NUM; c = c + 1) begin : COL_LOOP
        // fully-unrolled always_ff: one for each (r,c)
        always_ff @(posedge clk or posedge reset) begin
          if (reset) 
            weight_mem[r][c] <= 8'd0;
          else if (weight_en[r])
            weight_mem[r][c] <= weight_in[((r*`COL_NUM + c)*8) +: 8];
        end

        // flatten out
        assign weight_out[((r*`COL_NUM + c)*8) +: 8] = weight_mem[r][c];
      end
    end
  endgenerate

endmodule