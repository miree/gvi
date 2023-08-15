VERILATOR_VERSION=`verilator --version | cut -d' ' -f 2 `

IBEX_BASEDIR=ibex

IBEX_SOURCES_V=\
	$(IBEX_BASEDIR)/syn/rtl/prim_clock_gating.v 

IBEX_SOURCES_SV=\
	$(IBEX_BASEDIR)/dv/uvm/core_ibex/common/prim/prim_buf.sv \
	$(IBEX_BASEDIR)/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_generic_buf.sv \
	$(IBEX_BASEDIR)/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_dummy_macros.svh \
	$(IBEX_BASEDIR)/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv \
	$(IBEX_BASEDIR)/vendor/lowrisc_ip/ip/prim/rtl/prim_util_pkg.sv \
	$(IBEX_BASEDIR)/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv \
	$(IBEX_BASEDIR)/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv \
	$(IBEX_BASEDIR)/vendor/lowrisc_ip/ip/prim/rtl/prim_cipher_pkg.sv \
	$(IBEX_BASEDIR)/vendor/lowrisc_ip/ip/prim/rtl/prim_clock_gating_sync.sv \
	$(IBEX_BASEDIR)/vendor/lowrisc_ip/dv/sv/dv_utils/dv_fcov_macros.svh \
	$(IBEX_BASEDIR)/rtl/ibex_pkg.sv \
    $(IBEX_BASEDIR)/rtl/ibex_alu.sv \
    $(IBEX_BASEDIR)/rtl/ibex_compressed_decoder.sv \
    $(IBEX_BASEDIR)/rtl/ibex_controller.sv \
    $(IBEX_BASEDIR)/rtl/ibex_cs_registers.sv \
    $(IBEX_BASEDIR)/rtl/ibex_decoder.sv \
    $(IBEX_BASEDIR)/rtl/ibex_ex_block.sv \
    $(IBEX_BASEDIR)/rtl/ibex_id_stage.sv \
    $(IBEX_BASEDIR)/rtl/ibex_if_stage.sv \
    $(IBEX_BASEDIR)/rtl/ibex_wb_stage.sv \
    $(IBEX_BASEDIR)/rtl/ibex_load_store_unit.sv \
    $(IBEX_BASEDIR)/rtl/ibex_multdiv_slow.sv \
    $(IBEX_BASEDIR)/rtl/ibex_multdiv_fast.sv \
    $(IBEX_BASEDIR)/rtl/ibex_prefetch_buffer.sv \
    $(IBEX_BASEDIR)/rtl/ibex_fetch_fifo.sv \
    $(IBEX_BASEDIR)/rtl/ibex_pmp.sv \
    $(IBEX_BASEDIR)/rtl/ibex_core.sv \
    $(IBEX_BASEDIR)/rtl/ibex_tracer_pkg.sv \
    $(IBEX_BASEDIR)/rtl/ibex_tracer.sv \
    $(IBEX_BASEDIR)/rtl/ibex_top.sv 


IBEX_INCLUDES=\
	-I $(IBEX_BASEDIR)/rtl \
	-I $(IBEX_BASEDIR)/shared \
	-I $(IBEX_BASEDIR)/syn/rtl \
	-I $(IBEX_BASEDIR)/vendor/lowrisc_ip/ip/prim/rtl \
	-I $(IBEX_BASEDIR)/vendor/lowrisc_ip/dv/sv/dv_utils


all: run

run: testbench
	ghdl -r testbench --stop-time=100us --wave=simulation.ghw --ieee-asserts=disable


testbench: \
		.gvi/ibex_top/ibex_top_wrapper.vhd \
		testbench.vhd
	ghdl -a $(GHDLFLAGS) $+
	ghdl -m $(GHDLFLAGS) \
	        $(shell cat .gvi/ibex_top/ibex_top_wrapper.flags) \
	        $(shell cat .gvi/common.flags) \
	        testbench 	

.gvi/ibex_top/ibex_top_wrapper.vhd: gvi
	sed -i 's/  logic \[Width-1:0\] rdata\_q;/\/\* verilator lint_off UNOPTFLAT \*\/logic \[Width-1:0\] rdata\_q;\/\* verilator lint\_on UNOPTFLAT \*\//' $(IBEX_BASEDIR)/rtl/ibex_csr.sv
	./gvi -vv $(VERILATOR_VERSION) -v $(IBEX_SOURCES_V )$(IBEX_SOURCES_SV) $(IBEX_INCLUDES) -t ibex_top


gvi: ../../gvi.cpp
	g++ -o gvi $+


clean:
	rm -rf gvi .gvi *.o *.vcd *.ghw work-obj93.cf testbench 
