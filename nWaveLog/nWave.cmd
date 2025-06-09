wvResizeWindow -win $_nWave1 576 288 960 332
wvResizeWindow -win $_nWave1 576 251 1920 1043
verdiSetActWin -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 \
           {/home/n26130126/Desktop/AOC_Final_Project/AIoC_Final_Project/wave/top.fsdb}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/Tile_Scheduler_tb"
wvGetSignalSetScope -win $_nWave1 "/Tile_Scheduler_tb/dut"
wvGetSignalSetScope -win $_nWave1 "/Tile_Scheduler_tb"
wvGetSignalSetScope -win $_nWave1 "/Tile_Scheduler_tb/dut"
wvSetPosition -win $_nWave1 {("G1" 83)}
wvSetPosition -win $_nWave1 {("G1" 83)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/DMA_bias_finish} \
{/Tile_Scheduler_tb/dut/DMA_filter_finish} \
{/Tile_Scheduler_tb/dut/DMA_ifmap_finish} \
{/Tile_Scheduler_tb/dut/DMA_ipsum_finish} \
{/Tile_Scheduler_tb/dut/DMA_opsum_finish} \
{/Tile_Scheduler_tb/dut/GLB_bias_base_addr_o\[31:0\]} \
{/Tile_Scheduler_tb/dut/GLB_ifmap_base_addr_o\[31:0\]} \
{/Tile_Scheduler_tb/dut/GLB_opsum_base_addr_o\[31:0\]} \
{/Tile_Scheduler_tb/dut/GLB_weight_base_addr_o\[31:0\]} \
{/Tile_Scheduler_tb/dut/IC_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/OC_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/On_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/base_bias_i\[31:0\]} \
{/Tile_Scheduler_tb/dut/base_ifmap_i\[31:0\]} \
{/Tile_Scheduler_tb/dut/base_ofmap_i\[31:0\]} \
{/Tile_Scheduler_tb/dut/base_weight_i\[31:0\]} \
{/Tile_Scheduler_tb/dut/bias_en} \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/dma_addr_o\[31:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/dma_len_o\[31:0\]} \
{/Tile_Scheduler_tb/dut/dma_read_o} \
{/Tile_Scheduler_tb/dut/filter_en} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/flags_o\[3:0\]} \
{/Tile_Scheduler_tb/dut/ifmap_size\[31:0\]} \
{/Tile_Scheduler_tb/dut/in_C_i\[9:0\]} \
{/Tile_Scheduler_tb/dut/in_D_i\[9:0\]} \
{/Tile_Scheduler_tb/dut/in_R_i\[6:0\]} \
{/Tile_Scheduler_tb/dut/in_pixel_num\[31:0\]} \
{/Tile_Scheduler_tb/dut/ipsum_en} \
{/Tile_Scheduler_tb/dut/kH_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/kW_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/layer_first_tile} \
{/Tile_Scheduler_tb/dut/layer_type_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/layer_type_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/max_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/ns_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/opsum_size\[31:0\]} \
{/Tile_Scheduler_tb/dut/out_C_i\[9:0\]} \
{/Tile_Scheduler_tb/dut/out_C_o\[6:0\]} \
{/Tile_Scheduler_tb/dut/out_K_i\[9:0\]} \
{/Tile_Scheduler_tb/dut/out_R_i\[6:0\]} \
{/Tile_Scheduler_tb/dut/out_R_o\[6:0\]} \
{/Tile_Scheduler_tb/dut/out_pixel_num\[31:0\]} \
{/Tile_Scheduler_tb/dut/over_last_D_tile} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_R_tile} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_On\[31:0\]} \
{/Tile_Scheduler_tb/dut/rst_n} \
{/Tile_Scheduler_tb/dut/stride_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/stride_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/tile_D_f_i\[31:0\]} \
{/Tile_Scheduler_tb/dut/tile_D_i\[31:0\]} \
{/Tile_Scheduler_tb/dut/tile_K_f_i\[31:0\]} \
{/Tile_Scheduler_tb/dut/tile_K_i\[31:0\]} \
{/Tile_Scheduler_tb/dut/tile_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/tile_n_i\[31:0\]} \
{/Tile_Scheduler_tb/dut/tile_reach_max_o} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/weight_size\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvResizeWindow -win $_nWave1 0 0 1920 1043
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 \
           40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 \
           62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 \
           )} 
