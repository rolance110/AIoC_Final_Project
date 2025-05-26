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
    input  logic [7:0]   layer_id_i,
    input  logic [1:0]   layer_type_i,     // 0=PW,1=DW,2=STD,3=LIN
    input  logic [9:0]   in_R_i, in_C_i,   // input H,W
    input  logic [9:0]   in_D_i, out_K_i,  // input/out channels
    input  logic [3:0]   stride_i,         // stride
    input  logic [3:0]   pad_T_i, pad_B_i, pad_L_i, pad_R_i,

    input  logic [31:0]  base_ifmap_i,
    input  logic [31:0]  base_weight_i,
    input  logic [31:0]  base_bias_i,
    input  logic [31:0]  base_ofmap_i,

    input  logic [3:0]   flags_i,         // bit0=relu, 1=linear, 2=skip,3=bias
    input  logic [7:0]   quant_scale_i,   // per-layer scale

//* Layer Descriptor (uLD) Buffered outputs
    output logic [7:0]   layer_id_o,
    output logic [1:0]   layer_type_o,
    output logic [9:0]   in_padded_R_o, in_padded_C_o,
    output logic [9:0]   in_D_o, out_K_o,
    output logic [3:0]   stride_o,
    output logic [3:0]   pad_H_o, pad_B_o, pad_L_o, pad_R_o,
    output logic [31:0]  base_ifmap_o,
    output logic [31:0]  base_weight_o,
    output logic [31:0]  base_bias_o,
    output logic [31:0]  base_ofmap_o,
    output logic [3:0]   flags_o,
    output logic [7:0]   quant_scale_o,

//* tile lengths
    output logic [9:0]   tile_R_o,
    output logic [9:0]   tile_D_o,
    output logic [9:0]   tile_K_o,
    output logic [9:0]   out_tile_R_o,

//* num tiles
    output logic [9:0]   num_tiles_R_o,
    output logic [9:0]   num_tiles_D_o,
    output logic [9:0]   num_tiles_K_o,

//* ofmap size
    output logic [9:0]   out_R_o,
    output logic [9:0]   out_C_o 
);

//* Helper: ceil
function automatic int ceil_div(int a, int b);
    return (a + b - 1) / b;
endfunction

logic [9:0] padded_R, padded_C;
logic [9:0] kH, kW;
logic [9:0] tile_R_max, tile_R_dw;
logic [9:0] out_R, out_C;
logic [9:0] tile_D, tile_K;


//* Kernel size (kH, kW)
always_comb begin
    unique case (layer_type_i)
        2'd0: begin kH = 1; kW = 1; end // Pointwise
        2'd1: begin kH = 3; kW = 3; end // Depthwise (可讀自 uLD if 多種尺寸)
        default: begin kH = 3; kW = 3; end
    endcase
end

//* tile_D, tile_K
always_comb begin
    unique case (layer_type_i)
      2'd0: begin tile_D = 32; tile_K = 32; end  // Pointwise
      2'd1: begin tile_D = 1;  tile_K = 10; end  // Depthwise
      default: begin tile_D = 32; tile_K = 32; end
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
    .calc_tile_R_max(tile_R_max)
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
        layer_id_o      <= '0;
        layer_type_o    <= '0;
        in_padded_R_o   <= '0; 
        in_padded_C_o   <= '0;
        in_D_o          <= '0; 
        out_K_o         <= '0;

        stride_o        <= '0;
        pad_H_o         <= '0; 
        pad_B_o         <= '0;
        pad_L_o         <= '0; 
        pad_R_o         <= '0;
        
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
        
        out_R_o         <= '0;
        out_C_o         <= '0;
    end 
    else if(uLD_en_i) begin
        layer_id_o      <= layer_id_i;
        layer_type_o    <= layer_type_i;
        in_padded_R_o   <= padded_R;   
        in_padded_C_o   <= padded_C;   
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

module calc_tile_R_max#(
    parameter int GLB_BYTES  = 64 * 1024,
    parameter int BYTES_A      = 1,
    parameter int BYTES_W      = 1,
    parameter int BYTES_P      = 2
)(
    /* --------  Inputs  -------- */
    input logic [31:0] kernel_size,
    input logic [31:0] stride, 
    input logic [31:0] padded_C,   
    input logic [31:0] tile_D,     
    input logic [31:0] tile_K,    
    input logic [31:0] out_C,       
    output logic [31:0] calc_tile_R_max 
);

    /* --------  Locals  -------- */
    logic [31:0] SRAM_CAP;            
    logic [31:0] A, B, D, C;        
    logic [31:0] numerator;        
    logic [31:0] denominator;     


    /* 64 KiB SRAM 容量（單位須與其他變數一致） */
    assign SRAM_CAP = GLB_BYTES;

    /* A = padded_C * tile_D                              */
    assign A = padded_C * tile_D;

    /* D = 2 * tile_K * out_C                             */
    assign D = 2 * tile_K * out_C;

    /* B = tile_D * tile_K * kernel_size^2 + tile_K       */
    assign B = tile_D * tile_K * kernel_size * kernel_size
        + tile_K;

    /* C = B + D - (D * kernel_size) / stride             */
    assign C = B + D - (D * kernel_size) / stride;

    /* tile_R_max = (SRAM_CAP - C) / (A + D / stride)     */
    assign numerator   = SRAM_CAP - C;
    assign denominator = A + D / stride;

    /*  整數除法自動截尾 (floor)                           */
    assign calc_tile_R_max = numerator / denominator;
    
endmodule
