`include "../include/AXI_define.svh"
module top (
    input clk,
    input rst_n,
	//DRAM
    output logic DRAM_CSn,      //DRAM chip select
    output logic [3:0] DRAM_WEn, //write enable
    output logic DRAM_RASn,     //row access strobe
    output logic DRAM_CASn,     //column access strobe
    output logic [10:0]DRAM_A,  //DRAM address .    
	output logic [31:0]DRAM_D,  //DRAM data .    
	input [31:0] DRAM_Q,    //DRAM data 
	input DRAM_valid,
    input uLD_en_i, // uLD enable signal
    input [5:0]   layer_id_i,
    input [1:0]   layer_type_i,     // 0=PW,1=DW,2=STD,3=LIN

    input  [7:0]   in_R_i, in_C_i,   // input H,W
    input  [10:0]   in_D_i, out_K_i,  // input/out channels

    input  [1:0]   stride_i,         // stride
    input  [1:0]   pad_T_i, pad_B_i, pad_L_i, pad_R_i,

    input  [31:0]  base_ifmap_i,
    input  [31:0]  base_weight_i,
    input  [31:0]  base_bias_i,
    input  [31:0]  base_ofmap_i, // ipsum base same as ofmap

    input  [3:0]   flags_i,         // bit0=relu, 1=linear, 2=skip,3=bias
    input  [7:0]   quant_scale_i,
    output logic pass_done_o
);


//==========================================//
// M0: DSC M1: DMA
//==========================================//
//DSC signal
logic [31:0]  glb_addr_o_dsc; // GLB address
logic [31:0]  glb_write_data_o_dsc; // GLB write data
logic [3:0]   glb_web_o_dsc; // GLB write enable
logic [31:0]  glb_read_data_i_dsc; // GLB read data
logic PASS_START;
// logic pass_done_o;



//SLAVE INTERFACE FOR MASTERS
//WRITE ADDRESS
logic [`AXI_ID_BITS-1:0] AWID_M0;
logic [`AXI_ADDR_BITS-1:0] AWADDR_M0;
logic [`AXI_LEN_BITS-1:0] AWLEN_M0;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_M0;
logic [1:0] AWBURST_M0;
logic AWVALID_M0;
logic AWREADY_M0;
//WRITE DATA
logic [`AXI_DATA_BITS-1:0] WDATA_M0;
logic [`AXI_STRB_BITS-1:0] WSTRB_M0;
logic WLAST_M0;
logic WVALID_M0;
logic WREADY_M0;
//WRITE RESPONSE
logic [`AXI_ID_BITS-1:0] BID_M0;
logic [1:0] BRESP_M0;
logic BVALID_M0;
logic BREADY_M0;
//READ ADDRESS1
logic [`AXI_ID_BITS-1:0] ARID_M0;
logic [`AXI_ADDR_BITS-1:0] ARADDR_M0;
logic [`AXI_LEN_BITS-1:0] ARLEN_M0;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0;
logic [1:0] ARBURST_M0;
logic ARVALID_M0;
logic ARREADY_M0;
//READ DATA0
logic [`AXI_ID_BITS-1:0] RID_M0;
logic [`AXI_DATA_BITS-1:0] RDATA_M0;
logic [1:0] RRESP_M0;
logic RLAST_M0;
logic RVALID_M0;
logic RREADY_M0;

