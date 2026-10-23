	.att_syntax
	.file	"accel-threshold.cpu.mojo"
	.section	.rodata.cst4,"aM",@progbits,4
	.p2align	2, 0x0
	.type	.LCPI0_0,@object
.LCPI0_0:
	.long	0x3e800000
	.size	.LCPI0_0, 4
	.type	.LCPI0_1,@object
.LCPI0_1:
	.long	0xbf800000
	.size	.LCPI0_1, 4
	.type	.LCPI0_2,@object
.LCPI0_2:
	.long	0x3f000000
	.size	.LCPI0_2, 4
	.type	.LCPI0_3,@object
.LCPI0_3:
	.long	0x3f800000
	.size	.LCPI0_3, 4
	.type	.LCPI0_4,@object
.LCPI0_4:
	.long	0xc0800000
	.size	.LCPI0_4, 4
	.text
	.globl	xir_cpu_stage0
	.prefalign	4, .Lfunc_end0, nop
	.type	xir_cpu_stage0,@function
xir_cpu_stage0:
.Lxir_cpu_stage0$local:
	.type	.Lxir_cpu_stage0$local,@function
	movq	24(%rsp), %rax
	movslq	16(%rsp), %r10
	cmpq	%r10, %rax
	jge	.LBB0_2
	movq	8(%rsp), %r10
	vmovss	(%rdi,%rax,4), %xmm0
	vmovss	(%rsi,%rax,4), %xmm1
	vmulss	.LCPI0_0(%rip), %xmm0, %xmm0
	vaddss	.LCPI0_1(%rip), %xmm0, %xmm0
	vcmpgtss	.LCPI0_2(%rip), %xmm0, %k1
	vmovss	.LCPI0_3(%rip), %xmm2 {%k1} {z}
	vmulss	%xmm2, %xmm0, %xmm2
	vxorps	%xmm3, %xmm3, %xmm3
	vaddss	.LCPI0_4(%rip), %xmm1, %xmm1
	vmaxss	%xmm3, %xmm0, %xmm4
	vcvttss2si	%xmm1, %rsi
	movq	%rsi, %rdi
	shrq	$63, %rdi
	addq	%rsi, %rdi
	andq	$-2, %rdi
	movq	%rsi, %r11
	subq	%rdi, %r11
	testq	%rsi, %rsi
	sets	%sil
	testq	%r11, %r11
	setne	%dil
	andb	%sil, %dil
	movzbl	%dil, %esi
	leaq	(%r11,%rsi,2), %rsi
	vcvtsi2ss	%rsi, %xmm15, %xmm5
	vmaxss	%xmm3, %xmm1, %xmm3
	vmulss	%xmm5, %xmm1, %xmm1
	vmovss	%xmm0, (%rdx,%rax,4)
	vmovss	%xmm2, (%rcx,%rax,4)
	vmovss	%xmm4, (%r8,%rax,4)
	vmovss	%xmm3, (%r9,%rax,4)
	vmovss	%xmm1, (%r10,%rax,4)
.LBB0_2:
	retq
.Lfunc_end0:
	.size	xir_cpu_stage0, .Lfunc_end0-xir_cpu_stage0
	.size	.Lxir_cpu_stage0$local, .Lfunc_end0-xir_cpu_stage0

	.section	.rodata.cst4,"aM",@progbits,4
	.p2align	2, 0x0
	.type	.LCPI1_0,@object
.LCPI1_0:
	.long	0x3e800000
	.size	.LCPI1_0, 4
	.type	.LCPI1_1,@object
.LCPI1_1:
	.long	0xbf800000
	.size	.LCPI1_1, 4
	.type	.LCPI1_2,@object
.LCPI1_2:
	.long	0x3f000000
	.size	.LCPI1_2, 4
	.type	.LCPI1_3,@object
.LCPI1_3:
	.long	0x3f800000
	.size	.LCPI1_3, 4
	.type	.LCPI1_4,@object
.LCPI1_4:
	.long	0xc0800000
	.size	.LCPI1_4, 4
	.type	.LCPI1_5,@object
.LCPI1_5:
	.long	0x7fffffff
	.size	.LCPI1_5, 4
	.type	.LCPI1_6,@object
.LCPI1_6:
	.long	0x38d1b717
	.size	.LCPI1_6, 4
	.type	.LCPI1_7,@object
.LCPI1_7:
	.long	0x358637bd
	.size	.LCPI1_7, 4
	.text
	.globl	main
	.prefalign	4, .Lfunc_end1, nop
	.type	main,@function
main:
.Lmain$local:
	.type	.Lmain$local,@function
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$4328, %rsp
	.cfi_def_cfa_offset 4384
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%rsi, %rbx
	movl	%edi, %ebp
	callq	KGEN_CompilerRT_AsyncRT_GetCurrentCPUDevice@PLT
	testq	%rax, %rax
	jne	.LBB1_2
	leaq	static_string_a61c3395ab9379d9(%rip), %rdi
	movq	"std::builtin::_startup::__wrap_and_execute_raising_main[def() raises thin -> None](::SIMD[DType.int32, 1],!kgen.pointer<pointer<scalar<ui8>>>),main_func=accel-threshold.cpu::main()_closure_0"@GOTPCREL(%rip), %rdx
	movq	"std::builtin::_startup::__wrap_and_execute_raising_main[def() raises thin -> None](::SIMD[DType.int32, 1],!kgen.pointer<pointer<scalar<ui8>>>),main_func=accel-threshold.cpu::main()_closure_1"@GOTPCREL(%rip), %rcx
	movl	$7, %esi
	callq	KGEN_CompilerRT_GetOrCreateGlobal@PLT
.LBB1_2:
	movl	%ebp, %edi
	movq	%rbx, %rsi
	callq	KGEN_CompilerRT_SetArgV@PLT
	callq	KGEN_CompilerRT_PrintStackTraceOnFault@PLT
	movl	$1065353216, 4(%rsp)
	movl	$1073741824, 8(%rsp)
	movl	$1077936128, 12(%rsp)
	movl	$1082130432, 16(%rsp)
	movl	$1084227584, 20(%rsp)
	movl	$1086324736, 24(%rsp)
	movl	$1088421888, 28(%rsp)
	movl	$1090519040, 32(%rsp)
	leaq	4(%rsp), %rax
	movq	%rax, 80(%rsp)
	leaq	8(%rsp), %rax
	movq	%rax, 88(%rsp)
	leaq	12(%rsp), %rax
	movq	%rax, 96(%rsp)
	leaq	16(%rsp), %rax
	movq	%rax, 104(%rsp)
	leaq	20(%rsp), %rax
	movq	%rax, 112(%rsp)
	leaq	24(%rsp), %rax
	movq	%rax, 120(%rsp)
	leaq	28(%rsp), %rax
	movq	%rax, 128(%rsp)
	leaq	32(%rsp), %rax
	movq	%rax, 136(%rsp)
	movl	$4, %edi
	movl	$32, %esi
	callq	KGEN_CompilerRT_AlignedAlloc@PLT
	testq	%rax, %rax
	je	.LBB1_99
	movq	%rax, %r15
	xorl	%eax, %eax
	.p2align	4
.LBB1_4:
	movq	80(%rsp,%rax,8), %rcx
	vmovss	(%rcx), %xmm0
	vmovss	%xmm0, (%r15,%rax,4)
	incq	%rax
	cmpq	$8, %rax
	jne	.LBB1_4
	movl	$1065353216, 156(%rsp)
	movl	$1073741824, 4(%rsp)
	movl	$1077936128, 8(%rsp)
	movl	$1082130432, 12(%rsp)
	movl	$1084227584, 16(%rsp)
	movl	$1086324736, 20(%rsp)
	movl	$1088421888, 24(%rsp)
	movl	$1090519040, 28(%rsp)
	leaq	156(%rsp), %rax
	movq	%rax, 216(%rsp)
	leaq	4(%rsp), %rax
	movq	%rax, 224(%rsp)
	leaq	8(%rsp), %rax
	movq	%rax, 232(%rsp)
	leaq	12(%rsp), %rax
	movq	%rax, 240(%rsp)
	leaq	16(%rsp), %rax
	movq	%rax, 248(%rsp)
	leaq	20(%rsp), %rax
	movq	%rax, 256(%rsp)
	leaq	24(%rsp), %rax
	movq	%rax, 264(%rsp)
	leaq	28(%rsp), %rax
	movq	%rax, 272(%rsp)
	movl	$4, %edi
	movl	$32, %esi
	callq	KGEN_CompilerRT_AlignedAlloc@PLT
	testq	%rax, %rax
	je	.LBB1_140
	movq	%rax, %rbx
	xorl	%eax, %eax
	.p2align	4
.LBB1_7:
	movq	216(%rsp,%rax,8), %rcx
	vmovss	(%rcx), %xmm0
	vmovss	%xmm0, (%rbx,%rax,4)
	incq	%rax
	cmpq	$8, %rax
	jne	.LBB1_7
	movl	$4, %edi
	movl	$8, %ecx
	xorl	%esi, %esi
	xorl	%edx, %edx
	callq	"std::collections::list::List::_realloc(::List[$0],::SIMD[DType.int, 1]){conforms_to($0, ::AnyType & ::Movable)},T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>]"@PLT
	movq	%rax, %r14
	movq	%rdx, 72(%rsp)
	leaq	-9(%rcx), %rax
	cmpq	$-2, %rax
	jg	.LBB1_10
	leaq	(%r14,%rcx,4), %rdi
	shlq	$2, %rcx
	movl	$32, %edx
	subq	%rcx, %rdx
	xorl	%esi, %esi
	callq	memset@PLT
.LBB1_10:
	movl	$4, %edi
	movl	$8, %ecx
	xorl	%esi, %esi
	xorl	%edx, %edx
	callq	"std::collections::list::List::_realloc(::List[$0],::SIMD[DType.int, 1]){conforms_to($0, ::AnyType & ::Movable)},T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>]"@PLT
	movq	%rax, %r13
	movq	%rdx, 64(%rsp)
	leaq	-9(%rcx), %rax
	cmpq	$-2, %rax
	jg	.LBB1_12
	leaq	(,%rcx,4), %rdi
	addq	%r13, %rdi
	shlq	$2, %rcx
	movl	$32, %edx
	subq	%rcx, %rdx
	xorl	%esi, %esi
	callq	memset@PLT
.LBB1_12:
	movl	$4, %edi
	movl	$8, %ecx
	xorl	%esi, %esi
	xorl	%edx, %edx
	callq	"std::collections::list::List::_realloc(::List[$0],::SIMD[DType.int, 1]){conforms_to($0, ::AnyType & ::Movable)},T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>]"@PLT
	movq	%rax, %rbp
	movq	%rdx, 144(%rsp)
	leaq	-9(%rcx), %rax
	cmpq	$-2, %rax
	jg	.LBB1_14
	leaq	(,%rcx,4), %rdi
	addq	%rbp, %rdi
	shlq	$2, %rcx
	movl	$32, %edx
	subq	%rcx, %rdx
	xorl	%esi, %esi
	callq	memset@PLT
.LBB1_14:
	movl	$4, %edi
	movl	$8, %ecx
	xorl	%esi, %esi
	xorl	%edx, %edx
	callq	"std::collections::list::List::_realloc(::List[$0],::SIMD[DType.int, 1]){conforms_to($0, ::AnyType & ::Movable)},T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>]"@PLT
	movq	%rax, %r12
	movq	%rdx, 168(%rsp)
	leaq	-9(%rcx), %rax
	cmpq	$-2, %rax
	jg	.LBB1_16
	leaq	(%r12,%rcx,4), %rdi
	shlq	$2, %rcx
	movl	$32, %edx
	subq	%rcx, %rdx
	xorl	%esi, %esi
	callq	memset@PLT
.LBB1_16:
	movl	$4, %edi
	movl	$8, %ecx
	xorl	%esi, %esi
	xorl	%edx, %edx
	callq	"std::collections::list::List::_realloc(::List[$0],::SIMD[DType.int, 1]){conforms_to($0, ::AnyType & ::Movable)},T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>]"@PLT
	movq	%rdx, 160(%rsp)
	leaq	-9(%rcx), %rdx
	cmpq	$-2, %rdx
	movq	%rax, 56(%rsp)
	jg	.LBB1_18
	movq	56(%rsp), %rax
	leaq	(%rax,%rcx,4), %rdi
	shlq	$2, %rcx
	movl	$32, %edx
	subq	%rcx, %rdx
	xorl	%esi, %esi
	callq	memset@PLT
	movq	56(%rsp), %rax
.LBB1_18:
	vmovss	.LCPI1_0(%rip), %xmm0
	vmovss	.LCPI1_1(%rip), %xmm1
	xorl	%edi, %edi
	vmovss	.LCPI1_2(%rip), %xmm2
	vxorps	%xmm3, %xmm3, %xmm3
	vmovss	.LCPI1_4(%rip), %xmm4
	.p2align	4
.LBB1_19:
	vmulss	(%r15,%rdi), %xmm0, %xmm5
	vaddss	%xmm1, %xmm5, %xmm5
	vcmpgtss	%xmm2, %xmm5, %k1
	vmovss	.LCPI1_3(%rip), %xmm6 {%k1} {z}
	vmulss	%xmm6, %xmm5, %xmm6
	vmaxss	%xmm3, %xmm5, %xmm7
	vaddss	(%rbx,%rdi), %xmm4, %xmm8
	vmaxss	%xmm3, %xmm8, %xmm9
	vcvttss2si	%xmm8, %rcx
	movq	%rcx, %rdx
	shrq	$63, %rdx
	addq	%rcx, %rdx
	andq	$-2, %rdx
	movq	%rcx, %rsi
	subq	%rdx, %rsi
	testq	%rcx, %rcx
	sets	%cl
	testq	%rsi, %rsi
	setne	%dl
	andb	%cl, %dl
	movzbl	%dl, %ecx
	leaq	(%rsi,%rcx,2), %rcx
	vcvtsi2ss	%rcx, %xmm15, %xmm10
	vmulss	%xmm10, %xmm8, %xmm8
	vmovss	%xmm5, (%r14,%rdi)
	vmovss	%xmm6, (%r13,%rdi)
	vmovss	%xmm7, (%rbp,%rdi)
	vmovss	%xmm9, (%r12,%rdi)
	vmovss	%xmm8, (%rax,%rdi)
	addq	$4, %rdi
	cmpq	$32, %rdi
	jne	.LBB1_19
	movq	%rbx, %rdi
	callq	KGEN_CompilerRT_AlignedFree@PLT
	movq	%r15, %rdi
	callq	KGEN_CompilerRT_AlignedFree@PLT
	movl	$-1086324736, 4(%rsp)
	movl	$-1090519040, 8(%rsp)
	movl	$-1098907648, 12(%rsp)
	movl	$0, 16(%rsp)
	movl	$1048576000, 20(%rsp)
	movl	$1056964608, 24(%rsp)
	movl	$1061158912, 28(%rsp)
	movl	$1065353216, 32(%rsp)
	leaq	4(%rsp), %rax
	movq	%rax, 216(%rsp)
	leaq	8(%rsp), %rax
	movq	%rax, 224(%rsp)
	leaq	12(%rsp), %rax
	movq	%rax, 232(%rsp)
	leaq	16(%rsp), %rax
	movq	%rax, 240(%rsp)
	leaq	20(%rsp), %rax
	movq	%rax, 248(%rsp)
	leaq	24(%rsp), %rax
	movq	%rax, 256(%rsp)
	leaq	28(%rsp), %rax
	movq	%rax, 264(%rsp)
	leaq	32(%rsp), %rax
	movq	%rax, 272(%rsp)
	movl	$4, %edi
	movl	$32, %esi
	callq	KGEN_CompilerRT_AlignedAlloc@PLT
	testq	%rax, %rax
	je	.LBB1_141
	movq	%rax, %rbx
	xorl	%eax, %eax
	.p2align	4
.LBB1_22:
	movq	216(%rsp,%rax,8), %rcx
	vmovss	(%rcx), %xmm0
	vmovss	%xmm0, (%rbx,%rax,4)
	incq	%rax
	cmpq	$8, %rax
	jne	.LBB1_22
	movabsq	$2305843009213693952, %rcx
	movq	$12, 224(%rsp)
	leaq	static_string_6c4bc3d6af8b4e6e(%rip), %rax
	movq	%rax, 216(%rsp)
	movq	%rcx, 232(%rsp)
	leaq	static_string_bbe01a6a523daf15(%rip), %rax
	leaq	static_string_a8d4ace0dc8d360e(%rip), %r8
	leaq	216(%rsp), %rdi
	movl	$8, %ecx
	movl	$1, %r9d
	movq	%r14, %rsi
	movq	72(%rsp), %rdx
	pushq	$1
	.cfi_adjust_cfa_offset 8
	pushq	$0
	.cfi_adjust_cfa_offset 8
	pushq	$1
	.cfi_adjust_cfa_offset 8
	pushq	%rax
	.cfi_adjust_cfa_offset 8
	callq	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::collections::list::List,T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>]>>, struct<(struct<(pointer<none>, scalar<index>)>, scalar<index>) memoryOnly>]]"@PLT
	addq	$32, %rsp
	.cfi_adjust_cfa_offset -32
	testb	$64, 239(%rsp)
	je	.LBB1_26
	movq	216(%rsp), %rdi
	lock		decq	-8(%rdi)
	jne	.LBB1_26
	addq	$-8, %rdi
	#MEMBARRIER
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB1_26:
	vbroadcastss	.LCPI1_5(%rip), %xmm2
	xorl	%r15d, %r15d
	xorl	%eax, %eax
	.p2align	4
.LBB1_27:
	vmovss	(%r14,%rax,4), %xmm0
	vmovss	(%rbx,%rax,4), %xmm1
	incq	%rax
	vsubss	%xmm1, %xmm0, %xmm0
	vandps	%xmm2, %xmm0, %xmm0
	vandps	%xmm2, %xmm1, %xmm1
	vmulss	.LCPI1_6(%rip), %xmm1, %xmm1
	vmaxss	.LCPI1_7(%rip), %xmm1, %xmm1
	vucomiss	%xmm0, %xmm1
	adcq	$0, %r15
	cmpq	$8, %rax
	jne	.LBB1_27
	movq	%rbx, %rdi
	callq	KGEN_CompilerRT_AlignedFree@PLT
	cmpq	$0, 72(%rsp)
	jle	.LBB1_30
	movq	%r14, %rdi
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB1_30:
	movl	$-2147483648, 4(%rsp)
	movl	$-2147483648, 8(%rsp)
	movl	$-2147483648, 12(%rsp)
	movl	$0, 16(%rsp)
	movl	$0, 20(%rsp)
	movl	$0, 24(%rsp)
	movl	$1061158912, 28(%rsp)
	movl	$1065353216, 32(%rsp)
	leaq	4(%rsp), %rax
	movq	%rax, 216(%rsp)
	leaq	8(%rsp), %rax
	movq	%rax, 224(%rsp)
	leaq	12(%rsp), %rax
	movq	%rax, 232(%rsp)
	leaq	16(%rsp), %rax
	movq	%rax, 240(%rsp)
	leaq	20(%rsp), %rax
	movq	%rax, 248(%rsp)
	leaq	24(%rsp), %rax
	movq	%rax, 256(%rsp)
	leaq	28(%rsp), %rax
	movq	%rax, 264(%rsp)
	leaq	32(%rsp), %rax
	movq	%rax, 272(%rsp)
	movl	$4, %edi
	movl	$32, %esi
	callq	KGEN_CompilerRT_AlignedAlloc@PLT
	testq	%rax, %rax
	je	.LBB1_141
	movq	%rax, %rbx
	xorl	%eax, %eax
	movabsq	$2305843009213693952, %r14
	.p2align	4
.LBB1_32:
	movq	216(%rsp,%rax,8), %rcx
	vmovss	(%rcx), %xmm0
	vmovss	%xmm0, (%rbx,%rax,4)
	incq	%rax
	cmpq	$8, %rax
	jne	.LBB1_32
	movq	$12, 224(%rsp)
	leaq	static_string_8139647b818ca978(%rip), %rax
	movq	%rax, 216(%rsp)
	movq	%r14, 232(%rsp)
	leaq	static_string_a8d4ace0dc8d360e(%rip), %r8
	leaq	216(%rsp), %rdi
	movl	$8, %ecx
	movl	$1, %r9d
	movq	%r13, %rsi
	movq	64(%rsp), %rdx
	pushq	$1
	.cfi_adjust_cfa_offset 8
	pushq	$0
	.cfi_adjust_cfa_offset 8
	pushq	$1
	.cfi_adjust_cfa_offset 8
	leaq	static_string_bbe01a6a523daf15(%rip), %rax
	pushq	%rax
	.cfi_adjust_cfa_offset 8
	callq	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::collections::list::List,T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>]>>, struct<(struct<(pointer<none>, scalar<index>)>, scalar<index>) memoryOnly>]]"@PLT
	addq	$32, %rsp
	.cfi_adjust_cfa_offset -32
	movabsq	$4611686018427387904, %rax
	testq	%rax, 232(%rsp)
	je	.LBB1_36
	movq	216(%rsp), %rdi
	lock		decq	-8(%rdi)
	jne	.LBB1_36
	addq	$-8, %rdi
	#MEMBARRIER
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB1_36:
	xorl	%eax, %eax
	vbroadcastss	.LCPI1_5(%rip), %xmm2
	vmovss	.LCPI1_6(%rip), %xmm3
	vmovss	.LCPI1_7(%rip), %xmm4
	.p2align	4
.LBB1_37:
	vmovss	(%r13,%rax,4), %xmm0
	vmovss	(%rbx,%rax,4), %xmm1
	incq	%rax
	vsubss	%xmm1, %xmm0, %xmm0
	vandps	%xmm2, %xmm0, %xmm0
	vandps	%xmm2, %xmm1, %xmm1
	vmulss	%xmm3, %xmm1, %xmm1
	vmaxss	%xmm4, %xmm1, %xmm1
	vucomiss	%xmm0, %xmm1
	adcq	$0, %r15
	cmpq	$8, %rax
	jne	.LBB1_37
	movq	%rbx, %rdi
	callq	KGEN_CompilerRT_AlignedFree@PLT
	cmpq	$0, 64(%rsp)
	jle	.LBB1_40
	movq	%r13, %rdi
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB1_40:
	movl	$0, 4(%rsp)
	movl	$0, 8(%rsp)
	movl	$0, 12(%rsp)
	movl	$0, 16(%rsp)
	movl	$1048576000, 20(%rsp)
	movl	$1056964608, 24(%rsp)
	movl	$1061158912, 28(%rsp)
	movl	$1065353216, 32(%rsp)
	leaq	4(%rsp), %rax
	movq	%rax, 216(%rsp)
	leaq	8(%rsp), %rax
	movq	%rax, 224(%rsp)
	leaq	12(%rsp), %rax
	movq	%rax, 232(%rsp)
	leaq	16(%rsp), %rax
	movq	%rax, 240(%rsp)
	leaq	20(%rsp), %rax
	movq	%rax, 248(%rsp)
	leaq	24(%rsp), %rax
	movq	%rax, 256(%rsp)
	leaq	28(%rsp), %rax
	movq	%rax, 264(%rsp)
	leaq	32(%rsp), %rax
	movq	%rax, 272(%rsp)
	movl	$4, %edi
	movl	$32, %esi
	callq	KGEN_CompilerRT_AlignedAlloc@PLT
	testq	%rax, %rax
	je	.LBB1_81
	movq	%rax, %rbx
	xorl	%eax, %eax
	.p2align	4
.LBB1_42:
	movq	216(%rsp,%rax,8), %rcx
	vmovss	(%rcx), %xmm0
	vmovss	%xmm0, (%rbx,%rax,4)
	incq	%rax
	cmpq	$8, %rax
	jne	.LBB1_42
	movq	$12, 224(%rsp)
	leaq	static_string_cccd1b860a827236(%rip), %rax
	movq	%rax, 216(%rsp)
	movq	%r14, 232(%rsp)
	leaq	static_string_a8d4ace0dc8d360e(%rip), %r8
	leaq	216(%rsp), %rdi
	movl	$8, %ecx
	movl	$1, %r9d
	movq	%rbp, %rsi
	movq	144(%rsp), %rdx
	pushq	$1
	.cfi_adjust_cfa_offset 8
	pushq	$0
	.cfi_adjust_cfa_offset 8
	pushq	$1
	.cfi_adjust_cfa_offset 8
	leaq	static_string_bbe01a6a523daf15(%rip), %rax
	pushq	%rax
	.cfi_adjust_cfa_offset 8
	callq	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::collections::list::List,T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>]>>, struct<(struct<(pointer<none>, scalar<index>)>, scalar<index>) memoryOnly>]]"@PLT
	addq	$32, %rsp
	.cfi_adjust_cfa_offset -32
	movabsq	$4611686018427387904, %r13
	testq	%r13, 232(%rsp)
	je	.LBB1_46
	movq	216(%rsp), %rdi
	lock		decq	-8(%rdi)
	jne	.LBB1_46
	addq	$-8, %rdi
	#MEMBARRIER
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB1_46:
	xorl	%eax, %eax
	vbroadcastss	.LCPI1_5(%rip), %xmm2
	vmovss	.LCPI1_6(%rip), %xmm3
	vmovss	.LCPI1_7(%rip), %xmm4
	.p2align	4
.LBB1_47:
	vmovss	(%rbp,%rax,4), %xmm0
	vmovss	(%rbx,%rax,4), %xmm1
	incq	%rax
	vsubss	%xmm1, %xmm0, %xmm0
	vandps	%xmm2, %xmm0, %xmm0
	vandps	%xmm2, %xmm1, %xmm1
	vmulss	%xmm3, %xmm1, %xmm1
	vmaxss	%xmm4, %xmm1, %xmm1
	vucomiss	%xmm0, %xmm1
	adcq	$0, %r15
	cmpq	$8, %rax
	jne	.LBB1_47
	movq	%rbx, %rdi
	callq	KGEN_CompilerRT_AlignedFree@PLT
	cmpq	$0, 144(%rsp)
	jle	.LBB1_50
	movq	%rbp, %rdi
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB1_50:
	movl	$0, 4(%rsp)
	movl	$0, 8(%rsp)
	movl	$0, 12(%rsp)
	movl	$0, 16(%rsp)
	movl	$1065353216, 20(%rsp)
	movl	$1073741824, 24(%rsp)
	movl	$1077936128, 28(%rsp)
	movl	$1082130432, 32(%rsp)
	leaq	4(%rsp), %rax
	movq	%rax, 216(%rsp)
	leaq	8(%rsp), %rax
	movq	%rax, 224(%rsp)
	leaq	12(%rsp), %rax
	movq	%rax, 232(%rsp)
	leaq	16(%rsp), %rax
	movq	%rax, 240(%rsp)
	leaq	20(%rsp), %rax
	movq	%rax, 248(%rsp)
	leaq	24(%rsp), %rax
	movq	%rax, 256(%rsp)
	leaq	28(%rsp), %rax
	movq	%rax, 264(%rsp)
	leaq	32(%rsp), %rax
	movq	%rax, 272(%rsp)
	movl	$4, %edi
	movl	$32, %esi
	callq	KGEN_CompilerRT_AlignedAlloc@PLT
	testq	%rax, %rax
	je	.LBB1_81
	movq	%rax, %rbx
	xorl	%eax, %eax
	.p2align	4
.LBB1_52:
	movq	216(%rsp,%rax,8), %rcx
	vmovss	(%rcx), %xmm0
	vmovss	%xmm0, (%rbx,%rax,4)
	incq	%rax
	cmpq	$8, %rax
	jne	.LBB1_52
	movq	$14, 224(%rsp)
	leaq	static_string_2874a0219404abcb(%rip), %rax
	movq	%rax, 216(%rsp)
	movq	%r14, 232(%rsp)
	leaq	static_string_a8d4ace0dc8d360e(%rip), %r8
	leaq	216(%rsp), %rdi
	movl	$8, %ecx
	movl	$1, %r9d
	movq	%r12, %rsi
	movq	168(%rsp), %rbp
	movq	%rbp, %rdx
	pushq	$1
	.cfi_adjust_cfa_offset 8
	pushq	$0
	.cfi_adjust_cfa_offset 8
	pushq	$1
	.cfi_adjust_cfa_offset 8
	leaq	static_string_bbe01a6a523daf15(%rip), %rax
	pushq	%rax
	.cfi_adjust_cfa_offset 8
	callq	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::collections::list::List,T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>]>>, struct<(struct<(pointer<none>, scalar<index>)>, scalar<index>) memoryOnly>]]"@PLT
	addq	$32, %rsp
	.cfi_adjust_cfa_offset -32
	testq	%r13, 232(%rsp)
	je	.LBB1_56
	movq	216(%rsp), %rdi
	lock		decq	-8(%rdi)
	jne	.LBB1_56
	addq	$-8, %rdi
	#MEMBARRIER
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB1_56:
	xorl	%eax, %eax
	.p2align	4
