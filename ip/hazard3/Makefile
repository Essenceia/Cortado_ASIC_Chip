PROJECT_NAME=soc

BASE_PATH=../..
CONF := conf
WAIVER_FILE := waiver.vlt
SRC_DIR=$(BASE_PATH)/src

LIBRELANE_CONFIG=config.yaml

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

lint: $(RTL_DEPS)
	verilator $(CONF)/$(WAIVER_FILE) -y $(SRC_DIR) -y $(HAZARD_CORE_DIR) -DVERILATOR_LINT=1 --lint-only $(LINT_FLAGS) --no-timing $^ --top $(PROJECT_NAME)
.PHONY: lint

librelane: 
	librelane $(LIBRELANE_CONFIG) 
.PHONY: librelane

synth_explore: 
	librelane $(LIBRELANE_CONFIG) --flow synthesisexploration 
.PHONY: synth_explore



