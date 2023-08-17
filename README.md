# GHDL Verilator Interface (GVI)

GVI generates glue code that allows to run Verilog modules inside of VHDL testbenches. Have a look at the examples to see how it can be used. In order to run the m-labs-lm32, serv, ibex examples, git submodules have to be activated (git submodule init; git submodule update;)

 - examples/vhd_v_counter: Run a Verilog implementation of a counter with a VHDL implementation of the same counter in the same testbench
 - examples/two_modules: Two Verilog modules used at the same time. They may have multiple clock ports.
 - examples/m-labs-lm32: Run an instance of the lm32 cpu
 - examples/serv: Run an instance of the serv risc-v cpu
 - examples/ibex: Run an instance of a more performant risc-v cpu

# How it works

GHDL can call into C APIs using VHPIDIRECT. Verilator can generate C++ classes from a Verilog module, i.e. the verilated module, and C++ can create C APIs using extern "C". In order to use a verilated module from GHDL, two pieces of code are needed: 
 - C++ code that provides a C API for the verilated module.
 - VHDL code with an entity that has the same interface as the targeted Verilog module, with an architecture that calls the C API for the verilated module.

GVI calls Verilator, generates these tow pieces of code, the C++ part, and the VHDL part, and some text files with compiler flags that are needed to link everything together into an executable. Then it compiles everything into a library.

All that is needed to integrate Verilog modules into a VHDL simulations are a few lines in a Makefile.

# Constraints
 - GVI is developed and tested only with ghdl-gcc (GHDL with GCC backend)
 - It is only possible to use Verilog modules from VHDL, not the other way around.
 - Module parameters from the Verilog module are not translated into VHDL generics, they have to be specified when calling GVI.
   
