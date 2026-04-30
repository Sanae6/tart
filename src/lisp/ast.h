#pragma once

#define AST_NODE_SIZE 16

#define NODE_NEXT 0
#define NODE_TYPE 4
#define IDENT_ADDRESS 8
#define IDENT_SIZE 12
#define NUMBER_VALUE 8
#define GROUP_CHILDREN 8
#define GROUP_ARRAY 12

#define AST_IDENT 0
#define AST_NUMBER 1
#define AST_LIST 2
#define AST_SEXPR 3

/*
struct ast_node {
  u32 next;
  u16 type;
  u16 _padding;
  union {
    struct ident {
      u32 address;
      u32 size;
    }
    struct number {
      i32 value;
    }
    struct sexpr_or_list {
      u32 children;
      u32 arrayPtr;
    }
  }
}
*/
