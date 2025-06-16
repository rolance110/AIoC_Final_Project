//===========================================================================
// Module: ipsum_fifo_bank
// Description: Bank of 32 independent ipsum_fifo instances.  
//              Each FIFO supports 16-bit single push/pop and          
//              32-bit burst push via push_mod control.               
//===========================================================================
// `include "ipsum_fifo.sv"
module ipsum_fifo_bank #(
    parameter int WIDTH = 16,
    parameter int DEPTH = 2
)(
    input  logic           clk,
    input  logic           rst_n,

    // Push interfaces (one-hot per FIFO) 
    input  logic [31:0]    push_ipsum_en,        // per-FIFO push enable
    input  logic [31:0]    push_ipsum_mod,       // per-FIFO mode: 0=16-bit,1=32-bit burst
    input  logic [31:0] push_ipsum_data [31:0],   // broadcast 32-bit push data to 32 FIFOs
    output logic [31:0]    ipsum_fifo_full,      // per-FIFO full flag

    // Pop interfaces
    input  logic [31:0]    pop_ipsum_en,         // per-FIFO pop enable
    output logic [15:0] pop_ipsum_data [31:0],     // per-FIFO 16-bit pop data
    output logic [31:0]    ipsum_fifo_empty      // per-FIFO empty flag
);

    genvar i;
    generate
        for (i = 0; i < 32; i++) begin : FIFO_ARRAY
            ipsum_fifo #(
                .WIDTH(WIDTH),
                .DEPTH(DEPTH)
            ) ipsum_fifo_inst (
                .clk       (clk),
                .rst_n     (rst_n),
                .push_en   (push_ipsum_en[i]),
                .push_mod  (push_ipsum_mod[i]),
                .push_data (push_ipsum_data[i]),
                .full      (ipsum_fifo_full[i]),
                .pop_en    (pop_ipsum_en[i]),
                .pop_data  (pop_ipsum_data[i]),
                .empty     (ipsum_fifo_empty[i])
            );
        end
    endgenerate

endmodule
