`include "../include/AXI_define.svh"

module B_channel(
	output logic [`AXI_ID_BITS-1:0] BID_M0,
	output logic [1:0] BRESP_M0,
	output logic BVALID_M0,
	input BREADY_M0,
	output logic [`AXI_ID_BITS-1:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1,
	input BREADY_M1,
	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output logic BREADY_S0,
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic BREADY_S1,
	output logic WRITE_DONE,
	input logic [1:0] current_Wstate,
	input [1:0] slave 
	
);

logic [`AXI_IDS_BITS-1:0] BID_BUS;
logic [1:0] BRESP_BUS;
logic BVALID_BUS;
logic BREADY_BUS;
	
assign WRITE_DONE = BVALID_BUS && BREADY_BUS;

always_comb begin
	case(current_Wstate)
		`W_M1 : begin
			BID_M0    = 4'd0;
			BRESP_M0  = 2'd0;
			BVALID_M0 = 1'd0;
			BID_M1    = BID_BUS[3:0];
			BRESP_M1  = BRESP_BUS;
			BVALID_M1 = BVALID_BUS;
			BREADY_BUS=BREADY_M1;
		end

		`M1_WDATA : begin
			BID_M0    = 4'd0;
			BRESP_M0  = 2'd0;
			BVALID_M0 = 1'd0;
			BID_M1    = BID_BUS[3:0];
			BRESP_M1  = BRESP_BUS;
			BVALID_M1 = BVALID_BUS;
			BREADY_BUS=BREADY_M1;
		end
		default : begin
			BID_M0    = 4'd0;
			BRESP_M0  = 2'd0;
			BVALID_M0 = 1'd0;
			BID_M1    = 4'd0;
			BRESP_M1  = 2'd0;
			BVALID_M1 = 1'd0;
			BREADY_BUS=1'd0;
		end
	endcase
end
	
always_comb begin	
	case(slave)
		`SLAVE0 : begin
			BID_BUS    = BID_S0;
			BRESP_BUS  = BRESP_S0;
			BVALID_BUS = BVALID_S0;
			BREADY_S0  = BREADY_BUS;
			BREADY_S1  = 1'b0;
		end
		`SLAVE1 : begin
			BID_BUS    = BID_S1;
			BRESP_BUS  = BRESP_S1;
			BVALID_BUS = BVALID_S1;
			BREADY_S0  = 1'b0;
			BREADY_S1  = BREADY_BUS;
		end
		default : begin
			BID_BUS    = 8'd0;
			BRESP_BUS  = 2'd0;
			BVALID_BUS = 1'd0;
			BREADY_S0  = 1'b0;
			BREADY_S1  = 1'b0;
		end
	endcase
end
	
endmodule
