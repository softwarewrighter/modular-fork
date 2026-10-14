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

Not run yet. See `porting-arch-rtx5060.md` for the steps and what to record.

## Tesla M40 and other pre-Turing cards

Not attempted. See `older-gpus.md`.
