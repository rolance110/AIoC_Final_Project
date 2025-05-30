`define ROW_NUM 32

module Ipsum_buffer(
    input clk,
    input reset,
    input [`ROW_NUM - 1:0] ipsum_in,//from GLB
    input store_ipsum_f,//開始存GLB送過來的data_in signal
    input ipsum_out_f,//開始輸出到Reducer來累加

    output logic [`ROW_NUM*16 - 1:0] ipsum_out//send to Reducer
);
  // --------------------------------------------------
  // TODO:
  // 因為一次只能存32bit，所以一個FIFO需要2個cycle才能完成
  // 所以用cnt去決定這次是哪一個FIFO要存psum_in
  // --------------------------------------------------

  // 32 independent FIFOs, each 16-bit wide, depth = 4
  logic [15:0] fifo [0:`ROW_NUM-1][0:3];
  logic depth_cnt;//需要兩個cycle，可以塞滿一個FIFO的深度4
  logic [4:0] FIFO_cnt;//計算存到哪一個FIFO

  always_ff @(posedge clk or negedge reset) begin
    if(reset) begin
      depth_cnt <= 1'd0;
      FIFO_cnt <= 5'd0;
    end
    else if(store_ipsum_f) begin
      depth_cnt <= !depth_cnt;
      if(depth_cnt == 1'd1) begin
        if(FIFO_cnt == 5'd31)
          FIFO_cnt <= 5'd0;
        else
          FIFO_cnt <= FIFO_cnt + 5'd1;
      end
    end
    else begin
      depth_cnt <= 1'd0;
      FIFO_cnt <= 5'd0;
    end
  end

  genvar r;
  generate
    for (r = 0; r < `ROW_NUM; r = r + 1) begin : ROW_FIFO
      always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
          fifo[r][0] <= 16'd0;
          fifo[r][1] <= 16'd0;
          fifo[r][2] <= 16'd0;
          fifo[r][3] <= 16'd0;
        end 
        else if(store_ipsum_f && (FIFO_cnt == r)) begin
        //TODO: 按照第一次輸入的16bit為第一個的psum，後16bit為第二個，然後下一組相同
          fifo[r][0] <= ipsum_in[31:16];
          fifo[r][1] <= ipsum_in[15:0];
          fifo[r][2] <= fifo[r][0];
          fifo[r][3] <= fifo[r][1];
        end
        else if(ipsum_out_f)begin
          // push new ipsum_in into stage 0 each cycle
          fifo[r][0] <= 16'd0;
          // shift through depth-4 pipeline
          fifo[r][1] <= fifo[r][0];
          fifo[r][2] <= fifo[r][1];
          fifo[r][3] <= fifo[r][2];
        end
      end

      // output the oldest entry
      assign ipsum_out[r*16 +: 16] = fifo[r][3];
    end
  endgenerate

endmodule