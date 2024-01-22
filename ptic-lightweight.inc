# Base Lightweight distribution definition for Prodrive PTIC Project
#
# Copyright (C) 2023 Prodrive Technologies B.V. - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential

# Basic information
DISTRO_CODENAME = "kirkstone"
MAINTAINER = "Max van den Biggelaar <max.van.den.biggelaar@prodrive-technologies.com>"

# LIBC selection, musl provides smaller footprint
TCLIBC = "musl"

FULL_OPTIMIZATION="-Os -pipe ${DEBUG_FLAGS}"

PREFERRED_PROVIDER_virtual/kernel = "linux-imx"
PREFERRED_VERSION_linux-libc-headers_imx ?= "5.15"

# NXP provides 1.9.5p2 for some reason, but the poky version is newer. So use it.
PREFERRED_VERSION_sudo ?= "1.9.10"

# Enable LFS - see bug YOCTO #5865, not sure what this is for, as it is from
# poky-tiny
DISTRO_FEATURES:append:libc-musl = " largefile"

# At this moment no append for the TCLIBC
TCLIBCAPPEND = ""

# Disable wide char support for ncurses as we don't include it in in the LIBC features below.
# Leave native enable to avoid build failures
ENABLE_WIDEC = "false"
ENABLE_WIDEC_class-native = "true"

# Comment out any of the lines below to disable them in the build DISTRO_FEATURES options:
# alsa bluetooth ext2 pcmcia usbgadget usbhost wifi nfs zeroconf pci
# DISTRO_FEATURES_TINY = "pci"
DISTRO_FEATURES_NET = "ipv4 ipv6"
DISTRO_FEATURES_EXT = "ext2"
# DISTRO_FEATURES_USB = "usbhost"
# DISTRO_FEATURES_USBGADGET = "usbgadget"
# DISTRO_FEATURES_WIFI = "wifi"

DISTRO_FEATURES = "${DISTRO_FEATURES_TINY} \
                   ${DISTRO_FEATURES_NET} \
                   ${DISTRO_FEATURES_EXT} \
                   ${DISTRO_FEATURES_USB} \
                   ${DISTRO_FEATURES_USBGADGET} \
                   ${DISTRO_FEATURES_WIFI} \
                  "

DISTRO_FEATURES_class-native = "${DISTRO_FEATURES_DEFAULT}"
DISTRO_FEATURES_class-nativesdk = "${DISTRO_FEATURES_DEFAULT}"

# enable mdev/busybox for init
INIT_MANAGER ?= "mdev-busybox"

# Use lightweight core image by default
INITRAMFS_IMAGE ?= "ptic-core-image-lightweight"

# By default we only support initramfs. We don't build live as that pulls in a lot of dependencies for the
# live image and the installer, like udev, grub, etc.  These pull in gettext, which fails to build with wide
# character support.
IMAGE_FSTYPES = "cpio.xz"
QB_DEFAULT_FSTYPE = "${IMAGE_FSTYPES}"

KERNEL_CLASSES += "kernel-fitimage-ptic"

# Add additional dependency check to ensure the fakeroot-native is built before
# it is used.
do_image_create_sdcard_symlink[depends] += "virtual/fakeroot-native:do_populate_sysroot"

# Drop kernel-module-af-packet from RRECOMMENDS
POKY_DEFAULT_EXTRA_RRECOMMENDS ?= ""

# Drop v86d from qemu dependency list (we support serial)
# Drop grub from meta-intel BSPs
# FIXME: A different mechanism is needed here. We could define -tiny
#        variants of all compatible machines, but that leads to a lot
#        more machine configs to maintain long term.
MACHINE_ESSENTIAL_EXTRA_RDEPENDS ?= ""

# The mtrace script included by eglibc is a perl script. This means the system
# will build perl in case this package is installed. Since we don't care about
# this script for the purposes of tiny, remove the dependency from here.
RDEPENDS:${PN}-mtrace:pn-eglibc = ""

# Disable python usage in opkg-utils since it won't build with tiny config
PACKAGECONFIG:remove:pn-opkg-utils = "python"

# Added buildhistory for debugging information
INHERIT += "buildhistory"

# Following images are considered not competible with current distro.
# But most of them are just against the goal of the small size firmware.
SKIP_RECIPE[build-appliance-image] = "not buildable with poky-tiny"
SKIP_RECIPE[core-image-rt] = "not buildable with poky-tiny"
SKIP_RECIPE[core-image-rt-sdk] = "not buildable with poky-tiny"
SKIP_RECIPE[core-image-sato] = "not buildable with poky-tiny"
SKIP_RECIPE[core-image-sato-dev] = "not buildable with poky-tiny"
SKIP_RECIPE[core-image-sato-sdk] = "not buildable with poky-tiny"
SKIP_RECIPE[core-image-x11] = "not buildable with poky-tiny"
SKIP_RECIPE[core-image-weston] = "not buildable with poky-tiny"

SOURCE_MIRROR_URL = "https://artifactory.prodrive.nl:443/artifactory/ptic-yocto-local/mirror/kirkstone/"
INHERIT += "own-mirrors"
