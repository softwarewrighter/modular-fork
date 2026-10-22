# rust-demo: Rust writes Mojo, Mojo runs the GPU

A proof of one idea: a Rust program can generate Mojo source equivalent
to what a Mojo programmer would write for a GPU, build it as a shared
library with the Mojo compiler, load it, and run it on the GPU of the
machine it is on, with the answer checked against a Rust reference. On
the Mac the GPU is the Apple M1 Max through Metal; on the Arch box it
is the RTX 5060 Ti (16 GB) through CUDA, from the same code. All five
hand-written programs pass on both ([results](doc/results.md),
[Linux setup](doc/porting-arch-rtx5060.md)). Since 2026-10-16 the
program can come from X_eTaL source with nothing written by hand:
X_eTaL-gpu's `xetal-gpu lower` writes the XIR, this tool writes the Mojo,
and the GPU's answer is checked against X_eTaL's own evaluator
([below](#from-x_etal-source-nothing-by-hand)).

The blog post
[Array Languages #10: X_eTaL on Metal and CUDA, Through Mojo](https://blog.softwarewrighter.com/2026/10/16/array-languages-xetal-mojo-metal/)
tells the story, and
[Rabbit-hole #8: From X_eTaL to the Metal, One Kernel Down Every GPU Toolchain](https://blog.softwarewrighter.com/2026/10/21/rabbit-hole-xetal-to-the-metal/)
follows one kernel down every toolchain.

For the follow-up GPU deep dive, [the CUDA blog handoff](doc/cuda-blog-handoff.md)
contains generated CUDA C++ and Mojo, nvcc PTX, native NVIDIA assembly,
and a checked RTX 5060 Ti run of the lowered threshold program; [the
Metal blog handoff](doc/metal-blog-handoff.md) has Mojo's Metal AIR for
the same program and its checked run on the M1 Max; [the AMD blog
handoff](doc/amd-blog-handoff.md) has Mojo's gfx1100 assembly for it,
cross-compiled with no AMD GPU (listings only, nothing run); [the CPU
blog handoff](doc/cpu-blog-handoff.md) has the same Mojo built with
`-D XIR_CPU=true`, its arm64 kernel body, and the checked run on the
M1 Max's CPU. [doc/top-down.md](doc/top-down.md) walks one program
through every level, X_eTaL source to Core to XIR to Mojo to PTX, AIR,
AMDGCN and arm64, with the program or call at each step and a link to
every listing.

It is a simpler cousin of [X_eTaL-gpu](https://github.com/softwarewrighter/X_eTaL-gpu)'s
`gp:a_ccel<` macro and OpenCL emitter: the same shape of pipeline, with a
tiny IR in XIR's text form, a Mojo emitter in place of the OpenCL one,
and Mojo's `DeviceContext` in place of the OpenCL host runtime. Speed is
not the point; equivalence and provenance are.

```
programs/saxpy.xir ──parse, check──▶ IR ──Rust reference (f32)──────────────┐
                                     │                                        │ compare
                                     └──emit──▶ work/saxpy/saxpy.mojo         │
                                                  │ mojo build --emit shared-lib
                                                  ▼                           │
                                  work/saxpy/libsaxpy.dylib (.so on Linux)    │
                                                  │ dlopen (libloading)       │
                                                  ▼                           │
                            xir_run: DeviceContext → Metal or CUDA kernels ───┘
                                 xir_trace: which block and thread did each element
```

## What the demo shows

- **Rust emits Mojo a person could keep.** `just show saxpy` prints the
  generated file: a `def stage0(...)` kernel with the scale and the add
  fused, one thread per element, the constants as literals; the host code
  creating buffers, enqueueing the kernel and copying back; five
  `@export(...) abi("C")` entry points. Compare it with
  `max/examples/gpu-functions/vector_addition.mojo` and `reduction.mojo`
  in this repository.
- **It runs on the GPU, provably.** Every run prints the device the
  library opened (`api=metal  name=Apple M1 Max` on the Mac,
  `api=cuda  name=NVIDIA GeForce RTX 5060 Ti` on the Arch box), the grid
  it launched, and which block and thread computed the first and last
  element, read back from a provenance kernel. `just asm saxpy` prints
  what the device compiler received: Metal AIR on the Mac, PTX for
  `sm_120a` on the NVIDIA card. [doc/proving-gpu-execution.md](doc/proving-gpu-execution.md)
  has the full argument, including outside observers and a negative control.
- **It is checked.** The Rust reference evaluates the same program in f32,
  folding reductions from the right as X_eTaL's `r_/` does; the tool
  compares every output (exact for bools, within a relative 1e-4 for
  floats, reporting the largest difference) and the device gate test
  asserts it for every program.

Five programs exercise the paths: `saxpy` (fused elementwise), `threshold`
(comparisons, bools, select), `reduce` (sum, max and min of a thousand
items as two-pass shared-memory trees), `softmax` (two fused stages split
by two reductions, as X_eTaL-ML's NN library writes it), `stats` (mean and
variance: single-value maps computed in a kernel and written by thread 0).

## From X_eTaL source, nothing by hand

```
libs/Accel/demos/saxpy.xtl ──xetal-gpu lower──▶ accel-saxpy.xir ──xir-mojo──▶ Mojo ──▶ GPU
         (X_eTaL source, in X_eTaL-gpu)        (XIR text, read as is)                   │
libs/Accel/tests/demo-saxpy.out (what xetal printed) ──────────────── compared ─────────┘
```

The source is
[libs/Accel/demos/saxpy.xtl](https://github.com/softwarewrighter/X_eTaL-gpu/blob/main/libs/Accel/demos/saxpy.xtl)
in X_eTaL-gpu, seven lines of X_eTaL; the evaluator's output it is
checked against is
[libs/Accel/tests/demo-saxpy.out](https://github.com/softwarewrighter/X_eTaL-gpu/blob/main/libs/Accel/tests/demo-saxpy.out).
`just xtl ../../X_eTaL-gpu/libs/Accel/demos/saxpy.xtl` runs that chain
for any X_eTaL program whose lowering stays in this tool's subset. Five
of X_eTaL-gpu's thirteen
[Accel demos](https://github.com/softwarewrighter/X_eTaL-gpu/tree/main/libs/Accel/demos)
do (`saxpy`, `threshold`,
`reduce-sum`, `pipeline`, `vector-add`); their lowered XIR and X_eTaL's
evaluator output are committed as `programs/accel-*.xir` and `.expect`
(`just refresh-xtl` rewrites them from the sibling repository), so the
gate runs them on any machine without X_eTaL-gpu present. Every output
is checked twice: against the Rust reference and against what `xetal`
printed for the source. The other eight demos need axes, matrices and
gathers; that is X_eTaL-gpu's saga gpu-mojo, which ports this emitter
into `components/mojo` beside the OpenCL one.

The lowered programs brought two forms this tool did not have: `i64`
values (X_eTaL's Ints) and `cast`, plus `mod`. Ints are a shortcut
here: carried in f32 on the device and in the reference, exact while
every item stays below 2^24, which the checker and the reference
enforce; `mod` is floored, as X_eTaL's (`-3 mod 2` is `1`), through
Mojo's `Int %`. The generated file names the values it carries that way.

## How well it works

On the M1 Max through Metal (2026-10-13) and on the RTX 5060 Ti through
CUDA (2026-10-16), both with Mojo 1.2.0.dev2026101305, all five programs
agree with the reference: elementwise and bool outputs exactly,
reductions exactly or within 7e-6 (the variance, the device's tree
folding in another order). The NVIDIA run needed no change to the Rust,
the programs or the generated Mojo. The five programs lowered from
X_eTaL source agree exactly with the Rust reference and with X_eTaL's
evaluator on the M1 Max and on the RTX 5060 Ti (both 2026-10-16).
Per-program numbers and the raw Linux logs are in
[doc/results.md](doc/results.md).

| Step | M1 Max, Metal | RTX 5060 Ti, CUDA |
| ---- | ------------- | ----------------- |
| `mojo build --emit shared-lib`, per program | about 2.6 s | about 4.5 s |
| `xir_run`, including the first-use kernel compile, uploads and downloads | 40 to 55 ms | 390 to 465 ms |
| `just gate` (five programs, build and run) | about 15 s | about 13 s |

One run each, not benchmarks; the first-use compile dominates `xir_run`.

The same generated file also builds for the CPU (`-D XIR_CPU=true`,
`just cpu`): a CPU `DeviceContext`, each stage a parallel range over the
elements, each reduction a fold; the gate runs every program both ways.

What it does not do, by design, so that the lowering stays readable:
f32 on the device (i64 carried in it, exact below 2^24); rank 0 and rank 1 shapes, one vector length per program;
whole-array reductions only (no axis, no matmul, no gather); at most 65536
elements in a program with reductions (two passes); every call re-creates
the device context and re-uploads (no sessions, no resident weights; see
X_eTaL-gpu's `gpu-sessions.md` for what that costs and buys).

## The value proposition

For the X_eTaL ecosystem, Mojo is a candidate second backend for the same
accelerator IR, beside OpenCL:

- **One emitter, three vendors.** Mojo compiles the same kernel source
  for Metal, CUDA and HIP; the emitter does not know which. X_eTaL-gpu
  reaches Apple silicon through Apple's deprecated OpenCL 1.2 (no fp64);
  Mojo reaches it natively.
- **No CUDA toolkit.** The Mojo compiler carries its own PTX backend; the
  only NVIDIA dependency is the driver (580 or newer), or an external
  `ptxas` for older drivers and cards
  ([doc/older-gpus.md](doc/older-gpus.md) for the Maxwell M40 question).
- **Training-capable by construction.** The IR has no autograd and needs
  none: a gradient is more maps and reductions, which is how X_eTaL-ML
  writes them. MAX serves models and does not train; Mojo under X_eTaL is
  unaffected by that choice.
- **Readable output.** What Rust writes is ordinary Mojo, which a person
  can read, keep, hand-edit, or compare with Modular's own examples, and
  which the Mojo compiler, not this tool, keeps correct as the GPU APIs
  move.
- **Old cards stay with OpenCL.** Mojo's target table starts at Maxwell
  (sm_52) and the docs call pre-Turing unsupported; Kepler is absent. The
  OpenCL path remains the only one for the K4200, and the likely one for
  the M10 and P4. Two emitters from one IR is the plan that covers both.

The costs: a toolchain of several hundred megabytes in a venv; the
`max` wheel (needed for `max.gpu`) ships MAX under the Modular Community
License alongside the Apache-licensed Mojo; and kernels specialized per
shape, as X_eTaL-gpu's already are.

## Quick start

Requirements: [uv](https://docs.astral.sh/uv/), Rust stable, [`just`](https://github.com/casey/just);
on macOS 15 or newer, Xcode 16 or newer with the Metal toolchain
(`xcodebuild -downloadComponent MetalToolchain`); on Linux, an NVIDIA
driver 580 or newer (or `MODULAR_NVPTX_COMPILER_PATH`, see the docs).

```sh
cd rust-demo
just setup            # .venv with the pinned MAX nightly (Mojo + max.gpu); checks the GPU toolchain
just run saxpy        # generate, build, load, run on the GPU, check
just show softmax     # the generated Mojo, then the run
just asm saxpy        # the run with the device assembly printed
just all              # every program
just test             # parser, reference, plan, emitted text (no GPU)
just gate             # every program on the GPU, and again on the CPU, asserted
just capture          # versions, tests, GPU results and assembly into ignored work/results-*/
just lib my.mojo      # any hand-written Mojo file as a C-callable shared library
just xtl FILE.xtl     # X_eTaL source: lowered by ../../X_eTaL-gpu, run here, checked against xetal
just refresh-xtl      # rewrite programs/accel-*.xir and .expect from X_eTaL-gpu's Accel demos
just cpu saxpy        # the same generated Mojo built with -D XIR_CPU=true, run on the CPU, checked
just capture-metal    # evidence captures for the threshold program: Metal AIR and the run,
just capture-amd      #   gfx1100 listings with no AMD GPU, the CPU build and its host assembly
just capture-cpu      #   (each into a directory of text: logs, listings, the checked output)
```

Without `just`: `scripts/setup.sh`, then `cargo run --release -- run programs/saxpy.xir`.

For the verified NVIDIA run and portable text evidence, see
[the RTX 5060 Ti handoff](doc/rtx5060-handoff.md).

## Layout

| Path | What |
| ---- | ---- |
| `src/ir.rs` | the IR: parser and checker (XIR's text form, the subset here) |
| `src/eval.rs` | the Rust reference evaluator (f32, right folds) |
| `src/emit.rs` | the plan (fused stages split at reductions, what lives in a buffer) and the Mojo emitter |
| `src/host.rs` | finding `mojo`, `mojo build --emit shared-lib`, `dlopen`, the C ABI calls |
| `src/main.rs` | the `xir-mojo` tool: `run` and `check` |
| `programs/` | five hand-written programs with `.inputs` bindings; five `accel-*.xir` lowered from X_eTaL source by `xetal-gpu`, with `.expect` (what `xetal` printed) |
| `tests/programs.rs` | tests without a GPU |
| `tests/device.rs` | the device gate |
| `scripts/setup.sh` | the venv and toolchain check |
| `scripts/build-mojo-lib.sh` | build any Mojo file as a shared library; print exports, rpaths, dependencies |
| `scripts/from-xtl.sh` | X_eTaL source through `xetal-gpu lower` and this tool; `--refresh` rewrites `programs/accel-*` |
| `scripts/capture-metal.sh`, `capture-amd.sh`, `capture-cpu.sh`, `capture-cuda.sh` | evidence captures of the threshold program for the blog: listings, logs, checked runs (`doc/*-blog-handoff.md` read them) |
| `src/cuda.rs` | a second emitter, XIR to standalone CUDA C++ (`emit-cuda`), for comparing nvcc's PTX with Mojo's |
| `doc/mojo-as-a-library.md` | the recipe and the pitfalls found |
| `doc/proving-gpu-execution.md` | the evidence that the GPU ran it |
| `doc/porting-arch-rtx5060.md` | the same demo on the Arch box |
| `doc/older-gpus.md` | the plan for Maxwell and Pascal cards |
| `doc/results.md` | measured results, one row per device |
| `work/` | generated Mojo and libraries (ignored by git) |

## The IR, in one glance

```
%x = input f32 [1024]        # bound by the host
%m = reduce max %x           # whole-array: add, max, min
%c = map sub %x %m           # elementwise; a single value extends
%e = map exp %c
%s = reduce add %e
%p = map div %e %s
output %p
```

Maps: `add sub mul div mod min max neg abs exp log`, comparisons `eq ne lt le gt ge`
(giving bools), `and or not`; `select %cond %a %b`; `cast f64 %x` (and
`cast i64`, `cast bool`); types `f32` (`f64` reads as f32), `i64`
(carried in f32, exact below 2^24), `bool`. The checker refuses
what the device could not run (mixed types, two vector lengths, a reduce
of bools) with the line number.
