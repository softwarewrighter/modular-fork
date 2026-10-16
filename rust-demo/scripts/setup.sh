#!/usr/bin/env bash
# Creates rust-demo/.venv with the MAX nightly this repository pins (the
# `max` wheel carries the Mojo compiler, the standard library and the
# `max.gpu` Mojo package the generated kernels import; the `mojo` wheel alone
# lacks `max.gpu`). Then checks the GPU toolchain for this platform.
#
#   scripts/setup.sh                 # the pinned nightly
#   MAX_VERSION=26.7.0.dev2026101305 scripts/setup.sh
#   MAX_VERSION=latest scripts/setup.sh
set -euo pipefail
cd "$(dirname "$0")/.."

# The version the repository's lockfiles pin (see the [Release] commits on
# this branch); override with MAX_VERSION.
PINNED="26.7.0.dev2026101305"
VERSION="${MAX_VERSION:-$PINNED}"
PY="${PYTHON_VERSION:-3.12}"

command -v uv >/dev/null || { echo "uv is required: https://docs.astral.sh/uv/getting-started/installation/" >&2; exit 1; }
command -v cargo >/dev/null || { echo "cargo (Rust) is required: https://rustup.rs" >&2; exit 1; }

if [ ! -x .venv/bin/python ]; then
  uv venv .venv --python "$PY"
fi
if [ "$VERSION" = "latest" ]; then
  SPEC="max"
else
  SPEC="max==$VERSION"
fi
uv pip install --python .venv/bin/python "$SPEC" \
  --index https://whl.modular.com/nightly/simple/ --prerelease allow

echo
echo "mojo: $(.venv/bin/mojo --version 2>&1 | grep -v Crashpad)"
case "$(uname -s)" in
  Darwin)
    if xcrun -sdk macosx metal --version >/dev/null 2>&1; then
      echo "metal toolchain: $(xcrun -sdk macosx metal --version 2>&1 | head -1)"
    else
      echo "WARNING: the Metal toolchain is missing; run: xcodebuild -downloadComponent MetalToolchain" >&2
    fi
    echo "gpu: $(system_profiler SPDisplaysDataType 2>/dev/null | awk -F': ' '/Chipset Model/ {print $2; exit}')"
    ;;
  Linux)
    if command -v nvidia-smi >/dev/null; then
      if ! nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader | sed 's/^/gpu: /'; then
        echo "ERROR: nvidia-smi cannot access the GPU. Check host driver/device access; coding sandboxes may hide /dev/nvidia*." >&2
        exit 1
      fi
      DRIVER="$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -1 | cut -d. -f1)"
      if [ "${DRIVER:-0}" -lt 580 ]; then
        echo "NOTE: driver $DRIVER is older than 580; set MODULAR_NVPTX_COMPILER_PATH to a CUDA toolkit's ptxas (see doc/porting-arch-rtx5060.md)" >&2
      fi
    elif command -v rocm-smi >/dev/null; then
      rocm-smi --showproductname 2>/dev/null | grep -i 'card series' | sed 's/^/gpu: /' || true
    else
      echo "WARNING: no nvidia-smi or rocm-smi found; the kernels need a GPU and its driver" >&2
    fi
    ;;
esac
echo
echo "ready: cargo run --release -- run programs/saxpy.xir   (or: just run saxpy)"
