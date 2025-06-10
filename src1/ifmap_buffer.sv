module ifmap_buffer (
    input logic clk,                // Clock signal
    input logic rst_n,              // Active-low reset signal
    input logic [31:0] push,        // 32 push signals (one for each FIFO)
    input logic [31:0] pop,         // 32 pop signals (one for each FIFO)
    input logic [31:0][31:0] push_data, // 32 push_data inputs (32 bits each)
    output logic [31:0] full,       // 32 full signals (one for each FIFO)
    output logic [31:0] not_empty,  // 32 not_empty signals (one for each FIFO)
    output logic [31:0][31:0] pop_data // 32 pop_data outputs (32 bits each)
);

    // Parameters
    localparam FIFO_DEPTH = 4;
    localparam DATA_WIDTH = 32;
    localparam NUM_FIFOS = 32;

    // FIFO memory and pointers
    logic [DATA_WIDTH-1:0] fifo_mem [0:NUM_FIFOS-1][0:FIFO_DEPTH-1];//32bit, FIFO=32, depth=4
    logic [1:0] wr_ptr [0:NUM_FIFOS-1]; // 2 bits for depth 4
    logic [1:0] rd_ptr [0:NUM_FIFOS-1]; // 2 bits for depth 4
    logic [2:0] count [0:NUM_FIFOS-1]; // 3 bits to count up to 4
    logic [31:0][31:0] cnt;  // 32 counters for pop operations (32 bits each)TODO: 用來判斷有幾筆要做

    // Generate block for 32 FIFOs
    genvar i;
    generate
        for (i = 0; i < NUM_FIFOS; i = i + 1) begin : fifo_gen
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    wr_ptr[i] <= 0;
                    rd_ptr[i] <= 0;
                    count[i] <= 0;
                    cnt[i] <= 0;
                    full[i] <= 0;
                    not_empty[i] <= 0;
                end else begin
                    // Push operation(write operation)
                    if (push[i] && !full[i]) begin
                        fifo_mem[i][wr_ptr[i]] <= push_data[i];
                        wr_ptr[i] <= wr_ptr[i] + 1;
                        count[i] <= count[i] + 1;
                    end

                    // Pop operation(read operation)
                    if (pop[i] && not_empty[i]) begin
                        pop_data[i] <= fifo_mem[i][rd_ptr[i]];
                        rd_ptr[i] <= rd_ptr[i] + 1;
                        count[i] <= count[i] - 1;
                        cnt[i] <= cnt[i] + 1; // Increment pop counter
                    end

                    // Handle simultaneous push and pop
                    if (push[i] && !full[i] && pop[i] && not_empty[i]) begin
                        fifo_mem[i][wr_ptr[i]] <= push_data[i];
                        pop_data[i] <= fifo_mem[i][rd_ptr[i]];
                        wr_ptr[i] <= wr_ptr[i] + 1;
                        rd_ptr[i] <= rd_ptr[i] + 1;
                        count[i] <= count[i]; // No change in count
                        cnt[i] <= cnt[i] + 1;
                    end

                    // Update full and not_empty signals
                    full[i] <= (count[i] == FIFO_DEPTH);
                    not_empty[i] <= (count[i] != 0);
                end
            end
        end
    endgenerate

endmodule