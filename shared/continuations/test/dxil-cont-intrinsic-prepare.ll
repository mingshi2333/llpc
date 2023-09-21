; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --include-generated-funcs
; RUN: opt --opaque-pointers=0 --enforce-pointer-metadata=1 --verify-each -passes='add-types-metadata,dxil-cont-intrinsic-prepare,lint,remove-types-metadata' -S %s 2>%t.stderr | FileCheck %s
; RUN: count 0 < %t.stderr

target datalayout = "e-m:e-p:64:32-p20:32:32-p21:32:32-i1:32-i8:8-i16:32-i32:32-i64:32-f16:32-f32:32-f64:32-v16:32-v32:32-v48:32-v64:32-v80:32-v96:32-v112:32-v128:32-v144:32-v160:32-v176:32-v192:32-v208:32-v224:32-v240:32-v256:32-n8:16:32"

%struct.DispatchSystemData = type { i32 }
%struct.SystemData = type { %struct.DispatchSystemData, float }
%struct.TraversalData = type { %struct.SystemData, i32, i64 }

; Function Attrs: nounwind readnone
define i32 @_cont_GetContinuationStackAddr() #0 {
  ret i32 1
}

; Function Attrs: nounwind
define void @_cont_SetupRayGen(%struct.DispatchSystemData* noalias nocapture sret(%struct.DispatchSystemData) %agg.result) #1 {
  %1 = getelementptr inbounds %struct.DispatchSystemData, %struct.DispatchSystemData* %agg.result, i32 0, i32 0
  store i32 2, i32* %1, align 4
  %l = load i32, i32* %1, align 4
  %c = icmp eq i32 %l, 3
  br i1 %c, label %complete, label %end

complete:
  call void @_AmdComplete() #2
  br label %end

end:
  ret void
}

; Function Attrs: nounwind
define void @_cont_TraceRay(%struct.DispatchSystemData* noalias nocapture sret(%struct.DispatchSystemData) %agg.result, %struct.DispatchSystemData* nocapture readonly %data, i64 %accelStruct, i32 %rayFlags, i32 %instanceInclusioMask, i32 %rayContributionToHitGroupIndex, i32 %multiplierForGeometryContributionToShaderIndex, i32 %missShaderIndex, float %originX, float %originY, float %originZ, float %tMin, float %dirX, float %dirY, float %dirZ, float %tMax) #1 {
  %1 = alloca %struct.TraversalData, align 4
  %2 = alloca %struct.DispatchSystemData, align 4
  %3 = getelementptr inbounds %struct.DispatchSystemData, %struct.DispatchSystemData* %data, i32 0, i32 0
  %4 = load i32, i32* %3, align 4
  %5 = bitcast %struct.TraversalData* %1 to i8*
  call void @llvm.lifetime.start(i64 12, i8* %5) #2
  %6 = getelementptr inbounds %struct.TraversalData, %struct.TraversalData* %1, i32 0, i32 0, i32 0, i32 0
  store i32 %4, i32* %6, align 4
  %addr = call i64 @_AmdGetResumePointAddr() #2
  %a = getelementptr inbounds %struct.TraversalData, %struct.TraversalData* %1, i32 0, i32 2
  store i64 %addr, i64* %a, align 4
  call void @"\01?_AmdAwait@@YA?AUDispatchSystemData@@UTraversalData@@@Z"(%struct.DispatchSystemData* nonnull sret(%struct.DispatchSystemData) %2, i64 3, %struct.TraversalData* nonnull %1) #2
  %7 = getelementptr inbounds %struct.DispatchSystemData, %struct.DispatchSystemData* %2, i32 0, i32 0
  %8 = load i32, i32* %7, align 4
  %9 = getelementptr inbounds %struct.DispatchSystemData, %struct.DispatchSystemData* %agg.result, i32 0, i32 0
  store i32 %8, i32* %9, align 4
  call void @llvm.lifetime.end(i64 12, i8* %5) #2
  ret void
}

; Function Attrs: nounwind
declare void @llvm.lifetime.start(i64, i8* nocapture) #2

declare void @"\01?_AmdAwait@@YA?AUDispatchSystemData@@UTraversalData@@@Z"(%struct.DispatchSystemData* sret(%struct.DispatchSystemData), i64, %struct.TraversalData*) #3
declare i64 @_AmdGetResumePointAddr() #2
declare void @_AmdComplete() #2

; Function Attrs: nounwind
declare void @llvm.lifetime.end(i64, i8* nocapture) #2

