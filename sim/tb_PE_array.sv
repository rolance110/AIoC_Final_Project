`timescale 1ns/1ps

module tb_PE_array;

  // ------------------------------------------------------------------
  // Test-bench 參數 & 訊號
  // ------------------------------------------------------------------
  localparam int COL_NUM   = 32;
  localparam int ROW_NUM   = 32;
  localparam int LATENCY   = 1;   // 單列 MAC + adder-tree latency (改這裡即可)

  logic                    clk = 0;
  logic                    reset = 1;
  logic                    prod_out_en;
  logic [COL_NUM*8-1:0]    array_ifmap_in;
  logic [ROW_NUM*COL_NUM*8-1:0] array_weight_in;
  logic [5:0]              array_weight_en;   // 固定 32 (=6'b1_00000)

  logic [ROW_NUM*16-1:0]   array_opsum;
  logic prod_out_en_d;  // 新增延遲信號
  always_ff @(posedge clk) begin
      prod_out_en_d <= prod_out_en;
  end
  // ------------------------------------------------------------------
  // DUT
  // ------------------------------------------------------------------
  PE_array dut (
      .clk              (clk),
      .reset            (reset),
      .prod_out_en      (prod_out_en),
      .array_ifmap_in   (array_ifmap_in),
      .array_weight_in  (array_weight_in),
      .array_weight_en  (array_weight_en),
      .array_opsum      (array_opsum)
  );

  // ------------------------------------------------------------------
  // Clock & Reset
  // ------------------------------------------------------------------
  always #5 clk = ~clk;      // 100 MHz

  initial begin
    #20 reset = 0;           // 釋放 reset
  end

  initial begin
    $fsdbDumpfile("wave.fsdb");
    $fsdbDumpvars(0, tb_PE_array);
  end

  // ------------------------------------------------------------------
  // 1. 產生權重 (0-20)  → array_weight_in
  // ------------------------------------------------------------------
  logic [7:0] weight   [0:ROW_NUM-1][0:COL_NUM-1];

  initial begin : LOAD_WEIGHT
    automatic int idx = 0;
    for (int r=0; r<ROW_NUM; r++) begin
      for (int c=0; c<COL_NUM; c++) begin
        weight[r][c] = 10;
        array_weight_in[idx +: 8] = weight[r][c];
        idx += 8;
      end
    end
  end
  assign array_weight_en = 6'd32;   // 32 row—all enable once

  // ------------------------------------------------------------------
  // 2. 準備 32 組 ifmap (0-20 循環)
  // ------------------------------------------------------------------
  logic [7:0] ifmap_pattern [0:31][0:COL_NUM-1];  // 擴展到 32 組

  initial begin
    for (int g=0; g<32; g++) begin
      for (int c=0; c<COL_NUM; c++) begin
        ifmap_pattern[g][c] = (g*COL_NUM + c) % 21;  // 限制在 0 到 20
      end
    end
  end

  // ------------------------------------------------------------------
  // 3. 產生 prod_out_en 及 ifmap 流
  //     4 cycle 高 → 10 cycle 低
  // ------------------------------------------------------------------
  int ifmap_idx = 0;            // 指向 ifmap_pattern 的索引
  int cycle_in_group = 0;

  always_ff @(posedge clk) begin
    if (reset) begin
      prod_out_en     <= 0;
      array_ifmap_in  <= '0;
      ifmap_idx       <= 0;
      cycle_in_group  <= 0;
    end
    else begin
      // prod_out_en pattern: 在 cycle_in_group 1 到 4 時為高
      prod_out_en <= (cycle_in_group >=0 && cycle_in_group <=3);

      // 輸入 ifmap: 在 cycle_in_group 0 到 3 時提供連續 4 筆不同的 ifmap
      if (cycle_in_group <=3) begin
        for (int c=0; c<COL_NUM; c++)
          array_ifmap_in[c*8 +:8] <= ifmap_pattern[ifmap_idx + cycle_in_group][c];
      end
      else begin
        array_ifmap_in <= '0;
      end

      // 更新計數器
      cycle_in_group <= cycle_in_group + 1;
      if (cycle_in_group == 14) begin
        cycle_in_group <= 0;
        ifmap_idx      <= (ifmap_idx + 4) % 32;  // 每次跳到下一個 4 組
      end
    end
  end

  // ------------------------------------------------------------------
  // 4. Golden Reference & Scoreboard
  // ------------------------------------------------------------------
// Golden Reference
logic [7:0] row_ifmap [0:31][0:31];  // 記錄每個 ROW 的 ifmap
logic [15:0] golden_psum [0:31];     // 每個 ROW 的 golden psum
int err_cnt = 0;
longint total_chk = 0;

// ifmap 傳播模擬
always_ff @(posedge clk) begin
    if (reset) begin
        for (int r = 0; r < 32; r++) begin
            for (int c = 0; c < 32; c++) begin
                row_ifmap[r][c] <= 0;
            end
        end
    end
    else begin
        // ifmap 往下傳遞
        for (int r = 31; r > 0; r--) begin
            for (int c = 0; c < 32; c++) begin
                row_ifmap[r][c] <= row_ifmap[r-1][c];
            end
        end
        // ROW0 接收新的 ifmap
        if (cycle_in_group <= 3) begin  // 假設前 4 個 cycle 有 ifmap 輸入
            for (int c = 0; c < 32; c++) begin
                row_ifmap[0][c] <= ifmap_pattern[cycle_in_group][c];
            end
        end else begin
            for (int c = 0; c < 32; c++) begin
                row_ifmap[0][c] <= 0;
            end
        end
    end
end

// 計算 golden psum
always_comb begin
    for (int r = 0; r < 32; r++) begin
        golden_psum[r] = 16'd0;
        if (prod_out_en && row_ifmap[r][0] != 0) begin  // 當該 ROW 有 ifmap 時計算
            for (int c = 0; c < 32; c++) begin
                golden_psum[r] += weight[r][c] * row_ifmap[r][c];
            end
        end
    end
end

// Scoreboard 比較
always_ff @(posedge clk) begin
    if (!reset && prod_out_en) begin
        for (int r = 0; r < 32; r++) begin
            total_chk++;
            if (array_opsum[r*16 +:16] !== golden_psum[r]) begin
                $display("[%0t]  ERROR  row=%0d  expect=%0d  got=%0d",
                          $time, r, golden_psum[r], array_opsum[r*16 +:16]);
                err_cnt++;
            end else begin
                $display("[%0t]  PASS  row=%0d  expect=%0d  got=%0d",
                          $time, r, golden_psum[r], array_opsum[r*16 +:16]);
            end
        end
    end
end

  // ------------------------------------------------------------------
  // Finish
  // ------------------------------------------------------------------
  initial begin
      #50000;  // 模擬 50 µs
      if (err_cnt==0)
          $display("PASSED  -- %0d cases compared OK", total_chk);
      else
          $display("FAILED  : %0d / %0d compare mismatch!", err_cnt, total_chk);
      $finish;
  end

endmodule