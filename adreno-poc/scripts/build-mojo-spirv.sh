#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$root"
source work/host.env
export MODULAR_CACHE_DIR="$root/work/modular-cache"
mojo=${MOJO:-"$root/../rust-demo/.venv/bin/mojo"}
"$mojo" --version | grep -F 1.2.0.dev2026101305
build="$root/work/mojo-spirv-build"
bundle="$root/work/mojo-spirv-bundle"
mkdir -p "$build" "$bundle/lib" "$bundle/scripts" "$bundle/source"
"$mojo" build mojo/activation_gpu.mojo --target-accelerator=nvidia:120 --emit llvm -o "$build/mojo.ll"
modules=("$build"/*.nvptx.ll)
test "${#modules[@]}" = 1
python3 scripts/nvptx-to-spirv.py "${modules[0]}" "$build/activations.spirv.ll"
llvm-as "$build/activations.spirv.ll" -o "$build/activations.bc"
llc -mtriple=spirv64v1.0-unknown-unknown -filetype=obj "$build/activations.bc" -o "$bundle/activations.spv"
spirv-val --target-env opencl2.1 "$bundle/activations.spv"
spirv-dis "$bundle/activations.spv" -o "$build/activations.spvasm"
cargo build --locked --offline --manifest-path mojo-opencl-bridge/Cargo.toml --release --target aarch64-unknown-linux-gnu
"$mojo" build mojo/activation_spirv_host.mojo --target-triple aarch64-unknown-linux-gnu --target-cpu cortex-a53 --emit object -o "$build/host.o"
if aarch64-linux-gnu-nm -u "$build/host.o" | grep -q KGEN_; then
    echo 'Unexpected standard Mojo runtime dependency' >&2; exit 1
fi
aarch64-linux-gnu-gcc -Wall -Wextra -Werror mojo/spirv_launcher.c "$build/host.o" \
    -Ltarget/aarch64-unknown-linux-gnu/release -ladreno_mojo_opencl \
    -Wl,-rpath,'$ORIGIN/lib' -o "$bundle/mojo-spirv"
cp target/aarch64-unknown-linux-gnu/release/libadreno_mojo_opencl.so "$bundle/lib/"
cp scripts/demo-mojo-spirv.sh work/xetal-gpu/scripts/compare-out.py "$bundle/scripts/"
cp mojo/activation_gpu.mojo mojo/activation_spirv_host.mojo "$bundle/source/"
head -3 docs/evidence/unoq-xetal-opencl-20261023/threshold.expect > "$bundle/threshold.expect"
tar -czf work/mojo-spirv-bundle.tar.gz -C "$bundle" .
echo 'Bundle: work/mojo-spirv-bundle.tar.gz'
