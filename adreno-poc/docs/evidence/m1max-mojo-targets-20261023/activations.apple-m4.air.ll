; ModuleID = 'activation_gpu.mojo'
source_filename = "activation_gpu.metal"
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v16:16:16-v24:32:32-v32:32:32-v48:64:64-v64:64:64-v96:128:128-v128:128:128-v192:256:256-v256:256:256-v512:512:512-v1024:1024:1024-n8:16:32"
target triple = "air64-apple-macosx15.0.0"

declare float @air.fmax.f32(float, float)

declare i32 @air.thread_position_in_threadgroup.x()

declare i32 @air.threads_per_threadgroup.x()

declare i32 @air.threadgroup_position_in_grid.x()

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn
define void @activation_gpu_activations_Po6A6AoA6A6A_2d28411a43ede716(ptr addrspace(1) noundef nonnull "air-buffer-no-alias" "nocapture" "noundef" "readonly" %0, ptr addrspace(1) noundef nonnull "air-buffer-no-alias" "nocapture" "noundef" "readonly" %1, ptr addrspace(1) noundef nonnull "air-buffer-no-alias" "nocapture" "noundef" "writeonly" %2, ptr addrspace(2) noundef "air-buffer-no-alias" "nocapture" "noundef" %3, ptr addrspace(2) noundef "air-buffer-no-alias" "nocapture" "noundef" %4, <3 x i32> %threadgroup_position_in_grid, <3 x i32> %thread_position_in_threadgroup, <3 x i32> %threads_per_threadgroup, <3 x i32> %threads_per_grid, i32 %thread_index_in_simdgroup) local_unnamed_addr #0 {
  %6 = bitcast ptr addrspace(2) %3 to ptr addrspace(2)
  %.loaded = load float, ptr addrspace(2) %6, align 4
  %7 = bitcast ptr addrspace(2) %4 to ptr addrspace(2)
  %.loaded7 = load i32, ptr addrspace(2) %7, align 4
  %8 = bitcast ptr addrspace(1) %2 to ptr addrspace(1)
  %9 = load ptr addrspace(1), ptr addrspace(1) %8, align 8
  %10 = bitcast ptr addrspace(1) %1 to ptr addrspace(1)
  %11 = load ptr addrspace(1), ptr addrspace(1) %10, align 8
  %12 = bitcast ptr addrspace(1) %0 to ptr addrspace(1)
  %13 = load ptr addrspace(1), ptr addrspace(1) %12, align 8
  %14 = extractelement <3 x i32> %threadgroup_position_in_grid, i64 0
  %15 = zext i32 %14 to i64
  %16 = extractelement <3 x i32> %threads_per_threadgroup, i64 0
  %17 = sext i32 %16 to i64
  %18 = mul i64 %15, %17
  %19 = extractelement <3 x i32> %thread_position_in_threadgroup, i64 0
  %20 = zext i32 %19 to i64
  %21 = add i64 %18, %20
  %22 = bitcast ptr addrspace(1) %9 to ptr addrspace(1)
  %23 = getelementptr inbounds float, ptr addrspace(1) %22, i64 %21
  %24 = bitcast ptr addrspace(1) %23 to ptr addrspace(1)
  %25 = bitcast ptr addrspace(1) %11 to ptr addrspace(1)
  %26 = getelementptr inbounds float, ptr addrspace(1) %25, i64 %21
  %27 = bitcast ptr addrspace(1) %26 to ptr addrspace(1)
  %28 = bitcast ptr addrspace(1) %13 to ptr addrspace(1)
  %29 = getelementptr inbounds float, ptr addrspace(1) %28, i64 %21
  %30 = bitcast ptr addrspace(1) %29 to ptr addrspace(1)
  %31 = sext i32 %.loaded7 to i64
  %32 = icmp slt i64 %21, %31
  br i1 %32, label %33, label %42

33:                                               ; preds = %5
  %34 = bitcast ptr addrspace(1) %30 to ptr addrspace(1)
  %35 = load float, ptr addrspace(1) %34, align 4
  %36 = fcmp ogt float %35, %.loaded
  %37 = select i1 %36, float 1.000000e+00, float 0.000000e+00
  %38 = fmul contract float %35, %37
  %39 = bitcast ptr addrspace(1) %27 to ptr addrspace(1)
  store float %38, ptr addrspace(1) %39, align 4
  %40 = call float @air.fmax.f32(float %35, float 0.000000e+00)
  %41 = bitcast ptr addrspace(1) %24 to ptr addrspace(1)
  store float %40, ptr addrspace(1) %41, align 4
  br label %43

