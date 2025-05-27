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
logic signed [15:0] temp; 
logic [7:0] add_zp; 
logic signed [15:0] scaled_value;
logic signed [15:0] temp_with_zp;


always_comb begin

    scaled_value = data_in >>> 8; // 算術右移

    // ReLU6
    if (relu_en) begin
        temp = (scaled_value > 0) ? ((scaled_value > 6) ? 6 : scaled_value) : 0; // ReLU6
    end else begin
        temp = scaled_value;
    end
end

// add zp
always_comb begin
    
    temp_with_zp = temp + 16'd128; 


    if (temp_with_zp >= 255) begin
        add_zp = 8'd255;
    end else if (temp_with_zp <= 0) begin
        add_zp = 8'd0;
    end else begin
        add_zp = temp_with_zp[7:0]; 
    end
end
// data out 
always_comb begin

    if(add_zp < 8'd0) begin

        data_out = 8'd0;

    end else if(add_zp > 8'd255) begin

        data_out = 8'd255;

    end else begin

        data_out = add_zp;

    end

end


endmodule