wvSetPosition -win $_nWave1 {("G1" 83)}
wvSetPosition -win $_nWave1 {("G1" 83)}
wvSetPosition -win $_nWave1 {("G1" 83)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/DMA_bias_finish} \
{/Tile_Scheduler_tb/dut/DMA_filter_finish} \
{/Tile_Scheduler_tb/dut/DMA_ifmap_finish} \
{/Tile_Scheduler_tb/dut/DMA_ipsum_finish} \
{/Tile_Scheduler_tb/dut/DMA_opsum_finish} \
{/Tile_Scheduler_tb/dut/GLB_bias_base_addr_o\[31:0\]} \
{/Tile_Scheduler_tb/dut/GLB_ifmap_base_addr_o\[31:0\]} \
{/Tile_Scheduler_tb/dut/GLB_opsum_base_addr_o\[31:0\]} \
{/Tile_Scheduler_tb/dut/GLB_weight_base_addr_o\[31:0\]} \
{/Tile_Scheduler_tb/dut/IC_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/OC_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/On_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/base_bias_i\[31:0\]} \
{/Tile_Scheduler_tb/dut/base_ifmap_i\[31:0\]} \
{/Tile_Scheduler_tb/dut/base_ofmap_i\[31:0\]} \
{/Tile_Scheduler_tb/dut/base_weight_i\[31:0\]} \
{/Tile_Scheduler_tb/dut/bias_en} \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/dma_addr_o\[31:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/dma_len_o\[31:0\]} \
{/Tile_Scheduler_tb/dut/dma_read_o} \
{/Tile_Scheduler_tb/dut/filter_en} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/flags_o\[3:0\]} \
{/Tile_Scheduler_tb/dut/ifmap_size\[31:0\]} \
{/Tile_Scheduler_tb/dut/in_C_i\[9:0\]} \
{/Tile_Scheduler_tb/dut/in_D_i\[9:0\]} \
{/Tile_Scheduler_tb/dut/in_R_i\[6:0\]} \
{/Tile_Scheduler_tb/dut/in_pixel_num\[31:0\]} \
{/Tile_Scheduler_tb/dut/ipsum_en} \
{/Tile_Scheduler_tb/dut/kH_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/kW_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/layer_first_tile} \
{/Tile_Scheduler_tb/dut/layer_type_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/layer_type_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/max_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/ns_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/opsum_size\[31:0\]} \
{/Tile_Scheduler_tb/dut/out_C_i\[9:0\]} \
{/Tile_Scheduler_tb/dut/out_C_o\[6:0\]} \
{/Tile_Scheduler_tb/dut/out_K_i\[9:0\]} \
{/Tile_Scheduler_tb/dut/out_R_i\[6:0\]} \
{/Tile_Scheduler_tb/dut/out_R_o\[6:0\]} \
{/Tile_Scheduler_tb/dut/out_pixel_num\[31:0\]} \
{/Tile_Scheduler_tb/dut/over_last_D_tile} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_R_tile} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_On\[31:0\]} \
{/Tile_Scheduler_tb/dut/rst_n} \
{/Tile_Scheduler_tb/dut/stride_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/stride_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/tile_D_f_i\[31:0\]} \
{/Tile_Scheduler_tb/dut/tile_D_i\[31:0\]} \
{/Tile_Scheduler_tb/dut/tile_K_f_i\[31:0\]} \
{/Tile_Scheduler_tb/dut/tile_K_i\[31:0\]} \
{/Tile_Scheduler_tb/dut/tile_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/tile_n_i\[31:0\]} \
{/Tile_Scheduler_tb/dut/tile_reach_max_o} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/weight_size\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 \
           40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 \
           62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 \
           )} 
