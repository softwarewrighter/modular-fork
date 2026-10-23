#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$root"
out=${1:-work/results}
mkdir -p "$out"
out=$(cd "$out" && pwd)
export ADRENO_DUMP_DIR="$out"
{
    date -u
    uname -a
    cat revisions.txt
    sha256sum bin/mojo-adreno lib/libadreno_mojo_opencl.so source/*
    clinfo
} > "$out/environment.log" 2>&1
echo 'Mojo source (C launcher -> Cortex-A53 Mojo host -> OpenCL bridge -> FD702):'
cat source/threshold.mojo
timeout 120 bin/mojo-adreno > "$out/mojo.out" 2> "$out/mojo.log"
cat "$out/mojo.log"
cat "$out/mojo.out"
cp threshold.expect "$out/threshold.expect"
python3 scripts/compare-out.py threshold.expect "$out/mojo.out" 1e-5
if timeout 120 bin/mojo-adreno --corrupt-output > "$out/corrupt.out" 2> "$out/corrupt.log"; then
    echo 'FAIL: corrupted output was accepted' >&2
    exit 1
fi
grep -q 'Mismatch at 23' "$out/corrupt.log"
echo 'PASS: deliberately corrupted final output was rejected'
echo 'RESULT: 24 of 24 outputs agree with X_eTaL baseline and Mojo reference on physical FD702'
