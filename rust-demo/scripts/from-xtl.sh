#!/usr/bin/env bash
# X_eTaL source to the GPU through Mojo, with nothing written by hand:
# xetal-gpu (the sibling X_eTaL-gpu repository) lowers the program to XIR,
# this tool writes the Mojo, builds it, runs it on the GPU, and the result is
# checked against the Rust reference and against what X_eTaL's own evaluator
# printed for the program.
#
#   scripts/from-xtl.sh FILE.xtl [xir-mojo args]   lower FILE into work/xtl/, run it
#   scripts/from-xtl.sh --refresh                   rewrite programs/accel-*.xir and .expect
#                                                   from X_eTaL-gpu's Accel demos in the subset
#
# Needs X_eTaL-gpu beside this fork (or XETAL_GPU=/path) with its tool built
# (`just build` there, which also pins its X_eTaL). The committed
# programs/accel-*.xir need none of this: the gate runs them as they are.
set -euo pipefail
cd "$(dirname "$0")/.."
XETAL_GPU="${XETAL_GPU:-$PWD/../../X_eTaL-gpu}"
tool="$XETAL_GPU/target/release/xetal-gpu"
[ -x "$tool" ] || { echo "no $tool: clone X_eTaL-gpu beside this fork and run 'just build' there, or set XETAL_GPU" >&2; exit 1; }
XETAL_PATH="$(cd "$XETAL_GPU" && scripts/libs.py path)"   # absolute: libs/*/src there
export XETAL_PATH
rev="$(git -C "$XETAL_GPU" rev-parse --short HEAD)"

# The Accel demos whose lowering stays in this tool's subset (f32, i64 carried
# in f32, bool; vectors of one length; whole-array reductions). The others
# need axes, matrices, gathers: X_eTaL-gpu's saga gpu-mojo, steps 2 and 3.
IN_SUBSET="saxpy threshold reduce-sum pipeline vector-add"

lower() { # XTL OUT_STEM BASELINE_OR_EMPTY
  local xtl="$1" stem="$2" want="$3"
  {
    echo "# $(basename "$xtl"), lowered by xetal-gpu (X_eTaL-gpu $rev); not written by hand."
    echo "# Regenerate: scripts/from-xtl.sh --refresh (or scripts/from-xtl.sh FILE.xtl)."
    "$tool" lower "$xtl"
  } > "$stem.xir"
  if [ -n "$want" ] && [ -f "$want" ]; then
    { echo "# What X_eTaL's evaluator printed for $(basename "$xtl") (X_eTaL-gpu's $(basename "$want"))."
      cat "$want"; } > "$stem.expect"
  else
    { echo "# What xetal printed for $(basename "$xtl") (scripts/xt run, X_eTaL-gpu $rev)."
      (cd "$XETAL_GPU" && scripts/xt run "$xtl"); } > "$stem.expect"
  fi
}

if [ "${1:-}" = "--refresh" ]; then
  for d in $IN_SUBSET; do
    lower "$XETAL_GPU/libs/Accel/demos/$d.xtl" "programs/accel-$d" "$XETAL_GPU/libs/Accel/tests/demo-$d.out"
    echo "programs/accel-$d.xir ($(grep -c . "programs/accel-$d.xir") lines) and .expect, from libs/Accel/demos/$d.xtl at $rev"
  done
  exit 0
fi

xtl="${1:?FILE.xtl}"; shift
stem="work/xtl/$(basename "$xtl" .xtl)"
mkdir -p work/xtl
name="$(basename "$xtl" .xtl)"
lower "$xtl" "$stem" "$XETAL_GPU/libs/Accel/tests/demo-$name.out"
echo "lowered: $xtl -> $stem.xir ($(grep -c . "$stem.xir") lines of XIR), evaluator output in $stem.expect"
cargo build --release -q
exec target/release/xir-mojo run "$stem.xir" --work work/xtl "$@"
