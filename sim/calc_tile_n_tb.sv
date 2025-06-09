/*==========================================================*
 *  Testbench : tb_calc_tile_n_max
 *  Purpose   : 驗證 calc_tile_n 模組 + GLB 使用百分比
 *==========================================================*/
`include "../include/define.svh"

module calc_tile_n_max_tb;

    //---- Inputs ----
    logic [6:0] in_C, out_C;
    logic [6:0] tile_D, tile_K, tile_D_f, tile_K_f;
    logic [1:0] layer_type, kH, kW;
    logic [6:0] M1, M2, M3;

    //---- Output ----
    logic [31:0] tile_n;

    //---- DUT ----
    calc_tile_n #(
        .GLB_BYTES(`GLB_MAX_BYTES),
        .BYTES_I(`BYTES_I),
        .BYTES_W(`BYTES_W),
        .BYTES_P(`BYTES_P)
    ) uut (
        .layer_type(layer_type),
        .in_C(in_C),
        .out_C(out_C),
        .kH(kH), .kW(kW),
        .tile_D(tile_D), .tile_K(tile_K),
        .tile_D_f(tile_D_f), .tile_K_f(tile_K_f),
        .M1(M1), .M2(M2), .M3(M3),
        .tile_n(tile_n)
    );

    //---- Task: 印出 GLB 使用百分比 ----
    task print_glb_usage_percent;
        input [31:0] tile_n;
        input [6:0] tile_D, tile_K, tile_D_f, tile_K_f;
        input [1:0] kH, kW;
        input [6:0] M1, M2, M3;
        input [6:0] in_C, out_C;
        input [1:0] layer_type;

        real tmp1, tmp2, tmp3, tmp4, glb_usage, usage_percent;
        begin
            tmp1 = kH * kW * tile_D_f * tile_K_f * `BYTES_W;
            tmp2 = tile_K * `BYTES_P;
            tmp3 = M2 * M3 * tile_K * `BYTES_P;
            case (layer_type)
                `POINTWISE: tmp4 = M1 * tile_D * `BYTES_I + M3 * tile_K * `BYTES_P;
                default   : tmp4 = in_C * tile_D * `BYTES_I + out_C * tile_K * `BYTES_P;
            endcase
            glb_usage = tmp1 + tmp2 + tile_n * tmp4 - tmp3;
            usage_percent = (glb_usage * 100.0) / `GLB_MAX_BYTES;
            $display("🧮 Estimated GLB usage: %.1f KB (%.2f%%)", glb_usage / 1024.0, ((glb_usage / 1024.0)/64.0) * 100.0 );
        end
    endtask

    //---- 測試流程 ----
    initial begin
        // === Test 1: Pointwise ===
        $display("=========================================");
        $display("Test 1: Pointwise");
        layer_type = `POINTWISE;
        in_C = 112; out_C = 112;
        kH = 1; kW = 1;
        tile_D = 32; tile_K = 32;
        tile_D_f = 32; tile_K_f = 32;
        M1 = 1; M2 = 0; M3 = 1;
        #10;
        $display("tile_n: %0d", tile_n);
        print_glb_usage_percent(tile_n, tile_D, tile_K, tile_D_f, tile_K_f, kH, kW, M1, M2, M3, in_C, out_C, layer_type);

        // === Test 2: Depthwise ===
        $display("=========================================");
        $display("Test 2: Depthwise");
        layer_type = `DEPTHWISE;
        in_C = 112; out_C = 112;
        kH = 3; kW = 3;
        tile_D = 10; tile_K = 10;
        tile_D_f = 1; tile_K_f = 10;
        M1 = in_C; M2 = 2; M3 = out_C;
        #10;
        $display("tile_n: %0d", tile_n);
        print_glb_usage_percent(tile_n, tile_D, tile_K, tile_D_f, tile_K_f, kH, kW, M1, M2, M3, in_C, out_C, layer_type);

        // === Test 3: Standard Conv ===
        $display("=========================================");
        $display("Test 3: Standard Conv");
        layer_type = `STANDARD;
        in_C = 64; out_C = 64;
        kH = 3; kW = 3;
        tile_D = 10; tile_K = 10;
        tile_D_f = 10; tile_K_f = 10;
        M1 = in_C; M2 = 2; M3 = out_C;
        #10;
        $display("tile_n: %0d", tile_n);
        print_glb_usage_percent(tile_n, tile_D, tile_K, tile_D_f, tile_K_f, kH, kW, M1, M2, M3, in_C, out_C, layer_type);

        $display("=========================================");
        $display("✅ All tests completed.");
        $finish;
    end

    //---- Dump FSDB ----
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
