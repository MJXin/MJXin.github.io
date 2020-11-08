---
title: 附录-OC源码-Runloop： 数据结构源码解析`CFRunLoopSourceRef`,`CFRunLoopTimerRef`,`CFRunLoopObserverRef `,`CFRunLoopRef`,`_block_item`  
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
  
> 部分解释和源码中看不懂的含义参考自:     
> [深入理解RunLoop | Garan no dou](https://blog.ibireme.com/2015/05/18/runLoop/)(15 年的老文章了,代码较旧)    
  
下面内容只涉及核心字段, 目的是了解 runloop 数据结构及各结构体之间的关系以及其整体设计思路  
剩余的很多字段是在 runloop 执行时, 用于记录某些变量用的, 暂时不细究  
  
[一.runloop 是什么](https://mjxin.github.io/2020/08/20/OC%E5%9F%BA%E7%9F%B3-Runloop-%E6%AD%A3%E6%96%871.html) 从这里我们知道, runloop 有四个基本概念 `Thread`, `Runloop`,`Mode`,`Item`  
其中后面三个概念属于 Runloop,   
数据结构关系是:  
* `Thread` 与 `Runloop` 一对一  
* 一个 `Runloop` 包含多个 `Mode`, 一个 `Mode` 中包含多个 Item  
* `Item` 分为三种 `Source`, `Timer`, `Observer`  
* `Source` 又分为两种: `Source0`, `Source1`  
  
除了 `Thread` 是用的 `pthread_t` 外整体关系如下图所示:  
![](/assets/images/源码解析/runloop/runloop 数据结构.png)  
  
  
从右到左讲起  
  
## `CFRunLoopSourceRef` & `__CFRunLoopSource`  
`CFRunLoopSourceRef `, 接口中常见的类型, 本质是 `__CFRunLoopSource `的指针类型  
  
`__CFRunLoopSource`的核心属性:  
* `CFMutableBagRef`: 所属的 runloop  
* union 是联合体, 理解为下面描述的所有字段都在同一块内存地址, 并且同时只能是其中一个  
* `version0`: 上面提到的 source 0: 需要手动触发唤醒的事件,  
* `version1`: 上面提到的 source 1: 由内核触发事件, 基于端口的线程通信, 能主动唤醒 Runloop  
具体 `source 0` 和 `source 1` 见正文部分 [一.数据结构](https://mjxin.github.io/2020/08/17/OC%E5%9F%BA%E7%9F%B3-GCD-%E6%AD%A3%E6%96%87.html#%E5%9F%BA%E6%9C%AC%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84)    

```objc  
// 省略一部分字段  
struct __CFRunLoopSource {  
    CFMutableBagRef _runLoops;  
    union {  
			CFRunLoopSourceContext version0;    /* immutable, except invalidation */  
			CFRunLoopSourceContext1 version1;   /* immutable, except invalidation */  
    } _context;  
};  
```  
  
## `CFRunLoopTimerRef` & `__CFRunLoopTimer`  
`CFRunLoopObserverRef`, 接口中常见的类型, 本质是 `__CFRunLoopTimer `的指针类型  
  
`__CFRunLoopTimer `核心部分:  
* `runloop`: 所属 Runloop  
* `rlModes`: 所属的 mode  
* `nextFireDate`: 下一次触发时间  
* `interval`: 触发间隔  
* `tolerance`: 时间宽容度(误差?)  
* `_fireTSR`: 根据 `runloopRun` 函数来看,应该是触发的时间  
* `_callout`: 触发时执行的事件回调  
  
从其中的从属关系来看, Timer 不像其他 Item(`Source`, `Observer`)他不是隶属于某个的 Modes 的 

```objc  
typedef void (*CFRunLoopObserverCallBack)(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info);  
  
struct __CFRunLoopTimer {  
    CFRunLoopRef _runLoop;  
    CFMutableSetRef _rlModes;  
    CFAbsoluteTime _nextFireDate;  
    CFTimeInterval _interval;       /* immutable */  
    CFTimeInterval _tolerance;          /* mutable */  
    uint64_t _fireTSR;          /* TSR units */  
    CFRunLoopTimerCallBack _callout;    /* immutable */  
    CFRunLoopTimerContext _context; /* immutable, except invalidation */  
};  
```  
  
## `CFRunLoopObserverRef` & `__CFRunLoopObserver`  
`CFRunLoopObserverRef`, 接口中常见的类型, 本质是 `__CFRunLoopObserver`的指针类型  
```objc  
typedef struct CF_BRIDGED_MUTABLE_TYPE(id) __CFRunLoopObserver * CFRunLoopObserverRef;  
```  
  
`__CFRunLoopObserver` 的核心属性:  
* `runloop`: 所属的 runloop  
* `_activities`: runloop 的活动状态, 本质是个整型  
* `_callout `: 回调函数, 本质是个函数指针  
* `_context `: 上下文, 存放了一些 observer 的描述信息  

```objc  
typedef unsigned long long CFOptionFlags;  
typedef void (*CFRunLoopObserverCallBack)(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info);  
  
// 省略了一部分字段  
struct __CFRunLoopObserver {  
    CFRunLoopRef _runLoop;  
    CFOptionFlags _activities;      /* immutable */  
    CFRunLoopObserverCallBack _callout; /* immutable */  
    CFRunLoopObserverContext _context;  /* immutable, except invalidation */  
};  
```  
  
`CFRunLoopObserverContext`: Observer 信息  
```objc  
typedef struct {  
    CFIndex version;  
    void *  info;  
    const void *(*retain)(const void *info);  
    void    (*release)(const void *info);  
    CFStringRef (*copyDescription)(const void *info);  
} CFRunLoopObserverContext;  
```  
  
  
## `CFRunLoopRef` & `__CFRunLoop`  
`CFRunLoopRef` 也是我们在接口中常见的类型, 本质是`__CFRunLoop`的指针类型  
```objc  
typedef struct CF_BRIDGED_MUTABLE_TYPE(id) __CFRunLoop * CFRunLoopRef;  
```  
  
`__CFRunLoop`的核心属性:  
* _modes: runloop 所拥有的所有 mode  
* _currentMode: runloop 中当前的 mod  
* _commonModes: runloop 中被标记为 <mark>Common</mark> 的 modes  
* _commonModeItems: runloop 中被标记为 <mark>Common</mark> 的 items(Observer, Timer, Source)  

runloop 执行时, 有一部分的 mode 或者 item 可以手动加入 <mark>Common</mark> 中, 起到这么一个作用:  
所有加入了 `_commonModeItems` 中的内容, 会在执行时被自动同步到加入 `_commonModes` 的 Mode 中  
```objc  
// 省略了一部分字段  
struct __CFRunLoop {  
		CFMutableSetRef _modes;  
		CFRunLoopModeRef _currentMode;  
		CFMutableSetRef _commonModes;  
		CFMutableSetRef _commonModeItems;  
};  
```  
  
  
  
##  `CFRunLoopModeRef` & `__CFRunLoopMode`  
CFRunLoopModeRef 是比较常见的类型, 本质就是`__CFRunLoopMode `的指针类型  
```objc  
typedef struct __CFRunLoopMode *CFRunLoopModeRef;  
```  
  
先看 `__CFRunLoopMode` 的核心属性:  
* mode 名字  
* _pthread: 对应的线程;  
* source0: 上面 [`__CFRunLoopSource`]https://mjxin.github.io/2020/07/02/OC%E5%9F%BA%E7%9F%B3-Runloop-%E9%99%84%E5%BD%95-%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90.html#cfrunloopsourceref--__cfrunloopsource),Source 0 的集合  
* source1: 上面 [`__CFRunLoopSource`](https://mjxin.github.io/2020/07/02/OC%E5%9F%BA%E7%9F%B3-Runloop-%E9%99%84%E5%BD%95-%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90.html#cfrunloopsourceref--__cfrunloopsource),Source 1 的集合  
* observers: 上面 [`__CFRunLoopObserver`](https://mjxin.github.io/2020/07/02/OC%E5%9F%BA%E7%9F%B3-Runloop-%E9%99%84%E5%BD%95-%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90.html#cfrunloopobserverref--__cfrunloopobserver), observer 的集合  
* timers: 上面 [`__CFRunLoopTimer`](https://mjxin.github.io/2020/07/02/OC%E5%9F%BA%E7%9F%B3-Runloop-%E9%99%84%E5%BD%95-%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90.html#cfrunlooptimerref--__cfrunlooptimer), Timer 的集合  
* _blocks_head: 存储被 `dispatch_sync`,`dispatch_async`到当前 runloop 中的 block(头结点)  
* _blocks_tail: 存储被 `dispatch_sync`,`dispatch_async`到当前 runloop 中的 block(尾结点)  
* 上面这两很明显是个链表  
```objc  
// 省略了一部分字段  
struct __CFRunLoopMode {  
		CFStringRef _name;  
		CFMutableSetRef _sources0;  
		CFMutableSetRef _sources1;  
		CFMutableArrayRef _observers;  
		CFMutableArrayRef _timers;  
		struct _block_item *_blocks_head;  
		struct _block_item *_blocks_tail;  
};  
```  
- - - -  
## 不属于 Runloop 三元素但被用到的数据结构  
### `_block_item`: 就是我们 dispatch 进来的 `block`  
可以看到我们的 `block` 被封装为了链表结构  
	* _next: 下一个节点  
	* _mode: block 所在的模式  
	* _block: block 的函数体  
```objc  
struct _block_item {  
    struct _block_item *_next;  
    CFTypeRef _mode;    // CFString or CFSet  
    void (^_block)(void);  
};  
```  
  
#猿人/猿艺/iOS/基石/runloop/正文