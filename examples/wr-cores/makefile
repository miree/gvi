GHDLFLAGS = --ieee=synopsys --std=93c \
	-fexplicit -frelaxed-rules --no-vital-checks --warn-binding --mb-comments 

VERILATOR_VERSION=`verilator --version | cut -d' ' -f 2 `


all: vhdl_sources testbench

gvi: ../../gvi.cpp
	g++ -o $@ $<


testbench: vhdl_sources \
           .gvi/lm32_top_full_debug/lm32_top_full_debug_wrapper.vhd                   \
           .gvi/lm32_top_full/lm32_top_full_wrapper.vhd                               \
           .gvi/lm32_top_medium_icache_debug/lm32_top_medium_icache_debug_wrapper.vhd \
           .gvi/lm32_top_medium_debug/lm32_top_medium_debug_wrapper.vhd               \
           .gvi/lm32_top_medium_icache/lm32_top_medium_icache_wrapper.vhd             \
           .gvi/lm32_top_medium/lm32_top_medium_wrapper.vhd                           \
           .gvi/lm32_top_minimal/lm32_top_minimal_wrapper.vhd                         \
           .gvi/sockit_owm/sockit_owm_wrapper.vhd                                     \
            $(shell cat vhdl_sources)
	ghdl -a -g $(GHDLFLAGS) \
           .gvi/lm32_top_full_debug/lm32_top_full_debug_wrapper.vhd                   \
           .gvi/lm32_top_full/lm32_top_full_wrapper.vhd                               \
           .gvi/lm32_top_medium_icache_debug/lm32_top_medium_icache_debug_wrapper.vhd \
           .gvi/lm32_top_medium_debug/lm32_top_medium_debug_wrapper.vhd               \
           .gvi/lm32_top_medium_icache/lm32_top_medium_icache_wrapper.vhd             \
           .gvi/lm32_top_medium/lm32_top_medium_wrapper.vhd                           \
           .gvi/lm32_top_minimal/lm32_top_minimal_wrapper.vhd                         \
           .gvi/sockit_owm/sockit_owm_wrapper.vhd                                     \
            $(shell cat vhdl_sources)
	ghdl -m $(GHDLFLAGS) \
         $(shell cat .gvi/lm32_top_full_debug/lm32_top_full_debug_wrapper.flags)  \
         $(shell cat .gvi/lm32_top_full/lm32_top_full_wrapper.flags)  \
         $(shell cat .gvi/lm32_top_medium_icache_debug/lm32_top_medium_icache_debug_wrapper.flags)  \
         $(shell cat .gvi/lm32_top_medium_debug/lm32_top_medium_debug_wrapper.flags)  \
         $(shell cat .gvi/lm32_top_medium_icache/lm32_top_medium_icache_wrapper.flags)  \
         $(shell cat .gvi/lm32_top_medium/lm32_top_medium_wrapper.flags)  \
         $(shell cat .gvi/lm32_top_minimal/lm32_top_minimal_wrapper.flags)  \
         $(shell cat .gvi/sockit_owm/sockit_owm_wrapper.flags) \
	     $(shell cat .gvi/common.flags) \
	        testbench 

run: testbench makefile
	ghdl -r  testbench --max-stack-alloc=524288 --stop-time=100ms --wave=simulation.ghw --ieee-asserts=disable

## auto generate lm32 vhdl wrapper 
.gvi/lm32_top_full_debug/lm32_top_full_debug_wrapper.vhd: lm32_allprofiles.v gvi
	./gvi -vv $(VERILATOR_VERSION) -v lm32_allprofiles.v -t lm32_top_full_debug -I wr-cores/ip_cores/general-cores/modules/wishbone/wb_lm32/src -I wr-cores/ip_cores/general-cores/modules/wishbone/wb_lm32/platform/generic
	sed -i '/entity lm32_top_full_debug is/ageneric(eba_reset: std_logic_vector(31 downto 0);sdb_address: std_logic_vector(31 downto 0));' .gvi/lm32_top_full_debug/lm32_top_full_debug_wrapper.vhd

.gvi/lm32_top_full/lm32_top_full_wrapper.vhd: lm32_allprofiles.v gvi
	./gvi -vv $(VERILATOR_VERSION) -v lm32_allprofiles.v -t lm32_top_full -I wr-cores/ip_cores/general-cores/modules/wishbone/wb_lm32/src -I wr-cores/ip_cores/general-cores/modules/wishbone/wb_lm32/platform/generic
	sed -i '/entity lm32_top_full is/ageneric(eba_reset: std_logic_vector(31 downto 0);sdb_address: std_logic_vector(31 downto 0));' .gvi/lm32_top_full/lm32_top_full_wrapper.vhd

.gvi/lm32_top_medium_icache_debug/lm32_top_medium_icache_debug_wrapper.vhd: lm32_allprofiles.v gvi
	./gvi -vv $(VERILATOR_VERSION) -v lm32_allprofiles.v -t lm32_top_medium_icache_debug -I wr-cores/ip_cores/general-cores/modules/wishbone/wb_lm32/src -I wr-cores/ip_cores/general-cores/modules/wishbone/wb_lm32/platform/generic
	sed -i '/entity lm32_top_medium_icache_debug is/ageneric(eba_reset: std_logic_vector(31 downto 0);sdb_address: std_logic_vector(31 downto 0));' .gvi/lm32_top_medium_icache_debug/lm32_top_medium_icache_debug_wrapper.vhd

