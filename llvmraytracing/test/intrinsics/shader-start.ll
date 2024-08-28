; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 4
; RUN: opt --verify-each -passes='lower-raytracing-pipeline,lint' -S %s --lint-abort-on-error | FileCheck %s

%struct.DispatchSystemData = type { i32 }
%struct.SystemData = type { %struct.DispatchSystemData }
%struct.HitData = type { float, i32 }
%struct.BuiltInTriangleIntersectionAttributes = type { <2 x float> }

declare !pointeetys !8 i32 @_cont_GetLocalRootIndex(%struct.DispatchSystemData*)
declare !pointeetys !13 i1 @_cont_ReportHit(%struct.DispatchSystemData* %data, float %t, i32 %hitKind)
declare !pointeetys !15 %struct.BuiltInTriangleIntersectionAttributes @_cont_GetTriangleHitAttributes(%struct.SystemData*) #0

define void @main() !lgc.rt.shaderstage !10 {
; CHECK-LABEL: define %struct.DispatchSystemData @main(
; CHECK-SAME: i64 [[RETURNADDR:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP0:%.*]], [8 x i32] [[PADDING:%.*]], [30 x i32] [[PAYLOAD:%.*]]) !lgc.rt.shaderstage [[META5:![0-9]+]] !continuation.registercount [[META0:![0-9]+]] !continuation [[META6:![0-9]+]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA]], align 8
; CHECK-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA:%.*]] = alloca [30 x i32], align 4
; CHECK-NEXT:    store [30 x i32] [[PAYLOAD]], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; CHECK-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP0]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; CHECK-NEXT:    store i32 123, ptr [[SYSTEM_DATA_ALLOCA]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = load [30 x i32], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i64 [[RETURNADDR]], i32 -1, {} poison, i64 poison, [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP1]], [8 x i32] poison, [30 x i32] [[TMP2]]), !continuation.registercount [[META0]]
; CHECK-NEXT:    unreachable
;
entry:
  ret void
}

define void @_cont_ShaderStart(%struct.DispatchSystemData* %data) !pointeetys !11 {
; CHECK-LABEL: define void @_cont_ShaderStart(
; CHECK-SAME: ptr [[DATA:%.*]]) !pointeetys [[META3:![0-9]+]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = getelementptr [[STRUCT_DISPATCHSYSTEMDATA:%.*]], ptr [[DATA]], i32 0, i32 0
; CHECK-NEXT:    store i32 123, ptr [[TMP0]], align 4
; CHECK-NEXT:    ret void
;
entry:
  %0 = getelementptr %struct.DispatchSystemData, ptr %data, i32 0, i32 0
  store i32 123, ptr %0, align 4
  ret void
}

!0 = !{null, !"", null, !1, !6}
!1 = !{!2, null, null, null}
!2 = !{!3}
!3 = !{i1 ()* @main, !"main", null, null, !4}
!4 = !{i32 8, i32 7, i32 6, i32 16, i32 7, i32 8, i32 5, !5}
!5 = !{i32 0}
!6 = !{i32 0, i64 65536}
!7 = !{i32 21}
!8 = !{%struct.DispatchSystemData poison}
!9 = !{i32 0, %struct.DispatchSystemData poison}
!10 = !{i32 1}
!11 = !{%struct.DispatchSystemData poison}
!12 = !{i32 0, %struct.DispatchSystemData poison}
!13 = !{%struct.DispatchSystemData poison}
!14 = !{i32 0, %struct.SystemData poison}
!15 = !{%struct.SystemData poison}
;.
; CHECK: [[META0]] = !{i32 30}
; CHECK: [[META3]] = !{%struct.DispatchSystemData poison}
; CHECK: [[META5]] = !{i32 1}
; CHECK: [[META6]] = !{ptr @main}
;.
