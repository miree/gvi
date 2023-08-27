# A testbench for the [WhiteRabbit core](https://ohwr.org/project/wr-cores) 
This testbench is based on the repositories linked at the bottom of this page: https://ohwr.org/project/wr-cores/wikis/Wrpc-release-v42

WhiteRabbit has a VHDL code base but uses a few Verilog modules (LM32 CPU and 1-wire module).

Compiling this example requires hdlmake.

Instructions to compile and run the testbench:

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

A firmware binary (wrc.bram) is included in the repository. 
This is not a special "simulation"-firmware and it takes a while until something happens. 
To compile the firmware lm32-elf-gcc is required.
The patch (wrpc-sw.patch) is needed to compile with the lm32-elf-gcc package from Arch Linux.

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