//READ ADDRESS2
logic [`AXI_ID_BITS-1:0] ARID_M1;
logic [`AXI_ADDR_BITS-1:0] ARADDR_M1;
logic [`AXI_LEN_BITS-1:0] ARLEN_M1;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1;
logic [1:0] ARBURST_M1;
logic ARVALID_M1;
logic ARREADY_M1;
//READ DATA1
logic [`AXI_ID_BITS-1:0] RID_M1;
logic [`AXI_DATA_BITS-1:0] RDATA_M1;
logic [1:0] RRESP_M1;
logic RLAST_M1;
logic RVALID_M1;
logic RREADY_M1;


//WRITE ADDRESS
logic [`AXI_ID_BITS-1:0] AWID_M1;
logic [`AXI_ADDR_BITS-1:0] AWADDR_M1;
logic [`AXI_LEN_BITS-1:0] AWLEN_M1;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1;
logic [1:0] AWBURST_M1;
logic AWVALID_M1;
logic AWREADY_M1;
//WRITE DATA
logic [`AXI_DATA_BITS-1:0] WDATA_M1;
logic [`AXI_STRB_BITS-1:0] WSTRB_M1;
logic WLAST_M1;
logic WVALID_M1;
logic WREADY_M1;
//WRITE RESPONSE
logic [`AXI_ID_BITS-1:0] BID_M1;
logic [1:0] BRESP_M1;
logic BVALID_M1;
logic BREADY_M1;
//==========================================//
// S0: DMA S1: SRAM S2: DRAM
//==========================================//

//MASTER INTERFACE FOR SLAVES
//WRITE ADDRESS1
logic [`AXI_IDS_BITS-1:0] AWID_S0;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S0;
logic [`AXI_LEN_BITS-1:0] AWLEN_S0;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0;
logic [1:0] AWBURST_S0;
logic AWVALID_S0;
logic AWREADY_S0;
//WRITE DATA0
logic [`AXI_DATA_BITS-1:0] WDATA_S0;
logic [`AXI_STRB_BITS-1:0] WSTRB_S0;
logic WLAST_S0;
logic WVALID_S0;
logic WREADY_S0;
//WRITE RESPONSE0
logic [`AXI_IDS_BITS-1:0] BID_S0;
logic [1:0] BRESP_S0;
logic BVALID_S0;
logic BREADY_S0;


//WRITE ADDRESS1
logic [`AXI_IDS_BITS-1:0] AWID_S1;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S1;
logic [`AXI_LEN_BITS-1:0] AWLEN_S1;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1;
logic [1:0] AWBURST_S1;
logic AWVALID_S1;
logic AWREADY_S1;
//WRITE DATA0
logic [`AXI_DATA_BITS-1:0] WDATA_S1;
logic [`AXI_STRB_BITS-1:0] WSTRB_S1;
logic WLAST_S1;
logic WVALID_S1;
logic WREADY_S1;
//WRITE RESPONSE0
logic [`AXI_IDS_BITS-1:0] BID_S1;
logic [1:0] BRESP_S1;
logic BVALID_S1;
logic BREADY_S1;

//WRITE ADDRESS2
logic [`AXI_IDS_BITS-1:0] AWID_S2;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S2;
logic [`AXI_LEN_BITS-1:0] AWLEN_S2;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S2;
logic [1:0] AWBURST_S2;
logic AWVALID_S2;
logic AWREADY_S2;
//WRITE DATA1
logic [`AXI_DATA_BITS-1:0] WDATA_S2;
logic [`AXI_STRB_BITS-1:0] WSTRB_S2;
logic WLAST_S2;
logic WVALID_S2;
logic WREADY_S2;
//WRITE RESPONSE1
logic [`AXI_IDS_BITS-1:0] BID_S2;
logic [1:0] BRESP_S2;
logic BVALID_S2;
logic BREADY_S2;


//READ ADDRESS0
logic [`AXI_IDS_BITS-1:0] ARID_S0;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S0;
logic [`AXI_LEN_BITS-1:0] ARLEN_S0;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0;
logic [1:0] ARBURST_S0;
logic ARVALID_S0;
logic ARREADY_S0;
//READ DATA0
logic [`AXI_IDS_BITS-1:0] RID_S0;
logic [`AXI_DATA_BITS-1:0] RDATA_S0;
logic [1:0] RRESP_S0;
logic RLAST_S0;
logic RVALID_S0;
logic RREADY_S0;

//READ ADDRESS1
logic [`AXI_IDS_BITS-1:0] ARID_S1;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S1;
logic [`AXI_LEN_BITS-1:0] ARLEN_S1;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1;
logic [1:0] ARBURST_S1;
logic ARVALID_S1;
logic ARREADY_S1;
//READ DATA0
logic [`AXI_IDS_BITS-1:0] RID_S1;
logic [`AXI_DATA_BITS-1:0] RDATA_S1;
logic [1:0] RRESP_S1;
logic RLAST_S1;
logic RVALID_S1;
logic RREADY_S1;


