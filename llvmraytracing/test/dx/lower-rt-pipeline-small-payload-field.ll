; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --include-generated-funcs --version 3
; Test copying of fields between local and global payload whose size
; is not a multiple of i32s, requiring copies at a smaller granularity
; for at least a suffix of the fields.
; RUN: opt --verify-each -passes='dxil-cont-lgc-rt-op-converter,lint,lower-raytracing-pipeline,lint,continuations-lint,remove-types-metadata' -S %s --lint-abort-on-error | FileCheck %s

target datalayout = "e-m:e-p:64:32-p20:32:32-p21:32:32-p32:32:32-i1:32-i8:8-i16:16-i32:32-i64:32-f16:16-f32:32-f64:32-v8:8-v16:16-v32:32-v48:32-v64:32-v80:32-v96:32-v112:32-v128:32-v144:32-v160:32-v176:32-v192:32-v208:32-v224:32-v240:32-v256:32-n8:16:32"

; This payload struct is PAQed as follows:
; struct [raypayload] Payload
; {
;     int v[5]                 : write(caller) : read(miss, caller);
;     min16uint smallField     : write(miss)   : read(caller);
;     min16uint3 smallFieldVec : write(miss)   : read(caller);
; };
; The last two fields are particularly relevant.
; The i16 needs special treatment, as well as the last two bytes of the <3 x i16>.
%struct.PAQPayload = type { [5 x i32], i16, <3 x i16> }
; Identical, but without PAQ:
%struct.NoPAQPayload = type { [5 x i32], i16, <3 x i16> }
%struct.DispatchSystemData = type { i32 }
%struct.TraversalData = type { %struct.SystemData }
%struct.SystemData = type { %struct.DispatchSystemData }
%struct.AnyHitTraversalData = type { %struct.TraversalData, %struct.HitData }
%struct.HitData = type { float, i32 }
%struct.BuiltInTriangleIntersectionAttributes = type { <2 x float> }

; Function Attrs: nounwind
define void @MissPAQ(%struct.PAQPayload* noalias nocapture %payload) #0 !pointeetys !17 {
  %1 = getelementptr inbounds %struct.PAQPayload, %struct.PAQPayload* %payload, i32 0, i32 1
  store i16 17, i16* %1, align 4
  ret void
}

; Function Attrs: nounwind
define void @MissNoPAQ(%struct.NoPAQPayload* noalias nocapture %payload) #0 !pointeetys !31 {
  %1 = getelementptr inbounds %struct.NoPAQPayload, %struct.NoPAQPayload* %payload, i32 0, i32 1
  store i16 17, i16* %1, align 4
  ret void
}

; Function Attrs: alwaysinline
declare %struct.DispatchSystemData @_AmdAwaitTraversal(i64, %struct.TraversalData) #1

; Function Attrs: alwaysinline
declare %struct.DispatchSystemData @_AmdAwaitShader(i64, %struct.DispatchSystemData) #1

; Function Attrs: alwaysinline
declare %struct.AnyHitTraversalData @_AmdAwaitAnyHit(i64, %struct.AnyHitTraversalData, float, i32) #1

; Function Attrs: alwaysinline
declare !pointeetys !19 %struct.BuiltInTriangleIntersectionAttributes @_cont_GetTriangleHitAttributes(%struct.SystemData*) #1

; Function Attrs: alwaysinline
declare !pointeetys !21 void @_cont_SetTriangleHitAttributes(%struct.SystemData*, %struct.BuiltInTriangleIntersectionAttributes) #1

; Function Attrs: alwaysinline
declare !pointeetys !22 i1 @_cont_IsEndSearch(%struct.TraversalData*) #1

; Function Attrs: nounwind memory(read)
declare !pointeetys !24 i32 @_cont_HitKind(%struct.SystemData* nocapture readnone, %struct.HitData*) #2

; Function Attrs: nounwind memory(none)
declare !pointeetys !26 void @_AmdRestoreSystemData(%struct.DispatchSystemData*) #3

; Function Attrs: nounwind memory(none)
declare !pointeetys !28 void @_AmdRestoreSystemDataAnyHit(%struct.AnyHitTraversalData*) #3

; Function Attrs: alwaysinline
define i32 @_cont_GetLocalRootIndex(%struct.DispatchSystemData* %data) #1 !pointeetys !30 {
  ret i32 5
}

declare !pointeetys !31 i1 @_cont_ReportHit(%struct.AnyHitTraversalData* %data, float %t, i32 %hitKind)

