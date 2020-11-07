---
title: 附录-OC源码-Block：clang 编译后的的 Block 解析  
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
lightbox: true
pageview: true
tags: 源码解析 OC基石
coding: UTF-8
--- 
  
* [main.m](/assets/images/源码解析/block/main.m)
* [main.cpp](/assets/images/源码解析/block/main.cpp)
  
```shell  
clang -rewrite-objc main.m -o main.cpp  
//或者  
xcrun -sdk iphonesimulator clang -rewrite-objc main.m  
```  

文件中一个继承与 NSObject 的类, MYObject 作为外部变量.  
定义两个 block : `blockWithoutVar` & `blockWithVar`  
编译后代码看.cpp 文件  
(runtime 中有相关怎么看的讲解, 这里不深入,直接进入正题 [[其他: Clang 编译后的数据结构分析]] )  
  
## Block 的基本结构  

先看第一个 block: 首先找到 main 函数, 忽略掉类型转换部分, 可以看到主体是:  
`__main_block_impl_0()` 函数, 两个入参 `__main_block_func_0` 和 `__main_block_desc_0_DATA`  

```objc  
int main(int argc, const char * argv[]) {  
	void (*blockWithoutVar)(void) =   
	(  
		(void (*)()) 		&__main_block_impl_0(  
								(void *)__main_block_func_0,   
								&__main_block_desc_0_DATA  
							 )  
	);  
}  
```  
  
### Block 是一个结构体  
然后找到文件中的 `__main_block_impl_0`, 会发现是个结构体的构造函数  
所以这里得出一个结论:  **<mark>block 实质是一个结构体</mark>**   
```objc  
struct __main_block_impl_0 {  
  struct __block_impl impl;  
  struct __main_block_desc_0* Desc;  
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {  
    impl.isa = &_NSConcreteStackBlock;  
    impl.Flags = flags;  
    impl.FuncPtr = fp;  
    Desc = desc;  
  }  
};  
```  
  
### 定义 block 时的函数体,被 block 结构体的指针引用  

第一个入参 `__main_block_func_0`: 发现入参是我们 block 定义时的函数体  
结合上面的 `__main_block_impl_0` 构造函数, 这个函数体最终会被 impl 中的 `impl.FuncPtr` 引用  
这里得出第二个结论:  **<mark>block 定义时的函数体, 会被其结构体中的函数指针引用</mark>**   

```objc  
static void __main_block_func_0(struct __main_block_impl_0 *__cself) { printf("aaa \n"); }  
```  
  
第二个入参 `__main_block_desc_0_DATA`: 一个描述信息的结构体  

```objc  
static struct __main_block_desc_0 {  
  size_t reserved;  
  size_t Block_size;  
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};  
```  
  
## Block 中的外部变量  

再来看第二个定义 block:  
这个 block 的不同之处在于, block 内部使用了外部变量:   
* 局部引用类型: `MyObject *myObj`, `MyObject *myObj2  `,   
* 局部基本数据类型: `__block int` (会发现不加 block 就编译不过)  
* 全局基本数据类型: `int globalInt`  

```objc  
void (*blockWithVar)(void) =   
(  
		(void (*)())		&__main_block_impl_1(  
								(void *)__main_block_func_1,   
								&__main_block_desc_1_DATA,   
								myObj,   
								myObj2,   
								(__Block_byref_mainInt_0 *)&mainInt,   
								570425344  
							 )  
);  
```  
  
> 小知识,C++构造函数后面的`:`是给类成员变量赋值的方法    
找到`main_block_impl_1`的定义: 会发现有两个地方不同  
1. 外部 **局部** 变量在 block 结构体内部有对应的字段  
2. 构造函数中将 block 中使用的外部变量赋值给了 block 的内部字段  

