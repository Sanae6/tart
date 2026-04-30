#include "ast.h"
#include "std.lib.s"

.global lisp_parse
lisp_parse: start_frame 8 # () -> (a0 sexpr_list, a1 sexpr_list_len)
  sw s0, 0(sp)
  sw s1, 4(sp)
  la tp, file
  li a0, 4 * 32
  jal alloc_arena
  mv s0, a0
  sw zero, 0(s0)
  add s1, s0, 4
lisp_parse.loop:
  jal peek_char
  li t0, ' '
  beq a0, t0, lisp_parse.whitespace
  li t0, '\n'
  beq a0, t0, lisp_parse.whitespace
  li t0, '\r'
  beq a0, t0, lisp_parse.whitespace
  beqz a0, lisp_parse.end
  # print "reading sexpr\n"
  jal read_sexpr
  sw a0, 0(s1)
  add s1, s1, 4
  j lisp_parse.loop
lisp_parse.whitespace:
  # print "whitespace\n"
  jal read_char
  j lisp_parse.loop
lisp_parse.end:
  print "done parsing\n"
  mv a0, s0
  lw s0, 0(sp)
  lw s1, 4(sp)
  end_frame

# read expression
read_expr: start_frame 4 # () -> (a0 expr)
  sw s0, 0(sp)
read_expr.start:
  jal peek_char
  mv s0, a0
  # parse s-expr
  li t0, '('
  beq s0, t0, read_expr.sexpr
  li t0, '['
  beq s0, t0, read_expr.list
  
  mv a0, s0
  jal is_digit
  bnez a0, read_expr.number
  li t0, '-'
  beq s0, t0, read_expr.number

  j read_expr.ident
read_expr.ident:
  print "expr: reading ident\n"
  jal read_ident
  j read_expr.end
read_expr.number:
  print "expr: reading number\n"
  jal read_number
  j read_expr.end
read_expr.list:
  print "expr: reading list\n"
  jal read_list
  j read_expr.end
read_expr.sexpr:
  print "expr: reading sexpr\n"
  jal read_sexpr
  j read_expr.end
read_expr.end:
  lw s0, 0(sp)
  end_frame

read_ident: start_frame 16 # () -> (a0 node)
  sw s0, 0(sp)
  sw s1, 4(sp)
  sw s2, 8(sp)
  sw s3, 12(sp)
  mv s0, tp
  li s1, 1
  jal peek_char
  jal is_digit
  bnez a0, read_ident.not_an_ident
  jal peek_char
  li s2, '('
  li s3, ')'
  beq a0, s2, read_ident.not_an_ident
  beq a0, s3, read_ident.not_an_ident
read_ident.loop:
  jal peek_char
  jal is_digit
  bnez a0, read_ident.end
  jal peek_char
  li s2, '('
  li s3, ')'
  beq a0, s2, read_ident.end
  beq a0, s3, read_ident.end
  addi s1, s1, 1
  addi tp, tp, 1
  j read_ident.loop
read_ident.not_an_ident:
  print "ident: not an alphabetic character\n"
  j panic
read_ident.end:
  li a0, AST_NODE_SIZE
  jal alloc_arena
  li t0, AST_IDENT
  sh t0, NODE_TYPE(a0)
  sw s0, IDENT_ADDRESS(a0)
  sw s1, IDENT_SIZE(a0)
  lw s0, 0(sp)
  lw s1, 4(sp)
  lw s2, 8(sp)
  lw s3, 12(sp)
  end_frame

read_number: start_frame 8 # () -> (a0 node)
  sw s0, 0(sp)
  sw s1, 4(sp)
  mv s0, zero
  li s1, 0 # is negated
  jal read_char
  li t0, '-'
  bne a0, t0, read_number.cont
read_number.neg:
  xori s1, s1, 1
  jal read_char
  li t0, '-'
  beq a0, t0, read_number.neg
read_number.cont:
  jal is_digit
  beqz a0, read_number.not_a_number
read_number.loop:
  li t0, 10
  mul s0, s0, t0
  add s0, s0, a0
  jal peek_char
  jal is_digit
  beqz a0, read_number.end
  jal read_char
  j read_number.loop
read_number.not_a_number:
  print "number: not a digit\n"
  j panic
