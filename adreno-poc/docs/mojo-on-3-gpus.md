# One Mojo activation kernel on three GPUs

The same Mojo-authored threshold/ReLU kernel has now run on Apple M1 Max,
NVIDIA RTX 5060 Ti and Qualcomm Adreno 702. Every platform produced the
expected eight inputs, eight threshold values and eight ReLU values:
**24 of 24 displayed values agreed with the CPU reference**. Sixteen values
are computed by the GPU; eight are the input vector shown for context.

The source is [mojo/activation_gpu.mojo](../mojo/activation_gpu.mojo).
The full program runs normally on Metal and CUDA. On Adreno, its kernel
runs through an experimental LLVM-to-SPIR-V retargeting path and a separate
host wrapper. This does not add native Adreno support to `DeviceContext`.

## What ran

| GPU | Execution path | Verified result | Evidence |
| --- | --- | --- | --- |
| Apple M1 Max | Mojo -> AIR -> Metal | 24/24 reference values | [Metal run](evidence/m1max-mojo-targets-20261023/metal-run.log) |
| NVIDIA RTX 5060 Ti | Mojo -> NVPTX/PTX -> CUDA | 24/24 reference values | [CUDA run](evidence/unoq-mojo-spirv-20261023/rtx5060-run.log) |
| Qualcomm Adreno 702 on UNO Q | Mojo -> NVPTX LLVM IR -> retargeted LLVM IR -> SPIR-V -> rusticl OpenCL IL -> Adreno | 24/24 reference values | [Board run](evidence/unoq-mojo-spirv-20261023/run.log), [output](evidence/unoq-mojo-spirv-20261023/run.out) |

The Mac run was captured in the earlier Mac session. The CUDA and Adreno
runs were verified on the Arch host and connected UNO Q. The compiler was
pinned to Mojo `1.2.0.dev2026101305`. The Adreno driver was Mesa rusticl
`25.2.6-1~bpo13+1`, identifying device `FD702`, vendor `Qualcomm`, type GPU.
LLVM 23 provided the SPIR-V backend.

## The calculation

For each input v, compute:

```text
threshold(v, 0.5) = v * (1.0 if v > 0.5 else 0.0)
relu(v)           = max(v, 0.0)
```

The inputs are `(i + 1) / 4 - 1` for i from zero through seven. All these
values are exactly representable in Float32. In particular, an input equal
to 0.5 is excluded by the strict threshold comparison.

One GPU thread handles one element. A group contains 64 threads, and the
bounds check prevents the extra threads from accessing the eight-element
buffers. Both results are produced by one kernel launch.

## The Mojo source

Below is the whole shared program, exactly as in the linked file. The kernel is the
small `activations` function; `main` supplies the normal Metal/CUDA host
and checks the results against a CPU calculation.

