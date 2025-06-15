module opsum_fifo_ctrl (
    input  logic        clk,
    input  logic        rst_n,

    // 控制來源來自 L2
    input  logic        opsum_fifo_reset_i,    // FIFO reset
    input  logic        opsum_need_pop_i,      // L2 指令：請嘗試 pop 出一筆資料 (FIFO -> arbiter)

    // Arbiter grant: 你現在可以寫入 GLB
    input  logic        opsum_permit_pop_i,

    // FIFO 狀態
    input  logic        opsum_fifo_empty_i,
    input  logic        opsum_fifo_full_i,

    // GLB base address（由 Token Engine 統一給予）
    input  logic [31:0] opsum_glb_base_addr_i,

    // FIFO control
    output logic        opsum_fifo_pop_o,
    output logic        opsum_fifo_push_o,

    // 寫入 GLB token
    output logic        opsum_glb_write_req_o,
    output logic [31:0] opsum_glb_write_addr_o,
    output logic [3:0]  opsum_glb_write_web_o    // 每個位元對應一個 byte 的寫入使能
);


endmodule