.LBB1_57:
	vmovss	(%r12,%rax,4), %xmm0
	vcmpneqss	(%rbx,%rax,4), %xmm0, %k0
	incq	%rax
	kmovw	%k0, %ecx
	addq	%rcx, %r15
	cmpq	$8, %rax
	jne	.LBB1_57
	movq	%rbx, %rdi
	callq	KGEN_CompilerRT_AlignedFree@PLT
	testq	%rbp, %rbp
	jle	.LBB1_60
	movq	%r12, %rdi
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB1_60:
	movl	$-1069547520, 4(%rsp)
	movl	$0, 8(%rsp)
	movl	$-1082130432, 12(%rsp)
	movl	$0, 16(%rsp)
	movl	$1065353216, 20(%rsp)
	movl	$0, 24(%rsp)
	movl	$1077936128, 28(%rsp)
	movl	$0, 32(%rsp)
	leaq	4(%rsp), %rax
	movq	%rax, 216(%rsp)
	leaq	8(%rsp), %rax
	movq	%rax, 224(%rsp)
	leaq	12(%rsp), %rax
	movq	%rax, 232(%rsp)
	leaq	16(%rsp), %rax
	movq	%rax, 240(%rsp)
	leaq	20(%rsp), %rax
	movq	%rax, 248(%rsp)
	leaq	24(%rsp), %rax
	movq	%rax, 256(%rsp)
	leaq	28(%rsp), %rax
	movq	%rax, 264(%rsp)
	leaq	32(%rsp), %rax
	movq	%rax, 272(%rsp)
	movl	$4, %edi
	movl	$32, %esi
	callq	KGEN_CompilerRT_AlignedAlloc@PLT
	testq	%rax, %rax
	je	.LBB1_81
	movq	%rax, %rbx
	xorl	%eax, %eax
	.p2align	4
.LBB1_62:
	movq	216(%rsp,%rax,8), %rcx
	vmovss	(%rcx), %xmm0
	vmovss	%xmm0, (%rbx,%rax,4)
	incq	%rax
	cmpq	$8, %rax
	jne	.LBB1_62
	movq	$14, 224(%rsp)
	leaq	static_string_837040b3bb6a25ae(%rip), %rax
	movq	%rax, 216(%rsp)
	movq	%r14, 232(%rsp)
	leaq	static_string_a8d4ace0dc8d360e(%rip), %r8
	leaq	216(%rsp), %rdi
	movl	$8, %ecx
	movl	$1, %r9d
	movq	56(%rsp), %rsi
	movq	160(%rsp), %r12
	movq	%r12, %rdx
	pushq	$1
	.cfi_adjust_cfa_offset 8
	pushq	$0
	.cfi_adjust_cfa_offset 8
	pushq	$1
	.cfi_adjust_cfa_offset 8
	leaq	static_string_bbe01a6a523daf15(%rip), %rax
	pushq	%rax
	.cfi_adjust_cfa_offset 8
	callq	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::collections::list::List,T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>]>>, struct<(struct<(pointer<none>, scalar<index>)>, scalar<index>) memoryOnly>]]"@PLT
	addq	$32, %rsp
	.cfi_adjust_cfa_offset -32
	testq	%r13, 232(%rsp)
	je	.LBB1_66
	movq	216(%rsp), %rdi
	lock		decq	-8(%rdi)
	jne	.LBB1_66
	addq	$-8, %rdi
	#MEMBARRIER
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB1_66:
	xorl	%eax, %eax
	movq	56(%rsp), %rdx
	.p2align	4
.LBB1_67:
	vmovss	(%rdx,%rax,4), %xmm0
	vcmpneqss	(%rbx,%rax,4), %xmm0, %k0
	incq	%rax
	kmovw	%k0, %ecx
	addq	%rcx, %r15
	cmpq	$8, %rax
	jne	.LBB1_67
	movq	%rbx, %rdi
	callq	KGEN_CompilerRT_AlignedFree@PLT
	testq	%r12, %r12
	jle	.LBB1_70
	movq	56(%rsp), %rdi
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB1_70:
	movq	$17, 224(%rsp)
	leaq	static_string_b06715244581a357(%rip), %rax
	movq	%rax, 216(%rsp)
	movq	%r14, 232(%rsp)
	leaq	static_string_bbe01a6a523daf15(%rip), %rsi
	leaq	216(%rsp), %rdi
	movl	$1, %edx
	xorl	%ecx, %ecx
	movl	$1, %r8d
	callq	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]]"@PLT
	testq	%r13, 232(%rsp)
	je	.LBB1_73
	movq	216(%rsp), %rdi
	lock		decq	-8(%rdi)
	jne	.LBB1_73
	addq	$-8, %rdi
	#MEMBARRIER
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB1_73:
	movq	$7, 88(%rsp)
	leaq	static_string_c4c7be18a607e1c2(%rip), %rax
	movq	%rax, 80(%rsp)
	movq	%r14, 96(%rsp)
	movq	$19, 224(%rsp)
	leaq	static_string_baad52a56e0acbcf(%rip), %rax
	movq	%rax, 216(%rsp)
	movq	%r14, 232(%rsp)
	subq	$8, %rsp
	.cfi_adjust_cfa_offset 8
	leaq	static_string_a8d4ace0dc8d360e(%rip), %rcx
	leaq	static_string_bbe01a6a523daf15(%rip), %r9
	leaq	88(%rsp), %r14
	leaq	224(%rsp), %rbx
	movl	$1, %r8d
	movq	%r14, %rdi
	movq	%r15, %rsi
	movq	%rbx, %rdx
	pushq	$1
	.cfi_adjust_cfa_offset 8
	pushq	$0
	.cfi_adjust_cfa_offset 8
	pushq	$1
	.cfi_adjust_cfa_offset 8
	callq	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]]"@PLT
	addq	$32, %rsp
	.cfi_adjust_cfa_offset -32
	testq	%r13, 232(%rsp)
	je	.LBB1_76
	movq	216(%rsp), %rdi
	lock		decq	-8(%rdi)
	jne	.LBB1_76
	addq	$-8, %rdi
	#MEMBARRIER
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB1_76:
	testq	%r13, 96(%rsp)
	je	.LBB1_79
	movq	80(%rsp), %rdi
	lock		decq	-8(%rdi)
	jne	.LBB1_79
	addq	$-8, %rdi
	#MEMBARRIER
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB1_79:
	testq	%r15, %r15
	je	.LBB1_80
	movq	$32, 184(%rsp)
	leaq	static_string_ad918d8eb07d6197(%rip), %rax
	movq	%rax, 176(%rsp)
	movabsq	$2305843009213693952, %rax
	movq	%rax, 192(%rsp)
	xorl	%edi, %edi
	callq	"std::builtin::error::StackTrace::collect_if_enabled(::SIMD[DType.int, 1])"@PLT
	movq	%rax, 200(%rsp)
	movb	%dl, 208(%rsp)
	testb	%dl, %dl
	je	.LBB1_86
	movabsq	$9223372036854775807, %r15
	movq	16(%rax), %rsi
	xorl	%r12d, %r12d
	.p2align	4
.LBB1_88:
	cmpb	$0, (%rsi,%r12)
	je	.LBB1_90
	incq	%r12
	cmpq	%r12, %r15
	jne	.LBB1_88
.LBB1_97:
	movq	$36, 224(%rsp)
	leaq	static_string_30948303dbd8bc48(%rip), %rax
	movq	%rax, 216(%rsp)
	movabsq	$2305843009213693952, %rax
	movq	%rax, 232(%rsp)
	leaq	static_string_ede496b2d17dd639(%rip), %rdx
	leaq	216(%rsp), %r8
	movl	$888, %edi
	movl	$14, %esi
	movl	$33, %ecx
	callq	"std::os::os::_abort_report[::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],::Writable & ::AnyType](::SourceLocation,$1),prefix={ #interp.memref<{[(#interp.memory_handle<16, ~QABORT:\\00~Q string>, const_global, [], [])], []}, 0, 0>, 6 },message.T`=[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]"@PLT
	ud2
.LBB1_90:
	cmpq	$23, %r12
	ja	.LBB1_96
	vxorps	%xmm0, %xmm0, %xmm0
	vmovaps	%xmm0, 80(%rsp)
	leaq	1(%r15), %rax
	movq	%rax, 96(%rsp)
	xorl	%edx, %edx
	.p2align	4
.LBB1_92:
	cmpb	$0, (%rsi,%rdx)
	je	.LBB1_95
	incq	%rdx
	cmpq	%rdx, %r15
	jne	.LBB1_92
	movq	%r15, %rdx
.LBB1_95:
	leaq	80(%rsp), %rdi
	jmp	.LBB1_121
.LBB1_80:
	callq	KGEN_CompilerRT_DestroyGlobals@PLT
	xorl	%eax, %eax
	jmp	.LBB1_139
.LBB1_86:
	movl	$0, 56(%rsp)
	xorl	%edi, %edi
	xorl	%r8d, %r8d
	xorl	%edx, %edx
	xorl	%r10d, %r10d
	xorl	%r11d, %r11d
	movl	$0, 64(%rsp)
	xorl	%ebx, %ebx
	xorl	%ebp, %ebp
	xorl	%ecx, %ecx
	xorl	%r9d, %r9d
	xorl	%r12d, %r12d
	xorl	%r15d, %r15d
	xorl	%r14d, %r14d
	movq	$0, 72(%rsp)
	jmp	.LBB1_122
.LBB1_96:
	addq	$7, %r12
	movq	%r12, %rsi
	andq	$-8, %rsi
	addq	$8, %rsi
	js	.LBB1_97
	movq	%rax, %r13
	movl	$1, %edi
	callq	KGEN_CompilerRT_AlignedAlloc@PLT
	testq	%rax, %rax
	je	.LBB1_99
	sarq	$3, %r12
	movq	$1, (%rax)
	addq	$8, %rax
	movq	%rax, 80(%rsp)
	movq	$0, 88(%rsp)
	movabsq	$4611686018427387904, %rax
	orq	%rax, %r12
	movq	%r12, 96(%rsp)
	movq	$0, 4312(%rsp)
	movq	%r14, 4320(%rsp)
	movq	16(%r13), %rsi
	xorl	%edx, %edx
	.p2align	4
.LBB1_101:
	cmpb	$0, (%rsi,%rdx)
	je	.LBB1_103
	incq	%rdx
	cmpq	%rdx, %r15
	jne	.LBB1_101
	jmp	.LBB1_105
.LBB1_103:
	cmpq	$4097, %rdx
	jb	.LBB1_106
	movq	%rdx, %r15
.LBB1_105:
	movq	%r14, %rdi
	movq	%r15, %rdx
	callq	"std::collections::string::string::String::_iadd[LITImmOrigin,::Origin[False, $0]](::String,::Span[False, $0, ::SIMD[DType.uint8, 1], $1, AddressSpace.GENERIC])"@PLT
	xorl	%edx, %edx
.LBB1_120:
	movq	%r14, %rdi
	movq	%rbx, %rsi
.LBB1_121:
	callq	"std::collections::string::string::String::_iadd[LITImmOrigin,::Origin[False, $0]](::String,::Span[False, $0, ::SIMD[DType.uint8, 1], $1, AddressSpace.GENERIC])"@PLT
	movq	88(%rsp), %rax
	movq	96(%rsp), %r13
	movl	%eax, %r12d
	shrl	$8, %r12d
	movl	%eax, %esi
	shrl	$16, %esi
	movl	%esi, 56(%rsp)
	movl	%eax, %edi
	shrl	$24, %edi
	movq	%rax, %r8
	shrq	$32, %r8
	movq	%rax, %rdx
	shrq	$40, %rdx
	movq	%rax, %r10
	shrq	$48, %r10
	movq	%rax, %r11
	shrq	$56, %r11
	movl	%r13d, %ecx
	shrl	$8, %ecx
	movl	%ecx, 64(%rsp)
	movl	%r13d, %ebx
	shrl	$16, %ebx
	movl	%r13d, %ebp
	shrl	$24, %ebp
	movq	%r13, %rcx
	shrq	$32, %rcx
	movq	%r13, %r9
	shrq	$40, %r9
	movq	%r13, %r15
	shrq	$48, %r15
	movq	%r13, %r14
	shrq	$56, %r14
	movq	80(%rsp), %rsi
	movq	%rsi, 144(%rsp)
	movb	$1, %sil
	movq	%rsi, 72(%rsp)
.LBB1_122:
	movq	144(%rsp), %rsi
	movq	%rsi, 32(%rsp)
	movb	%al, 40(%rsp)
	movb	%r12b, 41(%rsp)
	movl	56(%rsp), %eax
	movb	%al, 42(%rsp)
	movb	%dil, 43(%rsp)
	movb	%r8b, 44(%rsp)
	movb	%dl, 45(%rsp)
	movb	%r10b, 46(%rsp)
	movb	%r11b, 47(%rsp)
	movb	%r13b, 48(%rsp)
	movl	64(%rsp), %eax
	movb	%al, 49(%rsp)
	movb	%bl, 50(%rsp)
	movb	%bpl, 51(%rsp)
	movb	%cl, 52(%rsp)
	movb	%r9b, 53(%rsp)
	movb	%r15b, 54(%rsp)
	movb	%r14b, 55(%rsp)
	movq	72(%rsp), %rbx
	testb	%bl, %bl
	je	.LBB1_123
	leaq	static_string_bbe01a6a523daf15(%rip), %rsi
	leaq	32(%rsp), %rdi
	movl	$1, %edx
	xorl	%ecx, %ecx
	movl	$2, %r8d
	callq	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]]"@PLT
	cmpb	$1, %bl
	movabsq	$2305843009213693952, %rbx
	movabsq	$4611686018427387904, %r14
	jne	.LBB1_130
	testq	%r14, 48(%rsp)
	je	.LBB1_130
	movq	32(%rsp), %rdi
	lock		decq	-8(%rdi)
	je	.LBB1_129
	jmp	.LBB1_130
.LBB1_123:
	movq	$123, 224(%rsp)
	leaq	static_string_fbe1ca471a988c5b(%rip), %rax
	movq	%rax, 216(%rsp)
	movabsq	$2305843009213693952, %rbx
	movq	%rbx, 232(%rsp)
	leaq	static_string_bbe01a6a523daf15(%rip), %rsi
	leaq	216(%rsp), %rdi
	movl	$1, %edx
	xorl	%ecx, %ecx
	movl	$2, %r8d
	callq	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]]"@PLT
	movabsq	$4611686018427387904, %r14
	testq	%r14, 232(%rsp)
	je	.LBB1_130
	movq	216(%rsp), %rdi
	lock		decq	-8(%rdi)
	jne	.LBB1_130
.LBB1_129:
	addq	$-8, %rdi
	#MEMBARRIER
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB1_130:
	movq	$44, 224(%rsp)
	leaq	static_string_26a85fbdc19bc0a1(%rip), %rax
	movq	%rax, 216(%rsp)
	movq	%rbx, 232(%rsp)
	leaq	static_string_a8d4ace0dc8d360e(%rip), %rdx
	leaq	static_string_bbe01a6a523daf15(%rip), %r8
	leaq	216(%rsp), %rdi
	leaq	176(%rsp), %rsi
	movl	$1, %ecx
	movl	$1, %r9d
	pushq	$2
	.cfi_adjust_cfa_offset 8
	pushq	$0
	.cfi_adjust_cfa_offset 8
	callq	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::builtin::error::Error>>, struct<(struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>, struct<(struct<(struct<(variant<struct<()>, struct<(pointer<none>) memoryOnly>>) memoryOnly>) memoryOnly>) memoryOnly>) memoryOnly>]]"@PLT
	addq	$16, %rsp
	.cfi_adjust_cfa_offset -16
	testq	%r14, 232(%rsp)
	je	.LBB1_133
	movq	216(%rsp), %rdi
	lock		decq	-8(%rdi)
	jne	.LBB1_133
	addq	$-8, %rdi
	#MEMBARRIER
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB1_133:
	testq	%r14, 192(%rsp)
	je	.LBB1_136
	movq	176(%rsp), %rdi
	lock		decq	-8(%rdi)
	jne	.LBB1_136
	addq	$-8, %rdi
	#MEMBARRIER
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB1_136:
	cmpb	$1, 208(%rsp)
	jne	.LBB1_138
	movq	200(%rsp), %rdi
	callq	"std::memory::arc_pointer::ArcPointer::__deinit__(::ArcPointer[$0]$),T=[typevalue<#kgen.instref<std::memory::owned_pointer::OwnedPointer,T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=ui8,length=1>>, scalar<ui8>]>>, pointer<none>]"@PLT
.LBB1_138:
	movl	$1, %eax
.LBB1_139:
	addq	$4328, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB1_106:
	.cfi_def_cfa_offset 4384
	testq	%rdx, %rdx
	je	.LBB1_118
	cmpq	$4, %rdx
	ja	.LBB1_110
	movzbl	(%rsi), %eax
	movb	%al, 216(%rsp)
	movzbl	-1(%rsi,%rdx), %eax
	movb	%al, 215(%rsp,%rdx)
	cmpq	$3, %rdx
	jb	.LBB1_118
	movzbl	1(%rsi), %eax
	movb	%al, 217(%rsp)
	movzbl	-2(%rsi,%rdx), %eax
	movb	%al, 214(%rsp,%rdx)
	jmp	.LBB1_118
.LBB1_110:
	cmpq	$16, %rdx
	ja	.LBB1_114
	cmpq	$8, %rdx
	jb	.LBB1_113
	movq	(%rsi), %rax
	movq	%rax, 216(%rsp)
	movq	-8(%rsi,%rdx), %rax
	movq	%rax, 208(%rsp,%rdx)
	jmp	.LBB1_118
.LBB1_114:
	movq	%rdx, %rbx
	andq	$8160, %rbx
	je	.LBB1_116
	leaq	216(%rsp), %rdi
	movq	%rsi, %r14
	movq	%rdx, %r15
	movq	%rbx, %rdx
	callq	memcpy@PLT
	movq	%r14, %rsi
	movq	%r15, %rdx
.LBB1_116:
	cmpq	%rbx, %rdx
	je	.LBB1_118
	leaq	(%rsp,%rbx), %rdi
	addq	$216, %rdi
	addq	%rbx, %rsi
	movl	%edx, %eax
	andl	$31, %eax
	movq	%rdx, %rbx
	movq	%rax, %rdx
	callq	memcpy@PLT
	movq	%rbx, %rdx
	jmp	.LBB1_118
.LBB1_113:
	movl	(%rsi), %eax
	movl	%eax, 216(%rsp)
	movl	-4(%rsi,%rdx), %eax
	movl	%eax, 212(%rsp,%rdx)
.LBB1_118:
	addq	4312(%rsp), %rdx
	movq	%rdx, 4312(%rsp)
	movq	4320(%rsp), %r14
	leaq	216(%rsp), %rbx
	cmpq	$4097, %rdx
	jl	.LBB1_120
	movq	%r14, %rdi
	movq	%rbx, %rsi
	callq	"std::collections::string::string::String::_iadd[LITImmOrigin,::Origin[False, $0]](::String,::Span[False, $0, ::SIMD[DType.uint8, 1], $1, AddressSpace.GENERIC])"@PLT
	movq	$0, 4312(%rsp)
	xorl	%edx, %edx
	movq	4320(%rsp), %r14
	jmp	.LBB1_120
.LBB1_81:
	movq	$37, 88(%rsp)
	leaq	static_string_09e773a88105e290(%rip), %rax
	movq	%rax, 80(%rsp)
	movq	%r14, 96(%rsp)
	jmp	.LBB1_82
.LBB1_141:
	movq	$37, 88(%rsp)
	leaq	static_string_09e773a88105e290(%rip), %rax
	movq	%rax, 80(%rsp)
	movabsq	$2305843009213693952, %rax
	movq	%rax, 96(%rsp)
.LBB1_82:
	leaq	static_string_ede496b2d17dd639(%rip), %rdx
	leaq	80(%rsp), %r8
.LBB1_83:
	movl	$761, %edi
	movl	$14, %esi
	movl	$33, %ecx
	callq	"std::os::os::_abort_report[::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],::Writable & ::AnyType](::SourceLocation,$1),prefix={ #interp.memref<{[(#interp.memory_handle<16, ~QABORT:\\00~Q string>, const_global, [], [])], []}, 0, 0>, 6 },message.T`=[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]"@PLT
	ud2
.LBB1_99:
	movq	$37, 224(%rsp)
	leaq	static_string_09e773a88105e290(%rip), %rax
	movq	%rax, 216(%rsp)
	movabsq	$2305843009213693952, %rax
	movq	%rax, 232(%rsp)
	leaq	static_string_ede496b2d17dd639(%rip), %rdx
	leaq	216(%rsp), %r8
	jmp	.LBB1_83
.LBB1_140:
	movq	$37, 40(%rsp)
	leaq	static_string_09e773a88105e290(%rip), %rax
	movq	%rax, 32(%rsp)
	movabsq	$2305843009213693952, %rax
	movq	%rax, 48(%rsp)
	leaq	static_string_ede496b2d17dd639(%rip), %rdx
	leaq	32(%rsp), %r8
	jmp	.LBB1_83
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.size	.Lmain$local, .Lfunc_end1-main
	.cfi_endproc

	.prefalign	4, .Lfunc_end2, nop
	.type	"std::builtin::error::StackTrace::collect_if_enabled(::SIMD[DType.int, 1])",@function
"std::builtin::error::StackTrace::collect_if_enabled(::SIMD[DType.int, 1])":
	.cfi_startproc
	pushq	%rbx
	.cfi_def_cfa_offset 16
	subq	$32, %rsp
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -16
	testq	%rdi, %rdi
	js	.LBB2_1
	movq	%rdi, %rsi
	movq	$0, 8(%rsp)
	leaq	8(%rsp), %rdi
	callq	KGEN_CompilerRT_GetStackTrace@PLT
	testq	%rax, %rax
	je	.LBB2_1
	movq	8(%rsp), %rbx
	movl	$8, %edi
	movl	$24, %esi
	callq	KGEN_CompilerRT_AlignedAlloc@PLT
	testq	%rax, %rax
	je	.LBB2_6
	movq	$1, (%rax)
	movq	$1, 8(%rax)
	movq	%rbx, 16(%rax)
	movb	$1, %dl
	addq	$32, %rsp
	.cfi_def_cfa_offset 16
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.LBB2_1:
	.cfi_def_cfa_offset 48
	xorl	%edx, %edx
	addq	$32, %rsp
	.cfi_def_cfa_offset 16
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.LBB2_6:
	.cfi_def_cfa_offset 48
	movq	$37, 16(%rsp)
	leaq	static_string_09e773a88105e290(%rip), %rax
	movq	%rax, 8(%rsp)
	movabsq	$2305843009213693952, %rax
	movq	%rax, 24(%rsp)
	leaq	static_string_ede496b2d17dd639(%rip), %rdx
	leaq	8(%rsp), %r8
	movl	$761, %edi
	movl	$14, %esi
	movl	$33, %ecx
	callq	"std::os::os::_abort_report[::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],::Writable & ::AnyType](::SourceLocation,$1),prefix={ #interp.memref<{[(#interp.memory_handle<16, ~QABORT:\\00~Q string>, const_global, [], [])], []}, 0, 0>, 6 },message.T`=[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]"@PLT
	ud2
.Lfunc_end2:
	.size	"std::builtin::error::StackTrace::collect_if_enabled(::SIMD[DType.int, 1])", .Lfunc_end2-"std::builtin::error::StackTrace::collect_if_enabled(::SIMD[DType.int, 1])"
	.cfi_endproc

	.prefalign	4, .Lfunc_end3, nop
	.type	"std::builtin::error::Error::write_to[::Writer & ::AnyType](::Error,$0),writer.T`2x1=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]",@function
"std::builtin::error::Error::write_to[::Writer & ::AnyType](::Error,$0),writer.T`2x1=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]":
	.cfi_startproc
	movq	%rdi, %rax
	movq	16(%rdi), %rdx
	testq	%rdx, %rdx
	js	.LBB3_1
	movq	8(%rax), %rdx
	movq	(%rax), %rax
	movq	%rsi, %rdi
	movq	%rax, %rsi
	jmp	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
.LBB3_1:
	shrq	$56, %rdx
	andl	$31, %edx
	movq	%rsi, %rdi
	movq	%rax, %rsi
	jmp	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
.Lfunc_end3:
	.size	"std::builtin::error::Error::write_to[::Writer & ::AnyType](::Error,$0),writer.T`2x1=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]", .Lfunc_end3-"std::builtin::error::Error::write_to[::Writer & ::AnyType](::Error,$0),writer.T`2x1=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]"
	.cfi_endproc

	.prefalign	4, .Lfunc_end4, nop
	.type	"std::collections::list::List::write_to[::Writer & ::AnyType](::List[$0],$1){conforms_to($0, ::Writable & ::AnyType)},T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>],writer.T`2x1=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]",@function
"std::collections::list::List::write_to[::Writer & ::AnyType](::List[$0],$1){conforms_to($0, ::Writable & ::AnyType)},T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>],writer.T`2x1=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]":
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r13
	.cfi_def_cfa_offset 32
	pushq	%r12
	.cfi_def_cfa_offset 40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	subq	$32, %rsp
	.cfi_def_cfa_offset 80
	.cfi_offset %rbx, -48
	.cfi_offset %r12, -40
	.cfi_offset %r13, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movq	%rcx, %rbx
	movq	%rdx, %r14
	movq	%rdi, %r15
	movq	4096(%rcx), %rdx
	leaq	1(%rdx), %rax
	cmpq	$4097, %rax
	jl	.LBB4_2
	movq	4104(%rbx), %rax
	movl	(%rax), %edi
	movq	%rbx, %rsi
	callq	write@PLT
	movq	$0, 4096(%rbx)
	xorl	%edx, %edx
.LBB4_2:
	movb	$91, (%rbx,%rdx)
	movq	4096(%rbx), %rdx
	incq	%rdx
	movq	%rdx, 4096(%rbx)
	testq	%r14, %r14
	jle	.LBB4_6
	movb	$1, %al
	leaq	static_string_44fd141e40b306d5(%rip), %r8
	movl	$2, %r9d
	xorl	%r13d, %r13d
	movq	%rsp, %r12
	movq	%rbx, %rsi
	.p2align	4
