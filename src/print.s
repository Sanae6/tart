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

.global print_nl # () -> netherlands
.global print_char
print_nl:
  li a0, '\n'
  #j print_char
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

.global print_integer
print_integer: # (a0 signed_integer)
  la t0, 0x10000000 # load uart
  li t2, 10
  li t3, '0'
  la t4, print_integer.digit_buffer
  li t5, 0
  bgez a0, print_integer.load_loop # don't branch to handle negatives
  li t1, '-'
  sb t1, 0(t0) # store to uart
  neg a0, a0 # be positive!
print_integer.load_loop:
  rem t1, a0, t2 # a0 % 10
  div a0, a0, t2 # a0 /= 10
  add t1, t1, t3 # convert to ascii digit
  sb t1, 0(t4) # store to digit buffer
  addi t4, t4, 1 # inc buffer ptr
  addi t5, t5, 1 # count up
  bnez a0, print_integer.load_loop # loop back until touching all digits
print_integer.rev:
  addi t5, t5, -1
  addi t4, t4, -1
  lb t1, 0(t4)
  sw t1, 0(t0)
  bnez t5, print_integer.rev
  ret
.bss
print_integer.digit_buffer:
  .zero 10 # using the fact that 32 bit integers can only represent up to 10 base-ten digits
