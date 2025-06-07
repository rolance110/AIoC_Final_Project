`timescale 1ns/1ps
`define ROW_NUM 32
`define CYCLE    10            // 10 ns = 100 MHz

module tb_Ipsum_buffer;

  // ──────────────────────────────────────────────
  //  ▍ DUT 連接埠
  // ──────────────────────────────────────────────
  logic                    clk , reset ;
  logic                    ready_ip , valid_ip ;
  logic  [5:0]             ip_time_4 ;
  logic                    first_f ;
  logic  [4:0]             close_start_num ;
  logic                    close_f ;
  logic  [5:0]             row_en ;
  logic  [`ROW_NUM-1:0]    ipsum_in ;
  logic                    ipsum_out_f ;
  logic  [`ROW_NUM*16-1:0] ipsum_out ;

  // ──────────────────────────────────────────────
  //  ▍ 例化 DUT
  // ──────────────────────────────────────────────
  Ipsum_buffer dut (
    .clk            (clk),
    .reset          (reset),
    .ready_ip       (ready_ip),
    .valid_ip       (valid_ip),
    .ip_time_4      (ip_time_4),
    .first_f        (first_f),
    .close_start_num(close_start_num),
    .close_f        (close_f),
    .row_en         (row_en),
    .ipsum_in       (ipsum_in),
    .ipsum_out_f    (ipsum_out_f),
    .ipsum_out      (ipsum_out)
  );

  // ──────────────────────────────────────────────
  //  ▍ 時脈
  // ──────────────────────────────────────────────
  initial clk = 0;
  always #(`CYCLE/2) clk = ~clk;

  initial begin
    $fsdbDumpfile("ipsum.fsdb");
    $fsdbDumpvars(0, tb_Ipsum_buffer, "+all");
    $fsdbDumpMDA;
  end

  initial begin
    reset = 1;
    ready_ip = 0;
    valid_ip = 0;
    ip_time_4 = 6'd8; // 假設前8個cycle
    first_f = 1;
    close_start_num = 5'd0;
    close_f = 0;
    row_en = 6'b100000; // 使用所有ROW
    ipsum_in = 32'h12345678; // 假設輸入數據
    ipsum_out_f = 0;

    #(`CYCLE * 2);
    reset = 0;

    // 模擬 handshake
    #(`CYCLE);
    ready_ip = 1;
    valid_ip = 1;

    #(`CYCLE * 16); // 等待一些時間

    // 停止 handshake
    ready_ip = 0;
    valid_ip = 0;
    ipsum_out_f = 1; // 開始輸出FIFO內容

    #(`CYCLE * 20); // 等待一些時間

    // 假設關閉PE array
    ipsum_out_f = 0; // 開始輸出FIFO內容
    close_f = 1;
    ready_ip = 1;
    valid_ip = 1;
    close_start_num = 5'd4; // 假設從第4個ROW開始關閉
    #(`CYCLE * 8); // 等待一些時間

    // 停止關閉PE array
    ready_ip = 0;
    valid_ip = 0;
    ipsum_out_f = 1; // 開始輸出FIFO內容
    #(`CYCLE * 10); // 等待一些時間


    $finish;
  end

endmodule
