# Showing that the code ran on the GPU

"It printed the right numbers" does not show where they were computed.
The tool stacks five kinds of evidence, from what the library reports to
what the operating system observes; the first three are printed on every
run, the last two are for a skeptic with a second terminal.

## 1. The device the library opened

```
device: api=metal  name=Apple M1 Max
```

`xir_device_info` asks the `DeviceContext` it opened for its API and
name. On the Arch box this reads `api=cuda  name=NVIDIA GeForce RTX 5060 Ti`.
A CPU-only build would say `api=cpu`, and the device gate test refuses it.

## 2. Provenance: which thread computed each element

```
launch: 4 block(s) of 256 threads for 1000 element(s)
proof: element 0 computed by block 0 thread 0; element 999 by block 3 thread 231; 4 distinct block(s), 256 distinct thread index(es)
       elements per block: block 0: 256, block 1: 256, block 2: 256, block 3: 232
```

`xir_trace` runs a kernel whose only job is to write `block_idx.x` and
`thread_idx.x` into two arrays. The host reads them back and summarizes.
Those values exist only inside a GPU grid; a sequential loop has no block
or thread index to report. The geometry (1000 elements, blocks of 256,
the last block 232 wide) is the one every elementwise kernel in the
library uses.

## 3. The device assembly

```sh
just asm saxpy          # xir-mojo run programs/saxpy.xir --dump-asm
```

builds with `-D DUMP_GPU_ASM=true`, so when the kernel is first compiled,
inside the Rust process, Mojo prints what the device compiler received.
On this Mac that is Metal AIR (LLVM IR for `target triple =
"air64-apple-macosx26.0.0"`, with `@air.thread_position_in_threadgroup.x()`
and friends); on NVIDIA it is PTX with a `.target sm_120` line for the
RTX 5060 Ti. The kernel names in the dump match the `def stage0(...)` and
`def reduce_add(...)` the generator wrote, so the text ties the source to
the device.

## 4. An outside observer

Run a large program in one terminal and watch the GPU in another.

macOS (needs root; samples GPU residency and power):

```sh
sudo powermetrics --samplers gpu_power -i 200 -n 20
```

Linux with NVIDIA (the process appears while it runs; utilization ticks):

```sh
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv -l 1
nvidia-smi dmon -s u
```

For a run long enough to see, make a program with a larger N (the
generator accepts any N up to 65536 for programs with reductions, any N
without) and loop it: `for i in $(seq 20); do just run softmax; done`.

## 5. A negative control (Linux)

Hide the GPU and the same library must fail, not fall back:

```sh
CUDA_VISIBLE_DEVICES= ./target/release/xir-mojo run programs/saxpy.xir
```

`DeviceContext()` raises, `xir_run` returns 1 and the tool stops with
"the device failed". There is no CPU path in the generated code to fall
back to. (macOS has no equivalent switch for the built-in GPU.)

## What the tests check

`just test` (no GPU) checks the parser, the reference, the plan and the
emitted text. `just gate` runs every program through the tool on the GPU
and asserts: the `device:` line names a non-CPU API, the `proof:` line is
present, and every output agrees with the Rust reference.
