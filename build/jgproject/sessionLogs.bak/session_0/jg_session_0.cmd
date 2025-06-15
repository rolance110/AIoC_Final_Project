# ----------------------------------------
# Jasper Version Info
# tool      : Jasper 2022.03
# platform  : Linux 4.18.0-553.51.1.el8_10.x86_64
# version   : 2022.03p002 64 bits
# build date: 2022.05.26 13:21:20 UTC
# ----------------------------------------
# started   : 2025-06-15 16:55:36 CST
# hostname  : icdeslab19.ee.ncku.edu.tw.(none)
# pid       : 25222
# arguments : '-label' 'session_0' '-console' '//127.0.0.1:34415' '-style' 'windows' '-data' 'AAAAunicXYoxCsJAFETfYmFr4SkE4wXS2ikBBVuRmCIQjOgGwcarepP1uYqFf/iz+2deAMpHSok8o7s2YcWaDUu9Yuf7m/D8fsrwpt0Zcw50qufGnoETV/2sei5EGo7mFVvpqfSnbew6WuloXmQt7Grz1j7m658s3NoLxi9WQR1w' '-proj' '/home/n26130126/Desktop/AOC_Final_Project/AIoC_Final_Project/build/jgproject/sessionLogs/session_0' '-init' '-hidden' '/home/n26130126/Desktop/AOC_Final_Project/AIoC_Final_Project/build/jgproject/.tmp/.initCmds.tcl' '../script/superlint.tcl'
check_superlint -init
clear -all

# Config rules
config_rtlds -rule -enable -domain { LINT }
config_rtlds -rule -disable -tag { CAS_IS_DFRC SIG_IS_DLCK SIG_NO_TGFL SIG_NO_TGRS SIG_NO_TGST FSM_NO_MTRN FSM_NO_TRRN }
# vsd2023_constrain //
config_rtlds -rule  -disable -category { NAMING AUTO_FORMAL_DEAD_CODE AUTO_FORMAL_SIGNALS AUTO_FORMAL_ARITHMETIC_OVERFLOW }
config_rtlds -rule  -disable -tag { IDN_NR_SVKY ARY_MS_DRNG IDN_NR_AMKY IDN_NR_CKYW IDN_NR_SVKW ARY_NR_LBND VAR_NR_INDL INS_NR_PTEX INP_NO_USED OTP_NR_ASYA FLP_NR_MXCS OTP_UC_INST OTP_NR_UDRV REG_NR_TRRC INS_NR_INPR MOD_NS_GLGC } 
config_rtlds -rule  -disable -tag { REG_NR_RWRC  }
config_rtlds -rule  -disable -tag { BUS_IS_FLOT ASG_IS_XRCH }
config_rtlds -rule  -disable -tag { FIL_NR_CTLC}
#config_rtlds -rule  -reset -sync
# vsd2023_constrain //

analyze -sv +incdir+../include+ ../src/controller/token_engine/token_engine.sv 
include ../script/superlint.tcl
include ../script/superlint.tcl
include ../script/superlint.tcl
include ../script/superlint.tcl
include ../script/superlint.tcl
include ../script/superlint.tcl
include ../script/superlint.tcl
include ../script/superlint.tcl
include ../script/superlint.tcl
include ../script/superlint.tcl
include ../script/superlint.tcl
include ../script/superlint.tcl
include ../script/superlint.tcl
include ../script/superlint.tcl
include ../script/superlint.tcl
include ../script/superlint.tcl
