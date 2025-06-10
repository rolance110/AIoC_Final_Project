//==============================================================================
// Token Engine FSM – 更新版 (SystemVerilog)
// 
// 此版本根據您最新提供的 I/O 端口定義，調整了訊號名稱與 Handshake 規格。
// 請依下列訊號，搭配您實際的 GLB/PE/PSUM Buffer 介面完成 RTL 實作。
//==============================================================================

`include "../include/define.svh"
module token_engine_fsm (
    //==============================================================================
    // 1) Clock / Reset
    //==============================================================================
    input  logic                 clk,               
    input  logic                 rst,           

    //==============================================================================
    // 2) Pass 觸發與參數 (由 Tile Scheduler / Layer Decoder 提供)
    //==============================================================================
    input  logic                      PASS_START,          // 1clk Pulse：收到後可開始向 GLB 抓值
    input  logic [1:0]                pass_layer_type,     // 
    input  logic [BYTE_CNT_WIDTH-1:0] pass_tile_n,         // 一次 DRAM→GLB 要搬入的 Ifmap bytes 總數
    input  logic [FLAG_WIDTH-1:0]     pass_flags,          // Flags 控制：bit[0]=bias_en, bit[1]=relu_en, bit[2]=skip_en, … 

    input  logic [ADDR_WIDTH-1:0] BASE_IFMAP,         // GLB 中「此層 Ifmap 資料」的起始位址
    input  logic [ADDR_WIDTH-1:0] BASE_WEIGHT,        // GLB 中「此層 Weight 資料」的起始位址
    input  logic [ADDR_WIDTH-1:0] BASE_OPSUM,         // GLB 中「此層 PSUM (Partial/Final) 資料」的起始位址

    input  logic [6:0]           out_C,              // 輸出圖片 column 數量 (width)
    input  logic [6:0]           out_R,              // 輸出圖片 row    數量 (height)

    //==============================================================================
    // 3) GLB 讀取接口 (Ifmap / Weight / Bias)
    //    – Token Engine 驅動 glb_read_addr & glb_read_ready
    //    – 接收 glb_read_valid & glb_read_data
    //==============================================================================
    output logic [ADDR_WIDTH-1:0] glb_read_addr,      // 要讀取的 GLB 位址 (Ifmap / Weight / Bias)
    output logic                  glb_read_ready,     // 1clk 脈衝：開始一次 GLB Read 交易
    input  logic                  glb_read_valid,     // GLB 回應：「此筆 glb_read_data 有效」
    input  logic [DATA_WIDTH-1:0] glb_read_data,      // GLB 回傳的資料 (4×8bit Ifmap/Weight Pack，或 1×Bias)

    //==============================================================================
    // 4) GLB 寫回接口 (PSUM 回寫)
    //    – Token Engine 驅動 glb_write_addr, glb_write_data & glb_write_ready
    //    – 接收 glb_write_valid
    //==============================================================================
    output logic [ADDR_WIDTH-1:0] glb_write_addr,     // 要寫回 GLB 的位址 (PSUM Partial / Final)
    output logic [DATA_WIDTH-1:0] glb_write_data,     // 要寫回 GLB 的 PSUM 資料 (32‐lane Pack 或 4‐channel Pack)
    output logic                  glb_write_ready,    // 1clk 脈衝：開始一次 GLB Write 交易
    input  logic                  glb_write_valid,    // GLB 回應：「此筆 glb_write_data 已寫回完成」
    //==============================================================================
    // 5) PE Array 接口 (Token → PE)
    //    – Token Engine 送 token_data & token_valid
    //    – 監看 pe_busy
    //==============================================================================
    output logic [DATA_WIDTH-1:0] token_data,         // 送給 PE Array 的 Ifmap/Weight/Bias Pack
    // output logic                  token_valid,        // 1clk 脈衝：token_data + token_tag 現在有效
    // input  logic                  pe_busy,            // PE Array 拉高表示「目前忙碌中，尚在 Compute」//FIXME: 感覺不用

    //==============================================================================
    // 6) Padding 控制 (Depthwise 或 空間 Padding)
    //==============================================================================
    output logic                 control_padding,    // 1 = 有 Padding；0 = 無 Padding

    //==============================================================================
    // 7) PSUM Buffer → Token Engine (Pop)
    //    – PSUM Buffer pop 出累計結果後拉 pe_psum_valid
    //    – Token Engine 回 pe_psum_ready 表示可 pop 下一筆
    //==============================================================================
    input  logic [DATA_WIDTH-1:0] pe_psum_data,       // PSUM Buffer pop 出的累加結果
    input  logic                  pe_psum_valid,      // PSUM Buffer 回：pe_psum_data 有效
    output logic                  pe_psum_ready,      // Token Engine 拉高後，PSUM Buffer 才 pop 出下一筆
    input pe_weight_ready,
    output logic pe_weight_valid,
    input pe_ifmap_ready,
    output logic pe_ifamp_valid,
    input pe_bias_ready,
    output logic pe_bias_valid,
    // output logic pe_psum_ready,
    // input pe_psum_valid
    input logic [6:0] tile_K_o;
    input logic [5:0] tile_D, // 記得接真實的

    output logic [5:0] col_en, // 給pe確定有幾行要算
    output logic [5:0] row_en, // 給pe確定有幾個WEIGHT要算
    //==============================================================================
    //==============================================================================
    // Depthwise 
    //==============================================================================

    output logic [1:0] compute_num,
    output logic change_row,//換row訊號
    input logic [6:0] in_C, //輸入特徵圖 Width column
    input logic [6:0] in_R, //輸入特徵圖 Height row
    input [1:0] stride,

    //==============================================================================
    // 8) Pass 完成回報 (送給 Tile Scheduler)
    //==============================================================================
    output logic                 pass_done           // 1clk 脈衝：本次 Pass (Tile) Ifmap→MAC→PSUM 回寫全流程完成
);

    //==========================================================================
    // 參數設定
    //==========================================================================
    parameter ADDR_WIDTH     = 16;  // GLB 地址寬度
    parameter DATA_WIDTH     = 32;  // GLB / PE 資料寬度 (4×8bit Pack or 1×32bit)
    parameter BYTE_CNT_WIDTH = 16;  // pass_tile_n 寬度
    parameter FLAG_WIDTH     = 4;   // pass_flags 寬度
    parameter IDX_WIDTH      = 4;   // tile 索引 (K, D 方向各自用)
    parameter TAG_WIDTH      = 3;   // token_tag 寬度 (0~⌈tile_D/4⌉-1)
    parameter FIFO_IDX_WIDTH = 3;   // 4-Channel Pack index (0~7)

    //==========================================================================
    // state定義 (enum 型態)
    //==========================================================================
    typedef enum logic [3:0] {
        S_IDLE        ,
        S_READ_WEIGHT ,
        S_WRITE_WEIGHT,
        S_READ_IFMAP  ,
        S_WRITE_IFMAP ,
        S_READ_BIAS   ,
        S_WRITE_BIAS  ,
        S_WAIT_OPSUM  ,
        S_WRITE_OPSUM ,
        S_PASS_DONE   
    } state_t;

    state_t current_state, next_state;

    //==========================================================================
    // 內部暫存器 (Latched Inputs & Counters)
    //==========================================================================
    logic [5:0]            tile_D_internal;    // 6-bit: 由 pass_layer_type 決定 (32 or 10)
    logic [5:0]            tile_K_internal;    // 6-bit: 由 pass_layer_type 決定 (32 or 10)

    logic [DATA_WIDTH-1:0] data_2_pe_reg;

    // Counters 數送了幾個
    logic [5:0]            cnt_bias;          // 已推 Bias 的筆數
    logic [5:0]            cnt_ifmap;         // 已推 Ifmap
    logic [5:0]            cnt_weight;        // 已推 Weight
    logic [5:0]            cnt_psum;          // 已 pop OPSUM 寫回的筆數

    logic [ADDR_WIDTH-1:0] weight_addr;       // Weight 的位址計數器
    logic [ADDR_WIDTH-1:0] ifmap_addr;        // Ifmap 的位址計數器
    logic [ADDR_WIDTH-1:0] bias_addr;         // Bias 的位址計數器
    logic [ADDR_WIDTH-1:0] opsum_addr;        // OPSUM 的位址計數器
    

    //===== 會拿通道數去 計算opsum_row_num
    logic [4:0] opsum_row_num; // OPSUM 有寫回的 row 數量

    //---------------------------------------------------
    // ofmap_addr
    //---------------------------------------------------
    logic [3:0] cnt_modify;
    logic [8:0] opsum_hsk_cnt;
    logic [8:0] ifmap_hsk_cnt; // for depthwise enable open
    logic [5:0] d_cnt;
    logic [7:0] n_cnt
    logic [5:0] k_cnt;
    logic [7:0] col_en_cnt;
    logic [31:0] channel_base;

    //---------------------------------------------------
    // opsum_addr 0~31
    //---------------------------------------------------

    logic [ADDR_WIDTH-1:0] opsum_addr0;
    logic [ADDR_WIDTH-1:0] opsum_addr1;
    logic [ADDR_WIDTH-1:0] opsum_addr2;
    logic [ADDR_WIDTH-1:0] opsum_addr3;
    logic [ADDR_WIDTH-1:0] opsum_addr4;
    logic [ADDR_WIDTH-1:0] opsum_addr5;
    logic [ADDR_WIDTH-1:0] opsum_addr6;
    logic [ADDR_WIDTH-1:0] opsum_addr7;
    logic [ADDR_WIDTH-1:0] opsum_addr8;
    logic [ADDR_WIDTH-1:0] opsum_addr9;
    logic [ADDR_WIDTH-1:0] opsum_addr10;
    logic [ADDR_WIDTH-1:0] opsum_addr11;
    logic [ADDR_WIDTH-1:0] opsum_addr12;
    logic [ADDR_WIDTH-1:0] opsum_addr13;
    logic [ADDR_WIDTH-1:0] opsum_addr14;
    logic [ADDR_WIDTH-1:0] opsum_addr15;
    logic [ADDR_WIDTH-1:0] opsum_addr16;
    logic [ADDR_WIDTH-1:0] opsum_addr17;
    logic [ADDR_WIDTH-1:0] opsum_addr18;
    logic [ADDR_WIDTH-1:0] opsum_addr19;
    logic [ADDR_WIDTH-1:0] opsum_addr20;
    logic [ADDR_WIDTH-1:0] opsum_addr21;
    logic [ADDR_WIDTH-1:0] opsum_addr22;
    logic [ADDR_WIDTH-1:0] opsum_addr23;
    logic [ADDR_WIDTH-1:0] opsum_addr24;
    logic [ADDR_WIDTH-1:0] opsum_addr25;
    logic [ADDR_WIDTH-1:0] opsum_addr26;
    logic [ADDR_WIDTH-1:0] opsum_addr27;
    logic [ADDR_WIDTH-1:0] opsum_addr28;
    logic [ADDR_WIDTH-1:0] opsum_addr29;
    logic [ADDR_WIDTH-1:0] opsum_addr30;
    logic [ADDR_WIDTH-1:0] opsum_addr31;
    logic [31:0] opsum_num;

    //==========================================================================
    //CNT : 數總共送了幾筆，方便轉換狀態
    //==========================================================================
    always_ff @ (posedge clk) begin
        if(rst) begin
            cnt_weight <= 0;
        end
        else if (current_state == S_WRITE_WEIGHT && pe_weight_valid && pe_weight_ready) begin
            if (cnt_weight == tile_K_o) begin // 假設每次搬入 32 個 Weight Pack
                cnt_weight <= 0; // 重置計數器
            end 
            else begin
                cnt_weight <= cnt_weight + 1; // 每次搬入 4-Channel Pack (32-bit)
            end
        end
    end

    // ifmap
    always_ff @ (posedge clk) begin
        if(rst) begin
            cnt_ifmap <= 0;
        end
        else if (current_state == S_WRITE_IFMAP && pe_ifamp_valid && pe_ifmap_ready) begin
            if (cnt_ifmap == col_en) begin // 假設每次搬入 32 個 Ifmap Pack
                cnt_ifmap <= 0; // 重置計數器
            end 
            else begin
                cnt_ifmap <= cnt_ifmap + 1; // 每次搬入 4-Channel Pack (32-bit)
            end
        end
    end
    // bias 
    //FIXME: 這邊的 cnt_bias 還沒考慮 stride 的情況
    always_ff @ (posedge clk) begin//因為你現在cnt 式握手一次就加一次，所以握兩次才代表要換拿下一張圖的資訊
        if(rst) begin
            cnt_bias <= 0;
        end
        else if (pass_layer_type == `POINTWISE) begin
            if (current_state == S_WRITE_BIAS && pe_bias_valid && pe_bias_ready) begin
                if (cnt_bias == 2*col_en) begin // 假設每次搬入 32 個 Bias Pack
                    cnt_bias <= 0; // 重置計數器
                end 
                else begin
                    cnt_bias <= cnt_bias + 1; // 每次搬入 4-Channel Pack (32-bit)
                end
            end
        end
        else if (pass_layer_type == `DEPTHWISE) begin
            if (current_state == S_WRITE_BIAS && pe_bias_valid && pe_bias_ready) begin
                if (cnt_bias == (2*col_en/3)) begin // 假設每次搬入 32 個 Bias Pack
                    cnt_bias <= 0; // 重置計數器
                end 
                else begin
                    cnt_bias <= cnt_bias + 1; // 每次搬入 4-Channel Pack (32-bit)
                end
            end
        end
    end    
    
    //cnt_psum
    always_ff @ (posedge clk) begin
        if(rst) begin
            cnt_psum <= 0;
        end
        else if(pass_layer_type == `POINTWISE) begin
            if (current_state == S_WRITE_OPSUM && glb_write_valid && glb_write_ready) begin
                if (cnt_psum == 2*tile_K_o) begin 
                    cnt_psum <= 0; // 重置計數器
                end 
                else begin
                    cnt_psum <= cnt_psum + 1; // 每次搬入 4-Channel Pack (32-bit)
                end
            end
        end
        else if (pass_layer_type == `DEPTHWISE) begin
            if (current_state == S_WRITE_OPSUM && glb_write_valid && glb_write_ready) begin
                if(stride == 2'd1) begin
                    if (cnt_psum == (1 + 3*n_cnt)<<1) begin // FIXME: 確認n_cnt是這個?
                        cnt_psum <= 0; // 重置計數器
                    end 
                    else begin
                        cnt_psum <= cnt_psum + 1; // 每次搬入 4-Channel Pack (32-bit)
                    end
                end
                else if(stride == 2'd2) begin
                    if (cnt_psum == d2_opsum_num*2) begin // FIXME: 還沒想好
                        cnt_psum <= 0; // 重置計數器
                    end 
                    else begin
                        cnt_psum <= cnt_psum + 1; // 每次搬入 4-Channel Pack (32-bit)
                    end
                end
            end
        end
    end

    always_ff @ (posedge clk) begin
        if (rst) begin
            col_en_cnt <= 8'd0;
        end
        else if (col_en_cnt == col_en) begin
            col_en_cnt <= 8'd0;
        end
        else if (pe_ifamp_valid && pe_ifmap_ready)begin
            col_en_cnt <= col_en_cnt + 8'd1;
        end
    end   

    logic        start,       // 啟動訊號（例如每送出一筆就拉高一拍）
    logic [9:0] opsum_addr   // 假設是 10-bit 位址


    logic [9:0] d2_opsum_num; // depthwise stride 2 opsum number 
    logic [3:0] count;              // 控制遞增模式（最多可支援超過 8 次跳躍）
    logic [1:0] phase;              // 控制 1、2 的輪替
    logic       first;              // 第一次 +1 特殊處理

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            d2_opsum_num   <= 10'd0;
            count  <= 4'd0;
            phase  <= 2'd0;
            first  <= 1'b1;
        end 
        else if(change_row) begin
            phase  <= 2'd0;
            first  <= 1'b1;
        end 
        else if (start) begin
            if (first) begin
                d2_opsum_num  <= d2_opsum_num + 10'd1; // 第一次固定 +1
                first <= 1'b0;
            end 
            else begin
                if (phase == 1'd0) begin
                    d2_opsum_num <= d2_opsum_num + 10'd2; // 奇數階段跳 2
                end 
                else begin
                    d2_opsum_num <= d2_opsum_num + 10'd1; // 偶數階段跳 1
                end
                phase <= ~phase; // 輪替 phase
            end
            count <= count + 1;
        end
    end

    // assign opsum_addr = d2_opsum_num;






    //==========================================================================
    //DEPTHWISE
    //==========================================================================
    logic enable0;
    logic enable1;
    logic enable2;
    logic enable3;
    logic enable4;
    logic enable5;
    logic enable6;
    logic enable7;
    logic enable8;
    logic enable9;

    logic [BYTE_CNT_WIDTH-1:0] tile_R; //dEPTHWISE 沒PADDING的ROW數
    assign tile_R = pass_tile_n - 2;
    //hsk 時 +1， 因 hsk cnt 會有歸0的情況，當數到 tile_n * tile_K_o 時，此次tile算完
    logic [31:0] total_opsum_num_cnt; 


    logic can_compute;//用來判斷是否可以換到 bias 狀態，還是要繼續讀ifmap
    // 若需要外部索引 (tile_k_idx, tile_d_idx) 可在此新增，但簡化示例省略

    // assign col_en = tile_D;   
    always_comb begin
        if (pass_layer_type == `POINTWISE) begin
            col_en = tile_D;
        end
        else if (pass_layer_type == `DEPTHWISE) begin
            col_en = (enable0 + enable1 + enable2 + 
                      enable3 + enable4 + enable5 + 
                      enable6 + enable7 + enable8 + 
                      enable9) * 3;
        end
    end

    assign row_en = tile_K_o;

    //can_compute //FIXME: only for depthwise
    always_ff @ (posedge clk) begin
        if (rst) begin
            can_compute <= 1'b0;
        end
        else if (change_row) begin
            can_compute <= 1'b0;
        end
        else if (col_en == 6'd30) begin
            can_compute <= 1'b1;
        end
    end


    //==========================================================================
    // 1) Seq. Logic: 狀態暫存 (State Register)
    //==========================================================================
    always_ff @(posedge clk) begin
        if (rst) begin
            current_state   <= S_IDLE;
        end 
        else begin
            current_state   <= next_state;
        end
    end 
    //==========================================================================
    // next_state
    //==========================================================================
    always_comb begin
        if(pass_layer_type == `POINTWISE) begin // 32-Channel Pack
            case (current_state)
                S_IDLE: begin
                    if (PASS_START) begin
                        next_state = S_READ_WEIGHT;
                    end 
                    else begin
                        next_state = S_IDLE;
                    end
                end

                S_READ_WEIGHT: begin
                    if (glb_read_valid && glb_read_ready) begin
                        next_state = S_WRITE_WEIGHT;
                    end 
                    else begin
                        next_state = S_READ_WEIGHT;
                    end
                end

                //FIXME: 可能改
                S_WRITE_WEIGHT: begin
                    // 把 glb_read_data (Weight Pack) 推送到內部 pe，或做後續處理
                    if (cnt_weight == 6'd31 && pe_weight_ready && pe_weight_valid) begin // FIXME: check 32?
                        next_state = S_READ_IFMAP;
                    end 
                    else if(pe_weight_ready && pe_weight_valid) begin
                        next_state = S_READ_WEIGHT;
                    end 
                    else begin
                        next_state = S_WRITE_WEIGHT;
                    end
                end

                S_READ_IFMAP: begin
                    if (glb_read_valid && glb_read_ready) begin
                        next_state = S_WRITE_IFMAP;
                    end 
                    else begin
                        next_state = S_READ_IFMAP;
                    end
                end

                //FIXME:可能改
                S_WRITE_IFMAP: begin
                    if (cnt_ifmap == 6'd31 && pe_ifamp_valid && pe_ifmap_ready) begin  //後面不一定是 32 可以改成一個parameter (ifmap 不夠大或是 channel 不夠多)
                        next_state = S_READ_BIAS;
                    end 
                    else if(pe_ifamp_valid && pe_ifmap_ready) begin
                        next_state = S_READ_IFMAP;
                    end
                    else begin
                        next_state = S_WRITE_IFMAP;
                    end
                end
                
                S_READ_BIAS: begin
                    if (glb_read_valid && glb_read_ready) begin
                        next_state = S_WRITE_BIAS;
                    end 
                    else begin
                        next_state = S_READ_BIAS;
                    end
                end


                //FIXME:可能改
                S_WRITE_BIAS: begin
                    
                    if ((cnt_bias == 6'd63) && pe_bias_valid && pe_bias_ready) begin //後面不一定是 32 可以改成一個parameter (ifmap 不夠大或是 channel 不夠多)
                        next_state = S_WAIT_OPSUM;
                    end 
                    else if (pe_bias_valid && pe_bias_ready) begin
                        next_state = S_READ_BIAS;
                    end 
                    else begin
                        next_state = S_WRITE_BIAS;
                    end
                end
                
                S_WAIT_OPSUM: begin
                    // 等待 PE / PSUM Buffer pop 出累加結果 (OPSUM)
                    if (pe_psum_valid && pe_psum_ready) begin
                        next_state = S_WRITE_OPSUM;
                    end 
                    else begin
                        next_state = S_WAIT_OPSUM;
                    end
                end

                S_WRITE_OPSUM: begin
                    // 將剛 Pop 出來的 OPSUM 寫回 GLB
                    if (glb_write_valid && glb_write_ready) begin
                        //FIXME: 還沒寫
                        if (total_opsum_num_cnt == (pass_tile_n * tile_K_o)) begin //整個算完
                            next_state = S_PASS_DONE;
                        end
                        else if (cnt_psum == 2*tile_K_o) begin
                            next_state = S_READ_IFMAP; // FIXME: 這裡的條件要根據實際情況調整
                        end
                        else begin
                            next_state = S_WAIT_OPSUM;
                        end
                    end 
                    else begin
                        next_state = S_WRITE_OPSUM;
                    end
                end

                S_PASS_DONE: begin //送出一個東西啟動DMA搬值(PASS_DONE)
                    next_state = S_IDLE;
                end

                default: begin
                    next_state = S_IDLE; // 預設回到 S_IDLE
                end
            endcase
        end


        else if (pass_layer_type == `DEPTHWISE) begin
            case (current_state)
                S_IDLE: begin
                    if (PASS_START) begin
                        next_state = S_READ_WEIGHT;
                    end 
                    else begin
                        next_state = S_IDLE;
                    end
                end

                S_READ_WEIGHT: begin
                    if (glb_read_valid && glb_read_ready) begin
                        next_state = S_WRITE_WEIGHT;
                    end 
                    else begin
                        next_state = S_READ_WEIGHT;
                    end
                end

                //FIXME:
                S_WRITE_WEIGHT: begin
                    if (cnt_weight == 6'd29 && pe_weight_ready && pe_weight_valid) begin // FIXME: check 32?
                        next_state = S_READ_IFMAP;
                    end 
                    else if(pe_weight_ready && pe_weight_valid) begin
                        next_state = S_READ_WEIGHT;
                    end 
                    else begin
                        next_state = S_WRITE_WEIGHT;
                    end
                end

                S_READ_IFMAP: begin
                    if (glb_read_valid && glb_read_ready) begin
                        next_state = S_WRITE_IFMAP;
                    end 
                    else begin
                        next_state = S_READ_IFMAP;
                    end
                end

                //FIXME:可能改
                S_WRITE_IFMAP: begin
                    if (col_en_cnt == col_en) begin
                        if (can_compute) begin  //後面不一定是 32 可以改成一個parameter (ifmap 不夠大或是 channel 不夠多)
                            next_state = S_READ_BIAS;
                        end 
                        else begin
                            next_state = S_READ_IFMAP;
                        end
                    end
                    else if(pe_ifamp_valid && pe_ifmap_ready) begin
                        next_state = S_READ_IFMAP;
                    end
                    else begin
                        next_state = S_WRITE_IFMAP;
                    end
                end
                
                S_READ_BIAS: begin
                    if (glb_read_valid && glb_read_ready) begin
                        next_state = S_WRITE_BIAS;
                    end 
                    else begin
                        next_state = S_READ_BIAS;
                    end
                end


                //FIXME:可能改
                S_WRITE_BIAS: begin
                    if ((cnt_bias == 2*(tile_K_o-1)) && pe_bias_valid && pe_bias_ready) begin 
                        next_state = S_WAIT_OPSUM;
                    end 
                    else if (pe_bias_valid && pe_bias_ready) begin
                        next_state = S_READ_BIAS;
                    end 
                    else begin
                        next_state = S_WRITE_BIAS;
                    end
                end
                
                S_WAIT_OPSUM: begin
                    if (pe_psum_valid && pe_psum_ready) begin
                        next_state = S_WRITE_OPSUM;
                    end 
                    else begin
                        next_state = S_WAIT_OPSUM;
                    end
                end

                S_WRITE_OPSUM: begin
                    if (glb_write_valid && glb_write_ready) begin
                        if (total_opsum_num_cnt == (tile_R * in_C * tile_K_o)) begin //整個算完
                            next_state = S_PASS_DONE;
                        end
                        else if (cnt_psum == 1+3*n_cnt && stride == 2'd1) begin // FIXME: 尚未考慮stride = 2的情況
                            next_state = S_READ_IFMAP; // FIXME: 這裡的條件要根據實際情況調整
                        end
                        else if(cnt_psum == d2_opsum_num && stride == 2'd2) begin
                            next_state = S_READ_IFMAP;
                        end
                        else begin
                            next_state = S_WAIT_OPSUM;
                        end
                    end 
                    else begin
                        next_state = S_WRITE_OPSUM;
                    end
                end

                S_PASS_DONE: begin //送出一個東西啟動DMA搬值(PASS_DONE)
                    next_state = S_IDLE;
                end

                default: begin
                    next_state = S_IDLE; // 預設回到 S_IDLE
                end
            endcase
        end

        else if (pass_layer_type == `STANDARD) begin

        end

        else begin //LINEAR
            
        end
    end

    //---------- ifmap ----------//
    // todo: save the ifmap data
    always_comb begin
        data_2_pe_reg = glb_read_data; // 假設 glb_read_data 是 4-Channel Pack
    end
//---------------------------------------------------
// weight, ifmap, bias, opsum, token 等訊號的 Handshake
//---------------------------------------------------
//FIXME: 還沒考慮丟給PPU的部分
always_comb begin
    if(current_state == S_WRITE_OPSUM || current_state == S_WAIT_OPSUM) begin
        glb_write_data = pe_psum_data;
    end
    else begin
        glb_write_data = '0; // 清除資料
    end
end
always_comb begin
    if (current_state == S_READ_WEIGHT || current_state == S_READ_IFMAP || current_state == S_READ_BIAS) begin
        glb_read_ready = 1'b1;
    end
    else begin
        glb_read_ready = 1'b0;
    end
end

always_comb begin
    if(current_state == S_WRITE_WEIGHT || current_state == S_WRITE_IFMAP || current_state == S_WRITE_BIAS) begin
        token_data = data_2_pe_reg; // 將讀取到的資料送給 PE
    end
    else begin
        token_data = '0; // 清除資料
    end
end


always_comb begin
    if (current_state == S_WRITE_WEIGHT) begin
        pe_weight_valid = 1'b1;
    end
    else begin
        pe_weight_valid = 1'b0;
    end
end

always_comb begin
    if (current_state == S_WRITE_IFMAP) begin
        pe_ifamp_valid = 1'b1;
    end
    else begin
        pe_ifamp_valid = 1'b0;
    end
end

always_comb begin
    if (current_state == S_WRITE_BIAS) begin
        pe_bias_valid = 1'b1;
    end
    else begin
        pe_bias_valid = 1'b0;
    end
end

always_comb begin
    if (current_state == S_WRITE_OPSUM) begin
        glb_write_ready = 1'b1; // 準備寫回 OPSUM
    end
    else begin
        glb_write_ready = 1'b0;
    end
end

always_comb begin
    if (current_state == S_WAIT_OPSUM) begin
        pe_psum_ready = 1'b1; // 準備 pop OPSUM
    end
    else begin
        pe_psum_ready = 1'b0;
    end
end

//---------------------------------------------------
// weight, ifmap, bias, opsum 等 addr 的計算
//---------------------------------------------------
// weight_addr
always_ff@(posedge clk) begin
    if(rst) begin
        weight_addr <= 0;
    end 
    else if (pass_layer_type == `POINTWISE) begin
        if(current_state == IDLE) begin
            weight_addr <= BASE_WEIGHT;
        end 
        else if(current_state == S_WRITE_WEIGHT && pe_weight_valid && pe_weight_ready) begin
            weight_addr <= weight_addr + 4;
        end
    end
    else if (pass_layer_type == `DEPTHWISE) begin
        if(current_state == IDLE) begin
            weight_addr <= BASE_WEIGHT;
        end 
        else if(current_state == S_WRITE_WEIGHT && pe_weight_valid && pe_weight_ready) begin
            weight_addr <= weight_addr + 3;
        end
    end
end

//---------------------------------------------------
// ifmap_addr 、 bias_addr
//---------------------------------------------------
// d_cnt
logic [7:0] y_cnt;
always_ff@(posedge clk) begin
    if(rst) begin
       d_cnt <= 0; // d_cnt 用於計算 Ifmap 的 Channel Pack 數量
    end 
    else if (pass_layer_type == `POINTWISE) begin
        if(current_state == S_WRITE_IFMAP&& (pe_ifamp_valid && pe_ifmap_ready)) begin
            d_cnt <= (d_cnt == tile_D) ? 0 : d_cnt + 1; // 每次搬入 4-Channel Pack (32-bit)
        end
        else if (pe_bias_valid && pe_bias_ready) begin
            d_cnt <= (d_cnt == 2*tile_D) ? 0 : d_cnt + 1; // 每次搬入 4-Channel Pack (32-bit)
        end
    end
    else if (pass_layer_type == `DEPTHWISE) begin   
        if(current_state == S_WRITE_IFMAP) begin
            if(d_cnt == tile_D) begin
                d_cnt <= 6'd0;
            end
            else if(y_cnt == 8'd0 || y_cnt == in_R - 1) begin
                if(ifmap_hsk_cnt == 9'd2) begin
                    d_cnt <= d_cnt + 6'd1;
                end
            end
            else begin
                if(ifmap_hsk_cnt == 9'd3) begin
                    d_cnt <= d_cnt + 6'd1;
                end
            end
        end
        else if (current_state == S_WRITE_BIAS) begin
            if(d_cnt == tile_D) begin
                d_cnt <= 6'd0;
            end
            else begin
                if(cnt_bias[0] && (pe_bias_valid && pe_bias_ready)) begin
                    d_cnt <= d_cnt + 6'd1;
                end
            end
        end
        else if (current_state == S_WRITE_OPSUM && glb_write_valid && glb_write_ready) begin
            if(d_cnt == tile_D) begin
                d_cnt <= 6'd0;
            end
            else begin
                d_cnt <= d_cnt + 6'd1; // 每次搬入 4-Channel Pack (32-bit)
            end
        end
    end
end

// ifmap_hsk_cnt
always_ff@(posedge clk) begin
    if(rst) begin
        ifmap_hsk_cnt <= 9'd0;
    end
    else if(current_state == S_READ_IFMAP && glb_read_valid && glb_read_ready) begin
        if(y_cnt == 8'd0 || y_cnt == in_R - 1) begin
             if(ifmap_hsk_cnt == 9'd2) begin
                ifmap_hsk_cnt <= 9'd0;
             end
        end
        else if(ifmap_hsk_cnt == 9'd3)begin
            ifmap_hsk_cnt <= 9'd0;
        end
        else begin
            ifmap_hsk_cnt <= ifmap_hsk_cnt + 9'd1;
        end
    end 
end

// n_cnt
always_ff@(posedge clk) begin
    if(rst) begin
        n_cnt <= 0; // n_cnt 用於計算 Ifmap 的 Channel Pack 數量
    end
    //
    else if (pass_layer_type == `POINTWISE) begin
        if (current_state == S_WRITE_IFMAP && pe_ifamp_valid && pe_ifmap_ready) begin
            if(d_cnt == tile_D)
                n_cnt <= ((n_cnt << 2) > pass_tile_n) ? 0 : n_cnt + 1; // 每次搬入 4-Channel Pack (32-bit)
        end
        else if (current_state == S_WRITE_BIAS && pe_bias_valid && pe_bias_ready) begin
            if(d_cnt == tile_D)
                n_cnt <= ((n_cnt << 3) > pass_tile_n) ? 0 : n_cnt + 1; // 每次搬入 4-Channel Pack (32-bit)
        end
        else if (current_state == S_WRITE_OPSUM && glb_write_valid && glb_write_ready) begin
            //FIXME:
            if(d_cnt == tile_D)
                n_cnt <= ((n_cnt << 3) > pass_tile_n) ? 0 : n_cnt + 1; // 每次搬入 4-Channel Pack (32-bit)
        end
    end
end

//------------------ n_cnt 0~9 for depthwise ------------------//
logic [7:0] n_cnt0, n_cnt1, n_cnt2, n_cnt3, n_cnt4, n_cnt5, n_cnt6, n_cnt7, n_cnt8, n_cnt9;

//n_cnt0
always_ff@(posedge clk) begin
    if (rst) begin
        n_cnt0 <= 8'd0;
    end
    else if (change_row) begin
        n_cnt0 <= 8'd0;
    end
    else if(col_en_cnt == 9'd3)begin
        n_cnt0 <= n_cnt0 + 8'd1;
    end
end

//n_cnt1
always_ff@(posedge clk) begin
    if (rst) begin
        n_cnt1 <= 8'd0;
    end
    else if (change_row) begin
        n_cnt1 <= 8'd0;
    end
    else if(col_en_cnt == 9'd6)begin
        n_cnt1 <= n_cnt1 + 8'd1;
    end
end

//n_cnt2
always_ff@(posedge clk) begin
    if (rst) begin
        n_cnt2 <= 8'd0;
    end
    else if (change_row) begin
        n_cnt2 <= 8'd0;
    end
    else if(col_en_cnt == 9'd9)begin
        n_cnt2 <= n_cnt2 + 8'd1;
    end
end

//n_cnt3
always_ff@(posedge clk) begin
    if (rst) begin
        n_cnt3 <= 8'd0;
    end
    else if (change_row) begin
        n_cnt3 <= 8'd0;
    end
    else if(col_en_cnt == 9'd12)begin
        n_cnt3 <= n_cnt3 + 8'd1;
    end
end

//n_cnt4
always_ff@(posedge clk) begin
    if (rst) begin
        n_cnt4 <= 8'd0;
    end
    else if (change_row) begin
        n_cnt4 <= 8'd0;
    end
    else if(col_en_cnt == 9'd15)begin
        n_cnt4 <= n_cnt4 + 8'd1;
    end
end

//n_cnt5
always_ff@(posedge clk) begin
    if (rst) begin
        n_cnt5 <= 8'd0;
    end
    else if (change_row) begin
        n_cnt5 <= 8'd0;
    end
    else if(col_en_cnt == 9'd18)begin
        n_cnt5 <= n_cnt5 + 8'd1;
    end
end

//n_cnt6
always_ff@(posedge clk) begin
    if (rst) begin
        n_cnt6 <= 8'd0;
    end
    else if (change_row) begin
        n_cnt6 <= 8'd0;
    end
    else if(col_en_cnt == 9'd21)begin
        n_cnt6 <= n_cnt6 + 8'd1;
    end
end

//n_cnt7
always_ff@(posedge clk) begin
    if (rst) begin
        n_cnt7 <= 8'd0;
    end
    else if (change_row) begin
        n_cnt7 <= 8'd0;
    end
    else if(col_en_cnt == 9'd24)begin
        n_cnt7 <= n_cnt7 + 8'd1;
    end
end

//n_cnt8
always_ff@(posedge clk) begin
    if (rst) begin
        n_cnt8 <= 8'd0;
    end
    else if (change_row) begin
        n_cnt8 <= 8'd0;
    end
    else if(col_en_cnt == 9'd27)begin
        n_cnt8 <= n_cnt8 + 8'd1;
    end
end

//n_cnt9
always_ff@(posedge clk) begin
    if (rst) begin
        n_cnt9 <= 8'd0;
    end
    else if (change_row) begin
        n_cnt9 <= 8'd0;
    end
    else if(col_en_cnt == 9'd30)begin
        n_cnt9 <= n_cnt9 + 8'd1;
    end
end

//k_cnt
always_ff@(posedge clk) begin
    if(rst) begin
        k_cnt <= 0; // k_cnt 用於計算 Weight 的 Channel Pack 數量
    end 
    else if (pass_layer_type == `POINTWISE) begin
        if(current_state == S_WRITE_OPSUM && pe_weight_valid && pe_weight_ready) begin
            if(k_cnt == (tile_K_o - 1)) begin
                k_cnt <= 0; // 重置 k_cnt
            end 
            //原本是3
            else if (current_state == S_WRITE_OPSUM && (opsum_hsk_cnt == (cnt_modify + 1) << 3)) begin
                k_cnt <= 0;
            end
            else begin
                if (opsum_hsk_cnt[0] && glb_write_ready && glb_write_valid) begin
                    k_cnt <= k_cnt + 1; // 每次搬入 4-Channel Pack (32-bit)
                end
            end
        end
    end
    else if (pass_layer_type == `DEPTHWISE) begin
        if (k_cnt == (tile_K_o - 1)) begin
            k_cnt <= 0; // 重置 k_cnt
        end 
        else if (opsum_hsk_cnt[0] && glb_write_ready && glb_write_valid) begin
            k_cnt <= k_cnt + 1; // 每次搬入 4-Channel Pack (32-bit)
        end
    end
end

//---------- ifmap addr0~9 for depthwise ----------//
logic [ADDR_WIDTH-1:0] ifmap_addr0, ifmap_addr1, ifmap_addr2, ifmap_addr3, ifmap_addr4, ifmap_addr5, ifmap_addr6, ifmap_addr7, ifmap_addr8, ifmap_addr9;
always_ff@(posedge clk) begin
    if(rst) begin
        ifmap_addr0 <= 0;
        ifmap_addr1 <= 0;
        ifmap_addr2 <= 0;
        ifmap_addr3 <= 0;
        ifmap_addr4 <= 0;
        ifmap_addr5 <= 0;
        ifmap_addr6 <= 0;
        ifmap_addr7 <= 0;
        ifmap_addr8 <= 0;
        ifmap_addr9 <= 0;
    end 
    else if(current_state == S_IDLE) begin
        ifmap_addr0 <= BASE_IFMAP;
        ifmap_addr1 <= BASE_IFMAP + in_C * tile_R;
        ifmap_addr2 <= BASE_IFMAP + in_C * tile_R * 2;
        ifmap_addr3 <= BASE_IFMAP + in_C * tile_R * 3;
        ifmap_addr4 <= BASE_IFMAP + in_C * tile_R * 4;
        ifmap_addr5 <= BASE_IFMAP + in_C * tile_R * 5;
        ifmap_addr6 <= BASE_IFMAP + in_C * tile_R * 6;
        ifmap_addr7 <= BASE_IFMAP + in_C * tile_R * 7;
        ifmap_addr8 <= BASE_IFMAP + in_C * tile_R * 8;
        ifmap_addr9 <= BASE_IFMAP + in_C * tile_R * 9;
    end 
    else if(current_state == S_WRITE_IFMAP && pe_ifamp_valid && pe_ifmap_ready) begin
        ifmap_addr0 <= ifmap_addr0 + n_cnt0 * 3 + (enable0 && n_cnt0 == 0) << 2 + in_C * c_cnt; // n_cnt0 為 4-Channel Pack 的數量
        ifmap_addr1 <= ifmap_addr1 + n_cnt1 * 3 + (enable1 && n_cnt1 == 0) << 2 + in_C * c_cnt;
        ifmap_addr2 <= ifmap_addr2 + n_cnt2 * 3 + (enable2 && n_cnt2 == 0) << 2 + in_C * c_cnt;
        ifmap_addr3 <= ifmap_addr3 + n_cnt3 * 3 + (enable3 && n_cnt3 == 0) << 2 + in_C * c_cnt;
        ifmap_addr4 <= ifmap_addr4 + n_cnt4 * 3 + (enable4 && n_cnt4 == 0) << 2 + in_C * c_cnt;
        ifmap_addr5 <= ifmap_addr5 + n_cnt5 * 3 + (enable5 && n_cnt5 == 0) << 2 + in_C * c_cnt;
        ifmap_addr6 <= ifmap_addr6 + n_cnt6 * 3 + (enable6 && n_cnt6 == 0) << 2 + in_C * c_cnt;
        ifmap_addr7 <= ifmap_addr7 + n_cnt7 * 3 + (enable7 && n_cnt7 == 0) << 2 + in_C * c_cnt;
        ifmap_addr8 <= ifmap_addr8 + n_cnt8 * 3 + (enable8 && n_cnt8 == 0) << 2 + in_C * c_cnt;
        ifmap_addr9 <= ifmap_addr9 + n_cnt9 * 3 + (enable9 && n_cnt9 == 0) << 2 + in_C * c_cnt;
    end
end

logic [8:0] c_cnt;
//depthwise 
always_ff @ (posedge clk) begin
    if (rst) begin
        c_cnt <= 9'd0;
    end 
    else if (pass_layer_type == `DEPTHWISE) begin
        if (current_state == S_WRITE_IFMAP && pe_ifamp_valid && pe_ifmap_ready) begin
            if (c_cnt == ) begin
                c_cnt <= 9'd0; // 重置 c_cnt
            end 
            else if () begin
                c_cnt <= c_cnt + 1; // 每次搬入 4-Channel Pack (32-bit)
            end
        end 
    end
end



always_ff@(posedge clk) begin
    if(rst) begin
        ifmap_addr <= 0;
    end 
    else if (pass_layer_type == `POINTWISE) begin
        if(current_state == IDLE) begin
            ifmap_addr <= BASE_IFMAP;
        end 
        else if(current_state == S_WRITE_IFMAP && pe_ifamp_valid && pe_ifmap_ready) begin
            ifmap_addr <= ifmap_addr + (n_cnt << 2) + channel_base; // n_cnt 為 4-Channel Pack 的數量        
        end
    end
    else if (pass_layer_type == `DEPTHWISE) begin
        case(cnt_ifmap) 
            6'd0, 6'd1, 6'd2:  ifmap_addr <= ifmap_addr0;
            6'd3, 6'd4, 6'd5:  ifmap_addr <= ifmap_addr1;
            6'd6, 6'd7, 6'd8:  ifmap_addr <= ifmap_addr2;
            6'd9, 6'd10, 6'd11: ifmap_addr <= ifmap_addr3;
            6'd12, 6'd13, 6'd14: ifmap_addr <= ifmap_addr4;
            6'd15, 6'd16, 6'd17: ifmap_addr <= ifmap_addr5;
            6'd18, 6'd19, 6'd20: ifmap_addr <= ifmap_addr6;
            6'd21, 6'd22, 6'd23: ifmap_addr <= ifmap_addr7;
            6'd24, 6'd25, 6'd26: ifmap_addr <= ifmap_addr8;
            6'd27, 6'd28, 6'd29: ifmap_addr <= ifmap_addr9;
            default: ifmap_addr <= 0; // 預設情況

        endcase


    end
end

//---------------------------------------------------
// bias_addr
always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr <= 0;
    end
    else if (pass_layer_type == `POINTWISE) begin
        if(current_state == IDLE) begin
            bias_addr <= BASE_BIAS;
        end 
        else if(current_state == S_WRITE_BIAS && pe_bias_valid && pe_bias_ready) begin // FIXME: 檢查hsk次數
            //FIXME:
            bias_addr <= bias_addr + (n_cnt << 1 + channel_base) << 1; // n_cnt 為 4-Channel Pack 的數量
        end
    end
    else if (pass_layer_type == `DEPTHWISE) begin
        if(current_state == IDLE) begin
            bias_addr <= BASE_BIAS;
        end 
        else if(current_state == S_WRITE_BIAS && pe_bias_valid && pe_bias_ready) begin
            if(stride == 2'd1) begin
                if (pe_bias_valid && pe_bias_ready && n_cnt9 == 1) begin
                    bias_addr <= bias_addr + 1 + channel_base; // 每次搬入 4-Channel Pack (32-bit)
                end
                else if(cnt_bias[0] && pe_bias_valid && pe_bias_ready)
                    bias_addr <= bias_addr + 3 + channel_base;
                else 
                    bias_addr <= bias_addr
            end 
            else if(stride == 2'd2) begin
    
            end
        end
    end
end

//---------------------------------------------------
// ofmap_addr
//---------------------------------------------------

always_comb begin
    if (pass_layer_type == `POINTWISE) begin
        channel_base = pass_tile_n * d_cnt;
    end
    else if (pass_layer_type == `DEPTHWISE) begin
        channel_base = tile_R * in_C * d_cnt; // 每個 Channel Pack 的偏移量
    end
end

// cnt_modify  //FIXME: 只有 POINTWISE 才有用到
always_ff@(posedge clk) begin
    if(rst) begin
        cnt_modify <= 0; 
    end
    else if(current_state == IDLE) begin
        cnt_modify <= 0; // 重置計數器
    end
    else if (cnt_modify == 4'd8) begin
        cnt_modify <= 4'd8;
    end
    else if(current_state == S_WRITE_OPSUM && (opsum_hsk_cnt == ((cnt_modify + 1) << 3)<<1)) begin
        cnt_modify <= cnt_modify + 1; // 每次寫回 OPSUM 都增加計數
    end 
end

// opsum_hsk_cnt  //FIXME: 只有 POINTWISE 才有用到
always_ff@(posedge clk) begin
    if(rst) begin
        opsum_hsk_cnt <= 0; // 用於計數 Handshake 次數
    end 
    else if(current_state == S_READ_IFMAP) begin
        opsum_hsk_cnt <= 0; // 重置計數器
    end
    else if(current_state == S_WRITE_OPSUM && glb_write_valid && glb_write_ready) begin
        opsum_hsk_cnt <= opsum_hsk_cnt + 1; // 每次寫回 OPSUM 都增加計數
    end 
end

always_comb begin
    if (pass_layer_type == `POINTWISE) begin
        opsum_num =  k_cnt * pass_tile_n;
    end
    // else if (pass_layer_type == `DEPTHWISE) begin

    // end
end

// FIXME: 只有POINTWISE有   不改
//---------------------------------------------------
// opsum_addr 0~3
//---------------------------------------------------
always_ff @ (posedge clk) begin
    if (rst) begin
        opsum_addr0 <= ADDR_WIDTH'd0;
        opsum_addr1 <= ADDR_WIDTH'd0;
        opsum_addr2 <= ADDR_WIDTH'd0;
        opsum_addr3 <= ADDR_WIDTH'd0;
    end
    else if (current_state == IDLE) begin
        opsum_addr0 <= BASE_OPSUM;
        opsum_addr1 <= BASE_OPSUM;
        opsum_addr2 <= BASE_OPSUM;
        opsum_addr3 <= BASE_OPSUM;
    end
    //FIXME: ERROR CHECK
    else if (current_state == S_WAIT_OPSUM && pe_psum_valid && pe_psum_ready) begin
        if (cnt_modify == 4'd0)  begin // 已經修改完
            opsum_addr0 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr1 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr2 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr3 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
        end
        else begin 
            opsum_addr0 <= opsum_addr0 + ((n_cnt << 2) + opsum_num    ) << 1;
            opsum_addr1 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 1) << 1;
            opsum_addr2 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 2) << 1;
            opsum_addr3 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 3) << 1;
        end 
    end
end
//---------------------------------------------------
// opsum_addr 4~7
//---------------------------------------------------
always_ff @ (posedge clk) begin
    if (rst) begin
        opsum_addr4 <= ADDR_WIDTH'd0;
        opsum_addr5 <= ADDR_WIDTH'd0;
        opsum_addr6 <= ADDR_WIDTH'd0;
        opsum_addr7 <= ADDR_WIDTH'd0;
    end
    else if (current_state == IDLE) begin
        opsum_addr4 <= BASE_OPSUM;
        opsum_addr5 <= BASE_OPSUM;
        opsum_addr6 <= BASE_OPSUM;
        opsum_addr7 <= BASE_OPSUM;
    end
    //FIXME: ERROR CHECK
    else if (current_state == S_WAIT_OPSUM && pe_psum_valid && pe_psum_ready) begin
        if (cnt_modify == 4'd1)  begin // 已經修改完
            opsum_addr4 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr5 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr6 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr7 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
        end
        else begin 
            opsum_addr4 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 4) << 1;
            opsum_addr5 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 5) << 1;
            opsum_addr6 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 6) << 1;
            opsum_addr7 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 7) << 1;
        end 
    end
end

//---------------------------------------------------
// opsum_addr 8-11
//---------------------------------------------------
always_ff @ (posedge clk) begin
    if (rst) begin
        opsum_addr8  <= ADDR_WIDTH'd0;
        opsum_addr9  <= ADDR_WIDTH'd0;
        opsum_addr10 <= ADDR_WIDTH'd0;
        opsum_addr11 <= ADDR_WIDTH'd0;
    end
    else if (current_state == IDLE) begin
        opsum_addr8  <= BASE_OPSUM;
        opsum_addr9  <= BASE_OPSUM;
        opsum_addr10 <= BASE_OPSUM;
        opsum_addr11 <= BASE_OPSUM;
    end
    //FIXME: ERROR CHECK
    else if (current_state == S_WAIT_OPSUM && pe_psum_valid && pe_psum_ready) begin
        if (cnt_modify == 4'd2)  begin // 已經修改完
            opsum_addr8  <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr9  <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr10 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr11 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
        end
        else begin 
            opsum_addr8  <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 8 ) << 1;
            opsum_addr9  <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 9 ) << 1;
            opsum_addr10 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 10) << 1;
            opsum_addr11 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 11) << 1;
        end 
    end
end

//---------------------------------------------------
// opsum_addr 12-15
//---------------------------------------------------
always_ff @ (posedge clk) begin
    if (rst) begin
        opsum_addr12 <= ADDR_WIDTH'd0;
        opsum_addr13 <= ADDR_WIDTH'd0;
        opsum_addr14 <= ADDR_WIDTH'd0;
        opsum_addr15 <= ADDR_WIDTH'd0;
    end
    else if (current_state == IDLE) begin
        opsum_addr12 <= BASE_OPSUM;
        opsum_addr13 <= BASE_OPSUM;
        opsum_addr14 <= BASE_OPSUM;
        opsum_addr15 <= BASE_OPSUM;
    end
    //FIXME: ERROR CHECK
    else if (current_state == S_WAIT_OPSUM && pe_psum_valid && pe_psum_ready) begin
        if (cnt_modify == 4'd3)  begin // 已經修改完
            opsum_addr12 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr13 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr14 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr15 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
        end
        else begin 
            opsum_addr12 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 12) << 1;
            opsum_addr13 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 13) << 1;
            opsum_addr14 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 14) << 1;
            opsum_addr15 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 15) << 1;
        end 
    end
end

//---------------------------------------------------
// opsum_addr 16-19
//---------------------------------------------------
always_ff @ (posedge clk) begin
    if (rst) begin
        opsum_addr16 <= ADDR_WIDTH'd0;
        opsum_addr17 <= ADDR_WIDTH'd0;
        opsum_addr18 <= ADDR_WIDTH'd0;
        opsum_addr19 <= ADDR_WIDTH'd0;
    end
    else if (current_state == IDLE) begin
        opsum_addr16 <= BASE_OPSUM;
        opsum_addr17 <= BASE_OPSUM;
        opsum_addr18 <= BASE_OPSUM;
        opsum_addr19 <= BASE_OPSUM;
    end
    //FIXME: ERROR CHECK
    else if (current_state == S_WAIT_OPSUM && pe_psum_valid && pe_psum_ready) begin
        if (cnt_modify == 4'd4)  begin // 已經修改完
            opsum_addr16 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr17 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr18 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr19 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
        end
        else begin 
            opsum_addr16 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 16) << 1;
            opsum_addr17 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 17) << 1;
            opsum_addr18 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 18) << 1;
            opsum_addr19 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 19) << 1;
        end 
    end
