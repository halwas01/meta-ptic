# This class is copied from the kernel-fitimage.bbclass file in the openembedded-core repository.
# The class is extended with PTIC specific variables.

inherit kernel-uboot kernel-artifact-names

KERNEL_IMAGETYPE_REPLACEMENT = ""

python __anonymous () {
    depends = d.getVar("DEPENDS")
    depends = "%s u-boot-tools-native dtc-native u-boot-scr" % depends

    # When a machine defines a recipe installing an AMP firmware binary, depend on it
    amp_recipe_dep = d.getVar('KERNEL_AMP_FIRMWARE_RECIPE_DEP') or ""
    depends = "%s %s" % (depends, amp_recipe_dep)
    d.setVar("DEPENDS", depends)

    uarch = d.getVar("UBOOT_ARCH")
    if uarch == "arm64":
        replacementtype = "Image"
    else:
        replacementtype = "zImage"

    d.setVar("KERNEL_IMAGETYPE_REPLACEMENT", replacementtype)

    # Override KERNEL_IMAGETYPE_FOR_MAKE variable, which is internal
    # to kernel.bbclass . We have to override it, since we pack zImage
    # (at least for now) into the fitImage .
    typeformake = d.getVar("KERNEL_IMAGETYPE_FOR_MAKE") or ""
    if 'fitImage' in typeformake.split():
        d.setVar('KERNEL_IMAGETYPE_FOR_MAKE', typeformake.replace('fitImage', replacementtype))

    image = d.getVar('INITRAMFS_IMAGE')
    if image:
        d.appendVarFlag('do_assemble_fitimage_initramfs', 'depends', ' ${INITRAMFS_IMAGE}:do_image_complete')

    #check if there are any dtb providers
    providerdtb = d.getVar("PREFERRED_PROVIDER_virtual/dtb")
    if providerdtb:
        d.appendVarFlag('do_assemble_fitimage_initramfs', 'depends', ' virtual/dtb:do_populate_sysroot')
        d.setVar('EXTERNAL_KERNEL_DEVICETREE', "${RECIPE_SYSROOT}/boot/devicetree")

    # Make sure the do_deploy task of the AMP firmware recipe is done before the assemble_fitimage tasks
    if amp_recipe_dep:
        d.appendVarFlag('do_assemble_fitimage_initramfs', 'depends', ' ' + amp_recipe_dep + ':do_deploy')
}

# Options for the device tree compiler passed to mkimage '-D' feature:
UBOOT_MKIMAGE_DTCOPTS ??= ""

# fitImage Hash Algo
FIT_HASH_ALG ?= "sha256"

# Description string
FIT_DESC ?= "U-Boot fitImage for ${DISTRO_NAME}/${PV}/${MACHINE}"

FIT_SUPPORTED_INITRAMFS_FSTYPES ?= "cpio.xz cpio.gz"

# mkimage command
UBOOT_MKIMAGE ?= "uboot-mkimage"
UBOOT_MKIMAGE_SIGN ?= "${UBOOT_MKIMAGE}"

# Define boot script variables needed for the kernel-fitimage class.
# Both are the same as we package the script into the FIT image and therefore
# it does not need to be in uImage format.
UBOOT_ENV = "${UBOOT_SCRIPT}"
UBOOT_ENV_BINARY = "${UBOOT_SCRIPT}"

#
# Emit the fitImage ITS header
#
# $1 ... .its filename
fitimage_emit_fit_header() {
  cat << EOF >> ${1}
/dts-v1/;

/ {
    description = "${FIT_DESC}";
    #address-cells = <1>;
EOF
}

#
# Emit the fitImage section bits
#
# $1 ... .its filename
# $2 ... Section bit type: imagestart - image section start
#                          confstart  - configuration section start
#                          sectend    - section end
#                          fitend     - fitimage end
#
fitimage_emit_section_maint() {
  case $2 in
  imagestart)
cat << EOF >> ${1}

    images {
EOF
  ;;
  confstart)
cat << EOF >> ${1}

    configurations {
EOF
  ;;
  sectend)
cat << EOF >> ${1}
    };
