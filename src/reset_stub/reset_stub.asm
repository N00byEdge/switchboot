org 0x1000
[bits 16]
_start:
  xor bx, bx
  mov ds, bx
  mov ss, bx

  mov eax, cr4
  or al, 0xA3
  mov cr4, eax

  mov ecx, 0xc0000080
  rdmsr
  or ax, (1 << 8)
  wrmsr

  mov eax, [saved_cr3]
  mov cr0, eax

  lgdt [gdtr]

  jmp far[saved_cs]

[bits 64]
go64:
  lidt [idtr]
  push qword [saved_rip]
  ret

times 128-($-$$) db 0

gdtr:
  dw 0x3131
  dd 0x32323232
idtr:
  dw 0x4242
  dd 0x43434343
saved_cr3: dd 0x5555
saved_rip: dq 0x6666666666666666
saved_cs: dw 0x4444
go64_addr: dw go64