//READ ADDRESS2
logic [`AXI_IDS_BITS-1:0] ARID_S2;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S2;
logic [`AXI_LEN_BITS-1:0] ARLEN_S2;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S2;
logic [1:0] ARBURST_S2;
logic ARVALID_S2;
logic ARREADY_S2;
//READ DATA1
logic [`AXI_IDS_BITS-1:0] RID_S2;
logic [`AXI_DATA_BITS-1:0] RDATA_S2;
logic [1:0] RRESP_S2;
logic RLAST_S2;
logic RVALID_S2;
logic RREADY_S2;

//===============================//

logic DMA_interrupt_i_dsc; // signal to restart DMA transfer

// logic    [`ID_WIDTH-1:0]      awid_m_o_dsc;    	// Write address ID tag
// logic    [`ADDR_WIDTH-1:0]    awaddr_m_o_dsc;  	// Write address
// logic    [`LEN_WIDTH-1:0]     awlen_m_o_dsc;   	// Write address burst length
// logic    [`SIZE_WIDTH-1:0]    awsize_m_o_dsc;  	// Write address burst size
// logic    [`BURST_WIDTH-1:0]   awburst_m_o_dsc; 	// Write address burst type
// logic                        awvalid_m_o_dsc;  	// Write address valid
// logic                        awready_m_i_dsc;  	// Write address ready

// logic    [`DATA_WIDTH-1:0]    wdata_m_o_dsc;   	// Write data
// logic    [`DATA_WIDTH/8-1:0]  wstrb_m_o_dsc;   	// Write strobe
// logic                        wlast_m_o_dsc;    	// Write last
// logic                        wvalid_m_o_dsc;   	// Write valid
// logic                        wready_m_i_dsc;   	// Write ready

// logic    [`ID_WIDTH-1:0]      bid_m_i_dsc;     	// Write response ID tag
// logic    [`BRESP_WIDTH-1:0]   bresp_m_i_dsc;   	// Write response
// logic                        bvalid_m_i_dsc;   	// Write response valid
// logic                        bready_m_o_dsc;   	// Write response ready

// logic    [`ID_WIDTH-1:0]      arid_m_o_dsc;    	// Read address ID tag
// logic    [`ADDR_WIDTH-1:0]    araddr_m_o_dsc;  	// Read address
// logic    [`LEN_WIDTH-1:0]     arlen_m_o_dsc;   	// Read address burst length
// logic    [`SIZE_WIDTH-1:0]    arsize_m_o_dsc;  	// Read address burst size
// logic    [`BURST_WIDTH-1:0]   arburst_m_o_dsc; 	// Read address burst type
// logic                        arvalid_m_o_dsc;  	// Read address valid
// logic                        arready_m_i_dsc;  	// Read address ready


// logic    [`ID_WIDTH-1:0]      rid_m_i_dsc;     	// Read ID tag
// logic    [`DATA_WIDTH-1:0]    rdata_m_i_dsc;   	// Read data
// logic                        rlast_m_i_dsc;    	// Read last
// logic                        rvalid_m_i_dsc;   	// Read valid
// logic    [`RRESP_WIDTH-1:0]   rresp_m_i_dsc;   	// Read response
// logic                        rready_m_o_dsc;   	// Read ready



