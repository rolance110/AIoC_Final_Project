module DLA_Controller #(
    parameter int GLB_BYTES  = `GLB_MAX_BYTES, // Global SRAM capacity in bytes
    parameter int BYTES_I    = `BYTES_I, //input feature map bytes
    parameter int BYTES_W    = `BYTES_W, //weight bytes
    parameter int BYTES_P    = `BYTES_P  //partial sum bytes
) (
    input  logic         clk,
    input  logic         rst_n
);

//* Layer Descriptor (uLD) (First Stage)
    layer_decoder layer_decoder_dut (
        .clk(clk),
        .rst_n(rst_n),
        .uLD_en_i(uLD_en_i),
        .layer_id_i(layer_id_i),
        .layer_type_i(layer_type_i),
        .in_R_i(in_R_i), .in_C_i(in_C_i),
        .in_D_i(in_D_i), .out_K_i(out_K_i),
        .stride_i(stride_i),
        .pad_T_i(pad_T_i), .pad_B_i(pad_B_i),
        .pad_L_i(pad_L_i), .pad_R_i(pad_R_i),
        .base_ifmap_i(base_ifmap_i),
        .base_weight_i(base_weight_i),
        .base_bias_i(base_bias_i),
        .base_ofmap_i(base_ofmap_i),
        .flags_i(flags_i),
        .quant_scale_i(quant_scale_i),

        .layer_id_o(layer_id_o),
        .layer_type_o(layer_type_o),
        .padded_R_o(padded_R_o), .padded_C_o(padded_C_o),
        .in_D_o(in_D_o), .out_K_o(out_K_o),
        .stride_o(stride_o),
        .pad_H_o(pad_H_o), .pad_B_o(pad_B_o),
        .pad_L_o(pad_L_o), .pad_R_o(pad_R_o),
        .kH_o(kH_o), .kW_o(kW_o),
        .base_ifmap_o(base_ifmap_o),
        .base_weight_o(base_weight_o),
        .base_bias_o(base_bias_o),
        .base_ofmap_o(base_ofmap_o),
        .flags_o(flags_o),
        .quant_scale_o(quant_scale_o),
        .tile_n_o(tile_n_o),
        .tile_D_o(tile_D_o), .tile_K_o(tile_K_o),
        .tile_D_f_o(tile_D_f_o), .tile_K_f_o(tile_K_f_o),
        .out_R_o(out_R_o), .out_C_o(out_C_o)
    );
//* Tile Scheduler (Second Stage)

// DUT Instance
Tile_Scheduler #(
    .BYTES_I(`BYTES_I),
    .BYTES_W(`BYTES_W),
    .BYTES_P(`BYTES_P)
) dut (
    .clk(clk),
    .rst_n(rst_n),

    .uLD_en_i(uLD_en_i),
    .kH_i(kH_i),
    .kW_i(kW_i),

    .tile_n_i(tile_n_i),
    .tile_D_i(tile_D_i),
    .tile_K_i(tile_K_i),
    .tile_D_f_i(tile_D_f_i),
    .tile_K_f_i(tile_K_f_i),

    .layer_type_i(layer_type_i),
    .stride_i(stride_i),

    .pad_T_i(pad_T_i),
    .pad_B_i(pad_B_i),
    .pad_L_i(pad_L_i),
    .pad_R_i(pad_R_i),

    .in_R_i(in_R_i),
    .in_C_i(in_C_i),
    .in_D_i(in_D_i),

    .out_K_i(out_K_i),
    .out_R_i(out_R_i),
    .out_C_i(out_C_i),

    .base_ifmap_i(base_ifmap_i),
    .base_weight_i(base_weight_i),
    .base_bias_i(base_bias_i),
    .base_ofmap_i(base_ofmap_i),
    .flags_i(flags_i),

    // DMA Interface
    .dma_enable_o(dma_enable_o), 
    .dma_read_o(dma_read_o), 
    .dma_addr_o(dma_addr_o), 
    .dma_len_o(dma_len_o), 
    .dma_interrupt_i(dma_interrupt_i), 

    // Pass Interface
    .pass_start_o(pass_start_o), 
    .pass_done_i(pass_done_i), 

   // GLB Interface
   .GLB_weight_base_addr_o(GLB_weight_base_addr_o), 
   .GLB_ifmap_base_addr_o(GLB_ifmap_base_addr_o), 
   .GLB_opsum_base_addr_o(GLB_opsum_base_addr_o), 

   .pad_T_o(pad_T_o), 
   .pad_B_o(pad_B_o), 
   .pad_L_o(pad_L_o), 
   .pad_R_o(pad_R_o), 
   // Stride
   .stride_o(stride_o), 
   // Layer type
   .layer_type_o(layer_type_o), 
   // Flags
   .flags_o(flags_o), 
   // Output size
   .out_R_o(out_R_o), 
   .out_C_o(out_C_o),
   .tile_reach_max_o(tile_reach_max_o)
);

TS_AXI_wrapper TS_AXI_wrapper_dut (
        .clk(clk),
        .rst_n(rst_n),
        .DMA_src(DMA_src),
        .DMA_dest(DMA_dest),
        .DMA_len(DMA_len),
        .DMA_en(DMA_en),
        .DMA_interrupt(DMA_interrupt),
        .awid_m(awid_m),
        .awaddr_m(awaddr_m),
        .awlen_m(awlen_m),
        .awsize_m(awsize_m),
        .awburst_m(awburst_m),
        .awvalid_m(awvalid_m),
        .awready_m(awready_m),
        .wdata_m(wdata_m),
        .wstrb_m(wstrb_m),
        .wlast_m(wlast_m),
        .wvalid_m(wvalid_m),
        .wready_m(1'b1),
        .bid_m(bid_m),
        .bresp_m(bresp_m),
        .bvalid_m(1'b1),
        .bready_m(bready_m),
        .arid_m(arid_m),
        .araddr_m(araddr_m),
        .arlen_m(arlen_m),
        .arsize_m(arsize_m),
        .arburst_m(arburst_m),
        .arvalid_m(arvalid_m),
        .arready_m(arready_m),
        .rid_m(rid_m),
        .rdata_m(rdata_m),
        .rlast_m(rlast_m),
        .rvalid_m(rvalid_m),
        .rresp_m(rresp_m),
        .rready_m(rready_m)
    );





endmodule