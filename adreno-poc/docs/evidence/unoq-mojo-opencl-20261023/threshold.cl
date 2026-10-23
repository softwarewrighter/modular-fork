// X_eTaL-gpu: generated OpenCL C 1.2. Floored division and remainder, as X_eTaL's d_iv and m_od.
inline long xetal_idiv_long(long a, long b) { long q = a / b; return (a % b != 0 && ((a < 0) != (b < 0))) ? q - 1 : q; }
inline long xetal_imod_long(long a, long b) { return a - xetal_idiv_long(a, b) * b; }
inline int xetal_idiv_int(int a, int b) { int q = a / b; return (a % b != 0 && ((a < 0) != (b < 0))) ? q - 1 : q; }
inline int xetal_imod_int(int a, int b) { return a - xetal_idiv_int(a, b) * b; }

// k0: 8 elements, one work-item each; computes %gt %mask %threshold %relu
__kernel void k0(__global const float* b_x, __global float* b_threshold, __global float* b_relu) {
    size_t i = get_global_id(0);
    if (i >= 8) return;
    int t_gt = (b_x[i] > 0.5f);
    float t_mask = (float)t_gt;
    float t_threshold = (b_x[i] * t_mask);
    float t_relu = fmax(b_x[i], 0.0f);
    b_threshold[i] = t_threshold;
    b_relu[i] = t_relu;
}
