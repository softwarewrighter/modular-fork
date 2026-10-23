from std.ffi import external_call

# C launcher provides storage; this exported function needs no Mojo startup.
@export("mojo_adreno_demo")
def mojo_adreno_demo(
    inputs: Pointer[Float32, MutAnyOrigin],
    outputs: Pointer[Float32, MutAnyOrigin],
    expected: Pointer[Float32, MutAnyOrigin],
    n: Int,
) abi("C") -> Int32:
    if n != 8:
        return -1
    for i in range(n):
        var x = Float32(i + 1) / 4.0 - 1.0
        inputs[unsafe_offset=i] = x
        expected[unsafe_offset=i] = x
        var mask = Float32(1.0) if x > 0.5 else Float32(0.0)
        expected[unsafe_offset=n + i] = x * mask
        expected[unsafe_offset=2 * n + i] = max(x, Float32(0.0))
    var status = external_call["adreno_threshold_v1", Int32](
        inputs, outputs, n, 3 * n
    )
    if status != 0:
        return status
    var failures: Int32 = 0
    for i in range(3 * n):
        if outputs[unsafe_offset=i] != expected[unsafe_offset=i]:
            failures += 1
    return failures