```mojo
# activation_gpu.mojo: threshold and ReLU as an ordinary Mojo GPU
# program, the way it is written for a GPU Mojo supports (Apple
# silicon, NVIDIA, AMD). The same file runs unchanged on the M1 Max
# (Metal) and the RTX 5060 Ti (CUDA): DeviceContext() picks the GPU
# and the compiler emits AIR or PTX for the kernel. Mojo has no
# Adreno target; there the kernel runs through a SPIR-V retarget
# (docs/mojo-on-3-gpus.md).
#
#   mojo run mojo/activation_gpu.mojo

from max.gpu import block_dim, block_idx, thread_idx
from max.gpu.host import DeviceContext

comptime N = 8
comptime TPB = 64
comptime BLOCKS = (N + TPB - 1) // TPB


def activations(
    x: Pointer[Float32, ImmutAnyOrigin],
    threshold: Pointer[Float32, MutAnyOrigin],
    relu: Pointer[Float32, MutAnyOrigin],
    t: Float32,
    n: Int32,
):
    """One thread per element: threshold(x, t) = x * (x > t),
    relu(x) = max(x, 0)."""
    var i = Int(block_idx.x * block_dim.x + thread_idx.x)
    if i < Int(n):
        var v = x[unsafe_offset=i]
        var mask = Float32(1.0) if v > t else Float32(0.0)
        threshold[unsafe_offset=i] = v * mask
        relu[unsafe_offset=i] = max(v, Float32(0.0))


def main() raises:
    var ctx = DeviceContext()
    print("device:", ctx.api(), ctx.name())

    # x = ((range 8) / 4) - 1.0, X_eTaL's range running 1..8
    var h_x = ctx.enqueue_create_host_buffer[DType.float32](N)
    ctx.synchronize()
    for i in range(N):
        h_x[i] = Float32(i + 1) / 4.0 - 1.0

    var d_x = ctx.enqueue_create_buffer[DType.float32](N)
    var d_threshold = ctx.enqueue_create_buffer[DType.float32](N)
    var d_relu = ctx.enqueue_create_buffer[DType.float32](N)
    ctx.enqueue_copy(dst_buf=d_x, src_buf=h_x)

    ctx.enqueue_function[activations](
        d_x, d_threshold, d_relu, Float32(0.5), Int32(N),
        grid_dim=BLOCKS, block_dim=TPB,
    )

    var h_threshold = ctx.enqueue_create_host_buffer[DType.float32](N)
    var h_relu = ctx.enqueue_create_host_buffer[DType.float32](N)
    ctx.enqueue_copy(dst_buf=h_threshold, src_buf=d_threshold)
    ctx.enqueue_copy(dst_buf=h_relu, src_buf=d_relu)
    ctx.synchronize()

    # The first three lines X_eTaL's evaluator prints for threshold.xtl.
    var failures = 0
    for row in range(3):
        var line = String()
        for i in range(N):
            var x = h_x[i]
            var got = x
            var want = x
            if row == 1:
                got = h_threshold[i]
                want = x * (Float32(1.0) if x > 0.5 else Float32(0.0))
            elif row == 2:
                got = h_relu[i]
                want = max(x, Float32(0.0))
            if got != want:
                failures += 1
            line += (" " if i else "") + String(got)
        print(line)
    print(
        "RESULT:", 3 * N - failures, "of", 3 * N,
        "outputs agree with the CPU reference",
    )
```

On the M1 Max, `DeviceContext()` selects Metal. On the RTX card, it selects
CUDA. The host allocates buffers, uploads x, launches `activations`, copies
both results back, and checks each against a CPU calculation. No alternate
Apple or NVIDIA kernel source is needed.

## How the Adreno path works

Mojo's normal GPU context and compiler target list do not provide an
Adreno/OpenCL backend in this pinned build. Asking the compiler directly
for a SPIR-V target failed. We instead used the target-neutral arithmetic
already present in the kernel's NVIDIA LLVM output.

The retargeter, [scripts/nvptx-to-spirv.py](../scripts/nvptx-to-spirv.py),
makes these limited substitutions:

| Mojo's NVPTX LLVM output | OpenCL-compatible form |
| --- | --- |
| NVPTX target and data layout | SPIR-V 64-bit target and data layout |
| `ptx_kernel` function | `spir_kernel` function |
| Generic buffer pointers | Global pointers in address space 1 |
| Block index | `get_group_id(0)` |
| Block size | `get_local_size(0)` |
| Thread index | `get_local_id(0)` |
| NVIDIA target CPU/features | Removed |

The comparisons, select, Float multiplication and maximum remain the
arithmetic emitted by Mojo. The index builtins preserve their original
32-bit values through explicit conversion from the OpenCL builtin results.
The script refuses unsupported calls, shared memory, barriers, atomics,
allocations, attributes and metadata. It is a tested converter for this
small scalar subset, not a general GPU compiler.

LLVM assembles the rewritten module and emits SPIR-V with:

```sh
llc -mtriple=spirv64v1.0-unknown-unknown -filetype=obj activations.bc -o activations.spv
spirv-val --target-env opencl2.1 activations.spv
```

The versioned target matters: the generic target initially emitted SPIR-V
1.4, which that validation environment rejected. Explicit SPIR-V 1.0
validated and ran on the board.

The [Adreno Mojo host](../mojo/activation_spirv_host.mojo) is cross-compiled
on Arch for Cortex-A53. It prepares inputs and a CPU reference, passes the
SPIR-V bytes to a small C ABI bridge, and checks all returned values. Its
key call is:

```mojo
var status = external_call["adreno_run_spirv_v1", Int32](
    il, il_len, inputs, outputs, n, 3 * n
)
```

