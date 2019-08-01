#include "uart.h"

static unsigned int processor = 0;	// global variable to sinc the processors

void kernel_main()
{
	const unsigned int id = proc_id();

	// Only CPU #0 do the UART initialization
	if(id == 0) {
		uart_init();
	}

	// Wait for previous CPU to finish printing
	while(id != processor) { }

	uart_send_string("Hello, from processor ");
	uart_send(id + '0');
	uart_send_string("\r\n");
	
	// Tells the next CPU to go
	++processor;

    // Only CPU #0 do the echo
	if (id == 0) {
		// Wait for everyone else to finish
		while(processor != 4) { }

		while (1) {
			uart_send(uart_recv());
		}
	}
}
