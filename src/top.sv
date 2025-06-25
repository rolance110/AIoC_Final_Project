module top(
    input logic clk,
    input logic rst_n,

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
    input  logic [31:0]  base_ofmap_i, // ipsum base same as ofmap

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

    input  logic [31:0]  glb_read_data_i // GLB read data

);

//* CONV.FIFO Interface
logic ifmap_fifo_reset; // Reset signal for IFMAP FIFO
logic [7:0] ifmap_fifo_push_data_matrix; // Data to push into IFMAP FIFO
logic [7:0] ifmap_fifo_push_mod_matrix; // Modified data to push into IFMAP FIFO
logic ifmap_fifo_push_matrix; // Push signal for IFMAP FIFO
logic ifmap_fifo_pop_matrix; // Pop signal for IFMAP FIFO
logic ifmap_fifo_full_matrix; // Full signal for IFMAP FIFO
logic ifmap_fifo_empty_matrix; // Empty signal for IFMAP FIFO

logic ipsum_fifo_reset; // Reset signal for IPSUM FIFO
logic [7:0] ipsum_fifo_push_data_matrix; // Data to push into IPSUM FIFO
logic [7:0] ipsum_fifo_push_mod_matrix; // Modified data to push into IPSUM FIFO
logic ipsum_fifo_push_matrix; // Push signal for IPSUM FIFO
logic ipsum_fifo_pop_matrix; // Pop signal for IPSUM FIFO
logic ipsum_fifo_full_matrix; // Full signal for IPSUM FIFO
logic ipsum_fifo_empty_matrix; // Empty signal for IPSUM FIFO

logic opsum_fifo_reset; // Reset signal for OPSUM FIFO
logic [7:0] opsum_fifo_push_data_matrix; // Data to push into OPSUM FIFO
logic [7:0] opsum_fifo_push_mod_matrix; // Modified data to push into OPSUM FIFO
logic opsum_fifo_push_matrix; // Push signal for OPSUM FIFO
logic opsum_fifo_pop_matrix; // Pop signal for OPSUM FIFO
logic opsum_fifo_full_matrix; // Full signal for OPSUM FIFO
logic opsum_fifo_empty_matrix; // Empty signal for OPSUM FIFO

logic [31:0] opsum_fifo_pop_data_matrix; // Data popped from OPSUM FIFO

//* CONV.PE_ARRAY Interface
logic [7:0] PE_en_matrix; // PE enable matrix
logic [7:0] PE_stall_matrix; // PE stall matrix

//* CONV.PE_ARRAY.WEIGHT Interface
logic [7:0] weight_in; // Weight input
logic [7:0] weight_load_en_matrix; // Weight load enable matrix









