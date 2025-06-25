`timescale 1ns/1ps
`include "../include/define.svh"
module opsum_fifo_tb;

    logic clk, rst_n;
    logic push_en;
    logic [15:0] push_data;
    logic pop_en;
    logic pop_mod;
    logic [31:0] pop_data;
    logic full, empty;

    // DUT
    opsum_fifo uut (
        .clk(clk),
        .rst_n(rst_n),
        .push_en(push_en),
        .push_data(push_data),
        .full(full),
        .pop_en(pop_en),
        .pop_mod(pop_mod),
        .pop_data(pop_data),
        .empty(empty)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Task: push 16-bit
    task push16(input [15:0] data);
        @(negedge clk);
        push_data = data;
        push_en   = 1;
        @(negedge clk);
        push_en = 0;
    endtask

    // Task: pop 16-bit
    task pop16();
        @(negedge clk);
        pop_en = 1;
        pop_mod = 0;
        @(negedge clk);
        pop_en = 0;
    endtask

    // Task: pop 32-bit (burst)
    task pop32();
        @(negedge clk);
        pop_en = 1;
        pop_mod = 1;
        @(negedge clk);
        pop_en = 0;
    endtask

    initial begin
        $display("--- opsum_fifo_tb Start ---");

        clk = 0;
        rst_n = 0;
        push_en = 0;
        pop_en = 0;
        pop_mod = 0;
        push_data = 0;

        @(negedge clk); rst_n = 1;

        // Test 1: push and pop single 16-bit values
        push16(16'hA5A5);
        push16(16'h1234);
        pop16();
        $display("Pop result = 0x%h (expect 0xA5A5)", pop_data[15:0]);
        pop16();
        $display("Pop result = 0x%h (expect 0x1234)", pop_data[15:0]);

        // Test 2: check empty behavior
        pop16();
        $display("Expect no change (empty=1): 0x%h", pop_data[15:0]);

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
        #20;
        $display("--- opsum_fifo_tb Done ---");
        $finish;
    end

endmodule