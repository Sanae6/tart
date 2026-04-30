#include "std.lib.s"
in_range: # (a0 value, a1 low, a2 high) -> (a0 bool)
  addi a2, a2, 1
  addi a1, a1, -1
  slt t0, a0, a2
  sgt t1, a0, a1
  and a0, t0, t1
  ret

.global is_digit
is_digit: # (a0 value) -> (a0 bool)
  li a1, '0'
  li a2, '9'
  j in_range

.global is_alpha
is_alpha: start_frame 4 # () -> (a0 bool)
  sw s0, 0(sp)
  mv s0, a0
  li a1, 'a'
  li a2, 'z'
  jal in_range
  bnez a0, is_alpha.end
  mv a0, s0
  li a1, 'A'
  li a2, 'Z'
  jal in_range
is_alpha.end:
  lw s0, 0(sp)
  end_frame
