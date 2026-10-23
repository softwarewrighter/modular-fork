# Scaffold handoff

Step 001 provides an empty `adreno-vk` library, `just gate`, a read-only
board inventory, and project-local host configuration. The gate checks Rust
formatting, tests and clippy, shell syntax, and mocked software/Adreno driver
classification. The mocks test reporting, not physical hardware.

## Host setup

Run from `adreno-poc`:

```sh
just setup
source work/host.env
just gate
```

Setup records installed Arch packages and missing tools in
`work/environment.log`. Default setup only prepares directories and shell
configuration. It does not install anything. Build output and Cargo downloads
stay inside this directory after sourcing the configuration.

When cross compilation is needed, `bash scripts/setup-host.sh --prepare-cross`
installs a separate minimal stable Rust toolchain and the
`aarch64-unknown-linux-gnu` target under `work/rustup`. Source `work/host.env`
again afterwards. This option requires network access and is not part of the
gate. On Arch it uses the system `aarch64-linux-gnu-gcc` linker; it never
installs system packages. On Mac it also creates `work/.venv`, installs
`ziglang` there and installs `cargo-zigbuild` under `work/bin`. Cross builds
on Mac use `cargo zigbuild --target aarch64-unknown-linux-gnu`.

For Mac Vulkan runs, supply an unpacked MoltenVK distribution with `lib/`
and `share/vulkan/icd.d/MoltenVK_icd.json` under `work/MoltenVK`. Alternatively
set `MOLTENVK_SOURCE` to that distribution when using `--prepare-cross` to
copy it there. Preserve the relative paths in the ICD manifest. No SDK is
downloaded automatically. Mac setup and provisioning have not run here.

The Arch scaffold run found `clinfo`, `glslangValidator` and `spirv-dis`.
`vulkaninfo`, `aarch64-linux-gnu-gcc`, and the aarch64 Rust target were absent.
Before steps 003 and 004, the user can install the system tools with:

```sh
sudo pacman -S --needed vulkan-tools aarch64-linux-gnu-gcc
```

Rerun setup after package installation to record package versions. This
command has not been run by this session.

## Board inventory

Copy `scripts/inventory.sh` to the UNO Q and run it using Bash:

```sh
bash inventory.sh unoq-inventory-20261023
```

Return the entire directory. Missing commands and nonzero exits remain in
the logs. Full Vulkan output retains device names, driver names, queue flags
and storage-buffer limits. If any software renderer is listed, the verdict
requires per-device review even if physical devices are listed too. Review
the OpenCL platform and device names before attributing rusticl to Adreno.
Step 002 decides OpenCL-first versus Vulkan-first from the actual board logs.

## Evidence and what this does not establish

`docs/evidence/arch-scaffold-20261023/` contains the setup environment and gate
log. No SDK, binary, wheel or shader binary is committed. No board was
contacted. No Vulkan or OpenCL dispatch, board capability, numerical result,
Mac execution, or cross-build readiness is established by this scaffold.