end

//---------------------------------------------------
// opsum_addr 20-23
//---------------------------------------------------
always_ff @ (posedge clk) begin
    if (rst) begin
        opsum_addr20 <= ADDR_WIDTH'd0;
        opsum_addr21 <= ADDR_WIDTH'd0;
        opsum_addr22 <= ADDR_WIDTH'd0;
        opsum_addr23 <= ADDR_WIDTH'd0;
    end
    else if (current_state == IDLE) begin
        opsum_addr20 <= BASE_OPSUM;
        opsum_addr21 <= BASE_OPSUM;
        opsum_addr22 <= BASE_OPSUM;
        opsum_addr23 <= BASE_OPSUM;
    end
    //FIXME: ERROR CHECK
    else if (current_state == S_WAIT_OPSUM && pe_psum_valid && pe_psum_ready) begin
        if (cnt_modify == 4'd5)  begin // 已經修改完
            opsum_addr20 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr21 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr22 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr23 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
        end
        else begin 
            opsum_addr20 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 20) << 1;
            opsum_addr21 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 21) << 1;
            opsum_addr22 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 22) << 1;
            opsum_addr23 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 23) << 1;
        end 
    end
end

//---------------------------------------------------
// opsum_addr 24-27
//---------------------------------------------------
always_ff @ (posedge clk) begin
    if (rst) begin
        opsum_addr24 <= ADDR_WIDTH'd0;
        opsum_addr25 <= ADDR_WIDTH'd0;
        opsum_addr26 <= ADDR_WIDTH'd0;
        opsum_addr27 <= ADDR_WIDTH'd0;
    end
    else if (current_state == IDLE) begin
        opsum_addr24 <= BASE_OPSUM;
        opsum_addr25 <= BASE_OPSUM;
        opsum_addr26 <= BASE_OPSUM;
        opsum_addr27 <= BASE_OPSUM;
    end
    //FIXME: ERROR CHECK
    else if (current_state == S_WAIT_OPSUM && pe_psum_valid && pe_psum_ready) begin
        if (cnt_modify == 4'd6)  begin // 已經修改完
            opsum_addr24 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr25 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr26 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr27 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
        end
        else begin 
            opsum_addr24 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 24) << 1;
            opsum_addr25 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 25) << 1;
            opsum_addr26 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 26) << 1;
            opsum_addr27 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 27) << 1;
        end 
    end