AXI AXI_1(
	.ACLK(clk),
	.ARESETn(rst_n),
	//SLAVE INTERFACE FOR MASTERS
	//WRITE ADDRESS M0
	.AWID_M0    (AWID_M0   ),
	.AWADDR_M0  (AWADDR_M0 ),
	.AWLEN_M0   (AWLEN_M0  ),
	.AWSIZE_M0  (AWSIZE_M0 ),
	.AWBURST_M0 (AWBURST_M0),
	.AWVALID_M0 (AWVALID_M0),
	.AWREADY_M0 (AWREADY_M0),
	//WRITE DATA
	.WDATA_M0   (WDATA_M0 ),
	.WSTRB_M0   (WSTRB_M0 ),
	.WLAST_M0   (WLAST_M0 ),
	.WVALID_M0  (WVALID_M0),
	.WREADY_M0  (WREADY_M0),
	//WRITE RESPONSE
	.BID_M0     (BID_M0   ),
	.BRESP_M0   (BRESP_M0 ),
	.BVALID_M0  (BVALID_M0),
	.BREADY_M0  (BREADY_M0),
	//WRITE ADDRESS M1
	.AWID_M1    (AWID_M1   ),
	.AWADDR_M1  (AWADDR_M1 ),
	.AWLEN_M1   (AWLEN_M1  ),
	.AWSIZE_M1  (AWSIZE_M1 ),
	.AWBURST_M1 (AWBURST_M1),
	.AWVALID_M1 (AWVALID_M1),
	.AWREADY_M1 (AWREADY_M1),
	//WRITE DATA
	.WDATA_M1   (WDATA_M1 ),
	.WSTRB_M1   (WSTRB_M1 ),
	.WLAST_M1   (WLAST_M1 ),
	.WVALID_M1  (WVALID_M1),
	.WREADY_M1  (WREADY_M1),
	//WRITE RESPONSE
	.BID_M1     (BID_M1   ),
	.BRESP_M1   (BRESP_M1 ),
	.BVALID_M1  (BVALID_M1),
	.BREADY_M1  (BREADY_M1),
	

	//READ ADDRESS1
	.ARID_M0    (ARID_M0   ),
	.ARADDR_M0  (ARADDR_M0 ),
	.ARLEN_M0   (ARLEN_M0  ),
	.ARSIZE_M0  (ARSIZE_M0 ),
	.ARBURST_M0 (ARBURST_M0),
	.ARVALID_M0 (ARVALID_M0),
	.ARREADY_M0 (ARREADY_M0),
	//READ DATA0
	.RID_M0    (RID_M0   ),
	.RDATA_M0  (RDATA_M0 ),
	.RRESP_M0  (RRESP_M0 ),
	.RLAST_M0  (RLAST_M0 ),
	.RVALID_M0 (RVALID_M0),
	.RREADY_M0 (RREADY_M0),
	//READ ADDRESS2
	.ARID_M1    (ARID_M1   ),
	.ARADDR_M1  (ARADDR_M1 ),
	.ARLEN_M1   (ARLEN_M1  ),
	.ARSIZE_M1  (ARSIZE_M1 ),
	.ARBURST_M1 (ARBURST_M1),
	.ARVALID_M1 (ARVALID_M1),
	.ARREADY_M1 (ARREADY_M1),
	//READ DATA1
	.RID_M1    (RID_M1   ),
	.RDATA_M1  (RDATA_M1 ),
	.RRESP_M1  (RRESP_M1 ),
	.RLAST_M1  (RLAST_M1 ),
	.RVALID_M1 (RVALID_M1),
	.RREADY_M1 (RREADY_M1),
	
	//MASTER INTERFACE FOR SLAVES
	//WRITE ADDRESS1
	
	.AWID_S0    (AWID_S0   ),
	.AWADDR_S0  (AWADDR_S0 ),
	.AWLEN_S0   (AWLEN_S0  ),
	.AWSIZE_S0  (AWSIZE_S0 ),
	.AWBURST_S0 (AWBURST_S0),
	.AWVALID_S0 (AWVALID_S0),
	.AWREADY_S0 (AWREADY_S0),
	//WRITE DATA0
	.WDATA_S0  (WDATA_S0 ),
	.WSTRB_S0  (WSTRB_S0 ),
	.WLAST_S0  (WLAST_S0 ),
	.WVALID_S0 (WVALID_S0),
	.WREADY_S0 (WREADY_S0),
	//WRITE RESPONSE0
	.BID_S0     (BID_S0   ),
	.BRESP_S0   (BRESP_S0 ),
	.BVALID_S0  (BVALID_S0),
	.BREADY_S0  (BREADY_S0),

	.AWID_S1    (AWID_S1   ),
	.AWADDR_S1  (AWADDR_S1 ),
	.AWLEN_S1   (AWLEN_S1  ),
	.AWSIZE_S1  (AWSIZE_S1 ),
	.AWBURST_S1 (AWBURST_S1),
	.AWVALID_S1 (AWVALID_S1),
	.AWREADY_S1 (AWREADY_S1),
	//WRITE DATA0
	.WDATA_S1  (WDATA_S1 ),
	.WSTRB_S1  (WSTRB_S1 ),
	.WLAST_S1  (WLAST_S1 ),
	.WVALID_S1 (WVALID_S1),
	.WREADY_S1 (WREADY_S1),
	//WRITE RESPONSE0
	.BID_S1     (BID_S1   ),
	.BRESP_S1   (BRESP_S1 ),
	.BVALID_S1  (BVALID_S1),
	.BREADY_S1  (BREADY_S1),
	
	//WRITE ADDRESS2
	.AWID_S2    (AWID_S2   ),
	.AWADDR_S2  (AWADDR_S2 ),
	.AWLEN_S2   (AWLEN_S2  ),
	.AWSIZE_S2  (AWSIZE_S2 ),
	.AWBURST_S2 (AWBURST_S2),
	.AWVALID_S2 (AWVALID_S2),
	.AWREADY_S2 (AWREADY_S2),
	//WRITE DATA1
	.WDATA_S2  (WDATA_S2 ),
	.WSTRB_S2  (WSTRB_S2 ),
	.WLAST_S2  (WLAST_S2 ),
	.WVALID_S2 (WVALID_S2),
	.WREADY_S2 (WREADY_S2),
	//WRITE RESPONSE1
	.BID_S2     (BID_S2   ),
	.BRESP_S2   (BRESP_S2 ),
	.BVALID_S2  (BVALID_S2),
	.BREADY_S2  (BREADY_S2),
	

    //READ ADDRESS0
	.ARID_S0    (ARID_S0   ),
	.ARADDR_S0  (ARADDR_S0 ),
	.ARLEN_S0   (ARLEN_S0  ),
	.ARSIZE_S0  (ARSIZE_S0 ),
	.ARBURST_S0 (ARBURST_S0),
	.ARVALID_S0 (ARVALID_S0),
	.ARREADY_S0 (ARREADY_S0),
	//READ DATA0
	.RID_S0     (RID_S0   ),
	.RDATA_S0   (RDATA_S0 ),
	.RRESP_S0   (RRESP_S0 ),
	.RLAST_S0   (RLAST_S0 ),
	.RVALID_S0  (RVALID_S0),
	.RREADY_S0  (RREADY_S0),


	//READ ADDRESS1
	.ARID_S1    (ARID_S1   ),
	.ARADDR_S1  (ARADDR_S1 ),
	.ARLEN_S1   (ARLEN_S1  ),
	.ARSIZE_S1  (ARSIZE_S1 ),
	.ARBURST_S1 (ARBURST_S1),
	.ARVALID_S1 (ARVALID_S1),
	.ARREADY_S1 (ARREADY_S1),
	//READ DATA0
	.RID_S1     (RID_S1   ),
	.RDATA_S1   (RDATA_S1 ),
	.RRESP_S1   (RRESP_S1 ),
	.RLAST_S1   (RLAST_S1 ),
	.RVALID_S1  (RVALID_S1),
	.RREADY_S1  (RREADY_S1),
	//READ ADDRESS2
	.ARID_S2    (ARID_S2   ),
	.ARADDR_S2  (ARADDR_S2 ),
	.ARLEN_S2   (ARLEN_S2  ),
	.ARSIZE_S2  (ARSIZE_S2 ),
	.ARBURST_S2 (ARBURST_S2),
	.ARVALID_S2 (ARVALID_S2),
	.ARREADY_S2 (ARREADY_S2),
	//READ DATA1
	.RID_S2    (RID_S2   ),
	.RDATA_S2  (RDATA_S2 ),
	.RRESP_S2  (RRESP_S2 ),
	.RLAST_S2  (RLAST_S2 ),
	.RVALID_S2 (RVALID_S2),
	.RREADY_S2 (RREADY_S2)
);

