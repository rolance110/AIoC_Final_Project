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
    input DW_PW_sel,//用來決定是DW還是PW，PW = 1, DW = 0
    input change_weight_f,//告訴PE，這個weight已經做完，需要更新Weight
    input [5:0] col_en,//控制這次有幾個col會動作(因為不是每次都會把Vertical buffer塞滿)
    input [5:0] row_en//控制這次有幾個ROW動作(因為不一定是32個Weight)，不一定會塞滿全部
);

  // --------------------------------------------------
  // TODO cs = WEIGHT_LOAD時，根據row_en來決定有幾個ROW要使用
  // --------------------------------------------------
logic [7:0] cnt;
typedef enum logic [2:0] {WEIGHT_LOAD, IFMAP_LOAD, IPSUM_LOAD, COMPUTE, OPSUM_OUT} state_t;
state_t cs, ns;

//設定每一個狀態所需的時間，根據這次開的row & col數量來浮動，避免放廢多餘的時間
wire [8:0] weight_load_time;
wire [5:0] ifmap_load_time;
wire [6:0] ipsum_load_time, opsum_load_time;
assign weight_load_time = row_en << 3;//總共有幾筆weight要輸入進來(weight一個ROW需要8個cycle)
assign ifmap_load_time = col_en;//一次載入32bit，剛好是一個col所需的時間
assign ipsum_load_time = row_en << 1;//一個ROW需要2個cycle才能填滿(因為一筆ipsum = 16 bit)
assign opsum_load_time = row_en << 1;//一個ROW需要2個cycle才能全部送回GLB(因為一筆ipsum = 16 bit)

//用來連接給各個module
wire [31:0] weight_in, ifmap_in, ipsum_in, opsum2GLB;
assign weight_in = (cs == WEIGHT_LOAD) ? data_in : 32'd0;
assign ifmap_in = (cs == IFMAP_LOAD) ? data_in : 32'd0;
assign ipsum_in = (cs == IPSUM_LOAD) ? data_in : 32'd0;
assign data_out = (cs == OPSUM_OUT) ? opsum2GLB : 32'd0;

always_ff @(posedge clk or negedge reset) begin
    if(reset)
        cs <= 3'd0;
    else 
        cs <= ns;
end

