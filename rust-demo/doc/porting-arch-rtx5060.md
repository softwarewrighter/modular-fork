# The same demo on the Arch Linux box with the RTX 5060 Ti (16 GB)

Nothing in `src/` or `programs/` is Mac-specific. The differences are the
wheel (Linux x86_64), the library suffix (`.so`), the device API (`cuda`)
and the outside observers (`nvidia-smi`). This was not run there yet; the
steps below are what to do and what to record.

## Steps

1. Clone the fork's `experimental` branch and enter `rust-demo/`.
2. Rust stable via rustup (the crate needs nothing recent; X_eTaL's own
   pins need Rust 1.95, this one does not). `just` from the Arch repos.
3. The driver: `nvidia-smi` must show driver 580 or newer (Mojo's bundled
   PTX assembler checks the driver version). Blackwell consumer cards
   (sm_120) need a recent driver anyway. If the driver is older than 580,
   install the `cuda` package and point Mojo at its assembler:

   ```sh
   export MODULAR_NVPTX_COMPILER_PATH=/opt/cuda/bin/ptxas
   ```

4. `scripts/setup.sh` (Linux x86_64 wheel, glibc 2.34 or newer; Arch is
   fine). It prints the GPU name, driver and memory from `nvidia-smi` and
   warns if the driver is older than 580.
5. `just test`, then `just run saxpy`, then `just gate`.

## What to expect

```
built: .../work/saxpy/libsaxpy.so (.../.venv/bin/mojo build --emit shared-lib) in ...
device: api=cuda  name=NVIDIA GeForce RTX 5060 Ti
launch: 1 block(s) of 256 threads for 8 element(s)
proof: element 0 computed by block 0 thread 0; element 7 by block 0 thread 7; ...
```

`just asm saxpy` prints PTX instead of Metal AIR: look for `.target sm_120`
(or `sm_120a`) and `.entry` lines named after `stage0` and `reduce_add`.

## If it does not

- "GPU not detected" with a GPU in `nvidia-smi`: `libcuda.so.1` must be
  findable (`/usr/lib/libcuda.so.1` on Arch). `MLRT_CUDA_DEBUG=1` logs the
  detection.
- The shared library cannot find `libKGENCompilerRTShared.so` or
  `libAsyncRTMojoBindings.so`: check the rpath `scripts/build-mojo-lib.sh`
  prints; if the Linux wheel did not embed one, set
  `LD_LIBRARY_PATH=$PWD/.venv/lib/python3.12/site-packages/modular/lib`
  before running the tool.
- A ptxas error naming the architecture: the driver's assembler is older
  than the card; use the `cuda` package's `ptxas` as in step 3.

## What to record (a row for the hardware table)

Device name and API as printed, driver version, Mojo version
(`.venv/bin/mojo --version`), the five programs' verdicts, the build time
per program and the `xir_run` time, and the first lines of the PTX dump.
Add them to `doc/results.md` beside the Mac's, as X_eTaL-gpu's results
tables name their card.
