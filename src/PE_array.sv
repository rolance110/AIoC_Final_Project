`define COL_NUM 32
`define ROW_NUM 32

module PE_array(
    input clk,
    input reset,
    input pe_pass_if, //用來決定有幾個PE會動作，從0開始算
    input prod_out_en,//只有在cs == Compute的時候會輸出給Reducer，維持四個cycle
    input [`COL_NUM*8 - 1 : 0] array_ifmap_in,//input由左到右 pe0(0~7bit) -> pe1(8~15bit) ... pe31(248~255bit)
    input [`ROW_NUM*`COL_NUM*8 - 1 : 0] array_weight_in,// ROW1=0~255, ROW2=256~511 ... ROW32=7936~8191
    input [5:0] array_weight_en,//說明啟用幾個ROW

    output logic signed [`ROW_NUM*16 - 1 : 0] array_opsum
);
  // --------------------------------------------------
  // 0) TODO 先設定enable signal，決定有幾個ROW會動作
  // --------------------------------------------------
  wire pe_weight_en [`ROW_NUM-1:0];
  genvar k;
  generate
    for (k = 0; k < `ROW_NUM; k = k + 1) begin
      assign pe_weight_en[k] = (k < array_weight_en) ? 1'b1 : 1'b0;
    end
  endgenerate
  // --------------------------------------------------
  // 1) TODO 拆出每顆 PE 的 ifmap_in / weight_in / weight_en
  // --------------------------------------------------
  // 暫存 PE 的 ifmap_out
  logic [7:0] ifmap_out_wire [0:`ROW_NUM-1][0:`COL_NUM-1];
  // 解包 weight
  logic [7:0] weight_wire    [0:`ROW_NUM-1][0:`COL_NUM-1];

  genvar r, c;
  generate
    for (r = 0; r < `ROW_NUM; r = r + 1) begin : UNPACK
      for (c = 0; c < `COL_NUM; c = c + 1) begin : COLS
        // weight FIXME: 方向跟weight_buffer當中存的相反
        assign weight_wire[r][c] = array_weight_in[((r*`COL_NUM + c)*8) +: 8];
      end
    end
  endgenerate

  // --------------------------------------------------
  // 2) TODO Instantiate 32×32 PEs, chain ifmap_out → next row ifmap_in
  // --------------------------------------------------
  logic signed [15:0] prod_wire [0:`ROW_NUM-1][0:`COL_NUM-1];

  generate
    for (r = 0; r < `ROW_NUM; r = r + 1) begin : ROWS
      for (c = 0; c < `COL_NUM; c = c + 1) begin : COLS
        // decide this PE's input ifmap
        logic [7:0] this_ifmap_in;
        if (r == 0) begin
          // top row reads directly from array_ifmap_in
          assign this_ifmap_in = array_ifmap_in[c*8 +: 8];
        end else begin
          // lower rows chain from above PE
          assign this_ifmap_in = ifmap_out_wire[r-1][c];
        end

        PE u_pe (
          .clk        (clk),
          .reset      (reset),
          .pe_pass_if (pe_pass_if),
          .prod_out_en(prod_out_en),
          .ifmap_in   (this_ifmap_in),
          .weight_in  (weight_wire[r][c]),
          .weight_en  (pe_weight_en[r]),
          .ifmap_out  (ifmap_out_wire[r][c]),
          .prod_out   (prod_wire[r][c])
        );
      end
    end
  endgenerate

  // --------------------------------------------------
  // 3) TODO 五層 RADDT，將每 row 32 個 prod → 1 個 sum
  // --------------------------------------------------
  // level1: 32→16
  logic signed [15:0] sum1 [0:`ROW_NUM-1][0:15];
  generate
    for (r = 0; r < `ROW_NUM; r = r + 1) begin : L1
      for (c = 0; c < 16; c = c + 1) begin
        assign sum1[r][c] = prod_wire[r][2*c] + prod_wire[r][2*c+1];
      end
    end
  endgenerate

  // level2: 16→8
  logic signed [15:0] sum2 [0:`ROW_NUM-1][0:7];
  generate
    for (r = 0; r < `ROW_NUM; r = r + 1) begin : L2
      for (c = 0; c < 8; c = c + 1) begin
        assign sum2[r][c] = sum1[r][2*c] + sum1[r][2*c+1];
      end
    end
  endgenerate

  // level3: 8→4
  logic signed [15:0] sum3 [0:`ROW_NUM-1][0:3];
  generate
    for (r = 0; r < `ROW_NUM; r = r + 1) begin : L3
      for (c = 0; c < 4; c = c + 1) begin
        assign sum3[r][c] = sum2[r][2*c] + sum2[r][2*c+1];
      end
    end
  endgenerate

  // level4: 4→2
  logic signed [15:0] sum4 [0:`ROW_NUM-1][0:1];
  generate
    for (r = 0; r < `ROW_NUM; r = r + 1) begin : L4
      assign sum4[r][0] = sum3[r][0] + sum3[r][1];
      assign sum4[r][1] = sum3[r][2] + sum3[r][3];
    end
  endgenerate

  // level5: 2→1 & pack
  generate
    for (r = 0; r < `ROW_NUM; r = r + 1) begin : L5
      wire signed[15:0] row_sum = sum4[r][0] + sum4[r][1];
      assign array_opsum[r*16 +: 16] = row_sum;
    end
  endgenerate

endmodule