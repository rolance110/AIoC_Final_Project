//------------------------------------------------------------------------------
// layer_decoder.sv
//------------------------------------------------------------------------------
// Decode the incoming Layer Descriptor (uLD) and produce all the
// control parameters downstream (tile sizes, num_tiles, out_dims, base_addrs…)
//------------------------------------------------------------------------------

module layer_decoder #(
  // 參數化：GLB 大小與 bitwidths，可在 compile time 調整
  parameter int GLB_BYTES = 64 * 1024,
  parameter int BIT_A      = 8,
  parameter int BIT_W      = 8,
  parameter int BIT_P      = 16
) (
  input  logic         clk,
  input  logic         rst_n,

  //==================================================================
  // Inputs: 每層 Descriptor（uLD）從 Testbench 送來
  //==================================================================
  input logic uLD_en_i, // uLD enable signal
  input  logic [7:0]   layer_id_i,
  input  logic [1:0]   layer_type_i,    // 0=PW,1=DW,2=STD,3=LIN
  input  logic [9:0]   in_R_i, in_C_i,   // input H,W
  input  logic [9:0]   in_D_i, out_K_i,  // input/out channels
  input  logic [3:0]   stride_i,        // 同向 stride
  input  logic [3:0]   pad_T_i, pad_B_i, pad_L_i, pad_R_i,

  input  logic [31:0]  base_ifmap_i,
  input  logic [31:0]  base_weight_i,
  input  logic [31:0]  base_bias_i,
  input  logic [31:0]  base_ofmap_i,

  input  logic [3:0]   flags_i,         // bit0=relu,1=linear,2=skip,3=bias
  input  logic [7:0]   quant_scale_i,   // eyeriss style per-layer scale

  //==================================================================
  // Outputs: 帶到 Tile Scheduler / Token Engine
  //==================================================================
  output logic [7:0]   layer_id_o,
  output logic [1:0]   layer_type_o,

  // 原始參數傳遞
  output logic [9:0]   in_R_o, in_C_o,
  output logic [9:0]   in_D_o, out_K_o,
  output logic [3:0]   stride_o,
  output logic [3:0]   pad_H_o, pad_B_o, pad_L_o, pad_R_o,
  output logic [31:0]  base_ifmap_o,
  output logic [31:0]  base_weight_o,
  output logic [31:0]  base_bias_o,
  output logic [31:0]  base_ofmap_o,
  output logic [3:0]   flags_o,
  output logic [7:0]   quant_scale_o,

  // 計算後的 tile 參數
  output logic [9:0]   tile_R_o,
  output logic [9:0]   tile_D_o,
  output logic [9:0]   tile_K_o,
  output logic [9:0]   out_tile_R_o,

  // 切塊數
  output logic [9:0]   num_tiles_R_o,
  output logic [9:0]   num_tiles_D_o,
  output logic [9:0]   num_tiles_K_o,

  // ofmap 空間維度
  output logic [9:0]   out_R_o,
  output logic [9:0]   out_C_o
);

  //--------------------------------------------------------------------------
  // Helper: 天花板除法 (ceil)
  //--------------------------------------------------------------------------
  function automatic int ceil_div(int a, int b);
    return (a + b - 1) / b;
  endfunction

  //--------------------------------------------------------------------------
  // 內部信號
  //--------------------------------------------------------------------------
  logic [9:0] padded_R, padded_C;
  logic [9:0] kH, kW;
  logic [9:0] tile_R_max, tile_R_dw;
  logic [9:0] out_R, out_C;
  logic [9:0] tile_D, tile_K;

  //--------------------------------------------------------------------------
  // Combinational: 決定 kernel size, tile_D, tile_K based on layer_type
  //--------------------------------------------------------------------------
always_comb begin
  // kernel 大小
  unique case (layer_type_i)
    2'd0: begin kH = 1; kW = 1; end // Pointwise
    2'd1: begin kH = 3; kW = 3; end // Depthwise (可讀自 uLD if 多種尺寸)
    2'd2,
    2'd3: begin kH = 3; kW = 3; end // Standard / Linear 假設 3x3
    default: begin kH = 1; kW = 1; end
  endcase
  // tile_D, tile_K
  unique case (layer_type_i)
    2'd0: begin tile_D = 32; tile_K = 32; end  // Pointwise
    2'd1: begin tile_D = 1;  tile_K = 10; end  // Depthwise
    2'd2: begin tile_D = 32; tile_K = 32; end  // Standard
    2'd3: begin tile_D = 32; tile_K = 32; end  // Linear
    default: begin tile_D = 32; tile_K = 32; end
  endcase
