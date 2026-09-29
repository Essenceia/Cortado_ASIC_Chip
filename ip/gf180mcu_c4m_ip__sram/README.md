# Produced by the Arrakeen SRAM Generator 

The SRAM's produced by this SRAM generator are experimental and have not been silicon proven. 

Generator repo: https://gitlab.com/Chips4Makers/c4m-pdk-gf180mcu/-/tree/dev_SRAM?ref_type=heads

Credit for the SRAM generator goes to Staf Verhaegen.


## How to run ? 

```
nix-shell 
make all
```
Define the env variable `STAM_RULES` to build SRAM using compact sram rules. 
