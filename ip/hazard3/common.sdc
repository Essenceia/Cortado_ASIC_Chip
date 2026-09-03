source $::env(SCRIPTS_DIR)/base.sdc

# set_max_fanout 16 [current_design] 
 
# code and comment stolled from RISCBoy-180, ofcourse I stole the comment, 
# what did you expect ? 

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
