module Layer_Decoder_tb;

  // Testbench parameters
  localparam int GLB_BYTES = 64 * 1024;
  localparam int BIT_A      = 8;
  localparam int BIT_W      = 8;
  localparam int BIT_P      = 16;

  // Clock and reset signals
  logic clk;
  logic rst_n;

  // Inputs to the layer decoder
  logic uLD_en_i;
  logic [7:0] layer_id_i;
  logic [1:0] layer_type_i;
  logic [9:0] in_R_i, in_C_i, in_D_i, out_K_i;
  logic [3:0] stride_i, pad_T_i, pad_B_i, pad_L_i, pad_R_i;
  
  logic [31:0] base_ifmap_i, base_weight_i, base_bias_i, base_ofmap_i;
  
  logic [3:0] flags_i;
  logic [7:0] quant_scale_i;

  // Outputs from the layer decoder
  logic [7:0] layer_id_o;
  logic [1:0] layer_type_o;
  
  logic [9:0] in_R_o, in_C_o, in_D_o, out_K_o;
  logic [3:0] stride_o, pad_H_o, pad_B_o, pad_L_o, pad_R_o;
  
  logic [31:0] base_ifmap_o, base_weight_o, base_bias_o, base_ofmap_o;
  
  logic [3:0] flags_o;
  logic [7:0] quant_scale_o;

  // Tile parameters
  logic [9:0] tile_R_o, tile_D_o, tile_K_o, out_tile_R_o;
  
  // Number of tiles
  logic [9:0] num_tiles_R_o, num_tiles_D_o, num_tiles_K_o;

    // Instantiate the layer decoder
    layer_decoder #(
        .GLB_BYTES(GLB_BYTES),
        .BIT_A(BIT_A),
        .BIT_W(BIT_W),
        .BIT_P(BIT_P)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .uLD_en_i(uLD_en_i),
        .layer_id_i(layer_id_i),
        .layer_type_i(layer_type_i),
        .in_R_i(in_R_i),
        .in_C_i(in_C_i),
        .in_D_i(in_D_i),
        .out_K_i(out_K_i),
        .stride_i(stride_i),
        .pad_T_i(pad_T_i),
        .pad_B_i(pad_B_i),
        .pad_L_i(pad_L_i),
        .pad_R_i(pad_R_i),
        .base_ifmap_i(base_ifmap_i),
        .base_weight_i(base_weight_i),
        .base_bias_i(base_bias_i),
        .base_ofmap_i(base_ofmap_i),
        .flags_i(flags_i),
        .quant_scale_i(quant_scale_i),
        .layer_id_o(layer_id_o),
        .layer_type_o(layer_type_o),
        .in_R_o(in_R_o),
        .in_C_o(in_C_o),
        .in_D_o(in_D_o),
        .out_K_o(out_K_o),
        .stride_o(stride_o),
        .pad_H_o(pad_H_o),
        .pad_B_o(pad_B_o),
        .pad_L_o(pad_L_o),
        .pad_R_o(pad_R_o),
        .base_ifmap_o(base_ifmap_o),
        .base_weight_o(base_weight_o),
        .base_bias_o(base_bias_o),
        .base_ofmap_o(base_ofmap_o),
        .flags_o(flags_o),
        .quant_scale_o(quant_scale_o),
        .tile_R_o(tile_R_o),
        .tile_D_o(tile_D_o),
        .tile_K_o(tile_K_o),
        .out_tile_R_o(out_tile_R_o),
        .num_tiles_R_o(num_tiles_R_o),
        .num_tiles_D_o(num_tiles_D_o),
        .num_tiles_K_o(num_tiles_K_o)
    );


    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units period
    end
    // Reset generation
    initial begin
        rst_n = 0;
        #10 rst_n = 1;
    end
    // Testbench stimulus
    initial begin
        // Initialize inputs
        uLD_en_i = 0;
        layer_id_i = 8'h01;
        layer_type_i = 2'b00; // Convolution
        in_R_i = 10'd32;
        in_C_i = 10'd32;
        in_D_i = 10'd3;
        out_K_i = 10'd64;
        stride_i = 4'd1;
        pad_T_i = 4'd1;
        pad_B_i = 4'd1;
        pad_L_i = 4'd1;
        pad_R_i = 4'd1;
        
        base_ifmap_i = 32'h00000000;
        base_weight_i = 32'h00010000;
        base_bias_i = 32'h00020000;
        base_ofmap_i = 32'h00030000;

        flags_i = 4'b0001; // Example flag
        quant_scale_i = 8'h01;

        // Wait for reset
        #20;

        // Enable the layer decoder
        uLD_en_i = 1;

        // Wait for a few clock cycles to observe outputs
        #50;

        // Disable the layer decoder
        uLD_en_i = 0;

        // Finish simulation
        #20;
        $finish;
    end
    // Monitor outputs
    initial begin
        $monitor("Time: %0t, layer_id_o: %0h, layer_type_o: %0b, in_R_o: %0d, in_C_o: %0d, in_D_o: %0d, out_K_o: %0d, stride_o: %0d, pad_H_o: %0d, pad_B_o: %0d, pad_L_o: %0d, pad_R_o: %0d, base_ifmap_o: %h, base_weight_o: %h, base_bias_o: %h, base_ofmap_o: %h, flags_o: %b, quant_scale_o: %h",
                 $time,
                 layer_id_o,
                 layer_type_o,
                 in_R_o,
                 in_C_o,
                 in_D_o,
                 out_K_o,
                 stride_o,
                 pad_H_o,
                 pad_B_o,
                 pad_L_o,
                 pad_R_o,
                 base_ifmap_o,
                 base_weight_o,
                 base_bias_o,
                 base_ofmap_o,
                 flags_o,
                 quant_scale_o);
    end

// dump FSDB file
initial begin
    `ifdef FSDB
        $fsdbDumpfile("../wave/top.fsdb");
        $fsdbDumpvars(0, uut);
    `elsif FSDB_ALL
        $fsdbDumpfile("../wave/top.fsdb");
        $fsdbDumpvars("+struct", "+mda", uut);
    `endif
end
endmodule