read_number.end:
  beqz s1, 2f
  neg s0, s0
2:
  li a0, AST_NODE_SIZE
  jal alloc_arena
  li t0, AST_NUMBER
  sh t0, NODE_TYPE(a0)
  sw zero, NUMBER_VALUE(a0)
  lw s0, 0(sp)
  lw s1, 4(sp)
  end_frame

#define GROUP_DEF_OPEN_CHAR 0
#define GROUP_DEF_CLOSE_CHAR 1
#define GROUP_DEF_AST_TYPE 2
#define GROUP_DEF_NAME 4
#define GROUP_DEF_NAME_LEN 8
read_group: start_frame 12 # (a0 group_type) -> (a0 node)
  print "reading a group\n"
  sw s0, 0(sp)
  sw s1, 4(sp)
  sw s2, 8(sp)
  mv s2, a0
  jal read_char
  lb t0, GROUP_DEF_OPEN_CHAR(s2)
  bne t0, a0, read_group.expected_open_char
  li a0, AST_NODE_SIZE
  jal alloc_arena
  mv s0, a0
  lb t0, GROUP_DEF_AST_TYPE(s2)
  sh t0, NODE_TYPE(s0)
  sw zero, GROUP_CHILDREN(s0)
  li a0, 4 * 32 # 32 children max
  jal alloc_arena
  sw a0, GROUP_ARRAY(s0)
  mv s1, a0
read_group.read_children:
  jal peek_char
  beqz a0, read_group.end_of_file
  lb t0, GROUP_DEF_CLOSE_CHAR(s2)
  beq t0, a0, read_group.end
  # skip whitespace
  li t0, ' '
  beq a0, t0, read_group.whitespace
  li t0, '\n'
  beq a0, t0, read_group.whitespace
  li t0, '\r'
  beq a0, t0, read_group.whitespace
  # read expr
  jal read_expr
  sw a0, 0(s1)
  addi s1, s1, 4
  j read_group.read_children
read_group.whitespace:
  jal read_char
  j read_group.read_children
read_group.expected_open_char:
  print "expected\n"
  lw a0, GROUP_DEF_NAME(s2)
  lw a1, GROUP_DEF_NAME_LEN(s2)
  jal print_text_with_length
  print ": expected '"
  lb a0, GROUP_DEF_OPEN_CHAR(s2)
  print "'\n"
  j panic
read_group.end_of_file:
  print "eof\n"
  lw a0, GROUP_DEF_NAME(s2)
  lw a1, GROUP_DEF_NAME_LEN(s2)
  jal print_text_with_length
  print ": end of file, unbalanced group\n"
  j panic
read_group.end:
  jal read_char
  mv a0, s0
  lw s0, 0(sp)
  lw s1, 4(sp)
  lw s2, 8(sp)
  end_frame

/*
struct group_def {
  u8 open_char;
  u8 close_char;
  u8 ast_type;
  u8 _padding;
  u32 name;
  u32 name_len;
}
*/
read_list:
  la a0, list_group
  j read_group
read_sexpr:
  la a0, sexpr_group
  j read_group

.rodata
.balign 4
list_group:
  .byte '[', ']', AST_LIST, 0
  .word 2f
  .word (3f - 2f)
2: .ascii "list"
3: .byte 0
.balign 4
sexpr_group:
  .byte '(', ')', AST_SEXPR, 0
  .word 2f
  .word (3f - 2f)
2: .ascii "s-expr"
3: .byte 0
.balign 4
.text

peek_char: start_frame
  jal erase_comments
  lb a0, 0(tp)
  end_frame

read_char: start_frame
  jal erase_comments
  lb a0, 0(tp)
  addi tp, tp, 1
  end_frame

erase_comments:
  lb a0, 0(tp)
  li t0, ';'
  bne a0, t0, erase_comments.end
  li t0, '\n'
erase_comments.loop:
  addi tp, tp, 1
  lb a0, 0(tp)
  beq a0, t0, erase_comments.end
  beqz a0, erase_comments.end
  j erase_comments.loop
erase_comments.end:
  ret

.bss
file_offset:
  .word 0


.rodata
.balign 4
file:
  .byte
#embed "file.txt"
  
  .word 0

  .balign 4
file_len:
  .word (file_len - file)