A [C launcher](../mojo/spirv_launcher.c) reads the module and provides array
storage. The [Rust bridge](../mojo-opencl-bridge/src/spirv.rs) selects the
physical FD702, loads the module with `clCreateProgramWithIL`, builds it,
binds the three buffers and scalar arguments, dispatches groups of 64,
and reads back. It does not compile an OpenCL C replacement for the kernel.

The launcher/export arrangement also avoids the standard ARM64 Mojo runtime.
An ordinary cross-linked hello failed on this board with an illegal
instruction. Its runtime contains LSE atomics absent from the board's CPU
feature list, a likely explanation; the exact faulting instruction was not
identified. The exported Mojo host works without that runtime. No compiler
or new system packages were installed on the UNO Q.

## Results and native code

All three platforms produced these numeric results. Formatting is normalized
here; board output uses `0` and `-0` where the normal Mojo host prints
`0.0` and `-0.0`.

```text
input:     -0.75 -0.5 -0.25 0.0 0.25 0.5 0.75 1.0
threshold: -0.0  -0.0 -0.0  0.0 0.0  0.0 0.75 1.0
relu:       0.0   0.0  0.0  0.0 0.25 0.5 0.75 1.0
```

On Adreno we also checked:

| Additional check | Result |
| --- | --- |
| n=1 | All 3 displayed values checked |
| n=65, spanning two groups | All 195 values checked |
| n=129, spanning three groups | All 387 values checked |
| Deliberately corrupt the final output | Rejected at element 23 |
| Invalid SPIR-V module header | Rejected with an error propagated to the launcher |
| Replay with driver compiler diagnostics | Same reference outputs |

The larger counts use the Mojo CPU reference, and include pass-through input
values. [Test transcript](evidence/unoq-mojo-spirv-20261023/demo.log).
No large-array throughput or speedup measurement is claimed.