attributes #0 = { nounwind readnone "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="0" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="0" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }
attributes #3 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="0" "unsafe-fp-math"="false" "use-soft-float"="false" }
; CHECK-LABEL: define {{[^@]+}}@_cont_GetContinuationStackAddr
; CHECK-SAME: () #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:    ret i32 1
;
;
; CHECK-LABEL: define {{[^@]+}}@_cont_SetupRayGen
; CHECK-SAME: () #[[ATTR1:[0-9]+]] {
; CHECK-NEXT:    [[TMP1:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA:%.*]], align 8
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds [[STRUCT_DISPATCHSYSTEMDATA]], %struct.DispatchSystemData* [[TMP1]], i32 0, i32 0
; CHECK-NEXT:    store i32 2, i32* [[TMP2]], align 4
; CHECK-NEXT:    [[L:%.*]] = load i32, i32* [[TMP2]], align 4
; CHECK-NEXT:    [[C:%.*]] = icmp eq i32 [[L]], 3
; CHECK-NEXT:    br i1 [[C]], label [[COMPLETE:%.*]], label [[END:%.*]]
; CHECK:       complete:
; CHECK-NEXT:    call void @continuation.complete()
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[TMP3:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA]], %struct.DispatchSystemData* [[TMP1]], align 4
; CHECK-NEXT:    ret [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP3]]
;
;
; CHECK-LABEL: define {{[^@]+}}@_cont_TraceRay
; CHECK-SAME: (%struct.DispatchSystemData* nocapture readonly [[DATA:%.*]], i64 [[ACCELSTRUCT:%.*]], i32 [[RAYFLAGS:%.*]], i32 [[INSTANCEINCLUSIOMASK:%.*]], i32 [[RAYCONTRIBUTIONTOHITGROUPINDEX:%.*]], i32 [[MULTIPLIERFORGEOMETRYCONTRIBUTIONTOSHADERINDEX:%.*]], i32 [[MISSSHADERINDEX:%.*]], float [[ORIGINX:%.*]], float [[ORIGINY:%.*]], float [[ORIGINZ:%.*]], float [[TMIN:%.*]], float [[DIRX:%.*]], float [[DIRY:%.*]], float [[DIRZ:%.*]], float [[TMAX:%.*]]) #[[ATTR1]] {
; CHECK-NEXT:    [[TMP1:%.*]] = alloca [[STRUCT_TRAVERSALDATA:%.*]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA:%.*]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA]], align 8
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[STRUCT_DISPATCHSYSTEMDATA]], %struct.DispatchSystemData* [[DATA]], i32 0, i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = load i32, i32* [[TMP4]], align 4
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast %struct.TraversalData* [[TMP1]] to i8*
; CHECK-NEXT:    call void @llvm.lifetime.start.p0i8(i64 12, i8* [[TMP6]]) #[[ATTR6:[0-9]+]]
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr inbounds [[STRUCT_TRAVERSALDATA]], %struct.TraversalData* [[TMP1]], i32 0, i32 0, i32 0, i32 0
; CHECK-NEXT:    store i32 [[TMP5]], i32* [[TMP7]], align 4
; CHECK-NEXT:    [[TMP8:%.*]] = call i64 @_AmdGetResumePointAddr()
; CHECK-NEXT:    [[A:%.*]] = getelementptr inbounds [[STRUCT_TRAVERSALDATA]], %struct.TraversalData* [[TMP1]], i32 0, i32 2
; CHECK-NEXT:    store i64 [[TMP8]], i64* [[A]], align 4
; CHECK-NEXT:    [[TMP9:%.*]] = load [[STRUCT_TRAVERSALDATA]], %struct.TraversalData* [[TMP1]], align 4
; CHECK-NEXT:    [[TMP10:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @_AmdAwait(i64 3, [[STRUCT_TRAVERSALDATA]] [[TMP9]])
; CHECK-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP10]], %struct.DispatchSystemData* [[TMP2]], align 4
; CHECK-NEXT:    [[TMP11:%.*]] = getelementptr inbounds [[STRUCT_DISPATCHSYSTEMDATA]], %struct.DispatchSystemData* [[TMP2]], i32 0, i32 0
; CHECK-NEXT:    [[TMP12:%.*]] = load i32, i32* [[TMP11]], align 4
; CHECK-NEXT:    [[TMP13:%.*]] = getelementptr inbounds [[STRUCT_DISPATCHSYSTEMDATA]], %struct.DispatchSystemData* [[TMP3]], i32 0, i32 0
; CHECK-NEXT:    store i32 [[TMP12]], i32* [[TMP13]], align 4
; CHECK-NEXT:    call void @llvm.lifetime.end.p0i8(i64 12, i8* [[TMP6]]) #[[ATTR6]]
; CHECK-NEXT:    [[TMP14:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA]], %struct.DispatchSystemData* [[TMP3]], align 4
; CHECK-NEXT:    ret [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP14]]
;