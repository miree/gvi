GHDLFLAGS=--std=08

all: run

gvi: ../../gvi.cpp
	g++ -o $@ $<

run: testbench
	make -C firmware && cp firmware/firmware.bitvector .
	ghdl -r testbench --stop-time=100ms --ieee-asserts=disable --wave=simulation.ghw #--read-wave-opt=all
#	ghdl -r testbench --ieee-asserts=disable # use this if you dont want .ghw trace files

testbench: 	\
		wbp_pkg.vhd                              \
		wbp_mux.vhd                              \
		dpram_wbp.vhd                            \
		.gvi/urv_cpu/urv_cpu_wrapper.vhd         \
		urv_cpu_wbp.vhd                          \
		.gvi/picorv32/picorv32_wrapper.vhd       \
		picorv32_wbp.vhd                         \
		.gvi/serv_rf_top/serv_rf_top_wrapper.vhd \
		.gvi/mdu_top/mdu_top_wrapper.vhd         \
		serv_rf_wbp.vhd                          \
		testbench.vhd
	ghdl -a $(GHDLFLAGS) $+
	ghdl -m $(GHDLFLAGS)                                            \
	        $(shell cat .gvi/common.flags)                          \
	        $(shell cat .gvi/urv_cpu/urv_cpu_wrapper.flags)         \
	        $(shell cat .gvi/picorv32/picorv32_wrapper.flags)       \
	        $(shell cat .gvi/serv_rf_top/serv_rf_top_wrapper.flags) \
	        $(shell cat .gvi/mdu_top/mdu_top_wrapper.flags)         \
	        testbench 

clean:
	rm -rf .gvi gvi *.o *.vcd *.ghw work-obj93.cf testbench firmware.bitvector


.gvi/urv_cpu/urv_cpu_wrapper.vhd: gvi urv-core/rtl/urv_cpu.v
	./gvi -v urv-core/rtl/urv_cpu.v -t urv_cpu -I urv-core/rtl -o -Wno-fatal

.gvi/picorv32/picorv32_wrapper.vhd: gvi picorv32/picorv32.v
	./gvi -v picorv32/picorv32.v -t picorv32 -o -Wno-fatal -G 'ENABLE_IRQ=1' -G 'PROGADDR_RESET=0' -G 'ENABLE_MUL=1' -G 'ENABLE_DIV=1'

# note that serv doesn't create .vcd trace files (-n parameter)
# make sure to set the parameter to enable the MDU extension (MDU=1)
.gvi/serv_rf_top/serv_rf_top_wrapper.vhd: gvi ../serv/serv/rtl/serv_rf_top.v
	./gvi -n -v ../serv/serv/rtl/serv_rf_top.v -t serv_rf_top -I ../serv/serv/rtl -G 'MDU=1'

# this multiply division unit (MDU) attaches to SERV CPU to allow mul and div instructions
.gvi/mdu_top/mdu_top_wrapper.vhd: gvi mdu/rtl/mdu_top.v
	./gvi -n -v mdu/rtl/mdu_top.v -t mdu_top 
