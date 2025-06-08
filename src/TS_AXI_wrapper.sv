`include "../include/define.svh"
module TS_AXI_wrapper(
    input logic clk,
    input logic rst_n,

    input logic [31:0] DMA_src,
    input logic [31:0] DMA_dest,
    input logic [31:0] DMA_len,
    input logic DMA_en,

    input logic DMA_interrupt, // signal to restart DMA transfer

	//master interface(FIFO mem)
	//Write address channel signals DM
    output logic    [`ID_WIDTH-1:0]      awid_m,    	// Write address ID tag
    output logic    [`ADDR_WIDTH-1:0]    awaddr_m,  	// Write address
    output logic    [`LEN_WIDTH-1:0]     awlen_m,   	// Write address burst length
    output logic    [`SIZE_WIDTH-1:0]    awsize_m,  	// Write address burst size
    output logic    [`BURST_WIDTH-1:0]   awburst_m, 	// Write address burst type
    output logic                        awvalid_m,  	// Write address valid
    input  logic                        awready_m,  	// Write address ready
	
    //Write data channel signals	
    output logic    [`DATA_WIDTH-1:0]    wdata_m,   	// Write data
    output logic    [`DATA_WIDTH/8-1:0]  wstrb_m,   	// Write strobe
    output logic                        wlast_m,    	// Write last
    output logic                        wvalid_m,   	// Write valid
    input  logic                        wready_m,   	// Write ready
	
    //Write response channel signals	
    input  logic    [`ID_WIDTH-1:0]      bid_m,     	// Write response ID tag
    input  logic    [`BRESP_WIDTH-1:0]   bresp_m,   	// Write response
    input  logic                        bvalid_m,   	// Write response valid
    output logic                        bready_m,   	// Write response ready
	 
    //Read address channel signals	
    output logic    [`ID_WIDTH-1:0]      arid_m,    	// Read address ID tag
    output logic    [`ADDR_WIDTH-1:0]    araddr_m,  	// Read address
    output logic    [`LEN_WIDTH-1:0]     arlen_m,   	// Read address burst length
    output logic    [`SIZE_WIDTH-1:0]    arsize_m,  	// Read address burst size
    output logic    [`BURST_WIDTH-1:0]   arburst_m, 	// Read address burst type
    output logic                        arvalid_m,  	// Read address valid
    input  logic                        arready_m,  	// Read address ready
    //Read data channel signals	
    input  logic    [`ID_WIDTH-1:0]      rid_m,     	// Read ID tag
    input  logic    [`DATA_WIDTH-1:0]    rdata_m,   	// Read data
    input  logic                        rlast_m,    	// Read last
    input  logic                        rvalid_m,   	// Read valid
    input  logic    [`RRESP_WIDTH-1:0]   rresp_m,   	// Read response
    output logic                        rready_m   	// Read ready
);


localparam IDLE = 3'd0;
localparam AW_HSK = 3'd3;
localparam W_HSK = 3'd4;
localparam B_HSK = 3'd5;
localparam FINISH = 3'd6;

always_comb begin// not use read
    arid_m = 4'd0;
    araddr_m = 32'd0;
    arlen_m = 4'd0;
    arsize_m = 3'b010;
    arburst_m = 2'b01;
    arvalid_m = 1'b0;
    rready_m = 1'b0;
end

always_comb begin
    awid_m = 4'd0; // Constant ID for simplicity
    awsize_m = 3'b010; // 4-byte transfers (32-bit data width)
    awburst_m = 2'b01; // INCR burst type
end

logic [2:0] cs_TSW, ns_TSW;
logic DMA_start;
logic [2:0] DMA_cnt; // 3 bits to count DMA operations (src, dest, len, en)

always_ff @(posedge clk) begin
    if (!rst_n)
        DMA_cnt <= 3'd0;
    else if(cs_TSW == IDLE)
        DMA_cnt <= 3'd0;
    else if (bvalid_m && bready_m)
        DMA_cnt <= DMA_cnt + 3'd1; // Increment count on write response

end


