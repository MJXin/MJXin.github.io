---
title: OC基石 -- Runtime 附录：id,SEL 等关键字及其含义     
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
picture_frame: shadow
tags: 源码解析 OC基石
coding: UTF-8
---   
## id  
`typedef struct objc_object *id;`  
没啥好说的就 objc_object 结构体的别名  
同样是结构体 objc_object 别的的还有关键字 `NSObject`等各种自定义的类  
(ps. 这里不是指 `NSObject` 等类是 `struct objc_object`, 要时刻注意 OC 类名这个概念与编译后 C 不一样. `NSObject` 这里指的是 `NSObject *obj`时, obj 的本质, 一个 struct objc_object)  
所以 id 可以指代某个对象的类型, NSObject 也可以, 各种子类也可以, 因为都是`struct objc_object`  
```c++  
struct objc_object {  
private:  
    isa_t isa;  
    /*...  
      isa操作相关  
      弱引用相关  
      关联对象相关  
      内存管理相关  
      ...  
     */  
};  
```  
  
## SEL  
`typedef struct objc_selector *SEL`  
SEL 在 runtime 源码中是 `struct objc_selecor *`, 但是 `struct objc_selecor`的定义在源码中没有  
clane 编译后的代码也没有, 只能通过别的办法找到  
* 官方文档: [Selector](https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-CocoaCore/Selector.html)  
官方文档提供的说明是, 这个玩意其实没干啥, 唯一的目的就是给函数提供一个 **唯一标识符**  
结合 runtime, 我们知道, 所有的类中函数, 都是以全局函数的方式写在代码中的. 并且为了延迟绑定, 需要为这些函数提供一个查找凭据.  
这个凭据就是一个字符串.  
所以实际上 `SEL` 是一个字符串指针, 作为唯一标识符用, 提供给 runtime 查找函数  
```objc  
SEL sel = @selector(testFunction);  
NSLog(@"sel %s",sel);  
```  
不同类调用相同的 SEL 会触发各自不同的函数  
```objc  
 SEL sel = @selector(testFunction);  
[test performSelector:sel]; //TestFunction  
[subTest performSelector:sel]; //SubtestFunction  
```  
* strack overflow:   
<mark>but what the heck is an objc_selector? Well, it’s defined differently depending on if you’re using the GNU Objective-C runtime, or the NeXT Objective-C Runtime (like Mac OS X).</mark>  
* [objective c - How do SEL and @selector work? - Stack Overflow](https://stackoverflow.com/questions/19322264/how-do-sel-and-selector-work)  
* [ios - What is the objc_selector implementation? - Stack Overflow](https://stackoverflow.com/questions/28581489/what-is-the-objc-selector-implementation)  
