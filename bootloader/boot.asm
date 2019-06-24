bits 16 ; tell NASM this is 16 bit code
org 0x7c00 ; tell NASM to start outputting at offset 0x7c00

jmp start

; DATA
; ------------------------------------------------------------------------
disk db 0x0
msg_hello db "Hello, World", 13, 10, 0
msg_start db 'Booting ...', 13, 10, 0
msg_reset db 'Reseting drive ...', 13, 10, 0
msg_a20 db "Enable a20 ...", 13, 10, 0
msg_disk db "Load disk ...", 13, 10, 0
msg_kernel db "Loading Kernel ...", 13, 10, 0
msg_gdt db "Loading GDT ...", 13, 10, 0
msg_pmode db "Entering Protected Model ...", 13, 10, 0

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

; FUNCTIONS
; ----------------------------------------------------------------------
rmode_print_char:
	mov ah, 0x0E	; teletype
	mov bh, 0x00	; Page no
	mov bl, 0x07	; text attribute: lightgrey font on black background
	int 0x10
	ret
	
rmode_print_string:
	nextc:
		mov al, [si]	; al = *si
		inc si			; si++
		cmp al, 0		; if al=0 call exit
		je exit
		call rmode_print_char
		jmp nextc
		exit: ret

error:
	hlt
	jmp error
; ----------------------------------------------------------------------

; main
; ----------------------------------------------------------------------
start:
    mov si, msg_hello ; point si register to hello label memory location
	call rmode_print_string
a20:
	mov si, msg_a20
	call rmode_print_string
	mov ax, 0x2401  ; fast a20 gate
				   	; ah=0x24 al=0x00 -> close a20
				   	; ah=0x24 al=0x01 -> open a20
	int 0x15		; system common function according to ax value
					; if bios support fast a20 gate -> CF = 0 
					; 					not support -> CF = 1
					; ax would get the a20 status
					; if a20 open -> ax = 1
					;        else -> ax = 0
	jc error       	; jump if carry (according to CF value)
	;mov ax, 0x3
	;int 0x10 ; set vga text mode 3
load_disk:
	mov si, msg_disk
	call rmode_print_string
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
	mov si, msg_gdt
	call rmode_print_string
    lgdt [gdt_pointer] ; load the gdt table
pmode:
	mov si, msg_pmode
	call rmode_print_string
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
    jmp CODE_SEG:boot ; long jump to the code segment

times 510 - ($-$$) db 0 ; pad remaining 510 bytes with zeros
dw 0xaa55 ; boot signature

copy_target:
bits 32
boot:
	cli
    hlt

times 1024 - ($-$$) db 0