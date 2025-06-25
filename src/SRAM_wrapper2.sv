// `include "../include/AXI_define.svh"
//`include "../src/SRAM/TS1N16ADFPCLLLVTA512X45M4SWSHOD.sv"
/****  slave interface  ****/
module SRAM_wrapper2 (
    input ACLK,
    input ARESETn,
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
    input BREADY

    // //0625
    // input pass_done_o,
    // input PASS_START,
    // output logic [31:0] dsc_read_data,
    // input [31:0] dsc_write_data,
    // input [31:0] dsc_glb_addr,
    // input [3:0] dsc_glb_web
 
    
);
    /// SRAM pin ///
    logic OE,CS_;
    logic WEB;
    logic [13:0] A;
    logic [31:0] DI;
    logic [31:0] DO;
	
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
	logic [31:0]WSTRB_32bit;
	logic [3:0] WSTRB_temp;
	
//state machine

	parameter IDEAL = 3'd0, 
			  READ_ADDR = 3'd1, 
			  READ_DATA = 3'd2, 
			  WRITE_ADDR = 3'd3, 
			  WRITE_DATA = 3'd4, 
			  WRITE_BACK = 3'd5, 
			  READ_WAIT = 3'd6;
	logic [2:0] cs,ns;
	
	always_ff@(posedge ACLK )begin
		if(!ARESETn)begin
		    cs <= IDEAL;
		end
		else begin
		    cs <= ns;
		end
	end
	
	always_comb begin
    case(cs)
        IDEAL: begin
            ns = (ARVALID) ? READ_ADDR : 
                 (AWVALID) ? WRITE_ADDR : 
                             IDEAL;
        end
        READ_ADDR: begin
            ns = (ARVALID && ARREADY) ? READ_DATA : READ_ADDR;
        end
        READ_DATA: begin
            ns = (RLAST && RVALID && RREADY) ? IDEAL : READ_DATA;
        end
        WRITE_ADDR: begin
            ns = (AWVALID && AWREADY) ? WRITE_DATA : WRITE_ADDR;
        end
        WRITE_DATA: begin
            ns = (WLAST && WVALID && WREADY) ? WRITE_BACK : WRITE_DATA;
        end
        WRITE_BACK: begin
            ns = (BVALID && BREADY) ? IDEAL : WRITE_BACK;
        end
        default: begin
            ns = IDEAL;
        end
    endcase
