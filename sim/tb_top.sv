
`include "../include/define.svh"
`define CYCLE    10

module tb_top;

  /* ──────────────────────────────────────────────
   * 1. Clock / Reset
   * ──────────────────────────────────────────── */
  logic clk;
  logic rst;

  /* ──────────────────────────────────────────────
   * 2. Tile / Layer 參數 (Scheduler → top)
   * ──────────────────────────────────────────── */
  logic                        PASS_START;
  logic [1:0]                  pass_layer_type;
  logic [`BYTE_CNT_WIDTH-1:0]  pass_tile_n;
  logic [`FLAG_WIDTH-1:0]      pass_flags;

  logic [`ADDR_WIDTH-1:0] BASE_IFMAP;
  logic [`ADDR_WIDTH-1:0] BASE_WEIGHT;
  logic [`ADDR_WIDTH-1:0] BASE_OPSUM;
  logic [`ADDR_WIDTH-1:0] BASE_BIAS;

  logic [6:0] out_C;
  logic [6:0] out_R;

  /* ──────────────────────────────────────────────
   * 3. GLB ↔ top 介面
   * ──────────────────────────────────────────── */
  logic                    glb_read_valid;
  logic [`DATA_WIDTH-1:0]  glb_read_data;

  logic                    glb_write_ready;

  /* ──────────────────────────────────────────────
   * 4. 其他 tiling / 網路設定
   * ──────────────────────────────────────────── */
  logic [6:0] tile_K_o;
  logic [5:0] tile_D;

  logic [7:0] in_C;
  logic [7:0] in_R;
  logic [1:0] stride;
logic [`ADDR_WIDTH-1:0] glb_read_addr;
logic                   glb_read_ready;
logic [`ADDR_WIDTH-1:0] glb_write_addr;
logic [`DATA_WIDTH-1:0] glb_write_data;
logic                   glb_write_valid;
logic                   WEB;
logic [31:0]            BWEB;
logic pass_done;
  /* ──────────────────────────────────────────────
   * 5. DUT 例化
   * ──────────────────────────────────────────── */
  top dut (
    .clk              (clk),
    .rst              (rst),

    .PASS_START       (PASS_START),
    .pass_layer_type  (pass_layer_type),
    .pass_tile_n      (pass_tile_n),
    .pass_flags       (pass_flags),

    .BASE_IFMAP       (BASE_IFMAP),
    .BASE_WEIGHT      (BASE_WEIGHT),
    .BASE_OPSUM       (BASE_OPSUM),
    .BASE_BIAS        (BASE_BIAS),

    .out_C            (out_C),
    .out_R            (out_R),

    .glb_read_valid   (glb_read_valid),
    .glb_read_data    (glb_read_data),

    .glb_write_ready  (glb_write_ready),
    .glb_read_addr(glb_read_addr),
    .glb_read_ready(glb_read_ready),
    .glb_write_addr(glb_write_addr),
    .glb_write_data(glb_write_data),
    .glb_write_valid(glb_write_valid),
    .WEB(WEB),
    .BWEB(BWEB),
    .tile_K_o         (tile_K_o),
    .tile_D           (tile_D),
    // .tile_K_out(tile_K_out),   // Token Engine ↔ PE
    .in_C             (in_C),
    .in_R             (in_R),
    .stride           (stride),
    .pass_done(pass_done)
  );

  /* ──────────────────────────────────────────────
   * 6. Clock 產生 (100 MHz → 10 ns 週期)
   * ──────────────────────────────────────────── */
initial clk = 1'b0;
always #(`CYCLE/2) clk = ~clk;


// initial begin
//     $fsdbDumpfile("conv_uint.fsdb");
//     $fsdbDumpvars(0, tb_Conv_uint, "+all");
//     $fsdbDumpMDA;
// end

initial begin
    $readmemh("init_sram_data.txt",u_sram.mem);
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars(0, tb_top);
    $fsdbDumpMDA;
end


initial begin
    /* === Default === */
    rst = 1;

    pass_layer_type = 0;//0=pw, 1=dw
    #10
    PASS_START  = 1;
    pass_tile_n = 32'd168; // 一次 DRAM→GLB 要搬入的 Ifmap bytes 總數
    pass_flags  = 0; // Flags 控制：bit[0]=bias_en, bit[1]=relu_en, bit[2]=skip_en, …
    BASE_WEIGHT = 0; // GLB 中「此層 Weight 資料」的起始位址
    BASE_IFMAP  = 1024; // GLB 中「此層 Ifmap 資料」的起始位址
    BASE_BIAS   = 13824; // GLB 中「此層 Bias 資料」的起始位址
    BASE_OPSUM  = 15000; // GLB 中「此層 PSUM (Partial/Final) 資料」的起始位址
    out_C = 112;
    out_R = 112;
    glb_read_valid  = 1; // GLB 回應：「此筆 glb_read_data 有效」
    glb_write_ready = 1;
    tile_K_o = 32;
    tile_D   = 32;
    in_C = 112; //輸入特徵圖 Width column
    in_R = 112; //輸入特徵圖 Height row
    stride = 1; //stride
    /* === Reset deassert === */
    #(`CYCLE * 2) 
    rst = 1'b0;
    wait(pass_done)
    $display("Simulation finished successfully.");
    $finish; // 結束模擬

end
initial begin
    #5000000
    $display("Simulation finished fail.");
    $finish; // 結束模擬

end



  MEM32x16384 u_sram (
  .CK(clk),
  .CS(1'b1),
  .WEB(WEB),
  .BWEB(BWEB),                     // 注意：WEB=0時寫入
  .RE(glb_read_ready),            // RE=1 時讀取
  .R_ADDR(glb_read_addr/4),    // 只支援 10-bit 位址
  .W_ADDR(glb_write_addr/4),   // 只支援 10-bit 位址
  .D_IN(glb_write_data),    // 只支援 24-bit 寬度
  .D_OUT(glb_read_data)     // 回傳值
);


endmodule