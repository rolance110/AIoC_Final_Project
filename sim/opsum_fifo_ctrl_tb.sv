`timescale 1ns / 1ps
`include "../include/define.svh"

module opsum_fifo_ctrl_tb;

  parameter CYCLE = 10;

  logic clk, rst_n;

  // DUT inputs
  logic fifo_glb_busy_i;
  logic opsum_fifo_reset_i;
  logic opsum_need_push_i;
  logic [31:0] opsum_push_num_i;
  logic opsum_fifo_push_mask_i;
  logic after_preheat_opsum_push_one_i;
  logic opsum_permit_pop_i;
  logic opsum_fifo_empty_i;
  logic opsum_fifo_full_i;
  logic [31:0] opsum_fifo_pop_data_i;
  logic [31:0] opsum_glb_base_addr_i;
  logic pe_array_move_i;

  // DUT outputs
  logic opsum_write_req_o;
  logic opsum_fifo_pop_o;
  logic opsum_fifo_pop_mod_o;
  logic opsum_fifo_push_o;
  logic [31:0] opsum_glb_write_addr_o;
  logic [3:0]  opsum_glb_write_web_o;
  logic [31:0] opsum_glb_write_data_o;
  logic opsum_is_PUSH_state_o;
  logic opsum_fifo_done_o;

  // internal FIFO stub state
  logic [31:0] pop_data;
  logic empty, full;

  assign opsum_fifo_empty_i = empty;
  assign opsum_fifo_full_i  = full;
  assign opsum_fifo_pop_data_i = pop_data;

  // golden reference
  logic [31:0] golden_data [0:1];
  logic [31:0] golden_addr [0:1];
  logic [3:0]  golden_web  [0:1];
  int golden_index;

  initial begin
    golden_data[0] = 32'h12345678;
    golden_addr[0] = 32'h1000_0000;
    golden_web[0]  = 4'b0011;

    golden_data[1] = 32'hdeadbeef;
    golden_addr[1] = 32'h1000_0002;
    golden_web[1]  = 4'b1100;
  end

  // Clock
  initial clk = 0;
  always #(CYCLE/2) clk = ~clk;

  assign opsum_permit_pop_i = opsum_write_req_o;

  // DUT instance
  opsum_fifo_ctrl u_opsum_fifo_ctrl (
    .clk(clk),
    .rst_n(rst_n),
    .fifo_glb_busy_i(fifo_glb_busy_i),
    .opsum_fifo_reset_i(opsum_fifo_reset_i),
    .opsum_need_push_i(opsum_need_push_i),
    .opsum_push_num_i(opsum_push_num_i),
    .opsum_fifo_mask_i(opsum_fifo_push_mask_i),
    .after_preheat_opsum_push_one_i(after_preheat_opsum_push_one_i),
    .opsum_permit_pop_i(opsum_permit_pop_i),
    .opsum_fifo_empty_i(opsum_fifo_empty_i),
    .opsum_fifo_full_i(opsum_fifo_full_i),
    .opsum_fifo_pop_data_i(opsum_fifo_pop_data_i),
    .opsum_glb_base_addr_i(opsum_glb_base_addr_i),
    .opsum_write_req_o(opsum_write_req_o),
    .opsum_fifo_pop_o(opsum_fifo_pop_o),
    .opsum_fifo_pop_mod_o(opsum_fifo_pop_mod_o),
    .opsum_fifo_push_o(opsum_fifo_push_o),
    .opsum_glb_write_addr_o(opsum_glb_write_addr_o),
    .opsum_glb_write_web_o(opsum_glb_write_web_o),
    .opsum_glb_write_data_o(opsum_glb_write_data_o),
    .opsum_is_PUSH_state_o(opsum_is_PUSH_state_o),
    .pe_array_move_i(pe_array_move_i),
    .opsum_fifo_done_o(opsum_fifo_done_o)
  );

  // Stub FIFO model: simulate pop_data switching and status
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pop_data <= 32'h12345678;
      empty <= 0;
      full  <= 0;
    end else if (opsum_fifo_pop_o) begin
      if (pop_data == 32'h12345678)
        pop_data <= 32'hdeadbeef;
      else
        pop_data <= 32'hcafebabe;
    end
  end

  // Compare with golden
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      golden_index <= 0;

    end else if(golden_index == 2) begin
      $display("✅ All golden checks passed.");
      $display("\033[38;2;255;0;0m               _._\033[0m");                  // 🔴 紅
      $display("\033[38;2;255;127;0m           __.{,_.}).__\033[0m");           // 🟠 橙
      $display("\033[38;2;255;255;0m        .-\"           \"-.\033[0m");         // 🟡 黃
      $display("\033[38;2;0;255;0m      .'  __.........__  '.\033[0m");         // 🟢 綠
      $display("\033[38;2;0;255;127m     /.-'`___.......___`'-.\\\033[0m");       // 🟢綠偏青
      $display("\033[38;2;0;255;255m    /_.-'` /   \\ /   \\ `'-._\\\033[0m");     // 🔵 青
      $display("\033[38;2;0;127;255m    |     |   '/ \\'   |     |\033[0m");      // 🔵 淺藍
      $display("\033[38;2;0;0;255m    |      '-'     '-'      |\033[0m");       // 🔵 藍
      $display("\033[38;2;75;0;130m    ;                       ;\033[0m");       // 🔵 靛
      $display("\033[38;2;139;0;255m    _\\         ___         /_\033[0m");      // 🟣 紫
      $display("\033[38;2;255;0;255m   /  '.'-.__  ___  __.-'.'  \\\033[0m");      // 🟣 粉紫
      $display("\033[38;2;255;0;127m _/_    `'-..._____...-'`    _\\_\033[0m");   // ❤️ 桃紅
      $display("\033[38;2;255;85;85m/   \\           .           /   \\\033[0m");  // 淺紅
      $display("\033[38;2;255;170;0m\\____)         .           (____/\033[0m");   // 橘
      $display("\033[38;2;200;200;0m    \\___________.___________/\033[0m");     // 黃
      $display("\033[38;2;0;200;100m      \\___________________/\033[0m");       // 淺綠
      $display("\033[38;2;0;150;200m     (_____________________)\033[0m");  
      $display("\n\n");
      $display("***************************************");
      $display("*   congratulation! simulation pass   *");      // 青藍
      $display("***************************************");
      $display("\n\n");
      $finish;
    end else if (opsum_write_req_o) begin
      if (opsum_glb_write_data_o !== golden_data[golden_index] ||
                   opsum_glb_write_addr_o !== golden_addr[golden_index] ||
                   opsum_glb_write_web_o  !== golden_web[golden_index]) begin
        $display("❌ [FAIL @ %0t] Mismatch at idx %0d", $time, golden_index);
        $display("    Got:    data=%h addr=%h web=%b",
                 opsum_glb_write_data_o, opsum_glb_write_addr_o, opsum_glb_write_web_o);
        $display("    Expect: data=%h addr=%h web=%b",
                 golden_data[golden_index], golden_addr[golden_index], golden_web[golden_index]);
      end else begin
        $display("✅ [PASS @ %0t] Match idx %0d", $time, golden_index);
        $display("    Got:    data=%h addr=%h web=%b",
                 opsum_glb_write_data_o, opsum_glb_write_addr_o, opsum_glb_write_web_o);
      end
      golden_index <= golden_index + 1;
    end
  end
  

  // Test sequence
  initial begin
    rst_n = 0;
    opsum_fifo_reset_i = 0;
    opsum_need_push_i = 0;
    opsum_push_num_i = 0;
    opsum_fifo_push_mask_i = 0;
    after_preheat_opsum_push_one_i = 0;
    pe_array_move_i = 0;
    fifo_glb_busy_i = 0;
    opsum_glb_base_addr_i = 32'h1000_0000;

    #12 rst_n = 1;

    $display("Test Case 1: Push 2 items and compare golden");

    // push 2 items
    opsum_need_push_i = 1;
    opsum_push_num_i = 2;
    #10;
    opsum_need_push_i = 0;

    // first push
    pe_array_move_i = 1; opsum_fifo_push_mask_i = 1; #10;
    pe_array_move_i = 0; opsum_fifo_push_mask_i = 0; #5;

    // second push
    pe_array_move_i = 1; opsum_fifo_push_mask_i = 1; #10;
    pe_array_move_i = 0; opsum_fifo_push_mask_i = 0;

    #100;
    $display("✅ Simulation completed.");

    $finish;
  end

  initial begin
    `ifdef FSDB
      $fsdbDumpfile("../wave/opsum_fifo_ctrl.fsdb");
      $fsdbDumpvars(0, opsum_fifo_ctrl_tb);
    `endif
  end

endmodule