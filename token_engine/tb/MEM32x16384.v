module MEM1024X24(
    input CK,
    input CS,
    input WEB,
    input RE,
    input [9:0] R_ADDR,
    input [9:0] W_ADDR,
    input [23:0] D_IN,
    output reg [23:0] D_OUT
);



initial
begin 
$display("\n ---------------");
$display(" one memory here");
$display(" ---------------\n");
end


reg [31:0] mem [0:16383];

initial begin
    $readmemh("init_sram_data.txt", u_sram.MEMORY);
end

always @(posedge CK) 
begin
    if(CS && ~WEB)
        mem[W_ADDR] <= D_IN;
    else
        mem[W_ADDR] <= mem[W_ADDR];
end

always@(posedge CK)
begin
    if(RE && CS && WEB)
        D_OUT <= mem[R_ADDR];
    else
        D_OUT <= 24'hxxxxxx;
end

endmodule