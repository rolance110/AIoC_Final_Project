`timescale 1ns / 1ps
`include "../include/define.svh"
module opsum_fifo_ctrl_tb;

    parameter CYCLE = 10; // Clock cycle time in ns
    // Clock and reset
    logic clk;
    logic rst_n;

    // L2 Controller signals
    logic opsum_need_push_i;
    logic [31:0] opsum_push_num_i;

    // Arbiter signals
    logic opsum_permit_pop_i;
    logic fifo_glb_busy_i;

    // GLB base address
    logic [31:0] opsum_glb_base_addr_i;

    // Push data to FIFO
    logic [15:0] push_data;

    // Signals connecting opsum_fifo_ctrl and opsum_fifo
    logic opsum_write_req_o;
    logic opsum_fifo_push_o;
    logic opsum_fifo_pop_o;
    logic opsum_fifo_pop_mod_o;
    logic opsum_glb_write_req_o;
    logic [31:0] opsum_glb_write_addr_o;
    logic [3:0] opsum_glb_write_web_o;
    logic [31:0] opsum_fifo_pop_data_o;
    logic opsum_fifo_done_o;
    logic full;
    logic empty;
    logic [31:0] pop_data;

    // Instantiate opsum_fifo_ctrl
    opsum_fifo_ctrl u_opsum_fifo_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        
        .fifo_glb_busy_i(fifo_glb_busy_i),
        .opsum_fifo_reset_i(1'b0),          // No FIFO reset in this test
        .opsum_need_push_i(opsum_need_push_i),

        .opsum_push_num_i(opsum_push_num_i),

        .opsum_permit_pop_i(opsum_permit_pop_i),

        .opsum_fifo_empty_i(empty),
        .opsum_fifo_full_i(full),

        .opsum_fifo_pop_data_i(pop_data[15:0]), // Only 16-bit data from FIFO

        .opsum_glb_base_addr_i(opsum_glb_base_addr_i),

        .opsum_write_req_o(opsum_write_req_o),

        .opsum_fifo_pop_o(opsum_fifo_pop_o),
        .opsum_fifo_pop_mod_o(opsum_fifo_pop_mod_o),
        .opsum_fifo_push_o(opsum_fifo_push_o),

        .opsum_write_req_o(opsum_glb_write_req_o),
        .opsum_glb_write_addr_o(opsum_glb_write_addr_o),
        .opsum_glb_write_web_o(opsum_glb_write_web_o),

        .opsum_fifo_pop_data_o(opsum_fifo_pop_data_o),

        .opsum_fifo_done_o(opsum_fifo_done_o)
    );

    // Instantiate opsum_fifo
    opsum_fifo u_opsum_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .push_en(opsum_fifo_push_o),
        .push_data(push_data),
        .full(full),
        .pop_en(opsum_fifo_pop_o),
        .pop_mod(opsum_fifo_pop_mod_o),
        .pop_data(pop_data),
        .empty(empty)
    );

    // Clock generation (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset and test sequence
    initial begin
        // Initialize signals
        rst_n = 0;
        opsum_need_push_i = 0;
        opsum_push_num_i = 0;
        opsum_permit_pop_i = 0;
        fifo_glb_busy_i = 0;
        opsum_glb_base_addr_i = 32'h1000_0000;
        push_data = 16'h0000;

        // Apply reset
        #10 rst_n = 1;
        #15;

        //* Test Case 1: Single push and pop
        $display("Test Case 1: Single push and pop");
        opsum_push_num_i = 1;
        opsum_need_push_i = 1;
        push_data = 16'hAAAA;
        #11;
        opsum_need_push_i = 0;
        @(posedge clk); // Wait for push to occur
        opsum_permit_pop_i = 1;
        #11;
        opsum_permit_pop_i = 0;
        //* next case
        @(posedge clk);
        assert(opsum_glb_write_req_o == 1 && opsum_fifo_pop_data_o == 32'h0000_AAAA && opsum_glb_write_addr_o == 32'h1000_0000 && opsum_glb_write_web_o == 4'b0011) else $error("Test Case 1 failed: Incorrect GLB write");
        #10.1;
        assert(opsum_fifo_done_o == 1) else $error("Test Case 1 failed: Done signal not asserted");
        #100

        //* Test Case 2: Push two entries until full, then pop
        $display("Test Case 2: Push until full, then pop");
        #20.5;
        opsum_push_num_i = 2;
        opsum_need_push_i = 1;
        @(posedge clk);
        push_data = 16'h1111;
        #10.5;
        push_data = 16'h2222;
        #10.5;
        opsum_need_push_i = 0;
        @(posedge clk);
        assert(full == 1) else $error("Test Case 2 failed: FIFO not full");
        opsum_permit_pop_i = 1;
        #(2*CYCLE + 1);
        opsum_permit_pop_i = 0;
        @(posedge clk);
        assert(opsum_fifo_done_o == 1) else $error("Test Case 2 failed: Done signal not asserted");

        // Test Case 3: Push with interleaved pop
        $display("Test Case 3: Push with interleaved pop");
        #20;
        opsum_push_num_i = 3;
        opsum_need_push_i = 1;
        push_data = 16'h3333;
        #10.1;
        opsum_permit_pop_i = 1;
        #10.1;
        opsum_permit_pop_i = 0;
        push_data = 16'h4444;
        #10.1;
        push_data = 16'h5555;
        #10.1;
        opsum_need_push_i = 0;
        opsum_permit_pop_i = 1;
        #30; // Pop remaining data
        opsum_permit_pop_i = 0;
        @(posedge clk);
        assert(opsum_fifo_done_o == 1) else $error("Test Case 3 failed: Done signal not asserted");

        // Test Case 4: Arbiter busy scenario
        $display("Test Case 4: Arbiter busy scenario");
        #20;
        opsum_push_num_i = 1;
        opsum_need_push_i = 1;
        push_data = 16'h6666;
        #10;
        opsum_need_push_i = 0;
        fifo_glb_busy_i = 1; // Arbiter busy
        #20;
        assert(opsum_fifo_pop_o == 0) else $error("Test Case 4 failed: Pop occurred during busy");
        fifo_glb_busy_i = 0;
        opsum_permit_pop_i = 1;
        #10;
        opsum_permit_pop_i = 0;
        @(posedge clk);
        assert(opsum_fifo_done_o == 1) else $error("Test Case 4 failed: Done signal not asserted");

        $display("Simulation completed");
        $finish;
    end

    // Monitor signals for debugging
    initial begin
        $monitor("Time=%0t | push_en=%b | pop_en=%b | full=%b | empty=%b | pop_data=%h | glb_write_req=%b | glb_addr=%h | glb_data=%h",
                 $time, opsum_fifo_push_o, opsum_fifo_pop_o, full, empty, pop_data, opsum_glb_write_req_o, opsum_glb_write_addr_o, opsum_fifo_pop_data_o);
    end
    initial begin
        `ifdef FSDB
            $fsdbDumpfile("../wave/top.fsdb");
            $fsdbDumpvars(0, u_opsum_fifo , u_opsum_fifo_ctrl);
        `elsif FSDB_ALL
            $fsdbDumpfile("../wave/top.fsdb");
            $fsdbDumpvars("+struct", "+mda", "+all", u_opsum_fifo , u_opsum_fifo_ctrl);
        `endif
    end
endmodule