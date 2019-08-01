// AArch64 mode
#include "mm.h"

.data
barrier: .byte 0
         .align 2

// To keep this in the first portion of the binary.
.section ".text.boot"
 
// Make _start global.
.globl _start

// Entry point for the kernel. Registers are not defined as in AArch32.
_start:
    // read cpu id, stop slave cores
    mrs     x1, mpidr_el1
    and     x1, x1, #3
    cbz     x1, 2f
    b wait
    // cpu id > 0, wait
2:  // cpu id == 0
 
    // set stack before our code
    ldr     x1, =_start
    mov     sp, x1
 
    // clear bss
    ldr     x1, =__bss_start
    ldr     w2, =__bss_size
3:  cbz     w2, 4f
    str     xzr, [x1], #8
    sub     w2, w2, #1
    cbnz    w2, 3b
    // Tell other CPU that BSS is ready
4:	mov w0, #1
	ldr x1, =barrier
	strb w0, [x1]
	b 5f
wait:
	// Wait for BSS to bo initialized
	ldr x1, =barrier
	ldrb w0, [x1]
	cmp w0, #1
	beq 5f
	b wait

proc_hang: 
	b 	proc_hang

	// Use the CPU ID to determine the stack location: 
	// CPU #0: sp = 1 * #LOW_MEMORY, CPU #1: sp = 2 * #LOW_MEMORY, etc
5:	mov	x0, #LOW_MEMORY
	mrs x1, mpidr_el1
	and x1, x1, #0xFF
	add x1, x1, #1
	mul x0, x0, x1
	mov sp, x0
    bl kernel_main
    // for failsafe, halt this core too
    b proc_hang