// S0  DMA  //
DMA_wrapper DMA_Wrapper(
	.ACLK(clk),
    .ARESETn(rst_n),
	//WRITE ADDRESS
    .S_AWID(AWID_S0),
    .S_AWADDR(AWADDR_S0),
    .S_AWLEN(AWLEN_S0),
    .S_AWSIZE(AWSIZE_S0),
    .S_AWBURST(AWBURST_S0),
    .S_AWVALID(AWVALID_S0),
    .S_AWREADY(AWREADY_S0),
    
    .S_WDATA(WDATA_S0),
    .S_WSTRB(WSTRB_S0),
    .S_WLAST(WLAST_S0),
    .S_WVALID(WVALID_S0),
    .S_WREADY(WREADY_S0),

    //WRITE RESPONSE
    .S_BID(BID_S0),
    .S_BRESP(BRESP_S0),
    .S_BVALID(BVALID_S0),
    .S_BREADY(BREADY_S0),
	
	//! M1 READ ADDRESS0
	.M_ARID(ARID_M1),
	.M_ARADDR(ARADDR_M1),
	.M_ARLEN(ARLEN_M1),
	.M_ARSIZE(ARSIZE_M1),
	.M_ARBURST(ARBURST_M1),
	.M_ARVALID(ARVALID_M1),
	.M_ARREADY(ARREADY_M1),
	//READ DATA0
	.M_RID(RID_M1),
	.M_RDATA(RDATA_M1),
	.M_RRESP(RRESP_M1),
	.M_RLAST(RLAST_M1),
	.M_RVALID(RVALID_M1),
	.M_RREADY(RREADY_M1),
	//WRITE ADDRESS1
    .M_AWID(AWID_M1),
	.M_AWADDR(AWADDR_M1),
	.M_AWLEN(AWLEN_M1),
	.M_AWSIZE(AWSIZE_M1),
	.M_AWBURST(AWBURST_M1),
	.M_AWVALID(AWVALID_M1),
	.M_AWREADY(AWREADY_M1),
	//WRITE DATA1
	.M_WDATA(WDATA_M1),
	.M_WSTRB(WSTRB_M1),
	.M_WLAST(WLAST_M1),
	.M_WVALID(WVALID_M1),
	.M_WREADY(WREADY_M1),
	//WRITE RESPONSE1
	.M_BID(BID_M1),
	.M_BRESP(BRESP_M1),
	.M_BVALID(BVALID_M1),
	.M_BREADY(BREADY_M1),
	.external_interrupt(DMA_interrupt_i_dsc)
);
	
