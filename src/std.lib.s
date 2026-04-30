.macro print text
  mv t6, a0
  la a0, 384f
  jal print_text
  j 385f
384:
  .asciz "\text"
  .balign 4
385:
  mv a0, t6
.endm

.macro start_frame size=0
  .set __frame_size, (4 +\size)
  .set __ra_offset, \size
  addi sp, sp, -__frame_size
  sw ra, __ra_offset(sp)
.endm
.macro end_frame
  lw ra, __ra_offset(sp)
  addi sp, sp, __frame_size
  ret
.endm
