# AMD listings for the GPU deep dive (no AMD GPU)

Prepared on the Mac (Apple M1 Max), 2026-10-21, for the blog agent. Mojo
cross-compiled the generated `accel-threshold.mojo` for AMD `gfx1100`
(RDNA3, the Radeon RX 7900 family) and wrote one AMDGCN assembly file per
kernel. No AMD hardware was present and nothing was run; these are
listings only, and the post should say so. The ask was A4 on Arch or M3 on
the Mac, whichever came first; this is the Mac's.

## Text the post can use

Mojo's compiler can target AMD with no AMD GPU in the machine, the same
way nvcc can emit PTX with no NVIDIA card: `mojo build
--target-accelerator=gfx1100 --emit asm` on the M1 Max wrote the kernel as
AMDGCN assembly for `amdgpu11.00-amd-amdhsa-unknown-gfx1100`, code object
version 6. The same `stage0` kernel that became PTX on the RTX 5060 Ti
and AIR on the M1 Max becomes RDNA3 vector instructions here: the loads
are `global_load_b32`, the arithmetic is `v_mul_f32` by 0.25,
`v_add_f32` of -1.0 and -4.0, `v_cmp_lt_f32` against 0.5 with
`v_cndmask_b32` selecting 1.0 or 0.0, two `v_max_f32`, and five
`global_store_b32`. What the AMD back-end spends most of its instructions
on is the integer modulo: RDNA3 has no single instruction to convert a
float to a 64-bit integer or back, so the `cvt.rzi.s64.f32` that was one
PTX line becomes a `v_trunc_f32`, a multiply by 2^-32, a `v_floor_f32`, a
`v_fma_f32` with -2^32 and two `v_cvt_u32_f32`, and the conversion back
becomes `v_cls_i32`, a shift, `v_cvt_f32_i32` and `v_ldexp_f32`. Same
program, same answer by construction, a different amount of machine code
for the same line of X_eTaL.

## Evidence to link from the draft

All paths are relative to this document. Everything is text.

| Artifact | What it establishes |
| --- | --- |
| [Stage 0 AMDGCN](evidence/amd-gfx1100-listings-20261021/accel-threshold-stage0.gfx1100.amdgcn) | The kernel for gfx1100, with its `.amdhsa_kernel` descriptor and the `amdhsa.kernels` metadata (argument layout, register counts) |
| [Trace kernel AMDGCN](evidence/amd-gfx1100-listings-20261021/accel-threshold-trace.gfx1100.amdgcn) | The provenance kernel for the same target |
| [Generated Mojo](evidence/amd-gfx1100-listings-20261021/accel-threshold.mojo) | The emitter's source; identical to the CUDA and Metal handoffs' copies |
| [Build commands](evidence/amd-gfx1100-listings-20261021/build.log) | Exact commands and paths; the `--target-accelerator=gfx1100` build succeeded with no AMD device |
| [Environment](evidence/amd-gfx1100-listings-20261021/environment.log) | Apple M1 Max, Mojo 1.2.0.dev2026101305, no AMD GPU |
| [Original XIR](../programs/accel-threshold.xir) | Lowering provenance: X_eTaL-gpu `38bae5c` |

The fork's compilation-targets notes marked AMD side files as untested.
Record: with this nightly, `--target-accelerator=gfx1100 --emit asm`
works on macOS and writes `<out>_<kernel>.amdgcn` beside the host `.s`.
The target can also be spelled `amdgpu:gfx1100`; the bare architecture
name is what this capture used.

## Reading the AMDGCN

The names below refer to `accel-threshold-stage0.gfx1100.amdgcn`.
`v` registers are per-lane (one per work-item), `s` registers are shared
by the wavefront.

