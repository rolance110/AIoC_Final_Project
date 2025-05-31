`timescale 1ns/1ps

`include "../src/Tile_Scheduler.sv"


module Tile_Scheduler_tb;

  parameter CYCLE = 10;

  logic clk;
  logic rst_n;

  // DUT I/O
  logic          uLD_en_i;
  logic [6:0]    tile_R_i;
  logic [6:0]    tile_D_i;
  logic [6:0]    tile_K_i;
  logic [6:0]    out_tile_R_i;
  logic [6:0]    num_tiles_R_i;
  logic [6:0]    num_tiles_D_i;
  logic [6:0]    num_tiles_K_i;
  logic [9:0]    in_C_i;
  logic [9:0]    in_D_i;
  logic [9:0]    out_R_i;
  logic [9:0]    out_C_i;
  logic [31:0]   base_ifmap_i;
  logic [31:0]   base_weight_i;
  logic [31:0]   base_bias_i;
  logic [31:0]   base_ofmap_i;
  logic [3:0]    flags_i;

  logic          dma_enable_o;
  logic          dma_read_o;
  logic [31:0]   dma_addr_o;
  logic [31:0]   dma_len_o;
  logic          dma_interrupt_i;

  logic          pass_info_vld_o;
  logic [6:0]    pass_tile_R_o;
  logic [6:0]    pass_tile_D_o;
  logic [6:0]    pass_tile_K_o;
  logic [6:0]    pass_out_tile_R_o;
  logic [6:0]    pass_k_idx_o;
  logic [6:0]    pass_r_idx_o;
  logic [6:0]    pass_d_idx_o;
  logic [3:0]    pass_flags_o;
  logic          pass_done_i;

  // Clock Gen
  always #(CYCLE/2) clk = ~clk;

  // DUT Instance
  Tile_Scheduler dut (
    .clk(clk),
    .rst_n(rst_n),

    .uLD_en_i(uLD_en_i),
    .tile_R_i(tile_R_i),
    .tile_D_i(tile_D_i),
    .tile_K_i(tile_K_i),
    .out_tile_R_i(out_tile_R_i),
    .num_tiles_R_i(num_tiles_R_i),
    .num_tiles_D_i(num_tiles_D_i),
    .num_tiles_K_i(num_tiles_K_i),
    .in_C_i(in_C_i),
    .in_D_i(in_D_i),
    .out_R_i(out_R_i),
    .out_C_i(out_C_i),
    .base_ifmap_i(base_ifmap_i),
    .base_weight_i(base_weight_i),
    .base_bias_i(base_bias_i),
    .base_ofmap_i(base_ofmap_i),
    .flags_i(flags_i),

    .dma_enable_o(dma_enable_o),
    .dma_read_o(dma_read_o),
    .dma_addr_o(dma_addr_o),
    .dma_len_o(dma_len_o),
    .dma_interrupt_i(dma_interrupt_i),

    .pass_info_vld_o(pass_info_vld_o),
    .pass_tile_R_o(pass_tile_R_o),
    .pass_tile_D_o(pass_tile_D_o),
    .pass_tile_K_o(pass_tile_K_o),
    .pass_out_tile_R_o(pass_out_tile_R_o),
    .pass_k_idx_o(pass_k_idx_o),
    .pass_r_idx_o(pass_r_idx_o),
    .pass_d_idx_o(pass_d_idx_o),
    .pass_flags_o(pass_flags_o),
    .pass_done_i(pass_done_i)
  );

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
  
  // Sim control
  
  //=== Stimulus
  initial begin
    $display("Start simulation...");
    clk = 0;
    rst_n = 0;
    dma_interrupt_i = 0;
    pass_done_i = 0;

    // 初始 Layer 設定
    uLD_en_i = 0;
    tile_R_i = 3;
    tile_D_i = 2;
    tile_K_i = 2;
    out_tile_R_i = 3;
    num_tiles_R_i = 2;
    num_tiles_D_i = 2;
    num_tiles_K_i = 2;
    in_C_i = 16;
    in_D_i = 32;
    out_R_i = 6;
    out_C_i = 8;
    base_ifmap_i = 32'h1000_0000;
    base_weight_i = 32'h2000_0000;
    base_bias_i = 32'h3000_0000;
    base_ofmap_i = 32'h4000_0000;
    flags_i = 4'b1000; // bias_en=1

    // Reset
    #(CYCLE*3);
    rst_n = 1;
    #(CYCLE*2);

    // 發出 Layer Descriptor
    uLD_en_i = 1;
    #CYCLE;
    uLD_en_i = 0;
  end

  //=== DMA_done 模擬：針對所有 dma_req 發出後延遲2 cycle 送回 done
  initial begin
    forever begin
      @(posedge clk);
      if (dma_enable_o) begin
        #(CYCLE*2);
        dma_interrupt_i = 1;
        #CYCLE;
        dma_interrupt_i = 0;
      end
    end
  end

  //=== pass_done 模擬：針對所有 pass_info 發出後延遲2 cycle 回應
  initial begin
    forever begin
      @(posedge clk);
      if (pass_info_vld_o) begin
        #(CYCLE*2);
        pass_done_i = 1;
        #CYCLE;
        pass_done_i = 0;
      end
    end
  end

  initial begin
  #100000;
    $display("Finish Simulation.");
    $finish;
  end

endmodule
