---
title: 附录-OC源码-GCD：GCD 中 isa 中有什么     
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
lightbox: true
pageview: true
tags: 源码解析 OC基石
coding: UTF-8
--- 
> 代码中见到的: `do_type`, `do_kind`, `do_dispose`, `do_invoke`, `do_probe`, `do_debug`    
> 都从这来    
  
通过前文逐个基本数据结构拆开, 里面都有这个宏链:  
`DISPATCH_OBJECT_HEADER` -> `_DISPATCH_OBJECT_HEADER` -> `OS_OBJECT_STRUCT_HEADER` -> `_OS_OBJECT_HEADER`  
  
最终是`_OS_OBJECT_HEADER`宏  
```objc  
//const struct x##_vtable_s *do_vtable  
#define _OS_OBJECT_HEADER(isa, ref_cnt, xref_cnt) \  
        isa; /* must be pointer-sized */ \  
        int volatile ref_cnt; \  
        int volatile xref_cnt  
```  
(`ref_cnt`, `xref_cnt`引用计数用, 没有细究)  
这个宏在各个数据结构中, 展开后, isa 为  
`const struct dispatch_object_vtable_s *do_vtable`  
`const struct dispatch_source_vtable_s *do_vtable`  
`const struct dispatch_queue_vtable_s *do_vtable`  
`const struct dispatch_semaphore_vtable_s *do_vtable`  
`const struct dispatch_group_vtable_s *do_vtable`  
  
那这个 `dispatch_XX_vtable_s` 是啥? 从 C++风格来看, 这名字通常是虚函数表  
可以找到`inti.c`文件中有定义, 都是一个使用 `DISPATCH_VTABLE_INSTANCE`的结构  
<a href='/assets/images/源码解析/GCD/init.c'>init.c</a>  
  
```objc  
#define DISPATCH_VTABLE_INSTANCE(name, ...) \  
    DISPATCH_VTABLE_SUBCLASS_INSTANCE(name, name, __VA_ARGS__)  
  
#define DISPATCH_VTABLE_SUBCLASS_INSTANCE(name, ctype, ...) \  
    OS_OBJECT_VTABLE_SUBCLASS_INSTANCE(dispatch_##name, dispatch_##ctype, \  
        _dispatch_xref_dispose, _dispatch_dispose, __VA_ARGS__)  
  
#define OS_OBJECT_VTABLE_SUBCLASS_INSTANCE(name, ctype, xdispose, dispose, ...) \  
    __attribute__((section("__DATA,__objc_data"), used)) \  
    const struct ctype##_extra_vtable_s \  
    OS_OBJECT_EXTRA_VTABLE_SYMBOL(name) = { __VA_ARGS__ }  
  
#define OS_OBJECT_EXTRA_VTABLE_SYMBOL(name) _OS_##name##_vtable  
```  
  
从数据结构上看, 其实基本可以理解为这个 isa 的用法和 runtime isa 用法一致, 都是指向其包含一些字段的另一个结构体.  
(object isa 指向其 class, class 指向其 metaclass)  
而其中的字段含义,从源码看大致如下(直接源码中搜等号后面):  
* `do_type`:  类型, 对应的是一个 enum, 描述在 `DISPATCH_OPTIONS`  
* `do_dispose` :deallocated 函数  
* `do_debug`   :print 函数  
* `do_invoke`  : 调用函数  
  