end

//---------------------------------------------------
// opsum_addr 28-31
//---------------------------------------------------
always_ff @ (posedge clk) begin
    if (rst) begin
        opsum_addr28 <= ADDR_WIDTH'd0;
        opsum_addr29 <= ADDR_WIDTH'd0;
        opsum_addr30 <= ADDR_WIDTH'd0;
        opsum_addr31 <= ADDR_WIDTH'd0;
    end
    else if (current_state == IDLE) begin
        opsum_addr28 <= BASE_OPSUM;
        opsum_addr29 <= BASE_OPSUM;
        opsum_addr30 <= BASE_OPSUM;
        opsum_addr31 <= BASE_OPSUM;
    end
    //FIXME: ERROR CHECK
    else if (current_state == S_WAIT_OPSUM && pe_psum_valid && pe_psum_ready) begin
        if (cnt_modify == 4'd7)  begin // 已經修改完
            opsum_addr28 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr29 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr30 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
            opsum_addr31 <= opsum_addr0 + ((n_cnt << 2) + opsum_num) << 1;
        end
        else begin 
            opsum_addr28 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 28) << 1;
            opsum_addr29 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 29) << 1;
            opsum_addr30 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 30) << 1;
            opsum_addr31 <= opsum_addr0 + ((n_cnt << 2) + opsum_num - 31) << 1;
        end 
    end
