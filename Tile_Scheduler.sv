//------------------------------------------------------------------------------
// tile_scheduler.sv
//------------------------------------------------------------------------------
// Tile Scheduler: 控制 DMA 傳輸與 Pass 啟動
// 三層迴圈依序為 K → R → D，D 方向完成後寫回 ofmap。
//------------------------------------------------------------------------------

`include "../include/define.svh"

module Tile_Scheduler #(
    parameter int BYTES_I = `BYTES_I,    // activation bytes
    parameter int BYTES_W = `BYTES_W,    // weight bytes
    parameter int BYTES_P = `BYTES_P     // psum/ofmap bytes
) (
    input  logic          clk,
    input  logic          rst_n,

    //=== Layer Descriptor ===
    input  logic          uLD_en_i,         // Descriptor valid

    input  logic [1:0] kH_i, kW_i, // kernel height, width

    input  logic [31:0]   tile_n_i,         // todo
    input  logic [31:0]   tile_D_i,         // input channels per tile
    input  logic [31:0]   tile_K_i,         // output channels per tile
    input  logic [31:0]   tile_D_f_i,       // input channels per tile (filter)
    input  logic [31:0]   tile_K_f_i,       // output channels per tile (filter)

    input  logic [1:0]    layer_type_i,     // 0=PW, 1=DW, 2=STD, 3=LIN
    input  logic [1:0]    stride_i,         // stride
    input  logic [1:0]    pad_T_i, pad_B_i, // padding
    input  logic [1:0]    pad_L_i, pad_R_i, // padding

    input  logic [6:0]    in_R_i,           // ifmap/ofmap height
    input  logic [9:0]    in_C_i,           // ifmap/ofmap width
    input  logic [9:0]    in_D_i,           // input channel total
    input  logic [9:0]    out_K_i,         // ifmap/ofmap height
    input  logic [6:0]    out_R_i,          // ofmap height
    input  logic [9:0]    out_C_i,          // ofmap width
    input  logic [31:0]   base_ifmap_i,
    input  logic [31:0]   base_weight_i,
    input  logic [31:0]   base_bias_i,
    input  logic [31:0]   base_ofmap_i,
    input  logic [3:0]    flags_i,          // bit3=bias_en

    //=== DMA Interface ===
    output logic          dma_enable_o,
    output logic          dma_read_o,   // 1=read DRAM, 0=write DRAM
    output logic [31:0]   dma_addr_o,
    output logic [31:0]   dma_len_o,
    input  logic          dma_interrupt_i,

  //=== Token Engine Interface ===
    output logic          pass_start_o, // Pass start signal
    input  logic          pass_done_i,  // Pass done  signal

    output logic [31:0]   GLB_weight_base_addr_o,
    output logic [31:0]   GLB_ifmap_base_addr_o,
    output logic [31:0]   GLB_opsum_base_addr_o,
    output logic [31:0]   GLB_bias_base_addr_o, // Bias base address

    output logic [1:0]    pad_T_o, pad_B_o, pad_L_o, pad_R_o, // padding
    output logic [1:0]    stride_o,
    output logic [1:0]    layer_type_o, // 0=PW, 1=DW, 2=STD, 3=LIN
    output logic [3:0]    flags_o,       // ReLU / Linear / Residual / Bias

    output logic [6:0]    out_R_o, out_C_o, // output size

    output logic tile_reach_max_o // tile reach max
);


// Tile 3-loop index
logic [6:0] k_idx, d_idx;

assign flags_o = flags_i; // pass flags to next stage
assign layer_type_o = layer_type_i; // pass layer type to next stage
assign stride_o = stride_i; // pass stride to next stage
assign pad_T_o = pad_T_i; // pass padding to next stage
assign pad_B_o = pad_B_i; // pass padding to next stage
assign pad_L_o = pad_L_i; // pass padding to next stage
assign pad_R_o = pad_R_i; // pass padding to next stage
logic bias_en;
logic filter_en;
logic reach_last_D_tile;
logic over_last_D_tile;
logic reach_last_On_tile; // reach last output channel tile
logic reach_last_R_tile;
logic reach_last_K_tile;

logic DMA_ifmap_finish;
logic DMA_ipsum_finish;
logic DMA_filter_finish;
logic DMA_bias_finish;
logic DMA_opsum_finish;

logic [6:0] On_idx; // 計數目前正在處理第幾個 On tile
logic layer_first_tile; // 是否為第一個 tile


assign layer_first_tile = ((On_idx == 7'b1111111)||(On_idx == 7'd0)) && d_idx == 7'd0 && k_idx == 7'd0; // 第一個 tile
always_comb begin
    if (layer_first_tile || reach_last_On_tile) // 第一個 tile
        filter_en = 1'b1;
    else
        filter_en = 1'b0;
end

