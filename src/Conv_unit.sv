`define COL_NUM 32
`define ROW_NUM 32

module conv_unit(
    input clk,
    input reset,
    //from GLB
    input [31:0] data_in,
    //to GLB
    output logic [31:0] data_out,
    //control signal
    input change_weight_f,//告訴PE，這個weight已經做完，需要更新Weight
    input [4:0] col_en,//控制這次有幾個col會動作(因為不是每次都會把Vertical buffer塞滿)
    input [4:0] row_en//控制這次有幾個ROW動作(因為不一定是32個Weight)，不一定會塞滿全部
);

  // --------------------------------------------------
  // TODO cs = WEIGHT_LOAD時，根據row_en來決定有幾個ROW要使用
  // --------------------------------------------------
logic [7:0] cnt;
typedef enum logic [2:0] {WEIGHT_LOAD, IFMAP_LOAD, IPSUM_LOAD, COMPUTE, OPSUM_OUT} state_t;
state_t cs, ns;

//設定每一個狀態所需的時間，根據這次開的row & col數量來浮動，避免放廢多餘的時間
wire [7:0] weight_load_time;
wire [4:0] ifmap_load_time;
wire [5:0] ipsum_load_time, opsum_load_time;
assign weight_load_time = row_en << 3;//總共有幾筆weight要輸入進來(weight一個ROW需要8個cycle)
assign ifmap_load_time = col_en;//一次載入32bit，剛好是一個col所需的時間
assign ipsum_load_time = row_en << 1;//一個ROW需要2個cycle才能填滿(因為一筆ipsum = 16 bit)
assign opsum_load_time = row_en << 1;//一個ROW需要2個cycle才能全部送回GLB(因為一筆ipsum = 16 bit)

//用來連接給各個module
wire [31:0] weight_in, ifmap_in, ipsum_in, opsum_out;
assign weight_in = (cs == WEIGHT_LOAD) ? data_in : 32'd0;
assign ifmap_in = (cs == IFMAP_LOAD) ? data_in : 32'd0;
assign ipsum_in = (cs == IPSUM_LOAD) ? data_in : 32'd0;
assign data_out = (cs == OPSUM_OUT) ? opsum_out : 32'd0;

always_ff @(posedge clk or negedge reset) begin
    if(reset)
        cs <= 3'd0;
    else 
        cs <= ns;
end

always_comb begin
    case (cs)
        WEIGHT_LOAD: begin
            if(cnt == weight_load_time)
                cs = IFMAP_LOAD;
            else
                cs = WEIGHT_LOAD;
        end
        IFMAP_LOAD: begin
            if(cnt == ifmap_load_time)
                cs = IPSUM_LOAD;
            else
                cs = IFMAP_LOAD;
        end
        IPSUM_LOAD: begin
            if(cnt == ipsum_load_time)
                cs = COMPUTE;
            else 
                cs = IPSUM_LOAD;
        end
        COMPUTE: begin
            if(cnt == 8'd3)
                cs = OPSUM_OUT;
            else
                cs = COMPUTE;
        end
        OPSUM_OUT: begin
            if(cnt == opsum_load_time) begin
                if(change_weight_f)
                    cs = WEIGHT_LOAD;//代表這32個channel做完，已經
                else
                    cs = IFMAP_LOAD;
            end
            else
                cs = OPSUM_OUT;
                
        end
        default: cs = WEIGHT_LOAD; 
    endcase 
end

always_ff @(posedge clk or negedge reset) begin
    if(reset) 
        cnt <= 8'd0;
    else if(((cs == WEIGHT_LOAD) && (cnt == weight_load_time)) || ((cs == IFMAP_LOAD) && (cnt == ifmap_load_time)))begin
        cnt <= 8'd0;
    end
    else if(((cs == IPSUM_LOAD) && (cnt == ipsum_load_time)) || ((cs == OPSUM_OUT) && (cnt == opsum_load_time)))begin
        cnt <= 8'd0;
    end
    else if((cs == COMPUTE) && cnt == 8'd3)
        cnt <= 8'd0;
    else
        cnt <= cnt + 8'd1;
end



endmodule