end

//---------------------------------------------------
// FIXME: 
//---------------------------------------------------
// opsum_addr
always_comb begin 
    if (pass_layer_type == `POINTWISE) begin  
        case(k_cnt)
            6'd0: opsum_addr = opsum_addr0;
            6'd1: opsum_addr = opsum_addr1;
            6'd2: opsum_addr = opsum_addr2;
            6'd3: opsum_addr = opsum_addr3;
            6'd4: opsum_addr = opsum_addr4;
            6'd5: opsum_addr = opsum_addr5;
            6'd6: opsum_addr = opsum_addr6;
            6'd7: opsum_addr = opsum_addr7;
            6'd8: opsum_addr = opsum_addr8;
            6'd9: opsum_addr = opsum_addr9;
            6'd10: opsum_addr = opsum_addr10;
            6'd11: opsum_addr = opsum_addr11;
            6'd12: opsum_addr = opsum_addr12;
            6'd13: opsum_addr = opsum_addr13;
            6'd14: opsum_addr = opsum_addr14;
            6'd15: opsum_addr = opsum_addr15;
            6'd16: opsum_addr = opsum_addr16;
            6'd17: opsum_addr = opsum_addr17;
            6'd18: opsum_addr = opsum_addr18;
            6'd19: opsum_addr = opsum_addr19;
            6'd20: opsum_addr = opsum_addr20;
            6'd21: opsum_addr = opsum_addr21;
            6'd22: opsum_addr = opsum_addr22;
            6'd23: opsum_addr = opsum_addr23;
            6'd24: opsum_addr = opsum_addr24;
            6'd25: opsum_addr = opsum_addr25;
            6'd26: opsum_addr = opsum_addr26;
            6'd27: opsum_addr = opsum_addr27;
            6'd28: opsum_addr = opsum_addr28;
            6'd29: opsum_addr = opsum_addr29;
            6'd30: opsum_addr = opsum_addr30;
            6'd31: opsum_addr = opsum_addr31;
            default :opsum_address = 6'd0; // 預設為最後一個地址
        endcase
    end
    else if (pass_layer_type == `DEPTHWISE) begin
        if(stride == 2'd1) begin
            if (pe_psum_valid && pe_psum_ready && n_cnt9 == 1) begin
                opsum_addr <= opsum_addr + 1 + channel_base; // 每次搬入 4-Channel Pack (32-bit)
            end
            else if(cnt_bias[0] && pe_psum_valid && pe_psum_ready)
                opsum_addr <= opsum_addr + 3 + channel_base;
            else 
                opsum_addr <= opsum_addr;
        end 
        else if(stride == 2'd2) begin

        end
    end
end
//---------------------------------------------------
// FIXME: 
//---------------------------------------------------
always_comb begin
    case(current_state)
        S_READ_WEIGHT, S_WRITE_WEIGHT: begin
            glb_read_addr = weight_addr; 
        end
        S_READ_IFMAP, S_WRITE_IFMAP: begin
            glb_read_addr = ifmap_addr; 
        end
        S_READ_BIAS, S_WRITE_BIAS: begin
            glb_read_addr = bias_addr; 
        end
        default:begin
            glb_read_addr = '0; // 預設為 0
        end
    endcase
end

always_comb begin
    if(current_state == S_WRITE_OPSUM || current_state == S_WAIT_OPSUM) begin
        glb_write_addr = opsum_addr; 
    end
    else begin
        glb_write_addr = '0; // 預設為 0
    end
end

//total_opsum_num_cnt
always_ff @(posedge clk) begin
    if (rst) begin
        total_opsum_num_cnt <= 0; // 用於計算總的 OPSUM 數量
    end 
    else if (current_state == S_PASS_DONE) begin
        total_opsum_num_cnt <= 0;
    end
    else if (pass_layer_type == `POINTWISE) begin
        if (current_state == S_WRITE_OPSUM && glb_write_valid && glb_write_ready) begin
            total_opsum_num_cnt <= total_opsum_num_cnt + 2; // 每次寫回 OPSUM 都增加計數
        end 
    end

    //FIXME:
    else if (pass_layer_type == `DEPTHWISE) begin
        if (stride == 2'd1) begin
            if ((n_cnt9 == 1) && current_state == S_WRITE_OPSUM && glb_write_valid && glb_write_ready) begin
                total_opsum_num_cnt <= total_opsum_num_cnt + 1; // 每次寫回 OPSUM 都增加計數
            end
            else if (cnt_bias[0] && current_state == S_WRITE_OPSUM && glb_write_valid && glb_write_ready) begin
                total_opsum_num_cnt <= total_opsum_num_cnt + 3; // 每次寫回 OPSUM 都增加計數
            end
        end
        else if (stride == 2'd2) begin

        end
        else begin
            total_opsum_num_cnt <= 0; // 預設為 0
        end
    end
end

//---------------------------------------------------
// FIXME: 
//---------------------------------------------------
always_comb begin
    pass_done = (current_state == S_PASS_DONE) ? 1'b1 : 1'b0; // 當前狀態為 S_PASS_DONE 時，送出 PASS_DONE 信號
end

endmodule
