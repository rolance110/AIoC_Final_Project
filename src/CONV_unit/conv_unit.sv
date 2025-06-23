//===========================================================================
// Module: conv_unit
// Description: Top-level convolution unit integrating ifmap FIFOs, PE array,
//              reducer, ipsum buffer, and opsum FIFOs.
//===========================================================================

// `include "ifmap_fifo_bank.sv"
// `include "pe_array.sv"
// `include "ipsum_buffer.sv"
// `include "reducer.sv"
// `include "opsum_fifo_bank.sv"

// `include "opsum_fifo.sv"
// `include "opsum_fifo_bank.sv"
// `include "ipsum_fifo.sv"
// `include "ipsum_fifo_bank.sv"
// `include "ipsum_buffer.sv"
module conv_unit (
    input  logic               clk,
    input  logic               rst_n,

//* reset
    input logic ifmap_fifo_reset_i,
    input logic ipsum_fifo_reset_i,
    input logic opsum_fifo_reset_i,

//* layer type
    input  logic [1:0]         layer_type,

//* ifmap fifo
    input  logic [31:0]        push_ifmap_en,
    input  logic [31:0]        push_ifmap_mod,
    input  logic [31:0]        push_ifmap_data [31:0], // broadcast 32-bit push data to 32 FIFOs
    input  logic [31:0]        pop_ifmap_en,

//* weight
    input  logic [7:0]         weight_in,
    input  logic  weight_load_en[31:0][31:0] , // 32*32 mul_array load enable

//* PE array
    input  logic PE_en_matrix [31:0][31:0] , // 32*32 PE array enable matrix
    input  logic  PE_stall_matrix [31:0][31:0], // 32*32 PE array stall matrix

//* ipsum fifo 
    input  logic [31:0]        push_ipsum_en,
    input  logic [31:0]        push_ipsum_mod, //* (push mod 0: 16 bits push, 1: 32 bits push)
    input  logic [31:0]        push_ipsum_data [31:0], // broadcast 32-bit push data to 32 FIFOs
    input  logic [31:0]        pop_ipsum_en,

//* reducer
    input  logic               ipsum_read_en, // enables reading data from ipsum buffer
    input  logic               ipsum_add_en,

//* opsum fifo
    input  logic [31:0]        opsum_push_en,
    input  logic [31:0]        opsum_pop_en,
    input  logic [31:0]        opsum_pop_mod,

//////* Outputs
//* ifmap fifo
    output logic [31:0]        ifmap_fifo_full,
    output logic [31:0]        ifmap_fifo_empty,

//* ipsum fifo
    output logic [31:0]        ipsum_fifo_full,
    output logic [31:0]        ipsum_fifo_empty,

    // output logic [31:0]        ipsum_pop_data [31:0] , //* to reducer
//* opsum fifo
    output logic [31:0]        opsum_fifo_full,
    output logic [31:0]        opsum_fifo_empty,

    output logic [31:0]        opsum_pop_data [31:0] // to GLB or PPU
);

    //==================== ifmap fifo ====================
    logic [7:0] ifmap_row0 [31:0];
    ifmap_fifo_bank #(
        .WIDTH(8),
        .DEPTH(4)
    ) u_ifmap_fifo_bank (
        .clk               (clk),
        .rst_n             (rst_n),
        .ifmap_fifo_reset_i (ifmap_fifo_reset_i),
        .push_ifmap_en     (push_ifmap_en),
        .push_ifmap_mod    (push_ifmap_mod),
        .push_ifmap_data   (push_ifmap_data),// broadcast 32-bit push data to 32 FIFOs
        .ifmap_fifo_full   (ifmap_fifo_full),
        .pop_ifmap_en      (pop_ifmap_en),
        .pop_ifmap_data    (ifmap_row0),
        .ifmap_fifo_empty  (ifmap_fifo_empty)
    );

    //==================== PE Array ====================
    logic [15:0] mul_out_matrix [31:0][31:0];
    logic [7:0]  dummy_ifmap; // unused (handled in pe_array)

    pe_array #(
        .ROW(32),
        .COL(32)
    ) u_pe_array (
        .clk            (clk),
        .rst_n          (rst_n),
        .ifmap_row0     (ifmap_row0),
        .weight_in      (weight_in),
        .w_load_en        (weight_load_en),
        .PE_en_matrix   (PE_en_matrix),
        .PE_stall_matrix(PE_stall_matrix),
        .mul_out_matrix (mul_out_matrix)
    );

    //==================== Ipsum Buffer ====================



    //==================== Ipsum FIFO Bank ====================
    logic [15:0] ipsum_pop_data [31:0]; // 16-bit output data from ipsum FIFO
    ipsum_fifo_bank #(
        .WIDTH(16),
        .DEPTH(2)
    ) u_ipsum_fifo_bank (
        .clk               (clk),
        .rst_n             (rst_n),
        .ipsum_fifo_reset_i (ipsum_fifo_reset_i),
        .push_ipsum_en     (push_ipsum_en),
        .push_ipsum_mod    (push_ipsum_mod),
        .push_ipsum_data   (push_ipsum_data),// broadcast 32-bit push data to 32 FIFOs
        .ipsum_fifo_full   (ipsum_fifo_full),

        .pop_ipsum_en      (pop_ipsum_en),
        .pop_ipsum_data    (ipsum_pop_data),
        .ipsum_fifo_empty  (ipsum_fifo_empty)
    );


    //==================== Reducer ====================
    logic [15:0] reducer_out [31:0];
    reducer u_reducer (
        .clk          (clk),
        .rst_n        (rst_n),
        .layer_type   (layer_type),
        .ipsum_add_en (ipsum_add_en),
        .mul_out_matrix (mul_out_matrix),
        .ipsum_out    (ipsum_pop_data),
        .final_psum   (reducer_out)
    );

    //==================== Opsum FIFO Bank ====================
    opsum_fifo_bank u_opsum_fifo_bank (
        .clk             (clk),
        .rst_n           (rst_n),
        .opsum_fifo_reset_i (opsum_fifo_reset_i),
        .push_opsum_en   (opsum_push_en),
        .push_opsum_data (reducer_out),
        .pop_opsum_en    (opsum_pop_en),
        .pop_opsum_mod   (opsum_pop_mod),
        .pop_opsum_data  (opsum_pop_data),
        .opsum_fifo_full (opsum_fifo_full),
        .opsum_fifo_empty(opsum_fifo_empty)
    );

endmodule