attributes #0 = { nounwind }
attributes #1 = { alwaysinline }
attributes #2 = { nounwind memory(read) }
attributes #3 = { nounwind memory(none) }

!llvm.ident = !{!0}
!dx.version = !{!1}
!dx.valver = !{!1}
!dx.shaderModel = !{!2}
!dx.typeAnnotations = !{!3}
!dx.dxrPayloadAnnotations = !{!8}
!dx.entryPoints = !{!12, !14, !33}

!0 = !{!"dxcoob 2019.05.00"}
!1 = !{i32 1, i32 7}
!2 = !{!"lib", i32 6, i32 7}
!3 = !{i32 1, void (%struct.PAQPayload*)* @MissPAQ, !4}
!4 = !{!5, !7}
!5 = !{i32 1, !6, !6}
!6 = !{}
!7 = !{i32 2, !6, !6}
!8 = !{i32 0, %struct.PAQPayload undef, !9}
!9 = !{!10, !11, !11}
!10 = !{i32 0, i32 259}
!11 = !{i32 0, i32 513}
!12 = !{null, !"", null, null, !13}
!13 = !{i32 0, i64 32}
!14 = !{void (%struct.PAQPayload*)* @MissPAQ, !"MissPAQ", null, null, !15}
!15 = !{i32 8, i32 11, i32 6, i32 24, i32 5, !16}
!16 = !{i32 0}
!17 = !{%struct.PAQPayload poison}
!18 = !{i32 0, %struct.PAQPayload poison}
!19 = !{%struct.SystemData poison}
!20 = !{i32 0, %struct.SystemData poison}
!21 = !{%struct.SystemData poison}
!22 = !{%struct.TraversalData poison}
!23 = !{i32 0, %struct.TraversalData poison}
!24 = !{null, %struct.SystemData poison, %struct.HitData poison}
!25 = !{i32 0, %struct.HitData poison}
!26 = !{%struct.DispatchSystemData poison}
!27 = !{i32 0, %struct.DispatchSystemData poison}
!28 = !{%struct.AnyHitTraversalData poison}
!29 = !{i32 0, %struct.AnyHitTraversalData poison}
!30 = !{%struct.DispatchSystemData poison}
!31 = !{%struct.NoPAQPayload poison}
!32 = !{i32 0, %struct.NoPAQPayload poison}
!33 = !{void (%struct.NoPAQPayload*)* @MissNoPAQ, !"MissNoPAQ", null, null, !34}
!34 = !{i32 8, i32 11, i32 6, i32 24, i32 5, !35}
!35 = !{i32 0}

