`timescale 1ns/1ps
`include "../include/define.svh"
module conv_unit_tb;
    parameter cycle = 10;
    logic clk;
    logic rst_n;

    // Controller signals
    logic [31:0]        push_ifmap_en;
    logic [31:0]        push_ifmap_mod;
    logic [31:0]        push_ifmap_data;// broadcast 32-bit push data to 32 FIFOs
    logic [31:0]        pop_ifmap_en;

    logic [7:0]         weight_in;
    logic [31:0][31:0]  weight_load_en;

    logic [31:0][31:0]  PE_en_matrix;

    logic               ipsum_load_en;
    logic [4:0]         ipsum_load_idx;
    logic [15:0]        ipsum_load_data;
    logic               ipsum_read_en;
    logic [1:0]         layer_type;
    logic               ipsum_add_en;

    logic [31:0]        opsum_push_en;
    logic [31:0]        opsum_pop_en;
    logic [31:0]        opsum_pop_mod;

    // Outputs
    logic [31:0]        ifmap_fifo_full;
    logic [31:0]        ifmap_fifo_empty;
    logic [31:0]        opsum_fifo_full;
    logic [31:0]        opsum_fifo_empty;
    logic [31:0]        opsum_pop_data [31:0];

//* ipsum fifo 
    logic [31:0]        push_ipsum_en;
    logic [31:0]        push_ipsum_mod; //* (push mod 0: 16 bits push, 1: 32 bits push)
    logic [31:0]        push_ipsum_data;// broadcast 32-bit push data to 32 FIFOs
    logic [31:0]        pop_ipsum_en;

    logic [31:0]        ipsum_fifo_full;
    logic [31:0]        ipsum_fifo_empty;

    conv_unit dut (
        .clk(clk),
        .rst_n(rst_n),
//* layer type
        .layer_type(layer_type),
//* ifmap fifo
        .push_ifmap_en(push_ifmap_en),
        .push_ifmap_mod(push_ifmap_mod),
        .push_ifmap_data(push_ifmap_data),
        .pop_ifmap_en(pop_ifmap_en),
//* weight
        .weight_in(weight_in),
        .weight_load_en(weight_load_en),
//* PE array
        .PE_en_matrix(PE_en_matrix),
//* ipsum fifo  
        .push_ipsum_en(push_ipsum_en),
        .push_ipsum_mod(push_ipsum_mod),
        .push_ipsum_data(push_ipsum_data),
        .pop_ipsum_en(pop_ipsum_en),
//* reducer
        .ipsum_read_en(ipsum_read_en),
        .ipsum_add_en(ipsum_add_en),
//* opsum fifo
        .opsum_push_en(opsum_push_en),
        .opsum_pop_en(opsum_pop_en),
        .opsum_pop_mod(opsum_pop_mod),
//* Outputs
//* ifmap fifo
        .ifmap_fifo_full(ifmap_fifo_full),
        .ifmap_fifo_empty(ifmap_fifo_empty),
//* ipsum fifo
        .ipsum_fifo_full(ipsum_fifo_full),
        .ipsum_fifo_empty(ipsum_fifo_empty),
        // .ipsum_pop_data(ipsum_pop_data), //* to reducer
//* opsum fifo
        .opsum_fifo_full(opsum_fifo_full),
        .opsum_fifo_empty(opsum_fifo_empty),
        .opsum_pop_data(opsum_pop_data) // to GLB or PPU
    );
// conv_unit (
//     input  logic               clk,
//     input  logic               rst_n,

// //* layer type
//     input  logic [1:0]         layer_type,

// //* ifmap fifo
//     input  logic [31:0]        push_ifmap_en,
//     input  logic [31:0]        push_ifmap_mod,
//     input  logic [31:0]        push_ifmap_data [31:0], // 32 input channel data
//     input  logic [31:0]        pop_ifmap_en,

// //* weight
//     input  logic [7:0]         weight_in,
//     input  logic [31:0][31:0]  weight_load_en, // 32*32 mul_array load enable

// //* PE array
//     input  logic [31:0][31:0]  PE_en_matrix, // 32*32 PE array enable matrix

// //* ipsum fifo 
//     input  logic [31:0]        push_ipsum_en,
//     input  logic [31:0]        push_ipsum_mod, //* (push mod 0: 16 bits push, 1: 32 bits push)
//     input  logic [31:0]        push_ipsum_data [31:0], // 32 input channel data
//     input  logic [31:0]        pop_ipsum_en,

// //* reducer
//     input  logic               ipsum_read_en, // enables reading data from ipsum buffer
//     input  logic               ipsum_add_en,

// //* opsum fifo
//     input  logic [31:0]        opsum_push_en,
//     input  logic [31:0]        opsum_pop_en,
//     input  logic [31:0]        opsum_pop_mod,

// //////* Outputs
// //* ifmap fifo
//     output logic [31:0]        ifmap_fifo_full,
//     output logic [31:0]        ifmap_fifo_empty,

// //* ipsum fifo
//     output logic [31:0]        ipsum_fifo_full,
//     output logic [31:0]        ipsum_fifo_empty,

//     // output logic [31:0]        ipsum_pop_data [31:0] , //* to reducer
// //* opsum fifo
//     output logic [31:0]        opsum_fifo_full,
//     output logic [31:0]        opsum_fifo_empty,

//     output logic [31:0]        opsum_pop_data [31:0] // to GLB or PPU
// );
    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        #(cycle);
        rst_n = 1;
        #(cycle);
        // load weight data
        weight_in = 8'h00; // Example weight data
        weight_load_en[0][0] = 1'b1; // load PE[0][0] with weight_in
        #(cycle);
        // load weight data
        weight_in = 8'h01; // Example weight data
        weight_load_en[0][1] = 1'b1; // load PE[0][1] with weight_in
        #(cycle);
        // push ifmap data
        push_ifmap_en = 32'h00000001; // Enable FIFO[0]
        push_ifmap_mod = 1'b1; // 32-bit mode
        push_ifmap_data = 32'h11223344; // Data to push
        #(cycle);
        push_ifmap_en = 32'h00000003; // Disable FIFO[0] and enable FIFO[1]
        push_ifmap_mod = 1'b1; // 32-bit mode
        push_ifmap_data = 32'h55667788; // Data to push

        


        $display("opsum_pop_data[0] = %h", opsum_pop_data[0]);
        $finish;
    end
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
