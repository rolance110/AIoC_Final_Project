
module W_channel(
	input clk,
	input rst_n,
	
	input [`AXI_DATA_BITS-1:0] WDATA_M0,
	input [`AXI_STRB_BITS-1:0] WSTRB_M0,
	input WLAST_M0,
	input WVALID_M0,
	output logic WREADY_M0,
	
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output logic WREADY_M1,

	// input [`AXI_DATA_BITS-1:0] WDATA_M2,
	// input [`AXI_STRB_BITS-1:0] WSTRB_M2,
	// input WLAST_M2,
	// input WVALID_M2,
	// output logic WREADY_M2,
	
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	input WREADY_S1,

	output logic [`AXI_DATA_BITS-1:0] WDATA_S2,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S2,
	output logic WLAST_S2,
	output logic WVALID_S2,
	input WREADY_S2,

	output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output logic WLAST_S0,
	output logic WVALID_S0,
	input WREADY_S0,

	// output logic [`AXI_DATA_BITS-1:0] WDATA_S4,
	// output logic [`AXI_STRB_BITS-1:0] WSTRB_S4,
	// output logic WLAST_S4,
	// output logic WVALID_S4,
	// input WREADY_S4,

	// output logic [`AXI_DATA_BITS-1:0] WDATA_S5,
	// output logic [`AXI_STRB_BITS-1:0] WSTRB_S5,
	// output logic WLAST_S5,
	// output logic WVALID_S5,
	// input WREADY_S5,
	
	input logic [3:0] cs, 
	input [2:0] slave
	
);

	logic [`AXI_DATA_BITS-1:0] WDATA;
	logic [`AXI_STRB_BITS-1:0] WSTRB;
	logic WLAST;
	logic WVALID;
	logic WREADY_BUS;
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
	parameter S0=3'd0, S1=3'd1, S2=3'd2, S3=3'd3, S4=3'd4, S5=3'd5, DEF=3'd6;
	always_comb begin
			case(cs)
				W_M0:begin
					WDATA = WDATA_M0;
					WSTRB = WSTRB_M0;
					WLAST = WLAST_M0;
					WVALID = WVALID_M0;
					WREADY_M0 = WREADY_BUS ;
					WREADY_M1 = 1'b0;
					// WREADY_M2 = 1'b0;
				end
				W_M1:begin
					WDATA = WDATA_M1;
					WSTRB = WSTRB_M1;
					WLAST = WLAST_M1;
					WVALID = WVALID_M1;
					WREADY_M0 = 1'b0;
					WREADY_M1 = WREADY_BUS ;
					// WREADY_M2 = 1'b0;
				end
				W_M2:begin
					// WDATA = WDATA_M2;
					// WSTRB = WSTRB_M2;
					// WLAST = WLAST_M2;
					// WVALID = WVALID_M2;
					// WREADY_M0 = 1'b0;
					// WREADY_M1 = 1'b0;
					// WREADY_M2 = WREADY_BUS ;
					
				end
				W_M0_DATA:begin
					WDATA = WDATA_M0;
					WSTRB = WSTRB_M0;
					WLAST = WLAST_M0;
					WVALID = WVALID_M0;
					WREADY_M1 = 1'b0;
					WREADY_M0 = WREADY_BUS ;
					// WREADY_M2 = 1'b0;
				end
				W_M1_DATA:begin
					WDATA = WDATA_M1;
					WSTRB = WSTRB_M1;
					WLAST = WLAST_M1;
					WVALID = WVALID_M1;
					WREADY_M0 = 1'b0;
					WREADY_M1 = WREADY_BUS ;
					// WREADY_M2 = 1'b0;
				end
				// W_M2_DATA:begin
				// 	// WDATA = WDATA_M2;
				// 	// WSTRB = WSTRB_M2;
				// 	// WLAST = WLAST_M2;
				// 	// WVALID = WVALID_M2;
				// 	// WREADY_M0 = 1'b0;
				// 	// WREADY_M1 = 1'b1;
				// 	// WREADY_M2 = WREADY_BUS ;
				// end
				default:begin
					WDATA = 32'd0;
					WSTRB = 4'd0;
					WLAST = 1'd0;
					WVALID = 1'd0;
					WREADY_M0 = 1'b0;
					WREADY_M1 = 1'b0;
					// WREADY_M2 = 1'b0;
				end
			endcase
	end
	
	always_comb begin	
			case(slave)
			S0:begin
					WDATA_S1 = 32'd0;
					WSTRB_S1 = 4'd0;
					WLAST_S1 = 1'd0;
					WVALID_S1= 1'd0;
					WDATA_S2 = 32'd0;
					WSTRB_S2 = 4'd0;
					WLAST_S2 = 1'd0;
					WVALID_S2= 1'd0;
					// WDATA_S3 = 32'd0;
					// WSTRB_S3 = 4'd0;
					// WLAST_S3 = 1'd0;
					// WVALID_S3 = 1'd0;
					WDATA_S0 = WDATA;
					WSTRB_S0 = WSTRB;
					WLAST_S0 = WLAST;
					WVALID_S0= WVALID;
					// WDATA_S5 = 32'd0;
					// WSTRB_S5 = 4'd0;
					// WLAST_S5 = 1'd0;
					// WVALID_S5 = 1'd0;
					WREADY_BUS = WREADY_S0;
				end
				S1:begin
					WDATA_S1 = WDATA;
					WSTRB_S1 = WSTRB;
					WLAST_S1 = WLAST;
					WVALID_S1 = WVALID;
					WDATA_S2 = 32'd0;
					WSTRB_S2 = 4'd0;
					WLAST_S2 = 1'd0;
					// WVALID_S2 = 1'd0;
					// WDATA_S3 = 32'd0;
					// WSTRB_S3 = 4'd0;
					// WLAST_S3 = 1'd0;
					// WVALID_S3 = 1'd0;
					WDATA_S0 = 32'd0;
					WSTRB_S0 = 4'd0;
					WLAST_S0 = 1'd0;
					WVALID_S0 = 1'd0;
					// WDATA_S5 = 32'd0;
					// WSTRB_S5 = 4'd0;
					// WLAST_S5 = 1'd0;
					// WVALID_S5 = 1'd0;
					WREADY_BUS = WREADY_S1;
				end
				S2:begin
					WDATA_S1 = 32'd0;
					WSTRB_S1 = 4'd0;
					WLAST_S1 = 1'd0;
					WVALID_S1 = 1'd0;
					WDATA_S2 = WDATA;
					WSTRB_S2 = WSTRB;
					WLAST_S2 = WLAST;
					WVALID_S2 = WVALID;
					// WDATA_S3 = 32'd0;
					// WSTRB_S3 = 4'd0;
					// WLAST_S3 = 1'd0;
					// WVALID_S3 = 1'd0;
					// WDATA_S4 = 32'd0;
					// WSTRB_S4 = 4'd0;
					// WLAST_S4 = 1'd0;
					// WVALID_S4 = 1'd0;
					// WDATA_S5 = 32'd0;
					// WSTRB_S5 = 4'd0;
					// WLAST_S5 = 1'd0;
					// WVALID_S5 = 1'd0;
					WREADY_BUS = WREADY_S2;
				end
				// S3:begin
				// 	WDATA_S1 = 32'd0;
				// 	WSTRB_S1 = 4'd0;
				// 	WLAST_S1 = 1'd0;
				// 	WVALID_S1 = 1'd0;
				// 	WDATA_S2 = 32'd0;
				// 	WSTRB_S2 = 4'd0;
				// 	WLAST_S2 = 1'd0;
				// 	WVALID_S2 = 1'd0;
				// 	WDATA_S3 = WDATA;
				// 	WSTRB_S3 = WSTRB;
				// 	WLAST_S3 = WLAST;
				// 	WVALID_S3 = WVALID;
				// 	WDATA_S4 = 32'd0;
				// 	WSTRB_S4 = 4'd0;
				// 	WLAST_S4 = 1'd0;
				// 	WVALID_S4 = 1'd0;
				// 	WDATA_S5 = 32'd0;
				// 	WSTRB_S5 = 4'd0;
				// 	WLAST_S5 = 1'd0;
				// 	WVALID_S5 = 1'd0;
				// 	WREADY_BUS = WREADY_S3;
				// end
				// S4:begin
				// 	WDATA_S1 = 32'd0;
				// 	WSTRB_S1 = 4'd0;
				// 	WLAST_S1 = 1'd0;
				// 	WVALID_S1 = 1'd0;
				// 	WDATA_S2 = 32'd0;
				// 	WSTRB_S2 = 4'd0;
				// 	WLAST_S2 = 1'd0;
				// 	WVALID_S2 = 1'd0;
				// 	WDATA_S3 = 32'd0;
				// 	WSTRB_S3 = 4'd0;
				// 	WLAST_S3 = 1'd0;
				// 	WVALID_S3 = 1'd0;
				// 	WDATA_S4 = WDATA;
				// 	WSTRB_S4 = WSTRB;
				// 	WLAST_S4 = WLAST;
				// 	WVALID_S4 = WVALID;
				// 	WDATA_S5 = 32'd0;
				// 	WSTRB_S5 = 4'd0;
				// 	WLAST_S5 = 1'd0;
				// 	WVALID_S5 = 1'd0;
				// 	WREADY_BUS = WREADY_S4;
				// end
				// S5:begin
				// 	WDATA_S1 = 32'd0;
				// 	WSTRB_S1 = 4'd0;
				// 	WLAST_S1 = 1'd0;
				// 	WVALID_S1 = 1'd0;
				// 	WDATA_S2 = 32'd0;
				// 	WSTRB_S2 = 4'd0;
				// 	WLAST_S2 = 1'd0;
				// 	WVALID_S2 = 1'd0;
				// 	WDATA_S3 = 32'd0;
				// 	WSTRB_S3 = 4'd0;
				// 	WLAST_S3 = 1'd0;
				// 	WVALID_S3 = 1'd0;
				// 	WDATA_S4 = 32'd0;
				// 	WSTRB_S4 = 4'd0;
				// 	WLAST_S4 = 1'd0;
				// 	WVALID_S4 = 1'd0;
				// 	WDATA_S5 = WDATA;
				// 	WSTRB_S5 = WSTRB;
				// 	WLAST_S5 = WLAST;
				// 	WVALID_S5 = WVALID;
				// 	WREADY_BUS = WREADY_S5;
				// end
				default:begin
					WDATA_S0 = 32'd0;
					WSTRB_S0 = 4'd0;
					WLAST_S0 = 1'd0;
					WVALID_S0 = 1'd0;
					WDATA_S1 = 32'd0;
					WSTRB_S1 = 4'd0;
					WLAST_S1 = 1'd0;
					WVALID_S1 = 1'd0;
					WDATA_S2 = 32'd0;
					WSTRB_S2 = 4'd0;
					WLAST_S2 = 1'd0;
					WVALID_S2 = 1'd0;
					// WDATA_S3 = 32'd0;
					// WSTRB_S3 = 4'd0;
					// WLAST_S3 = 1'd0;
					// WVALID_S3 = 1'd0;
					// WDATA_S4 = 32'd0;
					// WSTRB_S4 = 4'd0;
					// WLAST_S4 = 1'd0;
					// WVALID_S4 = 1'd0;
					// WDATA_S5 = 32'd0;
					// WSTRB_S5 = 4'd0;
					// WLAST_S5 = 1'd0;
					// WVALID_S5 = 1'd0;
					WREADY_BUS = 1'd0;
				end
			endcase
	end
	
	
endmodule
