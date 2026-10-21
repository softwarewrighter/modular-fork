# Top down: one X_eTaL program to five instruction sets

One eight-element program, `threshold.xtl`, followed from X_eTaL source
through every representation it takes on the way to a GPU or a CPU,
with the program or call that makes each step and a link to each
committed listing. Nothing on the path is written by hand: the source
is the only input, and every run is checked against two independent
oracles, the Rust reference evaluator in this tool and what X_eTaL's own
evaluator printed for the source. The blog post summarizes this
document; the handoff notes beside it (`*-blog-handoff.md`) read each
listing in detail.

Listings are from 2026-10-16 (Mojo's PTX, on the RTX 5060 Ti) and
2026-10-21 (everything else). X_eTaL-gpu revision `38bae5c` lowered the
program; Mojo 1.2.0.dev2026101305 compiled it everywhere.

```
threshold.xtl ──xetal──▶ Core ──xetal-gpu lower──▶ XIR ──xir-mojo──▶ Mojo ──mojo build──▶ PTX      (RTX 5060 Ti, CUDA)
                                                        │                                 AIR      (M1 Max, Metal)
                                                        │                                 AMDGCN   (gfx1100, listing only)
                                                        │                                 arm64    (M1 Max CPU)
                                                        ├──xir-mojo emit-cuda──▶ CUDA C++ ──nvcc──▶ PTX, SASS
                                                        └──xetal-gpu kernel────▶ OpenCL C ──driver─▶ (PTX on NVIDIA, not shown yet)
```

## Level 0: the X_eTaL source

The program is one of X_eTaL-gpu's Accel demos. Seven lines: a float
vector `x`, a threshold at 0.5, a ReLU, an Int vector `n`, a ReLU of
it, and a keep-by-mask with a floored modulo.

```
"ac:" u_se< "Accel"
x := ((r_ange 8) / 4) - 1.0
x
0.5 ac:t_hreshold x
ac:r_elu x
n := (r_ange 8) - 4
ac:r_elu n
(n m_od 2) ac:k_eep n
```

The three library functions are one line each in Accel:
`l:r_elu := { x -> x m_ax 0 }`,
`l:t_hreshold := { t x -> x * f_loat x > t }`,
`l:k_eep := { m x -> x * m }`.

- Source: [`libs/Accel/demos/threshold.xtl`](https://github.com/softwarewrighter/X_eTaL-gpu/blob/8d5b943/libs/Accel/demos/threshold.xtl) in X_eTaL-gpu; the library, [`libs/Accel/src/Accel.xtl`](https://github.com/softwarewrighter/X_eTaL-gpu/blob/8d5b943/libs/Accel/src/Accel.xtl).
- What the evaluator prints, the oracle every run below is held to: [`programs/accel-threshold.expect`](../programs/accel-threshold.expect).

```
-0.75 -0.5 -0.25 0.0 0.25 0.5 0.75 1.0
-0.0 -0.0 -0.0 0.0 0.0 0.0 0.75 1.0
0.0 0.0 0.0 0.0 0.25 0.5 0.75 1.0
0 0 0 0 1 2 3 4
-3 0 -1 0 1 0 3 0
```

## Level 1: Core

X_eTaL's loader parses the source, resolves the `u_se<` import, and
lowers to Core, the small applicative form its evaluator runs. The
program or call: `xetal core FILE` prints it; X_eTaL-gpu reaches the
same thing through `xetal_program::load(name, src)`.

```
(eval (app2 #u_se< "ac:" "Accel"))
(let x (app2 #- (app2 #/ (app #r_ange 8) 4) 1.0))
(eval x)
(eval (app2 ac:t_hreshold 0.5 x))
(eval (app ac:r_elu x))
(let n (app2 #- (app #r_ange 8) 4))
(eval (app ac:r_elu n))
(eval (app2 ac:k_eep (app2 #m_od n 2) n))
```

Nothing is specialized yet: the library calls are still calls, and
`r_ange 8` is still a call.

## Level 2: XIR

X_eTaL-gpu's lowering (`components/lower`) walks Core as a small
evaluator. Values it can compute now (`r_ange 8`, the scalars) fold
into constants; everything else becomes one XIR operation, with the
library closures inlined at their calls. Each push is type-checked
against the XIR checker. The program or call: `xetal-gpu lower FILE.xtl`;
in this repository, `scripts/from-xtl.sh` wraps it and adds a provenance
header.

```
%l = const f64 [8] 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0
%r = const f64 [] 4.0
%div = map div %l %r
%r_2 = const f64 [] 1.0
%sub = map sub %div %r_2
%r_3 = const f64 [] 0.5
%gt = map gt %sub %r_3
%f = cast f64 %gt
%mul = map mul %sub %f
%r_4 = const f64 [] 0.0
%max = map max %sub %r_4
%l_2 = const i64 [8] 1 2 3 4 5 6 7 8
%r_5 = const i64 [] 4
%sub_2 = map sub %l_2 %r_5
%r_6 = const i64 [] 0
%max_2 = map max %sub_2 %r_6
%r_7 = const i64 [] 2
%mod = map mod %sub_2 %r_7
%mul_2 = map mul %sub_2 %mod
output %sub
output %mul
output %max
output %max_2
output %mul_2
```

- Listing: [`programs/accel-threshold.xir`](../programs/accel-threshold.xir).
- Ten operations, five outputs, two vector constants, no reductions, so
  everything below fuses into one kernel. The three library functions
  are gone: `t_hreshold` is the `gt`, `cast`, `mul` triple.

## Level 3: Mojo

This tool (`xir-mojo`, Rust) parses the XIR, plans the fused stages, and
writes a Mojo file: one `stage0_at(i, ...)` body with a line per XIR
value, a `stage0` GPU kernel that calls it one thread per element, and
the host code (`xir_run`) that creates buffers, copies, launches and
copies back through Mojo's `DeviceContext`, exported with a C ABI. The
program or call: `xir-mojo run programs/accel-threshold.xir` (steps:
`ir::parse`, `eval::run` for the reference, `emit::plan`, `emit::emit`).

```mojo
@inline(.always)
def stage0_at(i: Int, b_l: ..., b_l_2: ..., b_sub: ..., b_mul: ..., b_max: ..., b_max_2: ..., b_mul_2: ...):
    var v_l = b_l[unsafe_offset=i]
    var v_l_2 = b_l_2[unsafe_offset=i]
    var v_div = v_l / Float32(4.0)
    var v_sub = v_div - Float32(1.0)
    var v_gt = Bool(v_sub > Float32(0.5))
    var v_f = Float32(1.0) if v_gt else Float32(0.0)
    var v_mul = v_sub * v_f
    var v_max = max(v_sub, Float32(0.0))
    var v_sub_2 = v_l_2 - Float32(4.0)
    var v_max_2 = max(v_sub_2, Float32(0.0))
    var v_mod = Float32(Int(v_sub_2) % Int(Float32(2.0)))
    var v_mul_2 = v_sub_2 * v_mod
    b_sub[unsafe_offset=i] = v_sub
    ...
```

- Listing: [`evidence/m1max-cpu-20261021/accel-threshold.mojo`](evidence/m1max-cpu-20261021/accel-threshold.mojo)
  (the current emitter, with the CPU path); the Metal and CUDA captures
  hold the earlier 196-line form without `stage0_at`, same kernel body.
- Ints are carried in `Float32` here, exact below 2^24, with the
  floored `mod` through Mojo's `Int %`. The same file builds for every
  target below; the emitter does not know which.

## Level 4a: PTX, through Mojo (NVIDIA, RTX 5060 Ti)

`mojo build --emit shared-lib` compiles `stage0` a second time for the
GPU target through the `kgen.compile_offload` intrinsic and LLVM's
NVPTX back-end, and embeds the result; `-D DUMP_GPU_ASM=true` prints it
at first use. The program or call: `xir-mojo run ... --dump-asm` (or
`just asm accel-threshold`) on a machine with the card.

```ptx
.target sm_120a
mul.rn.f32   %r6, %r4, 0f3E800000;      // l * 0.25
add.f32      %r7, %r6, 0fBF800000;      // - 1.0
setp.gt.f32  %p2, %r7, 0f3F000000;      // > 0.5
selp.f32     %r8, 0f3F800000, 0f00000000, %p2;
mul.f32      %r9, %r7, %r8;             // t_hreshold
max.f32      %r10, %r7, 0f00000000;     // r_elu x
cvt.rzi.s64.f32 %rd27, %r11;            // n as an Int, then ten lines of floored mod 2
```

- Listing: [`evidence/rtx5060-20261016-ten-programs/int-assembly.log`](evidence/rtx5060-20261016-ten-programs/int-assembly.log); the run beside it, five outputs exact against both oracles.
- How Mojo reaches the card without the CUDA toolkit: its own compiler
  makes the PTX, its bundled PTX compiler makes SASS, and only
  `libcuda.so` from the driver is borrowed, to load and launch
  ([`rtx5060-handoff.md`](rtx5060-handoff.md), [`porting-arch-rtx5060.md`](porting-arch-rtx5060.md)).

## Level 4b: AIR, through Mojo (Apple, M1 Max)

On Apple silicon the same build emits AIR, Metal's intermediate form
(LLVM IR with Apple's intrinsics), which Apple's compiler in the driver
turns into the GPU's native code at load. The program or call:
`mojo build --target-accelerator=metal:4 --emit asm` for the side file,
or `--dump-asm` in the run; `scripts/capture-metal.sh` does both.

```llvm
target triple = "air64-apple-macosx26.0.0"
%60 = fdiv float %57, 4.000000e+00
%61 = fsub contract float %60, 1.000000e+00
%62 = fcmp ogt float %61, 5.000000e-01
%63 = select i1 %62, float 1.000000e+00, float 0.000000e+00
%65 = call float @air.fmax.f32(float %61, float 0.000000e+00)
%68 = call i64 @air.convert.s.i64.f.f32(float %66)
```

- Listing: [`evidence/m1max-metal-20261021/accel-threshold-stage0.air.ll`](evidence/m1max-metal-20261021/accel-threshold-stage0.air.ll); the run, [`metal.log`](evidence/m1max-metal-20261021/metal.log), five outputs exact.
- Reading: [`metal-blog-handoff.md`](metal-blog-handoff.md). Apple does
  not expose the AIR-to-native step.

## Level 4c: AMDGCN, through Mojo (gfx1100, listing only)

Mojo cross-compiles for a named AMD architecture with no AMD device
present. The program or call: `mojo build --target-accelerator=gfx1100
--emit asm`; `scripts/capture-amd.sh`.

```
.amdgcn_target "amdgpu11.00-amd-amdhsa-unknown-gfx1100"
v_mul_f32_e32 v8, 0x3e800000, v8        ; * 0.25
v_add_f32_e32 v12, -1.0, v8
v_cmp_lt_f32_e32 vcc_lo, 0.5, v12
v_cndmask_b32_e64 v14, 0, 1.0, vcc_lo
v_max_f32_e32 v14, 0, v12
v_trunc_f32_e32 v2, v10                 ; the start of f32 -> i64, which RDNA3 has no single instruction for
```

- Listing: [`evidence/amd-gfx1100-listings-20261021/accel-threshold-stage0.gfx1100.amdgcn`](evidence/amd-gfx1100-listings-20261021/accel-threshold-stage0.gfx1100.amdgcn).
- Reading: [`amd-blog-handoff.md`](amd-blog-handoff.md). Nothing ran;
  no output, no check.

## Level 4d: arm64, through Mojo (the M1 Max's CPU)

The same file built with `-D XIR_CPU=true`: a CPU `DeviceContext`, the
same buffers and copies, and `stage0_at` called by `enqueue_cpu_range`
once per element instead of by a kernel. The program or call:
`xir-mojo run ... --cpu` (`just cpu accel-threshold`); the host assembly
from `mojo build -D XIR_CPU=true --emit asm`; `scripts/capture-cpu.sh`.

```
_xir_run_async_closure_2_resume:
fmov    s2, #0.25000000
fmov    s3, #-1.00000000
fmadd   s0, s0, s2, s3                  ; l * 0.25 - 1, fused
fcmp    s0, s2                          ; > 0.5
fcsel   s3, s3, s2, gt
fmaxnm  s4, s0, s2
fcvtzs  x9, s1                          ; n as an Int; nine instructions for the floored mod
```

- Listing: [`evidence/m1max-cpu-20261021/accel-threshold-xir_run-closures.s`](evidence/m1max-cpu-20261021/accel-threshold-xir_run-closures.s); the run, [`cpu.log`](evidence/m1max-cpu-20261021/cpu.log), five outputs exact.
- Reading: [`cpu-blog-handoff.md`](cpu-blog-handoff.md). The x86-64
  half is the Arch agent's (A6) and uses the same flag.

## The other roads from XIR

**CUDA C++ and nvcc.** A second emitter in this tool, `xir-mojo
emit-cuda`, writes a standalone `.cu` with one `__global__` kernel per
stage and a self-check in `main`; nvcc makes PTX and SASS from it.
This is the control for the Mojo PTX: two compilers, one program, the
same instructions except that nvcc's default flags fuse the first two
float operations into an `fma`.
Listings: [`evidence/rtx5060-cuda-20261021/`](evidence/rtx5060-cuda-20261021/)
(`accel-threshold.cu`, `.ptx`, `-no-fma.ptx`, `.sass`, the run with zero
mismatches); reading, [`cuda-blog-handoff.md`](cuda-blog-handoff.md).

**OpenCL C, in X_eTaL-gpu.** The original backend emits one OpenCL C 1.2
kernel per stage from the same XIR, with Ints as real `long`, and runs
it through the vendor's OpenCL driver with the standard `clBuildProgram`
and `clEnqueueNDRangeKernel` calls. The program or call: `xetal-gpu
kernel FILE.xtl` prints it, `xetal-gpu run FILE.xtl` runs it.
Listing: [`components/opencl/tests/expected/threshold.cl`](https://github.com/softwarewrighter/X_eTaL-gpu/blob/8d5b943/components/opencl/tests/expected/threshold.cl)
in X_eTaL-gpu (identical to what the tool prints today). The PTX that
NVIDIA's OpenCL driver makes from it, and Apple's program binary, are
not shown yet (asks A7 and X1).

**HIP.** Not yet: a XIR to HIP emitter and `hipcc --offload-arch=gfx1100
-S` are the Arch agent's A2 and A3; when they land, Level 4c is the
Mojo half of that comparison.

**Mojo, in X_eTaL-gpu itself.** This tool's emitter was ported into
X_eTaL-gpu as `components/mojo` (`xetal-gpu run FILE.xtl --device mojo`),
so the chain above also runs end to end inside X_eTaL-gpu with no
sibling checkout; its results are in that repository's
[`docs/rtx5060-mojo-results.md`](https://github.com/softwarewrighter/X_eTaL-gpu/blob/8d5b943/docs/rtx5060-mojo-results.md).

## One line, five spellings

The last source line, `(n m_od 2) ac:k_eep n`, is where the targets
differ most. `m_od` is X_eTaL's floored modulo (`-3 mod 2` is `1`); the
Int travels as f32 and must be converted, reduced, sign-fixed and
converted back. Roughly, for the whole `%mod` value:

| Target | Instructions for `%mod` | Why |
| ------ | ----------------------- | --- |
| PTX (Mojo and nvcc alike) | about 10 | `cvt.rzi.s64.f32`, shifts and masks for `% 2`, a predicate and select for the sign fix, `cvt.rn.f32.s64` |
| AIR | about 10 | `@air.convert.s.i64.f.f32`, `sdiv`/`mul`/`sub`, two `icmp`, `and`, `select`, `@air.convert.f.f32.s.i64`; generic LLVM IR, so the counting is of IR operations |
| AMDGCN gfx1100 | about 30 | RDNA3 has no f32-to-i64 or i64-to-f32 instruction; each conversion is expanded by hand (`v_trunc`, `v_floor`, `v_fma`, `v_cvt_u32`, and `v_cls_i32`, `v_ldexp` back) |
| arm64 | 9 | `fcvtzs`, `and`, `cneg`, `cmp`, `ccmp`, `csel`, `add`, `scvtf`: 64-bit conversions and conditionals in hardware |

The float lines barely differ: a multiply by 0.25 (the divide by 4
folded) and an add of -1.0, fused into one FMA by nvcc and by the arm64
back-end, kept separate by Mojo's PTX and by the AIR (which marks them
`contract`, allowing the fusion later).

## What is and is not established

| Target | Listing | Ran | Checked against both oracles |
| ------ | ------- | --- | ---------------------------- |
| PTX, Mojo (RTX 5060 Ti) | yes | yes | yes, exact |
| PTX and SASS, nvcc (RTX 5060 Ti) | yes | yes | yes, against `.expect` |
| AIR, Mojo (M1 Max) | yes | yes | yes, exact |
| AMDGCN, Mojo (gfx1100) | yes | no | no |
| arm64, Mojo (M1 Max CPU) | yes | yes | yes, exact |
| OpenCL C (X_eTaL-gpu) | yes | yes, on both cards (X_eTaL-gpu's results) | yes, in X_eTaL-gpu's gate |
| x86-64, Mojo (Arch CPU) | pending A6 | | |
| HIP and hipcc AMDGCN | pending A2, A3 | | |
| NVIDIA OpenCL's PTX, Apple's OpenCL binary | pending A7, X1 | | |

Metal's AIR-to-native step and the SASS Mojo's bundled assembler
produces are not shown; the nvcc SASS stands in for the latter.

## Reproducing the levels

From `rust-demo`, after `just setup`:

```sh
XETAL_PATH="$(cd ../../X_eTaL-gpu && scripts/libs.py path)"
(cd ../../X_eTaL-gpu && scripts/xt core libs/Accel/demos/threshold.xtl)        # Level 1
just xtl ../../X_eTaL-gpu/libs/Accel/demos/threshold.xtl                       # Levels 2 and 3, and the run on this GPU
just asm accel-threshold                                                       # Level 4a or 4b, whichever GPU this is
just capture-metal doc/evidence/<dir>   # 4b, committed form (Mac)
just capture-amd doc/evidence/<dir>     # 4c, any machine
just capture-cpu doc/evidence/<dir>     # 4d, any machine
cargo run --release -- emit-cuda programs/accel-threshold.xir && bash scripts/capture-cuda.sh <dir>   # nvcc road, needs the toolkit
(cd ../../X_eTaL-gpu && target/release/xetal-gpu kernel libs/Accel/demos/threshold.xtl)               # OpenCL C
```