wvSetPosition -win $_nWave1 {("G1" 83)}
wvGetSignalClose -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 48 )} 
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvSetCursor -win $_nWave1 7723206.114886 -snap {("G1" 57)}
wvDisplayGridCount -win $_nWave1 -off
wvResizeWindow -win $_nWave1 0 0 1920 1043
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvResizeWindow -win $_nWave1 0 0 1920 1043
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 8950641.028781 -snap {("G1" 64)}
wvDisplayGridCount -win $_nWave1 -off
wvResizeWindow -win $_nWave1 0 0 1920 1043
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvUnknownSaveResult -win $_nWave1 -clear
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/Layer_Decoder_tb/uut"
wvSetPosition -win $_nWave1 {("G2" 60)}
wvSetPosition -win $_nWave1 {("G2" 60)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Layer_Decoder_tb/uut/M1\[6:0\]} \
{/Layer_Decoder_tb/uut/M2\[6:0\]} \
{/Layer_Decoder_tb/uut/M3\[6:0\]} \
{/Layer_Decoder_tb/uut/base_bias_i\[31:0\]} \
{/Layer_Decoder_tb/uut/base_bias_o\[31:0\]} \
{/Layer_Decoder_tb/uut/base_ifmap_i\[31:0\]} \
{/Layer_Decoder_tb/uut/base_ifmap_o\[31:0\]} \
{/Layer_Decoder_tb/uut/base_ofmap_i\[31:0\]} \
{/Layer_Decoder_tb/uut/base_ofmap_o\[31:0\]} \
{/Layer_Decoder_tb/uut/base_weight_i\[31:0\]} \
{/Layer_Decoder_tb/uut/base_weight_o\[31:0\]} \
{/Layer_Decoder_tb/uut/clk} \
{/Layer_Decoder_tb/uut/flags_i\[3:0\]} \
{/Layer_Decoder_tb/uut/flags_o\[3:0\]} \
{/Layer_Decoder_tb/uut/in_C_i\[6:0\]} \
{/Layer_Decoder_tb/uut/in_D_i\[10:0\]} \
{/Layer_Decoder_tb/uut/in_D_o\[10:0\]} \
{/Layer_Decoder_tb/uut/in_R_i\[6:0\]} \
{/Layer_Decoder_tb/uut/kH\[1:0\]} \
{/Layer_Decoder_tb/uut/kH_o\[1:0\]} \
{/Layer_Decoder_tb/uut/kW\[1:0\]} \
{/Layer_Decoder_tb/uut/kW_o\[1:0\]} \
{/Layer_Decoder_tb/uut/layer_id_i\[5:0\]} \
{/Layer_Decoder_tb/uut/layer_id_o\[5:0\]} \
{/Layer_Decoder_tb/uut/layer_type_i\[1:0\]} \
{/Layer_Decoder_tb/uut/layer_type_o\[1:0\]} \
{/Layer_Decoder_tb/uut/out_C\[6:0\]} \
{/Layer_Decoder_tb/uut/out_C_o\[6:0\]} \
{/Layer_Decoder_tb/uut/out_K_i\[10:0\]} \
{/Layer_Decoder_tb/uut/out_K_o\[10:0\]} \
{/Layer_Decoder_tb/uut/out_R\[6:0\]} \
{/Layer_Decoder_tb/uut/out_R_o\[6:0\]} \
{/Layer_Decoder_tb/uut/pad_B_i\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_B_o\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_H_o\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_L_i\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_L_o\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_R_i\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_R_o\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_T_i\[1:0\]} \
{/Layer_Decoder_tb/uut/padded_C\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C_o\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_R\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_R_o\[6:0\]} \
{/Layer_Decoder_tb/uut/quant_scale_i\[7:0\]} \
{/Layer_Decoder_tb/uut/quant_scale_o\[7:0\]} \
{/Layer_Decoder_tb/uut/rst_n} \
{/Layer_Decoder_tb/uut/stride_i\[1:0\]} \
{/Layer_Decoder_tb/uut/stride_o\[1:0\]} \
{/Layer_Decoder_tb/uut/tile_D\[6:0\]} \
{/Layer_Decoder_tb/uut/tile_D_f\[6:0\]} \
{/Layer_Decoder_tb/uut/tile_D_f_o\[6:0\]} \
{/Layer_Decoder_tb/uut/tile_D_o\[6:0\]} \
{/Layer_Decoder_tb/uut/tile_K\[6:0\]} \
{/Layer_Decoder_tb/uut/tile_K_f\[6:0\]} \
{/Layer_Decoder_tb/uut/tile_K_f_o\[6:0\]} \
{/Layer_Decoder_tb/uut/tile_K_o\[6:0\]} \
{/Layer_Decoder_tb/uut/tile_n\[31:0\]} \
{/Layer_Decoder_tb/uut/tile_n_o\[31:0\]} \
{/Layer_Decoder_tb/uut/uLD_en_i} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvResizeWindow -win $_nWave1 0 0 1920 1043
wvSelectSignal -win $_nWave1 {( "G2" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 \
           40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 )} \
           
