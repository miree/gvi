all: run

gvi: ../../gvi.cpp
	g++ -o $@ $<

.gvi/serv_rf_top/serv_rf_top_wrapper.vhd: gvi serv/rtl/serv_rf_top.v
	./gvi -v serv/rtl/serv_rf_top.v -t serv_rf_top -I serv/rtl

run: testbench
	ghdl -r testbench --stop-time=100us --wave=simulation.ghw --ieee-asserts=disable

testbench: 	.gvi/serv_rf_top/serv_rf_top_wrapper.vhd \
			testbench.vhd
	ghdl -a $(GHDLFLAGS) $+
	ghdl -m $(GHDLFLAGS) \
	        $(shell cat .gvi/serv_rf_top/serv_rf_top_wrapper.flags) \
	        $(shell cat .gvi/common.flags) \
	        testbench 

clean:
	rm -rf serv_rf_top gvi .gvi *.o *.vcd *.ghw work-obj93.cf testbench 
