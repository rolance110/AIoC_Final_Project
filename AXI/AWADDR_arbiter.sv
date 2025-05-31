`include "../include/AXI_define.svh"
module AWADDR_arbiter(
	input ACLK,
	input ARESETn,
	input [`AXI_ID_BITS-1:0] AWID_M0,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M0,
	input [`AXI_LEN_BITS-1:0] AWLEN_M0,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M0,
	input [1:0] AWBURST_M0,
	input AWVALID_M0,
	
	input [`AXI_ID_BITS-1:0] AWID_M1,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	input [1:0] AWBURST_M1,
	input AWVALID_M1,
	
	input WRITE_DONE,
	input WVALID_M0,
	input WVALID_M1,
	
	output logic [`AXI_IDS_BITS-1:0] AWID_BUS,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_BUS,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_BUS,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_BUS,
	output logic [1:0] AWBURST_BUS,
	output logic AWVALID_BUS,
	
	input READY_S0,
	input READY_S1,
	output logic READY_M0,
	output logic READY_M1,
	
	output logic [1:0] current_Wstate,
	output logic [1:0] slave   
);
	
logic [1:0] next_Wstate;
logic [`AXI_ADDR_BITS-1:0] AWADDR_reg;

	
always_comb begin
	if(AWADDR_BUS[31:16] == 16'd0)
	    slave = `SLAVE0;		
	else if(AWADDR_BUS[31:16] == 16'd1)
	    slave = `SLAVE1;
	else 
	    slave = `DEFAULT_SLAVE;
end
	
always_ff @ (posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)
        current_Wstate <= `W_M1;
    else 
        current_Wstate <= next_Wstate;
end

always_comb begin	
	case(current_Wstate)
		`W_M1 : begin
			if((slave == `SLAVE0) && AWVALID_M1)begin			
				next_Wstate = (READY_S0) ? `M1_WDATA :`M1_AWADDR;
			end
			else if((slave == `SLAVE1) && AWVALID_M1)begin
				next_Wstate = (READY_S1) ? `M1_WDATA :`M1_AWADDR;
			end
			else begin
				next_Wstate = `W_M1;
			end							
		end

		`M1_AWADDR : begin			
			next_Wstate = ((slave == `SLAVE0 && READY_S0) || (slave == `SLAVE1 && READY_S1)) ? `M1_WDATA : `M1_AWADDR;			
		end

		`M1_WDATA:begin
			next_Wstate =(WRITE_DONE) ? `W_M1 : `M1_WDATA;	
		end
		default : begin
			next_Wstate = `W_M1;
		end
	endcase
end

always_comb begin
	case(current_Wstate)
		`W_M1 : begin
			AWLEN_BUS   = AWLEN_M1;
			AWADDR_BUS  = AWADDR_M1;
			AWSIZE_BUS  = AWSIZE_M1;
			AWBURST_BUS = AWBURST_M1;
			AWID_BUS    = {4'd0, AWID_M1};
			READY_M0    = 1'd0;
			READY_M1    = (slave == `SLAVE0) ? READY_S0 :
						  (slave == `SLAVE1) ? READY_S1 :
						  1'd0;
			AWVALID_BUS = AWVALID_M1 ;
		end

		`M1_AWADDR : begin
			AWLEN_BUS   = AWLEN_M1 ;
			AWADDR_BUS  = AWADDR_M1 ;
			AWSIZE_BUS  = AWSIZE_M1 ;
			AWBURST_BUS = AWBURST_M1 ;
			AWID_BUS    = {4'd0, AWID_M1};
			READY_M0    = 1'd0;
			READY_M1    = (slave == `SLAVE0) ? READY_S0 :
					      (slave == `SLAVE1) ? READY_S1 :
					      1'd1;
			AWVALID_BUS = AWVALID_M1;
		end

		`M1_WDATA : begin
			AWLEN_BUS   = 4'd0;
			AWADDR_BUS  = AWADDR_reg;
			AWSIZE_BUS  = 3'd0;
			AWBURST_BUS = 2'd0;
			AWID_BUS    = 8'd0;
			READY_M0    = 1'd0;
			READY_M1    = 1'd0;
			AWVALID_BUS = 1'd0;
		end
		default : begin
			AWLEN_BUS   = 4'd0;
			AWADDR_BUS  = 32'd0;
			AWSIZE_BUS  = 3'd0;
			AWBURST_BUS = 2'd0;
			AWID_BUS    = 8'd0;
			READY_M0    = 1'd0;
			READY_M1    = 1'd0;
			AWVALID_BUS = 1'd0;
		end
	endcase
end
	
always_ff @ (posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		AWADDR_reg <= 32'd0;
	end
	else begin
		if((current_Wstate == `W_M1) || (current_Wstate == `M1_AWADDR))begin
			AWADDR_reg <= AWADDR_BUS;
		end
		else begin
			AWADDR_reg <= AWADDR_reg;
		end
	end
end
	
endmodule
