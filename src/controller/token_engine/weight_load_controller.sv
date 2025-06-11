`include "../../../include/define.svh"
module weight_load_controller(
    input logic clk,
    input logic rst_n,
    input logic weight_load_state,
    input logic [1:0] layer_type, // 00: conv, 01: dwconv, 10: fc, 11: pool
    input logic [31:0] weight_GLB_base_addr, // base address of weight in GLB

    output logic [3:0] weight_load_WEB, // read enable to GLB (1 = write, 0 = read)
    output logic [31:0] weight_addr, // (count by byte) address  to GLB
    output logic [1:0] weight_load_byte_type,


    output logic weight_load_finish 
);

logic [31:0] weight_num; // total number of weights to load 
logic [31:0] weight_read_cnt; // counter for loaded weights



// weight_load_WEB
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        weight_load_WEB <= 4'b0000; // default read mode
    else if (weight_load_state)
        weight_load_WEB <= 4'b0000; // when start loading weight, set to read mode
end

always_comb begin
    case(layer_type)
        `POINTWISE: begin
            weight_num = 32'd1024; // 32*32 = 1024 weights for pointwise
        end
        `DEPTHWISE: begin
            weight_num = 32'd90; // 3*3*10 = 90 weights for depthwise
        end
        `STANDARD: begin
            weight_num = 32'd900; // 3*3*10*10 = 900 weights for standard conv
        end
        `LINEAR: begin
            weight_num = 32'd1024; // 32*32 = 1024 weights for linear layer
        end
        default: weight_num = 32'd0; // default to 0 for unsupported layer types
    endcase
end


// weight_read_cnt
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        weight_read_cnt <= 32'd0;
    else if (weight_load_state)
        weight_read_cnt <= weight_read_cnt + 32'd1; // increment counter until all weights are loaded
    else
        weight_read_cnt <= 32'd0; // reset counter when not loading weights
end

// weight_addr
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        weight_addr <= 32'd0;
    else if(weight_read_cnt==32'd0) // reset base address
        weight_addr <= weight_GLB_base_addr;
    else if (weight_load_state)
        weight_addr <= weight_addr + 32'd1; // increment counter until all weights are loaded
    else
        weight_addr <= 32'd0; // reset counter when not loading weights
end

always_comb begin
    case(weight_addr[1:0])
        2'b00: weight_load_byte_type = `LOAD_1BYTE; // load first byte
        2'b01: weight_load_byte_type = `LOAD_2BYTE; // load second byte
        2'b10: weight_load_byte_type = `LOAD_3BYTE; // load third byte
        2'b11: weight_load_byte_type = `LOAD_4BYTE; // load fourth byte
        default: weight_load_byte_type = 2'b00; // default to first byte for any other count
    endcase
end



always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        weight_load_finish <= 1'b0;
    else if (weight_read_cnt == (weight_num-32'd1))
        weight_load_finish <= 1'b1; // set finish flag when all weights are loaded
    else
        weight_load_finish <= 1'b0; // reset after 1 clock cycle
end

endmodule