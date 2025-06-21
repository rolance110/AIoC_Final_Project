module token_arbiter (
    input logic       clk,
    input logic       rst_n,
    input logic weight_load_state_i,
    input logic [31:0] weight_addr_i,

    input  logic [31:0] opsum_write_req_matrix_i,
    input  logic [3:0]  opsum_write_web_matrix_i   [31:0],

    input  logic [31:0] ifmap_read_req_matrix_i,
    input  logic [31:0] ipsum_read_req_matrix_i,

    input  logic [31:0] ifmap_read_addr_matrix_i [31:0],
    input  logic [31:0] ipsum_read_addr_matrix_i [31:0],
    input  logic [31:0] opsum_write_addr_matrix_i [31:0],

    input logic [31:0] opsum_fifo_pop_data_matrix_i [31:0], // 32-bit data for each write

//* to GLB read sel
    output logic        glb_read_o,
    output logic [31:0] glb_addr_o,
//* to GLB write sel
    output logic        glb_write_o,
    output logic [3:0]  glb_write_web_o,
    output logic [31:0] glb_write_data_o,
//* to fifo
    output logic [31:0] permit_ifmap_matrix_o,
    output logic [31:0] permit_ipsum_matrix_o,
    output logic [31:0] permit_opsum_matrix_o
);

logic [31:0] glb_write_addr;
logic [31:0] glb_read_addr;

always_comb begin
    if(glb_write_o)
        glb_addr_o = glb_write_addr;
    else if(glb_read_o)
        glb_addr_o = glb_read_addr;
    else 
        glb_addr_o = 32'd0;
end



// Priority Write: opsum first
logic [31:0] opsum_write_req_matrix_buf;
always_ff@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        opsum_write_req_matrix_buf <= 32'd0;
    end
    else begin
        opsum_write_req_matrix_buf <= opsum_write_req_matrix_i;
    end
end

