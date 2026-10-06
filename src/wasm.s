format ms64 coff
section '.data' data readable writeable
header: db 0x00, 0x61, 0x73, 0x6D, 1,0,0,0

section '.text' code readable executable

read_leb:

wasm_main:
