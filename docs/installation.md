# Installation of F4PGA toolchain

<!-- [reference](https://f4pga-examples.readthedocs.io/en/latest/getting.html#toolchain-installation) -->

- Create `Tools` directory if it doesnt exist.
```bash
[ -d ~/Tools ] || mkdir -p ~/Tools
cd ~/Tools
```

- Install dependencies.
```bash
Debian (Ubuntu)
sudo apt install -y findutils git wget which xz-utils

Fedora
sudo dnf install -y findutils git wget which xz
```

- Clone the examples repo.
```bash
git clone https://github.com/chipsalliance/f4pga-examples ~/f4pga_examples
cd ~/f4pga_examples
```

- Download [miniconda](https://www.anaconda.com/docs/getting-started/miniconda/install) installer script.
```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O conda_installer.sh
```

- Choosing installation dir and FPGA target family
```bash
export CONDA_INSTALL_DIR=$HOME/Tools/miniconda
export FPGA_FAM=xc7

# print and check if variables initialized properly
echo "CONDA_INSTALL_DIR:    $CONDA_INSTALL_DIR"
echo "FPGA_FAM:             $FPGA_FAM"
```

- Install miniconda
```bash
bash ./conda_installer.sh -u -p $CONDA_INSTALL_DIR

# check conda version
conda --version
```

> ℹ️ **INFO:** Terminal quits at this point after miniconda installation is complete. Start a new
> session. You may need to export the enviroment variables again.

> ℹ️ **OPTIONAL:**
> You can source the miniconda shell in two ways.
>
> Either add this path `export PATH="$CONDA_INSTALL_DIR/bin/:$PATH"` in your `.bashrc` or `.zshrc`.
>
> Or run this command `source ~/Tools/miniconda/etc/profile.d/conda.sh` everytime you need to run
> miniconda.


- Prevent base conda environment from automatically loading at startup
```bash
conda config --set auto_activate_base false
conda config --add channels defaults
ls -a ~ | grep ".conda"
cat ~/.condarc
```

- Source miniconda and create a miniconda environment
```bash
source "$CONDA_INSTALL_DIR/etc/profile.d/conda.sh";

# check for existing conda envs
conda env list

# set conda env name
export CONDA_ENV_NAME="f4pga_xc7"
echo "CONDA_ENV_NAME:       $CONDA_ENV_NAME"

# create conda env
conda env create -n $CONDA_ENV_NAME -f ~/Tools/f4pga_examples/xc7/environment.yml

conda env list
conda activate $CONDA_ENV_NAME
conda list -v
pip list -v
```

- Download architecture definitions
```bash
export F4PGA_PACKAGES='install-xc7 xc7a50t_test xc7a100t_test xc7a200t_test xc7z010_test'
echo $F4PGA_PACKAGES
```

- Choosing install directory and family for architecture definitions
```bash
# install dir
export F4PGA_INSTALL_DIR=/usr/local/

# select target family FPGAs
export FPGA_FAM=xc7

# print and check outputs
echo "CONDA_INSTALL_DIR:    $CONDA_INSTALL_DIR"
echo "FPGA_FAM:             $FPGA_FAM"
echo "install dir:          $F4PGA_INSTALL_DIR$FPGA_FAM"
```

- Create installation directory.
```bash
# create dir
sudo mkdir -p $F4PGA_INSTALL_DIR/$FPGA_FAM
cd $F4PGA_INSTALL_DIR/$FPGA_FAM
```

- Download and install architecture definitions.
```bash
# set the following vars
F4PGA_TIMESTAMP='20220920-124259'
F4PGA_HASH='007d1c1'

echo "F4PGA_TIMESTAMP:  $F4PGA_TIMESTAMP"
echo "F4PGA_HASH:       $F4PGA_HASH"

# definition for install-xc7
F4PGA_PACKAGE='install-xc7'
sudo wget https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/${F4PGA_TIMESTAMP}/symbiflow-arch-defs-${F4PGA_PACKAGE}-${F4PGA_HASH}.tar.xz
sudo tar -xJf symbiflow-arch-defs-${F4PGA_PACKAGE}-${F4PGA_HASH}.tar.xz -C $F4PGA_INSTALL_DIR$FPGA_FAM

# definition for xc7a50t_test
F4PGA_PACKAGE='xc7a50t_test'
sudo wget https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/${F4PGA_TIMESTAMP}/symbiflow-arch-defs-${F4PGA_PACKAGE}-${F4PGA_HASH}.tar.xz
sudo tar -xJf symbiflow-arch-defs-${F4PGA_PACKAGE}-${F4PGA_HASH}.tar.xz -C $F4PGA_INSTALL_DIR/$FPGA_FAM

# definition for xc7a100t_test
F4PGA_PACKAGE='xc7a100t_test'
sudo wget https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/${F4PGA_TIMESTAMP}/symbiflow-arch-defs-${F4PGA_PACKAGE}-${F4PGA_HASH}.tar.xz
sudo tar -xJf symbiflow-arch-defs-${F4PGA_PACKAGE}-${F4PGA_HASH}.tar.xz -C $F4PGA_INSTALL_DIR/$FPGA_FAM

# definition for xc7a100t_test
F4PGA_PACKAGE='xc7a100t_test'
sudo wget https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/${F4PGA_TIMESTAMP}/symbiflow-arch-defs-${F4PGA_PACKAGE}-${F4PGA_HASH}.tar.xz
sudo tar -xJf symbiflow-arch-defs-${F4PGA_PACKAGE}-${F4PGA_HASH}.tar.xz -C $F4PGA_INSTALL_DIR/$FPGA_FAM

# definition for xc7a200t_test
F4PGA_PACKAGE='xc7a200t_test'
sudo wget https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/${F4PGA_TIMESTAMP}/symbiflow-arch-defs-${F4PGA_PACKAGE}-${F4PGA_HASH}.tar.xz
sudo tar -xJf symbiflow-arch-defs-${F4PGA_PACKAGE}-${F4PGA_HASH}.tar.xz -C $F4PGA_INSTALL_DIR/$FPGA_FAM

# definition for xc7z010_test
F4PGA_PACKAGE='xc7z010_test'
sudo wget https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/${F4PGA_TIMESTAMP}/symbiflow-arch-defs-${F4PGA_PACKAGE}-${F4PGA_HASH}.tar.xz
sudo tar -xJf symbiflow-arch-defs-${F4PGA_PACKAGE}-${F4PGA_HASH}.tar.xz -C $F4PGA_INSTALL_DIR/$FPGA_FAM
```
