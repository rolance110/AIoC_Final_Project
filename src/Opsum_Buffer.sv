`define ROW_NUM 32

module Opsum_buffer(
    input clk,
    input reset,
    input [`ROW_NUM*16 - 1:0] psum_in,//from Reducer
    input [`ROW_NUM - 1:0] output_en,

    output logic [`ROW_NUM*16 - 1:0] psum_out//send to GLB
);

  // 32 independent 4-deep, 16-bit FIFOs
  logic [15:0] fifo [0:`ROW_NUM-1][0:3];
  // --------------------------------------------------
  // TODO 選擇哪幾個ROW要輸出給GLB，然後如果en=0，則輸出0
  //      最後一次組成一個ROW_NUM * 16bit送回去GLB儲存
  //      每個cycle都會送回去，因為即便送回去是0，反正做累加沒影響
  // --------------------------------------------------
  genvar r;
  generate
    for (r = 0; r < `ROW_NUM; r = r + 1) begin : ROW_FIFO
      // shift‐register FIFO
      always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
          fifo[r][0] <= 16'd0;
          fifo[r][1] <= 16'd0;
          fifo[r][2] <= 16'd0;
          fifo[r][3] <= 16'd0;
        end else begin
          // stage 0: only push when output_en[r]=1
          fifo[r][0] <= output_en[r]
                          ? psum_in[r*16 +: 16]
                          : 16'd0;
          // shift down
          fifo[r][1] <= fifo[r][0];
          fifo[r][2] <= fifo[r][1];
          fifo[r][3] <= fifo[r][2];
        end
      end

      // oldest entry out
      assign psum_out[r*16 +: 16] = fifo[r][3];
    end
  endgenerate

endmodule