.LBB4_4:
	vmovss	(%r15,%r13,4), %xmm0
	incq	%r13
	movzbl	%al, %edx
	movq	%r12, %rdi
	movl	$1, %ecx
	callq	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=f32,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_SequenceWriter,origin._mlir_origin`={  },W=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>],origin={  }>>, struct<(pointer<none>, scalar<bool>, scalar<bool>, struct<(pointer<none>, scalar<index>)>) memoryOnly>]"@PLT
	movq	(%rsp), %rsi
	movq	16(%rsp), %r8
	movq	24(%rsp), %r9
	movzbl	8(%rsp), %eax
	cmpq	%r13, %r14
	jne	.LBB4_4
	movq	4096(%rbx), %rdx
.LBB4_6:
	leaq	1(%rdx), %rax
	cmpq	$4097, %rax
	jl	.LBB4_8
	movq	4104(%rbx), %rax
	movl	(%rax), %edi
	movq	%rbx, %rsi
	callq	write@PLT
	movq	$0, 4096(%rbx)
	xorl	%edx, %edx
.LBB4_8:
	movb	$93, (%rbx,%rdx)
	incq	4096(%rbx)
	addq	$32, %rsp
	.cfi_def_cfa_offset 48
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end4:
	.size	"std::collections::list::List::write_to[::Writer & ::AnyType](::List[$0],$1){conforms_to($0, ::Writable & ::AnyType)},T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>],writer.T`2x1=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]", .Lfunc_end4-"std::collections::list::List::write_to[::Writer & ::AnyType](::List[$0],$1){conforms_to($0, ::Writable & ::AnyType)},T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>],writer.T`2x1=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]"
	.cfi_endproc

	.prefalign	4, .Lfunc_end5, nop
	.type	"std::collections::list::List::_realloc(::List[$0],::SIMD[DType.int, 1]){conforms_to($0, ::AnyType & ::Movable)},T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>]",@function
"std::collections::list::List::_realloc(::List[$0],::SIMD[DType.int, 1]){conforms_to($0, ::AnyType & ::Movable)},T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>]":
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r13
	.cfi_def_cfa_offset 32
	pushq	%r12
	.cfi_def_cfa_offset 40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	subq	$32, %rsp
	.cfi_def_cfa_offset 80
	.cfi_offset %rbx, -48
	.cfi_offset %r12, -40
	.cfi_offset %r13, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	testq	%rcx, %rcx
	js	.LBB5_1
	movq	%rcx, %r14
	movq	%rdx, %rbx
	movq	%rsi, %r12
	movq	%rdi, %r15
	leaq	(,%rcx,4), %rsi
	movl	$4, %edi
	callq	KGEN_CompilerRT_AlignedAlloc@PLT
	testq	%rax, %rax
	je	.LBB5_4
	movq	%rax, %r13
	testq	%rbx, %rbx
	je	.LBB5_18
	leaq	(,%rbx,4), %rdx
	cmpq	$4, %rdx
	jg	.LBB5_10
	testq	%rdx, %rdx
	je	.LBB5_18
	movzbl	(%r15), %eax
	movb	%al, (%r13)
	movzbl	-1(%r15,%rdx), %eax
	movb	%al, -1(%r13,%rdx)
	cmpq	$3, %rdx
	jl	.LBB5_18
	movzbl	1(%r15), %eax
	movb	%al, 1(%r13)
	movzbl	-2(%r15,%rdx), %eax
	movb	%al, -2(%r13,%rdx)
	testq	%r12, %r12
	jg	.LBB5_19
	jmp	.LBB5_20
.LBB5_10:
	cmpq	$16, %rdx
	ja	.LBB5_14
	cmpq	$8, %rdx
	jb	.LBB5_13
	movq	(%r15), %rax
	movq	%rax, (%r13)
	movq	-8(%r15,%rdx), %rax
	movq	%rax, -8(%r13,%rdx)
	testq	%r12, %r12
	jg	.LBB5_19
	jmp	.LBB5_20
.LBB5_14:
	movabsq	$9223372036854775776, %rax
	andq	%rdx, %rax
	je	.LBB5_16
	movq	%r13, %rdi
	movq	%r15, %rsi
	movq	%rax, %rdx
	movq	%rax, 24(%rsp)
	callq	memcpy@PLT
	movq	24(%rsp), %rax
	leaq	(,%rbx,4), %rdx
.LBB5_16:
	cmpq	%rdx, %rax
	je	.LBB5_18
	movq	%r13, %rdi
	addq	%rax, %rdi
	movq	%r15, %rsi
	addq	%rax, %rsi
	andl	$28, %edx
	callq	memcpy@PLT
.LBB5_18:
	testq	%r12, %r12
	jle	.LBB5_20
.LBB5_19:
	movq	%r15, %rdi
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB5_20:
	movq	%r13, %rax
	movq	%r14, %rdx
	movq	%rbx, %rcx
	addq	$32, %rsp
	.cfi_def_cfa_offset 48
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.LBB5_13:
	.cfi_def_cfa_offset 80
	movl	(%r15), %eax
	movl	%eax, (%r13)
	movl	-4(%r15,%rdx), %eax
	movl	%eax, -4(%r13,%rdx)
	testq	%r12, %r12
	jg	.LBB5_19
	jmp	.LBB5_20
.LBB5_1:
	movq	$36, 8(%rsp)
	leaq	static_string_30948303dbd8bc48(%rip), %rax
	movq	%rax, (%rsp)
	movabsq	$2305843009213693952, %rax
	movq	%rax, 16(%rsp)
	leaq	static_string_ede496b2d17dd639(%rip), %rdx
	movq	%rsp, %r8
	movl	$888, %edi
	movl	$14, %esi
	movl	$33, %ecx
	callq	"std::os::os::_abort_report[::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],::Writable & ::AnyType](::SourceLocation,$1),prefix={ #interp.memref<{[(#interp.memory_handle<16, ~QABORT:\\00~Q string>, const_global, [], [])], []}, 0, 0>, 6 },message.T`=[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]"@PLT
	ud2
.LBB5_4:
	movq	$37, 8(%rsp)
	leaq	static_string_09e773a88105e290(%rip), %rax
	movq	%rax, (%rsp)
	movabsq	$2305843009213693952, %rax
	movq	%rax, 16(%rsp)
	leaq	static_string_ede496b2d17dd639(%rip), %rdx
	movq	%rsp, %r8
	movl	$761, %edi
	movl	$14, %esi
	movl	$33, %ecx
	callq	"std::os::os::_abort_report[::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],::Writable & ::AnyType](::SourceLocation,$1),prefix={ #interp.memref<{[(#interp.memory_handle<16, ~QABORT:\\00~Q string>, const_global, [], [])], []}, 0, 0>, 6 },message.T`=[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]"@PLT
	ud2
.Lfunc_end5:
	.size	"std::collections::list::List::_realloc(::List[$0],::SIMD[DType.int, 1]){conforms_to($0, ::AnyType & ::Movable)},T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>]", .Lfunc_end5-"std::collections::list::List::_realloc(::List[$0],::SIMD[DType.int, 1]){conforms_to($0, ::AnyType & ::Movable)},T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>]"
	.cfi_endproc

	.prefalign	4, .Lfunc_end6, nop
	.type	"std::collections::string::string::String::_iadd[LITImmOrigin,::Origin[False, $0]](::String,::Span[False, $0, ::SIMD[DType.uint8, 1], $1, AddressSpace.GENERIC])",@function
"std::collections::string::string::String::_iadd[LITImmOrigin,::Origin[False, $0]](::String,::Span[False, $0, ::SIMD[DType.uint8, 1], $1, AddressSpace.GENERIC])":
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$72, %rsp
	.cfi_def_cfa_offset 128
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%rdi, %rbx
	movq	%rdx, %rdi
	subq	$1, %rdi
	jb	.LBB6_55
	movq	%rdx, %r14
	movq	%rsi, %r15
	movabsq	$4611686018427387904, %r8
	movq	16(%rbx), %rbp
	testq	%rbp, %rbp
	js	.LBB6_9
	movq	8(%rbx), %r12
	leaq	(%r12,%r14), %r13
	leaq	(,%rbp,8), %rcx
	cmpq	%r8, %rbp
	cmovbq	%r12, %rcx
	cmpq	%r13, %rcx
	cmovleq	%r13, %rcx
	cmpq	$24, %rcx
	jge	.LBB6_10
	movq	(%rbx), %rax
	movq	%r12, %rcx
	shlq	$56, %rcx
	movabsq	$9223372036854775776, %rdx
	addq	$32, %rdx
	orq	%rcx, %rdx
	vxorps	%xmm0, %xmm0, %xmm0
	vmovaps	%xmm0, 16(%rsp)
	movq	%rdx, 32(%rsp)
	testq	%r12, %r12
	jle	.LBB6_5
	movq	%rdi, 48(%rsp)
	leaq	16(%rsp), %rdi
	movq	%rax, 8(%rsp)
	movq	8(%rsp), %rsi
	movq	%r12, %rdx
	callq	memcpy@PLT
	movabsq	$4611686018427387904, %r8
	movq	48(%rsp), %rdi
	movq	8(%rsp), %rax
.LBB6_5:
	cmpq	%r8, %rbp
	jb	.LBB6_8
	lock		decq	-8(%rax)
	jne	.LBB6_8
	addq	$-8, %rax
	#MEMBARRIER
	movq	%rdi, %rbp
	movq	%rax, %rdi
	callq	KGEN_CompilerRT_AlignedFree@PLT
	movq	%rbp, %rdi
.LBB6_8:
	movq	16(%rsp), %rax
	movq	%rax, (%rbx)
	movq	32(%rsp), %rbp
	vmovups	24(%rsp), %xmm0
	vmovups	%xmm0, 8(%rbx)
	jmp	.LBB6_38
.LBB6_9:
	movq	%rbp, %r12
	shrq	$56, %r12
	andl	$31, %r12d
	leaq	(%r12,%r14), %r13
	movq	%r13, %rcx
	movq	%rbx, %rax
	cmpq	$24, %r13
	jl	.LBB6_39
.LBB6_10:
	testq	%r8, %rbp
	je	.LBB6_13
	movq	(%rbx), %rax
	cmpq	$1, -8(%rax)
	jne	.LBB6_13
	leaq	(,%rbp,8), %rdx
	testq	%rbp, %rbp
	movl	$23, %esi
	cmovnsq	%rdx, %rsi
	cmpq	%rsi, %rcx
	jle	.LBB6_38
.LBB6_13:
	movq	%r13, 64(%rsp)
	testq	%rbp, %rbp
	js	.LBB6_14
	movq	(%rbx), %rax
	movq	%rax, 56(%rsp)
	movq	8(%rbx), %rax
	leaq	(,%rbp,8), %r13
	cmpq	%r8, %rbp
	cmovbq	%rax, %r13
	addq	%r13, %r13
	jmp	.LBB6_16
.LBB6_14:
	movq	%rbp, %rax
	shrq	$56, %rax
	andl	$31, %eax
	movl	$46, %r13d
	movq	%rbx, 56(%rsp)
.LBB6_16:
	movq	%rax, 8(%rsp)
	movq	%rdi, 48(%rsp)
	cmpq	%r13, %rcx
	cmovgq	%rcx, %r13
	addq	$7, %r13
	movq	%r13, %rsi
	andq	$-8, %rsi
	addq	$8, %rsi
	js	.LBB6_17
	movl	$1, %edi
	callq	KGEN_CompilerRT_AlignedAlloc@PLT
	testq	%rax, %rax
	je	.LBB6_20
	movq	%rax, %rcx
	movq	$1, (%rax)
	addq	$8, %rax
	movq	8(%rsp), %r9
	movq	%r9, %rdx
	subq	$1, %rdx
	movabsq	$4611686018427387904, %r8
	movq	56(%rsp), %rdi
	jae	.LBB6_22
.LBB6_34:
	testq	%r8, %rbp
	je	.LBB6_37
	movq	(%rbx), %rdi
	lock		decq	-8(%rdi)
	jne	.LBB6_37
	addq	$-8, %rdi
	#MEMBARRIER
	movq	%rax, %rbp
	vzeroupper
	callq	KGEN_CompilerRT_AlignedFree@PLT
	movq	8(%rsp), %r9
	movabsq	$4611686018427387904, %r8
	movq	%rbp, %rax
.LBB6_37:
	sarq	$3, %r13
	movq	%r9, 8(%rbx)
	movq	%rax, (%rbx)
	orq	%r8, %r13
	movq	%r13, 16(%rbx)
	movq	%r13, %rbp
	movq	64(%rsp), %r13
	movq	48(%rsp), %rdi
.LBB6_38:
	testq	%rbp, %rbp
	cmovsq	%rbx, %rax
.LBB6_39:
	addq	%rax, %r12
	cmpq	$4, %r14
	jg	.LBB6_42
	movzbl	(%r15), %eax
	movb	%al, (%r12)
	movzbl	(%r15,%rdi), %eax
	movb	%al, (%r12,%rdi)
	cmpq	$3, %r14
	jl	.LBB6_51
	movzbl	1(%r15), %eax
	movb	%al, 1(%r12)
	movzbl	-2(%r15,%r14), %eax
	movb	%al, -2(%r12,%r14)
	movq	16(%rbx), %rax
	testq	%rax, %rax
	jns	.LBB6_53
	jmp	.LBB6_52
.LBB6_42:
	cmpq	$16, %r14
	ja	.LBB6_46
	cmpq	$8, %r14
	jb	.LBB6_45
	movq	(%r15), %rax
	movq	%rax, (%r12)
	movq	-8(%r15,%r14), %rax
	movq	%rax, -8(%r12,%r14)
	movq	16(%rbx), %rax
	testq	%rax, %rax
	jns	.LBB6_53
	jmp	.LBB6_52
.LBB6_46:
	movabsq	$9223372036854775776, %rax
	andq	%r14, %rax
	je	.LBB6_49
	xorl	%ecx, %ecx
	.p2align	4
.LBB6_48:
	vmovups	(%r15,%rcx), %ymm0
	vmovups	%ymm0, (%r12,%rcx)
	addq	$32, %rcx
	cmpq	%rax, %rcx
	jb	.LBB6_48
.LBB6_49:
	cmpq	%r14, %rax
	je	.LBB6_51
	.p2align	4
.LBB6_50:
	movzbl	(%r15,%rax), %ecx
	movb	%cl, (%r12,%rax)
	incq	%rax
	cmpq	%rax, %r14
	jne	.LBB6_50
.LBB6_51:
	movq	16(%rbx), %rax
	testq	%rax, %rax
	js	.LBB6_52
.LBB6_53:
	movq	%r13, 8(%rbx)
	jmp	.LBB6_54
.LBB6_22:
	cmpq	$4, %r9
	jg	.LBB6_25
	movzbl	(%rdi), %esi
	movb	%sil, (%rax)
	movzbl	(%rdi,%rdx), %esi
	movb	%sil, (%rax,%rdx)
	cmpq	$3, %r9
	jl	.LBB6_34
	movzbl	1(%rdi), %edx
	movb	%dl, 9(%rcx)
	movzbl	-2(%rdi,%r9), %edx
	movb	%dl, 6(%rcx,%r9)
	jmp	.LBB6_34
.LBB6_45:
	movl	(%r15), %eax
	movl	%eax, (%r12)
	movl	-4(%r15,%r14), %eax
	movl	%eax, -4(%r12,%r14)
	movq	16(%rbx), %rax
	testq	%rax, %rax
	jns	.LBB6_53
.LBB6_52:
	shlq	$56, %r13
	movabsq	$-2233785415175766017, %rcx
	andq	%rcx, %rax
	orq	%r13, %rax
.LBB6_54:
	movabsq	$-2305843009213693953, %rcx
	andq	%rax, %rcx
	movq	%rcx, 16(%rbx)
.LBB6_55:
	addq	$72, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	vzeroupper
	retq
.LBB6_25:
	.cfi_def_cfa_offset 128
	cmpq	$16, %r9
	ja	.LBB6_29
	cmpq	$8, %r9
	jb	.LBB6_28
	movq	(%rdi), %rdx
	movq	%rdx, 8(%rcx)
	movq	-8(%rdi,%r9), %rdx
	movq	%rdx, (%rcx,%r9)
	jmp	.LBB6_34
.LBB6_29:
	movabsq	$9223372036854775776, %rcx
	andq	%r9, %rcx
	je	.LBB6_32
	xorl	%edx, %edx
	.p2align	4
.LBB6_31:
	vmovups	(%rdi,%rdx), %ymm0
	vmovups	%ymm0, (%rax,%rdx)
	addq	$32, %rdx
	cmpq	%rcx, %rdx
	jb	.LBB6_31
.LBB6_32:
	cmpq	%r9, %rcx
	je	.LBB6_34
	.p2align	4
.LBB6_33:
	movzbl	(%rdi,%rcx), %edx
	movb	%dl, (%rax,%rcx)
	incq	%rcx
	cmpq	%rcx, %r9
	jne	.LBB6_33
	jmp	.LBB6_34
.LBB6_28:
	movl	(%rdi), %ecx
	movl	%ecx, (%rax)
	movl	-4(%rdi,%r9), %ecx
	movl	%ecx, -4(%rax,%r9)
	jmp	.LBB6_34
.LBB6_17:
	movq	$36, 24(%rsp)
	leaq	static_string_30948303dbd8bc48(%rip), %rax
	movq	%rax, 16(%rsp)
	movabsq	$2305843009213693952, %rax
	movq	%rax, 32(%rsp)
	leaq	static_string_ede496b2d17dd639(%rip), %rdx
	leaq	16(%rsp), %r8
	movl	$888, %edi
	movl	$14, %esi
	movl	$33, %ecx
	callq	"std::os::os::_abort_report[::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],::Writable & ::AnyType](::SourceLocation,$1),prefix={ #interp.memref<{[(#interp.memory_handle<16, ~QABORT:\\00~Q string>, const_global, [], [])], []}, 0, 0>, 6 },message.T`=[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]"@PLT
	ud2
.LBB6_20:
	movq	$37, 24(%rsp)
	leaq	static_string_09e773a88105e290(%rip), %rax
	movq	%rax, 16(%rsp)
	movabsq	$2305843009213693952, %rax
	movq	%rax, 32(%rsp)
	leaq	static_string_ede496b2d17dd639(%rip), %rdx
	leaq	16(%rsp), %r8
	movl	$761, %edi
	movl	$14, %esi
	movl	$33, %ecx
	callq	"std::os::os::_abort_report[::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],::Writable & ::AnyType](::SourceLocation,$1),prefix={ #interp.memref<{[(#interp.memory_handle<16, ~QABORT:\\00~Q string>, const_global, [], [])], []}, 0, 0>, 6 },message.T`=[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]"@PLT
	ud2
.Lfunc_end6:
	.size	"std::collections::string::string::String::_iadd[LITImmOrigin,::Origin[False, $0]](::String,::Span[False, $0, ::SIMD[DType.uint8, 1], $1, AddressSpace.GENERIC])", .Lfunc_end6-"std::collections::string::string::String::_iadd[LITImmOrigin,::Origin[False, $0]](::String,::Span[False, $0, ::SIMD[DType.uint8, 1], $1, AddressSpace.GENERIC])"
	.cfi_endproc

	.prefalign	4, .Lfunc_end7, nop
	.type	"std::collections::string::string::String::write_to[::Writer & ::AnyType](::String,$0),writer.T`2x1=[typevalue<#kgen.instref<std::format::_utils::_FixedWriteBuffer>>, struct<(struct<(array<2048, scalar<ui8>>) memoryOnly>, scalar<index>) memoryOnly>]",@function
"std::collections::string::string::String::write_to[::Writer & ::AnyType](::String,$0),writer.T`2x1=[typevalue<#kgen.instref<std::format::_utils::_FixedWriteBuffer>>, struct<(struct<(array<2048, scalar<ui8>>) memoryOnly>, scalar<index>) memoryOnly>]":
	.cfi_startproc
	subq	$40, %rsp
	.cfi_def_cfa_offset 48
	movq	16(%rdi), %rcx
	testq	%rcx, %rcx
	js	.LBB7_1
	movq	8(%rdi), %rcx
	movq	(%rdi), %rdi
	movq	2048(%rsi), %rax
	leaq	(%rax,%rcx), %rdx
	cmpq	$2049, %rdx
	jge	.LBB7_17
.LBB7_4:
	movq	%rcx, %rdx
	subq	$1, %rdx
	jae	.LBB7_5
.LBB7_16:
	addq	%rcx, 2048(%rsi)
	addq	$40, %rsp
	.cfi_def_cfa_offset 8
	retq
.LBB7_5:
	.cfi_def_cfa_offset 48
	addq	%rsi, %rax
	cmpq	$4, %rcx
	jg	.LBB7_8
	movzbl	(%rdi), %r8d
	movb	%r8b, (%rax)
	movzbl	(%rdi,%rdx), %r8d
	movb	%r8b, (%rax,%rdx)
	cmpq	$3, %rcx
	jl	.LBB7_16
	movzbl	1(%rdi), %edx
	movb	%dl, 1(%rax)
	movzbl	-2(%rdi,%rcx), %edx
	movb	%dl, -2(%rax,%rcx)
	addq	%rcx, 2048(%rsi)
	addq	$40, %rsp
	.cfi_def_cfa_offset 8
	retq
.LBB7_1:
	.cfi_def_cfa_offset 48
	shrq	$56, %rcx
	andl	$31, %ecx
	movq	2048(%rsi), %rax
	leaq	(%rax,%rcx), %rdx
	cmpq	$2049, %rdx
	jl	.LBB7_4
.LBB7_17:
	callq	"std::format::_utils::_fixed_buffer_exceeded()"@PLT
.LBB7_8:
	cmpq	$16, %rcx
	ja	.LBB7_12
	cmpq	$8, %rcx
	jb	.LBB7_11
	movq	(%rdi), %rdx
	movq	%rdx, (%rax)
	movq	-8(%rdi,%rcx), %rdx
	movq	%rdx, -8(%rax,%rcx)
	addq	%rcx, 2048(%rsi)
	addq	$40, %rsp
	.cfi_def_cfa_offset 8
	retq
.LBB7_12:
	.cfi_def_cfa_offset 48
	movabsq	$9223372036854775776, %rdx
	andq	%rcx, %rdx
	movq	%rcx, (%rsp)
	movq	%rsi, 24(%rsp)
	je	.LBB7_14
	movq	%rdi, 16(%rsp)
	movq	%rax, %rdi
	movq	16(%rsp), %rsi
	movq	%rdx, 8(%rsp)
	movq	8(%rsp), %rdx
	movq	%rax, 32(%rsp)
	callq	memcpy@PLT
	movq	(%rsp), %rcx
	movq	8(%rsp), %rdx
	movq	32(%rsp), %rax
	movq	16(%rsp), %rdi
	movq	24(%rsp), %rsi
.LBB7_14:
	cmpq	%rcx, %rdx
	je	.LBB7_16
	addq	%rdx, %rax
	addq	%rdx, %rdi
	movq	(%rsp), %rdx
	andl	$31, %edx
	movq	%rdi, %rcx
	movq	%rax, %rdi
	movq	%rcx, %rsi
	callq	memcpy@PLT
	movq	(%rsp), %rcx
	movq	24(%rsp), %rsi
	addq	%rcx, 2048(%rsi)
	addq	$40, %rsp
	.cfi_def_cfa_offset 8
	retq
.LBB7_11:
	.cfi_def_cfa_offset 48
	movl	(%rdi), %edx
	movl	%edx, (%rax)
	movl	-4(%rdi,%rcx), %edx
	movl	%edx, -4(%rax,%rcx)
	addq	%rcx, 2048(%rsi)
	addq	$40, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end7:
	.size	"std::collections::string::string::String::write_to[::Writer & ::AnyType](::String,$0),writer.T`2x1=[typevalue<#kgen.instref<std::format::_utils::_FixedWriteBuffer>>, struct<(struct<(array<2048, scalar<ui8>>) memoryOnly>, scalar<index>) memoryOnly>]", .Lfunc_end7-"std::collections::string::string::String::write_to[::Writer & ::AnyType](::String,$0),writer.T`2x1=[typevalue<#kgen.instref<std::format::_utils::_FixedWriteBuffer>>, struct<(struct<(array<2048, scalar<ui8>>) memoryOnly>, scalar<index>) memoryOnly>]"
	.cfi_endproc

	.prefalign	4, .Lfunc_end8, nop
	.type	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096",@function
"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096":
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r12
	.cfi_def_cfa_offset 32
	pushq	%rbx
	.cfi_def_cfa_offset 40
	subq	$24, %rsp
	.cfi_def_cfa_offset 64
	.cfi_offset %rbx, -40
	.cfi_offset %r12, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movq	%rdx, %rbx
	movq	%rsi, %r15
	movq	%rdi, %r14
	cmpq	$4097, %rdx
	jl	.LBB8_1
	movq	4096(%r14), %rdx
	movq	4104(%r14), %r12
	movl	(%r12), %edi
	movq	%r14, %rsi
	callq	write@PLT
	movq	$0, 4096(%r14)
	movl	(%r12), %edi
	movq	%r15, %rsi
	movq	%rbx, %rdx
	addq	$24, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	jmp	write@PLT
.LBB8_1:
	.cfi_def_cfa_offset 64
	movq	4096(%r14), %rdx
	leaq	(%rdx,%rbx), %rax
	cmpq	$4097, %rax
	jl	.LBB8_3
	movq	4104(%r14), %rax
	movl	(%rax), %edi
	movq	%r14, %rsi
	callq	write@PLT
	movq	$0, 4096(%r14)
	xorl	%edx, %edx
.LBB8_3:
	movq	%rbx, %rax
	subq	$1, %rax
	jae	.LBB8_4
.LBB8_15:
	addq	%rbx, 4096(%r14)
	addq	$24, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.LBB8_4:
	.cfi_def_cfa_offset 64
	addq	%r14, %rdx
	cmpq	$4, %rbx
	jg	.LBB8_7
	movzbl	(%r15), %ecx
	movb	%cl, (%rdx)
	movzbl	(%r15,%rax), %ecx
	movb	%cl, (%rdx,%rax)
	cmpq	$3, %rbx
	jl	.LBB8_15
	movzbl	1(%r15), %eax
	movb	%al, 1(%rdx)
	movzbl	-2(%r15,%rbx), %eax
	movb	%al, -2(%rdx,%rbx)
	jmp	.LBB8_15
.LBB8_7:
	cmpq	$16, %rbx
	ja	.LBB8_11
	cmpq	$8, %rbx
	jb	.LBB8_10
	movq	(%r15), %rax
	movq	%rax, (%rdx)
	movq	-8(%r15,%rbx), %rax
	movq	%rax, -8(%rdx,%rbx)
	jmp	.LBB8_15
.LBB8_11:
	movabsq	$9223372036854775776, %rax
	andq	%rbx, %rax
	je	.LBB8_13
	movq	%rdx, %rdi
	movq	%r15, %rsi
	movq	%rdx, 16(%rsp)
	movq	%rax, %rdx
	movq	%rax, 8(%rsp)
	callq	memcpy@PLT
	movq	8(%rsp), %rax
	movq	16(%rsp), %rdx
.LBB8_13:
	cmpq	%rbx, %rax
	je	.LBB8_15
	addq	%rax, %rdx
	addq	%rax, %r15
	movl	%ebx, %eax
	andl	$31, %eax
	movq	%rdx, %rdi
	movq	%r15, %rsi
	movq	%rax, %rdx
	callq	memcpy@PLT
	jmp	.LBB8_15
.LBB8_10:
	movl	(%r15), %eax
	movl	%eax, (%rdx)
	movl	-4(%r15,%rbx), %eax
	movl	%eax, -4(%rdx,%rbx)
	jmp	.LBB8_15
.Lfunc_end8:
	.size	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096", .Lfunc_end8-"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"
	.cfi_endproc

	.prefalign	4, .Lfunc_end9, nop
	.type	"std::memory::arc_pointer::ArcPointer::__deinit__(::ArcPointer[$0]$),T=[typevalue<#kgen.instref<std::memory::owned_pointer::OwnedPointer,T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=ui8,length=1>>, scalar<ui8>]>>, pointer<none>]",@function
"std::memory::arc_pointer::ArcPointer::__deinit__(::ArcPointer[$0]$),T=[typevalue<#kgen.instref<std::memory::owned_pointer::OwnedPointer,T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=ui8,length=1>>, scalar<ui8>]>>, pointer<none>]":
	.cfi_startproc
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset %rbx, -16
	lock		decq	(%rdi)
	jne	.LBB9_2
	movq	%rdi, %rbx
	#MEMBARRIER
	movq	16(%rdi), %rdi
	callq	KGEN_CompilerRT_AlignedFree@PLT
	lock		decq	8(%rbx)
	jne	.LBB9_2
	#MEMBARRIER
	movq	%rbx, %rdi
	popq	%rbx
	.cfi_def_cfa_offset 8
	jmp	KGEN_CompilerRT_AlignedFree@PLT
.LBB9_2:
	.cfi_def_cfa_offset 16
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end9:
	.size	"std::memory::arc_pointer::ArcPointer::__deinit__(::ArcPointer[$0]$),T=[typevalue<#kgen.instref<std::memory::owned_pointer::OwnedPointer,T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=ui8,length=1>>, scalar<ui8>]>>, pointer<none>]", .Lfunc_end9-"std::memory::arc_pointer::ArcPointer::__deinit__(::ArcPointer[$0]$),T=[typevalue<#kgen.instref<std::memory::owned_pointer::OwnedPointer,T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=ui8,length=1>>, scalar<ui8>]>>, pointer<none>]"
	.cfi_endproc

	.prefalign	4, .Lfunc_end10, nop
	.type	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=f32,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_SequenceWriter,origin._mlir_origin`={  },W=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>],origin={  }>>, struct<(pointer<none>, scalar<bool>, scalar<bool>, struct<(pointer<none>, scalar<index>)>) memoryOnly>]",@function
"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=f32,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_SequenceWriter,origin._mlir_origin`={  },W=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>],origin={  }>>, struct<(pointer<none>, scalar<bool>, scalar<bool>, struct<(pointer<none>, scalar<index>)>) memoryOnly>]":
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$152, %rsp
	.cfi_def_cfa_offset 208
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%r9, 48(%rsp)
	movq	%r8, 56(%rsp)
	movq	%rsi, 8(%rsp)
	movq	%rdi, 64(%rsp)
	vmovd	%xmm0, %eax
	movl	%eax, %esi
	andl	$8388607, %esi
	movl	%eax, %edi
	shrl	$23, %edi
	movzbl	%dil, %r14d
	movl	%eax, %r8d
	andl	$2147483647, %r8d
	testl	%esi, %esi
	setne	%r13b
	leaq	-150(%r14), %r9
	leal	(%rsi,%rsi), %r10d
	testl	%r14d, %r14d
	sete	%dil
	movq	$-149, %r15
	cmovneq	%r9, %r15
	leal	16777216(%rsi,%rsi), %ebx
	cmovel	%r10d, %ebx
	leal	-154(%r14), %r9d
	xorl	%ebp, %ebp
	cmpl	$-2, %r9d
	setb	%r9b
	cmpl	$2139095040, %r8d
	jne	.LBB10_7
	movl	%ecx, %r12d
	xorb	$1, %r12b
	andb	%dl, %r12b
	xorb	$1, %dl
	andb	%cl, %dl
	testl	%eax, %eax
	js	.LBB10_13
	testb	$1, %dl
	movq	8(%rsp), %r15
	je	.LBB10_4
	movq	%r15, %rdi
	movq	56(%rsp), %rsi
	movq	48(%rsp), %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
