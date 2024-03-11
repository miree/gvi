all: run

VERILATOR_VERSION=`verilator --version | cut -d' ' -f 2 `

gvi: ../../gvi.cpp
	g++ -o gvi ../../gvi.cpp

PORTSIZE?=48

.gvi/test_v/test_v_wrapper.vhd: gvi test_v.v makefile
	./gvi -vv $(VERILATOR_VERSION) -v test_v.v -t test_v -o -Gportsize=$(PORTSIZE) # use general option forwarding to set portsize

.gvi/test2_v/test2_v_wrapper.vhd: gvi test2_v.v makefile
	./gvi -vv $(VERILATOR_VERSION) -v test2_v.v -t test2_v -G portsize=$(PORTSIZE) # use special generics option to set portsize

run: testbench makefile
	ghdl -r  testbench -gportsize=$(PORTSIZE) --stop-time=100us --wave=simulation.ghw --ieee-asserts=disable

testbench: 	.gvi/test_v/test_v_wrapper.vhd \
			.gvi/test2_v/test2_v_wrapper.vhd \
			testbench.vhd
	ghdl -a $(GHDLFLAGS) $+
	ghdl -m $(GHDLFLAGS) \
	        $(shell cat .gvi/test_v/test_v_wrapper.flags) \
	        $(shell cat .gvi/test2_v/test2_v_wrapper.flags) \
	        $(shell cat .gvi/common.flags) \
	        testbench 

clean:
	rm -rf testbench .gvi gvi *.o *.vcd *.ghw work-obj93.cf 
