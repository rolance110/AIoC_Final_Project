`include "../include/AXI_define.svh"
module ARADDR_arbiter(
	input ACLK,
	input ARESETn,
	//----------M0 AR----------//
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,
	input ARVALID_M0,
	output logic ARREADY_M0,
	//----------M1 AR----------//
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output logic ARREADY_M1,
	//----------AR BUS----------//
	output logic [`AXI_IDS_BITS-1:0] ARID_BUS,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_BUS,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_BUS,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_BUS,
	output logic [1:0] ARBURST_BUS,
	output logic ARVALID_BUS,


	input ARREADY_S0,
	input ARREADY_S1,
	input RVALID_M0, 
	input RREADY_M0,
	input RLAST_M0,
	input RVALID_M1,
	input RREADY_M1,
	input RLAST_M1,
	output logic [1:0] current_Rstate,
	output logic [1:0] slave  
);

logic [`AXI_LEN_BITS-1:0] ARLEN_reg;
logic [`AXI_ID_BITS-1:0] ARID_reg;
logic [1:0] ARBURST_reg;
logic [31:0] ARADDR_reg;
logic [1:0] next_Rstate; 
///////////////////////////////////////////////////
always_ff@(posedge ACLK or negedge ARESETn)begin
    if(~ARESETn)
        current_Rstate <= `M0_ARADDR;
    else 
        current_Rstate <= next_Rstate;
end
    
always_comb begin
	if(ARADDR_BUS[31:16] == 16'd0)
	    slave = `SLAVE0;		
	else if(ARADDR_BUS[31:16] == 16'd1)
	    slave = `SLAVE1;
	else 
	    slave = `DEFAULT_SLAVE;
end
	
always_comb begin 
	case(current_Rstate)
		`M0_ARADDR:begin
			if(ARREADY_M0 && ARVALID_M0) begin
				next_Rstate = `M0_RDATA;
			end
			else if(ARVALID_M0) begin
				next_Rstate = `M0_ARADDR;
			end
			else if(ARVALID_M1) begin
				next_Rstate = `M1_ARADDR;
			end
			else 
				next_Rstate = `M0_ARADDR;
		end
		`M1_ARADDR:begin
			next_Rstate = (ARREADY_M1 && ARVALID_M1)  ? `M1_RDATA : `M1_ARADDR;
		end
		`M0_RDATA:begin
			if (RVALID_M0 && RREADY_M0 && RLAST_M0) begin
				if(ARVALID_M0) begin
					next_Rstate = `M0_ARADDR;
				end
				else if(ARVALID_M1) begin
				    next_Rstate = `M1_ARADDR;
				end
				else begin
				    next_Rstate = `M0_ARADDR;
				end
			end
			else    next_Rstate = `M0_RDATA;
		end
		`M1_RDATA:begin
			if (RVALID_M1 && RREADY_M1 && RLAST_M1) begin
				next_Rstate = `M0_ARADDR;
			end
			else 
				next_Rstate = `M1_RDATA;
		end
		default:begin
			    next_Rstate=`M0_ARADDR;
		end
    endcase 
end
					
always_ff@(posedge  ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		ARADDR_reg  <= 32'd0;
		ARID_reg    <= 4'd0;
		ARLEN_reg   <= 4'd0; 
		ARBURST_reg <= 2'd0;		
	end
	else begin
		if((current_Rstate == `M0_ARADDR)&& ARVALID_M0 && ARREADY_M0)begin
			ARADDR_reg  <= ARADDR_M0;
			ARID_reg    <= ARID_M0;
			ARLEN_reg   <= ARLEN_M0;
			ARBURST_reg <= ARBURST_M0;		
		end
		else if((current_Rstate == `M1_ARADDR) && ARVALID_M1 && ARREADY_M1)begin
			ARADDR_reg  <= ARADDR_M1 ;
			ARID_reg    <= ARID_M1;
			ARLEN_reg   <= ARLEN_M1;
			ARBURST_reg <= ARBURST_M1;				
		end
		else begin
			ARADDR_reg  <= ARADDR_reg;
			ARID_reg    <= ARID_reg;
			ARLEN_reg   <= ARLEN_reg;
			ARBURST_reg <= ARBURST_reg;	
		end
	end
end


always_comb begin
	case(current_Rstate)
		`M0_ARADDR:begin
			if (ARVALID_M0) begin
				ARID_BUS    = {4'd0, ARID_M0};
				ARADDR_BUS  = ARADDR_M0 ;
				ARLEN_BUS   = ARLEN_M0; 
				ARSIZE_BUS  = ARSIZE_M0;
				ARBURST_BUS = ARBURST_M0;
				ARVALID_BUS = ARVALID_M0;
				ARREADY_M0  = (ARADDR_M0[31:16] == 16'd0)? ARREADY_S0: ARREADY_S1 ;
				ARREADY_M1  = 1'd0;
			end
			else if(ARVALID_M1) begin
				ARID_BUS    = {4'd0, ARID_M1};
				ARADDR_BUS  = ARADDR_M1 ;
				ARLEN_BUS   = ARLEN_M1; 
				ARSIZE_BUS  = ARSIZE_M1;
				ARBURST_BUS = ARBURST_M1;
				ARVALID_BUS = ARVALID_M1;
				ARREADY_M0  = 1'd0;
				ARREADY_M1  = (ARADDR_M1[31:16] == 16'd0)? ARREADY_S0: ARREADY_S1 ;
			end
			else begin
				ARID_BUS    = {4'd0, ARID_reg};
				ARADDR_BUS  = ARADDR_reg ;
				ARLEN_BUS   = ARLEN_reg; 
				ARSIZE_BUS  = 3'd0;
				ARBURST_BUS = ARBURST_reg;
				ARVALID_BUS = 1'd0;
				ARREADY_M0  = 1'd0;
				ARREADY_M1  = 1'd0;
			end
		end
		`M1_ARADDR:begin
			if (ARVALID_M1) begin
				ARID_BUS    = {4'd0, ARID_M1};
				ARADDR_BUS  = ARADDR_M1 ;
				ARLEN_BUS   = ARLEN_M1; 
				ARSIZE_BUS  = ARSIZE_M1;
				ARBURST_BUS = ARBURST_M1;
				ARVALID_BUS = ARVALID_M1;
				ARREADY_M0  = 1'd0;
				ARREADY_M1  = (ARADDR_M1[31:16] == 16'd0)? ARREADY_S0: ARREADY_S1 ;
			end
			else begin
				ARID_BUS    = {4'd0, ARID_reg};
				ARADDR_BUS  = ARADDR_reg ;
				ARLEN_BUS   = ARLEN_reg; 
				ARSIZE_BUS  = 3'd0;
				ARBURST_BUS = ARBURST_reg;
				ARVALID_BUS = 1'd0;
				ARREADY_M0  = 1'd0;
				ARREADY_M1  = 1'd0;
			end
		end
		`M0_RDATA:begin
			ARID_BUS    = {4'd0, ARID_reg};
			ARADDR_BUS  = ARADDR_reg;
			ARLEN_BUS   = ARLEN_reg; 
			ARSIZE_BUS  = 3'd0;
			ARBURST_BUS = ARBURST_reg;
			ARVALID_BUS = 1'd0;
			ARREADY_M0  = 1'd0;
			ARREADY_M1  = 1'd0;
		end
		`M1_RDATA:begin
			ARID_BUS    = {4'd0, ARID_reg};
			ARADDR_BUS  = ARADDR_reg;
			ARLEN_BUS   = ARLEN_reg; 
			ARSIZE_BUS  = 3'd0;
			ARBURST_BUS = ARBURST_reg;
			ARVALID_BUS = 1'd0;
			ARREADY_M0  = 1'd0;
			ARREADY_M1  = 1'd0;
		end
		default:begin
			ARID_BUS    = {4'd0, ARID_reg};
			ARADDR_BUS  = ARADDR_reg;
			ARLEN_BUS   = ARLEN_reg; 
			ARSIZE_BUS  = 3'd0;
			ARBURST_BUS = ARBURST_reg;
			ARVALID_BUS = 1'd0;
			ARREADY_M0  = 1'd0;
			ARREADY_M1  = 1'd0;
		end
	endcase
end	
	
endmodule
