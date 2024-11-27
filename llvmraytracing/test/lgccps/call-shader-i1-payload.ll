; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --include-generated-funcs --version 3
; RUN: opt --verify-each -S -o - -passes='lower-raytracing-pipeline' %s | FileCheck --check-prefixes=LOWER-RAYTRACING-PIPELINE %s
; RUN: opt --verify-each -S -o - -passes='lower-raytracing-pipeline,sroa' %s | FileCheck --check-prefixes=SROA %s

; The test checks the payload alloca is fully written and be promoted to register successfully.

%struct.DispatchSystemData = type { i32 }
%struct.TraversalData = type { %struct.SystemData }
%struct.SystemData = type { %struct.DispatchSystemData }
%struct.MyParams = type { i32, i1 }

%struct.AnyHitTraversalData = type { { { i32, i32 }, { i64, i32, <3 x float>, <3 x float>, float, float }, { { float, i32, i32, i32, i32 }, <2 x float>, i32, i32, i32, i32, i32, i32, i32, i64 } }, { float, i32, i32, i32, i32 } }

; Need _cont_ReportHit to get anyhit traversal system data type
declare  !pointeetys !8 i1 @_cont_ReportHit(%struct.AnyHitTraversalData* %data, float %t, i32 %hitKind)

; Function Attrs: alwaysinline
declare %struct.DispatchSystemData @_AmdAwaitShader(i32, %struct.DispatchSystemData) #0

declare !pointeetys !1 <3 x i32> @_cont_DispatchRaysIndex3(%struct.DispatchSystemData*)

; Function Attrs: alwaysinline
define i32 @_cont_GetLocalRootIndex(ptr %data) #0 !pointeetys !1 {
  ret i32 5
}

; Function Attrs: alwaysinline
define void @_cont_CallShader(ptr %data, i32 %0) #0 !pointeetys !2 {
  %dis_data = load %struct.DispatchSystemData, ptr %data, align 4
  %newdata = call %struct.DispatchSystemData @_AmdAwaitShader(i32 2, %struct.DispatchSystemData %dis_data)
  store %struct.DispatchSystemData %newdata, ptr %data, align 4
  ret void
}

define void @called(ptr %params) !pointeetys !3 !cont.payload.type !4 !lgc.rt.shaderstage !5 {
  call void (...) @lgc.rt.call.callable.shader(i32 2, ptr %params, i32 4), !cont.payload.type !4
  ret void
}

; Function Attrs: nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @lgc.rt.call.callable.shader(...) #1

attributes #0 = { alwaysinline }
attributes #1 = { nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite) }

!lgc.cps.module = !{}

!0 = !{i32 0, %struct.DispatchSystemData poison}
!1 = !{%struct.DispatchSystemData poison}
!2 = !{%struct.DispatchSystemData poison}
!3 = !{%struct.MyParams poison}
!4 = !{%struct.MyParams poison}
!5 = !{i32 5}
!6 = !{i32 0, %struct.MyParams poison}
!7 = !{i32 0, %struct.AnyHitTraversalData poison}
!8 = !{!"function", i1 poison, !7, float poison, i32 poison}

