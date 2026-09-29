#!/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Based off staf's ws run 2 test chip, all credit goes to him
import os 

from textwrap import dedent

from pdkmaster.io.klayout import merge, export2db

from c4m.pdk.gf180mcu import (
    Library, gds_layers, SPSRAMFactory, DPSRAMFactory, SPSRAM5V0Factory, DPSRAM5V0Factory,
)

# getting env parameter, checking if we want to use SRAM design rules or standard rules 
SRAM_RULES=os.getenv("SRAM_RULES", False)

memlib = Library(name="gf180mcu_c4m__sram3v3")

# Generate single port SRAM only 

if SRAM_RULES:
    _fab = SPSRAMFactory(lib=memlib, sram_rules=True, name_prefix="SP6TR")
    rule_str = "using SRAM compact design rules" 
else: 
    _fab = SPSRAMFactory(lib=memlib)
    rule_str = ""

print("Generating 3.3V SRAMs "+rule_str)

sp1 = _fab.block(words=128, word_size=8, we_size=1,  cell_name="gf180mcu_c4m_ip__sram3v3_128x8")
sp2 = _fab.block(words=256, word_size=8, we_size=1,  cell_name="gf180mcu_c4m_ip__sram3v3_256x8")
sp3 = _fab.block(words=256, word_size=16, we_size=2, cell_name="gf180mcu_c4m_ip__sram3v3_256x16")

cells = (sp1, sp2, sp3)

# Merge all shapes using klayout, be sure all layouts are generated first
sp1.layout
sp2.layout
sp3.layout

merge(memlib)

# Export to klayout
kldb = export2db(
    memlib, gds_layers=gds_layers,
    add_pin_label=True,
)
kldb.write(f"gds/{memlib.name}.gds")

with open(f"lef/{memlib.name}.lef", "w") as f:
    f.write(
        dedent(
            f"""
            VERSION 5.7 ;
            NOWIREEXTENSIONATPIN ON ;
            DIVIDERCHAR "/" ;
            BUSBITCHARS "[]" ;

            """[1:]
        ) + "\n".join(
        cell.lef(header=False, input_gate_area=0.4928) for cell in cells
    ))

with open(f"vh/{memlib.name}.v", "w") as f:
    f.write("\n".join(
        cell.verilog() for cell in cells
    ))

