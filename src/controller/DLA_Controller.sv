module DLA_Controller #(
    parameter int GLB_BYTES  = `GLB_MAX_BYTES, // Global SRAM capacity in bytes
    parameter int BYTES_I    = `BYTES_I, //input feature map bytes
    parameter int BYTES_W    = `BYTES_W, //weight bytes
    parameter int BYTES_P    = `BYTES_P  //partial sum bytes
) (
    input  logic         clk,
    input  logic         rst_n,

//* Maceo Layer Descriptor (uLD) inputs
    input logic uLD_en_i, // uLD enable signal
    input  logic [5:0]   layer_id_i,
    input  logic [1:0]   layer_type_i,     // 0=PW,1=DW,2=STD,3=LIN

    input  logic [7:0]   in_R_i, in_C_i,   // input H,W
    input  logic [10:0]   in_D_i, out_K_i,  // input/out channels

    input  logic [1:0]   stride_i,         // stride
    input  logic [1:0]   pad_T_i, pad_B_i, pad_L_i, pad_R_i,

    input  logic [31:0]  base_ifmap_i,
    input  logic [31:0]  base_weight_i,
    input  logic [31:0]  base_bias_i,
    input  logic [31:0]  base_ofmap_i, // base ipsum same as ofmap

    input  logic [3:0]   flags_i,         // bit0=relu, 1=linear, 2=skip,3=bias
    input  logic [7:0]   quant_scale_i,

//* AXI DMA Signal
    input logic DMA_interrupt_i, // signal to restart DMA transfer

	//master interface(FIFO mem)
	//Write address channel signals DM
    output logic    [`ID_WIDTH-1:0]      awid_m_o,    	// Write address ID tag
    output logic    [`ADDR_WIDTH-1:0]    awaddr_m_o,  	// Write address
    output logic    [`LEN_WIDTH-1:0]     awlen_m_o,   	// Write address burst length
    output logic    [`SIZE_WIDTH-1:0]    awsize_m_o,  	// Write address burst size
    output logic    [`BURST_WIDTH-1:0]   awburst_m_o, 	// Write address burst type
    output logic                        awvalid_m_o,  	// Write address valid
    input  logic                        awready_m_i,  	// Write address ready
	
    //Write data channel signals	
    output logic    [`DATA_WIDTH-1:0]    wdata_m_o,   	// Write data
    output logic    [`DATA_WIDTH/8-1:0]  wstrb_m_o,   	// Write strobe
    output logic                        wlast_m_o,    	// Write last
    output logic                        wvalid_m_o,   	// Write valid
    input  logic                        wready_m_i,   	// Write ready
	
    //Write response channel signals	
    input  logic    [`ID_WIDTH-1:0]      bid_m_i,     	// Write response ID tag
    input  logic    [`BRESP_WIDTH-1:0]   bresp_m_i,   	// Write response
    input  logic                        bvalid_m_i,   	// Write response valid
    output logic                        bready_m_o,   	// Write response ready
	 
    //Read address channel signals	
    output logic    [`ID_WIDTH-1:0]      arid_m_o,    	// Read address ID tag
    output logic    [`ADDR_WIDTH-1:0]    araddr_m_o,  	// Read address
    output logic    [`LEN_WIDTH-1:0]     arlen_m_o,   	// Read address burst length
    output logic    [`SIZE_WIDTH-1:0]    arsize_m_o,  	// Read address burst size
    output logic    [`BURST_WIDTH-1:0]   arburst_m_o, 	// Read address burst type
    output logic                        arvalid_m_o,  	// Read address valid
    input  logic                        arready_m_i,  	// Read address ready
    //Read data channel signals	
    input  logic    [`ID_WIDTH-1:0]      rid_m_i,     	// Read ID tag
    input  logic    [`DATA_WIDTH-1:0]    rdata_m_i,   	// Read data
    input  logic                        rlast_m_i,    	// Read last
    input  logic                        rvalid_m_i,   	// Read valid
    input  logic    [`RRESP_WIDTH-1:0]   rresp_m_i,   	// Read response
    output logic                        rready_m_o,   	// Read ready



//* Global Buffer (GLB) Interface
    output logic [31:0]  glb_addr_o, // GLB address
    output logic [31:0]  glb_write_data_o, // GLB write data
    output logic [3:0]   glb_web_o, // GLB write enable

    input  logic [31:0]  glb_read_data_i, // GLB read data

//* CONV.Need Signal
    output logic [1:0] layer_type_o, // Layer type output

//* CONV.FIFO Interface
    output logic ifmap_fifo_reset_o, // Reset signal for IFMAP FIFO
    output logic [31:0] ifmap_fifo_push_data_matrix_o [31:0] , // Data to push into IFMAP FIFO
    output logic [31:0] ifmap_fifo_push_mod_matrix_o, // Modified data to push into IFMAP FIFO
    output logic [31:0] ifmap_fifo_push_matrix_o, // Push signal for IFMAP FIFO
    output logic [31:0] ifmap_fifo_pop_matrix_o, // Pop signal for IFMAP FIFO
    input  logic [31:0] ifmap_fifo_full_matrix_i, // Full signal for IFMAP FIFO
    input  logic [31:0] ifmap_fifo_empty_matrix_i, // Empty signal for IFMAP FIFO

    output logic ipsum_fifo_reset_o, // Reset signal for IPSUM FIFO
    output logic [31:0] ipsum_fifo_push_data_matrix_o [31:0] , // Data to push into IPSUM FIFO
    output logic [31:0] ipsum_fifo_push_mod_matrix_o, // Modified data to push into IPSUM FIFO
    output logic [31:0] ipsum_fifo_push_matrix_o, // Push signal for IPSUM FIFO
    output logic [31:0] ipsum_fifo_pop_matrix_o, // Pop signal for IPSUM FIFO
    input  logic [31:0] ipsum_fifo_full_matrix_i, // Full signal for IPSUM FIFO
    input  logic [31:0] ipsum_fifo_empty_matrix_i, // Empty signal for IPSUM FIFO

    output logic opsum_fifo_reset_o, // Reset signal for OPSUM FIFO
    output logic [31:0] opsum_fifo_push_data_matrix_o [31:0] , // Data to push into OPSUM FIFO
    output logic [31:0] opsum_fifo_push_mod_matrix_o, // Modified data to push into OPSUM FIFO
    output logic [31:0] opsum_fifo_push_matrix_o, // Push signal for OPSUM FIFO
    output logic [31:0] opsum_fifo_pop_matrix_o, // Pop signal for OPSUM FIFO
    input  logic [31:0] opsum_fifo_full_matrix_i, // Full signal for OPSUM FIFO
    input  logic [31:0] opsum_fifo_empty_matrix_i, // Empty signal for OPSUM FIFO

    input logic [31:0] opsum_fifo_pop_data_matrix_i [31:0], // Data popped from OPSUM FIFO

//* CONV.PE_ARRAY Interface
    output logic PE_en_matrix_o [31:0][31:0] , // PE enable matrix
    output logic PE_stall_matrix_o [31:0][31:0] , // PE stall matrix

//* CONV.PE_ARRAY.WEIGHT Interface
    output logic [7:0] weight_in_o, // Weight input
    output logic weight_load_en_matrix_o [31:0][31:0],  // Weight load enable matrix
    
    output logic pass_start, // Pass start signal
    output logic pass_done // Pass done signal
);

//* After Layer Decoder Buffer Signal
logic [5:0] layer_id;

logic [7:0] padded_R, padded_C;
logic [10:0] in_D, out_K;
logic [1:0] stride;
logic [1:0] pad_T, pad_B, pad_L, pad_R;
logic [1:0] kH, kW;
logic [31:0] base_ifmap, base_weight, base_bias, base_ipsum, base_ofmap;
logic [3:0] flags;
logic [5:0] quant_scale;
logic [31:0] tile_n;
logic [7:0] tile_D, tile_K, tile_D_f, tile_K_f;

logic [7:0] in_R, in_C; // Input size
logic [7:0] out_R, out_C;


//* Layer Descriptor (uLD) (First Stage)
    Layer_Decoder #(
        .GLB_BYTES(`GLB_MAX_BYTES),
        .BYTES_I(`BYTES_I),
        .BYTES_W(`BYTES_W),
        .BYTES_P(`BYTES_P)
    ) layer_decoder_dut (
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

        .layer_id_o(layer_id),
        .layer_type_o(layer_type_o),

        .padded_R_o(padded_R), .padded_C_o(padded_C),
        .in_D_o(in_D), .out_K_o(out_K),

        .stride_o(stride),
        .pad_T_o(pad_T), .pad_B_o(pad_B),
        .pad_L_o(pad_L), .pad_R_o(pad_R),

        .kH_o(kH), .kW_o(kW),

        .base_ifmap_o(base_ifmap),
        .base_weight_o(base_weight),
        .base_bias_o(base_bias),
        .base_ofmap_o(base_ofmap),

        .flags_o(flags),
        .quant_scale_o(quant_scale),

        .tile_n_o(tile_n),
        .tile_D_o(tile_D), .tile_K_o(tile_K),
        .tile_D_f_o(tile_D_f), .tile_K_f_o(tile_K_f),

        .in_R_o(in_R), .in_C_o(in_C),
        .out_R_o(out_R), .out_C_o(out_C)
    );

//* Tile Scheduler (Second Stage)
logic DMA_enable; // DMA enable signal
logic DMA_read; // DMA read signal
logic [31:0] DMA_addr; // DMA address
logic [31:0] DMA_len; // DMA length
// logic pass_start; // Pass start signal
// logic pass_done; // Pass done signal
logic [31:0] GLB_weight_base_addr; // GLB weight base address
logic [31:0] GLB_ifmap_base_addr; // GLB ifmap base address
logic [31:0] GLB_opsum_base_addr; // GLB opsum base address
logic [31:0] GLB_ipsum_base_addr; // GLB ipsum base address
logic [31:0] GLB_bias_base_addr; // GLB bias base

logic [31:0] On_real; // Output channels
logic [7:0] OC_real; // Output channels real
logic [7:0] IC_real; // Input channels real

logic [31:0] dma_src; // DMA source address
logic [31:0] dma_dest; // DMA destination address
logic [31:0] dma_len; // DMA length
logic dma_enable;


logic [7:0] scaling_factor; // Scaling factor for quantization
logic tile_reach_max;
// DUT Instance

logic uLD_buffer_OK;
always_ff@(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        uLD_buffer_OK <= 1'b0; // Default to PW layer
    end 
    else if(uLD_en_i) begin
        uLD_buffer_OK <= uLD_en_i; // Update layer type from uLD
    end
end
logic [31:0] dma_addr;
logic dma_read;
Tile_Scheduler #(
    .BYTES_I(`BYTES_I),
    .BYTES_W(`BYTES_W),
    .BYTES_P(`BYTES_P)
) dut_TS (
    .clk(clk),
    .rst_n(rst_n),

    .uLD_en_i(uLD_buffer_OK),

    .kH_i(kH),
    .kW_i(kW),

    .tile_n_i(tile_n),
    .tile_D_i(tile_D),
    .tile_K_i(tile_K),
    .tile_D_f_i(tile_D_f),
    .tile_K_f_i(tile_K_f),

    .layer_type_i(layer_type_o),
    .stride_i(stride),
    .pad_T_i(pad_T),
    .pad_B_i(pad_B),
    .pad_L_i(pad_L),
    .pad_R_i(pad_R),

    .in_R_i(in_R),
    .in_C_i(in_C),
    .in_D_i(in_D),

    .out_K_i(out_K),
    .out_R_i(out_R),
    .out_C_i(out_C),

    .base_ifmap_i(base_ifmap),
    .base_weight_i(base_weight),
    .base_ipsum_i(base_ipsum),
    .base_bias_i(base_bias),
    .base_ofmap_i(base_ofmap),

    .flags_i(flags),

    // DMA Interface
    
    .dma_enable_o(dma_enable), 
    .dma_src_o(dma_src), 
    .dma_dest_o(dma_dest),
    .dma_len_o(dma_len), 

    .dma_interrupt_i(DMA_interrupt_i), 

    .dma_read_o(dma_read), 
    .dma_addr_o(dma_addr), 
    

    // Pass Interface
    .pass_start_o(pass_start), 
    .pass_done_i(pass_done), 

   // GLB Interface
   .GLB_weight_base_addr_o(GLB_weight_base_addr), 
   .GLB_ifmap_base_addr_o(GLB_ifmap_base_addr), 
   .GLB_opsum_base_addr_o(GLB_opsum_base_addr), 
   .GLB_bias_base_addr_o(GLB_bias_base_addr),
   .GLB_ipsum_base_addr_o(GLB_ipsum_base_addr),

    .On_real_o(On_real),
    .OC_real_o(OC_real),
    .IC_real_o(IC_real),

   .tile_reach_max_o(tile_reach_max)
);

