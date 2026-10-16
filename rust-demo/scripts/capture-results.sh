#!/usr/bin/env bash
# Capture reproducible evidence without committing generated libraries or venvs.
# Usage: bash scripts/capture-results.sh [output-directory]
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="${1:-work/results-$(date -u +%Y%m%dT%H%M%SZ)}"
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"
MOJO="${MOJO:-$PWD/.venv/bin/mojo}"
export MOJO

{
  date -u '+%Y-%m-%dT%H:%M:%SZ'
  git rev-parse HEAD
  git status --short
  uname -sr
  rustc --version
  cargo --version
  "$MOJO" --version
  case "$(uname -s)" in
    Linux)
      if command -v nvidia-smi >/dev/null; then
        nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv
      fi
      ;;
    Darwin) system_profiler SPDisplaysDataType ;;
  esac
} 2>&1 | tee "$OUT/environment.log"

# Keep these sequential: each GPU command rebuilds the same program libraries.
cargo test --release --test programs 2>&1 | tee "$OUT/host-tests.log"
cargo build --release 2>&1 | tee "$OUT/build.log"
{
  for program in programs/*.xir; do
    echo "=== $program"
    target/release/xir-mojo run "$program"
  done
} 2>&1 | tee "$OUT/all.log"
XIR_REQUIRE_DEVICE=1 cargo test --release --test device -- --nocapture \
  2>&1 | tee "$OUT/gate.log"
target/release/xir-mojo run programs/saxpy.xir --dump-asm \
  2>&1 | tee "$OUT/assembly.log"
echo "Evidence captured in $OUT"
