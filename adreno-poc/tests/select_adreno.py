"""Require one physical Qualcomm FD702 rather than guessing opencl:0."""
import pathlib
import subprocess
import sys
import unittest

SELECTOR = pathlib.Path(__file__).resolve().parents[1] / "scripts/select-adreno.py"


class Selection(unittest.TestCase):
    def select(self, text):
        return subprocess.run([sys.executable, str(SELECTOR)], input=text,
                              text=True, capture_output=True)

    def test_physical_device_index_is_discovered(self):
        result = self.select("opencl:0  llvmpipe (CPU, Mesa; OpenCL 3.0)\n"
                             "opencl:2  FD702 (GPU, Qualcomm; OpenCL 3.0), no fp64\n")
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout.strip(), "opencl:2")

    def test_absent_software_wrong_vendor_and_ambiguous_are_rejected(self):
        physical = "opencl:1  FD702 (GPU, Qualcomm; OpenCL 3.0)\n"
        for text in ["", "opencl:0  FD702 (CPU, Qualcomm; OpenCL 3.0)",
                     "opencl:0  FD702 (GPU, Mesa; OpenCL 3.0)", physical * 2]:
            self.assertNotEqual(self.select(text).returncode, 0)


if __name__ == "__main__":
    unittest.main()
