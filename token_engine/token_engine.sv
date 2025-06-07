//==============================================================================
// Token Engine FSM – 更新版 (SystemVerilog)
// 
// 此版本根據您最新提供的 I/O 端口定義，調整了訊號名稱與 Handshake 規格。
// 請依下列訊號，搭配您實際的 GLB/PE/PSUM Buffer 介面完成 RTL 實作。
//==============================================================================

module token_engine_fsm (
    //==============================================================================
    // 1) Clock / Reset
    //==============================================================================
    input  logic                 clk,               
    input  logic                 reset_n,           

    //==============================================================================
    // 2) Pass 觸發與參數 (由 Tile Scheduler / Layer Decoder 提供)
    //==============================================================================
    input  logic                      PASS_START,          // 1clk Pulse：收到後可開始向 GLB 抓值
    input  logic [1:0]                pass_layer_type,     // 00=普通 Conv, 01=Pointwise (tile_D=32, tile_K=32), 10=Depthwise (tile_D=10, tile_K=10)
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
    output logic                  token_valid,        // 1clk 脈衝：token_data + token_tag 現在有效
    input  logic                  pe_busy,            // PE Array 拉高表示「目前忙碌中，尚在 Compute」

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
    output logic pe_psum_ready,
    input pe_psum_valid,
    //==============================================================================
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

    logic [ADDR_WIDTH-1:0] base_ifmap;         // Latched BASE_IFMAP
    logic [ADDR_WIDTH-1:0] base_weight;        // Latched BASE_WEIGHT
    logic [ADDR_WIDTH-1:0] base_bias;          // 可新增：若需要 Bias base，否則可省略
    logic [ADDR_WIDTH-1:0] base_opsum;         // Latched BASE_OPSUM

    logic [DATA_WIDTH-1:0] ifmap_reg;

    // Counters 數送了幾個
    logic [5:0]            cnt_bias;          // 已推 Bias 的筆數 (0~tile_K_internal-1)
    logic [5:0]            cnt_ifmap;         // 已推 Ifmap 的 4-Channel 組數 (0~⌈tile_D/4⌉-1)
    logic [5:0]            cnt_weight;        // 已推 Weight 的 4-Channel 組數 (0~⌈tile_D/4⌉-1)
    logic [5:0]            cnt_psum;          // 已 pop OPSUM 寫回的筆數 (0~tile_K_internal-1)


    //===== 會拿通道數去 計算opsum_row_num
    logic [4:0] opsum_row_num; // OPSUM 有寫回的 row 數量



    // 若需要外部索引 (tile_k_idx, tile_d_idx) 可在此新增，但簡化示例省略

    //==========================================================================
    // 1) Seq. Logic: 狀態暫存 (State Register)
    //==========================================================================
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state   <= S_IDLE;
        end else begin
            current_state   <= next_state;
        end
    end



    //==========================================================================
    // next_state
    //==========================================================================
    always_comb begin
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
                // 把 glb_read_data (Ifmap Pack) 推送到內部 FIFO，或做後續處理

                // 同時計算 control_padding (Depthwise / 空間 Padding)
                // 若需要: control_padding = 1'b1;
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
                if ((cnt_bias == 6'd31) && pe_bias_valid && pe_bias_ready) begin //後面不一定是 32 可以改成一個parameter (ifmap 不夠大或是 channel 不夠多)
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
                    if () begin //整個算完
                        next_state = S_PASS_DONE;
                    end
                    else if (cnt_psum == opsum_row_num) begin
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
        endcase
    end

    //---------- ifmap ----------//
    // todo: save the ifmap data
    always_ff@(posedge clk) begin

        if(rst) begin
            ifmap_reg <= DATA_WIDTH'd0;
        end else if(current_state == S_READ_IFMAP) begin
            ifmap_reg <= glb_read_data; // 假設 glb_read_data 是 4-Channel Pack
        end

    end
    //==========================================================================
    // 2) Comb. Logic: 下個狀態 (next_state) 及輸出控制
    //==========================================================================
    always_comb begin
        //--------------------------------------------------------------------------
        // 2.1) 預設所有輸出信號為 0
        //--------------------------------------------------------------------------
        glb_read_addr    = '0;
        glb_read_ready   = 1'b0;
        glb_write_addr   = '0;
        glb_write_data   = '0;
        glb_write_ready  = 1'b0;
        token_data       = '0;
        token_valid      = 1'b0;
        control_padding  = 1'b0;
        pe_psum_ready    = 1'b0;
        pass_done        = 1'b0;

        //--------------------------------------------------------------------------

        case (current_state)
            //---------------------------------------------------
            // state：S_IDLE
            //---------------------------------------------------
            //---------------------------------------------------
            // state：S_READ_WEIGHT
            //---------------------------------------------------
            S_READ_WEIGHT: begin
                glb_read_addr  = base_weight;   // 可自行加偏移：+ cnt_weight*BytesPerPack
                glb_read_ready = 1'b1;          // 1clk 脈衝：請求讀取 Weight
            end
            //---------------------------------------------------
            // state：S_WRITE_WEIGHT
            //---------------------------------------------------
            S_WRITE_WEIGHT: begin
                // 把 glb_read_data (Weight Pack) 推送到內部 FIFO，或做後續處理
                token_data      = glb_read_data; // Buffer 起始時可暫存
                token_valid     = 1'b1;          // 與 PE 或 FIFO 做 handshake
                // 也可以使用專屬訊號 write_weight…
            end
            //---------------------------------------------------
            // state：S_READ_IFMAP
            //---------------------------------------------------
            S_READ_IFMAP: begin
                // 啟動 GLB Read Ifmap (4-Channel Pack)
                glb_read_addr  = base_ifmap;    // 可自行加偏移：+ cnt_ifmap*4*BytesPerChannel
                glb_read_ready = 1'b1;          // 1clk 脈衝：請求讀取 Ifmap
            end
            //---------------------------------------------------
            // state：S_WRITE_IFMAP
            //---------------------------------------------------
            S_WRITE_IFMAP: begin
                // 把 glb_read_data (Ifmap Pack) 推送到內部 FIFO，或做後續處理
                token_data      = glb_read_data;
                token_valid     = 1'b1;         // 送給 PE 或 FIFO
                // 同時計算 control_padding (Depthwise / 空間 Padding)
                // 若需要: control_padding = 1'b1;
            end
            //---------------------------------------------------
            // state：S_READ_BIAS
            //---------------------------------------------------
            S_READ_BIAS: begin
                // 如果 pass_flags[0] = bias_en = 1，則讀 Bias
                if (pass_flags[0]) begin
                    glb_read_addr  = base_bias;  // 可自行加偏移：+ cnt_bias*BytesPerChannel
                    glb_read_ready = 1'b1;        // 1clk 脈衝：請求讀取 Bias
                end
            end
            //---------------------------------------------------
            // state：S_WRITE_BIAS
            //---------------------------------------------------
            S_WRITE_BIAS: begin
                // 把 glb_read_data (Bias) 推送到內部 FIFO，或做後續處理
                token_data     = glb_read_data;
                token_valid    = 1'b1;         // 送給 PE 或 FIFO
                // bias 推完 (可在此處增加計數器 cnt_bias++)，直接進入 WAIT_OPSUM
            end
            //---------------------------------------------------
            // state：S_WAIT_OPSUM
            //---------------------------------------------------
            S_WAIT_OPSUM: begin
                // 等待 PE / PSUM Buffer pop 出累加結果 (OPSUM)
                if (pe_psum_valid) begin
                    pe_psum_ready = 1'b1;     // 通知 PSUM Buffer 可以 pop 一筆
                end 
                else begin
                end
            end
            //---------------------------------------------------
            // state：S_WRITE_OPSUM
            //---------------------------------------------------
            S_WRITE_OPSUM: begin
                // 將剛 Pop 出來的 OPSUM 寫回 GLB
                glb_write_addr  = base_opsum;     // 可自行加偏移：+ cnt_psum*BytesPerChannel
                glb_write_data  = pe_psum_data;   // OPSUM 資料
                glb_write_ready = 1'b1;            // 1clk 脈衝：請求寫回
                if (glb_write_valid) begin
                end 
                else begin
                end
            end
            //---------------------------------------------------
            // state：S_PASS_DONE
            //---------------------------------------------------
            S_PASS_DONE: begin
                // 通知 Tile Scheduler：本次 Pass (Tile) 完成
                pass_done  = 1'b1; 
            end
            //---------------------------------------------------
            // 預設：回到 IDLE
            //---------------------------------------------------
        endcase
    end
//---------------------------------------------------
// weight, ifmap, bias, opsum, token 等訊號的 Handshake
//---------------------------------------------------
//TODO: 在對應的狀態中，加入 Handshake 邏輯 並且分好幾個always combination block

always_comb begin
    if (current_state == S_READ_WEIGHT) begin
        glb_read_ready = 
    end


end

    // typedef enum logic [3:0] {
    //     S_IDLE        ,
    //     S_READ_WEIGHT ,
    //     S_WRITE_WEIGHT,
    //     S_READ_IFMAP  ,
    //     S_WRITE_IFMAP ,
    //     S_READ_BIAS   ,
    //     S_WRITE_BIAS  ,
    //     S_WAIT_OPSUM  ,
    //     S_WRITE_OPSUM ,
    //     S_PASS_DONE   
    // } state_t;
endmodule
