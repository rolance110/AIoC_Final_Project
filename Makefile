root_dir := $(PWD)
src_dir := ./src
syn_dir := ./syn
wave_dir := ./wave
inc_dir := ./include
sim_dir := ./sim
bld_dir := ./build
log_dir := ./log
py_dir := ./python_gen_test_data
FSDB_DEF :=
ifeq ($(FSDB),1)
FSDB_DEF := +FSDB
else ifeq ($(FSDB),2)
FSDB_DEF := +FSDB_ALL
endif

TYPE_DEF :=
ifeq ($(TYPE),1)
TYPE_DEF := +POINTWISE_TYPE
else ifeq ($(TYPE),2)
TYPE_DEF := +DEPTHWISE_TYPE
else ifeq ($(TYPE),3)
TYPE_DEF := +DEPTHWISE_STRIDE2_TYPE
else ifeq ($(TYPE),4)
TYPE_DEF := +POINTWISE_PPU_RELU_TYPE
else ifeq ($(TYPE),5)
TYPE_DEF := +DEPTHWISE_PPU_RELU_TYPE
else ifeq ($(TYPE),6)
TYPE_DEF := +DEPTHWISE_STRIDE2_PPU_RELU_TYPE
else ifeq ($(TYPE),7)
TYPE_DEF := +POINTWISE_PPU_TYPE
else ifeq ($(TYPE),8)
TYPE_DEF := +DEPTHWISE_PPU_TYPE
else ifeq ($(TYPE),9)
TYPE_DEF := +DEPTHWISE_STRIDE2_PPU_TYPE
endif

CYCLE=`grep -v '^$$' $(root_dir)/sim/CYCLE`
MAX=`grep -v '^$$' $(root_dir)/sim/MAX`

$(bld_dir):
	mkdir -p $(bld_dir)
$(log_dir):
	mkdir -p $(log_dir)

$(syn_dir):
	mkdir -p $(syn_dir)

$(wave_dir):
	mkdir -p $(wave_dir)
# RTL simulation
rtl_all: calc_tile_n_tb Layer_Decoder_tb

calc_tile_n_tb: | $(bld_dir) $(wave_dir)
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/calc_tile_n_tb.sv -f $(root_dir)/$(src_dir)/filelist.f -debug_access+all -full64  \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+notimingcheck \
	+define+$(FSDB_DEF) \

Layer_Decoder_tb: | $(bld_dir) $(wave_dir)
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/Layer_Decoder_tb.sv -f $(root_dir)/$(src_dir)/filelist.f -debug_access+all -full64  \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+notimingcheck \
	+define+$(FSDB_DEF)


Tile_Scheduler_old_tb: | $(bld_dir) $(wave_dir)
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/Tile_Scheduler_old_tb.sv -f $(root_dir)/$(src_dir)/filelist.f -debug_access+all -full64  \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+notimingcheck \
	+define+$(FSDB_DEF)
	
Tile_Scheduler_tb: | $(bld_dir) $(wave_dir)
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/Tile_Scheduler_tb.sv -f $(root_dir)/$(src_dir)/filelist.f -debug_access+all -full64  \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+notimingcheck \
	+define+$(FSDB_DEF)

TS_AXI_wrapper_tb: | $(bld_dir) $(wave_dir)
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/TS_AXI_wrapper_tb.sv -f $(root_dir)/$(src_dir)/filelist.f -debug_access+all -full64  \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+notimingcheck \
	+define+$(FSDB_DEF)

ifmap_fifo_bank_tb: | $(bld_dir) $(wave_dir)
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/ifmap_fifo_bank_tb.sv -f $(root_dir)/$(src_dir)/filelist.f -debug_access+all -full64  \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+notimingcheck \
	+define+$(FSDB_DEF)

reducer_tb: | $(bld_dir) $(wave_dir)
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/reducer_tb.sv -f $(root_dir)/$(src_dir)/filelist.f -debug_access+all -full64  \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+notimingcheck \
	+define+$(FSDB_DEF)
opsum_fifo_tb: | $(bld_dir) $(wave_dir)
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/opsum_fifo_tb.sv -f $(root_dir)/$(src_dir)/filelist.f -debug_access+all -full64  \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+notimingcheck \
	+define+$(FSDB_DEF)
opsum_fifo_bank_tb: | $(bld_dir) $(wave_dir)
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/opsum_fifo_bank_tb.sv -f $(root_dir)/$(src_dir)/filelist.f -debug_access+all -full64  \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+notimingcheck \
	+define+$(FSDB_DEF)

conv_unit_tb: | $(bld_dir) $(wave_dir)
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/conv_unit_tb.sv -f $(root_dir)/$(src_dir)/filelist.f -debug_access+all -full64  \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+notimingcheck \
	+define+$(FSDB_DEF)

ifmap_fifo_ctrl_tb: | $(bld_dir) $(wave_dir)
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/ifmap_fifo_ctrl_tb.sv -f $(root_dir)/$(src_dir)/filelist.f -debug_access+all -full64  \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+$(FSDB_DEF) \

token_PE_tb: | $(bld_dir) $(log_dir) $(wave_dir)
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/token_PE_tb.sv -f $(root_dir)/$(src_dir)/filelist.f -debug_access+all -full64  \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+notimingcheck \
	-l $(root_dir)/$(log_dir)/token_PE.log \
	+define+$(FSDB_DEF)$(TYPE_DEF)\

opsum_fifo_ctrl_tb: | $(bld_dir) $(wave_dir)
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/opsum_fifo_ctrl_tb.sv -f $(root_dir)/$(src_dir)/filelist.f -debug_access+all -full64  \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+notimingcheck \
	+define+$(FSDB_DEF) \



# Utilities

gen_pointwise_test:
	@echo "Generate Pointwise Testbench SRAM Data..."
	cd $(py_dir); \
	python gen_SRAM_pointwise_data.py

gen_depthwise_test:
	@echo "Generate Depthwise Testbench SRAM Data..."
	cd $(py_dir); \
	python gen_SRAM_depthwise_data.py

gen_random_test:
	@echo "Generate Random Testbench SRAM Data..."
	cd $(py_dir); \
	python gen_SRAM_random_data.py

nWave: | $(wave_dir)
	@echo "Launching nWave in background..."
	cd $(wave_dir); \
	nohup nWave -ssf ../wave/top.fsdb > nWave.log 2>&1 &


nWave_rc:
	@echo "Launching nWave+signal.rc in background..."
	cd $(wave_dir); \
	nohup nWave -ssf ../wave/top.fsdb -sswr ../wave/signal.rc > nWave.log 2>&1 &


verdi: | $(wave_dir)
	cd $(wave_dir); \
	verdi -sverilog -f $(root_dir)/$(src_dir)/filelist.f &

superlint: | $(bld_dir)
	cd $(bld_dir); \
	jg -allow_unsupported_OS -superlint ../script/superlint.tcl &


clean:
	rm -rf $(bld_dir);
