# 変数定義
FC          = gfortran
FFLAGS      = -O3 -Wall -std=f2008 -J $(MOD_DIR)

BIN_DIR     = ../../bin
MOD_DIR     = tmp

COMMON_SRC  = parameters.f90 initial_condition.f90 boundary_condition.f90 io_field.f90
SRC1        = $(COMMON_SRC) solver_1d.f90 main_1d.f90
SRC2        = $(COMMON_SRC) solver_2d.f90 main_2d.f90

TARGETS     = $(BIN_DIR)/heat_1d $(BIN_DIR)/heat_2d

#====================================================
# ターゲット
#====================================================

# デフォルトターゲット (make と実行するとこれが実行される)
.PHONY: all heat_1d heat_2d clean

all: $(TARGETS)

heat_1d: $(BIN_DIR)/heat_1d

heat_2d: $(BIN_DIR)/heat_2d

$(BIN_DIR)/heat_1d: $(SRC1)
	mkdir -p $(BIN_DIR) $(MOD_DIR)
	$(FC) $(FFLAGS) $^ -o $@
	@echo "--- heat_1d build complete ---"

$(BIN_DIR)/heat_2d: $(SRC2)
	mkdir -p $(BIN_DIR) $(MOD_DIR)
	$(FC) $(FFLAGS) $^ -o $@
	@echo "--- heat_2d build complete ---"

clean:
	rm -rf $(BIN_DIR)/heat_1d $(BIN_DIR)/heat_2d $(MOD_DIR)/*
