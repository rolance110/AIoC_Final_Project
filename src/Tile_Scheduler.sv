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

    input  logic [31:0]   tile_n_i,         // todo
    input  logic [31:0]   tile_D_i,         // input channels per tile
    input  logic [31:0]   tile_K_i,         // output channels per tile

    input  logic [1:0]    layer_type_i,     // 0=PW, 1=DW, 2=STD, 3=LIN
    input  logic [1:0]    stride_i,         // stride
    input  logic [1:0]    pad_T_i, pad_B_i, // padding
    input  logic [1:0]    pad_L_i, pad_R_i, // padding

    input  logic [6:0]    in_R_i,           // ifmap/ofmap height
    input  logic [9:0]    in_C_i,           // ifmap/ofmap width
    input  logic [9:0]    in_D_i,           // input channel total
    input  logic [9:0]    out_K_i,         // ifmap/ofmap height
    input  logic [9:0]    out_R_i,          // ofmap height
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

    output logic [1:0]    pad_T_o, pad_B_o, pad_L_o, pad_R_o, // padding
    output logic [1:0]    stride_o,
    output logic [1:0]    layer_type_o, // 0=PW, 1=DW, 2=STD, 3=LIN
    output logic [3:0]    flags_o,       // ReLU / Linear / Residual / Bias

    output logic [6:0]    out_R_o, out_C_o // output size
);


// Tile 3-loop index
logic [6:0] k_idx, r_idx, d_idx;
logic bias_en;
assign bias_en = flags_i[3];
assign flags_o = flags_i; // pass flags to next stage
assign layer_type_o = layer_type_i; // pass layer type to next stage
assign stride_o = stride_i; // pass stride to next stage
assign pad_T_o = pad_T_i; // pass padding to next stage
assign pad_B_o = pad_B_i; // pass padding to next stage
assign pad_L_o = pad_L_i; // pass padding to next stage
assign pad_R_o = pad_R_i; // pass padding to next stage

logic reach_last_D_tile;
logic over_last_D_tile;
logic reach_last_On_tile; // reach last output channel tile
logic reach_last_R_tile;
logic reach_last_K_tile;

logic tile_reach_max;
logic DMA_ifmap_finish;
logic DMA_filter_finish;
logic DMA_bias_finish;
logic DMA_opsum_finish;

// FSM states
typedef enum logic [3:0] {
    IDLE,
    uLD_LOAD,
    TILE_IDX_GEN,
    GEN_ADDR_filter,
    DMA_filter,
    GEN_ADDR_ifmap, 
    DMA_ifmap,
    GEN_ADDR_bias,
    DMA_bias,
    PASS_START,
    PASS_FINISH,
    GEN_ADDR_opsum,
    DMA_opsum
} state_e;
state_e cs_ts, ns_ts;


always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cs_ts <= IDLE;
    else
        cs_ts <= ns_ts;
end

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
            if (tile_reach_max)
                ns_ts = IDLE; // no tiles to process
            else
                ns_ts = GEN_ADDR_filter;
        end
        GEN_ADDR_filter:begin
            ns_ts = DMA_filter;
        end
        DMA_filter:begin
            if (DMA_filter_finish && dma_interrupt_i)
                ns_ts = GEN_ADDR_ifmap;
            else
                ns_ts = DMA_filter;
        end
        GEN_ADDR_ifmap:begin
            ns_ts = DMA_ifmap;
        end
        DMA_ifmap:begin
            if (dma_interrupt_i)
                ns_ts = GEN_ADDR_ifmap;
            else if (DMA_ifmap_finish && dma_interrupt_i)
                ns_ts = GEN_ADDR_bias;
            else
                ns_ts = DMA_filter;
        end
        GEN_ADDR_bias:begin
            ns_ts = DMA_bias;
        end
        DMA_bias:begin
            if (dma_interrupt_i)
                ns_ts = GEN_ADDR_bias;
            else if (DMA_bias_finish && dma_interrupt_i)
                ns_ts = PASS_START;
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
            if (dma_interrupt_i)
                ns_ts = GEN_ADDR_opsum;
            else if (DMA_opsum_finish && dma_interrupt_i)
                ns_ts = TILE_IDX_GEN;
            else
                ns_ts = DMA_opsum;
        end
        default:begin
            ns_ts = IDLE;
        end
    endcase
end



logic [6:0] tile_On;

