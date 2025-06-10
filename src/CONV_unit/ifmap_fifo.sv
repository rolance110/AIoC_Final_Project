//===========================================================================
// Module: ifmap_fifo
// Description: Parameterizable FIFO supporting 8-bit single push/pop and
//              32-bit word (4-byte) burst push via push_mod control.
//===========================================================================
module ifmap_fifo #(
    parameter int WIDTH = 8,         // Data width per element (bits)
    parameter int DEPTH = 4          // FIFO depth (# of entries)
)(
    input  logic           clk,
    input  logic           rst_n,

    // Push interface
    input  logic           push_en,       // Push enable
    input  logic           push_mod,      // 0: push 8-bit, 1: push 32-bit (4 entries)
    input  logic [31:0]    push_data,     // Data for push (byte lanes)
    output logic           full,          // FIFO full flag

    // Pop interface
    input  logic           pop_en,        // Pop enable
    output logic [7:0]     pop_data,      // Data out (8-bit)
    output logic           empty          // FIFO empty flag
);

    // Internal storage
    logic [7:0] mem [0:3];
    logic [1:0] wr_ptr, rd_ptr; // 0 1 2 3
    logic [2:0] count;
    logic [7:0] data_out_reg;

    assign pop_data = data_out_reg;
    assign full  = (count == 3'd4);
    assign empty = (count == 3'd0);

    //todo: Write pointer update: 下一筆要寫入的位置
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            wr_ptr <= 2'd0;
        else if (push_en) begin
            if (push_mod == 1'b0 && !full)
                wr_ptr <= (wr_ptr + 2'd1);
            else if (push_mod == 1'b1 && empty) // only empty can accept burst push
                wr_ptr <= 2'd0; //Directly set to 0 (FIFO is full after burst push)
        end
    end
    // Write data
    always_ff @(posedge clk) begin
        if (push_en) begin
            if (push_mod == 1'b0 && !full)
                mem[wr_ptr] <= push_data[7:0];
            else if (push_mod == 1'b1 && empty) begin// only empty can accept burst push
                mem[0] <= push_data[7:0];
                mem[1] <= push_data[15:8];
                mem[2] <= push_data[23:16];
                mem[3] <= push_data[31:24];
            end
        end
    end


    //todo: Read pointer update // 0 1 2 3 下一筆要讀的位置
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rd_ptr <= 2'd0;
        else if (pop_en && !empty)
            rd_ptr <= (rd_ptr + 2'd1);
    end
    // Read data
    always_ff @(posedge clk) begin
        if (!rst_n)
            data_out_reg <= 7'd0;
        else if (pop_en && !empty)
            data_out_reg <= mem[rd_ptr];
    end

    // todo Count update // 1 2 3 4 
    // Count: The number of valid entries in the FIFO
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 3'd0;
        else if(push_en && pop_en) begin
            if(push_mod == 1'b0 && !full) // push 1 byte pop 1 byte
                count <= count; // 可以 pop 代表 fifo 裡面本來就有值 => mod 1 不可能發生
        end
        else if(push_en)begin
            if(push_mod == 1'b0 && !full)
                count <= count + 1; // Increment count for single push
            else if(push_mod == 1'b1 && empty)
                count <= 3'd4;
        end
        else if(pop_en && !empty)
            count <= count - 3'd1;
    end





endmodule
