module DMA_slave(
	input ACLK,
    input ARESETn,
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
	input external_interrupt,
	output logic DMAEN,
	output logic [31:0]DMASRC,
	output logic [31:0]DMADST,
	output logic [31:0]DMALEN
);
	logic [`AXI_IDS_BITS-1:0]  AWID_reg;
	logic [`AXI_ADDR_BITS-1:0] AWADDR_reg;
    logic [`AXI_LEN_BITS-1:0]  AWLEN_reg;
    logic [`AXI_SIZE_BITS-1:0] AWSIZE_reg;
    logic [1:0] AWBURST_reg;
	
	logic [`AXI_LEN_BITS-1:0]  AWLEN_count;
	logic [31:0]WSTRB_32bit;
	logic [3:0] WSTRB_temp;
	parameter IDEAL = 3'd0, 
			  WRITE_ADDR = 3'd3, 
			  WRITE_DATA = 3'd4, 
			  WRITE_BACK = 3'd5;
	logic [2:0] cs,ns;
	
	always_ff@(posedge ACLK)begin
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
				ns = (AWVALID) ? WRITE_ADDR : IDEAL;
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
	// WRITE_ADDR //
	always_ff@(posedge ACLK)begin
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
			WSTRB_temp = WSTRB;
		end 
		else begin
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
    logic [`AXI_ADDR_BITS-1:0] AWADDR_post;
    assign AWADDR_post = AWADDR_reg + {26'd0, AWLEN_count, 2'd0};

	always_ff@(posedge ACLK) begin //WDT
		if(!ARESETn)begin
			DMAEN<=1'b0;
			DMASRC<=32'd0;
			DMADST<=32'd0;
			DMALEN<=32'd0;
		end
		else begin
			if(cs==WRITE_DATA && WVALID)begin
				case(AWADDR_post)
					32'h3000_0400:begin //DMAEN
						DMAEN<=(WSTRB_temp==4'b0000 && WDATA!=32'd0)?1'b1:1'b0;
						DMASRC<=DMASRC;
						DMADST<=DMADST;
						DMALEN<=DMALEN;
					end
					32'h3000_0100:begin //DMASRC
						DMAEN<=DMAEN;
						DMASRC<=(WSTRB_temp==4'b0000)?WDATA:32'd0;
						DMADST<=DMADST;
						DMALEN<=DMALEN;
					end
					32'h3000_0200:begin //DMADST
						DMAEN<=DMAEN;
						DMASRC<=DMASRC;
						DMADST<=(WSTRB_temp==4'b0000)?WDATA:32'd0;
						DMALEN<=DMALEN;
					end
					32'h3000_0300:begin //DMALEN
						DMAEN<=DMAEN;
						DMASRC<=DMASRC;
						DMADST<=DMADST;
						DMALEN<=(WSTRB_temp==4'b0000)?WDATA:32'd0;
					end
					default:begin
						DMAEN<=DMAEN;
						DMASRC<=DMASRC;
						DMADST<=DMADST;
						DMALEN<=DMALEN;
					end
				endcase
			end
			else begin
				DMAEN<=(external_interrupt)?1'b0:DMAEN;
				DMASRC<=DMASRC;
				DMADST<=DMADST;
				DMALEN<=DMALEN;
			end
		end
	end
endmodule