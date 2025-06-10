wvResizeWindow -win $_nWave1 616 37 960 332
wvResizeWindow -win $_nWave1 616 0 1920 1043
verdiSetActWin -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 \
           {/home/n26130126/Desktop/AOC_Final_Project/AIoC_Final_Project/wave/top.fsdb}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/ifmap_fifo_bank_tb"
wvGetSignalSetScope -win $_nWave1 "/ifmap_fifo_bank_tb/uut"
wvGetSignalSetScope -win $_nWave1 \
           "/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst"
wvSetPosition -win $_nWave1 {("G1" 14)}
wvSetPosition -win $_nWave1 {("G1" 14)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/clk} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/count\[2:0\]} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/data_out_reg\[7:0\]} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/empty} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/full} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/mem\[0:3\]} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/pop_data\[7:0\]} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/pop_en} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/push_data\[31:0\]} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/push_en} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/push_mod} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/rd_ptr\[1:0\]} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/rst_n} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/wr_ptr\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 )} 
wvSetPosition -win $_nWave1 {("G1" 14)}
wvSetPosition -win $_nWave1 {("G1" 14)}
wvSetPosition -win $_nWave1 {("G1" 14)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/clk} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/count\[2:0\]} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/data_out_reg\[7:0\]} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/empty} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/full} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/mem\[0:3\]} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/pop_data\[7:0\]} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/pop_en} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/push_data\[31:0\]} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/push_en} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/push_mod} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/rd_ptr\[1:0\]} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/rst_n} \
{/ifmap_fifo_bank_tb/uut/FIFO_ARRAY\[1\]/fifo_inst/wr_ptr\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 )} 
wvSetPosition -win $_nWave1 {("G1" 14)}
wvGetSignalClose -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvSelectSignal -win $_nWave1 {( "G1" 7 )} 
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvSetCursor -win $_nWave1 40921.018983 -snap {("G1" 11)}
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
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvSelectAll -win $_nWave1
wvChangeDisplayAttr -win $_nWave1 -h 30
wvSetPosition -win $_nWave1 {("G1" 14)}
wvChangeDisplayAttr -win $_nWave1 -h 30
wvSetPosition -win $_nWave1 {("G1" 14)}
wvSelectSignal -win $_nWave1 {( "G1" 7 )} 
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvSelectSignal -win $_nWave1 {( "G1" 9 )} 
wvSelectSignal -win $_nWave1 {( "G1" 9 )} 
wvSetPosition -win $_nWave1 {("G1" 9)}
wvExpandBus -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 46)}
wvSelectSignal -win $_nWave1 {( "G1" 9 )} 
wvSetPosition -win $_nWave1 {("G1" 9)}
wvCollapseBus -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 9)}
wvResizeWindow -win $_nWave1 0 0 1920 1043
wvSetPosition -win $_nWave1 {("G1" 14)}
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvSetPosition -win $_nWave1 {("G1" 6)}
wvExpandBus -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 18)}
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvSetPosition -win $_nWave1 {("G1" 6)}
wvCollapseBus -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 6)}
wvSetPosition -win $_nWave1 {("G1" 14)}
wvSelectSignal -win $_nWave1 {( "G1" 9 )} 
wvSetPosition -win $_nWave1 {("G1" 7)}
wvSetPosition -win $_nWave1 {("G1" 6)}
wvSetPosition -win $_nWave1 {("G1" 5)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 5)}
wvSetPosition -win $_nWave1 {("G1" 6)}
wvSelectSignal -win $_nWave1 {( "G1" 11 )} 
wvSelectSignal -win $_nWave1 {( "G1" 2 )} 
wvSetPosition -win $_nWave1 {("G1" 3)}
wvSetPosition -win $_nWave1 {("G1" 4)}
wvSetPosition -win $_nWave1 {("G1" 5)}
wvSetPosition -win $_nWave1 {("G1" 6)}
wvSetPosition -win $_nWave1 {("G1" 7)}
wvSetPosition -win $_nWave1 {("G1" 8)}
wvSetPosition -win $_nWave1 {("G1" 9)}
wvSetPosition -win $_nWave1 {("G1" 10)}
wvSetPosition -win $_nWave1 {("G1" 11)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 11)}
wvSetCursor -win $_nWave1 46213.344764 -snap {("G1" 11)}
wvSetCursor -win $_nWave1 40070.466626 -snap {("G1" 9)}
wvSetCursor -win $_nWave1 45551.804042 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 65303.519902 -snap {("G1" 4)}
wvExit
