root_dir := $(PWD)
src_dir := ./src
syn_dir := ./syn
wave_dir := ./wave
inc_dir := ./include
sim_dir := ./sim
bld_dir := ./build
FSDB_DEF :=
ifeq ($(FSDB),1)
FSDB_DEF := +FSDB
else ifeq ($(FSDB),2)
FSDB_DEF := +FSDB_ALL
endif
CYCLE=`grep -v '^$$' $(root_dir)/sim/CYCLE`
MAX=`grep -v '^$$' $(root_dir)/sim/MAX`

$(bld_dir):
	mkdir -p $(bld_dir)

$(syn_dir):
	mkdir -p $(syn_dir)

$(wave_dir):
	mkdir -p $(wave_dir)
# RTL simulation
rtl_all: rtl0 rtl1

rtl0: | $(bld_dir) $(wave_dir)
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/calc_tile_n_tb.sv -f $(root_dir)/$(src_dir)/filelist.f -debug_access+all -full64  \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+notimingcheck \
	+define+$(FSDB_DEF) \

rtl1: | $(bld_dir) $(wave_dir)
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/Layer_Decoder_tb.sv -f $(root_dir)/$(src_dir)/filelist.f -debug_access+all -full64  \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+notimingcheck \
	+define+$(FSDB_DEF)


rtl2: | $(bld_dir) $(wave_dir)
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/Tile_Scheduler_tb.sv -f $(root_dir)/$(src_dir)/filelist.f -debug_access+all -full64  \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+notimingcheck \
	+define+$(FSDB_DEF)

rtl3: | $(bld_dir) $(wave_dir)
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir)/TS_AXI_wrapper_tb.sv -f $(root_dir)/$(src_dir)/filelist.f -debug_access+all -full64  \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+notimingcheck \
	+define+$(FSDB_DEF)

# Utilities
nWave: | $(wave_dir)
	cd $(wave_dir); \
	nWave -ssf ../wave/top.fsdb &

verdi: | $(wave_dir)
	cd $(wave_dir); \
	verdi -sverilog -f $(root_dir)/$(src_dir)/filelist.f &

superlint: | $(bld_dir)
	cd $(bld_dir); \
	jg -allow_unsupported_OS -superlint ../script/superlint.tcl &


clean:
	rm -rf $(bld_dir);
