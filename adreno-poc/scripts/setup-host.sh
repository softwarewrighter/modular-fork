#!/usr/bin/env bash
# Prepare local configuration only; never install system packages or mutate rustup.
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
mkdir -p "$root/work/cargo" "$root/work/bin" "$root/work/.venv"
if test "${1:-}" != '' && test "${1:-}" != --prepare-cross; then
    echo 'usage: setup-host.sh [--prepare-cross]' >&2
    exit 2
fi
case $(uname -s) in
    Darwin) host=mac ;;
    Linux)
        if test -r /etc/arch-release; then host=arch; else host=linux; fi ;;
    *) echo 'Unsupported host' >&2; exit 1 ;;
esac
# Explicit provisioning keeps even the Rust target under work/, rather than
# adding it to the user's shared rustup installation. Requires network access.
if test "${1:-}" = --prepare-cross; then
    export RUSTUP_HOME="$root/work/rustup"
    export CARGO_HOME="$root/work/cargo"
    rustup toolchain install stable --profile minimal --component rustfmt,clippy --target aarch64-unknown-linux-gnu --no-self-update
    if test "$host" = mac; then
        python3 -m venv "$root/work/.venv"
        "$root/work/.venv/bin/python" -m pip install ziglang
        cargo +stable install cargo-zigbuild --locked --root "$root/work"
        # Caller supplies an already-downloaded SDK; no unpinned SDK download.
        if test -n "${MOLTENVK_SOURCE:-}"; then
            mkdir -p "$root/work/MoltenVK"
            cp -R "$MOLTENVK_SOURCE/." "$root/work/MoltenVK/"
        fi
    fi
fi
{
    date -u
    echo "host=$host"
    uname -a
    rustc --version
    cargo --version
    rustup target list --installed
    if command -v pacman >/dev/null; then pacman -Q; fi
    for tool in aarch64-linux-gnu-gcc vulkaninfo clinfo glslangValidator spirv-dis; do
        command -v "$tool" || echo "missing: $tool"
    done
} > "$root/work/environment.log" 2>&1
{
    printf 'export CARGO_HOME=%q\n' "$root/work/cargo"
    printf 'export CARGO_TARGET_DIR=%q\n' "$root/target"
    printf 'export PATH=%q:"$PATH"\n' "$root/work/bin"
    if test -d "$root/work/rustup/toolchains"; then
        printf 'export RUSTUP_HOME=%q\n' "$root/work/rustup"
    fi
    if test "$host" = arch; then
        echo 'export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc'
    elif test "$host" = mac; then
        printf 'export VK_ICD_FILENAMES=%q\n' "$root/work/MoltenVK/share/vulkan/icd.d/MoltenVK_icd.json"
        printf 'export DYLD_LIBRARY_PATH=%q:"${DYLD_LIBRARY_PATH:-}"\n' "$root/work/MoltenVK/lib"
        printf 'export PATH=%q:"$PATH"\n' "$root/work/.venv/bin"
    fi
} > "$root/work/host.env"
cat <<EOF
Prepared $root/work/host.env ($host).
Source it before builds. See work/environment.log for installed/missing tools.
Cross compilation is not ready until the aarch64 Rust standard library and
linker are present. System packages and shared toolchains are never modified.
Use --prepare-cross to install a project-local Rust target (network required).
Mac: place MoltenVK under work/MoltenVK; install cargo-zigbuild under
work/ and ziglang in work/.venv when the Vulkan cross-build step needs them.
See docs/scaffold-handoff.md for local toolchain preparation instructions.
EOF
