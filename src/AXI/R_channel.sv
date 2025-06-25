
module R_channel(
	input ACLK,
	input ARESETn,

    input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,

	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	
	input [`AXI_IDS_BITS-1:0] RID_S2,
	input [`AXI_DATA_BITS-1:0] RDATA_S2,
	input [1:0] RRESP_S2,
	input RLAST_S2,
	input RVALID_S2,
	
    output logic RREADY_S0,
	output logic RREADY_S1,
	output logic RREADY_S2,

	///////////////////////////////// MASTER
	input RREADY_M0,
	input RREADY_M1,
	
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,

	input [3:0] cs,
	input [2:0] slave,
	
	input [`AXI_IDS_BITS-1:0] ARID_BUS,
	input [`AXI_LEN_BITS-1:0] ARLEN_BUS,
	input [1:0] ARBURST_BUS
	
);

	logic [`AXI_IDS_BITS-1:0] RID_BUS;
	logic [`AXI_DATA_BITS-1:0] RDATA_BUS;
	logic [1:0] RRESP_BUS;
	logic RLAST_BUS;
	logic RVALID_BUS;
	logic RREADY_BUS;
	
	logic [`AXI_LEN_BITS-1:0] cnt;
	parameter S0=3'd0, S1=3'd1, S2=3'd2, S3=3'd3, S4=3'd4, S5=3'd5, DEF=3'd6;
    parameter R_IDLE = 4'd0, 
	          R_M0 = 4'd1,
			  R_M1 = 4'd2,
			  R_M2 = 4'd3,
			  R_M0_ADDR = 4'd4, 
			  R_M1_ADDR = 4'd5,
			  R_M2_ADDR = 4'd6,
			  R_M0_DATA = 4'd7, 
			  R_M1_DATA = 4'd8,
			  R_M2_DATA = 4'd9;

	always_ff@(posedge  ACLK)begin
		if(!ARESETn)begin
			cnt <= 4'd0;
		end
		else begin
			if(cs==R_M0_DATA)begin
				cnt<= (RVALID_M0 && RREADY_M0) ? (cnt+4'd1):cnt;
			end
			else if(cs==R_M1_DATA)begin
				cnt<= (RVALID_M1 && RREADY_M1) ? (cnt+4'd1):cnt;
			end
			else begin
				cnt<=4'd0;
			end
		end
	end


	
	always_comb begin  /// mux_slave
		case(slave)
		    S0:begin
				RID_BUS = RID_S0;
				RDATA_BUS = RDATA_S0;
				RRESP_BUS = RRESP_S0;
				RLAST_BUS = RLAST_S0;
				RVALID_BUS = RVALID_S0;
				RREADY_S0 = RREADY_BUS;
				RREADY_S1 = 1'b0;
				RREADY_S2 = 1'b0;
				//RREADY_S3 = 1'b0;
			//	RREADY_S4 = 1'b0;
				// RREADY_S5 = 1'b0;
			end
			S1:begin
				RID_BUS = RID_S1;
				RDATA_BUS = RDATA_S1;
				RRESP_BUS = RRESP_S1;
				RLAST_BUS = RLAST_S1;
				RVALID_BUS = RVALID_S1;
				RREADY_S0 = 1'b0;
				RREADY_S1 = RREADY_BUS;
				RREADY_S2 = 1'b0;
				
			end
			S2:begin
				RID_BUS = RID_S2;
				RDATA_BUS = RDATA_S2;
				RRESP_BUS = RRESP_S2;
				RLAST_BUS = RLAST_S2;
				RVALID_BUS = RVALID_S2;
				RREADY_S0 = 1'b0;
				RREADY_S1 = 1'b0;
				RREADY_S2 = RREADY_BUS;
			end
			// S3:begin
			// 	RID_BUS = RID_S3;
			// 	RDATA_BUS = RDATA_S3;
			// 	RRESP_BUS = RRESP_S3;
			// 	RLAST_BUS = RLAST_S3;
			// 	RVALID_BUS = RVALID_S3;
			// 	RREADY_S0 = 1'b0;
			// 	RREADY_S1 = 1'b0;
			// 	RREADY_S2 = 1'b0;
			// 	RREADY_S3 = RREADY_BUS;
			 	//RREADY_S4 = 1'b0;
			// 	RREADY_S5 = 1'b0;
			// end
			// S4:begin
			// 	RID_BUS = RID_S4;
			// 	RDATA_BUS = RDATA_S4;
			// 	RRESP_BUS = RRESP_S4;
			// 	RLAST_BUS = RLAST_S4;
			// 	RVALID_BUS = RVALID_S4;
			// 	RREADY_S0 = 1'b0;
			// 	RREADY_S1 = 1'b0;
			// 	RREADY_S2 = 1'b0;
			// 	RREADY_S3 = 1'b0;
			// 	RREADY_S4 = RREADY_BUS;
			// 	RREADY_S5 = 1'b0;
			// end
			S5:begin
				// RID_BUS = RID_S5;
				// RDATA_BUS = RDATA_S5;
				// RRESP_BUS = RRESP_S5;
				// RLAST_BUS = RLAST_S5;
				// RVALID_BUS = RVALID_S5;
				// RREADY_S0 = 1'b0;
				// RREADY_S1 = 1'b0;
				// RREADY_S2 = 1'b0;
				//RREADY_S3 = 1'b0;
				//RREADY_S4 = 1'b0;
				// RREADY_S5 = RREADY_BUS;
			end
			default begin  //! 這邊可能要改
					RID_BUS = ARID_BUS;
			    	RDATA_BUS = 32'd0;
			   		RRESP_BUS = `AXI_RESP_DECERR;
				if(ARBURST_BUS==`AXI_BURST_INC)begin
			   		RLAST_BUS = ((cnt)==ARLEN_BUS)? 1'd1:1'd0;
				end
				else begin
					RLAST_BUS = 1'd1;
				end
			   		RVALID_BUS = RREADY_BUS; 
					RREADY_S1 = 1'b0;
					RREADY_S2 =  1'b0;
			end
		endcase
	end
		
	
	always_comb begin/// mux_master
	
		case(cs)
			R_M0_DATA:begin
				RID_M0 = RID_BUS[3:0];
				RDATA_M0 = RDATA_BUS;
				RRESP_M0 = (slave ==DEF) ? `AXI_RESP_DECERR : RRESP_BUS ;
				RLAST_M0 = RLAST_BUS;
				RVALID_M0 = RVALID_BUS; 
				RID_M1 = 4'd0;
				RDATA_M1 = 32'd0;
				RRESP_M1 = 2'd0;
				RLAST_M1 = 1'd0;
				RVALID_M1 = 1'd0;

				RREADY_BUS = RREADY_M0;
			end
			R_M1_DATA:begin
				RID_M0 = 4'd0;
				RDATA_M0 = 32'd0;
				RRESP_M0 = 2'd0;
				RLAST_M0 = 1'd0;
				RVALID_M0 = 1'd0;
				RID_M1 = RID_BUS[3:0];
				RDATA_M1 = RDATA_BUS;
				RRESP_M1 = (slave ==DEF) ? `AXI_RESP_DECERR : RRESP_BUS ;
				RLAST_M1 = RLAST_BUS;
				RVALID_M1 = RVALID_BUS;
				
                RREADY_BUS = RREADY_M1;
			end 
			R_M2_DATA:begin
				RID_M0 = 4'd0;
				RDATA_M0 = 32'd0;
				RRESP_M0 = 2'd0;
				RLAST_M0 = 1'd0;
				RVALID_M0 = 1'd0;
				RID_M1 = 4'd0;
				RDATA_M1 = 32'd0;
				RRESP_M1 = 2'd0;
				RLAST_M1 = 1'd0;
				RVALID_M1 = 1'd0;

				// RREADY_BUS = RREADY_M2;
			end 
			default:begin
				RID_M0 = 4'd0;
				RDATA_M0 = 32'd0;
				RRESP_M0 = 2'd0;
				RLAST_M0 = 1'd0;
				RVALID_M0 = 1'd0;
				RID_M1 = 4'd0;
				RDATA_M1 = 32'd0;
				RRESP_M1 = 2'd0;
				RLAST_M1 = 1'd0;
				RVALID_M1 = 1'd0;		
				RREADY_BUS = 1'd0;
			end
		endcase

	end
	

endmodule
