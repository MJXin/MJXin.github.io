---
title: 附录-OC源码-Runtime：探究 isa 的指向       
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
lightbox: true
pageview: true
tags: 源码解析 OC基石
coding: UTF-8
---  
![](/assets/images/源码解析/runtime/%E6%99%BA%E8%83%BD%E6%88%AA%E5%9B%BE%205.png)  
  
  
这篇没啥新的点, 主要是对已知的 isa 流程敲些代码做验证   
isa 具体是啥看这里: [其他: Tagged pointer 与 isa](https://mjxin.github.io/2020/07/01/OC%E5%9F%BA%E7%9F%B3-Runtime-%E9%99%84%E5%BD%95-TaggedPointer%E4%B8%8Eisa.html)  
isa 做了什么看这里: [三. runtime 的消息机制 - 作为全局查找索引的 `isa`](https://mjxin.github.io/2020/08/25/OC%E5%9F%BA%E7%9F%B3-Runtime-%E6%AD%A3%E6%96%873.html)  
  
下面这张图很常了(出自苹果官方文档,但是我回头找不到了)  
![](/assets/images/源码解析/runtime/23_7.png)  
  
这里我用下面的代码, 验证以上的过程:  
<a href='/assets/images/源码解析/runtime/NSObjectTest.zip'>NSObjectTest.zip</a>  
  
## 准备工作  
* 后面要注意区分**指针本身**的地址和**指针指向**的地址, 这是两基础概念, 但容易弄混  
* 指针的地址:              `&obj`  
* 指针的值\指针指向的地址:   `obj`, `&*obj`  
* 指针所指向的地址, 所存的值: `*obj`  
* 结构体的字段, 在其内部是按顺序分配的内存. 在输出结构体值时, 第一个字段如果刚好 8 字节, 其值就存放在**指向结构体**的指针所指向的地址  
* 我们知道`struct objc_object {isa_t isa}` 只有一个字段, isa, 并且 isa_t 刚好就是 8 个字节 [其他: Tagged pointer 与 isa](https://mjxin.github.io/2020/07/01/OC%E5%9F%BA%E7%9F%B3-Runtime-%E9%99%84%E5%BD%95-TaggedPointer%E4%B8%8Eisa.html)  
* 所以一个对象 objc, 是一个 `struct objc_object *` ([二. runtime 怎么实现封装](https://mjxin.github.io/2020/08/26/OC%E5%9F%BA%E7%9F%B3-Runtime-%E6%AD%A3%E6%96%872.html)), 其`所指向的地址` 的`前八个字节` 存的就是 `isa`   
* 其中 llvm 可以利用以下指令查看地址: [其他: 探究源码中的小工具]()  
  
所以我们看下面的源码:  
```objc  
 NSObject *obj = [[NSObject alloc] init];  
printf("\n ------------------------ 准备工作 ----------------------------\n");  
printf("  obj 是啥: [obj.description UTF8String] = %s\n",[obj.description UTF8String]);  
printf("  obj 地址: &obj = %p\n",&obj);  
printf("  obj 的值（指向的地址）: obj = %p\n",obj);  
printf("  *obj 的地址 (等同于 obj指向的地址) : &*obj = %p\n",&*(void **)(__bridge void*)obj);  
printf("  *obj 的值（obj指向的地址， 所存的值): *obj = %p\n",*(void **)(__bridge void*)obj);  
printf("  结论是， obj 第一个字段， 是个指向%p 的指针， 这个指针，指向 %p",&*(void **)(__bridge void*)obj, *(void **)(__bridge void*)obj);  
```  
  
## 探究过程  
### `class`: `obj.isa` 与 `[objc class]` 都指向其对象的类  
1. 先打出一个对象指针指向的地址**的值**, 然后再打出 objc.class 指向的地址  
2. 根据以前了解的 Tagged piointer([其他: Tagged pointer 与 isa](https://mjxin.github.io/2020/07/01/OC%E5%9F%BA%E7%9F%B3-Runtime-%E9%99%84%E5%BD%95-TaggedPointer%E4%B8%8Eisa.html)) 将第一个值 `& ISA_MASK`  
3. 得出结论, `obj.isa` 与 `objc.class` 的指向一直  
```objc  
//0x1dffff9730c119  
printf("  obj.isa = %p\n",*(void **)(__bridge void*)obj);  
//0x7fff9730c118  
printf("  obj.class (指向的地址）            = %p\n",obj.class);  
//0x7fff9730c118  
printf("  obj.isa  &  ISA_MASK             = %p\n",(void *)(objc_isa & 0x00007ffffffffff8ULL));  
```  
  
### `metaclass`:  `objc.isa.isa`  `*obj.class`  
1. 还是最前面的理论, `*obj.class` 指向等同于 `objc.class.isa` 等同于`obj.isa.isa`  
2. 上面的地址, 都为 `metaclass` 的地址  
没办法显式的找到可以显示 metaclass 的函数, 如果无法验证, 所以最终只能验证后面`metaclas 指向自己`  
```objc  
void * objClass = (void *)(objc_isa & 0x00007ffffffffff8ULL);  
unsigned long long int obj_isa_isa = *(unsigned long long int *)objClass;  
//*obj.class    = 0x7fff9730c0f0  
printf("  *obj.class    = %p\n",*(void **)(__bridge void*)obj.class);  
//objc.isa.isa  = 0x7fff9730c0f0  
printf("  obj.isa.isa  = %p\n",(void *)obj_isa_isa);  
//objc.isa.isa  ==  *obj.class   
printf("  obj.isa.isa  ==  *obj.class \n");  
```  
  
### `RootMetaClass` 最终指向 `RootMetaClass` 自己  
上面拿到了 `objc.class.isa` 根据理论, 他就是 `metaclass` 的地址, 所以我们只需要验证这个`metaClass`最终指向的是自己, 那么上面图中,最上面一环就做完了验证  
```objc  
void * objMetaClass = (void *)(obj_isa_isa & 0x00007ffffffffff8ULL);  
unsigned long long int obj_isa_isa_isa = *(unsigned long long int *)objMetaClass;  
// 0x7fff9730c0f0  
printf("  obj_isa_isa_isa & ISA_MASK                    = %p\n",obj_isa_isa_isa);  
// 0x7fff9730c0f0  
printf("  obj_isa_isa_isa & ISA_MASK                    = %p\n",(void *)(obj_isa_isa_isa & 0x00007ffffffffff8ULL));  
```  
  
  
整个流程比较绕, 具体代码中有很多注释, 执行插断点边打印着看会更清晰  
  