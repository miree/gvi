# https://twilco.github.io/riscv-from-scratch/2019/04/27/riscv-from-scratch-2.html
.section .init, "ax"
.global _start
_start:
    .cfi_startproc
    .cfi_undefined ra
    .org 0x00
    .rept 32
      nop
    .endr
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop
    la sp, __stack_top
    add s0, sp, zero
    jal zero, main
    .cfi_endproc
    .end
  