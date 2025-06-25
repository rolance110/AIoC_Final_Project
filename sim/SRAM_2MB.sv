// ======================================================
//  SRAM 64 KB  (32-bit, 16 384 words)  with $readmemh init
//  Author : ChatGPT – 2025-06-25
// ======================================================

module SRAM_2MB #(
    parameter string MEM_INIT_FILE = "../sim/sram_init.hex"  // HEX 檔；空字串則不載入
)(
    input  logic        clk,          // 時鐘
    input  logic        rst_n,        // 異步低電位有效復位
    input  logic [3:0]  WEB,          // Write-Enable Byte (低有效) 1 bit/byte
    input  logic [31:0] addr,         // 位元組位址
    input  logic [31:0] write_data,   // 寫入資料
    output logic [31:0] read_data     // 讀取資料
);

    // -------------------------------
    //  記憶體宣告：64 KB / 4 B = 16 384 words
    // -------------------------------
    localparam int DEPTH = 32'd200000;
    logic [31:0] memory [0:DEPTH-1];

    // -------------------------------
    //  $readmemh 初始化
    // -------------------------------
    initial begin
        if (MEM_INIT_FILE != "") begin
            $display("[%0t] SRAM: loading %s …", $time, MEM_INIT_FILE);

            $display("[%0t] SRAM: load done.", $time);
        end
        else begin
            $display("[%0t] SRAM: MEM_INIT_FILE empty, no preload.", $time);
        end
    end

    // -------------------------------
    //  地址對齊（word 位址）
    // -------------------------------
    wire [13:0] addr_word = addr[13:0];  // 64 KB 範圍 0-16383
    wire        addr_ok   = (addr[31:16] == 16'h0); // 超範圍保護（可選）

    // -------------------------------
    //  讀取邏輯 (同步)
    // -------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            read_data <= 32'h0;
        else if (addr_ok)
            read_data <= memory[addr_word];
    end

    // -------------------------------
    //  寫入邏輯 (同步，Byte Mask)
    // -------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            $readmemh(MEM_INIT_FILE, memory);
        end
        else if (addr_ok && (WEB != 4'hF)) begin  // 只要任一位為 0 即寫
            if (!WEB[0]) memory[addr_word][7:0]   <= write_data[7:0];
            if (!WEB[1]) memory[addr_word][15:8]  <= write_data[15:8];
            if (!WEB[2]) memory[addr_word][23:16] <= write_data[23:16];
            if (!WEB[3]) memory[addr_word][31:24] <= write_data[31:24];
        end
    end

    // -------------------------------
    //  偵錯列印（可用 +define+DEBUG 開關）
    // -------------------------------
`ifdef DEBUG
    always_ff @(posedge clk) begin
        if (addr_ok && (WEB != 4'hF))
            $display("[%0t] SRAM W addr=%h data=%h WEB=%b", $time, addr, write_data, WEB);
        else
            $display("[%0t] SRAM R addr=%h data=%h", $time, addr, read_data);
    end
`endif

endmodule
