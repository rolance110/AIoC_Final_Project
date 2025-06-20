// `include "weight_load_controller.sv"
// `include "pe_array_controller.sv"
// `include "Layer1_Controller.sv"
// `include "L2C_init_fifo_pe.sv"
// `include "L2C_preheat.sv"
// `include "L3C_fifo_ctrl.sv"
// `include "token_arbiter.sv"
// `include "../../../include/define.svh"

module token_engine (
    input  logic         clk,
    input  logic         rst_n,

    // 啟動控制
    input  logic         pass_start_i,
    output logic         pass_done_o,

    // 來自 Layer Decoder 的資訊（tile_K, tile_D, layer_type, stride, ...）
    input  logic [1:0]   layer_type_i,

    input logic  [31:0] weight_GLB_base_addr_i,
    input logic  [31:0] ifmap_GLB_base_addr_i,
    input logic  [31:0] ipsum_GLB_base_addr_i,
    input logic  [31:0] bias_GLB_base_addr_i,
    input logic  [31:0] opsum_GLB_base_addr_i,

    input logic is_bias_i,


    input logic [31:0] tile_n_i,

    input logic [7:0] in_C_i,
    input logic [7:0] in_R_i,
    input logic [1:0] pad_R_i,
    input logic [1:0] pad_L_i,
    input logic [7:0] out_C_i,
    input logic [7:0] out_R_i,
    input logic [7:0] IC_real_i,
    input logic [7:0] OC_real_i,
    input logic [31:0] On_real_i,

//* from GLB
    input  logic [31:0] glb_read_data_i,

//* from opsum fifo
    input logic [31:0] opsum_fifo_pop_data_matrix_i [31:0],



///* output


//* to GLB
    output logic [3:0] glb_web_o,
    output logic [31:0] glb_addr_o,
    output logic [31:0] glb_write_data_o,

//* to PE
    output logic PE_en_matrix_o [31:0][31:0],
    output logic PE_stall_matrix_o [31:0][31:0],

//* to CONV PE
    output logic [7:0]         weight_in_o,
    output logic weight_load_en_matrix_o [31:0][31:0], // weight load enable matrix

//* ifmap fifo
    output logic ifmap_fifo_reset_o, // reset signal for ifmap FIFO
    output logic [31:0]        ifmap_fifo_push_matrix_o,
    output logic [31:0]        ifmap_fifo_push_mod_matrix_o,
    output logic [31:0]        ifmap_fifo_pop_matrix_o,
    output logic [31:0]         ifmap_fifo_push_data_matrix_o [31:0],


//* ipsum fifo
    output logic ipsum_fifo_reset_o, // reset signal for ipsum FIFO
    output logic [31:0]        ipsum_fifo_push_matrix_o,
    output logic [31:0]        ipsum_fifo_push_mod_matrix_o,
    output logic [31:0]        ipsum_fifo_push_data_matrix_o [31:0],
    output logic [31:0]        ipsum_fifo_pop_matrix_o,


//* opsum fifo
    output logic opsum_fifo_reset_o, // reset signal for opsum FIFO
    output logic [31:0]        opsum_fifo_push_matrix_o,
    output logic [31:0]        opsum_fifo_push_mod_matrix_o,
    output logic [31:0]        opsum_fifo_push_data_matrix_o [31:0],
    output logic [31:0]        opsum_fifo_pop_matrix_o,

    input  logic [31:0]        ifmap_fifo_full_matrix_i,
    input  logic [31:0]        ifmap_fifo_empty_matrix_i,
    input  logic [31:0]        ipsum_fifo_full_matrix_i, 
    input  logic [31:0]        ipsum_fifo_empty_matrix_i,
    input  logic [31:0]        opsum_fifo_full_matrix_i,
    input  logic [31:0]        opsum_fifo_empty_matrix_i
);

// 狀態相關訊號 (State-related signals)
logic init_fifo_pe_state;
logic normal_loop_state;
logic preheat_state;
logic weight_load_state;

// 完成旗標訊號 (Done flags)
logic normal_loop_done;
logic preheat_done;
logic weight_load_done;

// 權重相關訊號 (Weight-related signals)
logic [31:0] weight_addr;
logic [1:0]  weight_load_byte_type;

