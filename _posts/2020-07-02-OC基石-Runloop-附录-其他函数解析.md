---
title: 附录-OC源码-Runloop： 其他函数解析(`CFRunLoopDoObservers`、`__CFRunLoopDoBlocks`、`__CFRunLoopDoSources0`)    
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
lightbox: true
pageview: true
tags: 源码解析 OC基石
coding: UTF-8
--- 
> 源码来源:  https://opensource.apple.com/tarballs/CF/    
> 使用的源码版本: [CF-1151.16.tar](/assets/images/源码解析/runloop/CF-1151.16.tar)   
  
## runloop 创建相关的函数  
### `_CFRunLoopGet0`  
外部获取某个线程的 runloop 时使用  
1. **空值判断**: 当传入线程为 空 时, 默认为主线程  
```objc  
if (pthread_equal(t, kNilPthreadT)) {  
    t = pthread_main_thread_np();  
}  
```  
2. **全局初始化**: `__CFRunLoops`是个全局变量, 但这个变量为空时,证明 runloop 的环境是第一次执行需要创建一些全局变量  
`dict`: 结合后面会看到, 这是个存储了全局 runloop 的集合  
`mainLoop`: 即主线程的 runloop, 会在第一次初始化时一块初始化, 之后会添加进 dict 中  
```objc  
if (!__CFRunLoops) {  
    CFMutableDictionaryRef dict = CFDictionaryCreateMutable(kCFAllocatorSystemDefault, 0, NULL, &kCFTypeDictionaryValueCallBacks);  
    CFRunLoopRef mainLoop = __CFRunLoopCreate(pthread_main_thread_np());  
    CFDictionarySetValue(dict, pthreadPointer(pthread_main_thread_np()), mainLoop);  
}  
```  
3. **loop 获取**: 后面会使用线程尝试获取一次 loop, 若是拿不到则创建一个, 若是能拿到则直接返回   

```objc  
CFRunLoopRef loop = (CFRunLoopRef)CFDictionaryGetValue(__CFRunLoops, pthreadPointer(t));  
if (!loop) {  
	CFRunLoopRef newLoop = __CFRunLoopCreate(t);  
	// 会再拿一次, 不知道为啥, __CFRunLoopCreate中也没有加入的操作  
	loop = (CFRunLoopRef)CFDictionaryGetValue(__CFRunLoops, pthreadPointer(t));  
	if (!loop) {  
		CFDictionarySetValue(__CFRunLoops, pthreadPointer(t), newLoop);  
		loop = newLoop;  
	}  
}  
// ...有省略  
return loop;  

```  

### `__CFRunLoopCreate`  
主要是调用 `_CFRuntimeCreateInstance` 然后赋初始值的操作  
### `_CFRuntimeCreateInstance`:  
 - [ ] 内部的代码已经到 CFRuntime 这一层了, 暂时不做深入,先回到 runloop 主线  
  
## runloop 执行相关的函数  
### 总结:  
* 会发现 doXXX 函数, 最终的核心部分都是调用 `__CFRUNLOOP_IS_CALLING_OUT_TO xxx` 的函数  
* `__CFRUNLOOP_IS_CALLING_OUT_TO` 基本上所有的实现,执行外部传入函数指针, 既<mark>真正的执行外界函数</mark>  
  
### 很多地方调用的`CFGetTypeID(sources)`是什么  
下面探究的函数中, 很多地方都能看到这个判断,  
虽然不是每个地方都有注释, 并且最终追溯也只能其对比的值是 0.  
但是通过其逻辑和部分注释, 能得出结论 <mark>这是一个判断某个指针是**单个元素**, 还是**集合_链表_数组**的判断</mark>  
(`CFStringGetTypeID` -> `__kCFStringTypeID` -> `_kCFRuntimeNotATypeID` -> `0`)  
(`CFRunLoopSourceGetTypeID` -> `_kCFRuntimeNotATypeID` -> `0`)  

```objc  
// sources is either a single (retained) CFRunLoopSourceRef or an array of (retained) CFRunLoopSourceRef  
CFGetTypeID(sources) == CFRunLoopSourceGetTypeID()  
CFStringGetTypeID() == CFGetTypeID(mode)  
CFStringGetTypeID() == CFGetTypeID(curr->_mode)  
CFGetTypeID(item) == CFRunLoopSourceGetTypeID()  
CFStringGetTypeID() == CFGetTypeID(curr->_mode)  

```  
  
