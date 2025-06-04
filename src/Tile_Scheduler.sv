//------------------------------------------------------------------------------
// tile_scheduler.sv
//------------------------------------------------------------------------------
// Tile Scheduler: 控制 DMA 傳輸與 Pass 啟動
// 三層迴圈依序為 K → R → D，D 方向完成後寫回 ofmap。
//------------------------------------------------------------------------------

module Tile_Scheduler #(
  parameter int BYTES_A = 1,    // activation bytes
  parameter int BYTES_W = 1,    // weight bytes
  parameter int BYTES_P = 2     // psum/ofmap bytes
) (
  input  logic          clk,
  input  logic          rst_n,

  //=== Layer Descriptor ===
  input  logic          uLD_en_i,         // Descriptor valid

  input  logic [6:0]    tile_n_i,         // todo
  input  logic [6:0]    tile_D_i,         // input channels per tile
  input  logic [6:0]    tile_K_i,         // output channels per tile

  input  logic [9:0]    in_C_i,           // ifmap/ofmap width
  input  logic [9:0]    in_D_i,           // input channel total
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
  output logic          pass_info_vld_o,
  output logic [6:0]    pass_tile_R_o,
  output logic [6:0]    pass_tile_D_o,
  output logic [6:0]    pass_tile_K_o,
  output logic [6:0]    pass_out_tile_R_o,
  output logic [6:0]    pass_k_idx_o,
  output logic [6:0]    pass_r_idx_o,
  output logic [6:0]    pass_d_idx_o,
  output logic [3:0]    pass_flags_o,
  input  logic          pass_done_i
);


// Tile 3-loop index
logic [6:0] k_idx, r_idx, d_idx;
logic bias_en;
assign bias_en = flags_i[3];
logic reach_last_D_tile;
logic over_last_D_tile;
logic reach_last_R_tile;
logic reach_last_K_tile;

// FSM states
typedef enum logic [3:0] {
    IDLE,
    uLD_LOAD,
    TILE_IDX_GEN,
    DMA_ifmap,
    DMA_weight,
    DMA_bias,
    PASS_START,
    PASS_FINISH,
    DMA_ofmap
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
            if (tile_idx_reach_max)
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


always_comb begin
    reach_last_D_tile = (cs_ts == TILE_IDX_GEN)?  (d_idx == num_tiles_D_i - 1) : 1'b0;
    over_last_D_tile =(cs_ts == TILE_IDX_GEN)? (d_idx == num_tiles_D_i) : 1'b0;
    reach_last_K_tile = (cs_ts == TILE_IDX_GEN)? (k_idx == num_tiles_K_i - 1): 1'b0;
end

// n_idx: count of input pixels
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        n_idx <= 7'd0;
    else if (cs_ts == uLD_LOAD)
        n_idx <= 7'd0; 
    else if (cs_ts == TILE_IDX_GEN) begin
        if(reach_last_n_tile)
            n_idx <= 7'd0;
        else
            n_idx <= n_idx + 7'd1;
    end
end

// d_idx
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        d_idx <= 7'd0;
    else if (cs_ts == uLD_LOAD)
        d_idx <= 7'd0; 
    else if (cs_ts == TILE_IDX_GEN) begin
        if (reach_last_D_tile && reach_last_n_tile)
            d_idx <= 7'd0;
        else if (reach_last_n_tile)
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
        if(reach_last_n_tile && reach_last_D_tile && reach_last_K_tile)
            k_idx <= 7'd0;
        else if(reach_last_n_tile && reach_last_D_tile)
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

//============= PASS =============
// pass_info_vld_o
always_comb begin
    case (cs_ts)
        PASS_START: pass_info_vld_o = 1'b1;
        PASS_FINISH: pass_info_vld_o = 1'b0;
        default: pass_info_vld_o = 1'b0;
    endcase
end


endmodule
