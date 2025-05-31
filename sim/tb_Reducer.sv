`timescale 1ns/1ps
`define CYCLE    10
`define ROW_NUM  32
`define VEC_W    (`ROW_NUM*16)   // 512 bits

module tb_Reducer;

// --------------------------------------------------
// 1. DUT 介面
// --------------------------------------------------
logic                clk;
logic                rst_n;
logic [`VEC_W-1:0]   array2reducer;
logic [`VEC_W-1:0]   ipsum2reducer;
logic                DW_PW_sel;
wire  [`VEC_W-1:0]   reducer2opsum;

// 每 ROW 的 16-bit 累加結果（方便觀波形 / $display）
wire [15:0] out_1      [`ROW_NUM-1:0];

Reducer dut (
    .array2reducer (array2reducer),
    .ipsum2reducer (ipsum2reducer),
    .DW_PW_sel     (DW_PW_sel),
    .reducer2opsum (reducer2opsum)
);

// --------------------------------------------------
// 2. 拆解 reducer2opsum → out_1/out_1_hi/out_1_lo
// -------------------------------------------------
assign out_1[0]    = reducer2opsum[15:0];
assign out_1[1]    = reducer2opsum[31:16];
assign out_1[2]    = reducer2opsum[47:32];
assign out_1[3]    = reducer2opsum[63:48];



// --------------------------------------------------
// 3. Clock & FSDB
// --------------------------------------------------
initial clk = 0;
always  #(`CYCLE/2) clk = ~clk;

initial begin
    $fsdbDumpfile("Reducer.fsdb");
    $fsdbDumpvars(0, tb_Reducer);   // 全層次 dump（含 out_1 陣列）
end

// --------------------------------------------------
// 4. 隨機向量產生 + golden 計算（同前版）
// --------------------------------------------------
function automatic logic [`VEC_W-1:0] gen_rand_vec ();
    logic [`VEC_W-1:0] vec;
    for (int i = 0; i < `ROW_NUM; i++)
        vec[i*16 +: 16] = $urandom_range(0, 255);
    return vec;
endfunction

function automatic logic [`VEC_W-1:0] golden_calc (
        input logic [`VEC_W-1:0] A,
        input logic [`VEC_W-1:0] I,
        input logic              sel);
    logic [`VEC_W-1:0] g;
    for (int i = 0; i < `ROW_NUM; i++) begin
        if (sel) begin
            g[i*16 +: 16] = A[i*16 +: 16] + I[i*16 +: 16]; // PW
        end else if (i < 30 && (i % 3) == 0) begin
            g[i*16 +: 16] = A[i*16 +: 16] +              // DW
                            A[i*16+16 +: 16] +
                            A[i*16+32 +: 16] +
                            I[i*16 +: 16];
        end else
            g[i*16 +: 16] = 16'd0;
    end
    return g;
endfunction

task automatic send_and_check (input logic sel);
    logic [`VEC_W-1:0] A_rand, I_rand, gold;
    begin
        A_rand = gen_rand_vec();
        I_rand = gen_rand_vec();
        gold   = golden_calc(A_rand, I_rand, sel);

        @(negedge clk);
        array2reducer = A_rand;
        ipsum2reducer = I_rand;
        DW_PW_sel     = sel;
        @(posedge clk);   // DUT 採樣
        @(posedge clk);   // 結果穩定

        if (reducer2opsum !== gold) begin
            $display("[ERROR] Mismatch sel=%0d @%0t", sel, $time);
            foreach (out_1[i]) begin
                if (out_1[i] !== gold[i*16 +: 16])
                    $display("  row%0d DUT=%0d GOLD=%0d",
                              i, out_1[i], gold[i*16 +: 16]);
            end
            $fatal(1, "STOP on mismatch");
        end
        else
            $display("[PASS] sel=%0d vector OK @%0t", sel, $time);
    end
endtask

// --------------------------------------------------
// 5. 主流程：4 次 PW + 1 次 DW
// --------------------------------------------------
initial begin
    rst_n = 0;
    DW_PW_sel = 0;
    array2reducer = '0;
    ipsum2reducer = '0;
    repeat (3) @(posedge clk);
    rst_n = 1;

    repeat (4) send_and_check(1'b1); // PW
    send_and_check(1'b0);            // DW

    $display("=== ALL TESTS PASS ===");
    #(`CYCLE) $finish;
end
endmodule