.LBB10_4:
	movq	4096(%r15), %rdx
	leaq	3(%rdx), %rax
	cmpq	$4097, %rax
	jl	.LBB10_6
	movq	4104(%r15), %rax
	movl	(%rax), %edi
	movq	%r15, %rsi
	callq	write@PLT
	movq	$0, 4096(%r15)
	xorl	%edx, %edx
.LBB10_6:
	movq	64(%rsp), %rax
	movw	$28265, (%r15,%rdx)
	movb	$102, 2(%r15,%rdx)
	addq	$3, 4096(%r15)
	jmp	.LBB10_132
.LBB10_7:
	vucomiss	%xmm0, %xmm0
	jp	.LBB10_141
	movl	%r14d, %r8d
	orl	%esi, %r8d
	testl	%eax, %eax
	setns	%r10b
	andb	%cl, %r10b
	testl	%r8d, %r8d
	je	.LBB10_18
	orb	%dil, %r13b
	movl	%edx, %r12d
	testl	%eax, %eax
	movl	%r10d, 4(%rsp)
	js	.LBB10_21
	leaq	global_constant(%rip), %rax
	testb	%r13b, %r13b
	je	.LBB10_26
.LBB10_11:
	imulq	$315653, %r15, %r13
	sarq	$20, %r13
	movl	$1, %edi
	movl	$1, %ecx
	subq	%r13, %rcx
	imulq	$1741647, %rcx, %rsi
	sarq	$19, %rsi
	addq	%r15, %rsi
	movl	$32, %edx
	movq	%rsi, %r14
	negq	%r14
	subq	%r13, %rdx
	leal	1(%rbx), %ecx
	shlxl	%esi, %ecx, %ecx
	leal	-1(%rbx), %r11d
	movl	$63, %r8d
	movq	(%rax,%rdx,8), %r10
	movq	%rdx, %rax
	shlq	$4, %rax
	leaq	global_constant_0(%rip), %rdx
	addq	%rax, %rdx
	movl	$64, %r9d
	leaq	1(%r13), %rax
	subq	%rsi, %r8
	subq	%rsi, %r9
	shrxq	%r8, %r10, %r8
	movl	%r10d, %r15d
	shrq	$32, %r10
	imulq	%rcx, %r10
	imulq	%rcx, %r15
	shrq	$32, %r15
	addq	%r10, %r15
	shrq	$32, %r15
	imulq	$1374389535, %r15, %r10
	shrq	$37, %r10
	imull	$-100, %r10d, %ecx
	addl	%r15d, %ecx
	cmpl	%r8d, %ecx
	jae	.LBB10_28
.LBB10_12:
	imull	$184254097, %r10d, %ecx
	shrdl	$4, %r10d, %ecx
	xorl	%edx, %edx
	cmpl	$429497, %ecx
	setb	%dl
	cmovael	%r10d, %ecx
	imull	$42949673, %ecx, %esi
	shrdl	$2, %ecx, %esi
	xorl	%edi, %edi
	cmpl	$42949673, %esi
	setb	%dil
	cmovael	%ecx, %esi
	imull	$1288490189, %esi, %r14d
	shrdl	$1, %esi, %r14d
	addl	%edi, %edi
	cmpl	$429496730, %r14d
	leal	(%rdi,%rdx,4), %r13d
	cmovael	%esi, %r14d
	adcq	%rax, %r13
	jmp	.LBB10_33
.LBB10_13:
	testb	$1, %dl
	movq	8(%rsp), %r15
	je	.LBB10_15
	movq	%r15, %rdi
	movq	56(%rsp), %rsi
	movq	48(%rsp), %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
.LBB10_15:
	movq	4096(%r15), %rdx
	leaq	4(%rdx), %rax
	cmpq	$4097, %rax
	jl	.LBB10_17
	movq	4104(%r15), %rax
	movl	(%rax), %edi
	movq	%r15, %rsi
	callq	write@PLT
	movq	$0, 4096(%r15)
	xorl	%edx, %edx
.LBB10_17:
	movq	64(%rsp), %rax
	movl	$1718511917, (%r15,%rdx)
	addq	$4, 4096(%r15)
.LBB10_132:
	xorl	%ebx, %ebx
	jmp	.LBB10_133
.LBB10_18:
	testl	%eax, %eax
	js	.LBB10_93
	movl	%edx, %eax
	xorb	$1, %al
	andb	%r10b, %al
	cmpb	$1, %al
	movq	8(%rsp), %r15
	movl	%edx, %ebx
	jne	.LBB10_98
	movq	%r15, %rdi
	movq	56(%rsp), %rsi
	movq	48(%rsp), %rdx
	movl	%r10d, %ebp
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movl	%ebp, %r10d
	jmp	.LBB10_98
.LBB10_21:
	movb	%r9b, 104(%rsp)
	movl	%edx, %eax
	notb	%al
	andb	%cl, %al
	testb	$1, %al
	movl	%edx, 44(%rsp)
	je	.LBB10_23
	movq	8(%rsp), %rdi
	movq	56(%rsp), %rsi
	movq	48(%rsp), %rdx
	movl	%ecx, 96(%rsp)
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movl	96(%rsp), %ecx
	movl	44(%rsp), %edx
.LBB10_23:
	xorb	$1, %cl
	movq	8(%rsp), %r12
	movq	4096(%r12), %rax
	leaq	1(%rax), %rsi
	cmpq	$4097, %rsi
	jl	.LBB10_25
	movq	4104(%r12), %rsi
	movl	(%rsi), %edi
	movq	%r12, %rsi
	movq	%rax, %rdx
	movl	%ecx, 96(%rsp)
	callq	write@PLT
	movl	96(%rsp), %ecx
	movl	44(%rsp), %edx
	movq	$0, 4096(%r12)
	xorl	%eax, %eax
.LBB10_25:
	movl	4(%rsp), %r10d
	movzbl	104(%rsp), %r9d
	andb	%dl, %cl
	movb	$45, (%r12,%rax)
	incq	4096(%r12)
	movl	%ecx, %r12d
	leaq	global_constant(%rip), %rax
	testb	%r13b, %r13b
	jne	.LBB10_11
.LBB10_26:
	imulq	$631305, %r14, %r13
	addq	$-94957413, %r13
	sarq	$21, %r13
	imulq	$-1741647, %r13, %rcx
	sarq	$19, %rcx
	addq	%r14, %rcx
	addq	$-150, %rcx
	movl	$31, %edx
	movl	$40, %esi
	subq	%r13, %rdx
	subq	%rcx, %rsi
	movb	%r9b, %bpl
	movq	(%rax,%rdx,8), %rax
	movq	%rax, %rdx
	shrq	$25, %rdx
	movq	%rax, %rdi
	subq	%rdx, %rdi
	shrxq	%rsi, %rdi, %rdx
	movq	%rax, %rdi
	shrq	$24, %rdi
	addq	%rax, %rdi
	shrxq	%rsi, %rdi, %rsi
	addl	%ebp, %edx
	movl	%esi, %esi
	imulq	$429496730, %rsi, %rsi
	shrq	$32, %rsi
	leal	(%rsi,%rsi), %edi
	leal	(%rdi,%rdi,4), %edi
	cmpl	%edx, %edi
	movq	8(%rsp), %r15
	jae	.LBB10_34
	movl	$39, %esi
	subq	%rcx, %rsi
	shrxq	%rsi, %rax, %r14
	incl	%r14d
	shrl	%r14d
	cmpl	%edx, %r14d
	adcl	$0, %r14d
	jmp	.LBB10_35
.LBB10_28:
	shlxq	%r14, %rdi, %rdi
	jne	.LBB10_31
	movq	(%rdx), %r14
	movq	%rdi, %rax
	movl	%r12d, %edi
	movq	8(%rdx), %r12
	imulq	%r11, %r12
	movl	%r14d, %r15d
	shrq	$32, %r14
	imulq	%r11, %r14
	imulq	%r11, %r15
	movq	%r15, %rbp
	shrq	$32, %rbp
	movl	%r14d, %r11d
	addq	%rbp, %r11
	movq	%r11, %rbp
	shrq	$32, %rbp
	shrq	$32, %r14
	addq	%r12, %r14
	movl	%edi, %r12d
	movq	%rax, %rdi
	leaq	1(%r13), %rax
	addq	%rbp, %r14
	testq	%rdi, %r14
	jne	.LBB10_12
	shlq	$32, %r11
	movl	%r15d, %r15d
	orq	%r11, %r15
	shlxq	%rsi, %r14, %rsi
	shrxq	%r9, %r15, %r9
	orq	%rsi, %r9
	testq	%r9, %r9
	je	.LBB10_12
.LBB10_31:
	leal	(%r10,%r10,4), %eax
	shrl	%r8d
	subl	%r8d, %ecx
	imull	$6554, %ecx, %esi
	addl	$32770, %esi
	movzwl	%si, %r8d
	shrl	$16, %esi
	leal	(%rsi,%rax,2), %r14d
	cmpl	$6553, %r8d
	ja	.LBB10_33
	movq	(%rdx), %rsi
	movq	8(%rdx), %rax
	imulq	%rbx, %rax
	movl	%esi, %edx
	shrq	$32, %rsi
	imulq	%rbx, %rsi
	imulq	%rbx, %rdx
	shrq	$32, %rdx
	movl	%esi, %r8d
	andl	$-2, %r8d
	addq	%rdx, %r8
	shrq	$32, %r8
	shrq	$32, %rsi
	addq	%rax, %rsi
	addq	%r8, %rsi
	testq	%rdi, %rsi
	setne	%al
	xorb	%cl, %al
	movzbl	%al, %eax
	andl	$1, %eax
	subl	%eax, %r14d
.LBB10_33:
	movq	8(%rsp), %r15
	movl	4(%rsp), %r10d
	jmp	.LBB10_35
.LBB10_34:
	incq	%r13
	imull	$184254097, %esi, %eax
	shrdl	$4, %esi, %eax
	xorl	%ecx, %ecx
	cmpl	$429497, %eax
	setb	%cl
	cmovael	%esi, %eax
	imull	$42949673, %eax, %edx
	shrdl	$2, %eax, %edx
	xorl	%esi, %esi
	cmpl	$42949673, %edx
	setb	%sil
	cmovael	%eax, %edx
	imull	$1288490189, %edx, %r14d
	shrdl	$1, %edx, %r14d
	addl	%esi, %esi
	cmpl	$429496730, %r14d
	leal	(%rsi,%rcx,4), %eax
	cmovael	%edx, %r14d
	adcq	%rax, %r13
.LBB10_35:
	movabsq	$2305843009213693952, %r11
	movq	%r13, %rbx
	negq	%rbx
	cmovsq	%r13, %rbx
	xorl	%ebp, %ebp
	testl	%r14d, %r14d
	je	.LBB10_39
	leaq	static_string_ffe5c571af8dd3fc(%rip), %rax
	leaq	static_string_a0fcf35b7349c924(%rip), %rcx
	movl	$3435973837, %edx
	movl	%r14d, %esi
	.p2align	4
.LBB10_37:
	movq	$6, 80(%rsp)
	movq	%rax, 72(%rsp)
	movq	%r11, 88(%rsp)
	movq	$39, 24(%rsp)
	movq	%rcx, 16(%rsp)
	movq	%r11, 32(%rsp)
	cmpq	$21, %rbp
	je	.LBB10_134
	movl	%esi, %edi
	imulq	%rdx, %rdi
	shrq	$35, %rdi
	leal	(%rdi,%rdi), %r8d
	leal	(%r8,%r8,4), %r8d
	movl	%esi, %r9d
	subl	%r8d, %r9d
	movb	%r9b, 123(%rsp,%rbp)
	incq	%rbp
	cmpl	$10, %esi
	sbbq	$-1, %r13
	cmpl	$9, %esi
	movl	%edi, %esi
	ja	.LBB10_37
.LBB10_39:
	leaq	-1(%rbp), %r9
	movq	%rbx, %rcx
	subq	%rbp, %rcx
	testq	%r13, %r13
	sets	%al
	movq	%rcx, 112(%rsp)
	cmpq	$4, %rcx
	setge	%cl
	cmpq	$15, %r13
	jg	.LBB10_50
	andb	%cl, %al
	jne	.LBB10_50
	testq	%r13, %r13
	sets	%al
	cmpq	$0, 112(%rsp)
	setg	%cl
	testb	%cl, %al
	je	.LBB10_67
	movl	%r12d, %eax
	xorb	$1, %al
	andb	%r10b, %al
	cmpb	$1, %al
	jne	.LBB10_44
	movq	%r15, %rdi
	movq	56(%rsp), %rsi
	movq	48(%rsp), %rdx
	movl	%r10d, %r14d
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movabsq	$2305843009213693952, %r11
	movl	%r14d, %r10d
.LBB10_44:
	xorb	$1, %r10b
	movq	4096(%r15), %rdx
	leaq	2(%rdx), %rax
	cmpq	$4097, %rax
	jl	.LBB10_46
	movq	4104(%r15), %rax
	movl	(%rax), %edi
	movq	%r15, %rsi
	movl	%r10d, %r14d
	callq	write@PLT
	movabsq	$2305843009213693952, %r11
	movl	%r14d, %r10d
	movq	$0, 4096(%r15)
	xorl	%edx, %edx
.LBB10_46:
	andb	%r10b, %r12b
	movw	$11824, (%r15,%rdx)
	movq	4096(%r15), %rdx
	addq	$2, %rdx
	movq	%rdx, 4096(%r15)
	jmp	.LBB10_48
	.p2align	4
.LBB10_47:
	movb	$48, (%r15,%rdx)
	movq	4096(%r15), %rdx
	incq	%rdx
	movq	%rdx, 4096(%r15)
	decq	%rbx
	cmpq	%rbx, %rbp
	je	.LBB10_88
.LBB10_48:
	leaq	1(%rdx), %rax
	cmpq	$4097, %rax
	jl	.LBB10_47
	movq	4104(%r15), %rax
	movl	(%rax), %edi
	movq	%r15, %rsi
	callq	write@PLT
	movabsq	$2305843009213693952, %r11
	movq	$0, 4096(%r15)
	xorl	%edx, %edx
	jmp	.LBB10_47
.LBB10_50:
	cmpl	$9, %r14d
	movb	%r12b, 44(%rsp)
	ja	.LBB10_54
	movl	%r12d, %eax
	xorb	$1, %al
	andb	%r10b, %al
	cmpb	$1, %al
	jne	.LBB10_53
	movq	%r15, %rdi
	movq	56(%rsp), %rsi
	movq	48(%rsp), %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
.LBB10_53:
	movl	%r14d, %edi
	movq	%r15, %rsi
	callq	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=ui32,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]"@PLT
	movabsq	$2305843009213693952, %rsi
	cmpq	$2, %rbp
	leaq	-1(%rbp), %rcx
	jae	.LBB10_60
	jmp	.LBB10_63
.LBB10_54:
	movq	$6, 80(%rsp)
	leaq	static_string_ffe5c571af8dd3fc(%rip), %rax
	movq	%rax, 72(%rsp)
	movq	%r11, 88(%rsp)
	movq	$39, 24(%rsp)
	leaq	static_string_a0fcf35b7349c924(%rip), %rax
	movq	%rax, 16(%rsp)
	movq	%r11, 32(%rsp)
	cmpq	$21, %r9
	jae	.LBB10_144
	movzbl	123(%rsp,%r9), %ebx
	movl	%r12d, %eax
	xorb	$1, %al
	andb	%r10b, %al
	cmpb	$1, %al
	jne	.LBB10_57
	movq	%r15, %rdi
	movq	56(%rsp), %rsi
	movq	48(%rsp), %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
.LBB10_57:
	movzbl	%bl, %edi
	movq	%r15, %rsi
	callq	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=ui8,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]"@PLT
	movq	4096(%r15), %rdx
	leaq	1(%rdx), %rax
	cmpq	$4097, %rax
	jl	.LBB10_59
	movq	4104(%r15), %rax
	movl	(%rax), %edi
	movq	%r15, %rsi
	callq	write@PLT
	movq	$0, 4096(%r15)
	xorl	%edx, %edx
.LBB10_59:
	movb	$46, (%r15,%rdx)
	incq	4096(%r15)
	movabsq	$2305843009213693952, %rsi
	cmpq	$2, %rbp
	leaq	-1(%rbp), %rcx
	jb	.LBB10_63
.LBB10_60:
	movq	%rcx, %rax
	sarq	$63, %rax
	andnq	%rcx, %rax, %r9
	decq	%r9
	xorl	%ebx, %ebx
	cmpq	$3, %rbp
	setge	%bl
	movq	%r9, %rax
	subq	%rbx, %rax
	leaq	static_string_ffe5c571af8dd3fc(%rip), %r14
	leaq	static_string_a0fcf35b7349c924(%rip), %r15
	.p2align	4
.LBB10_61:
	movq	$6, 80(%rsp)
	movq	%r14, 72(%rsp)
	movq	%rsi, 88(%rsp)
	movq	$39, 24(%rsp)
	movq	%r15, 16(%rsp)
	movq	%rsi, 32(%rsp)
	cmpq	$21, %r9
	jae	.LBB10_137
	movq	%rax, %r12
	movzbl	123(%rsp,%r9), %edi
	movq	8(%rsp), %rsi
	callq	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=ui8,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]"@PLT
	testq	%r12, %r12
	setg	%cl
	movl	%ebx, %eax
	andb	%cl, %al
	movzbl	%al, %edx
	movq	%r12, %rax
	subq	%rdx, %rax
	movq	%r12, %r9
	testb	$1, %bl
	movl	%ecx, %ebx
	movabsq	$2305843009213693952, %rsi
	jne	.LBB10_61
.LBB10_63:
	testq	%r13, %r13
	js	.LBB10_101
	movq	8(%rsp), %rbx
	movq	4096(%rbx), %rdx
	leaq	2(%rdx), %rax
	cmpq	$4097, %rax
	jl	.LBB10_66
	movq	4104(%rbx), %rax
	movl	(%rax), %edi
	movq	%rbx, %rsi
	callq	write@PLT
	movabsq	$2305843009213693952, %rsi
	movq	$0, 4096(%rbx)
	xorl	%edx, %edx
.LBB10_66:
	movw	$11109, (%rbx,%rdx)
	movq	4096(%rbx), %rdx
	addq	$2, %rdx
	movq	%rdx, 4096(%rbx)
	cmpq	$10, %r13
	jl	.LBB10_104
	jmp	.LBB10_107
.LBB10_67:
	testq	%rbp, %rbp
	je	.LBB10_117
	xorl	%ecx, %ecx
	movq	%rbp, %rax
	subq	$2, %rax
	movq	%rax, 144(%rsp)
	setge	%cl
	movq	%r9, %rax
	subq	%rcx, %rax
	xorb	$1, %r10b
	xorl	%ebx, %ebx
	movq	%r9, %r14
	jmp	.LBB10_70
	.p2align	4
.LBB10_69:
	movl	4(%rsp), %eax
	orb	%bl, %al
	movl	%eax, %ebx
	andb	%r15b, %r12b
	movzbl	%r14b, %edi
	movq	8(%rsp), %r15
	movq	%r15, %rsi
	callq	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=ui8,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]"@PLT
	movq	104(%rsp), %r14
	testq	%r14, %r14
	setg	%cl
	movq	96(%rsp), %rsi
	movl	%esi, %eax
	andb	%cl, %al
	movzbl	%al, %edx
	movq	%r14, %rax
	subq	%rdx, %rax
	movb	$1, %r10b
	testb	$1, %sil
	movabsq	$2305843009213693952, %r11
	je	.LBB10_114
.LBB10_70:
	movq	%rcx, 96(%rsp)
	movl	%ebx, 4(%rsp)
	movb	%r12b, 44(%rsp)
	movq	%rax, 104(%rsp)
	cmpq	$0, 112(%rsp)
	setle	%al
	movq	144(%rsp), %rcx
	subq	%r14, %rcx
	cmpq	%rcx, %r13
	sete	%bl
	andb	%al, %bl
	cmpb	$1, %bl
	jne	.LBB10_78
	movl	%r10d, %r12d
	movl	%r10d, %edx
	orb	44(%rsp), %dl
	leaq	-1(%rbp), %rax
	cmpq	%rax, %r14
	jne	.LBB10_79
	movq	$1, 24(%rsp)
	leaq	static_string_8439ccbd1c202210(%rip), %rsi
	movq	%rsi, 16(%rsp)
	movq	%r11, 32(%rsp)
	movl	$1, %eax
	movq	%r11, %rcx
	testb	$1, %dl
	jne	.LBB10_74
	movq	%r15, %rdi
	movq	56(%rsp), %rsi
	movq	48(%rsp), %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	32(%rsp), %rcx
	movq	16(%rsp), %rsi
	movq	24(%rsp), %rax
.LBB10_74:
	movq	%rcx, %rdx
	shrq	$56, %rdx
	andl	$31, %edx
	testq	%rcx, %rcx
	leaq	16(%rsp), %rcx
	cmovsq	%rcx, %rsi
	cmovnsq	%rax, %rdx
	movq	%r15, %rdi
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movabsq	$4611686018427387904, %rax
	testq	%rax, 32(%rsp)
	je	.LBB10_77
	movq	16(%rsp), %rdi
	lock		decq	-8(%rdi)
	jne	.LBB10_77
	addq	$-8, %rdi
	#MEMBARRIER
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB10_77:
	movq	$1, 24(%rsp)
	leaq	static_string_00747f69c2b26145(%rip), %rsi
	movq	%rsi, 16(%rsp)
	movabsq	$2305843009213693952, %rcx
	movq	%rcx, 32(%rsp)
	movl	$1, %eax
	jmp	.LBB10_81
	.p2align	4
.LBB10_78:
	movzbl	44(%rsp), %r15d
	jmp	.LBB10_85
	.p2align	4
.LBB10_79:
	movq	$1, 24(%rsp)
	leaq	static_string_00747f69c2b26145(%rip), %rsi
	movq	%rsi, 16(%rsp)
	movq	%r11, 32(%rsp)
	movl	$1, %eax
	movq	%r11, %rcx
	testb	$1, %dl
	jne	.LBB10_81
	movq	%r15, %rdi
	movq	56(%rsp), %rsi
	movq	48(%rsp), %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	32(%rsp), %rcx
	movq	16(%rsp), %rsi
	movq	24(%rsp), %rax
.LBB10_81:
	movq	%rcx, %rdx
	shrq	$56, %rdx
	andl	$31, %edx
	testq	%rcx, %rcx
	leaq	16(%rsp), %rcx
	cmovsq	%rcx, %rsi
	cmovnsq	%rax, %rdx
	movq	%r15, %rdi
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movabsq	$4611686018427387904, %rax
	testq	%rax, 32(%rsp)
	je	.LBB10_84
	movq	16(%rsp), %rdi
	lock		decq	-8(%rdi)
	jne	.LBB10_84
	addq	$-8, %rdi
	#MEMBARRIER
	callq	KGEN_CompilerRT_AlignedFree@PLT
.LBB10_84:
	movzbl	44(%rsp), %r15d
	movl	%r12d, %r10d
	andb	%r10b, %r15b
	movabsq	$2305843009213693952, %r11
.LBB10_85:
	movq	$6, 80(%rsp)
	leaq	static_string_ffe5c571af8dd3fc(%rip), %rax
	movq	%rax, 72(%rsp)
	movq	%r11, 88(%rsp)
	movq	$39, 24(%rsp)
	leaq	static_string_a0fcf35b7349c924(%rip), %rax
	movq	%rax, 16(%rsp)
	movq	%r11, 32(%rsp)
	cmpq	$21, %r14
	jae	.LBB10_138
	movzbl	123(%rsp,%r14), %r14d
	movl	%r10d, %eax
	orb	%bl, %al
	movl	%eax, %r12d
	orb	%r15b, %al
	testb	$1, %al
	jne	.LBB10_69
	movq	8(%rsp), %rdi
	movq	56(%rsp), %rsi
	movq	48(%rsp), %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	jmp	.LBB10_69
.LBB10_88:
	movl	%r12d, %r13d
	testq	%rbp, %rbp
	leaq	-1(%rbp), %rdx
	je	.LBB10_92
	xorl	%ebx, %ebx
	cmpq	$2, %rbp
	setge	%bl
	movq	%rdx, %rax
	subq	%rbx, %rax
	leaq	static_string_ffe5c571af8dd3fc(%rip), %r14
	leaq	static_string_a0fcf35b7349c924(%rip), %r15
	.p2align	4
.LBB10_90:
	movq	$6, 80(%rsp)
	movq	%r14, 72(%rsp)
	movq	%r11, 88(%rsp)
	movq	$39, 24(%rsp)
	movq	%r15, 16(%rsp)
	movq	%r11, 32(%rsp)
	cmpq	$21, %rdx
	jae	.LBB10_139
	movq	%rax, %r12
	movzbl	123(%rsp,%rdx), %edi
	movq	8(%rsp), %rsi
	callq	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=ui8,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]"@PLT
	testq	%r12, %r12
	setg	%cl
	movl	%ebx, %eax
	andb	%cl, %al
	movzbl	%al, %edx
	movq	%r12, %rax
	subq	%rdx, %rax
	movq	%r12, %rdx
	testb	$1, %bl
	movl	%ecx, %ebx
	movabsq	$2305843009213693952, %r11
	jne	.LBB10_90
.LBB10_92:
	xorl	%ebx, %ebx
	movq	64(%rsp), %rax
	movq	8(%rsp), %r15
	movl	%r13d, %r12d
	jmp	.LBB10_133
.LBB10_93:
	movl	%edx, %eax
	notb	%al
	andb	%cl, %al
	testb	$1, %al
	movq	8(%rsp), %r15
	je	.LBB10_95
	movq	%r15, %rdi
	movq	56(%rsp), %rsi
	movl	%edx, %ebx
	movq	48(%rsp), %rdx
	movl	%ecx, %ebp
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movl	%ebp, %ecx
	movl	%ebx, %edx
.LBB10_95:
	movq	4096(%r15), %rax
	leaq	1(%rax), %rsi
	movl	%edx, %ebx
	cmpq	$4097, %rsi
	jl	.LBB10_97
	movq	4104(%r15), %rdx
	movl	(%rdx), %edi
	movq	%r15, %rsi
	movq	%rax, %rdx
	movl	%ecx, %ebp
	callq	write@PLT
	movl	%ebp, %ecx
	movq	$0, 4096(%r15)
	xorl	%eax, %eax
.LBB10_97:
	movb	$45, (%r15,%rax)
	incq	4096(%r15)
	movl	%ecx, %r10d
.LBB10_98:
	xorb	$1, %r10b
	movq	4096(%r15), %rdx
	leaq	3(%rdx), %rax
	cmpq	$4097, %rax
	jl	.LBB10_100
	movq	4104(%r15), %rax
	movl	(%rax), %edi
	movq	%r15, %rsi
	movl	%r10d, %ebp
	callq	write@PLT
	movl	%ebp, %r10d
	movq	$0, 4096(%r15)
	xorl	%edx, %edx
.LBB10_100:
	movq	64(%rsp), %rax
	andb	%bl, %r10b
	movw	$11824, (%r15,%rdx)
	movb	$48, 2(%r15,%rdx)
	addq	$3, 4096(%r15)
	xorl	%ebx, %ebx
	movl	%r10d, %r12d
	jmp	.LBB10_133
.LBB10_101:
	movq	8(%rsp), %rbx
	movq	4096(%rbx), %rdx
	leaq	2(%rdx), %rax
	cmpq	$4097, %rax
	jl	.LBB10_103
	movq	4104(%rbx), %rax
	movl	(%rax), %edi
	movq	%rbx, %rsi
	callq	write@PLT
	movabsq	$2305843009213693952, %rsi
	movq	$0, 4096(%rbx)
	xorl	%edx, %edx
.LBB10_103:
	movw	$11621, (%rbx,%rdx)
	movq	4096(%rbx), %rdx
	addq	$2, %rdx
	movq	%rdx, 4096(%rbx)
	negq	%r13
	cmpq	$10, %r13
	jge	.LBB10_107
.LBB10_104:
	leaq	1(%rdx), %rax
	cmpq	$4097, %rax
	jl	.LBB10_106
	movq	4104(%rbx), %rax
	movl	(%rax), %edi
	movq	%rbx, %rsi
	callq	write@PLT
	movabsq	$2305843009213693952, %rsi
	movq	$0, 4096(%rbx)
	xorl	%edx, %edx
.LBB10_106:
	movb	$48, (%rbx,%rdx)
	incq	4096(%rbx)
	testq	%r13, %r13
	jle	.LBB10_113
.LBB10_107:
	movq	$-1, %r9
	leaq	static_string_ffe5c571af8dd3fc(%rip), %rbx
	leaq	static_string_a0fcf35b7349c924(%rip), %r14
	movabsq	$-3689348814741910323, %rax
	.p2align	4
