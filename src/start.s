#include "std.lib.s"

.section .init
.global system_entrypoint
system_entrypoint:
  la sp, stack_top
  la a0, bss_start
  la a1, bss_end
2:
  sb zero, 0(a0)
  addi a0, a0, 1
  bne a0, a1, 2b

  // to investigate if care (probably don't care)
  # li a0, 0x80000000
  # jal print_integer
  # jal print_nl
  jal lisp_main
  j exit

.bss
bstart:
.zero 128
