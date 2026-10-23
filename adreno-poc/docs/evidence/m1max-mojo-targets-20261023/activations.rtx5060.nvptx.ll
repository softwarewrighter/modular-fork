; ModuleID = 'activation_gpu.mojo'
source_filename = "activation_gpu.mojo"
target datalayout = "e-p3:32:32-p4:32:32-p5:32:32-p6:32:32-p7:32:32-p101:32:32-i64:64-i128:128-i256:256-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

; Function Attrs: norecurse
define dso_local ptx_kernel void @activation_gpu_activations_Po6A6AoA6A6A_2d28411a43ede716(ptr noundef %0, ptr noundef %1, ptr noundef %2, float noundef %3, i32 noundef %4) #0 {
  %6 = call i32 @llvm.nvvm.read.ptx.sreg.ctaid.x()
  %7 = zext i32 %6 to i64
  %8 = call i32 @llvm.nvvm.read.ptx.sreg.ntid.x()
  %9 = sext i32 %8 to i64
  %10 = mul i64 %7, %9
  %11 = call i32 @llvm.nvvm.read.ptx.sreg.tid.x()
  %12 = zext i32 %11 to i64
  %13 = add i64 %10, %12
  %14 = getelementptr inbounds float, ptr %2, i64 %13
  %15 = getelementptr inbounds float, ptr %1, i64 %13
  %16 = getelementptr inbounds float, ptr %0, i64 %13
  %17 = sext i32 %4 to i64
  %18 = icmp slt i64 %13, %17
  br i1 %18, label %19, label %25

19:                                               ; preds = %5
  %20 = load float, ptr %16, align 4
  %21 = fcmp ogt float %20, %3
  %22 = select i1 %21, float 1.000000e+00, float 0.000000e+00
  %23 = fmul contract float %20, %22
  store float %23, ptr %15, align 4
  %24 = call float @llvm.maxnum.f32(float %20, float 0.000000e+00)
  store float %24, ptr %14, align 4
  br label %26

25:                                               ; preds = %5
  br label %26

26:                                               ; preds = %25, %19
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare noundef range(i32 0, 2147483647) i32 @llvm.nvvm.read.ptx.sreg.ctaid.x() #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare noundef range(i32 1, 1025) i32 @llvm.nvvm.read.ptx.sreg.ntid.x() #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare noundef range(i32 0, 1024) i32 @llvm.nvvm.read.ptx.sreg.tid.x() #1

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.maxnum.f32(float, float) #2

attributes #0 = { norecurse "target-cpu"="sm_120a" "target-features"="+ptx87,+sm_120a" "tune-cpu"="sm_120a" }
attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #2 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
