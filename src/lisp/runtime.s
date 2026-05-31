#include "std.lib.s"
#include "ast.h"

.macro def_func label name frame_size
.rodata
.section .function_names
2: .ascii "\name"
3: .byte 0
.section .functions // address of string, size of string, ptr to func
  .word 2b
  .word (3b - 2b)
  .word lisp_func_\label
.text
lisp_func_\label: start_frame \frame_size
.endm

def_func plus "+" 4 # (a0 children)
  sw s0, 0(sp)
  lw s0, NODE_NEXT(a0)
  jal eval_expr
  mv t0, a0
  mv a0, s0
  mv s0, t0
  jal eval_expr
  add a0, a0, s0
  lw s0, 0(sp)
  end_frame

def_func minus "-" 4
  sw s0, 0(sp)
  lw s0, NODE_NEXT(a0)
  jal eval_expr
  mv t0, a0
  mv a0, s0
  mv s0, t0
  jal eval_expr
  add a0, a0, s0
  lw s0, 0(sp)
  end_frame
