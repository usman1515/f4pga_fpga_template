# project params
current_dir	:= $(PWD)


# INFO: change these variables accordingly to your project needs
# ==============================================================
SOURCES		:= ${current_dir}/rtl/*.v
TOP			:= counter
TARGET		:= basys3
XDC			:= ${current_dir}/constraint/${TARGET}.xdc
# ==============================================================

# Build directories
BUILDDIR		:= ${current_dir}/build
BOARD_BUILDDIR	:= ${BUILDDIR}/${TARGET}

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

FLAGS_GHDL += -fexplicit -frelaxed-rules --syn-binding -fsynopsys -Wlibrary --std=08

# ============================== Targets

vhdl_to_verilog:
	@ echo ---------------------- Converting VHDL RTL to Verilog ---------------------
	[ -d $(BOARD_BUILDDIR) ] || mkdir -p $(BOARD_BUILDDIR)
	ghdl -i $(FLAGS_GHDL) --workdir=$(BOARD_BUILDDIR) -Pbuild ${SOURCES}
	ghdl -i $(FLAGS_GHDL) --workdir=$(BOARD_BUILDDIR) -Pbuild ./rtl/*.vhd
	ghdl -m $(FLAGS_GHDL) --workdir=$(BOARD_BUILDDIR) $(TOP)
	ghdl synth $(FLAGS_GHDL) --workdir=$(BOARD_BUILDDIR) -Pbuild --out=verilog $(TOP) > $(BOARD_BUILDDIR)/$(TOP).v
	@ echo ------------------------------- DONE -----------------------------
	@ echo " "

synthesis_vhdl:
	[ -d $(BOARD_BUILDDIR) ] || mkdir -p $(BOARD_BUILDDIR)
	make vhdl_to_verilog
	cd ${BOARD_BUILDDIR} && \
		symbiflow_synth -t ${TOP} ${SURELOG_OPT} -v ${BOARD_BUILDDIR}/${TOP}.v -d ${BITSTREAM_DEVICE} -p ${PARTNAME} ${XDC_CMD}

synthesis_verilog:
	[ -d $(BOARD_BUILDDIR) ] || mkdir -p $(BOARD_BUILDDIR)
	cd ${BOARD_BUILDDIR} && \
		symbiflow_synth -t ${TOP} ${SURELOG_OPT} -v ${SOURCES} -d ${BITSTREAM_DEVICE} -p ${PARTNAME} ${XDC_CMD}

pack:
	cd ${BOARD_BUILDDIR} && \
		symbiflow_pack -e ${TOP}.eblif -d ${DEVICE} ${SDC_CMD}

place:
	cd ${BOARD_BUILDDIR} && \
		symbiflow_place -e ${TOP}.eblif -d ${DEVICE} ${PCF_CMD} -n ${TOP}.net -P ${PARTNAME} ${SDC_CMD}

route:
	cd ${BOARD_BUILDDIR} && \
		symbiflow_route -e ${TOP}.eblif -d ${DEVICE} ${SDC_CMD}

fasm:
	cd ${BOARD_BUILDDIR} && \
		symbiflow_write_fasm -e ${TOP}.eblif -d ${DEVICE}

bitstream:
	cd ${BOARD_BUILDDIR} && \
		symbiflow_write_bitstream -d ${BITSTREAM_DEVICE} -f ${TOP}.fasm -p ${PARTNAME} -b ${TOP}.bit

upload:
	if [ $(TARGET)='unsupported' ]; then \
		echo "The commands needed to download the bitstreams to the board type specified are not currently supported by the F4PGA makefiles. \
    Please see documentation for more information."; \
	fi
	openFPGALoader -b ${OFL_BOARD} ${BOARD_BUILDDIR}/${TOP}.bit

implementation:
	make pack place route fasm

all:
	make synthesis_vhdl implementation bitstream

clean:
	@ rm -rf ${BUILDDIR}
