	.build_version macos, 26, 0
	.section	__TEXT,__text,regular,pure_instructions
	.p2align	2
_xir_run_closure_0:
	.cfi_startproc
	b	_KGEN_CompilerRT_AsyncRT_GetOrCreateCPUDevice
	.cfi_endproc

	.p2align	2
_xir_run_closure_1:
	.cfi_startproc
	b	_KGEN_CompilerRT_AsyncRT_ReleaseCPUDevice
	.cfi_endproc

	.p2align	2
_xir_run_async_closure_2_resume:
	.cfi_startproc
	ldp	x8, x9, [x0, #48]
	ldr	x8, [x8]
	ldr	x9, [x9]
	ldp	x10, x11, [x0, #64]
	ldr	x10, [x10]
	ldr	x11, [x11]
	ldp	x12, x13, [x0, #80]
	ldr	x12, [x12]
	ldr	x13, [x13]
	ldp	x14, x15, [x0, #96]
	ldr	x14, [x14]
	ldr	x8, [x8]
	ldr	x9, [x9]
	ldr	x10, [x10]
	ldr	x11, [x11]
	ldr	x12, [x12]
	ldr	x13, [x13]
	ldr	s0, [x8, x15, lsl #2]
	ldr	x8, [x14]
	ldr	s1, [x9, x15, lsl #2]
	fmov	s2, #0.25000000
	fmov	s3, #-1.00000000
	fmadd	s0, s0, s2, s3
	fmov	s2, #0.50000000
	fcmp	s0, s2
	movi.2d	v2, #0000000000000000
	fmov	s3, #1.00000000
	fcsel	s3, s3, s2, gt
	fmul	s3, s0, s3
	fmaxnm	s4, s0, s2
	fmov	s5, #-4.00000000
	fadd	s1, s1, s5
	fmaxnm	s2, s1, s2
	fcvtzs	x9, s1
	and	x14, x9, #0x1
	cmp	x9, #0
	cneg	x14, x14, mi
	cmp	x14, #0
	ccmp	x9, #0, #0, ne
	mov	w9, #2
	csel	x9, x9, xzr, mi
	add	x9, x9, x14
	scvtf	s5, x9
	str	s0, [x10, x15, lsl #2]
	str	s3, [x11, x15, lsl #2]
	str	s4, [x12, x15, lsl #2]
	str	s2, [x13, x15, lsl #2]
	fmul	s0, s1, s5
	str	s0, [x8, x15, lsl #2]
	ldp	x1, x0, [x0, #16]
	br	x1
	.cfi_endproc

	.p2align	2
_xir_run_closure_3:
	ret

	.p2align	2
_xir_run_closure_4:
	.cfi_startproc
	ldr	x1, [x0, #8]
	br	x1
	.cfi_endproc

	.p2align	2
_xir_run_closure_5:
	.cfi_startproc
	b	_KGEN_CompilerRT_AlignedFree
	.cfi_endproc

	.section	__TEXT,__literal16,16byte_literals
	.p2align	4, 0x0
lCPI6_0:
	.quad	0
	.quad	2305843009213693952
lCPI6_1:
	.long	0x3f800000
	.long	0x40000000
	.long	0x40400000
	.long	0x40800000
lCPI6_2:
	.long	0x40a00000
	.long	0x40c00000
	.long	0x40e00000
	.long	0x41000000
lCPI6_3:
	.quad	3
	.quad	2305843009213693952
lCPI6_4:
	.quad	57
	.quad	2305843009213693952
lCPI6_5:
	.quad	15
	.quad	2305843009213693952
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_xir_run
	.p2align	2
_xir_run:
