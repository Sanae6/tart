.global read_uart_char
read_uart_char: # () -> (a0 char)
  la t0, 0x10000000 # load uart
  
  # wait for data
2:lb t1, 5(t0)
  andi t1, t1, 0b1
  beqz t1, 2b

  lb a0, 0(t0)
  ret
