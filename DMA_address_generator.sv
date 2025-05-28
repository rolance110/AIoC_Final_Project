//------------------------------------------------------------------------------
// dma_addr_generator.sv
//------------------------------------------------------------------------------
// [R][C][D] 內存排列 → 支援 Pointwise / Depthwise
//------------------------------------------------------------------------------ 
module dma_addr_generator #(
    parameter int DATA_BYTES = 1,
    parameter int PSUM_BYTES = 2,
    parameter int IN_D        = 1024  // 最大 input channels
)(
    input  logic         clk,
    input  logic         rst_n,
    input  logic [1:0]   layer_type,    // 0=PW,1=DW
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

    logic [31:0] offset;

    always_comb begin
        dma_base_addr    = 32'd0;
        dma_burst_len    = 32'd0;
        dma_burst_stride = 32'd0;

        unique case (layer_type)
            2'd0: begin  // Pointwise (PW)
                // 計算 offset = 跳過前面 row 的全部資料 + 跳過前面 column * 全 channel + 跳過 d_idx 個 tile_D channel
                offset = (r_idx * tile_R * in_C )                 // 前面幾行全部資料大小
                       + (c_idx * IN_D * tile_R)                  // 前面幾列跳過的資料大小 (每列有 IN_D * tile_R bytes)
                       + (d_idx * tile_D);                         // 同一列中跳過的 channel 數量
                
                dma_base_addr    = base_ifmap + offset * DATA_BYTES;
                dma_burst_len    = tile_D * tile_R * DATA_BYTES; // 一次抓完整個 tile_R 行 × tile_D channels
                // 取完這些 channel 後，要跳過該列剩餘 channel 數量才能到下一列的相同 channel 開頭
                dma_burst_stride = (IN_D - tile_D) * tile_R * DATA_BYTES;
            end

            2'd1: begin  // Depthwise (DW)
                // DW 一次取 tile_R 行 × 1 channel（tile_D=1）
                offset = (r_idx * tile_R * in_C * IN_D)          // 跳過前面 row 的全部資料
                       + (c_idx * IN_D * tile_R)                 // 跳過前面 column 的資料
                       + d_idx;                                  // 跳過前面 channel
                
                dma_base_addr    = base_ifmap + offset * DATA_BYTES;
                dma_burst_len    = tile_R * DATA_BYTES;          // 只抓 tile_R 行 × 1 channel
                dma_burst_stride = 0;                             // 一次連續抓，不用跳躍
            end

            default: begin
                dma_base_addr    = 32'd0;
                dma_burst_len    = 32'd0;
                dma_burst_stride = 32'd0;
            end
        endcase
    end

endmodule
