module SRAM_64KB (
    input  logic        clk,       // 時鐘
    input  logic        rst_n,    // 異步低電平有效復位
    input  logic [3:0]  WEB,      // 寫啟用信號，低電平有效，每位控制一個字節
    input  logic [31:0] addr,     // 32 位地址輸入
    input  logic [31:0] write_data, // 32 位寫入數據
    output logic [31:0] read_data  // 32 位讀取數據
);

    // 定義 64KB 記憶體，32 位寬，16384 個地址 (2^16 / 4 = 2^14)
    logic [31:0] memory [0:16383];

    // // 初始化記憶體

    // 地址有效性檢查 (限制在 64KB 範圍內，0 到 16383)
    wire [13:0] addr_valid = addr[15:2]; // 取地址高 14 位 (64KB / 4 = 16384 地址)

    // 同步讀寫操作
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_data <= 32'h0; // 復位時清零輸出
           
        end else begin
            // 寫操作：WEB 低電平有效，逐字節寫入
            if (|WEB == 0) begin // 當 WEB 不全為 1 時檢查寫入
                if (addr[31:16] == 16'h0) begin // 確保地址在 64KB 範圍內
                    for (int i = 0; i < 4; i++) begin
                        if (!WEB[i]) begin
                            memory[addr_valid][i*8 +: 8] <= write_data[i*8 +: 8];
                        end
                    end
                end
            end
            // 讀操作：直接讀取記憶體內容
            if (addr[31:16] == 16'h0) begin
                read_data <= memory[addr_valid];
            end else begin
                read_data <= 32'h0; // 無效地址返回 0
            end
        end
    end

    // 可選：用於調試的顯示信息
    `ifdef DEBUG
    always @(posedge clk) begin
        if (|WEB == 0 && addr[31:16] == 16'h0) begin
            $display("Write: addr=%h, data=%h, WEB=%b", addr, write_data, WEB);
        end
        if (addr[31:16] == 16'h0) begin
            $display("Read: addr=%h, data=%h", addr, read_data);
        end
    end
    `endif

endmodule