`define COL_NUM 32
`define ROW_NUM 32

module conv_unit(
    input clk,
    input reset,
    //from GLB
    input [31:0] data_in,
    //to GLB
    output logic [31:0] data_out,
    //handshake(ifmap, weight, ipsum, opsum)
    output logic ready_w,
    output logic ready_if,
    output logic ready_ip,
    output logic valid_op,
    input valid_w,
    input valid_if,
    input valid_ip,
    input ready_op,

    //control signal
    input DW_PW_sel,//用來決定是DW還是PW，PW = 1, DW = 0
    input change_weight_f,//告訴PE，這個weight已經做完，需要更新Weight
    input [5:0] col_en,//控制這次有幾個col會動作(因為不是每次都會把Vertical buffer塞滿)
    input [5:0] row_en//控制這次有幾個ROW動作(因為不一定是32個Weight)，不一定會塞滿全部
);

// --------------------------------------------------
// TODO: cs = WEIGHT_LOAD時，根據row_en來決定有幾個ROW要使用
// --------------------------------------------------
logic [7:0] cnt;
typedef enum logic [2:0] {IDLE, WEIGHT_LOAD, IFMAP_LOAD, IPSUM_LOAD, COMPUTE, OPSUM_OUT} state_t;
state_t cs, ns;

// TODO: 設定每一個狀態所需的時間，根據這次開的row & col數量來浮動，避免放廢多餘的時間
wire [7:0] weight_load_time;
wire [5:0] ifmap_load_time;
wire [6:0] ipsum_load_time, opsum_load_time;

wire [4:0] col_in = col_en - 5'd1;//從0開始到31
wire [3:0] col_num = col_in[5:3];
assign weight_load_time = (row_en * col_num) - 8'd1;//總共有幾筆weight要輸入進來(weight一個ROW最多需要8個cycle)
assign ifmap_load_time = col_en - 6'd1;//一次載入32bit，剛好是一個col所需的時間
assign ipsum_load_time = (row_en << 1) - 7'd1;//一個ROW需要2個cycle才能填滿(因為一筆ipsum = 16 bit)
assign opsum_load_time = (row_en << 1) - 7'd1;//一個ROW需要2個cycle才能全部送回GLB(因為一筆ipsum = 16 bit)

// TODO: 用來連接給各個module的data_input
wire [31:0] weight_in, ifmap_in, ipsum_in, opsum2GLB;
assign weight_in = (cs == WEIGHT_LOAD) ? data_in : 32'd0;
assign ifmap_in = (cs == IFMAP_LOAD) ? data_in : 32'd0;
assign ipsum_in = (cs == IPSUM_LOAD) ? data_in : 32'd0;
assign data_out = (cs == OPSUM_OUT) ? opsum2GLB : 32'd0;

//--------------------------------------------------------------//
//TODO:
//設計一個用來計算剛啟動這個PE array的時候，因為不會滿載，所以並非所有ROW都要使用
//所以可以只輸入部分ipsum & 只輸出部分opsum
//所以需要計算8個大循環，8個循環以後才會滿載計算

logic first_f;
logic [2:0] first_8_cnt; //用來計算第一個8個cycle的weight load