// IFMAP 相關訊號 (IFMAP-related signals)
logic [31:0] ifmap_need_pop_matrix;
logic [31:0] ifmap_permit_push_matrix;
logic [31:0] ifmap_pop_num_matrix [31:0];
logic [31:0] ifmap_read_addr_matrix [31:0];
logic [31:0] ifmap_read_req_matrix;

// IPSUM 相關訊號 (IPSUM-related signals)
logic [31:0] ipsum_permit_push_matrix;
logic [31:0] ipsum_pop_num_matrix [31:0];
logic [31:0] ipsum_read_addr_matrix [31:0];
logic [31:0] ipsum_read_req_matrix;

// OPSUM 相關訊號 (OPSUM-related signals)
logic [31:0] opsum_need_push_matrix;
logic [31:0] opsum_push_num_matrix [31:0];

logic [31:0] opsum_permit_pop_matrix;
logic [3:0]  opsum_pop_web [31:0];
logic [31:0] opsum_write_addr_matrix [31:0];
logic [3:0]  opsum_write_web_matrix [31:0];
logic [31:0] opsum_write_req_matrix;

// Global 相關訊號 (Global-related signals)
logic        glb_read_req;
logic        glb_write_req;





weight_load_controller weight_load_controller_dut(
    .clk(clk), .rst_n(rst_n),
    .weight_load_state_i(weight_load_state),
    .layer_type_i(layer_type_i),
    .weight_GLB_base_addr_i(weight_GLB_base_addr_i),
    .glb_read_data_i(glb_read_data_i),
 
    .weight_addr_o(weight_addr),
    .weight_load_byte_type_o(weight_load_byte_type),
    .weight_load_en_matrix_o(weight_load_en_matrix_o),       
    .weight_load_done_o(weight_load_done),

    .weight_in_o(weight_in_o)
);

pe_array_controller pe_array_controller(
    .clk(clk),
    .rst_n(rst_n),
//* input
    .layer_type_i(layer_type_i),

    .preheat_state_i(preheat_state), 
    .normal_loop_state_i(normal_loop_state), 

    .ifmap_fifo_pop_matrix_i(ifmap_fifo_pop_matrix_o),
    .ipsum_fifo_pop_matrix_i(ipsum_fifo_pop_matrix_o),
    .opsum_fifo_push_matrix_i(opsum_fifo_push_matrix_o),

//* output
    .PE_stall_matrix_o(PE_stall_matrix_o),
    .PE_en_matrix_o(PE_en_matrix_o)
);


//* Layer 1 Controller ==============================================
Layer1_Controller Layer1_Controller (
    .clk(clk),
    .rst_n(rst_n),
//* input
    // 啟動／完成
    .pass_start_i(pass_start_i),
    .pass_done_o(pass_done_o),

    .weight_load_done_i(weight_load_done),
    // .init_fifo_pe_done_i(init_fifo_pe_done_i), // 1 cycle
    .preheat_done_i(preheat_done),
    .normal_loop_done_i(normal_loop_done),

//* output
    // 傳給下層 L2 的控制
    .weight_load_state_o(weight_load_state),   // INIT_WEIGHT
    .init_fifo_pe_state_o(init_fifo_pe_state),  // INIT_FIFO_PE
    .preheat_state_o(preheat_state),       // 下層 PREHEAT 觸發
    .normal_loop_state_o(normal_loop_state)  // 下層 FLOW 觸發
);


