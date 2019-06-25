ASM_FILES=$(wildcard *.asm)
EXCEPT_FILES=$(wildcard boot_with_cpp*.asm)
SRC_FILES=$(filter-out $(EXCEPT_FILES), $(ASM_FILES))
BIN_FILES=$(SRC_FILES:%.asm=%.bin)

QUIET=@
ECHO=echo

all: clear
.PHONY: clear

basic: $(SRC_FILES)
	@for file in $(SRC_FILES); do\
		echo Compiling $$file into $${file%asm}bin;\
		nasm -f bin -o $${file%asm}bin $$file;\
		done


kernel_32:
	nasm -f elf32 -o boot_with_cpp.o boot_with_cpp_in_pmode.asm
	gcc -m32 kernel.c boot_with_cpp.o -o kernel.bin -ffreestanding -std=c11 -mno-red-zone -fno-exceptions -nostdlib -Wall -Wextra -Werror -T linker.ld

kernel_64:
	nasm -f elf64 -o boot_with_cpp.o boot_with_cpp_in_lmode.asm
	gcc kernel.c boot_with_cpp.o -o kernel.bin -ffreestanding -std=c11 -mno-red-zone -fno-exceptions -nostdlib -Wall -Wextra -Werror -T linker.ld

bochs_hello:
	bochs -qf hello.bochsrc

bochs_boot:
	bochs -qf boot.bochsrc

bochs_kernel:
	bochs -qf kernel.bochsrc

clear:
	$(QUIET)$(ECHO) Removing *.bin *.txt *.o
	$(QUIET) rm -f *.bin *.txt *.o


