DESCRIPTION="Compile and deploy U-Boot environment script"
LICENSE="CLOSED"
LIC_FILES_CHKSUM = ""

inherit staging
inherit nopackages

SRC_URI += " \
    file://boot.cmd-imx6ull-ptic-base \
    file://boot.cmd-imx8m-ptic-base \
    file://boot.cmd-imx8mn-ptic-base \
"

# Add /boot to the dirs staging considers for copying to sysroot dirs
SYSROOT_DIRS:append = "/boot"

do_install:append() {
  install -Dm 0644 ${WORKDIR}/${UBOOT_SCRIPT} ${D}/boot/${UBOOT_SCRIPT}
}