//* Layer 2 Controller ==============================================
logic [31:0] ifmap_fifo_base_addr_matrix [31:0];
logic [31:0] ipsum_fifo_base_addr_matrix [31:0];
logic [31:0] opsum_fifo_base_addr_matrix [31:0];
L2C_init_fifo_pe #(
    .NUM_FIFO(96)
) L2C_init_fifo_pe_dut (
    .clk(clk),
    .rst_n(rst_n),
//* input
    .init_fifo_pe_state_i(init_fifo_pe_state),   // 啟動初始化
    .ifmap_glb_base_addr_i(ifmap_GLB_base_addr_i), // ifmap base address 由 TB 配置
    .ipsum_glb_base_addr_i(ipsum_GLB_base_addr_i), // ipsum FIFO base address 由 TB 配置
    .opsum_glb_base_addr_i(opsum_GLB_base_addr_i), // opsum FIFO base address 由 TB 配置
    .bias_glb_base_addr_i(bias_GLB_base_addr_i),   // bias  FIFO base address 由 TB 配置
    .is_bias_i(is_bias_i), // 判斷現在 ipsum_fifo 是要輸入 bias or ipsum

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
    .opsum_fifo_base_addr_o(opsum_fifo_base_addr_matrix),

    .ifmap_fifo_reset_o(ifmap_fifo_reset_o), // reset signal for ifmap FIFO
    .ipsum_fifo_reset_o(ipsum_fifo_reset_o), // reset signal for ipsum FIFO
    .opsum_fifo_reset_o(opsum_fifo_reset_o) // reset signal for opsum FIFO
);
logic [31:0] ifmap_fifo_done_matrix;
logic [31:0] ipsum_fifo_done_matrix;
logic [31:0] opsum_fifo_done_matrix;
logic [31:0] ipsum_need_pop_matrix;


logic [31:0] ifmap_need_pop_pre_matrix;
logic [31:0] ifmap_pop_num_pre_matrix [31:0];
logic [31:0] ipsum_need_pop_pre_matrix;
logic [31:0] ipsum_pop_num_pre_matrix [31:0];

L2C_preheat #(
    .NUM_IFMAP_FIFO(32)
) L2C_preheat_dut (
    .clk(clk),
    .rst_n(rst_n),
    .start_preheat_i(preheat_state),
    .layer_type_i(layer_type_i),
    .ifmap_fifo_done_matrix_i(ifmap_fifo_done_matrix),
    .ipsum_fifo_done_matrix_i(ipsum_fifo_done_matrix),

    .ifmap_need_pop_o(ifmap_need_pop_pre_matrix),
    .ifmap_pop_num_o(ifmap_pop_num_pre_matrix),
    .ipsum_need_pop_o(ipsum_need_pop_pre_matrix),
    .ipsum_pop_num_o(ipsum_pop_num_pre_matrix),
    .preheat_done_o(preheat_done)

);

logic [31:0] ifmap_need_pop_nor_matrix; // 每個 ifmap FIFO 需要 pop 的訊號
logic [31:0] ifmap_pop_num_nor_matrix [31:0]; // 每個 ifmap FIFO 需要 pop 的數量
    
logic [31:0] ipsum_need_pop_nor_matrix; // 每個 ipsum FIFO 需要 pop 的訊號
logic [31:0] ipsum_pop_num_nor_matrix [31:0]; // 每個 ipsum FIFO 需要 pop 的數量
    
logic [31:0] opsum_need_push_nor_matrix; // 每個 opsum FIFO 需要 push 的訊號
logic [31:0] opsum_push_num_nor_matrix [31:0];

/* Normal Loop */
L2C_normal_loop L2C_normal_loop(
    .clk(clk),
    .rst_n(rst_n),

    .start_normal_loop_i(start_normal_loop), // 啟動 normal loop
    .layer_type_i(layer_type_i),


//* Tile Infomation
    .tile_n_i(tile_n_i), // tile 的數量

//* FIFO Done
    .ifmap_fifo_done_matrix_i(ifmap_fifo_done_matrix), // 每個 ifmap FIFO 是否完成
    .ipsum_fifo_done_matrix_i(ipsum_fifo_done_matrix), // 每個 ipsum FIFO 是否完成
    .opsum_fifo_done_matrix_i(opsum_fifo_done_matrix), // 每個 opsum FIFO 是否完成


//* L3 Controller
    .ifmap_need_pop_matrix_o(ifmap_need_pop_nor_matrix), // 每個 ifmap FIFO 需要 pop 的訊號
    .ifmap_pop_num_matrix_o(ifmap_pop_num_nor_matrix), // 每個 ifmap FIFO 需要 pop 的數量

    .ipsum_need_pop_matrix_o(ipsum_need_pop_nor_matrix), // 每個 ipsum FIFO 需要 pop 的訊號
    .ipsum_pop_num_matrix_o(ipsum_pop_num_nor_matrix), // 每個 ipsum FIFO 需要 pop 的數量

    .opsum_need_push_matrix_o(opsum_need_push_nor_matrix), // 每個 opsum FIFO 需要 push 的訊號
    .opsum_push_num_matrix_o(opsum_push_num_nor_matrix), // opsum only need push 1 time

    .normal_loop_done_o(normal_loop_done) // normal loop 完成訊號
);


