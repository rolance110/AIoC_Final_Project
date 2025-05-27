//------------------------------------------------------------------------------
// layer_decoder.sv
//------------------------------------------------------------------------------
// Decode the incoming Layer Descriptor (uLD) and produce all the
// control parameters downstream (tile sizes, num_tiles, out_dims, base_addrs…)
//------------------------------------------------------------------------------

module layer_decoder #(
    parameter int GLB_BYTES  = 64 * 1024,
    parameter int BYTES_A      = 1,
    parameter int BYTES_W      = 1,
    parameter int BYTES_P      = 2
) (
    input  logic         clk,
    input  logic         rst_n,

//* Layer Descriptor (uLD) inputs
    input logic uLD_en_i, // uLD enable signal
    input  logic [5:0]   layer_id_i,
    input  logic [1:0]   layer_type_i,     // 0=PW,1=DW,2=STD,3=LIN
    
    input  logic [6:0]   in_R_i, in_C_i,   // input H,W
    input  logic [10:0]   in_D_i, out_K_i,  // input/out channels
    
    input  logic [1:0]   stride_i,         // stride
    input  logic [1:0]   pad_T_i, pad_B_i, pad_L_i, pad_R_i,

    input  logic [31:0]  base_ifmap_i,
    input  logic [31:0]  base_weight_i,
    input  logic [31:0]  base_bias_i,
    input  logic [31:0]  base_ofmap_i,

    input  logic [3:0]   flags_i,         // bit0=relu, 1=linear, 2=skip,3=bias
    input  logic [7:0]   quant_scale_i,   // per-layer scale

//* Layer Descriptor (uLD) Buffered outputs
    output logic [5:0]   layer_id_o,
    output logic [1:0]   layer_type_o,
    
    output logic [6:0]   padded_R_o, padded_C_o,
    output logic [10:0]   in_D_o, out_K_o,
    
    output logic [1:0]   stride_o,
    output logic [1:0]   pad_H_o, pad_B_o, pad_L_o, pad_R_o,
    
    output logic [31:0]  base_ifmap_o,
    output logic [31:0]  base_weight_o,
    output logic [31:0]  base_bias_o,
    output logic [31:0]  base_ofmap_o,
    
    output logic [3:0]   flags_o,
    output logic [7:0]   quant_scale_o,

//* tile lengths (size not sure)
    output logic [6:0]   tile_R_o,
    output logic [6:0]   tile_D_o,
    output logic [6:0]   tile_K_o,
    output logic [6:0]   out_tile_R_o,

//* num tiles (size not sure)
    output logic [6:0]   num_tiles_R_o,
    output logic [6:0]   num_tiles_D_o,
    output logic [6:0]   num_tiles_K_o,

//* ofmap size (size not sure)
    output logic [6:0]   out_R_o,
    output logic [6:0]   out_C_o 
);

//* Helper: ceil
function automatic int ceil_div(int a, int b);
    return (a + b - 1) / b;
endfunction

logic [6:0] padded_R, padded_C;
logic [1:0] kH, kW;
logic [6:0] tile_R_max, tile_R_dw;
logic [6:0] out_R, out_C;
logic [6:0] tile_D, tile_K;


//* Kernel size (kH, kW)
always_comb begin
    unique case (layer_type_i)
        2'd0: begin kH = 2'd1; kW = 2'd1; end // Pointwise
        2'd1: begin kH = 2'd3; kW = 2'd3; end // Depthwise (可讀自 uLD if 多種尺寸)
        2'd2: begin kH = 2'd1; kW = 2'd1; end // linear (standard conv)
        default: begin kH = 2'd3; kW = 2'd3; end
    endcase
end

//* tile_D, tile_K
always_comb begin
    unique case (layer_type_i)
      2'd0: begin tile_D = 6'd32; tile_K = 6'd32; end  // Pointwise
      2'd1: begin tile_D = 6'd1;  tile_K = 6'd8; end  //todo: Depthwise Set tile_D=1
      default: begin tile_D = 6'd32; tile_K = 6'd32; end
    endcase
end


assign padded_R = in_R_i + pad_T_i + pad_B_i; // 計算 padded R
assign padded_C = in_C_i + pad_L_i + pad_R_i; // 計算 padded C

assign out_R = ceil_div(padded_R - kH, stride_i) + 1;
assign out_C = ceil_div(padded_C - kW, stride_i) + 1;

//* tile_R_max, tile_R


calc_tile_R_max #(
    .GLB_BYTES(GLB_BYTES),
    .BYTES_A(BYTES_A),
    .BYTES_W(BYTES_W),
    .BYTES_P(BYTES_P)
) calc_tile_R_max_inst (
    .kernel_size(kH), 
    .stride(stride_i), 
    .padded_C(padded_C), 
    .tile_D(tile_D), 
    .tile_K(tile_K), 
    .out_C(out_C), 
    .tile_R_max(tile_R_max)
);

