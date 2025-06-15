`timescale 1ns/1ps
`define ROW_NUM 32
`define COL_NUM 32
`define CYCLE    10            // 10 ns = 100 MHz

//我現在要完成的是整個CONV_uint的tb
module tb_Conv_uint;

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

    .data_in        (data_in),
    .data_out       (data_out),

    .ready_w        (ready_w),
    .valid_w        (valid_w),

    .ready_if       (ready_if),
    .valid_if       (valid_if),

    .ready_ip       (ready_ip),
    .valid_ip       (valid_ip),

    .valid_op       (valid_op),
    .ready_op       (ready_op),

    .dw_input_num   (dw_input_num),
    .dw_row_end     (dw_row_end),
    .dw_stride      (dw_stride),

    .DW_PW_sel      (DW_PW_sel),
    .col_en         (col_en),
    .row_en         (row_en)
  );
  // ──────────────────────────────────────────────
  //  ▍ 時脈
  // ──────────────────────────────────────────────
    initial clk = 0;
    always #(`CYCLE/2) clk = ~clk;

    initial begin
        $fsdbDumpfile("conv_uint.fsdb");
        $fsdbDumpvars(0, tb_Conv_uint, "+all");
        $fsdbDumpMDA;
    end

    initial begin
        reset = 1;
        valid_w = 0;
        valid_if = 0;
        valid_ip = 0;
        ready_op = 0;
        DW_PW_sel = 1; // 假設使用PW模式
        data_in = 32'h00000000; // 初始數據輸入

        col_en = 6'b100000; // 使用所有列
        row_en = 6'b100000; // 使用所有行

        #(`CYCLE*2);
        reset = 0; // 解除復位


        #(`CYCLE * 2); // 等待一段時間以觀察行為
        valid_w = 1;

        #(`CYCLE); // 等待一個時鐘週期
        data_in = 32'h01234567;

        #(`CYCLE * 256); // 等待一個時鐘週期
        valid_w = 0; // 停止寫入數據

        valid_if = 1; // 開始IF模式
        #(`CYCLE); // 等待一段時間以觀察行為
        data_in = 32'h10203040;

        #(`CYCLE * 32); // 等待一段時間以觀察行為
        valid_if = 0; // 停止IF模式
        valid_ip = 1; // 開始IP模式
        #(`CYCLE); // 等待一個時鐘週期

        data_in = 32'h00110011;
        #(`CYCLE * 8); // 等待一段時間以觀察行為
        valid_ip = 0; // 停止IP模式

        ready_op = 1; // 開始OP模式
        #(`CYCLE * 12); // 等待一個時鐘週期
        ready_op = 0; // 停止OP模式
        
        #(`CYCLE * 30); // 等待一個時鐘週期


        valid_if = 1; // 開始IF模式
        #(`CYCLE); // 等待一段時間以觀察行為
        data_in = 32'h10203040;

        #(`CYCLE * 32); // 等待一段時間以觀察行為
        valid_if = 0; // 停止IF模式

        valid_ip = 1; // 開始IP模式
        #(`CYCLE); // 等待一個時鐘週期

        data_in = 32'h00110011;
        #(`CYCLE * 16); // 等待一段時間以觀察行為
        valid_ip = 0; // 停止IP模式

        ready_op = 1; // 開始OP模式
        #(`CYCLE * 20); // 等待一個時鐘週期
        ready_op = 0; // 停止OP模式

        
        #(`CYCLE * 30); // 等待一個時鐘週期

        //3
        valid_if = 1; // 開始IF模式
        #(`CYCLE); // 等待一段時間以觀察行為
        data_in = 32'h10203040;

        #(`CYCLE * 32); // 等待一段時間以觀察行為
        valid_if = 0; // 停止IF模式

        valid_ip = 1; // 開始IP模式
        #(`CYCLE); // 等待一個時鐘週期

        data_in = 32'h00110011;
        #(`CYCLE * 24); // 等待一段時間以觀察行為
        valid_ip = 0; // 停止IP模式

        ready_op = 1; // 開始OP模式
        #(`CYCLE * 28); // 等待一個時鐘週期
        ready_op = 0; // 停止OP模式

        
        #(`CYCLE * 30); // 等待一個時鐘週期

        //4
        valid_if = 1; // 開始IF模式
        #(`CYCLE); // 等待一段時間以觀察行為
        data_in = 32'h10203040;

        #(`CYCLE * 32); // 等待一段時間以觀察行為
        valid_if = 0; // 停止IF模式

        valid_ip = 1; // 開始IP模式
        #(`CYCLE); // 等待一個時鐘週期

        data_in = 32'h00110011;
        #(`CYCLE * 32); // 等待一段時間以觀察行為
        valid_ip = 0; // 停止IP模式

        ready_op = 1; // 開始OP模式
        #(`CYCLE * 36); // 等待一個時鐘週期
        ready_op = 0; // 停止OP模式

        
        #(`CYCLE * 30); // 等待一個時鐘週期

        //3
        valid_if = 1; // 開始IF模式
        #(`CYCLE); // 等待一段時間以觀察行為
        data_in = 32'h10203040;

        #(`CYCLE * 32); // 等待一段時間以觀察行為
        valid_if = 0; // 停止IF模式

        valid_ip = 1; // 開始IP模式
        #(`CYCLE); // 等待一個時鐘週期

        data_in = 32'h00110011;
        #(`CYCLE * 40); // 等待一段時間以觀察行為
        valid_ip = 0; // 停止IP模式

        ready_op = 1; // 開始OP模式
        #(`CYCLE * 44); // 等待一個時鐘週期
        ready_op = 0; // 停止OP模式

        
        #(`CYCLE * 30); // 等待一個時鐘週期

        //3
        valid_if = 1; // 開始IF模式
        #(`CYCLE); // 等待一段時間以觀察行為
        data_in = 32'h10203040;

        #(`CYCLE * 32); // 等待一段時間以觀察行為
        valid_if = 0; // 停止IF模式

        valid_ip = 1; // 開始IP模式
        #(`CYCLE); // 等待一個時鐘週期

        data_in = 32'h00110011;
        #(`CYCLE * 48); // 等待一段時間以觀察行為
        valid_ip = 0; // 停止IP模式

        ready_op = 1; // 開始OP模式
        #(`CYCLE * 52); // 等待一個時鐘週期
        ready_op = 0; // 停止OP模式

        
        #(`CYCLE * 30); // 等待一個時鐘週期

        //3
        valid_if = 1; // 開始IF模式
        #(`CYCLE); // 等待一段時間以觀察行為
        data_in = 32'h10203040;

        #(`CYCLE * 32); // 等待一段時間以觀察行為
        valid_if = 0; // 停止IF模式

        valid_ip = 1; // 開始IP模式
        #(`CYCLE); // 等待一個時鐘週期

        data_in = 32'h00110011;
        #(`CYCLE * 56); // 等待一段時間以觀察行為
        valid_ip = 0; // 停止IP模式

        ready_op = 1; // 開始OP模式
        #(`CYCLE * 60); // 等待一個時鐘週期
        ready_op = 0; // 停止OP模式

        
        #(`CYCLE * 30); // 等待一個時鐘週期

        //3
        valid_if = 1; // 開始IF模式
        #(`CYCLE); // 等待一段時間以觀察行為
        data_in = 32'h10203040;

        #(`CYCLE * 32); // 等待一段時間以觀察行為
        valid_if = 0; // 停止IF模式

        valid_ip = 1; // 開始IP模式
        #(`CYCLE); // 等待一個時鐘週期

        data_in = 32'h00110011;
        #(`CYCLE * 64); // 等待一段時間以觀察行為
        valid_ip = 0; // 停止IP模式

        ready_op = 1; // 開始OP模式
        #(`CYCLE * 68); // 等待一個時鐘週期
        ready_op = 0; // 停止OP模式

        
        #(`CYCLE * 30); // 等待一個時鐘週期

        //3
        valid_if = 1; // 開始IF模式
        #(`CYCLE); // 等待一段時間以觀察行為
        data_in = 32'h10203040;

        #(`CYCLE * 32); // 等待一段時間以觀察行為
        valid_if = 0; // 停止IF模式

        valid_ip = 1; // 開始IP模式
        #(`CYCLE); // 等待一個時鐘週期

        data_in = 32'h00110011;
        #(`CYCLE * 64); // 等待一段時間以觀察行為
        valid_ip = 0; // 停止IP模式

        ready_op = 1; // 開始OP模式
        #(`CYCLE * 68); // 等待一個時鐘週期
        ready_op = 0; // 停止OP模式

        #(`CYCLE * 30); // 等待一個時鐘週期

