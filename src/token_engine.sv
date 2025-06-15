//==============================================================================
// Token Engine – 更新版 (SystemVerilog)
// 
//  date: 2025/06/10
//  version: 未完成padding 
// 
//==============================================================================
`include "../include/define.svh"
module token_engine (
    //==============================================================================
    // 1) Clock / Reset
    //==============================================================================
    input                   clk,               
    input                   rst,           

    //==============================================================================
    // 2) Pass 觸發與參數 (由 Tile Scheduler / Layer Decoder 提供)
    //==============================================================================
    input                        PASS_START,          // 1clk Pulse：收到後可開始向 GLB 抓值
    input   [1:0]                pass_layer_type,     // 
    input   [`BYTE_CNT_WIDTH-1:0] pass_tile_n,         // 一次 DRAM→GLB 要搬入的 Ifmap bytes 總數
    input   [`FLAG_WIDTH-1:0]     pass_flags,          // Flags 控制：bit[0]=bias_en, bit[1]=relu_en, bit[2]=skip_en, … 

    input   [`ADDR_WIDTH-1:0] BASE_IFMAP,         // GLB 中「此層 Ifmap 資料」的起始位址
    input   [`ADDR_WIDTH-1:0] BASE_WEIGHT,        // GLB 中「此層 Weight 資料」的起始位址
    input   [`ADDR_WIDTH-1:0] BASE_OPSUM,         // GLB 中「此層 PSUM (Partial/Final) 資料」的起始位址
    input   [`ADDR_WIDTH-1:0] BASE_BIAS,          // GLB 中「此層 Bias 資料」的起始位址

    input   [6:0]           out_C,              // 輸出圖片 column 數量 (width)
    input   [6:0]           out_R,              // 輸出圖片 row    數量 (height)

    //==============================================================================
    // 3) GLB 讀取接口 (Ifmap / Weight / Bias)
    //    – Token Engine 驅動 glb_read_addr & glb_read_ready
    //    – 接收 glb_read_valid & glb_read_data
    //==============================================================================
    output logic [`ADDR_WIDTH-1:0] glb_read_addr,      // 要讀取的 GLB 位址 (Ifmap / Weight / Bias)
    output logic                  glb_read_ready,     // 1clk 脈衝：開始一次 GLB Read 交易
    input                    glb_read_valid,     // GLB 回應：「此筆 glb_read_data 有效」
    input   [`DATA_WIDTH-1:0] glb_read_data,      // GLB 回傳的資料 (4×8bit Ifmap/Weight Pack，或 1×Bias)

    //==============================================================================
    // 4) GLB 寫回接口 (PSUM 回寫)
    //    – Token Engine 驅動 glb_write_addr, glb_write_data & glb_write_ready
    //    – 接收 glb_write_valid
    //==============================================================================
    output logic [`ADDR_WIDTH-1:0] glb_write_addr,     // 要寫回 GLB 的位址 (PSUM Partial / Final)
    output logic [`DATA_WIDTH-1:0] glb_write_data,     // 要寫回 GLB 的 PSUM 資料 (32‐lane Pack 或 4‐channel Pack)
    input                     glb_write_ready,    // 1clk 脈衝：開始一次 GLB Write 交易
    output logic              glb_write_valid,    // GLB 回應：「此筆 glb_write_data 已寫回完成」
    output logic WEB, 
    output logic [31:0] BWEB,
    //==============================================================================
    // 5) PE Array 接口 (Token → PE)
    //    – Token Engine 送 token_data & token_valid
    //    – 監看 pe_busy
    //==============================================================================
    output logic [`DATA_WIDTH-1:0] token_data,         // 送給 PE Array 的 Ifmap/Weight/Bias Pack
    // output logic                  token_valid,        // 1clk 脈衝：token_data + token_tag 現在有效
    // input  logic                  pe_busy,            // PE Array 拉高表示「目前忙碌中，尚在 Compute」//FIXME: 感覺不用

    //==============================================================================
    // 6) Padding 控制 (Depthwise 或 空間 Padding)
    //==============================================================================
    // output logic [1:0]                 control_padding,    // 0: up padding, 1: left paadding, 2: right padding, 3: down padding

    //==============================================================================
    // 7) PSUM Buffer → Token Engine (Pop)
    //    – PSUM Buffer pop 出累計結果後拉 pe_psum_valid
    //    – Token Engine 回 pe_psum_ready 表示可 pop 下一筆
    //==============================================================================
    input   [`DATA_WIDTH-1:0] pe_psum_data,       // PSUM Buffer pop 出的累加結果
    input                    pe_psum_valid,      // PSUM Buffer 回：pe_psum_data 有效
    output logic                  pe_psum_ready,      // Token Engine 拉高後，PSUM Buffer 才 pop 出下一筆
    input pe_weight_ready,
    output logic pe_weight_valid,
    input pe_ifmap_ready,
    output logic pe_ifamp_valid,
    input pe_bias_ready,
    output logic pe_bias_valid,
    // output logic pe_psum_ready,
    // input pe_psum_valid
    input logic [6:0] tile_K_o,
    input logic [5:0] tile_D, // 記得接真實的

    output logic [5:0] col_en, // 給pe確定有幾行要算
    output logic [5:0] row_en, // 給pe確定有幾個WEIGHT要算
    //==============================================================================
    //==============================================================================
    // Depthwise 
    //==============================================================================

    output logic [1:0] compute_num,
    output logic change_row,//換row訊號
    input logic [7:0] in_C, //輸入特徵圖 Width column
    input logic [7:0] in_R, //輸入特徵圖 Height row
    input [1:0] stride,

    output logic [1:0] compute_num0,
    output logic [1:0] compute_num1,
    output logic [1:0] compute_num2,
    output logic [1:0] compute_num3,
    output logic [1:0] compute_num4,
    output logic [1:0] compute_num5,
    output logic [1:0] compute_num6,
    output logic [1:0] compute_num7,
    output logic [1:0] compute_num8,
    output logic [1:0] compute_num9,

    //==============================================================================
    // 8) Pass 完成回報 (送給 Tile Scheduler)
    //==============================================================================
    output logic                 pass_done           // 1clk 脈衝：本次 Pass (Tile) Ifmap→MAC→PSUM 回寫全流程完成
);

    //==========================================================================
    // 參數設定
    //==========================================================================


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

    logic [`DATA_WIDTH-1:0] data_2_pe_reg;

    // Counters 數送了幾個
    logic [5:0]            cnt_bias;          // 已推 Bias 的筆數
    logic [5:0]            cnt_ifmap;         // 已推 Ifmap
    logic [8:0]            cnt_weight;        // 已推 Weight
    logic [5:0]            cnt_psum;          // 已 pop OPSUM 寫回的筆數

    logic [`ADDR_WIDTH-1:0] weight_addr;       // Weight 的位址計數器
    logic [`ADDR_WIDTH-1:0] ifmap_addr;        // Ifmap 的位址計數器
    logic [`ADDR_WIDTH-1:0] bias_addr;         // Bias 的位址計數器
    logic [`ADDR_WIDTH-1:0] opsum_addr;        // OPSUM 的位址計數器
    

    //===== 會拿通道數去 計算opsum_row_num
    logic [4:0] opsum_row_num; // OPSUM 有寫回的 row 數量

    //---------------------------------------------------
    // ofmap_addr
    //---------------------------------------------------
    logic [3:0] cnt_modify;
    logic [8:0] opsum_hsk_cnt;
    logic [8:0] ifmap_hsk_cnt; // for depthwise enable open
    logic [5:0] d_cnt;
    logic [7:0] n_cnt;
    logic [5:0] k_cnt;
    logic [7:0] col_en_cnt;
    logic [31:0] channel_base;

    //---------------------------------------------------
    // opsum_addr 0~31
    //---------------------------------------------------

    logic [`ADDR_WIDTH-1:0] opsum_addr0;
    logic [`ADDR_WIDTH-1:0] opsum_addr1;
    logic [`ADDR_WIDTH-1:0] opsum_addr2;
    logic [`ADDR_WIDTH-1:0] opsum_addr3;
    logic [`ADDR_WIDTH-1:0] opsum_addr4;
    logic [`ADDR_WIDTH-1:0] opsum_addr5;
    logic [`ADDR_WIDTH-1:0] opsum_addr6;
    logic [`ADDR_WIDTH-1:0] opsum_addr7;
    logic [`ADDR_WIDTH-1:0] opsum_addr8;
    logic [`ADDR_WIDTH-1:0] opsum_addr9;
    logic [`ADDR_WIDTH-1:0] opsum_addr10;
    logic [`ADDR_WIDTH-1:0] opsum_addr11;
    logic [`ADDR_WIDTH-1:0] opsum_addr12;
    logic [`ADDR_WIDTH-1:0] opsum_addr13;
    logic [`ADDR_WIDTH-1:0] opsum_addr14;
    logic [`ADDR_WIDTH-1:0] opsum_addr15;
    logic [`ADDR_WIDTH-1:0] opsum_addr16;
    logic [`ADDR_WIDTH-1:0] opsum_addr17;
    logic [`ADDR_WIDTH-1:0] opsum_addr18;
    logic [`ADDR_WIDTH-1:0] opsum_addr19;
    logic [`ADDR_WIDTH-1:0] opsum_addr20;
    logic [`ADDR_WIDTH-1:0] opsum_addr21;
    logic [`ADDR_WIDTH-1:0] opsum_addr22;
    logic [`ADDR_WIDTH-1:0] opsum_addr23;
    logic [`ADDR_WIDTH-1:0] opsum_addr24;
    logic [`ADDR_WIDTH-1:0] opsum_addr25;
    logic [`ADDR_WIDTH-1:0] opsum_addr26;
    logic [`ADDR_WIDTH-1:0] opsum_addr27;
    logic [`ADDR_WIDTH-1:0] opsum_addr28;
    logic [`ADDR_WIDTH-1:0] opsum_addr29;
    logic [`ADDR_WIDTH-1:0] opsum_addr30;
    logic [`ADDR_WIDTH-1:0] opsum_addr31;
    logic [31:0] opsum_num;
    logic [31:0] pe_opsum_cnt;

    logic [8:0] c_cnt;
    logic change_row0, change_row1, change_row2, change_row3, change_row4, change_row5, change_row6, change_row7, change_row8, change_row9;
    logic [9:0] d2_opsum_num; // depthwise stride 2 opsum number 
    logic [3:0] control_padding;
    logic [31:0] cnt_modify_cnt;

    logic [31:0] in_c_tile_R;
    logic [`BYTE_CNT_WIDTH-1:0] tile_R; //dEPTHWISE 沒PADDING的ROW數
    

    logic [31:0] BASE_IFMAP1;
    logic [31:0] BASE_IFMAP2;
    logic [31:0] BASE_IFMAP3;
    logic [31:0] BASE_IFMAP4;
    logic [31:0] BASE_IFMAP5;
    logic [31:0] BASE_IFMAP6;
    logic [31:0] BASE_IFMAP7;
    logic [31:0] BASE_IFMAP8;
    logic [31:0] BASE_IFMAP9;

    logic [31:0] Bias_reg1;
    logic [31:0] Bias_reg2;



    assign in_c_tile_R = in_C * tile_R;
    assign BASE_IFMAP1 = BASE_IFMAP + in_c_tile_R;
    assign BASE_IFMAP2 = BASE_IFMAP + in_c_tile_R * 2;
    assign BASE_IFMAP3 = BASE_IFMAP + in_c_tile_R * 3;
    assign BASE_IFMAP4 = BASE_IFMAP + in_c_tile_R * 4;
    assign BASE_IFMAP5 = BASE_IFMAP + in_c_tile_R * 5;
    assign BASE_IFMAP6 = BASE_IFMAP + in_c_tile_R * 6;
    assign BASE_IFMAP7 = BASE_IFMAP + in_c_tile_R * 7;
    assign BASE_IFMAP8 = BASE_IFMAP + in_c_tile_R * 8;
    assign BASE_IFMAP9 = BASE_IFMAP + in_c_tile_R * 9;

    //==========================================================================
    //CNT : 數總共送了幾筆，方便轉換狀態
    //==========================================================================
    always_ff @ (posedge clk) begin
        if(rst) begin
            cnt_weight <= 0;
        end

        else if (current_state == S_WRITE_WEIGHT && pe_weight_valid && pe_weight_ready) begin
            if (cnt_weight == ((tile_K_o << 3)-1)) begin // 假設每次搬入 32 個 Weight Pack
                cnt_weight <= 0; // 重置計數器
            end 
            else 
                cnt_weight <= cnt_weight + 1; // 每次搬入 4-Channel Pack (32-bit)
            
        end
    end

    // ifmap
    always_ff @ (posedge clk) begin
        if(rst) begin
            cnt_ifmap <= 0;
        end
        else if (current_state == S_WRITE_IFMAP && pe_ifamp_valid && pe_ifmap_ready) begin
            if (cnt_ifmap == col_en-1) begin // 假設每次搬入 32 個 Ifmap Pack
                cnt_ifmap <= 0; // 重置計數器
            end 
            else
                cnt_ifmap <= cnt_ifmap + 1; // 每次搬入 4-Channel Pack (32-bit)
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
                if (cnt_bias == ((cnt_modify + 32'd1) << 3) - 1) begin // 假設每次搬入 32 個 Bias Pack //((cnt_modify + 32'd1) << 2) - 1) 改<<3 因為16byte要送 16 筆bias要8次
                    cnt_bias <= 0; // 重置計數器
                end
                else  
                    cnt_bias <= cnt_bias + 1; // 每次搬入 4-Channel Pack (32-bit)
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
                if ((cnt_psum == 2*tile_K_o-1) || (cnt_psum == ((cnt_modify + 32'd1) << 3) - 1)) begin 
                    cnt_psum <= 0; // 重置計數器
                end 
                else 
                    cnt_psum <= cnt_psum + 1; // 每次搬入 4-Channel Pack (32-bit)
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
                    if (cnt_psum == d2_opsum_num*2-1) begin // FIXME: 還沒想好
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

    logic        start;       // 啟動訊號（例如每送出一筆就拉高一拍）
    logic [9:0] opsum_addr;   // 假設是 10-bit 位址



    logic [3:0] count;              // 控制遞增模式（最多可支援超過 8 次跳躍）
    logic [1:0] phase;              // 控制 1、2 的輪替
    logic       first;              // 第一次 +1 特殊處理

    always_ff @(posedge clk) begin
        if (rst) begin
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
        else begin
            col_en = 6'd0; // 預設值，若非 Pointwise 或 Depthwise，則不計算
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
                    if ((cnt_weight == (tile_K_o << 3)-1) && pe_weight_ready && pe_weight_valid) begin // FIXME: check 32?
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
                    if (cnt_ifmap == tile_D-1 && pe_ifamp_valid && pe_ifmap_ready) begin  //後面不一定是 32 可以改成一個parameter (ifmap 不夠大或是 channel 不夠多)
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
                    if (cnt_modify == 32'd8) begin
                        if ((cnt_bias == ((cnt_modify) << 3) - 1) && pe_bias_valid && pe_bias_ready) begin
                            next_state = S_WAIT_OPSUM;
                        end
                        else if (pe_bias_valid && pe_bias_ready) begin
                            next_state = S_READ_BIAS;
                        end 
                        else begin
                            next_state = S_WRITE_BIAS;
                        end
                    end
                    else if ((cnt_bias == ((cnt_modify + 32'd1) << 3) - 1) && pe_bias_valid && pe_bias_ready) begin //後面不一定是 32 可以改成一個parameter (ifmap 不夠大或是 channel 不夠多)
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
                        else if (cnt_modify == 32'd8) begin
                            if (((cnt_psum == 2*tile_K_o-1)))
                                next_state = S_READ_IFMAP; // FIXME: 這裡的條件要根據實際情況調整
                            else
                                next_state = S_WAIT_OPSUM; // 繼續等待 OPSUM 
                        end
                        else if ((cnt_psum == 2*tile_K_o-1) || (cnt_psum == ((cnt_modify + 32'd1) << 3) - 1)) begin
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
                    if (cnt_weight == 6'd30 && pe_weight_ready && pe_weight_valid) begin // FIXME: check 32?
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
                    if(stride == 2'd1) begin
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
                    else begin // stride == 2'd2 //FIXME:可能改, cnt_bias看波修正
                        if ((cnt_bias == (tile_K_o-1)) && pe_bias_valid && pe_bias_ready) begin 
                            next_state = S_WAIT_OPSUM;
                        end 
                        else if (pe_bias_valid && pe_bias_ready) begin
                            next_state = S_READ_BIAS;
                        end 
                        else begin
                            next_state = S_WRITE_BIAS;
                        end
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
                        else if (cnt_psum == 1+3*n_cnt && stride == 2'd1) begin 
                            next_state = S_READ_IFMAP; 
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
        //FIXME: CONV
        // else if (pass_layer_type == `STANDARD) begin

        // end

        else begin //LINEAR
            next_state = S_IDLE;
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
        glb_write_data = 32'd0; // 清除資料
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