//    S1_IM    //
SRAM_wrapper SRAM_64KB(
	.ACLK(clk),
	.ARESETn(rst_n),
    //SLAVE INTERFACE FOR MASTERS
    //WRITE ADDRESS
    .AWID     (AWID_S1   ),
    .AWADDR   (AWADDR_S1 ),
    .AWLEN    (AWLEN_S1  ),
    .AWSIZE   (AWSIZE_S1 ),
    .AWBURST  (AWBURST_S1),
    .AWVALID  (AWVALID_S1),
    .AWREADY  (AWREADY_S1),
    //WRITE DATA
    .WDATA  (WDATA_S1 ),
    .WSTRB  (WSTRB_S1 ),
    .WLAST  (WLAST_S1 ),
    .WVALID (WVALID_S1),
    .WREADY (WREADY_S1),
    //WRITE RESPONSE
    .BID    (BID_S1   ),
    .BRESP  (BRESP_S1 ),
    .BVALID (BVALID_S1),
    .BREADY (BREADY_S1),

    //READ ADDRESS
    .ARID     (ARID_S1   ),
    .ARADDR   (ARADDR_S1 ),
    .ARLEN    (ARLEN_S1  ),
    .ARSIZE   (ARSIZE_S1 ),
    .ARBURST  (ARBURST_S1),
    .ARVALID  (ARVALID_S1),
    .ARREADY  (ARREADY_S1),
    //READ DATA
    .RID    (RID_S1   ),
    .RDATA  (RDATA_S1 ),
    .RRESP  (RRESP_S1 ),
    .RLAST  (RLAST_S1 ),
    .RVALID (RVALID_S1),
    .RREADY (RREADY_S1),
    .dsc_read_data(glb_read_data_i_dsc),
    .dsc_write_data(glb_write_data_o_dsc),
    .dsc_glb_addr(glb_addr_o_dsc),
    .dsc_glb_web(glb_web_o_dsc)
    );


