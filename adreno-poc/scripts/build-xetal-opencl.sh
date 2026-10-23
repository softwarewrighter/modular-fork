#!/usr/bin/env bash
# Assemble a pinned, cross-built demo bundle. Toolchains/dependencies must be
# provisioned first; this command builds offline and writes only under work/.
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$root"
gpu_rev=94ff597a06eed0d4b16694af0fcb648119a9eb17
xetal_rev=27b3fd0d4903e43be4b9b6e93da7476987383dcf
gpu_source=${XETAL_GPU_SOURCE:-"$root/../../X_eTaL-gpu"}
if ! test -d work/xetal-gpu/.git; then
    git clone --no-hardlinks "$gpu_source" work/xetal-gpu
    git -C work/xetal-gpu checkout --detach "$gpu_rev"
fi
if ! test -d work/xetal-gpu/work/xetal/.git; then
    git clone --no-hardlinks "$gpu_source/work/xetal" work/xetal-gpu/work/xetal
    git -C work/xetal-gpu/work/xetal checkout --detach "$xetal_rev"
fi
test "$(git -C work/xetal-gpu rev-parse HEAD)" = "$gpu_rev"
test "$(git -C work/xetal-gpu/work/xetal rev-parse HEAD)" = "$xetal_rev"
test -z "$(git -C work/xetal-gpu status --porcelain --untracked-files=no)"
test -z "$(git -C work/xetal-gpu/work/xetal status --porcelain --untracked-files=no)"
export RUSTUP_HOME="$root/work/rustup"
export CARGO_HOME="$root/work/cargo"
export CARGO_TARGET_DIR="$root/target"
export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc
cargo build --offline --locked --manifest-path work/xetal-gpu/components/Cargo.toml \
    -p xetal-gpu-cli --release --target aarch64-unknown-linux-gnu
bundle="$root/work/xetal-opencl-bundle"
mkdir -p "$bundle/bin" "$bundle/scripts" "$bundle/schedules"
cp target/aarch64-unknown-linux-gnu/release/xetal-gpu "$bundle/bin/"
cp -R work/xetal-gpu/libs "$bundle/"
cp -R work/xetal-gpu/work/xetal/lib "$bundle/"
cp scripts/demo-xetal-opencl.sh scripts/select-adreno.py work/xetal-gpu/scripts/compare-out.py "$bundle/scripts/"
cp schedules/adreno-702.toml "$bundle/schedules/"
cp work/xetal-gpu/LICENSE "$bundle/LICENSE-xetal-gpu"
printf 'X_eTaL-gpu %s\nX_eTaL %s\n' "$gpu_rev" "$xetal_rev" > "$bundle/revisions.txt"
tar -czf work/xetal-opencl-bundle.tar.gz -C "$bundle" .
echo 'Bundle: work/xetal-opencl-bundle.tar.gz'
