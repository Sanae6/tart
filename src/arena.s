#include "std.lib.s"

#define ARENA_SIZE 0x1000

.global alloc_arena
alloc_arena: start_frame # (a0 size) -> (a0 ptr)
  # align up a0
  addi a0, a0, 0b11
  srli a0, a0, 2
  slli a0, a0, 2

  # update arena offset and return
  la t0, arena_offset
  lw t1, 0(t0)
  add t2, t1, a0
  sw t2, 0(t0)
  la t0, arena
  add a0, t0, t1
  li t2, ARENA_SIZE
  ble t2, t1, alloc_arena.panic
  end_frame
alloc_arena.panic:
  print "arena: out of memory"
  j panic
.bss
arena_offset: .word 0
arena:
  .zero ARENA_SIZE
