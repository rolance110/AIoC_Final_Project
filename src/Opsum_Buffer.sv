`define ROW_NUM 32

module Opsum_buffer(
    input clk,
    input reset,
    //handshake
    input ready_op,
    input valid_op,
    //PW
    //first 8 cycle
    input first_f,
    input [5:0] ip_time_4,//用來決定有幾個ROW要使用
    //close PE array
    //DW
    input [1:0] pass_layer_type,//用來決定是DW還是PW
    input [1:0] stride,
    input [1:0] dw_input_num,
    input dw_open_f,
    input [1:0] dw_out_times,//輸出幾筆opsum

    input store_opsum_f,//告知存計算結果
    input signed [`ROW_NUM*16 - 1:0] opsum_in,//from Reducer
    input [5:0] row_en,

    output logic signed [`ROW_NUM-1:0] opsum_out//send to GLB
);

  // 32 independent 4-deep, 16-bit FIFOs
  logic [15:0] fifo [0:`ROW_NUM-1][0:3];
  logic [5:0] cnt;

  logic [5:0] row_num;
  logic handshake_f;
  logic [5:0] first_8_cnt;
  logic [5:0] dw_out_cnt;
  
  always_comb begin
    row_num = (row_en << 1) - 6'd1;
    handshake_f = ready_op && valid_op;
    first_8_cnt = (ip_time_4 << 1) - 6'd1;
    dw_out_cnt = (row_en - 6'd1) << 1;
  end
  // --------------------------------------------------
  // TODO: 因為一次只能寫32bit回去，所以需要16個cycle才能把32個ROW
  //      的FIFO第一筆寫回，所以要控制FIFO每16個cycle才能往前推進一次
  //      否則會被蓋掉data
  // --------------------------------------------------

  logic depth_cnt;

  always_ff @(posedge clk) begin
    if(reset) begin
      cnt <= 6'd0;
      depth_cnt <= 1'd0;
    end
    else begin
      case(pass_layer_type)
        2'd1:begin
          if(handshake_f) begin
            if(dw_open_f) begin
              if(cnt == ((row_en << 1) - 6'd6))//最多10次
                  cnt <= 6'd0;
              else
                  cnt <= cnt + 6'd6;
            end
            else begin
              case(stride)
                2'd1:begin//stride = 1
                  if(dw_input_num > 2'd2) begin
                      depth_cnt <= !depth_cnt;
                      if(!depth_cnt) begin
                        if(cnt == (dw_out_cnt - 6'd3))//row_en從0開始算，所以要減3
                          cnt <= 6'd0;
                        else
                          cnt <= cnt + 6'd1;
                      end
                      else begin
                        depth_cnt <= !depth_cnt;
                        if(cnt == (dw_out_cnt - 6'd3))
                          cnt <= 6'd0;
                        else
                          cnt <= cnt + 6'd5;
                      end
                  end
                  else begin
                    depth_cnt <= 1'd0;
                      if(cnt == ((row_en << 1) - 6'd6))
                        cnt <= 6'd0;
                      else
                        cnt <= cnt + 6'd6;
                  end
                end
                2'd2:begin//TODO: stride = 2
                  if(cnt == (dw_out_cnt - 6'd6))
                      cnt <= 6'd0;
                  else
                      cnt <= cnt + 6'd6;
                end
                default: begin
                  cnt <= 6'd0; // Default case to handle unexpected values
                end
              endcase
            end
          end
        end
        2'd0:begin
          if(first_f) begin//前8個cycle的執行
            if(handshake_f) begin
              if(cnt == (first_8_cnt))//7 - 15 - 23 - 31 - 39 - 47 - 55 - 63
                cnt <= 6'd0;
              else
                cnt <= cnt + 6'd1;
            end
          end
          else if(handshake_f) begin
            if(cnt == row_num)
              cnt <= 6'd0;
            else
              cnt <= cnt + 6'd1;
          end
        end
        default: begin
          cnt <= 6'd0; // Default case to handle unexpected values
        end
      endcase
    end
  end


  genvar r;
  generate
    for (r = 0; r < `ROW_NUM; r = r + 1) begin : ROW_FIFO
      // shift‐register FIFO
      always_ff @(posedge clk) begin
        if (reset) begin
          fifo[r][0] <= 16'd0;
          fifo[r][1] <= 16'd0;          
          fifo[r][2] <= 16'd0;
          fifo[r][3] <= 16'd0;
        end 
        else if(store_opsum_f)begin//OKAY
          case(pass_layer_type)
            2'd1:begin
              if(dw_open_f) begin
                fifo[r][0] <= 16'd0;
                fifo[r][1] <= 16'd0;  
                fifo[r][2] <= 16'd0;
                fifo[r][3] <= opsum_in[r*16 +: 16];
              end
              else if((stride == 2'd2)) begin
                if(dw_out_times == 2'd2) begin//輸出一筆
                  fifo[r][0] <= 16'd0;
                  fifo[r][1] <= 16'd0;  
                  fifo[r][2] <= opsum_in[r*16 +: 16];
                  fifo[r][3] <= fifo[r][2];
                end
                else begin//輸出兩筆
                  fifo[r][0] <= 16'd0;
                  fifo[r][1] <= 16'd0;  
                  fifo[r][2] <= 16'd0;
                  fifo[r][3] <= opsum_in[r*16 +: 16];
                end
              end
              else if(dw_input_num > 2'd2) begin
                fifo[r][0] <= 16'd0;
                fifo[r][1] <= opsum_in[r*16 +: 16];
                fifo[r][2] <= fifo[r][1];
                fifo[r][3] <= fifo[r][2];
              end
              else if(dw_input_num == 2'd2) begin
                  fifo[r][0] <= 16'd0;
                  fifo[r][1] <= 16'd0;  
                  fifo[r][2] <= opsum_in[r*16 +: 16];
                  fifo[r][3] <= fifo[r][2];
              end
              else begin
                fifo[r][0] <= 16'd0;
                fifo[r][1] <= 16'd0;  
                fifo[r][2] <= 16'd0;
                fifo[r][3] <= opsum_in[r*16 +: 16];
              end
            end
            2'd0:begin
              fifo[r][0] <= opsum_in[r*16 +: 16];
              // shift down
              fifo[r][1] <= fifo[r][0];
              fifo[r][2] <= fifo[r][1];
              fifo[r][3] <= fifo[r][2];
            end
            default: begin
              fifo[r][0] <= 16'd0;
              fifo[r][1] <= 16'd0;  
              fifo[r][2] <= 16'd0;
              fifo[r][3] <= 16'd0; // Default case to avoid latches
            end
          endcase
        end
      end
    end
  endgenerate

  always_comb begin
    if(handshake_f) begin
      case(cnt)
        6'd0: opsum_out = {fifo[0][2], fifo[0][3]};
        6'd1: opsum_out = {fifo[0][0], fifo[0][1]};
        6'd2: opsum_out = {fifo[1][2], fifo[1][3]};
        6'd3: opsum_out = {fifo[1][0], fifo[1][1]};
        6'd4: opsum_out = {fifo[2][2], fifo[2][3]};
        6'd5: opsum_out = {fifo[2][0], fifo[2][1]};
        6'd6: opsum_out = {fifo[3][2], fifo[3][3]};
        6'd7: opsum_out = {fifo[3][0], fifo[3][1]};
        6'd8: opsum_out = {fifo[4][2], fifo[4][3]};
        6'd9: opsum_out = {fifo[4][0], fifo[4][1]};
        6'd10: opsum_out = {fifo[5][2], fifo[5][3]};
        6'd11: opsum_out = {fifo[5][0], fifo[5][1]};
        6'd12: opsum_out = {fifo[6][2], fifo[6][3]};
        6'd13: opsum_out = {fifo[6][0], fifo[6][1]};
        6'd14: opsum_out = {fifo[7][2], fifo[7][3]};
        6'd15: opsum_out = {fifo[7][0], fifo[7][1]};
        6'd16: opsum_out = {fifo[8][2], fifo[8][3]};
        6'd17: opsum_out = {fifo[8][0], fifo[8][1]};
        6'd18: opsum_out = {fifo[9][2], fifo[9][3]};
        6'd19: opsum_out = {fifo[9][0], fifo[9][1]};
        6'd20: opsum_out = {fifo[10][2], fifo[10][3]};
        6'd21: opsum_out = {fifo[10][0], fifo[10][1]};
        6'd22: opsum_out = {fifo[11][2], fifo[11][3]};
        6'd23: opsum_out = {fifo[11][0], fifo[11][1]};
        6'd24: opsum_out = {fifo[12][2], fifo[12][3]};
        6'd25: opsum_out = {fifo[12][0], fifo[12][1]};
        6'd26: opsum_out = {fifo[13][2], fifo[13][3]};
        6'd27: opsum_out = {fifo[13][0], fifo[13][1]};
        6'd28: opsum_out = {fifo[14][2], fifo[14][3]};
        6'd29: opsum_out = {fifo[14][0], fifo[14][1]};
        6'd30: opsum_out = {fifo[15][2], fifo[15][3]};
        6'd31: opsum_out = {fifo[15][0], fifo[15][1]};
        6'd32: opsum_out = {fifo[16][2], fifo[16][3]};
        6'd33: opsum_out = {fifo[16][0], fifo[16][1]};
        6'd34: opsum_out = {fifo[17][2], fifo[17][3]};
        6'd35: opsum_out = {fifo[17][0], fifo[17][1]};
        6'd36: opsum_out = {fifo[18][2], fifo[18][3]};
        6'd37: opsum_out = {fifo[18][0], fifo[18][1]};
        6'd38: opsum_out = {fifo[19][2], fifo[19][3]};
        6'd39: opsum_out = {fifo[19][0], fifo[19][1]};
        6'd40: opsum_out = {fifo[20][2], fifo[20][3]};
        6'd41: opsum_out = {fifo[20][0], fifo[20][1]};
        6'd42: opsum_out = {fifo[21][2], fifo[21][3]};
        6'd43: opsum_out = {fifo[21][0], fifo[21][1]};
        6'd44: opsum_out = {fifo[22][2], fifo[22][3]};
        6'd45: opsum_out = {fifo[22][0], fifo[22][1]};
        6'd46: opsum_out = {fifo[23][2], fifo[23][3]};
        6'd47: opsum_out = {fifo[23][0], fifo[23][1]};
        6'd48: opsum_out = {fifo[24][2], fifo[24][3]};
        6'd49: opsum_out = {fifo[24][0], fifo[24][1]};
        6'd50: opsum_out = {fifo[25][2], fifo[25][3]};
        6'd51: opsum_out = {fifo[25][0], fifo[25][1]};
        6'd52: opsum_out = {fifo[26][2], fifo[26][3]};
        6'd53: opsum_out = {fifo[26][0], fifo[26][1]};
        6'd54: opsum_out = {fifo[27][2], fifo[27][3]};
        6'd55: opsum_out = {fifo[27][0], fifo[27][1]};
        6'd56: opsum_out = {fifo[28][2], fifo[28][3]};
        6'd57: opsum_out = {fifo[28][0], fifo[28][1]};
        6'd58: opsum_out = {fifo[29][2], fifo[29][3]};
        6'd59: opsum_out = {fifo[29][0], fifo[29][1]};
        6'd60: opsum_out = {fifo[30][2], fifo[30][3]};
        6'd61: opsum_out = {fifo[30][0], fifo[30][1]};
        6'd62: opsum_out = {fifo[31][2], fifo[31][3]};
        6'd63: opsum_out = {fifo[31][0], fifo[31][1]};
        default: opsum_out = 32'd0; // Default case to avoid latches
      endcase
    end
    else
      opsum_out = 32'd0;
  end

endmodule