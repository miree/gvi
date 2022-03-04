# GHDL Verilator Interface (GVI)

GVI generates glue code that allows to run Verilog modules inside of VHDL testbenches. Have a look at the examples to see how it works.

 - examples/vhd_v_counter: Run a Verilog implementation of a counter with a VHDL implementation of the same counter in the same testbench
 - examples/two_modules: Two Verilog modules used at the same time. They may have multiple clock ports.
  