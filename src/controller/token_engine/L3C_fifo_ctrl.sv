module L3_fifo_ctrl #(
    parameter int IC_MAX = 32,
    parameter int OC_MAX = 32
)(
    input  logic        clk,
    input  logic        rst_n,

    //======== L2 控制訊號 (每條 FIFO 的需求與 reset 控制) ========
    input  logic [IC_MAX-1:0] ifmap_need_push,
    input  logic [IC_MAX-1:0] ifmap_need_pop,
    input  logic [IC_MAX-1:0] ifmap_permit_push,
    input  logic [IC_MAX-1:0] ifmap_fifo_full,
    input  logic [IC_MAX-1:0] ifmap_fifo_empty,
    input  logic [IC_MAX-1:0] ifmap_fifo_reset,
    input  logic [31:0]        ifmap_glb_base_addr,

    input  logic [OC_MAX-1:0] ipsum_need_push,
    input  logic [OC_MAX-1:0] ipsum_need_pop,
    input  logic [OC_MAX-1:0] ipsum_permit_push,
    input  logic [OC_MAX-1:0] ipsum_fifo_full,
    input  logic [OC_MAX-1:0] ipsum_fifo_empty,
    input  logic [OC_MAX-1:0] ipsum_fifo_reset,
    input  logic [31:0]        ipsum_glb_base_addr,

    input  logic [OC_MAX-1:0] opsum_need_push,
    input  logic [OC_MAX-1:0] opsum_need_pop,
    input  logic [OC_MAX-1:0] opsum_permit_pop,
    input  logic [OC_MAX-1:0] opsum_fifo_empty,
    input  logic [OC_MAX-1:0] opsum_fifo_reset,
    input  logic [OC_MAX-1:0][3:0] opsum_pop_web,
    input  logic [31:0]        opsum_glb_base_addr,

    //======== 控制訊號給 FIFO 本體 ========
    output logic [IC_MAX-1:0] ifmap_fifo_push_en,
    output logic [IC_MAX-1:0] ifmap_fifo_pop_en,
    output logic [IC_MAX-1:0] ifmap_fifo_reset_o,
    output logic [IC_MAX-1:0] ifmap_glb_read_req,
    output logic [IC_MAX-1:0][31:0] ifmap_glb_read_addr,

    output logic [OC_MAX-1:0] ipsum_fifo_push_en,
    output logic [OC_MAX-1:0] ipsum_fifo_pop_en,
    output logic [OC_MAX-1:0] ipsum_fifo_reset_o,
    output logic [OC_MAX-1:0] ipsum_glb_read_req,
    output logic [OC_MAX-1:0][31:0] ipsum_glb_read_addr,

    output logic [OC_MAX-1:0] opsum_fifo_pop_en,
    output logic [OC_MAX-1:0] opsum_fifo_push_en,
    output logic [OC_MAX-1:0] opsum_fifo_reset_o,
    output logic [OC_MAX-1:0] opsum_glb_write_req,
    output logic [OC_MAX-1:0][31:0] opsum_glb_write_addr,
    output logic [OC_MAX-1:0][3:0] opsum_glb_write_web
);

    genvar i;
    generate
        for (i = 0; i < IC_MAX; i++) begin : IFMAP_CTRL
            ifmap_fifo_ctrl u_ifmap_ctrl (
                .clk(clk),
                .rst_n(rst_n),
                .ifmap_fifo_reset_i(ifmap_fifo_reset[i]),
                .ifmap_need_push_i(ifmap_need_push[i]),
                .ifmap_need_pop_i(ifmap_need_pop[i]),
                .ifmap_permit_push_i(ifmap_permit_push[i]),
                .ifmap_fifo_full_i(ifmap_fifo_full[i]),
                .ifmap_fifo_empty_i(ifmap_fifo_empty[i]),
                .ifmap_glb_base_addr_i(ifmap_glb_base_addr),
                .ifmap_fifo_reset_o(ifmap_fifo_reset_o[i]),
                .ifmap_fifo_push_en_o(ifmap_fifo_push_en[i]),
                .ifmap_fifo_pop_en_o(ifmap_fifo_pop_en[i]),
                .ifmap_glb_read_req_o(ifmap_glb_read_req[i]),
                .ifmap_glb_read_addr_o(ifmap_glb_read_addr[i])
            );
        end

        for (i = 0; i < OC_MAX; i++) begin : IPSUM_CTRL
            ipsum_fifo_ctrl u_ipsum_ctrl (
                .clk(clk),
                .rst_n(rst_n),
                .ipsum_fifo_reset_i(ipsum_fifo_reset[i]),
                .ipsum_need_push_i(ipsum_need_push[i]),
                .ipsum_need_pop_i(ipsum_need_pop[i]),
                .ipsum_permit_push_i(ipsum_permit_push[i]),
                .ipsum_fifo_full_i(ipsum_fifo_full[i]),
                .ipsum_fifo_empty_i(ipsum_fifo_empty[i]),
                .ipsum_glb_base_addr_i(ipsum_glb_base_addr),
                .ipsum_fifo_reset_o(ipsum_fifo_reset_o[i]),
                .ipsum_fifo_push_en_o(ipsum_fifo_push_en[i]),
                .ipsum_fifo_pop_en_o(ipsum_fifo_pop_en[i]),
                .ipsum_glb_read_req_o(ipsum_glb_read_req[i]),
                .ipsum_glb_read_addr_o(ipsum_glb_read_addr[i])
            );
        end

        for (i = 0; i < OC_MAX; i++) begin : OPSUM_CTRL
            opsum_fifo_ctrl u_opsum_ctrl (
                .clk(clk),
                .rst_n(rst_n),
                .opsum_fifo_reset_i(opsum_fifo_reset[i]),
                .opsum_need_push_i(opsum_need_push[i]),
                .opsum_need_pop_i(opsum_need_pop[i]),
                .opsum_permit_pop_i(opsum_permit_pop[i]),
                .opsum_fifo_empty_i(opsum_fifo_empty[i]),
                .opsum_glb_base_addr_i(opsum_glb_base_addr),
                .opsum_pop_web_i(opsum_pop_web[i]),
                .opsum_fifo_reset_o(opsum_fifo_reset_o[i]),
                .opsum_fifo_push_en_o(opsum_fifo_push_en[i]),
                .opsum_fifo_pop_en_o(opsum_fifo_pop_en[i]),
                .opsum_glb_write_req_o(opsum_glb_write_req[i]),
                .opsum_glb_write_addr_o(opsum_glb_write_addr[i]),
                .opsum_glb_write_web_o(opsum_glb_write_web[i])
            );
        end
    endgenerate

endmodule