; LOWER-RAYTRACING-PIPELINE-LABEL: define i32 @_cont_GetLocalRootIndex(
; LOWER-RAYTRACING-PIPELINE-SAME: ptr [[DATA:%.*]]) #[[ATTR0:[0-9]+]] !pointeetys [[META3:![0-9]+]] {
; LOWER-RAYTRACING-PIPELINE-NEXT:    ret i32 5
;
;
; LOWER-RAYTRACING-PIPELINE-LABEL: define void @called(
; LOWER-RAYTRACING-PIPELINE-SAME: i32 [[RETURNADDR:%.*]], i32 [[SHADER_INDEX:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[SYSTEM_DATA:%.*]], {} [[HIT_ATTRS:%.*]], [8 x i32] [[PADDING:%.*]], [2 x i32] [[PAYLOAD:%.*]]) !lgc.rt.shaderstage [[META4:![0-9]+]] !lgc.cps [[META1:![0-9]+]] !continuation.registercount [[META1]] !continuation [[META5:![0-9]+]] {
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA]], align 8
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA:%.*]] = alloca [2 x i32], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP1:%.*]] = alloca [[STRUCT_MYPARAMS:%.*]], align 8
; LOWER-RAYTRACING-PIPELINE-NEXT:    store [2 x i32] [[PAYLOAD]], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[SYSTEM_DATA]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP2:%.*]] = getelementptr inbounds [[STRUCT_MYPARAMS]], ptr [[TMP1]], i32 0
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP3:%.*]] = load i32, ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    store i32 [[TMP3]], ptr [[TMP2]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP4:%.*]] = getelementptr inbounds i32, ptr [[TMP2]], i32 1
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP5:%.*]] = getelementptr inbounds i32, ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], i32 1
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP6:%.*]] = load i32, ptr [[TMP5]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    store i32 [[TMP6]], ptr [[TMP4]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[DIS_DATA_I:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP7:%.*]] = getelementptr inbounds [[STRUCT_MYPARAMS]], ptr [[TMP1]], i32 0
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP8:%.*]] = load i32, ptr [[TMP7]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    store i32 [[TMP8]], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP10:%.*]] = getelementptr inbounds i32, ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], i32 1
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP23:%.*]] = getelementptr inbounds i32, ptr [[TMP7]], i32 1
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP11:%.*]] = load i32, ptr [[TMP23]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    store i32 [[TMP11]], ptr [[TMP10]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP12:%.*]] = load [2 x i32], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP13:%.*]] = call { [[STRUCT_DISPATCHSYSTEMDATA]], [8 x i32], [2 x i32] } (...) @lgc.cps.await__sl_s_struct.DispatchSystemDatasa8i32a2i32s(i32 2, i32 4, i32 5, [9 x i32] poison, [2 x i32] [[TMP12]]), !continuation.registercount [[META1]], !continuation.returnedRegistercount [[META1]]
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP14:%.*]] = extractvalue { [[STRUCT_DISPATCHSYSTEMDATA]], [8 x i32], [2 x i32] } [[TMP13]], 2
; LOWER-RAYTRACING-PIPELINE-NEXT:    store [2 x i32] [[TMP14]], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP29:%.*]] = freeze [[STRUCT_MYPARAMS]] poison
; LOWER-RAYTRACING-PIPELINE-NEXT:    store [[STRUCT_MYPARAMS]] [[TMP29]], ptr [[TMP1]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP16:%.*]] = getelementptr inbounds [[STRUCT_MYPARAMS]], ptr [[TMP1]], i32 0
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP17:%.*]] = load i32, ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    store i32 [[TMP17]], ptr [[TMP16]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP18:%.*]] = getelementptr inbounds i32, ptr [[TMP16]], i32 1
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP19:%.*]] = getelementptr inbounds i32, ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], i32 1
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP20:%.*]] = load i32, ptr [[TMP19]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    store i32 [[TMP20]], ptr [[TMP18]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP15:%.*]] = extractvalue { [[STRUCT_DISPATCHSYSTEMDATA]], [8 x i32], [2 x i32] } [[TMP13]], 0
; LOWER-RAYTRACING-PIPELINE-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP15]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP21:%.*]] = getelementptr inbounds [[STRUCT_MYPARAMS]], ptr [[TMP1]], i32 0
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP22:%.*]] = load i32, ptr [[TMP21]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    store i32 [[TMP22]], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP24:%.*]] = getelementptr inbounds i32, ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], i32 1
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP28:%.*]] = getelementptr inbounds i32, ptr [[TMP21]], i32 1
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP25:%.*]] = load i32, ptr [[TMP28]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    store i32 [[TMP25]], ptr [[TMP24]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP30:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    [[TMP27:%.*]] = load [2 x i32], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; LOWER-RAYTRACING-PIPELINE-NEXT:    call void (...) @lgc.cps.jump(i32 [[RETURNADDR]], i32 6, i32 poison, i32 poison, i32 poison, [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP30]], [8 x i32] poison, [2 x i32] [[TMP27]]), !continuation.registercount [[META1]]
; LOWER-RAYTRACING-PIPELINE-NEXT:    unreachable
;
;
; SROA-LABEL: define i32 @_cont_GetLocalRootIndex(
; SROA-SAME: ptr [[DATA:%.*]]) #[[ATTR0:[0-9]+]] !pointeetys [[META3:![0-9]+]] {
; SROA-NEXT:    ret i32 5
;
;
; SROA-LABEL: define void @called(
; SROA-SAME: i32 [[RETURNADDR:%.*]], i32 [[SHADER_INDEX:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[SYSTEM_DATA:%.*]], {} [[HIT_ATTRS:%.*]], [8 x i32] [[PADDING:%.*]], [2 x i32] [[PAYLOAD:%.*]]) !lgc.rt.shaderstage [[META4:![0-9]+]] !lgc.cps [[META1:![0-9]+]] !continuation.registercount [[META1]] !continuation [[META5:![0-9]+]] {
; SROA-NEXT:    [[DOTSROA_5:%.*]] = alloca i8, align 4
; SROA-NEXT:    [[PAYLOAD_FCA_0_EXTRACT:%.*]] = extractvalue [2 x i32] [[PAYLOAD]], 0
; SROA-NEXT:    [[PAYLOAD_FCA_1_EXTRACT:%.*]] = extractvalue [2 x i32] [[PAYLOAD]], 1
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_8_4_EXTRACT_TRUNC:%.*]] = trunc i32 [[PAYLOAD_FCA_1_EXTRACT]] to i8
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_EXTRACT_SHIFT:%.*]] = lshr i32 [[PAYLOAD_FCA_1_EXTRACT]], 8
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_EXTRACT_TRUNC:%.*]] = trunc i32 [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_EXTRACT_SHIFT]] to i24
; SROA-NEXT:    [[SYSTEM_DATA_FCA_0_EXTRACT:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[SYSTEM_DATA]], 0
; SROA-NEXT:    store i8 [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_8_4_EXTRACT_TRUNC]], ptr [[DOTSROA_5]], align 4
; SROA-NEXT:    [[DIS_DATA_I_FCA_0_INSERT:%.*]] = insertvalue [[STRUCT_DISPATCHSYSTEMDATA]] poison, i32 [[SYSTEM_DATA_FCA_0_EXTRACT]], 0
; SROA-NEXT:    [[DOTSROA_5_0__SROA_5_4_2:%.*]] = load i8, ptr [[DOTSROA_5]], align 4
; SROA-NEXT:    [[DOTFCA_0_INSERT5:%.*]] = insertvalue [2 x i32] poison, i32 [[PAYLOAD_FCA_0_EXTRACT]], 0
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_INSERT_EXT19:%.*]] = zext i24 [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_EXTRACT_TRUNC]] to i32
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_INSERT_SHIFT20:%.*]] = shl i32 [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_INSERT_EXT19]], 8
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_INSERT_MASK21:%.*]] = and i32 undef, 255
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_INSERT_INSERT22:%.*]] = or i32 [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_INSERT_MASK21]], [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_INSERT_SHIFT20]]
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_8_4_INSERT_EXT15:%.*]] = zext i8 [[DOTSROA_5_0__SROA_5_4_2]] to i32
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_8_4_INSERT_MASK16:%.*]] = and i32 [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_INSERT_INSERT22]], -256
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_8_4_INSERT_INSERT17:%.*]] = or i32 [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_8_4_INSERT_MASK16]], [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_8_4_INSERT_EXT15]]
; SROA-NEXT:    [[DOTFCA_1_INSERT8:%.*]] = insertvalue [2 x i32] [[DOTFCA_0_INSERT5]], i32 [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_8_4_INSERT_INSERT17]], 1
; SROA-NEXT:    [[TMP1:%.*]] = call { [[STRUCT_DISPATCHSYSTEMDATA]], [8 x i32], [2 x i32] } (...) @lgc.cps.await__sl_s_struct.DispatchSystemDatasa8i32a2i32s(i32 2, i32 4, i32 5, [9 x i32] poison, [2 x i32] [[DOTFCA_1_INSERT8]]), !continuation.registercount [[META1]], !continuation.returnedRegistercount [[META1]]
; SROA-NEXT:    [[TMP2:%.*]] = extractvalue { [[STRUCT_DISPATCHSYSTEMDATA]], [8 x i32], [2 x i32] } [[TMP1]], 2
; SROA-NEXT:    [[DOTFCA_0_EXTRACT:%.*]] = extractvalue [2 x i32] [[TMP2]], 0
; SROA-NEXT:    [[DOTFCA_1_EXTRACT:%.*]] = extractvalue [2 x i32] [[TMP2]], 1
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_8_4_EXTRACT_TRUNC18:%.*]] = trunc i32 [[DOTFCA_1_EXTRACT]] to i8
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_EXTRACT_SHIFT23:%.*]] = lshr i32 [[DOTFCA_1_EXTRACT]], 8
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_EXTRACT_TRUNC24:%.*]] = trunc i32 [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_EXTRACT_SHIFT23]] to i24
; SROA-NEXT:    [[TMP4:%.*]] = freeze [[STRUCT_MYPARAMS:%.*]] poison
; SROA-NEXT:    [[DOTFCA_0_EXTRACT1:%.*]] = extractvalue [[STRUCT_MYPARAMS]] [[TMP4]], 0
; SROA-NEXT:    [[DOTFCA_1_EXTRACT1:%.*]] = extractvalue [[STRUCT_MYPARAMS]] [[TMP4]], 1
; SROA-NEXT:    store i1 [[DOTFCA_1_EXTRACT1]], ptr [[DOTSROA_5]], align 4
; SROA-NEXT:    store i8 [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_8_4_EXTRACT_TRUNC18]], ptr [[DOTSROA_5]], align 4
; SROA-NEXT:    [[TMP3:%.*]] = extractvalue { [[STRUCT_DISPATCHSYSTEMDATA]], [8 x i32], [2 x i32] } [[TMP1]], 0
; SROA-NEXT:    [[DOTFCA_0_EXTRACT27:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP3]], 0
; SROA-NEXT:    [[DOTSROA_5_0__SROA_5_4_:%.*]] = load i8, ptr [[DOTSROA_5]], align 4
; SROA-NEXT:    [[DOTFCA_0_INSERT38:%.*]] = insertvalue [[STRUCT_DISPATCHSYSTEMDATA]] poison, i32 [[DOTFCA_0_EXTRACT27]], 0
; SROA-NEXT:    [[DOTFCA_0_INSERT:%.*]] = insertvalue [2 x i32] poison, i32 [[DOTFCA_0_EXTRACT]], 0
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_INSERT_EXT:%.*]] = zext i24 [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_EXTRACT_TRUNC24]] to i32
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_INSERT_SHIFT:%.*]] = shl i32 [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_INSERT_EXT]], 8
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_INSERT_MASK:%.*]] = and i32 undef, 255
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_INSERT_INSERT:%.*]] = or i32 [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_INSERT_MASK]], [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_INSERT_SHIFT]]
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_8_4_INSERT_EXT:%.*]] = zext i8 [[DOTSROA_5_0__SROA_5_4_]] to i32
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_8_4_INSERT_MASK:%.*]] = and i32 [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_16_4_INSERT_INSERT]], -256
; SROA-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_8_4_INSERT_INSERT:%.*]] = or i32 [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_8_4_INSERT_MASK]], [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_8_4_INSERT_EXT]]
; SROA-NEXT:    [[DOTFCA_1_INSERT:%.*]] = insertvalue [2 x i32] [[DOTFCA_0_INSERT]], i32 [[PAYLOAD_SERIALIZATION_ALLOCA_SROA_8_4_INSERT_INSERT]], 1
; SROA-NEXT:    call void (...) @lgc.cps.jump(i32 [[RETURNADDR]], i32 6, i32 poison, i32 poison, i32 poison, [[STRUCT_DISPATCHSYSTEMDATA]] [[DOTFCA_0_INSERT38]], [8 x i32] poison, [2 x i32] [[DOTFCA_1_INSERT]]), !continuation.registercount [[META1]]
; SROA-NEXT:    unreachable
;
