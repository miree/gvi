files = [
   "testbench.vhd",
   "uart.vhd",
   "one_wire_tempsense.vhd"
]
modules = {
  "local" : [
    "wr-cores/modules",
    "wr-cores/ip_cores/general-cores/modules/genrams/xilinx",
    "wr-cores/ip_cores/general-cores",
    "wr-cores/modules/wrc_core"
  ]
}