// S2  DRAM //
SRAM_wrapper2 DRAM(
	.ACLK(clk),
	.ARESETn(rst_n),
    //SLAVE INTERFACE FOR MASTERS
    //WRITE ADDRESS
    .AWID     (AWID_S2   ),
    .AWADDR   (AWADDR_S2 ),
    .AWLEN    (AWLEN_S2  ),
    .AWSIZE   (AWSIZE_S2 ),
    .AWBURST  (AWBURST_S2),
    .AWVALID  (AWVALID_S2),
    .AWREADY  (AWREADY_S2),
    //WRITE DATA
    .WDATA  (WDATA_S2 ),
    .WSTRB  (WSTRB_S2 ),
    .WLAST  (WLAST_S2 ),
    .WVALID (WVALID_S2),
    .WREADY (WREADY_S2),
    //WRITE RESPONSE
    .BID    (BID_S2   ),
    .BRESP  (BRESP_S2 ),
    .BVALID (BVALID_S2),
    .BREADY (BREADY_S2),

    //READ ADDRESS
    .ARID     (ARID_S2   ),
    .ARADDR   (ARADDR_S2 ),
    .ARLEN    (ARLEN_S2  ),
    .ARSIZE   (ARSIZE_S2 ),
    .ARBURST  (ARBURST_S2),
    .ARVALID  (ARVALID_S2),
    .ARREADY  (ARREADY_S2),
    //READ DATA
    .RID    (RID_S2   ),
    .RDATA  (RDATA_S2 ),
    .RRESP  (RRESP_S2 ),
    .RLAST  (RLAST_S2 ),
    .RVALID (RVALID_S2),
    .RREADY (RREADY_S2)
    // .dsc_read_data(glb_read_data_i_dsc),
    // .dsc_write_data(glb_write_data_o_dsc),
    // .dsc_glb_addr(glb_addr_o_dsc),
    // .dsc_glb_web(glb_web_o_dsc)
    );


DSC DSC (
    .clk(clk),
    .rst_n(rst_n),

    // uLD inputs
    .uLD_en_i     (uLD_en_i      ),
    .layer_id_i   (layer_id_i    ),
    .layer_type_i (layer_type_i  ),
    .in_R_i       (in_R_i        ),
    .in_C_i       (in_C_i        ),
    .in_D_i       (in_D_i        ),
    .out_K_i      (out_K_i       ),
    .stride_i     (stride_i      ),
    .pad_T_i      (pad_T_i       ),
    .pad_B_i      (pad_B_i       ),
    .pad_L_i      (pad_L_i       ),
    .pad_R_i      (pad_R_i       ),
    .base_ifmap_i (base_ifmap_i  ),
    .base_weight_i(base_weight_i ),
    .base_bias_i  (base_bias_i   ),
    .base_ofmap_i (base_ofmap_i  ),
    .flags_i      (flags_i       ),
    .quant_scale_i(quant_scale_i ),

    // DMA
    .DMA_interrupt_i(DMA_interrupt_i_dsc),
    // Write address channel
    .awid_m_o(AWID_M0),
    .awaddr_m_o(AWADDR_M0),
    .awlen_m_o(AWLEN_M0),
    .awsize_m_o(AWSIZE_M0),
    .awburst_m_o(AWBURST_M0),
    .awvalid_m_o(AWVALID_M0),
    .awready_m_i(AWREADY_M0),

    // Write data channel
    .wdata_m_o(WDATA_M0),
    .wstrb_m_o(WSTRB_M0),
    .wlast_m_o(WLAST_M0),
    .wvalid_m_o(WVALID_M0),
    .wready_m_i(WREADY_M0),

    // Write response channel
    .bid_m_i(BID_M0),
    .bresp_m_i(BRESP_M0),
    .bvalid_m_i(BVALID_M0),
    .bready_m_o(BREADY_M0),
    // Read address channel
    .arid_m_o(ARID_M0),
    .araddr_m_o(ARADDR_M0),
    .arlen_m_o(ARLEN_M0),
    .arsize_m_o(ARSIZE_M0),
    .arburst_m_o(ARBURST_M0),
    .arvalid_m_o(ARVALID_M0),
    .arready_m_i(ARREADY_M0),

    // Read data channel
    .rid_m_i(RID_M0),
    .rdata_m_i(RDATA_M0),
    .rlast_m_i(RRESP_M0),
    .rvalid_m_i(RLAST_M0),
    .rresp_m_i(RVALID_M0),
    .rready_m_o(RREADY_M0),

    // GLB interface
    .glb_addr_o(glb_addr_o_dsc),
    .glb_write_data_o(glb_write_data_o_dsc),
    .glb_web_o(glb_web_o_dsc),
    .glb_read_data_i(glb_read_data_i_dsc),
    .PASS_START(PASS_START),
    .pass_done_o(pass_done_o)
);







//glb_addr








endmodule