#!/usr/bin/env python3
"""Select the unique physical FD702 GPU from pinned xetal-gpu devices output."""
import re
import sys

matches = []
for line in sys.stdin:
    match = re.match(r"^(opencl:\d+)\s+FD702\s+\(GPU,\s*Qualcomm;", line)
    if match:
        matches.append(match[1])
if len(matches) != 1:
    sys.exit(f"expected exactly one Qualcomm FD702 GPU, found {len(matches)}")
print(matches[0])
