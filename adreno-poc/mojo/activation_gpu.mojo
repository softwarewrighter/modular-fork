# activation_gpu.mojo: threshold and ReLU as an ordinary Mojo GPU program,
# the way it is written for a GPU Mojo supports (Apple silicon, NVIDIA,
# AMD). The same file runs unchanged on the M1 Max (Metal) and on the
# RTX 5060 Ti (CUDA): DeviceContext() picks the machine's GPU and the
# compiler emits AIR or PTX for the kernel. It does not run on the
# Adreno 702: there is no Mojo target or runtime for it (docs/adreno-deep-dive.md,
# "Toward ordinary Mojo on the Adreno").
#
#   mojo run mojo/activation_gpu.mojo

from max.gpu import block_dim, block_idx, thread_idx
from max.gpu.host import DeviceContext

comptime N = 8
comptime TPB = 64
comptime BLOCKS = (N + TPB - 1) // TPB


def activations(
    x: Pointer[Float32, ImmutAnyOrigin],
    threshold: Pointer[Float32, MutAnyOrigin],
    relu: Pointer[Float32, MutAnyOrigin],
    t: Float32,
    n: Int32,
):
    """One thread per element: threshold(x, t) = x * (x > t), relu(x) = max(x, 0)."""
    var i = Int(block_idx.x * block_dim.x + thread_idx.x)
    if i < Int(n):
        var v = x[unsafe_offset=i]
        var mask = Float32(1.0) if v > t else Float32(0.0)
        threshold[unsafe_offset=i] = v * mask
        relu[unsafe_offset=i] = max(v, Float32(0.0))


def main() raises:
    var ctx = DeviceContext()
    print("device:", ctx.api(), ctx.name())

    # x = ((range 8) / 4) - 1.0, X_eTaL's range running 1..8
    var h_x = ctx.enqueue_create_host_buffer[DType.float32](N)
    ctx.synchronize()
    for i in range(N):
        h_x[i] = Float32(i + 1) / 4.0 - 1.0

    var d_x = ctx.enqueue_create_buffer[DType.float32](N)
    var d_threshold = ctx.enqueue_create_buffer[DType.float32](N)
    var d_relu = ctx.enqueue_create_buffer[DType.float32](N)
    ctx.enqueue_copy(dst_buf=d_x, src_buf=h_x)

    ctx.enqueue_function[activations](
        d_x, d_threshold, d_relu, Float32(0.5), Int32(N),
        grid_dim=BLOCKS, block_dim=TPB,
    )

    var h_threshold = ctx.enqueue_create_host_buffer[DType.float32](N)
    var h_relu = ctx.enqueue_create_host_buffer[DType.float32](N)
    ctx.enqueue_copy(dst_buf=h_threshold, src_buf=d_threshold)
    ctx.enqueue_copy(dst_buf=h_relu, src_buf=d_relu)
    ctx.synchronize()

    # The same three lines X_eTaL's evaluator prints first for threshold.xtl.
    var failures = 0
    for row in range(3):
        var line = String()
        for i in range(N):
            var x = h_x[i]
            var got = x if row == 0 else (h_threshold[i] if row == 1 else h_relu[i])
            var want = x if row == 0 else (
                x * (Float32(1.0) if x > 0.5 else Float32(0.0)) if row == 1 else max(x, Float32(0.0))
            )
            if got != want:
                failures += 1
            line += (" " if i else "") + String(got)
        print(line)
    print("RESULT:", 3 * N - failures, "of", 3 * N, "outputs agree with the CPU reference")
