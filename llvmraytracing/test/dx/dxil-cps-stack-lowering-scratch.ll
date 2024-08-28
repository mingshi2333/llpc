; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --include-generated-funcs --version 3
; RUN: opt --verify-each -passes='dxil-cont-post-process,lint,continuations-lint,remove-types-metadata' -S %s --lint-abort-on-error | FileCheck -check-prefix=CPS-STACK-LOWERING-CPS %s

target datalayout = "e-m:e-p:64:32-p20:32:32-p21:32:32-p32:32:32-i1:32-i8:8-i16:16-i32:32-i64:32-f16:16-f32:32-f64:32-v8:8-v16:16-v32:32-v48:32-v64:32-v80:32-v96:32-v112:32-v128:32-v144:32-v160:32-v176:32-v192:32-v208:32-v224:32-v240:32-v256:32-n8:16:32"

%dx.types.Handle = type { ptr }
%struct.DispatchSystemData = type { i32 }
%struct.TraversalData = type { %struct.SystemData }
%struct.SystemData = type { %struct.DispatchSystemData }
%struct.BuiltInTriangleIntersectionAttributes = type { <2 x float> }
%called.Frame = type { i32 }
%struct.type = type { <2 x float> }

@"\01?RenderTarget@@3V?$RWTexture2D@V?$vector@M$03@@@@A" = external constant %dx.types.Handle, align 4

declare i32 @_cont_GetContinuationStackAddr()

declare %struct.DispatchSystemData @_AmdAwaitTraversal(i64, %struct.TraversalData)

declare %struct.DispatchSystemData @_AmdAwaitShader(i64, %struct.DispatchSystemData)

declare %struct.BuiltInTriangleIntersectionAttributes @_cont_GetTriangleHitAttributes(ptr)

declare void @_AmdRestoreSystemData(ptr)

define i32 @_cont_GetLocalRootIndex(ptr %data) {
  ret i32 5
}

declare i64 @_cont_GetContinuationStackGlobalMemBase()

define void @called(%struct.type %cont.state, i32 %return.addr, i32 %shader.index, %struct.DispatchSystemData %0, {} %padding, [1 x i32] %payload) !lgc.rt.shaderstage !15 !lgc.cps !16 !continuation !17 {
AllocaSpillBB:
  %1 = call ptr addrspace(32) @lgc.cps.alloc(i32 8)
  %payload.serialization.alloca = alloca [1 x i32], align 4
  %return.addr.spill.addr = getelementptr inbounds %called.Frame, ptr addrspace(32) %1, i32 0, i32 0
  store i32 %return.addr, ptr addrspace(32) %return.addr.spill.addr, align 4
  store [1 x i32] %payload, ptr %payload.serialization.alloca, align 4
  %2 = call %struct.DispatchSystemData @continuations.getSystemData.s_struct.DispatchSystemDatas()
  %.fca.0.extract = extractvalue %struct.DispatchSystemData %2, 0
  call void @amd.dx.setLocalRootIndex(i32 5)
  %ptr = getelementptr i8, ptr addrspace(32) %1, i32 9
  store i32 99, ptr addrspace(32) %ptr
  %dis_data.i.fca.0.insert = insertvalue %struct.DispatchSystemData poison, i32 %.fca.0.extract, 0
  %gep.payload = getelementptr i32, ptr %payload.serialization.alloca, i32 0
  store i32 undef, ptr %gep.payload, align 4
  %3 = call i64 (...) @lgc.cps.as.continuation.reference__i64(ptr @called.resume.0)
  %payload.reload = load [1 x i32], ptr %payload.serialization.alloca, align 4
  call void (...) @lgc.cps.jump(i32 2, i32 2, %struct.type %cont.state, i64 %3, %struct.DispatchSystemData %dis_data.i.fca.0.insert, {} poison, [1 x i32] %payload.reload), !continuation.registercount !16
  unreachable
}

