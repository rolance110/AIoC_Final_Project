`include "../include/AXI_define.svh"

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
	
	output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output logic WLAST_S0,
	output logic WVALID_S0,
	input WREADY_S0,

	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	input WREADY_S1,
	
	input logic [1:0] current_Wstate, 
	input [1:0] slave
	
);

logic [`AXI_DATA_BITS-1:0] WDATA;
logic [`AXI_STRB_BITS-1:0] WSTRB;
logic WLAST;
logic WVALID;
logic WREADY_BUS;
	
always_comb begin
	case(current_Wstate)
		`W_M1 : begin
			WDATA     = WDATA_M1;
			WSTRB     = WSTRB_M1;
			WLAST     = WLAST_M1;
			WVALID    = WVALID_M1;
			WREADY_M0 = 1'b0;
			//WREADY_M1 = (ADDR[31:16]==16'd0) ? WREADY_S0 : WREADY_S1 ;
			WREADY_M1 = WREADY_BUS ;
		end
		`M1_WDATA : begin
			WDATA     = WDATA_M1;
			WSTRB     = WSTRB_M1;
			WLAST     = WLAST_M1;
			WVALID    = WVALID_M1;
			WREADY_M0 = 1'b0;
			//WREADY_M1 = (ADDR[31:16]==16'd0) ? WREADY_S0 : WREADY_S1 ;
			WREADY_M1 = WREADY_BUS ;
		end
		default:begin
			WDATA     = 32'd0;
			WSTRB     = 4'd0;
			WLAST     = 1'd0;
			WVALID    = 1'd0;
			WREADY_M0 = 1'b0;
			WREADY_M1 = 1'b0;
		end
	endcase
end
	
always_comb begin	
	case(slave)
		`SLAVE0:begin
			WDATA_S0   = WDATA;
			WSTRB_S0   = WSTRB;
			WLAST_S0   = WLAST;
			WVALID_S0  = WVALID;
			WDATA_S1   = 32'd0;
			WSTRB_S1   = 4'd0;
			WLAST_S1   = 1'd0;
			WVALID_S1  = 1'd0;
			WREADY_BUS = WREADY_S0;
		end
		`SLAVE1:begin
			WDATA_S0   = 32'd0;
			WSTRB_S0   = 4'd0;
			WLAST_S0   = 1'd0;
			WVALID_S0  = 1'd0;
			WDATA_S1   = WDATA;
			WSTRB_S1   = WSTRB;
			WLAST_S1   = WLAST;
			WVALID_S1  = WVALID;
			WREADY_BUS = WREADY_S1;
		end
		default:begin
			WDATA_S0   = 32'd0;
			WSTRB_S0   = 4'd0;
			WLAST_S0   = 1'd0;
			WVALID_S0  = 1'd0;
			WDATA_S1   = 32'd0;
			WSTRB_S1   = 4'd0;
			WLAST_S1   = 1'd0;
			WVALID_S1  = 1'd0;
			WREADY_BUS = 1'd0;
		end
	endcase
end	

endmodule
