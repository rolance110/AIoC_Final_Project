//------------------------------------------------------------------------------
// dma_addr_generator.sv
//------------------------------------------------------------------------------
// [R][C][D] 內存排列 → 支援 Pointwise / Depthwise
//------------------------------------------------------------------------------ 
module dma_addr_generator #(
    parameter int DATA_BYTES = 1,
    parameter int PSUM_BYTES = 2,
    parameter int IN_D        = 32  //ifmap 的總channel數
)(
    input  logic         clk,
    input  logic         rst_n,
    input  logic [1:0]   layer_type,    // 0=PW,1=DW
    input  logic [1:0]   input_type,    //!新增  ifmap=0, weight=1,bias=2 預計透過FSM的資訊提供
    input  logic [6:0]   tile_R,
    input  logic [6:0]   tile_D,
    input  logic [6:0]   tile_K,
    input  logic [6:0]   in_R,
    input  logic [6:0]   in_C,
    input  logic [6:0]   out_R,
    input  logic [6:0]   out_C,
    input  logic [31:0]  base_ifmap,
    input  logic [31:0]  base_weight,
    input  logic [31:0]  base_bias,
    input  logic [31:0]  base_ofmap,
    input  logic [6:0]   r_idx, c_idx, d_idx, k_idx,

    // Outputs to DMA controller
    output logic [31:0]  dma_base_addr,
    output logic [31:0]  dma_burst_len,
    output logic [31:0]  dma_burst_stride
);

    logic [31:0] offset,ifmap_offset,weight_offset,bias_offset;
    logic [31:0] data_length;
    logic [6:0] D_idx = d_idx/tile_D;   //TODO 改掉除法方式
    
    // 外部迴圈示意：
    // for (r_idx = 0; r_idx < num_tile_R; r_idx++) begin
    //   for (d_idx = 0; d_idx < num_tile_D; d_idx++) begin
    //     for (c_idx = 0; c_idx < in_C; c_idx++) begin
    //       計算 dma_base_addr 和 dma_burst_len (tile_D × tile_R)
    //       發送 DMA 讀取
    //     end
    //   end
    // end
    //TODO ifmap weight bias 根據tile schu FSM 資訊
    always_comb begin
        dma_base_addr    = 32'd0;
        dma_burst_len    = 32'd0;
        dma_burst_stride = 32'd0;

        unique case (layer_type)
            2'd0: begin // Pointwise
                // for( r_idx < tile_R )
                // for (d_idx < tile_D )         
                ifmap_offset = (in_R * in_C * d_idx) + (tile_R * in_C *r_idx) + (D_idx * in_R * in_C * tile_D); 
                
                //in_K 是filter的個數 目前input還沒有
                weight_offset =   k_idx * tile_D * tile_K + D_idx * tile_D *in_K;
                
                //  假設bias是一次全部放到GLB
                

                case(input_type)
                    2'd0: dma_base_addr = base_ifmap + ifmap_offset;
                    2'd1: dma_base_addr = base_weight+ weight_offset;
                    2'd2: dma_base_addr = base_bias  ;
                endcase

                case(input_type)
                    2'd0: data_length = tile_R * in_C * tile_D;
                    2'd1: data_length = tile_K * tile_D;
                    2'd2: data_length = in_K * PSUM_BYTES;
                endcase
            end

            2'd1: begin // Depthwise 
                // DRAM_ifmap_height 是 tile_R - padding      
                ifmap_offset  = d_idx * in_R * in_C + r_idx * in_C * (tile_R - padding) - DRAM_ifmap_width;
                // weight 3*3 
                weight_offset =  base_weight + k_idx * tile_D * tile_K * 9 + d_idx * tile_D *in_K * 9; 
                // bias 先假設一次全部取完
                bais_offset = in_K * PSUM_BYTES;

            end

            default: begin
                
            end
        endcase
    end
endmodule
