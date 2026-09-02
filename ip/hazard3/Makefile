PROJECT_NAME=soc

BASE_PATH=../..
WAIVER_FILE := waiver.vlt
SRC_DIR=$(BASE_PATH)/src

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

RTL_DEPS=$(HAZARD_DEPS)
RTL_DEPS+=$(SRC_DIR)/soc.v

#LINT_FLAGS := -Wall -Wpedantic -Ilib

LINT_FLAGS := -Wpedantic

# generate merged config files
%_merged.yaml: %.yaml common_config.yaml
	cat common_config.yaml > $@
	cat $< >> $@
	
lint: $(RTL_DEPS)
	verilator $(WAIVER_FILE) -y $(SRC_DIR) -y $(HAZARD_CORE_DIR) -DVERILATOR_LINT=1 --lint-only $(LINT_FLAGS) --no-timing $^ --top $(PROJECT_NAME)
.PHONY: lint

soc-librelane: soc_config_merged.yaml
	librelane $<
.PHONY: soc-librelane

rf-librelane: rf_config_merged.yaml
	librelane $< 
.PHONY: rf-librelane

soc_synth_explore: 
	librelane $(SOC_LIBRELANE_CONFIG) --flow synthesisexploration 
.PHONY: synth_explore

clean: 
	rm -r ./runs
	rm -r ./*config_merged.yaml
.PHONY:clean

