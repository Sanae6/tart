#include "std.lib.s"
#include "ast.h"

.global lisp_main
lisp_main: start_frame 4
  sw s0, 0(sp)
  jal lisp_parse
  mv s0, a0
lisp_main.eval:
  mv a0, s0
  # ebreak
  jal eval_sexpr
  jal print_integer
  jal print_nl
lisp_main.end:
  lw s0, 0(sp)
  end_frame

eval_sexpr: start_frame 4 # (a0 sexpr) -> (a0 integer_value)
  sw s0, 0(sp)
  /*
    algorithm for first child
    none: panic
    integer: just return the integer
    sexpr: eval sexpr
    list: panic
  */
  lw a0, GROUP_START(a0)
  # ebreak
  beqz a0, eval_sexpr.no_child
  lw t0, NODE_TYPE(a0)
  li t1, AST_NUMBER
  beq t0, t1, eval_sexpr.eval_number
@default:
  mv a0, t0
  jal print_integer
  jal print_nl
  print "s-expr: default case panic lol"
  j panic
eval_sexpr.eval_number:
  jal eval_number
  j eval_sexpr.end
eval_sexpr.no_child:
  print "s-expr has no children"
  j panic
eval_sexpr.end:
  # a0 should be set by now
  lw s0, 0(sp)
  end_frame

eval_number: start_frame 4 # (a0 number) -> (a0 integer_value)
  sw s0, 0(sp)
  lw a0, NUMBER_VALUE(a0)
  mv s0, a0
  jal print_integer
  jal print_nl
  mv a0, s0
  lw s0, 0(sp)
  end_frame
