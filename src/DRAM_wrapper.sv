`include "../include/AXI_define.svh"

/****  DRAM interface  ****/
module DRAM_wrapper (
    input clk,
    input rst,

    //READ ADDRESS
    input [`AXI_IDS_BITS-1:0] ARID,
    input [`AXI_ADDR_BITS-1:0] ARADDR,
    input [`AXI_LEN_BITS-1:0] ARLEN,
    input [`AXI_SIZE_BITS-1:0] ARSIZE,
    input [1:0] ARBURST,
    input ARVALID,
    output logic ARREADY,
    //READ DATA
    output logic [`AXI_IDS_BITS-1:0] RID,
    output logic [`AXI_DATA_BITS-1:0] RDATA,
    output logic [1:0] RRESP,
    output logic RLAST,
    output logic RVALID,
    input RREADY,
	
	//WRITE ADDRESS
    input [`AXI_IDS_BITS-1:0] AWID,
    input [`AXI_ADDR_BITS-1:0] AWADDR,
    input [`AXI_LEN_BITS-1:0] AWLEN,
    input [`AXI_SIZE_BITS-1:0] AWSIZE,
    input [1:0] AWBURST,
    input AWVALID,
    output logic AWREADY,
    //WRITE DATA
    input [`AXI_DATA_BITS-1:0] WDATA,
    input [`AXI_STRB_BITS-1:0] WSTRB,
    input WLAST,
    input WVALID,
    output logic WREADY,
    //WRITE RESPONSE
    output logic [`AXI_IDS_BITS-1:0] BID,
    output logic [1:0] BRESP,
    output logic BVALID,
    input BREADY,
	
	input logic [31:0] Q,//Q
    output logic CSn,
    output logic [3:0] WEn,
	output logic RASn,
	output logic CASn,
    output logic [10:0] A,
    output logic [31:0] D,
	input VALID
);
  
    /// VALID_reg ///
    logic VALID_reg;
    logic [31:0] DO_reg;
	always_ff@(posedge clk  )begin
		if(rst)begin
		    VALID_reg <= 1'd0;
		    DO_reg <= 32'd0;
		end
		else begin
		    VALID_reg <= VALID;
		    DO_reg <= Q;
		end
	end
	
	
	
	/// buffer ///
    logic [`AXI_IDS_BITS-1:0]  ARID_reg;
	logic [`AXI_ADDR_BITS-1:0] ARADDR_reg;
    logic [`AXI_LEN_BITS-1:0]  ARLEN_reg;
    logic [`AXI_SIZE_BITS-1:0] ARSIZE_reg;
    logic [1:0] ARBURST_reg;
	
	logic [`AXI_LEN_BITS-1:0]  ARLEN_count;
	logic [`AXI_LEN_BITS-1:0]  ARLEN_count_handshake;
	
	logic [`AXI_IDS_BITS-1:0]  AWID_reg;
	logic [`AXI_ADDR_BITS-1:0] AWADDR_reg;
    logic [`AXI_LEN_BITS-1:0]  AWLEN_reg;
    logic [`AXI_SIZE_BITS-1:0] AWSIZE_reg;
    logic [1:0] AWBURST_reg;
	
	logic [`AXI_LEN_BITS-1:0]  AWLEN_count;
	logic [2:0] ROW_count,COL_count,PRE_count;
	
	logic [`AXI_ADDR_BITS-1:0] ARADDR_post,ARADDR_post_handshake,AWADDR_post;
	logic [10:0] AR_ROW,AR_COL;
	logic [10:0] AW_ROW,AW_COL;
	logic  R_BURST_END;
	