TS_AXI_wrapper TS_AXI_wrapper_dut (
        .clk(clk),
        .rst_n(rst_n),

        .DMA_src_i(dma_src),
        .DMA_dest_i(dma_dest),
        .DMA_len_i(dma_len),
        .DMA_en_i(dma_enable),

        .DMA_interrupt_i(DMA_interrupt_i),

        .awid_m_o(awid_m_o),
        .awaddr_m_o(awaddr_m_o),
        .awlen_m_o(awlen_m_o),
        .awsize_m_o(awsize_m_o),
        .awburst_m_o(awburst_m_o),
        .awvalid_m_o(awvalid_m_o),
        .awready_m_i(awready_m_i),

        .wdata_m_o(wdata_m_o),
        .wstrb_m_o(wstrb_m_o),
        .wlast_m_o(wlast_m_o),
        .wvalid_m_o(wvalid_m_o),
        .wready_m_i(wready_m_i),

        .bid_m_i(bid_m_i),
        .bresp_m_i(bresp_m_i),
        .bvalid_m_i(bvalid_m_i),
        .bready_m_o(bready_m_o),

        .arid_m_o(arid_m_o),
        .araddr_m_o(araddr_m_o),
        .arlen_m_o(arlen_m_o),
        .arsize_m_o(arsize_m_o),
        .arburst_m_o(arburst_m_o),
        .arvalid_m_o(arvalid_m_o),
        .arready_m_i(arready_m_i),

        .rid_m_i(rid_m_i),
        .rdata_m_i(rdata_m_i),
        .rlast_m_i(rlast_m_i),
        .rvalid_m_i(rvalid_m_i),
        .rresp_m_i(rresp_m_i),
        .rready_m_o(rready_m_o)
    );


