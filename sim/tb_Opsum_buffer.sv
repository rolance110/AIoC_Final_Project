`timescale 1ns/1ps
`define ROW_NUM 32
`define CYCLE    10            // 10 ns = 100 MHz

//寫一個Opsum_buffer的testbench
module tb_Opsum_buffer;
    // ──────────────────────────────────────────────
    //  ▍ DUT 連接埠
    // ──────────────────────────────────────────────
    logic                    clk , reset ;
    logic                    ready_op , valid_op ;
    logic  [5:0]             ip_time_4 ;
    logic                    first_f ;
    logic  [4:0]             close_start_num ;
    logic                    close_f ;
    logic                    store_opsum_f ;
    logic  [`ROW_NUM*16-1:0] opsum_in ;
    logic  [5:0]             row_en ;
    logic  [`ROW_NUM-1:0]    opsum_out ;
    
    // ──────────────────────────────────────────────
    //  ▍ 例化 DUT
    // ──────────────────────────────────────────────
    Opsum_buffer dut (
        .clk            (clk),
        .reset          (reset),
        .ready_op       (ready_op),
        .valid_op       (valid_op),
        .ip_time_4      (ip_time_4),
        .first_f        (first_f),
        .close_start_num(close_start_num),
        .close_f        (close_f),
        .store_opsum_f  (store_opsum_f),
        .opsum_in       (opsum_in),
        .row_en         (row_en),
        .opsum_out      (opsum_out)
    );
    
    // ──────────────────────────────────────────────
    //  ▍ 時脈
    // ──────────────────────────────────────────────
    initial clk = 0;
    always #(`CYCLE/2) clk = ~clk;
    
    initial begin
        $fsdbDumpfile("opsum.fsdb");
        $fsdbDumpvars(0, tb_Opsum_buffer, "+all");
        $fsdbDumpMDA;
    end

    initial begin    
        reset = 1;
        ready_op = 0;
        valid_op = 0;
        ip_time_4 = 6'd8; // 假設前8個cycle
        first_f = 1;
        close_start_num = 5'd0;
        close_f = 0;
        store_opsum_f = 1; // 假設要存計算結果
        row_en = 'b111111; // 使用所有ROW
        opsum_in = 'h11223344556677889900112233445566778899; // 假設輸入

        #(`CYCLE * 2);
        reset = 0;

        //handshake
        #(`CYCLE);
        opsum_in = 'h0; // 假設輸入
        #(`CYCLE);

        opsum_in = 'h333333333333333333333333333333333333333; // 假設輸入
        #(`CYCLE);

        opsum_in = 'h555555555555555555555555555555555; // 假設輸入
        #(`CYCLE);
        

        store_opsum_f = 0;
        ready_op = 1;
        valid_op = 1;

        #(`CYCLE * 16);

        ready_op = 0;
        valid_op = 0;

        #(`CYCLE * 10);

        $finish;
    end



endmodule
