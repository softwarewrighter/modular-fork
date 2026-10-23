#!/usr/bin/env python3
"""Retarget the audited scalar Mojo activations NVPTX IR subset to OpenCL IR.

Not a general CUDA converter. Unknown instructions/calls/address spaces fail.
LLVM verifies types, SSA and control flow after this textual transformation.
"""
import argparse
from pathlib import Path
import re

BUILTINS = {
    "ctaid.x": "_Z12get_group_idj",
    "ntid.x": "_Z14get_local_sizej",
    "tid.x": "_Z12get_local_idj",
}
LAYOUT = "e-p:64:64-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"


def rewrite(source):
    if 'target triple = "nvptx64-nvidia-cuda"' not in source:
        raise ValueError("expected nvptx64-nvidia-cuda target")
    for forbidden in [r"addrspace", r"\batomic\w*", r"\bcmpxchg\b", r"\bfence\b", r"barrier", r"libdevice", r"@__nv_", r"\bvolatile\b"]:
        if re.search(forbidden, source):
            raise ValueError(f"unsupported construct: {forbidden}")
    definitions = re.findall(r"^define .*", source, re.M)
    if len(definitions) != 1:
        raise ValueError("expected exactly one kernel definition")
    signature = r"define dso_local ptx_kernel void @([\w.$]+)\(ptr noundef %[\w.]+, ptr noundef %[\w.]+, ptr noundef %[\w.]+, float noundef %[\w.]+, i32 noundef %[\w.]+\) #0 \{"
    if not re.fullmatch(signature, definitions[0]):
        raise ValueError("unsupported kernel signature (three pointers, float, i32 required)")
    attribute_words = {"norecurse", "nocallback", "nocreateundeforpoison", "nofree", "nosync", "nounwind", "speculatable", "willreturn", "memory(none)"}
    for line in source.splitlines():
        if line.startswith("attributes "):
            body = line.split("{", 1)[1].rsplit("}", 1)[0]
            body = re.sub(r'"(?:target-cpu|target-features|tune-cpu)"="[^"\n]*"', "", body)
            for word in body.split():
                if word not in attribute_words:
                    raise ValueError(f"unsupported attribute: {word}")
        if line.startswith("!") and line not in {'!llvm.module.flags = !{!0}', '!0 = !{i32 2, !"Debug Info Version", i32 3}'}:
            raise ValueError(f"unsupported metadata: {line}")
    calls = re.findall(r"@([\w.]+)\(", source)
    allowed = {"llvm.nvvm.read.ptx.sreg." + n for n in BUILTINS} | {"llvm.maxnum.f32"}
    kernel_name = re.fullmatch(signature, definitions[0])[1]
    for call in calls:
        if call != kernel_name and call not in allowed:
            raise ValueError(f"unsupported call: {call}")
    result = ['; Audited NVPTX scalar kernel retargeted to OpenCL SPIR-V LLVM IR.',
              f'target datalayout = "{LAYOUT}"',
              'target triple = "spirv64-unknown-unknown"', '']
    inside = False
    intrinsic_calls = set()
    for line in source.splitlines():
        if line.startswith("define "):
            inside = True
            result.append(re.sub(r" #0(?= \{)", "", line.replace("ptx_kernel", "spir_kernel")).replace("ptr noundef", "ptr addrspace(1) noundef"))
        elif inside:
            if line == "}":
                inside = False
                result.append(line)
                continue
            stripped = line.strip()
            if not stripped or stripped.startswith(";") or re.match(r"^[\w.]+:\s*(;.*)?$", stripped):
                result.append(line)
                continue
            match = re.fullmatch(r"\s*(%[\w.]+) = call i32 @llvm\.nvvm\.read\.ptx\.sreg\.([\w.]+)\(\)", line)
            if match:
                value, intrinsic = match.groups()
                if intrinsic not in BUILTINS:
                    raise ValueError(f"unsupported nvvm intrinsic: {intrinsic}")
                intrinsic_calls.add(intrinsic)
                temporary = "%retarget_" + value[1:]
                if temporary in source:
                    raise ValueError("retarget temporary name collision")
                result.extend([f"  {temporary} = call spir_func i64 @{BUILTINS[intrinsic]}(i32 0)",
                               f"  {value} = trunc i64 {temporary} to i32"])
                continue
            instruction = re.sub(r"^%[\w.]+ = ", "", stripped)
            if not re.match(r"^(zext i32 |sext i32 |mul i64 |add i64 |getelementptr inbounds float, |icmp slt i64 |br |load float, |fcmp ogt float |select i1 |fmul contract float |store float |call float @llvm.maxnum.f32\(|ret void$)", instruction):
                raise ValueError(f"unsupported instruction: {instruction}")
            result.append(re.sub(r"\bptr\b", "ptr addrspace(1)", line))
        elif line.startswith("declare "):
            if "@llvm.maxnum.f32(" in line:
                result.append("declare float @llvm.maxnum.f32(float, float)")
            elif "@llvm.nvvm.read.ptx.sreg." not in line:
                raise ValueError(f"unsupported declaration: {line}")
        elif line.startswith((";", "target ", "source_filename ", "attributes ", "!")) or not line.strip():
            continue
        else:
            raise ValueError(f"unsupported module construct: {line}")
    if inside or intrinsic_calls != set(BUILTINS):
        raise ValueError("incomplete kernel or missing expected index intrinsic")
    result += [""] + [f"declare spir_func i64 @{name}(i32)" for name in BUILTINS.values()]
    return "\n".join(result) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    try:
        transformed = rewrite(args.source.read_text())
    except ValueError as error:
        parser.exit(1, f"refused: {error}\n")
    args.output.write_text(transformed)


if __name__ == "__main__":
    main()
