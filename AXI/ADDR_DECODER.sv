`include "../include/AXI_define.svh"
module ADDR_DECODER( 
    //ADDR_BUS
	input [`AXI_IDS_BITS-1:0] AID_BUS,//A FOR AR OR AW
	input [`AXI_ADDR_BITS-1:0] ADDR_BUS,
	input [`AXI_LEN_BITS-1:0] ALEN_BUS,
	input [`AXI_SIZE_BITS-1:0] ASIZE_BUS,
	input [1:0] ABURST_BUS,
	input AVALID_BUS,
	
	output logic [`AXI_IDS_BITS-1:0] AID_S0,
	output logic [`AXI_ADDR_BITS-1:0] ADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] ALEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] ASIZE_S0,
	output logic [1:0] ABURST_S0,
	output logic AVALID_S0,
	
	output logic [`AXI_IDS_BITS-1:0] AID_S1,
	output logic [`AXI_ADDR_BITS-1:0] ADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] ALEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] ASIZE_S1,
	output logic [1:0] ABURST_S1,
	output logic AVALID_S1,
	input  [1:0] slave
);
	
always_comb begin
	case(slave)
		`SLAVE0 : begin
			AID_S0    = AID_BUS;
			ADDR_S0   = ADDR_BUS;
			ALEN_S0   = ALEN_BUS;
			ASIZE_S0  = ASIZE_BUS;
			ABURST_S0 = ABURST_BUS;
			AVALID_S0 = AVALID_BUS;

			AID_S1    = `AXI_IDS_BITS'd0;
			ADDR_S1   = `AXI_ADDR_BITS'd0;
			ALEN_S1   = `AXI_LEN_BITS'd0;
			ASIZE_S1  = `AXI_SIZE_BITS'd0;
			ABURST_S1 = 2'd0;
			AVALID_S1 = 1'b0;		
		end
		`SLAVE1 : begin
			AID_S0    = `AXI_IDS_BITS'd0;
			ADDR_S0   = `AXI_ADDR_BITS'd0;
			ALEN_S0   = `AXI_LEN_BITS'd0;
			ASIZE_S0  = `AXI_SIZE_BITS'd0;
			ABURST_S0 = 2'd0;
			AVALID_S0 = 1'b0;	
				
			AID_S1    = AID_BUS;
			ADDR_S1   = ADDR_BUS;
			ALEN_S1   = ALEN_BUS;
			ASIZE_S1  = ASIZE_BUS;
			ABURST_S1 = ABURST_BUS;
			AVALID_S1 = AVALID_BUS;			
		end
		default : begin
			AID_S0    = `AXI_IDS_BITS'd0;
			ADDR_S0   = `AXI_ADDR_BITS'd0;
			ALEN_S0   = `AXI_LEN_BITS'd0;
			ASIZE_S0  = `AXI_SIZE_BITS'd0;
			ABURST_S0 = 2'd0;
			AVALID_S0 = 1'b0;	
				
			AID_S1    = `AXI_IDS_BITS'd0;
			ADDR_S1   = `AXI_ADDR_BITS'd0;
			ALEN_S1   = `AXI_LEN_BITS'd0;
			ASIZE_S1  = `AXI_SIZE_BITS'd0;
			ABURST_S1 = 2'd0;
			AVALID_S1 = 1'b0;	
		end
	endcase
end
	
endmodule
