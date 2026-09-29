# Required nix-shell to be sourced before hand 

# generate srams gds/lef/vh
all:
	uv run generator/gen_views.py 
.PHONY: all 

clean: 
	rm -f ./gds/*.gds
	rm -f ./lef/*.lef
	rm -f ./vh/*.v
.PHONY:clean
