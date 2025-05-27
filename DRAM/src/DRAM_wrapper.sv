`include "../include/AXI_define.svh"

module DRAM_wrapper(
	input clk,
	input rst,
	
	//WRITE ADDRESS0
	input [`AXI_IDS_BITS-1:0] AWID,
	input [`AXI_ADDR_BITS-1:0] AWADDR,
	input [`AXI_LEN_BITS-1:0] AWLEN,
	input [`AXI_SIZE_BITS-1:0] AWSIZE,
	input [1:0] AWBURST,
	input AWVALID,
	output logic AWREADY,
	
	//WRITE DATA0
	input [`AXI_DATA_BITS-1:0] WDATA,
	input [`AXI_STRB_BITS-1:0] WSTRB,
	input WLAST,
	input WVALID,
	output logic WREADY,
	
	//WRITE RESPONSE0
	output logic [`AXI_IDS_BITS-1:0] BID,
	output logic [1:0] BRESP,
	output logic BVALID,
	input BREADY,
	
	//READ ADDRESS0
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST,
	input ARVALID,
	output logic ARREADY,
	
	//READ DATA0
	output logic [`AXI_IDS_BITS-1:0] RID,
	output logic [`AXI_DATA_BITS-1:0] RDATA,
	output logic [1:0] RRESP,
	output logic RLAST,
	output logic RVALID,
	input RREADY,
	
	//off chip DRAM
	input [31:0]DRAM_Q,
	input DRAM_valid,
	output logic DRAM_CSn,
	output logic [3:0]DRAM_WEn,
	output logic DRAM_RASn,
	output logic DRAM_CASn,
	output logic [10:0]DRAM_A,
	output logic [31:0]DRAM_D
);
// logic [3:0]FSM;

