# FOSS Flow For FPGA (F4PGA) Setup

## Introduction
This repo explains how to get started with F4PGA toolchain and build example designs. This repo
focuses on setting up the Artix-7 family from Xilinx.

## Installing the toolchain

The [installation
readme](https://github.com/usman1515/f4pga_fpga_template/blob/main/docs/installation.md) mentions in
details on how to setup and install the tools. F4PGA requires
[miniconda](https://www.anaconda.com/docs/getting-started/miniconda/main) as a prequisite.

## Using F4PGA

### Project directory stucture

The repository provides a simple counter example consisting of `rtl` and `constraints`. Use the
hierarchy mentioned below when creating your own projects.
```bash
.
├── build
│   └── <build files, logs, reports, bitstreams generated>
├── constraint
│   └── <files>.xdc
├── rtl
│   └── <design_files>.sv
├── tb
│   └── <testbench_files>.sv
└── Makefile
```

A `Makefile` is included to streamline the FPGA development workflow from synthesis to
bitstream generation and upload for the Basys3 board. Using this Makefile, you can automate each
step of the process by simply running make commands in your terminal.

Make sure to source miniconda and actiavte the conda environemnt that you created using installation
readme.

```bash
# source miniconda
source ~/Tools/miniconda/etc/profile.d/conda.sh

# activate conda env
conda activate f4pga_xc7
```

### How to run:
- Available `TARGET` are `basys3`, `nexys4ddr`

```
# Synthesis:
make synthesis TARGET="basys3"

# Place and Route:
make implementation TARGET="basys3"

# Bitstream generation:
make bitstream TARGET="basys3"

# Bitstream upload:
make upload TARGET="basys3"
```

