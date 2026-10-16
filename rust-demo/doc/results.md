# Results, one row per device

Speed is not the goal; every number names its machine so the same program
can be compared across devices. `xir_run` includes the first-use kernel
compile, the uploads and the downloads; the build is `mojo build --emit
shared-lib` of the generated file.

## Apple M1 Max (this Mac), Metal

macOS 26.5, Xcode 26.6, Mojo 1.2.0.dev2026101305 / MAX 26.7.0.dev2026101305
(the repository's pinned nightly), Rust 1.96, 2026-10-13.
`device: api=metal  name=Apple M1 Max`.

| Program | N | Stages | Reductions | Build | xir_run | Verdict |
| ------- | - | ------ | ---------- | ----- | ------- | ------- |
| saxpy | 8 | 1 | 0 | 2.6 s | 40 ms | 1 of 1 agree, exact |
| threshold | 16 | 1 | 0 | 2.5 s | 38 ms | 2 of 2 agree, exact |
| reduce | 1000 | 0 | 3 | 2.7 s | 52 ms | 3 of 3 agree, exact |
| softmax | 1024 | 2 | 3 | 2.8 s | 54 ms | 2 of 2 agree (largest relative difference 5e-7) |
| stats | 1000 | 2 | 2 | 2.7 s | 48 ms | 2 of 2 agree (variance within 6.6e-6) |

Provenance on the 1000-element programs: four blocks of 256 threads, the
last block 232 wide; element 999 computed by block 3, thread 231. The
assembly dump shows Metal AIR for `air64-apple-macosx26.0.0`.

`just gate`: 5 programs in 14.8 s.

## NVIDIA GeForce RTX 5060 Ti (the Arch box), CUDA

Arch Linux, kernel 7.2.9-arch1-1, driver 615.78.08, 16311 MiB GPU memory,
Mojo 1.2.0.dev2026101305 / MAX 26.7.0.dev2026101305 (the same pinned
nightly as the Mac), Rust 1.99.0, 2026-10-16.
`device: api=cuda  name=NVIDIA GeForce RTX 5060 Ti`.

| Program | N | Stages | Reductions | Build | xir_run | Verdict |
| ------- | - | ------ | ---------- | ----- | ------- | ------- |
| saxpy | 8 | 1 | 0 | 4.4 s | 403 ms | 1 of 1 agree, exact |
| threshold | 16 | 1 | 0 | 4.6 s | 456 ms | 2 of 2 agree, exact |
| reduce | 1000 | 0 | 3 | 4.6 s | 392 ms | 3 of 3 agree, exact |
| softmax | 1024 | 2 | 3 | 4.7 s | 393 ms | 2 of 2 agree (largest relative difference 4.77e-7) |
| stats | 1000 | 2 | 2 | 4.5 s | 464 ms | 2 of 2 agree (variance within 6.56e-6) |

The existing Rust emitter and generated Mojo ran without source changes:
Rust loads a `.so`, and Mojo selects CUDA. No OpenCL path is involved.
Provenance on the 1000-element programs matches the Mac: element 999 is
computed by block 3, thread 231. `just asm saxpy` prints PTX targeting
`sm_120a`, with `saxpy_stage0` and `saxpy_trace` kernel entries.

All seven host tests pass. `just gate` passes all five programs in 13.27 s
(the test duration, excluding Cargo build time). Timings above are from
one `just all` run, not steady-state kernel benchmarks.

The original raw logs are committed in
[`evidence/rtx5060-20261016/`](evidence/rtx5060-20261016/); the
[blogging handoff](rtx5060-handoff.md) explains what they establish.
Use `just capture` to collect a fresh run under ignored `work/`. GPU runs required
access outside the coding sandbox, which hides the NVIDIA device nodes.
See [Linux setup](porting-arch-rtx5060.md) for reproduction.

## Tesla M40 and other pre-Turing cards

Not attempted. See `older-gpus.md`.
