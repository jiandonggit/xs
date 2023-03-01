corner ?= tc

# peak or avg
power_mode = time_based

# fsdb / saif / vcd
wave_form = vcd

harden = 0 

TIME := $(shell date +%F)
TCL   = $(TARGET).tcl
LOG   = ../log/$(TARGET).log
TARGET= $@.$(PREFIX)$(TIME).$(corner).$(power_mode)

VPATH = ../tcl

PT_TOOL = ${SNPS_ROOT}/2019/pt/bin/pt_shell

cfg = $(wildcard ../tcl/*_setting.tcl)
top = $(subst _setting,,$(basename $(notdir $(cfg))))

default: madrid

all: $(top)

%: %_setting.tcl power_common.tcl
	echo "set corner $(corner)" > $(TCL)
	echo "set POWER_MODE $(power_mode)" >> $(TCL)
	echo "set WAVE_FORM $(wave_form)" >> $(TCL)
ifdef wave_file
	echo "set WAVE_FILE $(wave_file)" >> $(TCL)
endif
	echo "set HARDEN $(harden)" >> $(TCL)
	echo "set TARGET $(TARGET)" >> $(TCL)
ifdef spef
	echo "set SPEF_EN 1" >> $(TCL) 
	echo "set SPEF_FILE $(spef)" >> $(TCL)
endif
	echo "source -e -v $< " >> $(TCL)
	echo "source -e -v $(VPATH)/power_common.tcl" >> $(TCL)
	echo "quit" >> $(TCL)
	$(PT_TOOL) -file $(TCL) | tee $(LOG)

clean:
	rm -rf *.log *Log novas* *.txt *.fsdb

help:
	@echo "Uasge : make xxx, e.g. make ddr" &

