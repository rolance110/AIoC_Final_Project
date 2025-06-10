`timescale 1ns/1ps
`include "../include/define.svh"
module opsum_fifo_bank_tb;

    logic clk;
    logic rst_n;

    logic [31:0]         push_opsum_en;
    logic [15:0]   push_opsum_data[31:0];
    logic [31:0]         pop_opsum_en;
    logic [31:0]         pop_opsum_mod;
    logic [31:0]   pop_opsum_data[31:0];
    logic [31:0]         opsum_fifo_full;
    logic [31:0]         opsum_fifo_empty;

    // Instantiate the DUT
    opsum_fifo_bank dut (
        .clk              (clk),
        .rst_n            (rst_n),
        .push_opsum_en    (push_opsum_en),
        .push_opsum_data  (push_opsum_data),
        .pop_opsum_en     (pop_opsum_en),
        .pop_opsum_mod    (pop_opsum_mod),
        .pop_opsum_data   (pop_opsum_data),
        .opsum_fifo_full  (opsum_fifo_full),
        .opsum_fifo_empty (opsum_fifo_empty)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("=== Begin opsum_fifo_bank Testbench ===");

        clk = 0;
        rst_n = 0;
        push_opsum_en   = 0;
        pop_opsum_en    = 0;
        pop_opsum_mod   = 0;

        #20;
        rst_n = 1;

        // Test 1: Push 16-bit to FIFO[0]
        push_opsum_en[0]   = 1;
        push_opsum_data[0] = 16'hAAAA;
        #10;
        push_opsum_en[0] = 0;

        // Test 2: Pop 16-bit from FIFO[0]
        pop_opsum_en[0]  = 1;
        pop_opsum_mod[0] = 0;
        #10;
        pop_opsum_en[0] = 0;

        // Test 3: Push two values to FIFO[1]
        push_opsum_en[1]   = 1;
        push_opsum_data[1] = 16'h1111;
        #10;
        push_opsum_data[1] = 16'h2222;
        #10;
        push_opsum_en[1] = 0;

        // Test 4: Pop 32-bit from FIFO[1]
        pop_opsum_en[1]  = 1;
        pop_opsum_mod[1] = 1;
        #10;
        pop_opsum_en[1] = 0;

        #20;
        $display("=== End of opsum_fifo_bank Testbench ===");
        $finish;
    end

endmodule
