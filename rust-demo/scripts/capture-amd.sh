#!/usr/bin/env bash
# AMD listings for the lowered threshold program, with no AMD GPU present:
# Mojo cross-compiles the generated kernels for a named AMD architecture
# (default gfx1100, RDNA3) and writes one .amdgcn side file per kernel.
# Listings only; nothing runs. Text only; run from any directory.
#   scripts/capture-amd.sh [OUT_DIR] [ARCH]   (default work/amd-evidence gfx1100)
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
out=${1:-"$root/work/amd-evidence"}
arch=${2:-gfx1100}
mkdir -p "$out"
out=$(cd -- "$out" && pwd)
work="$root/work/accel-threshold"
mojo="$root/.venv/bin/mojo"
{
    date -u
    git -C "$root" rev-parse HEAD
    uname -srm
    sysctl -n machdep.cpu.brand_string 2>/dev/null || grep -m1 "model name" /proc/cpuinfo || true
    "$mojo" --version
    rustc --version
    echo "AMD GPU present: none (cross-compiled for $arch)"
} > "$out/environment.log" 2>&1
cargo build --release -q --manifest-path "$root/Cargo.toml"
(
    set -x
    "$root/target/release/xir-mojo" run "$root/programs/accel-threshold.xir" --emit-only
    "$mojo" build "$work/accel-threshold.mojo" --target-accelerator="$arch" --emit asm -o "$work/accel-threshold-$arch.s"
) > "$out/build.log" 2>&1
cp "$work/accel-threshold.mojo" "$out/"
cp "$work"/accel-threshold-"$arch"_*stage0*.amdgcn "$out/accel-threshold-stage0.$arch.amdgcn"
cp "$work"/accel-threshold-"$arch"_*trace*.amdgcn "$out/accel-threshold-trace.$arch.amdgcn"
ls -l "$out"
