; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 3
;
; Traversal specialization tests. The Traversal functions in this module always pass through args,
; and the module contains metadata with argument slot infos.
; Value specialization has its own lit tests, so we focus here
; on everything that is implemented in SpecializeDriverShadersPass, particularly regarding the argument slot handling.
;
; RUN: opt --verify-each -passes='specialize-driver-shaders' -S %s | FileCheck %s
;
; Intentionally align i64 to 64 bits so we can test specializations within types with padding.
; i16 is aligned to 16 bits so we can test smaller-than-dword scalars.
; f32 is aligned to 16 bits to test misaligned dword-sized scalars.
target datalayout = "e-m:e-p:64:32-p20:32:32-p21:32:32-p32:32:32-i1:32-i8:8-i16:16-i32:32-i64:64-f16:16-f32:16-f64:32-v8:8-v16:16-v32:32-v48:32-v64:32-v80:32-v96:32-v112:32-v128:32-v144:32-v160:32-v176:32-v192:32-v208:32-v224:32-v240:32-v256:32-n8:16:32"

; Ignored prefix args: shaderAddr, levels, state, returnAddr, shaderRecIdx
declare void @lgc.cps.jump(...)

define void @SimpleArray(i32 %ret.addr, i32, [4 x i32] %args) !lgc.rt.shaderstage !{i32 6} {
; CHECK-LABEL: define void @SimpleArray(
; CHECK-SAME: i32 [[RET_ADDR:%.*]], i32 [[TMP0:%.*]], [4 x i32] [[ARGS:%.*]]) !lgc.rt.shaderstage [[META2:![0-9]+]] {
; CHECK-NEXT:    [[ARGS_SPECIALIZED:%.*]] = insertvalue [4 x i32] [[ARGS]], i32 42, 1
; CHECK-NEXT:    [[TMP3:%.*]] = freeze i32 poison
; CHECK-NEXT:    [[ARGS_SPECIALIZED1:%.*]] = insertvalue [4 x i32] [[ARGS_SPECIALIZED]], i32 [[TMP3]], 2
; CHECK-NEXT:    [[TMP4:%.*]] = freeze i32 poison
; CHECK-NEXT:    [[ARGS_SPECIALIZED2:%.*]] = insertvalue [4 x i32] [[ARGS_SPECIALIZED1]], i32 [[TMP4]], 3
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i32 poison, i32 poison, i32 poison, i32 poison, [4 x i32] [[ARGS_SPECIALIZED2]])
; CHECK-NEXT:    unreachable
;
  call void (...) @lgc.cps.jump(i32 poison, i32 poison, i32 poison, i32 poison, [4 x i32] %args)
  unreachable
}

define void @SimpleScalars(i32 %ret.addr, i32, i32 %arg0, i32 %arg1, i32 %arg2, i32 %arg3) !lgc.rt.shaderstage !{i32 6} {
; CHECK-LABEL: define void @SimpleScalars(
; CHECK-SAME: i32 [[RET_ADDR:%.*]], i32 [[TMP0:%.*]], i32 [[ARG0:%.*]], i32 [[ARG1:%.*]], i32 [[ARG2:%.*]], i32 [[ARG3:%.*]]) !lgc.rt.shaderstage [[META2]] {
; CHECK-NEXT:    [[TMP3:%.*]] = freeze i32 poison
; CHECK-NEXT:    [[TMP4:%.*]] = freeze i32 poison
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i32 poison, i32 poison, i32 poison, i32 poison, i32 [[ARG0]], i32 42, i32 [[TMP3]], i32 [[TMP4]])
; CHECK-NEXT:    unreachable
;
  call void (...) @lgc.cps.jump(i32 poison, i32 poison, i32 poison, i32 poison, i32 %arg0, i32 %arg1, i32 %arg2, i32 %arg3)
  unreachable
}

