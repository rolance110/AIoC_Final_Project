wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 \
           {/home/n26130126/Desktop/AOC_Final_Project/AIoC_Final_Project/wave/top.fsdb}
wvResizeWindow -win $_nWave1 558 37 960 332
wvResizeWindow -win $_nWave1 558 0 1920 1043
verdiSetActWin -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/Layer_Decoder_tb"
wvGetSignalSetScope -win $_nWave1 "/Layer_Decoder_tb/uut/calc_n_max_u"
wvGetSignalSetScope -win $_nWave1 "/Layer_Decoder_tb/uut"
wvSetPosition -win $_nWave1 {("G1" 4)}
wvSetPosition -win $_nWave1 {("G1" 4)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Layer_Decoder_tb/uut/padded_R\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_R_o\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C_o\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 4 )} 
wvSetPosition -win $_nWave1 {("G1" 4)}
wvSetPosition -win $_nWave1 {("G1" 6)}
wvSetPosition -win $_nWave1 {("G1" 6)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Layer_Decoder_tb/uut/padded_R\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_R_o\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C_o\[6:0\]} \
{/Layer_Decoder_tb/uut/in_R_i\[6:0\]} \
{/Layer_Decoder_tb/uut/in_C_i\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvSetPosition -win $_nWave1 {("G1" 6)}
wvSetPosition -win $_nWave1 {("G1" 6)}
wvSetPosition -win $_nWave1 {("G1" 6)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Layer_Decoder_tb/uut/padded_R\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_R_o\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C_o\[6:0\]} \
{/Layer_Decoder_tb/uut/in_R_i\[6:0\]} \
{/Layer_Decoder_tb/uut/in_C_i\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvSetPosition -win $_nWave1 {("G1" 6)}
wvGetSignalClose -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 25217.419355 -snap {("G1" 6)}
wvSelectSignal -win $_nWave1 {( "G1" 4 )} 
wvSetPosition -win $_nWave1 {("G1" 0)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/Layer_Decoder_tb"
wvGetSignalSetScope -win $_nWave1 "/Layer_Decoder_tb/uut"
wvGetSignalSetScope -win $_nWave1 "/Layer_Decoder_tb/uut"
wvSetPosition -win $_nWave1 {("G1" 1)}
wvSetPosition -win $_nWave1 {("G1" 1)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Layer_Decoder_tb/uut/clk} \
{/Layer_Decoder_tb/uut/padded_R\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_R_o\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C_o\[6:0\]} \
{/Layer_Decoder_tb/uut/in_R_i\[6:0\]} \
{/Layer_Decoder_tb/uut/in_C_i\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 )} 
wvSetPosition -win $_nWave1 {("G1" 1)}
wvSetPosition -win $_nWave1 {("G1" 2)}
wvSetPosition -win $_nWave1 {("G1" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Layer_Decoder_tb/uut/clk} \
{/Layer_Decoder_tb/uut/uLD_en_i} \
{/Layer_Decoder_tb/uut/padded_R\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_R_o\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C_o\[6:0\]} \
{/Layer_Decoder_tb/uut/in_R_i\[6:0\]} \
{/Layer_Decoder_tb/uut/in_C_i\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 2 )} 
wvSetPosition -win $_nWave1 {("G1" 2)}
wvGetSignalSetSignalFilter -win $_nWave1 "*rst*"
wvSetPosition -win $_nWave1 {("G1" 2)}
wvSetPosition -win $_nWave1 {("G1" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Layer_Decoder_tb/uut/clk} \
{/Layer_Decoder_tb/uut/uLD_en_i} \
{/Layer_Decoder_tb/uut/padded_R\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_R_o\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C_o\[6:0\]} \
{/Layer_Decoder_tb/uut/in_R_i\[6:0\]} \
{/Layer_Decoder_tb/uut/in_C_i\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 2 )} 
wvSetPosition -win $_nWave1 {("G1" 2)}
wvSetPosition -win $_nWave1 {("G1" 3)}
wvSetPosition -win $_nWave1 {("G1" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Layer_Decoder_tb/uut/clk} \
{/Layer_Decoder_tb/uut/uLD_en_i} \
{/Layer_Decoder_tb/uut/rst_n} \
{/Layer_Decoder_tb/uut/padded_R\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_R_o\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C_o\[6:0\]} \
{/Layer_Decoder_tb/uut/in_R_i\[6:0\]} \
{/Layer_Decoder_tb/uut/in_C_i\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 3 )} 
wvSetPosition -win $_nWave1 {("G1" 3)}
wvSetPosition -win $_nWave1 {("G1" 3)}
wvSetPosition -win $_nWave1 {("G1" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Layer_Decoder_tb/uut/clk} \
{/Layer_Decoder_tb/uut/uLD_en_i} \
{/Layer_Decoder_tb/uut/rst_n} \
{/Layer_Decoder_tb/uut/padded_R\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_R_o\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C_o\[6:0\]} \
{/Layer_Decoder_tb/uut/in_R_i\[6:0\]} \
{/Layer_Decoder_tb/uut/in_C_i\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 3 )} 
wvSetPosition -win $_nWave1 {("G1" 3)}
wvGetSignalClose -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSetCursor -win $_nWave1 35133.782991 -snap {("G1" 1)}
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 5 )} 
wvSelectSignal -win $_nWave1 {( "G1" 4 )} 
wvSelectSignal -win $_nWave1 {( "G1" 5 )} 
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvSetPosition -win $_nWave1 {("G2" 0)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/Layer_Decoder_tb"
wvGetSignalSetScope -win $_nWave1 "/Layer_Decoder_tb/uut"
wvGetSignalSetScope -win $_nWave1 "/Layer_Decoder_tb/uut"
wvGetSignalSetSignalFilter -win $_nWave1 "*pad*"
wvSetPosition -win $_nWave1 {("G2" 0)}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Layer_Decoder_tb/uut/clk} \
{/Layer_Decoder_tb/uut/uLD_en_i} \
{/Layer_Decoder_tb/uut/rst_n} \
{/Layer_Decoder_tb/uut/padded_R\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_R_o\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C_o\[6:0\]} \
{/Layer_Decoder_tb/uut/in_R_i\[6:0\]} \
{/Layer_Decoder_tb/uut/in_C_i\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSetPosition -win $_nWave1 {("G2" 0)}
wvSetPosition -win $_nWave1 {("G2" 1)}
wvSetPosition -win $_nWave1 {("G2" 1)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Layer_Decoder_tb/uut/clk} \
{/Layer_Decoder_tb/uut/uLD_en_i} \
{/Layer_Decoder_tb/uut/rst_n} \
{/Layer_Decoder_tb/uut/padded_R\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_R_o\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C_o\[6:0\]} \
{/Layer_Decoder_tb/uut/in_R_i\[6:0\]} \
{/Layer_Decoder_tb/uut/in_C_i\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Layer_Decoder_tb/uut/pad_R_o\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 1 )} 
wvSetPosition -win $_nWave1 {("G2" 1)}
wvSetPosition -win $_nWave1 {("G2" 1)}
wvSetPosition -win $_nWave1 {("G2" 1)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Layer_Decoder_tb/uut/clk} \
{/Layer_Decoder_tb/uut/uLD_en_i} \
{/Layer_Decoder_tb/uut/rst_n} \
{/Layer_Decoder_tb/uut/padded_R\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_R_o\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C\[6:0\]} \
{/Layer_Decoder_tb/uut/padded_C_o\[6:0\]} \
{/Layer_Decoder_tb/uut/in_R_i\[6:0\]} \
{/Layer_Decoder_tb/uut/in_C_i\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Layer_Decoder_tb/uut/pad_R_o\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSelectSignal -win $_nWave1 {( "G2" 1 )} 
wvSetPosition -win $_nWave1 {("G2" 1)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 5 )} 
wvSelectAll -win $_nWave1
wvChangeDisplayAttr -win $_nWave1 -h 35
wvSetPosition -win $_nWave1 {("G2" 1)}
wvChangeDisplayAttr -win $_nWave1 -h 35
wvSetPosition -win $_nWave1 {("G2" 1)}
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvSelectSignal -win $_nWave1 {( "G1" 5 )} 
wvSetPosition -win $_nWave1 {("G3" 0)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/Layer_Decoder_tb"
wvGetSignalSetScope -win $_nWave1 "/Layer_Decoder_tb/uut"
wvGetSignalSetScope -win $_nWave1 "/Layer_Decoder_tb/uut"
wvGetSignalSetSignalFilter -win $_nWave1 "*kH*"
wvSetPosition -win $_nWave1 {("G3" 0)}
wvSetPosition -win $_nWave1 {("G3" 0)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Layer_Decoder_tb/uut/clk} -height 35 \
{/Layer_Decoder_tb/uut/uLD_en_i} -height 35 \
{/Layer_Decoder_tb/uut/rst_n} -height 35 \
{/Layer_Decoder_tb/uut/padded_R\[6:0\]} -height 35 \
{/Layer_Decoder_tb/uut/padded_R_o\[6:0\]} -height 35 \
{/Layer_Decoder_tb/uut/padded_C\[6:0\]} -height 35 \
{/Layer_Decoder_tb/uut/padded_C_o\[6:0\]} -height 35 \
{/Layer_Decoder_tb/uut/in_R_i\[6:0\]} -height 35 \
{/Layer_Decoder_tb/uut/in_C_i\[6:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Layer_Decoder_tb/uut/pad_R_o\[1:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G3" \
}
wvSetPosition -win $_nWave1 {("G3" 0)}
wvSetPosition -win $_nWave1 {("G3" 2)}
wvSetPosition -win $_nWave1 {("G3" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Layer_Decoder_tb/uut/clk} -height 35 \
{/Layer_Decoder_tb/uut/uLD_en_i} -height 35 \
{/Layer_Decoder_tb/uut/rst_n} -height 35 \
{/Layer_Decoder_tb/uut/padded_R\[6:0\]} -height 35 \
{/Layer_Decoder_tb/uut/padded_R_o\[6:0\]} -height 35 \
{/Layer_Decoder_tb/uut/padded_C\[6:0\]} -height 35 \
{/Layer_Decoder_tb/uut/padded_C_o\[6:0\]} -height 35 \
{/Layer_Decoder_tb/uut/in_R_i\[6:0\]} -height 35 \
{/Layer_Decoder_tb/uut/in_C_i\[6:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Layer_Decoder_tb/uut/pad_R_o\[1:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Layer_Decoder_tb/uut/kH\[1:0\]} \
{/Layer_Decoder_tb/uut/kH_o\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 1 2 )} 
wvSetPosition -win $_nWave1 {("G3" 2)}
wvSetPosition -win $_nWave1 {("G3" 2)}
wvSetPosition -win $_nWave1 {("G3" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/Layer_Decoder_tb/uut/clk} -height 35 \
{/Layer_Decoder_tb/uut/uLD_en_i} -height 35 \
{/Layer_Decoder_tb/uut/rst_n} -height 35 \
{/Layer_Decoder_tb/uut/padded_R\[6:0\]} -height 35 \
{/Layer_Decoder_tb/uut/padded_R_o\[6:0\]} -height 35 \
{/Layer_Decoder_tb/uut/padded_C\[6:0\]} -height 35 \
{/Layer_Decoder_tb/uut/padded_C_o\[6:0\]} -height 35 \
{/Layer_Decoder_tb/uut/in_R_i\[6:0\]} -height 35 \
{/Layer_Decoder_tb/uut/in_C_i\[6:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/Layer_Decoder_tb/uut/pad_R_o\[1:0\]} -height 35 \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/Layer_Decoder_tb/uut/kH\[1:0\]} \
{/Layer_Decoder_tb/uut/kH_o\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 1 2 )} 
wvSetPosition -win $_nWave1 {("G3" 2)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 24737.595308 -snap {("G3" 1)}
wvSelectSignal -win $_nWave1 {( "G1" 2 )} 
wvSetCursor -win $_nWave1 24870.879765 -snap {("G1" 2)}
wvDisplayGridCount -win $_nWave1 -off
wvCloseGetStreamsDialog -win $_nWave1
wvAttrOrderConfigDlg -win $_nWave1 -close
wvCloseDetailsViewDlg -win $_nWave1
wvCloseDetailsViewDlg -win $_nWave1 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave1
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvUnknownSaveResult -win $_nWave1 -clear
wvExit
