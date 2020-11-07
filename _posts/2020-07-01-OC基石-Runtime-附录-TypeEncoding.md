---
title: 附录-OC源码-Runtime：Type Encodings   
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
lightbox: true
pageview: true
tags: 源码解析 OC基石
coding: UTF-8
--- 
> 官方文档: [Type Encodings](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html)    
本质上就是一个把返回值, 入参, 入参地址,入参大小. 用缩写, 描述成字符串的实现  
我们编译一个类的函数后, 会见到  
<a href='/assets/images/源码解析/runtime/Test.cpp'>Test.cpp</a>  
具体结构体分析见:  [其他: Clang 编译后的数据结构分析](bear://x-callback-url/open-note?id=1125C902-A4C7-4C62-99D8-18E96362C11F-483-0000B1D6DB95754C)  

```objc  
  
struct _objc_method {  
  struct objc_selector * _cmd;  
  const char *method_type;  
  void  *_imp;  
}  
  
static struct /*_method_list_t*/ {  
  unsigned int entsize;  // sizeof(struct _objc_method)  
  unsigned int method_count;  
  struct _objc_method method_list[1];  
} _OBJC_$_CLASS_METHODS_Test __attribute__ ((used, section ("__DATA,__objc_const"))) = {  
  sizeof(_objc_method),  
  1,  
  {
    {(struct objc_selector *)"testClassFunction", "v16@0:8", (void *)_C_Test_testClassFunction}}  
};  
  
```  
代码中: `_objc_method` 的 `method_type` 被赋值了`v16@0:8`  
这个 `v16@0:8` 就是 Type Encodings  
  
他的每一个字符都有自己的含义, 用以描述函数的信息, 例如:   
* `v` : 返回值类型, 这里是 `void`  
* `16`: 所有参数的总字符数   
* `@` : 第一个参数的类型, 这里是 id  
* `0` : 第一个参数从第几位开始  
* `:` : 第二个参数的类型, 这里是 SEL  
* `8` : 第二个参数从第几位开始  
  
具体含义见官方文档: [Type Encodings](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html)  
![](/assets/images/源码解析/runtime/8D07C818-61CD-4F13-86DB-B841B3CC6DC1.png)  
