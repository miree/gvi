all: run

VERILATOR_VERSION=`verilator --version | cut -d' ' -f 2 `

gvi: ../../gvi.cpp
	g++ -o gvi ../../gvi.cpp

.gvi/counter_v/counter_v_wrapper.vhd: gvi counter_v.v
	./gvi -vv $(VERILATOR_VERSION) -v counter_v.v -t counter_v -c clk_i 

.gvi/counter_mixed/counter_mixed_wrapper.vhd: gvi counter_mixed.v counter_vhd.v
	./gvi -vv $(VERILATOR_VERSION) -v counter_mixed.v -t counter_mixed -c clk_i 

counter_vhd.v: counter_vhd.vhd
	ghdl synth --out=verilog counter_vhd.vhd -e counter_vhd > counter_vhd.v

run: testbench
	ghdl -r testbench --stop-time=100us --wave=simulation.ghw --ieee-asserts=disable

testbench: 	.gvi/counter_v/counter_v_wrapper.vhd \
			.gvi/counter_mixed/counter_mixed_wrapper.vhd \
			counter_vhd.vhd              \
			testbench.vhd
	ghdl -a $(GHDLFLAGS) $+
	ghdl -m $(GHDLFLAGS) \
	        $(shell cat .gvi/counter_v/counter_v_wrapper.flags) \
	        $(shell cat .gvi/counter_mixed/counter_mixed_wrapper.flags) \
	        $(shell cat .gvi/common.flags) \
	        testbench 

clean:
	rm -rf counter_v counter_vhd.v gvi .gvi *.o *.vcd *.ghw work-obj93.cf testbench 
