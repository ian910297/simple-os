#include "printf.h"
#include "utils.h"
#include "uart.h"

void kernel_main(void)
{
	uart_init();
	init_printf(0, putc);
	int el = get_el();
	uart_send_string("Hello, world!\r\n");
	printf("Exception level: %d \r\n", el);

	while (1) {
		uart_send(uart_recv());
	}
}
