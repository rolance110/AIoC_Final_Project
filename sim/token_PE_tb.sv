`include "../include/define.svh"
`include "../sim/SRAM_64KB.sv"
module token_PE_tb;

//TODO: CONFIGURE SETTINGS
    parameter POINTWISE_N = 32'd40;
    parameter COMPUTE_ROW = 32'd3;
    // 紀錄之前 tile 已經計算幾個 ofmap row
    parameter Already_COMP_ROW = 32'd0; // Depthwise layer 會需要根據這個訊號去往上計數 => 確認是否需要 top pad, bottom pad
    parameter SCALE_FACTOR = 6'd0; // scaling factor
    parameter NEED_PPU_CONFIG = 0; // 是否需要 PPU 處理


    // 時鐘和重置訊號
    logic clk;
    logic rst_n;

    // token_engine 的輸入訊號
    logic         pass_start_i;
    logic [1:0]   layer_type_i;
    logic [31:0]  weight_GLB_base_addr_i;
    logic [31:0]  ifmap_GLB_base_addr_i;
    logic [31:0]  ipsum_GLB_base_addr_i;
    logic [31:0]  bias_GLB_base_addr_i;
    logic [31:0]  opsum_GLB_base_addr_i;
    logic         is_bias_i;
    logic [31:0]  tile_n_i;
    logic [7:0]   in_C_i;
    logic [7:0]   in_R_i;
    logic [1:0]   pad_R_i;
    logic [1:0]   pad_L_i;
    logic [1:0]   pad_T_i;
    logic [1:0]   pad_B_i;
    logic [7:0]   out_C_i;
    logic [7:0]   out_R_i;
    logic [7:0]   IC_real_i;
    logic [7:0]   OC_real_i;
    logic [31:0]  On_real_i;
    logic [31:0]  glb_read_data_i;

    // token_engine 的輸出訊號
    logic         pass_done_o;
    logic PE_en_matrix_o[31:0][31:0] ;
    logic PE_stall_matrix_o[31:0][31:0];
    logic [7:0]        weight_in_o;
    logic  weight_load_en_matrix_o[31:0][31:0];
    logic              ifmap_fifo_reset_o;
    logic [31:0]       ifmap_fifo_push_matrix_o;
    logic [31:0]       ifmap_fifo_push_mod_matrix_o;
    logic [31:0]       ifmap_fifo_pop_matrix_o;
    logic [31:0]       ifmap_fifo_push_data_matrix_o [31:0];
    logic              ipsum_fifo_reset_o;
    logic [31:0]       ipsum_fifo_push_matrix_o;
    logic [31:0]       ipsum_fifo_push_mod_matrix_o;
    logic [31:0]       ipsum_fifo_push_data_matrix_o [31:0];
    logic [31:0]       ipsum_fifo_pop_matrix_o;
    logic              opsum_fifo_reset_o;
    logic [31:0]       opsum_fifo_push_matrix_o;
    logic [31:0]       opsum_fifo_push_mod_matrix_o;
    logic [31:0]       opsum_fifo_push_data_matrix_o [31:0];
    logic [31:0]       opsum_fifo_pop_matrix_o;

    // FIFO 狀態訊號（conv_unit 輸出到 token_engine）
    logic [31:0] ifmap_fifo_full;
    logic [31:0] ifmap_fifo_empty;
    logic [31:0] ipsum_fifo_full;
    logic [31:0] ipsum_fifo_empty;
    logic [31:0] opsum_fifo_full;
    logic [31:0] opsum_fifo_empty;

    // conv_unit 的輸入訊號
    logic [1:0]        layer_type;
    logic [31:0]       push_ifmap_en;
    logic [31:0]       push_ifmap_mod;
    logic [31:0]       push_ifmap_data;
    logic [31:0]       pop_ifmap_en;
    logic [7:0]        weight_in;
    logic weight_load_en[31:0][31:0];
    logic PE_en_matrix[31:0][31:0];
    logic PE_stall_matrix[31:0][31:0];
    logic [31:0]       push_ipsum_en;
    logic [31:0]       push_ipsum_mod;
    logic [31:0]       push_ipsum_data;
    logic [31:0]       pop_ipsum_en;
    logic              ipsum_read_en;
    logic              ipsum_add_en;
    logic [31:0]       opsum_push_en;
    logic [31:0]       opsum_pop_en;
    logic [31:0]       opsum_pop_mod;
    logic n_tile_is_first_i;
    logic n_tile_is_last_i;
    logic [31:0] Already_Compute_Row;

    logic [3:0] flags;

    // conv_unit 的輸出訊號
    logic [31:0]       opsum_pop_data [31:0];

    logic [1:0] stride;
    logic [5:0] scaling_factor;

