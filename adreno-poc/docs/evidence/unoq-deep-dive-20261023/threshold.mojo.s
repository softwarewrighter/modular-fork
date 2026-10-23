	.file	"threshold.mojo"
	.text
	.globl	mojo_adreno_demo
	.p2align	2
	.prefalign	4, .Lfunc_end0, nop
	.type	mojo_adreno_demo,@function
mojo_adreno_demo:
.Lmojo_adreno_demo$local:
	.type	.Lmojo_adreno_demo$local,@function
	.cfi_startproc
	cmp	x3, #8
	b.ne	.LBB0_6
	stp	x30, x21, [sp, #-32]!
	stp	x20, x19, [sp, #16]
	.cfi_def_cfa_offset 32
	.cfi_offset w19, -8
	.cfi_offset w20, -16
	.cfi_offset w21, -24
	.cfi_offset w30, -32
	fmov	s0, #-1.00000000
	mov	x19, x2
	fmov	s1, #0.50000000
	mov	x20, x1
	movi	d2, #0000000000000000
	mov	x8, xzr
	fmov	s3, #1.00000000
	add	x21, x3, x3, lsl #1
	add	x9, x2, #64
	.p2align	4, , 8
.LBB0_2:
	mov	x10, x8
	add	x8, x8, #1
	ucvtf	s4, x8, #2
	fadd	s4, s4, s0
	fcmp	s4, s1
	str	s4, [x0, x10, lsl #2]
	fmaxnm	s6, s4, s2
	stur	s4, [x9, #-64]
	fcsel	s5, s3, s2, gt
	cmp	x8, #8
	fmul	s5, s4, s5
	stur	s5, [x9, #-32]
	str	s6, [x9], #4
	b.ne	.LBB0_2
	mov	x1, x20
	mov	w2, #8
	mov	x3, x21
	bl	adreno_threshold_v1
	cbnz	w0, .LBB0_5
	.p2align	4, , 8
.LBB0_4:
	ldr	s0, [x20], #4
	ldr	s1, [x19], #4
	fcmp	s0, s1
	cinc	w0, w0, ne
	subs	x21, x21, #1
	b.ne	.LBB0_4
.LBB0_5:
	ldp	x20, x19, [sp, #16]
	ldp	x30, x21, [sp], #32
	ret
.LBB0_6:
	mov	w0, #-1
	ret
.Lfunc_end0:
	.size	mojo_adreno_demo, .Lfunc_end0-mojo_adreno_demo
	.size	.Lmojo_adreno_demo$local, .Lfunc_end0-mojo_adreno_demo
	.cfi_endproc

	.section	".note.GNU-stack","",@progbits
