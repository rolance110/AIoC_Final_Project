module L3C_fifo_ctrl #(
    parameter int IC_MAX = 32,
    parameter int OC_MAX = 32
)(
    input  logic        clk,
    input  logic        rst_n,

    //======== L2 控制訊號 (每條 FIFO 的需求與 reset 控制) ========
    input  logic ifmap_fifo_reset_i,
    input  logic [31:0] ifmap_need_pop_matrix_i,
    input  logic [31:0] ifmap_pop_num_matrix_i [31:0],
    input  logic [31:0] ifmap_permit_push_matrix_i,
    input  logic [31:0] ifmap_fifo_full_matrix_i,
    input  logic [31:0] ifmap_fifo_empty_matrix_i,
    input  logic [31:0] ifmap_fifo_base_addr_matrix_i [31:0],
    input  logic [31:0] ifmap_glb_read_data_i , // read 1 data 1 time

    input  logic [31:0] ipsum_need_push_matrix_i,
    input  logic [31:0] ipsum_need_pop_matrix_i,
    input  logic [31:0] ipsum_permit_push_matrix_i,
    input  logic [31:0] ipsum_fifo_full_matrix_i,
    input  logic [31:0] ipsum_fifo_empty_matrix_i,
    input  logic ipsum_fifo_reset_i,
    input  logic [31:0] ipsum_fifo_base_addr_matrix_i [31:0],

    input  logic [31:0] opsum_need_push_matrix_i,
    input  logic [31:0] opsum_need_pop_matrix_i,
    input  logic [31:0] opsum_permit_pop_matrix_i,
    input  logic [31:0] opsum_fifo_empty_matrix_i,
    input  logic [31:0] opsum_fifo_full_matrix_i,
    input  logic opsum_fifo_reset_i,
    input  logic [31:0] opsum_fifo_base_addr_matrix_i [31:0],
    
    //======== 控制訊號給 FIFO 本體 ========
    output logic [31:0] ifmap_fifo_push_matrix_o,
    output logic [31:0] ifmap_fifo_push_data_matrix_o [31:0],
    output logic [31:0] ifmap_fifo_push_mod_matrix_o,
    output logic [31:0] ifmap_fifo_pop_matrix_o,
    output logic [31:0] ifmap_read_req_matrix_o,
    output logic [31:0] ifmap_glb_read_addr_matrix_o [31:0],
    output logic [31:0] ifmap_fifo_done_matrix_o,



    output logic [31:0] ipsum_fifo_push_matrix_o,
    output logic [31:0] ipsum_fifo_pop_matrix_o,
    output logic [31:0] ipsum_glb_read_req_matrix_o,
    output logic [31:0] ipsum_glb_read_addr_matrix_o [31:0],

    output logic [31:0] opsum_fifo_pop_matrix_o,
    output logic [31:0] opsum_fifo_push_matrix_o,
    output logic [31:0] opsum_glb_write_req_matrix_o,
    output logic [31:0] opsum_glb_write_addr_matrix_o [31:0],
    output logic [3:0] opsum_glb_write_web_matrix_o [31:0]
);

genvar i;
generate
    for (i = 0; i < 32; i++) begin : IFMAP_CTRL
        ifmap_fifo_ctrl u_ifmap_fifo_ctrl (
            .clk(clk),
            .rst_n(rst_n),
            // From L2 Controller
            .ifmap_fifo_reset_i(ifmap_fifo_reset_i), // Reset FIFO
            .ifmap_need_pop_i(ifmap_need_pop_matrix_i[i]),   // 新任務觸發
            .ifmap_pop_num_i(ifmap_pop_num_matrix_i[i]),    // 本次需 pop 幾次
            // From Arbiter
            .ifmap_permit_push_i(ifmap_permit_push_matrix_i[i]),
            // FIFO state
            .ifmap_fifo_full_i(ifmap_fifo_full_matrix_i[i]),
            .ifmap_fifo_empty_i(ifmap_fifo_empty_matrix_i[i]),
            // GLB base address
            .ifmap_fifo_base_addr_i(ifmap_fifo_base_addr_matrix_i[i]),
            .ifmap_glb_read_data_i(ifmap_glb_read_data_i),
            // to FIFO
            .ifmap_fifo_push_o(ifmap_fifo_push_matrix_o[i]),
            .ifmap_fifo_push_data_o(ifmap_fifo_push_data_matrix_o[i]),
            .ifmap_fifo_push_mod_o(ifmap_fifo_push_mod_matrix_o[i]),
            .ifmap_fifo_pop_en_o(ifmap_fifo_pop_matrix_o[i]),
            // Arbiter
            .ifmap_read_req_o(ifmap_read_req_matrix_o[i]),
            .ifmap_glb_read_addr_o(ifmap_glb_read_addr_matrix_o[i]),
            // to L2C Task done signal
            .ifmap_fifo_done_o(ifmap_fifo_done_matrix_o[i])
            );
    end
endgenerate


generate
    for (i = 0; i < 32; i++) begin : IPSUM_CTRL
        ipsum_fifo_ctrl u_ipsum_ctrl (
            .clk(clk),
            .rst_n(rst_n),
            .ipsum_fifo_reset_i(ipsum_fifo_reset_i),
            .ipsum_need_push_i(ipsum_need_push_matrix_i[i]),
            .ipsum_need_pop_i(ipsum_need_pop_matrix_i[i]),
            .ipsum_permit_push_i(ipsum_permit_push_matrix_i[i]),
            .ipsum_fifo_full_i(ipsum_fifo_full_matrix_i[i]),
            .ipsum_fifo_empty_i(ipsum_fifo_empty_matrix_i[i]),
            .ipsum_fifo_base_addr_i(ipsum_fifo_base_addr_matrix_i[i]),
            .ipsum_fifo_push_o(ipsum_fifo_push_matrix_o[i]),
            .ipsum_fifo_pop_o(ipsum_fifo_pop_matrix_o[i]),
            .ipsum_glb_read_req_o(ipsum_glb_read_req_matrix_o[i]),
            .ipsum_glb_read_addr_o(ipsum_glb_read_addr_matrix_o[i])
        );
    end
endgenerate



generate
    for (i = 0; i < 32; i++) begin : OPSUM_CTRL
        opsum_fifo_ctrl u_opsum_ctrl (
            .clk(clk),
            .rst_n(rst_n),
            .opsum_fifo_reset_i(opsum_fifo_reset),
            .opsum_need_push_i(opsum_need_push_matrix_i[i]),
            .opsum_need_pop_i(opsum_need_pop_matrix_i[i]),
            .opsum_permit_pop_i(opsum_permit_pop_matrix_i[i]),
            .opsum_fifo_empty_i(opsum_fifo_empty_matrix_i[i]),
            .opsum_fifo_base_addr_i(opsum_fifo_base_addr_matrix_i[i]),
            .opsum_fifo_push_o(opsum_fifo_push_matrix_o[i]),
            .opsum_fifo_pop_o(opsum_fifo_pop_matrix_o[i]),
            .opsum_glb_write_req_o(opsum_glb_write_req_matrix_o[i]),
            .opsum_glb_write_addr_o(opsum_glb_write_addr_matrix_o[i]),
            .opsum_glb_write_web_o(opsum_glb_write_web_matrix_o[i])
        );
    end
endgenerate

endmodule
