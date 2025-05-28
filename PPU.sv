// `include "src/PPU/post_quant.sv"
// `include "src/PPU/Comparator_Qint8.sv"
// `include "src/PPU/ReLU_Qint8.sv"
// `include "define.svh"

module PPU #(
    parameter DATA_BITS = 16
)(

    input clk,
    input rst,
    input signed [DATA_BITS-1:0] data_in,
    input [5:0] scaling_factor,
    input relu_en,

    output logic[7:0] data_out

);

//---------- logic declaration ----------//
logic signed [15:0] relu; 
logic [7:0] add_zp; 
logic signed [15:0] requant;
logic signed [15:0] temp_with_zp;


always_comb begin

    requant = data_in >>> 8; 

    // ReLU6
    // if (relu_en) begin
    //     relu = (requant > 0) ? ((requant > 6) ? 6 : requant) : 0; // ReLU6
    // end else begin
    //     relu = requant;
    // end

    // ReLU
    if (relu_en) begin
        relu = (requant > 0) ? requant : 0; // ReLU6
    end else begin
        relu = requant;
    end

end

// add zp & data out 
always_comb begin
    
    temp_with_zp = relu + 16'd128; 


    if (temp_with_zp >= 255) begin
        data_out = 8'd255;
    end else if (temp_with_zp <= 0) begin
        data_out = 8'd0;
    end else begin
        data_out = temp_with_zp[7:0]; 
    end
end

endmodule
