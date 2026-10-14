# Mojo as a library callable from Rust

How a Mojo source file becomes a shared library with C exports, and how a
Rust program loads it and calls into it. This is what `src/host.rs` does
for generated code and what `scripts/build-mojo-lib.sh` does for any
hand-written file. Nothing here builds the Mojo compiler: the compiler
comes from the `max` wheel that `scripts/setup.sh` installs.

## The recipe

1. Mark each function to call from Rust with `@export("c_name")` and the
   `abi("C")` effect. Arguments and results are C-compatible scalars
   (`Int32`, `Int64`, `Float32`) and pointers (`Pointer[Float32, MutAnyOrigin]`,
   `Pointer[UInt8, MutAnyOrigin]`; a pointer to pointers for arrays of arrays).
2. Call `initialize_runtime()` (from `std.runtime`) at the top of every
   exported function. A shared library has no Mojo `main()`, so the Mojo
   runtime (the thread pool and the GPU runtime's bookkeeping) is never set
   up otherwise, and runtime-dependent calls crash. The call is idempotent.
3. Build:

   ```sh
   .venv/bin/mojo build kernel.mojo --emit shared-lib -o libkernel.dylib   # .so on Linux
   ```

   The library depends on two Modular runtime libraries,
   `libKGENCompilerRTShared` and `libAsyncRTMojoBindings`, and the Mojo
   compiler embeds an rpath to where the wheel put them
   (`.venv/lib/python3.12/site-packages/modular/lib`), so a host that
   `dlopen`s the library by absolute path needs no extra search path.
   `scripts/build-mojo-lib.sh` prints the exports, the rpaths and the
   dependencies after building.
4. In Rust, open it with `libloading` and look up each symbol as an
   `unsafe extern "C" fn` of the matching signature (`src/host.rs`).

GPU code needs nothing more: `DeviceContext()` inside an exported function
opens the Metal (or CUDA, or HIP) device the same way it does in a Mojo
executable, and `ctx.enqueue_function[kernel](...)` compiles the kernel for
that device on first use, inside the Rust process.

## The C ABI the generated libraries export

| Export | Signature (C) | What |
| ------ | ------------- | ---- |
| `xir_init` | `int32 ()` | initializes the runtime; 1 when the build targets a GPU |
| `xir_device_info` | `int64 (uint8_t* buf, int64 cap)` | writes `api=metal;name=Apple M1 Max` (or `api=cuda;name=...`); its length, or -1 |
| `xir_launch` | `int32 (int32* blocks, int32* tpb)` | the grid every elementwise kernel uses |
| `xir_trace` | `int32 (int32* block_of, int32* thread_of, int64 n)` | runs the provenance kernel |
| `xir_run` | `int32 (const float* const* inputs, float* const* outputs, int64 n)` | runs the program |

Every array is `float32`, row-major, owned by the caller; bools travel as
0.0 and 1.0. `n` must equal the N the library was generated for (the
kernels are specialized per shape, as X_eTaL-gpu's are); 2 says it did not,
1 says the device failed (the Mojo side prints why).

## What was found on the way (this Mac, Mojo 1.2.0.dev2026101305)

- The `mojo` wheel alone has no `max.gpu` package and no `layout`
  package; GPU code needs the `max` wheel (which includes Mojo). The
  setup script installs `max`.
- On Metal, kernel arguments that are device memory must be passed as
  `DeviceBuffer`s to `enqueue_function`; the kernel declares them as
  `Pointer[Float32, ...]`. Passing `buffer.unsafe_ptr()` fails inside the
  Metal argument encoder at compile time.
- `out` is a Mojo keyword (an argument convention); a parameter cannot be
  named `out`.
- Positional indexing on `Pointer` (`p[i]`) is deprecated in favour of
  `p[unsafe_offset=i]`; the generator writes the latter.
- A Python venv is not relocatable: moving `.venv` breaks the `mojo`
  launcher. Delete it and run `scripts/setup.sh` again.
- `Failed to initialize Crashpad` on stderr from every `mojo` invocation is
  harmless noise (crash reporting is unavailable); the scripts filter it.
- The assembly dump is a compile-time define, not an environment variable:
  `mojo build -D DUMP_GPU_ASM=true` makes the library print each kernel's
  device assembly (Metal AIR here, PTX on NVIDIA) when the kernel is first
  compiled, which is at run time in the host process. A path form
  (`-D DUMP_GPU_ASM=/abs/path/%.asm`) exists but failed to build here.