end

  //--------------------------------------------------------------------------
  // Decode + Pipeline registers
  //--------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // 清 default
      layer_id_o      <= '0;
      layer_type_o    <= '0;
      in_R_o          <= '0; in_C_o      <= '0;
      in_D_o          <= '0; out_K_o     <= '0;
      stride_o        <= '0;
      pad_H_o         <= '0; pad_B_o     <= '0;
      pad_L_o         <= '0; pad_R_o     <= '0;
      base_ifmap_o    <= '0;
      base_weight_o   <= '0;
      base_bias_o     <= '0;
      base_ofmap_o    <= '0;
      flags_o         <= '0;
      quant_scale_o   <= '0;
      tile_R_o        <= '0;
      tile_D_o        <= '0;
      tile_K_o        <= '0;
      out_tile_R_o    <= '0;
      num_tiles_R_o   <= '0;
      num_tiles_D_o   <= '0;
      num_tiles_K_o   <= '0;
      out_R_o         <= '0;
      out_C_o         <= '0;
    end 
    else if(uLD_en_i) begin
      // 一次性寄存所有 input fields
      layer_id_o      <= layer_id_i;
      layer_type_o    <= layer_type_i;
      in_R_o          <= in_R_i;   in_C_o   <= in_C_i;
      in_D_o          <= in_D_i;   out_K_o  <= out_K_i;
      stride_o        <= stride_i;
      pad_H_o         <= pad_T_i;  pad_B_o <= pad_B_i;
      pad_L_o         <= pad_L_i;  pad_R_o <= pad_R_i;
      base_ifmap_o    <= base_ifmap_i;
      base_weight_o   <= base_weight_i;
      base_bias_o     <= base_bias_i;
      base_ofmap_o    <= base_ofmap_i;
      flags_o         <= flags_i;
      quant_scale_o   <= quant_scale_i;

      // 1. 計算 padded_R/C
      padded_R        <= in_R_i + pad_T_i + pad_B_i;
      padded_C        <= in_C_i + pad_L_i + pad_R_i;

      // 2. 計算 ofmap 維度 out_R, out_C
      out_R           <= ceil_div(padded_R - kH, stride_i) + 1;
      out_C           <= ceil_div(padded_C - kW, stride_i) + 1;

      // 3. 計算 num_tiles_{R,D,K}
      num_tiles_R_o   <= ceil_div(padded_R, tile_R_o); // tile_R_o 需先算出
      num_tiles_D_o   <= ceil_div(in_D_i, tile_D);
      num_tiles_K_o   <= ceil_div(out_K_i, tile_K);




      // 4. 計算 tile_R
      unique case (layer_type_i)
        2'd0: begin
          // Pointwise: 直接用 GLB capacity 推得
          // TODO: 在此插入 tile_R_max = floor( (GLB-B_weight)/(per_r) )
          tile_R_o <= /* tile_R_max from formula */;
        end
        2'd1: begin
          // Depthwise: 先 brute-force 找 tile_R_max，再 stride 對齊
          // TODO: 插入 brute-force & 修正邏輯
          tile_R_o <= /* aligned_tile_R */;
        end
        default: begin
          tile_R_o <= /* 可設為 in_R_o */ ;
        end
      endcase

      // 5. 計算 out_tile_R = ceil((tile_R - kH)/stride) + 1
      out_tile_R_o <= ceil_div(tile_R_o - kH, stride_i) + 1;
    end
  end

/* Calculate out_R, out_C */


/* tile_D */
/* tile_K */

/* Calculate tile_R_max */
/* Calculate tile_R */



/* Calculate num_tile_R */
num_tiles_R_o <= ceil_div(padded_R, tile_R);

/* Calculate num_tile_D */
num_tiles_D_o <= ceil_div(in_D_i, tile_D);

/* Calculate num_tile_K */
num_tiles_K_o <= ceil_div(out_K_i, tile_K);


function automatic int ceil_div(int a, int b);
  return (a + b - 1) / b;
endfunction

endmodule
