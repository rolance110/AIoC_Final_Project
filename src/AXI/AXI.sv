//////////////////////////////////////////////////////////////////////
//          ██╗       ██████╗   ██╗  ██╗    ██████╗            		//
//          ██║       ██╔══█║   ██║  ██║    ██╔══█║            		//
//          ██║       ██████║   ███████║    ██████║            		//
//          ██║       ██╔═══╝   ██╔══██║    ██╔═══╝            		//
//          ███████╗  ██║  	    ██║  ██║    ██║  	           		//
//          ╚══════╝  ╚═╝  	    ╚═╝  ╚═╝    ╚═╝  	           		//
//                                                             		//
// 	2024 Advanced VLSI System Design, advisor: Lih-Yih, Chiou		//
//                                                             		//
//////////////////////////////////////////////////////////////////////
//                                                             		//
// 	Autor: 			TZUNG-JIN, TSAI (Leo)				  	   		//
//	Filename:		 AXI.sv			                            	//
//	Description:	Top module of AXI	 							//
// 	Version:		1.0	    								   		//
//////////////////////////////////////////////////////////////////////


module AXI(

	input ACLK,
	input ARESETn,

	//SLAVE INTERFACE FOR MASTERS
	//WRITE ADDRESS
	input [`AXI_ID_BITS-1:0] AWID_M0,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M0,
	input [`AXI_LEN_BITS-1:0] AWLEN_M0,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M0,
	input [1:0] AWBURST_M0,
	input AWVALID_M0,
	output logic AWREADY_M0,
	
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_M0,
	input [`AXI_STRB_BITS-1:0] WSTRB_M0,
	input WLAST_M0,
	input WVALID_M0,
	output logic WREADY_M0,
	
	//WRITE RESPONSE
	output logic [`AXI_ID_BITS-1:0] BID_M0,
	output logic [1:0] BRESP_M0,
	output logic BVALID_M0,
	input BREADY_M0,



	//WRITE ADDRESS
	input [`AXI_ID_BITS-1:0] AWID_M1,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	input [1:0] AWBURST_M1,
	input AWVALID_M1,
	output logic AWREADY_M1,
	
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output logic WREADY_M1,
	
	//WRITE RESPONSE
	output logic [`AXI_ID_BITS-1:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1,
	input BREADY_M1,


	//READ ADDRESS1
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,
	input ARVALID_M0,
	output logic ARREADY_M0,
	
	//READ DATA0
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	input RREADY_M0,
	
	//READ ADDRESS2
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output logic ARREADY_M1,
	
	//READ DATA1
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,
	input RREADY_M1,


	//MASTER INTERFACE FOR SLAVES
	//WRITE ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] AWID_S0,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
	output logic [1:0] AWBURST_S0,
	output logic AWVALID_S0,
	input AWREADY_S0,
	
	//WRITE DATA0
	output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output logic WLAST_S0,
	output logic WVALID_S0,
	input WREADY_S0,
	
	//WRITE RESPONSE0
	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output logic BREADY_S0,
	//WRITE ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] AWID_S1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output logic [1:0] AWBURST_S1,
	output logic AWVALID_S1,
	input AWREADY_S1,
	
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	input WREADY_S1,
	
	//WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic BREADY_S1,
	
	//WRITE ADDRESS2
	output logic [`AXI_IDS_BITS-1:0] AWID_S2,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S2,
	output logic [1:0] AWBURST_S2,
	output logic AWVALID_S2,
	input AWREADY_S2,
	
	//WRITE DATA2
	output logic [`AXI_DATA_BITS-1:0] WDATA_S2,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S2,
	output logic WLAST_S2,
	output logic WVALID_S2,
	input WREADY_S2,
	
	//WRITE RESPONSE2
	input [`AXI_IDS_BITS-1:0] BID_S2,
	input [1:0] BRESP_S2,
	input BVALID_S2,
	output logic BREADY_S2,


	
//READ ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] ARID_S0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output logic [1:0] ARBURST_S0,
	output logic ARVALID_S0,
	input ARREADY_S0,
	
	//READ DATA0
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output logic RREADY_S0,


	//READ ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] ARID_S1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output logic [1:0] ARBURST_S1,
	output logic ARVALID_S1,
	input ARREADY_S1,
	
	//READ DATA0
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output logic RREADY_S1,
	
	//READ ADDRESS2
	output logic [`AXI_IDS_BITS-1:0] ARID_S2,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S2,
	output logic [1:0] ARBURST_S2,
	output logic ARVALID_S2,
	input ARREADY_S2,
	
	//READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S2,
	input [`AXI_DATA_BITS-1:0] RDATA_S2,
	input [1:0] RRESP_S2,
	input RLAST_S2,
	input RVALID_S2,
	output logic RREADY_S2
	
	// output logic [`AXI_IDS_BITS-1:0] ARID_S3,
	// output logic [`AXI_ADDR_BITS-1:0] ARADDR_S3,
	// output logic [`AXI_LEN_BITS-1:0] ARLEN_S3,
	// output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S3,
	// output logic [1:0] ARBURST_S3,
	// output logic ARVALID_S3,
	//input ARREADY_S3,
	
	//READ DATA1
	//input [`AXI_IDS_BITS-1:0] RID_S3,
	//input [`AXI_DATA_BITS-1:0] RDATA_S3,
	//input [1:0] RRESP_S3,
	//input RLAST_S3,
	//input RVALID_S3,
	// output logic RREADY_S3,

	// output logic [`AXI_IDS_BITS-1:0] ARID_S4,
	// output logic [`AXI_ADDR_BITS-1:0] ARADDR_S4,
	// output logic [`AXI_LEN_BITS-1:0] ARLEN_S4,
	// output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S4,
	// output logic [1:0] ARBURST_S4,
	// output logic ARVALID_S4,
	//input ARREADY_S4,
	
	//READ DATA1
	// input [`AXI_IDS_BITS-1:0] RID_S4,
	// input [`AXI_DATA_BITS-1:0] RDATA_S4,
	// input [1:0] RRESP_S4,
	// input RLAST_S4,
	// input RVALID_S4,
	//output logic RREADY_S4,

);
    //---------- you should put your design here ----------//

	
	// assign AWID_M0 = 4'd0;
	// assign AWADDR_M0 = 32'd0;
	// assign AWLEN_M0 = 4'd0;
	// assign AWSIZE_M0 = 3'd0;
	// assign AWBURST_M0 = 2'd0;
	// assign AWVALID_M0 = 1'd0;
	// assign WDATA_M0 = 32'd0;
	// assign WSTRB_M0 = 4'd0;
	// assign WLAST_M0 = 1'd0;
	// assign WVALID_M0 = 1'd0;
	// assign BREADY_M0 = 1'd0;
	
	
	logic [3:0] cs_r;
	logic [3:0] cs_w;
	logic [2:0] slave_r;
	logic [2:0] slave_w;
	
	//READ ADDRESS CHANNEL

	logic [`AXI_IDS_BITS-1:0] ARID_BUS;
	logic [`AXI_ADDR_BITS-1:0] ARADDR_BUS;
	logic [`AXI_LEN_BITS-1:0] ARLEN_BUS;
	logic [`AXI_SIZE_BITS-1:0] ARSIZE_BUS;
	logic [1:0] ARBURST_BUS;
	logic ARVALID_BUS;
	
	ARADDR_arbiter ARADDR_arbiter_0(
		.ACLK              (ACLK	),
		.ARESETn           (ARESETn	),
		                   			
		.ARID_M0           (ARID_M0	),
		.ARADDR_M0         (ARADDR_M0	),
		.ARLEN_M0          (ARLEN_M0	),
		.ARSIZE_M0         (ARSIZE_M0	),
		.ARBURST_M0        (ARBURST_M0	),
		.ARVALID_M0        (ARVALID_M0	),
		.ARREADY_M0        (ARREADY_M0	), //output
		                   			
		.ARID_M1           (ARID_M1	),
		.ARADDR_M1         (ARADDR_M1	),
		.ARLEN_M1          (ARLEN_M1	),
		.ARSIZE_M1         (ARSIZE_M1	),
		.ARBURST_M1        (ARBURST_M1	),
		.ARVALID_M1        (ARVALID_M1	),
		.ARREADY_M1        (ARREADY_M1	),

		//  .ARID_M2           (ARID_M2	),
		//  .ARADDR_M2         (ARADDR_M2	),
		//  .ARLEN_M2          (ARLEN_M2	),
		//  .ARSIZE_M2         (ARSIZE_M2	),
		//  .ARBURST_M2        (ARBURST_M2	),
		//  .ARVALID_M2        (ARVALID_M2	),
		//  .ARREADY_M2        (ARREADY_M2	),


		                  			
		.ARID_BUS          (ARID_BUS	),
		.ARADDR_BUS        (ARADDR_BUS	),
		.ARLEN_BUS         (ARLEN_BUS	),
		.ARSIZE_BUS        (ARSIZE_BUS	),
		.ARBURST_BUS       (ARBURST_BUS	),
		.ARVALID_BUS       (ARVALID_BUS	),
		
		.ARREADY_S0	       (ARREADY_S0	),
		.ARREADY_S1	       (ARREADY_S1	),
	    .ARREADY_S2        (ARREADY_S2	),
		//.ARREADY_S3        (ARREADY_S3	),
		//.ARREADY_S4        (ARREADY_S4	),
		// .ARREADY_S5        (ARREADY_S5	),

		.RVALID_M0          (RVALID_M0	), 			
		.RREADY_M0          (RREADY_M0	),
		.RLAST_M0           (RLAST_M0	),
		.RVALID_M1          (RVALID_M1	),
		.RREADY_M1          (RREADY_M1	),
		.RLAST_M1           (RLAST_M1	),
		//  .RVALID_M2          (RVALID_M2	),
		//  .RREADY_M2          (RREADY_M2	),
		//  .RLAST_M2           (RLAST_M2	),
		
		.cs                	(cs_r		),
		.slave      	    (slave_r    )
	
	);
	
	
	
	addr_dec_s araddr_dec_s_0(

		.AID_BUS		(ARID_BUS	),
		.ADDR_BUS		(ARADDR_BUS	),
		.ALEN_BUS		(ARLEN_BUS	),
		.ASIZE_BUS		(ARSIZE_BUS	),
		.ABURST_BUS		(ARBURST_BUS),
		.AVALID_BUS		(ARVALID_BUS),
		
		.AID_S0			(ARID_S0	),
		.ADDR_S0		(ARADDR_S0	),
		.ALEN_S0		(ARLEN_S0	),
		.ASIZE_S0		(ARSIZE_S0	),
		.ABURST_S0		(ARBURST_S0	),
		.AVALID_S0		(ARVALID_S0	),

		.AID_S1			(ARID_S1	),
		.ADDR_S1		(ARADDR_S1	),
		.ALEN_S1		(ARLEN_S1	),
		.ASIZE_S1		(ARSIZE_S1	),
		.ABURST_S1		(ARBURST_S1	),
		.AVALID_S1		(ARVALID_S1	),
									
		.AID_S2			(ARID_S2	),
		.ADDR_S2		(ARADDR_S2	),
		.ALEN_S2		(ARLEN_S2	),
		.ASIZE_S2		(ARSIZE_S2	),
		.ABURST_S2		(ARBURST_S2	),
		.AVALID_S2		(ARVALID_S2	),



		// .AID_S5			(ARID_S5	),
		// .ADDR_S5		(ARADDR_S5	),
		// .ALEN_S5		(ARLEN_S5	),
		// .ASIZE_S5		(ARSIZE_S5	),
		// .ABURST_S5		(ARBURST_S5	),
		// .AVALID_S5		(ARVALID_S5	),							
		.slave      	(slave_r    )	
		
	);
	//READ DATA CHANNEL

	R_channel R_channel_0(

		.ACLK           (ACLK	 	),
		.ARESETn        (ARESETn	),

		.RID_S0			(RID_S0		),
		.RDATA_S0		(RDATA_S0	),
		.RRESP_S0		(RRESP_S0	),
		.RLAST_S0		(RLAST_S0	),
		.RVALID_S0		(RVALID_S0	),

		.RID_S1			(RID_S1		),
		.RDATA_S1		(RDATA_S1	),
		.RRESP_S1		(RRESP_S1	),
		.RLAST_S1		(RLAST_S1	),
		.RVALID_S1		(RVALID_S1	),
					 				
		.RID_S2			(RID_S2		),
		.RDATA_S2		(RDATA_S2	),
		.RRESP_S2		(RRESP_S2	),
		.RLAST_S2		(RLAST_S2	),
		.RVALID_S2		(RVALID_S2	),


		// .RID_S5			(RID_S5		),
		// .RDATA_S5		(RDATA_S5	),
		// .RRESP_S5		(RRESP_S5	),
		// .RLAST_S5		(RLAST_S5	),
		// .RVALID_S5		(RVALID_S5	),

		.RREADY_S0		(RREADY_S0	),
		.RREADY_S1		(RREADY_S1	),
		.RREADY_S2		(RREADY_S2	),
		//.RREADY_S3		(RREADY_S3	),
		//.RREADY_S4		(RREADY_S4	),
		// .RREADY_S5		(RREADY_S5	),		

		.RREADY_M0		(RREADY_M0	),
		.RREADY_M1		(RREADY_M1	),
		// .RREADY_M2		(RREADY_M2	),
		          
		.RID_M0			(RID_M0		),
		.RDATA_M0		(RDATA_M0	),
		.RRESP_M0		(RRESP_M0	),
		.RLAST_M0		(RLAST_M0	),
		.RVALID_M0		(RVALID_M0	),
					 				
		.RID_M1			(RID_M1		),
		.RDATA_M1		(RDATA_M1	),
		.RRESP_M1		(RRESP_M1	),
		.RLAST_M1		(RLAST_M1	),
		.RVALID_M1		(RVALID_M1	),

		// .RID_M2			(RID_M2		),
		// .RDATA_M2		(RDATA_M2	),
		// .RRESP_M2		(RRESP_M2	),
		// .RLAST_M2		(RLAST_M2	),
		// .RVALID_M2		(RVALID_M2	),
		
					 				
		.cs				(cs_r		),
		.slave      	(slave_r	),
        .ARID_BUS       (ARID_BUS 	),
	    .ARLEN_BUS      (ARLEN_BUS	),
		.ARBURST_BUS    (ARBURST_BUS) 
	
	
	
	);
	
	//WRITE ADDR CHANNEL
	logic [`AXI_IDS_BITS-1:0] AWID_BUS;
	logic [`AXI_ADDR_BITS-1:0] AWADDR_BUS;
	logic [`AXI_LEN_BITS-1:0] AWLEN_BUS;
	logic [`AXI_SIZE_BITS-1:0] AWSIZE_BUS;
	logic [1:0] AWBURST_BUS;
	logic AWVALID_BUS;
	
	logic WDATA_DONE_M0;
	logic WDATA_DONE_M1;
	
	logic WDATA_DONE;
	
	logic [2:0] WDATA_control;
	
	logic [`AXI_ADDR_BITS-1:0] AW_ADDR_for_W;

	
	AWADDR_arbiter AWADDR_arbiter(
		.ACLK			(ACLK			),
		.ARESETn		(ARESETn		),
		.ID_M0			(AWID_M0		),
		.ADDR_M0		(AWADDR_M0		),
		.LEN_M0			(AWLEN_M0		),
		.SIZE_M0		(AWSIZE_M0		),
		.BURST_M0		(AWBURST_M0		),
		.VALID_M0		(AWVALID_M0		),
		.ID_M1			(AWID_M1		),
		.ADDR_M1		(AWADDR_M1		),
		.LEN_M1			(AWLEN_M1		),
		.SIZE_M1		(AWSIZE_M1		),
		.BURST_M1		(AWBURST_M1		),
		.VALID_M1		(AWVALID_M1		),

		// .ID_M2			(AWID_M2		),
		// .ADDR_M2		(AWADDR_M2		),
		// .LEN_M2			(AWLEN_M2		),
		// .SIZE_M2		(AWSIZE_M2		),
		// .BURST_M2		(AWBURST_M2		),
		// .VALID_M2		(AWVALID_M2		),

		.DONE			(WDATA_DONE		),
		
		.WVALID_M0		(WVALID_M0		),
		.WVALID_M1		(WVALID_M1		),
		// .WVALID_M2		(WVALID_M2		),
		.ID_BUS			(AWID_BUS		),
		.ADDR_BUS		(AWADDR_BUS		),
		.LEN_BUS		(AWLEN_BUS		),
		.SIZE_BUS		(AWSIZE_BUS		),
		.BURST_BUS		(AWBURST_BUS	),
		.VALID_BUS		(AWVALID_BUS	),
		.READY_S0		(AWREADY_S0		), 
		.READY_S1		(AWREADY_S1		),
		.READY_S2		(AWREADY_S2		),
		.READY_S3		(AWREADY_S3		),
		.READY_S4		(AWREADY_S4		),
		.READY_S5		(AWREADY_S5		),

		
		.READY_M0		(AWREADY_M0		),
		.READY_M1		(AWREADY_M1		),
		// .READY_M2		(AWREADY_M2		),
		
		.cs				(cs_w			),
		.slave      	(slave_w      	)	 
	);
	

	addr_dec_s awaddr_dec_s_0(

		.AID_BUS		(AWID_BUS		),
		.ADDR_BUS		(AWADDR_BUS		),
		.ALEN_BUS		(AWLEN_BUS		),
		.ASIZE_BUS		(AWSIZE_BUS		),
		.ABURST_BUS		(AWBURST_BUS	),
		.AVALID_BUS		(AWVALID_BUS	),
		
		.AID_S0			(AWID_S0		),
		.ADDR_S0		(AWADDR_S0		),
		.ALEN_S0		(AWLEN_S0		),
		.ASIZE_S0		(AWSIZE_S0		),
		.ABURST_S0		(AWBURST_S0		),
		.AVALID_S0		(AWVALID_S0		),

		.AID_S1			(AWID_S1		),
		.ADDR_S1		(AWADDR_S1		),
		.ALEN_S1		(AWLEN_S1		),
		.ASIZE_S1		(AWSIZE_S1		),
		.ABURST_S1		(AWBURST_S1		),
		.AVALID_S1		(AWVALID_S1		),
									
		.AID_S2			(AWID_S2		),
		.ADDR_S2		(AWADDR_S2		),
		.ALEN_S2		(AWLEN_S2		),
		.ASIZE_S2		(AWSIZE_S2		),
		.ABURST_S2		(AWBURST_S2		),
		.AVALID_S2		(AWVALID_S2		),
		
		.slave      	(slave_w        )	
	);
	
	//WRITE CHANNEL
	W_channel W_channel_i(
		.clk			(ACLK			),
		.rst_n			(ARESETn		),
		.WDATA_M0		(WDATA_M0		),
		.WSTRB_M0		(WSTRB_M0		),
		.WLAST_M0		(WLAST_M0		),
		.WVALID_M0		(WVALID_M0		),
		.WREADY_M0		(WREADY_M0		),
		.WDATA_M1		(WDATA_M1		),
		.WSTRB_M1		(WSTRB_M1		),
		.WLAST_M1		(WLAST_M1		),
		.WVALID_M1		(WVALID_M1		),
		.WREADY_M1		(WREADY_M1		),

        //  .WDATA_M2		(WDATA_M2		),
		// .WSTRB_M2		(WSTRB_M2		),
		// .WLAST_M2		(WLAST_M2		),
		// .WVALID_M2		(WVALID_M2		),
		// .WREADY_M2		(WREADY_M2		),


		.WDATA_S0		(WDATA_S0		),
		.WSTRB_S0		(WSTRB_S0		),
		.WLAST_S0		(WLAST_S0		),
		.WVALID_S0		(WVALID_S0		),
		.WREADY_S0		(WREADY_S0		),


		.WDATA_S1		(WDATA_S1		),
		.WSTRB_S1		(WSTRB_S1		),
		.WLAST_S1		(WLAST_S1		),
		.WVALID_S1		(WVALID_S1		),
		.WREADY_S1		(WREADY_S1		),


		.WDATA_S2		(WDATA_S2		),
		.WSTRB_S2		(WSTRB_S2		),
		.WLAST_S2		(WLAST_S2		),
		.WVALID_S2		(WVALID_S2		),
		.WREADY_S2		(WREADY_S2		),

		// .WDATA_S3		(WDATA_S3		),
		// .WSTRB_S3		(WSTRB_S3		),
		// .WLAST_S3		(WLAST_S3		),
		// .WVALID_S3		(WVALID_S3		),
		// .WREADY_S3		(WREADY_S3		),

		// .WDATA_S4		(WDATA_S4		),
		// .WSTRB_S4		(WSTRB_S4		),
		// .WLAST_S4		(WLAST_S4		),
		// .WVALID_S4		(WVALID_S4		),
		// .WREADY_S4		(WREADY_S4		),

		// .WDATA_S5		(WDATA_S5		),
		// .WSTRB_S5		(WSTRB_S5		),
		// .WLAST_S5		(WLAST_S5		),
		// .WVALID_S5		(WVALID_S5		),
		// .WREADY_S5		(WREADY_S5		),
		
		.cs				(cs_w			),
		.slave      	(slave_w      	) 
	);
	
	//WRITE RESPONSE CHANNEL
	B_channel B_channel_i(
		.BID_M0			(BID_M0			),
		.BRESP_M0		(BRESP_M0		),
		.BVALID_M0		(BVALID_M0		),
		.BREADY_M0		(BREADY_M0		),
		.BID_M1			(BID_M1			),
		.BRESP_M1		(BRESP_M1		),
		.BVALID_M1		(BVALID_M1		),
		.BREADY_M1		(BREADY_M1		),

        // .BID_M2			(BID_M2			),
		// .BRESP_M2		(BRESP_M2		),
		// .BVALID_M2		(BVALID_M2		),
		// .BREADY_M2		(BREADY_M2		),

		.BID_S0			(BID_S0			),
		.BRESP_S0		(BRESP_S0		),
		.BVALID_S0		(BVALID_S0		),
		.BREADY_S0		(BREADY_S0		),

		.BID_S1			(BID_S1			),
		.BRESP_S1		(BRESP_S1		),
		.BVALID_S1		(BVALID_S1		),
		.BREADY_S1		(BREADY_S1		),

		.BID_S2			(BID_S2			),
		.BRESP_S2		(BRESP_S2		),
		.BVALID_S2		(BVALID_S2		),
		.BREADY_S2		(BREADY_S2		),
		
		// .BID_S3			(BID_S3			),
		// .BRESP_S3		(BRESP_S3		),
		// .BVALID_S3		(BVALID_S3		),
		// .BREADY_S3		(BREADY_S3		),
		// .BID_S4			(BID_S4			),
		// .BRESP_S4		(BRESP_S4		),
		// .BVALID_S4		(BVALID_S4		),
		// .BREADY_S4		(BREADY_S4		),
		// .BID_S5			(BID_S5			),
		// .BRESP_S5		(BRESP_S5		),
		// .BVALID_S5		(BVALID_S5		),
		// .BREADY_S5		(BREADY_S5		),
		
		.DONE			(WDATA_DONE		),
		
		.cs				(cs_w			),
		.slave      	(slave_w      	)  
	);
	
	
endmodule

