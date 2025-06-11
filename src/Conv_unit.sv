`define COL_NUM 32
`define ROW_NUM 32
//TODO: PW 0 DW 1 CONV 2 LINEAR 3

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
    //DW signal
    input [1:0] dw_input_num,//決定輸入幾筆ifmap(1-3筆)
    input dw_row_end,//用來說明要換ROW，所以需要關閉PE array(觸發一個cycle))
    input dw_stride,//用來決定是DW還是PW，0 = stride 1, 1 = stride 2

    //control signal
    input DW_PW_sel,//用來決定是DW還是PW，PW = 1, DW = 0
    input [5:0] col_en,//控制這次有幾個col會動作(因為不是每次都會把Vertical buffer塞滿)
    input [5:0] row_en//控制這次有幾個ROW動作(因為不一定是32個Weight)，不一定會塞滿全部
);

// --------------------------------------------------
// TODO: cs = WEIGHT_LOAD時，根據row_en來決定有幾個ROW要使用
// --------------------------------------------------
logic [7:0] cnt;
typedef enum logic [2:0] {IDLE, WEIGHT_LOAD, IFMAP_LOAD, PASS, IPSUM_LOAD, COMPUTE, OPSUM_OUT} state_t;
state_t cs, ns;

// TODO: 設定每一個狀態所需的時間，根據這次開的row & col數量來浮動，避免放廢多餘的時間
wire [7:0] weight_load_time;
wire [4:0] ifmap_load_time;
wire [6:0] ipsum_load_time, opsum_load_time;

