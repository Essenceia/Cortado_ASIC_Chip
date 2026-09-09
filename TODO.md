Julia's TODO list

SoC - add minimum featureset: 
- debuger over JTAG : 
	- TAP 
	- DM
	- CDC ( DM <-> DMI ) 
	- DMI
- Timer (required) 
- UART 
- Memory 
	- External memory for storing program 
	- SRAM for current context 
	- both volatile and none-volatile memory can be made available though (q)spi
- MACSec AMBA?/APB? endpoint  

- ~replace hazard jtag dtm with my own implementation~ change of plan, reuse tap and expose status regs over sysbus
	- ~add dmi instr + widden ir/addr/data~
	- add support for boundary scan (if used)

- add APB endpoing
