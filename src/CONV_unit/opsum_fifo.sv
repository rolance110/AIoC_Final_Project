//===========================================================================
// Module: opsum_fifo
// Description: Parameterizable FIFO supporting 16-bit single push/pop and
//              32-bit word burst push via pop_mod control.
//===========================================================================
module opsum_fifo #(
    parameter int WIDTH = 16,         // Data width per element (bits)
    parameter int DEPTH = 2          // FIFO depth (# of entries)
)(
    input  logic           clk,
    input  logic           rst_n,

    // Push interface
    input  logic           push_en,
    input  logic [15:0]    push_data,
    output logic           full,

    // Pop interface
    input  logic           pop_en,
    input  logic           pop_mod,          // 0: 16-bit, 1: 32-bit
    output logic [31:0]    pop_data,
    output logic           empty
);

    // Internal storage
    logic [15:0] mem [1:0];
    logic wr_ptr, rd_ptr; // 0 1
    logic [1:0] count;

    assign full  = (count == 2'd2);
    assign empty = (count == 2'd0);

    // === Write pointer ===
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            wr_ptr <= 1'b0;
        else if (push_en && !full)
            wr_ptr <= ~wr_ptr;// +1
    end
    // === Write data ===
    always_ff @(posedge clk) begin
        if (push_en && !full) begin
            mem[wr_ptr] <= push_data;
        end
    end

    // === Read pointer ===
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rd_ptr <= 1'b0;
        else if (pop_en && !empty && pop_mod == 1'b0)
            rd_ptr <= ~rd_ptr;// +1
        else if (pop_en && pop_mod == 1'b1 && full) //todo: only full can pop 32-bit
            rd_ptr <= rd_ptr; // +2
    end

    // === Read data ===
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pop_data <= 32'd0;
        else if (pop_en && !empty) begin
            if (pop_mod == 1'b0)
                pop_data <= {16'd0, mem[rd_ptr]};
            else if (pop_mod == 1'b1 && full) //todo: only full can pop 32-bit
                pop_data <= {mem[1], mem[0]};
        end
    end


    // === Count ===
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 2'd0;
        else if (push_en && !full && pop_en && !empty && pop_mod == 1'b0) begin// push 1 pop 1
            count <= count; // no change
        end 
        else if (push_en && !full && pop_en && !empty && pop_mod == 1'b0) begin// push 1 pop 2
            count <= count - 2'd1; // pop 2
        end
        else if (pop_en && !empty) begin //pop
            if (pop_mod == 1'b0) // pop 1
                count <= count - 2'd1;
            else if (pop_mod == 1'b1 && full) // pop 2
                count <= 2'd0; // pop all out
        end
        else if (push_en && !full) begin // push
            count <= count + 2'd1;
        end
    end



    

endmodule
