module L3C_fifo_ctrl #(
    parameter int IC_MAX = 32,
    parameter int OC_MAX = 32
)(
    input  logic        clk,
    input  logic        rst_n,

    // Busy Signals
    input  logic        fifo_glb_busy_i, // FIFO <=> GLB 是否忙碌

    // Reset Control for FIFOs
    input  logic        ifmap_fifo_reset_i,
    input  logic        ipsum_fifo_reset_i,
    input  logic        opsum_fifo_reset_i,

    // todo: opsum_fifo_push_mask
    input logic [31:0] opsum_fifo_push_mask_i,

    // L2 Needs (Pop Requests)
    input  logic [31:0] ifmap_need_pop_matrix_i,
    input  logic [31:0] ifmap_pop_num_matrix_i [31:0],

    input  logic [31:0] ipsum_need_pop_matrix_i,
    input  logic [31:0] ipsum_pop_num_matrix_i [31:0],

    input logic [31:0] opsum_need_push_matrix_i,
    input logic [31:0] opsum_push_num_matrix_i [31:0],

    // FIFO Status (Full/Empty)
    input  logic [31:0] ifmap_fifo_full_matrix_i,
    input  logic [31:0] ifmap_fifo_empty_matrix_i,
    input  logic [31:0] ipsum_fifo_full_matrix_i,
    input  logic [31:0] ipsum_fifo_empty_matrix_i,
    input  logic [31:0] opsum_fifo_full_matrix_i,
    input  logic [31:0] opsum_fifo_empty_matrix_i,

    // Base Address for FIFOs
    input  logic [31:0] ifmap_fifo_base_addr_matrix_i [31:0],
    input  logic [31:0] ipsum_fifo_base_addr_matrix_i [31:0],
    input  logic [31:0] opsum_fifo_base_addr_matrix_i [31:0],

    // Arbiter Permits
    input  logic [31:0] ifmap_permit_push_matrix_i,
    input  logic [31:0] ipsum_permit_push_matrix_i,
    input  logic [31:0] opsum_permit_pop_matrix_i,

    // Global Buffer Read Data
    input  logic [31:0] ifmap_glb_read_data_i,
    input  logic [31:0] ipsum_glb_read_data_i,

    // Outputs to FIFOs
    output logic [31:0] ifmap_fifo_push_matrix_o,
    output logic [31:0] ifmap_fifo_push_mod_matrix_o,
    output logic [31:0] ifmap_fifo_push_data_matrix_o [31:0],
    output logic [31:0] ifmap_fifo_pop_matrix_o,

    output logic [31:0] ipsum_fifo_push_matrix_o,
    output logic [31:0] ipsum_fifo_push_mod_matrix_o,
    output logic [31:0] ipsum_fifo_push_data_matrix_o [31:0],
    output logic [31:0] ipsum_fifo_pop_matrix_o,

    output logic [31:0] opsum_fifo_push_matrix_o,
    output logic [31:0] opsum_fifo_pop_matrix_o,
    output logic [31:0] opsum_fifo_pop_mod_matrix_o,

    // Outputs to Arbiter
    output logic [31:0] ifmap_read_req_matrix_o,
    output logic [31:0] ifmap_glb_read_addr_matrix_o [31:0],

    output logic [31:0] ipsum_read_req_matrix_o,
    output logic [31:0] ipsum_glb_read_addr_matrix_o [31:0],

    output logic [31:0] opsum_glb_write_req_matrix_o,
    output logic [31:0] opsum_glb_write_addr_matrix_o [31:0],
    output logic [3:0]  opsum_glb_write_web_matrix_o [31:0],

    // Done Signals
    output logic [31:0] ifmap_fifo_done_matrix_o,
    output logic [31:0] ipsum_fifo_done_matrix_o,
    output logic [31:0] opsum_fifo_done_matrix_o
);