The [driver's native Adreno disassembly](evidence/unoq-mojo-spirv-20261023/debug/native.disasm)
contains the expected operations, for example:

```text
cmps.f.lt hr5.z, c9.z, r1.z       ; compare threshold argument with v
cov.u16f32 (even)r0.y, hr5.z      ; convert comparison to Float mask
mul.f r0.y, r1.z, r0.y           ; threshold = v * mask
max.f r1.z, r1.z, (0.0)          ; relu = max(v, 0)
stg.u32 g[r2.y], r0.y, 1         ; store threshold
stg.u32 g[r0.z], r1.z, 1         ; store relu
```

These are excerpts with explanatory annotations; scheduling directives and
intervening instructions are omitted. The driver reported 224 dwords for
this captured variant. This is diagnostic compiler output, not a readback
of GPU instruction memory or a proof of which variant every dispatch chose.

Intermediate artifacts are available for inspection:

- [Original Mojo-generated NVPTX LLVM IR](evidence/unoq-mojo-spirv-20261023/compiler/mojo_activation_gpu_activations_Po6A6AoA6A6A_2d28411a43ede716.nvptx.ll)
- [Retargeted LLVM IR](evidence/unoq-mojo-spirv-20261023/compiler/activations.spirv.ll)
- [Validated SPIR-V disassembly](evidence/unoq-mojo-spirv-20261023/compiler/activations.spvasm)
- [Mesa NIR and native-code trace](evidence/unoq-mojo-spirv-20261023/debug/mesa-debug.log)

## Reproduce the runs

On the M1 Max or RTX 5060 Ti, with the pinned environment providing Mojo
and `max.gpu`, run from `adreno-poc`:

```sh
mojo run mojo/activation_gpu.mojo
```

On this Arch checkout, the existing compiler is also available as
`../rust-demo/.venv/bin/mojo`. Build the Adreno bundle with:

```sh
bash scripts/build-mojo-spirv.sh
```

This requires the prepared local ARM64 Rust target, the existing local
bridge dependency checkout, LLVM with its SPIR-V backend, spirv-tools,
and `aarch64-linux-gnu-gcc`. The script pins the compiler version, validates
the module and builds the host export and launcher. Outputs stay under
ignored `work/` directories.

The bundle is already deployed on the connected board. Rerun it from the
host with:

```sh
ssh -p 2222 arduino@localhost 'cd adreno-poc/work/mojo-spirv && bash scripts/demo-mojo-spirv.sh'
```

To redeploy a rebuilt bundle:

```sh
scp -P 2222 work/mojo-spirv-bundle.tar.gz arduino@localhost:adreno-poc/work/
ssh -p 2222 arduino@localhost 'mkdir -p adreno-poc/work/mojo-spirv && tar --warning=no-timestamp -xzf adreno-poc/work/mojo-spirv-bundle.tar.gz -C adreno-poc/work/mojo-spirv'
```

## What an upstream Modular contribution might require

This section scopes possible future contributions. No upstream issue or
pull request has been prepared or opened for this report. The working
experiment is evidence for a discussion, not a ready-made support proposal.

The [repository contributor guide](../../CONTRIBUTING.md) asks for a
maintainer-approved issue before substantial changes, and new examples are
reviewed case by case under the [examples guidance](../../max/examples/README.md#contributing).
The appropriate first discussion would ask whether maintainers want a
small portable-kernel example, an experimental external-backend example,
or native OpenCL/SPIR-V support. Those have very different scopes.

| Part of this proof of concept | Plausible upstream contribution | What it would need first |
| --- | --- | --- |
| Shared activation kernel and normal host | A small example under an accepted examples directory | An agreed destination, current supported API usage, existing example/build conventions and tests on supported GPUs |
| Result checking and bounds handling | Focused regression tests | Tests that fail on wrong outputs and cover exact threshold ties, partial groups, signed zero and the agreed nonfinite-value behavior |
| LLVM retargeter | Experimental tooling only if maintainers want to support that extension point | A maintained IR contract, supported compiler versions, structural verification, explicit supported constructs, stable kernel discovery and fail-closed tests |
| OpenCL IL bridge and ARM64 launcher | An optional external-backend/interoperability example | Independent packaging, no development-machine paths or sibling-checkout assumptions, dependency/license review, clean error handling and reproducible target builds |
| Native Adreno `DeviceContext` path | A separate backend design and implementation effort | Modular-owned compiler/runtime changes, target and device discovery, memory/launch semantics, ABI agreement and sustained hardware coverage |
| ARM64 runtime compatibility failure | A separate minimal bug report or fix, if accepted | Exact faulting PC/instruction, runtime build and CPU feature requirements, and a supported-CPU expectation agreed with maintainers |

Before a contribution makes sense, the following gaps need resolution:

1. **Choose a small supported scope with maintainers.** The example might be
   useful without promising Adreno support. A native backend is a much larger
   project and cannot be delivered solely by changing this open repository.
2. **Make the result independently reproducible.** Remove hardcoded development
   paths, the fixed mangled kernel symbol and dependence on one nightly IR
   shape. Pin/document tool compatibility and obtain a clean-machine build
   without the research workspace's private layout.
3. **Define the semantics and unsupported cases.** Agree on Float comparisons,
   NaNs/infinities, signed zero, integer/index widths, pointer address spaces,
   launch bounds and errors. Either implement barriers, shared memory,
   atomics and library calls correctly or keep them explicitly rejected.
4. **Provide maintainable validation.** Add relevant Bazel/Pixi example targets,
   formatting and tests following the chosen area's conventions. Run hardware
   tests on Metal and CUDA; arrange an owner and suitable Adreno test coverage
   for any support claim. A missing device should be an explicit skip, not a
   passing GPU execution result. Retain compiler/driver versions and failing
   examples when regressions occur.
5. **Separate compatibility work from performance claims.** This eight-element
   example establishes correctness only. Any performance proposal needs
   meaningful sizes and before/after measurements that distinguish setup,
   transfer and kernel time.
6. **Meet contribution requirements.** Follow the destination's contribution
   guide, formatting checks and relevant tests, include required copyright
   and license headers, use a focused branch from current `main`, and keep
   changes small enough to review. Under the [AI tool use policy](../../AI_TOOL_POLICY.md),
   a human must review and own the contribution, disclose substantial AI
   assistance with an `Assisted-by:` trailer or equivalent, and write the
   eventual PR description themselves. Include the relevant sign-off and
   component-tag conventions.

The most realistic initial candidate is an agreed, self-contained Mojo
example plus tests and a clear experimental-backend note. Shipping this
prototype retargeter as general Adreno support would first require a stable
compiler integration contract and an explicit maintenance commitment.
