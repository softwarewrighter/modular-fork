#!/usr/bin/env bash
# Apple silicon evidence for the lowered threshold program: the generated
# Mojo, Mojo's Metal AIR for its kernels (as LLVM IR side files and as the
# DUMP_GPU_ASM dump), and the run on this Mac's GPU checked against the Rust
# reference and X_eTaL's evaluator output. Text only; run from any directory.
#   scripts/capture-metal.sh [OUT_DIR]   (default work/metal-evidence)
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
out=${1:-"$root/work/metal-evidence"}
mkdir -p "$out"
out=$(cd -- "$out" && pwd)
work="$root/work/accel-threshold"
mojo="$root/.venv/bin/mojo"
{
    date -u
    git -C "$root" rev-parse HEAD
    sw_vers
    xcodebuild -version
    sysctl -n machdep.cpu.brand_string
    system_profiler SPDisplaysDataType 2>/dev/null | grep -E "Chipset Model|Total Number of Cores|Metal" | sed 's/^ *//'
    "$mojo" --version
    rustc --version
} > "$out/environment.log" 2>&1
cargo build --release -q --manifest-path "$root/Cargo.toml"
(
    set -x
    "$root/target/release/xir-mojo" run "$root/programs/accel-threshold.xir" --emit-only
    "$mojo" build "$work/accel-threshold.mojo" --target-accelerator=metal:4 --emit asm -o "$work/accel-threshold-metal.s"
) > "$out/build.log" 2>&1
cp "$work/accel-threshold.mojo" "$out/"
for f in "$work"/accel-threshold-metal_*stage0*.ll; do cp "$f" "$out/accel-threshold-stage0.air.ll"; done
for f in "$work"/accel-threshold-metal_*trace*.ll; do cp "$f" "$out/accel-threshold-trace.air.ll"; done
# The run: build as a shared library with the dump switched on, load, run on
# the GPU, check against both oracles, and print the AIR the device received.
( cd "$root" && target/release/xir-mojo run programs/accel-threshold.xir --dump-asm ) > "$out/metal.log" 2>&1
grep -E "^(device|launch|ran|RESULT):|^  (gpu|rust|xetal|output|first|last|agree|elem)" "$out/metal.log" || true
tail -1 "$out/metal.log"
