#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
mkdir -p work
tmp=$(mktemp -d "$PWD/work/scaffold-test.XXXXXX")
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/bin"
# Mock driver output: software must never be classified as a physical GPU.
cat > "$tmp/bin/vulkaninfo" <<'EOF'
#!/usr/bin/env bash
echo 'deviceName = llvmpipe (LLVM)'
echo 'driverName = lavapipe'
EOF
chmod +x "$tmp/bin/vulkaninfo"
PATH="$tmp/bin:$PATH" bash scripts/inventory.sh "$tmp/software"
rg -q 'software Vulkan detected; physical GPU NOT established' "$tmp/software/verdict.log"
cat > "$tmp/bin/vulkaninfo" <<'EOF'
#!/usr/bin/env bash
echo 'deviceName = Adreno (TM) 702'
echo 'driverName = turnip'
echo 'queueFlags = QUEUE_COMPUTE_BIT'
EOF
PATH="$tmp/bin:$PATH" bash scripts/inventory.sh "$tmp/adreno"
rg -q 'Adreno/Turnip candidate' "$tmp/adreno/verdict.log"
rg -q 'COMPUTE' "$tmp/adreno/vulkan.log"
bash scripts/setup-host.sh
test -f work/environment.log
test -f work/host.env
echo 'scaffold checks passed'
