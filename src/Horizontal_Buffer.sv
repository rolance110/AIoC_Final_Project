`define COL_NUM 32
`define ROW_NUM 32

module Horizontal_Buffer(
    input clk,
    input reset,
    input change_weight_f,//切換weight的signal
    input [1:0] pass_layer_type,
    input [5:0] row_en,
    input [4:0] col_in,//用來判斷一個ROW要放幾筆data
    //handshake
    input ready_w,
    input valid_w,
    input [`ROW_NUM - 1 : 0] weight_in,//改成32bit，一個ROW weight需要8個cycle才能填滿

    output logic [`ROW_NUM*`COL_NUM*8 - 1 : 0] weight_out
);
// --------------------------------------------------
// TODO:
// 因為每次輸入32bit，一個ROW的weight需要8個cycle才能完成
// weight_en會說明有幾個ROW被放weight，依照外面FSM被切換的時間(不一定32ROW被填滿)
// 還沒有修改成DW可以使用的版本
// --------------------------------------------------
// storage for each PE’s weight
logic [31:0] weight_mem [0:`ROW_NUM-1][0:7];
logic [2:0] col_cnt;
logic [4:0] row_cnt;
logic change_f_reg;

logic handshake_f;
logic [2:0] col_num;

always_comb begin
    col_num = col_in[4:2];//最多一個ROW有8筆32bit
end

// wire handshake_f0 = (valid_w && ready_w) ? 1'b1 : 1'b0; // handshake signal for writing weights

// logic handshake_f;
// always_ff @(posedge clk) begin
//     if(reset) begin
//         handshake_f <= 1'b0;
//     end
//     else if(handshake_f0) begin
//         handshake_f <= 1'b1;
//     end
// end

always_comb begin
    handshake_f = (valid_w && ready_w) ? 1'b1 : 1'b0; // handshake signal for writing weights
end

always_ff @(posedge clk) begin
    if(reset || (ready_w == 1'd0)) begin
       col_cnt <= 3'd0;
       row_cnt <= 5'd0;
    end
    else begin
        case(pass_layer_type)
            2'd1:begin
                if(handshake_f) begin
                    if(row_cnt == row_en - 6'd1) begin
                        row_cnt <= 5'd0;
                    end
                    else
                        row_cnt <= row_cnt + 6'd1;
                end
            end
            2'd0: begin
                if(handshake_f && (col_cnt == col_num) && (row_cnt == row_en - 6'd1)) begin
                    col_cnt <= 3'd0;
                    row_cnt <= 5'd0;
                end
                else if(handshake_f && (col_cnt == col_num)) begin
                    col_cnt <= 3'd0;
                    row_cnt <= row_cnt + 6'd1;//不怕她爆掉，就給他在else的時候清0即可
                end
                else if(handshake_f) begin
                        col_cnt <= col_cnt + 3'd1;
                end
                else begin
                    col_cnt <= col_cnt;
                end
            end
            default: begin
                col_cnt <= 3'd0;
                row_cnt <= 5'd0;
            end
        endcase
    end 
end


always_ff @(posedge clk) begin
   if(reset || change_weight_f) begin
     for(int i=0;i<32;i=i+1) begin
       for(int j=0;j<8;j=j+1) begin
         weight_mem[i][j] <= 32'd0;
       end
      end
   end
   else if(handshake_f) begin
      weight_mem[row_cnt][col_cnt] <= weight_in;
   end
end

always_comb begin
    case(pass_layer_type)
        2'd1:begin//要斜對角放，每三個ROW整理一次
            //ROW0
            weight_out[255:0] = {weight_mem[0][0][23:16], weight_mem[1][0][23:16], weight_mem[2][0][23:16], 232'd0};
            weight_out[511:256] = {weight_mem[0][0][15:8], weight_mem[1][0][15:8], weight_mem[2][0][15:8], 232'd0};
            weight_out[767:512] = {weight_mem[0][0][7:0], weight_mem[1][0][7:0], weight_mem[2][0][7:0], 232'd0};
            //ROW1
            weight_out[1023:768] = {24'd0, weight_mem[3][0][7:0], weight_mem[4][0][7:0], weight_mem[5][0][7:0], 208'd0};
            weight_out[1279:1024] = {24'd0, weight_mem[3][0][7:0], weight_mem[4][0][7:0], weight_mem[5][0][7:0], 208'd0};
            weight_out[1535:1280] = {24'd0, weight_mem[3][0][7:0], weight_mem[4][0][7:0], weight_mem[5][0][7:0], 208'd0};
            //ROW2
            weight_out[1791:1536] = {48'd0, weight_mem[6][0][7:0], weight_mem[7][0][7:0], weight_mem[8][0][7:0], 184'd0};
            weight_out[2047:1792] = {48'd0, weight_mem[6][0][7:0], weight_mem[7][0][7:0], weight_mem[8][0][7:0], 184'd0};
            weight_out[2303:2048] = {48'd0, weight_mem[6][0][7:0], weight_mem[7][0][7:0], weight_mem[8][0][7:0], 184'd0};
            //ROW3
            weight_out[2559:2304] = {72'd0, weight_mem[9][0][7:0], weight_mem[10][0][7:0], weight_mem[11][0][7:0], 160'd0};
            weight_out[2815:2560] = {72'd0, weight_mem[9][0][7:0], weight_mem[10][0][7:0], weight_mem[11][0][7:0], 160'd0};
            weight_out[3071:2816] = {72'd0, weight_mem[9][0][7:0], weight_mem[10][0][7:0], weight_mem[11][0][7:0], 160'd0};
            //ROW4
            weight_out[3327:3072] = {96'd0, weight_mem[12][0][7:0], weight_mem[13][0][7:0], weight_mem[14][0][7:0], 136'd0};
            weight_out[3583:3328] = {96'd0, weight_mem[12][0][7:0], weight_mem[13][0][7:0], weight_mem[14][0][7:0], 136'd0};
            weight_out[3839:3584] = {96'd0, weight_mem[12][0][7:0], weight_mem[13][0][7:0], weight_mem[14][0][7:0], 136'd0};
            //ROW5
            weight_out[4095:3840] = {120'd0, weight_mem[15][0][7:0], weight_mem[16][0][7:0], weight_mem[17][0][7:0], 112'd0};
            weight_out[4351:4096] = {120'd0, weight_mem[15][0][7:0], weight_mem[16][0][7:0], weight_mem[17][0][7:0], 112'd0};
            weight_out[4607:4352] = {120'd0, weight_mem[15][0][7:0], weight_mem[16][0][7:0], weight_mem[17][0][7:0], 112'd0};
            //ROW6
            weight_out[4863:4608] = {144'd0, weight_mem[18][0][7:0], weight_mem[19][0][7:0], weight_mem[20][0][7:0], 88'd0};
            weight_out[5119:4864] = {144'd0, weight_mem[18][0][7:0], weight_mem[19][0][7:0], weight_mem[20][0][7:0], 88'd0};
            weight_out[5375:5120] = {144'd0, weight_mem[18][0][7:0], weight_mem[19][0][7:0], weight_mem[20][0][7:0], 88'd0};
            //ROW7
            weight_out[5631:5376] = {168'd0, weight_mem[21][0][7:0], weight_mem[22][0][7:0], weight_mem[23][0][7:0], 64'd0};
            weight_out[5887:5632] = {168'd0, weight_mem[21][0][7:0], weight_mem[22][0][7:0], weight_mem[23][0][7:0], 64'd0};
            weight_out[6143:5888] = {168'd0, weight_mem[21][0][7:0], weight_mem[22][0][7:0], weight_mem[23][0][7:0], 64'd0};
            //ROW8
            weight_out[6399:6144] = {192'd0, weight_mem[24][0][7:0], weight_mem[25][0][7:0], weight_mem[26][0][7:0], 40'd0};
            weight_out[6655:6400] = {192'd0, weight_mem[24][0][7:0], weight_mem[25][0][7:0], weight_mem[26][0][7:0], 40'd0};
            weight_out[6911:6656] = {192'd0, weight_mem[24][0][7:0], weight_mem[25][0][7:0], weight_mem[26][0][7:0], 40'd0};
            //ROW9
            weight_out[7167:6912] = {216'd0, weight_mem[27][0][7:0], weight_mem[28][0][7:0], weight_mem[29][0][7:0], 16'd0};
            weight_out[7423:7168] = {216'd0, weight_mem[27][0][7:0], weight_mem[28][0][7:0], weight_mem[29][0][7:0], 16'd0};
            weight_out[7679:7424] = {216'd0, weight_mem[27][0][7:0], weight_mem[28][0][7:0], weight_mem[29][0][7:0], 16'd0};
            //default
            weight_out[7935:7680] = {256'd0};
            weight_out[8191:7936] = {256'd0};
            //weight_out[(r*256)+(c*32) +: 32] = 32'd0; // DW mode, output zero
        end
        2'd0:begin
            //ROW0
            weight_out[255:0] = {weight_mem[0][7], weight_mem[0][6], weight_mem[0][5], weight_mem[0][4],
                                 weight_mem[0][3], weight_mem[0][2], weight_mem[0][1], weight_mem[0][0]};
            weight_out[511:256] = {weight_mem[1][7], weight_mem[1][6], weight_mem[1][5], weight_mem[1][4],
                                   weight_mem[1][3], weight_mem[1][2], weight_mem[1][1], weight_mem[1][0]};
            weight_out[767:512] = {weight_mem[2][7], weight_mem[2][6], weight_mem[2][5], weight_mem[2][4],
                                   weight_mem[2][3], weight_mem[2][2], weight_mem[2][1], weight_mem[2][0]};
            //ROW1
            weight_out[1023:768] = { weight_mem[3][7], weight_mem[3][6], weight_mem[3][5], weight_mem[3][4],
                                   weight_mem[3][3], weight_mem[3][2], weight_mem[3][1], weight_mem[3][0]};
            weight_out[1279:1024] = { weight_mem[4][7], weight_mem[4][6], weight_mem[4][5], weight_mem[4][4],
                                   weight_mem[4][3], weight_mem[4][2], weight_mem[4][1], weight_mem[4][0]};
            weight_out[1535:1280] = { weight_mem[5][7], weight_mem[5][6], weight_mem[5][5], weight_mem[5][4],
                                   weight_mem[5][3], weight_mem[5][2], weight_mem[5][1], weight_mem[5][0]};
            //ROW2
            weight_out[1791:1536] = { weight_mem[6][7], weight_mem[6][6], weight_mem[6][5], weight_mem[6][4],
                                   weight_mem[6][3], weight_mem[6][2], weight_mem[6][1], weight_mem[6][0]};
            weight_out[2047:1792] = { weight_mem[7][7], weight_mem[7][6], weight_mem[7][5], weight_mem[7][4],
                                   weight_mem[7][3], weight_mem[7][2], weight_mem[7][1], weight_mem[7][0]};
            weight_out[2303:2048] = { weight_mem[8][7], weight_mem[8][6], weight_mem[8][5], weight_mem[8][4],
                                   weight_mem[8][3], weight_mem[8][2], weight_mem[8][1], weight_mem[8][0]};
            //ROW3
            weight_out[2559:2304] = { weight_mem[9][7], weight_mem[9][6], weight_mem[9][5], weight_mem[9][4],
                                   weight_mem[9][3], weight_mem[9][2], weight_mem[9][1], weight_mem[9][0]};
            weight_out[2815:2560] = { weight_mem[10][7], weight_mem[10][6], weight_mem[10][5], weight_mem[10][4],
                                   weight_mem[10][3], weight_mem[10][2], weight_mem[10][1], weight_mem[10][0]};
            weight_out[3071:2816] = { weight_mem[11][7], weight_mem[11][6], weight_mem[11][5], weight_mem[11][4],
                                   weight_mem[11][3], weight_mem[11][2], weight_mem[11][1], weight_mem[11][0]};
            //ROW4
            weight_out[3327:3072] = { weight_mem[12][7], weight_mem[12][6], weight_mem[12][5], weight_mem[12][4],
                                   weight_mem[12][3], weight_mem[12][2], weight_mem[12][1], weight_mem[12][0]};
            weight_out[3583:3328] = { weight_mem[13][7], weight_mem[13][6], weight_mem[13][5], weight_mem[13][4],
                                   weight_mem[13][3], weight_mem[13][2], weight_mem[13][1], weight_mem[13][0]};
            weight_out[3839:3584] = { weight_mem[14][7], weight_mem[14][6], weight_mem[14][5], weight_mem[14][4],
                                   weight_mem[14][3], weight_mem[14][2], weight_mem[14][1], weight_mem[14][0]};
            //ROW5
            weight_out[4095:3840] = { weight_mem[15][7], weight_mem[15][6], weight_mem[15][5], weight_mem[15][4],
                                   weight_mem[15][3], weight_mem[15][2], weight_mem[15][1], weight_mem[15][0]};
            weight_out[4351:4096] = { weight_mem[16][7], weight_mem[16][6], weight_mem[16][5], weight_mem[16][4],
                                   weight_mem[16][3], weight_mem[16][2], weight_mem[16][1], weight_mem[16][0]};
            weight_out[4607:4352] = { weight_mem[17][7], weight_mem[17][6], weight_mem[17][5], weight_mem[17][4],
                                   weight_mem[17][3], weight_mem[17][2], weight_mem[17][1], weight_mem[17][0]};
            //ROW6
            weight_out[4863:4608] = { weight_mem[18][7], weight_mem[18][6], weight_mem[18][5], weight_mem[18][4],
                                   weight_mem[18][3], weight_mem[18][2], weight_mem[18][1], weight_mem[18][0]};
            weight_out[5119:4864] = { weight_mem[19][7], weight_mem[19][6], weight_mem[19][5], weight_mem[19][4],
                                   weight_mem[19][3], weight_mem[19][2], weight_mem[19][1], weight_mem[19][0]};
            weight_out[5375:5120] = { weight_mem[20][7], weight_mem[20][6], weight_mem[20][5], weight_mem[20][4],
                                   weight_mem[20][3], weight_mem[20][2], weight_mem[20][1], weight_mem[20][0]};
            //ROW7
            weight_out[5631:5376] = { weight_mem[21][7], weight_mem[21][6], weight_mem[21][5], weight_mem[21][4],
                                   weight_mem[21][3], weight_mem[21][2], weight_mem[21][1], weight_mem[21][0]};
            weight_out[5887:5632] = { weight_mem[22][7], weight_mem[22][6], weight_mem[22][5], weight_mem[22][4],
                                   weight_mem[22][3], weight_mem[22][2], weight_mem[22][1], weight_mem[22][0]};
            weight_out[6143:5888] = { weight_mem[23][7], weight_mem[23][6], weight_mem[23][5], weight_mem[23][4],
                                   weight_mem[23][3], weight_mem[23][2], weight_mem[23][1], weight_mem[23][0]};
            //ROW8
            weight_out[6399:6144] = { weight_mem[24][7], weight_mem[24][6], weight_mem[24][5], weight_mem[24][4],
                                   weight_mem[24][3], weight_mem[24][2], weight_mem[24][1], weight_mem[24][0]};
            weight_out[6655:6400] = { weight_mem[25][7], weight_mem[25][6], weight_mem[25][5], weight_mem[25][4],
                                   weight_mem[25][3], weight_mem[25][2], weight_mem[25][1], weight_mem[25][0]};
            weight_out[6911:6656] = { weight_mem[26][7], weight_mem[26][6], weight_mem[26][5], weight_mem[26][4],
                                   weight_mem[26][3], weight_mem[26][2], weight_mem[26][1], weight_mem[26][0]};
            //ROW9
            weight_out[7167:6912] = { weight_mem[27][7], weight_mem[27][6], weight_mem[27][5], weight_mem[27][4],
                                   weight_mem[27][3], weight_mem[27][2], weight_mem[27][1], weight_mem[27][0]};
            weight_out[7423:7168] = { weight_mem[28][7], weight_mem[28][6], weight_mem[28][5], weight_mem[28][4],
                                   weight_mem[28][3], weight_mem[28][2], weight_mem[28][1], weight_mem[28][0]};
            weight_out[7679:7424] = { weight_mem[29][7], weight_mem[29][6], weight_mem[29][5], weight_mem[29][4],
                                   weight_mem[29][3], weight_mem[29][2], weight_mem[29][1], weight_mem[29][0]};
            //default
            weight_out[7935:7680] = { weight_mem[30][7], weight_mem[30][6], weight_mem[30][5], weight_mem[30][4],
                                   weight_mem[30][3], weight_mem[30][2], weight_mem[30][1], weight_mem[30][0]};
            weight_out[8191:7936] = { weight_mem[31][7], weight_mem[31][6], weight_mem[31][5], weight_mem[31][4],
                                   weight_mem[31][3], weight_mem[31][2], weight_mem[31][1], weight_mem[31][0]};
        end
        default weight_out = 8192'd0; // Default case to avoid latches
    endcase
end

endmodule