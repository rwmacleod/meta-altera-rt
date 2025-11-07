SUMMARY = "Add fragments to plat_helpers.S in ATF source"
DESCRIPTION = "Implements HPS optimizations by core: no L3 allocate mode, cache partitioning, and HIC QOS to prioritize isolated core."


FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Add fragment files conditionally
SRC_URI:append = "${@bb.utils.contains('SOCFPGA_RT_FEATURES', 'rt-atf-core3', ' file://core3_nl3a_cp_qos_plat_helpers.S', '', d)}"
SRC_URI:append = "${@bb.utils.contains('SOCFPGA_RT_FEATURES', 'rt-atf-core1', ' file://core1_nl3a_cp_qos_plat_helpers.S', '', d)}"

# Append fragments to plat_helpers.S after patching
python do_patch:append() {
    import os

    target_file = os.path.join(d.getVar('S'), 'plat/intel/soc/common/aarch64/plat_helpers.S')
    workdir = d.getVar('WORKDIR')
    workdir = os.path.join(workdir, "sources-unpack")
    features = d.getVar('SOCFPGA_RT_FEATURES') or ''

    fragment_map = {
        'rt-atf-core3': 'core3_nl3a_cp_qos_plat_helpers.S',
        'rt-atf-core1': 'core1_nl3a_cp_qos_plat_helpers.S'
    }

    # Read original file
    with open(target_file, 'r') as f:
        content = f.read()

    for key, frag in fragment_map.items():
        if key in features:
            frag_path = os.path.join(workdir, frag)
            if os.path.exists(frag_path):
                with open(frag_path, 'r') as fr:
                    frag_content = fr.read()

                # Remove previous fragment if it exists
                if frag_content in content:
                    content = content.replace(frag_content, '')

                content += "\n" + frag_content
            else:
                bb.warn("Fragment %s not found in WORKDIR" % frag)

    # Write back
    with open(target_file, 'w') as fw:
        fw.write(content)
}
