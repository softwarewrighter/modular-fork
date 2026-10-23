# Mojo-authored activation kernel on Adreno 702

The kernel in `mojo/activation_gpu.mojo` now executes on the UNO Q's
physical Qualcomm FD702 through OpenCL IL. It is compiled by Mojo to LLVM
IR, narrowly retargeted, then compiled by LLVM's SPIR-V backend. This path
does not generate OpenCL C and does not use X_eTaL's emitter to implement
the kernel. The same ordinary Mojo source passed on the RTX 5060 Ti too.

## Run it now

From the Arch host:

```sh
ssh -p 2222 arduino@localhost 'cd adreno-poc/work/mojo-spirv && bash scripts/demo-mojo-spirv.sh'
```

The script checks the eight-element fixture against Mojo's own CPU
reference and the first three X_eTaL evaluator baseline lines. It also
checks partial workgroups, output corruption and invalid-IL propagation.

| Test | Result |
| --- | --- |
| Ordinary Mojo GPU source on RTX 5060 Ti | 24 of 24 reference outputs agree |
| Retargeted Mojo kernel on FD702 | 24 of 24 fixture outputs agree with both oracles |
| n=1, n=65, n=129 | All 3, 195, 387 values checked by Mojo and C launcher |
| Corrupt final output | Rejected at element 23 |
| Invalid SPIR-V header | Rejected and negative bridge status propagated |
| Diagnostic native-shader replay | Same 24 baseline values agree |

Eight values are the host input vector passed through for display; sixteen
are GPU-computed threshold/ReLU outputs. Counts above eight are checked
against the Mojo reference, not separately generated X_eTaL baselines.

## The exact compilation path

1. The pinned Mojo 1.2.0.dev2026101305 compiles `activation_gpu.mojo` for
   `nvidia:120`, emitting a separate kernel NVPTX LLVM module.
2. `scripts/nvptx-to-spirv.py` accepts only the audited scalar kernel
   signature/instructions. It changes the triple/data layout, kernel
   calling convention and three global pointer address spaces. NVVM block
   index/size/thread index become OpenCL group/local-size/local-ID builtins,
   with explicit i64-to-i32 truncation preserving the original value widths.
3. LLVM 23 assembles the rewritten IR. `llc` uses
   `-mtriple=spirv64v1.0-unknown-unknown -filetype=obj`. The explicit version
   matters: generic spirv64 emitted SPIR-V 1.4, which the OpenCL 2.1
   validation environment rejects. The final SPIR-V 1.0 passes
   `spirv-val --target-env opencl2.1`.
4. A Cortex-A53 Mojo host export supplies the input/reference arrays and
   calls `adreno_run_spirv_v1` with the module bytes. A C launcher provides
   storage/file loading, avoiding the incompatible standard Mojo runtime.
5. The Rust bridge selects a unique physical Qualcomm FD702, uses
   `clCreateProgramWithIL`, builds the program, sets three buffers, Float
   threshold 0.5 and Int32 count, and dispatches local=64 with a rounded-up
   global size. Output buffers start as NaN. All errors propagate.

The backend's `OpSource OpenCL_CPP` annotation describes its emitted
environment; it is not evidence that an OpenCL C++ source file was used.
The input was the captured Mojo-generated LLVM module, and the build
script never invokes an OpenCL source emitter for this path.

The retargeter refuses unknown NVVM calls, libdevice calls, shared address
spaces, barriers, atomics, allocations, unsupported attributes and unknown
metadata. Golden-file tests cover the committed Mac NVPTX fixture; mutation
tests cover rejection. LLVM additionally verifies the rewritten IR and
SPIR-V. This is an intentionally limited retargeter, not a CUDA translator.

## Native Adreno comparison

The diagnostic run disables Mesa shader caching and enables NIR/disassembly
logging. [Full compiler trace](evidence/unoq-mojo-spirv-20261023/debug/mesa-debug.log),
[native code](evidence/unoq-mojo-spirv-20261023/debug/native.disasm).

| Operation | Earlier generated OpenCL C path | Mojo-authored SPIR-V path |
| --- | --- | --- |
| Compare against threshold | `cmps.f.lt hr2.z, (0.5), r1.x` | `cmps.f.lt hr5.z, c9.z, r1.z` |
| Convert mask to Float | comparison followed by `cov.u16f32` | `cov.u16f32 (even)r0.y, hr5.z` |
| Apply threshold | `mul.f r1.w, r1.x, r1.w` | `mul.f r0.y, r1.z, r0.y` |
| ReLU | `max.f r1.x, r1.x, (0.0)` | `max.f r1.z, r1.z, (0.0)` |
| Write results | two `stg.u32` stores | two `stg.u32` stores |
| Driver code-size report | 224 and 192 dwords, two variants | 224 dwords, one captured variant |

Both reach the same core compare/convert/multiply/maximum/store operations.
They are not byte-identical: registers differ and Mojo's threshold is a
kernel argument (`c9.z`) while the C path bakes in literal 0.5. Variant and
launch differences also limit size comparisons. No speedup is claimed.
The diagnostic disassembly describes the emitted shader, not a GPU-memory
instruction-buffer readback or a per-dispatch variant trace.

## Rebuild and deploy

The existing local Rust target, source clones and pinned Mojo environment
from step 005 are reused. LLVM/LLVM libs, spirv-tools and the ARM64 GCC
cross toolchain are installed Arch packages; versions are recorded in
`environment.log`. No packages or compiler were installed on the board.

```sh
cd adreno-poc
bash scripts/build-mojo-spirv.sh
scp -P 2222 work/mojo-spirv-bundle.tar.gz arduino@localhost:adreno-poc/work/
ssh -p 2222 arduino@localhost 'mkdir -p adreno-poc/work/mojo-spirv && tar --warning=no-timestamp -xzf adreno-poc/work/mojo-spirv-bundle.tar.gz -C adreno-poc/work/mojo-spirv'
```

The reproducible build includes LLVM assembly, SPIR-V validation and the
cross-link step. Use the demo command above after deployment. The binary
module and executables remain under ignored `work/`, including the
negative-test module. Only text disassembly/IR/logs are committed.

Evidence is in `docs/evidence/unoq-mojo-spirv-20261023/`: original NVPTX
LLVM IR, rewritten LLVM IR, SPIR-V disassembly, validation, CUDA run,
board run, negative tests, partial-group checks, NIR/native disassembly,
tool versions and hashes. Board timestamps remain inaccurate; the host
collection time is recorded separately.

## What this does not establish

The kernel is authored in ordinary Mojo and compiled by Mojo, but its
whole `DeviceContext` host application is not natively supported on
Adreno. The host still uses the C ABI bridge. This proves one scalar,
one-dimensional kernel family, without barriers, shared memory, atomics,
libdevice math, large workloads or general pointer/calling conventions.
It does not fix the standard ARM64 Mojo runtime's earlier SIGILL or add a
native SPIR-V backend to Mojo's closed compiler. Those remain separate
work. The handoff's step 014 was executed out of order; Vulkan step 006
remains pending.
