`define ROW_NUM 32

module Ipsum_buffer(
    input clk,
    input reset,
    //handshake
    input ready_ip,
    input valid_ip,
    //剛開始啟動PE array
    input [5:0] ip_time_4,
    input first_f, //用來決定是否是第一個8個cycle的weight load
    //要關閉PE array
    input [4:0] close_start_num,//用來決定關閉PE array的ROW起始位子
    input close_f,//用來決定是否要關閉PE array

    input [5:0] row_en,//用來決定有幾個ROW要使用，從0開始算
    input [`ROW_NUM - 1:0] ipsum_in,//from GLB
    input ipsum_out_f,//開始輸出到Reducer來累加

    output logic [`ROW_NUM*16 - 1:0] ipsum_out//send to Reducer
);
// --------------------------------------------------
// TODO:
// 因為一次只能存32bit，所以一個FIFO需要2個cycle才能完成
// 所以用cnt去決定這次是哪一個FIFO要存psum_in
// 需要根據row_en來決定有幾個ROW要使用
// 如果是第一個8個cycle的weight load，則需要根據ip_time_4來決定有幾個FIFO要使用
// --------------------------------------------------

// 32 independent FIFOs, each 16-bit wide, depth = 4
logic [15:0] fifo [0:`ROW_NUM-1][0:3];
logic depth_cnt;//需要兩個cycle，可以塞滿一個FIFO的深度4
logic [4:0] FIFO_cnt;//計算存到哪一個FIFO

wire handshake_f = ready_ip && valid_ip;
wire [4:0] ip_time_4_cnt = ip_time_4 - 5'd1;//因為需要從0開始算，所以減1

wire [4:0] row_num = row_en - 5'd1;

always_ff @(posedge clk) begin
    if(reset) begin
        depth_cnt <= 1'd0;
        FIFO_cnt <= 5'd0;
    end
    else if(first_f) begin
        if(handshake_f) begin
            depth_cnt <= !depth_cnt;
            if(depth_cnt == 1'd1) begin
                if(FIFO_cnt == (ip_time_4_cnt))
                    FIFO_cnt <= 5'd0;
                else
                    FIFO_cnt <= FIFO_cnt + 5'd1;
            end
        end
    end
    else if(close_f) begin
        if(handshake_f) begin
            depth_cnt <= !depth_cnt;
            if(depth_cnt == 1'd1) begin
                if(FIFO_cnt == row_num)
                    FIFO_cnt <= close_start_num + 5'd4;
                else
                    FIFO_cnt <= FIFO_cnt + 5'd1;
            end
        end
    end
    else if(handshake_f) begin
        depth_cnt <= !depth_cnt;
        if(depth_cnt == 1'd1) begin
            if(FIFO_cnt == row_num)
                FIFO_cnt <= 5'd0;
            else
                FIFO_cnt <= FIFO_cnt + 5'd1;
      end
    end
end

genvar r;
generate
    for (r = 0; r < `ROW_NUM; r = r + 1) begin : ROW_FIFO
      always_ff @(posedge clk) begin
        if (reset) begin
          fifo[r][0] <= 16'd0;
          fifo[r][1] <= 16'd0;
          fifo[r][2] <= 16'd0;
          fifo[r][3] <= 16'd0;
        end 
        else if(handshake_f && (FIFO_cnt == r)) begin
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