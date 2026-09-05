set TCK_MHZ 1
set TCK_PERIOD [expr 1000.0/ $TCK_MHZ]
set tck_name tck

# pins
set tap_input_ports [get_ports {tdi_i tms_i trst_n}]
set tap_output_ports [get_ports {tdo_o}]

# jtag clk
create_clock [get_pins -hierarchical -regexp {.*m_clkroot_tck.magic_clkroot_anchor_u/Z}] \
	-name $tck_name \
	-period $TCK_PERIOD

# pins 
puts "\[INFO\] Setting IO delay $tck_name"
set input_delay_value [expr $TCK_PERIOD * $::env(IO_DELAY_CONSTRAINT) / 100]

set_input_delay -min 0 -clock $tck_name $tap_input_ports
set_input_delay -max $input_delay_value -clock $tck_name $tap_input_ports

# outputs are bidirectional 
set output_delay_value [expr $TCK_PERIOD * $::env(IO_DELAY_CONSTRAINT) / 100]

#set_input_delay -min 0 -clock $tck_name $tap_output_ports
#set_input_delay -max $input_delay_value -clock $tck_name $tap_output_ports
set_output_delay $output_delay_value -clock $tck_name $tap_output_ports

#clk constraints

puts "\[INFO] Setting clock uncertainty for $tck_name to $::env(CLOCK_UNCERTAINTY_CONSTRAINT)"
set_clock_uncertainty $::env(CLOCK_UNCERTAINTY_CONSTRAINT) $tck_name

puts "\[INFO] Setting clock transition for $tck_name to: $::env(CLOCK_TRANSITION_CONSTRAINT)"
set_clock_transition $::env(CLOCK_TRANSITION_CONSTRAINT) $tck_name


