# based on  Staf Verhaegen's SRAM pdn

set macros "m_chip_core.m_sram128x8"
puts "got macros $macros"

define_pdn_grid \
    -macro \
    -instances $macros \
    -name sram_macros \
    -starts_with POWER \
    -halo "$::env(PDN_HORIZONTAL_HALO) $::env(PDN_VERTICAL_HALO)"

add_pdn_connect \
    -grid sram_macros \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macros \
    -layers "$::env(PDN_HORIZONTAL_LAYER) Metal3"
