//------------------------------------------------------------------------------
// layer_decoder.sv
//------------------------------------------------------------------------------
// Decode the incoming Layer Descriptor (uLD) and produce all the
// control parameters downstream (tile sizes, num_tiles, out_dims, base_addrs…)
//------------------------------------------------------------------------------
`include "../include/define.svh"
module Layer_Decoder #(
    parameter int GLB_BYTES  = `GLB_MAX_BYTES, // Global SRAM capacity in bytes
    parameter int BYTES_I    = `BYTES_I, //input feature map bytes
    parameter int BYTES_W    = `BYTES_W, //weight bytes
    parameter int BYTES_P    = `BYTES_P  //partial sum bytes
) (
    input  logic         clk,
    input  logic         rst_n,

//* Layer Descriptor (uLD) inputs
    input logic uLD_en_i, // uLD enable signal
    input  logic [5:0]   layer_id_i,
    input  logic [1:0]   layer_type_i,     // 0=PW,1=DW,2=STD,3=LIN
    
    input  logic [7:0]   in_R_i, in_C_i,   // input H,W
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
    
    output logic [7:0]   padded_R_o, padded_C_o,
    output logic [10:0]   in_D_o, out_K_o,
    
    output logic [1:0]   stride_o,
    output logic [1:0]   pad_T_o, pad_B_o, pad_L_o, pad_R_o,

    output logic [1:0]   kH_o, kW_o, // kernel size    


    output logic [31:0]  base_ifmap_o,
    output logic [31:0]  base_weight_o,
    output logic [31:0]  base_bias_o,
    output logic [31:0]  base_ofmap_o,
    
    output logic [3:0]   flags_o,
    output logic [5:0]   quant_scale_o,

//* tile lengths (size not sure)
    output logic [31:0]  tile_n_o, //todo: max number of tiles
    output logic [7:0]   tile_D_o,
    output logic [7:0]   tile_K_o,
    output logic [7:0]   tile_D_f_o, // tile_D_f
    output logic [7:0]   tile_K_f_o, // tile_K_f


//* Input size (size not sure)
    output logic [7:0]   in_R_o,
    output logic [7:0]   in_C_o,
//* ofmap size (size not sure)
    output logic [7:0]   out_R_o,
    output logic [7:0]   out_C_o 
);

//* Helper: ceil
function automatic int ceil_div(int a, int b);
    return (a + b - 1) / b;
endfunction

logic [7:0] padded_R, padded_C;
logic [1:0] kH, kW;
logic [7:0] out_R, out_C;
logic [7:0] tile_D, tile_K;
logic [7:0] tile_D_f, tile_K_f;

logic [31:0] tile_n; // max number of tiles

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
        2'd0: begin tile_D = 11'd32; tile_K = 11'd32; end  // Pointwise
        2'd1: begin tile_D = 11'd10;  tile_K = 11'd10; end // Depthwise
        2'd2: begin tile_D = 11'd10; tile_K = 11'd10; end  // Standard
        default: begin tile_D = 11'd32; tile_K = 11'd32; end
    endcase
end

//* tile_D_f, tile_K_f
always_comb begin
    unique case (layer_type_i)
        2'd0: begin tile_D_f = 11'd32; tile_K_f = 11'd32; end  // Pointwise
        2'd1: begin tile_D_f = 11'd1;  tile_K_f = 11'd10; end  //* Depthwise kernel size 1x3x3
        2'd2: begin tile_D_f = 11'd10; tile_K_f = 11'd10; end  // Standard
        default: begin tile_D_f = 11'd32; tile_K_f = 11'd32; end
    endcase
end

//* M
logic [7:0] M1, M2, M3;
always_comb begin
    unique case (layer_type_i)
        `POINTWISE: begin M1 = 8'd1; M2 = 8'd0; M3 = 8'd1; end // Pointwise
        `DEPTHWISE: begin M1 = in_C_i; M2 = 8'd2; M3 = out_C; end // Depthwise
        `STANDARD: begin M1 = 8'd1; M2 = 8'd0; M3 = 8'd1; end // Standard
        default: begin M1 = 8'd1; M2 = 8'd0; M3 = 8'd1; end // Linear
    endcase