EOF
  ;;
  fitend)
cat << EOF >> ${1}
};
EOF
  ;;
  esac
}

#
# Emit the fitImage ITS kernel section
#
# $1 ... .its filename
# $2 ... Image counter
# $3 ... Path to kernel image
# $4 ... Compression type
fitimage_emit_section_kernel() {

  kernel_csum="${FIT_HASH_ALG}"

cat << EOF >> ${1}
        kernel-${2} {
            description = "Linux kernel";
            data = /incbin/("${3}");
            type = "kernel";
            arch = "${UBOOT_ARCH}";
            os = "linux";
            compression = "${4}";
            load = <${UBOOT_KERNEL_LOADADDRESS}>;
            entry = <${UBOOT_KERNEL_ENTRYPOINT}>;
            hash-1 {
                algo = "${kernel_csum}";
            };
        };
EOF
}

#
# Emit the fitImage ITS DTB section
#
# $1 ... .its filename
# $2 ... Image counter
# $3 ... Path to DTB image
fitimage_emit_section_dtb() {

  dtb_csum="${FIT_HASH_ALG}"

  dtb_loadline=""
  dtb_ext=${DTB##*.}
  if [ "${dtb_ext}" = "dtbo" ]; then
    if [ -n "${UBOOT_DTBO_LOADADDRESS}" ]; then
      dtb_loadline="load = <${UBOOT_DTBO_LOADADDRESS}>;"
    fi
  elif [ -n "${UBOOT_KERNEL_DTB_LOADADDRESS}" ]; then
    dtb_loadline="load = <${UBOOT_KERNEL_DTB_LOADADDRESS}>;"
  fi
cat << EOF >> ${1}
        fdt-${2} {
            description = "Flattened Device Tree blob";
            data = /incbin/("${3}");
            type = "flat_dt";
            arch = "${UBOOT_ARCH}";
            compression = "none";
            ${dtb_loadline}
            hash-1 {
                algo = "${dtb_csum}";
            };
        };
EOF
}

#
# Emit the fitImage ITS u-boot script section
#
# $1 ... .its filename
# $2 ... Image counter
# $3 ... Path to boot script image
fitimage_emit_section_boot_script() {

        bootscr_csum="${FIT_HASH_ALG}"

cat << EOF >> ${1}
        bootscript {
            description = "U-boot script";
            data = /incbin/("${3}");
            type = "script";
            arch = "${UBOOT_ARCH}";
            compression = "none";
            hash-1 {
                algo = "${bootscr_csum}";
            };
        };
EOF
}

#
# Emit the fitImage ITS AMP core firmware section
#
# $1 ... .its filename
# $2 ... AMP core firmware location
fitimage_emit_section_amp_firmware() {
        amp_core_csum="${FIT_HASH_ALG}"
        # AMP core architecture is always arm.
        amp_core_arch="arm"

cat << EOF >> ${1}
        amp-core {
            description = "AMP core firmware image";
            data = /incbin/("${2}");
            type = "firmware";
            compression = "none";
            arch = "${amp_core_arch}";
            load = <${KERNEL_AMP_FIRMWARE_LOADADDR}>;
            hash-1 {
                algo = "${amp_core_csum}";
            };
        };
EOF
}

#
# Emit the fitImage ITS ramdisk section
#
# $1 ... .its filename
# $2 ... Image counter
# $3 ... Path to ramdisk image
fitimage_emit_section_ramdisk() {

  ramdisk_csum="${FIT_HASH_ALG}"

cat << EOF >> ${1}
        ramdisk-${2} {
            description = "${INITRAMFS_IMAGE}";
            data = /incbin/("${3}");
            type = "ramdisk";
            arch = "${UBOOT_ARCH}";
            os = "linux";
            compression = "none";
EOF

  if [ -n "${UBOOT_KERNEL_RD_LOADADDRESS}" ]; then
    echo "            load = <${UBOOT_KERNEL_RD_LOADADDRESS}>;" >> ${1}
  fi
  if [ -n "${UBOOT_RD_ENTRYPOINT}" ]; then
    echo "            entry = <${UBOOT_RD_ENTRYPOINT}>;" >> ${1}
  fi

cat << EOF >> ${1}
            hash-1 {
                algo = "${ramdisk_csum}";
            };
        };
EOF
}

#
# Emit the fitImage ITS configuration section
#
# $1 ... .its filename
# $2 ... Linux kernel ID
# $3 ... DTB image name
# $4 ... ramdisk ID
# $5 ... u-boot script ID
# $6 ... config ID
# $7 ... default flag
fitimage_emit_section_config() {

  conf_csum="${FIT_HASH_ALG}"

  its_file="${1}"
  kernel_id="${2}"
  dtb_image="${3}"
  ramdisk_id="${4}"
  bootscr_id="${5}"
  config_id="${6}"
  default_flag="${7}"

  # Test if we have any DTBs at all
  sep=""
  conf_desc=""
  conf_node="conf-"
  kernel_line=""
  fdt_line=""
  ramdisk_line=""
  bootscr_line=""
  default_line=""

  # conf node name is selected based on dtb ID if it is present,
  # otherwise its selected based on kernel ID
  if [ -n "${dtb_image}" ]; then
    conf_node=$conf_node${dtb_image}
  else
    conf_node=$conf_node${kernel_id}
  fi

  if [ -n "${kernel_id}" ]; then
    conf_desc="Linux kernel"
    sep=", "
    kernel_line="            kernel = \"kernel-${kernel_id}\";"
  fi

  if [ -n "${dtb_image}" ]; then
    conf_desc="${conf_desc}${sep}FDT blob"
    sep=", "
    fdt_line="            fdt = \"fdt-${dtb_image}\";"
  fi

  if [ -n "${ramdisk_id}" ]; then
    conf_desc="${conf_desc}${sep}ramdisk"
    sep=", "
    ramdisk_line="            ramdisk = \"ramdisk-${ramdisk_id}\";"
  fi

  if [ -n "${bootscr_id}" ]; then
    conf_desc="${conf_desc}${sep}u-boot script"
    sep=", "
    bootscr_line="            bootscr = \"bootscr-${bootscr_id}\";"
  fi

  if [ "${default_flag}" = "1" ]; then
    # default node is selected based on dtb ID if it is present,
    # otherwise its selected based on kernel ID
    if [ -n "${dtb_image}" ]; then
      default_line="default = \"conf-${dtb_image}\";"
    else
      default_line="default = \"conf-${kernel_id}\";"
    fi
  fi

cat << EOF >> ${its_file}
        ${default_line}
        $conf_node {
            description = "${default_flag} ${conf_desc}";
${kernel_line}
${fdt_line}
${ramdisk_line}
${bootscr_line}
            hash-1 {
                algo = "${conf_csum}";
            };
EOF

cat << EOF >> ${its_file}
        };
EOF
}

#
# Assemble fitImage
#
# $1 ... .its filename
# $2 ... fitImage name
# $3 ... include ramdisk
fitimage_assemble() {
  kernelcount=1
  dtbcount=""
  DTBS=""
  ramdiskcount=${3}
  setupcount=""
  bootscr_id=""
  rm -f ${1} arch/${ARCH}/boot/${2}

  fitimage_emit_fit_header ${1}

  #
  # Step 1: Prepare a kernel image section.
  #
  fitimage_emit_section_maint ${1} imagestart

  uboot_prep_kimage

  if [ "${INITRAMFS_IMAGE_BUNDLE}" = "1" ]; then
    initramfs_bundle_path="arch/"${UBOOT_ARCH}"/boot/"${KERNEL_IMAGETYPE_REPLACEMENT}".initramfs"
    if [ -e "${initramfs_bundle_path}" ]; then

      #
      # Include the kernel/rootfs bundle.
      #

      fitimage_emit_section_kernel ${1} "${kernelcount}" "${initramfs_bundle_path}" "${linux_comp}"
    else
      bbwarn "${initramfs_bundle_path} not found."
    fi
  else
    fitimage_emit_section_kernel ${1} "${kernelcount}" linux.bin "${linux_comp}"
  fi

  #
  # Step 2: Prepare a DTB image section
  #

  if [ -z "${EXTERNAL_KERNEL_DEVICETREE}" ] && [ -n "${KERNEL_DEVICETREE}" ]; then
    dtbcount=1
    for DTB in ${KERNEL_DEVICETREE}; do
      if echo ${DTB} | grep -q '/dts/'; then
        bbwarn "${DTB} contains the full path to the the dts file, but only the dtb name should be used."
        DTB=`basename ${DTB} | sed 's,\.dts$,.dtb,g'`
      fi
      DTB_PATH="arch/${ARCH}/boot/dts/${DTB}"
      if [ ! -e "${DTB_PATH}" ]; then
        DTB_PATH="arch/${ARCH}/boot/${DTB}"
      fi

      DTB=$(basename "${DTB}"|cut -d . -f1)
      DTBS="${DTBS} ${DTB}"
      fitimage_emit_section_dtb ${1} ${DTB} ${DTB_PATH}
    done
  fi

  if [ -n "${EXTERNAL_KERNEL_DEVICETREE}" ]; then
    dtbcount=1
    for DTB in $(find "${EXTERNAL_KERNEL_DEVICETREE}" \( -name '*.dtb' -o -name '*.dtbo' \) -printf '%P\n' | sort); do
      DTB=$(echo "${DTB}" | tr '/' '_')
      DTBS="${DTBS} ${DTB}"
      fitimage_emit_section_dtb ${1} ${DTB} "${EXTERNAL_KERNEL_DEVICETREE}/${DTB}"
    done
  fi

  #
  # Step 3: Prepare a AMP core firmware section
  #

  if [ -z "${KERNEL_AMP_FIRMWARE_IMAGE}" ];then
    bbnote "Skipping inclusion of AMP firmware image as it is not defined"
  else
    if [ -f "${DEPLOY_DIR_IMAGE}/${KERNEL_AMP_FIRMWARE_IMAGE}" ];then
      cp ${DEPLOY_DIR_IMAGE}/${KERNEL_AMP_FIRMWARE_IMAGE} ${B}/amp-firmware.bin
      if [ ! -z "${KERNEL_AMP_FIRMWARE_LOADADDR}" ];then
        fitimage_emit_section_amp_firmware ${1} "amp-firmware.bin"
      else
        bbfatal "No AMP Core loadaddr definition found. Define KERNEL_AMP_FIRMWARE_LOADADDR in machine config"
      fi
    else
      bbfatal "${DEPLOY_DIR_IMAGE}/${KERNEL_AMP_FIRMWARE_IMAGE} not found, skip."
    fi
  fi

  #
  # Step 4: Prepare a u-boot script section
  #

  if [ -n "${UBOOT_ENV}" ] && [ -d "${STAGING_DIR_HOST}/boot" ]; then
    if [ -e "${STAGING_DIR_HOST}/boot/${UBOOT_ENV_BINARY}" ]; then
      cp ${STAGING_DIR_HOST}/boot/${UBOOT_ENV_BINARY} ${B}
      bootscr_id="${UBOOT_ENV_BINARY}"
      fitimage_emit_section_boot_script ${1} "${bootscr_id}" ${UBOOT_ENV_BINARY}
    else
      bbwarn "${STAGING_DIR_HOST}/boot/${UBOOT_ENV_BINARY} not found."
    fi
  fi

  #
  # Step 5: Prepare a ramdisk section.
  #
  if [ "x${ramdiskcount}" = "x1" ] && [ "${INITRAMFS_IMAGE_BUNDLE}" != "1" ]; then
    # Find and use the first initramfs image archive type we find
    found=
    for img in ${FIT_SUPPORTED_INITRAMFS_FSTYPES}; do
      initramfs_path="${DEPLOY_DIR_IMAGE}/${INITRAMFS_IMAGE_NAME}.$img"
      if [ -e "$initramfs_path" ]; then
        bbnote "Found initramfs image: $initramfs_path"
        found=true
        fitimage_emit_section_ramdisk $1 "$ramdiskcount" "$initramfs_path"
        break
      else
        bbnote "Did not find initramfs image: $initramfs_path"
      fi
    done

    if [ -z "$found" ]; then
      bbfatal "Could not find a valid initramfs type for ${INITRAMFS_IMAGE_NAME}, the supported types are: ${FIT_SUPPORTED_INITRAMFS_FSTYPES}"
    fi
  fi

  fitimage_emit_section_maint ${1} sectend

  # Force the first Kernel and DTB in the default config
  kernelcount=1
  if [ -n "${dtbcount}" ]; then
    dtbcount=1
  fi

  #
  # Step 6: Prepare a configurations section
  #
  fitimage_emit_section_maint ${1} confstart

  # kernel-fitimage.bbclass currently only supports a single kernel (no less or
  # more) to be added to the FIT image along with 0 or more device trees and
  # 0 or 1 ramdisk.
  # It is also possible to include an initramfs bundle (kernel and rootfs in one binary)
  # When the initramfs bundle is used ramdisk is disabled.
  # If a device tree is to be part of the FIT image, then select
  # the default configuration to be used is based on the dtbcount. If there is
  # no dtb present than select the default configuation to be based on
  # the kernelcount.
  if [ -n "${DTBS}" ]; then
    i=1
    for DTB in ${DTBS}; do
      dtb_ext=${DTB##*.}
      if [ "${dtb_ext}" = "dtbo" ]; then
        fitimage_emit_section_config ${1} "" "${DTB}" "" "${bootscr_id}" "" "`expr ${i} = ${dtbcount}`"
      else
        fitimage_emit_section_config ${1} "${kernelcount}" "${DTB}" "${ramdiskcount}" "${bootscr_id}" "${setupcount}" "`expr ${i} = ${dtbcount}`"
      fi
      i=`expr ${i} + 1`
    done
  else
    defaultconfigcount=1
    fitimage_emit_section_config ${1} "${kernelcount}" "" "${ramdiskcount}" "${bootscr_id}"  "${setupcount}" "${defaultconfigcount}"
  fi

  fitimage_emit_section_maint ${1} sectend

  fitimage_emit_section_maint ${1} fitend

  #
  # Step 7: Assemble the image
  #
  ${UBOOT_MKIMAGE} \
    ${@'-D "${UBOOT_MKIMAGE_DTCOPTS}"' if len('${UBOOT_MKIMAGE_DTCOPTS}') else ''} \
    -f ${1} \
    arch/${ARCH}/boot/${2}
}

do_assemble_fitimage_initramfs() {
  cd ${B}
  if [ "${INITRAMFS_IMAGE_BUNDLE}" = "1" ]; then
    fitimage_assemble fit-image-${INITRAMFS_IMAGE}.its fitImage ""
  else
    fitimage_assemble fit-image-${INITRAMFS_IMAGE}.its fitImage-${INITRAMFS_IMAGE} 1
  fi
}

addtask assemble_fitimage_initramfs before do_deploy after do_bundle_initramfs

kernel_do_deploy[vardepsexclude] = "DATETIME"
kernel_do_deploy:append() {
  # Update deploy directory
  if [ -n "${INITRAMFS_IMAGE}" ]; then
    bbnote "Copying fit-image-${INITRAMFS_IMAGE}.its source file..."
    install -m 0644 ${B}/fit-image-${INITRAMFS_IMAGE}.its "$deployDir/fitImage-its-${MACHINE}-${LINUX_VERSION}-${DISTRO}.its"

    if [ "${INITRAMFS_IMAGE_BUNDLE}" != "1" ]; then
      bbnote "Copying fitImage-${INITRAMFS_IMAGE} file..."
      install -m 0644 ${B}/arch/${ARCH}/boot/fitImage-${INITRAMFS_IMAGE} "$deployDir/fitImage-${MACHINE}-${LINUX_VERSION}-${DISTRO}.itb"
    fi
  fi
}
