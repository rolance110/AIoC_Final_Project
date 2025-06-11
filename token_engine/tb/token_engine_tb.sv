// token_engine_tb.sv
`timescale 1ns/1ps

module token_engine_tb;

  parameter ADDR_WIDTH = 14;
  parameter DATA_WIDTH = 32;
  parameter BYTE_CNT_WIDTH = 16;
  parameter FLAG_WIDTH = 3;

  logic clk, rst;
  logic PASS_START;
  logic [1:0] pass_layer_type;
  logic [BYTE_CNT_WIDTH-1:0] pass_tile_n;
  logic [FLAG_WIDTH-1:0] pass_flags;
  logic [ADDR_WIDTH-1:0] BASE_IFMAP, BASE_WEIGHT, BASE_OPSUM, BASE_BIAS;
  logic [ADDR_WIDTH-1:0] glb_read_addr;
  logic glb_read_ready;
  logic glb_read_valid;
  logic [DATA_WIDTH-1:0] glb_read_data;
  logic [ADDR_WIDTH-1:0] glb_write_addr;
  logic [DATA_WIDTH-1:0] glb_write_data;
  logic glb_write_ready;
  logic glb_write_valid;
  logic WEB;
  logic [DATA_WIDTH-1:0] token_data;
  logic pe_weight_valid, pe_ifamp_valid, pe_bias_valid;
  logic pe_weight_ready, pe_ifmap_ready, pe_bias_ready;
  logic [DATA_WIDTH-1:0] pe_psum_data;
  logic pe_psum_valid;
  logic pe_psum_ready;
  logic [6:0] tile_K_o;
  logic [5:0] tile_D;
  logic [5:0] col_en, row_en;
  logic [1:0] compute_num;
  logic change_row;
  logic [6:0] in_C, in_R;
  logic [1:0] stride;
  logic pass_done;

  always #5 clk = ~clk;

  token_engine dut (
    .clk(clk), .rst(rst), .PASS_START(PASS_START), .pass_layer_type(pass_layer_type),
    .pass_tile_n(pass_tile_n), .pass_flags(pass_flags),
    .BASE_IFMAP(BASE_IFMAP), .BASE_WEIGHT(BASE_WEIGHT),
    .BASE_OPSUM(BASE_OPSUM), .BASE_BIAS(BASE_BIAS),
    .glb_read_addr(glb_read_addr), .glb_read_ready(glb_read_ready),
    .glb_read_valid(glb_read_valid), .glb_read_data(glb_read_data),
    .glb_write_addr(glb_write_addr), .glb_write_data(glb_write_data),
    .glb_write_ready(glb_write_ready), .glb_write_valid(glb_write_valid),
    .WEB(WEB), .token_data(token_data), .pe_weight_valid(pe_weight_valid),
    .pe_ifamp_valid(pe_ifamp_valid), .pe_bias_valid(pe_bias_valid),
    .pe_weight_ready(pe_weight_ready), .pe_ifmap_ready(pe_ifmap_ready),
    .pe_bias_ready(pe_bias_ready), .pe_psum_data(pe_psum_data),
    .pe_psum_valid(pe_psum_valid), .pe_psum_ready(pe_psum_ready),
    .tile_K_o(tile_K_o), .tile_D(tile_D), .col_en(col_en), .row_en(row_en),
    .compute_num(compute_num), .change_row(change_row), .in_C(in_C), .in_R(in_R),
    .stride(stride), .pass_done(pass_done)
  );

  logic [DATA_WIDTH-1:0] sram_mem [0:16383];
  logic [ADDR_WIDTH-1:0] sram_addr_d;

  initial begin
    $readmemh("init_sram_data.txt", sram_mem);
    $fsdbDumpfile("token_engine.fsdb");
    $fsdbDumpvars(0, token_engine_tb);
    $fsdbDumpMDA();
  end

  always_ff @(posedge clk) begin
    if (glb_read_ready)
      sram_addr_d <= glb_read_addr;
  end

  assign glb_read_data = sram_mem[sram_addr_d];
  assign glb_read_valid = glb_read_ready;

  always_ff @(posedge clk) begin
    if (glb_write_ready && WEB == 1'b1) begin
      $display("[WRITE] Req Addr=%0d Data=%h", glb_write_addr, glb_write_data);
    end
    if (glb_write_valid && WEB == 1'b0) begin
      sram_mem[glb_write_addr] <= glb_write_data;
      $display("[WRITE CONFIRMED] Addr=%0d Data=%h", glb_write_addr, glb_write_data);
    end
  end

  initial begin
    clk = 0;
    rst = 1;
    PASS_START = 0;
    pe_weight_ready = 1;
    pe_ifmap_ready = 1;
    pe_bias_ready = 1;
    pe_psum_data = 32'hABCD1234;
    pe_psum_valid = 0;
    tile_K_o = 7'd1;
    tile_D = 6'd1;
    in_C = 7'd8;
    in_R = 7'd8;
    stride = 2'd1;

    #20;
    rst = 0;
    #20;

    BASE_IFMAP = 0;
    BASE_WEIGHT = 64;
    BASE_BIAS = 128;
    BASE_OPSUM = 192;
    pass_layer_type = 2'd0; // POINTWISE
    pass_tile_n = 16'd4;
    pass_flags = 3'b111;

    PASS_START = 1;
    #10;
    PASS_START = 0;
  end

  always_ff @(posedge clk) begin
    if (pe_weight_valid)
      $display("[CHECK] Weight Data Sent: %h", token_data);
    if (pe_ifamp_valid)
      $display("[CHECK] Ifmap Data Sent: %h", token_data);
    if (pe_bias_valid)
      $display("[CHECK] Bias Data Sent:   %h", token_data);
    if (pass_done)
      $display("[PASS DONE] at time %t", $time);
  end

endmodule