//TODO: 開始做關閉 close_f拉起來
        valid_ip = 1; // 開始IP模式
        #(`CYCLE); // 等待一個時鐘週期

        data_in = 32'h00110011;
        #(`CYCLE * 64); // 等待一段時間以觀察行為
        valid_ip = 0; // 停止IP模式

        ready_op = 1; // 開始OP模式
        #(`CYCLE * 68); // 等待一個時鐘週期
        ready_op = 0; // 停止OP模式

        #(`CYCLE * 30); // 等待一個時鐘週期

        //3
        valid_ip = 1; // 開始IP模式
        #(`CYCLE); // 等待一個時鐘週期

        data_in = 32'h00110011;
        #(`CYCLE * 56); // 等待一段時間以觀察行為
        valid_ip = 0; // 停止IP模式

        ready_op = 1; // 開始OP模式
        #(`CYCLE * 60); // 等待一個時鐘週期
        ready_op = 0; // 停止OP模式

        #(`CYCLE * 30); // 等待一個時鐘週期

        //3
        valid_ip = 1; // 開始IP模式
        #(`CYCLE); // 等待一個時鐘週期

        data_in = 32'h00110011;
        #(`CYCLE * 48); // 等待一段時間以觀察行為
        valid_ip = 0; // 停止IP模式

        ready_op = 1; // 開始OP模式
        #(`CYCLE * 52); // 等待一個時鐘週期
        ready_op = 0; // 停止OP模式

        #(`CYCLE * 30); // 等待一個時鐘週期

        //3
        valid_ip = 1; // 開始IP模式
        #(`CYCLE); // 等待一個時鐘週期

        data_in = 32'h00110011;
        #(`CYCLE * 40); // 等待一段時間以觀察行為
        valid_ip = 0; // 停止IP模式

        ready_op = 1; // 開始OP模式
        #(`CYCLE * 44); // 等待一個時鐘週期
        ready_op = 0; // 停止OP模式

        #(`CYCLE * 30); // 等待一個時鐘週期

        //3
        valid_ip = 1; // 開始IP模式
        #(`CYCLE); // 等待一個時鐘週期

        data_in = 32'h00110011;
        #(`CYCLE * 32); // 等待一段時間以觀察行為
        valid_ip = 0; // 停止IP模式

        ready_op = 1; // 開始OP模式
        #(`CYCLE * 36); // 等待一個時鐘週期
        ready_op = 0; // 停止OP模式

        #(`CYCLE * 30); // 等待一個時鐘週期

        //3
        valid_ip = 1; // 開始IP模式
        #(`CYCLE); // 等待一個時鐘週期

        data_in = 32'h00110011;
        #(`CYCLE * 24); // 等待一段時間以觀察行為
        valid_ip = 0; // 停止IP模式

        ready_op = 1; // 開始OP模式
        #(`CYCLE * 28); // 等待一個時鐘週期
        ready_op = 0; // 停止OP模式

        #(`CYCLE * 30); // 等待一個時鐘週期

        //3
        valid_ip = 1; // 開始IP模式
        #(`CYCLE); // 等待一個時鐘週期

        data_in = 32'h00110011;
        #(`CYCLE * 16); // 等待一段時間以觀察行為
        valid_ip = 0; // 停止IP模式

        ready_op = 1; // 開始OP模式
        #(`CYCLE * 20); // 等待一個時鐘週期
        ready_op = 0; // 停止OP模式

        #(`CYCLE * 30); // 等待一個時鐘週期

        //3
        valid_ip = 1; // 開始IP模式
        #(`CYCLE); // 等待一個時鐘週期

        data_in = 32'h00110011;
        #(`CYCLE * 8); // 等待一段時間以觀察行為
        valid_ip = 0; // 停止IP模式

        ready_op = 1; // 開始OP模式
        #(`CYCLE * 12); // 等待一個時鐘週期
        ready_op = 0; // 停止OP模式

        #(`CYCLE * 30); // 等待一個時鐘週期


        $finish; // 結束模

    end

endmodule
