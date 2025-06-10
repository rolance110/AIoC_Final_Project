`timescale 1ns/1ps
`include "../include/define.svh"

module reducer_tb;

    // Parameters
    logic clk;
    logic rst_n;
    logic layer_type;
    logic ipsum_add_en;

    logic [15:0] mul_out_matrix [31:0][31:0];
    logic [15:0] ipsum_out      [31:0];
    logic [15:0] final_psum     [31:0];

    logic [31:0] expected_psum  [31:0];
    int error_cnt;

    // DUT instantiation
    reducer dut (
        .clk(clk),
        .rst_n(rst_n),
        .layer_type(layer_type),
        .ipsum_add_en(ipsum_add_en),
        .mul_out_matrix(mul_out_matrix),
        .ipsum_out(ipsum_out),
        .final_psum(final_psum)
    );

    // Clock
    always #5 clk = ~clk;

    // Main test sequence
    initial begin
        clk = 0;
        rst_n = 0;
        error_cnt = 0;
        #10 rst_n = 1;

        // === 初始化測資 ===
        for (int i = 0; i < 32; i++) begin
            ipsum_out[i] = i;
            for (int j = 0; j < 32; j++) begin
                mul_out_matrix[i][j] = i + j;
            end
        end

        // === 測試 POINTWISE + IPSUM ===
        layer_type = `POINTWISE;
        ipsum_add_en = 1;
        #10;

        $display("\n[`POINTWISE + IPSUM]");
        for (int i = 0; i < 32; i++) begin
            expected_psum[i] = 32*i + 496 + i; // 32*i + sum(j=0~31) + ipsum = i
            if (final_psum[i] !== expected_psum[i]) begin
                $display("FAIL: [%0d] expected %0d, got %0d", i, expected_psum[i], final_psum[i]);
                error_cnt++;
            end else begin
                $display("PASS: [%0d] = %0d", i, final_psum[i]);
            end
        end

        // === 測試 DEPTHWISE no IPSUM ===
        layer_type = `DEPTHWISE;
        ipsum_add_en = 0;
        #10;

        $display("\n[`DEPTHWISE no IPSUM]");
        for (int i = 0; i < 32; i++) begin
            if (i < 10)
                expected_psum[i] = (32*(3*i) + 32*(3*i+1) + 32*(3*i+2)) + 3*496;
            else
                expected_psum[i] = 0;

            if (final_psum[i] !== expected_psum[i]) begin
                $display("FAIL: [%0d] expected %0d, got %0d", i, expected_psum[i], final_psum[i]);
                error_cnt++;
            end else begin
                $display("PASS: [%0d] = %0d", i, final_psum[i]);
            end
        end

        // === 測試 DEPTHWISE + IPSUM ===
        layer_type = `DEPTHWISE;
        ipsum_add_en = 1;
        #10;

        $display("\n[`DEPTHWISE + IPSUM]");
        for (int i = 0; i < 32; i++) begin
            if (i < 10)
                expected_psum[i] = (32*(3*i) + 32*(3*i+1) + 32*(3*i+2)) + 3*496 + i;
            else
                expected_psum[i] = i;

            if (final_psum[i] !== expected_psum[i]) begin
                $display("FAIL: [%0d] expected %0d, got %0d", i, expected_psum[i], final_psum[i]);
                error_cnt++;
            end else begin
                $display("PASS: [%0d] = %0d", i, final_psum[i]);
            end
        end

        $display("\n======== TEST FINISHED ========");
        if (error_cnt == 0)
            $display("🎉 ALL TESTS PASSED!");
        else
            $display("❌ %0d TEST(S) FAILED", error_cnt);

        $finish;
    end

    // Waveform Dump
    initial begin
        `ifdef FSDB
            $fsdbDumpfile("../wave/top.fsdb");
            $fsdbDumpvars(0, dut);
        `elsif FSDB_ALL
            $fsdbDumpfile("../wave/top.fsdb");
            $fsdbDumpvars("+struct", "+mda", dut);
        `endif
    end

endmodule
