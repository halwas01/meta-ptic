SUMMARY = "A lightweight image for ptic building blocks allowing the device to boot."

# PACKAGE_INSTALL variable allows the initramfs recipe to use a fixed set of packages and
# not be affected by IMAGE_INSTALL.

IMAGE_LINGUAS = " "

LICENSE = "CLOSED"

inherit core-image

# Basic packages that have to be installed in rootfs
PACKAGE_INSTALL = " \
    packagegroup-core-boot \
    ${VIRTUAL-RUNTIME_base-utils} \
    ${VIRTUAL-RUNTIME_dev_manager} \
    base-passwd \
    ${ROOTFS_BOOTSTRAP_INSTALL} \
"

IMAGE_ROOTFS_SIZE ?= "2048"
IMAGE_ROOTFS_EXTRA_SPACE ?= "512"

# Additional generic packages in rootfs
PACKAGE_INSTALL:append  = " \
    mtd-utils \
    u-boot-fw-utils \
    memtester \
    i2c-tools \
    ethtool \
"

# For machines containing a CANbus, add iproute2 (as busybox ip cannot handle CAN) and canutils package
PACKAGE_INSTALL:append = " \
    ${@bb.utils.contains('MACHINE_FEATURES', 'socketcan', 'iproute2', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'socketcan', 'canutils', '', d)} \
"

# Additional i.MX8 specific packages in rootfs
PACKAGE_INSTALL:append:mx8m-nxp-bsp = " \
    mmc-utils \
    e2fsprogs-mke2fs \
    firmware-imx-sdma-imx7d \
    firmware-imx-epdc \
"

# Additional i.MX6 specific packages in rootfs
PACKAGE_INSTALL:append:mx6-nxp-bsp  = " \
    mtd-utils-ubifs \
    firmware-imx-sdma-imx6q \
"

# Remove packages which are not used within PTIC
PACKAGE_INSTALL:remove = " \
    apt \
"

# Exclude packages to optimize size of image
PACKAGE_EXCLUDE = " \
    ncurses-terminfo-base \
"

do_mount_tmp_directory () {
    cat >> ${IMAGE_ROOTFS}/etc/fstab <<EOF
# Mount read/write /tmp directory with limited size
tmpfs                /tmp                 tmpfs      defaults,size=64M     0  0

EOF
}

do_mount_debugfs_directory () {
    cat >> ${IMAGE_ROOTFS}/etc/fstab <<EOF
# Mount debugfs /sys/kernel/debug for debugging
debugfs                /sys/kernel/debug          debugfs      defaults,noatime,rw     0  0

EOF
}

ROOTFS_POSTPROCESS_COMMAND += "do_mount_tmp_directory; "
ROOTFS_POSTPROCESS_COMMAND += "do_mount_debugfs_directory; "

# PTIC incompatibility with the following licenses
INCOMPATIBLE_LICENSE += "GPL-3.0* LGPL-3.0* AGPL-3.0*"
