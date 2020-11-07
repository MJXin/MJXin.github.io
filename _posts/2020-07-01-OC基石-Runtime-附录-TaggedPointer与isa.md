---
title: 附录-OC源码-Runtime：Tagged pointer 与 isa     
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
picture_frame: shadow
tags: 源码解析 OC基石
coding: UTF-8
--- 

<mark>Tagged pointer 与普通的指针不同在于其不再是指针, 而是用一部分空间(bit)存需要的数据, 另一部分存放了一些描述指针的信息</mark>  
  
类比于 解析网络协议, 蓝牙协议, usb 协议等等的一堆 16 进制的协议比如下面这种:  
`0xFF, 0x5A, 0x00, 0x08, 0x33, 0x00, 0x01, 0x21`  
这里共 8 个字节, 通常每个字节都有自己的含义, 比如 0~1 是包头, 2~3 是 checksum, 4~ 是 payload  
  
Tagged pointer 和这个类似, 一个指针假设长度 8 个字节 64 位  
以前是 64 位都用来存指针地址, 现在给变成给这 64 位 各自分配不同的含义  
以 isa 举例:  
* 中间固定一段(x86 是 44, arm64是 33(4~38))是存储的地址  
* 剩余的 bit 描述 `weakly_referenced`,`deallocating`,`extra_rc`这些弱引用,引用计数等信息  
  
## 为什么会有 Tagged Pointer  
**存储空间**上:  
* 32 位系统下的常用基本类型, NSInteger 4 个字节, 指针 4 个字节.  
* 64 位系统下的常用基本类型, NSInteger 8 个字节, 指针 8 个字节.  
运算上是一样的, 但是对于内存占用来说, 直接翻倍.  
  
**运算效率上**: 另一方面, 我们创建一个对象, 其还有引用计数等信息需要存储, 而为了存储这些信息,需要额外开辟内存空间.  
这增加了额外的运算逻辑, 而如果我们不另外开辟空间,就可以省去这些计算.  
  
所以苹果提出了: `Tagged Pointer`, 并广泛应用与 OC 中(比如 isa, 比如 NSNumber)  
大部分的变量, 本身用不到 64 位的空间, 所以很多时候, 存储对象的指针本身,会被拆成两个部分  
* 一部分存储**数据本身**  
* 另一部分存储**数据的一些标记**  
  
> 另外, 在新版本中, 以前直接存放值的`Tagged Pointer`的比如`NSNumber`不再能直接读出来    
> 这是因为新版的 Tagged Pointer 被做了混淆    
  
## Tagged Pointer 一些特性  
* 因为不是指针, 不再存放于堆中, 而是与基本数据类型存放一致  
* 可用于直接存放小于 64 位的数据(`NSNumber`, `NSDate`等)  
* 内存读取效率及创建效率都更高  
* 数据由 `信息` + `信息修饰` 组成  
  
## isa 是怎么存储的  
  
### 源码部分  
  
直接看源码:  
<a href='/assets/images/源码解析/runtime/objc-private.h'>objc-private.h</a>  
(结合 [其他: 探究源码中的宏](bear://x-callback-url/open-note?id=B224D47F-9AAE-4AD2-ACC9-4F5A78CFA357-6742-00018F0BA4161A9C) 找到对应的宏)  
```objc  
// 限 64 位, 32 位中是 int  
typedef unsigned long           uintptr_t;  
  
union isa_t {  
    isa_t() { }  
    isa_t(uintptr_t value) : bits(value) { }  
  
    Class cls;  
    uintptr_t bits;  
#if defined(ISA_BITFIELD)  
    struct {  
        ISA_BITFIELD;  // defined in isa.h  
    };  
#endif  
};  
```  
	* `union`: 关键字直接理解就是, isa_t 的值为下面的其中之一(这是块**独立**的内存, 只能是`{}`类含义之一)  
		* 要么是 Class(`struct objc_class *`)指针  
		* 要么是 uintptr_t (`unsigned long`)  
	* ` struct { ISA_BITFIELD}`: 不实际产生作用, 可理解为对 `bits`的注释  
  
下面来看`ISA_BITFIELD` 是如何定义的:  
<a href='/assets/images/源码解析/runtime/isa.h'>isa.h</a>  
```c  
# if __arm64__  
#   define ISA_MASK        0x0000000ffffffff8ULL  
#   define ISA_MAGIC_MASK  0x000003f000000001ULL  
#   define ISA_MAGIC_VALUE 0x000001a000000001ULL  
#   define ISA_BITFIELD                                                      \  
      uintptr_t nonpointer        : 1;                                       \  
      uintptr_t has_assoc         : 1;                                       \  
      uintptr_t has_cxx_dtor      : 1;                                       \  
      uintptr_t shiftcls          : 33; /*MACH_VM_MAX_ADDRESS 0x1000000000*/ \  
      uintptr_t magic             : 6;                                       \  
      uintptr_t weakly_referenced : 1;                                       \  
      uintptr_t deallocating      : 1;                                       \  
      uintptr_t has_sidetable_rc  : 1;                                       \  
      uintptr_t extra_rc          : 19  
  
```  
可以看得出来, 这里指定了每一位的含义, 大部分的长度只有 1bit  
各字段含义:  
* `nonpointer`: 0 代表普通指针，存储着class、meta-class对象的内存地址；1，代表优化过，使用位域存储更多信息  
* `has_assoc`: 是否设置过关联对象，如果没有，**施放时会速度更快**  
* `has_cxx_dtor`: 是否有C++的稀构函数，如果没有，**施放时会更快**  
* `shiftcls`: 这个部分存储的是**真正的**Class/Meta-Class对象的**内存地址**，通过 isa & ISA_MASK 能取出这里33位的值，得到对象的真正地址。  
* `magic`: 用于在调试的时候分辨对象是否完成了初始化 weekly_referenced—— 是否被弱饮用指针指向过，如果没有，**释放时会更快**  
* `extra_rc`: 里面存储的值是 引用计数 - 1  
* `deallocating`: 对象是否正在被释放  
* `has_sidtable_rc`: 引用计数器是否过大无法存储在isa中，若果是，这里就为1，引用计数就会被存储在一个叫SideTable的类的属性中  
  
### 结论部分  
所以 isa 是一个用一部分 bit 存储了指向的内存地址, 另一部分, 存了很多当前”对象”、”类”、”元类”描述信息的东西  
**如果要取出 isa 中存放的地址, 可以直接使用 isa & ISA_MASK 操作**  
  
  
最后, 对 isa 存储的实际探究和实现, 我写在这 [其他:探究 isa 的指向](bear://x-callback-url/open-note?id=623141C8-F03C-499F-A56E-961B5076B01A-477-00006B5900239E7D)  
  
> 参考文章:    
> [深入理解Tagged Pointer-InfoQ](https://www.infoq.cn/article/deep-understanding-of-tagged-pointer/)    
> [iOS 底层 -  isa 的前世今生](https://juejin.im/post/6844904069111218190)    
  
  
#猿人/猿艺/iOS/基石/runtime/正文