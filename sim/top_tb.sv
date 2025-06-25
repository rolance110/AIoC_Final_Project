
`define CYCLE 1.0 // Cycle time
`define CYCLE2 10.0 // Cycle time for WDT
`define MAX 6000000 // Max cycle number
`include "../include/define.svh"
// `timescale 1ns/10ps
// `include "top.sv"


`define mem_word(addr) \
  {top.DM1.i_SRAM.MEMORY[addr >> 5][(addr&6'b011111)]}
`define dram_word(addr) \
  {i_DRAM.Memory_byte3[addr], \
   i_DRAM.Memory_byte2[addr], \
   i_DRAM.Memory_byte1[addr], \
   i_DRAM.Memory_byte0[addr]}
`define SIM_END 'h3fff
`define SIM_END_CODE -32'd1
`define TEST_START 'h40000
module top_tb;

  logic clk;
  logic clk2;
  logic rst_n;
  logic rst2;
  logic [31:0] GOLDEN[4096];
  logic [7:0] Memory_byte0[16383:0];
  logic [7:0] Memory_byte1[16383:0];
  logic [7:0] Memory_byte2[16383:0];
  logic [7:0] Memory_byte3[16383:0];
  logic [31:0] Memory_word[16383:0];

  integer gf, i, num;
  logic [31:0] temp;
  integer err;
  string prog_path;
  always #(`CYCLE/2) clk = ~clk;
  always #(`CYCLE2/2) clk2 = ~clk2;
 

 //================ top signal=======================//
logic DRAM_CSn;      //DRAM chip select
logic [3:0] DRAM_WEn; //write enable
logic DRAM_RASn;     //row access strobe
logic DRAM_CASn;     //column access strobe
logic [10:0]DRAM_A;  //DRAM address .    
logic [31:0]DRAM_D;  //DRAM data .    
logic [31:0] DRAM_Q;    //DRAM data 
logic DRAM_valid;
logic uLD_en_i; // uLD enable signal
logic [5:0]   layer_id_i;
logic [1:0]   layer_type_i;     // 0=PW,1=DW,2=STD,3=LIN
logic  [7:0]   in_R_i, in_C_i;   // input H,W
logic  [10:0]   in_D_i, out_K_i;  // input/out channels
logic  [1:0]   stride_i;         // stride
logic  [1:0]   pad_T_i, pad_B_i, pad_L_i, pad_R_i;
logic  [31:0]  base_ifmap_i;
logic  [31:0]  base_weight_i;
logic  [31:0]  base_bias_i;
logic  [31:0]  base_ofmap_i; // ipsum base same as ofmap
logic  [3:0]   flags_i;         // bit0=relu, 1=linear, 2=skip,3=bias
logic  [7:0]   quant_scale_i;




logic pass_done_o;

top top (
    .clk(clk),
    .rst_n(rst_n),
	//DRAM
    // .DRAM_CSn(DRAM_CSn),      //DRAM chip select
    // .DRAM_WEn(DRAM_WEn), //write enable
    // .DRAM_RASn(DRAM_RASn),     //row access strobe
    // .DRAM_CASn(DRAM_CASn),     //column access strobe
    // .DRAM_A(DRAM_A),  //DRAM address .    
	  // .DRAM_D(DRAM_D),  //DRAM data .    
	  // .DRAM_Q(DRAM_Q),    //DRAM data 
	  // .DRAM_valid(DRAM_valid),
    .uLD_en_i(uLD_en_i), // uLD enable signal
    .layer_id_i(layer_id_i),
    .layer_type_i(layer_type_i),     // 0=PW,1=DW,2=STD,3=LIN

    .in_R_i(in_R_i), 
    .in_C_i(in_C_i),   // input H,W
    .in_D_i(in_D_i), 
    .out_K_i(out_K_i),  // input/out channels

    .stride_i(stride_i),         // stride
    .pad_T_i(pad_T_i), 
    .pad_B_i(pad_B_i), 
    .pad_L_i(pad_L_i), 
    .pad_R_i(pad_R_i),

    .base_ifmap_i(base_ifmap_i),
    .base_weight_i(base_weight_i),
    .base_bias_i(base_bias_i),
    .base_ofmap_i(base_ofmap_i), // ipsum base same as ofmap

    .flags_i(flags_i),         // bit0=relu, 1=linear, 2=skip,3=bias
    .quant_scale_i(quant_scale_i),
    .pass_done_o(pass_done_o)
);

  //  DRAM i_DRAM(
  //   .CK   (clk        ),
  //   .Q    (DRAM_Q     ),
  //   .RST  (!rst_n        ),
  //   .CSn  (DRAM_CSn   ),
  //   .WEn  (DRAM_WEn   ),
  //   .RASn (DRAM_RASn  ),
  //   .CASn (DRAM_CASn  ),
  //   .A    (DRAM_A     ),
  //   .D    (DRAM_D     ),
  //   .VALID(DRAM_valid )
  // );

