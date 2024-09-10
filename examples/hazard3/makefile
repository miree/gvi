all: run

VERILATOR_VERSION=`verilator --version | cut -d' ' -f 2 `

gvi: ../../gvi.cpp
	g++ -o $@ $<
	
.gvi/hazard3_core/hazard3_core_wrapper.vhd: gvi Hazard3/hdl/hazard3_core.v
	./gvi -v Hazard3/hdl/hazard3_core.v -I Hazard3/hdl/ -I Hazard3/hdl/arith -I Hazard3/hdl/debug -t hazard3_core

run: testbench
	ghdl -r testbench --stop-time=1us --wave=simulation.ghw --ieee-asserts=disable

testbench: 	.gvi/hazard3_core/hazard3_core_wrapper.vhd \
			testbench.vhd
	ghdl -a $(GHDLFLAGS) $+
	ghdl -m $(GHDLFLAGS) \
	        $(shell cat .gvi/hazard3_core/hazard3_core_wrapper.flags) \
	        $(shell cat .gvi/common.flags) \
	        testbench 

clean:
	rm -rf hazard3_core gvi .gvi *.o *.vcd *.ghw work-obj93.cf testbench 