define void @I16s(i32 %ret.addr, i32, i16 %arg0, i16 %arg1, i16 %arg2, i16 %arg3) !lgc.rt.shaderstage !{i32 6} {
; CHECK-LABEL: define void @I16s(
; CHECK-SAME: i32 [[RET_ADDR:%.*]], i32 [[TMP0:%.*]], i16 [[ARG0:%.*]], i16 [[ARG1:%.*]], i16 [[ARG2:%.*]], i16 [[ARG3:%.*]]) !lgc.rt.shaderstage [[META2]] {
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i32 poison, i32 poison, i32 poison, i32 poison, i16 [[ARG0]], i16 [[ARG1]], i16 [[ARG2]], i16 [[ARG3]])
; CHECK-NEXT:    unreachable
;
  call void (...) @lgc.cps.jump(i32 poison, i32 poison, i32 poison, i32 poison, i16 %arg0, i16 %arg1, i16 %arg2, i16 %arg3)
  unreachable
}

; Test that even if specialization of i16 arguments is ignored, we still specialize i32s.
define void @MixedI16I32s(i32 %ret.addr, i32, i16 %arg0, i32 %arg1, i16 %arg2, i32 %arg3) !lgc.rt.shaderstage !{i32 6} {
; CHECK-LABEL: define void @MixedI16I32s(
; CHECK-SAME: i32 [[RET_ADDR:%.*]], i32 [[TMP0:%.*]], i16 [[ARG0:%.*]], i32 [[ARG1:%.*]], i16 [[ARG2:%.*]], i32 [[ARG3:%.*]]) !lgc.rt.shaderstage [[META2]] {
; CHECK-NEXT:    [[TMP3:%.*]] = freeze i32 poison
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i32 poison, i32 poison, i32 poison, i32 poison, i16 [[ARG0]], i32 42, i16 [[ARG2]], i32 [[TMP3]])
; CHECK-NEXT:    unreachable
;
  call void (...) @lgc.cps.jump(i32 poison, i32 poison, i32 poison, i32 poison, i16 %arg0, i32 %arg1, i16 %arg2, i32 %arg3)
  unreachable
}

; Test that specializing an arg slot that occupies a full misaligned dword in the argument isn't supported
; In this test, the first contained float scalar is specialized, because it is dword-aligned,
; but the second isn't, because it is not aligned. This is because i16 and float use 16-bit alignment in this test.
define void @MisalignedDwords(i32 %ret.addr, i32, { i32, float, i16, float, i32 } %args) !lgc.rt.shaderstage !{i32 6} {
; CHECK-LABEL: define void @MisalignedDwords(
; CHECK-SAME: i32 [[RET_ADDR:%.*]], i32 [[TMP0:%.*]], { i32, float, i16, float, i32 } [[ARGS:%.*]]) !lgc.rt.shaderstage [[META2]] {
; CHECK-NEXT:    [[ARGS_SPECIALIZED:%.*]] = insertvalue { i32, float, i16, float, i32 } [[ARGS]], float 0x36F5000000000000, 1
; CHECK-NEXT:    call void (...) @lgc.cps.jump(i32 poison, i32 poison, i32 poison, i32 poison, { i32, float, i16, float, i32 } [[ARGS_SPECIALIZED]])
; CHECK-NEXT:    unreachable
;
  call void (...) @lgc.cps.jump(i32 poison, i32 poison, i32 poison, i32 poison, { i32, float, i16, float, i32 } %args)
  unreachable
}

!lgc.cps.module = !{}
!lgc.rt.specialize.driver.shaders.state = !{!0}
; Disable analysis, so traversal variants that we can't handle don't affect other functions in this test.
!lgc.rt.specialize.driver.shaders.opts = !{!1}

; Numerical status values:
;
;    Status        | Value
;    =====================
;    Dynamic       |     0
;    Constant      |     1
;    UndefOrPoison |     2
;    Preserve      |     3
;

!0 = !{
; Status |        [Constant] | Arg slot idx
  i32 0,   i32           0, ;            0
  i32 1,   i32          42, ;            1
  i32 2,   i32           0, ;            2
  i32 3,   i32           0, ;            3
  i32 0,   i32           0  ;            4
}
!1 = !{i32 0, i32 1}