#include "std.lib.s"

.global lisp_lookup
lisp_call: start_frame # (a0 sexpr)
  
  end_frame
