module token_arbiter (
    input  logic [31:0] opsum_write_req_vec,
    input  logic [31:0] ifmap_read_req_vec,
    input  logic [31:0] ipsum_read_req_vec,

    input  logic [31:0] ifmap_read_addr_vec [31:0],
    input  logic [31:0] ipsum_read_addr_vec [31:0],
    input  logic [31:0] opsum_write_addr_vec [31:0],
    input  logic [3:0]  opsum_write_web_vec   [31:0],

    output logic        glb_read_req,
    output logic [31:0] glb_read_addr,
    output logic        glb_write_req,
    output logic [31:0] glb_write_addr,
    output logic [3:0]  glb_write_web,

    output logic [31:0] permit_ifmap,
    output logic [31:0] permit_ipsum,
    output logic [31:0] permit_opsum
);

// Priority Write: opsum first
always_comb begin
    glb_write_req  = 1'b0;
    glb_write_addr = 32'd0;
    glb_write_web  = 4'd0;
    permit_opsum   = 32'd0;
    if (opsum_write_req_vec[0]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[0];
        glb_write_web  = opsum_write_web_vec[0];
        permit_opsum[0] = 1'b1;
    end
    else if (opsum_write_req_vec[1]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[1];
        glb_write_web  = opsum_write_web_vec[1];
        permit_opsum[1] = 1'b1;
    end
    else if (opsum_write_req_vec[2]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[2];
        glb_write_web  = opsum_write_web_vec[2];
        permit_opsum[2] = 1'b1;
    end
    else if (opsum_write_req_vec[3]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[3];
        glb_write_web  = opsum_write_web_vec[3];
        permit_opsum[3] = 1'b1;
    end
    else if (opsum_write_req_vec[4]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[4];
        glb_write_web  = opsum_write_web_vec[4];
        permit_opsum[4] = 1'b1;
    end
    else if (opsum_write_req_vec[5]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[5];
        glb_write_web  = opsum_write_web_vec[5];
        permit_opsum[5] = 1'b1;
    end
    else if (opsum_write_req_vec[6]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[6];
        glb_write_web  = opsum_write_web_vec[6];
        permit_opsum[6] = 1'b1;
    end
    else if (opsum_write_req_vec[7]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[7];
        glb_write_web  = opsum_write_web_vec[7];
        permit_opsum[7] = 1'b1;
    end
    else if (opsum_write_req_vec[8]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[8];
        glb_write_web  = opsum_write_web_vec[8];
        permit_opsum[8] = 1'b1;
    end
    else if (opsum_write_req_vec[9]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[9];
        glb_write_web  = opsum_write_web_vec[9];
        permit_opsum[9] = 1'b1;
    end
    else if (opsum_write_req_vec[10]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[10];
        glb_write_web  = opsum_write_web_vec[10];
        permit_opsum[10] = 1'b1;
    end
    else if (opsum_write_req_vec[11]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[11];
        glb_write_web  = opsum_write_web_vec[11];
        permit_opsum[11] = 1'b1;
    end
    else if (opsum_write_req_vec[12]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[12];
        glb_write_web  = opsum_write_web_vec[12];
        permit_opsum[12] = 1'b1;
    end
    else if (opsum_write_req_vec[13]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[13];
        glb_write_web  = opsum_write_web_vec[13];
        permit_opsum[13] = 1'b1;
    end
    else if (opsum_write_req_vec[14]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[14];
        glb_write_web  = opsum_write_web_vec[14];
        permit_opsum[14] = 1'b1;
    end
    else if (opsum_write_req_vec[15]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[15];
        glb_write_web  = opsum_write_web_vec[15];
        permit_opsum[15] = 1'b1;
    end
    else if (opsum_write_req_vec[16]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[16];
        glb_write_web  = opsum_write_web_vec[16];
        permit_opsum[16] = 1'b1;
    end
    else if (opsum_write_req_vec[17]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[17];
        glb_write_web  = opsum_write_web_vec[17];
        permit_opsum[17] = 1'b1;
    end
    else if (opsum_write_req_vec[18]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[18];
        glb_write_web  = opsum_write_web_vec[18];
        permit_opsum[18] = 1'b1;
    end
    else if (opsum_write_req_vec[19]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[19];
        glb_write_web  = opsum_write_web_vec[19];
        permit_opsum[19] = 1'b1;
    end
    else if (opsum_write_req_vec[20]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[20];
        glb_write_web  = opsum_write_web_vec[20];
        permit_opsum[20] = 1'b1;
    end
    else if (opsum_write_req_vec[21]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[21];
        glb_write_web  = opsum_write_web_vec[21];
        permit_opsum[21] = 1'b1;
    end
    else if (opsum_write_req_vec[22]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[22];
        glb_write_web  = opsum_write_web_vec[22];
        permit_opsum[22] = 1'b1;
    end
    else if (opsum_write_req_vec[23]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[23];
        glb_write_web  = opsum_write_web_vec[23];
        permit_opsum[23] = 1'b1;
    end
    else if (opsum_write_req_vec[24]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[24];
        glb_write_web  = opsum_write_web_vec[24];
        permit_opsum[24] = 1'b1;
    end
    else if (opsum_write_req_vec[25]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[25];
        glb_write_web  = opsum_write_web_vec[25];
        permit_opsum[25] = 1'b1;
    end
    else if (opsum_write_req_vec[26]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[26];
        glb_write_web  = opsum_write_web_vec[26];
        permit_opsum[26] = 1'b1;
    end
    else if (opsum_write_req_vec[27]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[27];
        glb_write_web  = opsum_write_web_vec[27];
        permit_opsum[27] = 1'b1;
    end
    else if (opsum_write_req_vec[28]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[28];
        glb_write_web  = opsum_write_web_vec[28];
        permit_opsum[28] = 1'b1;
    end
    else if (opsum_write_req_vec[29]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[29];
        glb_write_web  = opsum_write_web_vec[29];
        permit_opsum[29] = 1'b1;
    end
    else if (opsum_write_req_vec[30]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[30];
        glb_write_web  = opsum_write_web_vec[30];
        permit_opsum[30] = 1'b1;
    end
    else if (opsum_write_req_vec[31]) begin
        glb_write_req  = 1'b1;
        glb_write_addr = opsum_write_addr_vec[31];
        glb_write_web  = opsum_write_web_vec[31];
        permit_opsum[31] = 1'b1;
    end
    else begin
        glb_write_req  = 1'b0;
        glb_write_addr = 32'd0;
        glb_write_web  = 4'd0;
        permit_opsum   = 32'd0;
    end
end

// Priority Read: else ifmap second
always_comb begin
    glb_read_req  = 1'b0;
    glb_read_addr = 32'd0;
    permit_ifmap  = 32'd0;
    if (!glb_write_req) begin
        if (ifmap_read_req_vec[0]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[0];
            permit_ifmap[0] = 1'b1;
        end
        else if (ifmap_read_req_vec[1]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[1];
            permit_ifmap[1] = 1'b1;
        end
        else if (ifmap_read_req_vec[2]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[2];
            permit_ifmap[2] = 1'b1;
        end
        else if (ifmap_read_req_vec[3]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[3];
            permit_ifmap[3] = 1'b1;
        end
        else if (ifmap_read_req_vec[4]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[4];
            permit_ifmap[4] = 1'b1;
        end
        else if (ifmap_read_req_vec[5]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[5];
            permit_ifmap[5] = 1'b1;
        end
        else if (ifmap_read_req_vec[6]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[6];
            permit_ifmap[6] = 1'b1;
        end
        else if (ifmap_read_req_vec[7]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[7];
            permit_ifmap[7] = 1'b1;
        end
        else if (ifmap_read_req_vec[8]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[8];
            permit_ifmap[8] = 1'b1;
        end
        else if (ifmap_read_req_vec[9]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[9];
            permit_ifmap[9] = 1'b1;
        end
        else if (ifmap_read_req_vec[10]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[10];
            permit_ifmap[10] = 1'b1;
        end
        else if (ifmap_read_req_vec[11]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[11];
            permit_ifmap[11] = 1'b1;
        end
        else if (ifmap_read_req_vec[12]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[12];
            permit_ifmap[12] = 1'b1;
        end
        else if (ifmap_read_req_vec[13]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[13];
            permit_ifmap[13] = 1'b1;
        end
        else if (ifmap_read_req_vec[14]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[14];
            permit_ifmap[14] = 1'b1;
        end
        else if (ifmap_read_req_vec[15]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[15];
            permit_ifmap[15] = 1'b1;
        end
        else if (ifmap_read_req_vec[16]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[16];
            permit_ifmap[16] = 1'b1;
        end
        else if (ifmap_read_req_vec[17]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[17];
            permit_ifmap[17] = 1'b1;
        end
        else if (ifmap_read_req_vec[18]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[18];
            permit_ifmap[18] = 1'b1;
        end
        else if (ifmap_read_req_vec[19]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[19];
            permit_ifmap[19] = 1'b1;
        end
        else if (ifmap_read_req_vec[20]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[20];
            permit_ifmap[20] = 1'b1;
        end
        else if (ifmap_read_req_vec[21]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[21];
            permit_ifmap[21] = 1'b1;
        end
        else if (ifmap_read_req_vec[22]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[22];
            permit_ifmap[22] = 1'b1;
        end
        else if (ifmap_read_req_vec[23]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[23];
            permit_ifmap[23] = 1'b1;
        end
        else if (ifmap_read_req_vec[24]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[24];
            permit_ifmap[24] = 1'b1;
        end
        else if (ifmap_read_req_vec[25]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[25];
            permit_ifmap[25] = 1'b1;
        end
        else if (ifmap_read_req_vec[26]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[26];
            permit_ifmap[26] = 1'b1;
        end
        else if (ifmap_read_req_vec[27]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[27];
            permit_ifmap[27] = 1'b1;
        end
        else if (ifmap_read_req_vec[28]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[28];
            permit_ifmap[28] = 1'b1;
        end
        else if (ifmap_read_req_vec[29]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[29];
            permit_ifmap[29] = 1'b1;
        end
        else if (ifmap_read_req_vec[30]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[30];
            permit_ifmap[30] = 1'b1;
        end
        else if (ifmap_read_req_vec[31]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ifmap_read_addr_vec[31];
            permit_ifmap[31] = 1'b1;
        end
        else begin
            glb_read_req  = 1'b0;
            glb_read_addr = 32'd0;
            permit_ifmap  = 32'd0;
        end
    end
    else begin
        glb_read_req  = 1'b0;
        glb_read_addr = 32'd0;
        permit_ifmap  = 32'd0;
    end
end

// Priority Read: ipsum last
always_comb begin
    glb_read_req  = 1'b0;
    glb_read_addr = 32'd0;
    permit_ipsum  = 32'd0;
    if (!glb_write_req && !glb_read_req) begin
        if (ipsum_read_req_vec[0]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[0];
            permit_ipsum[0] = 1'b1;
        end
        else if (ipsum_read_req_vec[1]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[1];
            permit_ipsum[1] = 1'b1;
        end
        else if (ipsum_read_req_vec[2]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[2];
            permit_ipsum[2] = 1'b1;
        end
        else if (ipsum_read_req_vec[3]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[3];
            permit_ipsum[3] = 1'b1;
        end
        else if (ipsum_read_req_vec[4]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[4];
            permit_ipsum[4] = 1'b1;
        end
        else if (ipsum_read_req_vec[5]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[5];
            permit_ipsum[5] = 1'b1;
        end
        else if (ipsum_read_req_vec[6]) begin
            glb_read_req = 1;
            glb_read_addr = ipsum_read_addr_vec[6];
            permit_ipsum[6] = 1'b1;
        end
        else if (ipsum_read_req_vec[7]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[7];
            permit_ipsum[7] = 1'b1;
        end
        else if (ipsum_read_req_vec[8]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[8];
            permit_ipsum[8] = 1'b1;
        end
        else if (ipsum_read_req_vec[9]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[9];
            permit_ipsum[9] = 1'b1;
        end
        else if (ipsum_read_req_vec[10]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[10];
            permit_ipsum[10] = 1'b1;
        end
        else if (ipsum_read_req_vec[11]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[11];
            permit_ipsum[11] = 1'b1;
        end
        else if (ipsum_read_req_vec[12]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[12];
            permit_ipsum[12] = 1'b1;
        end
        else if (ipsum_read_req_vec[13]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[13];
            permit_ipsum[13] = 1'b1;
        end
        else if (ipsum_read_req_vec[14]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[14];
            permit_ipsum[14] = 1'b1;
        end
        else if (ipsum_read_req_vec[15]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[15];
            permit_ipsum[15] = 1'b1;
        end
        else if (ipsum_read_req_vec[16]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[16];
            permit_ipsum[16] = 1'b1;
        end
        else if (ipsum_read_req_vec[17]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[17];
            permit_ipsum[17] = 1'b1;
        end
        else if (ipsum_read_req_vec[18]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[18];
            permit_ipsum[18] = 1'b1;
        end
        else if (ipsum_read_req_vec[19]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[19];
            permit_ipsum[19] = 1'b1;
        end
        else if (ipsum_read_req_vec[20]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[20];
            permit_ipsum[20] = 1'b1;
        end
        else if (ipsum_read_req_vec[21]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[21];
            permit_ipsum[21] = 1'b1;
        end
        else if (ipsum_read_req_vec[22]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[22];
            permit_ipsum[22] = 1'b1;
        end
        else if (ipsum_read_req_vec[23]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[23];
            permit_ipsum[23] = 1'b1;
        end
        else if (ipsum_read_req_vec[24]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[24];
            permit_ipsum[24] = 1'b1;
        end
        else if (ipsum_read_req_vec[25]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[25];
            permit_ipsum[25] = 1'b1;
        end
        else if (ipsum_read_req_vec[26]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[26];
            permit_ipsum[26] = 1'b1;
        end
        else if (ipsum_read_req_vec[27]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[27];
            permit_ipsum[27] = 1'b1;
        end
        else if (ipsum_read_req_vec[28]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[28];
            permit_ipsum[28] = 1'b1;
        end
        else if (ipsum_read_req_vec[29]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[29];
            permit_ipsum[29] = 1'b1;
        end
        else if (ipsum_read_req_vec[30]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[30];
            permit_ipsum[30] = 1'b1;
        end
        else if (ipsum_read_req_vec[31]) begin
            glb_read_req  = 1'b1;
            glb_read_addr = ipsum_read_addr_vec[31];
            permit_ipsum[31] = 1'b1;
        end
        else begin
            glb_read_req  = 1'b0;
            glb_read_addr = 32'd0;
            permit_ipsum  = 32'd0;
        end
    end
    else begin
        glb_read_req  = 1'b0;
        glb_read_addr = 32'd0;
        permit_ipsum  = 32'd0;
    end
end




endmodule