always_comb begin
    if (opsum_write_req_matrix_buf[0]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[0];
    end
    else if (opsum_write_req_matrix_buf[1]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[1];
    end
    else if (opsum_write_req_matrix_buf[2]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[2];
    end
    else if (opsum_write_req_matrix_buf[3]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[3];
    end
    else if (opsum_write_req_matrix_buf[4]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[4];
    end
    else if (opsum_write_req_matrix_buf[5]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[5];
    end
    else if (opsum_write_req_matrix_buf[6]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[6];
    end
    else if (opsum_write_req_matrix_buf[7]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[7];
    end
    else if (opsum_write_req_matrix_buf[8]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[8];
    end
    else if (opsum_write_req_matrix_buf[9]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[9];
    end
    else if (opsum_write_req_matrix_buf[10]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[10];
    end
    else if (opsum_write_req_matrix_buf[11]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[11];
    end
    else if (opsum_write_req_matrix_buf[12]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[12];
    end
    else if (opsum_write_req_matrix_buf[13]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[13];
    end
    else if (opsum_write_req_matrix_buf[14]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[14];
    end
    else if (opsum_write_req_matrix_buf[15]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[15];
    end
    else if (opsum_write_req_matrix_buf[16]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[16];
    end
    else if (opsum_write_req_matrix_buf[17]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[17];
    end
    else if (opsum_write_req_matrix_buf[18]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[18];
    end
    else if (opsum_write_req_matrix_buf[19]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[19];
    end
    else if (opsum_write_req_matrix_buf[20]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[20];
    end
    else if (opsum_write_req_matrix_buf[21]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[21];
    end
    else if (opsum_write_req_matrix_buf[22]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[22];
    end
    else if (opsum_write_req_matrix_buf[23]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[23];
    end
    else if (opsum_write_req_matrix_buf[24]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[24];
    end
    else if (opsum_write_req_matrix_buf[25]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[25];
    end
    else if (opsum_write_req_matrix_buf[26]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[26];
    end
    else if (opsum_write_req_matrix_buf[27]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[27];
    end
    else if (opsum_write_req_matrix_buf[28]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[28];
    end
    else if (opsum_write_req_matrix_buf[29]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[29];
    end
    else if (opsum_write_req_matrix_buf[30]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[30];
    end
    else if (opsum_write_req_matrix_buf[31]) begin
        glb_write_data_o = opsum_fifo_pop_data_matrix_i[31];
    end
    else begin
        glb_write_data_o = 32'd0;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        glb_write_o <= 1'b0;
        glb_write_addr <= 32'd0;
        glb_write_web_o <= 4'd0;
    end
    else if (opsum_write_req_matrix_i[0]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[0];
        glb_write_web_o <= opsum_write_web_matrix_i[0];
    end
    else if (opsum_write_req_matrix_i[1]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[1];
        glb_write_web_o <= opsum_write_web_matrix_i[1];
    end
    else if (opsum_write_req_matrix_i[2]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[2];
        glb_write_web_o <= opsum_write_web_matrix_i[2];
    end
    else if (opsum_write_req_matrix_i[3]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[3];
        glb_write_web_o <= opsum_write_web_matrix_i[3];
    end
    else if (opsum_write_req_matrix_i[4]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[4];
        glb_write_web_o <= opsum_write_web_matrix_i[4];
    end
    else if (opsum_write_req_matrix_i[5]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[5];
        glb_write_web_o <= opsum_write_web_matrix_i[5];
    end
    else if (opsum_write_req_matrix_i[6]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[6];
        glb_write_web_o <= opsum_write_web_matrix_i[6];
    end
    else if (opsum_write_req_matrix_i[7]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[7];
        glb_write_web_o <= opsum_write_web_matrix_i[7];
    end
    else if (opsum_write_req_matrix_i[8]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[8];
        glb_write_web_o <= opsum_write_web_matrix_i[8];
    end
    else if (opsum_write_req_matrix_i[9]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[9];
        glb_write_web_o <= opsum_write_web_matrix_i[9];
    end
    else if (opsum_write_req_matrix_i[10]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[10];
        glb_write_web_o <= opsum_write_web_matrix_i[10];
    end
    else if (opsum_write_req_matrix_i[11]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[11];
        glb_write_web_o <= opsum_write_web_matrix_i[11];
    end
    else if (opsum_write_req_matrix_i[12]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[12];
        glb_write_web_o <= opsum_write_web_matrix_i[12];
    end
    else if (opsum_write_req_matrix_i[13]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[13];
        glb_write_web_o <= opsum_write_web_matrix_i[13];
    end
    else if (opsum_write_req_matrix_i[14]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[14];
        glb_write_web_o <= opsum_write_web_matrix_i[14];
    end
    else if (opsum_write_req_matrix_i[15]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[15];
        glb_write_web_o <= opsum_write_web_matrix_i[15];
    end
    else if (opsum_write_req_matrix_i[16]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[16];
        glb_write_web_o <= opsum_write_web_matrix_i[16];
    end
    else if (opsum_write_req_matrix_i[17]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[17];
        glb_write_web_o <= opsum_write_web_matrix_i[17];
    end
    else if (opsum_write_req_matrix_i[18]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[18];
        glb_write_web_o <= opsum_write_web_matrix_i[18];
    end
    else if (opsum_write_req_matrix_i[19]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[19];
        glb_write_web_o <= opsum_write_web_matrix_i[19];
    end
    else if (opsum_write_req_matrix_i[20]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[20];
        glb_write_web_o <= opsum_write_web_matrix_i[20];
    end
    else if (opsum_write_req_matrix_i[21]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[21];
        glb_write_web_o <= opsum_write_web_matrix_i[21];
    end
    else if (opsum_write_req_matrix_i[22]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[22];
        glb_write_web_o <= opsum_write_web_matrix_i[22];
    end
    else if (opsum_write_req_matrix_i[23]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[23];
        glb_write_web_o <= opsum_write_web_matrix_i[23];
    end
    else if (opsum_write_req_matrix_i[24]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[24];
        glb_write_web_o <= opsum_write_web_matrix_i[24];
    end
    else if (opsum_write_req_matrix_i[25]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[25];
        glb_write_web_o <= opsum_write_web_matrix_i[25];
    end
    else if (opsum_write_req_matrix_i[26]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[26];
        glb_write_web_o <= opsum_write_web_matrix_i[26];
    end
    else if (opsum_write_req_matrix_i[27]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[27];
        glb_write_web_o <= opsum_write_web_matrix_i[27];
    end
    else if (opsum_write_req_matrix_i[28]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[28];
        glb_write_web_o <= opsum_write_web_matrix_i[28];
    end
    else if (opsum_write_req_matrix_i[29]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[29];
        glb_write_web_o <= opsum_write_web_matrix_i[29];
    end
    else if (opsum_write_req_matrix_i[30]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[30];
        glb_write_web_o <= opsum_write_web_matrix_i[30];
    end
    else if (opsum_write_req_matrix_i[31]) begin
        glb_write_o <= 1'b1;
        glb_write_addr <= opsum_write_addr_matrix_i[31];
        glb_write_web_o <= opsum_write_web_matrix_i[31];
    end
    else begin
        glb_write_o <= 1'b0;
        glb_write_addr <= 32'd0;
        glb_write_web_o <= 4'd0; // read
    end
end
always_comb begin
    if (opsum_write_req_matrix_i[0]) begin
        permit_opsum_matrix_o = 32'b00000000_00000000_00000000_00000001; // permit_opsum_matrix_o[0] = 1'b1
    end
    else if (opsum_write_req_matrix_i[1]) begin
        permit_opsum_matrix_o = 32'b00000000_00000000_00000000_00000010; // permit_opsum_matrix_o[1] = 1'b1
    end
    else if (opsum_write_req_matrix_i[2]) begin
        permit_opsum_matrix_o = 32'b00000000_00000000_00000000_00000100; // permit_opsum_matrix_o[2] = 1'b1
    end
    else if (opsum_write_req_matrix_i[3]) begin
        permit_opsum_matrix_o = 32'b00000000_00000000_00000000_00001000; // permit_opsum_matrix_o[3] = 1'b1
    end
    else if (opsum_write_req_matrix_i[4]) begin
        permit_opsum_matrix_o = 32'b00000000_00000000_00000000_00010000; // permit_opsum_matrix_o[4] = 1'b1
    end
    else if (opsum_write_req_matrix_i[5]) begin
        permit_opsum_matrix_o = 32'b00000000_00000000_00000000_00100000; // permit_opsum_matrix_o[5] = 1'b1
    end
    else if (opsum_write_req_matrix_i[6]) begin
        permit_opsum_matrix_o = 32'b00000000_00000000_00000000_01000000; // permit_opsum_matrix_o[6] = 1'b1
    end
    else if (opsum_write_req_matrix_i[7]) begin
        permit_opsum_matrix_o = 32'b00000000_00000000_00000000_10000000; // permit_opsum_matrix_o[7] = 1'b1
    end
    else if (opsum_write_req_matrix_i[8]) begin
        permit_opsum_matrix_o = 32'b00000000_00000000_00000001_00000000; // permit_opsum_matrix_o[8] = 1'b1
    end
    else if (opsum_write_req_matrix_i[9]) begin
        permit_opsum_matrix_o = 32'b00000000_00000000_00000010_00000000; // permit_opsum_matrix_o[9] = 1'b1
    end
    else if (opsum_write_req_matrix_i[10]) begin
        permit_opsum_matrix_o = 32'b00000000_00000000_00000100_00000000; // permit_opsum_matrix_o[10] = 1'b1
    end
    else if (opsum_write_req_matrix_i[11]) begin
        permit_opsum_matrix_o = 32'b00000000_00000000_00001000_00000000; // permit_opsum_matrix_o[11] = 1'b1
    end
    else if (opsum_write_req_matrix_i[12]) begin
        permit_opsum_matrix_o = 32'b00000000_00000000_00010000_00000000; // permit_opsum_matrix_o[12] = 1'b1
    end
    else if (opsum_write_req_matrix_i[13]) begin
        permit_opsum_matrix_o = 32'b00000000_00000000_00100000_00000000; // permit_opsum_matrix_o[13] = 1'b1
    end
    else if (opsum_write_req_matrix_i[14]) begin
        permit_opsum_matrix_o = 32'b00000000_00000000_01000000_00000000; // permit_opsum_matrix_o[14] = 1'b1
    end
    else if (opsum_write_req_matrix_i[15]) begin
        permit_opsum_matrix_o = 32'b00000000_00000000_10000000_00000000; // permit_opsum_matrix_o[15] = 1'b1
    end
    else if (opsum_write_req_matrix_i[16]) begin
        permit_opsum_matrix_o = 32'b00000000_00000001_00000000_00000000; // permit_opsum_matrix_o[16] = 1'b1
    end
    else if (opsum_write_req_matrix_i[17]) begin
        permit_opsum_matrix_o = 32'b00000000_00000010_00000000_00000000; // permit_opsum_matrix_o[17] = 1'b1
    end
    else if (opsum_write_req_matrix_i[18]) begin
        permit_opsum_matrix_o = 32'b00000000_00000100_00000000_00000000; // permit_opsum_matrix_o[18] = 1'b1
    end
    else if (opsum_write_req_matrix_i[19]) begin
        permit_opsum_matrix_o = 32'b00000000_00001000_00000000_00000000; // permit_opsum_matrix_o[19] = 1'b1
    end
    else if (opsum_write_req_matrix_i[20]) begin
        permit_opsum_matrix_o = 32'b00000000_00010000_00000000_00000000; // permit_opsum_matrix_o[20] = 1'b1
    end
    else if (opsum_write_req_matrix_i[21]) begin
        permit_opsum_matrix_o = 32'b00000000_00100000_00000000_00000000; // permit_opsum_matrix_o[21] = 1'b1
    end
    else if (opsum_write_req_matrix_i[22]) begin
        permit_opsum_matrix_o = 32'b00000000_01000000_00000000_00000000; // permit_opsum_matrix_o[22] = 1'b1
    end
    else if (opsum_write_req_matrix_i[23]) begin
        permit_opsum_matrix_o = 32'b00000000_10000000_00000000_00000000; // permit_opsum_matrix_o[23] = 1'b1
    end
    else if (opsum_write_req_matrix_i[24]) begin
        permit_opsum_matrix_o = 32'b00000001_00000000_00000000_00000000; // permit_opsum_matrix_o[24] = 1'b1
    end
    else if (opsum_write_req_matrix_i[25]) begin
        permit_opsum_matrix_o = 32'b00000010_00000000_00000000_00000000; // permit_opsum_matrix_o[25] = 1'b1
    end
    else if (opsum_write_req_matrix_i[26]) begin
        permit_opsum_matrix_o = 32'b00000100_00000000_00000000_00000000; // permit_opsum_matrix_o[26] = 1'b1
    end
    else if (opsum_write_req_matrix_i[27]) begin
        permit_opsum_matrix_o = 32'b00001000_00000000_00000000_00000000; // permit_opsum_matrix_o[27] = 1'b1
    end
    else if (opsum_write_req_matrix_i[28]) begin
        permit_opsum_matrix_o = 32'b00010000_00000000_00000000_00000000; // permit_opsum_matrix_o[28] = 1'b1
    end
    else if (opsum_write_req_matrix_i[29]) begin
        permit_opsum_matrix_o = 32'b00100000_00000000_00000000_00000000; // permit_opsum_matrix_o[29] = 1'b1
    end
    else if (opsum_write_req_matrix_i[30]) begin
        permit_opsum_matrix_o = 32'b01000000_00000000_00000000_00000000; // permit_opsum_matrix_o[30] = 1'b1
    end
    else if (opsum_write_req_matrix_i[31]) begin
        permit_opsum_matrix_o = 32'b10000000_00000000_00000000_00000000; // permit_opsum_matrix_o[31] = 1'b1
    end
    else begin
        permit_opsum_matrix_o = 32'd0;
    end
end
// Priority Read: weight > ifmap > ipsum
always_comb begin
    if(weight_load_state_i)begin
        glb_read_o  = 1'b1;
        glb_read_addr = weight_addr_i;
    end
    else if (!glb_write_o) begin
        if (ifmap_read_req_matrix_i[0]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[0];
            permit_ifmap_matrix_o = 32'b00000000_00000000_00000000_00000001; // permit_ifmap_matrix_o[0] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[1]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[1];
            permit_ifmap_matrix_o = 32'b00000000_00000000_00000000_00000010; // permit_ifmap_matrix_o[1] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[2]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[2];
            permit_ifmap_matrix_o = 32'b00000000_00000000_00000000_00000100; // permit_ifmap_matrix_o[2] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[3]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[3];
            permit_ifmap_matrix_o = 32'b00000000_00000000_00000000_00001000; // permit_ifmap_matrix_o[3] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[4]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[4];
            permit_ifmap_matrix_o = 32'b00000000_00000000_00000000_00010000; // permit_ifmap_matrix_o[4] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[5]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[5];
            permit_ifmap_matrix_o = 32'b00000000_00000000_00000000_00100000; // permit_ifmap_matrix_o[5] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[6]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[6];
            permit_ifmap_matrix_o = 32'b00000000_00000000_00000000_01000000; // permit_ifmap_matrix_o[6] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[7]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[7];
            permit_ifmap_matrix_o = 32'b00000000_00000000_00000000_10000000; // permit_ifmap_matrix_o[7] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[8]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[8];
            permit_ifmap_matrix_o = 32'b00000000_00000000_00000001_00000000; // permit_ifmap_matrix_o[8] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[9]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[9];
            permit_ifmap_matrix_o = 32'b00000000_00000000_00000010_00000000; // permit_ifmap_matrix_o[9] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[10]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[10];
            permit_ifmap_matrix_o = 32'b00000000_00000000_00000100_00000000; // permit_ifmap_matrix_o[10] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[11]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[11];
            permit_ifmap_matrix_o = 32'b00000000_00000000_00001000_00000000; // permit_ifmap_matrix_o[11] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[12]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[12];
            permit_ifmap_matrix_o = 32'b00000000_00000000_00010000_00000000; // permit_ifmap_matrix_o[12] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[13]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[13];
            permit_ifmap_matrix_o = 32'b00000000_00000000_00100000_00000000; // permit_ifmap_matrix_o[13] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[14]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[14];
            permit_ifmap_matrix_o = 32'b00000000_00000000_01000000_00000000; // permit_ifmap_matrix_o[14] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[15]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[15];
            permit_ifmap_matrix_o = 32'b00000000_00000000_10000000_00000000; // permit_ifmap_matrix_o[15] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[16]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[16];
            permit_ifmap_matrix_o = 32'b00000000_00000001_00000000_00000000; // permit_ifmap_matrix_o[16] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[17]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[17];
            permit_ifmap_matrix_o = 32'b00000000_00000010_00000000_00000000; // permit_ifmap_matrix_o[17] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[18]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[18];
            permit_ifmap_matrix_o = 32'b00000000_00000100_00000000_00000000; // permit_ifmap_matrix_o[18] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[19]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[19];
            permit_ifmap_matrix_o = 32'b00000000_00001000_00000000_00000000; // permit_ifmap_matrix_o[19] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[20]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[20];
            permit_ifmap_matrix_o = 32'b00000000_00010000_00000000_00000000; // permit_ifmap_matrix_o[20] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[21]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[21];
            permit_ifmap_matrix_o = 32'b00000000_00100000_00000000_00000000; // permit_ifmap_matrix_o[21] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[22]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[22];
            permit_ifmap_matrix_o = 32'b00000000_01000000_00000000_00000000; // permit_ifmap_matrix_o[22] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[23]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[23];
            permit_ifmap_matrix_o = 32'b00000000_10000000_00000000_00000000; // permit_ifmap_matrix_o[23] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[24]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[24];
            permit_ifmap_matrix_o = 32'b00000001_00000000_00000000_00000000; // permit_ifmap_matrix_o[24] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[25]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[25];
            permit_ifmap_matrix_o = 32'b00000010_00000000_00000000_00000000; // permit_ifmap_matrix_o[25] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[26]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[26];
            permit_ifmap_matrix_o = 32'b00000100_00000000_00000000_00000000; // permit_ifmap_matrix_o[26] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[27]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[27];
            permit_ifmap_matrix_o = 32'b00001000_00000000_00000000_00000000; // permit_ifmap_matrix_o[27] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[28]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[28];
            permit_ifmap_matrix_o = 32'b00010000_00000000_00000000_00000000; // permit_ifmap_matrix_o[28] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[29]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[29];
            permit_ifmap_matrix_o = 32'b00100000_00000000_00000000_00000000; // permit_ifmap_matrix_o[29] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[30]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[30];
            permit_ifmap_matrix_o = 32'b01000000_00000000_00000000_00000000; // permit_ifmap_matrix_o[30] = 1'b1
        end
        else if (ifmap_read_req_matrix_i[31]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ifmap_read_addr_matrix_i[31];
            permit_ifmap_matrix_o = 32'b10000000_00000000_00000000_00000000; // permit_ifmap_matrix_o[31] = 1'b1
        end
    //todo: ipsum
        else if (ipsum_read_req_matrix_i[0]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[0];
            permit_ipsum_matrix_o = 32'b00000000_00000000_00000000_00000001; // permit_ipsum_matrix_o[0] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[1]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[1];
            permit_ipsum_matrix_o = 32'b00000000_00000000_00000000_00000010; // permit_ipsum_matrix_o[1] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[2]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[2];
            permit_ipsum_matrix_o = 32'b00000000_00000000_00000000_00000100; // permit_ipsum_matrix_o[2] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[3]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[3];
            permit_ipsum_matrix_o = 32'b00000000_00000000_00000000_00001000; // permit_ipsum_matrix_o[3] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[4]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[4];
            permit_ipsum_matrix_o = 32'b00000000_00000000_00000000_00010000; // permit_ipsum_matrix_o[4] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[5]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[5];
            permit_ipsum_matrix_o = 32'b00000000_00000000_00000000_00100000; // permit_ipsum_matrix_o[5] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[6]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[6];
            permit_ipsum_matrix_o = 32'b00000000_00000000_00000000_01000000; // permit_ipsum_matrix_o[6] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[7]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[7];
            permit_ipsum_matrix_o = 32'b00000000_00000000_00000000_10000000; // permit_ipsum_matrix_o[7] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[8]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[8];
            permit_ipsum_matrix_o = 32'b00000000_00000000_00000001_00000000; // permit_ipsum_matrix_o[8] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[9]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[9];
            permit_ipsum_matrix_o = 32'b00000000_00000000_00000010_00000000; // permit_ipsum_matrix_o[9] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[10]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[10];
            permit_ipsum_matrix_o = 32'b00000000_00000000_00000100_00000000; // permit_ipsum_matrix_o[10] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[11]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[11];
            permit_ipsum_matrix_o = 32'b00000000_00000000_00001000_00000000; // permit_ipsum_matrix_o[11] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[12]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[12];
            permit_ipsum_matrix_o = 32'b00000000_00000000_00010000_00000000; // permit_ipsum_matrix_o[12] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[13]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[13];
            permit_ipsum_matrix_o = 32'b00000000_00000000_00100000_00000000; // permit_ipsum_matrix_o[13] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[14]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[14];
            permit_ipsum_matrix_o = 32'b00000000_00000000_01000000_00000000; // permit_ipsum_matrix_o[14] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[15]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[15];
            permit_ipsum_matrix_o = 32'b00000000_00000000_10000000_00000000; // permit_ipsum_matrix_o[15] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[16]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[16];
            permit_ipsum_matrix_o = 32'b00000000_00000001_00000000_00000000; // permit_ipsum_matrix_o[16] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[17]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[17];
            permit_ipsum_matrix_o = 32'b00000000_00000010_00000000_00000000; // permit_ipsum_matrix_o[17] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[18]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[18];
            permit_ipsum_matrix_o = 32'b00000000_00000100_00000000_00000000; // permit_ipsum_matrix_o[18] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[19]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[19];
            permit_ipsum_matrix_o = 32'b00000000_00001000_00000000_00000000; // permit_ipsum_matrix_o[19] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[20]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[20];
            permit_ipsum_matrix_o = 32'b00000000_00010000_00000000_00000000; // permit_ipsum_matrix_o[20] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[21]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[21];
            permit_ipsum_matrix_o = 32'b00000000_00100000_00000000_00000000; // permit_ipsum_matrix_o[21] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[22]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[22];
            permit_ipsum_matrix_o = 32'b00000000_01000000_00000000_00000000; // permit_ipsum_matrix_o[22] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[23]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[23];
            permit_ipsum_matrix_o = 32'b00000000_10000000_00000000_00000000; // permit_ipsum_matrix_o[23] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[24]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[24];
            permit_ipsum_matrix_o = 32'b00000001_00000000_00000000_00000000; // permit_ipsum_matrix_o[24] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[25]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[25];
            permit_ipsum_matrix_o = 32'b00000010_00000000_00000000_00000000; // permit_ipsum_matrix_o[25] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[26]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[26];
            permit_ipsum_matrix_o = 32'b00000100_00000000_00000000_00000000; // permit_ipsum_matrix_o[26] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[27]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[27];
            permit_ipsum_matrix_o = 32'b00001000_00000000_00000000_00000000; // permit_ipsum_matrix_o[27] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[28]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[28];
            permit_ipsum_matrix_o = 32'b00010000_00000000_00000000_00000000; // permit_ipsum_matrix_o[28] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[29]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[29];
            permit_ipsum_matrix_o = 32'b00100000_00000000_00000000_00000000; // permit_ipsum_matrix_o[29] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[30]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[30];
            permit_ipsum_matrix_o = 32'b01000000_00000000_00000000_00000000; // permit_ipsum_matrix_o[30] = 1'b1
        end
        else if (ipsum_read_req_matrix_i[31]) begin
            glb_read_o  = 1'b1;
            glb_read_addr = ipsum_read_addr_matrix_i[31];
            permit_ipsum_matrix_o = 32'b10000000_00000000_00000000_00000000; // permit_ipsum_matrix_o[31] = 1'b1
        end
        else begin
            glb_read_o  = 1'b0;
            glb_read_addr = 32'd0;
            permit_ifmap_matrix_o  = 32'd0;
            permit_ipsum_matrix_o  = 32'd0;
        end
    end
end




endmodule
