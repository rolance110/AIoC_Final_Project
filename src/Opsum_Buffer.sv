`define ROW_NUM 32

module Opsum_buffer(
    input clk,
    input reset,
    input read_opsum_f,//維持時間根據外面的FSM決定
    input store_compute_f,//告知存計算結果
    input [`ROW_NUM*16 - 1:0] opsum_in,//from Reducer
    //input [4:0] output_en,

    output logic [`ROW_NUM-1:0] opsum_out//send to GLB
);

  // 32 independent 4-deep, 16-bit FIFOs
  logic [15:0] fifo [0:`ROW_NUM-1][0:3];
  logic [3:0] cnt;
  // --------------------------------------------------
  // TODO 因為一次只能寫32bit回去，所以需要16個cycle才能把32個ROW
  //      的FIFO第一筆寫回，所以要控制FIFO每16個cycle才能往前推進一次
  //      否則會被蓋掉data
  // --------------------------------------------------

  always_ff @(posedge clk or negedge reset) begin
    if(reset)
      cnt <= 4'd0;
    else if(read_opsum_f) begin
      if(cnt == 4'd15)
        cnt <= 4'd0;
      else
        cnt <= cnt + 4'd1;
    end
    else
      cnt <= 4'd0;
  end

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
        end 
        else if(read_opsum_f && (cnt == 4'd15)) begin//開始輸出，每16個cycle往前推進一次
          fifo[r][0] <= 16'd0;
          fifo[r][1] <= fifo[r][0];
          fifo[r][2] <= fifo[r][1];
          fifo[r][3] <= fifo[r][2];
        end
        else if(store_compute_f)begin
          fifo[r][0] <= opsum_in[r*16 +: 16];
          // shift down
          fifo[r][1] <= fifo[r][0];
          fifo[r][2] <= fifo[r][1];
          fifo[r][3] <= fifo[r][2];
        end
      end

    end
  endgenerate

  always_comb begin
    if(read_opsum_f) begin
      case(cnt)
        4'd0: opsum_out = {fifo[1][3], fifo[0][3]};
        4'd1: opsum_out = {fifo[3][3], fifo[2][3]};
        4'd2: opsum_out = {fifo[5][3], fifo[4][3]};
        4'd3: opsum_out = {fifo[7][3], fifo[6][3]};
        4'd4: opsum_out = {fifo[9][3], fifo[8][3]};
        4'd5: opsum_out = {fifo[11][3], fifo[10][3]};
        4'd6: opsum_out = {fifo[13][3], fifo[12][3]};
        4'd7: opsum_out = {fifo[15][3], fifo[14][3]};
        4'd8: opsum_out = {fifo[17][3], fifo[16][3]};
        4'd9: opsum_out = {fifo[19][3], fifo[18][3]};
        4'd10: opsum_out = {fifo[21][3], fifo[20][3]};
        4'd11: opsum_out = {fifo[23][3], fifo[22][3]};
        4'd12: opsum_out = {fifo[25][3], fifo[24][3]};
        4'd13: opsum_out = {fifo[27][3], fifo[26][3]};
        4'd14: opsum_out = {fifo[29][3], fifo[28][3]};
        4'd15: opsum_out = {fifo[31][3], fifo[30][3]};
      endcase
    end
    else
      opsum_out = 32'd0;
  end

endmodule