import importlib.util
import pathlib
import struct
import unittest

path = pathlib.Path(__file__).resolve().parents[1] / "scripts/inspect-rusticl.py"
spec = importlib.util.spec_from_file_location("inspect_rusticl", path)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class Container(unittest.TestCase):
    def test_extracts_payload_and_rejects_invalid_layouts(self):
        spirv = bytes.fromhex("03022307") + bytes(16)
        valid = b"rusticl\0" + struct.pack("<4I", 1, 5, len(spirv), 4) + b"FD702" + spirv
        self.assertEqual(module.decode(valid), (1, "FD702", 4, spirv))
        for bad in [b"", valid[:-1], valid + b"extra", b"wrong!!!" + valid[8:],
                    valid[:8] + struct.pack("<I", 2) + valid[12:], valid[:-20] + bytes(20)]:
            with self.assertRaises(ValueError):
                module.decode(bad)


if __name__ == "__main__":
    unittest.main()
