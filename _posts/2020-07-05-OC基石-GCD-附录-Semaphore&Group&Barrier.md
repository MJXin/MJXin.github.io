---
title: 附录-OC源码-GCD：GCD 函数源码 `semaphore` & `group` & `barrier`     
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
picture_frame: shadow
tags: 源码解析 OC基石
coding: UTF-8
---  
GCD 终于有容易读一点的代码了  
  
## `Semaphore`   
`Semaphore` 的数据结构我记在这一篇 [其他:GCD 的 `数据结构` 源码解析](bear://x-callback-url/open-note?id=217C6952-B9F6-4E2A-95F7-46474B0E6FF7-65647-000146F9FBC68795)  
其中两个字段 `dsema_value`, `dsema_orig` 就是信号量执行的关键  
  
### `dispatch_semaphore_create`   
创建比较简单, 就是对数据结构的字段赋值  
```objc  
dispatch_semaphore_t dispatch_semaphore_create(long value){  
  dispatch_semaphore_t dsema;  
  if (value < 0) { return DISPATCH_BAD_INPUT;}  
  dsema = _dispatch_object_alloc(DISPATCH_VTABLE(semaphore),  
      sizeof(struct dispatch_semaphore_s));  
  dsema->do_next = DISPATCH_OBJECT_LISTLESS;  
  dsema->do_targetq = _dispatch_get_default_queue(false);  
  dsema->dsema_value = value;  
  _dispatch_sema4_init(&dsema->dsema_sema, _DSEMA4_POLICY_FIFO);  
  dsema->dsema_orig = value;  
  return dsema;  
}  
```  
  
### `dispatch_semaphore_wait `  
`os_atomic_dec2o ` 最终递进到 `_os_atomic_c11_op((p), (v), m, sub, -)`, 然后执行汇编的函数,   
本质上是原子操作下的 dsema_value -1  
这里面是这几步:  
* dsema_value - 1  
* 判断当前值是否 >=0 (正常值), 如果是, 直接结束  
* 如果不是, 执行`_dispatch_semaphore_wait_slow` **这是 semaphore 能实现阻塞的原因**  
```objc  
long  
dispatch_semaphore_wait(dispatch_semaphore_t dsema, dispatch_time_t timeout){  
  long value = os_atomic_dec2o(dsema, dsema_value, acquire);  
  if (likely(value >= 0)) {  
    return 0;  
  }  
  return _dispatch_semaphore_wait_slow(dsema, timeout);  
}  
```  
`_dispatch_semaphore_wait_slow`  
内部主要是看超时的情况, 如果设置永不超时, 就会永久等待, 如果有设置超时, 那么在时间到了, 但是`dsema->dsema_value < 0`的情况就会执行 `Timeout`,需要注意的是,如果执行了`_dispatch_sema4_timedwait`, 那这个函数就不会立刻给返回值了**阻塞当前线程**  
```objc  
static long _dispatch_semaphore_wait_slow(dispatch_semaphore_t dsema, dispatch_time_t timeout){  
  _dispatch_sema4_create(&dsema->dsema_sema, _DSEMA4_POLICY_FIFO);  
  switch (timeout) {  
  default:  
    if (!_dispatch_sema4_timedwait(&dsema->dsema_sema, timeout)) {break; }  
  case DISPATCH_TIME_NOW:  
    orig = dsema->dsema_value;  
    while (orig < 0) {  
      if (os_atomic_cmpxchgvw2o(dsema, dsema_value, orig, orig + 1,  
          &orig, relaxed)) {  
        return _DSEMA4_TIMEOUT();  
      }  
    }  
  case DISPATCH_TIME_FOREVER:  
    _dispatch_sema4_wait(&dsema->dsema_sema);  
    break;  
  }  
  return 0;  
}  
```  
`_dispatch_sema4_wait ` & `_dispatch_sema4_timedwait` 都是休眠函数,里面是不满足条件就无法离开的循环  
```objc  
void _dispatch_sema4_wait(_dispatch_sema4_t *sema){  
  kern_return_t kr;  
  do {  
    kr = semaphore_wait(*sema);  
  } while (kr == KERN_ABORTED);  
  DISPATCH_SEMAPHORE_VERIFY_KR(kr);  
}  
```  
```objc  
bool _dispatch_sema4_timedwait(_dispatch_sema4_t *sema, dispatch_time_t timeout){  
  mach_timespec_t _timeout;  
  kern_return_t kr;  
  do {  
    uint64_t nsec = _dispatch_timeout(timeout);  
    _timeout.tv_sec = (__typeof__(_timeout.tv_sec))(nsec / NSEC_PER_SEC);  
    _timeout.tv_nsec = (__typeof__(_timeout.tv_nsec))(nsec % NSEC_PER_SEC);  
    kr = semaphore_timedwait(*sema, _timeout);  
  } while (unlikely(kr == KERN_ABORTED));  
  if (kr == KERN_OPERATION_TIMED_OUT) { return true; }  
  DISPATCH_SEMAPHORE_VERIFY_KR(kr);  
  return false;  
}  
```  

### `dispatch_semaphore_signal`  
与上面类似`os_atomic_inc2o` 追到最后其实是个+1 的逻辑  
```objc  
long dispatch_semaphore_signal(dispatch_semaphore_t dsema){  
  long value = os_atomic_inc2o(dsema, dsema_value, release);  
  if (likely(value > 0)) {  
    return 0;  
  }  
  if (unlikely(value == LONG_MIN)) {  
    DISPATCH_CLIENT_CRASH(value,  
        "Unbalanced call to dispatch_semaphore_signal()");  
  }  
  return _dispatch_semaphore_signal_slow(dsema);  
}  
```  
  
## `dispatch_group`  
看一些参考资料 `group` 是通过 `semaphore` 实现的, 但是我看的版本不是, `group` 有自己的控制字段  
### `dispatch_group_create`:   
具体数据结构也是在 [其他: 源码中使用的宏](bear://x-callback-url/open-note?id=47C4469A-E3E4-4A81-B258-5E6206F8F857-65647-00016933209B9646) 中,  create 内部是对基础数据结构的初始化  
<mark>其中`dg_bits` 在 group 使用中起控制作用的字段</mark>有些参考文章的老代码内部是 semaphore)  
```objc  
dispatch_group_t dispatch_group_create(void) {  
  return _dispatch_group_create_with_count(0);  
}  
static inline dispatch_group_t _dispatch_group_create_with_count(uint32_t n){  
  dispatch_group_t dg = _dispatch_object_alloc(DISPATCH_VTABLE(group),  
      sizeof(struct dispatch_group_s));  
  dg->do_next = DISPATCH_OBJECT_LISTLESS;  
  dg->do_targetq = _dispatch_get_default_queue(false);  
  if (n) {  
    os_atomic_store2o(dg, dg_bits,  
        (uint32_t)-n * DISPATCH_GROUP_VALUE_INTERVAL, relaxed);  
    os_atomic_store2o(dg, do_ref_cnt, 1, relaxed); // <rdar://22318411>  
  }  
  return dg;  
}  
```  
  
### `dispatch_group_enter `  
这是一个对 bit -1 的操作, -1 后根据当前的实际值, 做对应处理  
`_dispatch_retain`: 暂时还没  
```objc  
void dispatch_group_enter(dispatch_group_t dg){  
  uint32_t old_bits = os_atomic_sub_orig2o(dg, dg_bits,  
      DISPATCH_GROUP_VALUE_INTERVAL, acquire);  
  uint32_t old_value = old_bits & DISPATCH_GROUP_VALUE_MASK;  
  if (unlikely(old_value == 0)) { _dispatch_retain(dg); // <rdar://problem/22318411>}  
  if (unlikely(old_value == DISPATCH_GROUP_VALUE_MAX)) {  
    DISPATCH_CLIENT_CRASH(old_bits,  
        "Too many nested calls to dispatch_group_enter()");  
  }  
}  
```  
### `dispatch_group_leave `  
这一步处理的东西看起来不同, 从`dg_bits` 变成了`dg_state`.   
实际上联系我们的数据结构部分[其他: 源码中使用的宏](bear://x-callback-url/open-note?id=47C4469A-E3E4-4A81-B258-5E6206F8F857-65647-00016933209B9646)  
这是个联合体, 和理解为`dg_state` 是由 `dg_bits` 和`dg_gen`组成的  
这里的 dg_state `+`的操作和上面的`-`互相对应, 只是从字面上转个含义用于后面的对比  
```objc  
DISPATCH_UNION_LE(uint64_t volatile dg_state,  
      uint32_t dg_bits,  
      uint32_t dg_gen  
  ) DISPATCH_ATOMIC64_ALIGN;  
```  
后面的源码中涉及了太多宏标记, 很难完全理解其含义. 主要是在处理状态  
然后在状态合适时调用  `_dispatch_group_wake`, 结合我们调用的情况, 推测为 leave entry 刚好成对的时候  
```objc  
void dispatch_group_leave(dispatch_group_t dg){  
  
  uint64_t new_state, old_state = os_atomic_add_orig2o(dg, dg_state,  
      DISPATCH_GROUP_VALUE_INTERVAL, release);  
  uint32_t old_value = (uint32_t)(old_state & DISPATCH_GROUP_VALUE_MASK);  
  
  if (unlikely(old_value == DISPATCH_GROUP_VALUE_1)) {  
    old_state += DISPATCH_GROUP_VALUE_INTERVAL;  
    do {  
      new_state = old_state;  
      if ((old_state & DISPATCH_GROUP_VALUE_MASK) == 0) {  
        new_state &= ~DISPATCH_GROUP_HAS_WAITERS;  
        new_state &= ~DISPATCH_GROUP_HAS_NOTIFS;  
      } else {  
        new_state &= ~DISPATCH_GROUP_HAS_NOTIFS;  
      }  
      if (old_state == new_state) break;  
    } while (unlikely(!os_atomic_cmpxchgv2o(dg, dg_state,  
        old_state, new_state, &old_state, relaxed)));  
    return _dispatch_group_wake(dg, old_state, true);  
  }  
  
  if (unlikely(old_value == 0)) {  
    DISPATCH_CLIENT_CRASH((uintptr_t)old_value,  
        "Unbalanced call to dispatch_group_leave()");  
  }  
}  
```  
### `_dispatch_group_wake`  
这部分开始就是 group 都执行完, 在调用 notify 的流程  
显示声明几个变量,联系我们的数据结构[其他: 源码中使用的宏](bear://x-callback-url/open-note?id=47C4469A-E3E4-4A81-B258-5E6206F8F857-65647-00016933209B9646)(里面用到链表节点, 和 group 特有的 notify 节点)  
这里就是将 group 存着的通知链表拿出来. 然后逐个执行  
```objc  
static void _dispatch_group_wake(dispatch_group_t dg, uint64_t dg_state, bool needs_release){  
	//省略了很多代码  
	dc = os_mpsc_capture_snapshot(os_mpsc(dg, dg_notify), &tail);  
	do {  
	  dispatch_queue_t dsn_queue = (dispatch_queue_t)dc->dc_data;  
	  next_dc = os_mpsc_pop_snapshot_head(dc, tail, do_next);  
	  _dispatch_continuation_async(dsn_queue, dc,  
	      _dispatch_qos_from_pp(dc->dc_priority), dc->dc_flags);  
	  _dispatch_release(dsn_queue);  
	} while ((dc = next_dc));  
	  
	refs++;  
}  
```  
### `dispatch_group_async`  
可以看到 `dispatch_group_async` 简化的流程是  
1. 调用`dispatch_group_enter`  
2. 将入参的 block 封装,然后 push 放到待执行队列中  
3. 从这个流程开始, 与`dispatch_group_async`没关系, 后面是在执行过程中,某个时机调度了 `_dispatch_continuation_with_group_invoke`  
4. `_dispatch_continuation_with_group_invoke` 除了执行函数外, 还会执行一次 leave 

```objc  
void dispatch_group_async(dispatch_group_t dg, dispatch_queue_t dq, dispatch_block_t db){  
//省略一些代码  
  _dispatch_continuation_group_async(dg, dq, dc, qos);  
}  
static inline void _dispatch_continuation_group_async(dispatch_group_t dg, dispatch_queue_t dq,  
    dispatch_continuation_t dc, dispatch_qos_t qos){  
  dispatch_group_enter(dg);  
  dc->dc_data = dg;  
  _dispatch_continuation_async(dq, dc, qos, dc->dc_flags);  
}  
  
static inline void _dispatch_continuation_async(dispatch_queue_class_t dqu,  
    dispatch_continuation_t dc, dispatch_qos_t qos, uintptr_t dc_flags){  
#if DISPATCH_INTROSPECTION  
  if (!(dc_flags & DC_FLAG_NO_INTROSPECTION)) {  
    _dispatch_trace_item_push(dqu, dc);  
  }  
#else  
  (void)dc_flags;  
#endif  
  return dx_push(dqu._dq, dc, qos);  
}  
```  
  
```objc  
static inline void _dispatch_continuation_with_group_invoke(dispatch_continuation_t dc){  
	// 判断执行类型  
  if (type == DISPATCH_GROUP_TYPE) {  
    _dispatch_client_callout(dc->dc_ctxt, dc->dc_func);  
    _dispatch_trace_item_complete(dc);  
    dispatch_group_leave((dispatch_group_t)dou);  
  }  
//...省略部分代码  
}  
  
```  
  
### `dispatch_group_notify`  
* 封装入参 db  
* 将传入的函数体 push 到链表中. 然后视情况调用 `_dispatch_group_wake`  

```objc  
void dispatch_group_notify(dispatch_group_t dg, dispatch_queue_t dq, dispatch_block_t db){  
  dispatch_continuation_t dsn = _dispatch_continuation_alloc();  
  _dispatch_continuation_init(dsn, dq, db, 0, DC_FLAG_CONSUME);  
  _dispatch_group_notify(dg, dq, dsn);  
}  
static inline void _dispatch_group_notify(dispatch_group_t dg, dispatch_queue_t dq,  
    dispatch_continuation_t dsn){  
  uint64_t old_state, new_state;  
  dispatch_continuation_t prev;  
  
  dsn->dc_data = dq;  
  _dispatch_retain(dq);  
  
  prev = os_mpsc_push_update_tail(os_mpsc(dg, dg_notify), dsn, do_next);  
  if (os_mpsc_push_was_empty(prev)) _dispatch_retain(dg);  
  os_mpsc_push_update_prev(os_mpsc(dg, dg_notify), prev, dsn, do_next);  
  if (os_mpsc_push_was_empty(prev)) {  
    os_atomic_rmw_loop2o(dg, dg_state, old_state, new_state, release, {  
      new_state = old_state | DISPATCH_GROUP_HAS_NOTIFS;  
      if ((uint32_t)old_state == 0) {  
        os_atomic_rmw_loop_give_up({  
          return _dispatch_group_wake(dg, new_state, false);  
        });  
      }  
    });  
  }  
}  
```  
  
## `dispatch_barrier_async`  
栅栏函数, 本质实现超级简单, 就是调用一个 push  
关键地方在于 push 时传入的参数, 正在起到 barrier 作用的是执行函数根据参数处理的  
```objc  
void dispatch_barrier_async(dispatch_queue_t dq, dispatch_block_t work){  
  dispatch_continuation_t dc = _dispatch_continuation_alloc();  
  uintptr_t dc_flags = DC_FLAG_CONSUME | DC_FLAG_BARRIER;  
  dispatch_qos_t qos;  
  
  qos = _dispatch_continuation_init(dc, dq, work, 0, dc_flags);  
  _dispatch_continuation_async(dq, dc, qos, dc_flags);  
}  
// 内部就一个 push 函数  
static inline void _dispatch_continuation_async(dispatch_queue_class_t dqu,  
    dispatch_continuation_t dc, dispatch_qos_t qos, uintptr_t dc_flags) {  
#if DISPATCH_INTROSPECTION  
  if (!(dc_flags & DC_FLAG_NO_INTROSPECTION)) {  
    _dispatch_trace_item_push(dqu, dc);  
  }  
#else  
  (void)dc_flags;  
#endif  
  return dx_push(dqu._dq, dc, qos);  
}  
```  