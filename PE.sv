module PE(
    input clk,
    input reset,
    input [7:0] ifmap_in,
    input [7:0] weight_in,

    output logic [7:0] ifmap_out,
    output logic [15:0] prod_out
);

logic [15:0] prod_reg;
//send ifmap to next PE
always_ff @( posedge clk or negedge reset ) begin
    if(reset)
        ifmap_out <= 8'd0;
    else
        ifmap_out <= ifmap_in;
end

//multiply ifmap and weight
//send prod_out to adder tree
assign prod_reg = ifmap_in * weight_in;

always_ff @( posedge clk or negedge reset ) begin
    if(reset)
        prod_out <= 16'd0;
    else
        prod_out <= prod_reg;
end

endmodule