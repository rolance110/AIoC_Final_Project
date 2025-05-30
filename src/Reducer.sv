`define ROW_NUM 32

module Reducer(
    input [`ROW_NUM*16 - 1:0] array2reducer,
    input [`ROW_NUM*16 - 1:0] ipsum2reducer,
    input DW_PW_sel,//選擇哪一種做法,  1 = PW mode, 0 = DW mode

    output [`ROW_NUM*16 - 1:0] reducer2opsum
);

wire [15:0] prod_in [`ROW_NUM-1:0]; // 16-bit wide, `ROW_NUM deep
wire [15:0] ipsum_in [`ROW_NUM-1:0]; // 16-bit wide, `ROW_NUM deep
wire [15:0] PW_SUM [`ROW_NUM-1:0]; // 16-bit wide, `ROW_NUM deep
wire [15:0] DW_CONV_SUM [9:0]; // 16-bit wide, 10 deep

genvar k;
generate
    for (k = 0; k < `ROW_NUM; k = k + 1) begin : PW
        // unpack array2reducer and ipsum2reducer
        assign prod_in[k] = array2reducer[k*16 +: 16];
        assign ipsum_in[k] = ipsum2reducer[k*16 +: 16];
        ADD ADD(
          .ipsum    (ipsum_in[k]),
          .row_in   (prod_in[k]),
          .add_out  (PW_SUM[k])
        );
    end
endgenerate

//3個row加一次(ADDT)
genvar m;
generate
    for(m = 0;m < 10;m = m + 1) begin : DW_or_CONV
        ADDT ADDT(
            .ipsum    (ipsum_in[m*3]), // only use ipsum of the first row in each 3-group
            .row1     (prod_in[m*3]),
            .row2     (prod_in[m*3 + 1]),
            .row3     (prod_in[m*3 + 2]),
            .addt_out (DW_CONV_SUM[m])
        );
    end
endgenerate

genvar n;
generate
    for (n = 0; n < `ROW_NUM; n = n + 1) begin : OUTPUT
        // --------------------------------------------------
        // TODO output_en = 1，代表這個ROW可以輸出，然後再透過DW_PW_sel來確定輸出的是哪一種格式
        // --------------------------------------------------
        // 如果是DW模式，則每3個row加一次
        // 如果是PW模式，則每個row獨立計算
        if(n < 30) begin
          if ((n % 3) == 0) begin
              assign reducer2opsum[n*16 +: 16] = (DW_PW_sel) ? PW_SUM[n] : DW_CONV_SUM[n/3];
          end else begin
              assign reducer2opsum[n*16 +: 16] = (DW_PW_sel) ? PW_SUM[n] : 16'd0;
          end
        end
        else begin
          assign reducer2opsum[n*16 +: 16] = (DW_PW_sel) ? PW_SUM[n] : 16'd0;
        end
    end
endgenerate

endmodule