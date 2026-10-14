# rust-demo: Rust writes Mojo, Mojo runs the GPU

A proof of one idea: a Rust program can generate Mojo source equivalent
to what a Mojo programmer would write for a GPU, build it as a shared
library with the Mojo compiler, load it, and run it on the GPU of the
machine it is on, with the answer checked against a Rust reference. On
this Mac the GPU is the Apple M1 Max through Metal; on the Arch box it
will be the RTX 5060 Ti through CUDA, from the same code (not run there
yet: [doc/porting-arch-rtx5060.md](doc/porting-arch-rtx5060.md)).

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
                                         work/saxpy/libsaxpy.dylib            │
                                                  │ dlopen (libloading)       │
                                                  ▼                           │
                                 xir_run: DeviceContext → Metal kernels ──────┘
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
  library opened (`api=metal  name=Apple M1 Max`), the grid it launched,
  and which block and thread computed the first and last element, read
  back from a provenance kernel. `just asm saxpy` prints the Metal AIR
  the device compiler received. [doc/proving-gpu-execution.md](doc/proving-gpu-execution.md)
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

## How well it works

On the M1 Max (macOS 26.5, Mojo 1.2.0.dev2026101305, 2026-10-13) all
five programs agree with the reference: elementwise and bool outputs
exactly, reductions exactly or within 7e-6 (the variance, the device's
tree folding in another order). Numbers in [doc/results.md](doc/results.md).

| Step | Cost here |
| ---- | --------- |
| `mojo build --emit shared-lib`, per program | about 2.6 s |
| `xir_run`, including the first-use Metal compile of each kernel, uploads and downloads | 40 to 55 ms |
| `just gate` (five programs, build and run) | about 15 s |

What it does not do, by design, so that the lowering stays readable:
f32 only; rank 0 and rank 1 shapes, one vector length per program;
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
just gate             # every program on the GPU, asserted
just lib my.mojo      # any hand-written Mojo file as a C-callable shared library
```

Without `just`: `scripts/setup.sh`, then `cargo run --release -- run programs/saxpy.xir`.

## Layout

| Path | What |
| ---- | ---- |
| `src/ir.rs` | the IR: parser and checker (XIR's text form, the subset here) |
| `src/eval.rs` | the Rust reference evaluator (f32, right folds) |
| `src/emit.rs` | the plan (fused stages split at reductions, what lives in a buffer) and the Mojo emitter |
| `src/host.rs` | finding `mojo`, `mojo build --emit shared-lib`, `dlopen`, the C ABI calls |
| `src/main.rs` | the `xir-mojo` tool: `run` and `check` |
| `programs/` | the five programs and their `.inputs` bindings |
| `tests/programs.rs` | tests without a GPU |
| `tests/device.rs` | the device gate |
| `scripts/setup.sh` | the venv and toolchain check |
| `scripts/build-mojo-lib.sh` | build any Mojo file as a shared library; print exports, rpaths, dependencies |
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

Maps: `add sub mul div min max neg abs exp log`, comparisons `eq ne lt le gt ge`
(giving bools), `and or not`; `select %cond %a %b`. The checker refuses
what the device could not run (mixed types, two vector lengths, a reduce
of bools) with the line number.