assign ifmap_need_pop_matrix = preheat_state? ifmap_need_pop_pre_matrix: ifmap_need_pop_nor_matrix;
assign ifmap_pop_num_matrix = preheat_state? ifmap_pop_num_pre_matrix: ifmap_pop_num_nor_matrix;
assign ipsum_need_pop_matrix = preheat_state? ipsum_need_pop_pre_matrix: ipsum_need_pop_nor_matrix;
assign ipsum_pop_num_matrix = preheat_state? ipsum_pop_num_pre_matrix: ipsum_pop_num_nor_matrix;
assign opsum_need_push_matrix = opsum_need_push_nor_matrix;
assign opsum_push_num_matrix = opsum_push_num_nor_matrix;

logic [31:0] opsum_fifo_push_mask;


opsum_fifo_mask opsum_fifo_mask(
    .clk(clk),
    .rst_n(rst_n),


    .layer_type_i(layer_type_i), // 0: conv, 1: fc
    // 控制訊號
    .opsum_fifo_reset_i(opsum_fifo_reset),
    .normal_loop_state_i(normal_loop_state),

    // 參數：實際要啟用的 FIFO 數量 (0～32)
    .OC_real_i(OC_real_i),
    // ifmap_fifo_pop 事件，只要任一位有 pop 則視為「pop 一次」
    .ifmap_fifo_pop_matrix_i(ifmap_fifo_pop_matrix_o),

    // 最終哪幾個 opsum_fifo 可以 push
    .opsum_fifo_push_mask_o(opsum_fifo_push_mask)
);

