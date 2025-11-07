SUMMARY = "PREEMTP_RT patch for Kernel 6.6.%"

RT_LINUX_VERSION = "6.6.50"
RT_PATCH_VERSION = "42"

include linux-socfpga-rt.inc

SRC_URI:append = "${@bb.utils.contains('SOCFPGA_RT_FEATURES', 'rt-patch', ' https://cdn.kernel.org/pub/linux/kernel/projects/rt/6.6/older/patch-${RT_LINUX_VERSION}-rt${RT_PATCH_VERSION}.patch.gz;name=rt-patch;apply=yes', '', d)}"

SRC_URI[rt-patch.sha256sum] = "8ec45aca0a21c7a1914b4d2ee42e8815e3e6ad3f25a46785a4415a04d23b4af7"