////    state machine    ////

	parameter ACT = 4'd0, 
			  READ_ADDR = 4'd1, 
			  READ_ROW = 4'd2, 
			  READ_DATA = 4'd3, 
			  WRITE_ADDR = 4'd4, 
			  WRITE_ROW = 4'd5,
			  WRITE_DATA = 4'd6, 
			  WRITE_BACK = 4'd7, 
			  WRITE_WAIT = 4'd8, 
			  READ_PRE = 4'd9, 
			  WRITE_PRE = 4'd10;

	logic [3:0] cs,ns;


	assign	CSn = 1'd0;
	always_ff@(posedge clk)begin
		if(rst)begin
		    cs <= ACT;
		end
		else begin
		    cs <= ns;
		end
	end
	
	always_comb begin
	    case(cs)
		    ACT:begin
			    if(AWVALID)begin
				    ns = WRITE_ADDR;
				end
				else if(ARVALID)begin
				    ns = READ_ADDR;
				end
				else begin
				    ns = ACT;
				end
			end
			READ_ADDR:begin
			    if(ARVALID && ARREADY)begin
				    ns = READ_ROW;
				end
				else begin
				    ns = READ_ADDR;
				end
			end
			
			READ_ROW:begin
				if(ROW_count == 3'd4)begin // ! maybe 3
					ns = READ_DATA;
				end
				else begin
					ns = READ_ROW;
				end
			end
			READ_DATA:begin
				if(RVALID && RREADY && RLAST)begin
					ns = READ_PRE;
				end
				else if(RVALID && RREADY)begin 
					if(ARADDR_post[22:12] == ARADDR_post_handshake[22:12])begin
						ns = READ_DATA;
					end
					else begin
						ns = READ_PRE;
					end
				end
				else begin
				    ns = READ_DATA;
				end
			end
			READ_PRE:begin
				if(PRE_count == 3'd4)begin
					ns = (R_BURST_END ==1'b1)? ACT : READ_ROW;
				end
				else begin
					ns = READ_PRE;
				end
			end
		// WRITE //
			WRITE_ADDR:begin
			    if(AWVALID && AWREADY)begin
				    ns = WRITE_ROW;
				end
				else begin
				    ns = WRITE_ADDR;
				end
			end
			WRITE_ROW:begin 
			    if(ROW_count == 3'd4)begin
					ns = WRITE_DATA;
				end
				else begin
					ns = WRITE_ROW;
				end
			end
			WRITE_DATA:begin
				if(WVALID && WREADY)begin 
				    ns = WRITE_BACK;
				end
				else begin
				    ns = WRITE_DATA;
				end
			end
			WRITE_BACK:begin
			    if(BVALID && BREADY)begin 
				    ns = WRITE_PRE;
				end
				else begin
				    ns = WRITE_BACK;
				end
			end
			WRITE_PRE:begin 
			    if(PRE_count == 3'd4)begin
					ns = ACT;
				end
				else begin
					ns = WRITE_PRE;
				end
			end
			default:begin
			    ns = ACT;
			end
		endcase
	end


    // READ_ADDR //
	always_ff@(posedge clk  )begin
	    if(rst)begin
		    ARID_reg    <= `AXI_IDS_BITS'd0;
	        ARADDR_reg  <= `AXI_ADDR_BITS'd0;
            ARLEN_reg   <= `AXI_LEN_BITS'd0;
            ARSIZE_reg  <= `AXI_SIZE_BITS'd0;
            ARBURST_reg <= 2'd0;
		end
		else if(cs == READ_ADDR)begin
		    ARID_reg    <= ARID;
	        ARADDR_reg  <= ARADDR;
            ARLEN_reg   <= ARLEN;
            ARSIZE_reg  <= ARSIZE;
            ARBURST_reg <= ARBURST;
		end
		else if(cs == ACT)begin
		    ARID_reg    <= `AXI_IDS_BITS'd0;
	        ARADDR_reg  <= `AXI_ADDR_BITS'd0;
            ARLEN_reg   <= `AXI_LEN_BITS'd0;
            ARSIZE_reg  <= `AXI_SIZE_BITS'd0;
            ARBURST_reg <= 2'd0;
		end
		else begin
		    ARID_reg    <= ARID_reg;
	        ARADDR_reg  <= ARADDR_reg;
            ARLEN_reg   <= ARLEN_reg;
            ARSIZE_reg  <= ARSIZE_reg;
            ARBURST_reg <= ARBURST_reg;
		end
	end
	
    always_comb begin
	    if(cs == READ_ADDR)begin
		    ARREADY = 1'b1;
		end 
             else begin
		    ARREADY = 1'b0;
		end
	end   

	always_ff@(posedge clk )begin
		if(rst)begin
		    R_BURST_END <= 1'b0;
		end
		else if(cs == READ_DATA && RLAST && RVALID && RREADY ) begin
		     R_BURST_END <= 1'b1;
		end
		else if(cs == READ_PRE) begin
		     R_BURST_END <= R_BURST_END;
		end
		else begin
		     R_BURST_END <= 1'b0;
		end
	end
	
	// READ_DATA //
	always_comb begin
	    if(cs == READ_DATA || cs == READ_ROW)begin
			if(VALID_reg)begin
				if(ARLEN_count == ARLEN_reg)begin
					RID    = ARID_reg;
					RDATA  = DO_reg;
					RRESP  = 2'd0;
					RLAST  = 1'd1;
					RVALID = 1'd1;
				end
				else begin
					RID    = ARID_reg;
					RDATA  = DO_reg;
					RRESP  = 2'd0;
					RLAST  = 1'd0;
					RVALID = 1'd1;
				end
			end
			else begin
			    RID    = ARID_reg;
				RDATA  = DO_reg;
				RRESP  = 2'd0;
				RLAST  = 1'd0;
				RVALID = 1'd0;
			end
		end 
		else begin
		    RID    = `AXI_IDS_BITS'd0;
			RDATA  = `AXI_DATA_BITS'd0;
			RRESP  = 2'd0;
			RLAST  = 1'd0;
			RVALID = 1'd0;
		end
	end

// ARLEN_COUNT //
  
	
    assign ARLEN_count_handshake = ARLEN_count + `AXI_LEN_BITS'd1;
    always_ff@(posedge clk  )begin
	    if(rst)begin
		    ARLEN_count <= `AXI_LEN_BITS'd0;
		end
		else if(cs == READ_ROW || cs == READ_DATA || cs == READ_PRE)begin
		    if(RREADY == 1'b1 && RVALID == 1'b1 && RLAST == 1'b1)begin
			    ARLEN_count <= ARLEN_count;
			end
		    else if(RREADY == 1'b1 && RVALID == 1'b1)begin
			    ARLEN_count <= ARLEN_count + `AXI_LEN_BITS'd1;
			end
			else begin
			    ARLEN_count <= ARLEN_count;
			end
		end
		else begin
		    ARLEN_count <= `AXI_LEN_BITS'd0;
		end
	end



////    WRITE    ////

    // WRITE_ADDR //
	always_ff@(posedge clk  )begin
	    if(rst)begin
			AWID_reg    <= `AXI_IDS_BITS'd0;
	        AWADDR_reg  <= `AXI_ADDR_BITS'd0;
            AWLEN_reg   <= `AXI_LEN_BITS'd0;
            AWSIZE_reg  <= `AXI_SIZE_BITS'd0;
            AWBURST_reg <= 2'd0;
	    end
	    else if(cs == WRITE_ADDR)begin
			AWID_reg    <= AWID;
	        AWADDR_reg  <= AWADDR;
            AWLEN_reg   <= AWLEN;
            AWSIZE_reg  <= AWSIZE;
            AWBURST_reg <= AWBURST;
	    end
	    else if(cs == ACT)begin
			AWID_reg    <= `AXI_IDS_BITS'd0;
	        AWADDR_reg  <= `AXI_ADDR_BITS'd0;
            AWLEN_reg   <= `AXI_LEN_BITS'd0;
            AWSIZE_reg  <= `AXI_SIZE_BITS'd0;
            AWBURST_reg <= 2'd0;
	    end
	    else begin
			AWID_reg    <= AWID_reg;
	        AWADDR_reg  <= AWADDR_reg;
            AWLEN_reg   <= AWLEN_reg;
            AWSIZE_reg  <= AWSIZE_reg;
            AWBURST_reg <= AWBURST_reg;
	    end
	end
	
        always_comb begin
	    if(cs == WRITE_ADDR)begin
		    AWREADY = 1'b1;
		end 
            else begin
		    AWREADY = 1'b0;
		end
	end
	
	
	// WRITE_DATA //
	always_comb begin
	    if(cs == WRITE_DATA && COL_count == 3'd5)begin
		    WREADY = 1'd1;  
		end 
		else begin
		    WREADY = 1'd0;
		end
	end
	
	always_comb begin
	    if(cs == WRITE_DATA && COL_count == 3'd0)begin
		    D  = WDATA;
			WEn = WSTRB;
		end
		else if(cs == WRITE_DATA && COL_count != 3'd0)begin 
		    D  = WDATA;
			WEn = 4'b1111;
		end
		else if(cs == READ_PRE && PRE_count == 3'd0)begin
		    D  = 32'd0;
			WEn = 4'b0000;
		end 		
		else if(cs == WRITE_PRE && PRE_count == 3'd0)begin 
		    D  = 32'd0;
			WEn = 4'b0000;
		end 
		else begin
		    D  = 32'd0;
			WEn = 4'b1111;
		end
	end
	
	// WRITE_BACK //
	always_comb begin
	    if(cs == WRITE_BACK)begin
		    BVALID = 1'd1;
			BRESP  = 2'd0;
			BID    = AWID_reg;
		end 
		else begin
		    BVALID = 1'd0;
			BRESP  = 2'd0;
			BID    = `AXI_IDS_BITS'd0;
		end
	end
	
	// AWLEN_COUNT //
    always_ff@(posedge clk  )begin
	    if(rst)begin
		    AWLEN_count <= `AXI_LEN_BITS'd0;
		end
		else if(cs == WRITE_DATA)begin
		    if(WVALID == 1'b1 && WREADY == 1'b1 && WLAST == 1'b1)begin
			    AWLEN_count <= AWLEN_count;
			end
			else if(WVALID == 1'b1 && WREADY == 1'b1)begin
			    AWLEN_count <= AWLEN_count + `AXI_LEN_BITS'd1;
			end
			else begin
			    AWLEN_count <= AWLEN_count;
			end
		end
		else begin
		    AWLEN_count <= `AXI_LEN_BITS'd0;
		end
	end
	
////    ROW,COL count    ////
	
	always_ff@(posedge clk  )begin
		if(rst)begin
			PRE_count <= 3'd0;
		end
		else if(cs == READ_PRE || cs == WRITE_PRE)begin
			PRE_count <= PRE_count+3'd1;
		end
		else begin
			PRE_count <= 3'd0;
		end
	end
	
	always_ff@(posedge clk  )begin
		if(rst)begin
			ROW_count <= 3'd0;
		end
		else if(cs == READ_ROW || cs == WRITE_ROW)begin
			ROW_count <= ROW_count+3'd1;
		end
		else begin
			ROW_count <= 3'd0;
		end
	end
	
	always_ff@(posedge clk  )begin
		if(rst)begin
			COL_count <= 3'd0;
		end
		else if(cs == READ_DATA || cs == WRITE_DATA)begin
			if(COL_count == 3'd6)begin 
				COL_count <= 3'd0;
			end
			else begin
				COL_count <= COL_count + 3'd1;
			end
		end
		else begin
			COL_count <= 3'd0;
		end
	end

    
//  ADDRESS 
  
	assign ARADDR_post = ARADDR_reg + {26'd0, ARLEN_count, 2'd0};
    assign ARADDR_post_handshake = ARADDR_reg + {26'd0, ARLEN_count_handshake, 2'd0};
    assign AWADDR_post = AWADDR_reg + {26'd0, AWLEN_count, 2'd0};
	assign AR_ROW = ARADDR_post[22:12];
    assign AR_COL = {1'b0,ARADDR_post[11:2]};	
	assign AW_ROW = AWADDR_post[22:12];
    assign AW_COL = {1'b0,AWADDR_post[11:2]};	
	
    always_comb begin
	
		//----READ----//
		if(cs == READ_PRE && PRE_count == 3'd0)begin
			RASn = 1'b0;
			CASn = 1'b1;
		end
		else if(cs == READ_ROW && ROW_count == 3'd0)begin
			RASn = 1'b0;
			CASn = 1'b1;
		end
		else if(cs == READ_DATA && COL_count == 3'd0)begin
			RASn = 1'b1;
			CASn = 1'b0;
		end
						
		//----WRITE----//
		else if(cs == WRITE_PRE && PRE_count == 3'd0)begin
			RASn = 1'b0;
			CASn = 1'b1;
		end
		else if(cs == WRITE_ROW && ROW_count == 3'd0)begin
			RASn = 1'b0;
			CASn = 1'b1;
		end
		else if(cs == WRITE_DATA && COL_count == 3'd0)begin
			RASn = 1'b1;
			CASn = 1'b0;
		end
		
		else begin
			RASn = 1'b1;
			CASn = 1'b1;
		end
	end
	
	always_comb begin
	
		//----READ----//
		if(cs == READ_ADDR)begin
			A = AR_ROW;			
		end
		else if(cs == READ_PRE)begin
			A = AR_ROW;
		end
		else if(cs == READ_ROW)begin
			A = AR_ROW;
		end
		else if(cs == READ_DATA)begin
			A = AR_COL;
		end
						
		//----WRITE----//
		else if(cs == WRITE_ADDR)begin
			A = AW_ROW;			
		end
		else if(cs == WRITE_PRE)begin
			A = AW_ROW;
		end
		else if(cs == WRITE_ROW)begin
			A = AW_ROW;
		end
		else if(cs == WRITE_DATA)begin
			A = AW_COL;
		end
		
		else begin
		    A = 11'd0;
		end
	end
	 

endmodule
