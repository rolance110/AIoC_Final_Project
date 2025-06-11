`include "weight_load_controller.sv"
`include "pe_en_controller.sv"

`include "../../../include/define.svh"
module token_engine (
    input  logic         clk,
    input  logic         rst_n,

    // 啟動控制
    input  logic         pass_start_i,
    output logic         pass_done_o,

    // 來自 Layer Decoder 的資訊（tile_K, tile_D, layer_type, stride, ...）
    input  logic [1:0]   layer_type_i,

    input logic  [31:0] weight_GLB_base_addr, // base address of weight in GLB
    input logic  [31:0] ifmap_GLB_base_addr,  // base address of ifmap  in GLB
    input logic  [31:0] ipsum_GLB_base_addr,  // base address of ipsum  in GLB
    input logic  [31:0] opsum_GLB_base_addr,  // base address of opsum  in GLB

    input logic [31:0] tile_n_i, // tile size in N dimension

    input logic [6:0] in_C_i,
    input logic [6:0] in_R_i,
    input logic [6:0] out_C_i,
    input logic [6:0] out_R_i,
    input logic [6:0] IC_real_i, // real input channel number
    input logic [6:0] OC_real_i, // real output channel number
    
    // 與 conv_unit 連接的控制訊號（output）
    output logic [7:0]         weight_in,
    output logic [31:0][31:0]  weight_load_en,

    output logic [31:0]        push_ifmap_en,
    output logic [31:0]        push_ifmap_mod,
    output logic [31:0]        push_ifmap_data,

    output logic [31:0]        pop_ifmap_en,
    output logic PE_en_matrix [31:0][31:0],

    output logic [31:0]        push_ipsum_en,
    output logic [31:0]        push_ipsum_mod,
    output logic [31:0]        push_ipsum_data,

    output logic [31:0]        pop_ipsum_en,
    output logic               ipsum_read_en,
    output logic               ipsum_add_en,

    output logic [31:0]        opsum_push_en,
    output logic [31:0]        opsum_pop_en,
    output logic [31:0]        opsum_pop_mod,

    // FIFO 狀態讀取
    input  logic [31:0]        ifmap_fifo_full,
    input  logic [31:0]        ifmap_fifo_empty,
    input  logic [31:0]        ipsum_fifo_empty,
    input  logic [31:0]        opsum_fifo_full
);

logic weight_load_state; // weight load state
logic [3:0] weight_load_WEB; // read enable to GLB (1 = write, 0 = read)
logic [31:0] weight_addr; // (count by byte) address to GLB
logic [1:0] weight_load_byte_type; // load type for weight (1 byte, 2 byte, 3 byte, 4 byte)

logic [31:0] ifmap_fifo_pop_en; // active PE row count (0-31) 32 column

weight_load_controller weight_load_controller_dut(
//* input 
    .clk(clk),
    .rst_n(rst_n),
    .weight_load_state(weight_load_state),
    .layer_type(layer_type_i),
    .weight_GLB_base_addr(weight_GLB_base_addr),

//* output
    .weight_load_WEB(weight_load_WEB),
    .weight_addr(weight_addr),
    .weight_load_byte_type(weight_load_byte_type),
    .weight_load_finish(weight_load_finish)
);

pe_en_controller pe_en_controller_dut(
//* input
    .clk(clk),
    .rst_n(rst_n),

    .layer_type(layer_type_i),

    .ifmap_fifo_pop_en(ifmap_fifo_pop_en),

//* output
    .PE_en_matrix(PE_en_matrix)
);

endmodule