end

  
  
  
//READ ADDR
    always_comb begin
		if(cs == READ_ADDR)
		 ARADDR_reg  = ARADDR;
		 else if(cs == IDEAL)
		 ARADDR_reg  = `AXI_ADDR_BITS'd0;
		 else 
		 ARADDR_reg  = ARADDR_reg;
	end
   
	always_ff@(posedge ACLK)begin
	    if(!ARESETn)begin
		    ARID_reg    <= `AXI_IDS_BITS'd0;
            ARLEN_reg   <= `AXI_LEN_BITS'd0;
            ARSIZE_reg  <= `AXI_SIZE_BITS'd0;
            ARBURST_reg <= 2'd0;
		end
		else if(cs == READ_ADDR)begin
		    ARID_reg    <= ARID;
            ARLEN_reg   <= ARLEN;
            ARSIZE_reg  <= ARSIZE;
            ARBURST_reg <= ARBURST;
		end
		else if(cs == IDEAL)begin
		    ARID_reg    <= `AXI_IDS_BITS'd0;
            ARLEN_reg   <= `AXI_LEN_BITS'd0;
            ARSIZE_reg  <= `AXI_SIZE_BITS'd0;
            ARBURST_reg <= 2'd0;
		end
		else begin
		    ARID_reg    <= ARID_reg;
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

	// READ_DATA //
	
	always_comb begin
	    if(cs == READ_DATA)begin
     		if(ARLEN_count == ARLEN_reg)begin
				RID    = ARID_reg;	
				RDATA  = DO; 
				RRESP  = 2'd0;
				RLAST  = 1'd1; //when count to Burst length RLAST = 1
				RVALID = 1'd1;
			end
			else begin
			    RID    = ARID_reg;						
				RDATA  = DO;
				RRESP  = 2'd0;
				RLAST  = 1'd0;
				RVALID = 1'd1;
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
   
	// ARLEN for burst
    assign ARLEN_count_handshake = ARLEN_count + `AXI_LEN_BITS'd1;

    always_ff@(posedge ACLK )begin
	    if(!ARESETn)begin
		    ARLEN_count <= `AXI_LEN_BITS'd0;
		end
		else if(cs == READ_DATA)begin
		    if(RREADY == 1'b1 && RVALID == 1'b1)begin
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



// ! WRITE 

    // WRITE_ADDR //
	always_ff@(posedge ACLK )begin
	    if(!ARESETn)begin
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
	    else if(cs == IDEAL)begin
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
	    if(cs == WRITE_DATA)begin
		    WREADY = 1'd1;
		end 
		else begin
		    WREADY = 1'd0;
		end
	end
	
	always_comb begin
	    if(cs == WRITE_DATA && WVALID == 1'b1)begin
		    DI  = WDATA;
			WSTRB_temp = WSTRB;
		end 
		else begin
		    DI  = 32'd0;
			WSTRB_temp = 4'b1111;
		end
	end
	
	// WRITE_RESPONSE //
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
    always_ff@(posedge ACLK)begin
	    if(!ARESETn)begin
		    AWLEN_count <= `AXI_LEN_BITS'd0;
		end
		else if(cs == WRITE_DATA)begin
		    if(WVALID == 1'b1)begin
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

    
// ! ADDRESS 
    logic [`AXI_ADDR_BITS-1:0] ARADDR_post,ARADDR_post_handshake,AWADDR_post;
    assign ARADDR_post = ARADDR_reg + {26'd0, ARLEN_count, 2'd0};
    assign ARADDR_post_handshake = ARADDR_reg + {26'd0, ARLEN_count_handshake, 2'd0};
    assign AWADDR_post = AWADDR_reg + {26'd0, AWLEN_count, 2'd0};
    always_comb begin
	        if(cs == READ_ADDR || cs == READ_DATA )begin
		    if(RVALID && RREADY)begin
                        A = ARADDR_post_handshake[15:2];
                    end
		    else begin
                        A = ARADDR_post[15:2];
                    end
		end
		else if(cs == WRITE_DATA)begin
		    A = AWADDR_post[15:2];
		end
		else begin
		    A = 14'd0;
		end
	end

//WSTRB transform to 32bit
always_comb begin
		case(WSTRB_temp)
			4'b0000:begin
				WEB=1'b0;
				WSTRB_32bit = 32'b00000000_00000000_00000000_00000000;
			end
			4'b1110:begin
				WEB=1'b0;
				WSTRB_32bit = 32'b11111111_11111111_11111111_00000000;
			end
			4'b1101:begin
				WEB=1'b0;
				WSTRB_32bit = 32'b11111111_11111111_00000000_11111111;
			end
			4'b1011:begin
				WEB=1'b0;
				WSTRB_32bit = 32'b11111111_00000000_11111111_11111111;
			end
			4'b0111:begin
				WEB=1'b0;
				WSTRB_32bit = 32'b00000000_11111111_11111111_11111111;
			end
			4'b0011:begin
				WEB=1'b0;
				WSTRB_32bit = 32'b00000000_00000000_11111111_11111111;
			end
			4'b1100:begin
				WEB=1'b0;
				WSTRB_32bit = 32'b11111111_11111111_00000000_00000000;
			end
			4'b1001:begin
				WEB=1'b0;
				WSTRB_32bit = 32'b11111111_00000000_00000000_11111111;
			end
			4'b1110:begin
				WEB=1'b0;
				WSTRB_32bit = 32'b11111111_11111111_11111111_00000000;
			end
			default:begin
				WEB=1'b1;
				WSTRB_32bit = 32'b11111111_11111111_11111111_11111111;
			end
		endcase
	end




// logic [3:0] glb_web;
// logic [31:0] glb_addr;
// logic [31:0] glb_write_data;
// logic [31:0] glb_read_data;
// logic PASS_START_reg;

// always_ff @ (posedge ACLK or negedge ARESETn) begin
//     if (!ARESETn) begin
//         PASS_START_reg <= 1'b0;
//     end
//     else if (pass_done_o) begin
//         PASS_START_reg <= 1'b0; 
//     end
//     else if (PASS_START) begin
//         PASS_START_reg <= 1'b1; 
//     end
// end

// //glb_web
// always_comb begin
//     if (PASS_START_reg) begin
//         glb_web  = dsc_glb_web;
//         glb_addr = dsc_glb_addr[31:2];
//         // glb_read_data  = DO;
//         glb_write_data = dsc_write_data;
//     end
//     else begin
//         glb_web  = WSTRB;
//         glb_addr = A;
//         // glb_read_data  = DO;
//         glb_write_data = DI;
//     end
// end

// always_comb begin
//     dsc_read_data = DO;
// end

SRAM_2MB SRAM(
    .clk(ACLK),
    .rst_n(ARESETn),
    .WEB(WSTRB),
    .addr(A),
    .write_data(DI),
    .read_data(DO)
);



endmodule
