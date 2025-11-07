/* ##################################################################################
 * Copyright (C) 2025 Altera Corporation
 *
 * This software and the related documents are Altera copyrighted materials, and
 * your use of them is governed by the express license under which they were
 * provided to you ("License"). Unless the License provides otherwise, you may
 * not use, modify, copy, publish, distribute, disclose or transmit this software
 * or the related documents without Altera's prior written permission.
 *
 * This software and the related documents are provided as is, with no express
 * or implied warranties, other than those that are expressly stated in the License.
 * ##################################################################################
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/sysfs.h>
#include <linux/cpu.h>
#include <linux/smp.h>
#include <asm/sysreg.h>

#define CLUSTERACTLR_EL1        sys_reg(3, 0, 15, 3, 3)
#define CLUSTERPARTCR_EL1       sys_reg(3, 0, 15, 4, 3)
#define CLUSTERBUSQOS_EL1       sys_reg(3, 0, 15, 4, 4)
#define CLUSTERTHREADSID_EL1    sys_reg(3, 0, 15, 4, 0)
#define NUM_CORES 4

struct reg_values {
    u64 clusteractlr_el1;
    u64 clusterpartcr_el1;
    u64 clusterbusqos_el1;
    u64 clusterthreadsid_el1[NUM_CORES];
};

static struct reg_values sysreg_vals;

static u64 read_clusteractlr_el1(void)
{
    return read_sysreg_s(CLUSTERACTLR_EL1);
}

static u64 read_clusterpartcr_el1(void)
{
    return read_sysreg_s(CLUSTERPARTCR_EL1);
}

static u64 read_clusterbusqos_el1(void)
{
    return read_sysreg_s(CLUSTERBUSQOS_EL1);
}

static u64 read_clusterthreadsid_el1(void)
{
    return read_sysreg_s(CLUSTERTHREADSID_EL1);
}

static void capture_threadsid_per_core(void *data)
{
    int cpu = smp_processor_id();
    if (cpu < NUM_CORES) {
        sysreg_vals.clusterthreadsid_el1[cpu] = read_clusterthreadsid_el1();
    }
}

static ssize_t system_registers_show(struct kobject *kobj,
                                    struct kobj_attribute *attr, char *buf)
{
    int cpu;
    int len = 0;

    len += sprintf(buf + len, "CLUSTERACTLR_EL1: 0x%llx\n",  sysreg_vals.clusteractlr_el1);
    len += sprintf(buf + len, "CLUSTERPARTCR_EL1: 0x%llx\n", sysreg_vals.clusterpartcr_el1);
    len += sprintf(buf + len, "CLUSTERBUSQOS_EL1: 0x%llx\n", sysreg_vals.clusterbusqos_el1);
    for (cpu = 0; cpu < NUM_CORES; cpu++) {
        len += sprintf(buf + len, "CLUSTERTHREADSID_EL1 (CPU%d): 0x%llx\n",
                       cpu, sysreg_vals.clusterthreadsid_el1[cpu]);
    }
    return len;
}

static struct kobj_attribute system_registers_attr =
    __ATTR(system_registers, 0444, system_registers_show, NULL);

static int system_reg_probe(void)
{
    int cpu;
    int ret;

    /* Capture system register values */
    sysreg_vals.clusteractlr_el1 = read_clusteractlr_el1();
    sysreg_vals.clusterpartcr_el1 = read_clusterpartcr_el1();
    sysreg_vals.clusterbusqos_el1 = read_clusterbusqos_el1();

    /* Capture CLUSTERTHREADSID_EL1 for each core */
    for_each_online_cpu(cpu) {
        if (cpu < NUM_CORES) {
            smp_call_function_single(cpu, capture_threadsid_per_core, NULL, 1);
        }
    }

    /* Create sysfs file under /sys/kernel/ */
    ret = sysfs_create_file(kernel_kobj, &system_registers_attr.attr);
    if (ret) {
        pr_err("Failed to create sysfs file\n");
        return ret;
    }

    pr_info("System register dump module initialized\n");
    return 0;
}

static void system_reg_remove(void)
{
    sysfs_remove_file(kernel_kobj, &system_registers_attr.attr);
    pr_info("System register dump module removed\n");
}

static int __init system_reg_init(void)
{
    return system_reg_probe();
}

static void __exit system_reg_exit(void)
{
    system_reg_remove();
}

module_init(system_reg_init);
module_exit(system_reg_exit);

MODULE_LICENSE("GPL v2");
MODULE_AUTHOR("xAI");
MODULE_DESCRIPTION("System register dump module");
