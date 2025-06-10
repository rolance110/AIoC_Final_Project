//===========================================================================
// Module: opsum_fifo_bank
// Description: Bank of 32 independent opsum_fifo instances.
//              Each FIFO supports 16-bit single push and
//              16/32-bit pop via pop_mod control.
//===========================================================================

module opsum_fifo_bank #(
    parameter int WIDTH = 16,
    parameter int DEPTH = 2
)(
    input  logic             clk,
    input  logic             rst_n,

    // Push interfaces
    input  logic [31:0]            push_opsum_en,     // per-FIFO push enable
    input  logic [15:0]            push_opsum_data[31:0],   // per-FIFO 16-bit push data
    output logic [31:0]            opsum_fifo_full,   // per-FIFO full flag

    // Pop interfaces
    input  logic [31:0]            pop_opsum_en,      // per-FIFO pop enable
    input  logic [31:0]            pop_opsum_mod,     // per-FIFO mode: 0=16-bit, 1=32-bit
    output logic [31:0]            pop_opsum_data[31:0] ,    // per-FIFO 16 or 32-bit pop data
    output logic [31:0]            opsum_fifo_empty   // per-FIFO empty flag
);

    genvar i;
    generate
        for (i = 0; i < 32; i++) begin : OPSUM_FIFO_ARRAY
            opsum_fifo #(
                .WIDTH(WIDTH),
                .DEPTH(DEPTH)
            ) opsum_fifo_inst (
                .clk        (clk),
                .rst_n      (rst_n),
                .push_en    (push_opsum_en[i]),
                .push_data  (push_opsum_data[i]),
                .full       (opsum_fifo_full[i]),
                .pop_en     (pop_opsum_en[i]),
                .pop_mod    (pop_opsum_mod[i]),
                .pop_data   (pop_opsum_data[i]),
                .empty      (opsum_fifo_empty[i])
            );
        end
    endgenerate

endmodule
