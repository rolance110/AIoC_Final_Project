`define ROW_NUM 32

module Reducer(
    input [`ROW_NUM*16 - 1:0] array2reducer,
    input [`ROW_NUM*16 - 1:0] ipsum2reducer,
    input DW_PW_sel,//選擇哪一種做法,  1 = PW mode, 0 = DW mode

    output [`ROW_NUM*16 - 1:0] reducer2opsum
);

  genvar r;
  generate
    for (r = 0; r < `ROW_NUM; r = r + 1) begin : RED
      // pick base row of this 3-group
      localparam int base = (r/3)*3;

      // extract the three row inputs, out-of-range → 0
      wire [15:0] in0 = array2reducer[ (base+0 < `ROW_NUM ? (base+0)*16 : 0) +: 16 ];
      wire [15:0] in1 = array2reducer[ (base+1 < `ROW_NUM ? (base+1)*16 : 0) +: 16 ];
      wire [15:0] in2 = array2reducer[ (base+2 < `ROW_NUM ? (base+2)*16 : 0) +: 16 ];
      wire [15:0] ips = ipsum2reducer[ base*16 +: 16 ];  // only use ips of the first row

      // instantiate both
      wire [15:0] pw_sum;
      ADD u_add (
        .ipsum    (ips),
        .row_in   (in0),
        .add_out  (pw_sum)
      );

      wire [15:0] dw_sum;
      ADDT u_addt (
        .ipsum    (ips),
        .row1     (in0),
        .row2     (in1),
        .row3     (in2),
        .addt_out (dw_sum)
      );

      // choose: only r%3==0 produce, others zero
    // --------------------------------------------------
    // TODO output_en = 1，代表這個ROW可以輸出，然後再透過DW_PW_sel來確定輸出的是哪一種格式
    // --------------------------------------------------
      if ((r % 3) == 0) begin
        assign reducer2opsum[r*16 +: 16] = (DW_PW_sel) ? pw_sum : dw_sum;
      end else begin
        assign reducer2opsum[r*16 +: 16] = (DW_PW_sel) ? pw_sum : 16'd0;
      end
    end
  endgenerate

endmodule