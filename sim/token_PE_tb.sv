`include "../include/define.svh"
`include "../sim/SRAM_64KB.sv"
module token_PE_tb;

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

    // conv_unit 的輸出訊號
    logic [31:0]       opsum_pop_data [31:0];
    
initial begin
    $readmemh("../sim/memory.hex", u_SRAM.memory);
    $display("===== SRAM initialized from memory.hex =====");
 
end
    SRAM_64KB u_SRAM (
        .clk(clk),
        .rst_n(rst_n),
        .WEB(4'b0000), // 假設寫使能為全 0
        .addr(weight_GLB_base_addr_i[15:2]), // 使用地址的高 14 位
        .write_data(32'd0),
        .read_data()
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
        .tile_n_i(tile_n_i),
        .in_C_i(in_C_i),
        .in_R_i(in_R_i),
        .pad_R_i(pad_R_i),
        .pad_L_i(pad_L_i),
        .out_C_i(out_C_i),
        .out_R_i(out_R_i),
        .IC_real_i(IC_real_i),
        .OC_real_i(OC_real_i),
        .On_real_i(On_real_i),
        .glb_read_data_i(glb_read_data_i),
        .PE_en_matrix_o(PE_en_matrix_o),
        .PE_stall_matrix_o(PE_stall_matrix_o),
        .weight_in_o(weight_in_o),
        .weight_load_en_matrix_o(weight_load_en_matrix_o),
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
        .layer_type(layer_type_i), // 與 token_engine 共用相同的 layer_type_i
        .push_ifmap_en(ifmap_fifo_push_matrix_o),
        .push_ifmap_mod(ifmap_fifo_push_mod_matrix_o),
        .push_ifmap_data(ifmap_fifo_push_data_matrix_o[0]), // 使用第 0 個資料元素
        .pop_ifmap_en(ifmap_fifo_pop_matrix_o),
        .weight_in(weight_in_o),
        .weight_load_en(weight_load_en_matrix_o),
        .PE_en_matrix(PE_en_matrix_o),
        .PE_stall_matrix(PE_stall_matrix_o),
        .push_ipsum_en(ipsum_fifo_push_matrix_o),
        .push_ipsum_mod(ipsum_fifo_push_mod_matrix_o),
        .push_ipsum_data(ipsum_fifo_push_data_matrix_o[0]), // 使用第 0 個資料元素
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
        rst_n = 0;
        pass_start_i = 0;
        layer_type_i = 2'b00;
        weight_GLB_base_addr_i = 32'h0;
        ifmap_GLB_base_addr_i = 32'h0;
        ipsum_GLB_base_addr_i = 32'h0;
        bias_GLB_base_addr_i = 32'h0;
        opsum_GLB_base_addr_i = 32'h0;
        is_bias_i = 0;
        tile_n_i = 32'd1;
        in_C_i = 8'd3;
        in_R_i = 8'd224;
        pad_R_i = 2'd0;
        pad_L_i = 2'd0;
        out_C_i = 8'd3;
        out_R_i = 8'd224;
        IC_real_i = 8'd3;
        OC_real_i = 8'd64;
        On_real_i = 32'd64;
        glb_read_data_i = 32'h0000_1111;
        ipsum_read_en = 0;
        ipsum_add_en = 0;

        // 重置解除
        #20 rst_n = 1;

        // 啟動 token_engine
        #10 pass_start_i = 1;
        #10 pass_start_i = 0;

        // 模擬運行一段時間
        #1000 $finish;
    end

    // 監控訊號（可選）
    initial begin
        $monitor("Time=%0t rst_n=%b pass_done_o=%b", $time, rst_n, pass_done_o);
    end

endmodule