define void @called.resume.0({} %cont.state, i32 %returnAddr, %struct.type %0, { %struct.DispatchSystemData, {}, [1 x i32] } %1) !lgc.rt.shaderstage !15 !lgc.cps !16 !continuation !17 {
entryresume.0:
  %2 = call ptr addrspace(32) @lgc.cps.peek(i32 8)
  %payload.serialization.alloca = alloca [1 x i32], align 4
  %payload = extractvalue  { %struct.DispatchSystemData, {}, [1 x i32] } %1, 2
  store [1 x i32] %payload, ptr %payload.serialization.alloca, align 4
  %payload.gep = getelementptr i32, ptr %payload.serialization.alloca, i32 0
  %3 = load i32, ptr %payload.gep, align 4
  %4 = extractvalue %struct.type %0, 0
  %system.data = extractvalue { %struct.DispatchSystemData, {}, [1 x i32]} %1, 0
  %.fca.0.extract3 = extractvalue %struct.DispatchSystemData %system.data, 0
  call void @amd.dx.setLocalRootIndex(i32 5)
  %return.addr.reload.addr = getelementptr inbounds %called.Frame, ptr addrspace(32) %2, i32 0, i32 0
  %return.addr.reload = load i32, ptr addrspace(32) %return.addr.reload.addr, align 4
  store i32 %3, ptr %payload.gep, align 4
  %.fca.0.insert = insertvalue %struct.DispatchSystemData poison, i32 %.fca.0.extract3, 0
  call void @lgc.cps.free(i32 8)
  %payload.reload = load [1 x i32], ptr %payload.serialization.alloca, align 4
  call void (...) @lgc.cps.jump(i32 %return.addr.reload, i32 2, %struct.type %0, i64 poison, %struct.DispatchSystemData %.fca.0.insert, {} poison, [1 x i32] %payload.reload), !continuation.registercount !16
  unreachable
}

; Function Attrs: nofree nounwind willreturn
declare void @amd.dx.setLocalRootIndex(i32) #0

; Function Attrs: nounwind willreturn
declare %struct.DispatchSystemData @continuations.getSystemData.s_struct.DispatchSystemDatas() #2

; Function Attrs: noreturn
declare void @lgc.cps.jump(...) #3

; Function Attrs: nounwind willreturn
declare %struct.DispatchSystemData @lgc.cps.await.s_struct.DispatchSystemDatas(...) #2

declare !continuation !17 { ptr, ptr } @continuation.prototype.called(ptr, i1)

declare ptr @continuation.malloc(i32)

declare void @continuation.free(ptr)

; Function Attrs: nounwind
declare token @llvm.coro.id.retcon(i32, i32, ptr, ptr, ptr, ptr) #4

; Function Attrs: nounwind
declare ptr @llvm.coro.begin(token, ptr writeonly) #4

; Function Attrs: nounwind
declare i1 @llvm.coro.suspend.retcon.i1(...) #4

; Function Attrs: nounwind willreturn
declare %struct.DispatchSystemData @continuations.getReturnValue.s_struct.DispatchSystemDatas() #2

; Function Attrs: noreturn
declare void @continuation.return(...) #3

; Function Attrs: nounwind willreturn memory(inaccessiblemem: readwrite)
declare ptr addrspace(32) @lgc.cps.alloc(i32) #5

; Function Attrs: nounwind willreturn
declare i64 @lgc.cps.as.continuation.reference__i64(...) #2

; Function Attrs: nounwind willreturn memory(inaccessiblemem: read)
declare ptr addrspace(32) @lgc.cps.peek(i32) #6

; Function Attrs: nounwind willreturn memory(inaccessiblemem: readwrite)
declare void @lgc.cps.free(i32) #5

attributes #0 = { nofree nounwind willreturn }
attributes #1 = { nofree norecurse nosync nounwind willreturn memory(argmem: write) }
attributes #2 = { nounwind willreturn }
attributes #3 = { noreturn }
attributes #4 = { nounwind }
attributes #5 = { nounwind willreturn memory(inaccessiblemem: readwrite) }
attributes #6 = { nounwind willreturn memory(inaccessiblemem: read) }

!llvm.ident = !{!0}
!dx.version = !{!1}
!dx.valver = !{!1}
!dx.shaderModel = !{!2}
!dx.entryPoints = !{!3, !6}
!lgc.cps.module = !{}
!continuation.maxPayloadRegisterCount = !{!13}
!continuation.stackAddrspace = !{!14}