wire [4:0] col_in = col_en - 6'd1;//從0開始到31
wire [4:0] row_in = row_en - 6'd1;//從0開始到31
wire [3:0] col_num = {1'd0, col_in[4:2]} + 4'd1; //col_num = col_in[5:3] + 1，因為col_in是從0開始算，所以需要加1
assign weight_load_time = (row_en * col_num) - 8'd1;//總共有幾筆weight要輸入進來(weight一個ROW最多需要8個cycle)
assign ifmap_load_time = col_en - 5'd1;//一次載入32bit，剛好是一個col所需的時間
assign ipsum_load_time = (row_en << 1) - 7'd1;//一個ROW需要2個cycle才能填滿(因為一筆ipsum = 16 bit)
assign opsum_load_time = (row_en << 1) - 7'd1;//一個ROW需要2個cycle才能全部送回GLB(因為一筆ipsum = 16 bit)

// TODO: 用來連接給各個module的data_input
wire [31:0] weight_in, ifmap_in, ipsum_in, opsum2GLB;
assign weight_in = (cs == WEIGHT_LOAD) ? data_in : 32'd0;
assign ifmap_in = (cs == IFMAP_LOAD) ? data_in : 32'd0;
assign ipsum_in = (cs == IPSUM_LOAD) ? data_in : 32'd0;
assign data_out = (cs == OPSUM_OUT) ? opsum2GLB : 32'd0;

//--------------------------------------------------------------//
//TODO: PW
//設計一個用來計算剛啟動這個PE array的時候，因為不會滿載，所以並非所有ROW都要使用
//所以可以只輸入部分ipsum & 只輸出部分opsum
//所以需要計算8個大循環，8個循環以後才會滿載計算

    logic pw_first_f;
    logic [2:0] pw_open_cnt; //用來計算第一個8個cycle的weight load

    //給ipsum & opsum說明幾個ROW要使用
    wire [5:0] pw_time_4 = ((pw_open_cnt + 3'd1) << 2); //第一個8個cycle的ifmap load時間，因為每個ifmap需要2個cycle才能填滿，所以需要乘以2
    wire [6:0] pw_time_8 = (pw_time_4 << 1) - 7'd1; //psum是16bit，所以4個ROW需要8個cycle才能填滿

    always_ff @(posedge clk) begin
        if(reset)
            pw_first_f <= 1'd0;
        else if(cs == IDLE && ns == WEIGHT_LOAD)
            pw_first_f <= 1'd1;
        else if(cs == OPSUM_OUT && ns == IDLE && (pw_open_cnt == 3'd7))//等最後一次做完才放下
            pw_first_f <= 1'd0; //當進入IFMAP_LOAD的時候，代表已經完成第一個8個cycle的weight load
    end

    always_ff @(posedge clk) begin
        if(reset || (cs == WEIGHT_LOAD))
            pw_open_cnt <= 3'd0;
        else if(cs == IDLE && ns == IFMAP_LOAD)
            pw_open_cnt <= pw_open_cnt + 3'd1;
    end
    //--------------------------------------------------------------//


    //---------------------------------------------------------------//
    //TODO: 關閉PE array信號設定
    logic pw_close_f; //用來關閉PE array的信號
    logic [2:0] pw_close_cnt;

    wire [2:0] sub1_reg = pw_close_cnt - 3'd1;

    //0 - 4 - 8 - 12 - 16 - 20 - 24 - 28(總共8次)
    wire [4:0] pw_close_start_num = sub1_reg << 2; //關閉PE array的ROW起始位子
    wire [5:0] pw_close_num = (row_en << 1) - (pw_close_start_num << 1) - 6'd1;

    always_ff @(posedge clk) begin
        if(reset)
            pw_close_f <= 1'b0;
        else if(cs == IDLE && ns == IPSUM_LOAD)
            pw_close_f <= 1'b1; //當進入WEIGHT_LOAD的時候，代表已經完成第一個8個cycle的weight load
        else if(cs == OPSUM_OUT && ns == IDLE && (sub1_reg == 3'd7))//等最後一次做完才放下
            pw_close_f <= 1'b0; //當進入IFMAP_LOAD的時候，代表已經完成第一個8個cycle的weight load
    end

    always_ff @(posedge clk) begin
        if(reset || (cs == WEIGHT_LOAD))
            pw_close_cnt <= 3'd0;
        else if(cs == IDLE && ns == IPSUM_LOAD)
            pw_close_cnt <= pw_close_cnt + 3'd1;
    end
    //----------------------------------------------------------------//


//--------------------------------------------------------------//
//TODO: DW
// close signal要在open之前
//---------------------------------------------------------//
    logic dw_open_f; //用來決定是否是第一個8個cycle的weight load
    logic [3:0] dw_open_cnt; //共10筆

    wire [3:0] dw_open_num = row_en/3;//最多為10
    wire [4:0] dw_ip_num = (dw_open_num << 1) - 5'd1;//最多為19
    wire [4:0] dw_time_3 = col_en[4:0] - 5'd1;//做幾個cycle換狀態

    wire dw_first_if = (cs == WEIGHT_LOAD && ns == IFMAP_LOAD);

    //因為ifmap是從遠的開始放，所以需要從遠的開始放
    //27 - 24 - 21 - 18 - 15 - 12 - 9 - 6 - 3 - 0
    wire [4:0] dw_open_start_num = row_en - (dw_open_cnt * 3);//TODO: 給ifmap使用

    always_ff @(posedge clk) begin
        if(reset)
            dw_open_f <= 1'd0;
        else if((cs == IDLE && ns == WEIGHT_LOAD) || dw_row_end)//只要拉起來 再來就是準備要做重新開啟
            dw_open_f <= 1'd1;
        else if((dw_open_cnt == dw_open_num) && (ns == IDLE))//等最後一次做完才放下
            dw_open_f <= 1'd0; //當進入IFMAP_LOAD的時候，代表已經完成第一個8個cycle的weight load
    end

    always_ff @(posedge clk) begin
        if(reset || dw_row_end)
            dw_open_cnt <= 4'd0;
        else if((cs == IDLE && ns == IFMAP_LOAD) || (cs == WEIGHT_LOAD && ns == IFMAP_LOAD))
            dw_open_cnt <= dw_open_cnt + 4'd1;
    end
 
    

    //TODO: stride2的設定
    //前兩次都輸出1筆，後面都是兩筆
    logic dw_out_2_f;//if flag=1, 輸出兩筆 else 輸出一筆
    logic [1:0] stride_cnt;

    always_ff @(posedge clk) begin
        if(reset || (cs == WEIGHT_LOAD) || dw_row_end)
            stride_cnt <= 2'd0;
        else if(stride_cnt == 2'd2)
            stride_cnt <= stride_cnt;
        else if((cs == OPSUM_OUT && ns == IDLE) && dw_stride)
            stride_cnt <= stride_cnt + 2'd1;
    end

    always_ff @(posedge clk) begin
        if(reset || (stride_cnt < 2'd1))//代表只輸出一筆
            dw_out_2_f <= 1'b0;
        else if((DW_PW_sel == 1'd0) && (dw_stride == 1'd1) && (cs == COMPUTE) && (cnt[1:0] == (dw_input_num - 2'd1)))
            dw_out_2_f <= !dw_out_2_f;
    end
//--------------------------------------------------------------//

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
            case(DW_PW_sel)//OKAY
                1'd0: begin //DW
                    if(cnt == row_en - 6'd1)
                        ns = IFMAP_LOAD;
                    else
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
                    if(dw_open_f) begin
                        if(cnt == dw_time_3)
                            ns = PASS;
                        else
                            ns = IFMAP_LOAD;
                    end
                    else begin
                        if(cnt[4:0] == col_en - 5'd1)
                            ns = IPSUM_LOAD;
                        else
                            ns = IFMAP_LOAD;
                    end
                end
                1'd1: begin //PW
                    if(cnt[4:0] == ifmap_load_time)
                        ns = IPSUM_LOAD;
                    else
                        ns = IFMAP_LOAD;
                end
            endcase
        end
        PASS: begin
            if((dw_open_cnt == dw_open_num) && cnt == 8'd2)//最後一次，PE開啟完畢
                ns = IPSUM_LOAD; //如果沒有開啟PE array，就回到IFMAP_LOAD
            else begin
                if(cnt == 8'd2) //每個PE需要4個cycle來計算
                    ns = IDLE;
                else
                    ns = PASS;
            end
                
        end
        IPSUM_LOAD: begin
            case(DW_PW_sel)
                1'd0: begin //DW
                    if(dw_open_f) begin//第一次只要抓最多10筆
                        if(cnt[3:0] == dw_open_num - 4'd1) 
                            ns = COMPUTE;
                        else
                            ns = IPSUM_LOAD;
                    end
                    else begin
                        case(dw_stride)
                            1'd0: begin
                                if(dw_input_num < 2'd3) begin//代表送一筆就夠了
                                    if(cnt[3:0] == dw_open_num - 4'd1) begin//max 10筆
                                        ns = COMPUTE;
                                    end
                                    else
                                        ns = IPSUM_LOAD;
                                end
                                else begin//依舊要送兩筆, max 20筆
                                    if(cnt[4:0] == dw_ip_num)
                                        ns = COMPUTE;
                                    else
                                        ns = IPSUM_LOAD;
                                end
                            end
                            1'd1:begin//固定存一筆(因為1或2都可以一次傳送進來使用) max 10筆
                                if(cnt[3:0] == dw_open_num - 4'd1) begin
                                    ns = COMPUTE;
                                end
                                else
                                    ns = IPSUM_LOAD;
                            end
                        endcase
                    end
                end
                1'd1: begin //PW
                    if(pw_first_f) begin //第一個8個cycle的weight load
                        if(cnt[6:0] == pw_time_8) //pw_time_8 = (pw_open_cnt + 3'd1) << 3 - 7'd1
                            ns = COMPUTE;
                        else 
                            ns = IPSUM_LOAD;
                    end
                    else if(pw_close_f) begin //關閉PE array
                        if(cnt[5:0] == pw_close_num)
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
                    if(dw_open_f)//只需要一個cycle
                        ns = OPSUM_OUT;
                    else if(cnt == (dw_input_num - 2'd1)) //每個PE需要3個cycle來計算
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
                1'd0: begin //DW，共10個FIFO
                    if(dw_open_f) begin//第一次最多只要輸出10筆
                        if(cnt[3:0] == dw_open_num - 4'd1)//最大10筆
                            ns = IDLE;
                        else
                            ns = OPSUM_OUT;
                    end
                    else begin
                        case(dw_stride)
                            1'd0: begin
                                if(dw_input_num < 2'd3) begin//一個FIFO送一次
                                    if(cnt[3:0] == dw_open_num - 4'd1) begin//最大10筆
                                        ns = IDLE;
                                    end
                                    else
                                        ns = OPSUM_OUT;
                                end
                                else begin//一樣一個FIFO要送兩次
                                    if(cnt[4:0] == dw_ip_num) //dw_ip_num = (col_en << 1) - 6'd1
                                        ns = IDLE; 
                                    else 
                                        ns = OPSUM_OUT;
                                end
                            end
                            1'd1: begin
                                if(cnt[3:0] == dw_open_num - 4'd1) begin//最大10筆
                                    ns = IDLE;
                                end
                                else
                                    ns = OPSUM_OUT;
                            end
                        endcase
                    end
                end
                1'd1: begin //PW
                    if(pw_first_f) begin
                        if(cnt[6:0] == pw_time_8) //pw_time_8 = (pw_open_cnt + 3'd1) << 3 - 7'd1
                            ns = IDLE; //代表這32個channel做完，已經
                        else 
                            ns = OPSUM_OUT;
                    end
                    else if(pw_close_f) begin //關閉PE array
                        if(cnt[5:0] == pw_close_num)
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
                if(dw_open_f) begin
                    if(((cs == PASS) && (cnt == 8'd2)) ||
                    (cs == WEIGHT_LOAD && (cnt == row_en - 6'd1)) ||
                    (cs == IFMAP_LOAD && (cnt == dw_time_3)) ||
                    (cs == IPSUM_LOAD && (cnt[3:0] == dw_open_num - 4'd1)) ||
                    (cs == COMPUTE) ||
                    (cs == OPSUM_OUT && (cnt[3:0] == dw_open_num - 4'd1)))
                        cnt <= 8'd0;
                    else if((valid_if && ready_if) || (valid_w && ready_w) || (valid_ip && ready_ip) || (valid_op && ready_op) || (cs == PASS))
                        cnt <= cnt + 8'd1; //每次都+1
                end
                else begin //TODO: stride 2 可能會有問題
                    if(((cs == IFMAP_LOAD) && (cnt == (col_en - 5'd1))) ||
                    ((cs == WEIGHT_LOAD) && (cnt == row_en - 6'd1)) ||
                    ((cs == IPSUM_LOAD) && (dw_input_num < 2'd3) && (cnt[3:0] == dw_open_num - 4'd1)) ||
                    ((cs == IPSUM_LOAD) && (dw_input_num == 2'd3) && (cnt[4:0] == dw_ip_num)) ||
                    ((cs == IPSUM_LOAD) && (dw_input_num == 2'd3) && (cnt[3:0] == dw_open_num - 4'd1) && (dw_stride == 1'd1)) ||
                    ((cs == COMPUTE) && (cnt == (dw_input_num - 2'd1))) ||
                    ((cs == OPSUM_OUT) && (dw_input_num < 2'd3) && (cnt[3:0] == dw_open_num - 4'd1)) ||
                    ((cs == OPSUM_OUT) && (dw_input_num == 2'd3) && (cnt[4:0] == dw_ip_num) && (dw_stride == 1'd0)) ||
                    ((cs == OPSUM_OUT) && (dw_input_num == 2'd3) && (cnt[3:0] == dw_open_num - 4'd1) && (dw_stride == 1'd1))
                    )
                        cnt <= 8'd0;
                    else if((valid_if && ready_if) || (valid_w && ready_w) || (valid_ip && ready_ip) || (valid_op && ready_op) || (cs == COMPUTE))
                        cnt <= cnt + 8'd1;
                end
            end
            1'd1: begin//PW FIXME: OKAY
                if(pw_first_f) begin
                    if(((cs == WEIGHT_LOAD) && (cnt == weight_load_time)) || 
                    ((cs == IFMAP_LOAD) && (cnt[4:0] == ifmap_load_time)) ||
                    ((cs == IPSUM_LOAD) && (cnt[6:0] == pw_time_8)) || 
                    ((cs == OPSUM_OUT) && (cnt[6:0] == pw_time_8))  || 
                    ((cs == COMPUTE) && (cnt == 8'd3)))
                        cnt <= 8'd0;
                    else if((valid_if && ready_if) || (valid_w && ready_w) || (valid_ip && ready_ip) || (valid_op && ready_op) || (cs == COMPUTE))
                        cnt <= cnt + 8'd1;
                end
                else if(pw_close_f) begin
                    if(((cs == IPSUM_LOAD) && (cnt[5:0] == pw_close_num)) || 
                    ((cs == OPSUM_OUT) && (cnt[5:0] == pw_close_num))  || 
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
logic [8191:0] weight_out; //32個ROW，每個ROW 256bit，總共8192bit
logic change_weight_f; //用來決定是否要更新weight

always_ff @(posedge clk) begin
    if(reset || change_weight_f)
        ready_w <= 1'b0; //reset的時候，ready_w = 0
    else if(cs == WEIGHT_LOAD)
        ready_w = 1'b1; //在WEIGHT_LOAD的時候，ready_w = 1
    else
        ready_w = 1'b0; //其他狀態不需要ready_w
end

always_comb begin
    if(cs == IDLE && ns == WEIGHT_LOAD)
        change_weight_f = 1'd1;
    else
        change_weight_f = 1'd0; //其他狀態不需要change_weight_f
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
logic ifmap_out_f;
logic [255:0] ifmap_out; //32個ROW，每個ROW 8bit，總共256bit

always_comb begin
    case(DW_PW_sel)
        1'd0: begin //DW
            ifmap_out_f = (((cs == COMPUTE) || (cs == PASS)) && (cnt < {6'd0, dw_input_num}));
        end
        1'd1: begin //PW
            ifmap_out_f = ((cs == COMPUTE) && (cnt < 8'd4));
        end
    endcase
end

always_comb begin
    if(cs == IFMAP_LOAD)
        ready_if = 1'b1; //在WEIGHT_LOAD的時候，ready_w = 1
    else
        ready_if = 1'b0; //其他狀態不需要ready_w
end

Vertical_Buffer Vertical_Buffer(
    .clk(clk),
    .reset(reset),
    //DW
    .DW_PW_sel(DW_PW_sel), //用來決定是DW還是PW，PW = 1, DW = 0
    .dw_first_f(dw_open_f), //用來決定是否是第一個8個cycle的weight load
    .dw_open_start_num(dw_open_start_num), //用來決定有幾個ROW要使用
    .dw_first_if(dw_first_if),
    //PW
    .col_en(col_in),
    .row_en(row_in), 
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
logic [511:0] ipsum_out;
logic ip_out_dw_f;
logic [1:0] dw_out_times;//輸出幾筆opsum

//一開始為1，後面0 - 1 - 0的交換
always_ff @(posedge clk) begin
    if(reset)
        ip_out_dw_f <= 1'd0;
    else if(dw_stride) begin
        if(stride_cnt == 2'd0) begin
            if(ns == OPSUM_OUT)
                ip_out_dw_f <= 1'd0; //當進入OPSUM_OUT的時候，代表已經完成第一個8個cycle的weight load
            else if(ns == COMPUTE)
                ip_out_dw_f <= 1'd1;
        end
        else if(cs == COMPUTE) begin
            ip_out_dw_f <= ~ip_out_dw_f; 
        end


        if(stride_cnt == 2'd0) 
            dw_out_times <= 2'd1;
        else if(cs == OPSUM_OUT && ns == IDLE)begin
            if(dw_out_times == 2'd1) begin
                dw_out_times <= 2'd2;
            end
            else begin
                dw_out_times <= 2'd1;
            end
        end
    end
end

//if pass signal=1，則不動作 不輸出data
always_comb begin
    if(cs == COMPUTE) begin
        case(DW_PW_sel)
            1'd0: begin //DW
                case(dw_stride)
                    1'd0: begin // stride = 1
                        ipsum_out_f = ((cs == COMPUTE) && (cnt[1:0] < dw_input_num));
                    end
                    1'd1: begin // stride = 2
                        if((cs == COMPUTE) && (cnt[1:0] < dw_input_num))
                        ipsum_out_f = ip_out_dw_f;
                    end
                endcase
            end
            1'd1: begin //PW
                ipsum_out_f = ((cs == COMPUTE) && (cnt < 8'd4));
            end
            default: begin
                ipsum_out_f = 1'b0; //其他狀態不需要ipsum_out_f
            end
        endcase
    end
    else
        ipsum_out_f = 1'b0; //其他狀態不需要ipsum_out_f
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
    .ip_time_4(pw_time_4),//用來決定有幾個ROW要使用
    .first_f(pw_first_f), //用來決定是否是第一個8個cycle的weight load
    //要關閉PE array
    .close_start_num(pw_close_start_num), //用來決定關閉PE array的ROW起始位子
    .close_f(pw_close_f), //用來關閉PE array的信號
    //DW
    .DW_PW_sel(DW_PW_sel), //用來決定是DW還是PW，PW = 1, DW = 0
    .dw_stride(dw_stride), //用來決定是DW還是PW，0 = stride 1, 1 = stride 2
    .dw_input_num(dw_input_num), //決定輸入幾筆ifmap(1-3筆)
    .dw_open_num(dw_open_num), //用來決定有幾個ROW要使用
    .dw_open_f(dw_open_f),

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
logic [511:0] reducer2opsum;
logic store_opsum_f;

always_ff @(posedge clk) begin
    if(reset)
        valid_op <= 1'd0;
    else if(cs == OPSUM_OUT)
        valid_op <= 1'd1; //在OPSUM_OUT的時候，valid_op = 1
    else
        valid_op <= 1'd0; //其他狀態不需要valid_op
end

always_ff @(posedge clk) begin//TODO: 考慮DW
    if(reset)
        store_opsum_f <= 1'b0;
    else if(cs == COMPUTE) begin
        case(DW_PW_sel)
            1'd0:begin
                case(dw_stride)
                    1'd0:begin
                        store_opsum_f <= 1'b1; 
                    end
                    1'd1:begin
                        store_opsum_f <= ip_out_dw_f; //在compute的時候開始儲存opsum
                    end
                endcase
            end
            1'd1:begin
                    store_opsum_f <= 1'b1; //在compute的時候開始儲存opsum
            end        
        endcase
    end
    else
        store_opsum_f <= 1'b0; //讀取opsum後，清除儲存信號
end

Opsum_buffer Opsum_buffer(
    .clk(clk),
    .reset(reset),
    //handshake
    .ready_op(ready_op),
    .valid_op(valid_op),
    //DW
    .DW_PW_sel(DW_PW_sel), 
    .dw_stride(dw_stride), 
    .dw_input_num(dw_input_num), 
    .dw_open_f(dw_open_f),
    .dw_out_times(dw_out_times),
    //PW, first 8 cycle
    .first_f(pw_first_f),
    .ip_time_4(pw_time_4), //用來決定有幾個ROW要使用
    .pw_close_start_num(pw_close_start_num), //用來決定關閉PE array的ROW起始位子
    .close_f(pw_close_f), //用來關閉PE array的信號

    .row_en(row_en), //用來決定有幾個ROW要使用
    .store_opsum_f(store_opsum_f),
    .opsum_in(reducer2opsum),
    .opsum_out(opsum2GLB)//to GLB
);
//--------------------------------------------------------------//


//--------------------------------------------------------------//
//PE array
//TODO: 增加DW的pass功能，讓他可以把所有ifmap擺定位再開始動作
//可能需要改成三個ROW為一組的prod_out_en，因為在conv的時候，第一次都會需要等待他三個cycle就定位才能輸出
wire prod_out_en;
wire [511:0] array_opsum;
logic pe_pass_if;//哪幾個ROW要pass不做運算

always_comb begin
    if(((cs == PASS) && dw_open_f)/* || (cs == COMPUTE && (!ip_out_dw_f))*/)
        pe_pass_if = 1'd1;//TODO: 測試有沒有剛好pass 10 次
    else
        pe_pass_if = 1'd0;//給CONV用
end

assign prod_out_en = (cs == COMPUTE) && (cnt < 8'd4); //在compute的時候開始輸出給Reducer，維持四個cycle

PE_array PE_array(
    .clk(clk),
    .reset(reset),
    .pe_pass_if(pe_pass_if),
    .array_ifmap_in(ifmap_out), //從Vertical_Buffer來的
    .array_weight_in(weight_out), //從Horizontal_Buffer來的
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