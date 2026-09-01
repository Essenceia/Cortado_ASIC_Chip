# Cortado ASIC 

Second generation Ethernet focused ASIC chip featuring a 100Mbps capable cut-through, unmanaged, Ethernet switch. 

This full chip is targeting the Global Foundries 180 nm process (`gf180mcu`), using the [`gf180mcuD` PDK](https://gf180mcu-pdk.readthedocs.io/en/latest/). 

This is the default and preferred 1.94mm × 2.53mm floorplan configuration, targeting a package with 56 pads as well as the `0p5x0p5` wafer.space slot, part of wafer.space run 3.

Targeted featureset: 
- Ethernet switch:
  - 4x Full duplex Ethernet ports, 100BASE-TX (classic RJ42 cat-3 connection) 
  - Unmanaged switch 
  - Cut-though forwarding
- MACSec Ethernet Data Encryption Device (801.1ae clause 15)
	- Frame forwarding device between 2 100BASE-TX Ethernet ports
	- PSK key configuration
	- EAPol-MKA capable
- JTAG TAP:
  - custom instructions to monitor performance counters
  - boundary scan for checking PCB connections
  - partial scan chain for identifying silicon level fabrication defects

## Coffee-shop family 

This ASIC is part of a larger project to build Ethernet equipement called the [Coffee-shop project](https://github.com/Essenceia/Coffee_Shop_Project).

## Future improvements 

This is chip is part of a larger ongoing project to develop ethernet focused ASICs. 
Future improvements will be focused on working towards a more powerfull and larger version of the switch. 

Mid-term changes: 
- design custom FPGA board for accurate device emulation
- design experimental developpement board with FPGA and final chip support
- design final PCB
- Expand to 76 pad version 
- Expand to more ethernet ports 6-8
- Expand the number of routing entries
- Add cute GDS art to corners 

Longer-term changes: 
- Integrate analog ethernet PHY into the chip
- Target higher Ethernet bandwidths 

## AI Policy 

No AI was used by me in the development of this chip. 
All code and design decisions are, and will remain, entirely human made. 

## Credits

Thanks to the [Wafer.Space](https://wafer.space/) project, its contributors for making this possible.

## License 

This hardware is distributed under the **strongly** reciprocal CERN Open Hardware Licence Version 2 unless
otherwise specified.


