# X_eTaL source running on the Adreno 702

All five Accel source demos ran on the UNO Q's physical Qualcomm FD702 GPU
through Mesa rusticl 25.2.6-1~bpo13+1. Every output agrees with the pinned
X_eTaL evaluator baseline. This is an actual OpenCL dispatch on the board.

Path: X_eTaL `.xtl` source -> existing X_eTaL-gpu lowering -> XIR -> generated
OpenCL C 1.2 -> rusticl -> Adreno 702. The existing tool performed lowering
on the board. No hand-written replacement kernels or CPU fallback were used.

## Run the demo now

From the host terminal:

```sh
ssh -p 2222 arduino@localhost 'cd adreno-poc/work/xetal-opencl && bash scripts/demo-xetal-opencl.sh'
```

Or, inside your existing board SSH session:

```sh
cd ~/adreno-poc/work/xetal-opencl
bash scripts/demo-xetal-opencl.sh
```

It prints the device and driver, shows each `.xtl` source, prints evaluator
and GPU outputs, checks every output, and finishes with:

```text
RESULT: 5 of 5 X_eTaL source demos agree with evaluator baselines on physical FD702
```

The script discovers the actual index of the unique Qualcomm FD702 GPU;
this board currently uses `opencl:0`. Missing, ambiguous, CPU or wrong-vendor
devices fail selection. The script exits nonzero on build, dispatch or
comparison failure. Detailed per-command logs are written under the bundle's
`work/results/` (or an explicit output directory).

## Results and schedule

| Source demo | Outputs checked | Coverage | Result |
| --- | --- | --- | --- |
| threshold.xtl | 5 vectors, 40 elements | Threshold, Float/Int ReLU, mask selection | Pass |
| vector-add.xtl | 2 vectors, 16 elements | Int/Float vector addition and scaling | Pass |
| saxpy.xtl | 1 vector, 8 elements | Fused scale and add | Pass |
| reduce-sum.xtl | 5 scalars | Sum, maximum, dot product, Int/Float reductions | Pass |
| pipeline.xtl | 2 scalars | Multiply, add, select, reduce | Pass |

All 71 printed numeric elements are checked, not sampled. The CPU XIR
interpreter must match the evaluator baseline exactly. GPU results are
compared using the pinned upstream comparator: Ints exactly, Floats with
relative tolerance 1e-5 (and its absolute floor 1e-9). The baseline files
were copied unchanged from the pinned X_eTaL-gpu regression tests; a fresh
standalone X_eTaL evaluator was not built or run on the board in this step.

The default schedule passed the first three demos, then refused
`reduce_max_long`: the compiled kernel permits at most 192 work-items on
FD702, despite the device's overall 512-item limit. The tested
`schedules/adreno-702.toml` uses work_group=128, tile=8, f32 and i64. All five
demos then passed. `initial-default-schedule/` preserves the original
successful runs and the exact reduction failure. No upstream runtime or
emitter change was required.

These small examples establish execution and correctness, not speedup.
The timing logs include one-shot setup, upload, kernel and download costs.
Do not treat their microsecond-scale device times as throughput benchmarks.

## Sources, build and deployment

Pinned X_eTaL-gpu: `94ff597a06eed0d4b16694af0fcb648119a9eb17`.
Pinned X_eTaL: `27b3fd0d4903e43be4b9b6e93da7476987383dcf`.
Both were cloned under `adreno-poc/work/`; sibling repositories were not
modified. Rust 1.99.1 cross-built the CLI for aarch64-unknown-linux-gnu with
the Arch aarch64-linux-gnu-gcc linker. OpenCL is loaded dynamically on the
board. No packages or compiler toolchains were installed on the board.

Rebuild from `adreno-poc` on this Arch host:

```sh
bash scripts/setup-host.sh --prepare-cross
source work/host.env
# Sources already exist under work/ on this host. On a fresh checkout,
# build-xetal-opencl.sh clones the sibling X_eTaL-gpu and its pinned X_eTaL.
# Provision the pinned workspace dependencies once if not cached:
cargo fetch --locked --manifest-path work/xetal-gpu/components/Cargo.toml
bash scripts/build-xetal-opencl.sh
```

