	.globl	plat_reset_handler

func plat_reset_handler
	mrs	x0, mpidr_el1
	mov	x1, #0x0f00
	and	x2, x0, x1
	cmp	x2, #0x0300
	b.eq	is_core3
	cmp	x2, #0x0000
	b.eq	is_core0
	ret
is_core0:
	/* CLUSTERACTLR_EL1 */
	sysreg_bit_set S3_0_C15_C3_3, (1 << 26)
	/* CLUSTERPARTCR_EL1 */
	sysreg_bit_clear S3_0_C15_C4_3, 0xffffffffffffff00
	sysreg_bit_clear S3_0_C15_C4_3, 0xff
	sysreg_bit_set   S3_0_C15_C4_3, 0x1e
	/* CLUSTERBUSQOS_EL1 */
	sysreg_bit_clear S3_0_C15_C4_4, 0xffffffffffffff00
	sysreg_bit_clear S3_0_C15_C4_4, 0xff
	sysreg_bit_set   S3_0_C15_C4_4, 0xf0
	ret
is_core3:
	/* ACTLR_EL3 */
	sysreg_bit_set actlr_el3, ((1 << 11) | (1 << 10))
	/* CLUSTERTHREADSID_EL1 */
	sysreg_bit_clear S3_0_C15_C4_0, 0xffffffffffffff00
	sysreg_bit_clear S3_0_C15_C4_0, 0xff
	sysreg_bit_set   S3_0_C15_C4_0, 0x01
	ret
endfunc plat_reset_handler
