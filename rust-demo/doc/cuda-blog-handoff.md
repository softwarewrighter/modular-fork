# CUDA evidence for the GPU deep dive

Prepared on Arch, 2026-10-21, for the Mac blog agent. The lowered
`accel-threshold.xir` now has a generated CUDA C++ version, nvcc PTX,
native NVIDIA assembly, and a successful RTX 5060 Ti run checked against
the existing X_eTaL evaluator output. The generated Mojo is saved alongside
it so the post can link to a source listing outside ignored `work/`.

## Text the post can use

The same threshold XIR can also be emitted as CUDA C++. Rust writes a
kernel with one thread per element, two input buffers and five output
buffers. NVIDIA's `nvcc` compiles it into PTX; `ptxas`, invoked by nvcc
when building the native binary, assembles GPU machine code. On the
RTX 5060 Ti, this CUDA version produces all five of X_eTaL's expected
outputs with zero mismatched elements.

The CUDA source still says divide by four, subtract one, compare, cast
the Boolean mask to a number, multiply, take two maxima, and compute
floored modulo two. The compiler changes their spelling. With default
`nvcc -O3` settings, divide by four and subtract one become one
`fma.rn.f32` using 0.25 and -1. With `--fmad=false`, they become separate
multiply and add instructions. Both listings are saved. This is why
counting source operations and counting PTX instructions give different
answers.

## Evidence to link from the draft

All paths below are relative to this document. The files contain text,
so the Mac agent can inspect them without a CUDA installation.

| Artifact | What it establishes |
| --- | --- |
| [Generated CUDA C++](evidence/rtx5060-cuda-20261021/accel-threshold.cu) | Full kernel and host allocation, copies, launch, checks and cleanup |
| [Generated Mojo](evidence/rtx5060-cuda-20261021/accel-threshold.mojo) | Existing Mojo emitter's source for the same XIR; generation only in this capture |
| [Default nvcc PTX](evidence/rtx5060-cuda-20261021/accel-threshold.ptx) | PTX 9.4, target `sm_120a`, optimized with FMA contraction |
| [PTX without FMA contraction](evidence/rtx5060-cuda-20261021/accel-threshold-no-fma.ptx) | Separate multiply and add, useful beside the earlier Mojo PTX |
| [Native NVIDIA assembly](evidence/rtx5060-cuda-20261021/accel-threshold.sass) | `nvdisasm` output from nvcc's `sm_120a` cubin |
| [GPU output](evidence/rtx5060-cuda-20261021/cuda.log) | Actual CUDA execution, all five outputs, zero mismatches |
| [CPU expression check](evidence/rtx5060-cuda-20261021/cpu.log) | Same generated expressions compiled as host C++; not a Mojo CPU run |
| [Environment](evidence/rtx5060-cuda-20261021/environment.log) | nvcc 13.4.92, driver 615.78.08, RTX 5060 Ti, Mojo nightly version |
| [Build commands](evidence/rtx5060-cuda-20261021/build.log) | Exact compiler flags and file paths |
| [Original XIR](../programs/accel-threshold.xir) | Lowering provenance: X_eTaL-gpu `38bae5c` |
| [Expected output](../programs/accel-threshold.expect) | X_eTaL evaluator's independent oracle |

The environment log's Git hash identifies the base checkout. The emitter
and capture script were working-tree additions during this capture.

## Reading the default nvcc PTX

The registers below refer specifically to `accel-threshold.ptx`, not the
Mojo listing or the no-FMA listing.

| XIR value / purpose | PTX evidence |
| --- | --- |
| Element index | `%ctaid.x`, `%ntid.x`, `%tid.x`, then `mad.lo.s32 %r1` |
| Bounds check | `setp.gt.s32 %p1, %r1, 7` and predicated branch: only indices 0–7 proceed |
| `%l` load | First `ld.global.b32`, into `%r5` |
| `%div`, `%sub` | `fma.rn.f32 %r6, %r5, 0f3E800000, 0fBF800000`: `l * 0.25 - 1` |
| `%gt`, `%f` | `setp.gt.f32` against `0f3F000000` (0.5); `selp.f32` picks 1.0 or 0.0 |
| `%mul` | `mul.f32 %r8, %r6, %r7`: multiply by the numeric mask |
| `%l_2`, `%sub_2` | Second global load into `%r9`; `add.f32` with `0fC0800000` (-4.0) |
| `%max`, `%max_2` | Two `max.f32` instructions against `0f00000000` (0.0) |
| `%mod` | Conversion to signed 64-bit integer, shift/add/and/subtract and predicate/select correction, then conversion back to float |
| `%mul_2` | `mul.f32 %r14, %r10, %r13` |
| Five outputs | Five `st.global.b32`, in XIR output order |

