
module addr_dec_s(

	input [`AXI_IDS_BITS-1:0] AID_BUS,
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
	
	
	output logic [`AXI_IDS_BITS-1:0] AID_S2,
	output logic [`AXI_ADDR_BITS-1:0] ADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] ALEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] ASIZE_S2,
	output logic [1:0] ABURST_S2,
	output logic AVALID_S2,
	input  [2:0] slave 
	
);
	
	parameter S0=3'd0, S1=3'd1, S2=3'd2, S3=3'd3, S4=3'd4, S5=3'd5, DEF=3'd6;
	always_comb begin
		case(slave)
		S0:begin

 				AID_S0 = AID_BUS;
				ADDR_S0 = ADDR_BUS;
				ALEN_S0 = ALEN_BUS;
				ASIZE_S0 = ASIZE_BUS;
				
				ABURST_S0 = ABURST_BUS;
				AVALID_S0 = AVALID_BUS;

				AID_S1 = `AXI_IDS_BITS'd0;
				ADDR_S1 = `AXI_ADDR_BITS'd0;
				ALEN_S1 = `AXI_LEN_BITS'd0;
				ASIZE_S1 = `AXI_SIZE_BITS'd0;

				ABURST_S1 = 2'd0;
				AVALID_S1 = 1'b0;

				AID_S2 = `AXI_IDS_BITS'd0;
				ADDR_S2 = `AXI_ADDR_BITS'd0;
				ALEN_S2 = `AXI_LEN_BITS'd0;
				ASIZE_S2 = `AXI_SIZE_BITS'd0;

				ABURST_S2 = 2'd0;
				AVALID_S2 = 1'b0;
				
				// AID_S3 = `AXI_IDS_BITS'd0;
				// ADDR_S3 = `AXI_ADDR_BITS'd0;
				// ALEN_S3 = `AXI_LEN_BITS'd0;
				// ASIZE_S3 = `AXI_SIZE_BITS'd0;

				// ABURST_S3 = 2'd0;
				// AVALID_S3 = 1'b0;

				// AID_S4 = `AXI_IDS_BITS'd0;
				// ADDR_S4 = `AXI_ADDR_BITS'd0;
				// ALEN_S4 = `AXI_LEN_BITS'd0;
				// ASIZE_S4 = `AXI_SIZE_BITS'd0;

				// ABURST_S4 = 2'd0;
				// AVALID_S4 = 1'b0;

				// AID_S5 = `AXI_IDS_BITS'd0;
				// ADDR_S5 = `AXI_ADDR_BITS'd0;
				// ALEN_S5 = `AXI_LEN_BITS'd0;
				// ASIZE_S5 = `AXI_SIZE_BITS'd0;

				// ABURST_S5 = 2'd0;
				// AVALID_S5 = 1'b0;
				
			end
			S1:begin

 				AID_S0 = `AXI_IDS_BITS'd0;
				ADDR_S0 = `AXI_ADDR_BITS'd0;
				ALEN_S0 = `AXI_LEN_BITS'd0;
				ASIZE_S0 = `AXI_SIZE_BITS'd0;

				ABURST_S0 = 2'd0;
				AVALID_S0 = 1'b0;

				AID_S1 = AID_BUS;
				ADDR_S1 = ADDR_BUS;
				ALEN_S1 = ALEN_BUS;
				ASIZE_S1 = ASIZE_BUS;
				
				ABURST_S1 = ABURST_BUS;
				AVALID_S1 = AVALID_BUS;

				AID_S2 = `AXI_IDS_BITS'd0;
				ADDR_S2 = `AXI_ADDR_BITS'd0;
				ALEN_S2 = `AXI_LEN_BITS'd0;
				ASIZE_S2 = `AXI_SIZE_BITS'd0;

				ABURST_S2 = 2'd0;
				AVALID_S2 = 1'b0;
				
				// AID_S3 = `AXI_IDS_BITS'd0;
				// ADDR_S3 = `AXI_ADDR_BITS'd0;
				// ALEN_S3 = `AXI_LEN_BITS'd0;
				// ASIZE_S3 = `AXI_SIZE_BITS'd0;

				// ABURST_S3 = 2'd0;
				// AVALID_S3 = 1'b0;

				// AID_S4 = `AXI_IDS_BITS'd0;
				// ADDR_S4 = `AXI_ADDR_BITS'd0;
				// ALEN_S4 = `AXI_LEN_BITS'd0;
				// ASIZE_S4 = `AXI_SIZE_BITS'd0;

				// ABURST_S4 = 2'd0;
				// AVALID_S4 = 1'b0;

				// AID_S5 = `AXI_IDS_BITS'd0;
				// ADDR_S5 = `AXI_ADDR_BITS'd0;
				// ALEN_S5 = `AXI_LEN_BITS'd0;
				// ASIZE_S5 = `AXI_SIZE_BITS'd0;

				// ABURST_S5 = 2'd0;
				// AVALID_S5 = 1'b0;
				
			end
			S2:begin				
 				AID_S0 = `AXI_IDS_BITS'd0;
				ADDR_S0 = `AXI_ADDR_BITS'd0;
				ALEN_S0 = `AXI_LEN_BITS'd0;
				ASIZE_S0 = `AXI_SIZE_BITS'd0;

				ABURST_S0 = 2'd0;
				AVALID_S0 = 1'b0;

				AID_S1 = `AXI_IDS_BITS'd0;
				ADDR_S1 = `AXI_ADDR_BITS'd0;
				ALEN_S1 = `AXI_LEN_BITS'd0;
				ASIZE_S1 = `AXI_SIZE_BITS'd0;

				ABURST_S1 = 2'd0;
				AVALID_S1 = 1'b0;

				AID_S2 = AID_BUS;
				ADDR_S2 = ADDR_BUS;
				ALEN_S2 = ALEN_BUS;
				ASIZE_S2 = ASIZE_BUS;
				
				ABURST_S2 = ABURST_BUS;
				AVALID_S2 = AVALID_BUS;
				
				// AID_S3 = `AXI_IDS_BITS'd0;
				// ADDR_S3 = `AXI_ADDR_BITS'd0;
				// ALEN_S3 = `AXI_LEN_BITS'd0;
				// ASIZE_S3 = `AXI_SIZE_BITS'd0;

				// ABURST_S3 = 2'd0;
				// AVALID_S3 = 1'b0;

				// AID_S4 = `AXI_IDS_BITS'd0;
				// ADDR_S4 = `AXI_ADDR_BITS'd0;
				// ALEN_S4 = `AXI_LEN_BITS'd0;
				// ASIZE_S4 = `AXI_SIZE_BITS'd0;

				// ABURST_S4 = 2'd0;
				// AVALID_S4 = 1'b0;

				// AID_S5 = `AXI_IDS_BITS'd0;
				// ADDR_S5 = `AXI_ADDR_BITS'd0;
				// ALEN_S5 = `AXI_LEN_BITS'd0;
				// ASIZE_S5 = `AXI_SIZE_BITS'd0;

				// ABURST_S5 = 2'd0;
				// AVALID_S5 = 1'b0;		
			end
			S3:begin				
 				AID_S0 = `AXI_IDS_BITS'd0;
				ADDR_S0 = `AXI_ADDR_BITS'd0;
				ALEN_S0 = `AXI_LEN_BITS'd0;
				ASIZE_S0 = `AXI_SIZE_BITS'd0;

				ABURST_S0 = 2'd0;
				AVALID_S0 = 1'b0;

				AID_S1 = `AXI_IDS_BITS'd0;
				ADDR_S1 = `AXI_ADDR_BITS'd0;
				ALEN_S1 = `AXI_LEN_BITS'd0;
				ASIZE_S1 = `AXI_SIZE_BITS'd0;

				ABURST_S1 = 2'd0;
				AVALID_S1 = 1'b0;

				AID_S2 = `AXI_IDS_BITS'd0;
				ADDR_S2 = `AXI_ADDR_BITS'd0;
				ALEN_S2 = `AXI_LEN_BITS'd0;
				ASIZE_S2 = `AXI_SIZE_BITS'd0;

				ABURST_S2 = 2'd0;
				AVALID_S2 = 1'b0;
				
				// AID_S3 = AID_BUS;
				// ADDR_S3 = ADDR_BUS;
				// ALEN_S3 = ALEN_BUS;
				// ASIZE_S3 = ASIZE_BUS;
				
				// ABURST_S3 = ABURST_BUS;
				// AVALID_S3 = AVALID_BUS;

				// AID_S4 = `AXI_IDS_BITS'd0;
				// ADDR_S4 = `AXI_ADDR_BITS'd0;
				// ALEN_S4 = `AXI_LEN_BITS'd0;
				// ASIZE_S4 = `AXI_SIZE_BITS'd0;

				// ABURST_S4 = 2'd0;
				// AVALID_S4 = 1'b0;

				// AID_S5 = `AXI_IDS_BITS'd0;
				// ADDR_S5 = `AXI_ADDR_BITS'd0;
				// ALEN_S5 = `AXI_LEN_BITS'd0;
				// ASIZE_S5 = `AXI_SIZE_BITS'd0;

				// ABURST_S5 = 2'd0;
				// AVALID_S5 = 1'b0;		
			end
			S4:begin				
 				AID_S0 = `AXI_IDS_BITS'd0;
				ADDR_S0 = `AXI_ADDR_BITS'd0;
				ALEN_S0 = `AXI_LEN_BITS'd0;
				ASIZE_S0 = `AXI_SIZE_BITS'd0;

				ABURST_S0 = 2'd0;
				AVALID_S0 = 1'b0;

				AID_S1 = `AXI_IDS_BITS'd0;
				ADDR_S1 = `AXI_ADDR_BITS'd0;
				ALEN_S1 = `AXI_LEN_BITS'd0;
				ASIZE_S1 = `AXI_SIZE_BITS'd0;

				ABURST_S1 = 2'd0;
				AVALID_S1 = 1'b0;

				AID_S2 = `AXI_IDS_BITS'd0;
				ADDR_S2 = `AXI_ADDR_BITS'd0;
				ALEN_S2 = `AXI_LEN_BITS'd0;
				ASIZE_S2 = `AXI_SIZE_BITS'd0;

				ABURST_S2 = 2'd0;
				AVALID_S2 = 1'b0;
				
				// AID_S3 = `AXI_IDS_BITS'd0;
				// ADDR_S3 = `AXI_ADDR_BITS'd0;
				// ALEN_S3 = `AXI_LEN_BITS'd0;
				// ASIZE_S3 = `AXI_SIZE_BITS'd0;

				// ABURST_S3 = 2'd0;
				// AVALID_S3 = 1'b0;

				// AID_S4 = AID_BUS;
				// ADDR_S4 = ADDR_BUS;
				// ALEN_S4 = ALEN_BUS;
				// ASIZE_S4 = ASIZE_BUS;
				
				// ABURST_S4 = ABURST_BUS;
				// AVALID_S4 = AVALID_BUS;

				// AID_S5 = `AXI_IDS_BITS'd0;
				// ADDR_S5 = `AXI_ADDR_BITS'd0;
				// ALEN_S5 = `AXI_LEN_BITS'd0;
				// ASIZE_S5 = `AXI_SIZE_BITS'd0;

				// ABURST_S5 = 2'd0;
				// AVALID_S5 = 1'b0;		
			end
			S5:begin				
 				AID_S0 = `AXI_IDS_BITS'd0;
				ADDR_S0 = `AXI_ADDR_BITS'd0;
				ALEN_S0 = `AXI_LEN_BITS'd0;
				ASIZE_S0 = `AXI_SIZE_BITS'd0;

				ABURST_S0 = 2'd0;
				AVALID_S0 = 1'b0;

				AID_S1 = `AXI_IDS_BITS'd0;
				ADDR_S1 = `AXI_ADDR_BITS'd0;
				ALEN_S1 = `AXI_LEN_BITS'd0;
				ASIZE_S1 = `AXI_SIZE_BITS'd0;

				ABURST_S1 = 2'd0;
				AVALID_S1 = 1'b0;

				AID_S2 = `AXI_IDS_BITS'd0;
				ADDR_S2 = `AXI_ADDR_BITS'd0;
				ALEN_S2 = `AXI_LEN_BITS'd0;
				ASIZE_S2 = `AXI_SIZE_BITS'd0;

				ABURST_S2 = 2'd0;
				AVALID_S2 = 1'b0;
				
				// AID_S3 = `AXI_IDS_BITS'd0;
				// ADDR_S3 = `AXI_ADDR_BITS'd0;
				// ALEN_S3 = `AXI_LEN_BITS'd0;
				// ASIZE_S3 = `AXI_SIZE_BITS'd0;

				// ABURST_S3 = 2'd0;
				// AVALID_S3 = 1'b0;

				// AID_S4 = `AXI_IDS_BITS'd0;
				// ADDR_S4 = `AXI_ADDR_BITS'd0;
				// ALEN_S4 = `AXI_LEN_BITS'd0;
				// ASIZE_S4 = `AXI_SIZE_BITS'd0;

				// ABURST_S4 = 2'd0;
				// AVALID_S4 = 1'b0;

				// AID_S5 = AID_BUS;
				// ADDR_S5 = ADDR_BUS;
				// ALEN_S5 = ALEN_BUS;
				// ASIZE_S5 = ASIZE_BUS;
				
				// ABURST_S5 = ABURST_BUS;
				// AVALID_S5 = AVALID_BUS;		
			end
			default:begin
				AID_S0 = `AXI_IDS_BITS'd0;
				ADDR_S0 = `AXI_ADDR_BITS'd0;
				ALEN_S0 = `AXI_LEN_BITS'd0;
				ASIZE_S0 = `AXI_SIZE_BITS'd0;

				ABURST_S0 = 2'd0;
				AVALID_S0 = 1'b0;

				AID_S1 = `AXI_IDS_BITS'd0;
				ADDR_S1 = `AXI_ADDR_BITS'd0;
				ALEN_S1 = `AXI_LEN_BITS'd0;
				ASIZE_S1 = `AXI_SIZE_BITS'd0;

				ABURST_S1 = 2'd0;
				AVALID_S1 = 1'b0;

				AID_S2 = `AXI_IDS_BITS'd0;
				ADDR_S2 = `AXI_ADDR_BITS'd0;
				ALEN_S2 = `AXI_LEN_BITS'd0;
				ASIZE_S2 = `AXI_SIZE_BITS'd0;

				ABURST_S2 = 2'd0;
				AVALID_S2 = 1'b0;
				
				// AID_S3 = `AXI_IDS_BITS'd0;
				// ADDR_S3 = `AXI_ADDR_BITS'd0;
				// ALEN_S3 = `AXI_LEN_BITS'd0;
				// ASIZE_S3 = `AXI_SIZE_BITS'd0;

				// ABURST_S3 = 2'd0;
				// AVALID_S3 = 1'b0;

				// AID_S4 = `AXI_IDS_BITS'd0;
				// ADDR_S4 = `AXI_ADDR_BITS'd0;
				// ALEN_S4 = `AXI_LEN_BITS'd0;
				// ASIZE_S4 = `AXI_SIZE_BITS'd0;

				// ABURST_S4 = 2'd0;
				// AVALID_S4 = 1'b0;

				// AID_S5 = `AXI_IDS_BITS'd0;
				// ADDR_S5 = `AXI_ADDR_BITS'd0;
				// ALEN_S5 = `AXI_LEN_BITS'd0;
				// ASIZE_S5 = `AXI_SIZE_BITS'd0;

				// ABURST_S5 = 2'd0;
				// AVALID_S5 = 1'b0;	
				
				
			end
		endcase
	end
	
	
	
endmodule
