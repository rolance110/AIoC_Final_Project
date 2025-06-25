`include "../include/define.svh"

module tb_TS_AXI_wrapper;

    // Clock and reset
    logic clk;
    logic rst_n;

    // DMA inputs
    logic [31:0] DMA_src;
    logic [31:0] DMA_dest;
    logic [31:0] DMA_len;
    logic DMA_en;

    
    logic DMA_interrupt;

    // AXI Master interface signals
    logic [`ID_WIDTH-1:0] awid_m;
    logic [`ADDR_WIDTH-1:0] awaddr_m;
    logic [`LEN_WIDTH-1:0] awlen_m;
    logic [`SIZE_WIDTH-1:0] awsize_m;
    logic [`BURST_WIDTH-1:0] awburst_m;
    logic awvalid_m;
    logic awready_m;

    logic [`DATA_WIDTH-1:0] wdata_m;
    logic [`DATA_WIDTH/8-1:0] wstrb_m;
    logic wlast_m;
    logic wvalid_m;
    logic wready_m;

    logic [`ID_WIDTH-1:0] bid_m;
    logic [`BRESP_WIDTH-1:0] bresp_m;
    logic bvalid_m;
    logic bready_m;

    logic [`ID_WIDTH-1:0] arid_m;
    logic [`ADDR_WIDTH-1:0] araddr_m;
    logic [`LEN_WIDTH-1:0] arlen_m;
    logic [`SIZE_WIDTH-1:0] arsize_m;
    logic [`BURST_WIDTH-1:0] arburst_m;
    logic arvalid_m;
    logic arready_m;

    logic [`ID_WIDTH-1:0] rid_m;
    logic [`DATA_WIDTH-1:0] rdata_m;
    logic rlast_m;
    logic rvalid_m;
    logic [`RRESP_WIDTH-1:0] rresp_m;
    logic rready_m;

    // Instantiate the DUT
    TS_AXI_wrapper dut (
        .clk(clk),
        .rst_n(rst_n),
        .DMA_src_i(DMA_src),
        .DMA_dest_i(DMA_dest),
        .DMA_len_i(DMA_len),
        .DMA_en_i(DMA_en),
        .DMA_interrupt_i(DMA_interrupt),
        .awid_m_o(awid_m),
        .awaddr_m_o(awaddr_m),
        .awlen_m_o(awlen_m),
        .awsize_m_o(awsize_m),
        .awburst_m_o(awburst_m),
        .awvalid_m_o(awvalid_m),
        .awready_m_i(awready_m),
        .wdata_m_o(wdata_m),
        .wstrb_m_o(wstrb_m),
        .wlast_m_o(wlast_m),
        .wvalid_m_o(wvalid_m),
        .wready_m_i(1'b1),
        .bid_m_i(bid_m),
        .bresp_m_i(bresp_m),
        .bvalid_m_i(1'b1),
        .bready_m_o(bready_m),
        .arid_m_o(arid_m),
        .araddr_m_o(araddr_m),
        .arlen_m_o(arlen_m),
        .arsize_m_o(arsize_m),
        .arburst_m_o(arburst_m),
        .arvalid_m_o(arvalid_m),
        .arready_m_i(arready_m),
        .rid_m_i(rid_m),
        .rdata_m_i(rdata_m),
        .rlast_m_i(rlast_m),
        .rvalid_m_i(rvalid_m),
        .rresp_m_i(rresp_m),
        .rready_m_o(rready_m)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock (10ns period)
    end


always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        // Reset all AXI signals
        awready_m <= 1'b0;
    else if(awvalid_m && !awready_m)
        // Set awready_m when awvalid_m is high
        awready_m <= 1'b1;
    else
        awready_m <= 1'b0;
end


    // Reset task
    task reset();
        rst_n = 0;
        DMA_src = 32'h0;
        DMA_dest = 32'h0;
        DMA_len = 32'h0;
        DMA_en = 0;
        DMA_interrupt = 0;
        wready_m = 0;
        bvalid_m = 0;
        bid_m = 0;
        bresp_m = 0;
        arready_m = 0;
        rvalid_m = 0;
        rid_m = 0;
        rdata_m = 0;
        rresp_m = 0;
        rlast_m = 0;
        #20;
        rst_n = 1;
    endtask


    // Test sequence
    initial begin
        // Initialize
        reset();

        // Test case 1: Single DMA transfer
        $display("Starting Test Case 1: Single DMA transfer");
        DMA_src = 32'h1000_0000;
        DMA_dest = 32'h2000_0000;
        DMA_len = 32'h0000_0100;
        DMA_en = 1;


        // Check if state reaches FINISH
        wait(dut.cs_TSW == 3'd6);
        $display("Test Case 1: Reached FINISH state");
        DMA_interrupt = 1;
        // Test case 2: DMA restart with interrupt
        $display("Starting Test Case 2: DMA restart with interrupt");


        // Wait for state to return to IDLE
        wait(dut.cs_TSW == 3'd0);
        DMA_interrupt = 0;

        $display("Test Case 2: Returned to IDLE state");

        // Set new DMA parameters
        DMA_src = 32'h3000_0000;
        DMA_dest = 32'h4000_0000;
        DMA_len = 32'h0000_0200;
        DMA_en = 1;


        // Check if state reaches FINISH again
        wait(dut.cs_TSW == 3'd6);
        DMA_interrupt = 1;

        $display("Test Case 2: Reached FINISH state again");

        $display("Simulation completed successfully");
        $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time=%0t State=%0d awvalid_m=%b awaddr_m=%h wvalid_m=%b wdata_m=%h bready_m=%b bvalid_m=%b",
                 $time, dut.cs_TSW, awvalid_m, awaddr_m, wvalid_m, wdata_m, bready_m, bvalid_m);
    end

initial begin
    #1000000;
    $display("Simulation timeout, terminating...");
    $finish;
end


// dump FSDB file
initial begin
    `ifdef FSDB
        $fsdbDumpfile("../wave/top.fsdb");
        $fsdbDumpvars(0, dut);
    `elsif FSDB_ALL
        $fsdbDumpfile("../wave/top.fsdb");
        $fsdbDumpvars("+struct", "+mda", dut);
    `endif
end
endmodule