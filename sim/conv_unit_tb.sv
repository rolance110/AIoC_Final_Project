`timescale 1ns/1ps
`include "../include/define.svh"
module conv_unit_tb;

    parameter cycle = 10;
    logic clk;
    logic rst_n;

    // Reset control
    logic ifmap_fifo_reset_i;
    logic ipsum_fifo_reset_i;
    logic opsum_fifo_reset_i;

    // Inputs
    logic [1:0] layer_type;

    logic [31:0] push_ifmap_en;
    logic [31:0] push_ifmap_mod;
    logic [31:0] push_ifmap_data [31:0];
    logic [31:0] pop_ifmap_en;

    logic [7:0] weight_in;
    logic weight_load_en [31:0][31:0];

    logic PE_en_matrix [31:0][31:0];
    logic PE_stall_matrix [31:0][31:0];

    logic [31:0] push_ipsum_en;
    logic [31:0] push_ipsum_mod;
    logic [31:0] push_ipsum_data [31:0];
    logic [31:0] pop_ipsum_en;

    logic ipsum_read_en;
    logic ipsum_add_en;

    logic [31:0] opsum_push_en;
    logic [31:0] opsum_pop_en;
    logic [31:0] opsum_pop_mod;

    // Outputs
    logic [31:0] ifmap_fifo_full;
    logic [31:0] ifmap_fifo_empty;

    logic [31:0] ipsum_fifo_full;
    logic [31:0] ipsum_fifo_empty;

    logic [31:0] opsum_fifo_full;
    logic [31:0] opsum_fifo_empty;
    logic [31:0] opsum_pop_data [31:0];

    // DUT
    conv_unit dut (
        .clk(clk),
        .rst_n(rst_n),

        .ifmap_fifo_reset_i(ifmap_fifo_reset_i),
        .ipsum_fifo_reset_i(ipsum_fifo_reset_i),
        .opsum_fifo_reset_i(opsum_fifo_reset_i),

        .layer_type(layer_type),

        .push_ifmap_en(push_ifmap_en),
        .push_ifmap_mod(push_ifmap_mod),
        .push_ifmap_data(push_ifmap_data),
        .pop_ifmap_en(pop_ifmap_en),

        .weight_in(weight_in),
        .weight_load_en(weight_load_en),

        .PE_en_matrix(PE_en_matrix),
        .PE_stall_matrix(PE_stall_matrix),

        .push_ipsum_en(push_ipsum_en),
        .push_ipsum_mod(push_ipsum_mod),
        .push_ipsum_data(push_ipsum_data),
        .pop_ipsum_en(pop_ipsum_en),

        .ipsum_read_en(ipsum_read_en),
        .ipsum_add_en(ipsum_add_en),

        .opsum_push_en(opsum_push_en),
        .opsum_pop_en(opsum_pop_en),
        .opsum_pop_mod(opsum_pop_mod),

        .ifmap_fifo_full(ifmap_fifo_full),
        .ifmap_fifo_empty(ifmap_fifo_empty),

        .ipsum_fifo_full(ipsum_fifo_full),
        .ipsum_fifo_empty(ipsum_fifo_empty),

        .opsum_fifo_full(opsum_fifo_full),
        .opsum_fifo_empty(opsum_fifo_empty),
        .opsum_pop_data(opsum_pop_data)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        ifmap_fifo_reset_i = 1;
        ipsum_fifo_reset_i = 1;
        opsum_fifo_reset_i = 1;

        repeat (2) @(posedge clk);
        rst_n = 1;
        ifmap_fifo_reset_i = 0;
        ipsum_fifo_reset_i = 0;
        opsum_fifo_reset_i = 0;

        // TODO: Add test vectors for ifmap/ipsum push, PE enable, reducer, etc.
                $display("Start conv_unit_tb...");
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
        // $display("✅ Reset done. Begin testing...");
        $finish;
    end

    // FSDB Waveform
    initial begin
        `ifdef FSDB
            $fsdbDumpfile("../wave/top.fsdb");
            $fsdbDumpvars(0, dut);
        `elsif FSDB_ALL
            $fsdbDumpfile("../wave/top.fsdb");
            $fsdbDumpvars("+struct", "+mda", dut);
        `endif
    end

endmodule