genvar i;
generate
    for (i = 0; i < 32; i++) begin : IFMAP_CTRL
        ifmap_fifo_ctrl u_ifmap_fifo_ctrl (
            .clk(clk),
            .rst_n(rst_n),
            //* busy
            .fifo_glb_busy_i(fifo_glb_busy_i),
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
            .ifmap_fifo_pop_o(ifmap_fifo_pop_matrix_o[i]),
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
        ipsum_fifo_ctrl u_ipsum_fifo_ctrl (
            .clk(clk),
            .rst_n(rst_n),
            //* busy
            .fifo_glb_busy_i(fifo_glb_busy_i), // FIFO <=> GLB 是否忙碌
            // From L2 Controller
            .ipsum_fifo_reset_i(ipsum_fifo_reset_i), // Reset FIFO
            .ipsum_need_pop_i(ipsum_need_pop_matrix_i[i]),   // 新任務觸發
            .ipsum_pop_num_i(ipsum_pop_num_matrix_i[i]),    // 本次需 pop 幾次
            // From Arbiter
            .ipsum_permit_push_i(ipsum_permit_push_matrix_i[i]),
            // FIFO state
            .ipsum_fifo_full_i(ipsum_fifo_full_matrix_i[i]),
            .ipsum_fifo_empty_i(ipsum_fifo_empty_matrix_i[i]),
            // GLB base address
            .ipsum_fifo_base_addr_i(ipsum_fifo_base_addr_matrix_i[i]),
            .ipsum_glb_read_data_i(ipsum_glb_read_data_i),
            // to FIFO
            .ipsum_fifo_push_o(ipsum_fifo_push_matrix_o[i]),
            .ipsum_fifo_push_data_o(ipsum_fifo_push_data_matrix_o[i]),
            .ipsum_fifo_push_mod_o(ipsum_fifo_push_mod_matrix_o[i]),
            
            .ipsum_fifo_pop_o(ipsum_fifo_pop_matrix_o[i]),
            // Arbiter
            .ipsum_read_req_o(ipsum_read_req_matrix_o[i]),
            .ipsum_glb_read_addr_o(ipsum_glb_read_addr_matrix_o[i]),
            // to L2C Task done signal
            .ipsum_fifo_done_o(ipsum_fifo_done_matrix_o[i])
            );
    end
endgenerate

logic pe_array_move_i;



generate
    for (i = 0; i < 32; i++) begin : OPSUM_CTRL
        opsum_fifo_ctrl u_opsum_fifo_ctrl (
            .clk(clk),
            .rst_n(rst_n),

            .fifo_glb_busy_i(fifo_glb_busy_i),
            .opsum_fifo_reset_i(opsum_fifo_reset_i),

            .opsum_need_push_i(opsum_need_push_matrix_i[i]),
            .opsum_push_num_i(opsum_push_num_matrix_i[i]),

            .opsum_fifo_push_mask_i(opsum_fifo_push_mask_i[i]), // fixme
            .pe_array_move_i(pe_array_move_i), // fixme

            .opsum_permit_pop_i(opsum_permit_pop_matrix_i[i]),

            .opsum_fifo_empty_i(opsum_fifo_empty_matrix_i[i]),
            .opsum_fifo_full_i(opsum_fifo_full_matrix_i[i]),

            .opsum_glb_base_addr_i(opsum_fifo_base_addr_matrix_i[i]),
            .opsum_fifo_push_o(opsum_fifo_push_matrix_o[i]),
            .opsum_fifo_pop_o(opsum_fifo_pop_matrix_o[i]),

            .opsum_write_req_o(opsum_glb_write_req_matrix_o[i]),
            .opsum_glb_write_addr_o(opsum_glb_write_addr_matrix_o[i]),
            .opsum_glb_write_web_o(opsum_glb_write_web_matrix_o[i]),

            .opsum_fifo_done_o(opsum_fifo_done_matrix_o[i])
        );
    end
endgenerate


endmodule
