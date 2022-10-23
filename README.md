# GHDL Verilator Interface (GVI)

GVI generates glue code that allows to run Verilog modules inside of VHDL testbenches. Have a look at the examples to see how it works. In order to run the m-labs-lm32, serv, ibex examples, git submodules have to be activated (git submodule init; git submodule update;)

 - examples/vhd_v_counter: Run a Verilog implementation of a counter with a VHDL implementation of the same counter in the same testbench
 - examples/two_modules: Two Verilog modules used at the same time. They may have multiple clock ports.
 - examples/m-labs-lm32: Run an instance of the lm32 cpu
 - examples/serv: Run an instance of the serv risc-v cpu
 - examples/ibex: Run an instance of a more performant risc-v cpu