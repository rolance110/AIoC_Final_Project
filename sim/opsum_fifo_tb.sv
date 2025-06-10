`timescale 1ns/1ps
`include "../include/define.svh"
module opsum_fifo_tb;

    logic clk, rst_n;
    logic push_en;
    logic [15:0] push_data;
    logic pop_en;
    logic pop_mod;
    logic [31:0] pop_data;
    logic full, empty;

    // DUT
    opsum_fifo uut (
        .clk(clk),
        .rst_n(rst_n),
        .push_en(push_en),
        .push_data(push_data),
        .full(full),
        .pop_en(pop_en),
        .pop_mod(pop_mod),
        .pop_data(pop_data),
        .empty(empty)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Task: push 16-bit
    task push16(input [15:0] data);
        @(negedge clk);
        push_data = data;
        push_en   = 1;
        @(negedge clk);
        push_en = 0;
    endtask

    // Task: pop 16-bit
    task pop16();
        @(negedge clk);
        pop_en = 1;
        pop_mod = 0;
        @(negedge clk);
        pop_en = 0;
    endtask

    // Task: pop 32-bit (burst)
    task pop32();
        @(negedge clk);
        pop_en = 1;
        pop_mod = 1;
        @(negedge clk);
        pop_en = 0;
    endtask

    initial begin
        $display("--- opsum_fifo_tb Start ---");

        clk = 0;
        rst_n = 0;
        push_en = 0;
        pop_en = 0;
        pop_mod = 0;
        push_data = 0;

        @(negedge clk); rst_n = 1;

        // Test 1: push and pop single 16-bit values
        push16(16'hA5A5);
        push16(16'h1234);
        pop16();
        $display("Pop result = 0x%h (expect 0xA5A5)", pop_data[15:0]);
        pop16();
        $display("Pop result = 0x%h (expect 0x1234)", pop_data[15:0]);

        // Test 2: check empty behavior
        pop16();
        $display("Expect no change (empty=1): 0x%h", pop_data[15:0]);

        // Test 3: burst push (manually fill mem)
        @(negedge clk);
        push16(16'h1111);
        push16(16'h2222);

        pop32();
        $display("Pop32 result = 0x%h (expect 0x22221111)", pop_data);

        #20;
        $display("--- opsum_fifo_tb Done ---");
        $finish;
    end

endmodule