.LBB10_108:
	movq	$6, 80(%rsp)
	movq	%rbx, 72(%rsp)
	movq	%rsi, 88(%rsp)
	movq	$39, 24(%rsp)
	movq	%r14, 16(%rsp)
	movq	%rsi, 32(%rsp)
	cmpq	$9, %r9
	je	.LBB10_135
	movq	%r13, %rdx
	mulxq	%rax, %rcx, %rcx
	shrq	$3, %rcx
	imull	$246, %ecx, %edx
	addl	%r13d, %edx
	movb	%dl, 124(%rsp,%r9)
	incq	%r9
	cmpq	$9, %r13
	movq	%rcx, %r13
	ja	.LBB10_108
	xorl	%r15d, %r15d
	testq	%r9, %r9
	setne	%r15b
	movq	%r9, %rax
	subq	%r15, %rax
	.p2align	4
.LBB10_111:
	movq	$6, 80(%rsp)
	movq	%rbx, 72(%rsp)
	movq	%rsi, 88(%rsp)
	movq	$39, 24(%rsp)
	movq	%r14, 16(%rsp)
	movq	%rsi, 32(%rsp)
	cmpq	$10, %r9
	jae	.LBB10_136
	movq	%rax, %r12
	movzbl	123(%rsp,%r9), %edi
	movq	8(%rsp), %rsi
	callq	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=ui8,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]"@PLT
	testq	%r12, %r12
	setg	%cl
	movl	%r15d, %eax
	andb	%cl, %al
	movzbl	%al, %edx
	movq	%r12, %rax
	subq	%rdx, %rax
	movq	%r12, %r9
	testb	$1, %r15b
	movl	%ecx, %r15d
	movabsq	$2305843009213693952, %rsi
	jne	.LBB10_111
.LBB10_113:
	movl	4(%rsp), %eax
	xorb	$1, %al
	movzbl	44(%rsp), %r12d
	andb	%al, %r12b
	xorl	%ebx, %ebx
	movq	64(%rsp), %rax
	movq	8(%rsp), %r15
	jmp	.LBB10_133
.LBB10_114:
	xorl	%r10d, %r10d
	subq	%rbp, %r13
	movabsq	$9223372036854775806, %rax
	cmpq	%rax, %r13
	ja	.LBB10_115
.LBB10_118:
	movl	%ebx, 4(%rsp)
	xorb	$1, %r10b
	incq	%r13
	leaq	static_string_8439ccbd1c202210(%rip), %rbx
	leaq	16(%rsp), %r14
	jmp	.LBB10_120
	.p2align	4
.LBB10_119:
	andb	%bpl, %r12b
	movb	$1, %r10b
	decq	%r13
	movabsq	$2305843009213693952, %r11
	je	.LBB10_126
.LBB10_120:
	movl	%r12d, %ebp
	movl	%r10d, %r12d
	movq	$1, 24(%rsp)
	movq	%rbx, 16(%rsp)
	movq	%r11, 32(%rsp)
	movl	$1, %eax
	movq	%rbx, %rsi
	movq	%r11, %rcx
	testb	$1, %r10b
	jne	.LBB10_123
	testb	$1, %bpl
	jne	.LBB10_123
	movq	%r15, %rdi
	movq	56(%rsp), %rsi
	movq	48(%rsp), %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	32(%rsp), %rcx
	movq	16(%rsp), %rsi
	movq	24(%rsp), %rax
.LBB10_123:
	movq	%rcx, %rdx
	shrq	$56, %rdx
	andl	$31, %edx
	testq	%rcx, %rcx
	cmovsq	%r14, %rsi
	cmovnsq	%rax, %rdx
	movq	%r15, %rdi
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movabsq	$4611686018427387904, %rax
	testq	%rax, 32(%rsp)
	je	.LBB10_119
	movq	16(%rsp), %rdi
	lock		decq	-8(%rdi)
	jne	.LBB10_119
	addq	$-8, %rdi
	#MEMBARRIER
	callq	KGEN_CompilerRT_AlignedFree@PLT
	jmp	.LBB10_119
.LBB10_126:
	xorl	%r10d, %r10d
	movl	4(%rsp), %ebx
	testb	$1, %bl
	jne	.LBB10_116
.LBB10_127:
	xorb	$1, %r10b
	movl	%r10d, %eax
	orb	%r12b, %al
	testb	$1, %al
	jne	.LBB10_129
	movq	%r15, %rdi
	movq	56(%rsp), %rsi
	movq	48(%rsp), %rdx
	movl	%r10d, %ebx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movl	%ebx, %r10d
.LBB10_129:
	movq	4096(%r15), %rdx
	leaq	2(%rdx), %rax
	cmpq	$4097, %rax
	jl	.LBB10_131
	movq	4104(%r15), %rax
	movl	(%rax), %edi
	movq	%r15, %rsi
	movl	%r10d, %ebx
	callq	write@PLT
	movl	%ebx, %r10d
	movq	$0, 4096(%r15)
	xorl	%edx, %edx
.LBB10_131:
	movq	64(%rsp), %rax
	andb	%r10b, %r12b
	movw	$12334, (%r15,%rdx)
	addq	$2, 4096(%r15)
	jmp	.LBB10_132
.LBB10_117:
	xorl	%ebx, %ebx
	subq	%rbp, %r13
	movabsq	$9223372036854775806, %rax
	cmpq	%rax, %r13
	jbe	.LBB10_118
.LBB10_115:
	testb	$1, %bl
	je	.LBB10_127
.LBB10_116:
	andb	%r10b, %bl
	movq	64(%rsp), %rax
.LBB10_133:
	movq	48(%rsp), %rcx
	movq	%rcx, 24(%rax)
	movq	56(%rsp), %rcx
	movq	%rcx, 16(%rax)
	movb	%bl, 9(%rax)
	movq	%r15, (%rax)
	andb	$1, %r12b
	movb	%r12b, 8(%rax)
	addq	$152, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB10_134:
	.cfi_def_cfa_offset 208
	leaq	16(%rsp), %rax
	leaq	static_string_422d2414495ed121(%rip), %rdx
	leaq	72(%rsp), %r8
	movl	$257, %edi
	movl	$19, %esi
	movl	$42, %ecx
	movl	$21, %r9d
	pushq	$20
	.cfi_adjust_cfa_offset 8
	pushq	%rax
	.cfi_adjust_cfa_offset 8
	callq	"std::builtin::debug_assert::_debug_assert_fail_format[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2]](::SourceLocation,*$0),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>]]"@PLT
.LBB10_135:
	.cfi_def_cfa_offset 208
	leaq	16(%rsp), %rax
	leaq	static_string_422d2414495ed121(%rip), %rdx
	leaq	72(%rsp), %r8
	movl	$288, %edi
	movl	$27, %esi
	movl	$42, %ecx
	movl	$10, %r9d
	pushq	$9
	.cfi_adjust_cfa_offset 8
	pushq	%rax
	.cfi_adjust_cfa_offset 8
	callq	"std::builtin::debug_assert::_debug_assert_fail_format[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2]](::SourceLocation,*$0),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>]]"@PLT
.LBB10_136:
	.cfi_def_cfa_offset 208
	leaq	16(%rsp), %rax
	leaq	static_string_422d2414495ed121(%rip), %rdx
	leaq	72(%rsp), %r8
	movl	$292, %edi
	movl	$40, %esi
	movl	$42, %ecx
	pushq	$9
	.cfi_adjust_cfa_offset 8
	pushq	%rax
	.cfi_adjust_cfa_offset 8
	callq	"std::builtin::debug_assert::_debug_assert_fail_format[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2]](::SourceLocation,*$0),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>]]"@PLT
.LBB10_137:
	.cfi_def_cfa_offset 208
	leaq	16(%rsp), %rax
	leaq	static_string_422d2414495ed121(%rip), %rdx
	leaq	72(%rsp), %r8
	movl	$275, %edi
	jmp	.LBB10_140
.LBB10_138:
	leaq	static_string_422d2414495ed121(%rip), %rdx
	leaq	72(%rsp), %r8
	movl	$310, %edi
	movl	$36, %esi
	movl	$42, %ecx
	movq	%r14, %r9
	pushq	$20
	.cfi_adjust_cfa_offset 8
	leaq	24(%rsp), %rax
	pushq	%rax
	.cfi_adjust_cfa_offset 8
	callq	"std::builtin::debug_assert::_debug_assert_fail_format[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2]](::SourceLocation,*$0),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>]]"@PLT
.LBB10_139:
	.cfi_def_cfa_offset 208
	leaq	16(%rsp), %rax
	movq	%rdx, %r9
	leaq	static_string_422d2414495ed121(%rip), %rdx
	leaq	72(%rsp), %r8
	movl	$299, %edi
.LBB10_140:
	movl	$36, %esi
	movl	$42, %ecx
	pushq	$20
	.cfi_adjust_cfa_offset 8
	pushq	%rax
	.cfi_adjust_cfa_offset 8
	callq	"std::builtin::debug_assert::_debug_assert_fail_format[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2]](::SourceLocation,*$0),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>]]"@PLT
.LBB10_141:
	.cfi_def_cfa_offset 208
	movl	%ecx, %r12d
	xorb	$1, %r12b
	movl	%edx, %ebx
	movl	%edx, %eax
	notb	%al
	andb	%cl, %al
	testb	$1, %al
	je	.LBB10_143
	movq	8(%rsp), %rdi
	movq	56(%rsp), %rsi
	movq	48(%rsp), %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
.LBB10_143:
	andb	%bl, %r12b
	leaq	static_string_e5411518d45eb182(%rip), %rsi
	movl	$3, %edx
	movq	8(%rsp), %r15
	movq	%r15, %rdi
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	xorl	%ebx, %ebx
	movq	64(%rsp), %rax
	jmp	.LBB10_133
.LBB10_144:
	leaq	16(%rsp), %rax
	leaq	static_string_422d2414495ed121(%rip), %rdx
	leaq	72(%rsp), %r8
	movl	$271, %edi
	jmp	.LBB10_140
.Lfunc_end10:
	.size	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=f32,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_SequenceWriter,origin._mlir_origin`={  },W=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>],origin={  }>>, struct<(pointer<none>, scalar<bool>, scalar<bool>, struct<(pointer<none>, scalar<index>)>) memoryOnly>]", .Lfunc_end10-"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=f32,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_SequenceWriter,origin._mlir_origin`={  },W=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>],origin={  }>>, struct<(pointer<none>, scalar<bool>, scalar<bool>, struct<(pointer<none>, scalar<index>)>) memoryOnly>]"
	.cfi_endproc

	.prefalign	4, .Lfunc_end11, nop
	.type	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=index,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FixedWriteBuffer>>, struct<(struct<(array<2048, scalar<ui8>>) memoryOnly>, scalar<index>) memoryOnly>]",@function
"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=index,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FixedWriteBuffer>>, struct<(struct<(array<2048, scalar<ui8>>) memoryOnly>, scalar<index>) memoryOnly>]":
	.cfi_startproc
	pushq	%r14
	.cfi_def_cfa_offset 16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	subq	$104, %rsp
	.cfi_def_cfa_offset 128
	.cfi_offset %rbx, -24
	.cfi_offset %r14, -16
	testq	%rdi, %rdi
	je	.LBB11_1
	movq	%rdi, %rcx
	movq	2048(%rsi), %rdi
	jns	.LBB11_7
	leaq	1(%rdi), %rax
	cmpq	$2049, %rax
	jge	.LBB11_28
	movb	$45, (%rsi,%rdi)
	movq	2048(%rsi), %rdi
	incq	%rdi
	movq	%rdi, 2048(%rsi)
.LBB11_7:
	cmpq	$2049, %rdi
	jge	.LBB11_28
	movb	$0, 103(%rsp)
	movl	$63, %r8d
	testq	%rcx, %rcx
	js	.LBB11_9
	leaq	static_string_978d8d34847e5196(%rip), %rax
	movabsq	$-3689348814741910323, %r9
	.p2align	4
.LBB11_12:
	movq	%rcx, %rdx
	mulxq	%r9, %rdx, %rdx
	shrq	$3, %rdx
	leaq	(%rdx,%rdx), %r10
	leaq	(%r10,%r10,4), %r10
	movq	%rcx, %r11
	subq	%r10, %r11
	movzbl	(%rax,%r11), %r10d
	movb	%r10b, 39(%rsp,%r8)
	decq	%r8
	cmpq	$10, %rcx
	movq	%rdx, %rcx
	jae	.LBB11_12
	jmp	.LBB11_13
.LBB11_1:
	movq	2048(%rsi), %rax
	cmpq	$2048, %rax
	jg	.LBB11_28
	je	.LBB11_28
	movb	$48, (%rsi,%rax)
	incq	2048(%rsi)
	addq	$104, %rsp
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	retq
.LBB11_9:
	.cfi_def_cfa_offset 128
	movabsq	$7378697629483820647, %r9
	leaq	static_string_978d8d34847e5196(%rip), %r10
	movabsq	$-7378697629483820647, %r11
	.p2align	4
.LBB11_10:
	movq	%rcx, %rax
	imulq	%r9
	movq	%rdx, %rax
	shrq	$63, %rax
	sarq	$2, %rdx
	addq	%rax, %rdx
	addq	%rdx, %rdx
	leaq	(%rdx,%rdx,4), %rax
	movq	%rcx, %rdx
	subq	%rax, %rdx
	testq	%rcx, %rcx
	setns	%bl
	testq	%rdx, %rdx
	movq	$-10, %rax
	cmoveq	%rdx, %rax
	movq	%rcx, %r14
	sarq	$63, %r14
	andnq	%rax, %r14, %rax
	addq	%rdx, %rax
	movq	%rax, %rdx
	negq	%rdx
	cmovsq	%rax, %rdx
	movzbl	(%rdx,%r10), %eax
	movb	%al, 39(%rsp,%r8)
	decq	%r8
	movq	%rcx, %rax
	imulq	%r11
	movq	%rdx, %rax
	shrq	$63, %rax
	sarq	$2, %rdx
	addq	%rax, %rdx
	leaq	(%rdx,%rdx), %rax
	leaq	(%rax,%rax,4), %rax
	addq	%rcx, %rax
	setne	%al
	andb	%bl, %al
	movzbl	%al, %ecx
	subq	%rdx, %rcx
	jne	.LBB11_10
.LBB11_13:
	movl	$63, %ecx
	subq	%r8, %rcx
	leaq	(%rcx,%rdi), %rax
	cmpq	$2049, %rax
	jge	.LBB11_28
	cmpq	$63, %r8
	jne	.LBB11_15
.LBB11_26:
	addq	%rcx, 2048(%rsi)
	addq	$104, %rsp
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	retq
.LBB11_15:
	.cfi_def_cfa_offset 128
	leaq	(%rsp,%r8), %rdx
	addq	$39, %rdx
	leaq	(%rsp,%r8), %rax
	addq	$40, %rax
	addq	%rsi, %rdi
	cmpq	$4, %rcx
	jg	.LBB11_18
	movl	$62, %r9d
	subq	%r8, %r9
	movzbl	(%rax), %eax
	movb	%al, (%rdi)
	movzbl	102(%rsp), %eax
	movb	%al, (%rdi,%r9)
	cmpq	$3, %rcx
	jl	.LBB11_26
	movl	$61, %eax
	subq	%r8, %rax
	movzbl	2(%rdx), %edx
	movb	%dl, 1(%rdi)
	movzbl	101(%rsp), %edx
	movb	%dl, (%rdi,%rax)
	jmp	.LBB11_26
.LBB11_18:
	cmpq	$16, %rcx
	ja	.LBB11_22
	cmpq	$8, %rcx
	jb	.LBB11_21
	movl	$55, %edx
	subq	%r8, %rdx
	movq	(%rax), %rax
	movq	%rax, (%rdi)
	movq	95(%rsp), %rax
	movq	%rax, (%rdi,%rdx)
	jmp	.LBB11_26
.LBB11_22:
	movabsq	$9223372036854775776, %rbx
	andq	%rcx, %rbx
	movq	%rsi, 8(%rsp)
	je	.LBB11_24
	movq	%rcx, 24(%rsp)
	movq	%rdx, 16(%rsp)
	movl	$31, %edx
	subq	%r8, %rdx
	andq	$-32, %rdx
	addq	$32, %rdx
	movq	%rdi, (%rsp)
	movq	(%rsp), %rdi
	movq	%rax, %rsi
	callq	memcpy@PLT
	movq	16(%rsp), %rdx
	movq	24(%rsp), %rcx
	movq	(%rsp), %rdi
	movq	8(%rsp), %rsi
.LBB11_24:
	cmpq	%rcx, %rbx
	je	.LBB11_26
	addq	%rbx, %rdi
	leaq	(%rdx,%rbx), %rsi
	incq	%rsi
	movq	%rcx, %rbx
	movl	%ebx, %edx
	andl	$31, %edx
	callq	memcpy@PLT
	movq	%rbx, %rcx
	movq	8(%rsp), %rsi
	jmp	.LBB11_26
.LBB11_21:
	movl	$59, %edx
	subq	%r8, %rdx
	movl	(%rax), %eax
	movl	%eax, (%rdi)
	movl	99(%rsp), %eax
	movl	%eax, (%rdi,%rdx)
	jmp	.LBB11_26
.LBB11_28:
	callq	"std::format::_utils::_fixed_buffer_exceeded()"@PLT
.Lfunc_end11:
	.size	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=index,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FixedWriteBuffer>>, struct<(struct<(array<2048, scalar<ui8>>) memoryOnly>, scalar<index>) memoryOnly>]", .Lfunc_end11-"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=index,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FixedWriteBuffer>>, struct<(struct<(array<2048, scalar<ui8>>) memoryOnly>, scalar<index>) memoryOnly>]"
	.cfi_endproc

	.prefalign	4, .Lfunc_end12, nop
	.type	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=index,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]",@function
"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=index,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]":
	.cfi_startproc
	pushq	%r14
	.cfi_def_cfa_offset 16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	subq	$72, %rsp
	.cfi_def_cfa_offset 96
	.cfi_offset %rbx, -24
	.cfi_offset %r14, -16
	movq	%rsi, %rbx
	movq	%rdi, %r14
	testq	%rdi, %rdi
	js	.LBB12_1
	movq	4096(%rbx), %rdx
	je	.LBB12_9
	cmpq	$4097, %rdx
	jl	.LBB12_14
	movq	4104(%rbx), %rax
	movl	(%rax), %edi
	movq	%rbx, %rsi
	callq	write@PLT
	movq	$0, 4096(%rbx)
.LBB12_14:
	movb	$0, 71(%rsp)
	xorl	%eax, %eax
	leaq	static_string_978d8d34847e5196(%rip), %rcx
	movabsq	$-3689348814741910323, %rsi
	.p2align	4
.LBB12_15:
	movq	%r14, %rdx
	mulxq	%rsi, %rdx, %rdx
	shrq	$3, %rdx
	leaq	(%rdx,%rdx), %rdi
	leaq	(%rdi,%rdi,4), %rdi
	movq	%r14, %r8
	subq	%rdi, %r8
	movzbl	(%rcx,%r8), %edi
	movb	%dil, 70(%rsp,%rax)
	decq	%rax
	cmpq	$9, %r14
	movq	%rdx, %r14
	ja	.LBB12_15
	leaq	(%rsp,%rax), %rsi
	addq	$71, %rsi
	negq	%rax
	movq	%rbx, %rdi
	movq	%rax, %rdx
	jmp	.LBB12_17
.LBB12_1:
	movq	4096(%rbx), %rdx
	leaq	1(%rdx), %rax
	cmpq	$4097, %rax
	jl	.LBB12_3
	movq	4104(%rbx), %rax
	movl	(%rax), %edi
	movq	%rbx, %rsi
	callq	write@PLT
	movq	$0, 4096(%rbx)
	xorl	%edx, %edx
.LBB12_3:
	movb	$45, (%rbx,%rdx)
	movq	4096(%rbx), %rdx
	incq	%rdx
	movq	%rdx, 4096(%rbx)
	cmpq	$4097, %rdx
	jl	.LBB12_5
	movq	4104(%rbx), %rax
	movl	(%rax), %edi
	movq	%rbx, %rsi
	callq	write@PLT
	movq	$0, 4096(%rbx)
.LBB12_5:
	movb	$0, 71(%rsp)
	xorl	%ecx, %ecx
	movabsq	$7378697629483820647, %rsi
	leaq	static_string_978d8d34847e5196(%rip), %rdi
	movabsq	$-7378697629483820647, %r8
	.p2align	4
.LBB12_6:
	movq	%r14, %rax
	imulq	%rsi
	movq	%rdx, %rax
	shrq	$63, %rax
	sarq	$2, %rdx
	addq	%rax, %rdx
	addq	%rdx, %rdx
	leaq	(%rdx,%rdx,4), %rax
	movq	%r14, %rdx
	subq	%rax, %rdx
	testq	%r14, %r14
	setns	%r9b
	testq	%rdx, %rdx
	movq	$-10, %rax
	cmoveq	%rdx, %rax
	movq	%r14, %r10
	sarq	$63, %r10
	andnq	%rax, %r10, %rax
	addq	%rdx, %rax
	movq	%rax, %r10
	negq	%r10
	cmovsq	%rax, %r10
	movq	%r14, %rax
	imulq	%r8
	movzbl	(%r10,%rdi), %eax
	movb	%al, 70(%rsp,%rcx)
	movq	%rdx, %rax
	shrq	$63, %rax
	sarq	$2, %rdx
	addq	%rax, %rdx
	leaq	(%rdx,%rdx), %rax
	leaq	(%rax,%rax,4), %rax
	addq	%r14, %rax
	setne	%al
	andb	%r9b, %al
	movzbl	%al, %r14d
	decq	%rcx
	subq	%rdx, %r14
	jne	.LBB12_6
	leaq	(%rsp,%rcx), %rsi
	addq	$71, %rsi
	negq	%rcx
	movq	%rbx, %rdi
	movq	%rcx, %rdx
.LBB12_17:
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	addq	$72, %rsp
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	retq
.LBB12_9:
	.cfi_def_cfa_offset 96
	cmpq	$4097, %rdx
	setl	%al
	cmpq	$4096, %rdx
	setne	%cl
	testb	%cl, %al
	jne	.LBB12_11
	movq	4104(%rbx), %rax
	movl	(%rax), %edi
	movq	%rbx, %rsi
	callq	write@PLT
	movq	$0, 4096(%rbx)
	xorl	%edx, %edx
.LBB12_11:
	movb	$48, (%rbx,%rdx)
	incq	4096(%rbx)
	addq	$72, %rsp
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end12:
	.size	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=index,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]", .Lfunc_end12-"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=index,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]"
	.cfi_endproc

	.prefalign	4, .Lfunc_end13, nop
	.type	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=ui32,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]",@function
"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=ui32,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]":
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	subq	$72, %rsp
	.cfi_def_cfa_offset 96
	.cfi_offset %rbx, -24
	.cfi_offset %rbp, -16
	movq	%rsi, %rbx
	movq	4096(%rsi), %rdx
	testl	%edi, %edi
	je	.LBB13_1
	cmpq	$4097, %rdx
	jl	.LBB13_6
	movq	4104(%rbx), %rax
	movl	(%rax), %eax
	movl	%edi, %ebp
	movl	%eax, %edi
	movq	%rbx, %rsi
	callq	write@PLT
	movl	%ebp, %edi
	movq	$0, 4096(%rbx)
.LBB13_6:
	movb	$0, 71(%rsp)
	xorl	%edx, %edx
	movl	$3435973837, %eax
	leaq	static_string_978d8d34847e5196(%rip), %rcx
	.p2align	4
.LBB13_7:
	movl	%edi, %esi
	imulq	%rax, %rsi
	shrq	$35, %rsi
	leal	(%rsi,%rsi), %r8d
	leal	(%r8,%r8,4), %r8d
	movl	%edi, %r9d
	subl	%r8d, %r9d
	movzbl	(%r9,%rcx), %r8d
	movb	%r8b, 70(%rsp,%rdx)
	decq	%rdx
	cmpl	$9, %edi
	movl	%esi, %edi
	ja	.LBB13_7
	leaq	(%rsp,%rdx), %rsi
	addq	$71, %rsi
	negq	%rdx
	movq	%rbx, %rdi
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	addq	$72, %rsp
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB13_1:
	.cfi_def_cfa_offset 96
	cmpq	$4097, %rdx
	setl	%al
	cmpq	$4096, %rdx
	setne	%cl
	testb	%cl, %al
	jne	.LBB13_3
	movq	4104(%rbx), %rax
	movl	(%rax), %edi
	movq	%rbx, %rsi
	callq	write@PLT
	movq	$0, 4096(%rbx)
	xorl	%edx, %edx
.LBB13_3:
	movb	$48, (%rbx,%rdx)
	incq	4096(%rbx)
	addq	$72, %rsp
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end13:
	.size	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=ui32,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]", .Lfunc_end13-"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=ui32,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]"
	.cfi_endproc

	.prefalign	4, .Lfunc_end14, nop
	.type	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=ui8,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]",@function
"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=ui8,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]":
	.cfi_startproc
	pushq	%r14
	.cfi_def_cfa_offset 16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	subq	$72, %rsp
	.cfi_def_cfa_offset 96
	.cfi_offset %rbx, -24
	.cfi_offset %r14, -16
	movq	%rsi, %rbx
	movq	4096(%rsi), %rdx
	testb	%dil, %dil
	je	.LBB14_1
	cmpq	$4097, %rdx
	jl	.LBB14_6
	movq	4104(%rbx), %rax
	movl	(%rax), %eax
	movq	%rdi, %r14
	movl	%eax, %edi
	movq	%rbx, %rsi
	callq	write@PLT
	movq	%r14, %rdi
	movq	$0, 4096(%rbx)
.LBB14_6:
	movb	$0, 71(%rsp)
	xorl	%edx, %edx
	leaq	static_string_978d8d34847e5196(%rip), %rax
	.p2align	4
.LBB14_7:
	movzbl	%dil, %ecx
	imull	$205, %ecx, %edi
	shrl	$11, %edi
	leal	(%rdi,%rdi), %esi
	leal	(%rsi,%rsi,4), %esi
	movl	%ecx, %r8d
	subb	%sil, %r8b
	movzbl	%r8b, %esi
	movzbl	(%rsi,%rax), %esi
	movb	%sil, 70(%rsp,%rdx)
	decq	%rdx
	cmpb	$9, %cl
	ja	.LBB14_7
	leaq	(%rsp,%rdx), %rsi
	addq	$71, %rsi
	negq	%rdx
	movq	%rbx, %rdi
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	addq	$72, %rsp
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	retq
.LBB14_1:
	.cfi_def_cfa_offset 96
	cmpq	$4097, %rdx
	setl	%al
	cmpq	$4096, %rdx
	setne	%cl
	testb	%cl, %al
	jne	.LBB14_3
	movq	4104(%rbx), %rax
	movl	(%rax), %edi
	movq	%rbx, %rsi
	callq	write@PLT
	movq	$0, 4096(%rbx)
	xorl	%edx, %edx
.LBB14_3:
	movb	$48, (%rbx,%rdx)
	incq	4096(%rbx)
	addq	$72, %rsp
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end14:
	.size	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=ui8,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]", .Lfunc_end14-"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=ui8,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]"
	.cfi_endproc

	.prefalign	4, .Lfunc_end15, nop
	.type	"std::builtin::_startup::__wrap_and_execute_raising_main[def() raises thin -> None](::SIMD[DType.int32, 1],!kgen.pointer<pointer<scalar<ui8>>>),main_func=accel-threshold.cpu::main()_closure_0",@function
"std::builtin::_startup::__wrap_and_execute_raising_main[def() raises thin -> None](::SIMD[DType.int32, 1],!kgen.pointer<pointer<scalar<ui8>>>),main_func=accel-threshold.cpu::main()_closure_0":
	.cfi_startproc
	jmp	KGEN_CompilerRT_AsyncRT_GetOrCreateCPUDevice@PLT
.Lfunc_end15:
	.size	"std::builtin::_startup::__wrap_and_execute_raising_main[def() raises thin -> None](::SIMD[DType.int32, 1],!kgen.pointer<pointer<scalar<ui8>>>),main_func=accel-threshold.cpu::main()_closure_0", .Lfunc_end15-"std::builtin::_startup::__wrap_and_execute_raising_main[def() raises thin -> None](::SIMD[DType.int32, 1],!kgen.pointer<pointer<scalar<ui8>>>),main_func=accel-threshold.cpu::main()_closure_0"
	.cfi_endproc

	.prefalign	4, .Lfunc_end16, nop
	.type	"std::builtin::_startup::__wrap_and_execute_raising_main[def() raises thin -> None](::SIMD[DType.int32, 1],!kgen.pointer<pointer<scalar<ui8>>>),main_func=accel-threshold.cpu::main()_closure_1",@function
