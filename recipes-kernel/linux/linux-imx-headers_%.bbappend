# Override the kernel source tree location
KERNEL_BRANCH ??= "ptic_imx-5.15.32-2.0.0_y"
KERNEL_REPOS_URL ??= "git://bitbucket.prodrive.nl/scm/ptic203904/linux-ptic.git"
KERNEL_REPOS_PROTOCOL ??= "https"
KERNEL_COMMIT_HASH ??= "${AUTOREV}"
# Cannot do ??= on KERNEL_SRC, as the original linux-imx recipe already does ?=
KERNEL_SRC = "${KERNEL_REPOS_URL};protocol=${KERNEL_REPOS_PROTOCOL}"
SRC_URI = "${KERNEL_SRC};branch=${KERNEL_BRANCH}"
SRCREV = "${KERNEL_COMMIT_HASH}"
SCMVERSION = "y"