//給ipsum & opsum說明幾個ROW要使用
logic [5:0] time_4_cnt = ((first_8_cnt + 3'd1) << 2); //第一個8個cycle的ifmap load時間，因為每個ifmap需要2個cycle才能填滿，所以需要乘以2
logic [6:0] time_8_cnt = (time_4_cnt << 1) - 7'd1; //psum是16bit，所以4個ROW需要8個cycle才能填滿

always_ff @(posedge clk) begin
    if(reset)
        first_f <= 1'd0;
    else if(cs == IDLE && ns == WEIGHT_LOAD)
        first_f <= 1'd1;
    else if(cs == OPSUM_OUT && ns == IDLE && (first_8_cnt == 3'd7))//等最後一次做完才放下
        first_f <= 1'd0; //當進入IFMAP_LOAD的時候，代表已經完成第一個8個cycle的weight load
end

always_ff @(posedge clk) begin
    if(reset || (cs == WEIGHT_LOAD))
        first_8_cnt <= 3'd0;
    else if(cs == IDLE && ns == IFMAP_LOAD)
        first_8_cnt <= first_8_cnt + 3'd1;
end
//--------------------------------------------------------------//


//---------------------------------------------------------------//
//TODO: 關閉PE array信號設定
logic close_f; //用來關閉PE array的信號
logic [2:0] close_8_cnt;

//0 - 4 - 8 - 12 - 16 - 20 - 24 - 28(總共8次)
wire [4:0] close_start_num = close_8_cnt << 2; //關閉PE array的ROW起始位子
wire [5:0] close_num = (row_en << 1) - (close_start_num << 1) - 6'd1;

always_ff @(posedge clk) begin
    if(reset)
        close_f <= 1'b0;
    else if(cs == IDLE && ns == IPSUM_LOAD)
        close_f <= 1'b1; //當進入WEIGHT_LOAD的時候，代表已經完成第一個8個cycle的weight load
    else if(cs == OPSUM_OUT && ns == IDLE && (close_8_cnt == 3'd7))//等最後一次做完才放下
        close_f <= 1'b0; //當進入IFMAP_LOAD的時候，代表已經完成第一個8個cycle的weight load
end

always_ff @(posedge clk) begin
    if(reset || (cs == WEIGHT_LOAD))
        close_8_cnt <= 3'd0;
    else if(cs == IDLE && ns == IPSUM_LOAD)
        close_8_cnt <= close_8_cnt + 3'd1;
end
//----------------------------------------------------------------//

always_ff @(posedge clk) begin
    if(reset)
        cs <= IDLE;
    else 
        cs <= ns;
end

always_comb begin
    case (cs)
        IDLE: begin//go to weight or ifmap or ipsum(close pe array use)
            if(valid_w)
                ns = WEIGHT_LOAD;
            else if(valid_if)
                ns = IFMAP_LOAD;
            else if(valid_ip)
                ns = IPSUM_LOAD;
            else
                ns = IDLE;
        end
        WEIGHT_LOAD: begin
            case(DW_PW_sel)
                1'd0: begin //DW
                    ns = WEIGHT_LOAD;
                end
                1'd1: begin //PW
                    if(cnt == weight_load_time)
                        ns = IFMAP_LOAD;
                    else
                        ns = WEIGHT_LOAD;
                end
            endcase
        end
        IFMAP_LOAD: begin
            case(DW_PW_sel)
                1'd0: begin //DW
                        ns = IFMAP_LOAD;
                end
                1'd1: begin //PW
                    if(cnt[5:0] == ifmap_load_time)
                        ns = IPSUM_LOAD;
                    else
                        ns = IFMAP_LOAD;
                end
            endcase
        end
        IPSUM_LOAD: begin
            case(DW_PW_sel)
                1'd0: begin //DW
                    ns = IPSUM_LOAD;
                end
                1'd1: begin //PW
                    if(first_f) begin //第一個8個cycle的weight load
                        if(cnt[6:0] == time_8_cnt) //time_8_cnt = (first_8_cnt + 3'd1) << 3 - 7'd1
                            ns = COMPUTE;
                        else 
                            ns = IPSUM_LOAD;
                    end
                    else if(close_f) begin //關閉PE array
                        if(cnt[5:0] == close_num)
                            ns = COMPUTE;
                        else 
                            ns = IPSUM_LOAD;
                    end
                    else if(cnt[6:0] == ipsum_load_time)
                        ns = COMPUTE;
                    else 
                        ns = IPSUM_LOAD;
                end
            endcase
        end
        COMPUTE: begin
            case(DW_PW_sel)
                1'd0: begin //DW 三個cycle計算
                    if(cnt == 8'd2) //每個PE需要4個cycle來計算
                        ns = OPSUM_OUT;
                    else
                        ns = COMPUTE;
                end
                1'd1: begin //PW
                    if(cnt == 8'd3) //每個PE需要4個cycle來計算
                        ns = OPSUM_OUT;
                    else
                        ns = COMPUTE;
                end
            endcase
        end
        OPSUM_OUT: begin
            case(DW_PW_sel)
                1'd0: begin //DW
                    ns = IDLE;
                end
                1'd1: begin //PW
                    if(first_f) begin
                        if(cnt[6:0] == time_8_cnt) //time_8_cnt = (first_8_cnt + 3'd1) << 3 - 7'd1
                            ns = IDLE; //代表這32個channel做完，已經
                        else 
                            ns = OPSUM_OUT;
                    end
                    else if(close_f) begin //關閉PE array
                        if(cnt[5:0] == close_num)
                            ns = IDLE; //代表這32個channel做完，已經
                        else 
                            ns = OPSUM_OUT;
                    end
                    else if(cnt[6:0] == opsum_load_time - 7'd1) begin
                        ns = IDLE;
                    end
                    else
                        ns = OPSUM_OUT;
                end
            endcase
        end
        default: ns = IDLE; 
    endcase 
end

always_ff @(posedge clk) begin
    if(reset) 
        cnt <= 8'd0;
    else begin
        case(DW_PW_sel)
            1'd0: begin//DW
                cnt <= 8'd0; //DW的話，cnt永遠歸0
            end
            1'd1: begin//PW
                if(first_f) begin
                    if(((cs == WEIGHT_LOAD) && (cnt == weight_load_time)) || 
                    ((cs == IFMAP_LOAD) && (cnt[5:0] == ifmap_load_time)) ||
                    ((cs == IPSUM_LOAD) && (cnt[6:0] == time_8_cnt)) || 
                    ((cs == OPSUM_OUT) && (cnt[6:0] == time_8_cnt))  || 
                    ((cs == COMPUTE) && (cnt == 8'd3)))
                        cnt <= 8'd0;
                    else if((valid_if && ready_if) || (valid_w && ready_w) || (valid_ip && ready_ip) || (valid_op && ready_op) || (cs == COMPUTE))
                        cnt <= cnt + 8'd1;
                end
                else if(close_f) begin
                    if(((cs == IPSUM_LOAD) && (cnt[5:0] == close_num)) || 
                    ((cs == OPSUM_OUT) && (cnt[5:0] == close_num))  || 
                    ((cs == COMPUTE) && (cnt == 8'd3)))
                        cnt <= 8'd0;
                    else if((valid_ip && ready_ip) || (valid_op && ready_op) || (cs == COMPUTE))
                        cnt <= cnt + 8'd1;
                end
                else if(((cs == WEIGHT_LOAD) && (cnt == weight_load_time)) || ((cs == IFMAP_LOAD) && (cnt[5:0] == ifmap_load_time)) ||
                ((cs == IPSUM_LOAD) && (cnt[6:0] == ipsum_load_time)) || ((cs == OPSUM_OUT) && (cnt[6:0] == opsum_load_time)) || ((cs == COMPUTE) && cnt == 8'd3))begin
                    cnt <= 8'd0;
                end
                else if((valid_if && ready_if) || (valid_w && ready_w) || (valid_ip && ready_ip) || (valid_op && ready_op) || (cs == COMPUTE))
                    cnt <= cnt + 8'd1;
            end
        endcase
    end
end



//--------------------------------------------------------------//
//horizontal buffer
//TODO: handshake的時候才能輸入一筆data

always_comb begin
    if(cs == WEIGHT_LOAD)
        ready_w = 1'b1; //在WEIGHT_LOAD的時候，ready_w = 1
    else
        ready_w = 1'b0; //其他狀態不需要ready_w
end

Horizontal_Buffer Horizontal_Buffer(
    .clk(clk),
    .reset(reset),
    .change_weight_f(change_weight_f), //用來決定是否要更新weight
    .DW_PW_sel(DW_PW_sel), //用來決定是DW還是PW，PW = 1, DW = 0
    .row_en(row_en),
    .col_in(col_in),
    .ready_w(ready_w),
    .valid_w(valid_w),
    .weight_in(weight_in),
    .weight_out(weight_out)//to PE array
);
//--------------------------------------------------------------//





//--------------------------------------------------------------//
//vertical buffer
//TODO: 需要拉5個cycle，因為需要先花一個cycle從FIFO取出，再花四個cycle來pipeline 計算&取出
wire ifmap_out_f;
assign ifmap_out_f = ((cs == IPSUM_LOAD) && (ns == COMPUTE)) || ((cs == COMPUTE) && (cnt < 8'd4));//在compute的時候開始拉為1，總共維持四個cycle

always_comb begin
    if(cs == IFMAP_LOAD)
        ready_if = 1'b1; //在WEIGHT_LOAD的時候，ready_w = 1
    else
        ready_if = 1'b0; //其他狀態不需要ready_w
end

Vertical_Buffer Vertical_Buffer(
    .clk(clk),
    .reset(reset),
    .col_en(col_en),
    .ready_if(ready_if),
    .valid_if(valid_if),
    .ifmap_in(ifmap_in),
    .ifmap_out_f(ifmap_out_f),
    .ifmap_out(ifmap_out)//to PE array
);
//--------------------------------------------------------------//





//--------------------------------------------------------------//
//ipsum buffer
//TODO: 因為要跟ifmap配合，所以會比ifmap晚一個cycle，因為無須到PE做計算
//更改成考慮哪一種conv(PW DW Conv Linear)
//
logic ipsum_out_f;

always_comb begin
    case(DW_PW_sel)
        1'd0: begin //DW
            ipsum_out_f = ((cs == COMPUTE) && (cnt < 8'd3));
        end
        1'd1: begin //PW
            ipsum_out_f = ((cs == COMPUTE) && (cnt < 8'd4));
        end
    endcase
end

always_comb begin
    if(cs == IPSUM_LOAD)
        ready_ip = 1'b1; //在IPSUM_LOAD的時候，ready_ip = 1
    else
        ready_ip = 1'b0; //其他狀態不需要ready_ip
end

Ipsum_buffer Ipsum_buffer(
    .clk(clk),
    .reset(reset),
    //handshake
    .ready_ip(ready_ip),
    .valid_ip(valid_ip),
    //剛開始啟動PE array
    .time_4_cnt(time_4_cnt),//用來決定有幾個ROW要使用
    .first_f(first_f), //用來決定是否是第一個8個cycle的weight load
    //要關閉PE array
    .close_start_num(close_start_num), //用來決定關閉PE array的ROW起始位子
    .close_f(close_f), //用來關閉PE array的信號
    
    .row_en(row_en), //用來決定有幾個ROW要使用
    .ipsum_out_f(ipsum_out_f),
    .ipsum_in(ipsum_in),
    .ipsum_out(ipsum_out)//to PE array
);
//--------------------------------------------------------------//




//--------------------------------------------------------------//
//opsum buffer
//TODO: 因為進入cs = compute，下一個cycle ipsum才會在reducer跟prod做累加
// 所以store_opsum_f 也需要配合在compute的下一個cycle開始儲存opsum
wire [15:0] reducer2opsum;
logic store_opsum_f;

always_comb begin
    if(cs == OPSUM_OUT)
        valid_op = 1'b1; //在OPSUM_OUT的時候，valid_op = 1
    else
        valid_op = 1'b0; //其他狀態不需要valid_op
end

always_ff @(posedge clk) begin
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
    //handshake
    .ready_op(ready_op),
    .valid_op(valid_op),
    //first 8 cycle
    .first_f(first_f),
    .time_4_cnt(time_4_cnt), //用來決定有幾個ROW要使用

    .store_opsum_f(store_opsum_f),
    .opsum_in(reducer2opsum),
    .opsum2GLB(opsum2GLB)//to GLB
);
//--------------------------------------------------------------//





//--------------------------------------------------------------//
//PE array
//TODO: 增加DW的pass功能，讓他可以把所有ifmap擺定位再開始動作
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




//--------------------------------------------------------------//
//Reducer
Reducer Reducer(
    .array2reducer(array_opsum), //從PE_array來的
    .ipsum2reducer(ipsum_out), //只有在cs == Compute的時候會輸出給Reducer，維持四個cycle
    .DW_PW_sel(DW_PW_sel), //從Ipsum_buffer來的
    .reducer2opsum(reducer2opsum) //送到Opsum_buffer
);
//--------------------------------------------------------------//



endmodule