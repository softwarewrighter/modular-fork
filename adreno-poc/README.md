# adreno-poc

Mojo and X_eTaL on the Qualcomm Adreno 702, the GPU of the Arduino
UNO Q (Dragonwing QRB2210, four Cortex-A53, 2 GB). A research
directory of modular-fork on the branch
`research-qualcomm-adreno-702-gpu`, planned and tracked as an
agentrail saga (`.agentrail/`, the plan in [docs/plan.md](docs/plan.md)).

The question: what does it take to run parallel code on this GPU
written in Mojo and written in X_eTaL, and which demos show it. The
plan corrects the research notes ([docs/research.txt](docs/research.txt))
against what the repositories already have: X_eTaL-gpu's XIR, OpenCL
emitter, runtime and native extension; rust-demo's XIR parser,
evaluator and Mojo emitter; Mojo's published aarch64 Linux wheels.

Five X_eTaL source demos now run on the UNO Q's physical Adreno 702 through
rusticl OpenCL, with all 71 output elements checked against evaluator
baselines. See [the working demo and results](docs/xetal-opencl-handoff.md).
A Mojo-authored GPU kernel now also executes on Adreno through an audited
LLVM-to-SPIR-V retargeter; [run it](docs/mojo-spirv-handoff.md). A
cross-compiled Mojo host drives the earlier OpenCL bridge too; see
[the annotated deep dive](docs/adreno-deep-dive.md) for both compilation paths.
The scaffold and Vulkan vector addition are also validated on Arch's RTX
5060 Ti, with every element checked from 1K through 1M.
See [the host Vulkan results](docs/host-vulkan-handoff.md).
The [UNO Q inventory](docs/uno-q-capabilities.md) now confirms the physical
Adreno in Turnip and rusticl. OpenCL is the first path to test; Turnip
reports Vulkan 1.0, requiring a compatibility change to the host demo.
Start with
`just setup` and `just gate`. Run `bash scripts/inventory.sh OUTPUT_DIRECTORY`
on the UNO Q and return the complete output directory. See
[the scaffold handoff](docs/scaffold-handoff.md) for setup and limitations.

The steps, in order, with the host each needs:

| # | Step | Host | What it establishes |
| - | ---- | ---- | ------------------- |
| 1 | scaffold | mac | the workspace, the board inventory script, a host setup that stays inside `work/` |
| 2 | board-inventory | board | physical Adreno in vulkaninfo, a compute queue, rusticl in clinfo, glibc, memory; Vulkan-first or OpenCL-first |
| 3 | host-vulkan | arch (mac via MoltenVK) | `adreno-vk`: ash + naga vector add on the host GPU, every element checked |
| 4 | xetal-gpu-opencl-board (DONE) | arch, then board | Five X_eTaL source demos on physical FD702 through rusticl, every output checked |
| 5 | mojo-opencl-demo (DONE) | arch, then board | Mojo feasibility, then Mojo FFI driving the same Adreno OpenCL computation |
| 6 | cross-aarch64 | arch or mac, then board | the first dispatch on the Adreno 702 through Turnip |
| 7 | xir-glsl | mac or arch | XIR to GLSL compute: `xir-vk run`, ten programs on the host GPU against the evaluator |
| 8 | xir-vk-board | board | the same on the Adreno: X_eTaL source to the Adreno through Vulkan |
| 9 | mojo-on-board | board | Mojo on the A53 (the aarch64 wheel), rust-demo's CPU build checked; the GPU limitation in Mojo's own words |
| 10 | mojo-vulkan-ffi | board | Mojo calling the Vulkan runtime through its FFI: the same shader, the same outputs |
| 11 | xetal-ext-vk | mac or arch, then board | the Vulkan runtime as an ABI V1 extension beside X_eTaL-gpu's OpenCL one |
| 12 | demos-crossover | board | the demo progression, A53 versus Adreno, the crossover size, 2 GB versus 4 GB answered |
| 13 | mojo-spirv-research | mac | what this fork exposes for a Mojo to SPIR-V path; go/no-go |
| 14 | mojo-kernel-spirv (DONE, out of order) | arch, then board | Mojo-authored GPU kernel retargeted from LLVM to SPIR-V, checked on FD702 |
| 15 | release | any | results table, root README link, blog handoff, retrospective |

`work/` holds vendored tools and SDKs and is not tracked. Binaries are
never committed; SPIR-V is committed as its disassembly.