42:                                               ; preds = %5
  br label %43

43:                                               ; preds = %33, %42
  ret void
}

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn "approx-func-fp-math"="true" "frame-pointer"="all" "memory"="argmem: readwrite" "metal.kernel"="true" "metal.thread_args_added"="true" "metal.thread_index_in_simdgroup_idx"="9" "metal.thread_position_in_threadgroup_idx"="6" "metal.threadgroup_position_in_grid_idx"="5" "metal.threads_per_grid_idx"="8" "metal.threads_per_threadgroup_idx"="7" "min-legal-vector-width"="0" "no-builtins" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="true" }

!air.kernel = !{!31}
!air.compile_options = !{!3, !4, !5}
!air.language_version = !{!6}
!air.source_file_name = !{!7}
!llvm.ident = !{!8}
!air.version = !{!18}
!llvm.module.flags = !{!9, !10, !11, !12, !13, !14, !15, !16, !17}

!3 = !{!"air.compile.denorms_disable"}
!4 = !{!"air.compile.fast_math_disable"}
!5 = !{!"air.compile.framebuffer_fetch_enable"}
!6 = !{!"Metal", i32 3, i32 2, i32 0}
!7 = !{!"activation_gpu.metal"}
!8 = !{!"Apple metal version 32023.620 (metalfe-32023.620)"}
!9 = !{i32 1, !"SDK Version", [2 x i32] [i32 15, i32 5]}
!10 = !{i32 2, !"wchar_size", i32 4}
!11 = !{i32 4, !"frame-pointer", i32 2}
!12 = !{i32 7, !"air.max_device_buffers", i32 31}
!13 = !{i32 7, !"air.max_constant_buffers", i32 31}
!14 = !{i32 7, !"air.max_threadgroup_buffers", i32 31}
!15 = !{i32 7, !"air.max_textures", i32 128}
!16 = !{i32 7, !"air.max_read_write_textures", i32 8}
!17 = !{i32 7, !"air.max_samplers", i32 16}
!18 = !{i32 2, i32 7, i32 0}
!19 = !{}
!20 = !{i32 0, !"air.buffer", !"air.location_index", i32 0, i32 1, !"air.read", !"air.address_space", i32 1, !"air.arg_type_name", !"void"}
!21 = !{i32 1, !"air.buffer", !"air.location_index", i32 1, i32 1, !"air.read", !"air.address_space", i32 1, !"air.arg_type_name", !"void"}
!22 = !{i32 2, !"air.buffer", !"air.location_index", i32 2, i32 1, !"air.write", !"air.address_space", i32 1, !"air.arg_type_name", !"void"}
!23 = !{i32 3, !"air.buffer", !"air.location_index", i32 3, i32 1, !"air.read", !"air.address_space", i32 2, !"air.arg_type_name", !"float"}
!24 = !{i32 4, !"air.buffer", !"air.location_index", i32 4, i32 1, !"air.read", !"air.address_space", i32 2, !"air.arg_type_name", !"int"}
!25 = !{i32 5, !"air.threadgroup_position_in_grid", !"air.arg_type_name", !"uint3", !"air.arg_name", !"threadgroup_position_in_grid", !"air.arg_unused"}
!26 = !{i32 6, !"air.thread_position_in_threadgroup", !"air.arg_type_name", !"uint3", !"air.arg_name", !"thread_position_in_threadgroup", !"air.arg_unused"}
!27 = !{i32 7, !"air.threads_per_threadgroup", !"air.arg_type_name", !"uint3", !"air.arg_name", !"threads_per_threadgroup", !"air.arg_unused"}
!28 = !{i32 8, !"air.threads_per_grid", !"air.arg_type_name", !"uint3", !"air.arg_name", !"threads_per_grid", !"air.arg_unused"}
!29 = !{i32 9, !"air.thread_index_in_simdgroup", !"air.arg_type_name", !"uint", !"air.arg_name", !"thread_index_in_simdgroup"}
!30 = !{!20, !21, !22, !23, !24, !25, !26, !27, !28, !29}
!31 = !{ptr @activation_gpu_activations_Po6A6AoA6A6A_2d28411a43ede716, !19, !30}
