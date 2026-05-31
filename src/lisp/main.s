#include "std.lib.s"
#include "ast.h"

.global lisp_main
lisp_main: start_frame 4
  sw s0, 0(sp)
  jal lisp_parse
  mv s0, a0
lisp_main.eval:
  mv a0, s0
  beqz a0, lisp_main.end
  # ebreak
  jal eval_sexpr
  jal print_integer
  jal print_nl
  lw s0, NODE_NEXT(s0)
  j lisp_main.eval
lisp_main.end:
  lw s0, 0(sp)
  end_frame

.global eval_expr
eval_expr: start_frame # (a0 node) -> (a0 value)
  lw t0, NODE_TYPE(a0)
  li t1, AST_NUMBER
  beq t0, t1, eval_expr.eval_number
  li t1, AST_SEXPR
  beq t0, t1, eval_expr.eval_sexpr
  li t1, AST_LIST
  beq t0, t1, eval_expr.eval_list
@default:
  mv a0, t0
  jal print_integer
  jal print_nl
  print "s-expr: unimplemented eval case"
  j panic
eval_expr.eval_number:
  jal eval_number
  j eval_expr.end
eval_expr.eval_sexpr:
  jal eval_sexpr
  j eval_expr.end
eval_expr.eval_list:
  print "cannot evaluate a list"
  j panic
eval_expr.end:
  end_frame

eval_sexpr: start_frame 4 # (a0 sexpr) -> (a0 value)
  sw s0, 0(sp)
  /*
    algorithm for first child
    none: panic
    integer: just return the integer
    sexpr: eval sexpr
    list: panic
  */
  lw a0, GROUP_START(a0)
  beqz a0, eval_sexpr.no_child
  lw t0, NODE_TYPE(a0)
  li t1, AST_IDENT
  beq t0, t1, eval_sexpr.eval_ident
  lw t0, NODE_NEXT(a0)
  bnez t0, eval_sexpr.has_child
  jal eval_expr
  j eval_sexpr.end
eval_sexpr.eval_ident: # where the maybe more interesting stuff happens
  jal lisp_call
  j eval_sexpr.end
eval_sexpr.has_child:
  print "non-call sexpr has more than one child"
  j panic
eval_sexpr.no_child:
  print "s-expr has no children"
  j panic
eval_sexpr.end:
  # a0 should be set by now
  lw s0, 0(sp)
  end_frame

eval_number: # (a0 number) -> (a0 integer_value)
  lw a0, NUMBER_VALUE(a0)
  ret

lisp_call: start_frame 8 # (a0 ident) -> (a0 integer)
  sw s0, 0(sp)
  sw s1, 4(sp)
  mv s0, a0

  la s1, functions_start
  # mv a0, s1
  # jal print_integer
  # jal print_nl
  # la a0, functions_end
  # jal print_integer
  # jal print_nl
lisp_call.search:
  la t0, functions_end
  beq s1, t0, lisp_call.missing
  lw a2, IDENT_SIZE(s0)
  lw t0, 4(s1)
  beq a2, t0, lisp_call.candidate
lisp_call.search_miss:
  print "search miss\n"
  addi a0, s1, 12
  j lisp_call.search
lisp_call.candidate:
  lw a0, IDENT_ADDRESS(s0)
  lw a2, IDENT_SIZE(s0)
  lw a1, 0(s1)
  jal streq
  beqz a0, lisp_call.search_miss
  j lisp_call.end
lisp_call.missing:
  mv a0, s1
  print "unable to find required function: '"
  lw a0, IDENT_ADDRESS(s0)
  lw a1, IDENT_SIZE(s0)
  jal print_text_with_length
  print "'\n"
  jal panic
lisp_call.end:
  lw t0, 8(s1)
  lw a0, NODE_NEXT(s0)
  jalr t0
  lw s0, 0(sp)
  lw s1, 4(sp)
  end_frame
