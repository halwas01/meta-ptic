# This patches systemd to include watchdog pretimeout functionality. Patches are based on mainline systemd patches
# released in version v251. Whenever this version (or higher) is used for systemd, these patches can be omitted.
#
# This also sets the watchdog pretimeout to fire 1s before the watchdog timer expires. The default pretimeout governor
# set in Linux kernel config is maintained.
#
# Mainline systemd commit used:
# https://github.com/systemd/systemd-stable/commit/5717062e93ec6f128188d2ef4d1399623995bc63
# https://github.com/systemd/systemd-stable/commit/56b96db7005293063c47ecb9ba7b85f078ef8f23
# https://github.com/systemd/systemd-stable/commit/aff3a9e1fa8b5a4606577d2bcd6dbf5d35d7db37
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://0001-watchdog-Add-watchdog-pretimeout-support.patch \
    file://0002-watchdog-check-pretimeout-governor.patch \
    file://0003-watchdog-add-setting-to-configure-pretimeout-governo.patch \
    file://0004-Fixed-compiler-errors.patch \
    file://0005-Enable-hardware-watchdog-triggering.patch \
"