//FIXME:還沒 PADDING 
/* 0: up padding, 1: left paadding, 2: right padding, 3: down padding
   4: up left padding, 5: up right padding, 6: down left padding, 7: down right padding
   8: no padding
*/
always_comb begin
    if(current_state == S_WRITE_WEIGHT || current_state == S_WRITE_BIAS) begin
        token_data = data_2_pe_reg; // 將讀取到的資料送給 PE
    end
    else if(current_state == S_WRITE_IFMAP) begin
        case(control_padding)
            4'd0: begin
                token_data = 32'd0; // 上方 Padding
            end
            4'd1: begin
                token_data = {8'd0, data_2_pe_reg[15:0], 8'd0}; // 左側 Padding (假設是 4-Channel Pack)
            end
            4'd2: begin
                token_data = {16'd0, data_2_pe_reg[15:0]}; // 右側 Padding (假設是 4-Channel Pack)
            end
            4'd3: begin
                token_data = 32'd0; // 下方 Padding
            end
            4'd4: begin
                if (col_en_cnt%3 == 0) begin
                    token_data = 32'd0;
                end
                else begin
                    token_data = {8'd0, data_2_pe_reg[15:0], 8'd0}; // 上左 Padding (假設是 4-Channel Pack)
                end
            end
            4'd5: begin
                if (col_en_cnt%3 == 0) begin
                    token_data = 32'd0;
                end
                else begin
                    token_data = {16'd0, data_2_pe_reg[15:0]}; // 右側 Padding (假設是 4-Channel Pack)
                end
            end
            4'd6: begin
                if (col_en_cnt%3 == 2) begin
                    token_data = 32'd0;
                end
                else begin
                    token_data = {8'd0, data_2_pe_reg[15:0], 8'd0}; // 下左 Padding (假設是 4-Channel Pack)
                end
            end
            4'd7: begin
                if (col_en_cnt%3 == 2) begin
                    token_data = 32'd0;
                end
                else begin
                    token_data = {16'd0, data_2_pe_reg[15:0]}; // 下右 Padding (假設是 4-Channel Pack)
                end
            end
            4'd8: begin
                token_data = data_2_pe_reg;
            end

            default: begin
                token_data = data_2_pe_reg; // 預設情況下，將資料送給 PE
            end

        endcase
    end
    else begin
        token_data = 32'd0; // 清除資料
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
        glb_write_valid = 1'b1; // 準備寫回 OPSUM
    end
    else begin
        glb_write_valid = 1'b0;
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
        if(current_state == S_IDLE) begin
            weight_addr <= BASE_WEIGHT;
        end 
        else if(current_state == S_WRITE_WEIGHT && pe_weight_valid && pe_weight_ready) begin
            weight_addr <= weight_addr + 4;
        end
    end
    else if (pass_layer_type == `DEPTHWISE) begin
        if(current_state == S_IDLE) begin
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
        y_cnt <= 8'd0; // y_cnt 用於計算 Ifmap 的 Row 數量
    end 
    else if(stride == 2'd1) begin
        if(change_row) begin
            if(y_cnt == in_R - 1) begin
                y_cnt <= 8'd0;
            end 
            else begin
                y_cnt <= y_cnt + 8'd1;
            end
        end 
    end else if(stride == 2'd2) begin
        if(change_row) begin
            if(y_cnt == in_R - 1) begin // FIXME: 這邊的歸0要確認
                y_cnt <= 8'd0;
            end 
            else begin
                y_cnt <= y_cnt + 8'd2;
            end
        end 
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
       d_cnt <= 0; // d_cnt 用於計算 Ifmap 的 Channel Pack 數量
    end 
    else if (pass_layer_type == `POINTWISE) begin
        if((glb_read_ready && glb_read_valid) && d_cnt == tile_D-1) begin
            d_cnt <= 6'd0;
        end
        else if(current_state == S_READ_IFMAP&& (glb_read_ready && glb_read_valid)) begin
            d_cnt <=  d_cnt + 1; // 每次搬入 4-Channel Pack (32-bit)
        end
        else if (current_state == S_READ_BIAS && glb_read_ready && glb_read_valid && cnt_bias[0]) begin
            d_cnt <= d_cnt + 1; // 每次搬入 4-Channel Pack (32-bit)
        end
    end
    else if (pass_layer_type == `DEPTHWISE) begin   
        if(current_state == S_WRITE_IFMAP) begin
            if((glb_read_ready && glb_read_valid) && d_cnt == tile_D-1) begin
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
            if((glb_read_ready && glb_read_valid) && d_cnt == tile_D-1) begin
                d_cnt <= 6'd0;
            end
            else begin
                if(cnt_bias[0] && (pe_bias_valid && pe_bias_ready)) begin
                    d_cnt <= d_cnt + 6'd1;
                end
            end
        end
        else if (current_state == S_WRITE_OPSUM && glb_write_valid && glb_write_ready) begin
            if(d_cnt == tile_D-1) begin
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

        if (current_state == S_WRITE_OPSUM && glb_write_valid && glb_write_ready) begin
            //FIXME:
            if(d_cnt == tile_D-1 && cnt_psum[0])
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

// pe_opsum_cnt
always_ff@(posedge clk) begin
    if(rst) begin
        pe_opsum_cnt <= 32'd0;
    end
    else if(current_state == S_READ_IFMAP) begin
        pe_opsum_cnt <= 32'd0;
    end
    else if(current_state == S_WAIT_OPSUM && pe_psum_valid && pe_psum_ready) begin
        pe_opsum_cnt <= pe_opsum_cnt + 1; // 每次搬入 4-Channel Pack (32-bit)
    end
end



//k_cnt
always_ff@(posedge clk) begin
    if(rst) begin
        k_cnt <= 0; // k_cnt 用於計算 Weight 的 Channel Pack 數量
    end 
    else if (pass_layer_type == `POINTWISE) begin
        if (current_state == S_WRITE_OPSUM && glb_write_ready && glb_write_valid) begin
            if(k_cnt == (tile_K_o - 1) || (cnt_modify_cnt == (((cnt_modify + 1) << 3)-1))) begin
                k_cnt <= 0; // 重置 k_cnt
            end 
            else if (opsum_hsk_cnt[0]) begin
                k_cnt <= k_cnt + 1; // 每次搬入 4-Channel Pack (32-bit)
            end
        end
        // else if(pe_opsum_cnt[0] && pe_psum_valid && pe_psum_ready) begin
        //     k_cnt <= k_cnt + 1; 
        // end
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

logic [31:0] in_c_c_cnt;
assign in_c_c_cnt = in_C * c_cnt; // 用於計算 Ifmap 的 Channel Pack 數量
//---------- ifmap addr0~9 for depthwise ----------//
logic [`ADDR_WIDTH-1:0] ifmap_addr0, ifmap_addr1, ifmap_addr2, ifmap_addr3, ifmap_addr4, ifmap_addr5, ifmap_addr6, ifmap_addr7, ifmap_addr8, ifmap_addr9;
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
        ifmap_addr1 <= BASE_IFMAP1;
        ifmap_addr2 <= BASE_IFMAP2;
        ifmap_addr3 <= BASE_IFMAP3;
        ifmap_addr4 <= BASE_IFMAP4;
        ifmap_addr5 <= BASE_IFMAP5;
        ifmap_addr6 <= BASE_IFMAP6;
        ifmap_addr7 <= BASE_IFMAP7;
        ifmap_addr8 <= BASE_IFMAP8;
        ifmap_addr9 <= BASE_IFMAP9;
    end 
    else if(current_state == S_WRITE_IFMAP && pe_ifamp_valid && pe_ifmap_ready) begin
        ifmap_addr0 <=  BASE_IFMAP + n_cnt0 * 3 + ((enable0 && n_cnt0 == 0) << 2) + in_c_c_cnt; // n_cnt0 為 4-Channel Pack 的數量
        ifmap_addr1 <= BASE_IFMAP1 + n_cnt1 * 3 + ((enable1 && n_cnt1 == 0) << 2) + in_c_c_cnt;
        ifmap_addr2 <= BASE_IFMAP2 + n_cnt2 * 3 + ((enable2 && n_cnt2 == 0) << 2) + in_c_c_cnt;
        ifmap_addr3 <= BASE_IFMAP3 + n_cnt3 * 3 + ((enable3 && n_cnt3 == 0) << 2) + in_c_c_cnt;
        ifmap_addr4 <= BASE_IFMAP4 + n_cnt4 * 3 + ((enable4 && n_cnt4 == 0) << 2) + in_c_c_cnt;
        ifmap_addr5 <= BASE_IFMAP5 + n_cnt5 * 3 + ((enable5 && n_cnt5 == 0) << 2) + in_c_c_cnt;
        ifmap_addr6 <= BASE_IFMAP6 + n_cnt6 * 3 + ((enable6 && n_cnt6 == 0) << 2) + in_c_c_cnt;
        ifmap_addr7 <= BASE_IFMAP7 + n_cnt7 * 3 + ((enable7 && n_cnt7 == 0) << 2) + in_c_c_cnt;
        ifmap_addr8 <= BASE_IFMAP8 + n_cnt8 * 3 + ((enable8 && n_cnt8 == 0) << 2) + in_c_c_cnt;
        ifmap_addr9 <= BASE_IFMAP9 + n_cnt9 * 3 + ((enable9 && n_cnt9 == 0) << 2) + in_c_c_cnt;
    end
end
//----------------------------- enable -------------------------------// FIXME: 未完成
always_ff @ (posedge clk) begin
    if(rst) begin
        enable0 <= 1'b0;
    end
    else if (change_row0) begin
        enable0 <= 1'b0;
    end
    else begin
        enable0 <= 1'b1;
    end
end

always_ff @ (posedge clk) begin
    if(rst) begin
        enable1 <= 1'b0;
    end
    else if (change_row1) begin
        enable1 <= 1'b0;
    end
    else if (col_en_cnt == 9'd3) begin
        enable1 <= 1'b1;
    end
end

always_ff @ (posedge clk) begin
    if(rst) begin
        enable2 <= 1'b0;
    end
    else if (change_row2) begin
        enable2 <= 1'b0;
    end
    else if (col_en_cnt == 9'd6) begin
        enable2 <= 1'b1;
    end
end

always_ff @ (posedge clk) begin
    if(rst) begin
        enable3 <= 1'b0;
    end
    else if (change_row3) begin
        enable3 <= 1'b0;
    end
    else if (col_en_cnt == 9'd9) begin
        enable3 <= 1'b1;
    end
end

always_ff @ (posedge clk) begin
    if(rst) begin
        enable4 <= 1'b0;
    end
    else if (change_row4) begin
        enable4 <= 1'b0;
    end
    else if (col_en_cnt == 9'd12) begin
        enable4 <= 1'b1;
    end
end

always_ff @ (posedge clk) begin
    if(rst) begin
        enable5 <= 1'b0;
    end
    else if (change_row5) begin
        enable5 <= 1'b0;
    end
    else if (col_en_cnt == 9'd15) begin
        enable5 <= 1'b1;
    end
end

always_ff @ (posedge clk) begin
    if(rst) begin
        enable6 <= 1'b0;
    end
    else if (change_row6) begin
        enable6 <= 1'b0;
    end
    else if (col_en_cnt == 9'd18) begin
        enable6 <= 1'b1;
    end
end

always_ff @ (posedge clk) begin
    if(rst) begin
        enable7 <= 1'b0;
    end
    else if (change_row7) begin
        enable7 <= 1'b0;
    end
    else if (col_en_cnt == 9'd21) begin
        enable7 <= 1'b1;
    end
end

always_ff @ (posedge clk) begin
    if(rst) begin
        enable8 <= 1'b0;
    end
    else if (change_row8) begin
        enable8 <= 1'b0;
    end
    else if (col_en_cnt == 9'd24) begin
        enable8 <= 1'b1;
    end
end

always_ff @ (posedge clk) begin
    if(rst) begin
        enable9 <= 1'b0;
    end
    else if (change_row9) begin
        enable9 <= 1'b0;
    end
    else if (col_en_cnt == 9'd27) begin
        enable9 <= 1'b1;
    end
end

//---------------------------------------------------

//-------------------- compute number --------------------//
logic [9:0] cnt;
logic [9:0] saturate;




always_comb begin
    saturate = 2-1+3*n_cnt;
end

always_comb begin
    change_row0 = ((2-1+3*(n_cnt0+1)) >= in_C) ? 1'd1:1'd0;
    change_row1 = ((2-1+3*(n_cnt1+1)) >= in_C) ? 1'd1:1'd0;
    change_row2 = ((2-1+3*(n_cnt2+1)) >= in_C) ? 1'd1:1'd0;
    change_row3 = ((2-1+3*(n_cnt3+1)) >= in_C) ? 1'd1:1'd0;
    change_row4 = ((2-1+3*(n_cnt4+1)) >= in_C) ? 1'd1:1'd0;
    change_row5 = ((2-1+3*(n_cnt5+1)) >= in_C) ? 1'd1:1'd0;
    change_row6 = ((2-1+3*(n_cnt6+1)) >= in_C) ? 1'd1:1'd0;
    change_row7 = ((2-1+3*(n_cnt7+1)) >= in_C) ? 1'd1:1'd0;
    change_row8 = ((2-1+3*(n_cnt8+1)) >= in_C) ? 1'd1:1'd0;
    change_row9 = ((2-1+3*(n_cnt9+1)) >= in_C) ? 1'd1:1'd0;
end

always_comb begin
    change_row = change_row0 && 
                 change_row1 && 
                 change_row2 && 
                 change_row3 && 
                 change_row4 && 
                 change_row5 && 
                 change_row6 && 
                 change_row7 && 
                 change_row8 && 
                 change_row9;
end


always_comb begin
    if(change_row) begin// 控制ofmap
        compute_num = in_C - saturate;
    end else begin
        compute_num = 2'd3;
    end
end

always_comb begin
    if(change_row0) begin
        compute_num0 = in_C - (2-1+3*n_cnt0);
    end 
    else begin
        compute_num0 = 2'd3;
    end
end

always_comb begin
    if(change_row1) begin
        compute_num1 = in_C - (2-1+3*n_cnt1);
    end 
    else begin
        compute_num1 = 2'd3;
    end
end

always_comb begin
    if(change_row2) begin
        compute_num2 = in_C - (2-1+3*n_cnt2);
    end 
    else begin
        compute_num2 = 2'd3;
    end
end

always_comb begin
    if(change_row3) begin
        compute_num3 = in_C - (2-1+3*n_cnt3);
    end 
    else begin
        compute_num3 = 2'd3;
    end
end

always_comb begin
    if(change_row4) begin
        compute_num4 = in_C - (2-1+3*n_cnt4);
    end 
    else begin
        compute_num4 = 2'd3;
    end
end

always_comb begin
    if(change_row5) begin
        compute_num5 = in_C - (2-1+3*n_cnt5);
    end 
    else begin
        compute_num5 = 2'd3;
    end
end

always_comb begin
    if(change_row6) begin
        compute_num6 = in_C - (2-1+3*n_cnt6);
    end 
    else begin
        compute_num6 = 2'd3;
    end
end

always_comb begin
    if(change_row7) begin
        compute_num7 = in_C - (2-1+3*n_cnt7);
    end 
    else begin
        compute_num7 = 2'd3;
    end
end

always_comb begin
    if(change_row8) begin
        compute_num8 = in_C - (2-1+3*n_cnt8);
    end 
    else begin
        compute_num8 = 2'd3;
    end
end

always_comb begin
    if(change_row9) begin
        compute_num9 = in_C - (2-1+3*n_cnt9);
    end 
    else begin
        compute_num9 = 2'd3;
    end
end




//depthwise 
always_ff @ (posedge clk) begin
    if (rst) begin
        c_cnt <= 9'd0;
    end 
    else if (current_state == S_WRITE_IFMAP && pe_ifamp_valid && pe_ifmap_ready) begin
        if(y_cnt == 0) begin
            c_cnt <= !c_cnt;
        end 
        else if (c_cnt == y_cnt + 1) begin
            c_cnt <= y_cnt - 1;
        end
        else if (change_row) begin
            c_cnt <= y_cnt - 1;
        end
        else begin 
            c_cnt <= c_cnt + 1;
        end
    end 
end



always_ff@(posedge clk) begin
    if(rst) begin
        ifmap_addr <= 0;
    end 
    else if (pass_layer_type == `POINTWISE) begin
        if(current_state == S_IDLE) begin
            ifmap_addr <= BASE_IFMAP;
        end 
        else if(current_state == S_WRITE_IFMAP && pe_ifamp_valid && pe_ifmap_ready) begin
            ifmap_addr <= BASE_IFMAP + (n_cnt << 2) + channel_base; // n_cnt 為 4-Channel Pack 的數量        
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
logic bias_flag;
always_ff@(posedge clk) begin
    if(rst) begin
        bias_flag <= 1'b0; // bias_flag 用於判斷是否需要 Bias
    end 
    else if (pass_layer_type == `DEPTHWISE) begin
        if(bias_flag == 1'd0) begin
            bias_flag <= (cnt_bias == 10) ? 1'd1:bias_flag; // 有 Bias
        end 
        else begin
            bias_flag <= (cnt_bias == 20) ? 1'd0:bias_flag; // 無 Bias
        end
    end
end

// bias_addr
always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr <= 0;
    end
    else if (pass_layer_type == `POINTWISE) begin
        if(current_state == S_IDLE) begin
            bias_addr <= BASE_BIAS;
        end 
        else if(~cnt_bias[0] && pe_bias_valid && pe_bias_ready) begin
            bias_addr <= bias_addr + 4;
        end
        else if(current_state == S_WRITE_BIAS && pe_bias_valid && pe_bias_ready) begin // FIXME: 檢查hsk次數
            //FIXME:
            bias_addr <= BASE_BIAS + (((n_cnt << 1) + channel_base) << 1); // n_cnt 為 4-Channel Pack 的數量///FIXME
        end
    end
    else if (pass_layer_type == `DEPTHWISE) begin
        if(current_state == S_IDLE) begin
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
                    bias_addr <= bias_addr;
            end 
            else if(stride == 2'd2) begin
                if (pe_bias_valid && pe_bias_ready) begin
                    if (n_cnt9 == 1) begin
                        bias_addr <= bias_addr + 1 + channel_base; // 每次搬入 4-Channel Pack (32-bit)
                    end
                    else if(bias_flag && y_cnt >= 1) begin // 數20次
                        bias_addr <= bias_addr + 2 + channel_base;
                    end 
                    else if(!bias_flag && y_cnt >= 1) begin // 數20次
                        bias_addr <= bias_addr + 1 + channel_base;
                    end
                end
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
    else begin
        channel_base = 32'd0; // 預設情況
    end
end


always_ff@(posedge clk) begin
    if(rst) begin
        cnt_modify_cnt <= 0;
    end
    else if(current_state == S_WRITE_OPSUM && glb_write_ready && glb_write_valid) begin
        cnt_modify_cnt <= (cnt_modify_cnt == (((cnt_modify + 1) << 3)-1)) ? 0 : cnt_modify_cnt + 1; // 每次寫回 OPSUM 都增加計數
    end
end

// cnt_modify  //FIXME: 只有 POINTWISE 才有用到
always_ff@(posedge clk) begin
    if(rst) begin
        cnt_modify <= 0; 
    end
    else if(current_state == S_IDLE) begin
        cnt_modify <= 0; // 重置計數器
    end
    else if (cnt_modify == 4'd8) begin
        cnt_modify <= 4'd8;
    end
    else if(current_state == S_WRITE_OPSUM && (cnt_modify_cnt == (((cnt_modify + 1) << 3)-1))) begin
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
        opsum_num =  (k_cnt) * pass_tile_n;//+1為了用魔法打敗魔法
    end
    else begin
        opsum_num = 32'd0;
    end
    // else if (pass_layer_type == `DEPTHWISE) begin

    // end
end

// FIXME: 只有POINTWISE有   不改
// //---------------------------------------------------
// // opsum_addr 0~3
// //---------------------------------------------------

//------------- opsum_addr -------------------//
always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr0 <= 32'd0;
    end
    else if(current_state == S_IDLE) begin
        opsum_addr0 <= BASE_OPSUM;
    end
    else if(k_cnt == 6'd0 && glb_write_ready && glb_write_valid) begin
        opsum_addr0 <= opsum_addr0 + 32'd4;
   end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr1 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr1 <= BASE_OPSUM + pass_tile_n * 2;
    end
    else if(k_cnt == 6'd1 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd0 && opsum_hsk_cnt[0]) begin
            opsum_addr1 <= opsum_addr1 + 32'd2;
        end 
        else begin
            opsum_addr1 <= opsum_addr1 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr2 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr2 <= BASE_OPSUM + (pass_tile_n * 2) * 2;
    end
    else if(k_cnt == 6'd2 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd0 && opsum_hsk_cnt[0]) begin
            opsum_addr2 <= opsum_addr2;
        end 
        else begin
            opsum_addr2 <= opsum_addr2 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr3 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr3 <= BASE_OPSUM + (pass_tile_n * 2) * 3;
    end
    else if(k_cnt == 6'd3 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd0 && opsum_hsk_cnt[0]) begin
            opsum_addr3 <= opsum_addr3 - 32'd2;
        end 
        else begin
            opsum_addr3 <= opsum_addr3 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr4 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr4 <= BASE_OPSUM + (pass_tile_n * 2) * 4;
    end
    else if(k_cnt == 6'd4 && glb_write_ready && glb_write_valid) begin
        opsum_addr4 <= opsum_addr4 + 32'd4;
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr5 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr5 <= BASE_OPSUM + (pass_tile_n * 2) * 5;
    end
    else if(k_cnt == 6'd5 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd1 && opsum_hsk_cnt[0]) begin
            opsum_addr5 <= opsum_addr5 + 32'd2;
        end 
        else begin
            opsum_addr5 <= opsum_addr5 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr6 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr6 <= BASE_OPSUM + (pass_tile_n * 2) * 6;
    end
    else if(k_cnt == 6'd6 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd1 && opsum_hsk_cnt[0]) begin
            opsum_addr6 <= opsum_addr6;
        end 
        else begin
            opsum_addr6 <= opsum_addr6 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr7 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr7 <= BASE_OPSUM + (pass_tile_n * 2) * 7;
    end
    else if(k_cnt == 6'd7 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd1 && opsum_hsk_cnt[0]) begin
            opsum_addr7 <= opsum_addr7 - 32'd2;
        end 
        else begin
            opsum_addr7 <= opsum_addr7 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr8 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr8 <= BASE_OPSUM + (pass_tile_n * 2) * 8;
    end
    else if(k_cnt == 6'd8 && glb_write_ready && glb_write_valid) begin
        opsum_addr8 <= opsum_addr8 + 32'd4;
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr9 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr9 <= BASE_OPSUM + (pass_tile_n * 2) * 9;
    end
    else if(k_cnt == 6'd9 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd2 && opsum_hsk_cnt[0]) begin
            opsum_addr9 <= opsum_addr9 + 32'd2;
        end 
        else begin
            opsum_addr9 <= opsum_addr9 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr10 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr10 <= BASE_OPSUM + (pass_tile_n * 2) * 10;
    end
    else if(k_cnt == 6'd10 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd2 && opsum_hsk_cnt[0]) begin
            opsum_addr10 <= opsum_addr10;
        end 
        else begin
            opsum_addr10 <= opsum_addr10 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr11 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr11 <= BASE_OPSUM + (pass_tile_n * 2) * 11;
    end
    else if(k_cnt == 6'd11 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd2 && opsum_hsk_cnt[0]) begin
            opsum_addr11 <= opsum_addr11 - 32'd2;
        end 
        else begin
            opsum_addr11 <= opsum_addr11 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr12 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr12 <= BASE_OPSUM + (pass_tile_n * 2) * 12;
    end
    else if(k_cnt == 6'd12 && glb_write_ready && glb_write_valid) begin
        opsum_addr12 <= opsum_addr12 + 32'd4;
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr13 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr13 <= BASE_OPSUM + (pass_tile_n * 2) * 13;
    end
    else if(k_cnt == 6'd13 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd3 && opsum_hsk_cnt[0]) begin
            opsum_addr13 <= opsum_addr13 + 32'd2; 
        end 
        else begin
            opsum_addr13 <= opsum_addr13 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr14 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr14 <= BASE_OPSUM + (pass_tile_n * 2) * 14;
    end
    else if(k_cnt == 6'd14 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd3 && opsum_hsk_cnt[0]) begin
            opsum_addr14 <= opsum_addr14;
        end 
        else begin
            opsum_addr14 <= opsum_addr14 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr15 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr15 <= BASE_OPSUM + (pass_tile_n * 2) * 15;
    end
    else if(k_cnt == 6'd15 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd3 && opsum_hsk_cnt[0]) begin
            opsum_addr15 <= opsum_addr15 - 32'd2;
        end 
        else begin
            opsum_addr15 <= opsum_addr15 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr16 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr16 <= BASE_OPSUM + (pass_tile_n * 2) * 16;
    end
    else if(k_cnt == 6'd16 && glb_write_ready && glb_write_valid) begin
        opsum_addr16 <= opsum_addr16 + 32'd4;
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr17 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr17 <= BASE_OPSUM + (pass_tile_n * 2) * 17;
    end
    else if(k_cnt == 6'd17 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd4 && opsum_hsk_cnt[0]) begin
            opsum_addr17 <= opsum_addr17 + 32'd2;
        end 
        else begin
            opsum_addr17 <= opsum_addr17 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr18 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr18 <= BASE_OPSUM + (pass_tile_n * 2) * 18;
    end
    else if(k_cnt == 6'd18 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd4 && opsum_hsk_cnt[0]) begin
            opsum_addr18 <= opsum_addr18;
        end 
        else begin
            opsum_addr18 <= opsum_addr18 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr19 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr19 <= BASE_OPSUM + (pass_tile_n * 2) * 19;
    end
    else if(k_cnt == 6'd19 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd4 && opsum_hsk_cnt[0]) begin
            opsum_addr19 <= opsum_addr19 - 32'd2;
        end 
        else begin
            opsum_addr19 <= opsum_addr19 + 32'd4;
        end
    end
end 

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr20 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr20 <= BASE_OPSUM + (pass_tile_n * 2) * 20;
    end
    else if(k_cnt == 6'd20 && glb_write_ready && glb_write_valid) begin
        opsum_addr20 <= opsum_addr20 + 32'd4;
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr21 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr21 <= BASE_OPSUM + (pass_tile_n * 2) * 21;
    end
    else if(k_cnt == 6'd21 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd5 && opsum_hsk_cnt[0]) begin
            opsum_addr21 <= opsum_addr21 + 32'd2;
        end 
        else begin
            opsum_addr21 <= opsum_addr21 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr22 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr22 <= BASE_OPSUM + (pass_tile_n * 2) * 22;
    end
    else if(k_cnt == 6'd22 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd5 && opsum_hsk_cnt[0]) begin
            opsum_addr22 <= opsum_addr22;
        end 
        else begin
            opsum_addr22 <= opsum_addr22 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr23 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr23 <= BASE_OPSUM + (pass_tile_n * 2) * 23;
    end
    else if(k_cnt == 6'd23 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd5 && opsum_hsk_cnt[0]) begin
            opsum_addr23 <= opsum_addr23 - 32'd2;
        end 
        else begin
            opsum_addr23 <= opsum_addr23 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr24 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr24 <= BASE_OPSUM + (pass_tile_n * 2) * 24;
    end
    else if(k_cnt == 6'd24 && glb_write_ready && glb_write_valid) begin
        opsum_addr24 <= opsum_addr24 + 32'd4;
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr25 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr25 <= BASE_OPSUM + (pass_tile_n * 2) * 25;
    end
    else if(k_cnt == 6'd25 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd6 && opsum_hsk_cnt[0]) begin
            opsum_addr25 <= opsum_addr25 + 32'd2;
        end 
        else begin
            opsum_addr25 <= opsum_addr25 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr26 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr26 <= BASE_OPSUM + (pass_tile_n * 2) * 26;
    end
    else if(k_cnt == 6'd26 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd6 && opsum_hsk_cnt[0]) begin
            opsum_addr26 <= opsum_addr26;
        end 
        else begin
            opsum_addr26 <= opsum_addr26 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr27 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr27 <= BASE_OPSUM + (pass_tile_n * 2) * 27;
    end
    else if(k_cnt == 6'd27 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd6 && opsum_hsk_cnt[0]) begin
            opsum_addr27 <= opsum_addr27 - 32'd2;
        end 
        else begin
            opsum_addr27 <= opsum_addr27 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr28 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr28 <= BASE_OPSUM + (pass_tile_n * 2) * 28;
    end
    else if(k_cnt == 6'd28 && glb_write_ready && glb_write_valid) begin
        opsum_addr28 <= opsum_addr28 + 32'd4;
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr29 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr29 <= BASE_OPSUM + (pass_tile_n * 2) * 29;
    end
    else if(k_cnt == 6'd29 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd7 && opsum_hsk_cnt[0]) begin
            opsum_addr29 <= opsum_addr29 + 32'd2;
        end 
        else begin
            opsum_addr29 <= opsum_addr29 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr30 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr30 <= BASE_OPSUM + (pass_tile_n * 2) * 30;
    end
    else if(k_cnt == 6'd30 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd7 && opsum_hsk_cnt[0]) begin
            opsum_addr30 <= opsum_addr30;
        end 
        else begin
            opsum_addr30 <= opsum_addr30 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        opsum_addr31 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        opsum_addr31 <= BASE_OPSUM + (pass_tile_n * 2) * 31;
    end
    else if(k_cnt == 6'd31 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd7 && opsum_hsk_cnt[0]) begin
            opsum_addr31 <= opsum_addr31 - 32'd2;
        end 
        else begin
            opsum_addr31 <= opsum_addr31 + 32'd4;
        end
    end
end



// FIXME: 只有POINTWISE有   不改
// //---------------------------------------------------
// // bias_addr 0~31
// //---------------------------------------------------

logic [31:0] bias_addr0, bias_addr1, bias_addr2, bias_addr3;
logic [31:0] bias_addr4, bias_addr5, bias_addr6, bias_addr7;
logic [31:0] bias_addr8, bias_addr9, bias_addr10, bias_addr11;
logic [31:0] bias_addr12, bias_addr13, bias_addr14, bias_addr15;
logic [31:0] bias_addr16, bias_addr17, bias_addr18, bias_addr19;
logic [31:0] bias_addr20, bias_addr21, bias_addr22, bias_addr23;
logic [31:0] bias_addr24, bias_addr25, bias_addr26, bias_addr27;
logic [31:0] bias_addr28, bias_addr29, bias_addr30, bias_addr31;

//------------- opsum_addr -------------------//
always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr0 <= 32'd0;
    end
    else if(current_state == S_IDLE) begin
        bias_addr0 <= BASE_BIAS;
    end
    else if((((cnt_modify + 32'd1) << 2) - 1)  && glb_read_ready && glb_read_valid) begin
        
        bias_addr0 <= bias_addr0 + 32'd4;
   end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr1 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr1 <= BASE_BIAS + pass_tile_n * 2;
    end
    else if(k_cnt == 6'd1 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd0 && cnt_bias[0]) begin
            bias_addr1 <= bias_addr1 + 32'd2;
        end 
        else begin
            bias_addr1 <= bias_addr1 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr2 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr2 <= BASE_BIAS + (pass_tile_n * 2) * 2;
    end
    else if(k_cnt == 6'd2 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd0 && cnt_bias[0]) begin
            bias_addr2 <= bias_addr2;
        end 
        else begin
            bias_addr2 <= bias_addr2 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr3 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr3 <= BASE_BIAS + (pass_tile_n * 2) * 3;
    end
    else if(k_cnt == 6'd3 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd0 && cnt_bias[0]) begin
            bias_addr3 <= bias_addr3 - 32'd2;
        end 
        else begin
            bias_addr3 <= bias_addr3 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr4 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr4 <= BASE_BIAS + (pass_tile_n * 2) * 4;
    end
    else if(k_cnt == 6'd4 && glb_write_ready && glb_write_valid) begin
        bias_addr4 <= bias_addr4 + 32'd4;
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr5 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr5 <= BASE_BIAS + (pass_tile_n * 2) * 5;
    end
    else if(k_cnt == 6'd5 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd1 && cnt_bias[0]) begin
            bias_addr5 <= bias_addr5 + 32'd2;
        end 
        else begin
            bias_addr5 <= bias_addr5 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr6 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr6 <= BASE_BIAS + (pass_tile_n * 2) * 6;
    end
    else if(k_cnt == 6'd6 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd1 && cnt_bias[0]) begin
            bias_addr6 <= bias_addr6;
        end 
        else begin
            bias_addr6 <= bias_addr6 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr7 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr7 <= BASE_BIAS + (pass_tile_n * 2) * 7;
    end
    else if(k_cnt == 6'd7 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd1 && cnt_bias[0]) begin
            bias_addr7 <= bias_addr7 - 32'd2;
        end 
        else begin
            bias_addr7 <= bias_addr7 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr8 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr8 <= BASE_BIAS + (pass_tile_n * 2) * 8;
    end
    else if(k_cnt == 6'd8 && glb_write_ready && glb_write_valid) begin
        bias_addr8 <= bias_addr8 + 32'd4;
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr9 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr9 <= BASE_BIAS + (pass_tile_n * 2) * 9;
    end
    else if(k_cnt == 6'd9 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd2 && cnt_bias[0]) begin
            bias_addr9 <= bias_addr9 + 32'd2;
        end 
        else begin
            bias_addr9 <= bias_addr9 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr10 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr10 <= BASE_BIAS + (pass_tile_n * 2) * 10;
    end
    else if(k_cnt == 6'd10 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd2 && cnt_bias[0]) begin
            bias_addr10 <= bias_addr10;
        end 
        else begin
            bias_addr10 <= bias_addr10 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr11 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr11 <= BASE_BIAS + (pass_tile_n * 2) * 11;
    end
    else if(k_cnt == 6'd11 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd2 && cnt_bias[0]) begin
            bias_addr11 <= bias_addr11 - 32'd2;
        end 
        else begin
            bias_addr11 <= bias_addr11 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr12 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr12 <= BASE_BIAS + (pass_tile_n * 2) * 12;
    end
    else if(k_cnt == 6'd12 && glb_write_ready && glb_write_valid) begin
        bias_addr12 <= bias_addr12 + 32'd4;
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr13 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr13 <= BASE_BIAS + (pass_tile_n * 2) * 13;
    end
    else if(k_cnt == 6'd13 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd3 && cnt_bias[0]) begin
            bias_addr13 <= bias_addr13 + 32'd2; 
        end 
        else begin
            bias_addr13 <= bias_addr13 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr14 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr14 <= BASE_BIAS + (pass_tile_n * 2) * 14;
    end
    else if(k_cnt == 6'd14 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd3 && cnt_bias[0]) begin
            bias_addr14 <= bias_addr14;
        end 
        else begin
            bias_addr14 <= bias_addr14 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr15 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr15 <= BASE_BIAS + (pass_tile_n * 2) * 15;
    end
    else if(k_cnt == 6'd15 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd3 && cnt_bias[0]) begin
            bias_addr15 <= bias_addr15 - 32'd2;
        end 
        else begin
            bias_addr15 <= bias_addr15 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr16 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr16 <= BASE_BIAS + (pass_tile_n * 2) * 16;
    end
    else if(k_cnt == 6'd16 && glb_write_ready && glb_write_valid) begin
        bias_addr16 <= bias_addr16 + 32'd4;
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr17 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr17 <= BASE_BIAS + (pass_tile_n * 2) * 17;
    end
    else if(k_cnt == 6'd17 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd4 && cnt_bias[0]) begin
            bias_addr17 <= bias_addr17 + 32'd2;
        end 
        else begin
            bias_addr17 <= bias_addr17 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr18 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr18 <= BASE_BIAS + (pass_tile_n * 2) * 18;
    end
    else if(k_cnt == 6'd18 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd4 && cnt_bias[0]) begin
            bias_addr18 <= bias_addr18;
        end 
        else begin
            bias_addr18 <= bias_addr18 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr19 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr19 <= BASE_BIAS + (pass_tile_n * 2) * 19;
    end
    else if(k_cnt == 6'd19 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd4 && cnt_bias[0]) begin
            bias_addr19 <= bias_addr19 - 32'd2;
        end 
        else begin
            bias_addr19 <= bias_addr19 + 32'd4;
        end
    end
end 

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr20 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr20 <= BASE_BIAS + (pass_tile_n * 2) * 20;
    end
    else if(k_cnt == 6'd20 && glb_write_ready && glb_write_valid) begin
        bias_addr20 <= bias_addr20 + 32'd4;
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr21 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr21 <= BASE_BIAS + (pass_tile_n * 2) * 21;
    end
    else if(k_cnt == 6'd21 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd5 && cnt_bias[0]) begin
            bias_addr21 <= bias_addr21 + 32'd2;
        end 
        else begin
            bias_addr21 <= bias_addr21 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr22 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr22 <= BASE_BIAS + (pass_tile_n * 2) * 22;
    end
    else if(k_cnt == 6'd22 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd5 && cnt_bias[0]) begin
            bias_addr22 <= bias_addr22;
        end 
        else begin
            bias_addr22 <= bias_addr22 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr23 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr23 <= BASE_BIAS + (pass_tile_n * 2) * 23;
    end
    else if(k_cnt == 6'd23 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd5 && cnt_bias[0]) begin
            bias_addr23 <= bias_addr23 - 32'd2;
        end 
        else begin
            bias_addr23 <= bias_addr23 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr24 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr24 <= BASE_BIAS + (pass_tile_n * 2) * 24;
    end
    else if(k_cnt == 6'd24 && glb_write_ready && glb_write_valid) begin
        bias_addr24 <= bias_addr24 + 32'd4;
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr25 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr25 <= BASE_BIAS + (pass_tile_n * 2) * 25;
    end
    else if(k_cnt == 6'd25 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd6 && cnt_bias[0]) begin
            bias_addr25 <= bias_addr25 + 32'd2;
        end 
        else begin
            bias_addr25 <= bias_addr25 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr26 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr26 <= BASE_BIAS + (pass_tile_n * 2) * 26;
    end
    else if(k_cnt == 6'd26 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd6 && cnt_bias[0]) begin
            bias_addr26 <= bias_addr26;
        end 
        else begin
            bias_addr26 <= bias_addr26 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr27 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr27 <= BASE_BIAS + (pass_tile_n * 2) * 27;
    end
    else if(k_cnt == 6'd27 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd6 && cnt_bias[0]) begin
            bias_addr27 <= bias_addr27 - 32'd2;
        end 
        else begin
            bias_addr27 <= bias_addr27 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr28 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr28 <= BASE_BIAS + (pass_tile_n * 2) * 28;
    end
    else if(k_cnt == 6'd28 && glb_write_ready && glb_write_valid) begin
        bias_addr28 <= bias_addr28 + 32'd4;
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr29 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr29 <= BASE_BIAS + (pass_tile_n * 2) * 29;
    end
    else if(k_cnt == 6'd29 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd7 && cnt_bias[0]) begin
            bias_addr29 <= bias_addr29 + 32'd2;
        end 
        else begin
            bias_addr29 <= bias_addr29 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr30 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr30 <= BASE_BIAS + (pass_tile_n * 2) * 30;
    end
    else if(k_cnt == 6'd30 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd7 && cnt_bias[0]) begin
            bias_addr30 <= bias_addr30;
        end 
        else begin
            bias_addr30 <= bias_addr30 + 32'd4;
        end
    end
end

always_ff@(posedge clk) begin
    if(rst) begin
        bias_addr31 <= 32'd0;
    end 
    else if(current_state == S_IDLE) begin
        bias_addr31 <= BASE_BIAS + (pass_tile_n * 2) * 31;
    end
    else if(k_cnt == 6'd31 && glb_write_ready && glb_write_valid) begin
        if(cnt_modify == 4'd7 && cnt_bias[0]) begin
            bias_addr31 <= bias_addr31 - 32'd2;
        end 
        else begin
            bias_addr31 <= bias_addr31 + 32'd4;
        end
    end
end


//---------------------------------------------------
// FIXME: 
//---------------------------------------------------
// opsum_addr
logic [`ADDR_WIDTH-1:0] d_opsum_addr;

always_ff@(posedge clk) begin
    if(rst) begin
        d_opsum_addr <= 32'd0;
    end 
    else if(pass_layer_type == `DEPTHWISE) begin
        if(stride == 2'd1) begin
            if (pe_psum_valid && pe_psum_ready && n_cnt9 == 1) begin
                d_opsum_addr <= d_opsum_addr + 1 + channel_base; // 每次搬入 4-Channel Pack (32-bit)
            end
            else if(cnt_bias[0] && pe_psum_valid && pe_psum_ready)
                d_opsum_addr <= d_opsum_addr + 3 + channel_base;
            else 
                d_opsum_addr <= d_opsum_addr;
        end 
        else if(stride == 2'd2) begin
            if (pe_psum_valid && pe_psum_ready) begin
                if (n_cnt9 == 1) begin
                    d_opsum_addr <= d_opsum_addr + 1 + channel_base; // 每次搬入 4-Channel Pack (32-bit)
                end
                else if(bias_flag && y_cnt >= 1) begin // 數20次
                    d_opsum_addr <= d_opsum_addr + 2 + channel_base;
                end 
                else if(!bias_flag && y_cnt >= 1) begin // 數20次
                    d_opsum_addr <= d_opsum_addr + 1 + channel_base;
                end
            end
        end
    end
end

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
            default :opsum_addr = 32'd0; // 預設為最後一個地址
        endcase
    end
    else if (pass_layer_type == `DEPTHWISE) begin
        opsum_addr = d_opsum_addr; // 使用 d_opsum_addr
    end 
    else begin
        opsum_addr = 32'd0; // 預設為 0
    end
end

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
            glb_read_addr = 32'd0; // 預設為 0
        end
    endcase
end

always_comb begin
    if(current_state == S_WRITE_OPSUM || current_state == S_WAIT_OPSUM) begin
        glb_write_addr = opsum_addr; 
    end
    else begin
        glb_write_addr = 32'd0; // 預設為 0
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
            if (pe_psum_valid && pe_psum_ready) begin
                if (n_cnt9 == 1) begin
                    total_opsum_num_cnt <= total_opsum_num_cnt + 1; // 每次搬入 4-Channel Pack (32-bit)
                end
                else if(bias_flag && y_cnt >= 1) begin // 數20次
                    total_opsum_num_cnt <= total_opsum_num_cnt + 2;
                end 
                else if(!bias_flag && y_cnt >= 1) begin // 數20次
                    total_opsum_num_cnt <= total_opsum_num_cnt + 1;
                end
            end
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

//---------- WEB ----------//
always_comb begin   
    WEB = (current_state == S_WRITE_OPSUM) ? 1'd0 : 1'd1; 
end

//-------------------- padding logic --------------------//
/* 0: up padding, 1: left paadding, 2: right padding, 3: down padding
   4: up left padding, 5: up right padding, 6: down left padding, 7: down right padding
   8: no padding
*/
logic [2:0] padding_pe_hsk_cnt;
logic [5:0] padding_pe_hsk_cnt_left;




logic [3:0] control_padding0,   
            control_padding1, 
            control_padding2, 
            control_padding3, 
            control_padding4, 
            control_padding5, 
            control_padding6, 
            control_padding7, 
            control_padding8,
            control_padding9; 

always_ff@(posedge clk) begin
    if(rst) begin
        padding_pe_hsk_cnt <= 3'd0;
    end 
    else if(pe_ifamp_valid && pe_ifmap_ready) begin
        padding_pe_hsk_cnt <= (padding_pe_hsk_cnt == 3'd2) ? 3'd0 : padding_pe_hsk_cnt + 1; // 每次讀取 IFMAP 都增加計數
    end 
end

always_ff@(posedge clk) begin
    if(rst) begin
        padding_pe_hsk_cnt_left <= 6'd0;
    end 
    else if(current_state == S_WRITE_IFMAP && pe_ifamp_valid && pe_ifmap_ready) begin
        padding_pe_hsk_cnt_left <= (padding_pe_hsk_cnt_left == 6'd2) ? 6'd0 : padding_pe_hsk_cnt_left + 1; // 每次讀取 IFMAP 都增加計數
    end 
    else if(current_state == S_READ_IFMAP) begin
        padding_pe_hsk_cnt_left <= padding_pe_hsk_cnt_left;
    end 
    else begin
        padding_pe_hsk_cnt_left <= 6'd0; // 重置計數器
    end
end

always_comb begin
    if(pass_layer_type == `DEPTHWISE) begin 
        if(y_cnt == 0) begin // up padding 

            if(n_cnt0 == 0) begin       // FIXME: cant not use n_cnt
                control_padding0 = 4'd4;
            end 
            else if(change_row0) begin
                control_padding0 = 4'd5;
            end
            else begin
                control_padding0 = 4'd0;
            end

            if(n_cnt1 == 0) begin
                control_padding1 = 4'd4;
            end 
            else if(change_row1) begin
                control_padding1 = 4'd5;
            end
            else begin
                control_padding1 = 4'd0;
            end

            if(n_cnt2 == 0) begin
                control_padding2 = 4'd4;
            end 
            else if(change_row2) begin
                control_padding2 = 4'd5;
            end
            else begin
                control_padding2 = 4'd0;
            end

            if(n_cnt3 == 0) begin
                control_padding3 = 4'd4;
            end 
            else if(change_row3) begin
                control_padding3 = 4'd5;
            end
            else begin
                control_padding3 = 4'd0;
            end

            if(n_cnt4 == 0) begin
                control_padding4 = 4'd4;
            end 
            else if(change_row4) begin
                control_padding4 = 4'd5;
            end
            else begin
                control_padding4 = 4'd0;
            end

            if(n_cnt5 == 0) begin
                control_padding5 = 4'd4;
            end 
            else if(change_row5) begin
                control_padding5 = 4'd5;
            end
            else begin
                control_padding5 = 4'd0;
            end

            if(n_cnt6 == 0) begin
                control_padding6 = 4'd4;
            end 
            else if(change_row6) begin
                control_padding6 = 4'd5;
            end
            else begin
                control_padding6 = 4'd0;
            end

            if(n_cnt7 == 0) begin
                control_padding7 = 4'd4;
            end 
            else if(change_row7) begin
                control_padding7 = 4'd5;
            end
            else begin
                control_padding7 = 4'd0;
            end

            if(n_cnt8 == 0) begin
                control_padding8 = 4'd4;
            end 
            else if(change_row8) begin
                control_padding8 = 4'd5;
            end
            else begin
                control_padding8 = 4'd0;
            end

            if(n_cnt9 == 0) begin
                control_padding9 = 4'd4;
            end 
            else if(change_row9) begin
                control_padding9 = 4'd5;
            end
            else begin
                control_padding9 = 4'd0;
            end

        end 
        else if(y_cnt == in_R - 1) begin // down padding
            if(n_cnt0 == 0) begin
                control_padding0 = 4'd6;
            end 
            else if(change_row0) begin
                control_padding0 = 4'd7;
            end
            else begin
                control_padding0 = 4'd3;
            end

            if(n_cnt1 == 0) begin
                control_padding1 = 4'd6;
            end 
            else if(change_row1) begin
                control_padding1 = 4'd7;
            end
            else begin
                control_padding1 = 4'd3;
            end

            if(n_cnt2 == 0) begin
                control_padding2 = 4'd6;
            end 
            else if(change_row2) begin
                control_padding2 = 4'd7;
            end
            else begin
                control_padding2 = 4'd3;
            end

            if(n_cnt3 == 0) begin
                control_padding3 = 4'd6;
            end 
            else if(change_row3) begin
                control_padding3 = 4'd7;
            end
            else begin
                control_padding3 = 4'd3;
            end

            if(n_cnt4 == 0) begin
                control_padding4 = 4'd6;
            end 
            else if(change_row4) begin
                control_padding4 = 4'd7;
            end
            else begin
                control_padding4 = 4'd3;
            end

            if(n_cnt5 == 0) begin
                control_padding5 = 4'd6;
            end 
            else if(change_row5) begin
                control_padding5 = 4'd7;
            end
            else begin
                control_padding5 = 4'd3;
            end

            if(n_cnt6 == 0) begin
                control_padding6 = 4'd6;
            end 
            else if(change_row6) begin
                control_padding6 = 4'd7;
            end
            else begin
                control_padding6 = 4'd3;
            end

            if(n_cnt7 == 0) begin
                control_padding7 = 4'd6;
            end 
            else if(change_row7) begin
                control_padding7 = 4'd7;
            end
            else begin
                control_padding7 = 4'd3;
            end

            if(n_cnt8 == 0) begin
                control_padding8 = 4'd6;
            end 
            else if(change_row8) begin
                control_padding8 = 4'd7;
            end
            else begin
                control_padding8 = 4'd3;
            end

            if(n_cnt9 == 0) begin
                control_padding9 = 4'd6;
            end 
            else if(change_row9) begin
                control_padding9 = 4'd7;
            end
            else begin
                control_padding9 = 4'd3;
            end

        end else begin
            control_padding0 = 4'd8;
            control_padding1 = 4'd8;
            control_padding2 = 4'd8;
            control_padding3 = 4'd8;
            control_padding4 = 4'd8;
            control_padding5 = 4'd8;
            control_padding6 = 4'd8;
            control_padding7 = 4'd8;
            control_padding8 = 4'd8;
            control_padding9 = 4'd8; 
        end
    end
    else begin // no padding
        control_padding0 = 4'd8;
        control_padding1 = 4'd8;
        control_padding2 = 4'd8;
        control_padding3 = 4'd8;
        control_padding4 = 4'd8;
        control_padding5 = 4'd8;
        control_padding6 = 4'd8;
        control_padding7 = 4'd8;
        control_padding8 = 4'd8;
        control_padding9 = 4'd8; 
    end
end


//control_padding
always_comb begin
    if (col_en_cnt >= 8'd27) begin
        control_padding = control_padding9; // 27-30
    end
    else if (col_en_cnt >= 8'd24) begin
        control_padding = control_padding8; // 24-27
    end
    else if (col_en_cnt >= 8'd21) begin
        control_padding = control_padding7; // 21-24
    end
    else if (col_en_cnt >= 8'd18) begin
        control_padding = control_padding6; // 18-21
    end
    else if (col_en_cnt >= 8'd15) begin
        control_padding = control_padding5; // 15-18
    end
    else if (col_en_cnt >= 8'd12) begin
        control_padding = control_padding4; // 12-15
    end
    else if (col_en_cnt >= 8'd9) begin
        control_padding = control_padding3; // 9-12
    end
    else if (col_en_cnt >= 8'd6) begin
        control_padding = control_padding2; // 6-9
    end
    else if (col_en_cnt >= 8'd3) begin
        control_padding = control_padding1; // 3-6
    end 
    else begin 
        control_padding = control_padding0; // 0-3
    end
end

//-------------------- BWEB --------------------//
always_comb begin
    if(pass_layer_type == `POINTWISE) begin
        if(current_state == S_WRITE_OPSUM) begin
            case(opsum_addr[1:0])
                2'b00: BWEB = 32'hffff_ff00; // opsum_addr[1:0] = 00
                2'b01: BWEB = 32'hffff_00ff; // opsum_addr[1:0] = 01
                2'b10: BWEB = 32'hff00_ffff; // opsum_addr[1:0] = 10
                2'b11: BWEB = 32'h00ff_ffff; // opsum_addr[1:0] = 11
                default: BWEB = 32'hffff_ffff; // 預設為全開
            endcase
        end else begin
            BWEB = 32'hffff_ffff;
        end
    end else begin
        BWEB = 32'hffff_ffff; 
    end
end
endmodule