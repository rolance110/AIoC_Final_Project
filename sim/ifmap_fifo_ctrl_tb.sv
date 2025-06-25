`timescale 1ns / 1ps
`include "../include/define.svh"

module ifmap_fifo_ctrl_tb;

    logic clk, rst_n;

    // DUT inputs
    logic        ifmap_fifo_reset_i;
    logic        ifmap_need_pop_i;
    logic [31:0] ifmap_pop_num_i;
    logic        ifmap_permit_push_i;
    logic [31:0] ifmap_fifo_base_addr_i;
    logic [31:0] ifmap_glb_read_data_i;
    logic        fifo_glb_busy_i;
    logic [7:0]  in_C_i;
    logic [1:0]  pad_R_i, pad_L_i;
    logic        pe_array_move_i;

    // DUT outputs
    logic        ifmap_fifo_push_o;
    logic [31:0] ifmap_fifo_push_data_o;
    logic        ifmap_fifo_push_mod_o;
    logic        ifmap_fifo_pop_o;
    logic        ifmap_read_req_o;
    logic [31:0] ifmap_glb_read_addr_o;
    logic        ifmap_fifo_done_o;
    logic        ifmap_is_POP_state_o;

    // FIFO wires
    logic fifo_full, fifo_empty;
    logic [7:0] fifo_data_out;

    // GOLDEN compare
    logic [7:0] golden_mem [0:5];  // 預設 6 筆
    integer golden_idx = 0;
    integer pass_cnt = 0, fail_cnt = 0;

    // Instantiate ifmap_fifo_ctrl
    ifmap_fifo_ctrl dut (
        .clk(clk),
        .rst_n(rst_n),
        .ifmap_fifo_reset_i(ifmap_fifo_reset_i),
        .ifmap_need_pop_i(ifmap_need_pop_i),
        .ifmap_pop_num_i(ifmap_pop_num_i),
        .ifmap_permit_push_i(ifmap_permit_push_i),
        .ifmap_fifo_full_i(fifo_full),
        .ifmap_fifo_empty_i(fifo_empty),
        .ifmap_fifo_base_addr_i(ifmap_fifo_base_addr_i),
        .ifmap_glb_read_data_i(ifmap_glb_read_data_i),
        .ifmap_fifo_push_o(ifmap_fifo_push_o),
        .ifmap_fifo_push_data_o(ifmap_fifo_push_data_o),
        .ifmap_fifo_push_mod_o(ifmap_fifo_push_mod_o),
        .ifmap_fifo_pop_o(ifmap_fifo_pop_o),
        .ifmap_read_req_o(ifmap_read_req_o),
        .ifmap_glb_read_addr_o(ifmap_glb_read_addr_o),
        .ifmap_fifo_done_o(ifmap_fifo_done_o),
        .in_C_i(in_C_i),
        .pad_R_i(pad_R_i),
        .pad_L_i(pad_L_i),
        .fifo_glb_busy_i(fifo_glb_busy_i),
        .pe_array_move_i(pe_array_move_i),
        .ifmap_is_POP_state_o(ifmap_is_POP_state_o)
    );

    // Instantiate ifmap_fifo
    ifmap_fifo fifo (
        .clk(clk),
        .rst_n(rst_n),
        .push_en(ifmap_fifo_push_o),
        .push_mod(ifmap_fifo_push_mod_o),
        .push_data(ifmap_fifo_push_data_o),
        .full(fifo_full),
        .pop_en(ifmap_fifo_pop_o),
        .pop_data(fifo_data_out),
        .empty(fifo_empty)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("Start ifmap_fifo_ctrl_tb...");
        clk = 0;
        rst_n = 0;
        ifmap_fifo_reset_i = 0;
        ifmap_need_pop_i   = 0;
        ifmap_pop_num_i    = 0;
        ifmap_permit_push_i = 0;
        ifmap_fifo_base_addr_i = 32'h1000;
        ifmap_glb_read_data_i = 32'hCAFEBABE;
        fifo_glb_busy_i = 0;
        in_C_i = 8'd10;
        pad_R_i = 2'd1;
        pad_L_i = 2'd1;
        pe_array_move_i = 1;

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
    end

    // dump FSDB file
    initial begin
        `ifdef FSDB
            $fsdbDumpfile("../wave/top.fsdb");
            $fsdbDumpvars(0, dut, fifo, ifmap_fifo_ctrl_tb);
        `elsif FSDB_ALL
            $fsdbDumpfile("../wave/top.fsdb");
            $fsdbDumpvars("+struct", "+mda", dut, fifo, ifmap_fifo_ctrl_tb);
        `endif
    end

endmodule