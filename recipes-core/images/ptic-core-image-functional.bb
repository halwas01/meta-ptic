SUMMARY = "A functional image for ptic building blocks allowing the device to boot."

IMAGE_INSTALL = "packagegroup-core-boot ${CORE_IMAGE_EXTRA_INSTALL}"

IMAGE_LINGUAS = " "

LICENSE = "MIT"

inherit core-image

IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE:append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "", d)}"

# Additional packages, which needs to be installed, append them in the IMAGE_INSTALL
IMAGE_INSTALL:append = " \
    base-files \
    mtd-utils \
    u-boot-fw-utils \
"

# For machines containing a CANbus, add iproute2 (as busybox ip cannot handle CAN) and canutils package
IMAGE_INSTALL:append = " \
    ${@bb.utils.contains('MACHINE_FEATURES', 'socketcan', 'iproute2', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'socketcan', 'canutils', '', d)} \
"

# i.MX6ULL Machine specific installs
IMAGE_INSTALL:append:mx6-nxp-bsp = " \
    firmware-imx-sdma-imx6q \
    mtd-utils-ubifs \
"

# i.MX8M Machine specific installs
IMAGE_INSTALL:append:mx8m-nxp-bsp = " \
    mmc-utils \
    e2fsprogs-mke2fs \
    firmware-imx-sdma-imx7d \
    firmware-imx-epdc \
    gptfdisk \
"

# Remove packages which are not used within PTIC
PACKAGE_INSTALL:remove = " \
    apt \
    dpkg \
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
