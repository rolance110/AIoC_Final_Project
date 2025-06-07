verdiSetActWin -win $_nWave1
wvResizeWindow -win $_nWave1 576 251 1920 1043
wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 \
           {/home/n26130126/Desktop/AOC_Final_Project/AIoC_Final_Project/wave/top.fsdb}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/Tile_Scheduler_tb"
wvGetSignalSetScope -win $_nWave1 "/Tile_Scheduler_tb/dut"
wvSetPosition -win $_nWave1 {("G1" 1)}
wvSetPosition -win $_nWave1 {("G1" 1)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 )} 
wvSetPosition -win $_nWave1 {("G1" 1)}
wvSetCursor -win $_nWave1 4513998.852553 -snap {("G2" 0)}
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/Tile_Scheduler_tb"
wvGetSignalOpen -win $_nWave1
wvSetCursor -win $_nWave1 37491107.286288 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 42010900.745841 -snap {("G2" 0)}
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 60611589.213999 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 8)}
wvSetPosition -win $_nWave1 {("G1" 8)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 2 3 4 5 6 7 8 )} 
wvSetPosition -win $_nWave1 {("G1" 8)}
wvSetCursor -win $_nWave1 364852.266208 -snap {("G2" 0)}
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvResizeWindow -win $_nWave1 0 0 1920 1043
wvSetCursor -win $_nWave1 10309.079975 -snap {("G1" 1)}
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 12)}
wvSetPosition -win $_nWave1 {("G1" 12)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/dma_len_o\[31:0\]} \
{/Tile_Scheduler_tb/dut/dma_read_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 12 )} 
wvSetPosition -win $_nWave1 {("G1" 12)}
wvSelectSignal -win $_nWave1 {( "G1" 12 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G2" 0)}
wvSetPosition -win $_nWave1 {("G1" 11)}
wvSelectSignal -win $_nWave1 {( "G1" 9 )} 
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 11 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G2" 0)}
wvSetPosition -win $_nWave1 {("G1" 10)}
wvSetPosition -win $_nWave1 {("G1" 11)}
wvSetPosition -win $_nWave1 {("G1" 11)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 11 )} 
wvSetPosition -win $_nWave1 {("G1" 11)}
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 12)}
wvSetPosition -win $_nWave1 {("G1" 12)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 12 )} 
wvSetPosition -win $_nWave1 {("G1" 12)}
wvSetPosition -win $_nWave1 {("G1" 13)}
wvSetPosition -win $_nWave1 {("G1" 13)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 13 )} 
wvSetPosition -win $_nWave1 {("G1" 13)}
wvSetCursor -win $_nWave1 64767.915493 -snap {("G1" 9)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 95134.879332 -snap {("G1" 11)}
wvSetCursor -win $_nWave1 101970.247576 -snap {("G1" 11)}
wvSetCursor -win $_nWave1 113960.155807 -snap {("G1" 11)}
wvSetCursor -win $_nWave1 105443.959306 -snap {("G1" 10)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 144663.285297 -snap {("G1" 10)}
wvSetOptions -win $_nWave1 -cursorCenter on
wvSetOptions -win $_nWave1 -cursorCenter off
wvZoomIn -win $_nWave1
wvSetCursor -win $_nWave1 135279.209915 -snap {("G1" 9)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 134606.878612 -snap {("G1" 10)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvSetCursor -win $_nWave1 670762.529658 -snap {("G2" 0)}
wvSetCursor -win $_nWave1 458754.058874 -snap {("G2" 0)}
wvSetCursor -win $_nWave1 181081.230860 -snap {("G1" 10)}
wvZoomIn -win $_nWave1
wvSetOptions -win $_nWave1 -cursorCenter on
wvSetOptions -win $_nWave1 -cursorCenter off
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 14)}
wvSetPosition -win $_nWave1 {("G1" 14)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 14 )} 
wvSetPosition -win $_nWave1 {("G1" 14)}
wvSetPosition -win $_nWave1 {("G1" 15)}
wvSetPosition -win $_nWave1 {("G1" 15)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 15 )} 
wvSetPosition -win $_nWave1 {("G1" 15)}
wvSetPosition -win $_nWave1 {("G1" 15)}
wvSetPosition -win $_nWave1 {("G1" 15)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 15 )} 
wvSetPosition -win $_nWave1 {("G1" 15)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 176150.801307 -snap {("G1" 10)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 14 )} 
wvZoomIn -win $_nWave1
wvSetPosition -win $_nWave1 {("G2" 0)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetSignalFilter -win $_nWave1 "*idx"
wvSetPosition -win $_nWave1 {("G2" 0)}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvSetPosition -win $_nWave1 {("G2" 3)}
wvSetPosition -win $_nWave1 {("G2" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 1 2 3 )} 
wvSetPosition -win $_nWave1 {("G2" 3)}
wvSetCursor -win $_nWave1 203548.301892 -snap {("G2" 1)}
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvSetPosition -win $_nWave1 {("G3" 0)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetSignalFilter -win $_nWave1 "*com*"
wvSetPosition -win $_nWave1 {("G3" 0)}
wvSetPosition -win $_nWave1 {("G3" 0)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSetPosition -win $_nWave1 {("G3" 0)}
wvSetPosition -win $_nWave1 {("G3" 3)}
wvSetPosition -win $_nWave1 {("G3" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 1 2 3 )} 
wvSetPosition -win $_nWave1 {("G3" 3)}
wvSetPosition -win $_nWave1 {("G3" 3)}
wvSetPosition -win $_nWave1 {("G3" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 1 2 3 )} 
wvSetPosition -win $_nWave1 {("G3" 3)}
wvGetSignalClose -win $_nWave1
wvResizeWindow -win $_nWave1 0 0 1920 1043
wvSelectGroup -win $_nWave1 {G4}
wvSelectSignal -win $_nWave1 {( "G3" 3 )} 
wvSelectSignal -win $_nWave1 {( "G2" 1 2 3 )} {( "G3" 1 2 3 )} 
wvSelectSignal -win $_nWave1 {( "G2" 1 2 3 )} {( "G3" 1 2 3 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSetCursor -win $_nWave1 337536.814571 -snap {("G1" 11)}
wvSetCursor -win $_nWave1 304365.865994 -snap {("G1" 10)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G3" 3 )} 
wvSelectSignal -win $_nWave1 {( "G2" 1 2 3 )} {( "G3" 1 2 3 )} 
wvSelectSignal -win $_nWave1 {( "G2" 1 2 3 )} {( "G3" 1 2 3 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSetCursor -win $_nWave1 263574.564366 -snap {("G3" 2)}
wvSetCursor -win $_nWave1 385948.469250 -snap {("G1" 15)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 264471.076490 -snap {("G3" 3)}
wvZoomIn -win $_nWave1
wvSetOptions -win $_nWave1 -cursorCenter on
wvSetOptions -win $_nWave1 -cursorCenter off
wvZoomIn -win $_nWave1
wvScrollDown -win $_nWave1 0
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G3" 1 )} 
wvSetPosition -win $_nWave1 {("G4" 0)}
wvSetPosition -win $_nWave1 {("G3" 3)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G3" 3)}
wvSelectSignal -win $_nWave1 {( "G3" 2 )} 
wvSelectSignal -win $_nWave1 {( "G3" 1 )} 
wvSetPosition -win $_nWave1 {("G3" 2)}
wvSetPosition -win $_nWave1 {("G3" 3)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G3" 3)}
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 7294022.638373 -snap {("G3" 3)}
wvSetPosition -win $_nWave1 {("G4" 0)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetSignalFilter -win $_nWave1 "*last*"
wvSetPosition -win $_nWave1 {("G4" 0)}
wvSetPosition -win $_nWave1 {("G4" 0)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSetPosition -win $_nWave1 {("G4" 0)}
wvSetPosition -win $_nWave1 {("G4" 3)}
wvSetPosition -win $_nWave1 {("G4" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
}
wvSelectSignal -win $_nWave1 {( "G4" 1 2 3 )} 
wvSetPosition -win $_nWave1 {("G4" 3)}
wvSetPosition -win $_nWave1 {("G4" 3)}
wvSetPosition -win $_nWave1 {("G4" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
}
wvSelectSignal -win $_nWave1 {( "G4" 1 2 3 )} 
wvSetPosition -win $_nWave1 {("G4" 3)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G4" 2 )} 
wvSelectSignal -win $_nWave1 {( "G4" 3 )} 
wvSelectSignal -win $_nWave1 {( "G4" 1 )} 
wvSetCursor -win $_nWave1 831963.250788 -snap {("G4" 1)}
wvSetOptions -win $_nWave1 -cursorCenter on
wvSetOptions -win $_nWave1 -cursorCenter off
wvSelectSignal -win $_nWave1 {( "G4" 3 )} 
wvSetPosition -win $_nWave1 {("G4" 2)}
wvSetPosition -win $_nWave1 {("G4" 1)}
wvSetPosition -win $_nWave1 {("G4" 0)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G4" 0)}
wvSetPosition -win $_nWave1 {("G4" 1)}
wvSetCursor -win $_nWave1 1082986.645422 -snap {("G4" 1)}
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvSetOptions -win $_nWave1 -cursorCenter on
wvSetOptions -win $_nWave1 -cursorCenter off
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 867823.735736 -snap {("G4" 2)}
wvZoomIn -win $_nWave1
wvSetOptions -win $_nWave1 -cursorCenter on
wvSetOptions -win $_nWave1 -cursorCenter off
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G3" 1 )} 
wvSetCursor -win $_nWave1 688887.972942 -snap {("G3" 2)}
wvZoomOut -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 11 )} 
wvSelectGroup -win $_nWave1 {G3}
wvSelectSignal -win $_nWave1 {( "G3" 1 )} 
wvSetCursor -win $_nWave1 59169.800164 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 96823.309359 -snap {("G1" 11)}
wvSetCursor -win $_nWave1 172130.327749 -snap {("G1" 11)}
wvSetCursor -win $_nWave1 196336.155089 -snap {("G1" 12)}
wvSetCursor -win $_nWave1 198129.179336 -snap {("G1" 11)}
wvSetCursor -win $_nWave1 211576.861192 -snap {("G1" 11)}
wvSetCursor -win $_nWave1 198129.179336 -snap {("G1" 11)}
wvSetCursor -win $_nWave1 212473.373315 -snap {("G1" 11)}
wvSetCursor -win $_nWave1 198129.179336 -snap {("G1" 11)}
wvSetPosition -win $_nWave1 {("G4" 0)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/Tile_Scheduler_tb"
wvGetSignalSetScope -win $_nWave1 "/Tile_Scheduler_tb/dut"
wvGetSignalSetScope -win $_nWave1 "/Tile_Scheduler_tb/dut"
wvGetSignalSetSignalFilter -win $_nWave1 "*remain*"
wvSetPosition -win $_nWave1 {("G4" 0)}
wvSetPosition -win $_nWave1 {("G4" 0)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
}
wvSetPosition -win $_nWave1 {("G4" 0)}
wvSetPosition -win $_nWave1 {("G4" 3)}
wvSetPosition -win $_nWave1 {("G4" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/remain_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
}
wvSelectSignal -win $_nWave1 {( "G4" 3 )} 
wvSetPosition -win $_nWave1 {("G4" 3)}
wvSetPosition -win $_nWave1 {("G4" 3)}
wvSetPosition -win $_nWave1 {("G4" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/remain_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
}
wvSelectSignal -win $_nWave1 {( "G4" 3 )} 
wvSetPosition -win $_nWave1 {("G4" 3)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G4" 1 )} 
wvSelectSignal -win $_nWave1 {( "G4" 1 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSetPosition -win $_nWave1 {("G4" 6)}
wvSetPosition -win $_nWave1 {("G4" 0)}
wvScrollDown -win $_nWave1 0
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/Tile_Scheduler_tb"
wvGetSignalSetScope -win $_nWave1 "/Tile_Scheduler_tb/dut"
wvGetSignalSetScope -win $_nWave1 "/Tile_Scheduler_tb/dut"
wvGetSignalSetSignalFilter -win $_nWave1 "*max*"
wvSetPosition -win $_nWave1 {("G4" 0)}
wvSetPosition -win $_nWave1 {("G4" 0)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/remain_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
}
wvSetPosition -win $_nWave1 {("G4" 0)}
wvSetPosition -win $_nWave1 {("G4" 1)}
wvSetPosition -win $_nWave1 {("G4" 1)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/max_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/remain_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
}
wvSelectSignal -win $_nWave1 {( "G4" 1 )} 
wvSetPosition -win $_nWave1 {("G4" 1)}
wvSetPosition -win $_nWave1 {("G4" 1)}
wvSetPosition -win $_nWave1 {("G4" 1)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/max_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/remain_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
}
wvSelectSignal -win $_nWave1 {( "G4" 1 )} 
wvSetPosition -win $_nWave1 {("G4" 1)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G4" 1 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSelectSignal -win $_nWave1 {( "G4" 2 )} 
wvSelectSignal -win $_nWave1 {( "G3" 1 )} 
wvSetPosition -win $_nWave1 {("G3" 2)}
wvSetPosition -win $_nWave1 {("G3" 3)}
wvSetPosition -win $_nWave1 {("G4" 0)}
wvSetPosition -win $_nWave1 {("G4" 1)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G4" 2)}
wvSelectSignal -win $_nWave1 {( "G4" 3 )} 
wvSetCursor -win $_nWave1 257298.979500 -snap {("G4" 6)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 26278563.369713 -snap {("G3" 2)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 23208905.858185 -snap {("G4" 6)}
wvSelectSignal -win $_nWave1 {( "G4" 5 )} 
wvSelectSignal -win $_nWave1 {( "G4" 5 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSelectSignal -win $_nWave1 {( "G4" 3 )} 
wvSelectGroup -win $_nWave1 {G4}
wvSelectSignal -win $_nWave1 {( "G4" 1 )} 
wvSelectSignal -win $_nWave1 {( "G4" 1 2 3 4 5 )} 
wvSelectSignal -win $_nWave1 {( "G4" 1 2 3 4 5 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSelectSignal -win $_nWave1 {( "G4" 4 )} 
wvSelectSignal -win $_nWave1 {( "G4" 3 )} 
wvGetSignalOpen -win $_nWave1
wvGetSignalSetSignalFilter -win $_nWave1 "*idx*"
wvSetPosition -win $_nWave1 {("G4" 2)}
wvSetPosition -win $_nWave1 {("G4" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/max_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/remain_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
}
wvSetPosition -win $_nWave1 {("G4" 2)}
wvSetPosition -win $_nWave1 {("G4" 2)}
wvSetPosition -win $_nWave1 {("G4" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/max_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/remain_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
}
wvSetPosition -win $_nWave1 {("G4" 2)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G2" 1 )} 
wvSelectSignal -win $_nWave1 {( "G2" 1 2 3 )} 
wvSetPosition -win $_nWave1 {("G2" 3)}
wvSetPosition -win $_nWave1 {("G3" 0)}
wvSetPosition -win $_nWave1 {("G3" 1)}
wvSetPosition -win $_nWave1 {("G4" 0)}
wvSetPosition -win $_nWave1 {("G4" 1)}
wvSetPosition -win $_nWave1 {("G4" 2)}
wvSetPosition -win $_nWave1 {("G4" 3)}
wvSetPosition -win $_nWave1 {("G4" 4)}
wvSetPosition -win $_nWave1 {("G4" 5)}
wvSetPosition -win $_nWave1 {("G4" 6)}
wvSetPosition -win $_nWave1 {("G4" 7)}
wvSetPosition -win $_nWave1 {("G5" 0)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G5" 3)}
wvSetPosition -win $_nWave1 {("G5" 3)}
wvSelectSignal -win $_nWave1 {( "G4" 7 )} 
wvSelectSignal -win $_nWave1 {( "G4" 6 )} 
wvSelectSignal -win $_nWave1 {( "G4" 7 )} 
wvSelectSignal -win $_nWave1 {( "G5" 1 )} 
wvSetCursor -win $_nWave1 1405731.009952 -snap {("G5" 2)}
wvSetCursor -win $_nWave1 5766365.979599 -snap {("G5" 2)}
wvSetCursor -win $_nWave1 1262289.070161 -snap {("G4" 4)}
wvSelectSignal -win $_nWave1 {( "G4" 1 )} 
wvSelectSignal -win $_nWave1 {( "G4" 2 )} 
wvSetPosition -win $_nWave1 {("G4" 2)}
wvSetPosition -win $_nWave1 {("G4" 1)}
wvSetPosition -win $_nWave1 {("G4" 0)}
wvSetPosition -win $_nWave1 {("G3" 2)}
wvSetPosition -win $_nWave1 {("G3" 1)}
wvSetPosition -win $_nWave1 {("G3" 0)}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvSetPosition -win $_nWave1 {("G3" 0)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G3" 0)}
wvSetPosition -win $_nWave1 {("G3" 1)}
wvSelectSignal -win $_nWave1 {( "G4" 1 )} 
wvSetCursor -win $_nWave1 23467101.349809 -snap {("G3" 3)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 15348287.557638 -snap {("G4" 5)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 14545012.694808 -snap {("G4" 5)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 14372882.367059 -snap {("G4" 6)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G4" 2 )} 
wvSelectSignal -win $_nWave1 {( "G4" 1 )} 
wvSelectSignal -win $_nWave1 {( "G4" 1 )} 
wvSelectSignal -win $_nWave1 {( "G4" 2 )} 
wvSetCursor -win $_nWave1 1118847.130370 -snap {("G4" 3)}
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvSetOptions -win $_nWave1 -cursorCenter on
wvSetOptions -win $_nWave1 -cursorCenter off
wvSelectSignal -win $_nWave1 {( "G4" 2 )} 
wvSelectSignal -win $_nWave1 {( "G3" 2 )} 
wvSetCursor -win $_nWave1 1273047.215645 -snap {("G1" 15)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 1323251.894572 -snap {("G3" 2)}
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 15)}
wvSetPosition -win $_nWave1 {("G3" 0)}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetSignalFilter -win $_nWave1 "*real"
wvSetPosition -win $_nWave1 {("G2" 0)}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/max_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/remain_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvSetPosition -win $_nWave1 {("G2" 3)}
wvSetPosition -win $_nWave1 {("G2" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/IC_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/OC_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/On_real\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/max_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/remain_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
}
wvSelectSignal -win $_nWave1 {( "G2" 3 )} 
wvSetPosition -win $_nWave1 {("G2" 3)}
wvSetPosition -win $_nWave1 {("G2" 3)}
wvSetPosition -win $_nWave1 {("G2" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/IC_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/OC_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/On_real\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/max_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/remain_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
}
wvSelectSignal -win $_nWave1 {( "G2" 3 )} 
wvSetPosition -win $_nWave1 {("G2" 3)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G2" 2 )} 
wvSelectSignal -win $_nWave1 {( "G2" 3 )} 
wvSetPosition -win $_nWave1 {("G2" 2)}
wvSetPosition -win $_nWave1 {("G2" 1)}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G2" 0)}
wvSetPosition -win $_nWave1 {("G2" 1)}
wvSetCursor -win $_nWave1 831963.250788 -snap {("G2" 1)}
wvZoomIn -win $_nWave1
wvSetOptions -win $_nWave1 -cursorCenter on
wvSetOptions -win $_nWave1 -cursorCenter off
wvZoomIn -win $_nWave1
wvSetOptions -win $_nWave1 -cursorCenter on
wvSetOptions -win $_nWave1 -cursorCenter off
wvSetCursor -win $_nWave1 1341182.137046 -snap {("G2" 1)}
wvSelectSignal -win $_nWave1 {( "G2" 1 2 3 )} 
wvSelectSignal -win $_nWave1 {( "G2" 1 2 3 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSetCursor -win $_nWave1 7207957.474498 -snap {("G4" 4)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G4" 6 )} 
wvSelectSignal -win $_nWave1 {( "G4" 5 )} 
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 5665956.621745 -snap {("G4" 5)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G4" 5 )} 
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 7645455.390861 -snap {("G4" 5)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 2782773.631946 -snap {("G4" 5)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G3" 1 )} 
wvSelectSignal -win $_nWave1 {( "G3" 2 )} 
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G3" 1 )} 
wvSetCursor -win $_nWave1 164958.230760 -snap {("G3" 1)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 240265.249150 -snap {("G3" 0)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G3" 2 )} 
wvSetCursor -win $_nWave1 1294563.506614 -snap {("G3" 3)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvZoomOut -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G4" 1 )} 
wvSetCursor -win $_nWave1 2768429.437967 -snap {("G3" 3)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 7229473.765467 -snap {("G4" 7)}
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvSetOptions -win $_nWave1 -cursorCenter on
wvSetOptions -win $_nWave1 -cursorCenter off
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvScrollDown -win $_nWave1 0
wvSetPosition -win $_nWave1 {("G5" 3)}
wvGetSignalOpen -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 7178470.557719 -snap {("G4" 6)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 7182280.734245 -snap {("G4" 7)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvGetSignalSetSignalFilter -win $_nWave1 "*tile*"
wvSetPosition -win $_nWave1 {("G5" 3)}
wvSetPosition -win $_nWave1 {("G5" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/IC_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/OC_real\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/max_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/remain_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
}
wvSetPosition -win $_nWave1 {("G5" 3)}
wvSetPosition -win $_nWave1 {("G5" 4)}
wvSetPosition -win $_nWave1 {("G5" 4)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/IC_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/OC_real\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/max_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/remain_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/tile_reach_max} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
}
wvSelectSignal -win $_nWave1 {( "G5" 4 )} 
wvSetPosition -win $_nWave1 {("G5" 4)}
wvSetPosition -win $_nWave1 {("G5" 4)}
wvSetPosition -win $_nWave1 {("G5" 4)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/IC_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/OC_real\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/max_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/remain_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/tile_reach_max} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
}
wvSelectSignal -win $_nWave1 {( "G5" 4 )} 
wvSetPosition -win $_nWave1 {("G5" 4)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 7195056.032008 -snap {("G5" 1)}
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 7172096.989511 -snap {("G4" 2)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvUnknownSaveResult -win $_nWave1 -clear
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G6" 1)}
wvSetPosition -win $_nWave1 {("G6" 1)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/IC_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/OC_real\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/max_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/remain_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
{/Tile_Scheduler_tb/dut/tile_reach_max_o} \
}
wvAddSignal -win $_nWave1 -group {"G7" \
}
wvSelectSignal -win $_nWave1 {( "G6" 1 )} 
wvSetPosition -win $_nWave1 {("G6" 1)}
wvSetPosition -win $_nWave1 {("G6" 1)}
wvSetPosition -win $_nWave1 {("G6" 1)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/IC_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/OC_real\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/max_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/remain_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
{/Tile_Scheduler_tb/dut/tile_reach_max_o} \
}
wvAddSignal -win $_nWave1 -group {"G7" \
}
wvSelectSignal -win $_nWave1 {( "G6" 1 )} 
wvSetPosition -win $_nWave1 {("G6" 1)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 29204778.941290 -snap {("G6" 1)}
wvSetCursor -win $_nWave1 34770326.205151 -snap {("G6" 1)}
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 12 )} 
wvSetCursor -win $_nWave1 17688916.105328 -snap {("G3" 0)}
wvSetCursor -win $_nWave1 17874464.176363 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 36181873.851806 -snap {("G6" 1)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 26224127.372933 -snap {("G1" 12)}
wvSetCursor -win $_nWave1 36429271.279853 -snap {("G4" 2)}
wvSetCursor -win $_nWave1 30058787.507655 -snap {("G4" 4)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G4" 3 )} 
wvSetCursor -win $_nWave1 29512503.061849 -snap {("G5" 3)}
wvSetCursor -win $_nWave1 30503762.706675 -snap {("G5" 3)}
wvSetCursor -win $_nWave1 29422388.548683 -snap {("G5" 2)}
wvSetCursor -win $_nWave1 23407244.794856 -snap {("G4" 3)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 1)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetSignalFilter -win $_nWave1 "*type*"
wvSetPosition -win $_nWave1 {("G1" 1)}
wvSetPosition -win $_nWave1 {("G1" 1)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/IC_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/OC_real\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/max_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/remain_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
{/Tile_Scheduler_tb/dut/tile_reach_max_o} \
}
wvAddSignal -win $_nWave1 -group {"G7" \
}
wvSetPosition -win $_nWave1 {("G1" 1)}
wvSetPosition -win $_nWave1 {("G1" 2)}
wvSetPosition -win $_nWave1 {("G1" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/layer_type_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/IC_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/OC_real\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/max_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/remain_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
{/Tile_Scheduler_tb/dut/tile_reach_max_o} \
}
wvAddSignal -win $_nWave1 -group {"G7" \
}
wvSelectSignal -win $_nWave1 {( "G1" 2 )} 
wvSetPosition -win $_nWave1 {("G1" 2)}
wvSetPosition -win $_nWave1 {("G1" 2)}
wvSetPosition -win $_nWave1 {("G1" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Tile_Scheduler_tb/dut/clk} \
{/Tile_Scheduler_tb/dut/layer_type_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_B_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_L_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_R_o\[1:0\]} \
{/Tile_Scheduler_tb/dut/pad_T_i\[1:0\]} \
{/Tile_Scheduler_tb/dut/dma_enable_o} \
{/Tile_Scheduler_tb/dut/dma_interrupt_i} \
{/Tile_Scheduler_tb/dut/cs_ts\[3:0\]} \
{/Tile_Scheduler_tb/dut/uLD_en_i} \
{/Tile_Scheduler_tb/dut/flags_i\[3:0\]} \
{/Tile_Scheduler_tb/dut/pass_done_i} \
{/Tile_Scheduler_tb/dut/pass_start_o} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Tile_Scheduler_tb/dut/On_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/IC_real\[6:0\]} \
{/Tile_Scheduler_tb/dut/OC_real\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Tile_Scheduler_tb/dut/completed_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/completed_IC_cnt\[6:0\]} \
{/Tile_Scheduler_tb/dut/completed_OC_cnt\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
{/Tile_Scheduler_tb/dut/max_On_cnt\[31:0\]} \
{/Tile_Scheduler_tb/dut/remain_On\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_IC\[6:0\]} \
{/Tile_Scheduler_tb/dut/remain_OC\[6:0\]} \
{/Tile_Scheduler_tb/dut/reach_last_On_tile} \
{/Tile_Scheduler_tb/dut/reach_last_D_tile} \
{/Tile_Scheduler_tb/dut/reach_last_K_tile} \
}
wvAddSignal -win $_nWave1 -group {"G5" \
{/Tile_Scheduler_tb/dut/On_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/d_idx\[6:0\]} \
{/Tile_Scheduler_tb/dut/k_idx\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G6" \
{/Tile_Scheduler_tb/dut/tile_reach_max_o} \
}
wvAddSignal -win $_nWave1 -group {"G7" \
}
wvSelectSignal -win $_nWave1 {( "G1" 2 )} 
wvSetPosition -win $_nWave1 {("G1" 2)}
wvGetSignalClose -win $_nWave1
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvSelectSignal -win $_nWave1 {( "G1" 14 )} 
wvSelectSignal -win $_nWave1 {( "G1" 13 )} 
wvSelectSignal -win $_nWave1 {( "G6" 1 )} 
wvSetCursor -win $_nWave1 18180603.031231 -snap {("G4" 1)}
wvSetCursor -win $_nWave1 22686328.689528 -snap {("G4" 7)}
wvSetCursor -win $_nWave1 29354802.663809 -snap {("G6" 1)}
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvSetOptions -win $_nWave1 -cursorCenter on
wvSetOptions -win $_nWave1 -cursorCenter off
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvSetCursor -win $_nWave1 29264953.031709 -snap {("G4" 3)}
wvSetCursor -win $_nWave1 29254323.032283 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 29264778.769424 -snap {("G2" 1)}
wvSetCursor -win $_nWave1 29275234.506564 -snap {("G1" 13)}
wvSetCursor -win $_nWave1 29259725.163139 -snap {("G1" 8)}
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSaveSignal -win $_nWave1 \
           "/home/n26130126/Desktop/AOC_Final_Project/AIoC_Final_Project/wave/signal.rc"
wvExit
