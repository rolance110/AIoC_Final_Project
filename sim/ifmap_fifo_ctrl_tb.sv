`timescale 1ns / 1ps
`include "../include/define.svh"
`timescale 1ns/1ps
module ifmap_fifo_ctrl_tb;

    logic clk, rst_n;

    // DUT inputs
    logic        ifmap_fifo_reset_i;
    logic        ifmap_need_pop_i;
    logic [4:0]  ifmap_pop_num_i;
    logic        ifmap_permit_push_i;
    logic [31:0] ifmap_glb_base_addr_i;
    logic [31:0] ifmap_glb_read_data_i;

    // DUT outputs
    logic        ifmap_fifo_reset_o;
    logic        ifmap_fifo_push_en_o;
    logic [31:0] ifmap_fifo_push_data_o;
    logic        ifmap_fifo_push_mod_o;
    logic        ifmap_fifo_pop_en_o;
    logic        ifmap_glb_read_req_o;
    logic [31:0] ifmap_glb_read_addr_o;
    logic        ifmap_fifo_done_o;

    // FIFO wires
    logic fifo_full, fifo_empty;
    logic [7:0] fifo_data_out;

    // Instantiate ifmap_fifo_ctrl
    ifmap_fifo_ctrl dut (
        .clk(clk),
        .rst_n(rst_n),
        .ifmap_fifo_reset_i(ifmap_fifo_reset_i),
        .ifmap_need_pop_i(ifmap_need_pop_i),
        .ifmap_pop_num_i(ifmap_pop_num_i),
        .ifmap_permit_push_i(ifmap_permit_push_i),
        .ifmap_fifo_full_i(fifo_full),
        .ifmap_fifo_empty_i(fifo_empty),
        .ifmap_glb_base_addr_i(ifmap_glb_base_addr_i),
        .ifmap_glb_read_data_i(ifmap_glb_read_data_i),
        .ifmap_fifo_reset_o(ifmap_fifo_reset_o),
        .ifmap_fifo_push_en_o(ifmap_fifo_push_en_o),
        .ifmap_fifo_push_data_o(ifmap_fifo_push_data_o),
        .ifmap_fifo_push_mod_o(ifmap_fifo_push_mod_o),
        .ifmap_fifo_pop_en_o(ifmap_fifo_pop_en_o),
        .ifmap_glb_read_req_o(ifmap_glb_read_req_o),
        .ifmap_glb_read_addr_o(ifmap_glb_read_addr_o),
        .ifmap_fifo_done_o(ifmap_fifo_done_o)
    );

    // Instantiate ifmap_fifo
    ifmap_fifo fifo (
        .clk(clk),
        .rst_n(rst_n),
        .push_en(ifmap_fifo_push_en_o),
        .push_mod(ifmap_fifo_push_mod_o),
        .push_data(ifmap_fifo_push_data_o),
        .full(fifo_full),
        .pop_en(ifmap_fifo_pop_en_o),
        .pop_data(fifo_data_out),
        .empty(fifo_empty)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("Start ifmap_fifo_ctrl_tb...");
        clk = 0;
        rst_n = 0;
        ifmap_fifo_reset_i = 0;
        ifmap_need_pop_i   = 0;
        ifmap_pop_num_i    = 0;
        ifmap_permit_push_i = 0;
        ifmap_glb_base_addr_i = 32'h1000;
        ifmap_glb_read_data_i = 32'hCAFEBABE;

        #15 rst_n = 1;
        #15;

        // Issue pop task (need 6 pops)
        ifmap_need_pop_i = 1;
        ifmap_pop_num_i  = 5'd6;
        #10;
        ifmap_need_pop_i = 0;
        ifmap_pop_num_i  = 5'd0;
        // Simulate permit push with GLB data
        repeat (6) begin
            ifmap_permit_push_i = 1;
            ifmap_glb_read_data_i = $random;
            #10;
        end

        // Wait some cycles for FIFO to output
        ifmap_need_pop_i = 0;
        repeat (20) #10;

        $display("Done: ifmap_fifo_done_o = %b", ifmap_fifo_done_o);
        $finish;
    end


// dump FSDB file
initial begin
    `ifdef FSDB
        $fsdbDumpfile("../wave/top.fsdb");
        $fsdbDumpvars(0, dut,fifo, ifmap_fifo_ctrl_tb);
    `elsif FSDB_ALL
        $fsdbDumpfile("../wave/top.fsdb");
        $fsdbDumpvars("+struct", "+mda", dut,fifo,ifmap_fifo_ctrl_tb);
    `endif
end

endmodule