#!/usr/bin/env bash
# Run from a deployed bundle, with this script under bundle/scripts/.
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$root"
out=${1:-work/results}
mkdir -p "$out"
out=$(cd "$out" && pwd)
tool="$root/bin/xetal-gpu"
export XETAL_PATH="$root/libs/Accel/src:$root/lib"
export XETAL_GPU_NO_CACHE=1
{
    date -u
    uname -a
    getconf GNU_LIBC_VERSION
    cat revisions.txt
    sha256sum "$tool" scripts/demo-xetal-opencl.sh scripts/select-adreno.py scripts/compare-out.py schedules/adreno-702.toml
    clinfo
} > "$out/environment.log" 2>&1
cp schedules/adreno-702.toml "$out/adreno-702.toml"
"$tool" devices | tee "$out/devices.log"
device=$(python3 scripts/select-adreno.py < "$out/devices.log")
echo "Selected physical Adreno: $device (FD702, Qualcomm GPU)"
echo 'Driver identification (full details in environment.log):'
grep -E 'Device Name|Device Vendor |Driver Version|Device Type' "$out/environment.log"
printf 'XETAL_PATH=%s\nXETAL_GPU_NO_CACHE=1\n' "$XETAL_PATH" > "$out/commands.log"
for demo in threshold vector-add saxpy reduce-sum pipeline; do
    src="libs/Accel/demos/$demo.xtl"
    want="libs/Accel/tests/demo-$demo.out"
    echo "=== X_eTaL source: $demo ==="
    cat "$src"
    cp "$src" "$out/$demo.xtl"
    cp "$want" "$out/$demo.expect"
    printf '%q lower %q\n' "$tool" "$src" >> "$out/commands.log"
    timeout 120 "$tool" lower "$src" > "$out/$demo.xir" 2> "$out/$demo.lower.log"
    printf '%q kernel %q --schedule schedules/adreno-702.toml\n' "$tool" "$src" >> "$out/commands.log"
    timeout 120 "$tool" kernel "$src" --schedule schedules/adreno-702.toml > "$out/$demo.cl" 2> "$out/$demo.kernel.log"
    printf '%q run %q --device cpu\n' "$tool" "$src" >> "$out/commands.log"
    timeout 120 "$tool" run "$src" --device cpu > "$out/$demo.cpu.out" 2> "$out/$demo.cpu.log"
    python3 scripts/compare-out.py "$want" "$out/$demo.cpu.out" 0
    printf '%q run %q --device %q --schedule schedules/adreno-702.toml --time\n' "$tool" "$src" "$device" >> "$out/commands.log"
    timeout 120 "$tool" run "$src" --device "$device" --schedule schedules/adreno-702.toml --time > "$out/$demo.gpu.out" 2> "$out/$demo.gpu.log"
    echo 'Evaluator baseline:'; cat "$want"
    echo 'Adreno output:'; cat "$out/$demo.gpu.out"
    python3 scripts/compare-out.py "$want" "$out/$demo.gpu.out" 1e-5
    echo 'GPU timing:'; cat "$out/$demo.gpu.log"
    echo "PASS: $demo on $device (all outputs checked)"
done
echo 'RESULT: 5 of 5 X_eTaL source demos agree with evaluator baselines on physical FD702'