wvSetPosition -win $_nWave1 {("G2" 60)}
wvSetPosition -win $_nWave1 {("G2" 60)}
wvSetPosition -win $_nWave1 {("G2" 60)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Layer_Decoder_tb/uut/M1\[6:0\]} \
{/Layer_Decoder_tb/uut/M2\[6:0\]} \
{/Layer_Decoder_tb/uut/M3\[6:0\]} \
{/Layer_Decoder_tb/uut/base_bias_i\[31:0\]} \
{/Layer_Decoder_tb/uut/base_bias_o\[31:0\]} \
{/Layer_Decoder_tb/uut/base_ifmap_i\[31:0\]} \
{/Layer_Decoder_tb/uut/base_ifmap_o\[31:0\]} \
{/Layer_Decoder_tb/uut/base_ofmap_i\[31:0\]} \
{/Layer_Decoder_tb/uut/base_ofmap_o\[31:0\]} \
{/Layer_Decoder_tb/uut/base_weight_i\[31:0\]} \
{/Layer_Decoder_tb/uut/base_weight_o\[31:0\]} \
{/Layer_Decoder_tb/uut/clk} \
{/Layer_Decoder_tb/uut/flags_i\[3:0\]} \
{/Layer_Decoder_tb/uut/flags_o\[3:0\]} \
{/Layer_Decoder_tb/uut/in_C_i\[6:0\]} \
{/Layer_Decoder_tb/uut/in_D_i\[10:0\]} \
{/Layer_Decoder_tb/uut/in_D_o\[10:0\]} \
{/Layer_Decoder_tb/uut/in_R_i\[6:0\]} \
{/Layer_Decoder_tb/uut/kH\[1:0\]} \
{/Layer_Decoder_tb/uut/kH_o\[1:0\]} \
{/Layer_Decoder_tb/uut/kW\[1:0\]} \
{/Layer_Decoder_tb/uut/kW_o\[1:0\]} \
{/Layer_Decoder_tb/uut/layer_id_i\[5:0\]} \
{/Layer_Decoder_tb/uut/layer_id_o\[5:0\]} \
{/Layer_Decoder_tb/uut/layer_type_i\[1:0\]} \
{/Layer_Decoder_tb/uut/layer_type_o\[1:0\]} \
{/Layer_Decoder_tb/uut/out_C\[6:0\]} \
{/Layer_Decoder_tb/uut/out_C_o\[6:0\]} \
{/Layer_Decoder_tb/uut/out_K_i\[10:0\]} \
{/Layer_Decoder_tb/uut/out_K_o\[10:0\]} \
{/Layer_Decoder_tb/uut/out_R\[6:0\]} \
{/Layer_Decoder_tb/uut/out_R_o\[6:0\]} \
{/Layer_Decoder_tb/uut/pad_B_i\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_B_o\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_H_o\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_L_i\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_L_o\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_R_i\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_R_o\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_T_i\[1:0\]} \
{/Layer_Decoder_tb/uut/padded_C\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C_o\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_R\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_R_o\[6:0\]} \
{/Layer_Decoder_tb/uut/quant_scale_i\[7:0\]} \
{/Layer_Decoder_tb/uut/quant_scale_o\[7:0\]} \
{/Layer_Decoder_tb/uut/rst_n} \
{/Layer_Decoder_tb/uut/stride_i\[1:0\]} \
{/Layer_Decoder_tb/uut/stride_o\[1:0\]} \
{/Layer_Decoder_tb/uut/tile_D\[6:0\]} \
{/Layer_Decoder_tb/uut/tile_D_f\[6:0\]} \
{/Layer_Decoder_tb/uut/tile_D_f_o\[6:0\]} \
{/Layer_Decoder_tb/uut/tile_D_o\[6:0\]} \
{/Layer_Decoder_tb/uut/tile_K\[6:0\]} \
{/Layer_Decoder_tb/uut/tile_K_f\[6:0\]} \
{/Layer_Decoder_tb/uut/tile_K_f_o\[6:0\]} \
{/Layer_Decoder_tb/uut/tile_K_o\[6:0\]} \
{/Layer_Decoder_tb/uut/tile_n\[31:0\]} \
{/Layer_Decoder_tb/uut/tile_n_o\[31:0\]} \
{/Layer_Decoder_tb/uut/uLD_en_i} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 \
           40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 )} \
           