always_comb begin
    case (cs)
        WEIGHT_LOAD: begin
            if(cnt == weight_load_time - 8'd1)
                ns = IFMAP_LOAD;
            else
                ns = WEIGHT_LOAD;
        end
        IFMAP_LOAD: begin
            if(cnt == ifmap_load_time - 6'd1)
                ns = IPSUM_LOAD;
            else
                ns = IFMAP_LOAD;
        end
        IPSUM_LOAD: begin
            if(cnt == ipsum_load_time - 7'd1)
                ns = COMPUTE;
            else 
                ns = IPSUM_LOAD;
        end
        COMPUTE: begin
            if(cnt == 8'd3)
                ns = OPSUM_OUT;
            else
                ns = COMPUTE;
        end
        OPSUM_OUT: begin
            if(cnt == opsum_load_time - 7'd1) begin
                if(change_weight_f)
                    ns = WEIGHT_LOAD;//代表這32個channel做完，已經
                else
                    ns = IFMAP_LOAD;
            end
            else
                ns = OPSUM_OUT;
                
        end
        default: ns = WEIGHT_LOAD; 
    endcase 
end

always_ff @(posedge clk or negedge reset) begin
    if(reset) 
        cnt <= 8'd0;
    else if(((cs == WEIGHT_LOAD) && (cnt == weight_load_time)) || ((cs == IFMAP_LOAD) && (cnt == ifmap_load_time)) ||
    ((cs == IPSUM_LOAD) && (cnt == ipsum_load_time)) || ((cs == OPSUM_OUT) && (cnt == opsum_load_time)) || ((cs == COMPUTE) && cnt == 8'd3))begin
        cnt <= 8'd0;
    end
    else
        cnt <= cnt + 8'd1;
end


//--------------------------------------------------------------//
//vertical buffer
//TODO 需要拉5個cycle，因為需要先花一個cycle從FIFO取出，再花四個cycle來pipeline 計算&取出
wire ifmap_out_f, store_ifmap_f;
assign store_ifmap_f = (cs == IFMAP_LOAD) && (cnt < ifmap_load_time);
assign ifmap_out_f = ((cs ==IPSUM_LOAD) && (cnt == ipsum_load_time - 7'd1)) || ((cs == COMPUTE) && (cnt < 8'd4));//在compute的時候開始拉為1，總共維持四個cycle

Vertical_Buffer Vertical_Buffer(
    .clk(clk),
    .reset(reset),
    .store_ifmap_f(store_ifmap_f),
    .ifmap_in(ifmap_in),
    .ifmap_out_f(ifmap_out_f),
    .ifmap_out(ifmap_out)//to PE array
);
//--------------------------------------------------------------//
//horizontal buffer
wire store_weight_f;
assign store_weight_f = (cs == WEIGHT_LOAD) && (cnt < weight_load_time);

Horizontal_Buffer Horizontal_Buffer(
    .clk(clk),
    .reset(reset),
    .store_weight_f(store_weight_f),
    .weight_en(row_en),
    .weight_in(weight_in),
    .weight_out(weight_out)//to PE array
);
//--------------------------------------------------------------//
//ipsum buffer
//TODO 因為要跟ifmap配合，所以會比ifmap晚一個cycle，因為無須到PE做計算
wire store_ipsum_f, ipsum_out_f;
assign store_ipsum_f = (cs == IPSUM_LOAD) && (cnt < ipsum_load_time);
assign ipsum_out_f = ((cs == COMPUTE) && (cnt < 8'd4));

Ipsum_buffer Ipsum_buffer(
    .clk(clk),
    .reset(reset),
    .store_ipsum_f(store_ipsum_f),
    .ipsum_out_f(ipsum_out_f),
    .ipsum_in(ipsum_in),
    .ipsum_out(ipsum_out)//to PE array
);
//--------------------------------------------------------------//
//opsum buffer
//TODO 因為進入cs = compute，下一個cycle ipsum才會在reducer跟prod做累加
// 所以store_opsum_f 也需要配合在compute的下一個cycle開始儲存opsum
wire read_opsum_f;
wire [15:0] reducer2opsum;
logic store_opsum_f;

assign read_opsum_f = (cs == OPSUM_OUT) && (cnt < opsum_load_time);

always_ff @(posedge clk or negedge reset) begin
    if(reset)
        store_opsum_f <= 1'b0;
    else if(cs == COMPUTE)
        store_opsum_f <= 1'b1; //在compute的時候開始儲存opsum
    else
        store_opsum_f <= 1'b0; //讀取opsum後，清除儲存信號
end

Opsum_buffer Opsum_buffer(
    .clk(clk),
    .reset(reset),
    .store_opsum_f(store_opsum_f),
    .read_opsum_f(read_opsum_f),
    .opsum_in(reducer2opsum),
    .opsum2GLB(opsum2GLB)//to GLB
);
//--------------------------------------------------------------//
//PE array
wire prod_out_en;
wire [15:0] array_opsum;
assign prod_out_en = (cs == COMPUTE) && (cnt < 8'd4); //在compute的時候開始輸出給Reducer，維持四個cycle

PE_array PE_array(
    .clk(clk),
    .reset(reset),
    .array_ifmap_in(ifmap_out), //從Vertical_Buffer來的
    .array_weight_in(weight_out), //從Horizontal_Buffer來的
    .ipsum_in(ipsum_out), //從Ipsum_buffer來的
    .prod_out_en(prod_out_en),
    .array_weight_en(row_en), //根據row_en來決定有幾個ROW會動作
    .array_opsum(array_opsum) //送到Opsum_buffer
);
//--------------------------------------------------------------//
//Reducer


Reducer Reducer(
    .array2reducer(array_opsum), //從PE_array來的
    .ipsum2reducer(ipsum_out), //只有在cs == Compute的時候會輸出給Reducer，維持四個cycle
    .DW_PW_sel(DW_PW_sel), //從Ipsum_buffer來的
    .reducer2opsum(reducer2opsum) //送到Opsum_buffer
);



endmodule