其中全局队列`Global`,`Main`的初始化, 都会用到 [`DISPATCH_GLOBAL_OBJECT_HEADER`](https://mjxin.github.io/2020/07/05/OC%E5%9F%BA%E7%9F%B3-GCD-%E9%99%84%E5%BD%95-%E6%BA%90%E7%A0%81%E4%B8%AD%E4%BD%BF%E7%94%A8%E7%9A%84%E5%AE%8F.html#dispatch_global_object_header-%E5%9C%A8-global-main-queue-%E5%88%9D%E5%A7%8B%E5%8C%96%E6%97%B6%E5%B8%B8%E8%A7%81)  
  
```objc  
DISPATCH_VTABLE_INSTANCE(semaphore,  
  .do_type        = DISPATCH_SEMAPHORE_TYPE,  
  .do_dispose     = _dispatch_semaphore_dispose,  
  .do_debug       = _dispatch_semaphore_debug,  
  .do_invoke      = _dispatch_object_no_invoke,  
);  
  
DISPATCH_VTABLE_INSTANCE(group,  
  .do_type        = DISPATCH_GROUP_TYPE,  
  .do_dispose     = _dispatch_group_dispose,  
  .do_debug       = _dispatch_group_debug,  
  .do_invoke      = _dispatch_object_no_invoke,  
);  
  
#if !DISPATCH_DATA_IS_BRIDGED_TO_NSDATA  
DISPATCH_VTABLE_INSTANCE(data,  
  .do_type        = DISPATCH_DATA_TYPE,  
  .do_dispose     = _dispatch_data_dispose,  
  .do_debug       = _dispatch_data_debug,  
  .do_invoke      = _dispatch_object_no_invoke,  
);  
#endif  
  
DISPATCH_VTABLE_INSTANCE(queue_attr,  
  .do_type        = DISPATCH_QUEUE_ATTR_TYPE,  
  .do_dispose     = _dispatch_object_no_dispose,  
  .do_debug       = _dispatch_object_missing_debug,  
  .do_invoke      = _dispatch_object_no_invoke,  
);  
  
#if HAVE_MACH  
DISPATCH_VTABLE_INSTANCE(mach_msg,  
  .do_type        = DISPATCH_MACH_MSG_TYPE,  
  .do_dispose     = _dispatch_mach_msg_dispose,  
  .do_debug       = _dispatch_mach_msg_debug,  
  .do_invoke      = _dispatch_mach_msg_invoke,  
);  
#endif // HAVE_MACH  
  
DISPATCH_VTABLE_INSTANCE(io,  
  .do_type        = DISPATCH_IO_TYPE,  
  .do_dispose     = _dispatch_io_dispose,  
  .do_debug       = _dispatch_io_debug,  
  .do_invoke      = _dispatch_object_no_invoke,  
);  
  
DISPATCH_VTABLE_INSTANCE(operation,  
  .do_type        = DISPATCH_OPERATION_TYPE,  
  .do_dispose     = _dispatch_operation_dispose,  
  .do_debug       = _dispatch_operation_debug,  
  .do_invoke      = _dispatch_object_no_invoke,  
);  
  
DISPATCH_VTABLE_INSTANCE(disk,  
  .do_type        = DISPATCH_DISK_TYPE,  
  .do_dispose     = _dispatch_disk_dispose,  
  .do_debug       = _dispatch_object_missing_debug,  
  .do_invoke      = _dispatch_object_no_invoke,  
);  
DISPATCH_VTABLE_INSTANCE(queue,  
  // This is the base class for queues, no objects of this type are made  
  .do_type        = _DISPATCH_QUEUE_CLUSTER,  
  .do_dispose     = _dispatch_object_no_dispose,  
  .do_debug       = _dispatch_queue_debug,  
  .do_invoke      = _dispatch_object_no_invoke,  
  
  .dq_activate    = _dispatch_queue_no_activate,  
);  
  
DISPATCH_VTABLE_INSTANCE(workloop,  
  .do_type        = DISPATCH_WORKLOOP_TYPE,  
  .do_dispose     = _dispatch_workloop_dispose,  
  .do_debug       = _dispatch_queue_debug,  
  .do_invoke      = _dispatch_workloop_invoke,  
  
  .dq_activate    = _dispatch_queue_no_activate,  
  .dq_wakeup      = _dispatch_workloop_wakeup,  
  .dq_push        = _dispatch_workloop_push,  
);  
  
DISPATCH_VTABLE_SUBCLASS_INSTANCE(queue_serial, lane,  
  .do_type        = DISPATCH_QUEUE_SERIAL_TYPE,  
  .do_dispose     = _dispatch_lane_dispose,  
  .do_debug       = _dispatch_queue_debug,  
  .do_invoke      = _dispatch_lane_invoke,  
  
  .dq_activate    = _dispatch_lane_activate,  
  .dq_wakeup      = _dispatch_lane_wakeup,  
  .dq_push        = _dispatch_lane_push,  
);  
  
DISPATCH_VTABLE_SUBCLASS_INSTANCE(queue_concurrent, lane,  
  .do_type        = DISPATCH_QUEUE_CONCURRENT_TYPE,  
  .do_dispose     = _dispatch_lane_dispose,  
  .do_debug       = _dispatch_queue_debug,  
  .do_invoke      = _dispatch_lane_invoke,  
  
  .dq_activate    = _dispatch_lane_activate,  
  .dq_wakeup      = _dispatch_lane_wakeup,  
  .dq_push        = _dispatch_lane_concurrent_push,  
);  
  
DISPATCH_VTABLE_SUBCLASS_INSTANCE(queue_global, lane,  
  .do_type        = DISPATCH_QUEUE_GLOBAL_ROOT_TYPE,  
  .do_dispose     = _dispatch_object_no_dispose,  
  .do_debug       = _dispatch_queue_debug,  
  .do_invoke      = _dispatch_object_no_invoke,  
  
  .dq_activate    = _dispatch_queue_no_activate,  
  .dq_wakeup      = _dispatch_root_queue_wakeup,  
  .dq_push        = _dispatch_root_queue_push,  
);  
  
#if DISPATCH_USE_PTHREAD_ROOT_QUEUES  
DISPATCH_VTABLE_SUBCLASS_INSTANCE(queue_pthread_root, lane,  
  .do_type        = DISPATCH_QUEUE_PTHREAD_ROOT_TYPE,  
  .do_dispose     = _dispatch_pthread_root_queue_dispose,  
  .do_debug       = _dispatch_queue_debug,  
  .do_invoke      = _dispatch_object_no_invoke,  
  
  .dq_activate    = _dispatch_queue_no_activate,  
  .dq_wakeup      = _dispatch_root_queue_wakeup,  
  .dq_push        = _dispatch_root_queue_push,  
);  
#endif // DISPATCH_USE_PTHREAD_ROOT_QUEUES  
  
DISPATCH_VTABLE_SUBCLASS_INSTANCE(queue_mgr, lane,  
  .do_type        = DISPATCH_QUEUE_MGR_TYPE,  
  .do_dispose     = _dispatch_object_no_dispose,  
  .do_debug       = _dispatch_queue_debug,  
#if DISPATCH_USE_MGR_THREAD  
  .do_invoke      = _dispatch_mgr_thread,  
#else  
  .do_invoke      = _dispatch_object_no_invoke,  
#endif  
  
  .dq_activate    = _dispatch_queue_no_activate,  
  .dq_wakeup      = _dispatch_mgr_queue_wakeup,  
  .dq_push        = _dispatch_mgr_queue_push,  
);  
  
DISPATCH_VTABLE_SUBCLASS_INSTANCE(queue_main, lane,  
  .do_type        = DISPATCH_QUEUE_MAIN_TYPE,  
  .do_dispose     = _dispatch_lane_dispose,  
  .do_debug       = _dispatch_queue_debug,  
  .do_invoke      = _dispatch_lane_invoke,  
  
  .dq_activate    = _dispatch_queue_no_activate,  
  .dq_wakeup      = _dispatch_main_queue_wakeup,  
  .dq_push        = _dispatch_main_queue_push,  
);  
  
#if DISPATCH_COCOA_COMPAT  
DISPATCH_VTABLE_SUBCLASS_INSTANCE(queue_runloop, lane,  
  .do_type        = DISPATCH_QUEUE_RUNLOOP_TYPE,  
  .do_dispose     = _dispatch_runloop_queue_dispose,  
  .do_debug       = _dispatch_queue_debug,  
  .do_invoke      = _dispatch_lane_invoke,  
  
  .dq_activate    = _dispatch_queue_no_activate,  
  .dq_wakeup      = _dispatch_runloop_queue_wakeup,  
  .dq_push        = _dispatch_lane_push,  
);  
#endif  
  
DISPATCH_VTABLE_INSTANCE(source,  
  .do_type        = DISPATCH_SOURCE_KEVENT_TYPE,  
  .do_dispose     = _dispatch_source_dispose,  
  .do_debug       = _dispatch_source_debug,  
  .do_invoke      = _dispatch_source_invoke,  
  
  .dq_activate    = _dispatch_source_activate,  
  .dq_wakeup      = _dispatch_source_wakeup,  
  .dq_push        = _dispatch_lane_push,  
);  
  
DISPATCH_VTABLE_INSTANCE(channel,  
  .do_type        = DISPATCH_CHANNEL_TYPE,  
  .do_dispose     = _dispatch_channel_dispose,  
  .do_debug       = _dispatch_channel_debug,  
  .do_invoke      = _dispatch_channel_invoke,  
  
  .dq_activate    = _dispatch_lane_activate,  
  .dq_wakeup      = _dispatch_channel_wakeup,  
  .dq_push        = _dispatch_lane_push,  
);  
  
#if HAVE_MACH  
DISPATCH_VTABLE_INSTANCE(mach,  
  .do_type        = DISPATCH_MACH_CHANNEL_TYPE,  
  .do_dispose     = _dispatch_mach_dispose,  
  .do_debug       = _dispatch_mach_debug,  
  .do_invoke      = _dispatch_mach_invoke,  
  
  .dq_activate    = _dispatch_mach_activate,  
  .dq_wakeup      = _dispatch_mach_wakeup,  
  .dq_push        = _dispatch_lane_push,  
);  
#endif // HAVE_MACH  
```  