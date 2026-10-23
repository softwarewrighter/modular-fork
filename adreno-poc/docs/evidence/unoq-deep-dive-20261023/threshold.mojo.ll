; ModuleID = 'threshold.mojo'
source_filename = "threshold.mojo"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

define dso_local i32 @mojo_adreno_demo(ptr noundef %0, ptr noundef %1, ptr noundef %2, i64 noundef %3) #0 {
  %5 = call i64 @llvm.smax.i64(i64 %3, i64 0)
  %6 = mul i64 %3, 2
  %7 = mul i64 %3, 3
  %8 = call i64 @llvm.smax.i64(i64 %7, i64 0)
  %9 = icmp eq i64 %3, 8
  %10 = xor i1 %9, true
  br i1 %10, label %11, label %12

11:                                               ; preds = %4
  br label %59

12:                                               ; preds = %4
  br label %13

13:                                               ; preds = %18, %12
  %14 = phi i64 [ 0, %12 ], [ %19, %18 ]
  %15 = icmp slt i64 %14, %5
  br i1 %15, label %16, label %17

16:                                               ; preds = %13
  br label %18

17:                                               ; preds = %13
  br label %33

18:                                               ; preds = %16
  %19 = add i64 %14, 1
  %20 = sitofp i64 %19 to float
  %21 = fdiv float %20, 4.000000e+00
  %22 = fsub contract float %21, 1.000000e+00
  %23 = getelementptr inbounds float, ptr %0, i64 %14
  store float %22, ptr %23, align 4
  %24 = getelementptr inbounds float, ptr %2, i64 %14
  store float %22, ptr %24, align 4
  %25 = fcmp ogt float %22, 5.000000e-01
  %26 = select i1 %25, float 1.000000e+00, float 0.000000e+00
  %27 = add i64 %3, %14
  %28 = getelementptr inbounds float, ptr %2, i64 %27
  %29 = fmul contract float %22, %26
  store float %29, ptr %28, align 4
  %30 = add i64 %6, %14
  %31 = getelementptr inbounds float, ptr %2, i64 %30
  %32 = call float @llvm.maxnum.f32(float %22, float 0.000000e+00)
  store float %32, ptr %31, align 4
  br label %13

33:                                               ; preds = %17
  %34 = call i32 @adreno_threshold_v1(ptr %0, ptr %1, i64 %3, i64 %7)
  %35 = icmp eq i32 %34, 0
  %36 = xor i1 %35, true
  br i1 %36, label %37, label %38

37:                                               ; preds = %33
  br label %57

38:                                               ; preds = %33
  br label %39

39:                                               ; preds = %45, %38
  %40 = phi i64 [ 0, %38 ], [ %46, %45 ]
  %41 = phi i32 [ 0, %38 ], [ %54, %45 ]
  %42 = icmp slt i64 %40, %8
  br i1 %42, label %43, label %44

43:                                               ; preds = %39
  br label %45

44:                                               ; preds = %39
  br label %55

45:                                               ; preds = %43
  %46 = add i64 %40, 1
  %47 = getelementptr inbounds float, ptr %1, i64 %40
  %48 = getelementptr inbounds float, ptr %2, i64 %40
  %49 = load float, ptr %47, align 4
  %50 = load float, ptr %48, align 4
  %51 = fcmp oeq float %49, %50
  %52 = xor i1 %51, true
  %53 = add i32 %41, 1
  %54 = select i1 %52, i32 %53, i32 %41
  br label %39

55:                                               ; preds = %44
  %56 = phi i32 [ %41, %44 ]
  br label %57

57:                                               ; preds = %37, %55
  %58 = phi i32 [ %56, %55 ], [ %34, %37 ]
  br label %59

59:                                               ; preds = %11, %57
  %60 = phi i32 [ %58, %57 ], [ -1, %11 ]
  ret i32 %60
}

declare i32 @adreno_threshold_v1(ptr, ptr, i64, i64) #0

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.smax.i64(i64, i64) #1

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.maxnum.f32(float, float) #1

attributes #0 = { "target-cpu"="cortex-a53" "target-features"="+aes,+crc,+fp-armv8,+neon,+perfmon,+sha2" }
attributes #1 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
