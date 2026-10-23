#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
out=${1:-docs/evidence/arch-host-vulkan-20261023}
mkdir -p -- "$out"
bash scripts/setup-host.sh > "$out/setup.log" 2>&1
cp work/environment.log "$out/environment.log"
{
    git rev-parse HEAD
    sha256sum shaders/vector_add.comp Cargo.lock
    vulkaninfo --summary
} >> "$out/environment.log" 2>&1
just gate > "$out/build.log" 2>&1
just gpu-check > "$out/run.log" 2>&1
# Keep shader binaries only in ignored build output. Commit text disassembly.
modules=(target/release/build/adreno-vk-*/out/vector_add.spv)
test "${#modules[@]}" = 1
spirv-val --target-env vulkan1.1 "${modules[0]}" > "$out/spirv-validation.log" 2>&1
spirv-dis "${modules[0]}" -o "$out/vector_add.spvasm"
echo 'SPIR-V validated for Vulkan 1.1' >> "$out/spirv-validation.log"
cat "$out/run.log"
