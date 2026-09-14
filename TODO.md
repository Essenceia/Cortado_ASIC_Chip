Julia's TODO list

- dropping riscv idea
- add cpu handoff over pio to the rp2040 core

- CPU handoff 
	- make asic as an SPI slave for configuration from the CPU
		- configure S-PPIO tag
			- make inclusion of S-PRIO tag optional
			- set PTP  
		- read performance counters: 
			- pkts: seen, dropped, forwarded to cpu, formwarded over network 
	- custom parallel buses for packet forwarding
		- ASIC -> CPU: 
			- 2b data
			- early valid
			- valid
		- CPU -> ASIC: 
			- clk (also used for ASIC -> CPU direction)
			- 2b data
			- valid (used as request) 
			- accept (ASIC -> CPU)  


- Identify structure of ethtype offload filter: read up about how device adversises there MAC on the network, what do I need for MACSec ? 
