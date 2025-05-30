module PE(
    input clk,
    input reset,
    input [7:0] ifmap_in,
    input [7:0] weight_in,
    input prod_out_en,//只有在cs == Compute的時候會輸出給Reducer，維持四個cycle
    input weight_en,

    output logic [7:0] ifmap_out,
    output logic [15:0] prod_out
);

logic [15:0] prod_reg;
logic [7:0] weight_reg;
wire zero_f;
//store weight
always_ff @(posedge clk or negedge reset) begin
    if(reset)
        weight_reg <= 8'd0;
    else if(weight_en)
        weight_reg <= weight_in;
end

//send ifmap to next PE
always_ff @( posedge clk or negedge reset ) begin
    if(reset)
        ifmap_out <= 8'd0;
    else if(prod_out_en)
        ifmap_out <= ifmap_in;
end

//multiply ifmap and weight
//send prod_out to adder tree
assign zero_f = (weight_reg == 8'd0) || (ifmap_in == 8'd0);
assign prod_reg = (zero_f) ? 16'd0 : ifmap_in * weight_reg;

always_ff @( posedge clk or negedge reset ) begin
    if(reset)
        prod_out <= 16'd0;
    else if(prod_out_en)
        prod_out <= prod_reg;
end

endmodule