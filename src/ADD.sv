module ADD(
    input [15:0] ipsum,
    input [15:0] row_in,

    output [15:0] add_out
);

assign add_out = ipsum + row_in;

endmodule