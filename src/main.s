format pe64 dll efi
entry efi_main

section '.reloc' fixups data discardable
section '.data' data readable writeable
memmap: times 0x4000 db 0
memmapsize dq 0
memmapkey dq 0
memmapdescsize dq 0
memmapdescver dq 0
STK dq    0
Handle dq 0
SystemTable dq 0
_hello du "auby",13,10,0
_world du "  gaming",13,10,0
_weh du   "weh",13,10,0
acpi20_table_guid:
  dd      0x8868e871
  dw      0xe4f1
  dw      0x11d3
  db      0xbc,0x22,0x00,0x80,0xc7,0x3c,0x88,0x81
acpi_xsdt: dq 0, 0 ; start, end
acpi_string: times 8 db 0
  du      13, 10, 0

section '.text' code readable executable
efi_main:
  sub     rsp, 6 * 8
  mov     [Handle], rcx
  mov     [SystemTable], rdx

  mov     rcx, [SystemTable]
  mov     rcx, [rcx + 64]       ; EFI_SYSTEM_TABLE.ConOut
  call    qword [rcx + 0]       ; SIMPLE_TEXT_OUTPUT_INTERFACE.Reset
  lea     rdx, [_hello]
  mov     rcx, [SystemTable]
  mov     rcx, [rcx + 64]       ; EFI_SYSTEM_TABLE.ConOut
  call    qword [rcx + 8]       ; SIMPLE_TEXT_OUTPUT_INTERFACE.OutputString

  ; mov     rcx, 1000000
  ; mov     rbx, [SystemTable]
  ; mov     rbx, [rbx + 96]       ; EFI_SYSTEM_TABLE.BootServices
  ; call    qword [rbx + 248]      ; EFI_BOOT_SERVICES.Stall

  lea     rdx, [_world]
  mov     rcx, [SystemTable]
  mov     rcx, [rcx + 64]       ; EFI_SYSTEM_TABLE.ConOut
  call    qword[rcx + 8]        ; SIMPLE_TEXT_OUTPUT_INTERFACE.OutputString

  mov     rbx, [SystemTable]
  mov     rax, [rbx + 104]       ; EFI_SYSTEM_TABLE.NumberOfTableEntries
  mov     rbx, [rbx + 112]       ; EFI_SYSTEM_TABLE.ConfigurationTable
find_acpi.loop:
  cmp     rax, 0
  je      oops
  mov     r9,  [rbx]
  mov     r10, [acpi20_table_guid + 0]
  cmp     r9, r10
  jne     find_acpi.cont
  mov     r9,  [rbx + 8]
  mov     r10, [acpi20_table_guid + 8]
  cmp     r9, r10
  je      find_acpi.end
find_acpi.cont:
  sub     rax, 1
  add     rbx, 24
  jmp     find_acpi.loop
find_acpi.end:
  mov     rax, [rbx + 16]
  ; acpi validation start :3
  mov     rbx, 0
  mov     bl, byte[rax + 15]
  cmp     bl, 2
  jne     oops
  mov     rax, [rax + 24]
  ; mov     ebx, [rax]
  mov     r11d, [rax]
  mov     ebx, [rax + 4]
  add     rbx, rax
  mov     rcx, 0x24
  add     rcx, rax
  mov     [acpi_xsdt + 0], rcx
  mov     [acpi_xsdt + 8], rbx


  mov     r10, acpi_string
find_mcfg.loop:
  cmp     rcx, rbx
  je      oops
  mov     rax, [rcx]
  mov     r9, [rax]
  cmp     r9d, "MCFG"
  je      find_mcfg.end

  add     rcx, 8
  jmp     find_mcfg.loop
find_mcfg.end:

  mov     qword [memmapsize], 0x4000
  lea     rcx, [memmapsize]
  lea     rdx, [memmap]
  lea     r8, [memmapkey]
  lea     r9, [memmapdescsize]
  lea     r10, [memmapdescver]
  mov     qword [STK], rsp
  push    r10
  sub     rsp, 4*8
  mov     rbx, [SystemTable]
  mov     rbx, [rbx + 96]       ; EFI_SYSTEM_TABLE.BootServices
  call    qword [rbx + 56]      ; EFI_BOOT_SERVICES.GetMemoryMap
  add     rsp, 4*8
  pop     r10
  mov     rsp, [STK]
  mov     rbx, [memmapsize]
  cmp     rax, 0
  jne     oops
  ; immediately call ExitBootServices (it will explode if anything is called between these two)
  mov     rcx, [Handle]
  mov     rdx, [memmapkey]
  mov     rbx, [SystemTable]
  mov     rbx, [rbx + 97]       ; EFI_SYSTEM_TABLE.BootServices
  call    qword [rbx + 232]     ; EFI_BOOT_SERVICES.ExitBootServices
  cmp     rax, 0
  jne     oops
  jmp     loopin

oops:
  int3
  lea     rdx, [_weh]
  mov     rcx, [SystemTable]
  mov     rcx, [rcx + 64]       ; EFI_SYSTEM_TABLE.ConOut
  call    qword[rcx + 8]        ; SIMPLE_TEXT_OUTPUT_INTERFACE.OutputString

loopin:
  jmp     loopin
