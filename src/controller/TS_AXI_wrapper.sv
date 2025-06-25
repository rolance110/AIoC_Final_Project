`include "../include/define.svh"
module TS_AXI_wrapper(
    input logic clk,
    input logic rst_n,

    input logic [31:0] DMA_src_i,
    input logic [31:0] DMA_dest_i,
    input logic [31:0] DMA_len_i,
    input logic DMA_en_i,

    input logic DMA_interrupt_i, // signal to restart DMA transfer

	//master interface(FIFO mem)
	//Write address channel signals DM
    output logic    [`ID_WIDTH-1:0]      awid_m_o,    	// Write address ID tag
    output logic    [`ADDR_WIDTH-1:0]    awaddr_m_o,  	// Write address
    output logic    [`LEN_WIDTH-1:0]     awlen_m_o,   	// Write address burst length
    output logic    [`SIZE_WIDTH-1:0]    awsize_m_o,  	// Write address burst size
    output logic    [`BURST_WIDTH-1:0]   awburst_m_o, 	// Write address burst type
    output logic                        awvalid_m_o,  	// Write address valid
    input  logic                        awready_m_i,  	// Write address ready
	
    //Write data channel signals	
    output logic    [`DATA_WIDTH-1:0]    wdata_m_o,   	// Write data
    output logic    [`DATA_WIDTH/8-1:0]  wstrb_m_o,   	// Write strobe
    output logic                        wlast_m_o,    	// Write last
    output logic                        wvalid_m_o,   	// Write valid
    input  logic                        wready_m_i,   	// Write ready
	
    //Write response channel signals	
    input  logic    [`ID_WIDTH-1:0]      bid_m_i,     	// Write response ID tag
    input  logic    [`BRESP_WIDTH-1:0]   bresp_m_i,   	// Write response
    input  logic                        bvalid_m_i,   	// Write response valid
    output logic                        bready_m_o,   	// Write response ready
	 
    //Read address channel signals	
    output logic    [`ID_WIDTH-1:0]      arid_m_o,    	// Read address ID tag
    output logic    [`ADDR_WIDTH-1:0]    araddr_m_o,  	// Read address
    output logic    [`LEN_WIDTH-1:0]     arlen_m_o,   	// Read address burst length
    output logic    [`SIZE_WIDTH-1:0]    arsize_m_o,  	// Read address burst size
    output logic    [`BURST_WIDTH-1:0]   arburst_m_o, 	// Read address burst type
    output logic                        arvalid_m_o,  	// Read address valid
    input  logic                        arready_m_i,  	// Read address ready
    //Read data channel signals	
    input  logic    [`ID_WIDTH-1:0]      rid_m_i,     	// Read ID tag
    input  logic    [`DATA_WIDTH-1:0]    rdata_m_i,   	// Read data
    input  logic                        rlast_m_i,    	// Read last
    input  logic                        rvalid_m_i,   	// Read valid
    input  logic    [`RRESP_WIDTH-1:0]   rresp_m_i,   	// Read response
    output logic                        rready_m_o   	// Read ready
);


localparam IDLE = 3'd0;
localparam AW_HSK = 3'd3;
localparam W_HSK = 3'd4;
localparam B_HSK = 3'd5;
localparam FINISH = 3'd6;

always_comb begin// not use read
    arid_m_o = 4'd0;
    araddr_m_o = 32'd0;
    arlen_m_o = 4'd0;
    arsize_m_o = 3'b010;
    arburst_m_o = 2'b01;
    arvalid_m_o = 1'b0;
    rready_m_o = 1'b0;
end

always_comb begin
    awid_m_o = 4'd0; // Constant ID for simplicity
    awsize_m_o = 3'b010; // 4-byte transfers (32-bit data width)
    awburst_m_o = 2'b01; // INCR burst type
end

logic [2:0] cs_TSW, ns_TSW;
logic DMA_start;
logic [2:0] DMA_cnt; // 3 bits to count DMA operations (src, dest, len, en)

always_ff @(posedge clk) begin
    if (!rst_n)
        DMA_cnt <= 3'd0;
    else if(cs_TSW == IDLE)
        DMA_cnt <= 3'd0;
    else if (bvalid_m_i && bready_m_o)
        DMA_cnt <= DMA_cnt + 3'd1; // Increment count on write response

end