end


assign padded_R = in_R_i + pad_T_i + pad_B_i; // 計算 padded R
assign padded_C = in_C_i + pad_L_i + pad_R_i; // 計算 padded C

assign out_R = ((padded_R - kH + stride_i - 1)/stride_i ) + 1;
assign out_C =  ((padded_C - kW + stride_i - 1)/stride_i) + 1;

//* n max
calc_tile_n #(
    .GLB_BYTES(GLB_BYTES),
    .BYTES_I(BYTES_I),
    .BYTES_W(BYTES_W),
    .BYTES_P(BYTES_P)
) calc_n_max_u (
//* input
    .layer_type(layer_type_i),
    .out_C(out_C),
    .kH(kH),
    .kW(kW),   
    .tile_D(tile_D), 
    .tile_K(tile_K),
    .tile_D_f(tile_D_f),
    .tile_K_f(tile_K_f),
    .M1(M1), // Global SRAM capacity in bytes
    .M2(M2), // Global SRAM capacity in bytes
    .M3(M3), // Global SRAM capacity in bytes
//* output
    .tile_n(tile_n)
);


//--------------------------------------------------------------------------
// Decode + Pipeline registers
//--------------------------------------------------------------------------

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        layer_id_o      <= 6'd0;
        layer_type_o    <= 2'd0;
        padded_R_o      <= 8'd0; 
        padded_C_o      <= 8'd0;
        kH_o           <= 2'd0;
        kW_o           <= 2'd0;
        in_D_o          <= 11'd0; 
        out_K_o         <= 11'd0;

        stride_o        <= 2'd0;
        pad_T_o         <= 2'd0; 
        pad_B_o         <= 2'd0;
        pad_L_o         <= 2'd0; 
        pad_R_o         <= 2'd0;
        
        base_ifmap_o    <= 32'd0;
        base_weight_o   <= 32'd0;
        base_bias_o     <= 32'd0;
        base_ofmap_o    <= 32'd0;
        
        flags_o         <= 4'd0;
        
        quant_scale_o   <= 6'd0;
        
        tile_n_o         <= 32'd0;
        tile_D_o        <= 8'd0;
        tile_K_o        <= 8'd0;
        tile_D_f_o      <= 8'd0;
        tile_K_f_o      <= 8'd0;
        in_R_o          <= 8'd0;
        in_C_o          <= 8'd0;
        out_R_o         <= 8'd0;
        out_C_o         <= 8'd0;
    end 
    else if(uLD_en_i) begin
        layer_id_o      <= layer_id_i;
        layer_type_o    <= layer_type_i;
        padded_R_o      <= padded_R;   
        padded_C_o      <= padded_C;   
        kH_o           <= kH;
        kW_o           <= kW;
        in_D_o          <= in_D_i;   
        out_K_o         <= out_K_i;
        
        stride_o        <= stride_i;
        pad_T_o         <= pad_T_i;  
        pad_B_o         <= pad_B_i;
        pad_L_o         <= pad_L_i;  
        pad_R_o         <= pad_R_i;
        
        base_ifmap_o    <= base_ifmap_i;
        base_weight_o   <= base_weight_i;
        base_bias_o     <= base_bias_i;
        base_ofmap_o    <= base_ofmap_i;
        
        flags_o         <= flags_i;
        
        quant_scale_o   <= quant_scale_i;
        
        tile_n_o         <= tile_n;
        tile_D_o        <= tile_D;
        tile_K_o        <= tile_K;
        tile_D_f_o        <= tile_D_f;
        tile_K_f_o        <= tile_K_f;
        in_R_o          <= in_R_i;
        in_C_o          <= in_C_i;
        out_R_o         <= out_R;
        out_C_o         <= out_C;
    end
end


endmodule

