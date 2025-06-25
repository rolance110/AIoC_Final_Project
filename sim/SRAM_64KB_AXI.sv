module SRAM_64KB_AXI (
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
    wire [13:0] addr_valid = addr[13:0]; // 取地址高 14 位 (64KB / 4 = 16384 地址)
    integer i, j;
    // 同步讀寫操作
    always @(posedge clk or negedge rst_n) begin
        if (&WEB == 1'b0) begin // 當 WEB 不全為 0 時檢查寫入
            if(!WEB[0]) begin
                memory[addr_valid][7:0]   <= write_data[7:0];   // 寫入最低位
            end
            if(!WEB[1]) begin
                memory[addr_valid][15:8]  <= write_data[15:8];  // 寫入次低位
            end
            if(!WEB[2]) begin
                memory[addr_valid][23:16] <= write_data[23:16]; // 寫入次高位
            end
            if(!WEB[3]) begin
                memory[addr_valid][31:24] <= write_data[31:24]; // 寫入最高位
            end
        end
    end


    always_ff@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_data <= 32'h0; // 復位時清零輸出
        end 
        else if (addr[31:16] == 16'h0)
            read_data <= memory[addr_valid];
        else 
            read_data <= 32'h0; // 地址超出範圍時返回 0
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