`timescale 1ns/1ps

`include "../include/define.svh"
module Tile_Scheduler_tb;

  parameter CYCLE = 10;

  logic clk;
  logic rst_n;
  logic          uLD_en_i;         // Descriptor valid logic [1:0] kH_i; kW_i; // kernel height; width logic [31:0]   tile_n_i;         // todo
  logic [31:0]   tile_D_i;         // input channels per tile
  logic [31:0]   tile_K_i;         // output channels per tile
  logic [31:0]   tile_D_f_i;       // input channels per tile (filter)
  logic [31:0]   tile_K_f_i;       // output channels per tile (filter)
  logic [1:0]    layer_type_i;     // 0=PW; 1=DW; 2=STD; 3=LIN
  logic [1:0]    stride_i;         // stride
  logic [1:0]    pad_T_i; 
  logic [1:0]    pad_B_i; // padding
  logic [1:0]    pad_L_i; 
  logic [1:0]    pad_R_i; // padding
  logic [1:0]    kH_i;           // kernel height
  logic [1:0]    kW_i;           // kernel width
  logic [6:0]    in_R_i;           // ifmap/ofmap height
  logic [9:0]    in_C_i;           // ifmap/ofmap width
  logic [9:0]    in_D_i;           // input channel total
  logic [6:0]    out_R_o;          // ofmap height
  logic [31:0]   tile_n_i;         // tile number
  logic [9:0]    out_K_i;         // ifmap/ofmap height
  logic [6:0]    out_R_i;          // ofmap height
  logic [9:0]    out_C_i;          // ofmap width
  logic [31:0]   base_ifmap_i;
  logic [31:0]   base_weight_i;
  logic [31:0]   base_bias_i;
  logic [31:0]   base_ofmap_i;
 logic [3:0]    flags_i;          // bit3=bias_enDMA Interface ===
 logic          dma_enable_o;
 logic          dma_read_o;   // 1=read DRAM; 0=write DRAM
 logic [31:0]   dma_addr_o;
 logic [31:0]   dma_len_o;
 logic          dma_interrupt_i; // DMA Interrupt
 logic          pass_start_o; // Pass start signal
 logic          pass_done_i;  // Pass done  signal
 logic [31:0]   GLB_weight_base_addr_o;
 logic [31:0]   GLB_ifmap_base_addr_o;
 logic [31:0]   GLB_opsum_base_addr_o; 
 logic [1:0]    pad_T_o; 
 logic [1:0]    pad_B_o; 
 logic [1:0]    pad_L_o;
 logic [1:0]    pad_R_o; // padding
 logic [1:0]    stride_o;
 logic [1:0]    layer_type_o; // 0=PW; 1=DW; 2=STD; 3=LIN
 logic [3:0]    flags_o;       // ReLU / Linear / Residual / Bias logic [6:0]    out_R_o, out_C_o // output size
  logic [6:0]   out_C_o; // output size  
logic         tile_reach_max_o; // tile reach max signal
  // Clock Gen
  always #(CYCLE/2) clk = ~clk;

