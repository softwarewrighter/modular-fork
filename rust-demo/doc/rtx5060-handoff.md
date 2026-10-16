# RTX 5060 Ti verification: handoff for the Mac blogging agent

Update, 2026-10-16: the expanded ten-program suite at `f95c7ba386` also
passes on this card, including all five committed X_eTaL-lowered Accel
demos against both oracles. See the
[ten-program results](results.md#ten-program-re-run-rtx-5060-ti-cuda-2026-10-16)
and [dated capture evidence](evidence/rtx5060-20261016-ten-programs/).
The five-program account below describes the first verification.

On 2026-10-16 the existing `rust-demo` ran successfully on the Arch Linux
RTX 5060 Ti with 16 GB VRAM. This is the same Rust emitter, five XIR
programs, and pinned MAX/Mojo nightly used for the Apple M1 Max run.
No emitter, kernel, or Rust host changes were required for NVIDIA.

The demonstrated path is:

```text
XIR text → Rust emitter → generated Mojo → shared library → Mojo DeviceContext
                                                         ├─ Metal → Apple M1 Max
                                                         └─ CUDA  → RTX 5060 Ti
```

Rust loads `.dylib` on macOS and `.so` on Linux. Mojo selects the device
backend. The NVIDIA run does not use OpenCL. This demo consumes the small
XIR subset in `rust-demo/programs`; it does not yet connect the full
X_eTaL language frontend or replace X_eTaL-gpu's OpenCL runtime.

## Evidence to cite

- [Measured results and versions](results.md): all five programs agree
  with the Rust f32 reference; seven host tests and the device gate pass.
- [Original all-program transcript](evidence/rtx5060-20261016/all.log):
  device names, build/run times, outputs, numerical differences, and
  block/thread provenance.
- [Original device gate](evidence/rtx5060-20261016/gate.log): all five
  programs asserted, test duration 13.27 s.
- [Original PTX transcript](evidence/rtx5060-20261016/assembly.log):
  `.target sm_120a`, `saxpy_stage0`, and `saxpy_trace` entries.

The raw transcripts retain the Linux checkout's absolute paths. The
timings include first-use compilation, allocation, uploads, and downloads;
they are single-run observations, not a comparison of steady-state GPU
throughput. Float reductions may differ because the GPU uses a tree
instead of the reference's right fold; all differences meet the demo's
existing tolerance.

## Reproduce

```sh
git switch experimental
git pull --ff-only origin experimental
cd rust-demo
scripts/setup.sh
just capture
```

Without `just`, use `bash scripts/capture-results.sh`. The capture script
records versions, source revision and working-tree status, host tests,
all five GPU runs, the assertion gate, and saxpy assembly in
`work/results-<UTC timestamp>/`. It stops on failure and runs GPU commands
sequentially because they rebuild the same libraries. An optional output
directory can be supplied to the script.

On the Mac this should capture Metal evidence; the new script was validated
on Linux. The Linux GPU must be visible to the process: this coding
sandbox hid `/dev/nvidia*`, so GPU verification ran outside it. Setup now
reports that possibility when `nvidia-smi` fails.

Only compact text evidence is committed. Virtual environments, generated
Mojo, shared libraries, Cargo outputs, and fresh capture directories stay
ignored. The demo's ignore rules now also cover macOS `.dylib` artifacts
written outside `work/`; the root ignore rules already cover `.so` files.
