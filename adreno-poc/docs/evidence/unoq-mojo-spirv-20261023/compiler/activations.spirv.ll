; Audited NVPTX scalar kernel retargeted to OpenCL SPIR-V LLVM IR.
target datalayout = "e-p:64:64-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "spirv64-unknown-unknown"

define dso_local spir_kernel void @activation_gpu_activations_Po6A6AoA6A6A_2d28411a43ede716(ptr addrspace(1) noundef %0, ptr addrspace(1) noundef %1, ptr addrspace(1) noundef %2, float noundef %3, i32 noundef %4) {
  %retarget_6 = call spir_func i64 @_Z12get_group_idj(i32 0)
  %6 = trunc i64 %retarget_6 to i32
  %7 = zext i32 %6 to i64
  %retarget_8 = call spir_func i64 @_Z14get_local_sizej(i32 0)
  %8 = trunc i64 %retarget_8 to i32
  %9 = sext i32 %8 to i64
  %10 = mul i64 %7, %9
  %retarget_11 = call spir_func i64 @_Z12get_local_idj(i32 0)
  %11 = trunc i64 %retarget_11 to i32
  %12 = zext i32 %11 to i64
  %13 = add i64 %10, %12
  %14 = getelementptr inbounds float, ptr addrspace(1) %2, i64 %13
  %15 = getelementptr inbounds float, ptr addrspace(1) %1, i64 %13
  %16 = getelementptr inbounds float, ptr addrspace(1) %0, i64 %13
  %17 = sext i32 %4 to i64
  %18 = icmp slt i64 %13, %17
  br i1 %18, label %19, label %25

19:                                               ; preds = %5
  %20 = load float, ptr addrspace(1) %16, align 4
  %21 = fcmp ogt float %20, %3
  %22 = select i1 %21, float 1.000000e+00, float 0.000000e+00
  %23 = fmul contract float %20, %22
  store float %23, ptr addrspace(1) %15, align 4
  %24 = call float @llvm.maxnum.f32(float %20, float 0.000000e+00)
  store float %24, ptr addrspace(1) %14, align 4
  br label %26

25:                                               ; preds = %5
  br label %26

26:                                               ; preds = %25, %19
  ret void
}
declare float @llvm.maxnum.f32(float, float)

declare spir_func i64 @_Z12get_group_idj(i32)
declare spir_func i64 @_Z14get_local_sizej(i32)
declare spir_func i64 @_Z12get_local_idj(i32)
