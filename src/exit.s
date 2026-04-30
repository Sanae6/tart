# sifive test device
.global exit, panic
exit:
  la t0, 0x100000
  li t1, 0x5555
  sw t1, 0(t0)
  2:
  j 2b
panic: 
  la t0, 0x100000
  li t1, 0x3333
  sw t1, 0(t0)
  2:
  j 2b
