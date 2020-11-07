---
title: 附录-OC源码-Runloop： CFRunloopRun 源码解析   
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
picture_frame: shadow
tags: 源码解析 OC基石
coding: UTF-8
--- 
> 源码来源:  https://opensource.apple.com/tarballs/CF/    
> 使用的源码版本: [CF-1151.16.tar](/assets/images/源码解析/runloop/CF-1151.16.tar)   
    
> 下面的源码解析摘自`CFRunloop.c`, 被我删减了宏过滤掉的部分(大多是系统判断), 并做了格式化    
> [CFRunloopRun.c](/assets/images/源码解析/runloop/CFRunloopRun.c)    
> 源码中有部分涉及 `Mach` 这是属于系统内核的调度, 了解的不多, 暂时也不做深入了解 [其他: Mach 是什么](bear://x-callback-url/open-note?id=715FA7E8-B8B5-4FA2-862C-F7F7EED7689F-470-00002563D7DA5446)    
> 参考文章:    
> [Run Loops](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html)    
> [深入理解RunLoop | Garan no dou](https://blog.ibireme.com/2015/05/18/runloop/)    
  
## `__CFRunLoopRun` 的本质  
先抛开其他代码, 找最核心部分, (格式化的文件中第 42 行和第 158 行)  

```c  
int32_t retVal = 0;  
do {  
//...  
} while (0 == retVal);  

```  
可以看到, `runlooprun` 的核心是一个受 `retVal` 控制的循环  
`retval` 是 `CFRunLoopRunResult` 内描述的几个值(或初始化的 0), 在 do 循环过程前会被设为 0, 之后根据不同的状态做修改  

```c  
typedef CF_ENUM(SInt32, CFRunLoopRunResult) {  
    kCFRunLoopRunFinished = 1,  
    kCFRunLoopRunStopped = 2,  
    kCFRunLoopRunTimedOut = 3,  
    kCFRunLoopRunHandledSource = 4  
};  

```  
  
## 记录开始时间  

```c  
uint64_t startTSR = mach_absolute_time();  
```  
  
## 状态判断与获取消息端口  
字面意思理解, 代码在判断 runloop 是否已经处于停止状态, 以及安全与否  
并拿到一个dispatch_port(看其他参考文章是 获取 GCD 的消息端口, 调用一个室友 api, 4CF 意为 for core foundation)  

```c  
if (__CFRunLoopIsStopped(rl)) {  
		__CFRunLoopUnsetStopped(rl);  
		return kCFRunLoopRunStopped;  
} else if (rlm->_stopped) {  
		rlm->_stopped = false;  
		return kCFRunLoopRunStopped;  
}  
mach_port_name_t dispatchPort = MACH_PORT_NULL;  
Boolean libdispatchQSafe = pthread_main_np() && ((HANDLE_DISPATCH_ON_BASE_INVOCATION_ONLY && NULL == previousMode) || (!HANDLE_DISPATCH_ON_BASE_INVOCATION_ONLY && 0 == _CFGetTSD(__CFTSDKeyIsInGCDMainQ)));  
if (libdispatchQSafe && (CFRunLoopGetMain() == rl) && CFSetContainsValue(rl->_commonModes, rlm->_name)) dispatchPort = _dispatch_get_main_queue_port_4CF();  

```  
  
## 超时设置  
如果超时小于 0 全部按 0 处理, 处理结果是无超时  
如果超时大于安全值, 直接将其设成最大数, 永不超时  
如果超时设置在合法范围内, 则使用 GCD 添加一个 Timer  
* 如果在主线程 queue 为 `__CFDispatchQueueGetGenericMatchingMain`否则为`__CFDispatchQueueGetGenericBackground`  
* 设置处理函数`__CFRunLoopTimeout`, 取消函数`__CFRunLoopTimeoutCancel`  
* 并触发这个 Timer  
(下面代码有省略)  

```c  
// for conservative arithmetic safety, such that (TIMER_DATE_LIMIT + TIMER_INTERVAL_LIMIT + kCFAbsoluteTimeIntervalSince1970) * 10^9 < 2^63  
#define TIMER_DATE_LIMIT    4039289856.0  
#define TIMER_INTERVAL_LIMIT    504911232.0  
if (seconds <= 0.0) { // instant timeout  
		seconds = 0.0;  
		timeout_context->termTSR = 0ULL;  
} else if (seconds <= TIMER_INTERVAL_LIMIT) {  
		// 设置 queue  
		dispatch_queue_t queue = pthread_main_np() ? __CFDispatchQueueGetGenericMatchingMain() : __CFDispatchQueueGetGenericBackground();  
		//构造 Timer  
		timeout_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);  
		//设置执行的函数  
		dispatch_source_set_event_handler_f(timeout_timer, __CFRunLoopTimeout);  
     dispatch_source_set_cancel_handler_f(timeout_timer, __CFRunLoopTimeoutCancel);  
		//执行  
		dispatch_resume(timeout_timer);  
} else { // infinite timeout  
     seconds = 9999999999.0;  
     timeout_context->termTSR = UINT64_MAX;  
}  

```  
  
## 核心 `do-while`  
> 我在这里面解读了一些细节函数    
> [其他: 一些其他函数解析(`CFRunLoopDoObservers`、`__CFRunLoopDoBlocks`)](bear://x-callback-url/open-note?id=460B8C4E-45D7-45E1-ADA1-930BB7AF5D4A-470-00002CE3191B3685)     
> ❓我其实没找到具体休眠的的代码    
  
前面提过,`格式化文件`中第 42 行和第 158 行是 do-while, `CFRunloopRun` 函数的核心, 这里直接看其内部代码  
1. **初始化循环条件**: 进入 do-while 前先将 while 的判断条件设为`int32_t retVal = 0;` 默认下一次会继续循环  
2. ❓执行`__CFRunLoopUnsetIgnoreWakeUps`改了个标志位(暂时不知道干啥)  
3. **调用监听者**: 通知监听了 `kCFRunLoopBeforeTimers` 的 Observers, 源码解析见: [`CFRunLoopDoObservers`](bear://x-callback-url/open-note?id=460B8C4E-45D7-45E1-ADA1-930BB7AF5D4A-470-00002CE3191B3685)  
4. **调用监听者**: 通知监听了 `kCFRunLoopBeforeSources` 的 Observers,源码解析见: [`CFRunLoopDoObservers`](bear://x-callback-url/open-note?id=460B8C4E-45D7-45E1-ADA1-930BB7AF5D4A-470-00002CE3191B3685)  
```objc  
if (rlm->_observerMask & kCFRunLoopBeforeTimers) __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeTimers);  
if (rlm->_observerMask & kCFRunLoopBeforeSources) __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeSources);  
```  
5. **执行 block**: 执行 blocks 源码解析见另一篇文章: [`__CFRunLoopDoBlocks`](bear://x-callback-url/open-note?id=460B8C4E-45D7-45E1-ADA1-930BB7AF5D4A-470-00002CE3191B3685)  
```objc
__CFRunLoopDoBlocks(rl, rlm);  
```  
6. **执行 source0**: 判断 source 0, 并执行[`__CFRunLoopDoSources0`](bear://x-callback-url/open-note?id=460B8C4E-45D7-45E1-ADA1-930BB7AF5D4A-470-00002CE3191B3685)  
7. **执行 block**: 然后根据情况只要 source0 内部正确执行了,就要再执行一次 block (怀疑是 source 0 有东西加入 block, 但是我在源码中发现; 推测是 source0 中执行的内容, 有可能又调用 `dispatch_async` `dispatch_sync`, 导致有新的 block 加入)  
```objc  
Boolean sourceHandledThisLoop = __CFRunLoopDoSources0(rl, rlm, stopAfterHandle);  
if (sourceHandledThisLoop) { __CFRunLoopDoBlocks(rl, rlm);}  
```  
11. **处理 source1**❓ 这一步我不是很确定, 因为其被几个宏包裹, 内部在执行 mach 相关的东西  
12. **休眠**: poll, 看后面的代码, 是用来判断是否要休眠用的, 如果前面 source 有效,并且无设置超时, 则不休眠  
❓休眠代码我看内部只是在改标志位, 实际推测是`CFRunLoopServiceMachPort`调用了休眠  
```objc  
Boolean poll = sourceHandledThisLoop || (0ULL == timeout_context->termTSR);  
if (!poll && (rlm->_observerMask & kCFRunLoopBeforeWaiting)) __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeWaiting);  
// 可以理解为从这里开始,休眠开始  
__CFRunLoopSetSleeping(rl);  
// ...中间省去一些代码  
CFAbsoluteTime sleepStart = poll ? 0.0 : CFAbsoluteTimeGetCurrent();  
// 增加睡眠的记录  
rl->_sleepTime += (poll ? 0.0 : (CFAbsoluteTimeGetCurrent() - sleepStart));  
// 可以理解为从这里开始,休眠结束  
__CFRunLoopUnsetSleeping(rl);  
```  
11. ❓`__CFPortSetInsert(dispatchPort, waitSet); `: 没看懂具体做了啥, 我所搜到的实现与 mach 有关,暂时不探究  
12. **调用监听者**: 通知监听了 `kCFRunLoopAfterWaiting` 的 Observers, 源码解析见另一篇文章: [`CFRunLoopDoObservers`](bear://x-callback-url/open-note?id=460B8C4E-45D7-45E1-ADA1-930BB7AF5D4A-470-00002CE3191B3685)  
13. **执行唤醒的内容**: `CFRUNLOOP_WAKEUP_FOR_NOTHING`,`CFRUNLOOP_WAKEUP_FOR_WAKEUP` 本质都是`do { } while (0)`意思是跑个啥也不干一次循环.  
这里主要是根据唤醒的东西来执行对应的事情, 下面这两情况都是啥也不干  
```objc  
 if (MACH_PORT_NULL == livePort) {  
    CFRUNLOOP_WAKEUP_FOR_NOTHING();  
} else if (livePort == rl->_wakeUpPort) {  
    CFRUNLOOP_WAKEUP_FOR_WAKEUP();  
}  
```  
  被 Timer 唤醒的, 则执行 timer  
```objc  
if (rlm->_timerPort != MACH_PORT_NULL && livePort == rlm->_timerPort) {  
            CFRUNLOOP_WAKEUP_FOR_TIMER();  
```  
  被 GCD 唤醒的则执行 GCD  
```objc  
 else if (livePort == dispatchPort) {  
            CFRUNLOOP_WAKEUP_FOR_DISPATCH();  
            __CFRunLoopModeUnlock(rlm);  
            __CFRunLoopUnlock(rl);  
            _CFSetTSD(__CFTSDKeyIsInGCDMainQ, (void *)6, NULL);  
            __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(msg);  
            _CFSetTSD(__CFTSDKeyIsInGCDMainQ, (void *)0, NULL);  
            __CFRunLoopLock(rl);  
            __CFRunLoopModeLock(rlm);  
            sourceHandledThisLoop = true;  
            didDispatchPortLastTime = true;  
}   
```  
  剩下就是 `source1` 的事件, 都执行 `CFRUNLOOP_WAKEUP_FOR_SOURCE();`  
14. **执行 block**: `__CFRunLoopDoBlocks(rl, rlm);`, 应该是上面的行为又有可能导致什么东西被扔进 block 中  
15. 最后根据执行结果修改 runloop 的状态(while 的依据 `while (0 == retVal);`)  

```c  
	if (sourceHandledThisLoop && stopAfterHandle) {  
	    retVal = kCFRunLoopRunHandledSource;  
        } else if (timeout_context->termTSR < mach_absolute_time()) {  
            retVal = kCFRunLoopRunTimedOut;  
	} else if (__CFRunLoopIsStopped(rl)) {  
            __CFRunLoopUnsetStopped(rl);  
	    retVal = kCFRunLoopRunStopped;  
	} else if (rlm->_stopped) {  
	    rlm->_stopped = false;  
	    retVal = kCFRunLoopRunStopped;  
	} else if (__CFRunLoopModeIsEmpty(rl, rlm, previousMode)) {  
	    retVal = kCFRunLoopRunFinished;  
	}  

```  