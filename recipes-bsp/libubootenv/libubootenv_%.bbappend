# This recipe provides the configuration files for the libubootenv package
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://boot_env-imx6ull-ptic-base.config \
    file://boot_env-imx8m-ptic-base.config \
    file://factory_env-imx6ull-ptic-base.config \
    file://factory_env-imx8m-ptic-base.config \
    file://customer_env-imx6ull-ptic-base.config \
    file://customer_env-imx8m-ptic-base.config \
"

do_install:append () {
    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/${UBOOT_FW_UTILS} ${D}${sysconfdir}/${UBOOT_FW_UTILS}
    install -m 0644 ${WORKDIR}/${UBOOT_FACTORY_UTILS} ${D}${sysconfdir}/factory_env.config
    install -m 0644 ${WORKDIR}/${UBOOT_CUSTOMER_UTILS} ${D}${sysconfdir}/customer_env.config

    # Config of file links to default fw_env
    ln -sf ${UBOOT_FW_UTILS} ${D}${sysconfdir}/fw_env.config
}