// DUT Instance
Tile_Scheduler #(
    .BYTES_I(`BYTES_I),
    .BYTES_W(`BYTES_W),
    .BYTES_P(`BYTES_P)
) dut (
    .clk(clk),
    .rst_n(rst_n),

    .uLD_en_i(uLD_en_i),
    .kH_i(kH_i),
    .kW_i(kW_i),

    .tile_n_i(tile_n_i),
    .tile_D_i(tile_D_i),
    .tile_K_i(tile_K_i),
    .tile_D_f_i(tile_D_f_i),
    .tile_K_f_i(tile_K_f_i),

    .layer_type_i(layer_type_i),
    .stride_i(stride_i),

    .pad_T_i(pad_T_i),
    .pad_B_i(pad_B_i),
    .pad_L_i(pad_L_i),
    .pad_R_i(pad_R_i),

    .in_R_i(in_R_i),
    .in_C_i(in_C_i),
    .in_D_i(in_D_i),

    .out_K_i(out_K_i),
    .out_R_i(out_R_i),
    .out_C_i(out_C_i),

    .base_ifmap_i(base_ifmap_i),
    .base_weight_i(base_weight_i),
    .base_bias_i(base_bias_i),
    .base_ofmap_i(base_ofmap_i),
    .flags_i(flags_i),

    // DMA Interface
    .dma_enable_o(dma_enable_o), 
    .dma_read_o(dma_read_o), 
    .dma_addr_o(dma_addr_o), 
    .dma_len_o(dma_len_o), 
    .dma_interrupt_i(dma_interrupt_i), 

    // Pass Interface
    .pass_start_o(pass_start_o), 
    .pass_done_i(pass_done_i), 

   // GLB Interface
   .GLB_weight_base_addr_o(GLB_weight_base_addr_o), 
   .GLB_ifmap_base_addr_o(GLB_ifmap_base_addr_o), 
   .GLB_opsum_base_addr_o(GLB_opsum_base_addr_o), 

   .pad_T_o(pad_T_o), 
   .pad_B_o(pad_B_o), 
   .pad_L_o(pad_L_o), 
   .pad_R_o(pad_R_o), 
   // Stride
   .stride_o(stride_o), 
   // Layer type
   .layer_type_o(layer_type_o), 
   // Flags
   .flags_o(flags_o), 
   // Output size
   .out_R_o(out_R_o), 
   .out_C_o(out_C_o),
   .tile_reach_max_o(tile_reach_max_o)
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
//=== Test Procedure ===
    initial begin
        // Initialize signals
        $display("Initializing signals...");
        clk = 0;
        rst_n = 0;
        uLD_en_i = 0;
        kH_i = 0;
        kW_i = 0;
        tile_n_i = 0;
        tile_D_i = 0;
        tile_K_i = 0;
        tile_D_f_i = 0;
        tile_K_f_i = 0;
        layer_type_i = 0;
        stride_i = 0;
        pad_T_i = 0;
        pad_B_i = 0;
        pad_L_i = 0;
        pad_R_i = 0;
        in_R_i = 0;
        in_C_i = 0;
        in_D_i = 0;
        out_K_i = 0;
        out_R_i = 0;
        out_C_i = 0;
        base_ifmap_i = 0;
        base_weight_i = 0;
        base_bias_i = 0;
        base_ofmap_i = 0;
        flags_i = 0;
        dma_interrupt_i = 0;
        pass_done_i = 0;

        // Reset
        #20 rst_n = 1;

        // Test Case 1: Pointwise Convolution
        $display("Starting Test Case 1: Pointwise Convolution");
        @(posedge clk);
        uLD_en_i = 1;
        layer_type_i = `POINTWISE; // 0 = PW
        tile_n_i = 28;
        tile_D_i = 32;
        tile_K_i = 32;
        tile_D_f_i = 32;
        tile_K_f_i = 32;
        kH_i = 1;
        kW_i = 1;
        stride_i = 1;
        pad_T_i = 0;
        pad_B_i = 0;
        pad_L_i = 0;
        pad_R_i = 0;
        in_R_i = 12;
        in_C_i = 12;
        in_D_i = 80;
        out_K_i = 100;
        out_R_i = 12;
        out_C_i = 12;
        base_ifmap_i = 32'h1000_0000;
        base_weight_i = 32'h2000_0000;
        base_bias_i = 32'h3000_0000;
        base_ofmap_i = 32'h4000_0000;
        flags_i = 4'b1000; // Bias enabled
        @(posedge clk);
        uLD_en_i = 0;
        wait(tile_reach_max_o);
        uLD_en_i = 0;
        #30
        
        $display("Starting Test Case 2: Standard Convolution");
        @(posedge clk);
        uLD_en_i = 1;
        layer_type_i = `DEPTHWISE; // 2 = STD
        tile_n_i = 5;
        tile_D_i = 10;
        tile_K_i = 10;
        tile_D_f_i = 1;
        tile_K_f_i = 10;
        kH_i = 3;
        kW_i = 3;
        stride_i = 2;
        pad_T_i = 1;
        pad_B_i = 1;
        pad_L_i = 1;
        pad_R_i = 1;
        in_R_i = 56;
        in_C_i = 56;
        in_D_i = 32;
        out_K_i = 32;
        out_R_i = 28;
        out_C_i = 28;
        base_ifmap_i = 32'h5000_0000;
        base_weight_i = 32'h6000_0000;
        base_bias_i = 32'h7000_0000;
        base_ofmap_i = 32'h8000_0000;
        flags_i = 4'b1000; // Bias enabled
        @(posedge clk);
        uLD_en_i = 0;

        wait(tile_reach_max_o);
        $finish;
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
      if (pass_start_o) begin
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