"std::builtin::_startup::__wrap_and_execute_raising_main[def() raises thin -> None](::SIMD[DType.int32, 1],!kgen.pointer<pointer<scalar<ui8>>>),main_func=accel-threshold.cpu::main()_closure_1":
	.cfi_startproc
	jmp	KGEN_CompilerRT_AsyncRT_ReleaseCPUDevice@PLT
.Lfunc_end16:
	.size	"std::builtin::_startup::__wrap_and_execute_raising_main[def() raises thin -> None](::SIMD[DType.int32, 1],!kgen.pointer<pointer<scalar<ui8>>>),main_func=accel-threshold.cpu::main()_closure_1", .Lfunc_end16-"std::builtin::_startup::__wrap_and_execute_raising_main[def() raises thin -> None](::SIMD[DType.int32, 1],!kgen.pointer<pointer<scalar<ui8>>>),main_func=accel-threshold.cpu::main()_closure_1"
	.cfi_endproc

	.section	.text.unlikely.,"ax",@progbits
	.prefalign	4, .Lfunc_end17, nop
	.type	"std::builtin::debug_assert::_debug_assert_fail_format[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2]](::SourceLocation,*$0),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>]]",@function
"std::builtin::debug_assert::_debug_assert_fail_format[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2]](::SourceLocation,*$0),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>]]":
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$2072, %rsp
	.cfi_def_cfa_offset 2128
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%r9, %r13
	movq	%rcx, 8(%rsp)
	movq	%rdx, (%rsp)
	movq	%rsi, %r15
	movq	%rdi, %r12
	movq	2136(%rsp), %rbp
	movq	2128(%rsp), %rbx
	movq	$0, 2064(%rsp)
	leaq	16(%rsp), %r14
	movq	%r8, %rdi
	movq	%r14, %rsi
	callq	"std::collections::string::string::String::write_to[::Writer & ::AnyType](::String,$0),writer.T`2x1=[typevalue<#kgen.instref<std::format::_utils::_FixedWriteBuffer>>, struct<(struct<(array<2048, scalar<ui8>>) memoryOnly>, scalar<index>) memoryOnly>]"@PLT
	movq	%r13, %rdi
	movq	%r14, %rsi
	callq	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=index,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FixedWriteBuffer>>, struct<(struct<(array<2048, scalar<ui8>>) memoryOnly>, scalar<index>) memoryOnly>]"@PLT
	movq	%rbx, %rdi
	movq	%r14, %rsi
	callq	"std::collections::string::string::String::write_to[::Writer & ::AnyType](::String,$0),writer.T`2x1=[typevalue<#kgen.instref<std::format::_utils::_FixedWriteBuffer>>, struct<(struct<(array<2048, scalar<ui8>>) memoryOnly>, scalar<index>) memoryOnly>]"@PLT
	movq	%rbp, %rdi
	movq	%r14, %rsi
	callq	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=index,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FixedWriteBuffer>>, struct<(struct<(array<2048, scalar<ui8>>) memoryOnly>, scalar<index>) memoryOnly>]"@PLT
	movq	2064(%rsp), %rax
	leaq	1(%rax), %rcx
	cmpq	$2049, %rcx
	jl	.LBB17_2
	callq	"std::format::_utils::_fixed_buffer_exceeded()"@PLT
.LBB17_2:
	movb	$0, 16(%rsp,%rax)
	incq	2064(%rsp)
	leaq	16(%rsp), %rdi
	movq	%r12, %rsi
	movq	%r15, %rdx
	movq	(%rsp), %rcx
	movq	8(%rsp), %r8
	callq	"std::builtin::debug_assert::_debug_assert_msg[LITImmOrigin,::Origin[False, $0]](::Pointer[False, $0, ::SIMD[DType.uint8, 1], $1, AddressSpace.GENERIC],::SIMD[DType.int, 1],::SourceLocation)"@PLT
.Lfunc_end17:
	.size	"std::builtin::debug_assert::_debug_assert_fail_format[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2]](::SourceLocation,*$0),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>]]", .Lfunc_end17-"std::builtin::debug_assert::_debug_assert_fail_format[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2]](::SourceLocation,*$0),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>]]"
	.cfi_endproc

	.prefalign	4, .Lfunc_end18, nop
	.type	"std::builtin::debug_assert::_debug_assert_msg[LITImmOrigin,::Origin[False, $0]](::Pointer[False, $0, ::SIMD[DType.uint8, 1], $1, AddressSpace.GENERIC],::SIMD[DType.int, 1],::SourceLocation)",@function
"std::builtin::debug_assert::_debug_assert_msg[LITImmOrigin,::Origin[False, $0]](::Pointer[False, $0, ::SIMD[DType.uint8, 1], $1, AddressSpace.GENERIC],::SIMD[DType.int, 1],::SourceLocation)":
	.cfi_startproc
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rdi, %rax
	movq	%rcx, %rdi
	movq	%rax, %rcx
	movl	$1, %r8d
	callq	"std::io::io::_printf[KGENParamList[::AnyType],::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],*::AnyType,LITImmOrigin,::Origin[False, $3]](*$0,file:::FileDescriptor),types.values`=[[typevalue<#kgen.instref<std::ffi::cstring::CStringSpan,origin._mlir_origin`={  },origin={  }>>, pointer<none>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::memory::pointer::Pointer,mut=false,origin._mlir_origin`={  },T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=ui8,length=1>>, scalar<ui8>],origin={  },address_space=0>>, pointer<none>]],fmt={ #interp.memref<{[(#interp.memory_handle<16, ~QAt: %s:%llu:%llu: Assert Error: %s\\0A\\00~Q string>, const_global, [], [])], []}, 0, 0>, 35 }"@PLT
	ud2
.Lfunc_end18:
	.size	"std::builtin::debug_assert::_debug_assert_msg[LITImmOrigin,::Origin[False, $0]](::Pointer[False, $0, ::SIMD[DType.uint8, 1], $1, AddressSpace.GENERIC],::SIMD[DType.int, 1],::SourceLocation)", .Lfunc_end18-"std::builtin::debug_assert::_debug_assert_msg[LITImmOrigin,::Origin[False, $0]](::Pointer[False, $0, ::SIMD[DType.uint8, 1], $1, AddressSpace.GENERIC],::SIMD[DType.int, 1],::SourceLocation)"
	.cfi_endproc

	.prefalign	4, .Lfunc_end19, nop
	.type	"std::format::_utils::_fixed_buffer_exceeded()",@function
"std::format::_utils::_fixed_buffer_exceeded()":
	.cfi_startproc
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$1, %edi
	callq	"std::io::io::_printf[KGENParamList[::AnyType],::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],*::AnyType,LITImmOrigin,::Origin[False, $3]](*$0,file:::FileDescriptor),types.values`=[],fmt={ #interp.memref<{[(#interp.memory_handle<16, ~QFIXED_WRITE_BUFFER_BYTES exceeded, increase with: `mojo -D FIXED_WRITE_BUFFER_BYTES=4096`\\0A\\00~Q string>, const_global, [], [])], []}, 0, 0>, 90 }"@PLT
	ud2
.Lfunc_end19:
	.size	"std::format::_utils::_fixed_buffer_exceeded()", .Lfunc_end19-"std::format::_utils::_fixed_buffer_exceeded()"
	.cfi_endproc

	.text
	.prefalign	4, .Lfunc_end20, nop
	.type	"std::io::io::_flush(::FileDescriptor)",@function
"std::io::io::_flush(::FileDescriptor)":
	.cfi_startproc
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset %rbx, -16
	callq	dup@PLT
	leaq	static_string_0d78baac08237ddb(%rip), %rsi
	movl	%eax, %edi
	callq	fdopen@PLT
	movq	%rax, %rbx
	movq	%rax, %rdi
	callq	fflush@PLT
	movq	%rbx, %rdi
	popq	%rbx
	.cfi_def_cfa_offset 8
	jmp	fclose@PLT
.Lfunc_end20:
	.size	"std::io::io::_flush(::FileDescriptor)", .Lfunc_end20-"std::io::io::_flush(::FileDescriptor)"
	.cfi_endproc

	.prefalign	4, .Lfunc_end21, nop
	.type	"std::io::io::_printf[KGENParamList[::AnyType],::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],*::AnyType,LITImmOrigin,::Origin[False, $3]](*$0,file:::FileDescriptor),types.values`=[],fmt={ #interp.memref<{[(#interp.memory_handle<16, ~QFIXED_WRITE_BUFFER_BYTES exceeded, increase with: `mojo -D FIXED_WRITE_BUFFER_BYTES=4096`\\0A\\00~Q string>, const_global, [], [])], []}, 0, 0>, 90 }",@function
"std::io::io::_printf[KGENParamList[::AnyType],::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],*::AnyType,LITImmOrigin,::Origin[False, $3]](*$0,file:::FileDescriptor),types.values`=[],fmt={ #interp.memref<{[(#interp.memory_handle<16, ~QFIXED_WRITE_BUFFER_BYTES exceeded, increase with: `mojo -D FIXED_WRITE_BUFFER_BYTES=4096`\\0A\\00~Q string>, const_global, [], [])], []}, 0, 0>, 90 }":
	.cfi_startproc
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset %rbx, -16
	callq	dup@PLT
	leaq	static_string_0d78baac08237ddb(%rip), %rsi
	movl	%eax, %edi
	callq	fdopen@PLT
	movq	%rax, %rbx
	leaq	static_string_3dbcb4d72b465ec0(%rip), %rsi
	movq	%rax, %rdi
	xorl	%eax, %eax
	callq	KGEN_CompilerRT_fprintf@PLT
	movq	%rbx, %rdi
	popq	%rbx
	.cfi_def_cfa_offset 8
	jmp	fclose@PLT
.Lfunc_end21:
	.size	"std::io::io::_printf[KGENParamList[::AnyType],::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],*::AnyType,LITImmOrigin,::Origin[False, $3]](*$0,file:::FileDescriptor),types.values`=[],fmt={ #interp.memref<{[(#interp.memory_handle<16, ~QFIXED_WRITE_BUFFER_BYTES exceeded, increase with: `mojo -D FIXED_WRITE_BUFFER_BYTES=4096`\\0A\\00~Q string>, const_global, [], [])], []}, 0, 0>, 90 }", .Lfunc_end21-"std::io::io::_printf[KGENParamList[::AnyType],::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],*::AnyType,LITImmOrigin,::Origin[False, $3]](*$0,file:::FileDescriptor),types.values`=[],fmt={ #interp.memref<{[(#interp.memory_handle<16, ~QFIXED_WRITE_BUFFER_BYTES exceeded, increase with: `mojo -D FIXED_WRITE_BUFFER_BYTES=4096`\\0A\\00~Q string>, const_global, [], [])], []}, 0, 0>, 90 }"
	.cfi_endproc

	.prefalign	4, .Lfunc_end22, nop
	.type	"std::io::io::_printf[KGENParamList[::AnyType],::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],*::AnyType,LITImmOrigin,::Origin[False, $3]](*$0,file:::FileDescriptor),types.values`=[[typevalue<#kgen.instref<std::ffi::cstring::CStringSpan,origin._mlir_origin`={  },origin={  }>>, pointer<none>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::memory::pointer::Pointer,mut=false,origin._mlir_origin`={  },T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=ui8,length=1>>, scalar<ui8>],origin={  },address_space=0>>, pointer<none>]],fmt={ #interp.memref<{[(#interp.memory_handle<16, ~QAt: %s:%llu:%llu: Assert Error: %s\\0A\\00~Q string>, const_global, [], [])], []}, 0, 0>, 35 }",@function
"std::io::io::_printf[KGENParamList[::AnyType],::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],*::AnyType,LITImmOrigin,::Origin[False, $3]](*$0,file:::FileDescriptor),types.values`=[[typevalue<#kgen.instref<std::ffi::cstring::CStringSpan,origin._mlir_origin`={  },origin={  }>>, pointer<none>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::memory::pointer::Pointer,mut=false,origin._mlir_origin`={  },T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=ui8,length=1>>, scalar<ui8>],origin={  },address_space=0>>, pointer<none>]],fmt={ #interp.memref<{[(#interp.memory_handle<16, ~QAt: %s:%llu:%llu: Assert Error: %s\\0A\\00~Q string>, const_global, [], [])], []}, 0, 0>, 35 }":
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r13
	.cfi_def_cfa_offset 32
	pushq	%r12
	.cfi_def_cfa_offset 40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -48
	.cfi_offset %r12, -40
	.cfi_offset %r13, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movq	%rcx, %rbx
	movq	%rdx, %r14
	movq	%rsi, %r15
	movq	%rdi, %r12
	movl	%r8d, %edi
	callq	dup@PLT
	leaq	static_string_0d78baac08237ddb(%rip), %rsi
	movl	%eax, %edi
	callq	fdopen@PLT
	movq	%rax, %r13
	leaq	static_string_0dcb71a55f79a509(%rip), %rsi
	movq	%rax, %rdi
	movq	%r12, %rdx
	movq	%r15, %rcx
	movq	%r14, %r8
	movq	%rbx, %r9
	xorl	%eax, %eax
	callq	KGEN_CompilerRT_fprintf@PLT
	movq	%r13, %rdi
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	jmp	fclose@PLT
.Lfunc_end22:
	.size	"std::io::io::_printf[KGENParamList[::AnyType],::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],*::AnyType,LITImmOrigin,::Origin[False, $3]](*$0,file:::FileDescriptor),types.values`=[[typevalue<#kgen.instref<std::ffi::cstring::CStringSpan,origin._mlir_origin`={  },origin={  }>>, pointer<none>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::memory::pointer::Pointer,mut=false,origin._mlir_origin`={  },T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=ui8,length=1>>, scalar<ui8>],origin={  },address_space=0>>, pointer<none>]],fmt={ #interp.memref<{[(#interp.memory_handle<16, ~QAt: %s:%llu:%llu: Assert Error: %s\\0A\\00~Q string>, const_global, [], [])], []}, 0, 0>, 35 }", .Lfunc_end22-"std::io::io::_printf[KGENParamList[::AnyType],::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],*::AnyType,LITImmOrigin,::Origin[False, $3]](*$0,file:::FileDescriptor),types.values`=[[typevalue<#kgen.instref<std::ffi::cstring::CStringSpan,origin._mlir_origin`={  },origin={  }>>, pointer<none>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::memory::pointer::Pointer,mut=false,origin._mlir_origin`={  },T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=ui8,length=1>>, scalar<ui8>],origin={  },address_space=0>>, pointer<none>]],fmt={ #interp.memref<{[(#interp.memory_handle<16, ~QAt: %s:%llu:%llu: Assert Error: %s\\0A\\00~Q string>, const_global, [], [])], []}, 0, 0>, 35 }"
	.cfi_endproc

	.prefalign	4, .Lfunc_end23, nop
	.type	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::builtin::error::Error>>, struct<(struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>, struct<(struct<(struct<(variant<struct<()>, struct<(pointer<none>) memoryOnly>>) memoryOnly>) memoryOnly>) memoryOnly>) memoryOnly>]]",@function
"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::builtin::error::Error>>, struct<(struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>, struct<(struct<(struct<(variant<struct<()>, struct<(pointer<none>) memoryOnly>>) memoryOnly>) memoryOnly>) memoryOnly>) memoryOnly>]]":
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$4120, %rsp
	.cfi_def_cfa_offset 4176
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%r9, %rbx
	movq	%r8, %r14
	movq	%rcx, %r12
	movq	%rdx, %r13
	movq	%rsi, %r15
	movq	%rdi, %rsi
	movzbl	4176(%rsp), %eax
	movb	%al, 3(%rsp)
	movl	4184(%rsp), %eax
	movl	%eax, 4(%rsp)
	movq	$0, 4104(%rsp)
	leaq	4(%rsp), %rax
	movq	%rax, 4112(%rsp)
	movq	16(%rdi), %rdx
	testq	%rdx, %rdx
	js	.LBB23_1
	movq	8(%rsi), %rdx
	movq	(%rsi), %rsi
	jmp	.LBB23_3
.LBB23_1:
	shrq	$56, %rdx
	andl	$31, %edx
.LBB23_3:
	leaq	8(%rsp), %rbp
	movq	%rbp, %rdi
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	%rbp, %rdi
	movq	%r13, %rsi
	movq	%r12, %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	%r15, %rdi
	movq	%rbp, %rsi
	callq	"std::builtin::error::Error::write_to[::Writer & ::AnyType](::Error,$0),writer.T`2x1=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]"@PLT
	movq	%rbp, %rdi
	movq	%r14, %rsi
	movq	%rbx, %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	4104(%rsp), %rdx
	movq	4112(%rsp), %rax
	movl	(%rax), %edi
	movq	%rbp, %rsi
	callq	write@PLT
	testb	$1, 3(%rsp)
	je	.LBB23_4
	movl	4(%rsp), %edi
	addq	$4120, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	jmp	"std::io::io::_flush(::FileDescriptor)"@PLT
.LBB23_4:
	.cfi_def_cfa_offset 4176
	addq	$4120, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end23:
	.size	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::builtin::error::Error>>, struct<(struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>, struct<(struct<(struct<(variant<struct<()>, struct<(pointer<none>) memoryOnly>>) memoryOnly>) memoryOnly>) memoryOnly>) memoryOnly>]]", .Lfunc_end23-"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::builtin::error::Error>>, struct<(struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>, struct<(struct<(struct<(variant<struct<()>, struct<(pointer<none>) memoryOnly>>) memoryOnly>) memoryOnly>) memoryOnly>) memoryOnly>]]"
	.cfi_endproc

	.prefalign	4, .Lfunc_end24, nop
	.type	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::collections::list::List,T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>]>>, struct<(struct<(pointer<none>, scalar<index>)>, scalar<index>) memoryOnly>]]",@function
"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::collections::list::List,T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>]>>, struct<(struct<(pointer<none>, scalar<index>)>, scalar<index>) memoryOnly>]]":
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$4136, %rsp
	.cfi_def_cfa_offset 4192
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%r9, %rbp
	movq	%r8, %rbx
	movq	%rcx, %r15
	movq	%rdx, %r12
	movq	%rsi, %r13
	movq	%rdi, %rsi
	movq	4200(%rsp), %rax
	movq	%rax, 16(%rsp)
	movq	4192(%rsp), %rax
	movq	%rax, 8(%rsp)
	movzbl	4208(%rsp), %eax
	movb	%al, 3(%rsp)
	movl	4216(%rsp), %eax
	movl	%eax, 4(%rsp)
	movq	$0, 4120(%rsp)
	leaq	4(%rsp), %rax
	movq	%rax, 4128(%rsp)
	movq	16(%rdi), %rdx
	testq	%rdx, %rdx
	js	.LBB24_1
	movq	8(%rsi), %rdx
	movq	(%rsi), %rsi
	jmp	.LBB24_3
.LBB24_1:
	shrq	$56, %rdx
	andl	$31, %edx
.LBB24_3:
	leaq	24(%rsp), %r14
	movq	%r14, %rdi
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	%r14, %rdi
	movq	%rbx, %rsi
	movq	%rbp, %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	%r13, %rdi
	movq	%r12, %rsi
	movq	%r15, %rdx
	movq	%r14, %rcx
	callq	"std::collections::list::List::write_to[::Writer & ::AnyType](::List[$0],$1){conforms_to($0, ::Writable & ::AnyType)},T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>],writer.T`2x1=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]"@PLT
	movq	%r14, %rdi
	movq	8(%rsp), %rsi
	movq	16(%rsp), %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	4120(%rsp), %rdx
	movq	4128(%rsp), %rax
	movl	(%rax), %edi
	movq	%r14, %rsi
	callq	write@PLT
	testb	$1, 3(%rsp)
	je	.LBB24_4
	movl	4(%rsp), %edi
	addq	$4136, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	jmp	"std::io::io::_flush(::FileDescriptor)"@PLT
.LBB24_4:
	.cfi_def_cfa_offset 4192
	addq	$4136, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end24:
	.size	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::collections::list::List,T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>]>>, struct<(struct<(pointer<none>, scalar<index>)>, scalar<index>) memoryOnly>]]", .Lfunc_end24-"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::collections::list::List,T=[typevalue<#kgen.instref<std::simd::SIMD,dtype=f32,length=1>>, scalar<f32>]>>, struct<(struct<(pointer<none>, scalar<index>)>, scalar<index>) memoryOnly>]]"
	.cfi_endproc

	.prefalign	4, .Lfunc_end25, nop
	.type	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]]",@function
"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]]":
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$4136, %rsp
	.cfi_def_cfa_offset 4192
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%r9, 16(%rsp)
	movq	%r8, %r12
	movq	%rcx, %r13
	movq	%rdx, %r15
	movq	%rsi, %rbp
	movq	%rdi, %rsi
	movq	4192(%rsp), %r14
	movzbl	4200(%rsp), %eax
	movb	%al, 11(%rsp)
	movl	4208(%rsp), %eax
	movl	%eax, 12(%rsp)
	movq	$0, 4120(%rsp)
	leaq	12(%rsp), %rax
	movq	%rax, 4128(%rsp)
	movq	16(%rdi), %rdx
	testq	%rdx, %rdx
	js	.LBB25_1
	movq	8(%rsi), %rdx
	movq	(%rsi), %rsi
	jmp	.LBB25_3
.LBB25_1:
	shrq	$56, %rdx
	andl	$31, %edx
.LBB25_3:
	leaq	24(%rsp), %rbx
	movq	%rbx, %rdi
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	%rbx, %rdi
	movq	%r13, %rsi
	movq	%r12, %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	%rbp, %rdi
	movq	%rbx, %rsi
	callq	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=index,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]"@PLT
	movq	%rbx, %rdi
	movq	%r13, %rsi
	movq	%r12, %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	16(%r15), %rdx
	testq	%rdx, %rdx
	js	.LBB25_4
	movq	8(%r15), %rdx
	movq	(%r15), %r15
	jmp	.LBB25_6
.LBB25_4:
	shrq	$56, %rdx
	andl	$31, %edx
.LBB25_6:
	leaq	24(%rsp), %rbx
	movq	%rbx, %rdi
	movq	%r15, %rsi
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	%rbx, %rdi
	movq	16(%rsp), %rsi
	movq	%r14, %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	4120(%rsp), %rdx
	movq	4128(%rsp), %rax
	movl	(%rax), %edi
	movq	%rbx, %rsi
	callq	write@PLT
	testb	$1, 11(%rsp)
	je	.LBB25_7
	movl	12(%rsp), %edi
	addq	$4136, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	jmp	"std::io::io::_flush(::FileDescriptor)"@PLT
.LBB25_7:
	.cfi_def_cfa_offset 4192
	addq	$4136, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end25:
	.size	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]]", .Lfunc_end25-"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>],[typevalue<#kgen.instref<std::simd::SIMD,dtype=index,length=1>>, scalar<index>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]]"
	.cfi_endproc

	.prefalign	4, .Lfunc_end26, nop
	.type	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]]",@function
"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]]":
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r12
	.cfi_def_cfa_offset 32
	pushq	%rbx
	.cfi_def_cfa_offset 40
	subq	$4120, %rsp
	.cfi_def_cfa_offset 4160
	.cfi_offset %rbx, -40
	.cfi_offset %r12, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movl	%ecx, %ebx
	movq	%rdx, %r14
	movq	%rsi, %r15
	movq	%rdi, %rsi
	movl	%r8d, 4(%rsp)
	movq	$0, 4104(%rsp)
	leaq	4(%rsp), %rax
	movq	%rax, 4112(%rsp)
	movq	16(%rdi), %rdx
	testq	%rdx, %rdx
	js	.LBB26_1
	movq	8(%rsi), %rdx
	movq	(%rsi), %rsi
	jmp	.LBB26_3
.LBB26_1:
	shrq	$56, %rdx
	andl	$31, %edx
.LBB26_3:
	leaq	8(%rsp), %r12
	movq	%r12, %rdi
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	%r12, %rdi
	movq	%r15, %rsi
	movq	%r14, %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	4104(%rsp), %rdx
	movq	4112(%rsp), %rax
	movl	(%rax), %edi
	movq	%r12, %rsi
	callq	write@PLT
	testb	$1, %bl
	je	.LBB26_4
	movl	4(%rsp), %edi
	addq	$4120, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	jmp	"std::io::io::_flush(::FileDescriptor)"@PLT
.LBB26_4:
	.cfi_def_cfa_offset 4160
	addq	$4120, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end26:
	.size	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]]", .Lfunc_end26-"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]]"
	.cfi_endproc

	.prefalign	4, .Lfunc_end27, nop
	.type	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string_span::StringSpan,origin._mlir_origin`={  },origin={  }>>, struct<(pointer<none>, scalar<index>)>],[typevalue<#kgen.instref<std::collections::string::string_span::StringSpan,origin._mlir_origin`={  },origin={  }>>, struct<(pointer<none>, scalar<index>)>],[typevalue<#kgen.instref<std::reflection::location::SourceLocation>>, struct<(scalar<index>, scalar<index>, struct<(pointer<none>, scalar<index>)>)>],[typevalue<#kgen.instref<std::collections::string::string_span::StringSpan,origin._mlir_origin`={  },origin={  }>>, struct<(pointer<none>, scalar<index>)>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]]",@function
"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string_span::StringSpan,origin._mlir_origin`={  },origin={  }>>, struct<(pointer<none>, scalar<index>)>],[typevalue<#kgen.instref<std::collections::string::string_span::StringSpan,origin._mlir_origin`={  },origin={  }>>, struct<(pointer<none>, scalar<index>)>],[typevalue<#kgen.instref<std::reflection::location::SourceLocation>>, struct<(scalar<index>, scalar<index>, struct<(pointer<none>, scalar<index>)>)>],[typevalue<#kgen.instref<std::collections::string::string_span::StringSpan,origin._mlir_origin`={  },origin={  }>>, struct<(pointer<none>, scalar<index>)>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]]":
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$4184, %rsp
	.cfi_def_cfa_offset 4240
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%r9, 24(%rsp)
	movq	%r8, 16(%rsp)
	movq	%rcx, 8(%rsp)
	movq	%rdx, %rbx
	movq	%rsi, %rdx
	movq	%rdi, %rsi
	movq	4304(%rsp), %rax
	movq	%rax, 64(%rsp)
	movq	4296(%rsp), %rax
	movq	%rax, 56(%rsp)
	movq	4288(%rsp), %r15
	movq	4280(%rsp), %r13
	movq	4264(%rsp), %rax
	movq	%rax, 40(%rsp)
	movq	4256(%rsp), %rax
	movq	%rax, 32(%rsp)
	movzbl	4312(%rsp), %eax
	movb	%al, 3(%rsp)
	movq	4272(%rsp), %rax
	movq	%rax, 48(%rsp)
	movq	4240(%rsp), %r14
	movq	4248(%rsp), %rbp
	movl	4320(%rsp), %eax
	movl	%eax, 4(%rsp)
	movq	$0, 4168(%rsp)
	leaq	4(%rsp), %rax
	movq	%rax, 4176(%rsp)
	leaq	72(%rsp), %r12
	movq	%r12, %rdi
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	%r12, %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	%r12, %rdi
	movq	%rbx, %rsi
	movq	8(%rsp), %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	%r12, %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	%r12, %rdi
	movq	%r14, %rsi
	movq	%rbp, %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	4168(%rsp), %rdx
	leaq	1(%rdx), %rax
	cmpq	$4097, %rax
	jl	.LBB27_2
	movq	4176(%rsp), %rax
	movl	(%rax), %edi
	leaq	72(%rsp), %rsi
	callq	write@PLT
	movq	$0, 4168(%rsp)
	xorl	%edx, %edx
.LBB27_2:
	movb	$58, 72(%rsp,%rdx)
	incq	4168(%rsp)
	leaq	72(%rsp), %rsi
	movq	16(%rsp), %rdi
	callq	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=index,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]"@PLT
	movq	4168(%rsp), %rdx
	leaq	1(%rdx), %rax
	cmpq	$4097, %rax
	jl	.LBB27_4
	movq	4176(%rsp), %rax
	movl	(%rax), %edi
	leaq	72(%rsp), %rsi
	callq	write@PLT
	movq	$0, 4168(%rsp)
	xorl	%edx, %edx
.LBB27_4:
	movb	$58, 72(%rsp,%rdx)
	incq	4168(%rsp)
	leaq	72(%rsp), %rbx
	movq	24(%rsp), %rdi
	movq	%rbx, %rsi
	callq	"std::simd::SIMD::write_to[::Writer & ::AnyType](::SIMD[$0, $1],$2),dtype=index,length=1,writer.T`2x=[typevalue<#kgen.instref<std::format::_utils::_FlushingWriteBuffer,origin._mlir_origin`={  },origin={  },W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096>>, struct<(struct<(array<4096, scalar<ui8>>) memoryOnly>, scalar<index>, pointer<none>) memoryOnly>]"@PLT
	movq	%rbx, %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	%rbx, %rdi
	movq	32(%rsp), %rsi
	movq	40(%rsp), %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	%rbx, %rdi
	movq	%r13, %rsi
	movq	%r15, %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	48(%rsp), %rsi
	movq	16(%rsi), %rdx
	testq	%rdx, %rdx
	js	.LBB27_5
	movq	8(%rsi), %rdx
	movq	(%rsi), %rsi
	jmp	.LBB27_7
