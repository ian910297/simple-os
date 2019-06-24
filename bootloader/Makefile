ASMFILES=$(wildcard *.asm)
BINS=$(ASMFILES:%.asm=%.bin)

QUIET=@
ECHO=echo

all: $(BINS)

%.bin: %.asm
	$(QUIET)$(ECHO) "Compiling" $<
	$(QUIET) nasm -f bin -o $@ $<

bochs_hello:
	bochs -qf hello.bochsrc

bochs_boot:
	bochs -qf boot.bochsrc

clear:
	$(QUIET)$(ECHO) "Removing" $(BINS) "*.txt"
	$(QUIET) rm $(BINS) *.txt


