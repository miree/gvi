# GHDL Verilator Interface (GVI)

GVI generates glue code that allows to run Verilog modules inside of VHDL testbenches. Have a look at the examples to see how it can be used. In order to run the m-labs-lm32, serv, ibex, hazard3, toy_SoC or wr-cores examples, git submodules have to be activated (`git submodule init; git submodule update;`)

 - examples/vhd_v_counter: Run a Verilog implementation of a counter with a VHDL implementation of the same counter in the same testbench.
 - examples/two_modules: Two Verilog modules used at the same time. They may have multiple clock ports.
 - examples/m-labs-lm32: Run an instance of the lm32 cpu.
 - examples/serv: Run an instance of the serv risc-v cpu.
 - examples/ibex: Run an instance of a more performant risc-v cpu.
 - examples/hazard3: Run an instance of yet another risc-v cpu.
 - examples/toy_SoC: A slightly more complex example with a simple SoC. Three RISC-V CPUs (uRV, picorv32, serv with MDU) are available. They have a custom wishbone wrapper for data and instruction bus and all CPUs runs the exact same firmware stored in memory that calculates digits of PI and writes these digits onto a pseudo UART device that ends up in a text file in the simulation directory (`cpu_output.txt`). [more details are here](examples/toy_SoC/README.md)
 - examples/vhdl_verilog_mixed: Demonstrate a fully mixed language design. VHDL implementation, Verilog implementation, and Verilog instantiating VHDL entity running together in the same testbench. This is possible because GHDL can convert VHDL code into Verilog code using its synthesis capabilities (only tested with GHDL version 4). 

# How it works

GHDL can call into C APIs using VHPIDIRECT. Verilator can generate a C++ class (the verilated module) from a Verilog module, and C++ can create C APIs using extern "C". In order to use a verilated module from GHDL, two pieces of code are needed: 
 - C++ code that provides a C API for the verilated module.
 - VHDL code with an entity that has the same interface as the targeted Verilog module, with an architecture that calls the C API for the verilated module.

GVI calls Verilator, compiles the verilated module, and generates these two pieces of code plus some text files containing compiler/linker flags that are needed to integrate everything with GHDL.

With GVI, using Verilog modules in a VHDL simulation requires only a few lines in a Makefile.

# Limitations
 - Only input and output ports of verilog modules are supported. inout is not possible yet. 
 - GVI is developed and tested only with ghdl-gcc (GHDL with GCC backend)
 - It is possible to use Verilog modules from VHDL, not the other way around. This limitation can be overcome by automatically converting VHDL code to Verilog using GHDL sythesis feature (see examples/vhdl_verilog_mixed).
 - Module parameters from the Verilog module are not translated into VHDL generics, they have to be specified when calling GVI.
   
