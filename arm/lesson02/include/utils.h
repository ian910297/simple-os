#ifndef	_BOOT_H
#define	_BOOT_H

extern void delay(unsigned long);
extern void put32(unsigned long, unsigned int);
extern unsigned int get32(unsigned long);
extern int get_el(void);
extern void memzero(unsigned long src, unsigned long n);

#endif  /*_BOOT_H */