.LBB27_5:
	shrq	$56, %rdx
	andl	$31, %edx
.LBB27_7:
	leaq	72(%rsp), %rbx
	movq	%rbx, %rdi
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	%rbx, %rdi
	movq	56(%rsp), %rsi
	movq	64(%rsp), %rdx
	callq	"std::format::_utils::_FlushingWriteBuffer::write_string[LITImmOrigin,::Origin[False, $4]](::_FlushingWriteBuffer[$0, $1, $2, $3],::StringSpan[$4, $5]),W=[typevalue<#kgen.instref<std::io::file_descriptor::FileDescriptor>>, scalar<si32>],capacity_bytes=4096"@PLT
	movq	4168(%rsp), %rdx
	movq	4176(%rsp), %rax
	movl	(%rax), %edi
	movq	%rbx, %rsi
	callq	write@PLT
	testb	$1, 3(%rsp)
	je	.LBB27_8
	movl	4(%rsp), %edi
	addq	$4184, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	jmp	"std::io::io::_flush(::FileDescriptor)"@PLT
.LBB27_8:
	.cfi_def_cfa_offset 4240
	addq	$4184, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end27:
	.size	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string_span::StringSpan,origin._mlir_origin`={  },origin={  }>>, struct<(pointer<none>, scalar<index>)>],[typevalue<#kgen.instref<std::collections::string::string_span::StringSpan,origin._mlir_origin`={  },origin={  }>>, struct<(pointer<none>, scalar<index>)>],[typevalue<#kgen.instref<std::reflection::location::SourceLocation>>, struct<(scalar<index>, scalar<index>, struct<(pointer<none>, scalar<index>)>)>],[typevalue<#kgen.instref<std::collections::string::string_span::StringSpan,origin._mlir_origin`={  },origin={  }>>, struct<(pointer<none>, scalar<index>)>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]]", .Lfunc_end27-"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string_span::StringSpan,origin._mlir_origin`={  },origin={  }>>, struct<(pointer<none>, scalar<index>)>],[typevalue<#kgen.instref<std::collections::string::string_span::StringSpan,origin._mlir_origin`={  },origin={  }>>, struct<(pointer<none>, scalar<index>)>],[typevalue<#kgen.instref<std::reflection::location::SourceLocation>>, struct<(scalar<index>, scalar<index>, struct<(pointer<none>, scalar<index>)>)>],[typevalue<#kgen.instref<std::collections::string::string_span::StringSpan,origin._mlir_origin`={  },origin={  }>>, struct<(pointer<none>, scalar<index>)>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]]"
	.cfi_endproc

	.prefalign	4, .Lfunc_end28, nop
	.type	"std::os::os::_abort_report[::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],::Writable & ::AnyType](::SourceLocation,$1),prefix={ #interp.memref<{[(#interp.memory_handle<16, ~QABORT:\\00~Q string>, const_global, [], [])], []}, 0, 0>, 6 },message.T`=[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]",@function
"std::os::os::_abort_report[::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],::Writable & ::AnyType](::SourceLocation,$1),prefix={ #interp.memref<{[(#interp.memory_handle<16, ~QABORT:\\00~Q string>, const_global, [], [])], []}, 0, 0>, 6 },message.T`=[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]":
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%rbx
	.cfi_def_cfa_offset 32
	.cfi_offset %rbx, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movq	%r8, %r11
	movq	%rcx, %r10
	movq	%rdx, %rax
	movq	%rsi, %r9
	movq	%rdi, %r8
	subq	$8, %rsp
	.cfi_adjust_cfa_offset 8
	leaq	static_string_bbe01a6a523daf15(%rip), %rbx
	leaq	static_string_c44bdff4074eecdb(%rip), %r14
	leaq	static_string_7f1562353e292282(%rip), %r15
	leaq	static_string_31203c1a2bdb78cc(%rip), %rdi
	leaq	static_string_a8d4ace0dc8d360e(%rip), %rdx
	movl	$6, %esi
	movl	$1, %ecx
	pushq	$1
	.cfi_adjust_cfa_offset 8
	pushq	$1
	.cfi_adjust_cfa_offset 8
	pushq	$1
	.cfi_adjust_cfa_offset 8
	pushq	%rbx
	.cfi_adjust_cfa_offset 8
	pushq	$0
	.cfi_adjust_cfa_offset 8
	pushq	%r14
	.cfi_adjust_cfa_offset 8
	pushq	%r11
	.cfi_adjust_cfa_offset 8
	pushq	$2
	.cfi_adjust_cfa_offset 8
	pushq	%r15
	.cfi_adjust_cfa_offset 8
	pushq	%r10
	.cfi_adjust_cfa_offset 8
	pushq	%rax
	.cfi_adjust_cfa_offset 8
	callq	"std::io::io::print[KGENParamList[::Writable & ::AnyType],*::Writable & ::AnyType,LITImmOrigin,::Origin[False, $2],LITImmOrigin,::Origin[False, $4],LITImmOrigin,::Origin[False, $6]](*$0,sep:::StringSpan[$4, $5],end:::StringSpan[$6, $7],flush:::Bool,file:::FileDescriptor$),Ts.values`=[[typevalue<#kgen.instref<std::collections::string::string_span::StringSpan,origin._mlir_origin`={  },origin={  }>>, struct<(pointer<none>, scalar<index>)>],[typevalue<#kgen.instref<std::collections::string::string_span::StringSpan,origin._mlir_origin`={  },origin={  }>>, struct<(pointer<none>, scalar<index>)>],[typevalue<#kgen.instref<std::reflection::location::SourceLocation>>, struct<(scalar<index>, scalar<index>, struct<(pointer<none>, scalar<index>)>)>],[typevalue<#kgen.instref<std::collections::string::string_span::StringSpan,origin._mlir_origin`={  },origin={  }>>, struct<(pointer<none>, scalar<index>)>],[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]]"@PLT
	addq	$96, %rsp
	.cfi_adjust_cfa_offset -96
	popq	%rbx
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end28:
	.size	"std::os::os::_abort_report[::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],::Writable & ::AnyType](::SourceLocation,$1),prefix={ #interp.memref<{[(#interp.memory_handle<16, ~QABORT:\\00~Q string>, const_global, [], [])], []}, 0, 0>, 6 },message.T`=[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]", .Lfunc_end28-"std::os::os::_abort_report[::StringSpan[ImmStaticOrigin, ::Origin[False, ImmStaticOrigin]()],::Writable & ::AnyType](::SourceLocation,$1),prefix={ #interp.memref<{[(#interp.memory_handle<16, ~QABORT:\\00~Q string>, const_global, [], [])], []}, 0, 0>, 6 },message.T`=[typevalue<#kgen.instref<std::collections::string::string::String>>, struct<(pointer<none>, scalar<index>, scalar<index>) memoryOnly>]"
	.cfi_endproc

	.type	static_string_baad52a56e0acbcf,@object
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
static_string_baad52a56e0acbcf:
	.asciz	"mismatched elements"
	.size	static_string_baad52a56e0acbcf, 20

	.type	static_string_c4c7be18a607e1c2,@object
	.p2align	4, 0x0
static_string_c4c7be18a607e1c2:
	.asciz	"RESULT:"
	.size	static_string_c4c7be18a607e1c2, 8

	.type	static_string_b06715244581a357,@object
	.p2align	4, 0x0
static_string_b06715244581a357:
	.asciz	"backend: Mojo CPU"
	.size	static_string_b06715244581a357, 18

	.type	static_string_837040b3bb6a25ae,@object
	.p2align	4, 0x0
static_string_837040b3bb6a25ae:
	.asciz	"output %mul_2:"
	.size	static_string_837040b3bb6a25ae, 15

	.type	static_string_2874a0219404abcb,@object
	.p2align	4, 0x0
static_string_2874a0219404abcb:
	.asciz	"output %max_2:"
	.size	static_string_2874a0219404abcb, 15

	.type	static_string_cccd1b860a827236,@object
	.p2align	4, 0x0
static_string_cccd1b860a827236:
	.asciz	"output %max:"
	.size	static_string_cccd1b860a827236, 13

	.type	static_string_8139647b818ca978,@object
	.p2align	4, 0x0
static_string_8139647b818ca978:
	.asciz	"output %mul:"
	.size	static_string_8139647b818ca978, 13

	.type	static_string_6c4bc3d6af8b4e6e,@object
	.p2align	4, 0x0
static_string_6c4bc3d6af8b4e6e:
	.asciz	"output %sub:"
	.size	static_string_6c4bc3d6af8b4e6e, 13

	.type	static_string_ad918d8eb07d6197,@object
	.p2align	4, 0x0
static_string_ad918d8eb07d6197:
	.asciz	"CPU outputs disagree with oracle"
	.size	static_string_ad918d8eb07d6197, 33

	.type	static_string_26a85fbdc19bc0a1,@object
	.p2align	4, 0x0
static_string_26a85fbdc19bc0a1:
	.asciz	"Unhandled exception caught during execution:"
	.size	static_string_26a85fbdc19bc0a1, 45

	.type	static_string_fbe1ca471a988c5b,@object
	.p2align	4, 0x0
static_string_fbe1ca471a988c5b:
	.asciz	"stack trace was not collected. Enable stack trace collection with environment variable `MODULAR_DEBUG=stack-trace-on-error`"
	.size	static_string_fbe1ca471a988c5b, 124

	.type	static_string_a61c3395ab9379d9,@object
	.p2align	4, 0x0
static_string_a61c3395ab9379d9:
	.asciz	"Runtime"
	.size	static_string_a61c3395ab9379d9, 8

	.type	static_string_44fd141e40b306d5,@object
	.p2align	4, 0x0
static_string_44fd141e40b306d5:
	.asciz	", "
	.size	static_string_44fd141e40b306d5, 3

	.type	static_string_ede496b2d17dd639,@object
	.p2align	4, 0x0
static_string_ede496b2d17dd639:
	.asciz	"Mojo/stdlib/std/memory/alloc.mojo"
	.size	static_string_ede496b2d17dd639, 34

	.type	static_string_09e773a88105e290,@object
	.p2align	4, 0x0
static_string_09e773a88105e290:
	.asciz	"alloc failed: returned a null pointer"
	.size	static_string_09e773a88105e290, 38

	.type	static_string_30948303dbd8bc48,@object
	.p2align	4, 0x0
static_string_30948303dbd8bc48:
	.asciz	"alloc: `Layout.count()` must be >= 0"
	.size	static_string_30948303dbd8bc48, 37

	.type	static_string_a0fcf35b7349c924,@object
	.p2align	4, 0x0
static_string_a0fcf35b7349c924:
	.asciz	" is out of bounds, valid range is 0 to "
	.size	static_string_a0fcf35b7349c924, 40

	.type	static_string_ffe5c571af8dd3fc,@object
	.p2align	4, 0x0
static_string_ffe5c571af8dd3fc:
	.asciz	"index "
	.size	static_string_ffe5c571af8dd3fc, 7

	.type	static_string_e5411518d45eb182,@object
	.p2align	4, 0x0
static_string_e5411518d45eb182:
	.asciz	"nan"
	.size	static_string_e5411518d45eb182, 4

	.type	static_string_00747f69c2b26145,@object
	.p2align	4, 0x0
static_string_00747f69c2b26145:
	.asciz	"."
	.size	static_string_00747f69c2b26145, 2

	.type	static_string_8439ccbd1c202210,@object
	.p2align	4, 0x0
static_string_8439ccbd1c202210:
	.asciz	"0"
	.size	static_string_8439ccbd1c202210, 2

	.type	static_string_422d2414495ed121,@object
	.p2align	4, 0x0
static_string_422d2414495ed121:
	.asciz	"Mojo/stdlib/std/builtin/_format_float.mojo"
	.size	static_string_422d2414495ed121, 43

	.type	global_constant,@object
	.p2align	3, 0x0
global_constant:
	.quad	-9093133594791772939
	.quad	-6754730975062328270
	.quad	-3831727700400522433
	.quad	-177973607073265138
	.quad	-7028762532061872567
	.quad	-4174267146649952805
	.quad	-606147914885053102
	.quad	-7296371474444240045
	.quad	-4508778324627912152
	.quad	-1024286887357502286
	.quad	-7557708332239520785
	.quad	-4835449396872013077
	.quad	-1432625727662628442
	.quad	-7812920107430224632
	.quad	-5154464115860392886
	.quad	-1831394126398103204
	.quad	-8062150356639896358
	.quad	-5466001927372482544
	.quad	-2220816390788215276
	.quad	-8305539271883716404
	.quad	-5770238071427257601
	.quad	-2601111570856684097
	.quad	-8543223759426509416
	.quad	-6067343680855748867
	.quad	-2972493582642298179
	.quad	-8775337516792518218
	.quad	-6357485877563259868
	.quad	-3335171328526686932
	.quad	-9002011107970261188
	.quad	-6640827866535438581
	.quad	-3689348814741910323
	.quad	-9223372036854775808
	.quad	-6917529027641081856
	.quad	-4035225266123964416
	.quad	-432345564227567616
	.quad	-7187745005283311616
	.quad	-4372995238176751616
	.quad	-854558029293551616
	.quad	-7451627795949551616
	.quad	-4702848726509551616
	.quad	-1266874889709551616
	.quad	-7709325833709551616
	.quad	-5024971273709551616
	.quad	-1669528073709551616
	.quad	-7960984073709551616
	.quad	-5339544073709551616
	.quad	-2062744073709551616
	.quad	-8206744073709551616
	.quad	-5646744073709551616
	.quad	-2446744073709551616
	.quad	-8446744073709551616
	.quad	-5946744073709551616
	.quad	-2821744073709551616
	.quad	-8681119073709551616
	.quad	-6239712823709551616
	.quad	-3187955011209551616
	.quad	-8910000909647051616
	.quad	-6525815118631426616
	.quad	-3545582879861895366
	.quad	-9133518327554766459
	.quad	-6805211891016070170
	.quad	-3894828845342699809
	.quad	-256850038250986857
	.quad	-7078060301547948642
	.quad	-4235889358507547898
	.quad	-683175679707046969
	.quad	-7344513827457986211
	.quad	-4568956265895094860
	.quad	-1099509313941480671
	.quad	-7604722348854507275
	.quad	-4894216917640746190
	.quad	-1506085128623544834
	.quad	-7858832233030797377
	.quad	-5211854272861108818
	.quad	-1903131822648998118
	.quad	-8106986416796705680
	.quad	-5522047002568494196
	.quad	-2290872734783229841
	.size	global_constant, 624

	.type	global_constant_0,@object
	.p2align	4, 0x0
global_constant_0:
	.quad	2731688931043774331
	.quad	-38366372719436721
	.quad	8624834609543440813
	.quad	-6941508010590729807
	.quad	-3054014793352862696
	.quad	-4065198994811024355
	.quad	5405853545163697438
	.quad	-469812725086392539
	.quad	5684501474941004851
	.quad	-7211161980820077193
	.quad	2493940825248868160
	.quad	-4402266457597708587
	.quad	7729112049988473104
	.quad	-891147053569747830
	.quad	-9004363024039368022
	.quad	-7474495936122174250
	.quad	2579604275232953684
	.quad	-4731433901725329908
	.quad	3224505344041192105
	.quad	-1302606358729274481
	.quad	8932844867666826922
	.quad	-7731658001846878407
	.quad	-2669001970698630060
	.quad	-5052886483881210105
	.quad	-3336252463373287575
	.quad	-1704422086424124727
	.quad	2526528228819083170
	.quad	-7982792831656159810
	.quad	-6065211750830921845
	.quad	-5366805021142811859
	.quad	1641857348316123501
	.quad	-2096820258001126919
	.quad	-5891368184943504668
	.quad	-8228041688891786181
	.quad	-7364210231179380835
	.quad	-5673366092687344822
	.quad	4629795266307937668
	.quad	-2480021597431793123
	.quad	5199465050656154995
	.quad	-8467542526035952558
	.quad	-2724040723534582064
	.quad	-5972742139117552794
	.quad	-8016736922845615485
	.quad	-2854241655469553088
	.quad	6518754469289960082
	.quad	-8701430062309552536
	.quad	8148443086612450103
	.quad	-6265101559459552766
	.quad	962181821410786820
	.quad	-3219690930897053053
	.quad	-1704479370831952189
	.quad	-8929835859451740015
	.quad	7092772823314835571
	.quad	-6550608805887287114
	.quad	-357406007711231344
	.quad	-3576574988931720989
	.quad	8999993282035256218
	.quad	-9152888395723407474
	.quad	2026619565689294465
	.quad	-6829424476226871438
	.quad	-6690097579743157727
	.quad	-3925094576856201394
	.quad	5472436080603216553
	.quad	-294682202642863838
	.quad	8031958568804398250
	.quad	-7101705404292871755
	.quad	-3795109844276665900
	.quad	-4265445736938701790
	.quad	9091170749936331337
	.quad	-720121152745989333
	.quad	3376138709496513134
	.quad	-7367604748107325189
	.quad	-391512631556746487
	.quad	-4597819916706768583
	.quad	8733981247408842699
	.quad	-1135588877456072824
	.quad	5458738279630526687
	.quad	-7627272076051127371
	.quad	-7011635205744005353
	.quad	-4922404076636521310
	.quad	5070514048102157021
	.quad	-1541319077368263733
	.quad	863228270850154186
	.quad	-7880853450996246689
	.quad	-3532650679864695172
	.quad	-5239380795317920458
	.quad	-9027499368258256869
	.quad	-1937539975720012668
	.quad	-3336344095947716591
	.quad	-8128491512466089774
	.quad	-8782116138362033642
	.quad	-5548928372155224313
	.quad	7469098900757009563
	.quad	-2324474446766642487
	.quad	-2249342214667950879
	.quad	-8370325556870233411
	.quad	6411694268519837209
	.quad	-5851220927660403859
	.quad	-5820440219632367201
	.quad	-2702340141148116920
	.quad	7891439908798240260
	.quad	-8606491615858654931
	.quad	-3970758169284363388
	.quad	-6146428501395930760
	.quad	-351761693178066331
	.quad	-3071349608317525546
	.quad	6697677969404790400
	.quad	-8837122532839535322
	.quad	-851274575098787809
	.quad	-6434717147622031249
	.quad	-1064093218873484761
	.quad	-3431710416100151157
	.quad	8558313775058847833
	.quad	-9062348037703676329
	.quad	6086206200396171887
	.quad	-6716249028702207507
	.quad	-6227300304786948854
	.quad	-3783625267450371480
	.quad	-3172439362556298163
	.quad	-117845565885576446
	.quad	-4288617610811380304
	.quad	-6991182506319567135
	.quad	3862600023340550428
	.quad	-4127292114472071014
	.quad	-4395122007679087773
	.quad	-547429124662700864
	.quad	8782263791269039902
	.quad	-7259672230555269896
	.quad	-7468914334623251739
	.quad	-4462904269766699466
	.quad	4498915137003099038
	.quad	-966944318780986428
	.quad	-6411550076227838909
	.quad	-7521869226879198374
	.quad	5820620459997365076
	.quad	-4790650515171610063
	.quad	-6559282480285457367
	.quad	-1376627125537124675
	.quad	-8711237568605798758
	.quad	-7777920981101784778
	.quad	2946011094524915264
	.quad	-5110715207949843068
	.quad	3682513868156144080
	.quad	-1776707991509915931
	.quad	4607414176811284002
	.quad	-8027971522334779313
	.quad	1147581702586717098
	.quad	-5423278384491086237
	.quad	-3177208890193991531
	.quad	-2167411962186469893
	.quad	7237616480483531101
	.quad	-8272161504007625539
	.quad	-4788037454677749836
	.quad	-5728515861582144020
	.quad	-1373360799919799391
	.quad	-2548958808550292121
	.quad	-858350499949874619
	.quad	-8510628282985014432
	.quad	3538747893490044630
	.quad	-6026599335303880135
	.quad	9035120885289943692
	.quad	-2921563150702462265
	.quad	-5882264492762254952
	.quad	-8743505996830120772
	.quad	-2741144597525430787
	.quad	-6317696477610263061
	.quad	-3426430746906788484
	.quad	-3285434578585440922
	.quad	4776009810824339054
	.quad	-8970925639256982432
	.quad	5970012263530423817
	.quad	-6601971030643840136
	.quad	7462515329413029772
	.quad	-3640777769877412266
	.quad	52386062455755703
	.quad	-9193015133814464522
	.quad	-9157889458785081179
	.quad	-6879582898840692749
	.quad	6999382250228200142
	.quad	-3987792605123478032
	.quad	8749227812785250178
	.quad	-373054737976959636
	.quad	-3755104653863994447
	.quad	-7150688238876681629
	.quad	-4693880817329993059
	.quad	-4326674280168464132
	.quad	-1255665003235103419
	.quad	-796656831783192261
	.quad	8438581409832836171
	.quad	-7415439547505577019
	.quad	-3286831292991118498
	.quad	-4657613415954583370
	.quad	-8720225134666286027
	.quad	-1210330751515841308
	.quad	-3144297699952734815
	.quad	-7673985747338482674
	.quad	-8542058143368306422
	.quad	-4980796165745715438
	.quad	3157485376071780684
	.quad	-1614309188754756393
	.quad	8890957387685944784
	.quad	-7926472270612804602
	.quad	1890324697752655171
	.quad	-5296404319838617848
	.quad	2362905872190818964
	.quad	-2008819381370884406
	.quad	6088502188546649757
	.quad	-8173041140997884610
	.quad	-1612744301171463612
	.quad	-5604615407819967859
	.quad	7207441660390446293
	.quad	-2394083241347571919
	.quad	-2412877989897052923
	.quad	-8413831053483314306
	.quad	-7627783505798704058
	.quad	-5905602798426754978
	.quad	4300328673033783640
	.quad	-2770317479606055818
	.quad	-1923980597781273129
	.quad	-8648977452394866743
	.quad	6818396289628184397
	.quad	-6199535797066195524
	.quad	8522995362035230496
	.quad	-3137733727905356501
	.quad	3021029092058325108
	.quad	-8878612607581929669
	.quad	-835399653354481519
	.quad	-6486579741050024183
	.quad	8179122470161673909
	.quad	-3496538657885142324
	.quad	-4111420493003729615
	.quad	-9102865688819295809
	.quad	-5139275616254662019
	.quad	-6766896092596731857
	.quad	-6424094520318327523
	.quad	-3846934097318526917
	.quad	-8030118150397909404
	.quad	-196981603220770742
	.quad	-7324666853212387329
	.quad	-7040642529654063570
	.quad	4679224488766679550
	.quad	-4189117143640191558
	.quad	-3374341425896426371
	.quad	-624710411122851544
	.quad	-9026492418826348337
	.quad	-7307973034592864071
	.quad	-2059743486678159614
	.quad	-4523280274813692185
	.quad	-2574679358347699518
	.quad	-1042414325089727327
	.quad	3002511419460075706
	.quad	-7569037980822161435
	.quad	8364825292752482536
	.quad	-4849611457600313890
	.quad	1232659579085827362
	.quad	-1450328303573004458
	.quad	-3841273781498745803
	.quad	-7823984217374209643
	.quad	4421779809981343555
	.quad	-5168294253290374149
	.quad	915538744049291539
	.quad	-1848681798185579782
	.quad	5183897733458195116
	.quad	-8072955151507069220
	.quad	6479872166822743895
	.quad	-5479507920956448621
	.quad	3488154190101041965
	.quad	-2237698882768172872
	.quad	2180096368813151228
	.quad	-8316090829371189901
	.quad	-1886565557410948869
	.quad	-5783427518286599473
	.quad	-2358206946763686086
	.quad	-2617598379430861437
	.quad	7749492695127472004
	.quad	-8553528014785370254
	.quad	463493832054564197
	.quad	-6080224000054324913
	.quad	-4032318728359182658
	.quad	-2988593981640518238
	.quad	-4826042214438183113
	.quad	-8785400266166405755
	.quad	3190819268807046917
	.quad	-6370064314280619289
	.quad	-623161932418579258
	.quad	-3350894374423386208
	.quad	-7307005235402693892
	.quad	-9011838011655698236
	.quad	-4522070525825979461
	.quad	-6653111496142234891
	.quad	3570783879572301481
	.quad	-3704703351750405709
	.quad	-148206168962011053
	.quad	-19193171260619233
	.quad	-92628855601256908
	.quad	-6929524759678968877
	.quad	-115786069501571135
	.quad	-4050219931171323192
	.quad	4466953431550423985
	.quad	-451088895536766085
	.quad	486002885505321039
	.quad	-7199459587351560659
	.quad	5219189625309039203
	.quad	-4387638465762062920
	.quad	6523987031636299003
	.quad	-872862063775190746
	.quad	-534194123654701027
	.quad	-7463067817500576073
	.quad	-667742654568376284
	.quad	-4717148753448332187
	.quad	8388693718644305453
	.quad	-1284749923383027329
	.quad	-6286281471915778851
	.quad	-7720497729755473937
	.quad	-7857851839894723564
	.quad	-5038936143766954517
	.quad	8624429273841147160
	.quad	-1686984161281305242
	.quad	778582277723329071
	.quad	-7971894128441897632
	.quad	973227847154161339
	.quad	-5353181642124984136
	.quad	1216534808942701674
	.quad	-2079791034228842266
	.quad	-3851351762838199358
	.quad	-8217398424034108273
	.quad	-4814189703547749197
	.quad	-5660062011615247437
	.quad	-6017737129434686497
	.quad	-2463391496091671392
	.quad	7768129340171790700
	.quad	-8457148712698376476
	.quad	-8736582398494813241
	.quad	-5959749872445582691
	.quad	-1697355961263740744
	.quad	-2838001322129590460
	.quad	1244995533423855987
	.quad	-8691279853972075893
	.quad	-3055441601647567920
	.quad	-6252413799037706963
	.quad	5404070034795315908
	.quad	-3203831230369745799
	.quad	-3539985255894009413
	.quad	-8919923546622172981
	.quad	-4424981569867511767
	.quad	-6538218414850328322
	.quad	8303831092947774003
	.quad	-3561087000135522498
	.quad	578208414664970848
	.quad	-9143208402725783417
	.quad	-3888925500096174344
	.quad	-6817324484979841368
	.quad	-249470856692830026
	.quad	-3909969587797413806
	.quad	-4923524589293425437
	.quad	-275775966319379353
	.quad	-3077202868308390898
	.quad	-7089889006590693952
	.quad	765182433041899282
	.quad	-4250675239810979535
	.quad	5568164059729762006
	.quad	-701658031336336515
	.quad	5785945546544795206
	.quad	-7356065297226292178
	.quad	-1990940103673781801
	.quad	-4583395603105477319
	.quad	6734696907262548557
	.quad	-1117558485454458744
	.quad	4209185567039092848
	.quad	-7616003081050118571
	.quad	-8573576096483297652
	.quad	-4908317832885260310
	.quad	3118087934678041647
	.quad	-1523711272679187483
	.quad	4254647968387469982
	.quad	-7869848573065574033
	.quad	706623942056949573
	.quad	-5225624697904579637
	.quad	-3728406090856200938
	.quad	-1920344853953336643
	.quad	-6941939825212513490
	.quad	-8117744561361917258
	.quad	5157633273766521850
	.quad	-5535494683275008668
	.quad	6447041592208152312
	.quad	-2307682335666372931
	.quad	6335244004343789147
	.quad	-8359830487432564938
	.quad	-1304317031425039374
	.quad	-5838102090863318269
	.quad	-1630396289281299218
	.quad	-2685941595151759932
	.quad	1286845328412881941
	.quad	-8596242524610931813
	.quad	-3003129357911285478
	.quad	-6133617137336276863
	.quad	5469460339465668960
	.quad	-3055335403242958174
	.quad	8030098730593431004
	.quad	-8827113654667930715
	.quad	-3797434642040374957
	.quad	-6422206049907525490
	.quad	9088264752731695016
	.quad	-3416071543957018958
	.quad	-8154892584824854327
	.quad	-9052573742614218705
	.quad	8253128342678483707
	.quad	-6704031159840385477
	.quad	5704724409920716730
	.quad	-3768352931373093942
	.quad	-2092466524453879895
	.quad	-98755145788979524
	.quad	998051431430019018
	.quad	-6979250993759194058
	.quad	-7975807747567252036
	.quad	-4112377723771604669
	.quad	8476984389250486571
	.quad	-528786136287117932
	.quad	-3925256793573221701
	.quad	-7248020362820530564
	.quad	-294884973539139223
	.quad	-4448339435098275301
	.quad	-368606216923924028
	.quad	-948738275445456222
	.quad	-2536221894791146469
	.quad	-7510490449794491995
	.quad	6053094668365842721
	.quad	-4776427043815727089
	.quad	2954682317029915497
	.quad	-1358847786342270957
	.quad	-459166561069996766
	.quad	-7766808894105001205
	.quad	-573958201337495958
	.quad	-5096825099203863602
	.quad	-5329133770099257851
	.quad	-1759345355577441598
	.quad	-5636551615525730109
	.quad	-8017119874876982855
	.quad	2177682517447613172
	.quad	-5409713825168840664
	.quad	2722103146809516465
	.quad	-2150456263033662926
	.quad	6313000485183335695
	.quad	-8261564192037121185
	.quad	3279564588051781714
	.quad	-5715269221619013577
	.quad	-512230283362660762
	.quad	-2532400508596379068
	.quad	1985699082112030976
	.quad	-8500279345513818773
	.quad	-2129562165787349184
	.quad	-6013663163464885563
	.quad	6561419329620589328
	.quad	-2905392935903719049
	.quad	-7428327965055601430
	.quad	-8733399612580906262
	.quad	4549648098962661925
	.quad	-6305063497298744923
	.quad	-8147997931578836306
	.quad	-3269643353196043250
	.quad	1825030320404309165
	.quad	-8961056123388608887
	.quad	6892973918932774360
	.quad	-6589634135808373205
	.quad	4004531380238580046
	.quad	-3625356651333078602
	.quad	-2108853905778275375
	.quad	-9183376934724255983
	.quad	6587304654631931589
	.quad	-6867535149977932074
	.quad	-989241218564861322
	.quad	-3972732919045027189
	.quad	-1236551523206076653
	.quad	-354230130378896082
	.quad	6144684325637283948
	.quad	-7138922859127891907
	.quad	-6154202648235558777
	.quad	-4311967555482476980
	.quad	-3081067291867060567
	.quad	-778273425925708321
	.quad	-1925667057416912854
	.quad	-7403949918844649557
	.quad	-2407083821771141068
	.quad	-4643251380128424042
	.quad	-7620540795641314239
	.quad	-1192378206733142148
	.quad	-2456994988062127447
	.quad	-7662765406849295699
	.quad	6152128301777116499
	.quad	-4966770740134231719
	.quad	-6144897678060768089
	.quad	-1596777406740401745
	.quad	-3840561048787980055
	.quad	-7915514906853832947
	.quad	4422670725869800739
	.quad	-5282707615139903279
	.quad	-8306719647944912789
	.quad	-1991698500497491195
	.quad	8643358275316593219
	.quad	-8162340590452013853
	.quad	6192511825718353620
	.quad	-5591239719637629412
	.quad	7740639782147942025
	.quad	-2377363631119648861
	.quad	2532056854628769814
	.quad	-8403381297090862394
	.quad	-6058300968568813541
	.quad	-5892540602936190089
	.quad	-7572876210711016926
	.quad	-2753989735242849707
	.quad	9102010423587778133
	.quad	-8638772612167862923
	.quad	-2457545025797441046
	.quad	-6186779746782440750
	.quad	-7683617300674189211
	.quad	-3121788665050663033
	.quad	-4802260812921368257
	.quad	-8868646943297746252
	.quad	-1391139997724322417
	.quad	-6474122660694794911
	.quad	7484447039699372787
	.quad	-3480967307441105734
	.quad	-9157278655470055720
	.quad	-9093133594791772940
	.quad	-6834912300910181746
	.quad	-6754730975062328271
	.quad	679731660717048625
	.quad	-3831727700400522434
	.quad	-8373707460958465027
	.quad	-177973607073265139
	.quad	8601490892183123070
	.quad	-7028762532061872568
	.quad	-7694880458480647778
	.quad	-4174267146649952806
	.quad	4216457482181353989
	.quad	-606147914885053103
	.quad	-4282243101277735613
	.quad	-7296371474444240046
	.quad	8482254178684994196
	.quad	-4508778324627912153
	.quad	5991131704928854841
	.quad	-1024286887357502287
	.quad	-3173071712060547580
	.quad	-7557708332239520786
	.quad	-8578025658503072379
	.quad	-4835449396872013078
	.quad	3112525982153323238
	.quad	-1432625727662628443
	.quad	4251171748059520976
	.quad	-7812920107430224633
	.quad	702278666647013315
	.quad	-5154464115860392887
	.quad	5489534351736154548
	.quad	-1831394126398103205
	.quad	1125115960621402641
	.quad	-8062150356639896359
	.quad	6018080969204141205
	.quad	-5466001927372482545
	.quad	2910915193077788602
	.quad	-2220816390788215277
	.quad	-486521013540076076
	.quad	-8305539271883716405
	.quad	-608151266925095095
	.quad	-5770238071427257602
	.quad	-5371875102083756772
	.quad	-2601111570856684098
	.quad	3560107088838733873
	.quad	-8543223759426509417
	.quad	-161552157378970562
	.quad	-6067343680855748868
	.quad	4409745821703674701
	.quad	-2972493582642298180
	.quad	-6467280898289979120
	.quad	-8775337516792518219
	.quad	1139270913992301908
	.quad	-6357485877563259869
	.quad	-3187597375937010519
	.quad	-3335171328526686933
	.quad	7231123676894144234
	.quad	-9002011107970261189
	.quad	4427218577690292388
	.quad	-6640827866535438582
	.quad	-3689348814741910323
	.quad	-3689348814741910324
	.quad	0
	.quad	-9223372036854775808
	.quad	0
	.quad	-6917529027641081856
	.quad	0
	.quad	-4035225266123964416
	.quad	0
	.quad	-432345564227567616
	.quad	0
	.quad	-7187745005283311616
	.quad	0
	.quad	-4372995238176751616
	.quad	0
	.quad	-854558029293551616
	.quad	0
	.quad	-7451627795949551616
	.quad	0
	.quad	-4702848726509551616
	.quad	0
	.quad	-1266874889709551616
	.quad	0
	.quad	-7709325833709551616
	.quad	0
	.quad	-5024971273709551616
	.quad	0
	.quad	-1669528073709551616
	.quad	0
	.quad	-7960984073709551616
	.quad	0
	.quad	-5339544073709551616
	.quad	0
	.quad	-2062744073709551616
	.quad	0
	.quad	-8206744073709551616
	.quad	0
	.quad	-5646744073709551616
	.quad	0
	.quad	-2446744073709551616
	.quad	0
	.quad	-8446744073709551616
	.quad	0
	.quad	-5946744073709551616
	.quad	0
	.quad	-2821744073709551616
	.quad	0
	.quad	-8681119073709551616
	.quad	0
	.quad	-6239712823709551616
	.quad	0
	.quad	-3187955011209551616
	.quad	0
	.quad	-8910000909647051616
	.quad	0
	.quad	-6525815118631426616
	.quad	0
	.quad	-3545582879861895366
	.quad	4611686018427387904
	.quad	-9133518327554766460
	.quad	5764607523034234880
	.quad	-6805211891016070171
	.quad	-6629298651489370112
	.quad	-3894828845342699810
	.quad	5548434740920451072
	.quad	-256850038250986858
	.quad	-1143914305352105984
	.quad	-7078060301547948643
	.quad	7793479155164643328
	.quad	-4235889358507547899
	.quad	-4093209111326359552
	.quad	-683175679707046970
	.quad	4359273333062107136
	.quad	-7344513827457986212
	.quad	5449091666327633920
	.quad	-4568956265895094861
	.quad	2199678564482154496
	.quad	-1099509313941480672
	.quad	1374799102801346560
	.quad	-7604722348854507276
	.quad	1718498878501683200
	.quad	-4894216917640746191
	.quad	6759809616554491904
	.quad	-1506085128623544835
	.quad	6530724019560251392
	.quad	-7858832233030797378
	.quad	-1059967012404461568
	.quad	-5211854272861108819
	.quad	7898413271349198848
	.quad	-1903131822648998119
	.quad	-1981020733047832576
	.quad	-8106986416796705681
	.quad	-2476275916309790720
	.quad	-5522047002568494197
	.quad	-3095344895387238400
	.quad	-2290872734783229842
	.quad	4982938468024057856
	.quad	-8349324486880600507
	.quad	-7606384970252091392
	.quad	-5824969590173362730
	.quad	4327076842467049472
	.quad	-2669525969289315508
	.quad	-6518949010312869888
	.quad	-8585982758446904049
	.quad	-8148686262891087360
	.quad	-6120792429631242157
	.quad	8260886245095692416
	.quad	-3039304518611664792
	.quad	5163053903184807760
	.quad	-8817094351773372351
	.quad	-7381240676301154012
	.quad	-6409681921289327535
	.quad	-3178808521666707
	.quad	-3400416383184271515
	.quad	-4613672773753429595
	.quad	-9042789267131251553
	.quad	-5767090967191786994
	.quad	-6691800565486676537
	.quad	-7208863708989733743
	.quad	-3753064688430957767
	.quad	212292400617608629
	.quad	-79644842111309304
	.quad	132682750386005393
	.quad	-6967307053960650171
	.quad	4777539456409894646
	.quad	-4097447799023424810
	.quad	-3251447716342407501
	.quad	-510123730351893109
	.quad	7191217214140771120
	.quad	-7236356359111015049
	.quad	4377335499248575996
	.quad	-4433759430461380907
	.quad	-8363388681221443717
	.quad	-930513269649338230
	.quad	-7532960934977096275
	.quad	-7499099821171918250
	.quad	4418856886560793368
	.quad	-4762188758037509908
	.quad	5523571108200991710
	.quad	-1341049929119499481
	.quad	-8076983103442849941
	.quad	-7755685233340769032
	.quad	-5484542860876174523
	.quad	-5082920523248573386
	.quad	6979379479186945559
	.quad	-1741964635633328828
	.quad	-4861259862362934834
	.quad	-8006256924911912374
	.quad	7758483227328495170
	.quad	-5396135137712502563
	.quad	-4136954021121544750
	.quad	-2133482903713240300
	.quad	-279753253987271517
	.quad	-8250955842461857044
	.quad	4261994450943298508
	.quad	-5702008784649933400
	.quad	5327493063679123135
	.quad	-2515824962385028846
	.quad	7941369183226839864
	.quad	-8489919629131724885
	.quad	5315025460606161925
	.quad	-6000713517987268202
	.quad	-2579590211097073401
	.quad	-2889205879056697349
	.quad	7611128154919104932
	.quad	-8723282702051517699
	.quad	-4321147861633282547
	.quad	-6292417359137009220
	.quad	-789748808614215279
	.quad	-3253835680493873621
	.quad	8729779031470891259
	.quad	-8951176327949752869
	.quad	6300537770911226169
	.quad	-6577284391509803182
	.quad	-1347699823215743097
	.quad	-3609919470959866074
	.quad	6075216638131242421
	.quad	-9173728696990998152
	.quad	7594020797664053026
	.quad	-6855474852811359786
	.quad	269153960225290474
	.quad	-3957657547586811828
	.quad	336442450281613092
	.quad	-335385916056126881
	.quad	7127805559067090039
	.quad	-7127145225176161157
	.quad	4298070930406474645
	.quad	-4297245513042813542
	.quad	-3850783373846682502
	.quad	-759870872876129024
	.quad	9122475437414293196
	.quad	-7392448323188662496
	.quad	-7043649776941685121
	.quad	-4628874385558440216
	.quad	-4192876202749718497
	.quad	-1174406963520662366
	.quad	-4926390635932268013
	.quad	-7651533379841495835
	.quad	3065383741939440792
	.quad	-4952730706374481889
	.quad	-779956341003086914
	.quad	-1579227364540714458
	.quad	6430056314514152535
	.quad	-7904546130479028392
	.quad	8037570393142690669
	.quad	-5268996644671397586
	.quad	823590954573587528
	.quad	-1974559787411859078
	.quad	5126430365035880109
	.quad	-8151628894773493780
	.quad	6408037956294850136
	.quad	-5577850100039479321
	.quad	3398361426941174766
	.quad	-2360626606621961247
	.quad	-4793553135802847627
	.quad	-8392920656779807636
	.quad	-1380255401326171630
	.quad	-5879464802547371641
	.quad	-1725319251657714538
	.quad	-2737644984756826647
	.quad	3533361486141316318
	.quad	-8628557143114098510
	.quad	-4806670179178130410
	.quad	-6174010410465235234
	.quad	7826720331309500699
	.quad	-3105826994654156138
	.quad	280014188641050033
	.quad	-8858670899299929442
	.quad	-8873354301053463267
	.quad	-6461652605697523899
	.quad	-1868320839462053276
	.quad	-3465379738694516970
	.quad	5749828502977298559
	.quad	-9083391364325154962
	.quad	-2036086408133152610
	.quad	-6742553186979055799
	.quad	6678264026688335046
	.quad	-3816505465296431844
	.quad	8347830033360418807
	.quad	-158945813193151901
	.quad	2911550761636567803
	.quad	-7016870160886801794
	.quad	-5583933584809066055
	.quad	-4159401682681114339
	.quad	2243455055843443239
	.quad	-587566084924005019
	.quad	3708002419115845977
	.quad	-7284757830718584993
	.quad	23317005467419567
	.quad	-4494261269970843337
	.quad	-4582539761593113445
	.quad	-1006140569036166268
	.quad	-558244341782001951
	.quad	-7546366883288685774
	.quad	-5309491445654890343
	.quad	-4821272585683469313
	.quad	-6636864307068612929
	.quad	-1414904713676948737
	.quad	-4148040191917883080
	.quad	-7801844473689174817
	.quad	-5185050239897353851
	.quad	-5140619573684080617
	.quad	-6481312799871692314
	.quad	-1814088448677712867
	.quad	-8662506518347195600
	.quad	-8051334308064652398
	.quad	3006924907348169212
	.quad	-5452481866653427593
	.quad	-853029884242176389
	.quad	-2203916314889396588
	.quad	1772699331562333709
	.quad	-8294976724446954723
	.quad	6827560182880305040
	.quad	-5757034887131305500
	.quad	8534450228600381300
	.quad	-2584607590486743971
	.quad	7639874402088932265
	.quad	-8532908771695296838
	.quad	326470965756389523
	.quad	-6054449946191733143
	.quad	5019774725622874807
	.quad	-2956376414312278525
	.quad	831516194300602803
	.quad	-8765264286586255934
	.quad	-8183976793979022305
	.quad	-6344894339805432014
	.quad	3605087062808385831
	.quad	-3319431906329402113
	.quad	9170708441896323001
	.quad	-8992173969096958177
	.quad	6851699533943015847
	.quad	-6628531442943809817
	.quad	3952938399001381904
	.quad	-3673978285252374367
	.quad	-4446942528265218166
	.quad	-9213765455923815836
	.quad	-946992141904134803
	.quad	-6905520801477381891
	.quad	8039631859474607304
	.quad	-4020214983419339459
	.quad	-3785518230938904582
	.quad	-413582710846786420
	.quad	-60105885123121412
	.quad	-7176018221920323369
	.quad	-75132356403901765
	.quad	-4358336758973016307
	.quad	9129456591349898602
	.quad	-836234930288882479
	.quad	-1211618658047395230
	.quad	-7440175859071633406
	.quad	-6126209340986631941
	.quad	-4688533805412153853
	.quad	-7657761676233289927
	.quad	-1248981238337804412
	.quad	-2480258038432112252
	.quad	-7698142301602209614
	.quad	-7712008566467528219
	.quad	-5010991858575374113
	.quad	8806733365625141342
	.quad	-1652053804791829737
	.quad	-6025006692552756421
	.quad	-7950062655635975442
	.quad	6303799689591218186
	.quad	-5325892301117581398
	.quad	-1343622424865753076
	.quad	-2045679357969588844
	.quad	1466078993672598280
	.quad	-8196078626372074883
	.quad	6444284760518135753
	.quad	-5633412264537705700
	.quad	8055355950647669692
	.quad	-2430079312244744221
	.quad	2728754459941099605
	.quad	-8436328597794046994
	.quad	-5812428961928401301
	.quad	-5933724728815170839
	.quad	1957835834444274181
	.quad	-2805469892591575644
	.quad	-7999724640327104445
	.quad	-8670947710510816634
	.quad	3835402254873283156
	.quad	-6226998619711132888
	.quad	4794252818591603945
	.quad	-3172062256211528206
	.quad	7608094030047140370
	.quad	-8900067937773286985
	.quad	4898431519131537558
	.quad	-6513398903789220827
	.quad	-7712018656367741764
	.quad	-3530062611309138130
	.quad	2097517367411243254
	.quad	-9123818159709293187
	.quad	7233582727691441971
	.quad	-6793086681209228580
	.quad	9041978409614302463
	.quad	-3879672333084147821
	.quad	6690786993590490175
	.quad	-237904397927796872
	.quad	4181741870994056360
	.quad	-7066219276345954901
	.quad	615491320315182545
	.quad	-4221088077005055722
	.quad	-8454007886460797626
	.quad	-664674077828931749
	.quad	3939617107816777292
	.quad	-7332950326284164199
	.quad	-8910536670511192098
	.quad	-4554501889427817345
	.quad	7308573235570561494
	.quad	-1081441343357383777
	.quad	-6961356773836868826
	.quad	-7593429867239446717
	.quad	-8701695967296086033
	.quad	-4880101315621920492
	.quad	-6265433940692719637
	.quad	-1488440626100012711
	.quad	695789805494438131
	.quad	-7847804418953589800
	.quad	869737256868047664
	.quad	-5198069505264599346
	.quad	-8136200465769716229
	.quad	-1885900863153361279
	.quad	-473439272678684739
	.quad	-8096217067111932656
	.quad	4019886927579031981
	.quad	-5508585315462527915
	.quad	-8810199395808373736
	.quad	-2274045625900771990
	.quad	-7812217631593927537
	.quad	-8338807543829064350
	.quad	4069786015789754291
	.quad	-5811823411358942533
	.quad	475546501309804959
	.quad	-2653093245771290262
	.quad	4908902581746016004
	.quad	-8575712306248138270
	.quad	-3087243809672255804
	.quad	-6107954364382784934
	.quad	-8470740780517707659
	.quad	-3023256937051093263
	.quad	-682526969396179382
	.quad	-8807064613298015146
	.quad	-5464844730172612132
	.quad	-6397144748195131028
	.quad	-2219369894288377261
	.quad	-3384744916816525881
	.quad	-1387106183930235788
	.quad	-9032994600651410532
	.quad	2877803288514593169
	.quad	-6679557232386875260
	.quad	3597254110643241461
	.quad	-3737760522056206171
	.quad	9108253656731439730
	.quad	-60514634142869810
	.quad	1080972517029761927
	.quad	-6955350673980375487
	.quad	5962901664714590313
	.quad	-4082502324048081455
	.quad	-6381430974388925821
	.quad	-491441886632713915
	.quad	-8600080377420466542
	.quad	-7224680206786528053
	.quad	7696643601933968438
	.quad	-4419164240055772162
	.quad	397432465562684740
	.quad	-912269281642327298
	.quad	-4363290727450709941
	.quad	-7487697328667536418
	.quad	8380944645968776285
	.quad	-4747935642407032618
	.quad	1252808770606194548
	.quad	-1323233534581402868
	.quad	-8440366555225904215
	.quad	-7744549986754458649
	.quad	7896285879677171347
	.quad	-5069001465015685407
	.quad	-3964700705685699528
	.quad	-1724565812842218855
	.quad	2133748077373825699
	.quad	-7995382660667468640
	.quad	2667185096717282124
	.quad	-5382542307406947896
	.quad	3333981370896602654
	.quad	-2116491865831296966
	.quad	6695424375237764563
	.quad	-8240336443785642460
	.quad	8369280469047205704
	.quad	-5688734536304665171
	.quad	-3373457468973156582
	.quad	-2499232151953443560
	.quad	-9025939945749304720
	.quad	-8479549122611984081
	.quad	7164319141522920716
	.quad	-5987750384837592197
	.quad	4343712908476262991
	.quad	-2873001962619602342
	.quad	7326506586225052274
	.quad	-8713155254278333320
	.quad	9158133232781315342
	.quad	-6279758049420528746
	.quad	2224294504121868369
	.quad	-3238011543348273028
	.quad	-7833187971778608077
	.quad	-8941286242233752499
	.quad	-568112927868484288
	.quad	-6564921784364802720
	.quad	3901544858591782543
	.quad	-3594466212028615495
	.quad	-4479063491021217766
	.quad	-9164070410158966541
	.quad	-5598829363776522208
	.quad	-6843401994271320272
	.quad	-2386850686293264856
	.quad	-3942566474411762436
	.quad	1628122660560806834
	.quad	-316522074587315140
	.quad	-8205795374004271537
	.quad	-7115355324258153819
	.quad	-1033872180650563613
	.quad	-4282508136895304370
	.quad	-5904026244240592420
	.quad	-741449152691742558
	.quad	-5995859411864064214
	.quad	-7380934748073420955
	.quad	1728547772024695540
	.quad	-4614482416664388289
	.quad	-2451001303396518479
	.quad	-1156417002403097458
	.quad	5385653213018257807
	.quad	-7640289654143017767
	.quad	-7102991539009341454
	.quad	-4938676049251384305
	.quad	-8878739423761676818
	.quad	-1561659043136842477
	.quad	3674159897003727797
	.quad	-7893565929601608404
	.quad	4592699871254659746
	.quad	-5255271393574622601
	.quad	1129188820640936779
	.quad	-1957403223540890347
	.quad	3011586022114279439
	.quad	-8140906042354138323
	.quad	8376168546070237203
	.quad	-5564446534515285000
	.quad	-7976533391121755113
	.quad	-2343872149716718346
	.quad	1932195658189984911
	.quad	-8382449121214030822
	.quad	-6808127464117294670
	.quad	-5866375383090150624
	.quad	-3898473311719230433
	.quad	-2721283210435300376
	.quad	9092669226243950739
	.quad	-8618331034163144591
	.quad	-2469221522477225288
	.quad	-6161227774276542835
	.quad	6136845133758244198
	.quad	-3089848699418290639
	.quad	-3082000819042179232
	.quad	-8848684464777513506
	.quad	-8464187042230111944
	.quad	-6449169562544503978
	.quad	3254824252494523782
	.quad	-3449775934753242068
	.quad	-7189106879045698444
	.quad	-9073638986861858149
	.quad	-8986383598807123056
	.quad	-6730362715149934782
	.quad	2602078556773259892
	.quad	-3801267375510030573
	.quad	-1359087822460813039
	.quad	-139898200960150313
	.quad	-849429889038008149
	.quad	-7004965403241175802
	.quad	-5673473379724898090
	.quad	-4144520735624081848
	.quad	-2480155706228734709
	.quad	-568964901102714406
	.quad	-3855940325606653145
	.quad	-7273132090830278360
	.quad	-208239388580928527
	.quad	-4479729095110460046
	.quad	-4871985254153548563
	.quad	-987975350460687153
	.quad	-3044990783845967852
	.quad	-7535013621679011327
	.quad	5417133557047315993
	.quad	-4807081008671376254
	.quad	-2451955090545630817
	.quad	-1397165242411832414
	.quad	-3838314940804713212
	.quad	-7790757304148477115
	.quad	4425478360848884292
	.quad	-5126760611758208489
	.quad	920161932633717461
	.quad	-1796764746270372707
	.quad	2880944217109767366
	.quad	-8040506994060064798
	.quad	-5622191765467566601
	.quad	-5438947724147693094
	.quad	6807318348447705460
	.quad	-2186998636757228463
	.quad	-2662955059861265943
	.quad	-8284403175614349646
	.quad	-7940379843253970333
	.quad	-5743817951090549153
	.quad	8521269269642088700
	.quad	-2568086420435798537
	.quad	-6203421752542164322
	.quad	-8522583040413455942
	.quad	6080780864604458309
	.quad	-6041542782089432023
	.quad	-6234081974526590826
	.quad	-2940242459184402125
	.quad	5327070802775656542
	.quad	-8755180564631333184
	.quad	6658838503469570677
	.quad	-6332289687361778576
	.quad	8323548129336963346
	.quad	-3303676090774835316
	.quad	-4021154456019173716
	.quad	-8982326584375353929
	.quad	-5026443070023967146
	.quad	-6616222212041804507
	.quad	2940318199324816876
	.quad	-3658591746624867729
	.quad	8755227902219092404
	.quad	-9204148869281624187
	.quad	-2891023177508298208
	.quad	-6893500068174642330
	.quad	-8225464990312760664
	.quad	-4005189066790915008
	.quad	-5670145219463562926
	.quad	-394800315061255856
	.quad	7985374283903742932
	.quad	-7164279224554366766
	.quad	758345818024902857
	.quad	-4343663012265570553
	.quad	-3663753745896259333
	.quad	-817892746904575288
	.quad	-9207375118826243939
	.quad	-7428711994456441411
	.quad	-2285846861678029116
	.quad	-4674203974643163860
	.quad	1754377441329851509
	.quad	-1231068949876566920
	.quad	1096485900831157193
	.quad	-7686947121313936181
	.quad	-3241078642388441413
	.quad	-4996997883215032323
	.quad	5172023733869224042
	.quad	-1634561335591402499
	.quad	5538357842881958978
	.quad	-7939129862385708418
	.quad	-2300424733252327085
	.quad	-5312226309554747619
	.quad	6347841120289366951
	.quad	-2028596868516046619
	.quad	6273243709394548297
	.quad	-8185402070463610993
	.quad	3229868618315797467
	.quad	-5620066569652125837
	.quad	-574350245532641070
	.quad	-2413397193637769393
	.quad	-358968903457900669
	.quad	-8425902273664687727
	.quad	8774660907532399972
	.quad	-5920691823653471754
	.quad	1744954097560724157
	.quad	-2789178761139451788
	.quad	-8132775725879323210
	.quad	-8660765753353239224
	.quad	-5554283638921766109
	.quad	-6214271173264161126
	.quad	6892203506629956076
	.quad	-3156152948152813503
	.quad	-2609901835997359308
	.quad	-8890124620236590296
	.quad	1349308723430688769
	.quad	-6500969756868349965
	.quad	-2925050114139026943
	.quad	-3514526177658049553
	.quad	-1828156321336891839
	.quad	-9114107888677362827
	.quad	6938176635183661009
	.quad	-6780948842419315629
	.quad	4061034775552188357
	.quad	-3864500034596756632
	.quad	5076293469440235446
	.quad	-218939024818557886
	.quad	7784369436827535058
	.quad	-7054365918152680535
	.quad	-4104596259247744890
	.quad	-4206271379263462765
	.quad	-5130745324059681112
	.quad	-646153205651940552
	.size	global_constant_0, 9904

	.type	static_string_978d8d34847e5196,@object
	.p2align	4, 0x0
static_string_978d8d34847e5196:
	.asciz	"0123456789abcdefghijklmnopqrstuvwxyz"
	.size	static_string_978d8d34847e5196, 37

	.type	static_string_3dbcb4d72b465ec0,@object
	.p2align	4, 0x0
static_string_3dbcb4d72b465ec0:
	.asciz	"FIXED_WRITE_BUFFER_BYTES exceeded, increase with: `mojo -D FIXED_WRITE_BUFFER_BYTES=4096`\n"
	.size	static_string_3dbcb4d72b465ec0, 91

	.type	static_string_0d78baac08237ddb,@object
	.p2align	4, 0x0
static_string_0d78baac08237ddb:
	.asciz	"a"
	.size	static_string_0d78baac08237ddb, 2

	.type	static_string_0dcb71a55f79a509,@object
	.p2align	4, 0x0
static_string_0dcb71a55f79a509:
	.asciz	"At: %s:%llu:%llu: Assert Error: %s\n"
	.size	static_string_0dcb71a55f79a509, 36

	.type	static_string_bbe01a6a523daf15,@object
	.p2align	4, 0x0
static_string_bbe01a6a523daf15:
	.asciz	"\n"
	.size	static_string_bbe01a6a523daf15, 2

	.type	static_string_a8d4ace0dc8d360e,@object
	.p2align	4, 0x0
static_string_a8d4ace0dc8d360e:
	.asciz	" "
	.size	static_string_a8d4ace0dc8d360e, 2

	.type	static_string_31203c1a2bdb78cc,@object
	.p2align	4, 0x0
static_string_31203c1a2bdb78cc:
	.asciz	"ABORT:"
	.size	static_string_31203c1a2bdb78cc, 7

	.type	static_string_7f1562353e292282,@object
	.p2align	4, 0x0
static_string_7f1562353e292282:
	.asciz	": "
	.size	static_string_7f1562353e292282, 3

	.type	static_string_c44bdff4074eecdb,@object
	.p2align	4, 0x0
static_string_c44bdff4074eecdb:
	.zero	1
	.size	static_string_c44bdff4074eecdb, 1

	.section	".note.GNU-stack","",@progbits
