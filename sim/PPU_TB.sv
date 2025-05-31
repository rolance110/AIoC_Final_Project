`timescale 1ns/1ps
`include "PPU.sv"

module ppu_tb;

  localparam DATA_BITS = 16;

  // Clock and Reset
  reg clk;
  reg rst;

  // DUT Inputs
  reg signed [DATA_BITS-1:0] data_in;
  reg [5:0] scaling_factor;
  reg relu_en;

  // DUT Output
  wire [7:0] data_out;

  // DUT Instantiation
  PPU #(
    .DATA_BITS(DATA_BITS)
  ) dut (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .scaling_factor(scaling_factor),
    .relu_en(relu_en),
    .data_out(data_out)
  );

  // Clock Generation: 100MHz (10ns period)
  always #5 clk = ~clk;

  // Testbench variables
  integer test_file, golden_file, scan_file;
  integer test_count = 0, pass_count = 0, fail_count = 0;
  integer scaling_factor_read;
  integer data_in_read, relu_en_read, golden_read;

  initial begin
    // Initial setup
    clk = 0;
    rst = 1;
    data_in = 0;
    scaling_factor = 0;
    relu_en = 0;

    // Dump waveform
    $fsdbDumpfile("ppu_tb.fsdb");
    $fsdbDumpvars(0, ppu_tb);

    // Reset sequence
    repeat (2) @(posedge clk);
    rst = 0;
    @(posedge clk);

    // Open files
    test_file = $fopen("../hex/test.txt", "r");
    golden_file = $fopen("../hex/golden.txt", "r");
    if (!test_file || !golden_file) begin
      $display("Error: Cannot open test.txt or golden.txt");
      $finish;
    end

    // Read scaling_factor (first line)
    if ($fscanf(test_file, "%d\n", scaling_factor_read) != 1) begin
      $display("Error: Failed to read scaling_factor from test.txt");
      $finish;
    end
    scaling_factor = scaling_factor_read;
    $display("Scaling factor read: %0d", scaling_factor);

    // Apply scaling_factor (latched for DUT)
    @(posedge clk);

    // Read test cases
    while (!$feof(test_file)) begin
      scan_file = $fscanf(test_file, "%d %d\n", data_in_read, relu_en_read);
      if (scan_file != 2) begin
        $display("Error: Invalid format in test.txt at test %0d", test_count+1);
        $finish;
      end

      data_in = data_in_read;
      relu_en = relu_en_read;

      // Stimulus at posedge
      @(posedge clk);
      #1;

      // Wait for output (1-cycle latency assumed)
      @(posedge clk);
      #1;

      // Read expected result
      if ($fscanf(golden_file, "%d\n", golden_read) != 1) begin
        $display("Error: Not enough data in golden.txt at test %0d", test_count+1);
        $finish;
      end

      // Compare results
      if (data_out === golden_read) begin
        // $display("Test %0d PASSED: data_in=%0d, relu_en=%0d -> data_out=%0d (expected %0d)", test_count+1, data_in, relu_en, data_out, golden_read);
        // pass_count++;
      end else begin
        $display("Test %0d FAILED: data_in=%0d, relu_en=%0d -> data_out=%0d (expected %0d)", test_count+1, data_in, relu_en, data_out, golden_read);
        fail_count++;
      end

      // Clear inputs
      data_in = 0;
      relu_en = 0;

      test_count++;
    end

    // Summary
    $display("\n=== Simulation Summary ===");
    $display("Total: %0d, Passed: %0d, Failed: %0d", test_count, pass_count, fail_count);

    if (fail_count == 0)
      $display("🎉 ALL TESTS PASSED!");
    else
      $display("⚠️ SOME TESTS FAILED!");

    $finish;
  end

endmodule
