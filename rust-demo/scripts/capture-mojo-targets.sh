#!/usr/bin/env bash
# Offline AMD assembly, plus a real Mojo CPU build and oracle-checked run.
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
out=${1:-"$root/work/mojo-target-evidence"}
mkdir -p "$out"
out=$(cd -- "$out" && pwd)
work="$root/work/accel-threshold"
mojo=${MOJO:-"$root/.venv/bin/mojo"}
export MODULAR_CACHE_DIR="$root/work/modular-cache"
{
    date -u
    git -C "$root" rev-parse HEAD
    uname -a
    lscpu
    "$mojo" --version
} > "$out/environment.log" 2>&1
(
    set -x
    cargo run --manifest-path "$root/Cargo.toml" -- run "$root/programs/accel-threshold.xir" --emit-only
    cargo run --manifest-path "$root/Cargo.toml" -- emit-cpu "$root/programs/accel-threshold.xir"
    cp "$work/accel-threshold.mojo" "$work/accel-threshold.cpu.mojo" "$out/"
    "$mojo" build --target-accelerator=amdgpu:gfx1100 --emit asm "$out/accel-threshold.mojo" -o "$work/mojo-amd-host.s"
    cp "$work"/mojo-amd-host_*.amdgcn "$out/"
    "$mojo" build --emit asm "$out/accel-threshold.cpu.mojo" -o "$out/threshold-cpu.s"
    "$mojo" build "$out/accel-threshold.cpu.mojo" -o "$work/threshold-mojo-cpu"
) > "$out/build.log" 2>&1
"$work/threshold-mojo-cpu" > "$out/cpu.log" 2>&1
cat "$out/cpu.log"