DLA_Controller #(
    .GLB_BYTES(`GLB_MAX_BYTES),
    .BYTES_I(`BYTES_I),
    .BYTES_W(`BYTES_W),
    .BYTES_P(`BYTES_P)
) u_DLA_Controller (
    .clk(clk),
    .rst_n(rst_n),

//* Maceo Layer Descriptor (uLD) inputs
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

//* AXI DMA Signal
    .DMA_interrupt_i(DMA_interrupt_i),
    //master interface(FIFO mem)
    .awid_m_o(awid_m_o),
    .awaddr_m_o(awaddr_m_o),
    .awlen_m_o(awlen_m_o),
    .awsize_m_o(awsize_m_o),
    .awburst_m_o(awburst_m_o),
    .awvalid_m_o(awvalid_m_o),
    .awready_m_i(awready_m_i),

    //Write data channel signals
    .wdata_m_o(wdata_m_o),
    .wstrb_m_o(wstrb_m_o),
    .wlast_m_o(wlast_m_o),
    .wvalid_m_o(wvalid_m_o),
    .wready_m_i(wready_m_i),

    //Write response channel signals
    .bid_m_i(bid_m_i),
    .bresp_m_i(bresp_m_i),
    .bvalid_m_i(bvalid_m_i),
    .bready_m_o(bready_m_o),

    //Read address channel signals
    .arid_m_o(arid_m_o),
    .araddr_m_o(araddr_m_o),
    .arlen_m_o(arlen_m_o),
    .arsize_m_o(arsize_m_o),
    .arburst_m_o(arburst_m_o),
    .arvalid_m_o(arvalid_m_o),
    .arready_m_i(arready_m_i),

    //Read data channel signals
    .rid_m_i(rid_m_i),
    .rdata_m_i(rdata_m_i),
    .rlast_m_i(rlast_m_i),
    .rvalid_m_i(rvalid_m_i),
    .rresp_m_i(rresp_m_i),
    .rready_m_o(rready_m_o),

//* Global Buffer (GLB) Interface
    .glb_addr_o(glb_addr_o),
    .glb_write_data_o(glb_write_data_o),
    .glb_web_o(glb_web_o),

    .glb_read_data_i(glb_read_data_i),

//* CONV.Need Signal
    .layer_type_o(layer_type), // Layer type output


//* CONV.FIFO Interface
    .ifmap_fifo_reset_o(ifmap_fifo_reset),
    .ifmap_fifo_push_data_matrix_o(ifmap_fifo_push_data_matrix),
    .ifmap_fifo_push_mod_matrix_o(ifmap_fifo_push_mod_matrix),
    .ifmap_fifo_push_matrix_o(ifmap_fifo_push_matrix),
    .ifmap_fifo_pop_matrix_o(ifmap_fifo_pop_matrix),
    .ifmap_fifo_full_matrix_i(ifmap_fifo_full_matrix_i),
    .ifmap_fifo_empty_matrix_i(ifmap_fifo_empty_matrix_i),

    .ipsum_fifo_reset_o(ipsum_fifo_reset_o),
    .ipsum_fifo_push_data_matrix_o(ipsum_fifo_push_data_matrix_o),
    .ipsum_fifo_push_mod_matrix_o(ipsum_fifo_push_mod_matrix_o),
    .ipsum_fifo_push_matrix_o(ipsum_fifo_push_matrix_o),
    .ipsum_fifo_pop_matrix_o(ipsum_fifo_pop_matrix_o),
    .ipsum_fifo_full_matrix_i(ipsum_fifo_full_matrix_i),
    .ipsum_fifo_empty_matrix_i(ipsum_fifo_empty_matrix_i),

    .opsum_fifo_reset_o(opsum_fifo_reset_o),
    .opsum_fifo_push_data_matrix_o(opsum_fifo_push_data_matrix_o),
    .opsum_fifo_push_mod_matrix_o(opsum_fifo_push_mod_matrix_o),
    .opsum_fifo_push_matrix_o(opsum_fifo_push_matrix_o),
    .opsum_fifo_pop_matrix_o(opsum_fifo_pop_matrix_o),
    .opsum_fifo_full_matrix_i(opsum_fifo_full_matrix_i),
    .opsum_fifo_empty_matrix_i(opsum_fifo_empty_matrix_i),

    .opsum_fifo_pop_data_matrix_i(opsum_fifo_pop_data_matrix_i),

//* CONV.PE_ARRAY Interface
    .PE_en_matrix_o(PE_en_matrix_o),
    .PE_stall_matrix_o(PE_stall_matrix_o),

//* CONV.PE_ARRAY.WEIGHT Interface
    .weight_in(weight_in),
    .weight_load_en_matrix_o(weight_load_en_matrix)
);


// 實例化 conv_unit
    conv_unit u_conv_unit (
        .clk(clk),
        .rst_n(rst_n),

//* reset
        .ifmap_fifo_reset_i(ifmap_fifo_reset),
        .ipsum_fifo_reset_i(ipsum_fifo_reset),
        .opsum_fifo_reset_i(opsum_fifo_reset),


        .layer_type(layer_type), // 與 token_engine 共用相同的 layer_type_i
        .push_ifmap_en(ifmap_fifo_push_matrix),
        .push_ifmap_mod(ifmap_fifo_push_mod_matrix),
        .push_ifmap_data(ifmap_fifo_push_data_matrix), 
        .pop_ifmap_en(ifmap_fifo_pop_matrix),
        .weight_in(weight_in),
        .weight_load_en(weight_load_en_matrix),
        .PE_en_matrix(PE_en_matrix),
        .PE_stall_matrix(PE_stall_matrix),
        .push_ipsum_en(ipsum_fifo_push_matrix),
        .push_ipsum_mod(ipsum_fifo_push_mod_matrix),
        .push_ipsum_data(ipsum_fifo_push_data_matrix), 
        .pop_ipsum_en(ipsum_fifo_pop_matrix),
        .ipsum_read_en(ipsum_read_en),
        .ipsum_add_en(ipsum_add_en),
        .opsum_push_en(opsum_fifo_push_matrix),
        .opsum_pop_en(opsum_fifo_pop_matrix),
        .opsum_pop_mod(opsum_fifo_push_mod_matrix), // 使用 push_mod 作為 pop_mod
        .ifmap_fifo_full(ifmap_fifo_full),
        .ifmap_fifo_empty(ifmap_fifo_empty),
        .ipsum_fifo_full(ipsum_fifo_full),
        .ipsum_fifo_empty(ipsum_fifo_empty),
        .opsum_fifo_full(opsum_fifo_full),
        .opsum_fifo_empty(opsum_fifo_empty),
        .opsum_pop_data(opsum_pop_data)
    );



endmodule

