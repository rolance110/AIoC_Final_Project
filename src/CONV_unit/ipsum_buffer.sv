module ipsum_buffer (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        load_en,
    input  logic [4:0]  load_idx,
    input  logic [15:0] load_data,

    input  logic        read_en,
    output logic [15:0] ipsum_out [31:0] 
);

/*
    load | 1  | 1  |    |
    addr | 0  | 1  |    |
    data |----|m[0]|m[1]|

*/

    logic [15:0] ipsum_mem [31:0];

    // 寫入行為
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++)
                ipsum_mem[i] <= 16'd0;
        end
        else if (load_en) begin
            ipsum_mem[load_idx] <= load_data;
        end
    end

    // 輸出至 adder tree
    always_comb begin
        if (read_en)
            for (int i = 0; i < 32; i++)
                ipsum_out[i] = ipsum_mem[i];
        else
            for (int i = 0; i < 32; i++)
                ipsum_out[i] = 16'd0;
    end

endmodule
