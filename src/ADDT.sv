module ADDT(
    input [15:0] ipsum,
    input [15:0] row1,
    input [15:0] row2,
    input [15:0] row3,

    output logic [15:0] addt_out
);

always_comb begin 
    addt_out = ipsum + row1 + row2 + row3;
end

endmodule