//* ==========================================================================
    logic is_bias; // 是否有 bias
    assign is_bias = 1'b0; // flags[3] = 1 => 有 bias
    logic [31:0] Already_Compute_Row; // 已經計算過的行數, 主要用於 Depthwise layer 的 padding 計算
    assign Already_Compute_Row = 32'd0; // 預設為 0, 代表沒有已經計算過的行數
    logic n_tile_is_first; // 是否為第一個 tile
    assign n_tile_is_first = 1'd1; // 預設為 1, 代表第一個 tile
    logic n_tile_is_last; // 是否為最後一個 tile
    assign n_tile_is_last = 1'd0; // 預設為 0, 代表最後一個 tile
    logic Need_PPU;
    assign Need_PPU = 1'b0; // 預設為 0, 代表不需要 PPU
    //FIXME: assign is_bias = flags[3] && first_n_tile; // flags[3] = 1 => 有 bias
//* ==========================================================================



token_engine u_token_engine (
        .clk(clk),
        .rst_n(rst_n),
        .pass_start_i(pass_start),
        .pass_done_o(pass_done),
        .layer_type_i(layer_type_o),
        .weight_GLB_base_addr_i(GLB_weight_base_addr),
        .ifmap_GLB_base_addr_i(GLB_ifmap_base_addr),
        .ipsum_GLB_base_addr_i(GLB_ipsum_base_addr), 
        .bias_GLB_base_addr_i(GLB_bias_base_addr),
        .opsum_GLB_base_addr_i(GLB_opsum_base_addr),
        .flags_i(flags),
        .scaling_factor_i(quant_scale), // scaling factor
        .is_bias_i(is_bias), 
        .tile_n_i(tile_n),
        .stride_i(stride), // stride 設定
        .in_C_i(in_C),
        .in_R_i(in_R),
        .pad_R_i(pad_R),
        .pad_L_i(pad_L),
        .pad_T_i(pad_T),
        .pad_B_i(pad_B),
        .out_C_i(out_C),
        .out_R_i(out_R),
        .IC_real_i(IC_real),
        .OC_real_i(OC_real),
        .On_real_i(On_real),
    //* SRAM input
        .glb_read_data_i(glb_read_data_i),
    //* FIFO input    
        .opsum_fifo_pop_data_matrix_i(opsum_fifo_pop_data_matrix_i),
        
        .n_tile_is_first_i(n_tile_is_first),
        .n_tile_is_last_i(n_tile_is_last),
        .Already_Compute_Row_i(Already_Compute_Row), // Depthwise layer 會需要根據這個訊號去往上計數 => 確認是否需要 top pad, bottom pad
        .Need_PPU_i(Need_PPU), // 是否需要 PPU


//* to GLB
        .glb_web_o(glb_web_o),
        .glb_addr_o(glb_addr_o),
        .glb_write_data_o(glb_write_data_o),

//* to conv.pe_array
        .PE_en_matrix_o(PE_en_matrix_o),
        .PE_stall_matrix_o(PE_stall_matrix_o),
//* to conv.pe_array.weight 
        .weight_in_o(weight_in_o),
        .weight_load_en_matrix_o(weight_load_en_matrix_o),
//* to FIFO
        .ifmap_fifo_reset_o(ifmap_fifo_reset_o),
        .ifmap_fifo_push_matrix_o(ifmap_fifo_push_matrix_o),
        .ifmap_fifo_push_mod_matrix_o(ifmap_fifo_push_mod_matrix_o),
        .ifmap_fifo_pop_matrix_o(ifmap_fifo_pop_matrix_o),
        .ifmap_fifo_push_data_matrix_o(ifmap_fifo_push_data_matrix_o),
        .ipsum_fifo_reset_o(ipsum_fifo_reset_o),
        .ipsum_fifo_push_matrix_o(ipsum_fifo_push_matrix_o),
        .ipsum_fifo_push_mod_matrix_o(ipsum_fifo_push_mod_matrix_o),
        .ipsum_fifo_push_data_matrix_o(ipsum_fifo_push_data_matrix_o),
        .ipsum_fifo_pop_matrix_o(ipsum_fifo_pop_matrix_o),
        .opsum_fifo_reset_o(opsum_fifo_reset_o),
        .opsum_fifo_push_matrix_o(opsum_fifo_push_matrix_o),
        .opsum_fifo_push_mod_matrix_o(opsum_fifo_push_mod_matrix_o),
        .opsum_fifo_push_data_matrix_o(opsum_fifo_push_data_matrix_o),
        .opsum_fifo_pop_matrix_o(opsum_fifo_pop_matrix_o),
//* from FIFO
        .ifmap_fifo_full_matrix_i(ifmap_fifo_full_matrix_i),
        .ifmap_fifo_empty_matrix_i(ifmap_fifo_empty_matrix_i),
        .ipsum_fifo_full_matrix_i(ipsum_fifo_full_matrix_i),
        .ipsum_fifo_empty_matrix_i(ipsum_fifo_empty_matrix_i),
        .opsum_fifo_full_matrix_i(opsum_fifo_full_matrix_i),
        .opsum_fifo_empty_matrix_i(opsum_fifo_empty_matrix_i)
);



endmodule