#include "std.lib.s"

.global lisp_main
lisp_main: start_frame
  jal lisp_parse
  end_frame
