PROJECT_NAME=soc

BASE_PATH=../..
WAIVER_FILE := waiver.vlt
SRC_DIR=$(BASE_PATH)/src
PHONY_STD_PATH=../../lib

SOC_LIBRELANE_CONFIG=soc_config.yaml
RF_LIBRELANE_CONFIG=rf_config.yaml

# core + utils
HAZARD_CORE_DIR=$(SRC_DIR)/hazard3/hdl

HAZARD_DEPS=$(HAZARD_CORE_DIR)/hazard3_core.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_cpu_1port.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/arith/hazard3_alu.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/arith/hazard3_branchcmp.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/arith/hazard3_mul_fast.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/arith/hazard3_muldiv_seq.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/arith/hazard3_onehot_encode.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/arith/hazard3_onehot_priority.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/arith/hazard3_onehot_priority_dynamic.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/arith/hazard3_priority_encode.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/arith/hazard3_shift_barrel.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_csr.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_decode.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_frontend.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_instr_decompress.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_irq_ctrl.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_pmp.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_power_ctrl.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_regfile_1w2r.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/hazard3_triggers.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/debug/cdc/hazard3_sync_1bit.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/debug/cdc/hazard3_reset_sync.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/debug/cdc/hazard3_apb_async_bridge.v
HAZARD_DEPS+=$(HAZARD_CORE_DIR)/debug/dtm/hazard3_jtag_dtm_core.v

RTL_DEPS=$(HAZARD_DEPS)
RTL_DEPS+=$(SRC_DIR)/soc.v

CONFIG_DEPS=$(SRC_DIR)/hazard3_config.vh
CONFIG_DEPS+=$(HAZARD_CORE_DIR)/$(wildcard *.vh)

PHONY_STD_LIB=$(PHONY_STD_PATH)/gf180mcu_fd_sc_phony.v

LINT_FLAGS := -Wall -Wpedantic
LINT_DEFINES = -DVERILATOR_LINT=1 -DGF180MCU=1 #-DEXTERNAL_REGFILE

LINT_INCLUDE_DIR = -y $(SRC_DIR) -y $(HAZARD_CORE_DIR) 
LINT_INCLUDE_DIR += -y $(HAZARD_CORE_DIR)/debug/cdc -y $(HAZARD_CORE_DIR)/debug/dtm
LINT_INCLUDE_DIR += -y $(PHONY_STD_PATH)

# generate merged config files
soc_config_merged.yaml soc_extern_rf_config_merged.yaml rf_config_merged.yaml: %_config_merged.yaml: %_config.yaml common_config.yaml
	cat common_config.yaml > $@
	cat $< >> $@
	
lint: $(RTL_DEPS) 
	verilator $(WAIVER_FILE) $(LINT_INCLUDE_DIR) $(LINT_DEFINES) --lint-only $(LINT_FLAGS) --no-timing $^ $(PHONY_STD_LIB) --top $(PROJECT_NAME)
.PHONY: lint

soc_librelane soc_extern_rf_librelane rf_librelane: %-librelane: %_config_merged.yaml $(RTL_DEPS) $(CONFIG_DEPS) common.sdc
	librelane $<
.PHONY: %-librelane

soc-librelane-nodrc soc_extern_rf-librelane-nodrc rf-librelane-nodrc:%-librelane-nodrc: %_config_merged.yaml $(RTL_DEPS) $(CONFIG_DEPS) common.sdc
	librelane $< --skip KLayout.DRC 
.PHONY: %-librelane-nodrc

soc_synth_explore soc_extern_rf_synth_explore rf_synth_explore: %_synth_explore: %_config_merged.yaml $(RTL_DEPS) $(CONFIG_DEPS) 
	librelane $< --flow synthesisexploration 
.PHONY:soc_synth_explore rf_synth_explore 

%-librelane-openroad: %_config_merged.yaml
	librelane $< --last-run --flow OpenInOpenROAD
.PHONY: %-librelane-openroad

%-librelane-klayout: %_config_merged.yaml      
	librelane $< --last-run --flow OpenInKLayout
.PHONY: %-librelane-klayout

clean: 
	rm -r ./runs
	rm -r ./*config_merged.yaml
.PHONY:clean

