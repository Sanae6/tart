format ms64 coff
section '.data' data readable writeable
common_cfg: dq 0
isr_cfg: dq 0
device_cfg: dq 0
section '.text' code readable executable
public init_vconsole ; rax = pcie cam
init_vconsole:
  push    r8
  push    r9
  push    r13
  push    r15
init_vconsole.loop:
  mov     r9d, [rax]
  cmp     r9d, 0x1003_1AF4
  je      init_vconsole.end
  cmp     r9d, 0xFFFF_FFFF
  je      oops
  add     rax, 0x8000
  jmp     init_vconsole.loop
init_vconsole.end:
  ; rax contains the virtio console pci device
  mov     r13, 0
  mov     r15, 0
  mov     r13b, [rax + 0x34]

  ; capability pointers
cap_search.loop:
  cmp     r13b, 0
  je      cap_search.end
  add     r13, rax
  ; r13 contains capability
  mov     r15b, [r13 + 3]
  mov     r9, common_cfg
  cmp     r15b, 1
  je      cap_search.store
  mov     r9, isr_cfg
  cmp     r15b, 3
  je      cap_search.store
  mov     r9, device_cfg
  cmp     r15b, 4
  jne     cap_search.cont
cap_search.store:
; sooo much just to properly load the bar
  ; get bar list
  mov     r8, 0x10
  add     r8, rax
  ; pci_cap.bar
  mov     r15, 0
  add     r15b, [r13 + 4]
  ; calc bar index
  shl     r15b, 2
  ; bar list into r8
  add     r8, r15
  ; load high bar
  mov     r15d, [r8 + 4]
  shl     r15, 32
  ; load low bar
  mov     r8, 0
  mov     r8d, [r8 + 0]
  add     r15, r8
  ; align to 16 bytes
  shr     r15, 4
  shl     r15, 4
  ; load offset into bar
  mov     r8, 0
  mov     r8d, [r13 + 8]
  add     r15, r8
  mov     [r9], r15
cap_search.cont:
  mov     r13b, [r13 + 1]
  and     r13, 0xff
  jmp     cap_search.loop
cap_search.end:
  ; mov     r8, [common_cfg]
  ; mov     r9, [isr_cfg]
  ; mov     r10, [device_cfg]

  pop     r8
  pop     r9
  pop     r13
  pop     r15

  ret
oops:
  int3

  public print_to_vconsole
print_to_vconsole:      ; string in rax
  push    r8
  push    r9
  mov     r8, [device_cfg]
  mov     r9, 0
print_to_vconsole.loop: ; string in rax
  mov     r9b, [rax]
  cmp     r9b, 0
  je      print_to_vconsole.end
  mov     [r8 + 8], r9d
  inc     rax
  jmp     print_to_vconsole.loop
print_to_vconsole.end:
  pop     r8
  pop     r9
  ret
  ; ; int3

  ; mov     dword[r8 + 8], 'H'
  ; mov     dword[r8 + 8], 'i'
  ; mov     dword[r8 + 8], 0xA
