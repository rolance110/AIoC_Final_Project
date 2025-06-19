verdiSetActWin -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 \
           {/home/n26130126/Desktop/AOC_Final_Project/AIoC_Final_Project/wave/top.fsdb}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/opsum_fifo_ctrl_tb"
wvGetSignalSetScope -win $_nWave1 "/opsum_fifo_ctrl_tb/u_opsum_fifo"
wvGetSignalSetScope -win $_nWave1 "/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl"
wvSetPosition -win $_nWave1 {("G1" 9)}
wvSetPosition -win $_nWave1 {("G1" 9)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 9 )} 
wvSetPosition -win $_nWave1 {("G1" 9)}
wvSetPosition -win $_nWave1 {("G1" 9)}
wvSetPosition -win $_nWave1 {("G1" 9)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 9 )} 
wvSetPosition -win $_nWave1 {("G1" 9)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvSetPosition -win $_nWave1 {("G1" 4)}
wvSetPosition -win $_nWave1 {("G1" 3)}
wvSetPosition -win $_nWave1 {("G1" 2)}
wvSetPosition -win $_nWave1 {("G1" 1)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 1)}
wvSetPosition -win $_nWave1 {("G1" 2)}
wvSelectSignal -win $_nWave1 {( "G1" 5 )} 
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvSelectSignal -win $_nWave1 {( "G1" 7 )} 
wvSelectSignal -win $_nWave1 {( "G1" 7 8 9 )} 
wvSetPosition -win $_nWave1 {("G2" 0)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G2" 3)}
wvSetPosition -win $_nWave1 {("G2" 3)}
wvSelectGroup -win $_nWave1 {G3}
wvSelectSignal -win $_nWave1 {( "G2" 3 )} 
wvSetPosition -win $_nWave1 {("G2" 2)}
wvSetPosition -win $_nWave1 {("G2" 1)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G2" 1)}
wvSetPosition -win $_nWave1 {("G2" 2)}
wvSelectAll -win $_nWave1
wvChangeDisplayAttr -win $_nWave1 -h 35
wvSetPosition -win $_nWave1 {("G2" 2)}
wvSelectSignal -win $_nWave1 {( "G1" 1 )} 
wvScrollDown -win $_nWave1 0
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSetPosition -win $_nWave1 {("G2" 1)}
wvScrollDown -win $_nWave1 0
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/opsum_fifo_ctrl_tb"
wvGetSignalSetScope -win $_nWave1 "/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl"
wvSetPosition -win $_nWave1 {("G2" 2)}
wvSetPosition -win $_nWave1 {("G2" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_push_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 2 )} 
wvSetPosition -win $_nWave1 {("G2" 2)}
wvSetPosition -win $_nWave1 {("G2" 2)}
wvSetPosition -win $_nWave1 {("G2" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_push_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 2 )} 
wvSetPosition -win $_nWave1 {("G2" 2)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 26.240196 -snap {("G2" 2)}
wvSetCursor -win $_nWave1 19.637824 -snap {("G2" 1)}
wvSetCursor -win $_nWave1 24.885863 -snap {("G2" 2)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/opsum_fifo_ctrl_tb"
wvGetSignalSetScope -win $_nWave1 "/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl"
wvGetSignalSetScope -win $_nWave1 "/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl"
wvGetSignalSetScope -win $_nWave1 "/opsum_fifo_ctrl_tb/u_opsum_fifo"
wvSetPosition -win $_nWave1 {("G2" 4)}
wvSetPosition -win $_nWave1 {("G2" 4)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_push_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_data\[15:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_en} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 4 )} 
wvSetPosition -win $_nWave1 {("G2" 4)}
wvSetPosition -win $_nWave1 {("G2" 4)}
wvSetPosition -win $_nWave1 {("G2" 4)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_push_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_data\[15:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_en} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 4 )} 
wvSetPosition -win $_nWave1 {("G2" 4)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G2" 3 4 )} 
wvSetPosition -win $_nWave1 {("G2" 5)}
wvSetPosition -win $_nWave1 {("G2" 6)}
wvSetPosition -win $_nWave1 {("G3" 0)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G3" 2)}
wvSetPosition -win $_nWave1 {("G3" 2)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/opsum_fifo_ctrl_tb"
wvGetSignalSetScope -win $_nWave1 "/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl"
wvGetSignalSetScope -win $_nWave1 "/opsum_fifo_ctrl_tb/u_opsum_fifo"
wvSetPosition -win $_nWave1 {("G3" 3)}
wvSetPosition -win $_nWave1 {("G3" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_push_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_data\[15:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_en} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/mem\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 3 )} 
wvSetPosition -win $_nWave1 {("G3" 3)}
wvSetPosition -win $_nWave1 {("G3" 3)}
wvSetPosition -win $_nWave1 {("G3" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_push_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_data\[15:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_en} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/mem\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 3 )} 
wvSetPosition -win $_nWave1 {("G3" 3)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G3" 2 )} 
wvSetPosition -win $_nWave1 {("G3" 1)}
wvSetPosition -win $_nWave1 {("G3" 0)}
wvMoveSelected -win $_nWave1
wvSetPosition -win $_nWave1 {("G3" 0)}
wvSetPosition -win $_nWave1 {("G3" 1)}
wvSetCursor -win $_nWave1 29.287445 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 24.208697 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 29.626028 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 21.330740 -snap {("G2" 1)}
wvSetCursor -win $_nWave1 10.326787 -snap {("G1" 2)}
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvSetCursor -win $_nWave1 74.657590 -snap {("G2" 1)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 24.547280 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 31.657527 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 28.779570 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 36.059108 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 94.803289 -snap {("G3" 1)}
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
wvSetCursor -win $_nWave1 33.181151 -snap {("G3" 1)}
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvSetCursor -win $_nWave1 34.989722 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 29.751739 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 35.241145 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 24.974700 -snap {("G2" 2)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 34.947818 -snap {("G1" 1)}
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 96.378874 -snap {("G3" 2)}
wvSelectGroup -win $_nWave1 {G3}
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G3" 3)}
wvSetPosition -win $_nWave1 {("G3" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_push_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_en} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_permit_pop_i} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_pop_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_data\[15:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/mem\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 3 )} 
wvSetPosition -win $_nWave1 {("G3" 3)}
wvSetPosition -win $_nWave1 {("G3" 3)}
wvSetPosition -win $_nWave1 {("G3" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_push_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_en} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_permit_pop_i} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_pop_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_data\[15:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/mem\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 3 )} 
wvSetPosition -win $_nWave1 {("G3" 3)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 44.082859 -snap {("G3" 2)}
wvSetCursor -win $_nWave1 156.217584 -snap {("G4" 0)}
wvScrollDown -win $_nWave1 0
wvSetCursor -win $_nWave1 104.256799 -snap {("G2" 1)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 53.972170 -snap {("G3" 2)}
wvSetCursor -win $_nWave1 103.083491 -snap {("G3" 2)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 56.318786 -snap {("G3" 2)}
wvSetPosition -win $_nWave1 {("G3" 4)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/opsum_fifo_ctrl_tb/u_opsum_fifo"
wvSetPosition -win $_nWave1 {("G3" 6)}
wvSetPosition -win $_nWave1 {("G3" 6)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_push_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_en} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_permit_pop_i} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_pop_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_data\[15:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_en} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_data\[31:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/mem\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 6 )} 
wvSetPosition -win $_nWave1 {("G3" 6)}
wvSetPosition -win $_nWave1 {("G3" 6)}
wvSetPosition -win $_nWave1 {("G3" 6)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_push_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_en} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_permit_pop_i} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_pop_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_data\[15:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_en} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_data\[31:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/mem\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 6 )} 
wvSetPosition -win $_nWave1 {("G3" 6)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 55.145478 -snap {("G3" 6)}
wvSetCursor -win $_nWave1 112.972802 -snap {("G3" 4)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 5 )} 
wvSetCursor -win $_nWave1 64.867173 -snap {("G1" 3)}
wvSelectSignal -win $_nWave1 {( "G2" 4 )} 
wvSetPosition -win $_nWave1 {("G2" 4)}
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G2" 5)}
wvSetPosition -win $_nWave1 {("G2" 5)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_push_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_cnt\[4:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_en} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_permit_pop_i} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_pop_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_data\[15:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_en} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_data\[31:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/mem\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G2" 5 )} 
wvSetPosition -win $_nWave1 {("G2" 5)}
wvSetPosition -win $_nWave1 {("G2" 5)}
wvSetPosition -win $_nWave1 {("G2" 5)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_push_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_cnt\[4:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_en} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_permit_pop_i} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_pop_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_data\[15:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_en} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_data\[31:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/mem\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G2" 5 )} 
wvSetPosition -win $_nWave1 {("G2" 5)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 54.810247 -snap {("G3" 5)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 195.774826 -snap {("G2" 1)}
wvSetOptions -win $_nWave1 -cursorCenter on
wvSetOptions -win $_nWave1 -cursorCenter off
wvSetCursor -win $_nWave1 212.348197 -snap {("G2" 1)}
wvSetCursor -win $_nWave1 194.748577 -snap {("G3" 0)}
wvSetCursor -win $_nWave1 194.748577 -snap {("G3" 1)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 5 )} 
wvSelectSignal -win $_nWave1 {( "G1" 4 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G3" 0)}
wvSetPosition -win $_nWave1 {("G2" 5)}
wvSelectSignal -win $_nWave1 {( "G2" 1 )} 
wvSetPosition -win $_nWave1 {("G1" 3)}
wvScrollDown -win $_nWave1 0
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 4)}
wvSetPosition -win $_nWave1 {("G1" 4)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_push_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_cnt\[4:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_en} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_permit_pop_i} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_pop_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_data\[15:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_en} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_data\[31:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/mem\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G1" 4 )} 
wvSetPosition -win $_nWave1 {("G1" 4)}
wvSetPosition -win $_nWave1 {("G1" 4)}
wvSetPosition -win $_nWave1 {("G1" 4)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_push_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_cnt\[4:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_en} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_permit_pop_i} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_pop_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_data\[15:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_en} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_data\[31:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/mem\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G1" 4 )} 
wvSetPosition -win $_nWave1 {("G1" 4)}
wvGetSignalClose -win $_nWave1
wvSelectAll -win $_nWave1
wvChangeDisplayAttr -win $_nWave1 -h 35
wvSetPosition -win $_nWave1 {("G1" 4)}
wvChangeDisplayAttr -win $_nWave1 -h 35
wvSetPosition -win $_nWave1 {("G1" 4)}
wvSelectSignal -win $_nWave1 {( "G1" 3 )} 
wvSelectSignal -win $_nWave1 {( "G2" 1 )} 
wvSetCursor -win $_nWave1 205.308349 -snap {("G1" 5)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 196.257116 -snap {("G2" 1)}
wvSetCursor -win $_nWave1 205.978811 -snap {("G2" 4)}
wvSetCursor -win $_nWave1 214.527198 -snap {("G2" 5)}
wvSetCursor -win $_nWave1 206.146426 -snap {("G2" 2)}
wvSetCursor -win $_nWave1 206.481657 -snap {("G3" 4)}
wvSetCursor -win $_nWave1 196.089500 -snap {("G3" 4)}
wvSetCursor -win $_nWave1 208.493042 -snap {("G2" 2)}
wvSetCursor -win $_nWave1 197.598039 -snap {("G2" 1)}
wvSetCursor -win $_nWave1 206.314042 -snap {("G2" 2)}
wvSetCursor -win $_nWave1 195.083808 -snap {("G2" 1)}
wvSetCursor -win $_nWave1 205.811195 -snap {("G3" 4)}
wvSetCursor -win $_nWave1 203.632195 -snap {("G2" 2)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 216.706199 -snap {("G3" 4)}
wvSetCursor -win $_nWave1 224.751739 -snap {("G1" 3)}
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvSelectSignal -win $_nWave1 {( "G3" 2 )} 
wvSetPosition -win $_nWave1 {("G3" 1)}
wvGetSignalOpen -win $_nWave1
wvSetPosition -win $_nWave1 {("G3" 3)}
wvSetPosition -win $_nWave1 {("G3" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_push_o} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_cnt\[4:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_en} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/req_cnt\[2:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_glb_write_req_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_permit_pop_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_pop_o} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_data\[15:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_en} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_data\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/mem\[1:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 3 )} 
wvSetPosition -win $_nWave1 {("G3" 3)}
wvSetPosition -win $_nWave1 {("G3" 3)}
wvSetPosition -win $_nWave1 {("G3" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_push_o} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_cnt\[4:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_en} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/req_cnt\[2:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_glb_write_req_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_permit_pop_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_pop_o} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_data\[15:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_en} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_data\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/mem\[1:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 3 )} 
wvSetPosition -win $_nWave1 {("G3" 3)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 205.308349 -snap {("G3" 1)}
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
wvSetPosition -win $_nWave1 {("G3" 4)}
wvSetPosition -win $_nWave1 {("G3" 4)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_push_o} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_cnt\[4:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_en} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/req_cnt\[2:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_permit_pop_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_write_req_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_pop_o} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_data\[15:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_en} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_data\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/mem\[1:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 4 )} 
wvSetPosition -win $_nWave1 {("G3" 4)}
wvSetPosition -win $_nWave1 {("G3" 4)}
wvSetPosition -win $_nWave1 {("G3" 4)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/clk} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/rst_n} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_cs\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/op_ns\[1:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_empty_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_full_i} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_need_push_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_push_o} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_push_num_i\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_num_buf\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/push_cnt\[4:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_en} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/req_cnt\[2:0\]} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_permit_pop_i} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_write_req_o} \
{/opsum_fifo_ctrl_tb/u_opsum_fifo_ctrl/opsum_fifo_pop_o} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/push_data\[15:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_en} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/pop_data\[31:0\]} -height 35 \
{/opsum_fifo_ctrl_tb/u_opsum_fifo/mem\[1:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 4 )} 
wvSetPosition -win $_nWave1 {("G3" 4)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 234.305819 -snap {("G3" 3)}
wvSetCursor -win $_nWave1 252.743517 -snap {("G3" 3)}
wvSetCursor -win $_nWave1 235.646743 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 243.692283 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 252.911132 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 234.976281 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 243.859899 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 203.799810 -snap {("G3" 1)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 234.976281 -snap {("G3" 7)}
wvSetCursor -win $_nWave1 244.530361 -snap {("G3" 8)}
wvSetCursor -win $_nWave1 255.928210 -snap {("G3" 7)}
wvSetCursor -win $_nWave1 203.799810 -snap {("G3" 1)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSetCursor -win $_nWave1 244.865591 -snap {("G3" 8)}
wvSetCursor -win $_nWave1 252.240670 -snap {("G3" 8)}
wvSetOptions -win $_nWave1 -cursorCenter on
wvSetOptions -win $_nWave1 -cursorCenter off
wvSelectSignal -win $_nWave1 {( "G1" 5 )} 
wvSetCursor -win $_nWave1 280.058507 -snap {("G1" 4)}
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvScrollDown -win $_nWave1 0
wvSaveSignal -win $_nWave1 \
           "/home/n26130126/Desktop/AOC_Final_Project/AIoC_Final_Project/wave/signal.rc"
wvExit
