`include "DMA_slave.sv"
`include "DMA_master.sv"
`include "../include/AXI_define.svh"
module DMA_wrapper(
	input ACLK,
    input ARESETn,
	
	
	//WRITE ADDRESS
    input [`AXI_IDS_BITS-1:0] S_AWID,
    input [`AXI_ADDR_BITS-1:0] S_AWADDR,
    input [`AXI_LEN_BITS-1:0] S_AWLEN,
    input [`AXI_SIZE_BITS-1:0] S_AWSIZE,
    input [1:0] S_AWBURST,
    input S_AWVALID,
    output logic S_AWREADY,

    //WRITE DATA
    input [`AXI_DATA_BITS-1:0] S_WDATA,
    input [`AXI_STRB_BITS-1:0] S_WSTRB,
    input S_WLAST,
    input S_WVALID,
    output logic S_WREADY,

    //WRITE RESPONSE
    output logic [`AXI_IDS_BITS-1:0] S_BID,
    output logic [1:0] S_BRESP,
    output logic S_BVALID,
    input S_BREADY,
	
	//READ ADDRESS0
	output logic [`AXI_ID_BITS-1:0] M_ARID,
	output logic [`AXI_ADDR_BITS-1:0] M_ARADDR,
	output logic [`AXI_LEN_BITS-1:0] M_ARLEN,
	output logic [`AXI_SIZE_BITS-1:0] M_ARSIZE,
	output logic [1:0] M_ARBURST,
	output logic M_ARVALID,
	input M_ARREADY,
	//READ DATA0
	input [`AXI_ID_BITS-1:0] M_RID,
	input [`AXI_DATA_BITS-1:0] M_RDATA,
	input [1:0] M_RRESP,
	input M_RLAST,
	input M_RVALID,
	output logic M_RREADY,
	//WRITE ADDRESS1
    output logic [`AXI_ID_BITS-1:0] M_AWID,
	output logic [`AXI_ADDR_BITS-1:0] M_AWADDR,
	output logic [`AXI_LEN_BITS-1:0] M_AWLEN,
	output logic [`AXI_SIZE_BITS-1:0] M_AWSIZE,
	output logic [1:0] M_AWBURST,
	output logic M_AWVALID,
	input M_AWREADY,
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] M_WDATA,
	output logic [`AXI_STRB_BITS-1:0] M_WSTRB,
	output logic M_WLAST,
	output logic M_WVALID,
	input M_WREADY,
	//WRITE RESPONSE1
	input [`AXI_ID_BITS-1:0] M_BID,
	input [1:0] M_BRESP,
	input M_BVALID,
	output logic M_BREADY,
	
	output logic external_interrupt
);
	logic DMAEN;
	logic [31:0]DMASRC;
	logic [31:0]DMADST;
	logic [31:0]DMALEN;
	
	DMA_slave DMA_slave(
		.ACLK(ACLK),
		.ARESETn(ARESETn),
		.AWID(S_AWID),
		.AWADDR(S_AWADDR),
		.AWLEN(S_AWLEN),
		.AWSIZE(S_AWSIZE),
		.AWBURST(S_AWBURST),
		.AWVALID(S_AWVALID),
		.AWREADY(S_AWREADY),
		
		//WRITE DATA
		.WDATA(S_WDATA),
		.WSTRB(S_WSTRB),
		.WLAST(S_WLAST),
		.WVALID(S_WVALID),
		.WREADY(S_WREADY),
		
		//WRITE RESPONSE
		.BID(S_BID),
		.BRESP(S_BRESP),
		.BVALID(S_BVALID),
		.BREADY(S_BREADY),
		
		.external_interrupt(external_interrupt),
		.DMAEN(DMAEN),
		.DMASRC(DMASRC),
		.DMADST(DMADST),
		.DMALEN(DMALEN)
	);
	DMA_master DMA_master(
		.ACLK(ACLK),
		.ARESETn(ARESETn),
		//READ ADDRESS0
		.ARID(M_ARID),
		.ARADDR(M_ARADDR),
		.ARLEN(M_ARLEN),
		.ARSIZE(M_ARSIZE),
		.ARBURST(M_ARBURST),
		.ARVALID(M_ARVALID),
		.ARREADY(M_ARREADY),
		//READ DATA0
		.RID(M_RID),
		.RDATA(M_RDATA),
		.RRESP(M_RRESP),
		.RLAST(M_RLAST),
		.RVALID(M_RVALID),
		.RREADY(M_RREADY),
		//WRITE ADDRESS1
		.AWID(M_AWID),
		.AWADDR(M_AWADDR),
		.AWLEN(M_AWLEN),
		.AWSIZE(M_AWSIZE),
		.AWBURST(M_AWBURST),
		.AWVALID(M_AWVALID),
		.AWREADY(M_AWREADY),
		//WRITE DATA1
		.WDATA(M_WDATA),
		.WSTRB(M_WSTRB),
		.WLAST(M_WLAST),
		.WVALID(M_WVALID),
		.WREADY(M_WREADY),
		//WRITE RESPONSE1
		.BID(M_BID),
		.BRESP(M_BRESP),
		.BVALID(M_BVALID),
		.BREADY(M_BREADY),
		
		.external_interrupt(external_interrupt),
		
		.DMAEN(DMAEN),
		.DMASRC(DMASRC),
		.DMADST(DMADST),
		.DMALEN(DMALEN)
	);
endmodule