wvSetPosition -win $_nWave1 {("G2" 60)}
wvGetSignalClose -win $_nWave1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 0
wvSelectSignal -win $_nWave1 {( "G2" 59 )} 
wvSelectSignal -win $_nWave1 {( "G2" 59 60 )} 
wvSelectSignal -win $_nWave1 {( "G2" 60 )} 
wvScrollUp -win $_nWave1 18
wvScrollDown -win $_nWave1 18
wvSelectSignal -win $_nWave1 {( "G2" 57 )} 
wvSelectSignal -win $_nWave1 {( "G2" 60 )} 
wvSetPosition -win $_nWave1 {("G2" 56)}
wvSetPosition -win $_nWave1 {("G2" 53)}
wvSetPosition -win $_nWave1 {("G2" 52)}
wvSetPosition -win $_nWave1 {("G2" 49)}
wvSetPosition -win $_nWave1 {("G2" 47)}
wvSetPosition -win $_nWave1 {("G2" 45)}
wvSetPosition -win $_nWave1 {("G2" 43)}
wvSetPosition -win $_nWave1 {("G2" 41)}
wvSetPosition -win $_nWave1 {("G2" 40)}
wvSetPosition -win $_nWave1 {("G2" 39)}
wvSetPosition -win $_nWave1 {("G2" 38)}
wvSetPosition -win $_nWave1 {("G2" 37)}
wvSetPosition -win $_nWave1 {("G2" 36)}
wvSetPosition -win $_nWave1 {("G2" 35)}
wvSetPosition -win $_nWave1 {("G2" 34)}
wvSetPosition -win $_nWave1 {("G2" 32)}
wvSetPosition -win $_nWave1 {("G2" 31)}
wvSetPosition -win $_nWave1 {("G2" 30)}
wvSetPosition -win $_nWave1 {("G2" 29)}
wvSetPosition -win $_nWave1 {("G2" 28)}
wvSetPosition -win $_nWave1 {("G2" 27)}
wvSetPosition -win $_nWave1 {("G2" 26)}
wvSetPosition -win $_nWave1 {("G2" 25)}
wvSetPosition -win $_nWave1 {("G2" 24)}
wvSetPosition -win $_nWave1 {("G2" 60)}
wvSetPosition -win $_nWave1 {("G2" 16)}
wvSetPosition -win $_nWave1 {("G2" 15)}
wvSetPosition -win $_nWave1 {("G2" 14)}
wvSetPosition -win $_nWave1 {("G2" 15)}
wvSetPosition -win $_nWave1 {("G2" 16)}
wvSetPosition -win $_nWave1 {("G2" 15)}
wvSetPosition -win $_nWave1 {("G2" 14)}
wvSetPosition -win $_nWave1 {("G2" 13)}
wvSetPosition -win $_nWave1 {("G2" 12)}
wvSetPosition -win $_nWave1 {("G2" 11)}
wvSetPosition -win $_nWave1 {("G2" 10)}
wvSetPosition -win $_nWave1 {("G2" 9)}
wvSetPosition -win $_nWave1 {("G2" 8)}
wvSetPosition -win $_nWave1 {("G2" 7)}
wvSetPosition -win $_nWave1 {("G2" 6)}
wvSetPosition -win $_nWave1 {("G2" 5)}
wvSetPosition -win $_nWave1 {("G2" 4)}
wvSetPosition -win $_nWave1 {("G2" 3)}
wvSetPosition -win $_nWave1 {("G2" 2)}
wvSetPosition -win $_nWave1 {("G2" 1)}
wvSetPosition -win $_nWave1 {("G2" 3)}
wvSetPosition -win $_nWave1 {("G2" 5)}
wvSetPosition -win $_nWave1 {("G2" 6)}
wvSetPosition -win $_nWave1 {("G2" 7)}
wvSetPosition -win $_nWave1 {("G2" 8)}
wvSetPosition -win $_nWave1 {("G2" 9)}
wvSetPosition -win $_nWave1 {("G2" 10)}
wvSetPosition -win $_nWave1 {("G2" 11)}
wvSetPosition -win $_nWave1 {("G2" 12)}
wvSetPosition -win $_nWave1 {("G2" 11)}
wvSetPosition -win $_nWave1 {("G2" 12)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G2" 12)}
wvSetPosition -win $_nWave1 {("G2" 13)}
wvSetCursor -win $_nWave1 34726.158122 -snap {("G2" 12)}
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvSetCursor -win $_nWave1 24367.263743 -snap {("G2" 43)}
wvSetCursor -win $_nWave1 24956.794317 -snap {("G2" 43)}
wvDisplayGridCount -win $_nWave1 -off
wvResizeWindow -win $_nWave1 0 0 1920 1043
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvResizeWindow -win $_nWave1 0 0 1920 1043
wvReloadFile -win $_nWave1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvScrollUp -win $_nWave1 1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 30284.403953 -snap {("G2" 14)}
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvScrollDown -win $_nWave1 1
wvSelectSignal -win $_nWave1 {( "G2" 38 )} 
wvSelectAll -win $_nWave1
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G2" 0)}
wvResizeWindow -win $_nWave1 0 0 1920 1043
wvGetSignalOpen -win $_nWave1
wvGetSignalSetSignalFilter -win $_nWave1 "*clk"
wvSetPosition -win $_nWave1 {("G2" 0)}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvSetPosition -win $_nWave1 {("G2" 1)}
wvSetPosition -win $_nWave1 {("G2" 1)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Layer_Decoder_tb/uut/clk} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 1 )} 
wvSetPosition -win $_nWave1 {("G2" 1)}
wvGetSignalSetSignalFilter -win $_nWave1 "*uLC"
wvSetPosition -win $_nWave1 {("G2" 1)}
wvSetPosition -win $_nWave1 {("G2" 1)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Layer_Decoder_tb/uut/clk} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 1 )} 
wvSetPosition -win $_nWave1 {("G2" 1)}
wvGetSignalSetSignalFilter -win $_nWave1 "*en*"
wvSetPosition -win $_nWave1 {("G2" 1)}
wvSetPosition -win $_nWave1 {("G2" 1)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Layer_Decoder_tb/uut/clk} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 1 )} 
wvSetPosition -win $_nWave1 {("G2" 1)}
wvSetPosition -win $_nWave1 {("G2" 2)}
wvSetPosition -win $_nWave1 {("G2" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Layer_Decoder_tb/uut/clk} \
{/Layer_Decoder_tb/uut/uLD_en_i} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 2 )} 
wvSetPosition -win $_nWave1 {("G2" 2)}
wvGetSignalSetSignalFilter -win $_nWave1 "*i*"
wvSetPosition -win $_nWave1 {("G2" 2)}
wvSetPosition -win $_nWave1 {("G2" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Layer_Decoder_tb/uut/clk} \
{/Layer_Decoder_tb/uut/uLD_en_i} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 2 )} 
wvSetPosition -win $_nWave1 {("G2" 2)}
wvGetSignalSetSignalFilter -win $_nWave1 "*_i*"
wvSetPosition -win $_nWave1 {("G2" 2)}
wvSetPosition -win $_nWave1 {("G2" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Layer_Decoder_tb/uut/clk} \
{/Layer_Decoder_tb/uut/uLD_en_i} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 2 )} 
wvSetPosition -win $_nWave1 {("G2" 2)}
wvSetPosition -win $_nWave1 {("G2" 21)}
wvSetPosition -win $_nWave1 {("G2" 21)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Layer_Decoder_tb/uut/clk} \
{/Layer_Decoder_tb/uut/uLD_en_i} \
{/Layer_Decoder_tb/uut/base_bias_i\[31:0\]} \
{/Layer_Decoder_tb/uut/base_ifmap_i\[31:0\]} \
{/Layer_Decoder_tb/uut/base_ifmap_o\[31:0\]} \
{/Layer_Decoder_tb/uut/base_ofmap_i\[31:0\]} \
{/Layer_Decoder_tb/uut/base_weight_i\[31:0\]} \
{/Layer_Decoder_tb/uut/flags_i\[3:0\]} \
{/Layer_Decoder_tb/uut/in_C_i\[6:0\]} \
{/Layer_Decoder_tb/uut/in_D_i\[10:0\]} \
{/Layer_Decoder_tb/uut/in_R_i\[6:0\]} \
{/Layer_Decoder_tb/uut/layer_id_i\[5:0\]} \
{/Layer_Decoder_tb/uut/layer_id_o\[5:0\]} \
{/Layer_Decoder_tb/uut/layer_type_i\[1:0\]} \
{/Layer_Decoder_tb/uut/out_K_i\[10:0\]} \
{/Layer_Decoder_tb/uut/pad_B_i\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_L_i\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_R_i\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_T_i\[1:0\]} \
{/Layer_Decoder_tb/uut/quant_scale_i\[7:0\]} \
{/Layer_Decoder_tb/uut/stride_i\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 \
           19 20 21 )} 
