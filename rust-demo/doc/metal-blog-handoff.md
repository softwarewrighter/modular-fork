# Apple silicon evidence for the GPU deep dive

Prepared on the Mac (Apple M1 Max), 2026-10-21, for the blog agent. The
lowered `accel-threshold.xir` was emitted as Mojo, built for Metal, run on
the M1 Max, and checked against the Rust reference and X_eTaL's evaluator
output. Mojo's Metal AIR for the kernel is committed twice: as the side
file `mojo build --emit asm` writes, and as the `DUMP_GPU_ASM` dump
printed from inside the run. The two kernel bodies are identical.

## Text the post can use

On Apple silicon Mojo does not emit PTX. Its compiler lowers the same
`stage0` kernel to AIR, Apple's intermediate representation for Metal,
which is LLVM IR with Apple's calling convention and intrinsics. The
listing says `target triple = "air64-apple-macosx26.0.0"` and the
module's metadata names Metal language version 3.2 and AIR version 2.7.
Thread position comes in as function arguments
(`%threadgroup_position_in_grid`, `%thread_position_in_threadgroup`,
`%threads_per_threadgroup`) rather than special registers, the maxima
are calls to `@air.fmax.f32`, and the int conversions are
`@air.convert.s.i64.f.f32` and back. Apple's Metal compiler, inside the
driver, turns that AIR into the GPU's native code when the function is
first loaded; that final step has no public listing. The run on the M1
Max produced all five of X_eTaL's expected outputs exactly.

The source operations are still readable in the AIR: `fdiv` by 4.0,
`fsub` 1.0, `fcmp ogt` 0.5, a `select` of 1.0 or 0.0 for the cast,
`fmul`, two `fmax`, and the floored modulo as `sdiv`, `mul`, `sub` and a
sign fix. Unlike nvcc's default PTX, the divide and subtract are not fused
here: the `fsub` carries a `contract` flag, so Apple's back-end is
allowed to fuse them later, but the AIR itself keeps them separate.

## Evidence to link from the draft

All paths are relative to this document. Everything is text.

| Artifact | What it establishes |
| --- | --- |
| [Generated Mojo](evidence/m1max-metal-20261021/accel-threshold.mojo) | The emitter's source for the XIR; identical to the CUDA handoff's copy (same emitter, same XIR) |
| [Stage 0 AIR, side file](evidence/m1max-metal-20261021/accel-threshold-stage0.air.ll) | `mojo build --target-accelerator=metal:4 --emit asm`: the kernel as AIR, with its `!air.*` metadata |
| [Trace kernel AIR, side file](evidence/m1max-metal-20261021/accel-threshold-trace.air.ll) | The provenance kernel (which threadgroup and thread computed each element) |
| [Run on the M1 Max](evidence/m1max-metal-20261021/metal.log) | `xir-mojo run --dump-asm`: device, launch, the AIR dump, five outputs against both oracles, RESULT line |
| [Environment](evidence/m1max-metal-20261021/environment.log) | macOS 26.5, Xcode 26.6, Apple M1 Max (32 GPU cores, Metal 4), Mojo 1.2.0.dev2026101305, Rust 1.96 |
| [Build commands](evidence/m1max-metal-20261021/build.log) | Exact commands and paths |
| [Original XIR](../programs/accel-threshold.xir) | Lowering provenance: X_eTaL-gpu `38bae5c` |
| [Expected output](../programs/accel-threshold.expect) | X_eTaL evaluator's independent oracle |

The side file is what the compiler writes when asked for assembly with a
Metal target: for Metal, "assembly" is the AIR module as LLVM IR text, one
file per kernel, beside the host `.s`. The dump in `metal.log` is the same
module printed at run time by the `DeviceFunction` constructor when the
library was built with `-D DUMP_GPU_ASM=true`.

## Reading the AIR

The names below refer to `accel-threshold-stage0.air.ll`.

| XIR value / purpose | AIR evidence |
| --- | --- |
| Element index | `extractelement` of `%threadgroup_position_in_grid`, `%threads_per_threadgroup` and `%thread_position_in_threadgroup`, then `mul` and `add` into `%31` |
| Bounds check | `icmp slt i64 %31, %53` where `%53` is the `n` argument loaded from the constant address space (`addrspace(2)`), then `br` |
| `%l`, `%l_2` loads | Two `load float, ptr addrspace(1)`, `%57` and `%59` |
| `%div`, `%sub` | `fdiv float %57, 4.0` and `fsub contract float %60, 1.0` |
| `%gt`, `%f` | `fcmp ogt float %61, 0.5` and `select i1 %62, float 1.0, float 0.0` |
| `%mul` | `fmul contract float %61, %63` |
| `%max` | `call float @air.fmax.f32(float %61, float 0.0)` |
| `%sub_2`, `%max_2` | `fsub contract float %59, 4.0` and the second `@air.fmax.f32` |
| `%mod` | `@air.convert.s.i64.f.f32`, then `sdiv`/`mul`/`sub` for the C-style remainder, `icmp slt` and `icmp ne` with `and` and `select` adding 2 when the operand is negative and the remainder nonzero, then `@air.convert.f.f32.s.i64` back |
| `%mul_2` | `fmul contract float %66, %77` |
| Five outputs | Five `store float, ptr addrspace(1)` in XIR output order |

The floored-modulo fix is the same idea as nvcc's and Mojo's PTX, spelled
in generic LLVM IR rather than PTX: `-3 mod 2` is `1`, so the last output
row starts with `-3`.

Buffer metadata: `!air.buffer` entries mark arguments 0 and 1 as
`air.read` and arguments 2 to 6 as `air.write` or `air.read_write`, all in
address space 1 (device memory); argument 7, the length, is in address
space 2 (constant).

## Observed output

```text
device: api=metal  name=Apple M1 Max
launch: 1 block(s) of 256 threads for 8 element(s)
  gpu:       -0.75 -0.5 -0.25 0.0 0.25 0.5 0.75 1.0
  gpu:       -0.0 -0.0 -0.0 0.0 0.0 0.0 0.75 1.0
  gpu:       0.0 0.0 0.0 0.0 0.25 0.5 0.75 1.0
  gpu:       0 0 0 0 1 2 3 4
  gpu:       -3 0 -1 0 1 0 3 0
RESULT: 5 of 5 outputs agree with the Rust reference; 5 of 5 with the X_eTaL evaluator (programs/accel-threshold.expect)
```

Every output agrees exactly with both oracles (the log prints each
`gpu:` row beside its `xetal:` row). The library was built once with the
dump switched on; `xir_run` took about 5 ms including the first-use
kernel compile, uploads and downloads. No speed claim: eight elements.

## Reproduction on the Mac

From `rust-demo`, after `just setup`:

```sh
scripts/capture-metal.sh doc/evidence/m1max-metal-20261021
```

The script records the environment, emits the Mojo, writes the AIR side
files with `--target-accelerator=metal:4 --emit asm`, then runs the
program on the GPU with `--dump-asm` and checks it against both oracles.
A failed build, a device failure or a disagreeing output stops it.
`just asm accel-threshold` prints the same run and dump without saving.

## What this does not establish

Metal's final compilation step from AIR to the M1 Max's native
instruction set is not shown; Apple does not expose it. There is no
AMD, CUDA or CPU run here (see `cuda-blog-handoff.md` for the CUDA
evidence; the AMD listings and the CPU runs have their own captures).
The `metal:4` in the target name selects Metal 4 as the API level the
side files are built against; the run itself used whatever Metal the
installed driver provides, which `environment.log` records as Metal 4.
