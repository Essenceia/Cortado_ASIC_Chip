# based on  Staf Verhaegen's SRAM pdn

set sram_macro_list "m_chip_core.m_sram128x8"
puts "got macros $sram_macro_list"

define_pdn_grid \
    -macro \
    -instances $sram_macro_list \
    -name sram_macros \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macros \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macros \
    -layers "$::env(PDN_HORIZONTAL_LAYER) Metal3"