always_ff @(posedge clk) begin
    if(!rst_n)
        DMA_start <= 1'b0;
    else if(DMA_cnt == 3'd4) // (0)DMA_src -> (1)DMA_dest -> (2)DMA_len -> (3)DMA_en
        DMA_start <= 1'b0;
    else if(DMA_en)
        DMA_start <= 1'b1;

end

always_ff @(posedge clk) begin
	if(!rst_n)
		cs_TSW <= IDLE;  
	else 
		cs_TSW <= ns_TSW;
end
always_comb begin
	case(cs_TSW)
			IDLE: begin
				if(DMA_en) // DMA start
					ns_TSW = AW_HSK;
				else	
					ns_TSW = IDLE;
			end
			AW_HSK: begin
				if(awvalid_m && awready_m)
					ns_TSW = W_HSK;
				else
					ns_TSW = AW_HSK;
			end
			W_HSK: begin
				if(wvalid_m && wready_m && wlast_m)
					ns_TSW = B_HSK;
				else
					ns_TSW = W_HSK;
			end
			B_HSK: begin
				if(bvalid_m && bready_m && DMA_cnt == 3'd3)
                    ns_TSW = FINISH; // Last write response received
                else if(bvalid_m && bready_m)
					ns_TSW = AW_HSK;
				else
					ns_TSW = B_HSK;
			end
            FINISH: begin
                if (DMA_interrupt) // restart
                    ns_TSW = IDLE;
                else
                    ns_TSW = FINISH;
            end
			default: ns_TSW = IDLE;
		endcase
end

always_comb begin
	case(cs_TSW)
		IDLE: begin
			//AW channel
			awaddr_m  = 32'b0;
			awlen_m	= 4'b0;
			awvalid_m = 1'b0;
			//W channel
			wdata_m	= 32'b0;
			wlast_m	= 1'b0;
			wvalid_m	= 1'b0;
            wstrb_m    = 4'b1111; // Always write all bytes
			//B channel
			bready_m  = 1'b0;
		end
		AW_HSK: begin
			//AW channel
			case(DMA_cnt)
                3'd0: awaddr_m = `DMA_SRC_ADDR; // Source address
                3'd1: awaddr_m = `DMA_DEST_ADDR; // Destination address
                3'd2: awaddr_m = `DMA_LEN_ADDR;  // Transfer length
                3'd3: awaddr_m = `DMA_EN_ADDR;   // Enable signal
                default: awaddr_m = 32'b0;
			endcase
			awlen_m	= `LEN_WIDTH'd1;
			awvalid_m = 1'b1;
			//W channel
			wdata_m	= 32'b0;
			wlast_m	= 1'b0;
			wvalid_m	= 1'b0;
            wstrb_m    = 4'b1111; // Always write all bytes
			//B channel
			bready_m  = 1'b0;
		end
		W_HSK: begin
			//AW channel
			awaddr_m  = 32'b0;
			awlen_m	= 4'd0;
			awvalid_m = 1'b0;
			//W channel
            case(DMA_cnt)
                3'd0: wdata_m = DMA_src;  // Write source address
                3'd1: wdata_m = DMA_dest; // Write destination address
                3'd2: wdata_m = DMA_len;   // Write transfer length
                3'd3: wdata_m = {31'b0, DMA_en}; // Write enable signal
                default: wdata_m = 32'b0;
            endcase
			wlast_m	= 1'b1; // Only transfer one data at a time
			wvalid_m	= 1'b1;
			wstrb_m    = 4'b0000;

			//B channel
			bready_m  = 1'b0;
		end
		B_HSK: begin
			//AW channel
			awaddr_m  = 32'b0;
			awlen_m	= 4'b0;
			awvalid_m = 1'b0;
			//W channel
			wdata_m	= 32'b0;
			wlast_m	= 1'b0;
			wvalid_m	= 1'b0;
            wstrb_m    = 4'b1111; // Always write all bytes
			//B channel
			bready_m  = 1'b1; // Ready to receive write response
		end
		FINISH: begin
			//AW channel
			awaddr_m  = 32'b0;
			awlen_m	= 4'b0;
			awvalid_m = 1'b0;
			//W channel
			wdata_m	= 32'b0;
			wlast_m	= 1'b0;
			wvalid_m	= 1'b0;
            wstrb_m    = 4'b1111; // Always write all bytes
			//B channel
			bready_m  = 1'b0;
		end
		default: begin
			//AW channel
			awaddr_m  = 32'b0;
			awlen_m	= 4'b0;
			awvalid_m = 1'b0;
			//W channel
			wdata_m	= 32'b0;
			wlast_m	= 1'b0;
			wvalid_m	= 1'b0;
            wstrb_m    = 4'b1111;
			//B channel
			bready_m  = 1'b0;
		end
	endcase
end




endmodule