logic [`AXI_ADDR_BITS-1:0]ADDR_reg;
logic [`AXI_IDS_BITS-1:0] ID_reg;
logic [4:0] LEN_reg;
logic [`AXI_SIZE_BITS-1:0] SIZE_reg;
logic [1:0] BURST_reg;

//DRAM control
logic [11:0]ACTIVATE_ROW_ADDR;
logic [2:0]DRAM_cnt;
//DRAM signal
assign DRAM_CSn = 1'b0;


//numric state
typedef enum logic [3:0] {
	DRAM_IDLE,    // 空閒狀態
	DRAM_W_ACT,   // 開始狀態
	DRAM_W_PRECHRGE, // 處理狀態
	DRAM_W_DIN, // 輸入狀態
	DRAM_W_DBUF, // 緩衝狀態
	// DRAM_W_RESP, // 回應狀態
	DRAM_R_ACT,   // 開始狀態
	DRAM_R_PRECHRGE, // 處理狀態
	R_WAIT, // wait DRAM valid 
	R_DOUT // output DRAM data
} state_t;

state_t DRAM_cs, DRAM_ns;



//DRAM_FSM
always_ff@(posedge clk) begin
	if(rst)
		DRAM_cs <= DRAM_IDLE;
	else
		DRAM_cs <= DRAM_ns;
end

always_comb begin
	case(DRAM_cs)
			DRAM_IDLE  : begin
				if(ARVALID) begin
					if(ACTIVATE_ROW_ADDR == {3'b0, ARADDR[20:12]})
						DRAM_ns = R_WAIT;
					else
						DRAM_ns = DRAM_R_PRECHRGE;
				end
				else if(AWVALID) begin
					if(ACTIVATE_ROW_ADDR == {3'b0, AWADDR[20:12]})
						DRAM_ns = DRAM_W_DIN;
					else
						DRAM_ns = DRAM_W_PRECHRGE;	
				end
				else
					DRAM_ns = DRAM_IDLE;
			end
			DRAM_W_PRECHRGE: begin
				if(DRAM_cnt == 3'b0)
					DRAM_ns = DRAM_W_ACT;
				else
					DRAM_ns = DRAM_W_PRECHRGE;
			end
			DRAM_W_ACT: begin
				if(DRAM_cnt == 3'b0)
					DRAM_ns = DRAM_W_DIN;
				else 
					DRAM_ns = DRAM_W_ACT;
			end
			DRAM_W_DIN: begin
				if(WREADY && WVALID)
					DRAM_ns = DRAM_W_DBUF;
				else
					DRAM_ns = DRAM_W_DIN;
			end
			DRAM_W_DBUF: begin
				if(DRAM_cnt == 3'b0) begin
					if(LEN_reg == 5'b11111) 
						DRAM_ns = DRAM_IDLE; //WHEN WRITE THE LAST, BVALID=1 STATE=>IDLE
					else 
						DRAM_ns = DRAM_W_DIN;
				end
				else 
					DRAM_ns = DRAM_W_DBUF;
			end
			// DRAM_W_RESP: begin
			// 	if(BREADY && BVALID)
			// 		DRAM_ns = DRAM_IDLE;
			// 	else
			// 		DRAM_ns = DRAM_W_RESP;
			// end
			// DRAM_W_RESP: begin
			// 	DRAM_ns = DRAM_IDLE;
			// end
			DRAM_R_PRECHRGE: begin
				if(DRAM_cnt == 3'b0)
					DRAM_ns = DRAM_R_ACT;
				else 
					DRAM_ns = DRAM_R_PRECHRGE;
			end
			DRAM_R_ACT: begin
				if(DRAM_cnt == 3'b0)
					DRAM_ns = R_WAIT;
				else
					DRAM_ns = DRAM_R_ACT;
			end
			R_WAIT: begin
				if(DRAM_valid)
					DRAM_ns = R_DOUT;
				else
					DRAM_ns = R_WAIT;
			end
			R_DOUT: begin
				if(RVALID && RREADY) begin
					if(LEN_reg == 5'b0)
						DRAM_ns = DRAM_IDLE;
					else
						DRAM_ns = R_WAIT;
				end
				else
					DRAM_ns = R_DOUT;
			end
			default: begin
				DRAM_ns = DRAM_IDLE;
			end
		endcase
	
end

//*================================================
wire row_hit_r = ACTIVATE_ROW_ADDR == {3'b0, ARADDR[20:12]};
wire row_hit_w = ACTIVATE_ROW_ADDR == {3'b0, AWADDR[20:12]};
always@(posedge clk) begin
	if(rst)
		DRAM_cnt	  <= 3'b0;
	else begin
		case(DRAM_cs)
			DRAM_IDLE  : begin
				if(ARVALID && row_hit_r || AWVALID && row_hit_w) 
					DRAM_cnt <= 3'd0;	//A* handshake + R/W handshake must over 5 cycles
				else if(ARVALID || AWVALID) 
					DRAM_cnt <= 3'd4;    //Precharge -> Row Activate
			end
			DRAM_W_PRECHRGE: begin
				if(DRAM_cnt == 3'b0) 
					DRAM_cnt <= 3'd2;
				else
					DRAM_cnt <= DRAM_cnt - 3'd1;
			end
			DRAM_W_ACT: begin
				DRAM_cnt <= DRAM_cnt - 3'd1;
			end
			DRAM_W_DIN: begin//FIXME:
				if(WREADY && WVALID)
					DRAM_cnt <= 3'd0;
				else
					DRAM_cnt <= DRAM_cnt;
			end
			DRAM_W_DBUF: begin
				if(DRAM_cnt == 3'b0)
					DRAM_cnt <= DRAM_cnt;
				else
					DRAM_cnt <= DRAM_cnt - 3'b01;
			end
			//-------------READ----------------
			DRAM_R_PRECHRGE: begin
				if(DRAM_cnt == 3'b0) 
					DRAM_cnt <= 3'd4;
				else 
					DRAM_cnt <= DRAM_cnt - 3'd1;	
			end
			DRAM_R_ACT: begin
				if(DRAM_cnt == 3'b0)
					DRAM_cnt <= 3'b11;
				else
					DRAM_cnt <= DRAM_cnt - 3'b01;
			end
			default: begin
				DRAM_cnt <= DRAM_cnt;
			end
		endcase
	end
end


//DRAM WEn
always_ff@(posedge clk)begin
	if(rst)
		DRAM_WEn <= 4'h0;
	else if((DRAM_cs == DRAM_W_PRECHRGE||DRAM_cs == DRAM_R_PRECHRGE) && DRAM_cnt == 3'b0)
		DRAM_WEn <= 4'h0;
	else if(WREADY && WVALID)
		DRAM_WEn <= WSTRB;
	else
		DRAM_WEn <= 4'hf;
end
/*============================================*/

always_ff@(posedge clk)begin
	if(rst) begin
		DRAM_RASn <= 1'b1;
		DRAM_CASn <= 1'b1;
	end
	else begin
		case(DRAM_cs)
			DRAM_IDLE  : begin
				if(ARVALID) begin
					if(ACTIVATE_ROW_ADDR == {3'b0, ARADDR[20:12]})begin//row hit
						DRAM_RASn <= 1'b1;
						DRAM_CASn <= 1'b0;
					end
					else begin
						DRAM_RASn <= 1'b0;
						DRAM_CASn <= 1'b1;
					end
				end
				else if(AWVALID) begin
					if(ACTIVATE_ROW_ADDR == {3'b0, AWADDR[20:12]})begin//row hit
						DRAM_RASn <= 1'b1;
						DRAM_CASn <= 1'b1;
					end
					else begin
						DRAM_RASn <= 1'b0;
						DRAM_CASn <= 1'b1;
					end
				end
				else begin
					DRAM_RASn <= 1'b1;
					DRAM_CASn <= 1'b1;
				end
			end
			DRAM_W_PRECHRGE: begin
				if(DRAM_cnt == 3'b0) begin
					DRAM_RASn <= 1'b0;
					DRAM_CASn <= 1'b1;
				end
				else begin
					DRAM_RASn <= 1'b1;
					DRAM_CASn <= 1'b1;
				end
			end
			DRAM_W_DIN: begin
				if(WREADY && WVALID) begin
					DRAM_RASn <= 1'b1;
					DRAM_CASn <= 1'b0;
				end
			end
			DRAM_R_PRECHRGE: begin
				if(DRAM_cnt == 3'b0) begin
					DRAM_RASn <= 1'b0;
					DRAM_CASn <= 1'b1;
				end
				else begin
					DRAM_RASn <= 1'b1;
					DRAM_CASn <= 1'b1;
				end
			end
			DRAM_R_ACT: begin
				if(DRAM_cnt == 3'b0) begin
					DRAM_RASn <= 1'b1;
					DRAM_CASn <= 1'b0;
				end
				else begin
					DRAM_RASn <= 1'b1;
					DRAM_CASn <= 1'b1;
				end
				
			end
			R_DOUT: begin
				if(RVALID && RREADY) begin
					if(LEN_reg == 5'b0) begin
					end
					else begin
						DRAM_CASn <= 1'b0;
					end
				end
			end
			default: begin
				DRAM_RASn <= 1'b1;
				DRAM_CASn <= 1'b1;
			end
		endcase
	end
end
/*============================================*/

always@(posedge clk) begin
	if(rst) begin
		DRAM_A <= 11'b0;
		DRAM_D <= 32'b0;
	end
	else begin
		case(DRAM_cs)
			DRAM_IDLE  : begin
				if(ARVALID) begin
					if(ACTIVATE_ROW_ADDR == {3'b0, ARADDR[20:12]})	begin//row hit
						DRAM_A	  <= {1'b0,ARADDR[11:2]};//column address
						DRAM_D	  <= 32'b0;
					end
					else begin
						DRAM_A	  <= {2'b0,ARADDR[20:12]};//row address
						DRAM_D	  <= 32'b0;
					end
				end
				else if(AWVALID) begin
					if(ACTIVATE_ROW_ADDR == {3'b0, AWADDR[20:12]})	begin//row hit
						DRAM_A	  <= {1'b0,AWADDR[11:2]};
						DRAM_D	  <= DRAM_D;
					end
					else begin
						DRAM_A	  <= {2'b0,AWADDR[20:12]};
						DRAM_D	  <= 32'b0;
					end
				end
			end
			DRAM_W_PRECHRGE: begin
				DRAM_A	  <= {2'b0,ADDR_reg[20:12]};
				DRAM_D	  <= 32'b0;
			end
			DRAM_W_ACT: begin
				DRAM_A	  <= {2'b0,ADDR_reg[20:12]};
				DRAM_D	  <= 32'b0;
			end
			DRAM_W_DIN: begin
				if(WREADY && WVALID) begin
					DRAM_A	  <= {1'b0,ADDR_reg[11:2]};
					DRAM_D	  <= WDATA;
				end
			end
			DRAM_W_DBUF: begin
				DRAM_A	  <= {1'b0,ADDR_reg[11:2]};
				DRAM_D	  <= DRAM_D;
			end
			DRAM_R_PRECHRGE: begin
				DRAM_A	  <= {2'b0,ADDR_reg[20:12]};
				DRAM_D	  <= 32'b0;
			end
			DRAM_R_ACT: begin
				if(DRAM_cnt == 3'b0) begin
					DRAM_A	  <= {1'b0,ADDR_reg[11:2]};
					DRAM_D	  <= 32'b0;
				end
				else begin
					DRAM_A	  <= {2'b0,ADDR_reg[20:12]};
					DRAM_D	  <= 32'b0;
				end
				
			end
			R_WAIT: begin
				DRAM_A	  <= {1'b0,ADDR_reg[11:2]};
				DRAM_D	  <= 32'b0;
			end
			R_DOUT: begin
				DRAM_A	  <= {1'b0,ADDR_reg[11:2]};
				DRAM_D	  <= 32'b0;
			end
			default : begin
				DRAM_A	  <= DRAM_A;
				DRAM_D	  <= DRAM_D;
			end
		endcase
	end
end
//*================================================*/
/*=================================================*/
always@(posedge clk) begin
	if(rst) begin
		ADDR_reg <= 32'b0;
		ID_reg <= 8'b0;
		LEN_reg <= 5'b0;
		SIZE_reg <= 3'b0;
		BURST_reg <= 2'b0;
	end
	else begin
		case(DRAM_cs)
			DRAM_IDLE  : begin
				if(ARVALID) begin
					ID_reg <= ARID;
					ADDR_reg <= ARADDR;
					LEN_reg <= {1'b0,ARLEN};
					SIZE_reg <= ARSIZE;
					BURST_reg <= ARBURST;
				end
				else if(AWVALID) begin
					ID_reg <= AWID;
					ADDR_reg <= AWADDR;
					LEN_reg <= {1'b0,AWLEN};
					SIZE_reg <= AWSIZE;
					BURST_reg <= AWBURST;
				end
			end
			DRAM_W_DIN: begin
				if(WREADY && WVALID) begin
					LEN_reg <= LEN_reg - 5'b1;
					ADDR_reg <= (BURST_reg == `AXI_BURST_INC)? (ADDR_reg + 32'd4): ADDR_reg;
				end
			end
			R_WAIT: begin
				if(DRAM_valid)
					ADDR_reg <= ADDR_reg + 32'd4;
			end
			R_DOUT: begin
				if(RVALID && RREADY) begin
					if(LEN_reg != 5'b0) begin
						LEN_reg <= LEN_reg - 5'b1;
					end
				end
			end
			default: begin
			end
		endcase
	end
end
/*=================================================*/
always_comb begin
	if(((DRAM_cs == DRAM_W_DBUF) && ((DRAM_cnt == 3'b0) && (LEN_reg == 5'b11111)))/* ||  (DRAM_cs == DRAM_W_RESP)*/) begin
		BID = ID_reg;
		BRESP = `AXI_RESP_OKAY;
		BVALID = 1'b1;
	end
	else begin
		BID = 8'b0;
		BRESP = 2'b0;
		BVALID = 1'b0;
	end
end

always@(posedge clk) begin
	if(rst) begin
		//input & output signal
		AWREADY <= 1'b0;
		WREADY <= 1'b0;
		// BID <= 8'b0;
		// BRESP <= 2'b0;
		// BVALID <= 1'b0;
		ARREADY <= 1'b0;
		RID <= 8'b0;
		RDATA  <= 32'b0;
		RRESP <= 2'b0;
		RLAST <= 1'b0;
		RVALID <= 1'b0;
		ACTIVATE_ROW_ADDR <= 12'b1000_0000_0000;
	end
	else begin
		case(DRAM_cs)
			DRAM_IDLE  : begin
				if(ARVALID)
					ARREADY <= 1'b1;
				else if(AWVALID)
					AWREADY <= 1'b1;
			end
			DRAM_W_PRECHRGE: begin
				AWREADY <= 1'b0;
				ACTIVATE_ROW_ADDR <= {3'b0,ADDR_reg[20:12]};
			end
			DRAM_W_DIN: begin
				AWREADY <= 1'b0;
				if(WREADY && WVALID) begin
					WREADY <= 1'b0;
				
				end
				else if(!WREADY) 
					WREADY <= 1'b1;
			end
			// DRAM_W_DBUF: begin
			// 	if((DRAM_cnt == 3'b0) && (LEN_reg == 5'b11111)) begin
			// 		BID <= ID_reg;
			// 		BRESP <= `AXI_RESP_OKAY;
			// 		BVALID <= 1'b1;
			// 	end
			// end
			// DRAM_W_RESP: begin
			// 	if(BREADY && BVALID) begin
			// 		BID <= 8'b0;
			// 		BRESP <= 2'b0;
			// 		BVALID <= 1'b0;
			// 	end
			// end
			DRAM_R_PRECHRGE: begin
				ARREADY <= 1'b0;
				ACTIVATE_ROW_ADDR <= {3'b0,ADDR_reg[20:12]};
			end
			R_WAIT: begin
				if(DRAM_valid) begin
					RID <= ID_reg;
					RDATA <= DRAM_Q;
					RLAST <= (LEN_reg == 5'b0);
					RVALID <= 1'b1;
				end
				ARREADY <= 1'b0;
			end
			R_DOUT: begin
				if(RVALID && RREADY) begin
					RID <= 8'b0;
					RDATA <= 32'b0;
					RLAST <= 1'b0;
					RVALID <= 1'b0;
				end
			end
			default: begin

			end
		endcase
	end
end
endmodule
