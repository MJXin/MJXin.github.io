---
title: 附录-OC源码-GCD：GCD 函数源码 `dispatch_once`     
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
lightbox: true
pageview: true
tags: 源码解析 OC基石
coding: UTF-8
---  

> 参考文章: [iOS 多线程（GCD源码分析）](https://juejin.im/post/6844904055655890952)    
  
## 基础  
`os_atomic_cmpxchg`:  追到底层发现是汇编, 看着吃力采用参考文章说法  
> 首先它是原子操作, 包含了判断, 和修改    
> 第二个参数与第一个参数值比较    
>   如果相等, 将第三个参数, 设到第二个参数中, 返回 true    
>   如果不相等, 啥都不干, 返回 false    
  
`os_atomic_xchg`  
  
## `dispatch_once`  
看点就一个 — <mark>怎么做到在多线程中只执行一次</mark>  
先看入参 :  
* `dispatch_once_t *val`, 一个很单纯的整型指针~  
* `dispatch_function_t`, 一个函数指针  
```objc  
typedef intptr_t dispatch_once_t;  
typedef void (*dispatch_function_t)(void *_Nullable);  
```  
  
整个函数主要分成 4 个部分:  
0. 使用`os_atomic_load`拿到状态值 (可惜的是这个值被引申到汇编里面去了)  
1. 判断是否已经执行过, 是则结束  
2. 判断是否处理中, 如果是执行 `_dispatch_once_mark_done_if_quiesced`  
3. 判断是否可以执行, 是则执行 `_dispatch_once_callout`  
4. 都为否(既没有执行过, 也不是执行中, 也无法进入执行), 则调用 `_dispatch_once_wait`  
  
从上面的步骤看, once 执行一次的关键点就在于 `os_atomic_load` 拿到的这个状态值  
```objc  
void dispatch_once_f(dispatch_once_t *val, void *ctxt, dispatch_function_t func){  
	dispatch_once_gate_t l = (dispatch_once_gate_t)val;  
 //读出当前的状态  
	uintptr_t v = os_atomic_load(&l->dgo_once, acquire);  
	if (likely(v == DLOCK_ONCE_DONE)) {  
		return;  
	}  
	if (likely(DISPATCH_ONCE_IS_GEN(v))) {  
		return _dispatch_once_mark_done_if_quiesced(l, v);  
	}  
	if (_dispatch_once_gate_tryenter(l)) {  
		return _dispatch_once_callout(l, ctxt, func);  
	}  
	return _dispatch_once_wait(l);  
}  
```  
### 1. 状态判断, DLOCK_ONCE_DONE 直接跳出  
### 2. 生成判断  
`DISPATCH_ONCE_IS_GEN` 内部是一个与操作, 不细看, 主要是`_dispatch_once_mark_done_if_quiesced` 函数  
可以理解为,这一步直接将 DLOCK_ONCE_DONE 存入了入参 dgo 中  
❓ 这一步其实没有特别看明白, `_dispatch_once_generation` 内部是在做位运算, 然后得出的值 - gen. 这些值的含义不明白  
```objc  
static inline void _dispatch_once_mark_done_if_quiesced(dispatch_once_gate_t dgo, uintptr_t gen){  
  if (_dispatch_once_generation() - gen >= DISPATCH_ONCE_GEN_SAFE_DELTA)  
    os_atomic_store(&dgo->dgo_once, DLOCK_ONCE_DONE, relaxed);  
}  
```  
### 3.执行部分  
先看判断部分
#### `_dispatch_once_gate_tryenter`  
宏的定义在最上面:  
1. 判断`&l->dgo_once` 是否为 DLOCK_ONCE_UNLOCKED, 若是, 改为`_dispatch_lock_value_for_self`(记住这个值,后面有用)  
2. 若不是, 返回 fasle,就无法往下执行  
这一步执行成功后 `&l->dgo_once` 就变为了`_dispatch_lock_value_for_self `  
```objc  
static inline bool _dispatch_once_gate_tryenter(dispatch_once_gate_t l){  
  return os_atomic_cmpxchg(&l->dgo_once, DLOCK_ONCE_UNLOCKED, (uintptr_t)_dispatch_lock_value_for_self(), relaxed);  
}  
```  
上一步 true 的情况下, 走到核心执行函数 `_dispatch_once_callout `, 共两步  
1. **拿到一个函数指针(入参那个), 并执行**  
2. 调用 `_dispatch_once_gate_broadcast`  

```objc  
static inline void _dispatch_client_callout(void *ctxt, dispatch_function_t f)  
{ return f(ctxt); }  
  
void _dispatch_once_callout(dispatch_once_gate_t l, void *ctxt, dispatch_function_t func){  
  _dispatch_client_callout(ctxt, func);  
  _dispatch_once_gate_broadcast(l);  
}  
```  
  
#### `_dispatch_once_gate_broadcast`:   
```objc  
static inline void _dispatch_once_gate_broadcast(dispatch_once_gate_t l){  
  dispatch_lock value_self = _dispatch_lock_value_for_self();  
  //..  
}  
```  
其中调用的第一个函数, `_dispatch_lock_value_for_self`(就是上面赋值时用的那个)  从源码最终追溯到  
`pthread_getspecific`: 因为没有开源, 从字面意思理解为  **取出一个特定的线程,返回值是 id**  
  
这个取线程操作入参是固定的`_PTHREAD_TSD_SLOT_MACH_THREAD_SELF`由此可以得出返回值也固  
**无论哪里调用的 dispatch_once, 最终都取出同一个线程**  
然后用将这个线程 ID 位与 (改变其中一些 bit), 获取当前的状态标记  
**小知识点: pthread 线程是在 tid 的部分 bit 上记了些状态数据**  
(参考之前研究的 runtime 源码[Tagged pointer](https://mjxin.github.io/2020/07/01/OC%E5%9F%BA%E7%9F%B3-Runtime-%E9%99%84%E5%BD%95-TaggedPointer%E4%B8%8Eisa.html)类似用法, 部分 bit 用作存 id,部分用于其他标记)  
```objc  
// _dispatch_lock_value_for_self 是取 tid, 并位与拿到一个值  
static inline dispatch_lock _dispatch_lock_value_for_self(void) {  
  return _dispatch_lock_value_from_tid(_dispatch_tid_self());  
}  
// 位与操作  
dispatch_lock _dispatch_lock_value_from_tid(dispatch_tid tid){  
  return tid & DLOCK_OWNER_MASK;  
}  
// 外面位与操作拿 tid 的函数  
#define _dispatch_tid_self()    ((dispatch_tid)_dispatch_thread_port())  
// _dispatch_thread_port 入参永远为 _PTHREAD_TSD_SLOT_MACH_THREAD_SELF  
#define _dispatch_thread_port() ((mach_port_t)(uintptr_t) _dispatch_thread_getspecific(_PTHREAD_TSD_SLOT_MACH_THREAD_SELF))  
// 获取指定线程操作  
static inline void * _dispatch_thread_getspecific(pthread_key_t k){  
	// 省略部分代码  
  return pthread_getspecific(k);  
}  
//没有开源的找线程  
void* _Nullable pthread_getspecific(pthread_key_t);  
```  
  
所以`_dispatch_once_gate_broadcast`   
1. 拿个线程的 tip 出来, 然后读他的状态  
2. 设置一个变量 v, 改状态   
```objc  
static inline void _dispatch_once_gate_broadcast(dispatch_once_gate_t l){  
  dispatch_lock value_self = _dispatch_lock_value_for_self();  
  uintptr_t v;  
#if DISPATCH_ONCE_USE_QUIESCENT_COUNTER  
  v = _dispatch_once_mark_quiescing(l);  
#else  
  v = _dispatch_once_mark_done(l);  
#endif  
  if (likely((dispatch_lock)v == value_self)) return;  
  _dispatch_gate_broadcast_slow(&l->dgo_gate, (dispatch_lock)v);  
}  
```  
  
其实整篇看下来, 似懂非懂,  
核心在与: **用 os_atomic_cmpxchg 原子比较 + 原子修改状态**, 其保证了比较和修改状态时, 外界没法进入判断中  
  
入参的 dispatch_once_t 状态被改了从而使他只能执行一次  
遗憾的是, 状态修改的代码大部分在汇编中, _dispatch_once_mark_quiescing 具体的含义没弄清楚  