| XIR value / purpose | AMDGCN evidence |
| --- | --- |
| Kernel arguments | `s_load_b32 s3, s[0:1], 0x4c` and `0x38` (dispatch packet fields), `s_load_b256 s[4:11], s[0:1], 0x0` and `0x20` (the seven buffer pointers) |
| Element index | `v_mad_u64_u32 v[2:3], null, s3, s15, v[0:1]`: workgroup id times workgroup size plus lane id, as a 64-bit value |
| Bounds check | `v_cmp_gt_i64_e32 vcc_lo, s[2:3], v[2:3]`, then `s_and_saveexec_b32` and `s_cbranch_execz .LBB0_2`: lanes past `n` are masked off and the wave skips to `s_endpgm` |
| `%l`, `%l_2` loads | `global_load_b32 v4` and `global_load_b32 v8`, addresses formed by `v_lshlrev_b64 ... 2` and 64-bit `v_add_co_u32`/`v_add_co_ci_u32` |
| `%div`, `%sub` | `v_mul_f32_e32 v8, 0x3e800000, v8` (times 0.25) and `v_add_f32_e32 v12, -1.0, v8` |
| `%gt`, `%f` | `v_cmp_lt_f32_e32 vcc_lo, 0.5, v12` and `v_cndmask_b32_e64 v14, 0, 1.0, vcc_lo` |
| `%mul` | `v_mul_f32_e32 v13, v12, v14` |
| `%max` | `v_max_f32_e32 v14, 0, v12` |
| `%sub_2`, `%max_2` | `v_add_f32_e32 v10, -4.0, v4` and `v_max_f32_e32 v15, 0, v10` |
| `%mod`, float to i64 | `v_trunc_f32_e32 v2, v10`, `v_mul_f32_e64 v3, 0x2f800000, |v2|` (times 2^-32), `v_floor_f32`, `v_fma_f32 v4, 0xcf800000, v3, |v2|` (low word), two `v_cvt_u32_f32`, then `v_xor_b32`/`v_sub_co_u32` to restore the sign |
| `%mod`, floored remainder by 2 | `v_lshrrev_b32 v2, 31, v5` (sign bit), add, `v_and_b32 v2, -2, v2`, subtract: the truncating remainder; `v_cmp_gt_i32 s2, 0, v5` and `v_cmp_ne_u64 vcc_lo, 0, v[2:3]` with `s_and_b32`, then `v_cndmask_b32_e64 v4, 0, 2, s2` adds 2 when negative and nonzero |
| `%mod`, i64 to float | `v_cls_i32_e32 v5, v3` (leading sign bits), `v_min_u32`, `v_lshlrev_b64`, `v_or_b32`, `v_cvt_f32_i32_e32 v11, v11`, `v_ldexp_f32 v11, v11, v13` |
| `%mul_2` | `v_mul_f32_e32 v10, v10, v11` |
| Five outputs | Five `global_store_b32`, in XIR output order |

The `s_delay_alu` and `s_waitcnt` lines are RDNA3 scheduling hints and
memory fences, not arithmetic. Hex constants are IEEE binary32 bit
patterns: `3e800000` is 0.25, `2f800000` is 2^-32, `cf800000` is -2^32;
`-1.0`, `-4.0`, `0.5` and `1.0` are inline constants the encoding allows.

The descriptor at the end of the file (`.amdhsa_kernel`) records what a
launch would need: kernel argument bytes, the SGPR and VGPR counts, and
the wavefront size (`.amdhsa_wavefront_size32 1`, RDNA3's 32-wide waves,
against the 32-thread warps of the NVIDIA listing and the 32-wide SIMD
groups of Apple's).

## Reproduction

From `rust-demo`, after `just setup`, on any machine with the pinned
nightly, AMD GPU or not:

```sh
scripts/capture-amd.sh doc/evidence/amd-gfx1100-listings-20261021          # gfx1100
scripts/capture-amd.sh work/amd-gfx942 gfx942                              # MI300, if wanted
```

The script records the environment, emits the Mojo, cross-compiles with
`--target-accelerator=ARCH --emit asm`, and copies the two kernel side
files. A failed compile stops it.

## What this does not establish

Nothing ran. There is no AMD output, no check against `.expect`, and no
claim that the code object loads on a real gfx1100 or that the driver
accepts code object version 6. The HIP route (a XIR to HIP emitter,
`hipcc --offload-arch=gfx1100 -S`, and its disassembly) is the Arch
agent's A1 to A3 and is not here; when it lands, this listing is the
Mojo half of that comparison, as the Metal and CUDA handoffs compared
Mojo's PTX with nvcc's. The comparison should allow for the fact that
hipcc and Mojo share LLVM's AMDGPU back-end, so the vector arithmetic
should match closely and the differences will be in argument loading and
the integer-conversion expansions.
