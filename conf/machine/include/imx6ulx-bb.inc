#@TYPE: Machine include
#@NAME: Prodrive Technologies i.MX6ULL building block
#@SOC: i.MX6ULL
#@DESCRIPTION: Machine configuration include for the Prodrive Technologies i.MX6 building block
#@MAINTAINER: Max van den Biggelaar <max.van.den.biggelaar@prodrive-technologies.com>

# This include can be used by projects implementing the i.MX6ULL building block into a new design.
# The project team is responsible for providing a machine configuration to include this file.
# By default, the machine configuration of the i.MX6ULL 256MiB DDR3 is used as it is the high-runner.

# This machine configuration is based on the imx6ullevk.conf under
# \meta-freescale\conf\machine\imx6ullevk.conf

MACHINEOVERRIDES =. "mx6:mx6ul:mx6ull:"

include conf/machine/include/imx-base.inc
include conf/machine/include/arm/armv7a/tune-cortexa7.inc

KERNEL_BRANCH ??= "release/ptic-imx-5.15.32-2.0.0_R01_y"
KERNEL_COMMIT_HASH ??= "34f4567cf8d034ec323ec53c406f67ee493e8c24"

# TODO: Add multiple dtb's in FIT image
KERNEL_DEFCONFIG  ?= "ptic/imx6ulx_ptic_base_defconfig"
KERNEL_DEVICETREE ?= "ptic/imx6ulx-ptic-base.dtb"

PREFERRED_PROVIDER_virtual/kernel = "linux-imx"
PREFERRED_VERSION_linux-imx ?= "5.%"

SERIAL_CONSOLES = "115200;ttymxc0"

# Optee is included in the poky distro, but we don't need it.
MACHINE_FEATURES:remove ?= "optee wifi bluetooth alsa"

# Used to fill FIT template
UBOOT_KERNEL_DTB_LOADADDRESS ?= "0x818A0000"
UBOOT_KERNEL_LOADADDRESS     ?= "0x81920000"
UBOOT_KERNEL_ENTRYPOINT      ?= "0x81920000"
UBOOT_KERNEL_RD_LOADADDRESS  ?= "0x83720000"

# U-Boot environment script names
UBOOT_SCRIPT        ?= "boot.cmd-imx6ull-ptic-base"

# U-Boot fw-utils configuration names
UBOOT_FW_UTILS       ?= "boot_env-imx6ull-ptic-base.config"
UBOOT_FACTORY_UTILS  ?= "factory_env-imx6ull-ptic-base.config"
UBOOT_CUSTOMER_UTILS ?= "customer_env-imx6ull-ptic-base.config"
