// `include "src/PPU/post_quant.sv"
// `include "src/PPU/Comparator_Qint8.sv"
// `include "src/PPU/ReLU_Qint8.sv"
// `include "define.svh"

module PPU #(
    parameter DATA_BITS = 16
)(

    input clk,
    input rst,
    input [DATA_BITS-1:0] data_in,
    input [5:0] scaling_factor,
    input maxpool_en,
    input maxpool_init,
    input relu_sel,
    input relu_en,

    output logic[7:0] data_out

);

//---------- logic declaration ----------//
logic signed [DATA_BITS-1:0] requant;
logic [7:0] add_zp;
// logic [DATA_BITS-1:0] result;
// logic [7:0] clamped;
logic [DATA_BITS-1:0] relu_data_in;
// logic [7:0] result_no_zp;
logic [7:0] max_value;
// logic [1:0] pool_cnt;

//---------- post quantization ----------//
always_comb begin

    relu_data_in = relu_en ? data_in[DATA_BITS-1] ? {DATA_BITS{1'd0}} : data_in > 16'd6 ? 16'd6 : data_in : data_in;
    requant = relu_data_in >>> scaling_factor;
    add_zp = requant[7] ? 8'd255 : requant[7:0] ^ 8'h80;

end

//---------- maxpooling ----------//
always_ff@(posedge clk) begin

    if(rst) begin

        max_value <= 8'd0;
        
    end else if(maxpool_en) begin

        if(maxpool_init) begin

            max_value <= add_zp;
        
        end else begin

            max_value <= (add_zp > max_value) ? add_zp : max_value;

        end

    end

end

//---------- ReLU ----------//
always_comb begin

    // todo: relu_sel = 0, choose post_quant,otherwise, choose maxpool
    if(relu_sel == 1'd0) begin

            data_out = add_zp;

    end else begin

            data_out = max_value;

    end

end

endmodule