
PARALLEL=0

LV=0

ifneq ($(LV),0)
	LV_SUFFIX = _lv
endif

TARGETS = max_power_noi2c

SIM_DIR = ${DIGITAL}/verification/ST/SOC_MODULE/cpu_sys/vcs_gate

WORK_DIR = work/$@${LV_SUFFIX}
TEST_NAME = max_power_95p_noi2c_dc
FSDB_FILE = ${TEST_NAME}.fsdb
FSDB_TIME = $(shell grep '^\s*${FSDB_FILE}\b' import/fsdb.time | sed 's/${FSDB_FILE}\b\s*//g')
LOG_FILE = work/$@${LV_SUFFIX}.log

GEN_FLAG = -work ${WORK_DIR}
GEN_FLAG += -file import/filelist.f
GEN_FLAG += -lib import/lib${LV_SUFFIX}.f
GEN_FLAG += -fsdb import/${FSDB_FILE} ${FSDB_TIME}
#GEN_FLAG += -spef import/route_opt.spef.ctyp_25.gz
GEN_FLAG += -blackbox import/blackbox.tcl
GEN_FLAG += -voerwrite

$(TARGETS) : _FORCE
	mkdir -p $(WORK_DIR) && ln -sfT ${PWD}/import ${WORK_DIR}/import 
	perl import/gen_sg_pa_netlist.pl ${GEN_FLAG} > ${LOG_FILE}
ifneq (${PARALLEL},0)
	make -C ${WORK_DIR} 97 23 | tee -a ${LOG_FILE} >& /dev/null &
else
	make -C ${WORK_DIR} 97 23 | tee -a ${LOG_FILE} 
endif

all: $(TARGETS)

fsdb:
	sh import/import_fsdb.sh ${SIM_DIR} ${LV} $(foreach case, $(TARGETS),st_chip_power_est_$(case)_test)

_FORCE :
