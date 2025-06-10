`timescale 1ns/1ps
`define ROW_NUM 32
`define COL_NUM 32
`define CYCLE    10            // 10 ns = 100 MHz

//我現在要完成的是整個CONV_uint的tb
module tb_dw_conv_uint;

  // ──────────────────────────────────────────────
  //  ▍ DUT 連接埠
  // ──────────────────────────────────────────────
  logic                    clk , reset;
  logic                    ready_w , valid_w;
  logic                    ready_if , valid_if;
  logic                    ready_ip , valid_ip;
  logic                    valid_op , ready_op;
  logic                    DW_PW_sel;
  logic                    change_weight_f;
  logic  [31:0]            data_in;
  logic  [31:0]            data_out;
  logic  [5:0]             col_en;
  logic  [5:0]             row_en;
  logic  [1:0]             dw_input_num;
  logic                    dw_row_end;  
  logic                    dw_stride;
  // ──────────────────────────────────────────────
  //  ▍ 例化 DUT
  // ──────────────────────────────────────────────
    conv_unit dut(
    .clk            (clk),
    .reset          (reset),

    .ready_w        (ready_w),
    .valid_w        (valid_w),

    .ready_if       (ready_if),
    .valid_if       (valid_if),

    .ready_ip       (ready_ip),
    .valid_ip       (valid_ip),

    .valid_op       (valid_op),
    .ready_op       (ready_op),

    .DW_PW_sel      (DW_PW_sel),
    .change_weight_f(change_weight_f),
    .dw_input_num   (dw_input_num),
    .dw_row_end     (dw_row_end),
    .dw_stride      (dw_stride),

    .data_in        (data_in),
    .data_out       (data_out),
    .col_en         (col_en),
    .row_en         (row_en)
  );
  // ──────────────────────────────────────────────
  //  ▍ 時脈
  // ──────────────────────────────────────────────
    initial clk = 0;
    always #(`CYCLE/2) clk = ~clk;

    initial begin
        $fsdbDumpfile("dw_conv.fsdb");
        $fsdbDumpvars(0, tb_dw_conv_uint, "+all");
        $fsdbDumpMDA;
    end

    initial begin
        reset = 1;
        valid_w = 0;
        valid_if = 0;
        valid_ip = 0;
        ready_op = 0;
        DW_PW_sel = 1; // 假設使用PW模式
        change_weight_f = 0; // 假設不改變權重
        data_in = 32'h00000000; // 初始數據輸入

        dw_stride = 0; // 假設使用stride 1
        dw_input_num = 2'b11; // 假設使用兩個輸入
        dw_row_end = 0; // 假設不是行結束

        col_en = 6'b100000; // 使用所有列
        row_en = 6'b100000; // 使用所有行

        #(`CYCLE*2);
        reset = 0; // 解除復位

        #(`CYCLE * 2); // 等待一段時間以觀察行為
        change_weight_f = 1; // 假設不改變權重
        valid_w = 1;

        #(`CYCLE); // 等待一個時鐘週期
        data_in = 32'h00123456;

        #(`CYCLE * 32); // 等待一個時鐘週期
        change_weight_f = 0; // 假設不改變權重
        valid_w = 0; // 停止寫入數據
        

        valid_if = 1; // 開始IF模式
        #(`CYCLE); // 等待一段時間以觀察行為
        data_in = 32'h00203040;

        #(`CYCLE * 3); // 等待一個時鐘週期
        valid_if = 0; // 停止IF模式

        #(`CYCLE * 1); // 等待一段時間以觀察行為
        valid_if = 1; // 再次開始IF模式
        #(`CYCLE); // 等待一個時鐘週期
        data_in = 32'h00112233;
        #(`CYCLE * 6); // 等待一個時鐘週期
        valid_if = 0; // 停止IF模式

        #(`CYCLE * 1); // 等待一段時間以觀察行為
        valid_if = 1; // 再次開始IF模式
        #(`CYCLE); // 等待一個時鐘週期
        data_in = 32'h00203040;
        #(`CYCLE * 9); // 等待一個時鐘週期
        valid_if = 0; // 停止IF模式

        #(`CYCLE * 1); // 等待一段時間以觀察行為
        valid_if = 1; // 再次開始IF模式
        #(`CYCLE); // 等待一個時鐘週期
        data_in = 32'h00112233;
        #(`CYCLE * 12); // 等待一個時鐘週期
        valid_if = 0; // 停止IF模式

        #(`CYCLE * 1); // 等待一段時間以觀察行為
        valid_if = 1; // 再次開始IF模式
        #(`CYCLE); // 等待一個時鐘週期
        data_in = 32'h00203040;
        #(`CYCLE * 15); // 等待一個時鐘週期
        valid_if = 0; // 停止IF模式

        #(`CYCLE * 1); // 等待一段時間以觀察行為
        valid_if = 1; // 再次開始IF模式
        #(`CYCLE); // 等待一個時鐘週期
        data_in = 32'h00112233;
        #(`CYCLE * 18); // 等待一個時鐘週期
        valid_if = 0; // 停止IF模式

        #(`CYCLE * 1); // 等待一段時間以觀察行為
        valid_if = 1; // 再次開始IF模式
        #(`CYCLE); // 等待一個時鐘週期
        data_in = 32'h00203040;
        #(`CYCLE * 21); // 等待一個時鐘週期
        valid_if = 0; // 停止IF模式

        #(`CYCLE * 1); // 等待一段時間以觀察行為
        valid_if = 1; // 再次開始IF模式
        #(`CYCLE); // 等待一個時鐘週期
        data_in = 32'h00112233;
        #(`CYCLE * 24); // 等待一個時鐘週期
        valid_if = 0; // 停止IF模式

        #(`CYCLE * 1); // 等待一段時間以觀察行為
        valid_if = 1; // 再次開始IF模式
        #(`CYCLE); // 等待一個時鐘週期
        data_in = 32'h00203040;
        #(`CYCLE * 27); // 等待一個時鐘週期
        valid_if = 0; // 停止IF模式

        #(`CYCLE * 1); // 等待一段時間以觀察行為
        valid_if = 1; // 再次開始IF模式
        #(`CYCLE); // 等待一個時鐘週期
        data_in = 32'h00112233;
        #(`CYCLE * 30); // 等待一個時鐘週期
        valid_if = 0; // 停止IF模式

        valid_ip = 1; // 開始IP模式
        #(`CYCLE); // 等待一個時鐘週期
        data_in = 32'h00001111; // 假設輸入數據
        #(`CYCLE * 60); // 等待一段時間以觀察行為
        valid_ip = 0; // 停止IP模式
        ready_op = 1; // 開始OP模式
        #(`CYCLE * 60); // 等待一個時鐘週期
        ready_op = 0; // 停止OP模式
        #(`CYCLE * 30); // 等待一個時鐘週期

        $finish; // 結束模

    end

endmodule
