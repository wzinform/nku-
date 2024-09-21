; 定义全局变量n和a, 其中n为常数10，a为变量4  
@n = constant i32 10, align 4  
@a = global i32 4, align 4  
  
; 函数 int func (int e, int *f)  
define dso_local i32 @func(i32 noundef %0, i32* noundef %1) #0 {  
entry:  
    %2 = alloca i32, align 4       ; 分配e的副本  
    %3 = alloca i32*, align 8      ; 分配f的副本（实际上是f的指针）  
    %4 = alloca i32, align 4       ; 用于累加结果的变量  
  
    store i32 %0, i32* %2, align 4 ; 存储e的副本  
    store i32* %1, i32** %3, align 8 ; 存储f的指针  
    store i32 0, i32* %4, align 4   ; 初始化累加器为0  
  
    br label %while_start  
  
while_start:  
    %5 = load i32, i32* %2, align 4  ; 加载e的值  
    %6 = icmp ne i32 %5, 0           ; 比较e是否不为0  
    br i1 %6, label %while_body, label %return  
  
while_body:  
    %7 = load i32, i32* %4, align 4  ; 加载当前累加器的值  
    %8 = load i32, i32* %2, align 4  ; 重新加载e的值（因为e在循环中可能会改变）  
    %9 = load i32*, i32** %3, align 8 ; 加载f的指针  
    %10 = getelementptr inbounds i32, i32* %9, i64 0 ; 获取f[0]的地址  
    %11 = load i32, i32* %10, align 4 ; 加载f[0]的值  
    %12 = mul nsw i32 %8, %11        ; e * f[0]  
    %13 = add nsw i32 %7, %12        ; 累加到当前结果  
  
    ; 重复上述过程，但这次使用f[1]  
    %14 = getelementptr inbounds i32, i32* %9, i64 1  
    %15 = load i32, i32* %14, align 4  
    %16 = mul nsw i32 %8, %15  
    %17 = add nsw i32 %13, %16  
  
    store i32 %17, i32* %4, align 4  ; 更新累加器的值  
    %18 = sub nsw i32 %8, 1          ; e--  
    store i32 %18, i32* %2, align 4  ; 更新e的值  
    br label %while_start  
  
return:  
    %19 = load i32, i32* %4, align 4  
    %20 = srem i32 %19, 10           ; 取余数  
    ret i32 %20  
}  
  
; main函数  
define dso_local i32 @main() #0 {  
entry:  
    %0 = alloca i32, align 4      ; 用于存储c  
    %1 = alloca float, align 4    ; 用于存储输入的浮点数b  
    %2 = alloca [2 x i32], align 4 ; 数组array  
  
    ; 初始化array  
    %3 = getelementptr [2 x i32], [2 x i32]* %2, i64 0, i64 0  
    store i32 0, i32* %3, align 4  
    %4 = getelementptr [2 x i32], [2 x i32]* %2, i64 0, i64 1  
    store i32 1, i32* %4, align 4  
  
    ; 输入b  
    %5 = call float @getfloat()  
    store float %5, float* %1, align 4  
  
    ; 计算c  
    %6 = load i32, i32* @a, align 4  
    %7 = load float, float* %1, align 4  
    %8 = fptosi float %7 to i32  
    %9 = add nsw i32 %6, %8  
    store i32 %9, i32* %0, align 4  
  
    ; if条件判断  
    %10 = load i32, i32* %0, align 4  
    %11 = icmp slt i32 %10, 10      ; 注意这里是小于(slt)，不是小于等于(sle)  
    br i1 %11, label %if_true, label %if_false  
  
if_true:  
    %12 = load i32, i32* %0, align 4  
    %13 = sdiv i32 %12, 10  
    store i32 %13, i32* %0, align 4  
    %14 = load i32, i32* %0, align 4  
    call void @putint(i32 %14)  
    br label %exit  
  
if_false:  
    %15 = load i32, i32* %0, align 4  
    %16 = getelementptr inbounds [2 x i32], [2 x i32]* %2, i64 0, i64 0  
    %17 = call i32 @func(i32 %15, i32* %16)  
    store i32 %17, i32* %0, align 4  
    %18 = load i32, i32* %0, align 4  
    call void @putint(i32 %18)  
    br label %exit  
  
exit:  
    ret i32 0  
}  
  
; 外部函数声明  
declare float @getfloat()  
declare void @putint(i32) 
