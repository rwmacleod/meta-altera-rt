SUMMARY = "PREEMTP_RT patch for Kernel 6.12.%"

RT_LINUX_VERSION = "6.12.8"
RT_PATCH_VERSION = "8"

include linux-socfpga-rt.inc

SRC_URI:append = "${@bb.utils.contains('SOCFPGA_RT_FEATURES', 'rt-patch', ' https://cdn.kernel.org/pub/linux/kernel/projects/rt/6.12/older/patch-${RT_LINUX_VERSION}-rt${RT_PATCH_VERSION}.patch.gz;name=rt-patch;apply=yes', '', d)}"

SRC_URI[rt-patch.sha256sum] = "81e08a6b8e324c08518b50256fb434b8b3fbf85618e08e99de106ce1ac4815b2"
