; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 3
; RUN: opt --verify-each -passes='lower-raytracing-pipeline,lint,sroa,lint,lower-await,lint,coro-early,dxil-coro-split,coro-cleanup,lint,legacy-cleanup-continuations,lint,dxil-cont-post-process,lint,continuations-lint,remove-types-metadata' -S %s --lint-abort-on-error | FileCheck -check-prefix=ALL %s
; RUN: opt --verify-each -passes='lower-raytracing-pipeline,lint,continuations-lint,remove-types-metadata' -S %s --lint-abort-on-error | FileCheck -check-prefix=LOWERRAYTRACINGPIPELINE %s

%struct.DispatchSystemData = type { i32 }
%struct.BuiltInTriangleIntersectionAttributes = type { <2 x float> }
%struct.HitData = type { float, i32 }
%struct.Payload = type { [4 x i32] }
%struct.SystemData = type { float }
%struct.TraversalData = type { i32 }

@debug_global = external global i32

declare i32 @_AmdContPayloadRegistersGetI32(i32)

declare !pointeetys !9 i32 @_cont_GetLocalRootIndex(%struct.DispatchSystemData*)

declare !pointeetys !11 %struct.BuiltInTriangleIntersectionAttributes @_cont_GetTriangleHitAttributes(%struct.DispatchSystemData*)

declare !pointeetys !12 i32 @_cont_HitKind(%struct.DispatchSystemData*, %struct.HitData*)

declare !pointeetys !17 i1 @_cont_ReportHit(%struct.TraversalData* %data, float %t, i32 %hitKind)

define void @_cont_ExitRayGen(ptr nocapture readonly %data) alwaysinline nounwind !pointeetys !{%struct.DispatchSystemData poison} {
  ret void
}

declare void @lgc.cps.jump(...)

