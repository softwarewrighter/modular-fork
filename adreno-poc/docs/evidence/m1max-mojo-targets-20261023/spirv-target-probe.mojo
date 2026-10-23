from std.compile import compile_info
from std.sys.info import CompilationTarget

comptime SPIRV = CompilationTarget[
    _mlir_value=__mlir_attr[
        `#kgen.target<triple = "spirv64-unknown-unknown", `,
        `arch = "", `,
        `features = "", `,
        `data_layout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64-G1", `,
        `simd_bit_width = 128`,
        `> : !kgen.target`,
    ]
]()

def relu_scalar(x: Pointer[Float32, ImmutAnyOrigin], y: Pointer[Float32, MutAnyOrigin], i: Int):
    y[unsafe_offset=i] = max(x[unsafe_offset=i], Float32(0.0))

def main():
    print(compile_info[relu_scalar, emission_kind="llvm", target=SPIRV]().asm)
