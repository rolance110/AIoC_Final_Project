
module B_channel(
	output logic [`AXI_ID_BITS-1:0] BID_M0,
	output logic [1:0] BRESP_M0,
	output logic BVALID_M0,
	input BREADY_M0,
	output logic [`AXI_ID_BITS-1:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1,
	input BREADY_M1,

    output logic [`AXI_ID_BITS-1:0] BID_M2,
	output logic [1:0] BRESP_M2,
	output logic BVALID_M2,
	input BREADY_M2,
	
		input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output logic BREADY_S0,


	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic BREADY_S1,

	input [`AXI_IDS_BITS-1:0] BID_S2,
	input [1:0] BRESP_S2,
	input BVALID_S2,
	output logic BREADY_S2,
	
	input [`AXI_IDS_BITS-1:0] BID_S3,
	input [1:0] BRESP_S3,
	input BVALID_S3,
	output logic BREADY_S3,

	input [`AXI_IDS_BITS-1:0] BID_S4,
	input [1:0] BRESP_S4,
	input BVALID_S4,
	output logic BREADY_S4,

	input [`AXI_IDS_BITS-1:0] BID_S5,
	input [1:0] BRESP_S5,
	input BVALID_S5,
	output logic BREADY_S5,



	output logic DONE,
	
	input logic [3:0] cs,
	input [2:0] slave 
	
);

	logic [`AXI_IDS_BITS-1:0] BID_BUS;
	logic [1:0] BRESP_BUS;
	logic BVALID_BUS;
	logic BREADY_BUS;
    parameter S0=3'd0, S1=3'd1, S2=3'd2, S3=3'd3, S4=3'd4, S5=3'd5, DEF=3'd6;	
    parameter W_IDLE =4'd0, 
	          W_M0 = 4'd1, 
			  W_M1 = 4'd2,
			  W_M2 = 4'd3,
			  W_M0_ADDR = 4'd4, 
			  W_M1_ADDR = 4'd5,
			  W_M2_ADDR = 4'd6,
			  W_M0_DATA = 4'd7, 
			  W_M1_DATA = 4'd8,
			  W_M2_DATA = 4'd9, 
			  W_M0_B = 4'd10,  
			  W_M1_B = 4'd11,
			  W_M2_B = 4'd12;
	assign DONE = BVALID_BUS && BREADY_BUS;

	always_comb begin
			case(cs)
				W_M0:begin
					BID_M0 = BID_BUS[3:0];
					BRESP_M0 = BRESP_BUS;
					BVALID_M0 = BVALID_BUS;
					BID_M1 = 4'd0;
					BRESP_M1 = 2'd0;
					BVALID_M1 = 1'd0;
					// BID_M2 = 4'd0;
					// BRESP_M2 = 2'd0;
					// BVALID_M2 = 1'd0;
					
					BREADY_BUS=BREADY_M0;
				end
				W_M1:begin
					BID_M0 = 4'd0;
					BRESP_M0 = 2'd0;
					BVALID_M0 = 1'd0;
					BID_M1 = BID_BUS[3:0];
					BRESP_M1 = BRESP_BUS;
					BVALID_M1 = BVALID_BUS;
					// BID_M2 = 4'd0;
					// BRESP_M2 = 2'd0;
					// BVALID_M2 = 1'd0;
					
					BREADY_BUS=BREADY_M1;
				end
				// W_M2:begin
				// 	BID_M0 = 4'd0;
				// 	BRESP_M0 = 2'd0;
				// 	BVALID_M0 = 1'd0;
				// 	BID_M1 = 4'd0;
				// 	BRESP_M1 = 2'd0;
				// 	BVALID_M1 = 1'd0;
				// 	BID_M2 = BID_BUS[3:0];
				// 	BRESP_M2 = BRESP_BUS;
				// 	BVALID_M2 = BVALID_BUS;
					
				// 	BREADY_BUS=BREADY_M2;
				// end
				W_M0_DATA:begin
					BID_M1 = 4'd0;
					BRESP_M1 = 2'd0;
					BVALID_M1 = 1'd0;
					BID_M0 = BID_BUS[3:0];
					BRESP_M0 = BRESP_BUS;
					BVALID_M0 = BVALID_BUS;
					// BID_M2 = 4'd0;
					// BRESP_M2 = 2'd0;
					// BVALID_M2 = 1'd0;

					BREADY_BUS=BREADY_M0;
				end
				W_M1_DATA:begin
					BID_M0 = 4'd0;
					BRESP_M0 = 2'd0;
					BVALID_M0 = 1'd0;
					BID_M1 = BID_BUS[3:0];
					BRESP_M1 = BRESP_BUS;
					BVALID_M1 = BVALID_BUS;
					// BID_M2 = 4'd0;
					// BRESP_M2 = 2'd0;
					// BVALID_M2 = 1'd0;

					BREADY_BUS=BREADY_M1;
				end
				// W_M2_DATA:begin
				// 	BID_M0 = 4'd0;
				// 	BRESP_M0 = 2'd0;
				// 	BVALID_M0 = 1'd0;
				// 	BID_M1 = 4'd0;
				// 	BRESP_M1 = 2'd0;
				// 	BVALID_M1 = 1'd0;
				// 	BID_M2 = BID_BUS[3:0];
				// 	BRESP_M2 = BRESP_BUS;
				// 	BVALID_M2 = BVALID_BUS;
				// 	BREADY_BUS=BREADY_M2;
				// end
				default:begin
					BID_M0 = 4'd0;
					BRESP_M0 = 2'd0;
					BVALID_M0 = 1'd0;
					BID_M1 = 4'd0;
					BRESP_M1 = 2'd0;
					BVALID_M1 = 1'd0;
					BID_M2 = 4'd0;
					BRESP_M2 = 2'd0;
					BVALID_M2 = 1'd0;
					BREADY_BUS=1'd0;
						
				end
			endcase
	end
	
	always_comb begin	
			case(slave)
				S0:begin
					BID_BUS = BID_S0;
					BRESP_BUS = BRESP_S0;
					BVALID_BUS = BVALID_S0;
					BREADY_S0 = BREADY_BUS;
					BREADY_S1 = 1'b0;
					BREADY_S2 = 1'b0;
					// BREADY_S3 = 1'b0;
					// BREADY_S4 = 1'b0;
					// BREADY_S5 = 1'b0;
				end
				S1:begin
					BID_BUS = BID_S1;
					BRESP_BUS = BRESP_S1;
					BVALID_BUS = BVALID_S1;
					BREADY_S1 = BREADY_BUS;
					BREADY_S2 = 1'b0;
					// BREADY_S3 = 1'b0;
					// BREADY_S4 = 1'b0;
					// BREADY_S5 = 1'b0;
				end
				S2:begin
					BID_BUS = BID_S2;
					BRESP_BUS = BRESP_S2;
					BVALID_BUS = BVALID_S2;
					BREADY_S1 = 1'b0;
					BREADY_S2 = BREADY_BUS;
					// BREADY_S3 = 1'b0;
					// BREADY_S4 = 1'b0;
					// BREADY_S5 = 1'b0;
				end

				// S3:begin
				// 	BID_BUS = BID_S3;
				// 	BRESP_BUS = BRESP_S3;
				// 	BVALID_BUS = BVALID_S3;
				// 	BREADY_S1 = 1'b0;
				// 	BREADY_S2 = 1'b0;
				// 	BREADY_S3 = BREADY_BUS;
				// 	BREADY_S4 = 1'b0;
				// 	BREADY_S5 = 1'b0;
				// end
				// S4:begin
				// 	BID_BUS = BID_S4;
				// 	BRESP_BUS = BRESP_S4;
				// 	BVALID_BUS = BVALID_S4;
				// 	BREADY_S1 = 1'b0;
				// 	BREADY_S2 = 1'b0;
				// 	BREADY_S3 = 1'b0;
				// 	BREADY_S4 = BREADY_BUS;
				// 	BREADY_S5 = 1'b0;
				// end
				// S5:begin
				// 	BID_BUS = BID_S5;
				// 	BRESP_BUS = BRESP_S5;
				// 	BVALID_BUS = BVALID_S5;
				// 	BREADY_S1 = 1'b0;
				// 	BREADY_S2 = 1'b0;
				// 	// BREADY_S3 = 1'b0;
				// 	// BREADY_S4 = 1'b0;
				// 	// BREADY_S5 = BREADY_BUS;
				// end

				default:begin
					BID_BUS = 8'd0;
					BRESP_BUS = 2'd0;
					BVALID_BUS = 1'd0;
					BREADY_S1 = 1'b0;
					BREADY_S2 = 1'b0;
					// BREADY_S3 = 1'b0;
					// BREADY_S4 = 1'b0;
					// BREADY_S5 = 1'b0;
				end
			endcase
	end
	
endmodule
