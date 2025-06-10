//===========================================================================
// Module: ifmap_fifo_bank
// Description: Bank of 32 independent ifmap_fifo instances.  
//              Each FIFO supports 8-bit single push/pop and          
//              32-bit burst push via push_mod control.               
//===========================================================================
// `include "ifmap_fifo.sv"
module ifmap_fifo_bank #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 4
)(
    input  logic           clk,
    input  logic           rst_n,

    // Push interfaces (one-hot per FIFO)
    input  logic [31:0]    push_ifmap_en,        // per-FIFO push enable
    input  logic [31:0]    push_ifmap_mod,       // per-FIFO mode: 0=8-bit,1=32-bit burst
    input  logic [31:0][31:0] push_ifmap_data,   // per-FIFO 32-bit push data
    output logic [31:0]    ifmap_fifo_full,      // per-FIFO full flag

    // Pop interfaces
    input  logic [31:0]    pop_ifmap_en,         // per-FIFO pop enable
    output logic [31:0][7:0] pop_ifmap_data,     // per-FIFO 8-bit pop data
    output logic [31:0]    ifmap_fifo_empty      // per-FIFO empty flag
);

    genvar i;
    generate
        for (i = 0; i < 32; i++) begin : FIFO_ARRAY
            ifmap_fifo #(
                .WIDTH(WIDTH),
                .DEPTH(DEPTH)
            ) fifo_inst (
                .clk       (clk),
                .rst_n     (rst_n),
                .push_en   (push_ifmap_en[i]),
                .push_mod  (push_ifmap_mod[i]),
                .push_data (push_ifmap_data[i]),
                .full      (ifmap_fifo_full[i]),
                .pop_en    (pop_ifmap_en[i]),
                .pop_data  (pop_ifmap_data[i]),
                .empty     (ifmap_fifo_empty[i])
            );
        end
    endgenerate

endmodule