always_ff @(posedge clk) begin
    if(!rst_n)
        DMA_start <= 1'b0;
    else if(DMA_cnt == 3'd4) // (0)DMA_src_i -> (1)DMA_dest_i -> (2)DMA_len_i -> (3)DMA_en_i
        DMA_start <= 1'b0;
    else if(DMA_en_i)
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
				if(DMA_en_i) // DMA start
					ns_TSW = AW_HSK;
				else	
					ns_TSW = IDLE;
			end
			AW_HSK: begin
				if(awvalid_m_o && awready_m_i)
					ns_TSW = W_HSK;
				else
					ns_TSW = AW_HSK;
			end
			W_HSK: begin
				if(wvalid_m_o && wready_m_i && wlast_m_o)
					ns_TSW = B_HSK;
				else
					ns_TSW = W_HSK;
			end
			B_HSK: begin
				if(bvalid_m_i && bready_m_o && DMA_cnt == 3'd3)
                    ns_TSW = FINISH; // Last write response received
                else if(bvalid_m_i && bready_m_o)
					ns_TSW = AW_HSK;
				else
					ns_TSW = B_HSK;
			end
            FINISH: begin
                if (DMA_interrupt_i) // restart
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
			awaddr_m_o  = 32'b0;
			awlen_m_o	= 4'b0;
			awvalid_m_o = 1'b0;
			//W channel
			wdata_m_o	= 32'b0;
			wlast_m_o	= 1'b0;
			wvalid_m_o	= 1'b0;
            wstrb_m_o    = 4'b1111; // Always write all bytes
			//B channel
			bready_m_o  = 1'b0;
		end
		AW_HSK: begin
			//AW channel
			case(DMA_cnt)
                3'd0: awaddr_m_o = `DMA_SRC_ADDR; // Source address
                3'd1: awaddr_m_o = `DMA_DEST_ADDR; // Destination address
                3'd2: awaddr_m_o = `DMA_LEN_ADDR;  // Transfer length
                3'd3: awaddr_m_o = `DMA_EN_ADDR;   // Enable signal
                default: awaddr_m_o = 32'b0;
			endcase
			awlen_m_o	= `LEN_WIDTH'd1;
			awvalid_m_o = 1'b1;
			//W channel
			wdata_m_o	= 32'b0;
			wlast_m_o	= 1'b0;
			wvalid_m_o	= 1'b0;
            wstrb_m_o    = 4'b1111; // Always write all bytes
			//B channel
			bready_m_o  = 1'b0;
		end
		W_HSK: begin
			//AW channel
			awaddr_m_o  = 32'b0;
			awlen_m_o	= 4'd0;
			awvalid_m_o = 1'b0;
			//W channel
            case(DMA_cnt)
                3'd0: wdata_m_o = DMA_src_i;  // Write source address
                3'd1: wdata_m_o = DMA_dest_i; // Write destination address
                3'd2: wdata_m_o = DMA_len_i;   // Write transfer length
                3'd3: wdata_m_o = {31'b0, DMA_en_i}; // Write enable signal
                default: wdata_m_o = 32'b0;
            endcase
			wlast_m_o	= 1'b1; // Only transfer one data at a time
			wvalid_m_o	= 1'b1;
			wstrb_m_o    = 4'b0000;

			//B channel
			bready_m_o  = 1'b0;
		end
		B_HSK: begin
			//AW channel
			awaddr_m_o  = 32'b0;
			awlen_m_o	= 4'b0;
			awvalid_m_o = 1'b0;
			//W channel
			wdata_m_o	= 32'b0;
			wlast_m_o	= 1'b0;
			wvalid_m_o	= 1'b0;
            wstrb_m_o    = 4'b1111; // Always write all bytes
			//B channel
			bready_m_o  = 1'b1; // Ready to receive write response
		end
		FINISH: begin
			//AW channel
			awaddr_m_o  = 32'b0;
			awlen_m_o	= 4'b0;
			awvalid_m_o = 1'b0;
			//W channel
			wdata_m_o	= 32'b0;
			wlast_m_o	= 1'b0;
			wvalid_m_o	= 1'b0;
            wstrb_m_o    = 4'b1111; // Always write all bytes
			//B channel
			bready_m_o  = 1'b0;
		end
		default: begin
			//AW channel
			awaddr_m_o  = 32'b0;
			awlen_m_o	= 4'b0;
			awvalid_m_o = 1'b0;
			//W channel
			wdata_m_o	= 32'b0;
			wlast_m_o	= 1'b0;
			wvalid_m_o	= 1'b0;
            wstrb_m_o    = 4'b1111;
			//B channel
			bready_m_o  = 1'b0;
		end
	endcase
end




endmodule