; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes='lto<O3>'               -S < %s  | FileCheck %s

define void @hoist_fdiv(ptr %a, float %b) {
; CHECK-LABEL: @hoist_fdiv(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = fdiv fast float 1.000000e+00, [[B:%.*]]
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    [[I_0:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_INC:%.*]] ]
; CHECK-NEXT:    [[CMP_NOT:%.*]] = icmp eq i32 [[I_0]], 1024
; CHECK-NEXT:    br i1 [[CMP_NOT]], label [[FOR_END:%.*]], label [[FOR_INC]]
; CHECK:       for.inc:
; CHECK-NEXT:    [[IDXPROM:%.*]] = zext nneg i32 [[I_0]] to i64
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds nuw float, ptr [[A:%.*]], i64 [[IDXPROM]]
; CHECK-NEXT:    [[TMP1:%.*]] = load float, ptr [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = fmul fast float [[TMP1]], [[TMP0]]
; CHECK-NEXT:    store float [[TMP2]], ptr [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[INC]] = add nuw nsw i32 [[I_0]], 1
; CHECK-NEXT:    br label [[FOR_COND]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  br label %for.cond

for.cond:
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %cmp = icmp ne i32 %i.0, 1024
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:
  br label %for.end

for.body:
  %idxprom = sext i32 %i.0 to i64
  %arrayidx = getelementptr inbounds float, ptr %a, i64 %idxprom
  %0 = load float, ptr %arrayidx, align 4
  %div = fdiv fast float %0, %b
  store float %div, ptr %arrayidx, align 4
  br label %for.inc

for.inc:
  %inc = add nsw i32 %i.0, 1
  br label %for.cond

for.end:
  ret void
}
