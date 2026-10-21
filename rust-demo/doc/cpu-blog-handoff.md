# CPU evidence for the GPU deep dive (arm64, the Mac)

Prepared on the Mac (Apple M1 Max, 10 CPU cores), 2026-10-21, for the
blog agent. The same generated `accel-threshold.mojo` that ran on Metal,
CUDA and was cross-compiled for AMD was built with `-D XIR_CPU=true` and
run on the CPU through Mojo, checked against the Rust reference and
X_eTaL's evaluator output. The kernel body's arm64 assembly is committed.
This is the Mac half of the ask (M2); the Arch agent's A6 is the x86-64
half, and the same `--cpu` flag does it there.

## Text the post can use

The generated Mojo has one more build. With `-D XIR_CPU=true` the host
code opens a CPU `DeviceContext` instead of the GPU's, creates the same
buffers and copies, and hands each fused stage to the context as a
parallel range over the elements (`enqueue_cpu_range`) instead of a grid
of threads (`enqueue_function`). The kernel's body is the same function,
`stage0_at(i, ...)`, called once per element either way. Nothing is
emitted twice: the Rust emitter writes both paths into one file and a
`comptime if XIR_CPU` picks one at compile time. On the M1 Max the CPU
build produced all five of X_eTaL's expected outputs exactly, in under a
millisecond including the copies.

The arm64 listing shows the body once more in a fourth instruction set.
Like nvcc with its default flags, LLVM's AArch64 back-end fused the
divide-by-four and subtract-one into one `fmadd` with 0.25 and -1.0.
The comparison is `fcmp` and `fcsel` selecting 1.0 or 0.0, the maxima are
`fmaxnm`, and the floored modulo is `fcvtzs` to a 64-bit integer, an
`and` with 1 for the remainder, `cneg` and `ccmp` and `csel` for the
sign fix, and `scvtf` back. Where Mojo's PTX spent about ten instructions on the
modulo and RDNA3 about thirty, AArch64 spends nine: it has 64-bit
integer conversions and conditional instructions in hardware.

## Evidence to link from the draft

All paths are relative to this document. Everything is text.

| Artifact | What it establishes |
| --- | --- |
| [Generated Mojo](evidence/m1max-cpu-20261021/accel-threshold.mojo) | One file, both paths: `xir_context()`, `stage0_at`, the `comptime if XIR_CPU` range or launch |
| [Host assembly, the closures](evidence/m1max-cpu-20261021/accel-threshold-xir_run-closures.s) | `mojo build -D XIR_CPU=true --emit asm`: the closures `xir_run` hands to the CPU context; `_xir_run_async_closure_2_resume` is the kernel body |
| [Run on the CPU](evidence/m1max-cpu-20261021/cpu.log) | `xir-mojo run --cpu`: `device: api=cpu`, five outputs against both oracles, RESULT line |
| [Environment](evidence/m1max-cpu-20261021/environment.log) | Apple M1 Max, 10 logical CPUs, Mojo 1.2.0.dev2026101305, Rust 1.96 |
| [Build commands](evidence/m1max-cpu-20261021/build.log) | Exact commands and paths |
| [Original XIR](../programs/accel-threshold.xir) | Lowering provenance: X_eTaL-gpu `38bae5c` |
| [Expected output](../programs/accel-threshold.expect) | X_eTaL evaluator's independent oracle |

## Reading the arm64

The body is `_xir_run_async_closure_2_resume` in the closures file: the
function the CPU context's thread pool calls with the element index.
Its first lines load the seven buffer pointers out of the closure's
capture record (`x0`); `x15` is the element index.

| XIR value / purpose | AArch64 evidence |
| --- | --- |
| `%l`, `%l_2` loads | `ldr s0, [x8, x15, lsl #2]` and `ldr s1, [x9, x15, lsl #2]`: base plus 4 times the index |
| `%div`, `%sub` | `fmov s2, #0.25`, `fmov s3, #-1.0`, `fmadd s0, s0, s2, s3`: fused, as nvcc's default PTX |
| `%gt`, `%f` | `fcmp s0, s2` against 0.5; `fcsel s3, s3, s2, gt` picks 1.0 or 0.0 (`v2` was zeroed by `movi.2d`) |
| `%mul` | `fmul s3, s0, s3` |
| `%max` | `fmaxnm s4, s0, s2` with 0.0 |
| `%sub_2`, `%max_2` | `fmov s5, #-4.0`, `fadd s1, s1, s5`, `fmaxnm s2, s1, s2` |
| `%mod` | `fcvtzs x9, s1` (to i64), `and x14, x9, #0x1` and `cneg x14, x14, mi` (the truncating remainder), `cmp`, `ccmp`, `csel x9, x9, xzr, mi` adding 2 when negative and nonzero, `add`, `scvtf s5, x9` (back to f32) |
| `%mul_2` | `fmul s0, s1, s5` |
| Five outputs | Five `str s?, [x??, x15, lsl #2]` in XIR output order |
| Return | `ldp x1, x0, [x0, #16]` and `br x1`: the closure resumes the context's continuation rather than returning |

`fmaxnm` is the NaN-propagating maximum AArch64 uses for `max`; with
finite inputs it is the same as `fmax`.

## Observed output

```text
built: .../libaccel-threshold-cpu.dylib (mojo build --emit shared-lib -D XIR_CPU=true) in 1.0 s
cpu: the same source built with -D XIR_CPU=true; a CPU DeviceContext, each stage a parallel range over the elements (has_accelerator() = true)
device: api=cpu  name=cpu
launch: a parallel range of 8 element(s) on the CPU (no grid)
ran: xir_run in 0.72 ms on the CPU (includes the copies; speed is not the point)
proof: none to read back; on the CPU there is no block or thread, xir_trace returns 3
RESULT: 5 of 5 outputs agree with the Rust reference; 5 of 5 with the X_eTaL evaluator (programs/accel-threshold.expect)
```

Every output agrees exactly with both oracles. `has_accelerator()` is
still true because this Mac has a GPU; the build simply does not use it.
Eight elements; no speed claim.

## Reproduction, on any machine with the pinned nightly

From `rust-demo`, after `just setup`:

```sh
just cpu accel-threshold                      # the run, checked
scripts/capture-cpu.sh doc/evidence/<host>-cpu-<date>   # the committed form
```

The device gate (`just gate`) now runs every program twice, on the GPU
and with `--cpu`; all ten pass both ways on the M1 Max. For the x86-64
half (A6), the same script on Arch writes the x86-64 assembly and the
run; its kernel body will be a `_xir_run_async_closure_N_resume` symbol
as well.

## What this does not establish

The CPU context's parallel range is Mojo's thread pool, not a GPU, and
there is no block or thread provenance to read back (`xir_trace`
returns 3 and the tool says so). The closures file is the part of the
host assembly before `_xir_run` itself; the rest of `xir_run` (buffer
creation, copies, the calls into the runtime) is ordinary host code and
is not included. One observation worth a sentence: on this nightly a
`synchronize()` was needed between the upload and the range; without it
the range read zeros for the first elements. The generated code
synchronizes before every stage in the CPU build.