wvSetPosition -win $_nWave1 {("G2" 21)}
wvSetPosition -win $_nWave1 {("G2" 21)}
wvSetPosition -win $_nWave1 {("G2" 21)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Layer_Decoder_tb/uut/clk} \
{/Layer_Decoder_tb/uut/uLD_en_i} \
{/Layer_Decoder_tb/uut/base_bias_i\[31:0\]} \
{/Layer_Decoder_tb/uut/base_ifmap_i\[31:0\]} \
{/Layer_Decoder_tb/uut/base_ifmap_o\[31:0\]} \
{/Layer_Decoder_tb/uut/base_ofmap_i\[31:0\]} \
{/Layer_Decoder_tb/uut/base_weight_i\[31:0\]} \
{/Layer_Decoder_tb/uut/flags_i\[3:0\]} \
{/Layer_Decoder_tb/uut/in_C_i\[6:0\]} \
{/Layer_Decoder_tb/uut/in_D_i\[10:0\]} \
{/Layer_Decoder_tb/uut/in_R_i\[6:0\]} \
{/Layer_Decoder_tb/uut/layer_id_i\[5:0\]} \
{/Layer_Decoder_tb/uut/layer_id_o\[5:0\]} \
{/Layer_Decoder_tb/uut/layer_type_i\[1:0\]} \
{/Layer_Decoder_tb/uut/out_K_i\[10:0\]} \
{/Layer_Decoder_tb/uut/pad_B_i\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_L_i\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_R_i\[1:0\]} \
{/Layer_Decoder_tb/uut/pad_T_i\[1:0\]} \
{/Layer_Decoder_tb/uut/quant_scale_i\[7:0\]} \
{/Layer_Decoder_tb/uut/stride_i\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 \
           19 20 21 )} 
wvSetPosition -win $_nWave1 {("G2" 21)}
wvGetSignalClose -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G2" 6 )} 
wvSelectSignal -win $_nWave1 {( "G2" 5 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G3" 0)}
wvSetPosition -win $_nWave1 {("G2" 20)}
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
