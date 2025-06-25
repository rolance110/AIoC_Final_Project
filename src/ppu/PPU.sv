// `include "src/PPU/post_quant.sv"
// `include "src/PPU/Comparator_Qint8.sv"
// `include "src/PPU/ReLU_Qint8.sv"
// `include "define.svh"

module PPU #(
    parameter DATA_BITS = 32
)(

    input clk,
    input rst_n,
    input [DATA_BITS-1:0] data_in,
    input [5:0] scaling_factor, 
    input relu_en,  // connect with flag[0] (ReLU enable)
    input need_ppu,
    input [3:0] WEB,
    

    // fixme: 如果大哥的存法是{8'd0, data_out_reg_up, 8'd0, data_out_reg_down}再做修改
    output logic [DATA_BITS-1:0] data_out

);

//---------- logic declaration ----------//
// data in segmentation
logic signed [15:0] data_in_down;
logic signed [15:0] data_in_up;

// relu segmentation
logic signed [15:0] relu_down; 
logic signed [15:0] relu_up;

// requant segmentation
logic signed [15:0] requant_down;
logic signed [15:0] requant_up;

// temp with zero point segmentation
logic signed [15:0] temp_with_zp_down;
logic signed [15:0] temp_with_zp_up;

// data out reg
logic [7:0] data_out_reg_down;
logic [7:0] data_out_reg_up; 

// fixme: 若不需WEB，將註解解開
// always_comb begin
//     data_in_down = data_in[15:0];  // lower 16 bits
//     data_in_up   = data_in[31:16]; // upper 16 bits
// end

always_comb begin
    if(WEB == 4'b1111) begin
        data_in_down = data_in[15:0];  // lower 16 bits
        data_in_up   = data_in[31:16]; // upper 16 bits
    end else if(WEB == 4'b1100) begin
        data_in_down = 16'd0;          // lower 16 bits
        data_in_up   = data_in[31:16]; // upper 16 bits
    end else if(WEB == 4'b0011) begin
        data_in_down = data_in[15:0];  // lower 16 bits
        data_in_up   = 16'd0;          // upper 16 bits
    end else begin
        data_in_down = 16'd0; // lower 16 bits
        data_in_up   = 16'd0; // upper 16 bits
    end 
end

// always_comb begin

//     requant_down = data_in_down >>> scaling_factor; // requantization
//     requant_up   = data_in_up   >>> scaling_factor; // requantization

//     // ReLU6
//     // if (relu_en) begin
//     //     relu = (requant > 0) ? ((requant > 6) ? 6 : requant) : 0; // ReLU6
//     // end else begin
//     //     relu = requant;
//     // end

//     // ReLU
//     if (relu_en) begin
//         relu_down = (requant_down > 0) ? requant_down : 0; // ReLU
//         relu_up   = (requant_up > 0)   ? requant_up   : 0; // ReLU
//     end else begin
//         relu_down = requant_down;
//         relu_up   = requant_up;
//     end

// end

always_comb begin

    // ReLU6
    // if (relu_en) begin
    //     relu = (requant > 0) ? ((requant > 6) ? 6 : requant) : 0; // ReLU6
    // end else begin
    //     relu = requant;
    // end

    // ReLU
    if (relu_en) begin
        relu_down = (data_in_down > 0) ? data_in_down : 0; // ReLU
        relu_up   = (data_in_up > 0)   ? data_in_up   : 0; // ReLU
    end else begin
        relu_down = data_in_down;
        relu_up   = data_in_up;
    end

    requant_down = relu_down >>> scaling_factor; // requantization
    requant_up   = relu_up   >>> scaling_factor; // requantization


end


// add zp & data out 
always_comb begin
    
    temp_with_zp_down = requant_down + 16'd128; 
    temp_with_zp_up   = requant_up   + 16'd128;

    if (temp_with_zp_down >= 255) begin
        data_out_reg_down = 8'd255;
    end else if (temp_with_zp_down <= 0) begin
        data_out_reg_down = 8'd0;
    end else begin
        data_out_reg_down = temp_with_zp_down[7:0]; 
    end

    if(temp_with_zp_up >= 255) begin
        data_out_reg_up = 8'd255;
    end else if (temp_with_zp_up <= 0) begin
        data_out_reg_up = 8'd0;
    end else begin
        data_out_reg_up = temp_with_zp_up[7:0]; 
    end
end

// fixme: 如果大哥的存法是{8'd0, data_out_reg_up, 8'd0, data_out_reg_down}再做修改
always_comb begin
    if(need_ppu) begin
        data_out = {8'd0, data_out_reg_up, 8'd0, data_out_reg_down}; 
    end 
    else begin
        data_out = data_in; 
    end
end

endmodule