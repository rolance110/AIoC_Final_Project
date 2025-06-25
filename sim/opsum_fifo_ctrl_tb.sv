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
    
    logic opsum_fifo_push_mask_i;
    logic  pe_array_move_i;
    logic opsum_fifo_reset_i; // Reset signal for FIFO
    // Instantiate opsum_fifo_ctrl
    opsum_fifo_ctrl u_opsum_fifo_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        
        .fifo_glb_busy_i(fifo_glb_busy_i),
        .opsum_fifo_reset_i(opsum_fifo_reset_i),          // No FIFO reset in this test

        .opsum_need_push_i(opsum_need_push_i),
        .opsum_push_num_i(opsum_push_num_i),

        .opsum_fifo_push_mask_i(opsum_fifo_push_mask_i), // fixme
        .pe_array_move_i(pe_array_move_i), // fixme

        .opsum_permit_pop_i(opsum_permit_pop_i),

        .opsum_fifo_empty_i(empty),
        .opsum_fifo_full_i(full),

        .opsum_fifo_pop_data_i(pop_data[15:0]), // Only 16-bit data from FIFO

        .opsum_glb_base_addr_i(opsum_glb_base_addr_i),


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
    always_comb begin
        opsum_permit_pop_i = opsum_glb_write_req_o;
    end     // Connect opsum_permit_pop_i to opsum_write_req_o
    // Reset and test sequence
    initial begin
        // Initialize signals
        rst_n = 0;
        opsum_need_push_i = 0;
        opsum_push_num_i = 0;
        fifo_glb_busy_i = 0;
        opsum_glb_base_addr_i = 32'h1000_0000;
        push_data = 16'h0000;
        opsum_fifo_push_mask_i = 1'b0;
        pe_array_move_i = 1'b0;
        opsum_fifo_reset_i = 1'b0; // No FIFO reset initially
        // Apply reset
        #10 rst_n = 1;
        #15.1;
        $display("Test Case 1: Single push and pop");
        opsum_fifo_push_mask_i = 1'b0;
        
        opsum_need_push_i = 1;
        opsum_push_num_i = 32'h0000_0001; // Push
        #10.1;
        opsum_need_push_i = 0;
        opsum_push_num_i = 32'h0000_0000; // Push

        opsum_fifo_push_mask_i = 1'b0;
        pe_array_move_i = 1'b0;
        #10.1;
        opsum_fifo_push_mask_i = 1'b0;
        pe_array_move_i = 1'b1;
        #10.1;
        opsum_fifo_push_mask_i = 1'b1;
        pe_array_move_i = 1'b1;
        #10.1;
        pe_array_move_i = 1'b0;

        #50.1;
        opsum_fifo_reset_i = 1'b1; // Reset FIFO
        #10.1;
        opsum_fifo_reset_i = 1'b0; // Release FIFO reset
        $display("Test Case 2: Push until full, then pop");
        opsum_fifo_push_mask_i = 1'b0;
        
        opsum_need_push_i = 1;
        opsum_push_num_i = 32'h0000_0010; // Push
        #10.1;
        opsum_need_push_i = 0;
        opsum_push_num_i = 32'h0000_0000; // Push

        opsum_fifo_push_mask_i = 1'b0;
        pe_array_move_i = 1'b0;
        #10.1;
        opsum_fifo_push_mask_i = 1'b0;
        pe_array_move_i = 1'b1;
        #10.1;
        opsum_fifo_push_mask_i = 1'b1;
        pe_array_move_i = 1'b1;
        #20; // push 2 item
        pe_array_move_i = 1'b0;
        wait(u_opsum_fifo_ctrl.op_cs == u_opsum_fifo_ctrl.CAN_PUSH);
        pe_array_move_i = 1'b1;
        #20; // push 2 item
        pe_array_move_i = 1'b0;
        wait(u_opsum_fifo_ctrl.op_cs == u_opsum_fifo_ctrl.CAN_PUSH);
        pe_array_move_i = 1'b1;
        #20; // push 2 item
        pe_array_move_i = 1'b0;

        #50;       
        $display("Test Case 3: Push with interleaved pop");
       
        $display("Test Case 4: Arbiter busy scenario");


        $display("Simulation completed");
        $finish;
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