define void @_cont_Traversal(%struct.TraversalData %data) #1 !lgc.rt.shaderstage !3 {
; ALL-LABEL: define void @_cont_Traversal(
; ALL-SAME: i32 [[CSPINIT:%.*]], i64 [[RETURNADDR:%.*]], [[STRUCT_TRAVERSALDATA:%.*]] [[TMP0:%.*]], [8 x i32] [[PADDING:%.*]], [4 x i32] [[PAYLOAD:%.*]]) !lgc.rt.shaderstage [[META2:![0-9]+]] !continuation.registercount [[META0:![0-9]+]] !continuation [[META3:![0-9]+]] !continuation.state [[META4:![0-9]+]] {
; ALL-NEXT:  entry:
; ALL-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; ALL-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; ALL-NEXT:    [[PAYLOAD_FCA_0_EXTRACT:%.*]] = extractvalue [4 x i32] [[PAYLOAD]], 0
; ALL-NEXT:    [[PAYLOAD_FCA_1_EXTRACT:%.*]] = extractvalue [4 x i32] [[PAYLOAD]], 1
; ALL-NEXT:    [[PAYLOAD_FCA_5_EXTRACT:%.*]] = extractvalue [4 x i32] [[PAYLOAD]], 2
; ALL-NEXT:    [[PAYLOAD_FCA_3_EXTRACT:%.*]] = extractvalue [4 x i32] [[PAYLOAD]], 3
; ALL-NEXT:    [[DOTFCA_0_EXTRACT:%.*]] = extractvalue [[STRUCT_TRAVERSALDATA]] [[TMP0]], 0
; ALL-NEXT:    store i32 [[PAYLOAD_FCA_5_EXTRACT]], ptr @debug_global, align 4
; ALL-NEXT:    [[DOTFCA_0_INSERT:%.*]] = insertvalue [4 x i32] poison, i32 [[PAYLOAD_FCA_0_EXTRACT]], 0
; ALL-NEXT:    [[DOTFCA_1_INSERT:%.*]] = insertvalue [4 x i32] [[DOTFCA_0_INSERT]], i32 [[PAYLOAD_FCA_1_EXTRACT]], 1
; ALL-NEXT:    [[DOTFCA_2_INSERT:%.*]] = insertvalue [4 x i32] [[DOTFCA_1_INSERT]], i32 [[PAYLOAD_FCA_5_EXTRACT]], 2
; ALL-NEXT:    [[DOTFCA_3_INSERT:%.*]] = insertvalue [4 x i32] [[DOTFCA_2_INSERT]], i32 [[PAYLOAD_FCA_3_EXTRACT]], 3
; ALL-NEXT:    [[TMP1:%.*]] = load i32, ptr [[CSP]], align 4
; ALL-NEXT:    call void (...) @lgc.ilcps.waitContinue(i64 0, i64 -1, i32 [[TMP1]], i64 poison, [[STRUCT_SYSTEMDATA:%.*]] poison, [8 x i32] poison, [4 x i32] [[DOTFCA_3_INSERT]])
; ALL-NEXT:    unreachable
;
; LOWERRAYTRACINGPIPELINE-LABEL: define %struct.TraversalData @_cont_Traversal(
; LOWERRAYTRACINGPIPELINE-SAME: i64 [[RETURNADDR:%.*]], [[STRUCT_TRAVERSALDATA:%.*]] [[TMP0:%.*]], [8 x i32] [[PADDING:%.*]], [4 x i32] [[PAYLOAD:%.*]]) !lgc.rt.shaderstage [[META2:![0-9]+]] !continuation.registercount [[META0:![0-9]+]] !continuation [[META3:![0-9]+]] {
; LOWERRAYTRACINGPIPELINE-NEXT:  entry:
; LOWERRAYTRACINGPIPELINE-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca [[STRUCT_TRAVERSALDATA]], align 8
; LOWERRAYTRACINGPIPELINE-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA:%.*]] = alloca [4 x i32], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store [4 x i32] [[PAYLOAD]], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store [[STRUCT_TRAVERSALDATA]] [[TMP0]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP1:%.*]] = getelementptr [4 x i32], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], i32 0, i32 2
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP2:%.*]] = load i32, ptr [[TMP1]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    store i32 [[TMP2]], ptr @debug_global, align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    [[TMP3:%.*]] = load [4 x i32], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; LOWERRAYTRACINGPIPELINE-NEXT:    call void (...) @lgc.cps.jump(i64 0, i32 -1, {} poison, i64 poison, [[STRUCT_SYSTEMDATA:%.*]] poison, [8 x i32] poison, [4 x i32] [[TMP3]]), !waitmask [[META4:![0-9]+]], !continuation.registercount [[META0]]
; LOWERRAYTRACINGPIPELINE-NEXT:    unreachable
;
entry:
  %val = call i32 @_AmdContPayloadRegistersGetI32(i32 2)
  store i32 %val, i32* @debug_global, align 4
  call void (...) @lgc.cps.jump(i64 0, i32 -1, {} poison, i64 poison, %struct.SystemData poison), !waitmask !2
  unreachable
}

!continuation.maxPayloadRegisterCount = !{!18}

!2 = !{i32 -1}
!3 = !{i32 6}
!4 = !{i32 8, i32 12, i32 6, i32 16, i32 7, i32 8, i32 5, !5}
!5 = !{i32 0}
!6 = !{i32 0, i64 65536}
!8 = !{i32 8, i32 10, i32 6, i32 16, i32 7, i32 8, i32 5, !5}
!9 = !{%struct.DispatchSystemData poison}
!10 = !{i32 0, %struct.DispatchSystemData poison}
!11 = !{%struct.DispatchSystemData poison}
!12 = !{null, %struct.DispatchSystemData poison, %struct.HitData poison}
!13 = !{i32 0, %struct.HitData poison}
!14 = !{null, %struct.Payload poison, %struct.Payload poison}
!15 = !{i32 0, %struct.Payload poison}
!16 = !{i32 0, %struct.TraversalData poison}
!17 = !{%struct.TraversalData poison}
!18 = !{i32 4}
