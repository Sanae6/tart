.global print_text
print_text: # (a0 string)
  lb t0, 0(a0) # load char
  la t1, 0x10000000 # load uart
  add a0, a0, 1 # inc ptr
  beqz t0, print_text.end # if nul, return
  sb t0, 0(t1) # store to uart
  j print_text # loop
print_text.end:
  ret

.global print_char
print_char: # (a0 char)
  la t0, 0x10000000 # load uart
  sb a0, 0(t0) # store to uart
  ret

.global print_text_with_length
print_text_with_length: # (a0 string, a1 length)
  lb t0, 0(a0) # load char
  la t1, 0x10000000 # load uart
  li t2, 1 # load 1 for sub
  add a0, a0, 1 # inc ptr
  beqz a1, print_text_with_length.end
  sb t0, 0(t1)
  sub a1, a1, t2 # sub length
  j print_text_with_length
print_text_with_length.end:
  ret
