verdiSetActWin -win $_nWave1
wvResizeWindow -win $_nWave1 2091 27 1920 983
wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 \
           {/home/n26130126/Desktop/AOC_Final_Project/AIoC_Final_Project/wave/top.fsdb}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/calc_tile_R_max_tb"
wvGetSignalSetScope -win $_nWave1 "/calc_tile_R_max_tb/uut"
wvSetPosition -win $_nWave1 {("G1" 14)}
wvSetPosition -win $_nWave1 {("G1" 14)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/calc_tile_R_max_tb/uut/A\[31:0\]} \
{/calc_tile_R_max_tb/uut/B\[31:0\]} \
{/calc_tile_R_max_tb/uut/C\[31:0\]} \
{/calc_tile_R_max_tb/uut/D\[31:0\]} \
{/calc_tile_R_max_tb/uut/denominator\[31:0\]} \
{/calc_tile_R_max_tb/uut/kernel_size\[1:0\]} \
{/calc_tile_R_max_tb/uut/numerator\[31:0\]} \
{/calc_tile_R_max_tb/uut/out_C\[6:0\]} \
{/calc_tile_R_max_tb/uut/padded_C\[6:0\]} \
{/calc_tile_R_max_tb/uut/result\[31:0\]} \
{/calc_tile_R_max_tb/uut/stride\[1:0\]} \
{/calc_tile_R_max_tb/uut/tile_D\[6:0\]} \
{/calc_tile_R_max_tb/uut/tile_K\[6:0\]} \
{/calc_tile_R_max_tb/uut/tile_R_max\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 )} 
wvSetPosition -win $_nWave1 {("G1" 14)}
wvSetPosition -win $_nWave1 {("G1" 14)}
wvSetPosition -win $_nWave1 {("G1" 14)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/calc_tile_R_max_tb/uut/A\[31:0\]} \
{/calc_tile_R_max_tb/uut/B\[31:0\]} \
{/calc_tile_R_max_tb/uut/C\[31:0\]} \
{/calc_tile_R_max_tb/uut/D\[31:0\]} \
{/calc_tile_R_max_tb/uut/denominator\[31:0\]} \
{/calc_tile_R_max_tb/uut/kernel_size\[1:0\]} \
{/calc_tile_R_max_tb/uut/numerator\[31:0\]} \
{/calc_tile_R_max_tb/uut/out_C\[6:0\]} \
{/calc_tile_R_max_tb/uut/padded_C\[6:0\]} \
{/calc_tile_R_max_tb/uut/result\[31:0\]} \
{/calc_tile_R_max_tb/uut/stride\[1:0\]} \
{/calc_tile_R_max_tb/uut/tile_D\[6:0\]} \
{/calc_tile_R_max_tb/uut/tile_K\[6:0\]} \
{/calc_tile_R_max_tb/uut/tile_R_max\[6:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 )} 
wvSetPosition -win $_nWave1 {("G1" 14)}
wvGetSignalClose -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvExit
