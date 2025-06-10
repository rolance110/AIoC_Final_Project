`timescale 1ns/1ps

//===========================================================================
// Testbench: ifmap_fifo_bank_tb
// Purpose  : Verify functionality of ifmap_fifo_bank and underlying ifmap_fifo instances
//===========================================================================
module ifmap_fifo_bank_tb;

    // Clock and reset
    logic clk;
    logic rst_n;
    always #5 clk = ~clk;

    // Control signals for 32 FIFOs
    logic [31:0] push_ifmap_en;
    logic [31:0] push_ifmap_mod;
    logic [31:0][31:0] push_ifmap_data;
    logic [31:0] ifmap_fifo_full;

    logic [31:0] pop_ifmap_en;
    logic [31:0][7:0] pop_ifmap_data;
    logic [31:0] ifmap_fifo_empty;

    // Instantiate DUT
    ifmap_fifo_bank #(
        .WIDTH(8),
        .DEPTH(4)
    ) uut (
        .clk               (clk),
        .rst_n             (rst_n),
        .push_ifmap_en     (push_ifmap_en),
        .push_ifmap_mod    (push_ifmap_mod),
        .push_ifmap_data   (push_ifmap_data),
        .ifmap_fifo_full   (ifmap_fifo_full),
        .pop_ifmap_en      (pop_ifmap_en),
        .pop_ifmap_data    (pop_ifmap_data),
        .ifmap_fifo_empty  (ifmap_fifo_empty)
    );

    // Test sequence
    initial begin
        // Initialize
        clk = 0;
        rst_n = 0;
        push_ifmap_en   = '0;
        push_ifmap_mod  = '0;
        push_ifmap_data = 32'd0;
        pop_ifmap_en    = '0;

        // Reset pulse
        #12;
        rst_n = 1;

        //=== Test 1: Single 8-bit push/pop on FIFO[0] ===
        $display("--- Test 1: 8-bit push/pop on FIFO[0] ---");
        push_ifmap_mod[0]  = 1'b0;               // mode = 8-bit
        push_ifmap_data[0] = 32'h000000AA;       // data = 0xAA
        push_ifmap_en[0]   = 1'b1;
        #10;
        push_ifmap_en[0]   = 1'b0;
        #10;
        pop_ifmap_en[0]    = 1'b1;
        #10;
        pop_ifmap_en[0]    = 1'b0;
        $display("FIFO[0].pop_data = 0x%0h (expected 0xAA)", pop_ifmap_data[0]);
        $display("FIFO[0].empty = %b (expected 1)", ifmap_fifo_empty[0]);

        //=== Test 2: 32-bit burst push/pop on FIFO[1] ===
        $display("--- Test 2: 32-bit burst push on FIFO[1] ---");
        push_ifmap_mod[1]  = 1'b1;               // burst mode
        push_ifmap_data[1] = 32'h11223344;       // low->0x44, next->0x33, ->0x22, ->0x11
        push_ifmap_en[1]   = 1'b1;
        #10;
        push_ifmap_en[1]   = 1'b0;
        // Pop four times
        repeat (4) begin
            #10 pop_ifmap_en[1] = 1'b1;
            #10 pop_ifmap_en[1] = 1'b0;
            #10;
        
        $display("FIFO[1] pop sequence = [%0h] (expected 44->33->22->11)",
                 pop_ifmap_data[1]);
        $display("FIFO[1].empty = %b", ifmap_fifo_empty[1]);
        end
        //=== Test 3: Full condition on FIFO[2] ===
        $display("--- Test 3: Full condition on FIFO[2] ---");
        push_ifmap_mod[2]  = 1'b0;
        push_ifmap_data[2] = 32'h000000A5;
        // Fill to capacity (4 entries)
        repeat (4) begin
            #10 push_ifmap_en[2] = 1'b1;
            #10 push_ifmap_en[2] = 1'b0;
        end
        #10;
        $display("FIFO[2].full = %b (expected 1)", ifmap_fifo_full[2]);
        // Attempt one more push -> should not increase count
        #10 push_ifmap_en[2] = 1'b1;
        #10 push_ifmap_en[2] = 1'b0;
        #10;
        $display("FIFO[2].full after extra push = %b (expected 1)", ifmap_fifo_full[2]);

        //=== Test 4: Empty condition on FIFO[2] after pops ===
        $display("--- Test 4: Empty condition on FIFO[2] after pops ---");
        // Pop all
        repeat (4) begin
            #10 pop_ifmap_en[2] = 1'b1;
            #10 pop_ifmap_en[2] = 1'b0;
        end
        #10;
        $display("FIFO[2].empty = %b (expected 1)", ifmap_fifo_empty[2]);

        $display("=== All tests completed ===");
        $finish;
    end
        //---- Dump FSDB ----
    initial begin
        `ifdef FSDB
            $fsdbDumpfile("../wave/top.fsdb");
            $fsdbDumpvars(0, uut);
        `elsif FSDB_ALL
            $fsdbDumpfile("../wave/top.fsdb");
            $fsdbDumpvars("+struct", "+mda", uut);
        `endif
    end

endmodule