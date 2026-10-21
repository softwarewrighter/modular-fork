#!/usr/bin/env bash
# CPU evidence for the lowered threshold program: the same generated Mojo
# built with -D XIR_CPU=true (a CPU DeviceContext; each stage a parallel
# range over the elements), its host assembly with the kernel body, and
# the run checked against the Rust reference and X_eTaL's evaluator
# output. Text only; run from any directory, on any machine with the
# pinned nightly (no GPU needed).
#   scripts/capture-cpu.sh [OUT_DIR]   (default work/cpu-evidence)
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
out=${1:-"$root/work/cpu-evidence"}
mkdir -p "$out"
out=$(cd -- "$out" && pwd)
work="$root/work/accel-threshold"
mojo="$root/.venv/bin/mojo"
{
    date -u
    git -C "$root" rev-parse HEAD
    uname -srm
    sysctl -n machdep.cpu.brand_string 2>/dev/null || grep -m1 "model name" /proc/cpuinfo || true
    sysctl -n hw.ncpu 2>/dev/null | sed 's/^/logical cpus: /' || nproc | sed 's/^/logical cpus: /' || true
    "$mojo" --version
    rustc --version
} > "$out/environment.log" 2>&1
cargo build --release -q --manifest-path "$root/Cargo.toml"
(
    set -x
    "$root/target/release/xir-mojo" run "$root/programs/accel-threshold.xir" --emit-only
    "$mojo" build "$work/accel-threshold.mojo" -D XIR_CPU=true --emit asm -o "$work/accel-threshold-cpu.s"
) > "$out/build.log" 2>&1
cp "$work/accel-threshold.mojo" "$out/"
# The host assembly: everything before xir_run itself, which is the closures
# xir_run hands to the CPU context; the range body (the kernel) is the one
# with the float arithmetic.
sed -n '1,/^_xir_run:$/p' "$work/accel-threshold-cpu.s" > "$out/accel-threshold-xir_run-closures.s"
( cd "$root" && target/release/xir-mojo run programs/accel-threshold.xir --cpu ) > "$out/cpu.log" 2>&1
grep -E "^(built|cpu|device|launch|ran|proof|RESULT):" "$out/cpu.log"
