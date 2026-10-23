#!/usr/bin/env python3
"""Inspect the observed rusticl v1 container; extract SPIR-V, not GPU ISA."""
import argparse
import hashlib
import pathlib
import struct


def decode(data):
    if len(data) < 24 or data[:8] != b"rusticl\0":
        raise ValueError("not the observed rusticl container")
    version, name_size, payload_size, binary_type = struct.unpack_from("<4I", data, 8)
    if version != 1 or len(data) != 24 + name_size + payload_size:
        raise ValueError("unsupported version or inconsistent lengths")
    name = data[24:24 + name_size].decode("ascii")
    payload = data[24 + name_size:]
    if len(payload) < 20 or payload[:4] != bytes.fromhex("03022307"):
        raise ValueError("payload is not SPIR-V")
    return version, name, binary_type, payload


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("binary", type=pathlib.Path)
    parser.add_argument("--extract-spv", type=pathlib.Path)
    args = parser.parse_args()
    data = args.binary.read_bytes()
    version, name, binary_type, payload = decode(data)
    print(f"container bytes: {len(data)}; sha256: {hashlib.sha256(data).hexdigest()}")
    print(f"observed version: {version}; device: {name}; binary type word: {binary_type}")
    print(f"SPIR-V offset: {len(data) - len(payload)}; payload bytes: {len(payload)}")
    print("This payload is OpenCL SPIR-V, not final Adreno machine code.")
    if args.extract_spv:
        args.extract_spv.write_bytes(payload)


if __name__ == "__main__":
    main()
