import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("retarget", ROOT / "scripts/nvptx-to-spirv.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
FIXTURE = ROOT / "docs/evidence/m1max-mojo-targets-20261023/activations.rtx5060.nvptx.ll"


class Retarget(unittest.TestCase):
    def test_committed_kernel_matches_golden(self):
        self.assertEqual(module.rewrite(FIXTURE.read_text()),
                         (ROOT / "tests/expected/activations.spirv.ll").read_text())

    def test_unknown_constructs_are_refused(self):
        original = FIXTURE.read_text()
        for old, new in [
            ("@llvm.nvvm.read.ptx.sreg.tid.x", "@llvm.nvvm.read.ptx.sreg.tid.y"),
            ("@llvm.maxnum.f32", "@__nv_sin"),
            ("ptr noundef %0", "ptr addrspace(3) noundef %0"),
            ("  ret void", "  fence seq_cst\n  ret void"),
            ("  ret void", "  call void @barrier(i32 1)\n  ret void"),
            ("  ret void", "  %bad = atomicrmw add ptr %0, i32 1 seq_cst\n  ret void"),
            ("  ret void", "  %bad = alloca float\n  ret void"),
            ("norecurse", "convergent"),
            ('!"Debug Info Version"', '!"Unknown Semantic Metadata"'),
        ]:
            with self.subTest(construct=new), self.assertRaises(ValueError):
                module.rewrite(original.replace(old, new))


if __name__ == "__main__":
    unittest.main()
