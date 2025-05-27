module dma_addr_generator #(
    parameter int DATA_BYTES = 1,       // ifmap, weight, bias default 1B
    parameter int PSUM_BYTES = 2        // ofmap/psum default 2B
)(                                      
    input  logic [1:0]  layer_type,     // 0=PW,1=DW,2=STD,3=LIN  //TODO: 需補上conv linear
    input  logic [6:0]  tile_R,
    input  logic [6:0]  tile_D,
    input  logic [6:0]  tile_K,
    input  logic [6:0]  in_R, in_C,
    input  logic [6:0]  out_R, out_C,

    input  logic [31:0] base_ifmap,
    input  logic [31:0] base_weight,
    input  logic [31:0] base_bias,
    input  logic [31:0] base_ofmap,

    input  logic [6:0]  r_idx,
    input  logic [6:0]  d_idx,
    input  logic [6:0]  k_idx,

    output logic [31:0] addr_ifmap,
    output logic [31:0] addr_weight,
    output logic [31:0] addr_bias,
    output logic [31:0] addr_ofmap
);

    // Intermediate offsets
    logic [31:0] offset_ifmap;
    logic [31:0] offset_weight;
    logic [31:0] offset_bias;
    logic [31:0] offset_ofmap;

    always_comb begin
        case (layer_type)
            2'd0: begin  // Pointwise  //TODO: 更改取的方式
                // offset_ifmap  = (d_idx * tile_D * in_R * in_C) + (r_idx * tile_R * in_C);
                // offset_weight = (k_idx * tile_K * in_D) + (d_idx * tile_D);
                // offset_bias   = k_idx * tile_K;
                // offset_ofmap  = (k_idx * in_R * in_C) + (r_idx * tile_R * in_C);
               
                base_address = base_ifmap + ((r_idx * tile_R) + in_C + (tile_D * d_idx));
                ifmap_tile = 
                // addr_ifmap  = (base_ifmap  + offset_ifmap ) ;
                // addr_weight = (base_weight + offset_weight) ;
                // addr_bias   = (base_bias   + offset_bias  ) ;
                // addr_ofmap  = (base_ofmap  + offset_ofmap ) ;
            end

            2'd1: begin  // Depthwise
                offset_ifmap  = (d_idx * in_R * in_C) + (r_idx * tile_R * in_C);
                offset_weight = d_idx * 9;  // 3×3 kernel
                offset_bias   = d_idx;
                offset_ofmap  = (d_idx * out_R * out_C) + (r_idx * tile_R * out_C);

                addr_ifmap  = base_ifmap  + offset_ifmap  * DATA_BYTES;
                addr_weight = base_weight + offset_weight * DATA_BYTES;
                addr_bias   = base_bias   + offset_bias   * DATA_BYTES;
                addr_ofmap  = base_ofmap  + offset_ofmap  * PSUM_BYTES;
            end

            default: begin
                addr_ifmap  = 32'd0;
                addr_weight = 32'd0;
                addr_bias   = 32'd0;
                addr_ofmap  = 32'd0;
            end
        endcase
    end

endmodule
