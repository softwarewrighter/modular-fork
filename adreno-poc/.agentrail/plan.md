# adreno-poc -- Mojo and X_eTaL on the Arduino UNO Q's Adreno 702

Research branch `research-qualcomm-adreno-702-gpu` of modular-fork; the
research notes are `docs/research.txt` (archival, not normative: it
was written without seeing the repositories, and this plan corrects
it where the code disagrees). The question: what does it take to run
parallel code on the Qualcomm Adreno 702 (Dragonwing QRB2210, Arduino
UNO Q, 2 GB model in hand) written in Mojo and written in X_eTaL, and
which demos show it. Every step produces evidence in the form
rust-demo uses (`doc/evidence/<host>-<what>-<date>/` with
environment.log, build.log, the run checked against the X_eTaL
evaluator's `.expect`) and says what ran and what is only a listing.

## What is already true (2026-10-23)

- X_eTaL-gpu already has the accelerator IR (XIR), an OpenCL C 1.2
  emitter, an OpenCL host runtime (opencl3, the library loaded at run
  time), `xetal-gpu devices/run/kernel`, one schedule TOML per device,
  and `extensions/gpu/`: the GPU as an ABI V1 native extension that
  X_eTaL programs call through X_eTaL-extensions' `xetal-x`. The
  research's "build a gpu-core/gpu-vulkan crate tree" starts from zero
  where the ecosystem does not. Arduino's UNO Q datasheet claims
  OpenCL 2.0 through Mesa (rusticl) on the Adreno 702, so the shortest
  X_eTaL path on the board is the existing OpenCL path, with no new
  code if rusticl works. Vulkan (Turnip, 1.1 claimed) is the second
  path and needs a new emitter (XIR to GLSL compute, SPIR-V) and a
  Vulkan runtime; both are new code, written here, not in X_eTaL-gpu,
  until they earn a move.
- rust-demo (this repository) already parses XIR, evaluates it as a
  reference, reads `.expect`, and emits Mojo (GPU and `-D XIR_CPU`
  CPU builds) and CUDA C++. It is a library crate (`xir-mojo`), so the
  Vulkan tool here reuses its parser, evaluator and expect reader by
  path dependency and adds `emit_glsl` and an `ash` host.
- Mojo publishes aarch64 Linux wheels (`mojo` 1.2.0,
  manylinux_2_34; `max` 26.7.0), so Mojo on the UNO Q's Cortex-A53 is
  a pip install if its Debian has glibc >= 2.34 (bookworm: 2.36).
  Mojo has no Vulkan or SPIR-V target and its runtime discovers CUDA,
  HIP and Metal only, so Mojo kernels on the Adreno are research, not
  a build flag. Mojo calling a Vulkan library through its FFI is the
  near-term Mojo path (the research's Approach A).
- The board is not reachable from the Mac today (no `unoq.local`).
  Steps marked [board] produce a script the user runs on the UNO Q, or
  run over ssh once a host is known; their evidence comes back by
  commit.
- Hosts. Mac (M1 Max): no Vulkan SDK, no glslang, no cross linker;
  Rust targets installed lack aarch64-unknown-linux-gnu. Everything
  the Mac needs can stay inside this directory: `naga` (GLSL to SPIR-V
  in pure Rust, a cargo dependency), `ash` loading a vendored
  MoltenVK under `work/` for host-side runs, `cargo-zigbuild` with
  the `ziglang` pip package in `work/.venv` as the cross linker. Arch
  (RTX 5060 Ti): pacman has vulkan-tools, glslang, shaderc,
  spirv-tools, clinfo, aarch64-linux-gnu-gcc, qemu-user-static and a
  real Vulkan driver, and Mesa's rusticl can be enabled over llvmpipe
  to rehearse the board's OpenCL path. Arch is the better host for the
  Vulkan steps; the Mac does the cargo-only ones. Steps say which.

## Rules

- TDD where there is code: the test first, the Rust reference and
  the `.expect` file are the oracles, every element checked.
- Nothing installed outside this directory for this work: vendored
  tools and SDKs go under `work/` (gitignored); pacman packages on
  Arch are the exception and are named in environment.log.
- No binaries committed: SPIR-V is committed as its disassembly
  (text), MoltenVK and wheels never.
- A run on lavapipe or llvmpipe is never reported as a GPU run; every
  run log prints the driver name and the device name first.
- Evidence directories and a handoff document per result, as
  rust-demo does; "what this does not establish" in each.
- Docs ASCII-only. Commit tag `[adreno-poc]`, signed (`-s`), the
  `.agentrail/` state committed with the work, pushed.
- The gate (`just gate`) before every commit.

## Steps

1. scaffold [mac] -- the workspace: README, .gitignore (work/, target/,
   .venv/), justfile, the saga; `scripts/inventory.sh` for the board
   (uname, os-release, glibc, free, /dev/dri, lsmod, vulkaninfo,
   clinfo, ldconfig -p for vulkan/OpenCL/GLES, the Turnip-or-lavapipe
   check); `scripts/setup-host.sh` that detects mac or arch and
   prepares `work/` (Rust target, zig or the cross gcc, MoltenVK on
   the Mac) without touching the system; `just gate` passes on an
   empty crate.
2. board-inventory [board] -- run the inventory on the 2 GB UNO Q,
   commit `docs/evidence/unoq-inventory-<date>/`, write
   `docs/uno-q-capabilities.md`: physical Adreno in vulkaninfo or
   not, a queue with COMPUTE, storage buffers, the rusticl device in
   clinfo or none, glibc, free memory and disk; the go/no-go between
   Vulkan-first and OpenCL-first, decided from the output.
3. host-vulkan [arch, or mac via MoltenVK] -- crate `adreno-vk`: a
   vector-add compute shader (GLSL, compiled by naga at build time),
   an `ash` host that lists devices with driver names, picks one,
   creates storage buffers, binds, dispatches with the count as a push
   constant, reads back and checks every element against a CPU
   reference; 1 K to 1 M elements. Runs on the host GPU first.
4. cross-aarch64 [arch or mac, then board] -- the
   aarch64-unknown-linux-gnu build of adreno-vk (cross gcc on Arch,
   cargo-zigbuild on the Mac), `scripts/deploy.sh` (scp, ssh, run,
   fetch the log); the first dispatch on the Adreno 702 through
   Turnip, driver name in the log, every element checked. This is the
   research's acceptance criterion; nothing compiler-side before it.
5. xetal-gpu-opencl-board [board] -- X_eTaL-gpu's existing path:
   cross-build `xetal-gpu`, `xetal-gpu devices` on the board through
   rusticl, the Accel demos (threshold, saxpy, reduce-sum, pipeline,
   vector-add) run and checked against the evaluator, a
   `schedules/adreno-702.toml` if the defaults do not fit; evidence
   and a handoff. If rusticl is absent or broken, that finding is the
   deliverable and the step closes.
6. xir-glsl [mac or arch] -- the emitter: XIR to GLSL compute, one
   shader per fused stage, reductions as two passes, patterned on
   rust-demo's `emit.rs` and X_eTaL-gpu's OpenCL emitter; `xir-vk run
   programs/<p>.xir` runs it on the host GPU and checks against the
   Rust reference and `.expect`; all of rust-demo's ten programs; a
   `--dump-spirv` that writes the disassembly as text.
7. xir-vk-board [board] -- the same tool cross-built and run on the
   Adreno 702 for every program; the evidence directory with the
   SPIR-V disassembly; X_eTaL source to the Adreno through Vulkan,
   nothing by hand.
8. mojo-on-board [board] -- `pip install mojo` on the UNO Q (the
   manylinux_2_34 aarch64 wheel; record disk and memory), a hello,
   then rust-demo's generated Mojo for accel-threshold built with
   `-D XIR_CPU=true` and run on the A53 against `.expect`; the exact
   text of `DeviceContext()` failing and what `--target-accelerator`
   accepts, as the documented limitation. If the wheel will not
   install or run, that is the finding.
9. mojo-vulkan-ffi [board] -- adreno-vk as a cdylib with a small C ABI
   (context, buffer, upload, dispatch by shader name, download, free,
   a version), Mojo calling it through `DLHandle` on the board: the
   same shader, the same inputs, the same checked outputs as Rust. The
   Mojo path that exists today; the log says the kernel was not
   authored in Mojo.
10. xetal-ext-vk [mac or arch, then board] -- the Vulkan runtime as an
    ABI V1 extension in X_eTaL-gpu's `extensions/gpu` shape (devices,
    load, bind, run, output), so an X_eTaL program chooses `vulkan:N`
    beside `opencl:N` through `xetal-x`; one program run both ways on
    the board; an asks document for X_eTaL-gpu and X_eTaL-extensions
    for whatever should move there.
11. demos-crossover [board] -- the demo progression and the
    measurement: threshold, saxpy, ReLU, softmax (maps and
    reductions, what XIR has today) at 1 K to 1 M elements on the A53
    (Rust reference, Mojo `--cpu`) and on the Adreno (Vulkan, OpenCL),
    the research's JSON record per run (setup, upload, dispatch,
    download, total), the crossover size in a table; peak RSS; the
    2 GB versus 4 GB question answered from the numbers.
12. mojo-spirv-research [mac] -- what this fork exposes for a Mojo to
    SPIR-V path: `kgen.compile_offload`, the accepted target triples
    and `--target-accelerator` values, `_emission_kind`, whether the
    bundled compiler carries MLIR's SPIR-V dialect; a findings
    document with a go/no-go for the research's Approach B and C and
    the smallest experiment that would decide it.
13. release -- `adreno-poc/README.md` with the results table (what
    ran where, checked against what), the root README's links row,
    a blog handoff like rust-demo's, the retrospective, the saga
    archived.
