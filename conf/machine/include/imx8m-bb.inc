#@TYPE: Machine include
#@NAME: Prodrive Technologies i.MX8Mx building block
#@SOC: i.MX8M
#@DESCRIPTION: Machine configuration include for the Prodrive Technologies i.MX8M building block
#@MAINTAINER: Max van den Biggelaar <max.van.den.biggelaar@prodrive-technologies.com>

# This include can be used by projects implementing the i.MX8MM building block into a new design.
# The project team is responsible for providing a machine configuration to include this file.
# By default, the machine configuration of the i.MX8M Mini 4GiB LPDDR4 is used as it the high-runner.

MACHINEOVERRIDES =. "imx-boot-container:mx8:mx8m:"

require conf/machine/include/imx-base.inc
require conf/machine/include/arm/armv8a/tune-cortexa53.inc

SERIAL_CONSOLES = "115200;ttymxc3"

KERNEL_BRANCH ??= "release/ptic-imx-5.15.32-2.0.0_R01_y"
KERNEL_COMMIT_HASH ??= "34f4567cf8d034ec323ec53c406f67ee493e8c24"

# TODO: Add multiple dtb's in FIT image
KERNEL_DEVICETREE:mx8mm-nxp-bsp ?= "prodrive/ptic/imx8mm-ptic-base.dtb"
KERNEL_DEVICETREE:mx8mn-nxp-bsp ?= "prodrive/ptic/imx8mn-ptic-base.dtb"
KERNEL_DEVICETREE:mx8mp-nxp-bsp ?= "prodrive/ptic/imx8mp-ptic-base.dtb"
KERNEL_DEFCONFIG  ?= "ptic/imx8m_defconfig"

# DDR Base address macro for csf-offsets.txt
DDR_BASE_ADDRESS               ??= "0x40000000"
DDR_BASE_ADDRESS:mx8mn-nxp-bsp ?= "0x60000000"

# FIT image U-Boot entry points i.MX8M Mini and Plus controllers
UBOOT_KERNEL_DTB_LOADADDRESS ??= "0x49600000"
UBOOT_KERNEL_LOADADDRESS     ??= "0x49800000"
UBOOT_KERNEL_ENTRYPOINT      ??= "0x49800000"
UBOOT_KERNEL_RD_LOADADDRESS  ??= "0x4B480000"

# FIT image U-Boot entry points i.MX8M Nano
UBOOT_KERNEL_DTB_LOADADDRESS:mx8mn-nxp-bsp  ?= "0x69600000"
UBOOT_KERNEL_LOADADDRESS:mx8mn-nxp-bsp      ?= "0x69800000"
UBOOT_KERNEL_ENTRYPOINT:mx8mn-nxp-bsp       ?= "0x69800000"
UBOOT_KERNEL_RD_LOADADDRESS:mx8mn-nxp-bsp   ?= "0x6B480000"

# U-Boot environment script names
UBOOT_SCRIPT                ??= "boot.cmd-imx8m-ptic-base"
UBOOT_SCRIPT:mx8mn-nxp-bsp  ?= "boot.cmd-imx8mn-ptic-base"

# U-Boot fw-utils configuration names
UBOOT_FW_UTILS      ?= "boot_env-imx8m-ptic-base.config"
UBOOT_FACTORY_UTILS ?= "factory_env-imx8m-ptic-base.config"
UBOOT_CUSTOMER_UTILS ?= "customer_env-imx8m-ptic-base.config"
