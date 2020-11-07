---
title: 附录-OC源码-Runtime：Runtime 源码索引       
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
lightbox: true
pageview: true
tags: 源码解析 OC基石
coding: UTF-8
---  
* 上源码: [Source Browser](https://opensource.apple.com/tarballs/objc4/)  
<a href='/assets/images/源码解析/runtime/objc4-781.tar'>objc4-781.tar</a>    
  
* `struct objc_object`: `objc-private.h`  
<a href='/assets/images/源码解析/runtime/objc-private.h'>objc-private.h</a>    
  
* `union isa_t`:  
<a href='/assets/images/源码解析/runtime/objc-private%202.h'>objc-private 2.h</a>  
<a href='/assets/images/源码解析/runtime/isa.h'>isa.h</a>    
  
* `struct objc_class`: 新版 `objc-runtime-new`, 旧版 `objc-runtime-old`  
<a href='/assets/images/源码解析/runtime/objc-runtime-new.h'>objc-runtime-new.h</a>  
<a href='/assets/images/源码解析/runtime/objc-runtime-new.mm'>objc-runtime-new.mm</a>  
<a href='/assets/images/源码解析/runtime/objc-runtime-old.h'>objc-runtime-old.h</a>  
<a href='/assets/images/源码解析/runtime/objc-runtime-old.mm'>objc-runtime-old.mm</a>    
  
* `objc_msgSend`: 汇编中实现, 手机是`objc-msg-arm64.s`  
<a href='/assets/images/源码解析/runtime/objc-msg-arm64.s'>objc-msg-arm64.s</a> 
 <a href='/assets/images/源码解析/runtime/objc-msg-x86_64.s'>objc-msg-x86_64.s</a>    
  
* `_lookUpImpOrForward`: 函数表查找 IMP 流程  
<a href='/assets/images/源码解析/runtime/objc-runtime-new%202.mm'>objc-runtime-new 2.mm</a>    
  
* `resolveClassMethod` & `resolveInstanceMethod`: 动态解析流程  
<a href='/assets/images/源码解析/runtime/objc-runtime-new%203.mm'>objc-runtime-new 3.mm</a>    
  
* `forwardingTargetForSelector` & `methodSignatureForSelector`: 消息转发流程  
<a href='/assets/images/源码解析/runtime/NSObject.h'>NSObject.h</a>  
<a href='/assets/images/源码解析/runtime/NSObject.mm'>NSObject.mm</a>    