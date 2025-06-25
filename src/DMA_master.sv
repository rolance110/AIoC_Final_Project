module DMA_master(
	input ACLK,
    input ARESETn,
	//READ ADDRESS0
	output logic [`AXI_ID_BITS-1:0] ARID,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR,
	output logic [`AXI_LEN_BITS-1:0] ARLEN,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE,
	output logic [1:0] ARBURST,
	output logic ARVALID,
	input ARREADY,
	//READ DATA0
	input [`AXI_ID_BITS-1:0] RID,
	input [`AXI_DATA_BITS-1:0] RDATA,
	input [1:0] RRESP,
	input RLAST,
	input RVALID,
	output logic RREADY,
	//WRITE ADDRESS1
    output logic [`AXI_ID_BITS-1:0] AWID,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR,
	output logic [`AXI_LEN_BITS-1:0] AWLEN,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE,
	output logic [1:0] AWBURST,
	output logic AWVALID,
	input AWREADY,
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA,
	output logic [`AXI_STRB_BITS-1:0] WSTRB,
	output logic WLAST,
	output logic WVALID,
	input WREADY,
	//WRITE RESPONSE1
	input [`AXI_ID_BITS-1:0] BID,
	input [1:0] BRESP,
	input BVALID,
	output logic BREADY,
	
	output logic external_interrupt,
	
	input DMAEN,
	input [31:0] DMASRC,
	input [31:0] DMADST,
	input [31:0] DMALEN
);
	logic [31:0] fifo_mem[0:15];
	logic [4:0] wptr,rptr;
	logic [31:0] load_addr;
	logic [31:0] store_addr;
	logic [31:0] load_length; // count the data number need to transfer in one period
	logic [31:0] load_remaining; // count the remaining data
	logic [31:0] load_counting; //count the number have been transfer
	logic [31:0] store_cnt;
	parameter IDEAL = 4'd0, 
			  READ_ADDR = 4'd1, 
			  READ_DATA = 4'd2, 
			  WRITE_ADDR = 4'd3, 
			  WRITE_DATA = 4'd4, 
			  WRITE_BACK = 4'd5, 
			  READ_WAIT = 4'd6,
			  WRITE_WAIT = 4'd7,
			  FINISH = 4'd8;
	logic [3:0] cs,ns;
	assign external_interrupt=(cs==FINISH)?1'b1:1'b0;
	assign load_remaining = DMALEN - load_counting;
	always_comb begin
		if(load_remaining>32'd15)		load_length = 32'd15;
		else if(load_remaining!=32'd0)	load_length = (load_counting==32'd0)?{28'd0,load_remaining[3:0]}:{28'd0,load_remaining[3:0]}-32'd1;
		else							load_length = 32'd0;
	end
	always_ff@(posedge ACLK)begin
		if(!ARESETn)begin
			load_counting<=32'd0;
			load_addr<=32'd0;
			store_addr<=32'd0;
			store_cnt<=32'd0;
			wptr<=5'd0;
			rptr<=5'd0;
		end
		else begin
			if(!DMAEN)begin
				load_addr<=32'd0;
				store_addr<=32'd0;
				load_counting<=32'd0;
				load_addr<=32'd0;
				wptr<=5'd0;
				rptr<=5'd0;
			end
			else begin
				case(cs)
					IDEAL:begin
						if(DMAEN)begin
							load_addr<=DMASRC;
							store_addr<=DMADST;
						end
						else begin
							load_addr<=32'd0;
							store_addr<=32'd0;
						end
						load_counting<=32'd0;
						wptr<=5'd0;
						rptr<=5'd0;
					end
					READ_ADDR :begin
						load_addr<=load_addr;
						store_addr<=store_addr;
						load_counting<=load_counting;
						wptr<=5'd0;
						rptr<=5'd0;
					end
					READ_DATA :begin
						load_addr<=load_addr;
						store_addr<=store_addr;
						load_counting<=load_counting;
						load_addr<=load_addr;
						wptr<=(RVALID && RREADY)?wptr+5'd1:wptr;
						rptr<=rptr;
					end
					WRITE_ADDR :begin
						load_addr<=load_addr;
						store_addr<=store_addr;
						load_counting<=load_counting;
						load_addr<=load_addr;
						wptr<=wptr;
						rptr<=rptr;
					end
					WRITE_DATA :begin
						if(WVALID && WREADY)begin
							rptr<=rptr+5'd1;
							wptr<=wptr;
							if(WLAST)begin
								store_cnt<=32'd0;
								load_addr<=load_addr+{load_length[29:0],2'd0}+3'd4;
								store_addr<=store_addr+{load_length[29:0],2'd0}+3'd4;
								load_counting<=load_counting+load_length+1;
							end
							else begin
								store_cnt<=store_cnt+32'd1;
								load_addr<=load_addr;
								store_addr<=store_addr;
								load_counting<=load_counting;
							end
						end
						else begin
							load_addr<=load_addr;
							store_addr<=store_addr;
							load_counting<=load_counting;
							load_addr<=load_addr;
							wptr<=wptr;
							rptr<=rptr;
						end
					end
					WRITE_BACK :begin
						load_addr<=load_addr;
						store_addr<=store_addr;
						load_counting<=load_counting;
						load_addr<=load_addr;
						wptr<=wptr;
						rptr<=rptr;
					end
					READ_WAIT :begin
						load_addr<=load_addr;
						store_addr<=store_addr;
						load_counting<=load_counting;
						load_addr<=load_addr;
						wptr<=wptr;
						rptr<=rptr;
					end
					WRITE_WAIT :begin
						load_addr<=load_addr;
						store_addr<=store_addr;
						load_counting<=load_counting;
						load_addr<=load_addr;
						wptr<=wptr;
						rptr<=rptr;
					end
					FINISH :begin
						load_addr<=load_addr;
						store_addr<=store_addr;
						load_counting<=load_counting;
						load_addr<=load_addr;
						wptr<=wptr;
						rptr<=rptr;
					end
					default:begin
						load_addr<=32'd0;
						store_addr<=32'd0;
						load_counting<=32'd0;
						load_addr<=32'd0;
						wptr<=5'd0;
						rptr<=5'd0;
					end
				endcase
			end
		end
	end
	always_ff@(posedge ACLK)begin
		if(!ARESETn)begin
			fifo_mem[ 0] <= 32'b0;
			fifo_mem[ 1] <= 32'b0;
			fifo_mem[ 2] <= 32'b0;
			fifo_mem[ 3] <= 32'b0;
			fifo_mem[ 4] <= 32'b0;
			fifo_mem[ 5] <= 32'b0;
			fifo_mem[ 6] <= 32'b0;
			fifo_mem[ 7] <= 32'b0;
			fifo_mem[ 8] <= 32'b0;
			fifo_mem[ 9] <= 32'b0;
			fifo_mem[10] <= 32'b0;
			fifo_mem[11] <= 32'b0;
			fifo_mem[12] <= 32'b0;
			fifo_mem[13] <= 32'b0;
			fifo_mem[14] <= 32'b0;
			fifo_mem[15] <= 32'b0;
		end
		else if(cs==READ_ADDR)begin
			fifo_mem[ 0] <= 32'b0;
			fifo_mem[ 1] <= 32'b0;
			fifo_mem[ 2] <= 32'b0;
			fifo_mem[ 3] <= 32'b0;
			fifo_mem[ 4] <= 32'b0;
			fifo_mem[ 5] <= 32'b0;
			fifo_mem[ 6] <= 32'b0;
			fifo_mem[ 7] <= 32'b0;
			fifo_mem[ 8] <= 32'b0;
			fifo_mem[ 9] <= 32'b0;
			fifo_mem[10] <= 32'b0;
			fifo_mem[11] <= 32'b0;
			fifo_mem[12] <= 32'b0;
			fifo_mem[13] <= 32'b0;
			fifo_mem[14] <= 32'b0;
			fifo_mem[15] <= 32'b0;
		end
		else begin
			if(RVALID && RREADY) begin
				fifo_mem[wptr[3:0]] <= RDATA;
			end
		end
	end
	always_ff@(posedge ACLK)begin
		if(!ARESETn)begin
		    cs <= IDEAL;
		end
		else if(DMAEN)begin
		    cs <= ns;
		end
		else begin
			cs <= IDEAL;
		end
	end
	
	always_comb begin
	    case(cs)
		    IDEAL:begin
				ns = (DMAEN)?READ_ADDR:IDEAL;
			end
			READ_ADDR:begin
				ns =(ARVALID && ARREADY)?READ_DATA:READ_ADDR;
			end
			READ_DATA:begin
				ns = (RLAST && RVALID && RREADY)?WRITE_ADDR:READ_DATA;
			end
			WRITE_ADDR:begin
				ns = (AWVALID && AWREADY)?WRITE_DATA:WRITE_ADDR;
			end
			WRITE_DATA:begin
				ns = (WLAST && WVALID && WREADY)?WRITE_WAIT:WRITE_DATA;
			end
            WRITE_WAIT:begin //wait one cycle
			    ns = WRITE_BACK;
			end
			WRITE_BACK:begin
				if(load_remaining==32'd0)	ns =FINISH;
				else ns = (BVALID && BREADY)?READ_ADDR:WRITE_BACK;
			end
			default:begin
				ns = IDEAL;
			end
			
		endcase
	end
	
	always_comb begin
	    if(cs == READ_ADDR)begin
		    ARID    = `AXI_ID_BITS'd0;
			ARADDR  = load_addr;
			ARLEN   = load_length;
			ARSIZE  = `AXI_SIZE_BITS'd2;
			ARBURST = 2'd1;
			ARVALID = 1'd1;
		end
		else begin
		    ARID    = `AXI_ID_BITS'd0;
			ARADDR  = `AXI_ADDR_BITS'd0;
			ARLEN   = `AXI_LEN_BITS'd0;
			ARSIZE  = `AXI_SIZE_BITS'd0;
			ARBURST = 2'd0;
			ARVALID = 1'd0;
		end
	end
	
	// READ_DATA //
	logic [`AXI_DATA_BITS-1:0] RDATA_reg;
	
	always_comb begin
	    if(cs == READ_DATA)begin
		    RREADY = 1'd1;
		end
		else begin
		    RREADY = 1'd0;
		end
	end
	
	always_ff@(posedge ACLK)begin
		if(!ARESETn)begin
		    RDATA_reg <= `AXI_DATA_BITS'd0;
		end
		else if(cs == READ_DATA)begin
		    RDATA_reg <= RDATA;
		end
		else begin
		    RDATA_reg <= RDATA_reg;
		end
	end
	
  
    // WRITE_ADDR //
	always_comb begin
	    if(cs == WRITE_ADDR)begin
		    AWID    = `AXI_ID_BITS'd0;
			AWADDR  = store_addr;
			AWLEN   = `AXI_LEN_BITS'd0;
			AWSIZE  = `AXI_SIZE_BITS'd2;
			AWBURST = 2'd1; 
			AWVALID = 1'd1;
		end
		else begin
		    AWID    = `AXI_ID_BITS'd0;
			AWADDR  = `AXI_ADDR_BITS'd0;
			AWLEN   = `AXI_LEN_BITS'd0;
			AWSIZE  = `AXI_SIZE_BITS'd0;
			AWBURST = 2'd0;
			AWVALID = 1'd0;
		end
	end
	
	// WRITE_DATA //
	always_comb begin
	    if(cs == WRITE_DATA)begin
		    WVALID = 1'd1;
		end
		else begin
		    WVALID = 1'd0;
		end
	end
	
	always_comb begin
	    if(cs == WRITE_DATA)begin
		    WDATA = fifo_mem[rptr[3:0]]; //need modity
			WSTRB = 4'b0000; //need modify
			WLAST = (store_cnt==load_length);
		end
		else begin
		    WDATA = `AXI_DATA_BITS'd0;
			WSTRB = `AXI_STRB_BITS'b1111;
			WLAST = 1'b0;
		end
	end
	
	// WRITE_BACK //
	always_comb begin
	    if(cs == WRITE_BACK)begin
		    BREADY = 1'b1;
		end
		else begin
		    BREADY = 1'b0;
		end
	end
	
endmodule