#!/usr/bin/env bash
# Builds one Mojo source file as a shared library with C exports, the step
# the Rust tool performs for generated code, for any hand-written library:
#
#   scripts/build-mojo-lib.sh SRC.mojo [OUT] [extra mojo build args...]
#
# OUT defaults to lib<stem>.dylib (macOS) or lib<stem>.so (Linux) beside SRC.
# Prints the exported symbols and the embedded rpaths, so a host program's
# dynamic loader can be checked against them. Functions to export carry
# `@export("name")` and `abi("C")`, and call `initialize_runtime()` first
# (see doc/mojo-as-a-library.md).
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
MOJO="${MOJO:-$HERE/.venv/bin/mojo}"
SRC="${1:?usage: build-mojo-lib.sh SRC.mojo [OUT] [mojo args]}"
shift
case "$(uname -s)" in Darwin) EXT=dylib ;; *) EXT=so ;; esac
STEM="$(basename "${SRC%.mojo}")"
OUT="${1:-$(dirname "$SRC")/lib$STEM.$EXT}"
[ $# -gt 0 ] && shift
"$MOJO" build "$SRC" --emit shared-lib -o "$OUT" "$@" 2> >(grep -v Crashpad >&2)
echo "built $OUT"
echo "exports:"
if [ "$EXT" = dylib ]; then
  nm -gU "$OUT" | awk '{print "  " $3}' | grep -v '^  _mlir\|^  _KGEN' || true
  echo "rpaths:"; otool -l "$OUT" | awk '/LC_RPATH/ {f=1} f && /path/ {print "  " $2; f=0}'
  echo "needs:"; otool -L "$OUT" | tail -n +2 | awk '{print "  " $1}'
else
  nm -D --defined-only "$OUT" | awk '{print "  " $3}' | grep -v '^  _mlir\|^  KGEN' || true
  echo "rpaths:"; readelf -d "$OUT" | grep -i 'rpath\|runpath' | sed 's/^/  /' || true
  echo "needs:"; readelf -d "$OUT" | grep NEEDED | awk -F'[][]' '{print "  " $2}'
fi
