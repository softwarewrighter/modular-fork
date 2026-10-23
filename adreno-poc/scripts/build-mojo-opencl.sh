#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$root"
source work/host.env
export MODULAR_CACHE_DIR="$root/work/modular-cache"
mojo=${MOJO:-"$root/../rust-demo/.venv/bin/mojo"}
"$mojo" --version | grep -F '1.2.0.dev2026101305'
test "$(git -C work/xetal-gpu rev-parse HEAD)" = 94ff597a06eed0d4b16694af0fcb648119a9eb17
cargo build --offline --locked --manifest-path mojo-opencl-bridge/Cargo.toml --release --target aarch64-unknown-linux-gnu
bundle="$root/work/mojo-adreno-bundle"
mkdir -p "$bundle/bin" "$bundle/lib" "$bundle/scripts" "$bundle/source" "$root/work/mojo-cross"
"$mojo" build mojo/threshold.mojo --target-triple aarch64-unknown-linux-gnu --target-cpu cortex-a53 --emit object -o work/mojo-cross/threshold.o
if aarch64-linux-gnu-nm -u work/mojo-cross/threshold.o | grep -q KGEN_; then
    echo 'Unexpected Mojo runtime dependency in exported function' >&2
    exit 1
fi
aarch64-linux-gnu-gcc -Wall -Wextra -Werror mojo/launcher.c work/mojo-cross/threshold.o \
    -Ltarget/aarch64-unknown-linux-gnu/release -ladreno_mojo_opencl \
    -Wl,-rpath,'$ORIGIN/../lib' -o "$bundle/bin/mojo-adreno"
cp target/aarch64-unknown-linux-gnu/release/libadreno_mojo_opencl.so "$bundle/lib/"
cp scripts/demo-mojo-opencl.sh work/xetal-gpu/scripts/compare-out.py "$bundle/scripts/"
cp mojo/threshold.mojo mojo/launcher.c "$bundle/source/"
head -3 docs/evidence/unoq-xetal-opencl-20261023/threshold.expect > "$bundle/threshold.expect"
printf 'Mojo 1.2.0.dev2026101305\nX_eTaL-gpu 94ff597a06eed0d4b16694af0fcb648119a9eb17\n' > "$bundle/revisions.txt"
tar -czf work/mojo-adreno-bundle.tar.gz -C "$bundle" .
echo 'Bundle: work/mojo-adreno-bundle.tar.gz'