logic [31:0] completed_On_cnt;
logic [6:0] completed_OC_cnt;
logic [6:0] completed_IC_cnt;
//* completed_On_cnt:  計數目前已完成的 image pixel 數量
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        completed_On_cnt <= 7'd0;
    else if (cs_ts == uLD_LOAD)
        completed_On_cnt <= 7'd0;
    else if(/*算完一個 output channel tile*/)
        completed_On_cnt <= 7'd0; // 歸 0
    else if (layer_type_i == `POINTWISE/* && 算完一格 output pixel */)
        completed_On_cnt <= completed_On_cnt + 7'd1;
    else if (layer_type_i == `DEPTHWISE/* && 算完一個 output row */)
        completed_On_cnt <= completed_On_cnt + 7'd1;
end

//* completed_IC_cnt: 計數目前已完成的 input channel 數量
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        completed_IC_cnt <= 7'd0;
    else if (cs_ts == uLD_LOAD)
        completed_IC_cnt <= 7'd0;
    else if (/*算完一個 output channel tile*/)
        completed_IC_cnt <= 7'd0; // 歸 0
    else if (layer_type_i == `POINTWISE /*&& 算完一個 input channel tile*/)
        completed_IC_cnt <= completed_IC_cnt + 7'd32;
    else if (layer_type_i == `DEPTHWISE /*&& 算完一個 input channel tile*/)
        completed_IC_cnt <= completed_IC_cnt + 7'd10;
end

//* completed_OC_cnt: 計數目前已完成的 output channel 數量
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        completed_OC_cnt <= 7'd0;
    else if (cs_ts == uLD_LOAD)
        completed_OC_cnt <= 7'd0;
    else if (layer_type_i == `POINTWISE /*&& 算完一個 output channel tile*/)
        completed_OC_cnt <= completed_OC_cnt + 7'd32;
    else if (layer_type_i == `DEPTHWISE /*&& 算完一個 output channel tile*/)
        completed_OC_cnt <= completed_OC_cnt + 7'd10;
end

logic [31:0] max_On_cnt;
//* max_On_cnt: 目前 tile 最多能輸出的 On             數量
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
logic [6:0] remain_IC;
assign remain_IC = in_D_i - completed_IC_cnt; // 剩餘的 input channel 數量
logic [6:0] remain_OC;
assign remain_OC = out_K_i - completed_OC_cnt; // 剩餘的 output channel 數量

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


always_comb begin
    //fixme:reach_last_On_tile = (cs_ts == TILE_IDX_GEN)? (On_idx == tile_n_i - 1) : 1'b0;
    reach_last_D_tile = (cs_ts == TILE_IDX_GEN)?  (d_idx == ((remain_IC < tile_D_i) || (remain_IC == tile_D_i) )) : 1'b0;
    reach_last_K_tile = (cs_ts == TILE_IDX_GEN)? (k_idx == ((remain_OC < tile_K_i) || (remain_OC == tile_K_i))): 1'b0;
end

//fixme: On_idx: 計數 目前輸出的 opsum pixel 數量
always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        On_idx <= 7'd0;
    else if (cs_ts == uLD_LOAD)
        On_idx <= 7'd0;
    else if (/*算完一個 tile*/)
        On_idx <= 7'd0; // 歸 0
    else if (layer_type_i == `POINTWISE && /*算完一個 opsum*/)
        On_idx <= On_idx + 7'd1;
    else if (layer_type_i == `DEPTHWISE && /*算完 1 row opsum*/)
        On_idx <= On_idx + 7'd1;
end


// d_idx
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        d_idx <= 7'd0;
    else if (cs_ts == uLD_LOAD)
        d_idx <= 7'd0; 
    else if (cs_ts == TILE_IDX_GEN) begin
        if (reach_last_D_tile && reach_last_On_tile)
            d_idx <= 7'd0;
        else if (reach_last_On_tile)
            d_idx <= d_idx + 7'd1;
    end
end

// k_idx
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        k_idx <= 7'd0;
    else if (cs_ts == uLD_LOAD)
        k_idx <= 7'd0; 
    else if (cs_ts == TILE_IDX_GEN) begin
        if(reach_last_On_tile && reach_last_D_tile && reach_last_K_tile)
            k_idx <= 7'd0;
        else if(reach_last_On_tile && reach_last_D_tile)
            k_idx <= k_idx + 7'd1;
    end
end

//============= DMA =============
//dma_enable_o
always_comb begin
    case (cs_ts)
        DMA_filter, DMA_ifmap, DMA_bias, DMA_opsum: dma_enable_o = 1'b1;
        default: dma_enable_o = 1'b0;
    endcase
end

// Gen_DMA_addr

endmodule
