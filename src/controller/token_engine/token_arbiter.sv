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
    integer i, j, k;
    always_comb begin
        for (i = 0; i < 32; i++) begin
            if (opsum_write_req_vec[i]) begin
                glb_write_req  = 1;
                glb_write_addr = opsum_write_addr_vec[i];
                glb_write_web  = opsum_write_web_vec[i];
                permit_opsum[i] = 1;
            end
        end
    end

    // Priority Read: ifmap second
    always_comb begin
        if (!glb_write_req) begin
            for (j = 0; j < 32; j++) begin
                if (ifmap_read_req_vec[j]) begin
                    glb_read_req  = 1;
                    glb_read_addr = ifmap_read_addr_vec[j];
                    permit_ifmap[j] = 1;
                end
            end
        end
    end

    // Priority Read: ipsum last
    always_comb begin
        if (!glb_write_req && !glb_read_req) begin
            for (k = 0; k < 32; k++) begin
                if (ipsum_read_req_vec[k]) begin
                    glb_read_req  = 1;
                    glb_read_addr = ipsum_read_addr_vec[k];
                    permit_ipsum[k] = 1;
                end
            end
        end
    end

endmodule
