# Follow-on: Mojo libraries on older NVIDIA GPUs (a Tesla M40, for example)

Status: a plan, not a result. Nothing here has been run on such a card.

## What Mojo needs to run a kernel on NVIDIA

No CUDA toolkit is needed to build. The Mojo compiler carries its own
LLVM NVPTX backend and emits PTX for the architecture it detects at run
time; that PTX is then assembled to machine code (SASS) and loaded through
the CUDA driver API (`libcuda.so.1`, part of the driver, not the toolkit).
The assembler is either Mojo's bundled one, which requires driver 580 or
newer, or any `ptxas` named by `MODULAR_NVPTX_COMPILER_PATH`.

So the question "does an old card need an older CUDA library" splits in
three: the driver, the assembler, and the compiler's target table.

## The three constraints for a Tesla M40 (Maxwell GM200, sm_52)

1. **The driver.** NVIDIA's 580 series is the last driver branch that
   supports Maxwell, Pascal and Volta; later branches do not drive the
   M40 at all. Driver 580.x therefore satisfies both the card and Mojo's
   "580 or newer" requirement. A machine that must also drive a newer
   card on a newer branch cannot host the M40 (the Arch box's RTX 5060 Ti
   is fine on 580.x today, but that will not last as 590+ becomes the
   norm).
2. **The assembler.** CUDA 13 dropped sm_50 through sm_70 from `ptxas`.
   If Mojo's bundled assembler refuses sm_52, install a CUDA 12.x toolkit
   (12.8 is the last 12 series) somewhere and set
   `MODULAR_NVPTX_COMPILER_PATH=/path/to/cuda-12.x/bin/ptxas`. This is the
   only sense in which "an older CUDA library" is involved: an older
   `ptxas` binary, used at run time, never linked.
3. **The compiler's target table.** Mojo's standard library defines a
   Maxwell family (sm_50 to sm_53) and a Pascal family (sm_60 to sm_62),
   with named entries for the GeForce GTX 970, 1060 and 1080 Ti
   (`Mojo/stdlib/std/_gpu/host/_builtin_targets.mojo`), and its
   "supported archs" message lists `sm_52 (Maxwell)` and `sm_60/sm_61
   (Pascal)`. So the compiler can emit PTX for the M40's architecture. The
   Modular docs still say pre-Turing cards are "not supported out of the
   box" and point at `MODULAR_NVPTX_COMPILER_PATH`; no M40 or M10 is in
   their tables, and the runtime may need the device name mapped to the
   Maxwell family (check what `MLRT_CUDA_DEBUG=1` reports).

The kernels this demo generates use only loads, stores, float arithmetic,
shared memory and barriers. Nothing in them needs tensor cores, bf16 or
any post-Maxwell instruction, which is why they are a reasonable first
thing to try on such a card. Kepler (the Quadro K4200) has no entry in
Mojo's target table at all and stays with X_eTaL-gpu's OpenCL path.

## The experiment, when the card is at hand

1. Host: Linux with driver 580.x (`nvidia-smi` shows the M40 and the
   version). Install the CUDA 12.x toolkit for its `ptxas` only.
2. `scripts/setup.sh`; `just probe` to see whether `DeviceContext()` opens
   the card and what `api` and `name` it reports.
3. `just run saxpy`. If the assembler complains about sm_52, set
   `MODULAR_NVPTX_COMPILER_PATH` and retry. If the compiler emits PTX for
   the wrong architecture, `just asm saxpy` shows the `.target` line it
   chose.
4. `just gate`; record the row (device, driver, assembler used, verdicts,
   PTX `.target`) in `doc/results.md`.

## If Mojo cannot reach the M40

Then the division of labour from the comparison stands: X_eTaL-gpu's
OpenCL emitter covers Kepler, Maxwell and Pascal, and the Mojo emitter
covers Turing and newer plus Metal. The same IR feeds both; only the
emitter and the host runtime differ.
