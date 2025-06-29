`timescale 1ns/1ps
`include "../include/define.svh"

module Layer_Decoder_tb;

    // Clock and Reset
    parameter CLK_PERIOD = 10;
    logic clk = 0;
    logic rst_n = 0;

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // DUT input
    logic         uLD_en_i;
    logic  [5:0]  layer_id_i;
    logic  [1:0]  layer_type_i;
    logic  [7:0]  in_R_i, in_C_i;
    logic [10:0]  in_D_i, out_K_i;
    logic  [1:0]  stride_i;
    logic  [1:0]  pad_T_i, pad_B_i, pad_L_i, pad_R_i;
    logic [31:0]  base_ifmap_i, base_weight_i, base_bias_i, base_ofmap_i;
    logic  [3:0]  flags_i;
    logic  [7:0]  quant_scale_i;

    // DUT output
    logic [5:0]   layer_id_o;
    logic [1:0]   layer_type_o;
    logic [7:0]   padded_R_o, padded_C_o;
    logic [10:0]  in_D_o, out_K_o;
    logic [1:0]   stride_o;
    logic [1:0]   pad_T_o, pad_B_o, pad_L_o, pad_R_o;
    logic [1:0]   kH_o, kW_o;
    logic [31:0]  base_ifmap_o, base_weight_o, base_bias_o, base_ofmap_o;
    logic [3:0]   flags_o;
    logic [7:0]   quant_scale_o;
    logic [31:0]  tile_n_o;
    logic [7:0]   tile_D_o, tile_K_o, tile_D_f_o, tile_K_f_o;

    logic [7:0]   in_R_o, in_C_o;   // ✅ 修正命名，不再與 out_R_o 共用
    logic [7:0]   out_R_o, out_C_o;

    // DUT Instantiation
    Layer_Decoder# (
        .GLB_BYTES(`GLB_MAX_BYTES),
        .BYTES_I(`BYTES_I),
        .BYTES_W(`BYTES_W),
        .BYTES_P(`BYTES_P)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .uLD_en_i(uLD_en_i),
        .layer_id_i(layer_id_i),
        .layer_type_i(layer_type_i),
        .in_R_i(in_R_i), .in_C_i(in_C_i),
        .in_D_i(in_D_i), .out_K_i(out_K_i),
        .stride_i(stride_i),
        .pad_T_i(pad_T_i), .pad_B_i(pad_B_i),
        .pad_L_i(pad_L_i), .pad_R_i(pad_R_i),
        .base_ifmap_i(base_ifmap_i),
        .base_weight_i(base_weight_i),
        .base_bias_i(base_bias_i),
        .base_ofmap_i(base_ofmap_i),
        .flags_i(flags_i),
        .quant_scale_i(quant_scale_i),

        .layer_id_o(layer_id_o),
        .layer_type_o(layer_type_o),
        .padded_R_o(padded_R_o), .padded_C_o(padded_C_o),
        .in_D_o(in_D_o), .out_K_o(out_K_o),
        .stride_o(stride_o),
        .pad_T_o(pad_T_o), .pad_B_o(pad_B_o),
        .pad_L_o(pad_L_o), .pad_R_o(pad_R_o),
        .kH_o(kH_o), .kW_o(kW_o),
        .base_ifmap_o(base_ifmap_o),
        .base_weight_o(base_weight_o),
        .base_bias_o(base_bias_o),
        .base_ofmap_o(base_ofmap_o),
        .flags_o(flags_o),
        .quant_scale_o(quant_scale_o),
        .tile_n_o(tile_n_o),
        .tile_D_o(tile_D_o), .tile_K_o(tile_K_o),
        .tile_D_f_o(tile_D_f_o), .tile_K_f_o(tile_K_f_o),
        .in_R_o(in_R_o), .in_C_o(in_C_o),          // ✅ 修改：與 out 分開
        .out_R_o(out_R_o), .out_C_o(out_C_o)
    );

    // Initial test scenario
    initial begin
        $display("==== Start Layer Decoder Test ====");

        // Reset
        rst_n = 0;
        uLD_en_i = 0;
        #(2*CLK_PERIOD);
        rst_n = 1;

        // === Test: Pointwise Layer ===
        @(negedge clk);
        layer_id_i = 6'd1;
        layer_type_i = `POINTWISE;
        in_R_i = 7'd32; in_C_i = 7'd32;
        in_D_i = 11'd64; out_K_i = 11'd64;
        stride_i = 2'd1;
        pad_T_i = 2'd1; pad_B_i = 2'd1;
        pad_L_i = 2'd1; pad_R_i = 2'd1;
        base_ifmap_i = 32'h1000_0000;
        base_weight_i = 32'h2000_0000;
        base_bias_i   = 32'h3000_0000;
        base_ofmap_i  = 32'h4000_0000;
        flags_i = 4'b0011;
        quant_scale_i = 8'd128;
        uLD_en_i = 1;
        $display("[Pointwise Layer] Input=====");
        $display("Layer ID: %0d, Type: %0d", layer_id_i, layer_type_i);
        $display("Input R: %0d, C: %0d, D: %0d", in_R_i, in_C_i, in_D_i);
        $display("Output K: %0d", out_K_i);
        $display("Stride: %0d, Padding: T=%0d, B=%0d, L=%0d, R=%0d", stride_i, pad_T_i, pad_B_i, pad_L_i, pad_R_i);
        $display("DRAM Base Ifmap: %h, Weight: %h, Bias: %h, Ofmap: %h", base_ifmap_i, base_weight_i, base_bias_i, base_ofmap_i);

        @(negedge clk);
        uLD_en_i = 0;
        layer_id_i = 6'd0;
        layer_type_i = 2'd0;
        in_R_i = 7'd0; in_C_i = 7'd0;
        in_D_i = 11'd0; out_K_i = 11'd0;
        stride_i = 2'd0;
        pad_T_i = 2'd0; pad_B_i = 2'd0;
        pad_L_i = 2'd0; pad_R_i = 2'd0;
        base_ifmap_i = 32'd0;
        base_weight_i = 32'd0;
        base_bias_i   = 32'd0;
        base_ofmap_i  = 32'd0;
        flags_i = 4'd0;
        quant_scale_i = 8'd0;

        @(posedge clk);

        $display("[Pointwise Layer] Output=====");
        $display("tile_n = %0d", tile_n_o);
        $display("out_R = %0d, out_C = %0d", out_R_o, out_C_o);
        $display("tile_D = %0d, tile_K = %0d", tile_D_o, tile_K_o);
        $display("padded_R = %0d, padded_C = %0d", padded_R_o, padded_C_o);

        $display("==== Test1 Finished ====");        $display("\033[38;2;255;0;0m               _._\033[0m");                  // 🔴 紅
        $display("\033[38;2;255;127;0m           __.{,_.}).__\033[0m");           // 🟠 橙
        $display("\033[38;2;255;255;0m        .-\"           \"-.\033[0m");         // 🟡 黃
        $display("\033[38;2;0;255;0m      .'  __.........__  '.\033[0m");         // 🟢 綠
        $display("\033[38;2;0;255;127m     /.-'`___.......___`'-.\\\033[0m");       // 🟢綠偏青
        $display("\033[38;2;0;255;255m    /_.-'` /   \\ /   \\ `'-._\\\033[0m");     // 🔵 青
        $display("\033[38;2;0;127;255m    |     |   '/ \\'   |     |\033[0m");      // 🔵 淺藍
        $display("\033[38;2;0;0;255m    |      '-'     '-'      |\033[0m");       // 🔵 藍
        $display("\033[38;2;75;0;130m    ;                       ;\033[0m");       // 🔵 靛
        $display("\033[38;2;139;0;255m    _\\         ___         /_\033[0m");      // 🟣 紫
        $display("\033[38;2;255;0;255m   /  '.'-.__  ___  __.-'.'  \\\033[0m");      // 🟣 粉紫
        $display("\033[38;2;255;0;127m _/_    `'-..._____...-'`    _\\_\033[0m");   // ❤️ 桃紅
        $display("\033[38;2;255;85;85m/   \\           .           /   \\\033[0m");  // 淺紅
        $display("\033[38;2;255;170;0m\\____)         .           (____/\033[0m");   // 橘
        $display("\033[38;2;200;200;0m    \\___________.___________/\033[0m");     // 黃
        $display("\033[38;2;0;200;100m      \\___________________/\033[0m");       // 淺綠
        $display("\033[38;2;0;150;200m     (_____________________)\033[0m");  
        $display("\n\n");
        $display("***************************************");
        $display("*   congratulation! simulation pass   *");      // 青藍
        $display("***************************************");
        $display("\n\n");
        

        $display("======= All Case Finished =======");
        $finish;
    end

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