logic [31:0] opsum_fifo_pop_data_matrix_i[31:0];
logic [31:0] glb_addr_o;
logic [31:0] glb_write_data_o;
logic [3:0] glb_web_o;

    initial begin
        `ifdef FSDB
            $fsdbDumpfile("../wave/top.fsdb");
            $fsdbDumpvars(0, u_token_engine, u_conv_unit, u_SRAM);
        `elsif FSDB_ALL
            $fsdbDumpfile("../wave/top.fsdb");
            $fsdbDumpvars("+struct", "+mda", "+all", u_token_engine, u_conv_unit, u_SRAM);
        `endif
    end

    // 定義 golden 數據陣列
    logic [31:0] golden_opsum [0:16383]; // 640 個 32-bit 值

initial begin
    `ifdef POINTWISE_TYPE
        // 讀取 pointwise_memory.hex 到 SRAM
        $readmemh("../sim/pointwise_memory.hex", u_SRAM.memory);
        $display("===== SRAM initialized from pointwise_memory.hex =====");
        // 讀取 pointwise_golden.hex 到 golden_opsum 陣列
        $readmemh("../sim/pointwise_golden.hex", golden_opsum);
        $display("===== Golden data loaded from pointwise_golden.hex =====");
    `elsif DEPTHWISE_TYPE
        // // 讀取 depthwise_memory.hex 到 SRAM
        $readmemh("../sim/depthwise_memory.hex", u_SRAM.memory);
        $display("===== SRAM initialized from depthwise_memory.hex =====");
        // 讀取 depthwise_golden.hex 到 golden_opsum 陣列
        $readmemh("../sim/depthwise_golden.hex", golden_opsum);
        $display("===== Golden data loaded from depthwise_golden.hex =====");
        // $readmemh("../sim/memory.hex", u_SRAM.memory);
        $display("===== SRAM initialized from depthwise_golden.hex =====");
    `elsif DEPTHWISE_STRIDE2_TYPE
        // // 讀取 depthwise_memory.hex 到 SRAM
        $readmemh("../sim/depthwise_stride2_memory.hex", u_SRAM.memory);
        $display("===== SRAM initialized from depthwise_stride2_memory.hex =====");
        // 讀取 depthwise_golden.hex 到 golden_opsum 陣列
        $readmemh("../sim/depthwise_stride2_golden.hex", golden_opsum);
        $display("===== Golden data loaded from depthwise_stride2_golden.hex =====");

        $display("===== SRAM initialized from depthwise_stride2_golden.hex =====");
    `elsif POINTWISE_PPU_RELU_TYPE
        // 讀取 pointwise_memory.hex 到 SRAM
        $readmemh("../sim/pointwise_ppu_relu_memory.hex", u_SRAM.memory);
        $display("===== SRAM initialized from pointwise_ppu_relu_memory.hex =====");
        // 讀取 pointwise_golden.hex 到 golden_opsum 陣列
        $readmemh("../sim/pointwise_ppu_relu_golden.hex", golden_opsum);
        $display("===== Golden data loaded from pointwise_ppu_relu_golden.hex =====");
    `elsif DEPTHWISE_PPU_RELU_TYPE
        // 讀取 pointwise_memory.hex 到 SRAM
        $readmemh("../sim/depthwise_ppu_relu_memory.hex", u_SRAM.memory);
        $display("===== SRAM initialized from depthwise_ppu_relu_memory.hex =====");
        // 讀取 pointwise_golden.hex 到 golden_opsum 陣列
        $readmemh("../sim/depthwise_ppu_relu_golden.hex", golden_opsum);
        $display("===== Golden data loaded from depthwise_ppu_relu_golden.hex =====");
    `elsif DEPTHWISE_STRIDE2_PPU_RELU_TYPE
        // 讀取 pointwise_memory.hex 到 SRAM
        $readmemh("../sim/depthwise_stride2_ppu_relu_memory.hex", u_SRAM.memory);
        $display("===== SRAM initialized from depthwise_stride2_ppu_relu_memory.hex =====");
        // 讀取 pointwise_golden.hex 到 golden_opsum 陣列
        $readmemh("../sim/depthwise_stride2_ppu_relu_golden.hex", golden_opsum);
        $display("===== Golden data loaded from depthwise_stride2_ppu_relu_golden.hex =====");
    `elsif POINTWISE_PPU_TYPE
        // 讀取 pointwise_memory.hex 到 SRAM
        $readmemh("../sim/pointwise_ppu_memory.hex", u_SRAM.memory);
        $display("===== SRAM initialized from pointwise_ppu_memory.hex =====");
        // 讀取 pointwise_golden.hex 到 golden_opsum 陣列
        $readmemh("../sim/pointwise_ppu_golden.hex", golden_opsum);
        $display("===== Golden data loaded from pointwise_ppu_golden.hex =====");
    `elsif DEPTHWISE_PPU_TYPE
        // 讀取 pointwise_memory.hex 到 SRAM
        $readmemh("../sim/depthwise_ppu_memory.hex", u_SRAM.memory);
        $display("===== SRAM initialized from depthwise_ppu_memory.hex =====");
        // 讀取 pointwise_golden.hex 到 golden_opsum 陣列
        $readmemh("../sim/depthwise_ppu_golden.hex", golden_opsum);
        $display("===== Golden data loaded from depthwise_ppu_golden.hex =====");
    `elsif DEPTHWISE_STRIDE2_PPU_TYPE
        // 讀取 pointwise_memory.hex 到 SRAM
        $readmemh("../sim/depthwise_stride2_ppu_memory.hex", u_SRAM.memory);
        $display("===== SRAM initialized from depthwise_stride2_ppu_memory.hex =====");
        // 讀取 pointwise_golden.hex 到 golden_opsum 陣列
        $readmemh("../sim/depthwise_stride2_ppu_golden.hex", golden_opsum);
        $display("===== Golden data loaded from depthwise_stride2_ppu_golden.hex =====");
    `endif
end
logic Need_PPU;
logic [31:0] write_data;
    SRAM_64KB u_SRAM (
        .clk(clk),
        .rst_n(rst_n),
        .WEB(glb_web_o), // 假設寫使能為全 0
        .addr(glb_addr_o), // 使用地址的高 14 位
        .write_data(glb_write_data_o),
        .read_data(glb_read_data_i)
    );


    // 實例化 token_engine
    token_engine u_token_engine (
        .clk(clk),
        .rst_n(rst_n),
        .pass_start_i(pass_start_i),
        .pass_done_o(pass_done_o),

        .layer_type_i(layer_type_i),

        .weight_GLB_base_addr_i(weight_GLB_base_addr_i),
        .ifmap_GLB_base_addr_i(ifmap_GLB_base_addr_i),
        .ipsum_GLB_base_addr_i(ipsum_GLB_base_addr_i), 
        .bias_GLB_base_addr_i(bias_GLB_base_addr_i),
        .opsum_GLB_base_addr_i(opsum_GLB_base_addr_i),

        .is_bias_i(is_bias_i), 
        .Need_PPU_i(Need_PPU),
        .flags_i(flags), // flags 設定

        .n_tile_is_first_i(n_tile_is_first_i),
        .n_tile_is_last_i(n_tile_is_last_i),
        .Already_Compute_Row_i(Already_Compute_Row), // Depthwise layer 會需要根據這個訊號去往上計數 => 確認是否需要 top pad, bottom pad



        .tile_n_i(tile_n_i),
        .stride_i(stride), // stride 設定
        .scaling_factor_i(scaling_factor), // scaling factor


        .in_C_i(in_C_i),
        .in_R_i(in_R_i),
        .pad_R_i(pad_R_i),
        .pad_L_i(pad_L_i),
        .pad_T_i(pad_T_i),
        .pad_B_i(pad_B_i),
        .out_C_i(out_C_i),
        .out_R_i(out_R_i),
        .IC_real_i(IC_real_i),
        .OC_real_i(OC_real_i),
        .On_real_i(On_real_i),
        .glb_read_data_i(glb_read_data_i),
        .opsum_fifo_pop_data_matrix_i(opsum_pop_data),


//* to GLB
        .glb_web_o(glb_web_o),
        .glb_addr_o(glb_addr_o),
        .glb_write_data_o(glb_write_data_o),
//* to conv.pe_array
        .PE_en_matrix_o(PE_en_matrix_o),
        .PE_stall_matrix_o(PE_stall_matrix_o),
//* to conv.pe_array.weight 
        .weight_in_o(weight_in_o),
        .weight_load_en_matrix_o(weight_load_en_matrix_o),
//* to FIFO
        .ifmap_fifo_reset_o(ifmap_fifo_reset_o),
        .ifmap_fifo_push_matrix_o(ifmap_fifo_push_matrix_o),
        .ifmap_fifo_push_mod_matrix_o(ifmap_fifo_push_mod_matrix_o),
        .ifmap_fifo_pop_matrix_o(ifmap_fifo_pop_matrix_o),
        .ifmap_fifo_push_data_matrix_o(ifmap_fifo_push_data_matrix_o),
        .ipsum_fifo_reset_o(ipsum_fifo_reset_o),
        .ipsum_fifo_push_matrix_o(ipsum_fifo_push_matrix_o),
        .ipsum_fifo_push_mod_matrix_o(ipsum_fifo_push_mod_matrix_o),
        .ipsum_fifo_push_data_matrix_o(ipsum_fifo_push_data_matrix_o),
        .ipsum_fifo_pop_matrix_o(ipsum_fifo_pop_matrix_o),
        .opsum_fifo_reset_o(opsum_fifo_reset_o),
        .opsum_fifo_push_matrix_o(opsum_fifo_push_matrix_o),
        .opsum_fifo_push_mod_matrix_o(opsum_fifo_push_mod_matrix_o),
        .opsum_fifo_push_data_matrix_o(opsum_fifo_push_data_matrix_o),
        .opsum_fifo_pop_matrix_o(opsum_fifo_pop_matrix_o),
//* from FIFO
        .ifmap_fifo_full_matrix_i(ifmap_fifo_full),
        .ifmap_fifo_empty_matrix_i(ifmap_fifo_empty),
        .ipsum_fifo_full_matrix_i(ipsum_fifo_full),
        .ipsum_fifo_empty_matrix_i(ipsum_fifo_empty),
        .opsum_fifo_full_matrix_i(opsum_fifo_full),
        .opsum_fifo_empty_matrix_i(opsum_fifo_empty)
    );

    // 實例化 conv_unit
    conv_unit u_conv_unit (
        .clk(clk),
        .rst_n(rst_n),

//* reset
        .ifmap_fifo_reset_i(ifmap_fifo_reset_o),
        .ipsum_fifo_reset_i(ipsum_fifo_reset_o),
        .opsum_fifo_reset_i(opsum_fifo_reset_o),


        .layer_type(layer_type_i), // 與 token_engine 共用相同的 layer_type_i
        .push_ifmap_en(ifmap_fifo_push_matrix_o),
        .push_ifmap_mod(ifmap_fifo_push_mod_matrix_o),
        .push_ifmap_data(ifmap_fifo_push_data_matrix_o), 
        .pop_ifmap_en(ifmap_fifo_pop_matrix_o),
        .weight_in(weight_in_o),
        .weight_load_en(weight_load_en_matrix_o),
        .PE_en_matrix(PE_en_matrix_o),
        .PE_stall_matrix(PE_stall_matrix_o),
        .push_ipsum_en(ipsum_fifo_push_matrix_o),
        .push_ipsum_mod(ipsum_fifo_push_mod_matrix_o),
        .push_ipsum_data(ipsum_fifo_push_data_matrix_o), 
        .pop_ipsum_en(ipsum_fifo_pop_matrix_o),
        .ipsum_read_en(ipsum_read_en),
        .ipsum_add_en(ipsum_add_en),
        .opsum_push_en(opsum_fifo_push_matrix_o),
        .opsum_pop_en(opsum_fifo_pop_matrix_o),
        .opsum_pop_mod(opsum_fifo_push_mod_matrix_o), // 使用 push_mod 作為 pop_mod
        .ifmap_fifo_full(ifmap_fifo_full),
        .ifmap_fifo_empty(ifmap_fifo_empty),
        .ipsum_fifo_full(ipsum_fifo_full),
        .ipsum_fifo_empty(ipsum_fifo_empty),
        .opsum_fifo_full(opsum_fifo_full),
        .opsum_fifo_empty(opsum_fifo_empty),
        .opsum_pop_data(opsum_pop_data)
    );

    // 時鐘產生器
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns 週期
    end

    // 初始重置和輸入驅動
    initial begin
        // 初始化訊號
        
        `ifdef POINTWISE_TYPE
            // 初始化訊號
            rst_n = 0;
            pass_start_i = 0;
            layer_type_i = `POINTWISE;
            weight_GLB_base_addr_i = 32'h0000_0000;
            ifmap_GLB_base_addr_i = 32'h0000_1000;
            ipsum_GLB_base_addr_i = 32'h0000_2000;
            bias_GLB_base_addr_i = 32'h0000_2500;
            opsum_GLB_base_addr_i = 32'h0000_3000;
            is_bias_i = 0;
            tile_n_i = POINTWISE_N;
            in_C_i = 8'd224;
            in_R_i = 8'd224;
            n_tile_is_first_i = 1; // 第一個 tile
            n_tile_is_last_i = 0; // 不是最後一個 tile
            Already_Compute_Row = 8'd0; // Pointwise layer 不需要這個訊號
            pad_R_i = 2'd0;
            pad_L_i = 2'd0;
            pad_T_i = 2'd0;
            pad_B_i = 2'd0;
            out_C_i = 8'd224;
            out_R_i = 8'd224;
            IC_real_i = 8'd32;
            OC_real_i = 8'd32;
            On_real_i = POINTWISE_N;
            // glb_read_data_i = 32'd0;// read from SRAM
            ipsum_read_en = 0;
            ipsum_add_en = 1;
            stride = 2'd1;
            flags = 4'b0000;//0bit -> relu
            scaling_factor = 6'd0; // scaling factor
            Need_PPU = 1'd0; // 是否需要 PPU 處理
            // 重置解除
            #20 rst_n = 1;

            // 啟動 token_engine
            #10 pass_start_i = 1;
            #10 pass_start_i = 0;

            // 模擬運行一段時間
           #100000 
            $display("Simulation Failed: No pass_done_o signal received.");

           $finish;
        `elsif DEPTHWISE_TYPE
            rst_n = 0;
            pass_start_i = 0;
            layer_type_i = `DEPTHWISE;
            weight_GLB_base_addr_i = 32'h0000_0000;
            ifmap_GLB_base_addr_i = 32'h0000_1000;
            ipsum_GLB_base_addr_i = 32'h0000_2000;
            bias_GLB_base_addr_i = 32'h0000_2500;
            opsum_GLB_base_addr_i = 32'h0000_3000;
            
            is_bias_i = 0; //*
            tile_n_i = COMPUTE_ROW; //* 1 tile has tile_n_i row

            in_C_i = 8'd224;
            in_R_i = 8'd224;
            Already_Compute_Row = Already_COMP_ROW; // Depthwise layer 會需要根據這個訊號去往上計數 => 確認是否需要 top pad, bottom pad 
            n_tile_is_first_i = 1; // 第一個 tile
            n_tile_is_last_i = 0; // 不是最後一個 tile
            stride = 2'd1;
            pad_R_i = 2'd1;
            pad_L_i = 2'd1;
            pad_T_i = 2'd1;
            pad_B_i = 2'd1;
            out_C_i = 8'd224;
            out_R_i = 8'd224;
            IC_real_i = 8'd10;
            OC_real_i = 8'd10;
            On_real_i = COMPUTE_ROW - 32'd2; //* tile_n_i - 2
            ipsum_read_en = 0;
            ipsum_add_en = 1;
            flags = 4'b0000;
            scaling_factor = 6'd0; // scaling factor
            Need_PPU = 1'd0; // 是否需要 PPU 處理
            // 重置解除
            #20 rst_n = 1;

            // 啟動 token_engine
            #10 pass_start_i = 1;
            #10 pass_start_i = 0;

            // 模擬運行一段時間
          #500000
            $display("Simulation Failed: No pass_done_o signal received.");
            $finish;
        `elsif DEPTHWISE_STRIDE2_TYPE
            rst_n = 0;
            pass_start_i = 0;
            layer_type_i = `DEPTHWISE;
            weight_GLB_base_addr_i = 32'h0000_0000;
            ifmap_GLB_base_addr_i = 32'h0000_1000;
            ipsum_GLB_base_addr_i = 32'h0000_2000;
            bias_GLB_base_addr_i = 32'h0000_2900;
            opsum_GLB_base_addr_i = 32'h0000_3000;
            
            is_bias_i = 0; //*
            tile_n_i = 5; //* 1 tile has tile_n_i row

            in_C_i = 8'd114;
            in_R_i = 8'd114;
            Already_Compute_Row = Already_COMP_ROW; // Depthwise layer 會需要根據這個訊號去往上計數 => 確認是否需要 top pad, bottom pad 
            n_tile_is_first_i = 1; // 第一個 tile
            n_tile_is_last_i = 0; // 不是最後一個 tile
            stride = 2'd2;
            pad_R_i = 2'd1;
            pad_L_i = 2'd1;
            pad_T_i = 2'd1;
            pad_B_i = 2'd1;
            out_C_i = 8'd57;
            out_R_i = 8'd57;
            IC_real_i = 8'd10;
            OC_real_i = 8'd10;
            On_real_i = 2; //* tile_n_i - 2
            ipsum_read_en = 0;
            ipsum_add_en = 1;
            flags = 4'b0000;
            scaling_factor = 6'd0; // scaling factor
            Need_PPU = 1'd0; // 是否需要 PPU 處理

            // 重置解除
            #20 rst_n = 1;

            // 啟動 token_engine
            #10 pass_start_i = 1;
            #10 pass_start_i = 0;

            // 模擬運行一段時間
          #500000
            $display("Simulation Failed: No pass_done_o signal received.");
            $finish;
        `elsif POINTWISE_PPU_RELU_TYPE
            // 初始化訊號
            rst_n = 0;
            pass_start_i = 0;
            layer_type_i = `POINTWISE;
            weight_GLB_base_addr_i = 32'h0000_0000;
            ifmap_GLB_base_addr_i = 32'h0000_1000;
            ipsum_GLB_base_addr_i = 32'h0000_2000;
            bias_GLB_base_addr_i = 32'h0000_2500;
            opsum_GLB_base_addr_i = 32'h0000_3000;
            is_bias_i = 0;
            tile_n_i = POINTWISE_N;
            in_C_i = 8'd224;
            in_R_i = 8'd224;
            n_tile_is_first_i = 1; // 第一個 tile
            n_tile_is_last_i = 0; // 不是最後一個 tile
            Already_Compute_Row = 8'd0; // Pointwise layer 不需要這個訊號
            pad_R_i = 2'd0;
            pad_L_i = 2'd0;
            pad_T_i = 2'd0;
            pad_B_i = 2'd0;
            out_C_i = 8'd224;
            out_R_i = 8'd224;
            IC_real_i = 8'd32;
            OC_real_i = 8'd32;
            On_real_i = POINTWISE_N;
            // glb_read_data_i = 32'd0;// read from SRAM
            ipsum_read_en = 0;
            ipsum_add_en = 1;
            stride = 2'd1;
            flags = 4'b0001;//0bit -> relu
            scaling_factor = 6'd1; // scaling factor
            Need_PPU = 1'd1; // 是否需要 PPU 處理
            // 重置解除
            #20 rst_n = 1;

            // 啟動 token_engine
            #10 pass_start_i = 1;
            #10 pass_start_i = 0;

            // 模擬運行一段時間
            #100000 
            $display("Simulation Failed: No pass_done_o signal received.");
           $finish;
        `elsif DEPTHWISE_PPU_RELU_TYPE
            rst_n = 0;
            pass_start_i = 0;
            layer_type_i = `DEPTHWISE;
            weight_GLB_base_addr_i = 32'h0000_0000;
            ifmap_GLB_base_addr_i = 32'h0000_1000;
            ipsum_GLB_base_addr_i = 32'h0000_2000;
            bias_GLB_base_addr_i = 32'h0000_2500;
            opsum_GLB_base_addr_i = 32'h0000_3000;
            
            is_bias_i = 0; //*
            tile_n_i = COMPUTE_ROW; //* 1 tile has tile_n_i row

            in_C_i = 8'd224;
            in_R_i = 8'd224;
            Already_Compute_Row = Already_COMP_ROW; // Depthwise layer 會需要根據這個訊號去往上計數 => 確認是否需要 top pad, bottom pad 
            n_tile_is_first_i = 1; // 第一個 tile
            n_tile_is_last_i = 0; // 不是最後一個 tile
            stride = 2'd1;
            pad_R_i = 2'd1;
            pad_L_i = 2'd1;
            pad_T_i = 2'd1;
            pad_B_i = 2'd1;
            out_C_i = 8'd224;
            out_R_i = 8'd224;
            IC_real_i = 8'd10;
            OC_real_i = 8'd10;
            On_real_i = COMPUTE_ROW - 32'd2; //* tile_n_i - 2
            ipsum_read_en = 0;
            ipsum_add_en = 1;
            flags = 4'b0001;
            scaling_factor = 6'd3; // scaling factor
            Need_PPU = 1'd1; // 是否需要 PPU 處理
            // 重置解除
            #20 rst_n = 1;

            // 啟動 token_engine
            #10 pass_start_i = 1;
            #10 pass_start_i = 0;

            // 模擬運行一段時間
          #500000
            $display("Simulation Failed: No pass_done_o signal received.");
            $finish;
        `elsif DEPTHWISE_STRIDE2_PPU_RELU_TYPE
            rst_n = 0;
            pass_start_i = 0;
            layer_type_i = `DEPTHWISE;
            weight_GLB_base_addr_i = 32'h0000_0000;
            ifmap_GLB_base_addr_i = 32'h0000_1000;
            ipsum_GLB_base_addr_i = 32'h0000_2000;
            bias_GLB_base_addr_i = 32'h0000_2900;
            opsum_GLB_base_addr_i = 32'h0000_3000;
            
            is_bias_i = 0; //*
            tile_n_i = 5; //* 1 tile has tile_n_i row

            in_C_i = 8'd114;
            in_R_i = 8'd114;
            Already_Compute_Row = Already_COMP_ROW; // Depthwise layer 會需要根據這個訊號去往上計數 => 確認是否需要 top pad, bottom pad 
            n_tile_is_first_i = 1; // 第一個 tile
            n_tile_is_last_i = 0; // 不是最後一個 tile
            stride = 2'd2;
            pad_R_i = 2'd1;
            pad_L_i = 2'd1;
            pad_T_i = 2'd1;
            pad_B_i = 2'd1;
            out_C_i = 8'd57;
            out_R_i = 8'd57;
            IC_real_i = 8'd10;
            OC_real_i = 8'd10;
            On_real_i = 2; //* tile_n_i - 2
            ipsum_read_en = 0;
            ipsum_add_en = 1;
            flags = 4'b0001;
            scaling_factor = 6'd2; // scaling factor
            Need_PPU = 1'd1; // 是否需要 PPU 處理

            // 重置解除
            #20 rst_n = 1;

            // 啟動 token_engine
            #10 pass_start_i = 1;
            #10 pass_start_i = 0;

            // 模擬運行一段時間
          #500000
            $display("Simulation Failed: No pass_done_o signal received.");
            $finish;
        `elsif POINTWISE_PPU_TYPE
            // 初始化訊號
            rst_n = 0;
            pass_start_i = 0;
            layer_type_i = `POINTWISE;
            weight_GLB_base_addr_i = 32'h0000_0000;
            ifmap_GLB_base_addr_i = 32'h0000_1000;
            ipsum_GLB_base_addr_i = 32'h0000_2000;
            bias_GLB_base_addr_i = 32'h0000_2500;
            opsum_GLB_base_addr_i = 32'h0000_3000;
            is_bias_i = 0;
            tile_n_i = POINTWISE_N;
            in_C_i = 8'd224;
            in_R_i = 8'd224;
            n_tile_is_first_i = 1; // 第一個 tile
            n_tile_is_last_i = 0; // 不是最後一個 tile
            Already_Compute_Row = 8'd0; // Pointwise layer 不需要這個訊號
            pad_R_i = 2'd0;
            pad_L_i = 2'd0;
            pad_T_i = 2'd0;
            pad_B_i = 2'd0;
            out_C_i = 8'd224;
            out_R_i = 8'd224;
            IC_real_i = 8'd32;
            OC_real_i = 8'd32;
            On_real_i = POINTWISE_N;
            // glb_read_data_i = 32'd0;// read from SRAM
            ipsum_read_en = 0;
            ipsum_add_en = 1;
            stride = 2'd1;
            flags = 4'b0000;//0bit -> relu
            scaling_factor = 6'd1; // scaling factor
            Need_PPU = 1'd1; // 是否需要 PPU 處理
            // 重置解除
            #20 rst_n = 1;

            // 啟動 token_engine
            #10 pass_start_i = 1;
            #10 pass_start_i = 0;

            // 模擬運行一段時間
            #100000 
            $display("Simulation Failed: No pass_done_o signal received.");
           $finish;
        `elsif DEPTHWISE_PPU_TYPE
            rst_n = 0;
            pass_start_i = 0;
            layer_type_i = `DEPTHWISE;
            weight_GLB_base_addr_i = 32'h0000_0000;
            ifmap_GLB_base_addr_i = 32'h0000_1000;
            ipsum_GLB_base_addr_i = 32'h0000_2000;
            bias_GLB_base_addr_i = 32'h0000_2500;
            opsum_GLB_base_addr_i = 32'h0000_3000;
            
            is_bias_i = 0; //*
            tile_n_i = COMPUTE_ROW; //* 1 tile has tile_n_i row

            in_C_i = 8'd224;
            in_R_i = 8'd224;
            Already_Compute_Row = Already_COMP_ROW; // Depthwise layer 會需要根據這個訊號去往上計數 => 確認是否需要 top pad, bottom pad 
            n_tile_is_first_i = 1; // 第一個 tile
            n_tile_is_last_i = 0; // 不是最後一個 tile
            stride = 2'd1;
            pad_R_i = 2'd1;
            pad_L_i = 2'd1;
            pad_T_i = 2'd1;
            pad_B_i = 2'd1;
            out_C_i = 8'd224;
            out_R_i = 8'd224;
            IC_real_i = 8'd10;
            OC_real_i = 8'd10;
            On_real_i = COMPUTE_ROW - 32'd2; //* tile_n_i - 2
            ipsum_read_en = 0;
            ipsum_add_en = 1;
            flags = 4'b0000;
            scaling_factor = 6'd3; // scaling factor
            Need_PPU = 1'd1; // 是否需要 PPU 處理
            // 重置解除
            #20 rst_n = 1;

            // 啟動 token_engine
            #10 pass_start_i = 1;
            #10 pass_start_i = 0;

            // 模擬運行一段時間
          #500000
            $display("Simulation Failed: No pass_done_o signal received.");
            $finish;
        `elsif DEPTHWISE_STRIDE2_PPU_TYPE
            rst_n = 0;
            pass_start_i = 0;
            layer_type_i = `DEPTHWISE;
            weight_GLB_base_addr_i = 32'h0000_0000;
            ifmap_GLB_base_addr_i = 32'h0000_1000;
            ipsum_GLB_base_addr_i = 32'h0000_2000;
            bias_GLB_base_addr_i = 32'h0000_2900;
            opsum_GLB_base_addr_i = 32'h0000_3000;
            
            is_bias_i = 0; //*
            tile_n_i = 5; //* 1 tile has tile_n_i row

            in_C_i = 8'd114;
            in_R_i = 8'd114;
            Already_Compute_Row = Already_COMP_ROW; // Depthwise layer 會需要根據這個訊號去往上計數 => 確認是否需要 top pad, bottom pad 
            n_tile_is_first_i = 1; // 第一個 tile
            n_tile_is_last_i = 0; // 不是最後一個 tile
            stride = 2'd2;
            pad_R_i = 2'd1;
            pad_L_i = 2'd1;
            pad_T_i = 2'd1;
            pad_B_i = 2'd1;
            out_C_i = 8'd57;
            out_R_i = 8'd57;
            IC_real_i = 8'd10;
            OC_real_i = 8'd10;
            On_real_i = 2; //* tile_n_i - 2
            ipsum_read_en = 0;
            ipsum_add_en = 1;
            flags = 4'b0000;
            scaling_factor = 6'd2; // scaling factor
            Need_PPU = 1'd1; // 是否需要 PPU 處理

            // 重置解除
            #20 rst_n = 1;

            // 啟動 token_engine
            #10 pass_start_i = 1;
            #10 pass_start_i = 0;

            // 模擬運行一段時間
          #500000
            $display("Simulation Failed: No pass_done_o signal received.");
            $finish;
        `endif
    end
