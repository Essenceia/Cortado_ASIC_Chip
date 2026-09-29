LIB_NAME=gf180mcu_c4m__sram3v3

# Required nix-shell to be sourced before hand 

# generate srams gds/lef/vh
all:
	uv run generator/gen_views.py 
.PHONY: all 

klayout: gds/${LIB_NAME}.gds
	klayout $^
.PHONY: klayout
 
clean: 
	rm -f ./gds/*.gds
	rm -f ./lef/*.lef
	rm -f ./vh/*.v
.PHONY:clean