```objc  
struct __main_block_impl_1 {  
  struct __block_impl impl;  
  struct __main_block_desc_1* Desc;  
  MyObject *myObj;  
  MyObject *myObj2;  
  __Block_byref_mainInt_0 *mainInt; // by ref  
  __main_block_impl_1(void *fp, struct __main_block_desc_1 *desc, MyObject *_myObj, MyObject *_myObj2, __Block_byref_mainInt_0 *_mainInt, int flags=0) : myObj(_myObj), myObj2(_myObj2), mainInt(_mainInt->__forwarding) {  
    impl.isa = &_NSConcreteStackBlock;  
    impl.Flags = flags;  
    impl.FuncPtr = fp;  
    Desc = desc;  
  }  
};  
```  
  
再看这些外部变量怎么用的, 可以看到这个执行函数比之前的, 除了执行部分还多出了内部变量获取  
需要特别注意注释 **bound by ref** **bound by copy**, 可知这是通过 copy 和 ref 的方式拿到的外部值  
所以可以得出结论 **<mark>block 中使用的局部外部变量会 copy 后在函数体中使用</mark>** (执行时 copy, 构造时应该没 copy)  

```objc  
static void __main_block_func_1(struct __main_block_impl_1 *__cself) {  
  __Block_byref_mainInt_0 *mainInt = __cself->mainInt; // bound by ref  
  MyObject *myObj = __cself->myObj; // bound by copy  
  MyObject *myObj2 = __cself->myObj2; // bound by copy  
}  
```  

并且我们可以看到全局的 `int globalInt` 没在这里面出现: **<mark>全局变量 block 可以直接使用而无需 copy</mark>**  
  
## __Block 的作用  

最后再来看 局部的 `int mainInt`  
这个变量如果前面不加 `__block` 是用不了的. 下面看加了 `__block`发生了什么  
mainInt 在全局的声明变成了 `__Block_byref_mainInt_0 *mainInt`  

```objc  
struct __Block_byref_mainInt_0 {  
  void *__isa;  
__Block_byref_mainInt_0 *__forwarding;  
 int __flags;  
 int __size;  
 int mainInt;  
};  
```  
 **<mark>加了 Block 后基本数据类型被封装成了一个引用类型</mark>**   
其值被藏在 mainInt->__forwarding->mainInt 中  
  
## 编译后多出来的函数  
另一个可以看到的是一旦 block 中使用了外部变量, 他的描述结构体会多出两个函数定义  

```objc  
static struct __main_block_desc_1 {  
  size_t reserved;  
  size_t Block_size;  
  void (*copy)(struct __main_block_impl_1*, struct __main_block_impl_1*);  
  void (*dispose)(struct __main_block_impl_1*);  
} __main_block_desc_1_DATA = { 0, sizeof(struct __main_block_impl_1), __main_block_copy_1, __main_block_dispose_1};  
```  
  
这两个函数指针对应的函数体:  
* 望名知意, 一个用于复制变量, 一个用于销毁变量  

```objc  
static void __main_block_copy_1(struct __main_block_impl_1*dst, struct __main_block_impl_1*src) {  
	_Block_object_assign((void*)&dst->myObj, (void*)src->myObj, 3/*BLOCK_FIELD_IS_OBJECT*/);  
	_Block_object_assign((void*)&dst->myObj2, (void*)src->myObj2, 3/*BLOCK_FIELD_IS_OBJECT*/);  
	_Block_object_assign((void*)&dst->mainInt, (void*)src->mainInt, 8/*BLOCK_FIELD_IS_BYREF*/);  
}  
  
static void __main_block_dispose_1(struct __main_block_impl_1*src) {  
	_Block_object_dispose((void*)src->myObj, 3/*BLOCK_FIELD_IS_OBJECT*/);  
	_Block_object_dispose((void*)src->myObj2, 3/*BLOCK_FIELD_IS_OBJECT*/);  
	_Block_object_dispose((void*)src->mainInt, 8/*BLOCK_FIELD_IS_BYREF*/);  
}  
```  
  
具体两个函数什么作用, 我放在 [[其他: block 的源码解析]] 看源码时一块看  
最终结论总结在 [[正文: Block 是什么]]  
