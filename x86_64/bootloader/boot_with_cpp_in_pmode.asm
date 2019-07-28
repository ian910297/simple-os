section .boot
bits 16 ; tell NASM this is 16 bit code
global boot
jmp boot

; DATA
; ------------------------------------------------------------------------
disk db 0x0

; GDT
gdt_pointer:
    dw gdt_end - gdt_start
    dd gdt_start
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

gdt_start:
    dq 0x0
gdt_code:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0
gdt_data:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0
gdt_end:
; ------------------------------------------------------------------------

; main
; ----------------------------------------------------------------------
boot:
	mov ax, 0x2401  ; fast a20 gate
				   	; ah=0x24 al=0x00 -> close a20
				   	; ah=0x24 al=0x01 -> open a20
	int 0x15		; system common function according to ax value
					; if bios support fast a20 gate -> CF = 0 
					; 					not support -> CF = 1
					; ax would get the a20 status
					; if a20 open -> ax = 1
					;        else -> ax = 0
	mov ax, 0x3
	int 0x10 ; set vga text mode 3
load_disk:
	mov [disk], dl
	mov ah, 0x2    ;read sectors
	mov al, 1      ;sectors to read
	mov ch, 0      ;cylinder idx
	mov dh, 0      ;head idx
	mov cl, 2      ;sector idx
	mov dl, [disk] ;disk idx
	mov bx, copy_target;target pointer
	int 0x13
	cli
load_gdt:
    lgdt [gdt_pointer] ; load the gdt table
pmode:
    mov eax, cr0 
    or eax, 0x1         ; set the protected mode bit on special CPU reg cr0
    mov cr0, eax
load_data:
	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
    jmp CODE_SEG:boot_in_pmode ; long jump to the code segment

times 510 - ($-$$) db 0 ; pad remaining 510 bytes with zeros
dw 0xaa55 ; boot signature

copy_target:
bits 32
msg_hello db "Hello, 512 World", 13, 10, 0
boot_in_pmode:
	mov esi, msg_hello
	mov ebx, 0xb8000
.loop:
	lodsb
	or al, al
	jz halt
	or eax, 0x0F00
	mov word [ebx], ax
	add ebx, 2
	jmp .loop
halt:
c_program:
	mov esp, kernel_stack_top
	extern kmain
	call kmain
	cli
	hlt

section .bss
align 4
kernel_stack_bottom: equ $
	resb 16384 ; 16 KB
kernel_stack_top: