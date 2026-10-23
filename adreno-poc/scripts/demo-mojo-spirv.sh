#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$root"
out=${1:-work/results}
mkdir -p "$out"
out=$(cd "$out" && pwd)
{
    date -u
    uname -a
    sha256sum mojo-spirv activations.spv lib/libadreno_mojo_opencl.so source/*
    clinfo
} > "$out/environment.log" 2>&1
timeout 120 ./mojo-spirv activations.spv > "$out/run.out" 2> "$out/run.log"
cat "$out/run.log" "$out/run.out"
python3 scripts/compare-out.py threshold.expect "$out/run.out" 1e-5
cp threshold.expect "$out/threshold.expect"
if timeout 120 ./mojo-spirv activations.spv --corrupt-output > "$out/negative.out" 2> "$out/negative.log"; then
    echo 'FAIL: corrupt final output accepted' >&2; exit 1
fi
grep -q 'Mismatch at 23' "$out/negative.log"
echo 'PASS: corrupted final output rejected'
for n in 1 65 129; do
    timeout 120 ./mojo-spirv activations.spv --count "$n" > "$out/count-$n.out" 2> "$out/count-$n.log"
    echo "PASS: n=$n, all $((3*n)) values checked by Mojo and launcher"
done
python3 -c 'import pathlib,sys; pathlib.Path(sys.argv[1]).write_bytes(bytes(20))' "$out/invalid.spv"
if timeout 120 ./mojo-spirv "$out/invalid.spv" > "$out/invalid.out" 2> "$out/invalid.log"; then
    echo 'FAIL: invalid module accepted' >&2; exit 1
fi
grep -q 'SPIR-V bridge error' "$out/invalid.log"
echo 'PASS: invalid IL rejected and error propagated'
echo 'RESULT: Mojo-authored kernel on FD702; 24 of 24 fixture outputs agree with both oracles'
