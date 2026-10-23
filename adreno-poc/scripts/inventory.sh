#!/usr/bin/env bash
# Read-only inventory. Missing tools are findings, not a reason to lose the log.
set -euo pipefail
out=${1:?usage: inventory.sh OUTPUT_DIRECTORY}
mkdir -p -- "$out"
capture() {
    local file=$1
    shift
    { printf 'command:'; printf ' %q' "$@"; printf '\n';
      if "$@"; then echo 'exit: 0'; else echo "exit: $?"; fi;
    } > "$out/$file" 2>&1
}
{
    date -u
    uname -a
    cat /etc/os-release 2>/dev/null || true
    getconf GNU_LIBC_VERSION 2>/dev/null || true
    command -v pacman >/dev/null && pacman -Q || true
} > "$out/environment.log" 2>&1
capture memory.log free -h
capture disk.log df -h
capture dri.log ls -la /dev/dri
capture modules.log lsmod
# Full output retains queue flags, storage-buffer limits and per-device names.
capture vulkan.log vulkaninfo
capture opencl.log clinfo
capture libraries.log sh -c 'ldconfig -p 2>&1 | grep -Ei "vulkan|OpenCL|GLES"'
{
    echo 'Driver and device names: review full vulkan.log and opencl.log.'
    if grep -Eiq 'lavapipe|llvmpipe' "$out/vulkan.log"; then
        echo 'software Vulkan detected; physical GPU NOT established'
        echo 'Mixed hardware/software listings require per-device inspection.'
    elif grep -Eiq 'turnip|adreno' "$out/vulkan.log"; then
        echo 'Adreno/Turnip candidate; verify physical device, COMPUTE queue and storage limits.'
    else
        echo 'Adreno Vulkan NOT established (missing tool, driver, or device).'
    fi
    if grep -Eiq 'rusticl' "$out/opencl.log"; then
        echo 'rusticl listed; inspect device name and type before claiming GPU execution.'
    else
        echo 'rusticl NOT established.'
    fi
    echo 'Inventory only: no dispatch or numerical correctness established.'
} > "$out/verdict.log"
cat "$out/verdict.log"
