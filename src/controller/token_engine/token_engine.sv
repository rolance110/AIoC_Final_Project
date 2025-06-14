`include "weight_load_controller.sv"
`include "pe_array_controller.sv"
`include "L2C_init_fifo_pe.sv"
`include "L2C_preheat.sv"
`include "L3C_fifo_ctrl.sv"
`include "token_arbiter.sv"
`include "../../../include/define.svh"

module token_engine (
    input  logic         clk,
    input  logic         rst_n,

    // 啟動控制
    input  logic         pass_start_i,
    output logic         pass_done_o,

    // 來自 Layer Decoder 的資訊（tile_K, tile_D, layer_type, stride, ...）
    input  logic [1:0]   layer_type_i,

    input logic  [31:0] weight_GLB_base_addr,
    input logic  [31:0] ifmap_GLB_base_addr,
    input logic  [31:0] ipsum_GLB_base_addr,
    input logic  [31:0] bias_GLB_base_addr,
    input logic  [31:0] opsum_GLB_base_addr,

    input logic [31:0] tile_n_i,

    input logic [6:0] in_C_i,
    input logic [6:0] in_R_i,
    input logic [1:0] pad_R_i,
    input logic [1:0] pad_L_i,
    input logic [6:0] out_C_i,
    input logic [6:0] out_R_i,
    input logic [6:0] IC_real_i,
    input logic [6:0] OC_real_i,
    input logic [31:0] On_real_i,

//* to PE
    output logic PE_en_matrix [31:0][31:0],
    output logic PE_stall_matrix [31:0][31:0],

//* to GLB
    output logic [7:0]         weight_in,
    output logic [31:0][31:0]  weight_load_en,

//* ifmap fifo
    output logic [31:0]        push_ifmap_en,
    output logic [31:0]        push_ifmap_mod,
    output logic [31:0]        push_ifmap_data,
    output logic [31:0]        pop_ifmap_en,

//* ipsum fifo
    output logic [31:0]        push_ipsum_en,
    output logic [31:0]        push_ipsum_mod,
    output logic [31:0]        push_ipsum_data,
    output logic [31:0]        pop_ipsum_en,
    output logic               ipsum_read_en,
    output logic               ipsum_add_en,

//* opsum fifo
    output logic [31:0]        opsum_push_en,
    output logic [31:0]        opsum_pop_en,
    output logic [31:0]        opsum_pop_mod,

    input  logic [31:0]        ifmap_fifo_full,
    input  logic [31:0]        ifmap_fifo_empty,
    input  logic [31:0]        ipsum_fifo_full, 
    input  logic [31:0]        ipsum_fifo_empty,
    input  logic [31:0]        opsum_fifo_full,
    input  logic [31:0]        opsum_fifo_empty
);

logic weight_load_state;
logic [3:0] weight_load_WEB;
logic [31:0] weight_addr;
logic [1:0] weight_load_byte_type;
logic [31:0] ifmap_fifo_pop_en;

logic [31:0] ifmap_need_pop, ifmap_permit_push, ifmap_fifo_reset;
logic [31:0] ifmap_fifo_push_en, ifmap_fifo_reset_o;
logic [31:0] ifmap_glb_read_req, ifmap_glb_read_addr;

logic [31:0] ipsum_need_push, ipsum_need_pop, ipsum_permit_push, ipsum_fifo_reset;
logic [31:0] ipsum_fifo_push_en, ipsum_fifo_reset_o;
logic [31:0] ipsum_glb_read_req, ipsum_glb_read_addr;

logic [31:0] opsum_need_push, opsum_need_pop, opsum_permit_pop, opsum_fifo_reset;
logic [31:0] opsum_pop_web, opsum_fifo_pop_en, opsum_fifo_push_en;
logic [31:0] opsum_fifo_reset_o, opsum_glb_write_req, opsum_glb_write_addr, opsum_glb_write_web;

logic [31:0] opsum_write_req_vec, ifmap_read_req_vec, ipsum_read_req_vec;
logic [31:0] ifmap_read_addr_vec, ipsum_read_addr_vec;
logic [31:0] opsum_write_addr_vec, opsum_write_web_vec;
logic        glb_read_req, glb_write_req;
logic [31:0] glb_read_addr, glb_write_addr;
logic [3:0]  glb_read_web, glb_write_web;
logic [31:0] permit_ifmap, permit_ipsum, permit_opsum;


logic weight_load_finish;

assign ifmap_read_req_vec   = ifmap_glb_read_req;
assign ifmap_read_addr_vec  = ifmap_glb_read_addr;
assign ipsum_read_req_vec   = ipsum_glb_read_req;
assign ipsum_read_addr_vec  = ipsum_glb_read_addr;
assign opsum_write_req_vec  = opsum_glb_write_req;
assign opsum_write_addr_vec = opsum_glb_write_addr;
assign opsum_write_web_vec  = opsum_glb_write_web;

assign ifmap_permit_push = permit_ifmap;
assign ipsum_permit_push = permit_ipsum;
assign opsum_permit_pop  = permit_opsum;

assign push_ifmap_en = ifmap_fifo_push_en;
assign pop_ifmap_en  = ifmap_fifo_pop_en;
assign push_ipsum_en = ipsum_fifo_push_en;
assign pop_ipsum_en  = ipsum_fifo_pop_en;
assign opsum_pop_en  = opsum_fifo_pop_en;
assign opsum_push_en = opsum_fifo_push_en;
assign opsum_pop_mod = opsum_pop_web;

weight_load_controller weight_load_controller_dut(
    .clk(clk), .rst_n(rst_n),
    .weight_load_state(weight_load_state),
    .layer_type(layer_type_i),
    .weight_GLB_base_addr(weight_GLB_base_addr),
    .weight_load_WEB(weight_load_WEB),
    .weight_addr(weight_addr),
    .weight_load_byte_type(weight_load_byte_type),
    .weight_load_finish(weight_load_finish)
);
logic start_preheat_i;
logic start_normal_i;
logic [31:0] ifmap_fifo_pop_matrix_i;
pe_array_controller pe_array_controller(
    .clk(clk),
    .rst_n(rst_n),
//* input
    .layer_type(layer_type_i),

    .start_preheat_i(start_preheat_i), 
    .start_normal_i(start_normal_i), 

    .ifmap_fifo_pop_matrix_i(ifmap_fifo_pop_matrix_i),

//* output
    .PE_stall_matrix(PE_stall_matrix),
    .PE_en_matrix(PE_en_matrix)
);

logic preheat_done_i;
logic normal_loop_done_i;
logic init_fifo_pe_state;
logic preheat_state;
logic normal_loop_state;
//* Layer 1 Controller ==============================================
Layer1_Controller Layer1_Controller (
    .clk(clk),
    .rst_n(rst_n),
//* input
    // 啟動／完成
    .pass_start_i(pass_start_i),
    .pass_done_o(pass_done_o),

    .weight_load_done_i(weight_load_finish),
    // .init_fifo_pe_done_i(init_fifo_pe_done_i), // 1 cycle
    .preheat_done_i(preheat_done_i),
    .normal_loop_done_i(normal_loop_done_i),

//* output
    // 傳給下層 L2 的控制
    .weight_load_state(weight_load_state),   // INIT_WEIGHT
    .init_fifo_pe_state(init_fifo_pe_state),  // INIT_FIFO_PE
    .preheat_state(preheat_state),       // 下層 PREHEAT 觸發
    .normal_loop_state(normal_loop_state)  // 下層 FLOW 觸發
);


//* Layer 2 Controller ==============================================
logic [31:0] ifmap_fifo_base_addr_matrix [31:0];
logic [31:0] ipsum_fifo_base_addr_matrix [31:0];
logic [31:0] opsum_fifo_base_addr_matrix [31:0];
L2C_init_fifo_pe #(
    .NUM_FIFOz(96)
) L2C_init_fifo_pe_dut (
    .clk(clk),
    .rst_n(rst_n),
//* input
    .init_fifo_pe_state_i(init_fifo_pe_state),   // 啟動初始化
    .ifmap_glb_base_addr_i(ifmap_GLB_base_addr), // ifmap base address 由 TB 配置
    .ipsum_glb_base_addr_i(ipsum_GLB_base_addr), // ipsum FIFO base address 由 TB 配置
    .opsum_glb_base_addr_i(opsum_GLB_base_addr), // opsum FIFO base address 由 TB 配置
    .bias_glb_base_addr_i(bias_GLB_base_addr),   // bias  FIFO base address 由 TB 配置
    .is_bias(is_bias), // 判斷現在 ipsum_fifo 是要輸入 bias or ipsum

    //* From Tile_Scheduler
    .layer_type_i(layer_type_i),
    // ifmap base addr require
    .tile_n_i(tile_n_i),
    .in_C_i(in_C_i),
    .pad_R_i(pad_R_i),
    .pad_L_i(pad_L_i),
    // ofmap base addr require
    .On_real_i(On_real_i),
    .out_C_i(out_C_i),

//* output
    .ifmap_fifo_base_addr_o(ifmap_fifo_base_addr_matrix),
    .ipsum_fifo_base_addr_o(ipsum_fifo_base_addr_matrix),
    .opsum_fifo_base_addr_o(opsum_fifo_base_addr_matrix)
);

L2C_preheat #(
    .NUM_IFMAP_FIFO(32)
) L2C_preheat_dut (
    .clk(clk),
    .rst_n(rst_n),
    .start_preheat_i(start_preheat_i),
    .layer_type_i(layer_type_i),
    .ifmap_fifo_done_i(ifmap_fifo_done_i),

    .ifmap_need_pop_o(ifmap_need_pop_o),
    .ifmap_pop_num_o(ifmap_pop_num_o),
    .preheat_done_o(preheat_done_o)

);



//* Layer 3 Controller ==============================================
L3C_fifo_ctrl #(
    .IC_MAX(32),
    .OC_MAX(32)
) u_L3C_fifo_ctrl (
    .clk(clk),
    .rst_n(rst_n),
//* input
    //======== L2 控制訊號 (每條 FIFO 的需求與 reset 控制) ========
    .ifmap_fifo_reset_i(ifmap_fifo_reset_i),
    .ifmap_need_pop_i(ifmap_need_pop_i),
    .ifmap_pop_num_i(ifmap_pop_num_i),
    .ifmap_permit_push_i(ifmap_permit_push_i),
    .ifmap_fifo_full_i(ifmap_fifo_full_i),
    .ifmap_fifo_empty_i(ifmap_fifo_empty_i),
    .ifmap_glb_base_addr_matrix_i(ifmap_fifo_base_addr_matrix),
    .ifmap_glb_read_data_i(ifmap_glb_read_data_i),

    .ipsum_need_push_i(ipsum_need_push_i),
    .ipsum_need_pop_i(ipsum_need_pop_i),
    .ipsum_permit_push_i(ipsum_permit_push_i),
    .ipsum_fifo_full_i(ipsum_fifo_full_i),
    .ipsum_fifo_empty_i(ipsum_fifo_empty_i),
    .ipsum_fifo_reset_i(ipsum_fifo_reset_i),
    .ipsum_fifo_base_addr_matrix_i(ipsum_fifo_base_addr_matrix),

    .opsum_need_push_i(opsum_need_push_i),
    .opsum_need_pop_i(opsum_need_pop_i),
    .opsum_permit_pop_i(opsum_permit_pop_i),
    .opsum_fifo_empty_i(opsum_fifo_empty_i),
    .opsum_fifo_reset_i(opsum_fifo_reset_i),
    .opsum_pop_web_i(opsum_pop_web_i),
    .opsum_fifo_base_addr_matrix_i(opsum_fifo_base_addr_matrix),

//* output
    //======== 控制訊號給 FIFO 本體 ========
    .ifmap_fifo_reset_o(ifmap_fifo_reset_o),
    .ifmap_fifo_push_en_o(ifmap_fifo_push_en_o),
    .ifmap_fifo_push_data_o(ifmap_fifo_push_data_o),
    .ifmap_fifo_push_mod_o(ifmap_fifo_push_mod_o),
    .ifmap_fifo_pop_en_o(ifmap_fifo_pop_en_o),
    .ifmap_glb_read_req_o(ifmap_glb_read_req_o),
    .ifmap_glb_read_addr_o(ifmap_glb_read_addr_o),
    .ifmap_fifo_done_o(ifmap_fifo_done_o),

    .ipsum_fifo_push_en_o(ipsum_fifo_push_en_o),
    .ipsum_fifo_pop_en_o(ipsum_fifo_pop_en_o),
    .ipsum_fifo_reset_o(ipsum_fifo_reset_o),
    .ipsum_glb_read_req_o(ipsum_glb_read_req_o),
    .ipsum_glb_read_addr_o(ipsum_glb_read_addr_o),

    .opsum_fifo_pop_en_o(opsum_fifo_pop_en_o),
    .opsum_fifo_push_en_o(opsum_fifo_push_en_o),
    .opsum_fifo_reset_o(opsum_fifo_reset_o),
    .opsum_glb_write_req_o(opsum_glb_write_req_o),
    .opsum_glb_write_addr_o(opsum_glb_write_addr_o),
    .opsum_glb_write_web_o(opsum_glb_write_web_o)
);

token_arbiter token_arbiter_dut (
    .opsum_write_req_vec(opsum_write_req_vec),
    .ifmap_read_req_vec(ifmap_read_req_vec),
    .ipsum_read_req_vec(ipsum_read_req_vec),
    .ifmap_read_addr_vec(ifmap_read_addr_vec),
    .ipsum_read_addr_vec(ipsum_read_addr_vec),
    .opsum_write_addr_vec(opsum_write_addr_vec),
    .opsum_write_web_vec(opsum_write_web_vec),
    .glb_read_req(glb_read_req),
    .glb_read_addr(glb_read_addr),
    .glb_read_web(glb_read_web),
    .glb_write_req(glb_write_req),
    .glb_write_addr(glb_write_addr),
    .glb_write_web(glb_write_web),
    .permit_ifmap(permit_ifmap),
    .permit_ipsum(permit_ipsum),
    .permit_opsum(permit_opsum)
);

endmodule
