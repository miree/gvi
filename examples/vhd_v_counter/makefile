all: run

gvi: ../../gvi.cpp
	g++ -o gvi ../../gvi.cpp

.gvi/counter_v/counter_v_wrapper.vhd: gvi counter_v.v
	./gvi -v counter_v.v -t counter_v -c clk_i 

run: testbench
	ghdl -r testbench --stop-time=100us --wave=simulation.ghw --ieee-asserts=disable

testbench: 	.gvi/counter_v/counter_v_wrapper.vhd \
			counter_vhd.vhd              \
			testbench.vhd
	ghdl -a $(GHDLFLAGS) $+
	ghdl -m $(GHDLFLAGS) \
	        $(shell cat .gvi/counter_v/counter_v_wrapper.flags) \
	        $(shell cat .gvi/common.flags) \
	        testbench 

clean:
	rm -rf counter_v gvi .gvi *.o *.vcd *.ghw work-obj93.cf testbench 