always_comb begin
    if(flags_i[3] && (layer_first_tile || (d_idx == 7'd0 && On_idx == 7'd0))) // bias enable
        bias_en = 1'b1;
    else
        bias_en = 1'b0;
end
logic ipsum_en;

always_comb begin
    if(d_idx != 7'd0 && (layer_type_i != `DEPTHWISE)) // input enable
        ipsum_en = 1'b1;
    else
        ipsum_en = 1'b0;
end

// FSM states
typedef enum logic [3:0] {
    IDLE,
    uLD_LOAD,
    TILE_IDX_GEN,
    GEN_ADDR_filter,
    DMA_filter,
    GEN_ADDR_ifmap, 
    DMA_ifmap,
    GEN_ADDR_ipsum,
    DMA_ipsum,
    GEN_ADDR_bias,
    DMA_bias,
    PASS_START,
    PASS_FINISH,
    GEN_ADDR_opsum,
    DMA_opsum
} state_e;
state_e cs_ts, ns_ts;

assign DMA_filter_finish = 1'b1; //fixme
assign DMA_ifmap_finish = 1'b1; //fixme
assign DMA_ipsum_finish = 1'b1; //fixme
assign DMA_bias_finish = 1'b1; //fixme
assign DMA_opsum_finish = 1'b1; //fixme

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cs_ts <= IDLE;
    else
        cs_ts <= ns_ts;
end
assign tile_reach_max_o = reach_last_On_tile && reach_last_D_tile && reach_last_K_tile; // 是否已經處理完所有 tile

always_comb begin
    case (cs_ts)
        IDLE: begin
            if (uLD_en_i) // read layer descriptor
                ns_ts = uLD_LOAD;
            else
                ns_ts = IDLE;
        end
        uLD_LOAD:
            ns_ts = TILE_IDX_GEN;
        TILE_IDX_GEN:begin
            if (tile_reach_max_o)
                ns_ts = IDLE; // no tiles to process
            else if(filter_en) // first tile
                ns_ts = GEN_ADDR_filter;
            else
                ns_ts = GEN_ADDR_ifmap;
        end
        GEN_ADDR_filter:begin
            ns_ts = DMA_filter;
        end
        DMA_filter:begin // filter 1 次 DMA 就能搬運完
            if (DMA_filter_finish && dma_interrupt_i)
                ns_ts = GEN_ADDR_ifmap;
            else
                ns_ts = DMA_filter;
        end
        GEN_ADDR_ifmap:begin
            ns_ts = DMA_ifmap;
        end
        DMA_ifmap:begin
            if (DMA_ifmap_finish && dma_interrupt_i)begin
                if(ipsum_en) // need read ipsum
                    ns_ts = GEN_ADDR_ipsum;
                else if(bias_en) // don't need read ipsum, need read bias
                    ns_ts = GEN_ADDR_bias;
                else
                    ns_ts = PASS_START; // 如果不需要讀取 input feature map 或 bias，直接開始 Pass
            end
            else if (dma_interrupt_i)
                ns_ts = GEN_ADDR_ifmap;
            else
                ns_ts = DMA_ifmap;
        end
        GEN_ADDR_ipsum:begin
            ns_ts = DMA_ipsum;
        end
        DMA_ipsum:begin
            if (DMA_ipsum_finish && dma_interrupt_i)
                if(bias_en) // need read bias
                    ns_ts = GEN_ADDR_bias;
                else
                    ns_ts = PASS_START; // 如果不需要讀取 bias，直接開始 Pass
            else if (dma_interrupt_i)
                ns_ts = GEN_ADDR_ipsum;
            else
                ns_ts = DMA_ipsum;
        end
        GEN_ADDR_bias:begin
            ns_ts = DMA_bias;
        end
        DMA_bias:begin
            if (DMA_bias_finish && dma_interrupt_i)
                ns_ts = PASS_START;
            else if (dma_interrupt_i)
                ns_ts = GEN_ADDR_bias;
            else
                ns_ts = DMA_bias;
        end
        PASS_START:begin
            if (pass_done_i)
                ns_ts = PASS_FINISH;
            else
                ns_ts = PASS_START;
        end
        PASS_FINISH:begin
            ns_ts =  GEN_ADDR_opsum;
        end
        GEN_ADDR_opsum:begin
            ns_ts = DMA_opsum;
        end
        DMA_opsum:begin
            if (DMA_opsum_finish && dma_interrupt_i)
                ns_ts = TILE_IDX_GEN;
            else if (dma_interrupt_i)
                ns_ts = GEN_ADDR_opsum;
            else
                ns_ts = DMA_opsum;
        end
        default:begin
            ns_ts = IDLE;
        end
    endcase
end

always_comb begin
    if(cs_ts == PASS_START)
        pass_start_o = 1'b1; // Pass start signal
    else
        pass_start_o = 1'b0; // Pass not started
end

logic [6:0] tile_On;

logic [31:0] completed_On_cnt;
logic [6:0] completed_OC_cnt;
logic [6:0] completed_IC_cnt;



logic [31:0] max_On_cnt;
//* max_On_cnt: 目前 tile 最多能輸出的 On 數量
always_comb begin
    if(layer_type_i == `POINTWISE)
        max_On_cnt = out_C_i * out_R_i; // Full Output Image Pixel
    else if (layer_type_i == `DEPTHWISE)
        max_On_cnt = out_R_i; // Depthwise: 每個 tile 處理單一 input channel
    else if (layer_type_i == `STANDARD)
        max_On_cnt = out_R_i; // Standard: 每個 tile 處理所有 output channel 和 input channel
    else
        max_On_cnt = out_C_i * out_R_i; // Linear: Full Output Image Pixel
end



logic [6:0] On_real; 
logic [6:0] IC_real;
logic [6:0] OC_real;
//* On_real: 目前 tile 實際總共要輸出 On_real 個 On (GLB => DRAM)
//* IC_real: 目前 tile 實際總共要輸入 IC_real 個 input channel (DRAM => GLB)
//* OC_real: 目前 tile 實際總共要輸入 OC_real 個 output channel pixel (DRAM <=> GLB)
logic [31:0] remain_On;
assign remain_On = max_On_cnt - completed_On_cnt; // 剩餘的 output pixel 數量
logic [6:0] remain_IC;
assign remain_IC = in_D_i - completed_IC_cnt; // 剩餘的 input channel 數量
logic [6:0] remain_OC;
assign remain_OC = out_K_i - completed_OC_cnt; // 剩餘的 output channel 數量

always_comb begin
    if(remain_On < tile_n_i)
        On_real = remain_On; // 實際輸出的 opsum pixel 數量
    else
        On_real = tile_n_i; // 最多輸出 32 個 opsum pixel
end

//todo: 要使用 tile_D_f_i 判斷
always_comb begin
    if(remain_IC < tile_D_i)
        IC_real = remain_IC; // 實際輸入的 input channel 數量
    
    else
        IC_real = tile_D_i; // 最多輸入 32 個 input channel
end

always_comb begin
    if(remain_OC < tile_K_i)
        OC_real = remain_OC; // 實際輸出的 output channel 數量
    else
        OC_real = tile_K_i; // 最多輸出 32 個 output channel
end


//reach_last_On_tile: 是否正在處理 最後一個 On tile
always_comb  begin
    if ((cs_ts == TILE_IDX_GEN) && (remain_On == 7'd0))
        reach_last_On_tile = 1'b1; // reach last output channel tile
    else
        reach_last_On_tile = 1'b0;
end
//reach_last_D_tile: 是否正在處理 最後一個 D tile
always_comb begin
    if ((cs_ts == TILE_IDX_GEN) && (remain_IC == 7'd0))
        reach_last_D_tile = 1'b1; // reach last input channel tile
    else
        reach_last_D_tile = 1'b0;
end
//reach_last_K_tile: 是否正在處理 最後一個 K tile
always_comb begin
    if ((cs_ts == TILE_IDX_GEN) && (remain_OC == 7'd0))
        reach_last_K_tile = 1'b1; // reach last output channel tile
    else
        reach_last_K_tile = 1'b0; 
end


//todo: idx: 計數目前正在計算第幾個 tile 
//todo: completed_On_cnt: 計數 目前這張圖輸出的 opsum pixel 數量
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        completed_On_cnt <= 7'd0;
        On_idx <= 7'b1111111;
    end
    else if (cs_ts == uLD_LOAD)begin
        completed_On_cnt <= 7'd0;
        On_idx <= 7'b1111111; // 歸 0
    end
    else if (reach_last_On_tile && cs_ts == TILE_IDX_GEN)begin
        completed_On_cnt <= 7'd0; // 
        On_idx <= 7'b0; // 歸 0
    end
    else if (cs_ts == TILE_IDX_GEN)begin
        completed_On_cnt <= completed_On_cnt + On_real;
        On_idx <= On_idx + 7'd1; // 處理下一個 On tile
    end
end
//* completed_IC_cnt: 計數目前已完成的 input channel 數量
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        completed_IC_cnt <= 7'd0;
        d_idx <= 7'd0; // 歸 0
    end
    else if (cs_ts == uLD_LOAD)begin //depthwise 不考慮 input channel
        completed_IC_cnt <= layer_type_i==`DEPTHWISE? in_D_i: 7'd0; 
        d_idx <= 7'd0; // 歸 0
    end
    else if (reach_last_D_tile && reach_last_On_tile && cs_ts == TILE_IDX_GEN)begin
        completed_IC_cnt <= layer_type_i==`DEPTHWISE? in_D_i: 7'd0; 
        d_idx <= 7'd0; // 歸 0
    end
    else if (reach_last_On_tile && cs_ts == TILE_IDX_GEN)begin
        completed_IC_cnt <= completed_IC_cnt + IC_real;
        d_idx <= d_idx + 7'd1; // 處理下一個 D tile
    end
end

//* completed_OC_cnt: 計數目前已完成的 output channel 數量
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        completed_OC_cnt <= 7'd0;
        k_idx <= 7'd0; // 歸 0
    end
    else if (cs_ts == uLD_LOAD)begin
        completed_OC_cnt <= 7'd0;
        k_idx <= 7'd0; // 歸 0
    end
    else if (reach_last_K_tile && reach_last_D_tile && reach_last_On_tile && cs_ts == TILE_IDX_GEN)begin
        completed_OC_cnt <= 7'd0; // 歸 0
        k_idx <= 7'd0; // 歸 0
    end
    else if (reach_last_On_tile && reach_last_D_tile && cs_ts == TILE_IDX_GEN)begin
        completed_OC_cnt <= completed_OC_cnt + OC_real;
        k_idx <= k_idx + 7'd1; // 處理下一個 K tile
    end
end




//============= GLB Base Address =============

logic [31:0] in_pixel_num, out_pixel_num;
always_comb begin
    if (layer_type_i == `POINTWISE || layer_type_i == `LINEAR) begin
        in_pixel_num = tile_n_i; // Input pixel size in bytes
        out_pixel_num = tile_n_i; // Output pixel size in bytes
    end 
    else begin
        in_pixel_num = tile_n_i * in_C_i ; // Input pixel size in bytes for depthwise
        out_pixel_num = (tile_n_i-2) * out_C_i; // Output pixel size in bytes for depthwise
    end
end

logic [31:0] weight_size, ifmap_size, opsum_size;
assign weight_size = tile_D_f_i * tile_K_f_i * kH_i * kW_i * BYTES_W; // Weight size in bytes
assign ifmap_size = tile_D_i * in_pixel_num * BYTES_I; // Ifmap size in bytes
assign opsum_size = tile_K_i * out_pixel_num * BYTES_P; // Opsum size in bytes
always_comb begin
    GLB_weight_base_addr_o = 32'd0;
    GLB_ifmap_base_addr_o = weight_size;
    GLB_opsum_base_addr_o = weight_size + ifmap_size;
    GLB_bias_base_addr_o = weight_size + ifmap_size + opsum_size; // Bias base address
end


//============= DMA =============
//dma_enable_o
always_comb begin
    case (cs_ts)
        DMA_filter, DMA_ifmap, DMA_ipsum, DMA_bias, DMA_opsum: dma_enable_o = 1'b1;
        default: dma_enable_o = 1'b0;
    endcase
end

// Gen_DMA_addr
logic [2:0]input_type; // 0=filter, 1=ifmap, 2=bias, 3=opsum ,4=ipsum
always_comb begin
    case (cs_ts)
        GEN_ADDR_filter:input_type = 3'd0;
        GEN_ADDR_ifmap :input_type = 3'd1;
        GEN_ADDR_bias  :input_type = 3'd2;
        GEN_ADDR_opsum :input_type = 3'd3;
        GEN_ADDR_ipsum :input_type = 3'd4;
    endcase
end
dma_address_generator(
    .clk(clk),
    .rst_n(rst_n),
    
    .tile_D_i(IC_real),         //!ic_real 
    .tile_K_i(OC_real),
    .tile_n_i(On_real),         //!On_real 
    .tile_D_f_i(tile_D_f_i),       // input channels per tile (filter)
    .tile_K_f_i(tile_K_f_i),       // output channels per tile (filter)

    .in_R_i(in_R_i),           // ifmap/ofmap height
    .in_C_i(in_C_i),           // ifmap/ofmap width
    .in_D_i(in_D_i),           // input channel total
    .out_K_i(out_K_i),          // ifmap/ofmap height
    .out_R_i(out_R_i),          // ofmap height
    .out_C_i(out_C_i),          // ofmap width
    .base_ifmap_i(base_ifmap_i),
    .base_weight_i(base_weight_i),
    .base_bias_i(base_bias_i),
    .base_ofmap_i(base_ofmap_i),
    .layer_type_i(layer_type_i),     // 0=PW, 1=DW, 2=STD, 3=LIN
    .input_type(input_type),       // 0=filter, 1=ifmap, 2=bias, 3=opsum
    .dma_interrupt_i(dma_interrupt_i),
    .stride_i(stride_i),
   
    .k_idx(k_idx),
    .d_idx(d_idx),
    .pass_done_i(pass_done_i),
    .dma_base_addr_o(dma_addr_o), //base address
    .dma_len_o(dma_len_o)
);
endmodule