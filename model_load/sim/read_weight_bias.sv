`timescale 1ns/1ps

module tb;

  // --- 宣告 memory ---
  parameter MEM_SIZE = 65536;
  reg [7:0] memory [0:MEM_SIZE-1];

  

  // --- 模擬波形 ---
 initial begin
    `ifdef FSDB
      $fsdbDumpfile("top.fsdb");
      $fsdbDumpvars;
    `elsif FSDB_ALL
      $fsdbDumpfile("top.fsdb");
      $fsdbDumpvars;
      $fsdbDumpMDA;
    `endif
  end


  // --- 層資訊以 array 管理 ---
  integer K_arr[0:52];
  integer D_arr[0:52];
  integer kH_arr[0:52];
  integer kW_arr[0:52];
  integer wsize_arr[0:52];
  integer bsize_arr[0:52];
  integer base_addr_arr[0:52];

  integer num_layers;
  integer addr_cursor;

  // --- 層名稱用 reg array 儲存 ---
  reg [8*64-1:0] layer_names [0:52];

  // --- 初始化名稱 ---
  initial begin
    layer_names[0] = "features_0";
    layer_names[1] = "features_3_conv_0";
    layer_names[2] = "features_3_conv_3";
    layer_names[3] = "features_4_conv_0";
    layer_names[4] = "features_4_conv_3";
    layer_names[5] = "features_4_conv_6";
    layer_names[6] = "features_5_conv_0";
    layer_names[7] = "features_5_conv_3";
    layer_names[8] = "features_5_conv_6";
    layer_names[9] = "features_6_conv_0";
    layer_names[10] = "features_6_conv_3";
    layer_names[11] = "features_6_conv_6";
    layer_names[12] = "features_7_conv_0";
    layer_names[13] = "features_7_conv_3";
    layer_names[14] = "features_7_conv_6";
    layer_names[15] = "features_8_conv_0";
    layer_names[16] = "features_8_conv_3";
    layer_names[17] = "features_8_conv_6";
    layer_names[18] = "features_9_conv_0";
    layer_names[19] = "features_9_conv_3";
    layer_names[20] = "features_9_conv_6";
    layer_names[21] = "features_10_conv_0";
    layer_names[22] = "features_10_conv_3";
    layer_names[23] = "features_10_conv_6";
    layer_names[24] = "features_11_conv_0";
    layer_names[25] = "features_11_conv_3";
    layer_names[26] = "features_11_conv_6";
    layer_names[27] = "features_12_conv_0";
    layer_names[28] = "features_12_conv_3";
    layer_names[29] = "features_12_conv_6";
    layer_names[30] = "features_13_conv_0";
    layer_names[31] = "features_13_conv_3";
    layer_names[32] = "features_13_conv_6";
    layer_names[33] = "features_14_conv_0";
    layer_names[34] = "features_14_conv_3";
    layer_names[35] = "features_14_conv_6";
    layer_names[36] = "features_15_conv_0";
    layer_names[37] = "features_15_conv_3";
    layer_names[38] = "features_15_conv_6";
    layer_names[39] = "features_16_conv_0";
    layer_names[40] = "features_16_conv_3";
    layer_names[41] = "features_16_conv_6";
    layer_names[42] = "features_17_conv_0";
    layer_names[43] = "features_17_conv_3";
    layer_names[44] = "features_17_conv_6";
    layer_names[45] = "features_18_conv_0";
    layer_names[46] = "features_18_conv_3";
    layer_names[47] = "features_18_conv_6";
    layer_names[48] = "features_19_conv_0";
    layer_names[49] = "features_19_conv_3";
    layer_names[50] = "features_19_conv_6";
    layer_names[51] = "features_20";
    layer_names[52] = "classifier_0";
  end

  // --- 載入權重與 Bias ---
  integer i, wfd, bfd;
  reg [8*256-1:0] wfile, bfile;
  reg [8*256-1:0] hex_path;
  reg [8*64-1:0] layer_str;
  reg [8*256-1:0] line;
  integer wline_idx, bline_idx;
  integer byte_val, bias_val;
  integer dummy;


  initial begin
    // 預設 hex_path
    hex_path = "../layer_info";
    addr_cursor = 0;
    num_layers = 0;

    for (i = 0; i < 53; i = i + 1) begin
      // 組合檔案名稱
      layer_str = layer_names[i];
      $swrite(wfile, "%0s/%0s_weight.hex", hex_path,  layer_str);
      $swrite(bfile, "%0s/%0s_bias_int16.hex", hex_path,  layer_str);

      wfd = $fopen(wfile, "r");
      bfd = $fopen(bfile, "r");

      if (wfd == 0 || bfd == 0) begin
        $display("[WARNING] Missing %s or %s", wfile, bfile);
        continue;
      end

      // 判斷是否為 linear 層
      if (layer_names[i][8*64-1 -: 12] == "classifier_0") begin
        dummy = $fscanf(wfd, "%d %d\n", K_arr[i], D_arr[i]);
        kH_arr[i] = 1;
        kW_arr[i] = 1;
      end else begin
        dummy = $fscanf(wfd, "%x %x %x %x\n", K_arr[i], D_arr[i], kH_arr[i], kW_arr[i]);
      end

      wsize_arr[i] = K_arr[i] * D_arr[i] * kH_arr[i] * kW_arr[i];
      bsize_arr[i] = K_arr[i];
      base_addr_arr[i] = addr_cursor;

      $display("[INFO] Layer %0d (%s): shape=(%0d,%0d,%0d,%0d) @%0d",
        i, layer_names[i], K_arr[i], D_arr[i], kH_arr[i], kW_arr[i], addr_cursor);

      // 讀取 weight
      wline_idx = 0;
      while (!$feof(wfd)) begin
        dummy = $fgets(line, wfd);
        if ($sscanf(line, "%x", byte_val)) begin
          memory[addr_cursor] = byte_val[7:0];
          addr_cursor = addr_cursor + 1;
          wline_idx = wline_idx + 1;
        end
      end
      $fclose(wfd);

      // 讀取 bias
      bline_idx = 0;
      while (!$feof(bfd) && bline_idx < K_arr[i]) begin
        dummy = $fgets(line, bfd);
        if ($sscanf(line, "%x", bias_val)) begin
          memory[addr_cursor]     = bias_val[15:8];  // high byte
          memory[addr_cursor + 1] = bias_val[7:0];   // low byte
          addr_cursor = addr_cursor + 2;
          bline_idx = bline_idx + 1;
        end
      end
      $fclose(bfd);

      $display("[INFO] Layer %0d loaded: %0d weights, %0d biases", i, wline_idx, bline_idx);
      num_layers = num_layers + 1;
    end

    $display("[INFO] Loaded %0d layers, memory used = %0d bytes", num_layers, addr_cursor);

    //  memory
    for (i = 0; i < 929; i = i + 1) begin
      $display("memory[%0d] = 0x%02x", i, memory[i]);
    end

    $finish;
  end

endmodule