.gvi/lm32_top_medium_debug/lm32_top_medium_debug_wrapper.vhd: lm32_allprofiles.v gvi
	./gvi -vv $(VERILATOR_VERSION) -v lm32_allprofiles.v -t lm32_top_medium_debug -I wr-cores/ip_cores/general-cores/modules/wishbone/wb_lm32/src -I wr-cores/ip_cores/general-cores/modules/wishbone/wb_lm32/platform/generic
	sed -i '/entity lm32_top_medium_debug is/ageneric(eba_reset: std_logic_vector(31 downto 0);sdb_address: std_logic_vector(31 downto 0));' .gvi/lm32_top_medium_debug/lm32_top_medium_debug_wrapper.vhd

.gvi/lm32_top_medium_icache/lm32_top_medium_icache_wrapper.vhd: lm32_allprofiles.v gvi
	./gvi -vv $(VERILATOR_VERSION) -v lm32_allprofiles.v -t lm32_top_medium_icache -I wr-cores/ip_cores/general-cores/modules/wishbone/wb_lm32/src -I wr-cores/ip_cores/general-cores/modules/wishbone/wb_lm32/platform/generic
	sed -i '/entity lm32_top_medium_icache is/ageneric(eba_reset: std_logic_vector(31 downto 0);sdb_address: std_logic_vector(31 downto 0));' .gvi/lm32_top_medium_icache/lm32_top_medium_icache_wrapper.vhd

.gvi/lm32_top_medium/lm32_top_medium_wrapper.vhd: lm32_allprofiles.v gvi
	./gvi -vv $(VERILATOR_VERSION) -v lm32_allprofiles.v -t lm32_top_medium -I wr-cores/ip_cores/general-cores/modules/wishbone/wb_lm32/src -I wr-cores/ip_cores/general-cores/modules/wishbone/wb_lm32/platform/generic
	sed -i '/entity lm32_top_medium is/ageneric(eba_reset: std_logic_vector(31 downto 0);sdb_address: std_logic_vector(31 downto 0));' .gvi/lm32_top_medium/lm32_top_medium_wrapper.vhd

.gvi/lm32_top_minimal/lm32_top_minimal_wrapper.vhd: lm32_allprofiles.v gvi
	./gvi -vv $(VERILATOR_VERSION) -v lm32_allprofiles.v -t lm32_top_minimal -I wr-cores/ip_cores/general-cores/modules/wishbone/wb_lm32/src -I wr-cores/ip_cores/general-cores/modules/wishbone/wb_lm32/platform/generic
	sed -i '/entity lm32_top_minimal is/ageneric(eba_reset: std_logic_vector(31 downto 0);sdb_address: std_logic_vector(31 downto 0));' .gvi/lm32_top_minimal/lm32_top_minimal_wrapper.vhd



#lm32 
lm32_allprofiles.v: wr-cores/ip_cores/general-cores/modules/wishbone/wb_lm32/generated/lm32_allprofiles.v
	sed    '/input \[ (32-1):0\] interrupt;/i \/\* verilator lint_off SYMRSVDWORD \*\/' $< > $@
	sed -i '/input \[ (32-1):0\] interrupt;/a \/\* verilator lint_on  SYMRSVDWORD \*\/' $@

.gvi/sockit_owm/sockit_owm_wrapper.vhd: sockit_owm.v gvi
	./gvi -vv $(VERILATOR_VERSION) -v $< -t sockit_owm -G BTP_N=5.0 -G BTP_O=1.0 -G OWN=2 -G CDR_N=4 -G CDR_O=0
	sed -i '/entity sockit_owm is/ageneric(BTP_N: string; BTP_O: string; OWN: integer; CDR_N : integer; CDR_O : integer);' .gvi/sockit_owm/sockit_owm_wrapper.vhd

sockit_owm.v:  wr-cores/ip_cores/general-cores/modules/wishbone/wb_onewire_master/sockit_owm.v
	sed -e "s/owr_sel <= /owr_sel = /g" $< > $@ 


# modify the list of VHDL source files ( exclude certain files or replace them with patched files)
hdl_sources: Manifest.py
	hdlmake list-files > hdl_sources 

vhdl_sources: hdl_sources 
	grep .vhd hdl_sources       | \
	grep -v kintex              | \
	grep -v xc7                 | \
	grep -v si57x               | \
	grep -v xwb_fine_pulse_gen  | \
	grep -v cheby_dpssram.vhd     \
	> vhdl_sources

v_sources: hdl_sources
	grep .v hdl_sources > v_sources	

clean:
	rm -f *.o gvi hdl_sources vhdl_sources lm32_allprofiles.v sockit_owm.v testbench simulation.ghw Vlm32_top_medium_icache_vlt_dump_00.vcd Vsockit_owm_vlt_dump_00.vcd work-obj93.cf 




