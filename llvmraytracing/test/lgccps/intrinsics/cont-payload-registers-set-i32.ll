; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 3
; RUN: opt --verify-each -passes='lower-raytracing-pipeline,lint' -S %s --lint-abort-on-error | FileCheck %s

%struct.AnyHitTraversalData = type { { { i32, i32 }, { i64, i32, <3 x float>, <3 x float>, float, float }, { { float, i32, i32, i32, i32 }, <2 x float>, i32, i32, i32, i32, i32, i32, i32, i64 } }, { float, i32, i32, i32, i32 } }
%struct.DispatchSystemData = type { i32 }

; Need _cont_ReportHit to get system data type
declare !pointeetys !6 i1 @_cont_ReportHit(%struct.AnyHitTraversalData* %data, float %t, i32 %hitKind)

declare !pointeetys !10 i32 @_cont_GetLocalRootIndex(%struct.DispatchSystemData*)

declare i64 @_AmdGetCurrentFuncAddr()
declare void @_AmdContPayloadRegistersSetI32(i32, i32)

define dso_local spir_func { { float, i32, i32, i32, i32 }, <2 x float>, i32 } @_cont_Traversal(ptr addrspace(5) %0) local_unnamed_addr !lgc.shaderstage !0 !pointeetys !1 !lgc.rt.shaderstage !3 {
; CHECK-LABEL: define dso_local spir_func void @_cont_Traversal(
; CHECK-SAME: {} [[CONT_STATE:%.*]], i32 [[RETURNADDR:%.*]], i32 [[SHADER_INDEX:%.*]], { { i32 } } [[SYSTEM_DATA:%.*]], {} [[HIT_ATTRS:%.*]], [41 x i32] [[PADDING:%.*]], [30 x i32] [[PAYLOAD:%.*]]) local_unnamed_addr !lgc.shaderstage [[META4:![0-9]+]] !lgc.rt.shaderstage [[META5:![0-9]+]] !lgc.cps [[META6:![0-9]+]] !continuation [[META7:![0-9]+]] {
; CHECK-NEXT:  .entry:
; CHECK-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca { { i32 } }, align 8, addrspace(5)
; CHECK-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA:%.*]] = alloca [30 x i32], align 4
; CHECK-NEXT:    store [30 x i32] [[PAYLOAD]], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; CHECK-NEXT:    store { { i32 } } [[SYSTEM_DATA]], ptr addrspace(5) [[SYSTEM_DATA_ALLOCA]], align 4
; CHECK-NEXT:    [[TMP0:%.*]] = getelementptr [30 x i32], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], i32 0, i32 3
; CHECK-NEXT:    store i32 42, ptr [[TMP0]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = load [30 x i32], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i32 4, i32 -1, {} poison, i32 poison, i32 5, [42 x i32] poison, [30 x i32] [[TMP1]]), !continuation.registercount [[META0:![0-9]+]]
; CHECK-NEXT:    unreachable
;
.entry:
  call void @_AmdContPayloadRegistersSetI32(i32 3, i32 42)
  call void (...) @lgc.cps.jump(i32 4, i32 -1, {} poison, i32 poison, i32 5)
  unreachable
}

declare void @lgc.cps.jump(...) local_unnamed_addr

!lgc.cps.module = !{}

!0 = !{i32 7}
!1 = !{ { { i32 } } poison}
!3 = !{i32 6}
!5 = !{i32 0, %struct.AnyHitTraversalData poison}
!6 = !{ %struct.AnyHitTraversalData poison}
!7 = !{i32 8}
!9 = !{i32 0, %struct.DispatchSystemData poison}
!10 = !{%struct.DispatchSystemData poison}
