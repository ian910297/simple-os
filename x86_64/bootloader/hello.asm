bits 16    ; tell NASM this is 16 bit code
org 0x7c00 ; tell NASM to start outputting at offset 0x7c00

boot:
    mov si, hello ; point si register to hello label memory location
    mov ah, 0x0e  ; 0x0e means 'Write Character in TTY mode
.loop:
    lodsb     ; loads byte at address `ds:si` into `al`
              ; load string byte 
              ; if (df==0) al = *si++; else al=*si--
    or al, al ; is al == 0 ?
    jz halt   ; if al == 0 jump to halt
    int 0x10  ; runs BIOS interrupt 0x10 - the action that print string stored in si to screen
    jmp .loop

halt:
    cli ; clear interrupt flag
    hlt ; halt execution

hello: db "Hello, World", 13, 10, 0

times 510 - ($-$$) db 0 ; pad remaining 510 bytes with zeros
dw 0xaa55 ; magic bootloader magic - marks this 512 byte sector bootable