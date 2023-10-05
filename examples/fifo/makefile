all: run

VERILATOR_VERSION=`verilator --version | cut -d' ' -f 2 `

gvi: ../../gvi.cpp
	g++ -o gvi ../../gvi.cpp

.gvi/fifo/fifo_wrapper.vhd: gvi fifo.v
	./gvi -vv $(VERILATOR_VERSION) -v fifo.v -t fifo -c clk 

.gvi/clock_crossing_fifo/clock_crossing_fifo_wrapper.vhd: gvi clock_crossing_fifo.v
	./gvi -vv $(VERILATOR_VERSION) -v clock_crossing_fifo.v -t clock_crossing_fifo 

run: testbench
	ghdl -r testbench --stop-time=100us --wave=simulation.ghw --ieee-asserts=disable

testbench: 	.gvi/clock_crossing_fifo/clock_crossing_fifo_wrapper.vhd \
			testbench.vhd
	ghdl -a $(GHDLFLAGS) $+
	ghdl -m $(GHDLFLAGS) \
	        $(shell cat .gvi/clock_crossing_fifo/clock_crossing_fifo_wrapper.flags) \
	        $(shell cat .gvi/common.flags) \
	        testbench 

clean:
	rm -rf fifo gvi .gvi *.o *.vcd *.ghw work-obj93.cf testbench 
