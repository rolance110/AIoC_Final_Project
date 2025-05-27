`include "../src/Layer_Decoder.sv"

/*==========================================================*
 *  Testbench : tb_calc_tile_R_max
 *  Purpose   : 驗證 calc_tile_R_max 模組 (ks=1, ks=2)
 *==========================================================*/
module calc_tile_R_max_tb;

    //---- Inputs ----
    logic [1:0]  kernel_size;
    logic [1:0]  stride;
    logic [6:0]  padded_C;
    logic [6:0]  tile_D;
    logic [6:0]  tile_K;
    logic [6:0]  out_C;

    //---- Output ----
    logic [6:0]  tile_R_max;

    //---- DUT Instantiation ----
    calc_tile_R_max uut (
        .kernel_size(kernel_size),
        .stride     (stride),
        .padded_C   (padded_C),
        .tile_D     (tile_D),
        .tile_K     (tile_K),
        .out_C      (out_C),
        .tile_R_max (tile_R_max)
    );

    initial begin
        // 固定其餘參數
        stride   = 1;
        padded_C = 112;
        tile_D   = 8;
        tile_K   = 16;
        out_C    = 112;

        //---- Test Case 1: kernel_size = 1 ----
        kernel_size = 1;
        #10;
        $display("TC1: ks=%0d, stride=%0d, padded_C=%0d, tile_D=%0d, tile_K=%0d, out_C=%0d -> tile_R_max=%0d",
                 kernel_size, stride, padded_C, tile_D, tile_K, out_C, tile_R_max);

        //---- Test Case 2: kernel_size = 2 ----
        kernel_size = 2;
        #10;
        $display("TC2: ks=%0d, stride=%0d, padded_C=%0d, tile_D=%0d, tile_K=%0d, out_C=%0d -> tile_R_max=%0d",
                 kernel_size, stride, padded_C, tile_D, tile_K, out_C, tile_R_max);

        $finish;
    end

endmodule