; CHECK-LABEL: define %struct.DispatchSystemData @MissPAQ(
; CHECK-SAME: i64 [[RETURNADDR:%.*]], [[STRUCT_SYSTEMDATA:%.*]] [[TMP0:%.*]], [16 x i32] [[PADDING:%.*]], [11 x i32] [[PAYLOAD:%.*]]) #[[ATTR0:[0-9]+]] !lgc.rt.shaderstage [[META21:![0-9]+]] !continuation.registercount [[META22:![0-9]+]] !continuation [[META23:![0-9]+]] {
; CHECK-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca [[STRUCT_SYSTEMDATA]], align 8
; CHECK-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA:%.*]] = alloca [11 x i32], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = alloca [[STRUCT_PAYLOAD:%.*]], align 8
; CHECK-NEXT:    store [11 x i32] [[PAYLOAD]], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; CHECK-NEXT:    store [[STRUCT_SYSTEMDATA]] [[TMP0]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr inbounds [[STRUCT_SYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], i32 0, i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[STRUCT_PAYLOAD]], ptr [[TMP2]], i32 0, i32 0
; CHECK-NEXT:    [[TMP7:%.*]] = load i32, ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; CHECK-NEXT:    store i32 [[TMP7]], ptr [[TMP4]], align 4
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr inbounds i32, ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], i32 7
; CHECK-NEXT:    [[TMP8:%.*]] = getelementptr inbounds i32, ptr [[TMP4]], i32 1
; CHECK-NEXT:    [[TMP10:%.*]] = load i32, ptr [[TMP6]], align 4
; CHECK-NEXT:    store i32 [[TMP10]], ptr [[TMP8]], align 4
; CHECK-NEXT:    [[TMP11:%.*]] = getelementptr inbounds i32, ptr [[TMP8]], i32 1
; CHECK-NEXT:    [[TMP19:%.*]] = getelementptr inbounds i32, ptr [[TMP6]], i32 1
; CHECK-NEXT:    [[TMP12:%.*]] = load i32, ptr [[TMP19]], align 4
; CHECK-NEXT:    store i32 [[TMP12]], ptr [[TMP11]], align 4
; CHECK-NEXT:    [[TMP13:%.*]] = getelementptr inbounds i32, ptr [[TMP8]], i32 2
; CHECK-NEXT:    [[TMP25:%.*]] = getelementptr inbounds i32, ptr [[TMP6]], i32 2
; CHECK-NEXT:    [[TMP14:%.*]] = load i32, ptr [[TMP25]], align 4
; CHECK-NEXT:    store i32 [[TMP14]], ptr [[TMP13]], align 4
; CHECK-NEXT:    [[TMP15:%.*]] = getelementptr inbounds i32, ptr [[TMP8]], i32 3
; CHECK-NEXT:    [[TMP34:%.*]] = getelementptr inbounds i32, ptr [[TMP6]], i32 3
; CHECK-NEXT:    [[TMP16:%.*]] = load i32, ptr [[TMP34]], align 4
; CHECK-NEXT:    store i32 [[TMP16]], ptr [[TMP15]], align 4
; CHECK-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; CHECK-NEXT:    [[TMP17:%.*]] = getelementptr inbounds [[STRUCT_PAYLOAD]], ptr [[TMP2]], i32 0, i32 1
; CHECK-NEXT:    store i16 17, ptr [[TMP17]], align 4
; CHECK-NEXT:    [[TMP18:%.*]] = getelementptr inbounds [[STRUCT_PAYLOAD]], ptr [[TMP2]], i32 0, i32 1
; CHECK-NEXT:    [[TMP20:%.*]] = getelementptr inbounds i32, ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], i32 1
; CHECK-NEXT:    [[TMP21:%.*]] = load i8, ptr [[TMP18]], align 1
; CHECK-NEXT:    store i8 [[TMP21]], ptr [[TMP20]], align 1
; CHECK-NEXT:    [[TMP35:%.*]] = getelementptr i8, ptr [[TMP20]], i32 1
; CHECK-NEXT:    [[TMP22:%.*]] = getelementptr i8, ptr [[TMP18]], i32 1
; CHECK-NEXT:    [[TMP23:%.*]] = load i8, ptr [[TMP22]], align 1
; CHECK-NEXT:    store i8 [[TMP23]], ptr [[TMP35]], align 1
; CHECK-NEXT:    [[TMP24:%.*]] = getelementptr inbounds [[STRUCT_PAYLOAD]], ptr [[TMP2]], i32 0, i32 2
; CHECK-NEXT:    [[TMP26:%.*]] = getelementptr inbounds i32, ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], i32 2
; CHECK-NEXT:    [[TMP27:%.*]] = load i32, ptr [[TMP24]], align 4
; CHECK-NEXT:    store i32 [[TMP27]], ptr [[TMP26]], align 4
; CHECK-NEXT:    [[TMP37:%.*]] = getelementptr i8, ptr [[TMP26]], i32 4
; CHECK-NEXT:    [[TMP28:%.*]] = getelementptr i8, ptr [[TMP24]], i32 4
; CHECK-NEXT:    [[TMP29:%.*]] = load i8, ptr [[TMP28]], align 1
; CHECK-NEXT:    store i8 [[TMP29]], ptr [[TMP37]], align 1
; CHECK-NEXT:    [[TMP38:%.*]] = getelementptr i8, ptr [[TMP26]], i32 5
; CHECK-NEXT:    [[TMP30:%.*]] = getelementptr i8, ptr [[TMP24]], i32 5
; CHECK-NEXT:    [[TMP31:%.*]] = load i8, ptr [[TMP30]], align 1
; CHECK-NEXT:    store i8 [[TMP31]], ptr [[TMP38]], align 1
; CHECK-NEXT:    [[TMP32:%.*]] = getelementptr inbounds [[STRUCT_SYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], i32 0, i32 0
; CHECK-NEXT:    [[TMP33:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA:%.*]], ptr [[TMP32]], align 4
; CHECK-NEXT:    [[TMP36:%.*]] = load [11 x i32], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i64 [[RETURNADDR]], i32 -1, {} poison, i64 poison, [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP33]], [16 x i32] poison, [11 x i32] [[TMP36]]), !continuation.registercount [[META22]]
; CHECK-NEXT:    unreachable
;
;
; CHECK-LABEL: define %struct.DispatchSystemData @MissNoPAQ(
; CHECK-SAME: i64 [[RETURNADDR:%.*]], [[STRUCT_SYSTEMDATA:%.*]] [[TMP0:%.*]], [16 x i32] [[PADDING:%.*]], [14 x i32] [[PAYLOAD:%.*]]) #[[ATTR0]] !lgc.rt.shaderstage [[META21]] !continuation.registercount [[META19:![0-9]+]] !continuation [[META24:![0-9]+]] {
; CHECK-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca [[STRUCT_SYSTEMDATA]], align 8
; CHECK-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA:%.*]] = alloca [14 x i32], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = alloca [[STRUCT_NOPAQPAYLOAD:%.*]], align 8
; CHECK-NEXT:    store [14 x i32] [[PAYLOAD]], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; CHECK-NEXT:    store [[STRUCT_SYSTEMDATA]] [[TMP0]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr inbounds [[STRUCT_SYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], i32 0, i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[STRUCT_NOPAQPAYLOAD]], ptr [[TMP2]], i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = load i32, ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; CHECK-NEXT:    store i32 [[TMP5]], ptr [[TMP4]], align 4
; CHECK-NEXT:    [[TMP17:%.*]] = getelementptr inbounds i32, ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], i32 7
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr inbounds i32, ptr [[TMP4]], i32 1
; CHECK-NEXT:    [[TMP9:%.*]] = load i32, ptr [[TMP17]], align 4
; CHECK-NEXT:    store i32 [[TMP9]], ptr [[TMP6]], align 4
; CHECK-NEXT:    [[TMP8:%.*]] = getelementptr inbounds i32, ptr [[TMP6]], i32 1
; CHECK-NEXT:    [[TMP23:%.*]] = getelementptr inbounds i32, ptr [[TMP17]], i32 1
; CHECK-NEXT:    [[TMP11:%.*]] = load i32, ptr [[TMP23]], align 4
; CHECK-NEXT:    store i32 [[TMP11]], ptr [[TMP8]], align 4
; CHECK-NEXT:    [[TMP10:%.*]] = getelementptr inbounds i32, ptr [[TMP6]], i32 2
; CHECK-NEXT:    [[TMP26:%.*]] = getelementptr inbounds i32, ptr [[TMP17]], i32 2
; CHECK-NEXT:    [[TMP15:%.*]] = load i32, ptr [[TMP26]], align 4
; CHECK-NEXT:    store i32 [[TMP15]], ptr [[TMP10]], align 4
; CHECK-NEXT:    [[TMP12:%.*]] = getelementptr inbounds i32, ptr [[TMP6]], i32 3
; CHECK-NEXT:    [[TMP16:%.*]] = getelementptr inbounds i32, ptr [[TMP17]], i32 3
; CHECK-NEXT:    [[TMP19:%.*]] = load i32, ptr [[TMP16]], align 4
; CHECK-NEXT:    store i32 [[TMP19]], ptr [[TMP12]], align 4
; CHECK-NEXT:    [[TMP14:%.*]] = getelementptr inbounds i32, ptr [[TMP6]], i32 4
; CHECK-NEXT:    [[TMP28:%.*]] = getelementptr inbounds i32, ptr [[TMP17]], i32 4
; CHECK-NEXT:    [[TMP21:%.*]] = load i32, ptr [[TMP28]], align 4
; CHECK-NEXT:    store i32 [[TMP21]], ptr [[TMP14]], align 4
; CHECK-NEXT:    [[TMP18:%.*]] = getelementptr inbounds i32, ptr [[TMP6]], i32 5
; CHECK-NEXT:    [[TMP22:%.*]] = getelementptr inbounds i32, ptr [[TMP17]], i32 5
; CHECK-NEXT:    [[TMP54:%.*]] = load i32, ptr [[TMP22]], align 4
; CHECK-NEXT:    store i32 [[TMP54]], ptr [[TMP18]], align 4
; CHECK-NEXT:    [[TMP20:%.*]] = getelementptr inbounds i32, ptr [[TMP6]], i32 6
; CHECK-NEXT:    [[TMP31:%.*]] = getelementptr inbounds i32, ptr [[TMP17]], i32 6
; CHECK-NEXT:    [[TMP55:%.*]] = load i32, ptr [[TMP31]], align 4
; CHECK-NEXT:    store i32 [[TMP55]], ptr [[TMP20]], align 4
; CHECK-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; CHECK-NEXT:    [[TMP24:%.*]] = getelementptr inbounds [[STRUCT_NOPAQPAYLOAD]], ptr [[TMP2]], i32 0, i32 1
; CHECK-NEXT:    store i16 17, ptr [[TMP24]], align 4
; CHECK-NEXT:    [[TMP25:%.*]] = getelementptr inbounds [[STRUCT_NOPAQPAYLOAD]], ptr [[TMP2]], i32 0
; CHECK-NEXT:    [[TMP29:%.*]] = load i32, ptr [[TMP25]], align 4
; CHECK-NEXT:    store i32 [[TMP29]], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; CHECK-NEXT:    [[TMP30:%.*]] = getelementptr inbounds i32, ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], i32 7
; CHECK-NEXT:    [[TMP27:%.*]] = getelementptr inbounds i32, ptr [[TMP25]], i32 1
; CHECK-NEXT:    [[TMP32:%.*]] = load i32, ptr [[TMP27]], align 4
; CHECK-NEXT:    store i32 [[TMP32]], ptr [[TMP30]], align 4
; CHECK-NEXT:    [[TMP33:%.*]] = getelementptr inbounds i32, ptr [[TMP30]], i32 1
; CHECK-NEXT:    [[TMP34:%.*]] = getelementptr inbounds i32, ptr [[TMP27]], i32 1
; CHECK-NEXT:    [[TMP35:%.*]] = load i32, ptr [[TMP34]], align 4
; CHECK-NEXT:    store i32 [[TMP35]], ptr [[TMP33]], align 4
; CHECK-NEXT:    [[TMP36:%.*]] = getelementptr inbounds i32, ptr [[TMP30]], i32 2
; CHECK-NEXT:    [[TMP37:%.*]] = getelementptr inbounds i32, ptr [[TMP27]], i32 2
; CHECK-NEXT:    [[TMP38:%.*]] = load i32, ptr [[TMP37]], align 4
; CHECK-NEXT:    store i32 [[TMP38]], ptr [[TMP36]], align 4
; CHECK-NEXT:    [[TMP39:%.*]] = getelementptr inbounds i32, ptr [[TMP30]], i32 3
; CHECK-NEXT:    [[TMP40:%.*]] = getelementptr inbounds i32, ptr [[TMP27]], i32 3
; CHECK-NEXT:    [[TMP41:%.*]] = load i32, ptr [[TMP40]], align 4
; CHECK-NEXT:    store i32 [[TMP41]], ptr [[TMP39]], align 4
; CHECK-NEXT:    [[TMP42:%.*]] = getelementptr inbounds i32, ptr [[TMP30]], i32 4
; CHECK-NEXT:    [[TMP43:%.*]] = getelementptr inbounds i32, ptr [[TMP27]], i32 4
; CHECK-NEXT:    [[TMP44:%.*]] = load i32, ptr [[TMP43]], align 4
; CHECK-NEXT:    store i32 [[TMP44]], ptr [[TMP42]], align 4
; CHECK-NEXT:    [[TMP51:%.*]] = getelementptr inbounds i32, ptr [[TMP30]], i32 5
; CHECK-NEXT:    [[TMP52:%.*]] = getelementptr inbounds i32, ptr [[TMP27]], i32 5
; CHECK-NEXT:    [[TMP47:%.*]] = load i32, ptr [[TMP52]], align 4
; CHECK-NEXT:    store i32 [[TMP47]], ptr [[TMP51]], align 4
; CHECK-NEXT:    [[TMP48:%.*]] = getelementptr inbounds i32, ptr [[TMP30]], i32 6
; CHECK-NEXT:    [[TMP49:%.*]] = getelementptr inbounds i32, ptr [[TMP27]], i32 6
; CHECK-NEXT:    [[TMP50:%.*]] = load i32, ptr [[TMP49]], align 4
; CHECK-NEXT:    store i32 [[TMP50]], ptr [[TMP48]], align 4
; CHECK-NEXT:    [[TMP45:%.*]] = getelementptr inbounds [[STRUCT_SYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], i32 0, i32 0
; CHECK-NEXT:    [[TMP46:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA:%.*]], ptr [[TMP45]], align 4
; CHECK-NEXT:    [[TMP53:%.*]] = load [14 x i32], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i64 [[RETURNADDR]], i32 -1, {} poison, i64 poison, [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP46]], [16 x i32] poison, [14 x i32] [[TMP53]]), !continuation.registercount [[META19]]
; CHECK-NEXT:    unreachable
;
;
; CHECK-LABEL: define i32 @_cont_GetLocalRootIndex(
; CHECK-SAME: ptr [[DATA:%.*]]) #[[ATTR1:[0-9]+]] {
; CHECK-NEXT:    ret i32 5
;
