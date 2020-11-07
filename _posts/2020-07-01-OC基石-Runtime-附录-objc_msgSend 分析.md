---
title: 附录-OC源码-Runtime：源码中 objc_msgSend 分析       
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
picture_frame: shadow
tags: 源码解析 OC基石
coding: UTF-8
---  
> <a href='/assets/images/源码解析/runtime/objc-msg-arm.s'>objc-msg-arm.s</a>  
<a href='/assets/images/源码解析/runtime/objc-msg-arm64.s'>objc-msg-arm64.s</a>  
<a href='/assets/images/源码解析/runtime/objc-runtime-new.mm'>objc-runtime-new.mm</a>      
> [其他: Runtime 源码索引](bear://x-callback-url/open-note?id=B3550C45-8F01-4EC0-9821-2C07B25675BB-477-000128BDB612EEEA)    
  
源码中数据为汇编, 勉强阅读  
这里以网上其他文章做索引帮助理解  
> 参考文章:    
> [深入汇编探索objc_msgSend](https://www.codenong.com/js9d4cc1d91fbf/) (老源码, 易于理解, 只讲完消息查找, 无 **动态解析** 和 **消息转发** 流程)    
> [iOS 底层拾遗：objc_msgSend 与方法缓存](https://cloud.tencent.com/developer/article/1528514)(老源码, 源码说明不如上文清晰, 优势在 **缓存机制** 讲的比较清楚)    
> [深入浅出 Runtime（三）：消息机制](https://juejin.im/post/6844904072235974663) (老源码, 整体流程介绍的十分透彻)    
> [Objective-C 消息发送与转发机制原理 | yulingtianxia’s blog](http://yulingtianxia.com/blog/2016/06/15/Objective-C-Message-Sending-and-Forwarding/) (老源码, 需要有**汇编**和**反编译**基础)    
>     
> 里面涉及的其他基础概念在我之前的其他文章里:    
> tagged pointer:  [其他: Tagged pointer 与 isa](bear://x-callback-url/open-note?id=DD6BA620-7369-40F2-8076-EEFCFF947C69-477-00005195DB13B02E)    
> isa: [其他:探究 isa 的指向](bear://x-callback-url/open-note?id=623141C8-F03C-499F-A56E-961B5076B01A-477-00006B5900239E7D)    
  
## 总结  
objc_msgSend 整体分为三个流程:  
* 消息查找  
	* 汇编: 缓存中查找  
	* C++: 遍历函数表查找(排过序用**二分**, 未排序用**遍历**)  
	* C++: 遍历父类函数表查找  
* 消息动态解析  
	* C++: 非元类调用开发实现的 `resolveInstanceMethod`  
	* C++: 元类调用开发实现的 `resolveClassMethod` 再调用 `resolveInstanceMethod`  
	* C++: 重新执行消息查找(只在查找缓存)  
* 消息转发(不在 `runtime`, 在 `CoreFoundation` 中)  
	* OC: 调用 `forwardingTargetForSelector` 尝试找下一个 Target 接收 ,  (NSObject 默认`return nil`)  
	* OC: 上一步失败调用 `methodSignatureForSelector `,打包函数签名  
	* OC: 调用`forwardInvocation` 处理打包的签名(NSObject 打印`unrecognized selector`)  
  
整体流程图:  
![](/assets/images/源码解析/runtime/%E6%99%BA%E8%83%BD%E6%88%AA%E5%9B%BE-%E6%B0%B4%E5%8D%B0.jpg)  
  
- - - -  

##  objc_msgSend 源码主线流程  
  
* arm64 汇编代码会出现很多`p`字母，实际上是一个宏，64 位下是`x`，32 位下是`w`，`p`就是寄存器。  
* 阅读时, 直接点开源码, 对着源码阅读  
1. 入口  
```  
  ENTRY _objc_msgSend   
```  
2. 判断消息接收者是否为空: p0(第一个入参) , 是的话走 `LNilOrTagged` 或 `LReturnZero `, 不是的话继续往下  
```  
  cmp p0, #0      // nil check and tagged pointer check  
#if SUPPORT_TAGGED_POINTERS  
  b.le  LNilOrTagged    //  (MSB tagged pointer looks negative)  
#else  
  b.eq  LReturnZero  
#endif  
```  
3. 获取到 isa 指向的地址: 把 isa 放到寄存器 13 (前文提过, isa 是 `tagged pointer`, 存了指针, 但本身不等同于指针)  
```  
  ldr p13, [x0]   // p13 = isa  
```  
4. 使用 isa 获取 class 地址放到 16: [其他: 源码中 objc_msgSend 分析 - `GetClassFromIsa_p16`](bear://x-callback-url/open-note?id=D8CD1552-D1A3-4A06-945D-862AA56A34D7-477-000083B0800E83B0&header=%60GetClassFromIsa_p16%60)   
(isa 除了指针外还有别的数据, 前文提到过的 Tagged Pointer, 这里通过掩码方式直接取出 isa 存的指针)  
```  
 GetClassFromIsa_p16 p13   // p16 = class  
```  
5. 核心部分,调用 `CacheLookup `, 开始查找IMP  
```  
  CacheLookup NORMAL, _objc_msgSend  
```  
6. 后面的 `LNilOrTagged`, `LReturnZero ` 暂略, 弄完主线有时间再看, 可以理解为是处理 ISA 和空值情况  
  
> 🔴没弄懂的内容:    
> `LGetIsaDone:` 的意思是否是锚点?    
> 如果是锚点, 那代码最终会走到 `LReturnZero:` 后面, 即使是有效值, 因为没有从 `CacheLookup`跳到最后一局的, 如果不是锚点, 那这段只有跳过来才会执行? 那`CacheLookup` 就没机会调用了, 也是矛盾的    
> 🟢已经搞懂了: 是锚点, 汇编没有函数入栈出栈, 不像高级语言, 代码跳走了就真的是跳走, 不回来的, 所以不会执行到 `LReturnZero:`    
  
## `CacheLookup`: 缓存中找函数  
1. 先是几个之前寄存器的值, 0 = self, 1 = SEL, 16 = isa  
```  
	//   - x0 contains the receiver  
	//   - x1 contains the selector  
	//   - x16 contains the isa  
```  
  
2. **找到 objc_class.cache.buckets**  
回顾 `struct objc_class`的数据结构, 这里将 `objc_class.cache.buckets` 拿出来  
* 继承的`struct objc_object` 内部有一个 isa  8 字节  
* `Class` 为 `struct objc_class *`, 结构体指针 8 字节  
* 所以 `objc_class` 的第 16 个字节开始就是 `cache`,   
* cache 的开头是`_buckets`: 结构体指针 8 个字节, `mask` `_occupied ` 是 `uint32`: 4 个字节  
```objc++  
//objc-runtime-new.h  
struct objc_class : objc_object {  
    Class superclass;  
    cache_t cache;             // formerly cache pointer and vtable  
    class_data_bits_t bits;    //  
	   ...  
}  
typedef uint32_t mask_t;  
struct cache_t {  
#if CACHE_MASK_STORAGE == CACHE_MASK_STORAGE_OUTLINED  
		explicit_atomic<struct bucket_t *> _buckets;  
	  	mask_t _mask;  
    	mask_t _occupied;  
}  
```  
最上面定义了, `CACHE` 为两个 pointer 的大小, 就是 16  
```  
//objc-msg-arm64.s  
#define CACHE            (2 * __SIZEOF_POINTER__)  
```  
此处在拿到 **cache** 然后放到 p11 中, cache 的前 8 个字节是 buckets; 所以 p11 是 buckets  
```  
//objc-msg-arm64.s  
	// p1 = SEL, p16 = isa  
	ldr	p11, [x16, #CACHE]				// p11 = mask|buckets  
```  
3. **从buckets哈希表中, 找到了 IMP 的地址, 放到 p12中, 找到哈希表中的 KEY,放到 p9 中**  
这里通过一些系列计算, 中间过程即使结合了参考文章, 看着也很吃力. 这里暂时只有操作的结论     

```  
#if CACHE_MASK_STORAGE == CACHE_MASK_STORAGE_HIGH_16  
	and	p10, p11, #0x0000ffffffffffff	// p10 = buckets  
	and	p12, p1, p11, LSR #48		// x12 = _cmd & mask  
#elif CACHE_MASK_STORAGE == CACHE_MASK_STORAGE_LOW_4  
	and	p10, p11, #~0xf			// p10 = buckets  
	and	p11, p11, #0xf			// p11 = maskShift  
	mov	p12, #0xffff  
	lsr	p11, p12, p11				// p11 = mask = 0xffff >> p11  
	and	p12, p1, p11				// x12 = _cmd & mask  
#else  
#error Unsupported cache mask storage for ARM64.  
#endif  
	add	p12, p10, p12, LSL #(1+PTRSHIFT)  
		             // p12 = buckets + ((_cmd & mask) << (1+PTRSHIFT))  
	ldp	p17, p9, [x12]		// {imp, sel} = *bucket  
1:	cmp	p9, p1			// if (bucket->sel != _cmd)  
	b.ne	2f			//     scan more  
	CacheHit $0			// call or return imp  
	  
2:	// not hit: p12 = not-hit bucket  
	CheckMiss $0			// miss if bucket->sel == 0  
	cmp	p12, p10		// wrap if bucket == buckets  
	b.eq	3f  
	ldp	p17, p9, [x12, #-BUCKET_SIZE]!	// {imp, sel} = *--bucket  
	b	1b			// loop  
3:	// wrap: p12 = first bucket, w11 = mask  
#if CACHE_MASK_STORAGE == CACHE_MASK_STORAGE_HIGH_16  
	add	p12, p12, p11, LSR #(48 - (1+PTRSHIFT))  
					// p12 = buckets + (mask << 1+PTRSHIFT)  
#elif CACHE_MASK_STORAGE == CACHE_MASK_STORAGE_LOW_4  
	add	p12, p12, p11, LSL #(1+PTRSHIFT)  
					// p12 = buckets + (mask << 1+PTRSHIFT)  
#else  
#error Unsupported cache mask storage for ARM64.  
#endif  
	// Clone scanning loop to miss instead of hang when cache is corrupt.  
	// The slow path may detect any corruption and halt later.  
	ldp	p17, p9, [x12]		// {imp, sel} = *bucket  
```   
4.**对比 入参 SEL 与 HASH 的 SEL, 判断是 CacheHit 找到 IMP 并执行, 还是 CheckMiss 继续找或开始查函数表**  
使用 p9 中 hash 表中的 SEL 与之前 p1 的做对比:  
  1. `CacheHit`: 成功找到缓存, 根据开始时调用 `CacheLookup` 的入参, 一般是直接通过`TailCallCachedImp`直接调用 IMP  
  2. `CheckMiss`: 没找到, 就递归到下一个 bucket, 如果最终还是没找到, 就会调用 `JumpMiss`, 开始查类的函数表  
ps.`CheckMiss`是找不到的情况, 往前位移继续找重复 1 的过程, 后面不赘述. 直接看成功&失败  

```  
1:	cmp	p9, p1			// if (bucket->sel != _cmd)  
	b.ne	2f			//     scan more  
	CacheHit $0			// call or return imp  
	  
2:	// not hit: p12 = not-hit bucket  
	CheckMiss $0			// miss if bucket->sel == 0  
	cmp	p12, p10		// wrap if bucket == buckets  
	b.eq	3f  
	ldp	p17, p9, [x12, #-BUCKET_SIZE]!	// {imp, sel} = *--bucket  
	b	1b			// loop  
  
LLookupEnd$1:  
LLookupRecover$1:  
3:	// double wrap  
	JumpMiss $0  
  
.endmacro  
```  
  
5.**CacheHit: 执行找到的 IMP**  
根据开始`LookupCache` 开始时入参, 执行不同函数, 一般是 `TailCallCachedImp` 直接调用 IMP 的过程  
> `TailCallCachedImp` 在`arm64-asm.h` 是个很短的宏    

```  
.macro CacheHit  
.if $0 == NORMAL  
  TailCallCachedImp x17, x12, x1, x16 // authenticate and call imp  
.elseif $0 == GETIMP  
  //...  
  AuthAndResignAsIMP x0, x12, x1, x16 // authenticate imp and re-sign as IMP  
9:  ret       // return IMP  
.elseif $0 == LOOKUP  
	  //...  
  AuthAndResignAsIMP x17, x12, x1, x16  // authenticate imp and re-sign as IMP  
  ret       // return imp via x17  
.else  
.abort oops  
.endmacro  
  
```  
6.**JumpMiss: 缓存中找不到, 开始在函数表中查找**  
直接走 `__objc_msgSend_uncached`  
只关注 `NORMAL` 因为 objc_SendMsg 就是传 `NORMAL`  
```  
.macro JumpMiss  
.if $0 == GETIMP  
  b LGetImpMiss  
.elseif $0 == NORMAL  
  b __objc_msgSend_uncached  
.elseif $0 == LOOKUP  
  b __objc_msgLookup_uncached  
.else  
.abort oops  
.endif  
.endmacro  
```  
  
7.**函数表中找 IMP 并执行**  
	1. `MethodTableLookup`  
	2. `TailCallFunctionPointer`  
```  
  STATIC_ENTRY __objc_msgSend_uncached  
  UNWIND __objc_msgSend_uncached, FrameWithNoSaves  
  
  // THIS IS NOT A CALLABLE C FUNCTION  
  // Out-of-band p16 is the class to search  
    
  MethodTableLookup  
  TailCallFunctionPointer x17  
  
  END_ENTRY __objc_msgSend_uncached  
  
```  
  
## `MethodTableLookup`: 类的函数表中找函数  
核心是 `_lookUpImpOrForward `, 这是一个 C++ 中的函数  
其他的看描述,是在操作变量和存放 IMP?  
```  
.macro MethodTableLookup    
  // push frame  
	 ...  
  // save parameter registers: x0..x8, q0..q7  
  ...  
  // lookUpImpOrForward(obj, sel, cls, LOOKUP_INITIALIZE | LOOKUP_RESOLVER)  
  // receiver and selector already in x0 and x1  
	 ...  
  bl  _lookUpImpOrForward  
  // IMP in x0  
  ...  
  // restore registers and return  
  ...  
  AuthenticateLR  
  
.endmacro  
```  
  
## `_lookUpImpOrForward`: 真正开始的 IMP 查找  
<a href='/assets/images/源码解析/runtime/objc-runtime-new%202.mm'>objc-runtime-new 2.mm</a>  
  
* **入参与返回值**:  
* 返回值: IMP 证明这个函数最后结果是找到 IMP 并返回  
* 入参: `id inst`(class 的实例), `SEL sel`, `Class cls`, `int behavior`(可以理解为当前状态的枚举值)  
	(behavior 在旧版中是`bool initialize, bool cache, bool resolver` 三个参数, 现在合为了一个, 在实际判断时, 用&操作符, 取出某一部分做判断`int behavior`)  
  
* **一些判断状态的准备工作**:  
	1. 解开 Debug 锁: 源码中看不出干嘛的, 暂时根据名字推测是 debug 用的锁  
	( [其他: 源码中 objc_msgSend 分析 - `assertUnlocked`](bear://x-callback-url/open-note?id=D8CD1552-D1A3-4A06-945D-862AA56A34D7-477-000083B0800E83B0&header=%60assertUnlocked%60) )  
```objc  
runtimeLock.assertUnlocked();  
```  
	2. 判断是否需要使用缓存(从 `objc_sendMsg` 进来的已经判断过了)  
走缓存的实际上最后走到 CacheLookup: [其他: 源码中 objc_msgSend 分析 - `_cache_getImp `](bear://x-callback-url/open-note?id=D8CD1552-D1A3-4A06-945D-862AA56A34D7-477-000083B0800E83B0&header=%60_cache_getImp%20%60)  
```objc  
// Optimistic cache lookup  
if (fastpath(behavior & LOOKUP_CACHE)) {  
    imp = cache_getImp(cls, sel);  
    if (imp) goto done_nolock;  
}  
```  
	3. 检查并处理类结构体本身: 检查 cls 是否已实现, 检查 cls 是否已创建, 如果没有, 则做对应处理  
```objc  
// 源码中有解释, 目的是先上个锁避免 cls 在检查和处理过程中发生变化  
// 因为是运行时, cls 随时可能发生变化  
runtimeLock.lock();  
checkIsKnownClass(cls);  
if (slowpath(!cls->isRealized())) {  
        cls = realizeClassMaybeSwiftAndLeaveLocked(cls, runtimeLock);  
}  
if (slowpath((behavior & LOOKUP_INITIALIZE) && !cls->isInitialized())) {  
        cls = initializeAndLeaveLocked(cls, inst, runtimeLock);  
}  
```  
  
* **开始查询 IMP**:   
外层 for 循环, 内层:  
	1. 先在 cls 自己的函数表查,调用`getMethodNoSuper_nolock ` 查到的话直接结束  
	( [其他: 源码中 objc_msgSend 分析 - `getMethodNoSuper_nolock`:查找 cls 中的 Method](bear://x-callback-url/open-note?id=D8CD1552-D1A3-4A06-945D-862AA56A34D7-477-000083B0800E83B0&header=%60getMethodNoSuper_nolock%60:%E6%9F%A5%E6%89%BE%20cls%20%E4%B8%AD%E7%9A%84%20Method) )  
	2. 然后 `curClass = curClass->superclass` 指向父类, 并且不为空, 继续 3, 否则到 5  
	3. 调用 `cache_getImp` 在缓存里查, 查到了直接结束, 否则循环到 1  
	4. 父类都查空,或者别的啥意外, 则到 5  
	5. imp = forward_imp;(一个用于告知要走消息转发的标记)  
注意: 无论如何 imp 都会有值  
```objc  
 for (unsigned attempts = unreasonableClassCount();;) {  
			// 1: 查自己的 Method 列表  
        Method meth = getMethodNoSuper_nolock(curClass, sel);  
        if (meth) {  
            imp = meth->imp;  
            goto done;  
        }  
			// 2: 查自己查不到, 把自己变成父类: 如果没有父类, 直接结束 , 如果有,到 3  
        if (slowpath((curClass = curClass->superclass) == nil)) {  
            // No implementation found, and method resolver didn't help.  
            // Use forwarding.  
            imp = forward_imp;  
            break;  
        }  
  
        // Halt if there is a cycle in the superclass chain.  
        if (slowpath(--attempts == 0)) {  
            _objc_fatal("Memory corruption in class list.");  
        }  
			  
			// 3: 从cache 里拿(这是 cls 已经在 2 变成了前一刻的父类), cache 拿不到, 就下一个循环到 1  
        imp = cache_getImp(curClass, sel);  
			// 前面如果被设成了 forward_imp, 怎么已经所有办法都试过了, 还是查不到,直接结束  
        if (slowpath(imp == forward_imp)) {  
            // Found a forward:: entry in a superclass.  
            // Stop searching, but don't cache yet; call method  
            // resolver for this class first.  
            break;  
        }  
			// 如果查到有效的 imp, 那就结束  
        if (fastpath(imp)) {  
            // Found the method in a superclass. Cache it in this class.  
            goto done;  
        }  
    }  
```  
  
* **拿到有效 IMP 后, 填充缓存, 解锁**  
```objc  
 done:  
    log_and_fill_cache(cls, imp, sel, inst, curClass);  
    runtimeLock.unlock();  
return imp;  
```  
  
* **若没拿到有效的 IMP, 则走消息转发流程**  
上一步, 若是找到 IMP 会跳转到 done: 若是最后找不到, 则会出循环, 执行下面的语句  
因为我有个地方没搞懂, 汇编在调用 `lookupIMPorForward` 时给的 `behavior` 没看懂, 只能根据注释和其他文章说法判断  
[其他: 源码中 objc_msgSend 分析 - `resolveMethod_locked`: 消息转发流程](bear://x-callback-url/open-note?id=D8CD1552-D1A3-4A06-945D-862AA56A34D7-477-000083B0800E83B0&header=%60resolveMethod_locked%60:%20%E6%B6%88%E6%81%AF%E8%BD%AC%E5%8F%91%E6%B5%81%E7%A8%8B)  

```objc  
//objc-msg-arm64.s  
// lookUpImpOrForward(obj, sel, cls, LOOKUP_INITIALIZE | LOOKUP_RESOLVER)  
  
//objc-runtime-new.mm  
 // No implementation found. Try method resolver once.  
if (slowpath(behavior & LOOKUP_RESOLVER)) {  
    behavior ^= LOOKUP_RESOLVER;  
    return resolveMethod_locked(inst, sel, cls, behavior);  
}  
  
```  
  
## `getMethodNoSuper_nolock`:在 cls 中遍历 data 里的 Method_list  
这个没啥说的, 核心就是遍历:  
从 cls->data() 中循环拿 `method_list`(clas 中 data 存了很多个 method_list, 而 method_list 又是 method 的集合. 具体看数据结构那章)  
再调用 `search_method_list_inline` 从 `method_list` 中找 IMP  
```objc  
static method_t * getMethodNoSuper_nolock(Class cls, SEL sel) {  
    runtimeLock.assertLocked();  
    ASSERT(cls->isRealized());  
    auto const methods = cls->data()->methods();  
    for (auto mlists = methods.beginLists(), end = methods.endLists();  
         mlists != end; ++mlists) {  
        method_t *m = search_method_list_inline(*mlists, sel);  
        if (m) return m;  
    }  
    return nil;  
}  
  
```  
  
* `search_method_list_inline`: 在 Method_list 中找 IMP  
很明显,一个 if-else, 分两种情况, 排过序的调用`findMethodInSortedMethodList`, 没排过序的直接遍历  
```objc  
ALWAYS_INLINE static method_t *  
search_method_list_inline(const method_list_t *mlist, SEL sel)  
{  
    int methodListIsFixedUp = mlist->isFixedUp();  
    int methodListHasExpectedSize = mlist->entsize() == sizeof(method_t);  
    if (fastpath(methodListIsFixedUp && methodListHasExpectedSize)) {  
        return findMethodInSortedMethodList(sel, mlist);  
    } else {  
        // Linear search of unsorted method list  
        for (auto& meth : *mlist) {  
            if (meth.name == sel) return &meth;  
        }  
    }  
}  
```  
  
* `findMethodInSortedMethodList`: 使用**二分查找**在 Method_list 中找排过序的 IMP  
	1. `count = list->count` count 为链表长度  
	2. `count >> 1` 二进制的右移一位, 数据大小每次少一半  
	3. `probe = base +(count >> 1)`: probe 每次从整体中间开始(假设 count = 100, probe 从 50 开始, base 从 0 开始)  
	4. `if (keyValue == probeValue)`: if 内的语句是,如果找到了, 一直 while 到相等并且最小的那个, 然后返回  
	5. `if (keyValue > probeValue)`: 如果要找的值比左半边最大值`probe` 都大, 则 base 从 probe+1 开始,因为 base=count>>1 +1, 所以 count 总数要 - 1, base+count 才是不越界的坐标    
	(base = 51, count= 100-1=99, 99>>=1 = 49)  

```objc  
ALWAYS_INLINE static method_t *findMethodInSortedMethodList(SEL key, const method_list_t *list)  
{  
    ASSERT(list);  
  
    const method_t * const first = &list->first;  
    const method_t *base = first;  
    const method_t *probe;  
    uintptr_t keyValue = (uintptr_t)key;  
    uint32_t count;  
      
    for (count = list->count; count != 0; count >>= 1) {  
        probe = base + (count >> 1);  
          
        uintptr_t probeValue = (uintptr_t)probe->name;  
          
        if (keyValue == probeValue) {  
            // `probe` is a match.  
            // Rewind looking for the *first* occurrence of this value.  
            // This is required for correct category overrides.  
            while (probe > first && keyValue == (uintptr_t)probe[-1].name) {  
                probe--;  
            }  
            return (method_t *)probe;  
        }  
          
        if (keyValue > probeValue) {  
            base = probe + 1;  
            count--;  
        }  
    }  
      
    return nil;  
}  
```  
  
## `resolveMethod_locked`: 动态解析流程  
* 如果是元类 `! cls->isMetaClass()` 走 `resolveInstanceMethod`  
* 如果是类走 `resolveClassMethod`  
* 上面两个函数, 目的都是调用一个给开发自定义的函数, 把函数**添加**到类的函数表里  
* 所以 return 时还再执行一次`lookUpImpOrForward`让函数**执行**(ps 注意入参LOOKUP_CACHE, 避免死循环递归用的)  
```objc  
static NEVER_INLINE IMP resolveMethod_locked(id inst, SEL sel, Class cls, int behavior)  
{  
    if (! cls->isMetaClass()) {  
        resolveInstanceMethod(inst, sel, cls);  
    } else {  
        resolveClassMethod(inst, sel, cls);  
        if (!lookUpImpOrNil(inst, sel, cls)) {  
				// ⚠️ 如果 cls 是元类, 那这函数属于元类的实例的方法, 所以还要执行一次resolveInstanceMethod  
				// ⚠️ 其实不是特别明白  
            resolveInstanceMethod(inst, sel, cls);  
        }  
    }  
    return lookUpImpOrForward(inst, sel, cls, behavior | LOOKUP_CACHE);  
}  
```  
  
## `resolveInstanceMethod`: 动态解析对象的函数  
* 先不看源码里的`resolveInstanceMethod`, 这里 `@selector(resolveInstanceMethod:)` 其实跟外面 OC 拿 SEL 的流程一样的  
* 不管当前在执行的是啥函数, 这里先执行一次 objc_msgSend, send 的消息是`resolveInstanceMethod`, 参数是 sel  
* 这个`resolveInstanceMethod` 具体由开发决定怎么实现, (一般是将 sel 加入类函数表中)  
```objc  
SEL resolve_sel = @selector(resolveInstanceMethod:);  
BOOL (*msg)(Class, SEL, SEL) = (typeof(msg))objc_msgSend;  
bool resolved = msg(cls, resolve_sel, sel);  
```  
* 然后再尝试将,当前调用的函数缓存起来(方式是执行一次`lookUpImpOrNil`)  
* 这里再次注意, 上面说过`resolveInstanceMethod`是由开发自己实现, 所以开发完全可以将这个 sel 添加到函数表中  
* imp 的作用只是后面打 log, 实质 `lookUpImpOrNil` 的结果不影响运行  
```objc  
// Cache the result (good or bad) so the resolver doesn't fire next time.  
// +resolveInstanceMethod adds to self a.k.a. cls  
IMP imp = lookUpImpOrNil(inst, sel, cls);  
```  
  
## `resolveClassMethod`: 动态解析类的函数  
大同小异, 多了一些判断类已实现的操作, 并且执行的对象是 metaclass  
```objc  
BOOL (*msg)(Class, SEL, SEL) = (typeof(msg))objc_msgSend;  
bool resolved = msg(nonmeta, @selector(resolveClassMethod:), sel);  
IMP imp = lookUpImpOrNil(inst, sel, cls);  
```  
  
## 动态解析找不到, imp 被设为`_objc_msgForward_impcache`, 进入消息转发流程  
`_objc_msgForward_impcache` 是一个函数指针, 在前面代码中可以看到, `_lookUpImpOrForward` 从开始就会给 IMP 默认值设为这个指针.  
  
**消息转发**: 这部分代码不在 `runtime` 中, 根据资料其实现于 CoreFoundation 框架. 要用反编译才能追踪  
我追查 `_objc_msgForward_impcache`, 最终断链在 `__objc_forward_handler`  
> OC:`_objc_msgForward_impcache` -> 汇编:`__objc_msgForward` -> 汇编:`__objc_forward_handler` -> C++:`objc_defaultForwardHandler`    
>     
> `objc_defaultForwardHandler`. 里面有个很熟悉的语句:`unrecognized selector sent to instance` 打日志并 crash    
  
之后涉及到反编译后反汇编内容, 结论都来自于参考文章:  
1. **找一个新的 Target**: 调用 `forwardingTargetForSelector` 返回新的`receiver`  
* 新的 Target 有效: 用新的 target 执行消息  
* 新的 Target 无效: (`nil`/`self`) 下一步  
2. 调用 `methodSignatureForSelector` 生成`NSInvocation`,   
3. 再调用`forwardInvocation` 处理 `NSInvocation` 对象  
4. 若类本身都未实现, 则默认执行 `doesNotRecognizeSelector `  
(NSObject 实现了`forwardInvocation` 并默认调用 `doesNotRecognizeSelector`)  
```objc  
+ (void)forwardInvocation:(NSInvocation *)invocation {  
    [self doesNotRecognizeSelector:(invocation ? [invocation selector] : 0)];  
}  
- (void)forwardInvocation:(NSInvocation *)invocation {  
    [self doesNotRecognizeSelector:(invocation ? [invocation selector] : 0)];  
}  
```  
  
可以用于实现多继承: [Message Forwarding](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtForwarding.html#//apple_ref/doc/uid/TP40008048-CH105-SW11)  
  
  
## 其他: 中途调用其他细节代码分析  
### `GetClassFromIsa_p16`  
本质就是 `isa and(&)  ISA_MASK`  
代码很长, 这里不过度细究. 内容是对于 3 种不同的 isa 不同的处理方式. 这里只看 64 位下的  
```  
.macro GetClassFromIsa_p16 /* src */  
...  
#elif __LP64__  
  // 64-bit packed isa  
  and p16, $0, #ISA_MASK  
#else  
...  
.endmacro  
  
```  
  
### `assertUnlocked`  
```objc  
//objc-os.h  
void assertUnlocked() {  
    lockdebug_mutex_assert_unlocked(this);  
}  
//objc-lockdebug.mm  
void lockdebug_mutex_assert_unlocked(mutex_t *lock)  
{  
    auto& locks = ownedLocks();  
    if (hasLock(locks, lock, MUTEX)) {  
        _objc_fatal("mutex incorrectly locked");  
    }  
}  
```  
  
### `_cache_getImp `  
```objc  
STATIC_ENTRY _cache_getImp  
  GetClassFromIsa_p16 p0  
  CacheLookup GETIMP, _cache_getImp  
LGetImpMiss:  
  mov p0, #0  
  ret  
  
  END_ENTRY _cache_getImp  
```  
  
