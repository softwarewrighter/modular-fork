#!/usr/bin/env bash
# Run from any directory. The output is text evidence; no binaries are retained there.
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
out=${1:-"$root/work/cuda-evidence"}
mkdir -p "$out"
out=$(cd -- "$out" && pwd)
work="$root/work/accel-threshold"
{
    date -u
    git -C "$root" rev-parse HEAD
    nvcc --version
    nvidia-smi
    "$root/.venv/bin/mojo" --version
} > "$out/environment.log" 2>&1
cargo run --manifest-path "$root/Cargo.toml" -- emit-cuda "$root/programs/accel-threshold.xir"
cargo run --manifest-path "$root/Cargo.toml" -- run "$root/programs/accel-threshold.xir" --emit-only
cp "$work/accel-threshold.cu" "$work/accel-threshold.mojo" "$out/"
(
    set -x
    nvcc -O3 -arch=compute_120a -ptx "$work/accel-threshold.cu" -o "$out/accel-threshold.ptx"
    nvcc -O3 --fmad=false -arch=compute_120a -ptx "$work/accel-threshold.cu" -o "$out/accel-threshold-no-fma.ptx"
    nvcc -O3 -arch=sm_120a -cubin "$work/accel-threshold.cu" -o "$work/accel-threshold.cubin"
    nvdisasm "$work/accel-threshold.cubin" > "$out/accel-threshold.sass"
    nvcc -O3 -arch=sm_120a "$work/accel-threshold.cu" -o "$work/threshold-cuda"
    c++ -O3 -DXIR_CPU_ONLY -x c++ "$work/accel-threshold.cu" -o "$work/threshold-cpu"
) > "$out/build.log" 2>&1
"$work/threshold-cpu" > "$out/cpu.log" 2>&1
"$work/threshold-cuda" > "$out/cuda.log" 2>&1
cat "$out/cuda.log"