// "/home/local_users/1137n/AXI_test/DAGGER_sorry/sim/prog0/dram3.hex"

  initial
  begin
    // $value$plusargs("prog_path=%s", prog_path);
    clk = 0; rst_n = 1; 
    #(`CYCLE+`CYCLE2) rst_n = 0;
    // $readmemh({prog_path, "/rom0.hex"}, i_ROM.Memory_byte0);
    // $readmemh({prog_path, "/rom1.hex"}, i_ROM.Memory_byte1);
    // $readmemh({prog_path, "/rom2.hex"}, i_ROM.Memory_byte2);
    // $readmemh({prog_path, "/rom3.hex"}, i_ROM.Memory_byte3);
    // $readmemh({"/home/local_users/1137n/AXI_test/DAGGER_sorry/sim/prog0/dram0.hex"}, i_DRAM.Memory_byte0);
    // $readmemh({"/home/local_users/1137n/AXI_test/DAGGER_sorry/sim/prog0/dram1.hex"}, i_DRAM.Memory_byte1);
    // $readmemh({"/home/local_users/1137n/AXI_test/DAGGER_sorry/sim/prog0/dram2.hex"}, i_DRAM.Memory_byte2);
    // $readmemh({"/home/local_users/1137n/AXI_test/DAGGER_sorry/sim/prog0/dram3.hex"}, i_DRAM.Memory_byte3);
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
        // out_R_i = 0;
        // out_C_i = 0;
        base_ifmap_i = 0;
        base_weight_i = 0;
        base_bias_i = 0;
        base_ofmap_i = 0;
        flags_i = 0;
        // pass_done_i = 0;

        // Reset
        #20 rst_n = 1;

        // Test Case 1: Pointwise Convolution
        $display("Starting Test Case 1: Pointwise Convolution");
        @(posedge clk);
        uLD_en_i = 1;
        layer_type_i = `POINTWISE; // 0 = PW
        stride_i = 1;
        pad_T_i = 0;
        pad_B_i = 0;
        pad_L_i = 0;
        pad_R_i = 0;
        in_R_i = 12; // input total pixel 144
        in_C_i = 12;
        in_D_i = 64; // input channel total
        out_K_i = 32; // output channel total
        // out_R_i = 12; // output total pixel 144
        // out_C_i = 12;
        base_ifmap_i = 32'h2000_1C40;
        base_weight_i = 32'h2000_0000;
        base_bias_i = 32'h2002_2680;
        base_ofmap_i = 32'h4000_0000;
        flags_i = 4'b1000; // Bias enabled
        @(posedge clk);
        uLD_en_i = 0;
        // wait(pass_done_o);
        wait(top.DSC.u_DLA_Controller.dut_TS.tile_reach_max_o == 1'b1);
        #30
        


        
        $display("Starting Test Case 2: Standard Convolution");
        @(posedge clk);
        uLD_en_i = 1;
        layer_type_i = `DEPTHWISE; // 2 = STD
        stride_i = 2;
        pad_T_i = 1;
        pad_B_i = 1;
        pad_L_i = 1;
        pad_R_i = 1;
        in_R_i = 56;
        in_C_i = 56;
        in_D_i = 32;
        out_K_i = 32;
        // out_R_i = 28;
        // out_C_i = 28;
        base_ifmap_i = 32'h5000_0000;
        base_weight_i = 32'h6000_0000;
        base_bias_i = 32'h7000_0000;
        base_ofmap_i = 32'h8000_0000;
        flags_i = 4'b1000; // Bias enabled
        @(posedge clk);
        uLD_en_i = 0;

        // wait(tile_reach_max_o);
        $finish;
    end


initial begin
    #(`CYCLE*`MAX)
    $display("Simulation timeout, terminating...");
    $finish;
end



  `ifdef SYN
  initial $sdf_annotate("../syn/top_syn.sdf", top);
  `elsif PR
  initial $sdf_annotate("../syn/top_pr.sdf", top);
  `endif

  initial
  begin
    `ifdef FSDB
    $fsdbDumpfile("../wave/top.fsdb");
    $fsdbDumpvars;
    `elsif FSDB_ALL
    $fsdbDumpfile("../wave/top.fsdb");
    $fsdbDumpvars("+struct", "+mda", top);
    // $fsdbDumpvars("+struct", i_DRAM);

    `endif

  end


  task result;
    input integer err;
    input integer num;
    integer rf;
    begin
      `ifdef SYN
        rf = $fopen({prog_path, "/result_syn.txt"}, "w");
        `elsif PR
        rf = $fopen({prog_path, "/result_pr.txt"}, "w");
      `else
        rf = $fopen({prog_path, "/result_rtl.txt"}, "w");
      `endif
      $fdisplay(rf, "%d,%d", num - err, num);
      if (err === 0)
      begin
        $display("\n");
        $display("\n");
        $display("        ****************************               ");
        $display("        **                        **       |\__||  ");
        $display("        **  Congratulations !!    **      / O.O  | ");
        $display("        **                        **    /_____   | ");
        $display("        **  Simulation PASS!!     **   /^ ^ ^ \\  |");
        $display("        **                        **  |^ ^ ^ ^ |w| ");
        $display("        ****************************   \\m___m__|_|");
        $display("\n");
      end
      else
      begin
        $display("\n");
        $display("\n");
        $display("        ****************************               ");
        $display("        **                        **       |\__||  ");
        $display("        **  OOPS!!                **      / X,X  | ");
        $display("        **                        **    /_____   | ");
        $display("        **  Simulation Failed!!   **   /^ ^ ^ \\  |");
        $display("        **                        **  |^ ^ ^ ^ |w| ");
        $display("        ****************************   \\m___m__|_|");
        $display("         Totally has %d errors                     ", err); 
        $display("\n");
      end
    end
  endtask

endmodule