logic [31:0] opsum_write_data_matrix [31:0]; // opsum FIFO pop data to GLB write data
//* Layer 3 Controller ==============================================
L3C_fifo_ctrl #(
    .IC_MAX(32),
    .OC_MAX(32)
) u_L3C_fifo_ctrl (
    .clk(clk),
    .rst_n(rst_n),
//* input
// reset 
    .ifmap_fifo_reset_i(ifmap_fifo_reset_o),
    .ipsum_fifo_reset_i(ipsum_fifo_reset_o),
    .opsum_fifo_reset_i(opsum_fifo_reset_o),


//* busy
    .fifo_glb_busy_i(glb_read_req || glb_write_req), //fixme FIFO <=> GLB 是否忙碌

// todo: opsum_fifo_push_mask
    .opsum_fifo_push_mask_i(opsum_fifo_push_mask), // todo: opsum FIFO enable mask, 1: enable, 0: disable

// L2 need 
    .ifmap_need_pop_matrix_i(ifmap_need_pop_matrix),
    .ifmap_pop_num_matrix_i(ifmap_pop_num_matrix),

    .ipsum_need_pop_matrix_i(ipsum_need_pop_matrix),
    .ipsum_pop_num_matrix_i(ipsum_pop_num_matrix),

    .opsum_need_push_matrix_i(opsum_need_push_matrix),
    .opsum_push_num_matrix_i(opsum_push_num_matrix), // opsum only need push 1 time

// FIFO
    .ifmap_fifo_full_matrix_i(ifmap_fifo_full_matrix_i),
    .ifmap_fifo_empty_matrix_i(ifmap_fifo_empty_matrix_i),
    .ipsum_fifo_full_matrix_i(ipsum_fifo_full_matrix_i),
    .ipsum_fifo_empty_matrix_i(ipsum_fifo_empty_matrix_i),
    .opsum_fifo_full_matrix_i(opsum_fifo_full_matrix_i),
    .opsum_fifo_empty_matrix_i(opsum_fifo_empty_matrix_i),

    .opsum_fifo_pop_data_matrix_i(opsum_fifo_pop_data_matrix_i), // opsum FIFO pop data input for processing

// base address matrix
    .ifmap_fifo_base_addr_matrix_i(ifmap_fifo_base_addr_matrix),
    .ipsum_fifo_base_addr_matrix_i(ipsum_fifo_base_addr_matrix),
    .opsum_fifo_base_addr_matrix_i(opsum_fifo_base_addr_matrix),

// arbiter permit
    .ifmap_permit_push_matrix_i(ifmap_permit_push_matrix),
    .ipsum_permit_push_matrix_i(ipsum_permit_push_matrix),
    .opsum_permit_pop_matrix_i(opsum_permit_pop_matrix),

// GLB read data in (need pre-processed by FIFO ctrl)
    .ifmap_glb_read_data_i(glb_read_data_i),
    .ipsum_glb_read_data_i(glb_read_data_i),



//* output
//to FIFO 
    .ifmap_fifo_push_matrix_o(ifmap_fifo_push_matrix_o),
    .ifmap_fifo_push_mod_matrix_o(ifmap_fifo_push_mod_matrix_o),
    .ifmap_fifo_push_data_matrix_o(ifmap_fifo_push_data_matrix_o),
    .ifmap_fifo_pop_matrix_o(ifmap_fifo_pop_matrix_o),

    .ipsum_fifo_push_matrix_o(ipsum_fifo_push_matrix_o),
    .ipsum_fifo_push_mod_matrix_o(ipsum_fifo_push_mod_matrix_o),
    .ipsum_fifo_push_data_matrix_o(ipsum_fifo_push_data_matrix_o),
    .ipsum_fifo_pop_matrix_o(ipsum_fifo_pop_matrix_o),

    .opsum_fifo_pop_matrix_o(opsum_fifo_pop_matrix_o),
    .opsum_fifo_push_matrix_o(opsum_fifo_push_matrix_o),
    .opsum_fifo_pop_mod_matrix_o(opsum_fifo_push_mod_matrix_o),


// to arbiter
    .ifmap_read_req_matrix_o(ifmap_read_req_matrix),
    .ifmap_glb_read_addr_matrix_o(ifmap_read_addr_matrix),

    .ipsum_read_req_matrix_o(ipsum_read_req_matrix),
    .ipsum_glb_read_addr_matrix_o(ipsum_read_addr_matrix),

    .opsum_glb_write_req_matrix_o(opsum_write_req_matrix),
    .opsum_glb_write_addr_matrix_o(opsum_write_addr_matrix),
    .opsum_glb_write_web_matrix_o(opsum_write_web_matrix),
    .opsum_glb_write_data_matrix_o(opsum_write_data_matrix),

// done
    .ifmap_fifo_done_matrix_o(ifmap_fifo_done_matrix),
    .ipsum_fifo_done_matrix_o(ipsum_fifo_done_matrix),
    .opsum_fifo_done_matrix_o(opsum_fifo_done_matrix)
);

token_arbiter token_arbiter_dut (

//* input
    .weight_load_state_i(weight_load_state),
    .weight_addr_i(weight_addr),

    .opsum_write_req_matrix_i(opsum_write_req_matrix),
    .ifmap_read_req_matrix_i(ifmap_read_req_matrix),
    .ipsum_read_req_matrix_i(ipsum_read_req_matrix),
    
    .ifmap_read_addr_matrix_i(ifmap_read_addr_matrix),
    .ipsum_read_addr_matrix_i(ipsum_read_addr_matrix),
    .opsum_write_addr_matrix_i(opsum_write_addr_matrix),

    .opsum_write_web_matrix_i(opsum_write_web_matrix),
    .opsum_fifo_pop_data_matrix_i(opsum_write_data_matrix),

//* output
    .glb_read_o(glb_read_req),
    .glb_write_o(glb_write_req),
    .glb_addr_o(glb_addr_o),
    .glb_write_web_o(glb_web_o),
    .glb_write_data_o(glb_write_data_o),

    .permit_ifmap_matrix_o(ifmap_permit_push_matrix),
    .permit_ipsum_matrix_o(ipsum_permit_push_matrix),
    .permit_opsum_matrix_o(opsum_permit_pop_matrix)
);

endmodule
