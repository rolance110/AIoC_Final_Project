`include "../include/AXI_define.svh"
module R_channel(
	input ACLK,
	input ARESETn,
    //R_S0
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	//R_S1
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
    //READY SIGNAL
	output logic RREADY_S0,
	output logic RREADY_S1,
	input RREADY_M0,
	input RREADY_M1,
	/////////////////////////////////
    //R_M0
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	//R_M1
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,
	
	input [1:0] current_Rstate,
	input [1:0] slave,

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
logic [`AXI_LEN_BITS-1:0] BURST_LEN_CNT;
	


always_ff@(posedge  ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		BURST_LEN_CNT <= 4'd0;
	end
	else begin
		if(current_Rstate == `M0_RDATA)begin
			BURST_LEN_CNT <= (RVALID_M0 && RREADY_M0) ? (BURST_LEN_CNT+4'd1) : BURST_LEN_CNT;
		end
		else if(current_Rstate == `M1_RDATA)begin
			BURST_LEN_CNT <= (RVALID_M1 && RREADY_M1) ? (BURST_LEN_CNT+4'd1) : BURST_LEN_CNT;
		end
		else begin
			BURST_LEN_CNT <= 4'd0;
		end
	end
end


	
always_comb begin  /// mux_slave
	case(slave)
		`SLAVE0 : begin
			RID_BUS    = RID_S0;
			RDATA_BUS  = RDATA_S0;
			RRESP_BUS  = RRESP_S0;
			RLAST_BUS  = RLAST_S0;
			RVALID_BUS = RVALID_S0;
			RREADY_S0  = RREADY_BUS;
			RREADY_S1  = 1'b0;
		end
		`SLAVE1 : begin
			RID_BUS    = RID_S1;
			RDATA_BUS  = RDATA_S1;
			RRESP_BUS  = RRESP_S1;
			RLAST_BUS  = RLAST_S1;
			RVALID_BUS = RVALID_S1;
			RREADY_S0  = 1'b0;
			RREADY_S1  = RREADY_BUS;
		end
		default : begin
			RID_BUS   = ARID_BUS;
		    RDATA_BUS = 32'd0;
		   	RRESP_BUS = `AXI_RESP_DECERR;
			if(ARBURST_BUS == `AXI_BURST_INC)begin
		   		RLAST_BUS = ((BURST_LEN_CNT) == ARLEN_BUS) ? 1'b1 : 1'b0;
			end
			else begin
				RLAST_BUS = 1'd1;
			end
			
			RVALID_BUS = RREADY_BUS;  
			RREADY_S0  = 1'b0;
			RREADY_S1  = 1'b0;
				
		end
	endcase
end
		
always_comb begin/// mux_master	
	case(current_Rstate)
		`M0_RDATA : begin
			RID_M0     = RID_BUS[3:0];
			RDATA_M0   = RDATA_BUS;
			RRESP_M0   = (slave == `DEFAULT_SLAVE) ? `AXI_RESP_DECERR : RRESP_BUS ;
			RLAST_M0   = RLAST_BUS;
			RVALID_M0  = RVALID_BUS; 
			RID_M1     = 4'd0;
			RDATA_M1   = 32'd0;
			RRESP_M1   = 2'd0;
			RLAST_M1   = 1'd0;
			RVALID_M1  = 1'd0;
			RREADY_BUS = RREADY_M0;
		end
		`M1_RDATA : begin
			RID_M0     = 4'd0;
			RDATA_M0   = 32'd0;
			RRESP_M0   = 2'd0;
			RLAST_M0   = 1'd0;
			RVALID_M0  = 1'd0;
			RID_M1     = RID_BUS[3:0];
			RDATA_M1   = RDATA_BUS;
			RRESP_M1   = (slave == `DEFAULT_SLAVE) ? `AXI_RESP_DECERR : RRESP_BUS ;
			RLAST_M1   = RLAST_BUS;
			RVALID_M1  = RVALID_BUS;
			RREADY_BUS = RREADY_M1;
		end 
			
		default : begin
			RID_M0     = 4'd0;
			RDATA_M0   = 32'd0;
			RRESP_M0   = 2'd0;
			RLAST_M0   = 1'd0;
			RVALID_M0  = 1'd0;
			RID_M1     = 4'd0;
			RDATA_M1   = 32'd0;
			RRESP_M1   = 2'd0;
			RLAST_M1   = 1'd0;
			RVALID_M1  = 1'd0;		
			RREADY_BUS = 1'd0;
		end
	endcase
end
endmodule