The integer correction matters: C++ `%` truncates toward zero. The
emitter adds the divisor when the remainder is nonzero and the operands
have different signs. Thus `-3 mod 2` is 1, and the final product is -3.
It also handles a negative divisor; the host test exercises both signs.
Integer values retain this demo's existing f32 storage convention and
2^24 range limit. This is not a general i64 implementation.

Hex constants, interpreted as IEEE 754 binary32 bit patterns:
`3E800000` = 0.25, `BF800000` = -1.0, `3F000000` = 0.5,
`3F800000` = 1.0, `00000000` = 0.0, `C0800000` = -4.0.

## Observed output

```text
output %sub: -0.75 -0.5 -0.25 0 0.25 0.5 0.75 1
output %mul: -0 -0 -0 0 0 0 0.75 1
output %max: 0 0 0 0 0.25 0.5 0.75 1
output %max_2: 0 0 0 0 1 2 3 4
output %mul_2: -3 -0 -1 0 1 0 3 0
backend: CUDA
RESULT: 0 mismatched elements
```

Integer and Boolean outputs are checked exactly; finite float outputs
use relative 1e-4 or absolute 1e-6 tolerance. Positive and negative zero
compare equal. These threshold float results are exactly representable;
the displayed values agree with the existing oracle. No speed claim is
made: this is an eight-element correctness example, not a benchmark.

## Reproduction on the NVIDIA machine

From the repository root:

```sh
cargo test --manifest-path rust-demo/Cargo.toml --test cuda --test programs
bash rust-demo/scripts/capture-cuda.sh rust-demo/work/cuda-evidence
```

The script generates both source listings, compiles both PTX variants,
builds a cubin and disassembles it, builds the CUDA executable and the
CPU expression check, and runs both. A failed compilation, CUDA call or
output check stops the script. In a restricted agent sandbox, GPU device
access may require running the capture outside the sandbox. The initial
`nvidia-smi` failure here was that restriction; the driver worked normally
outside it.

To emit another elementwise program:

```sh
cargo run --manifest-path rust-demo/Cargo.toml -- emit-cuda rust-demo/programs/threshold.xir
```

`--inputs FILE`, `--expect FILE` and `--work DIR` are supported. The
emitter embeds inputs and expected outputs into a standalone executable.
When an `.expect` exists, it first checks the Rust reference against it
and uses that oracle in the executable. Otherwise it uses the Rust
reference. Reductions are explicitly refused in this CUDA comparison
backend; softmax remains available through the existing Mojo backend.

## CUDA toolchain wording

CUDA kernels here use CUDA C++, often informally called CUDA C. Building
requires the CUDA Toolkit and a supported host C++ compiler. PTX emission
and cubin assembly can be done offline without an NVIDIA GPU. A cubin
contains native GPU machine code; PTX is a virtual instruction set.
The CUDA runtime selects a suitable image at execution; a PTX image can
be compiled by the driver at runtime when needed. This capture explicitly
builds an `sm_120a` native executable and separately saves PTX for reading.

Running requires a compatible NVIDIA GPU and driver, plus any runtime
libraries linked dynamically by the application. nvcc defaults to static
CUDA runtime linking, so installing the whole Toolkit is not inherently
required on the destination machine. Building and running have different
requirements. See NVIDIA's [nvcc documentation](https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html),
especially Compilation Phases, CUDA Compilation Trajectory, `--fmad`,
and `--cudart`.

## Remaining matrix items

This handoff completes the CUDA threshold comparison and preserves the
generated threshold Mojo source. It does not establish Apple's AIR,
Metal's final compilation step, AMD/HIP output, NVIDIA OpenCL's returned
program binary, or Mojo CPU runs and arm64/x86-64 assembly. Those need
their own evidence. No AMD execution is claimed.
