DESCRIPTIOM = "Custom shell and python scripts for RT test"
LICENSE = "CLOSED"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "file://run_cyclictest_hackbench-core.sh"
SRC_URI += "file://rt-plot-generator.py"


RDEPENDS:${PN} = "python3-core python3-pandas python3-matplotlib"

SRC_DIR = "${WORKDIR}"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${SRC_DIR}/run_cyclictest_hackbench-core.sh ${D}${bindir}/run_cyclictest_hackbench-core
    install -m 0755 ${SRC_DIR}/rt-plot-generator.py ${D}${bindir}/rt-plot-generator
}

FILES:${PN} += "${bindir}/run_cyclictest_hackbench-core ${bindir}/rt-plot-generator"
