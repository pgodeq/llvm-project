; RUN: opt -S -passes=instcombine < %s | FileCheck %s

; Test to select immediate dominator when multiple dominators exist.

%struct.vtbl = type { i32, i32 }
; *** IR Dump Before InstCombinePass on test3 ***
; Function Attrs: nounwind optsize
define dso_local i32 @test3(i32 noundef %m, ptr noundef %vt, i32 noundef %c, i32 noundef %mask) local_unnamed_addr #0 {
entry:
  %cmp = icmp ule i32 %m, 2
  %lnot = xor i1 %cmp, true
  %lnot.ext = zext i1 %lnot to i32
  br i1 %lnot, label %if.then, label %while.cond

if.then:                                          ; preds = %entry
  %call = call i32 @time(ptr noundef null) #2
  unreachable

while.cond:                                       ; preds = %entry, %if.end23
  %mask.addr.0 = phi i32 [ %mask, %entry ], [ %and, %if.end23 ]
  %tobool2 = icmp ne i32 %c, 0
  br i1 %tobool2, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %call4 = call i32 @time(ptr noundef null) #2
  %shl = shl nuw i32 1, %c
  %not = xor i32 %shl, -1
  %and = and i32 %mask.addr.0, %not
  %0 = load i32, ptr %vt, align 4
  %and8 = and i32 %0, %not
  %cmp9 = icmp uge i32 %m, 1
  br i1 %cmp9, label %if.end13, label %if.end13.thread

if.end13.thread:                                  ; preds = %while.body
  %b1445 = getelementptr inbounds %struct.vtbl, ptr %vt, i32 0, i32 1
  %1 = load i32, ptr %b1445, align 4
  %and1748 = and i32 %1, %not
  br label %if.end23

if.end13:                                         ; preds = %while.body
  %or = or i32 %and8, %shl
  %b14 = getelementptr inbounds %struct.vtbl, ptr %vt, i32 0, i32 1
  %2 = load i32, ptr %b14, align 4
  %and17 = and i32 %2, %not
; CHECK: %cmp18.not = icmp eq i32 %m, 1
  %cmp18 = icmp uge i32 %m, 2
  br i1 %cmp18, label %if.then20, label %if.end23

if.then20:                                        ; preds = %if.end13
  %or22 = or i32 %and17, %shl
  br label %if.end23

if.end23:                                         ; preds = %if.end13.thread, %if.then20, %if.end13
  %a.050 = phi i32 [ %or, %if.then20 ], [ %or, %if.end13 ], [ %and8, %if.end13.thread ]
  %b.0 = phi i32 [ %or22, %if.then20 ], [ %and17, %if.end13 ], [ %and1748, %if.end13.thread ]
  store i32 %a.050, ptr %vt, align 4
  %b25 = getelementptr inbounds %struct.vtbl, ptr %vt, i32 0, i32 1
  store i32 %b.0, ptr %b25, align 4
  br label %while.cond

while.end:                                        ; preds = %while.cond
  %3 = load i32, ptr %vt, align 4
  %b27 = getelementptr inbounds %struct.vtbl, ptr %vt, i32 0, i32 1
  %4 = load i32, ptr %b27, align 4
  %add = add i32 %3, %4
  ret i32 %add
}
; Function Attrs: optsize
declare dso_local i32 @time(ptr noundef) #3
