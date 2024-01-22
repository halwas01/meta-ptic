# This is a recipe append file (.bbappend). The content of this file will be
# appended into the linux-imx recipe, sort of like a patch. So that Yocto will
# take this additional add-on when Yocto builds the component "Linux-imx".

# The original recipe is under
# /meta-imx/meta-bsp/recipes-kernel/linux/linux-imx_5.15.bb

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
KERNEL_BRANCH ??= "ptic_imx-5.15.32-2.0.0_y"
KERNEL_REPOS_URL ??= "git://bitbucket.prodrive.nl/scm/ptic203904/linux-ptic.git"
KERNEL_REPOS_PROTOCOL ??= "https"
KERNEL_COMMIT_HASH ??= "${AUTOREV}"
# Cannot do ??= on KERNEL_SRC, as the original linux-imx recipe already does ?=
KERNEL_SRC = "${KERNEL_REPOS_URL};protocol=${KERNEL_REPOS_PROTOCOL}"
SRC_URI = "${KERNEL_SRC};branch=${KERNEL_BRANCH}"
SRCREV = "${KERNEL_COMMIT_HASH}"
SCMVERSION = "y"

SRC_ARCH_DIRECTORY ?= "arm"
SRC_ARCH_DIRECTORY:mx6-nxp-bsp = "arm"
SRC_ARCH_DIRECTORY:mx7-nxp-bsp = "arm"
SRC_ARCH_DIRECTORY:mx8-nxp-bsp = "arm64"

do_copy_defconfig () {
    install -d ${B}
    mkdir -p ${B}
    cp ${S}/arch/${SRC_ARCH_DIRECTORY}/configs/${KERNEL_DEFCONFIG} ${B}/.config
    cp ${S}/arch/${SRC_ARCH_DIRECTORY}/configs/${KERNEL_DEFCONFIG} ${B}/../defconfig
}