integer i, errors;
logic [31:0] sram_data;
logic [31:0] golden_data;
// pass_done_o 觸發時進行驗證
    initial begin
        // 等待 pass_done_o 信號
        wait(pass_done_o);
        $display("Simulation finished successfully at time %0t", $time);
    `ifdef POINTWISE_TYPE
        // 驗證 GLB opsum 區塊與 golden 數據
        $display("===== Verifying opsum data in SRAM with pointwise_golden.hex =====");
        begin
            errors = 0;
            // 共 640 個 32-bit 值（2560 bytes）
            for (i = 0; i < (POINTWISE_N*32/2); i++) begin
                // 從 SRAM 讀取 4 bytes 組成 32-bit 值（小端序）
                sram_data = u_SRAM.memory[12288 + i];
                // $display("SRAM addr 0x%h: 0x%h", (12288 + i), u_SRAM.memory[12288 + i]);
                // 從 golden_opsum 讀取對應值
                golden_data = golden_opsum[i];
                // 比較
                if (u_SRAM.memory[12288 + i] !== golden_data) begin
                    $display("Mismatch at index %0d (SRAM addr 0x%h): SRAM=0x%h, Golden=0x%h",
                             i, (12288 + i), u_SRAM.memory[12288 + i], golden_data);
                    errors++;
                end
                else begin
                    $display("Match at index %0d (SRAM addr 0x%h): SRAM=0x%h, Golden=0x%h",
                             i, (12288 + i), u_SRAM.memory[12288 + i], golden_data);
                end
            end
            // 報告結果
            if (errors == 0) begin
                $display("Verification PASSED: All opsum data matches golden data!");
            end else begin
                $display("Verification FAILED: Found %0d mismatches!", errors);
            end
        end
    `elsif DEPTHWISE_TYPE
        // 驗證 GLB opsum 區塊與 golden 數據
        $display("===== Verifying opsum data in SRAM with depthwise_golden.hex =====");
        begin
            integer i, errors = 0;
            logic [31:0] sram_data, golden_data;
            // 共 1120 個 32-bit 值（2560 bytes）
            for (i = 0; i < ((COMPUTE_ROW-2)*1120); i++) begin
                // 從 SRAM 讀取 4 bytes 組成 32-bit 值（小端序）
                sram_data = u_SRAM.memory[12288 + i];
                // 從 golden_opsum 讀取對應值
                golden_data = golden_opsum[i];
                // 比較
                if (u_SRAM.memory[12288 + i] !== golden_data) begin
                    $display("Mismatch at index %0d (SRAM addr 0x%h): SRAM=0x%h, Golden=0x%h",
                             i, (12288 + i), u_SRAM.memory[12288 + i], golden_data);
                    errors++;
                end
                else begin
                    $display("Match at index %0d (SRAM addr 0x%h): SRAM=0x%h, Golden=0x%h",
                             i, (12288 + i), u_SRAM.memory[12288 + i], golden_data);
                end
            end
            // 報告結果
            if (errors == 0) begin
                $display("Verification PASSED: All opsum data matches golden data!");
            end else begin
                $display("Verification FAILED: Found %0d mismatches!", errors);
            end
        end
    `elsif DEPTHWISE_STRIDE2_TYPE
        // 驗證 GLB opsum 區塊與 golden 數據
        $display("===== Verifying opsum data in SRAM with depthwise_stride2_golden.hex =====");
        begin
            integer i, errors = 0;
            logic [31:0] sram_data, golden_data;
            // 共 1120 個 32-bit 值（2560 bytes）
            for (i = 0; i < 285; i++) begin
                // 從 SRAM 讀取 4 bytes 組成 32-bit 值（小端序）
                sram_data = u_SRAM.memory[12288 + i];
                // 從 golden_opsum 讀取對應值
                golden_data = golden_opsum[i];
                // 比較
                if (u_SRAM.memory[12288 + i] !== golden_data) begin
                    $display("Mismatch at index %0d (SRAM addr 0x%h): SRAM=0x%h, Golden=0x%h",
                             i, (12288 + i), u_SRAM.memory[12288 + i], golden_data);
                    errors++;
                end
                else begin
                    $display("Match at index %0d (SRAM addr 0x%h): SRAM=0x%h, Golden=0x%h",
                             i, (12288 + i), u_SRAM.memory[12288 + i], golden_data);
                end
            end
            // 報告結果
            if (errors == 0) begin
                $display("Verification PASSED: All opsum data matches golden data!");
            end else begin
                $display("Verification FAILED: Found %0d mismatches!", errors);
            end
        end
    `elsif POINTWISE_PPU_RELU_TYPE
        // 驗證 GLB opsum 區塊與 golden 數據
        $display("===== Verifying opsum data in SRAM with pointwise_golden.hex =====");
        begin
            errors = 0;
            // 共 640 個 32-bit 值（2560 bytes）
            for (i = 0; i < (POINTWISE_N*32/2); i++) begin
                // 從 SRAM 讀取 4 bytes 組成 32-bit 值（小端序）
                sram_data = u_SRAM.memory[12288 + i];
                // $display("SRAM addr 0x%h: 0x%h", (12288 + i), u_SRAM.memory[12288 + i]);
                // 從 golden_opsum 讀取對應值
                golden_data = golden_opsum[i];
                // 比較
                if (u_SRAM.memory[12288 + i] !== golden_data) begin
                    $display("Mismatch at index %0d (SRAM addr 0x%h): SRAM=0x%h, Golden=0x%h",
                             i, (12288 + i), u_SRAM.memory[12288 + i], golden_data);
                    errors++;
                end
                else begin
                    $display("Match at index %0d (SRAM addr 0x%h): SRAM=0x%h, Golden=0x%h",
                             i, (12288 + i), u_SRAM.memory[12288 + i], golden_data);
                end
            end
            // 報告結果
            if (errors == 0) begin
                $display("Verification PASSED: All opsum data matches golden data!");
            end else begin
                $display("Verification FAILED: Found %0d mismatches!", errors);
            end
        end
    `elsif DEPTHWISE_PPU_RELU_TYPE
        // 驗證 GLB opsum 區塊與 golden 數據
        $display("===== Verifying opsum data in SRAM with depthwise_golden.hex =====");
        begin
            integer i, errors = 0;
            logic [31:0] sram_data, golden_data;
            // 共 1120 個 32-bit 值（2560 bytes）
            for (i = 0; i < ((COMPUTE_ROW-2)*1120); i++) begin
                // 從 SRAM 讀取 4 bytes 組成 32-bit 值（小端序）
                sram_data = u_SRAM.memory[12288 + i];
                // 從 golden_opsum 讀取對應值
                golden_data = golden_opsum[i];
                // 比較
                if (u_SRAM.memory[12288 + i] !== golden_data) begin
                    $display("Mismatch at index %0d (SRAM addr 0x%h): SRAM=0x%h, Golden=0x%h",
                             i, (12288 + i), u_SRAM.memory[12288 + i], golden_data);
                    errors++;
                end
                else begin
                    $display("Match at index %0d (SRAM addr 0x%h): SRAM=0x%h, Golden=0x%h",
                             i, (12288 + i), u_SRAM.memory[12288 + i], golden_data);
                end
            end
            // 報告結果
            if (errors == 0) begin
                $display("Verification PASSED: All opsum data matches golden data!");
            end else begin
                $display("Verification FAILED: Found %0d mismatches!", errors);
            end
        end
    `elsif DEPTHWISE_STRIDE2_PPU_RELU_TYPE
        // 驗證 GLB opsum 區塊與 golden 數據
        $display("===== Verifying opsum data in SRAM with depthwise_stride2_golden.hex =====");
        begin
            integer i, errors = 0;
            logic [31:0] sram_data, golden_data;
            // 共 1120 個 32-bit 值（2560 bytes）
            for (i = 0; i < 285; i++) begin
                // 從 SRAM 讀取 4 bytes 組成 32-bit 值（小端序）
                sram_data = u_SRAM.memory[12288 + i];
                // 從 golden_opsum 讀取對應值
                golden_data = golden_opsum[i];
                // 比較
                if (u_SRAM.memory[12288 + i] !== golden_data) begin
                    $display("Mismatch at index %0d (SRAM addr 0x%h): SRAM=0x%h, Golden=0x%h",
                             i, (12288 + i), u_SRAM.memory[12288 + i], golden_data);
                    errors++;
                end
                else begin
                    $display("Match at index %0d (SRAM addr 0x%h): SRAM=0x%h, Golden=0x%h",
                             i, (12288 + i), u_SRAM.memory[12288 + i], golden_data);
                end
            end
            // 報告結果
            if (errors == 0) begin
                $display("Verification PASSED: All opsum data matches golden data!");
            end else begin
                $display("Verification FAILED: Found %0d mismatches!", errors);
            end
        end
    `elsif POINTWISE_PPU_TYPE
        // 驗證 GLB opsum 區塊與 golden 數據
        $display("===== Verifying opsum data in SRAM with pointwise_golden.hex =====");
        begin
            errors = 0;
            // 共 640 個 32-bit 值（2560 bytes）
            for (i = 0; i < (POINTWISE_N*32/2); i++) begin
                // 從 SRAM 讀取 4 bytes 組成 32-bit 值（小端序）
                sram_data = u_SRAM.memory[12288 + i];
                // $display("SRAM addr 0x%h: 0x%h", (12288 + i), u_SRAM.memory[12288 + i]);
                // 從 golden_opsum 讀取對應值
                golden_data = golden_opsum[i];
                // 比較
                if (u_SRAM.memory[12288 + i] !== golden_data) begin
                    $display("Mismatch at index %0d (SRAM addr 0x%h): SRAM=0x%h, Golden=0x%h",
                             i, (12288 + i), u_SRAM.memory[12288 + i], golden_data);
                    errors++;
                end
                else begin
                    $display("Match at index %0d (SRAM addr 0x%h): SRAM=0x%h, Golden=0x%h",
                             i, (12288 + i), u_SRAM.memory[12288 + i], golden_data);
                end
            end
            // 報告結果
            if (errors == 0) begin
                $display("Verification PASSED: All opsum data matches golden data!");
            end else begin
                $display("Verification FAILED: Found %0d mismatches!", errors);
            end
        end
    `elsif DEPTHWISE_PPU_TYPE
        // 驗證 GLB opsum 區塊與 golden 數據
        $display("===== Verifying opsum data in SRAM with depthwise_golden.hex =====");
        begin
            integer i, errors = 0;
            logic [31:0] sram_data, golden_data;
            // 共 1120 個 32-bit 值（2560 bytes）
            for (i = 0; i < ((COMPUTE_ROW-2)*1120); i++) begin
                // 從 SRAM 讀取 4 bytes 組成 32-bit 值（小端序）
                sram_data = u_SRAM.memory[12288 + i];
                // 從 golden_opsum 讀取對應值
                golden_data = golden_opsum[i];
                // 比較
                if (u_SRAM.memory[12288 + i] !== golden_data) begin
                    $display("Mismatch at index %0d (SRAM addr 0x%h): SRAM=0x%h, Golden=0x%h",
                             i, (12288 + i), u_SRAM.memory[12288 + i], golden_data);
                    errors++;
                end
                else begin
                    $display("Match at index %0d (SRAM addr 0x%h): SRAM=0x%h, Golden=0x%h",
                             i, (12288 + i), u_SRAM.memory[12288 + i], golden_data);
                end
            end
            // 報告結果
            if (errors == 0) begin
                $display("Verification PASSED: All opsum data matches golden data!");
            end else begin
                $display("Verification FAILED: Found %0d mismatches!", errors);
            end
        end
    `elsif DEPTHWISE_STRIDE2_PPU_TYPE
        // 驗證 GLB opsum 區塊與 golden 數據
        $display("===== Verifying opsum data in SRAM with depthwise_stride2_golden.hex =====");
        begin
            integer i, errors = 0;
            logic [31:0] sram_data, golden_data;
            // 共 1120 個 32-bit 值（2560 bytes）
            for (i = 0; i < 285; i++) begin
                // 從 SRAM 讀取 4 bytes 組成 32-bit 值（小端序）
                sram_data = u_SRAM.memory[12288 + i];
                // 從 golden_opsum 讀取對應值
                golden_data = golden_opsum[i];
                // 比較
                if (u_SRAM.memory[12288 + i] !== golden_data) begin
                    $display("Mismatch at index %0d (SRAM addr 0x%h): SRAM=0x%h, Golden=0x%h",
                             i, (12288 + i), u_SRAM.memory[12288 + i], golden_data);
                    errors++;
                end
                else begin
                    $display("Match at index %0d (SRAM addr 0x%h): SRAM=0x%h, Golden=0x%h",
                             i, (12288 + i), u_SRAM.memory[12288 + i], golden_data);
                end
            end
            // 報告結果
            if (errors == 0) begin
                $display("Verification PASSED: All opsum data matches golden data!");
            end else begin
                $display("Verification FAILED: Found %0d mismatches!", errors);
            end
        end
    `endif
        $finish;
    end

    // 監控訊號（可選）
    initial begin
        $monitor("Time=%0t rst_n=%b pass_done_o=%b", $time, rst_n, pass_done_o);
    end

endmodule