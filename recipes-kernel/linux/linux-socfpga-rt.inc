DESCRIPTION = "Linux RT Kernel for Altera SoCFPGA: add utilities, Kernel config, and PREEMPT-RT patch"
LICENSE = "CLOSED"

FILESEXTRAPATHS:prepend := "${THISDIR}/config:"
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRCREV ?= "${AUTOREV}"
SRCREV_machine ?= "${SRCREV}"

SRC_URI:append = "${@bb.utils.contains('SOCFPGA_RT_FEATURES', 'rt-patch', ' file://rt.scc', '', d)}"
SRC_URI:append = "${@bb.utils.contains('SOCFPGA_RT_FEATURES', 'rt-core-isol', ' file://rt-core-isol.scc', '', d)}"
SRC_URI:append = "${@bb.utils.contains('SOCFPGA_RT_FEATURES', 'rt-irq-aff', ' file://rt-irq-aff.scc', '', d)}"
SRC_URI:append = "${@bb.utils.contains('SOCFPGA_RT_FEATURES', 'rt-no-hz-full', ' file://rt-no-hz-full.scc', '', d)}"
SRC_URI:append = "${@bb.utils.contains('SOCFPGA_RT_FEATURES', 'rt-rcu-nocbs', ' file://rt-rcu-nocbs.scc', '', d)}"
SRC_URI:append = "${@bb.utils.contains('SOCFPGA_RT_FEATURES', 'rt-utils', ' file://system_reg_dump.c', '', d)}"

SRC_DIR = "${WORKDIR}/sources-unpack"

do_configure:append() {
        ${@bb.utils.contains('SOCFPGA_RT_FEATURES', 'rt-utils','cp ${SRC_DIR}/system_reg_dump.c ${B}/source/drivers/misc/system_reg_dump.c','', d)}
        ${@bb.utils.contains('SOCFPGA_RT_FEATURES', 'rt-utils','echo "obj-y += system_reg_dump.o" >> ${B}/source/drivers/misc/Makefile','', d)}
}
