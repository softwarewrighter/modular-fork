// Generated from XIR by xir-mojo emit-cuda. Integers carried in float (exact to 2^24).
#include <cmath>
#include <cstdio>
#include <cstdlib>
#ifndef XIR_CPU_ONLY
#include <cuda_runtime.h>
#define HD __host__ __device__
#define CUDA(call) do { cudaError_t e = (call); if (e != cudaSuccess) { std::fprintf(stderr, "%s: %s\n", #call, cudaGetErrorString(e)); std::exit(2); } } while (0)
#else
#define HD
#endif
static float h_0[] = {1.0f, 2.0f, 3.0f, 4.0f, 5.0f, 6.0f, 7.0f, 8.0f};
static float h_11[] = {1.0f, 2.0f, 3.0f, 4.0f, 5.0f, 6.0f, 7.0f, 8.0f};
HD inline void element(int i, const float* b_0, const float* b_11, float* out_0, float* out_1, float* out_2, float* out_3, float* out_4) {
    float v_0 = b_0[i]; // %l
    float v_1 = 4.0f; // %r
    float v_2 = v_0 / v_1; // %div
    float v_3 = 1.0f; // %r_2
    float v_4 = v_2 - v_3; // %sub
    float v_5 = 0.5f; // %r_3
    bool v_6 = v_4 > v_5; // %gt
    float v_7 = float(v_6); // %f
    float v_8 = v_4 * v_7; // %mul
    float v_9 = 0.0f; // %r_4
    float v_10 = fmaxf(v_4, v_9); // %max
    float v_11 = b_11[i]; // %l_2
    float v_12 = 4.0f; // %r_5
    float v_13 = v_11 - v_12; // %sub_2
    float v_14 = 0.0f; // %r_6
    float v_15 = fmaxf(v_13, v_14); // %max_2
    float v_16 = 2.0f; // %r_7
    float v_17 = float((static_cast<long long>(v_13) % static_cast<long long>(v_16)) + (((static_cast<long long>(v_13) % static_cast<long long>(v_16)) != 0 && ((v_13 < 0) != (v_16 < 0))) ? static_cast<long long>(v_16) : 0)); // %mod
    float v_18 = v_13 * v_17; // %mul_2
    out_0[i] = float(v_4);
    out_1[i] = float(v_8);
    out_2[i] = float(v_10);
    out_3[i] = float(v_15);
    out_4[i] = float(v_18);
}
#ifndef XIR_CPU_ONLY
extern "C" __global__ void stage0(const float* b_0, const float* b_11, float* out_0, float* out_1, float* out_2, float* out_3, float* out_4) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < 8) element(i, b_0, b_11, out_0, out_1, out_2, out_3, out_4);
}
#endif
int main() {
#ifndef XIR_CPU_ONLY
    float* b_0;
    CUDA(cudaMalloc(&b_0, sizeof(h_0)));
    CUDA(cudaMemcpy(b_0, h_0, sizeof(h_0), cudaMemcpyHostToDevice));
#else
    float* b_0 = h_0;
#endif
#ifndef XIR_CPU_ONLY
    float* b_11;
    CUDA(cudaMalloc(&b_11, sizeof(h_11)));
    CUDA(cudaMemcpy(b_11, h_11, sizeof(h_11), cudaMemcpyHostToDevice));
#else
    float* b_11 = h_11;
#endif
    float result_0[8];
#ifndef XIR_CPU_ONLY
    float* out_0;
    CUDA(cudaMalloc(&out_0, sizeof(result_0)));
#else
    float* out_0 = result_0;
#endif
    float result_1[8];
#ifndef XIR_CPU_ONLY
    float* out_1;
    CUDA(cudaMalloc(&out_1, sizeof(result_1)));
#else
    float* out_1 = result_1;
#endif
    float result_2[8];
#ifndef XIR_CPU_ONLY
    float* out_2;
    CUDA(cudaMalloc(&out_2, sizeof(result_2)));
#else
    float* out_2 = result_2;
#endif
    float result_3[8];
#ifndef XIR_CPU_ONLY
    float* out_3;
    CUDA(cudaMalloc(&out_3, sizeof(result_3)));
#else
    float* out_3 = result_3;
#endif
    float result_4[8];
#ifndef XIR_CPU_ONLY
    float* out_4;
    CUDA(cudaMalloc(&out_4, sizeof(result_4)));
#else
    float* out_4 = result_4;
#endif
#ifndef XIR_CPU_ONLY
    stage0<<<1, 256>>>(b_0, b_11, out_0, out_1, out_2, out_3, out_4);
    CUDA(cudaGetLastError());
    CUDA(cudaDeviceSynchronize());
#else
    for (int i = 0; i < 8; ++i) element(i, b_0, b_11, out_0, out_1, out_2, out_3, out_4);
#endif
    int failures = 0;
#ifndef XIR_CPU_ONLY
    CUDA(cudaMemcpy(result_0, out_0, sizeof(result_0), cudaMemcpyDeviceToHost));
    CUDA(cudaFree(out_0));
#endif
    const float expected_0[] = {-0.75f, -0.5f, -0.25f, 0.0f, 0.25f, 0.5f, 0.75f, 1.0f};
    std::printf("output %%sub:");
    for (int i = 0; i < 8; ++i) {
        float g = result_0[i], w = expected_0[i];
        std::printf(" %.9g", g);
        if (!std::isfinite(g) || !std::isfinite(w) || (fabsf(g-w) > 1e-6f && fabsf(g-w) > 1e-4f * fabsf(w))) ++failures;
    }
    std::puts("");
#ifndef XIR_CPU_ONLY
    CUDA(cudaMemcpy(result_1, out_1, sizeof(result_1), cudaMemcpyDeviceToHost));
    CUDA(cudaFree(out_1));
#endif
    const float expected_1[] = {-0.0f, -0.0f, -0.0f, 0.0f, 0.0f, 0.0f, 0.75f, 1.0f};
    std::printf("output %%mul:");
    for (int i = 0; i < 8; ++i) {
        float g = result_1[i], w = expected_1[i];
        std::printf(" %.9g", g);
        if (!std::isfinite(g) || !std::isfinite(w) || (fabsf(g-w) > 1e-6f && fabsf(g-w) > 1e-4f * fabsf(w))) ++failures;
    }
    std::puts("");
#ifndef XIR_CPU_ONLY
    CUDA(cudaMemcpy(result_2, out_2, sizeof(result_2), cudaMemcpyDeviceToHost));
    CUDA(cudaFree(out_2));
#endif
    const float expected_2[] = {0.0f, 0.0f, 0.0f, 0.0f, 0.25f, 0.5f, 0.75f, 1.0f};
    std::printf("output %%max:");
    for (int i = 0; i < 8; ++i) {
        float g = result_2[i], w = expected_2[i];
        std::printf(" %.9g", g);
        if (!std::isfinite(g) || !std::isfinite(w) || (fabsf(g-w) > 1e-6f && fabsf(g-w) > 1e-4f * fabsf(w))) ++failures;
    }
    std::puts("");
#ifndef XIR_CPU_ONLY
    CUDA(cudaMemcpy(result_3, out_3, sizeof(result_3), cudaMemcpyDeviceToHost));
    CUDA(cudaFree(out_3));
#endif
    const float expected_3[] = {0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 2.0f, 3.0f, 4.0f};
    std::printf("output %%max_2:");
    for (int i = 0; i < 8; ++i) {
        float g = result_3[i], w = expected_3[i];
        std::printf(" %.9g", g);
        if (g != w) ++failures;
    }
    std::puts("");
#ifndef XIR_CPU_ONLY
    CUDA(cudaMemcpy(result_4, out_4, sizeof(result_4), cudaMemcpyDeviceToHost));
    CUDA(cudaFree(out_4));
#endif
    const float expected_4[] = {-3.0f, 0.0f, -1.0f, 0.0f, 1.0f, 0.0f, 3.0f, 0.0f};
    std::printf("output %%mul_2:");
    for (int i = 0; i < 8; ++i) {
        float g = result_4[i], w = expected_4[i];
        std::printf(" %.9g", g);
        if (g != w) ++failures;
    }
    std::puts("");
#ifndef XIR_CPU_ONLY
    CUDA(cudaFree(b_0));
#endif
#ifndef XIR_CPU_ONLY
    CUDA(cudaFree(b_11));
#endif
#ifdef XIR_CPU_ONLY
    std::puts("backend: CPU expression check (no GPU execution)");
#else
    std::puts("backend: CUDA");
#endif
    std::printf("RESULT: %d mismatched elements\n", failures);
    return failures ? 1 : 0;
}
