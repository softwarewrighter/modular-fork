# UNO Q inventory and backend decision

Collected over `ssh -p 2222 arduino@localhost` on host session date
2026-10-23. Evidence: `docs/evidence/unoq-inventory-20261023/`.
The board clock reports 2025-09-09; timestamps inside the raw logs are
not reliable collection dates. The clock was not changed.

## Board and resources

| Item | Observed |
| --- | --- |
| OS | Debian 13.1 (trixie), aarch64 |
| Kernel | 6.16.7-g0dd6551ae96b |
| CPU | Four logical CPUs, reported as Qualcomm Kryo-V2, max 2016 MHz |
| glibc | 2.41 (libc6 2.41-12) |
| RAM | 1.7 GiB total, 1.3 GiB available at collection |
| Swap | 870 MiB, unused at collection |
| Root disk | 9.8 GiB total, 3.1 GiB available |
| Arduino home disk | 3.6 GiB total, 2.9 GiB available |
| DRM | card0 and renderD128; arduino belongs to video and render |
| Kernel graphics module | msm loaded |

glibc exceeds the plan's manylinux_2_34 baseline. That is only a prerequisite
for the later Mojo installation experiment, not proof that Mojo will run.
The observed memory/disk availability is a snapshot, not a capacity study.

## Physical Vulkan device

`vulkan.log` lists two devices. Device 0 is `Turnip Adreno (TM) 702`,
type INTEGRATED_GPU, device ID 0x7000200, driver `turnip Mesa driver`,
Mesa 25.2.6-1~bpo13+1. Its reported API is **Vulkan 1.0.318**.
Device 1 is the software CPU renderer `llvmpipe (LLVM 19.1.7, 128 bits)`.
The loader's Vulkan 1.4.309 and llvmpipe's 1.4.318 do not describe the
physical Adreno's API support.

The physical device has queue family 0 with one queue supporting GRAPHICS,
COMPUTE and TRANSFER. Its relevant limits are:

| Limit | Adreno value |
| --- | --- |
| maxStorageBufferRange | 134217728 bytes (128 MiB) |
| maxComputeWorkGroupCount | 65535 x 65535 x 65535 |
| maxComputeWorkGroupInvocations | 512 |
| maxComputeWorkGroupSize | 512 x 512 x 64 |
| maxComputeSharedMemorySize | 16384 bytes |
| Device-local heap | 912596992 bytes (870.32 MiB) |

A HOST_VISIBLE, HOST_COHERENT, DEVICE_LOCAL memory type is exposed. The
256-thread workgroup and 4 MiB buffers of the host vector-add demo fit
these reported limits. Its current Vulkan >= 1.1 selection requirement
would nevertheless reject the Adreno. Step 005 needs a Vulkan 1.0-compatible
path, including extension-aware property queries and shader validation for
that environment, before attempting a physical dispatch. Do not select
llvmpipe to bypass this requirement.

The inventory script's conservative verdict says a software renderer was
detected. Per-device inspection above establishes that a physical Adreno
is also listed; the verdict is not a claim that only software is present.

## Physical OpenCL device

`opencl.log` reports one platform, Mesa rusticl, and one device, `FD702`,
vendor Qualcomm, type GPU. The device and compiler are available. Platform
and device advertise OpenCL 3.0; OpenCL C 1.2 is reported and listed among
the supported language versions. Driver: Mesa 25.2.6-1~bpo13+1.

The maximum workgroup size is 512, work-item sizes are 1024 x 1024 x 64,
local memory is 16 KiB, and reported global memory is 1825193984 bytes.
Do not use the reported single-allocation limit as an allocation budget:
the board shares memory with its OS and applications.

`clCreateContextFromType` for GPU succeeds and identifies FD702. No
environment overrides were applied by the inventory session. No OpenCL
kernel has been compiled or dispatched by this inventory.

## Decision and next work

**OpenCL-first: go for the existing X_eTaL-gpu path.** The physical GPU and
compiler are exposed through rusticl, with the OpenCL C 1.2 language that
the existing emitter uses. Step 004 must still verify compilation,
dispatch and every output against the evaluator before calling it working.

**Vulkan: go for a Vulkan 1.0 compatibility experiment.** Physical compute
queues and appropriate buffer/workgroup limits are exposed, but the host
demo's 1.1 minimum is incompatible with this driver as reported. Keep
step 005's real-Adreno dispatch acceptance criterion; modify the host
code with tests when that step is begun. No compiler-side work is justified
by inventory alone.

## Evidence and what this does not establish

The original inventory script was copied to `~/adreno-poc/work/` and run
there; its complete output was retrieved. `details.log` supplements package
versions, CPU information, user groups and libraries. The initial
`libraries.log` is empty because unqualified `ldconfig` was unavailable in
the noninteractive PATH; the supplemental `/sbin/ldconfig -p` succeeds and
lists Vulkan, rusticl, the OpenCL loader and GLES libraries. No packages,
drivers or system settings were changed on the board.

This establishes enumeration and reported capabilities, not numerical
correctness, kernel execution, throughput, thermal behavior or the benefit
of a 4 GiB board. No GPU dispatch, X_eTaL demo, Mojo execution or cross-built
binary was run. `build.log` records the local project gate, not a board build.
