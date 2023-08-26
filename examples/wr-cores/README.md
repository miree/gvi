# A testbench for the [WhiteRabbit core](https://ohwr.org/project/wr-cores) 
This testbench is based on the repositories linked at the bottom of this page: https://ohwr.org/project/wr-cores/wikis/Wrpc-release-v42

The WhiteRabbit core can be simulated with GVI.
WhiteRabbit has a VHDL codebase but ueses a few Verilog modules (an LM32 CPU and a 1-wire module).
Compiling the examples requires hdlmake.

To compile and run the testbench:

```bash
[gvi/examples/wr-cores]$ git submodule init
[gvi/examples/wr-cores]$ git submodule update 
[gvi/examples/wr-cores]$ cd wr-cores
[gvi/examples/wr-cores/wr-cores]$ git apply ../wr-cores.patch
[gvi/examples/wr-cores/wr-cores]$ git submodule init
[gvi/examples/wr-cores/wr-cores]$ git submodule update
[gvi/examples/wr-cores/wr-cores]$ cd ..
[gvi/examples/wr-cores]$ make testbench
[gvi/examples/wr-cores]$ make run
```
A firmware binary wrc.bram is included. 
This is not a special "simulation-firmware" and it takes a while until something happens. 
To compile the firmware an installation of lm32-elf-gcc is required.
The patch (wrpc-sw.patch) is needed to compile with the lm32-elf-gcc from Arch Linux.

```bash
[gvi/examples/wr-cores]$ cd wrpc-sw
[gvi/examples/wr-cores/wrpc-sw]$ git apply ../wrpc-sw.patch
[gvi/examples/wr-cores/wrpc-sw]$ git submodule init
[gvi/examples/wr-cores/wrpc-sw]$ git submodule update
[gvi/examples/wr-cores/wrpc-sw]$ make config # answer the questions
[gvi/examples/wr-cores/wrpc-sw]$ make
[gvi/examples/wr-cores/wrpc-sw]$ cp ..
[gvi/examples/wr-cores/wrpc-sw]$ cp wrpc-sw/wrc.bram .
```
