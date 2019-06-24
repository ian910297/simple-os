bits 16 ; tell NASM this is 16 bit code
org 0x7c00 ; tell NASM to start outputting at offset 0x7c00

jmp start
; DATA
; ------------------------------------------------------------------------
bootdrive db 0
msg_hello db "Hello, World", 13, 10, 0
msg_start db 'Booting ...', 13, 10, 0
msg_reset db 'Reseting drive ...', 13, 10, 0
msg_a20 db "Enable a20 ..."
msg_kernel db "Loading Kernel ...", 13, 10, 0
msg_gdt db "Loading GDT ...", 13, 10, 0
msg_pmode db "Entering Protected Model ...", 13, 10, 0
; ------------------------------------------------------------------------

; FUNCTIONS
; ----------------------------------------------------------------------
print_char:
	mov ah, 0x0E	; teletype
	mov bh, 0x00	; Page no
	mov bl, 0x07	; text attribute: lightgrey font on black background
	int 0x10
	ret
	
print_string:
	nextc:
		mov al, [si]	; al = *si
		inc si			; si++
		cmp al, 0		; if al=0 call exit
		je exit
		call print_char
		jmp nextc
		exit: ret

error:
	hlt
	jmp error

start:
	mov ax, cs	; Update the segment registers
	mov ds, ax	; set data segment
	mov es, ax	; set extra segment
	mov ss, ax	; set stack segment
	mov [bootdrive], dl	; retrieve bootdrive id
	mov si, msg_start
	call print_string



times 510 - ($-$$) db 0 ; pad remaining 510 bytes with zeros
dw 0xaa55 ; boot signature
