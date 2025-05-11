# project params
current_dir	:= $(PWD)


# INFO: change these variables accordingly to your project needs
# ==============================================================
# for VHDL / Verilog / SystemVerilog RTL files
# RTL		:= ${current_dir}/rtl/*.sv
RTL		:= ${current_dir}/rtl/*.vhd

TOP		:= counter_seven_segment_display
TARGET	:= basys3
XDC		:= ${current_dir}/constraint/${TARGET}.xdc
# ==============================================================

# Build directories
DIR_BUILD		:= ${current_dir}/build
DIR_BOARD_BUILD	:= ${DIR_BUILD}/${TARGET}

# Set board properties based on TARGET variable
ifeq ($(TARGET),arty_35)
	DEVICE := xc7a50t_test
	BITSTREAM_DEVICE := artix7
	PARTNAME := xc7a35tcsg324-1
	OFL_BOARD := arty_a7_35t
else ifeq ($(TARGET),arty_100)
	DEVICE := xc7a100t_test
	BITSTREAM_DEVICE := artix7
	PARTNAME := xc7a100tcsg324-1
	OFL_BOARD := arty_a7_100t
else ifeq ($(TARGET),nexys4ddr)
	DEVICE := xc7a100t_test
	BITSTREAM_DEVICE := artix7
	PARTNAME := xc7a100tcsg324-1
	OFL_BOARD := unsupported
else ifeq ($(TARGET),zybo)
	DEVICE := xc7z010_test
	BITSTREAM_DEVICE := zynq7
	PARTNAME := xc7z010clg400-1
	OFL_BOARD := zybo_z7_10
else ifeq ($(TARGET),nexys_video)
	DEVICE := xc7a200t_test
	BITSTREAM_DEVICE := artix7
	PARTNAME := xc7a200tsbg484-1
	OFL_BOARD := nexysVideo
else ifeq ($(TARGET),basys3)
	DEVICE := xc7a50t_test
	BITSTREAM_DEVICE := artix7
	PARTNAME := xc7a35tcpg236-1
	OFL_BOARD := $(TARGET)
else
	$(error Unsupported board type)
endif

# Determine the type of constraint being used
ifneq (${XDC},)
	XDC_CMD := -x ${XDC}
endif
ifneq (${SDC},)
	SDC_CMD := -s ${SDC}
endif
ifneq (${PCF},)
	PCF_CMD := -p ${PCF}
endif

# Determine if we should use Surelog/UHDM to read sources
ifneq (${SURELOG_CMD},)
	SURELOG_OPT := -s ${SURELOG_CMD}
endif

# GHDL runtime options
FLAGS_GHDL += -fexplicit -frelaxed-rules --syn-binding -fsynopsys -Wlibrary --std=08

# shell colors
GREEN=\033[0;32m
RED=\033[0;31m
BLUE=\033[0;34m
END=\033[0m

# ============================== Targets

vhdl_to_verilog:
	@ bash -c 'echo -e "$(GREEN) -------------------- Converting VHDL to Verilog -------------------- $(END)"'
	@ [ -d $(DIR_BOARD_BUILD) ] || mkdir -p $(DIR_BOARD_BUILD)
	@ ghdl -i $(FLAGS_GHDL) --workdir=$(DIR_BOARD_BUILD) -Pbuild ${RTL}
	@ ghdl -m $(FLAGS_GHDL) --workdir=$(DIR_BOARD_BUILD) $(TOP)
	@ ghdl synth $(FLAGS_GHDL) --workdir=$(DIR_BOARD_BUILD) -Pbuild --out=verilog $(TOP) \
	> $(DIR_BOARD_BUILD)/$(TOP).v
	@ bash -c 'echo -e "$(GREEN) --------------------------------------------------------------------- $(END)"'

synthesis_vhdl:
	@ bash -c 'echo -e "$(GREEN) ----------------------------- Synthesis ---------------------------- $(END)"'
	@ [ -d $(DIR_BOARD_BUILD) ] || mkdir -p $(DIR_BOARD_BUILD)
	make vhdl_to_verilog
	@ cd $(DIR_BOARD_BUILD) && \
		symbiflow_synth -t $(TOP) $(SURELOG_OPT) -v $(DIR_BOARD_BUILD)/$(TOP).v -d $(BITSTREAM_DEVICE) -p $(PARTNAME) $(XDC_CMD)
	@ bash -c 'echo -e "$(GREEN) --------------------------------------------------------------------- $(END)"'

synthesis_verilog:
	@ bash -c 'echo -e "$(GREEN) ----------------------------- Synthesis ---------------------------- $(END)"'
	[ -d $(DIR_BOARD_BUILD) ] || mkdir -p $(DIR_BOARD_BUILD)
	cd $(DIR_BOARD_BUILD) && \
		symbiflow_synth -t $(TOP) $(SURELOG_OPT) -v ${RTL} -d $(BITSTREAM_DEVICE) -p $(PARTNAME) $(XDC_CMD)
	@ bash -c 'echo -e "$(GREEN) --------------------------------------------------------------------- $(END)"'

pack:
	@ bash -c 'echo -e "$(GREEN) ----------------------------- Packing ------------------------------ $(END)"'
	cd $(DIR_BOARD_BUILD) && \
		symbiflow_pack -e $(TOP).eblif -d $(DEVICE) $(SDC_CMD)
	@ bash -c 'echo -e "$(GREEN) --------------------------------------------------------------------- $(END)"'

place:
	@ bash -c 'echo -e "$(GREEN) ----------------------------- Placement ---------------------------- $(END)"'
	cd $(DIR_BOARD_BUILD) && \
		symbiflow_place -e $(TOP).eblif -d $(DEVICE) $(PCF_CMD) -n $(TOP).net -P $(PARTNAME) $(SDC_CMD)
	@ bash -c 'echo -e "$(GREEN) --------------------------------------------------------------------- $(END)"'

route:
	@ bash -c 'echo -e "$(GREEN) ----------------------------- Routing ------------------------------ $(END)"'
	cd $(DIR_BOARD_BUILD) && \
		symbiflow_route -e $(TOP).eblif -d $(DEVICE) $(SDC_CMD)
	@ bash -c 'echo -e "$(GREEN) --------------------------------------------------------------------- $(END)"'

fasm:
	@ bash -c 'echo -e "$(GREEN) -------------------------------- Fasm ------------------------------- $(END)"'
	cd $(DIR_BOARD_BUILD) && \
		symbiflow_write_fasm -e $(TOP).eblif -d $(DEVICE)
	@ bash -c 'echo -e "$(GREEN) --------------------------------------------------------------------- $(END)"'

bitstream:
	@ bash -c 'echo -e "$(GREEN) ------------------------ Bitstream Generation ----------------------- $(END)"'
	cd $(DIR_BOARD_BUILD) && \
		symbiflow_write_bitstream -d $(BITSTREAM_DEVICE) -f $(TOP).fasm -p $(PARTNAME) -b $(TOP).bit
	@ bash -c 'echo -e "$(GREEN) --------------------------------------------------------------------- $(END)"'

upload:
	@ bash -c 'echo -e "$(GREEN) -------------------------- Bitstream Upload ------------------------- $(END)"'
	if [ $(TARGET)='unsupported' ]; then \
		echo "The commands needed to download the bitstreams to the board type specified are not currently supported by the F4PGA makefiles. \
    Please see documentation for more information."; \
	fi
	openFPGALoader -b ${OFL_BOARD} $(DIR_BOARD_BUILD)/$(TOP).bit
	@ bash -c 'echo -e "$(GREEN) --------------------------------------------------------------------- $(END)"'

implementation:
	@ bash -c 'echo -e "$(GREEN) -------------------------- Implementation --------------------------- $(END)"'
	make pack place route fasm
	@ bash -c 'echo -e "$(GREEN) --------------------------------------------------------------------- $(END)"'

all:
	make synthesis_vhdl implementation bitstream

clean:
	@ rm -rf ${DIR_BUILD}
