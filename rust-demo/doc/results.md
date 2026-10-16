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

## From X_eTaL source: Apple M1 Max, Metal (2026-10-16)

The five Accel demos of X_eTaL-gpu (revision 38bae5c) whose lowering
stays in this tool's subset, lowered by `xetal-gpu lower` with nothing
written by hand (`programs/accel-*.xir`), run through the same emitter
and checked against the Rust reference and against X_eTaL's evaluator
baseline for the source (`programs/accel-*.expect`). Same Mojo and MAX
nightly as above.

| Accel demo | Outputs | Stages | Reductions | xir_run | Verdict |
| ---------- | ------- | ------ | ---------- | ------- | ------- |
| saxpy | 1 | 1 | 0 | 50 ms | exact, both oracles |
| threshold | 5 | 1 | 0 | 47 ms | exact, both oracles (ints, `cast`, floored `mod`) |
| reduce-sum | 5 | 4 | 5 | 59 ms | exact, both oracles |
| pipeline | 2 | 2 | 2 | 49 ms | exact, both oracles |
| vector-add | 2 | 1 | 0 | 42 ms | exact, both oracles |

`just gate` now runs ten programs. The Arch re-run is recorded below.

## Ten-program re-run: RTX 5060 Ti, CUDA (2026-10-16)

Verified revision `f95c7ba386198ed07a4855456275b49dc4bc55ad` with the
committed Accel XIR pinned to X_eTaL-gpu `38bae5c`. No sibling checkout,
lowering refresh, or source changes were needed for this verification.
Arch Linux 7.2.9-arch1-1, NVIDIA driver **615.78.08**, 16311 MiB VRAM,
Mojo **1.2.0.dev2026101305 (bb6fedb4)** / MAX 26.7.0.dev2026101305,
Rust 1.99.0.

```text
device: api=cuda  name=NVIDIA GeForce RTX 5060 Ti
```

`just test`, `just all`, `just gate`, and `just capture` all passed:
nine host tests and all ten GPU programs. The separate `just gate` took
25.50 s (test duration); the captured gate took 25.87 s. The times and
ten verbatim verdicts below are
from the subsequent capture starting at 2026-10-16T22:14:38Z.

| Program | xir_run |
| ------- | ------- |
| accel-pipeline | 400.38 ms |
| accel-reduce-sum | 403.85 ms |
| accel-saxpy | 399.50 ms |
| accel-threshold | 397.04 ms |
| accel-vector-add | 386.68 ms |
| reduce | 398.24 ms |
| saxpy | 397.07 ms |
| softmax | 396.25 ms |
| stats | 395.31 ms |
| threshold | 392.37 ms |

In the same program order:

```text
RESULT: 2 of 2 outputs agree with the Rust reference; 2 of 2 with the X_eTaL evaluator (programs/accel-pipeline.expect)
RESULT: 5 of 5 outputs agree with the Rust reference; 5 of 5 with the X_eTaL evaluator (programs/accel-reduce-sum.expect)
RESULT: 1 of 1 outputs agree with the Rust reference; 1 of 1 with the X_eTaL evaluator (programs/accel-saxpy.expect)
RESULT: 5 of 5 outputs agree with the Rust reference; 5 of 5 with the X_eTaL evaluator (programs/accel-threshold.expect)
RESULT: 2 of 2 outputs agree with the Rust reference; 2 of 2 with the X_eTaL evaluator (programs/accel-vector-add.expect)
RESULT: 3 of 3 outputs agree with the Rust reference
RESULT: 1 of 1 outputs agree with the Rust reference
RESULT: 2 of 2 outputs agree with the Rust reference
RESULT: 2 of 2 outputs agree with the Rust reference
RESULT: 2 of 2 outputs agree with the Rust reference
```

The five `accel-*` demos agree exactly with both oracles, including
threshold's integer, cast, and floored-modulo operations. The original
five still pass their existing numerical tolerances. These remain
single-run timings including first-use compilation and transfers.

Capture evidence is committed under
[`evidence/rtx5060-20261016-ten-programs/`](evidence/rtx5060-20261016-ten-programs/):
`environment.log`, `host-tests.log`, `all.log`, `gate.log`, and
`assembly.log`. The earlier five-program evidence remains unchanged.

Re-run when X_eTaL-gpu lowering changes the emitted XIR for these demos:
use `just refresh-xtl` with the built sibling, review
`git diff -- programs/accel-*`, then repeat the checks and capture above.
The committed programs can be verified without X_eTaL-gpu on the machine.

## Tesla M40 and other pre-Turing cards

Not attempted. See `older-gpus.md`.
