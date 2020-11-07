---
title: 附录-OC源码-Runtime：探究源码中的宏       
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
picture_frame: shadow
tags: 源码解析 OC基石
coding: UTF-8
---  
* <mark>__ARM_ARCH_7K__</mark> : **0** ( iPhone 64 真机推测值)  
参考文章,未证实的出处: [浅尝 objc_msgSend </mark> :iBlog](https://kingcos.me/posts/2019/objc_msgsend/)  
ARM 7k 架构 CPU 的代码中的标志宏  
```c  
// ARM.cpp  
// Unfortunately, __ARM_ARCH_7K__ is now more of an ABI descriptor. The CPU  
// happens to be Cortex-A7 though, so it should still get __ARM_ARCH_7A__.  
if (getTriple().isWatchABI())  
  Builder.defineMacro("__ARM_ARCH_7K__", "2");  
```  
影响:    
	* `objc-config.h` - `SUPPORT_INDEXED_ISA `  
  <br/>
* <mark>__arm64__</mark>  : **1** ( iPhone 64 真机运行值)  
参考文章, 未查源码出处  
ARM 64 架构宏  
影响:    
	* `objc-config.h` - `SUPPORT_INDEXED_ISA `  
  <br/>
* <mark>__LP64__</mark> : **1** ( iPhone 64 真机运行值)  
参考文章, 未查源码出处 [编译器中和64位编程有关的预定义宏_liangbch的专栏-CSDN博客](https://blog.csdn.net/liangbch/article/details/36020391)  
Linux 64 位宏,代表 long 和 pointer 为 64 位  
影响:    
	* `objc-config.h` - `SUPPORT_INDEXED_ISA `  
  <br/>
* <mark>SUPPORT_INDEXED_ISA</mark> : **0** ( iPhone 64 推测值)  
```c  
// objc-object.h  
#if __ARM_ARCH_7K__ >= 2  ||  (__arm64__ && !__LP64__)  
#   define SUPPORT_INDEXED_ISA 1  
#else  
#   define SUPPORT_INDEXED_ISA 0  
#endif  
```  
影响:   
	* `objc-object.h` -  `objc_object<mark>ISA()`   
  <br/>
* <mark>SUPPORT_PACKED_ISA</mark> : **1** ( iPhone 64 推测值)  
	* `TARGET_OS_WIN32`, `TARGET_OS_SIMULATOR ` 打印都是 0, 直面意思理解,不细究  
```c  
// objc-object.h  
#if (!__LP64__  ||  TARGET_OS_WIN32  ||  \  
     (TARGET_OS_SIMULATOR && !TARGET_OS_IOSMAC))  
#   define SUPPORT_PACKED_ISA 0  
#else  
#   define SUPPORT_PACKED_ISA 1  
#endif  
```  
 <br/> 
* <mark>SUPPORT_NONPOINTER_ISA</mark> : **1** ( iPhone 64 推测值)  
```c  
// objc-object.h  
#if !SUPPORT_INDEXED_ISA  &&  !SUPPORT_PACKED_ISA  
#   define SUPPORT_NONPOINTER_ISA 0  
#else  
#   define SUPPORT_NONPOINTER_ISA 1  
#endif  
```  
影响:  `struct objc_object`中诸多函数的真正实现  