The bundle builder builds offline, verifies pinned revisions and clean
tracked source files, and writes `work/xetal-opencl-bundle.tar.gz`. If run
on a fresh project before fetching dependencies, its first offline build
can fail after cloning; run the fetch command above, then rerun the builder.
`XETAL_GPU_SOURCE` overrides the sibling source path. Tools, SDK components,
source clones, caches and binaries remain under this project.

Deploy the bundle (the board directory already exists):

```sh
scp -P 2222 work/xetal-opencl-bundle.tar.gz arduino@localhost:adreno-poc/work/
ssh -p 2222 arduino@localhost 'mkdir -p adreno-poc/work/xetal-opencl && tar --warning=no-timestamp -xzf adreno-poc/work/xetal-opencl-bundle.tar.gz -C adreno-poc/work/xetal-opencl'
```

The bundle includes the Accel sources, evaluator baselines, standard library,
upstream output comparator, device selector, schedule and demo script.
No binary is committed to this repository.

## Evidence and validation

`docs/evidence/unoq-xetal-opencl-20261023/` contains the complete successful
transcript, device/driver enumeration, script and binary hashes, source
revisions, exact commands, original `.xtl` sources, lowered XIR, generated
OpenCL C, baselines, CPU/GPU outputs, and timing logs. The board clock still
reports September 2025; `collection.log` records the host collection date.
Local build, provisioning and gate logs accompany the board logs.

`just gate` passes with device-selection tests that reject software, wrong
vendor, missing and ambiguous devices. The cross-toolchain setup now
disables rustup self-update (avoiding a CARGO_HOME-local rustup error) and
includes rustfmt/clippy so the local toolchain can run the project gate.

## What this does not establish

No Vulkan or Mojo dispatch on Adreno, large-array speedup, matrix workload,
memory-pressure measurement, or benefit of the 4 GiB board is established.
This step ran the existing X_eTaL-gpu CLI source-lowering path, not the
`xetal-x` native-extension facade. The Float computation schedule is f32;
the device does not advertise fp64. Next is the Mojo/OpenCL equivalent demo feasibility step; Vulkan cross-build,
larger OpenCL demos and crossover measurement remain separate work.

## Equivalent Mojo demo: next step and blockers

The next Agentrail step is `005-mojo-opencl-demo`. The board presently has
Python 3.13.5 but no `mojo`, `pip` executable or Python pip module. A
project-local aarch64 toolchain and a compiled hello must be tested first.
[Mojo's documented requirements](https://docs.modular.com/mojo/requirements/)
specify 8 GB RAM and list ARM64 Linux testing on AWS Graviton2/3. This board
has 1.7 GiB usable RAM; compiler feasibility and CPU compatibility remain
unproven. glibc 2.41 clears the documented 2.34 baseline.

The same requirements document lists NVIDIA, AMD and Apple GPU support;
it does not list Qualcomm Adreno or OpenCL. The immediate experiment is a
Mojo host using FFI to a small C ABI around the proven OpenCL path, with
identical input and output checks. This would demonstrate Mojo driving
Adreno computation, while the GPU kernel remains OpenCL C. Mojo-authored
native GPU kernels require separate compiler/runtime backend work. The
[compilation targets documentation](https://docs.modular.com/mojo/tools/compilation/)
describes the existing accelerator targets and notes that cross-compilation
support is still in development; a host cross-build fallback must be tested,
not assumed, if the board cannot run the compiler.

Arch cross-compilation probe with the pinned Mojo
1.2.0.dev2026101305 compiler succeeded with `--emit object`,
`--target-triple aarch64-unknown-linux-gnu --target-cpu cortex-a53`.
`file` identifies the output as ARM aarch64. A normal executable build
instead invoked the host linker and failed with `EM: 183` / wrong format.
The next step now prioritizes target linking and ARM64 runtime provisioning,
then a real board hello, before attempting compiler installation on the board.
Evidence: `docs/evidence/arch-mojo-cross-20261023/`; no object is committed.
Trailing horizontal whitespace in captured OpenCL logs was normalized for
Git's whitespace check; numeric outputs and diagnostics are preserved.
