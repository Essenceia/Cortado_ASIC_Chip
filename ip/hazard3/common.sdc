
# Credit: some code and comments borrowed from RISCBoy-180, ofcourse I stole the comment
# what did you expect ? 
source $::env(SCRIPTS_DIR)/base.sdc

set TCK_MHZ 1
set TCK_PERIOD [expr 1000.0/ $TCK_MHZ]
set tck_name tck


# TODO: do we want to increase max fanout ? max is currently 10 
# set_max_fanout 16 [current_design] 

# creating clocks 
# sourcing base.sdc, will create main clk
set clk_name [llength $::env(CLOCK_PORT)]
set CLK_PERIOD $::env(CLOCK_PERIOD) 

# jtag clk
create_clock [get_pins *m_clkroot_tck.magic_clkroot_anchor_u/Z] \
	-name $tck_name \
	-period $TCK_PERIOD

# CDC 
proc cdc_maxdelay {clk_from clk_to period_to} {
    # Allow two cycles of propagation; really this is putting an upper bound on the skew
    set_max_delay [expr 2.0 * $period_to] -from [get_clocks $clk_from] -to [get_clocks $clk_to]
    # OpenROAD doesn't support set_max_delay -datapath_only!
    # Instead, manually disable hold checks between unrelated clocks:
    set_false_path -hold -from [get_clocks $clk_from] -to [get_clocks $clk_to]
}

# All paths between clk_sys and DCK should be in the APB CDC, or reset
# controls which go into synchronisers in the destination domain. MCP of 2 is
# sufficient.
cdc_maxdelay $tck_name $clk_name $CLK_PERIOD
cdc_maxdelay $clk_name $tck_name $TCK_PERIOD

# Apply RTL-inserted false path constraints (setup/hold only, still constrain slew)
set_false_path -setup -hold -through [get_pins *.magic_falsepath_anchor_u/Z] 

# SDFF 
# The Machine Spirit is angry. Brother, get the holy oils

puts "\[SCANMAP\] Adding holly waivers to the heretical pseudo-DFFE scan flops:"
set scan_flops [get_cells -hier -filter "ref_name =~ gf180mcu_fd_sc_mcu*t5v0__sdffq_*"]
foreach flop $scan_flops {
    set flop_name [sta::get_full_name $flop]
    set q [sta::get_full_name [get_nets -of_object [get_pins ${flop_name}/Q]]]
    set d [sta::get_full_name [get_nets -of_object [get_pins ${flop_name}/D]]]
    set si [sta::get_full_name [get_nets -of_object [get_pins ${flop_name}/SI]]]
    if {[string equal $q $d]} {
        puts "\[DEBUG\] Disabling hold checks -> D for pseudo-DFFE $flop_name (D = Q = ${q})"
        set_false_path -hold -to [get_pins ${flop_name}/D]
    } elseif {[string equal $q $si]} {
        puts "\[DEBUG\] Disabling hold checks -> SI for pseudo-DFFE $flop_name (SI = Q = ${q})"
        set_false_path -hold -to [get_pins ${flop_name}/SI]
    } else {
        puts "\[DEBUG\] Skipping scan flop ${flop_name}: D = ${d} SI = ${si} Q = ${q}"
    }
}

puts "\[SCANMAP\] Finished burning of the infidels" 


# Propage clock
if { [info exists ::env(OPENLANE_SDC_IDEAL_CLOCKS)] && $::env(OPENLANE_SDC_IDEAL_CLOCKS) } {
    unset_propagated_clock [all_clocks]
} else {
    set_propagated_clock [all_clocks]
}
