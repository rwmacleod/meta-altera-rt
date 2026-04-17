SUMMARY = "PREEMTP_RT patch for Kernel 6.18.%"

RT_LINUX_VERSION = "6.18.13"
RT_PATCH_VERSION = "4"

include linux-socfpga-rt.inc

SRC_URI:append = "${@bb.utils.contains('SOCFPGA_RT_FEATURES', 'rt-patch', ' https://cdn.kernel.org/pub/linux/kernel/projects/rt/6.18/older/patch-${RT_LINUX_VERSION}-rt${RT_PATCH_VERSION}.patch.gz;name=rt-patch;apply=yes', '', d)}"

SRC_URI[rt-patch.sha256sum] = "3fa9894501df230db90c8dab3a05702d5246b05adca50276121662c8eb7fa9f1"
