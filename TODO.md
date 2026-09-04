Julia's TODO list

SoC - add minimum featureset: 
- debuger over JTAG : 
	- TAP 
	- DM
	- CDC ( DM <-> DMI ) 
	- DMI
- UART 
- External memory for storing program 
- SRAM for current context 
- both volatile and none-volatile memory can be made available though (q)spi
- MACSec AMBA endpoint  

- replace hazard jtag dtm with my own implementation 
	- add dmi instr + widden ir/addr/data
