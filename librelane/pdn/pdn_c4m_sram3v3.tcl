# based on  Staf Verhaegen's SRAM pdn

set sram_macro_list "\
m_chip_core.m_sram_test.m_sram128x8 \
m_chip_core.m_sram_test.m_sram256x8 \
m_chip_core.m_sram_test.m_sram256x16_0 \
m_chip_core.m_sram_test.m_sram256x16_1"
puts "got macros $sram_macro_list"

define_pdn_grid \
    -macro \
    -instances $sram_macro_list \
    -name sram_macros \
    -starts_with POWER \
    -halo "1.0 1.0"

add_pdn_connect \
    -grid sram_macros \
    -layers "$::env(PDN_VERTICAL_LAYER) $::env(PDN_HORIZONTAL_LAYER)"

add_pdn_connect \
    -grid sram_macros \
    -layers "$::env(PDN_HORIZONTAL_LAYER) Metal3"
