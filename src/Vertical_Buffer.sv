`define COL_NUM 32

module Vertical_Buffer(
    input clk,
    input reset,
    input [4:0] col_en,
    input [4:0] row_en,
    //TODO: DW signal
    input dw_first_f,
    input [1:0] DW_PW_sel, // 0 = pw, 1 = dw
    input [4:0] dw_open_start_num, // 5-bit to accommodate values up to 31
    //handshake 
    input ready_if,
    input valid_if,
    input [`COL_NUM - 1 : 0] ifmap_in,
    //input [`COL_NUM - 1 : 0] col_en,//用來決定是否要關掉，直到所有PE算完，在切換到下一個layer的ifmap
    input ifmap_out_f,//開始輸出FIFO內容的signal,在compute的時候開始拉為1，總共維持四個cycle

    output logic [`COL_NUM*8 - 1 : 0] ifmap_out
);

// 32 independent FIFOs, each 8-bit wide, depth = 4
logic [7:0] fifo [0:`COL_NUM-1][0:3];
logic [4:0] cnt;

wire handshake_f = ready_if && valid_if;

always_ff @(posedge clk) begin
  if(reset)
    cnt <= 5'd0;
  else begin
    case(DW_PW_sel)
      1'd0: begin
        if(handshake_f) begin
          if(dw_first_f) begin//每次的第一次
            if(cnt == 5'd0)//處理第一次開始cnt = 0
              cnt <= dw_open_start_num; // start from the last 3 cycles of the previous layer
            else if(cnt == row_en)
              cnt <= dw_open_start_num - 5'd3;
            else
              cnt <= cnt + 5'd1;
          end
          else begin
            if(cnt == col_en)
              cnt <= 5'd0;
            else
              cnt <= cnt + 5'd1;
          end
        end
      end
      1'd1: begin
        if(handshake_f) begin
          if(cnt == col_en)
            cnt <= 5'd0;
          else
            cnt <= cnt + 5'd1;
        end
      end
    endcase
  end
end

genvar col;

generate
  for (col = 0; col < `COL_NUM; col = col + 1) begin : COL_FIFO
    // shift-register style FIFO: on each cycle
    //  - fifo[col][0] takes new ifmap_in
    //  - fifo[col][i] takes previous fifo[col][i-1]
    // output = fifo[col][3] (oldest)
    always_ff @(posedge clk) begin
      if (reset) begin
        fifo[col][0] <= 8'd0;
        fifo[col][1] <= 8'd0;
        fifo[col][2] <= 8'd0;
        fifo[col][3] <= 8'd0;
      end 
      else if(handshake_f && (col == cnt))begin
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