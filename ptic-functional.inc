# Base Functional distribution definition for Prodrive PTIC Project
#
# Copyright (C) October 2021 Prodrive Technologies B.V. - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential

# Basic information
DISTRO_CODENAME = "kirkstone"
MAINTAINER = "Max van den Biggelaar <max.van.den.biggelaar@prodrive-technologies.com>"

# LIBC selection, glibc required for precompiled GPU libraries
TCLIBC = "glibc"

PREFERRED_PROVIDER_virtual/kernel = "linux-imx"
PREFERRED_VERSION_linux-libc-headers_imx ?= "5.15"
PREFERRED_RPROVIDER_mfgtool-image = "linux-imx-mfgtool"
PREFERRED_RPROVIDER_mfgtool-image-image = "linux-imx-mfgtool"
PREFERRED_RPROVIDER_mfgtool-base = "linux-imx-mfgtool"
PREFERRED_RPROVIDER_mfgtool-image-fitimage = "linux-imx-mfgtool"
PREFERRED_PROVIDER_virtual/opencl-icd = "imx-gpu-viv"

# NXP provides 1.9.5p2 for some reason, but the poky version is newer. So use it.
PREFERRED_VERSION_sudo ?= "1.9.10"

# Use systemd as default init manager
VIRTUAL-RUNTIME_init_manager = "systemd"
PREFERRED_PROVIDER_udev = "systemd"
PREFERRED_PROVIDER_udev-utils = "systemd"
DISTRO_FEATURES_BACKFILL_CONSIDERED = "sysvinit"
POKY_DEFAULT_DISTRO_FEATURES += " systemd"

# Use functional core image by default
INITRAMFS_IMAGE ?= "ptic-core-image-functional"

# Root file system supports file system compression xz/gz and ext4
# Compression xz is applicable for optimized memory size systems
# Compression gz is applicable for faster boot time use cases
IMAGE_FSTYPES = "cpio.xz cpio.gz ext4"
QB_DEFAULT_FSTYPE = "${IMAGE_FSTYPES}"

KERNEL_CLASSES += "kernel-fitimage-ptic"

# Add additional dependency check to ensure the fakeroot-native is built before
# it is used.
do_image_create_sdcard_symlink[depends] += "virtual/fakeroot-native:do_populate_sysroot"

# Add imx8m sdma firmware
MACHINE_EXTRA_RRECOMMENDS:append:mx8-nxp-bsp = " linux-firmware-imx-sdma-imx7d"

# Exclusively using wayland, so remove x11 and directfb
DISTRO_FEATURES:remove = "directfb x11"
DISTRO_FEATURES:append = " systemd wayland pam"

# Added buildhistory for information
INHERIT += "buildhistory"

# Build is much faster by using own mirror links
SOURCE_MIRROR_URL = "https://artifactory.prodrive.nl:443/artifactory/ptic-yocto-local/mirror/kirkstone/"
INHERIT += "own-mirrors"
