# Host Vulkan vector-add handoff

Step 003 implements `adreno-vk`: Naga 24 compiles GLSL to SPIR-V at build
time; ash 0.38 loads Vulkan at runtime. Three storage buffers hold the two
inputs and output. A four-byte push constant carries the element count.
Each workgroup has 256 invocations, with a bounds guard for partial groups.
The output starts as NaN so an unwritten element cannot pass the oracle.

Every discovered device is printed with its driver and device type. The
first integrated or discrete GPU with a compute queue and Vulkan >= 1.1 is
selected. CPU devices and names containing llvmpipe/lavapipe are rejected.
The code checks dispatch and storage-buffer limits, uses host-visible
coherent memory, inserts a shader-write to host-read barrier, and waits for
a fence before readback. RAII cleanup covers partial initialization.

## Reproduce

From `adreno-poc`, after `just setup` and sourcing `work/host.env`:

```sh
cargo fetch --locked
just gate
just gpu-check
cargo run --offline --release -- --count 1025
bash scripts/capture-host-vulkan.sh docs/evidence/arch-host-vulkan-20261023
```

The ordinary gate runs without a GPU; the physical-device test is ignored
there and run explicitly by `gpu-check`. In the Codex sandbox the NVIDIA
driver is inaccessible; hardware checks require execution outside it.
No software-driver fallback is enabled.

## Result

Evidence: `docs/evidence/arch-host-vulkan-20261023/`. Driver: NVIDIA
615.78.08. Device: NVIDIA GeForce RTX 5060 Ti. Compute queue family: 0.

| Check | Counts | Oracle | Result |
| --- | --- | --- | --- |
| Physical GPU integration | 1, 1024, 1025, 65536, 1048576 | Rust elementwise sum | Every element matched |
| Release sweep | 1024, 4096, 16384, 65536, 262144, 1048576 | Rust elementwise sum | Every element matched |
| Oracle rejection | Corrupt first/middle/last, NaN, infinity, wrong length | Independent CPU expectations | Rejected |
| Invalid dispatch sizes | 0, 1048577, usize::MAX | API count bounds | Rejected before loading driver |

The deterministic inputs use small integer and quarter-integer values, so
the sums are exactly representable as Float32 and checked for exact equality.
The committed SPIR-V disassembly is text; the binary remains under `target/`.
`spirv-val --target-env vulkan1.1` checks the generated module.

The evidence environment records the pre-implementation HEAD plus shader
and lockfile hashes. The Agentrail completion points to the implementation
commit. Host setup now records the installed `vulkan-tools` and
`aarch64-linux-gnu-gcc` packages.

## What this does not establish

No UNO Q was connected, so this says nothing about its physical Adreno,
Turnip version, compute limits, rusticl availability, memory pressure or
performance. Step 002 is reserved for the board session. This is standalone
GLSL vector addition checked against a Rust oracle, not X_eTaL lowering or
Mojo execution. Vulkan validation layers were not enabled. Vulkan 1.0-only
devices are currently rejected; the board inventory must establish whether
its driver supports the Vulkan 1.1 requirement. Mac/MoltenVK execution,
aarch64 cross compilation, and deployment remain untested.

Next: collect board inventory and complete the cross-build/deploy step. The
cross compiler is installed, but the project-local aarch64 Rust target has
not yet been provisioned. Do not claim an Adreno dispatch from the host logs.
