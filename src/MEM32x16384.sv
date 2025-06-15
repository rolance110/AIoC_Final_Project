
module MEM32x16384(
    input               CK,
    input               CS,
    input               WEB,
    input               RE,
    input       [31:0]  R_ADDR,
    input       [31:0]  W_ADDR,
    input       [31:0]  D_IN,
    input       [31:0]  BWEB,       // 新增 bit-wise write enable
    output reg  [31:0]  D_OUT
);

reg [31:0] mem [0:16383];

initial begin
    $display("\n ---------------");
    $display(" one memory here");
    $display(" ---------------\n");
end

// 寫入邏輯（支援 BWEB bit mask）
always @(posedge CK) begin
    if (CS && ~WEB) begin
        // 使用 bit-wise 遮罩進行選擇性寫入
        mem[W_ADDR] <= (mem[W_ADDR] & BWEB) | (D_IN & ~BWEB);
    end
end

// 讀取邏輯
always @(posedge CK) begin
    if (RE && CS && WEB)
        D_OUT <= mem[R_ADDR];
    else
        D_OUT <= 32'hzzzzzzzz;
end

endmodule