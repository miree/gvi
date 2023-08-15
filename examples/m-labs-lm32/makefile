all: run

VERILATOR_VERSION=`verilator --version | cut -d' ' -f 2 `

gvi: ../../gvi.cpp
	g++ -o $@ $<

.gvi/lm32_top/lm32_top_wrapper.vhd: gvi lm32_top_fixed.v lm32_config.v
	./gvi -vv $(VERILATOR_VERSION) -v lm32_top_fixed.v -t lm32_top -c clk_i -I lm32/rtl

# fix the source code to be able to run in verilator
lm32_top_fixed.v: lm32/rtl/lm32_top.v
	sed    '/input...LM32_INTERRUPT_RNG..interrupt.*/i \/\* verilator lint_off SYMRSVDWORD \*\/' $+ > lm32_top_fixed.v
	sed -i '/input...LM32_INTERRUPT_RNG..interrupt.*/a \/\* verilator lint_on  SYMRSVDWORD \*\/' lm32_top_fixed.v

run: testbench
	ghdl -r testbench --stop-time=100us --wave=simulation.ghw --ieee-asserts=disable

testbench: 	.gvi/lm32_top/lm32_top_wrapper.vhd \
			testbench.vhd
	ghdl -a $(GHDLFLAGS) $+
	ghdl -m $(GHDLFLAGS) \
	        $(shell cat .gvi/lm32_top/lm32_top_wrapper.flags) \
	        $(shell cat .gvi/common.flags) \
	        testbench 

clean:
	rm -rf lm32_top gvi .gvi *.o *.vcd *.ghw work-obj93.cf testbench lm32_top_fixed.v 
