//! HIP spelling of the same standalone elementwise comparison as CUDA.
//! Keep the arithmetic generator shared so the two backends cannot drift.
use crate::{cuda, ir::Program};
use std::collections::HashMap;

/// Emit portable HIP source, compilable by hipcc for AMD or NVIDIA.
pub fn emit(p: &Program, inputs: &HashMap<String, Vec<f32>>, expected: &[Vec<f32>]) -> Result<String, String> {
    let mut source = cuda::emit(p, inputs, expected)?;
    for (cuda, hip) in [
        ("emit-cuda", "emit-hip"),
        ("<cuda_runtime.h>", "<hip/hip_runtime.h>"),
        ("cudaError_t", "hipError_t"), ("cudaSuccess", "hipSuccess"),
        ("cudaGetErrorString", "hipGetErrorString"),
        ("cudaMalloc", "hipMalloc"), ("cudaFree", "hipFree"),
        ("cudaMemcpyHostToDevice", "hipMemcpyHostToDevice"),
        ("cudaMemcpyDeviceToHost", "hipMemcpyDeviceToHost"),
        ("cudaMemcpy", "hipMemcpy"),
        ("cudaGetLastError", "hipGetLastError"),
        ("cudaDeviceSynchronize", "hipDeviceSynchronize"),
        ("CUDA(call)", "HIP(call)"), ("CUDA(", "HIP("),
        ("backend: CUDA", "backend: HIP"),
    ] { source = source.replace(cuda, hip); }
    Ok(source)
}