assign tile_R = tile_R_max - ( ( tile_R_max - kH ) % stride_i );
assign out_tile_R     = ceil_div(tile_R - kH, stride_i) + 1;

//* num_tiles
assign num_tiles_R_o = ceil_div(padded_R, tile_R_o);
assign num_tiles_D_o = ceil_div(in_D_i, tile_D);
assign num_tiles_K_o = ceil_div(out_K_i, tile_K);


//--------------------------------------------------------------------------
// Decode + Pipeline registers
//--------------------------------------------------------------------------

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        layer_id_o      <= 6'd0;
        layer_type_o    <= 2'd0;
        padded_R_o      <= 7'd0; 
        padded_C_o      <= 7'd0;
        in_D_o          <= 11'd0; 
        out_K_o         <= 11'd0;

        stride_o        <= 2'd0;
        pad_H_o         <= 2'd0; 
        pad_B_o         <= 2'd0;
        pad_L_o         <= 2'd0; 
        pad_R_o         <= 2'd0;
        
        base_ifmap_o    <= 32'd0;
        base_weight_o   <= 32'd0;
        base_bias_o     <= 32'd0;
        base_ofmap_o    <= 32'd0;
        
        flags_o         <= 4'd0;
        
        quant_scale_o   <= 8'd0;
        
        tile_R_o        <= 7'd0;
        tile_D_o        <= 7'd0;
        tile_K_o        <= 7'd0;
        out_tile_R_o    <= 7'd0;
        
        out_R_o         <= 7'd0;
        out_C_o         <= 7'd0;
    end 
    else if(uLD_en_i) begin
        layer_id_o      <= layer_id_i;
        layer_type_o    <= layer_type_i;
        padded_R_o      <= padded_R;   
        padded_C_o      <= padded_C;   
        in_D_o          <= in_D_i;   
        out_K_o         <= out_K_i;
        
        stride_o        <= stride_i;
        pad_H_o         <= pad_T_i;  
        pad_B_o         <= pad_B_i;
        pad_L_o         <= pad_L_i;  
        pad_R_o         <= pad_R_i;
        
        base_ifmap_o    <= base_ifmap_i;
        base_weight_o   <= base_weight_i;
        base_bias_o     <= base_bias_i;
        base_ofmap_o    <= base_ofmap_i;
        
        flags_o         <= flags_i;
        
        quant_scale_o   <= quant_scale_i;
        
        tile_R_o        <= tile_R;
        tile_D_o        <= tile_D;
        tile_K_o        <= tile_K;
        out_tile_R_o    <= out_tile_R;

        out_R_o         <= out_R;
        out_C_o         <= out_C;
    end
end


endmodule


/*==========================================================*
 *  Module : calc_tile_R_max
 *  Purpose: 計算最大 tile_R，考慮各種位元組大小參數
 *==========================================================*/
module calc_tile_R_max #(
    parameter int GLB_BYTES = 64 * 1024,  // 全局 SRAM 容量 (byte)
    parameter int BYTES_A   = 1,          // Activation bytes
    parameter int BYTES_W   = 1,          // Weight bytes
    parameter int BYTES_P   = 2           // Partial-sum bytes
)(
    /* ---- Inputs ---- */
    input  logic [1:0]  kernel_size,     // 卷積核大小
    input  logic [1:0]  stride,          // 步幅
    input  logic [6:0]  padded_C,        // IFmap 寬度 (#channels)
    input  logic [6:0]  tile_D,          // IFmap 深度 tile
    input  logic [6:0]  tile_K,          // Kernel tile
    input  logic [6:0]  out_C,           // OFmap 寬度 (#channels)
    /* ---- Output ---- */
    output logic [6:0]  tile_R_max       // 計算出的最大 tile_R
);

    /* ---- 中介變數 ---- */
    logic [31:0] A, B, D, C;
    logic [31:0] numerator, denominator, result;

    // A = 活化資料大小: padded_C * tile_D * BYTES_A (bytes)
    assign A = padded_C * tile_D * BYTES_A;

    // D = 每列部分和大小: tile_K * out_C * BYTES_P (bytes)
    assign D = tile_K * out_C * BYTES_P;

    // B = 權重 + 偏差大小:
    //   權重 = tile_D*tile_K*kernel_size^2 * BYTES_W
    //   偏差 = tile_K * BYTES_P
    assign B = tile_D
             * tile_K
             * kernel_size
             * kernel_size
             * BYTES_W
             + tile_K * BYTES_P;

    // C = B + D - (D * kernel_size)/stride
    assign C = B
             + D
             - (D * kernel_size) / stride;

    // 分子、分母
    assign numerator   = GLB_BYTES - C;
    assign denominator = A + (D / stride);

    // 加入除以 0 保護；整數除法自動向下取整
    assign result = (denominator != 0)
                    ? numerator / denominator
                    : 32'd0;

    // 取低 7 bits 作為輸出
    assign tile_R_max = result[6:0];

endmodule