!0 = !{!"clang version 3.7.0 (tags/RELEASE_370/final)"}
!1 = !{i32 1, i32 6}
!2 = !{!"lib", i32 6, i32 6}
!3 = !{null, !"", null, !4, !12}
!4 = !{!5, !9, null, null}
!5 = !{!6}
!6 = !{ptr @called, !"called", null, null, !7}
!7 = !{i32 8, i32 12, i32 6, i32 16, i32 7, i32 8, i32 5, !8}
!8 = !{i32 0}
!9 = !{!10}
!10 = !{i32 0, ptr @"\01?RenderTarget@@3V?$RWTexture2D@V?$vector@M$03@@@@A", !"RenderTarget", i32 0, i32 0, i32 1, i32 2, i1 false, i1 false, i1 false, !11}
!11 = !{i32 0, i32 9}
!12 = !{i32 0, i64 65536}
!13 = !{i32 30}
!14 = !{i32 21}
!15 = !{i32 5}
!16 = !{i32 1}
!17 = !{ptr @called}
; CPS-STACK-LOWERING-CPS-LABEL: define i32 @_cont_GetLocalRootIndex(
; CPS-STACK-LOWERING-CPS-SAME: ptr [[DATA:%.*]]) {
; CPS-STACK-LOWERING-CPS-NEXT:    ret i32 5
;
;
; CPS-STACK-LOWERING-CPS-LABEL: define void @called(
; CPS-STACK-LOWERING-CPS-SAME: [[STRUCT_TYPE:%.*]] [[CONT_STATE:%.*]], i32 [[CSPINIT:%.*]], i32 [[RETURN_ADDR:%.*]], i32 [[SHADER_INDEX:%.*]], [[STRUCT_DISPATCHSYSTEMDATA:%.*]] [[TMP0:%.*]], {} [[PADDING:%.*]], [1 x i32] [[PAYLOAD:%.*]]) !lgc.rt.shaderstage [[META15:![0-9]+]] !lgc.cps [[META16:![0-9]+]] !continuation [[META17:![0-9]+]] {
; CPS-STACK-LOWERING-CPS-NEXT:  AllocaSpillBB:
; CPS-STACK-LOWERING-CPS-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; CPS-STACK-LOWERING-CPS-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP1:%.*]] = load i32, ptr [[CSP]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP2:%.*]] = add i32 [[TMP1]], 8
; CPS-STACK-LOWERING-CPS-NEXT:    store i32 [[TMP2]], ptr [[CSP]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA:%.*]] = alloca [1 x i32], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP3:%.*]] = inttoptr i32 [[TMP1]] to ptr addrspace(21)
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP4:%.*]] = getelementptr i8, ptr addrspace(21) [[TMP3]], i32 0
; CPS-STACK-LOWERING-CPS-NEXT:    store i32 [[RETURN_ADDR]], ptr addrspace(21) [[TMP4]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    store [1 x i32] [[PAYLOAD]], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP5:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @[[CONTINUATIONS_GETSYSTEMDATA_S_STRUCT_DISPATCHSYSTEMDATAS:[a-zA-Z0-9_$\"\\.-]*[a-zA-Z_$\"\\.-][a-zA-Z0-9_$\"\\.-]*]]()
; CPS-STACK-LOWERING-CPS-NEXT:    [[DOTFCA_0_EXTRACT:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP5]], 0
; CPS-STACK-LOWERING-CPS-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP6:%.*]] = add i32 [[TMP1]], 9
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP7:%.*]] = inttoptr i32 [[TMP6]] to ptr addrspace(21)
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP8:%.*]] = getelementptr i8, ptr addrspace(21) [[TMP7]], i32 0
; CPS-STACK-LOWERING-CPS-NEXT:    store i32 99, ptr addrspace(21) [[TMP8]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    [[DIS_DATA_I_FCA_0_INSERT:%.*]] = insertvalue [[STRUCT_DISPATCHSYSTEMDATA]] poison, i32 [[DOTFCA_0_EXTRACT]], 0
; CPS-STACK-LOWERING-CPS-NEXT:    [[GEP_PAYLOAD:%.*]] = getelementptr i32, ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], i32 0
; CPS-STACK-LOWERING-CPS-NEXT:    store i32 undef, ptr [[GEP_PAYLOAD]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP10:%.*]] = call i64 @continuation.getAddrAndMD(ptr @called.resume.0)
; CPS-STACK-LOWERING-CPS-NEXT:    [[PAYLOAD_RELOAD:%.*]] = load [1 x i32], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP9:%.*]] = load i32, ptr [[CSP]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    call void (...) @lgc.ilcps.continue(i64 2, i32 [[TMP9]], i64 [[TMP10]], [[STRUCT_DISPATCHSYSTEMDATA]] [[DIS_DATA_I_FCA_0_INSERT]], {} poison, [1 x i32] [[PAYLOAD_RELOAD]])
; CPS-STACK-LOWERING-CPS-NEXT:    unreachable
;
;
; CPS-STACK-LOWERING-CPS-LABEL: define void @called.resume.0(
; CPS-STACK-LOWERING-CPS-SAME: {} [[CONT_STATE:%.*]], i32 [[CSPINIT:%.*]], i32 [[RETURNADDR:%.*]], [[STRUCT_TYPE:%.*]] [[TMP0:%.*]], { [[STRUCT_DISPATCHSYSTEMDATA:%.*]], {}, [1 x i32] } [[TMP1:%.*]]) !lgc.rt.shaderstage [[META15]] !lgc.cps [[META16]] !continuation [[META17]] {
; CPS-STACK-LOWERING-CPS-NEXT:  entryresume.0:
; CPS-STACK-LOWERING-CPS-NEXT:    [[CSP:%.*]] = alloca i32, align 4
; CPS-STACK-LOWERING-CPS-NEXT:    store i32 [[CSPINIT]], ptr [[CSP]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP2:%.*]] = load i32, ptr [[CSP]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP3:%.*]] = add i32 [[TMP2]], -8
; CPS-STACK-LOWERING-CPS-NEXT:    [[PAYLOAD_SERIALIZATION_ALLOCA:%.*]] = alloca [1 x i32], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    [[PAYLOAD:%.*]] = extractvalue { [[STRUCT_DISPATCHSYSTEMDATA]], {}, [1 x i32] } [[TMP1]], 2
; CPS-STACK-LOWERING-CPS-NEXT:    store [1 x i32] [[PAYLOAD]], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    [[PAYLOAD_GEP:%.*]] = getelementptr i32, ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], i32 0
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP4:%.*]] = load i32, ptr [[PAYLOAD_GEP]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP5:%.*]] = extractvalue [[STRUCT_TYPE]] [[TMP0]], 0
; CPS-STACK-LOWERING-CPS-NEXT:    [[SYSTEM_DATA:%.*]] = extractvalue { [[STRUCT_DISPATCHSYSTEMDATA]], {}, [1 x i32] } [[TMP1]], 0
; CPS-STACK-LOWERING-CPS-NEXT:    [[DOTFCA_0_EXTRACT3:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[SYSTEM_DATA]], 0
; CPS-STACK-LOWERING-CPS-NEXT:    call void @amd.dx.setLocalRootIndex(i32 5)
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP6:%.*]] = inttoptr i32 [[TMP3]] to ptr addrspace(21)
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP7:%.*]] = getelementptr i8, ptr addrspace(21) [[TMP6]], i32 0
; CPS-STACK-LOWERING-CPS-NEXT:    [[RETURN_ADDR_RELOAD:%.*]] = load i32, ptr addrspace(21) [[TMP7]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    store i32 [[TMP4]], ptr [[PAYLOAD_GEP]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    [[DOTFCA_0_INSERT:%.*]] = insertvalue [[STRUCT_DISPATCHSYSTEMDATA]] poison, i32 [[DOTFCA_0_EXTRACT3]], 0
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP8:%.*]] = load i32, ptr [[CSP]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP9:%.*]] = add i32 [[TMP8]], -8
; CPS-STACK-LOWERING-CPS-NEXT:    store i32 [[TMP9]], ptr [[CSP]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    [[PAYLOAD_RELOAD:%.*]] = load [1 x i32], ptr [[PAYLOAD_SERIALIZATION_ALLOCA]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP10:%.*]] = zext i32 [[RETURN_ADDR_RELOAD]] to i64
; CPS-STACK-LOWERING-CPS-NEXT:    [[TMP11:%.*]] = load i32, ptr [[CSP]], align 4
; CPS-STACK-LOWERING-CPS-NEXT:    call void (...) @lgc.ilcps.continue(i64 [[TMP10]], i32 [[TMP11]], i64 poison, [[STRUCT_DISPATCHSYSTEMDATA]] [[DOTFCA_0_INSERT]], {} poison, [1 x i32] [[PAYLOAD_RELOAD]])
; CPS-STACK-LOWERING-CPS-NEXT:    unreachable
;