ps.我推测其原理类似于之前研究的 runtime 的 isa 技术 [其他: Tagged pointer 与 isa](https://mjxin.github.io/2020/07/01/OC%E5%9F%BA%E7%9F%B3-Runtime-%E9%99%84%E5%BD%95-TaggedPointer%E4%B8%8Eisa.html)  
  
### `__CFRunLoopDoObservers`  
[CFRunLoop.c](/assets/images/源码解析/runloop/CFRunLoop.c)  
核心部分是一个: for 循环取出 Observer, 循环中经过一系列操作后执行  
`__CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__`  
  
这个函数会真正的调用 [`__CFRunLoopObserver`](https://mjxin.github.io/2020/07/02/OC%E5%9F%BA%E7%9F%B3-Runloop-%E9%99%84%E5%BD%95-%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90.html#cfrunloopobserverref--__cfrunloopobserver)中的回调  
  
1. 先拿 Set 中的 Observers 个数, 然后拿去申请内存, 之后逐个加入数组中(代码有省略)   
```objc  
  // 获取个数  
  CFIndex cnt = rlm->_observers ? CFArrayGetCount(rlm->_observers) : 0;  
  // 根据情况申请空间  
  CFRunLoopObserverRef *collectedObservers = (cnt <= 1024) ? buffer : (CFRunLoopObserverRef *)malloc(cnt * sizeof(CFRunLoopObserverRef));  
  // 加入数组  
  for (CFIndex idx = 0; idx < cnt; idx++) {  
    collectedObservers[obs_cnt++] = (CFRunLoopObserverRef)CFRetain(rlo);  
  }  
```
2. 接下来是核心部分: for 循环外部有锁操作(🔲具体锁以后视情况探究,暂时不深入)  
```objc  
__CFRunLoopModeUnlock(rlm);  
__CFRunLoopUnlock(rl);  
for (CFIndex idx = 0; idx < obs_cnt; idx++) {...}  
__CFRunLoopLock(rl);  
__CFRunLoopModeLock(rlm);  
```

3.for 循环内部: 最终正确的会执行 `__CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__ `  
执行过程中会调用`__CFRunLoopObserverSetFiring` 和 `__CFRunLoopObserverUnsetFiring`修改标记,追踪源码, 这是个做计算的宏  
主要是这些操作:  
1. 验证有效性  
2. 验证重复  
3. 标记为 `Firing`  
4. **核心代码**: 调用`__CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__`, 真正的执行回调  
5. 取消标记`Firing`  
```objc  
for (CFIndex idx = 0; idx < obs_cnt; idx++) {  
    CFRunLoopObserverRef rlo = collectedObservers[idx];  
    __CFRunLoopObserverLock(rlo);  
    if (__CFIsValid(rlo)) {  
        Boolean doInvalidate = !__CFRunLoopObserverRepeats(rlo);  
        __CFRunLoopObserverSetFiring(rlo);  
        __CFRunLoopObserverUnlock(rlo);  
        __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(rlo->_callout, rlo, activity, rlo->_context.info);  
        if (doInvalidate) {  
            CFRunLoopObserverInvalidate(rlo);  
        }  
        __CFRunLoopObserverUnsetFiring(rlo);  
    } else {  
        __CFRunLoopObserverUnlock(rlo);  
    }  
    CFRelease(rlo);  
}  
```  

```objc  
CF_INLINE void __CFRunLoopObserverSetFiring(CFRunLoopObserverRef rlo) {  
    __CFBitfieldSetValue(((CFRuntimeBase *)rlo)->_cfinfo[CF_INFO_BITS], 0, 0, 1);  
}  
#define __CFBitfieldSetValue(V, N1, N2, X)  ((V) = ((V) & ~__CFBitfieldMask(N1, N2)) | (((X) << (N2)) & __CFBitfieldMask(N1, N2)))  
```  
  
### `__CFRunLoopDoBlocks`  
<a href='/assets/images/源码解析/runloop/CFRunLoop.c'>CFRunLoop.c</a>  
核心逻辑是: while 遍历 block 的链表中取出 block,  然后调用`__CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__`  
`block` 具体是啥我写在这: [其他: 数据结构源码解析`block`](https://mjxin.github.io/2020/07/02/OC%E5%9F%BA%E7%9F%B3-Runloop-%E9%99%84%E5%BD%95-%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90.html#%E4%B8%8D%E5%B1%9E%E4%BA%8E-runloop-%E4%B8%89%E5%85%83%E7%B4%A0%E4%BD%86%E8%A2%AB%E7%94%A8%E5%88%B0%E7%9A%84%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84)  
`CFRunLoopRef` 具体数据结构:[其他: 数据结构源码解析`CFRunLoopRef`](https://mjxin.github.io/2020/07/02/OC%E5%9F%BA%E7%9F%B3-Runloop-%E9%99%84%E5%BD%95-%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90.html#cfrunloopref--__cfrunloop)  
  
可以理解为, 这里就是在处理,我们 `dispatch_async`, `dispatch_sync` 所传入的 block  
  
1. 从源码解析那篇文章中可以看到, block 被以链表的形式存了起来, 这里取出了链表, 然后清掉之前存的数据  
```objc  
struct _block_item *head = rl->_blocks_head;  
struct _block_item *tail = rl->_blocks_tail;  
rl->_blocks_head = NULL;  
rl->_blocks_tail = NULL;  
```   
2. 之后就涉及到之前提过的 `common` 概念, 拿到当前 common 的所有 modes  
✏️ 补充 common 的连接  
```objc  
CFSetRef commonModes = rl->_commonModes;  
```  
3. 进入循环 `while (item)`,开始遍历链表, 这里直接看进入循环后  
4. 拿到当前节点, 并且再往下走一个元素  
```objc  
struct _block_item *curr = item;  
item = item->_next;  
```  
5. 判断 block 的 mode , **以决定 block 是否需要被执行**  
* 这里面的判断`CFGetTypeID`, `CFEqual` 等看上面 [很多地方调用的`CFGetTypeID(sources)`是什么](https://mjxin.github.io/2020/07/02/OC%E5%9F%BA%E7%9F%B3-Runloop-%E9%99%84%E5%BD%95-%E5%85%B6%E4%BB%96%E5%87%BD%E6%95%B0%E8%A7%A3%E6%9E%90.html#%E5%BE%88%E5%A4%9A%E5%9C%B0%E6%96%B9%E8%B0%83%E7%94%A8%E7%9A%84cfgettypeidsources%E6%98%AF%E4%BB%80%E4%B9%88)  
* 最终外层判断出来当前 block 的 mode 是单一元素, 还是一个 set  
  * 单个元素执行下面判断:  
    1. block 所属的 mode, 是否等于当前 runloop 的 mode  
    2. 当前 runloop 的 mode 是否在 `common` 中且 block 的 mode 是否在 `common`中  
  * set 执行下面判断:  
    1. 当前 runloop 的 mode 是否在 block.mode 中  
    2. CommonMode 是否包含了 block.mode 且 CommonMode 是否包含当前 runloop.mode  
```objc  
// CFRunloop.c  
if (CFStringGetTypeID() == CFGetTypeID(curr->_mode)) {  
    doit = CFEqual(curr->_mode, curMode) || (CFEqual(curr->_mode, kCFRunLoopCommonModes) && CFSetContainsValue(commonModes, curMode));  
    } else {  
    doit = CFSetContainsValue((CFSetRef)curr->_mode, curMode) || (CFSetContainsValue((CFSetRef)curr->_mode, kCFRunLoopCommonModes) && CFSetContainsValue(commonModes, curMode));  
}  
```  
6.**核心** 需要被执行的操作最后会调用`__CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__`  
```objc  
// 省略一些指针操作  
 if (doit) {  
		__CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__(block);  
		did = true;  
}  
```  
  
### `__CFRunLoopDoSources0`  
核心逻辑: for 循环取出 source0, 验证后执行`__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__`  
其实与上面大同小异:  
1. 一些校验操作后, 判断是单个元素还是 set  
2. 如果是 set, 进入循环, 做校验,然后执行**核心部分**  
`__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__`  
  
  
```objc  
// 把东西取出来, CFSetApplyFunction 其实内部是 do-while 宏, 主要是 __CFRunLoopCollectSources0 函数  
 if (NULL != rlm->_sources0 && 0 < CFSetGetCount(rlm->_sources0)) {  
    CFSetApplyFunction(rlm->_sources0, (__CFRunLoopCollectSources0), &sources);  
}  
```  
  
  
```objc  
//循环和非循环类似, 都是执行下面的, 最终执行到`__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__`  
CFIndex cnt = CFArrayGetCount((CFArrayRef)sources);  
CFArraySortValues((CFMutableArrayRef)sources, CFRangeMake(0, cnt), (__CFRunLoopSourceComparator), NULL);  
for (CFIndex idx = 0; idx < cnt; idx++) {  
CFRunLoopSourceRef rls = (CFRunLoopSourceRef)CFArrayGetValueAtIndex((CFArrayRef)sources, idx);  
__CFRunLoopSourceLock(rls);  
if (__CFRunLoopSourceIsSignaled(rls)) {  
    __CFRunLoopSourceUnsetSignaled(rls);  
    if (__CFIsValid(rls)) {  
        __CFRunLoopSourceUnlock(rls);  
        __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__(rls->_context.version0.perform, rls->_context.version0.info);  
        CHECK_FOR_FORK();  
        sourceHandled = true;  
    } else {  
        __CFRunLoopSourceUnlock(rls);  
    }  
} else {  
	 __CFRunLoopSourceUnlock(rls);  
}  
}  
```  