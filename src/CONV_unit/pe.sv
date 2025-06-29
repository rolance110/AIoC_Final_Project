module pe (
    input  logic        clk,
    input  logic        rst_n,

    // 控制與資料
    input  logic signed [7:0]  w_in,
    input  logic        w_load_en,
    input  logic        PE_en,
    input  logic        PE_stall,
    input  logic signed [7:0]  ifmap,

    output logic signed [7:0]  ifmap_out,   // 傳下去的資料
    output logic signed [15:0] mul_out      // 輸出結果
);

    logic signed [7:0] weight_reg;

    // 權重 buffer 更新
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            weight_reg <= 8'sd0;
        else if(PE_en) begin
            if(w_load_en)
                weight_reg <= w_in;
        end
    end

    always_comb begin
        if(PE_en)
            mul_out = weight_reg * ifmap;
        else
            mul_out = 16'sd0;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            ifmap_out <= 8'sd0;
        else if(PE_en) begin
            if (PE_stall)
                ifmap_out <= ifmap;
        end
    end


endmodule
