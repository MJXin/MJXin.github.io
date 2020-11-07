---
title: 附录-OC源码-Runtime：Clang 编译后的数据结构分析       
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
lightbox: true
pageview: true
tags: 源码解析 OC基石
coding: UTF-8
---  

很多文章以不同的概念告诉我  
objc_class, objc_object 与 NSObject 的关系, 这反而使我混乱了  
先抛开他, 那可能被略过了细节, 或者是错的.  
  
这里定义一个新类, 继承于 NSObject. clang 执行. 看结果  
<a href='/assets/images/源码解析/runtime//Test.m'>Test.m</a><a href='/assets/images/源码解析/runtime//Test.h'>Test.h</a>  
  
`clang -rewrite-objc Test.m -o Test.cpp`  
<a href='/assets/images/源码解析/runtime//Test.cpp'>Test.cpp</a>  
[其他: Runtime 源码索引](bear://x-callback-url/open-note?id=B3550C45-8F01-4EC0-9821-2C07B25675BB-477-000128BDB612EEEA)  
  
> 备注: 同名的关键字在编译前和编译后不是一个含义, 比如 `NSObject`    
> 编译后是 `objc_object` 的别名, 这个”单词” 和类本身没关系, 只用于创建结构体指针. 编译前是类名    
> 前后的`NSObject` 指代的内容不同    

- - - -  

## 索引:  
先放个整体结构图图:  
其中紫色表头为结构体定义, 黑色表头为结构体变量  
![](/assets/images/源码解析/runtime//%E6%99%BA%E8%83%BD%E6%88%AA%E5%9B%BE%2014.png)  
本文重点:  
* NSObject 和 自定义 Class 被编译后变成了什么?  
* `成员变量的结构体`,  `成员变量集合的结构体`, `函数的结构体`, `函数集合的结构体`  
* `描述类的结构体`, `描述类关系的结构体`  
* 上面这些结构体怎么组合起来, 描述一个类  
* 对象的本质是 `struct objc_object`, 怎么与类产生关系(成员变量, 成员函数, 类函数等怎么关联到对象上)  
  
- - - -  
## NSObject 的定义  
```c  
typedef struct objc_object NSObject;  
typedef struct {} _objc_exc_NSObject;  
  
struct NSObject_IMPL {  
  Class isa;  
};  
```  
  
* `NSObject(编译后)` 关键字是结构体 `objc_object`的别名  
* `NSObject_IMPL`  是一个带 `Class isa` 字段, 但是目前和 `NSObject` 没有关系的东西  
  
## Test 类定义  
* Test 在编译后, 拆成两个结构体,   
	* 一个是 `Test` 是  `objc_object` 的别称  
	* 另一个是 `Test_IMPL`, 带了父类和自己的成员变量  
* Test 的成员函数被定义成静态函数, 内部包含了实现  

```c  
typedef struct objc_object Test;  
typedef struct {} _objc_exc_Test;  
struct Test_IMPL {  
  struct NSObject_IMPL NSObject_IVARS;  
  NSNumber *testProperty1;  
  NSString *testProperty2;  
  Test *testProperty3;  
};  
  
static void _I_Test_testFunction(Test * self, SEL _cmd) {  
    printf("aaa");  
}  
```  
  
  
## 一些描述类或对象用的 结构体 定义(暂时只考虑函数,变量, 排除协议等)  
### 成员变量(没有类变量) 相关的结构体  
> ps. 属性声明时,现在加入了 class 关键字, 但是只是声明, 实际内部实现用的是指定义 getter, setter    

* **类/成员变量结构体**: `_ivar_t`  
	* 变量本身单独存放在另一个地方(写在哪找到了,但是没看懂?)  
	* 这个结构体里有: 变量指针, 名字, 类型(用字符串表示), 不知道啥, 变量实际大小  
* **类/成员变量结构体的 集合结构体**: `_ivar_list_t(实际是匿名)` 归纳 **类/成员变量结构体**  
	* 里面包含: 单个 `_ivar_t` 大小, `_ivar_t` 个数, 存放`_ivar_t`的数组  

```c  
// 类/成员变量定义: 没看懂  
extern "C" unsigned long int OBJC_IVAR_$_Test$testProperty1 __attribute__ ((used, section ("__DATA,__objc_ivar"))) = __OFFSETOFIVAR__(struct Test, testProperty1);  
  
//类或成员变量结构体:  _ivar_t  
struct _ivar_t {  
  unsigned long int *offset;  // pointer to ivar offset location  
  const char *name;  
  const char *type;  
  unsigned int alignment;  
  unsigned int  size;  
};  
  
// 类/成员变量结构体的 集合结构体: _ivar_list_t  
// 一个匿名结构体, 直接创建一个变量, _OBJC_$_INSTANCE_VARIABLES_Test  (后称Test_Var)  
static struct /*_ivar_list_t*/ {  
  unsigned int entsize;  // sizeof(struct _prop_t)  
  unsigned int count;  
  struct _ivar_t ivar_list[3];  
} _OBJC_$_INSTANCE_VARIABLES_Test __attribute__ ((used, section ("__DATA,__objc_const"))) = {  
  sizeof(_ivar_t),  
  3,  {
    {(unsigned long int *)&OBJC_IVAR_$_Test$testProperty1, "testProperty1", "@\"NSNumber\"", 3, 8},  
   {(unsigned long int *)&OBJC_IVAR_$_Test$testProperty2, "testProperty2", "@\"NSString\"", 3, 8},  
   {(unsigned long int *)&OBJC_IVAR_$_Test$testProperty3, "testProperty3", "@\"Test\"", 3, 8}}  
};  
```  
  
### 函数相关结构体  
* OC 定义在类中的函数, 直接变成了 C 中 <mark>全局静态函数</mark>  
* 由**函数结构体**: `_objc_method`来描述函数及其信息  
	* SEL [其他: id,SEL 等关键字及其含义](bear://x-callback-url/open-note?id=BB3D8AF7-2916-4306-963B-F555BC45D9C1-477-00007146039DCDCF), TypeEncodings [其他: Type Encodings](bear://x-callback-url/open-note?id=3B5FE7A2-609D-44F9-B593-AAD81CB42173-477-00007D9BC42DFA18) , 函数指针  
* **函数结构体的 集合结构体**: `_method_list_t` 归纳 **函数结构体**  
	* 里面包含: `_objc_method`单个大小, 数目, `_objc_method` 组成的数组  

```c  
// _objc_method  
struct _objc_method {  
  struct objc_selector * _cmd;  
  const char *method_type;  
  void  *_imp;  
};  
  
// 新建一个结构体 无名, 直接给变量  _OBJC_$_INSTANCE_METHODS_Test (后称Test_Method)  
// 方法列表: 单个大小, 方法数, 具体方法数组  
// 直接将 OC 语言中定义的函数名称赋值过来  
static struct /*_method_list_t*/ {  
  unsigned int entsize;  // sizeof(struct _objc_method)  
  unsigned int method_count;  
  struct _objc_method method_list[1];  
} _OBJC_$_INSTANCE_METHODS_Test __attribute__ ((used, section ("__DATA,__objc_const"))) = {  
  sizeof(_objc_method),  
  1,  
  {
    {(struct objc_selector *)"testFunction", "v16@0:8", (void *)_I_Test_testFunction}}  
};  
```  
  
### 类相关结构体  
* 最后,类的整体定义被拆成了两个结构体: `struct _class_t ` 和 `struct _class_ro_t `  
	* 这两个成对出现, 组合描述一个类  
	* `class_or` 是 `class` 的其中一个字段  
* 第一个 `class`(`struct _class_t`): 一个包含了`class_or`的结构体  
	* 带了 isa, superclass 指针, cache, vtable(不知道啥), class_or  
	* 这个结构体有下一个结构体的指针  
* 第二个 `class_or`(`struct _class_ro_t `)   
	* 描述起始位置,大小, 名称, 函数表集合,  协议,成员变量集合, 弱引用, 属性表  
	* 这里面存放了上面的`baseMethods `和`ivars`既上文两个集合结构体  

```c  
struct _class_ro_t {  
  unsigned int flags;  
  unsigned int instanceStart;  
  unsigned int instanceSize;  
  unsigned int reserved;  
  const unsigned char *ivarLayout;  
  const char *name;  
  const struct _method_list_t *baseMethods;  
  const struct _objc_protocol_list *baseProtocols;  
  const struct _ivar_list_t *ivars;  
  const unsigned char *weakIvarLayout;  
  const struct _prop_list_t *properties;  
};  
  
struct _class_t {  
  struct _class_t *isa;  
  struct _class_t *superclass;  
  void *cache;  
  void *vtable;  
  struct _class_ro_t *ro;  
};  
```  
  
  
## 关联部分  
那么上面这些结构体,最终怎么通过结构体的变量相互组合用来描述类和对象的呢?  
  
首先, 介绍共有哪些变量:  
  1. 一个 OC 的类, 对应**两个**C 层的 `struct _class_t`(Class Test, 在 C 层是 `ClassTest` 和 `MetaClassTest`)  
  * `ClassTest` 用于描述 OC Test 这个类的**对象**, 所拥有的的 **成员函数** 和 **成员变量**  
  * `MetaClassTest` 用于描述 OC Test 这个类, 所拥有的 **类函数**  
  * `ClassTest` 在赋值时, 会将 `MetaClassTest` 赋值到其 isa 字段  
  2. `struct class_t` 内部用 `struct class_ro` 描述信息, 所以这里共需要关注 **四个变量**  
  * ClassTest:  `class ClassTest`, `class_or ClassTest_or`  
  * MetaClassTest:  `class MetaClassTest `, `class_or MetaClassTest_or`  
  
然后怎么将这 **四个变量** 建立关系从而描述 OC 的类和变量? 通过`OBJC_CLASS_SETUP_$_Test`函数赋值:  
* `MetaClassTest`:  
  1. `MetaClassTest_or` 赋值一些 OC 类相关的值(比如类函数)  
  2. `MetaClassTest`:   
  * `isa`: 指向(`MetaClass_NSObject`)  
  * `superclass`: 指向父类的 Meta (`MetaClass_NSObject`)  
  * `or`: 指向自己的 or(`MetaClassTest_or `)  
* `ClassTest`:  
  1. `ClassTest_or`:   
  * `flags`: 0  
  * `instanceStart`: 计算 Offset, 从第一个属性的地址开始  
  * `instanceSize `: `sizeof(struct *Test_IMPL*)`  
  * `instanceStart `: 0  
  * `reserved `: 0  
  * `ivarLayout`: 0  
  * `name`: “Test”  
  * `baseMethods`: _method_list_t  
  * `baseProtocols`: 协议(之后再谈,先看基础)  
  * `ivars`: _ivar_list_t  
  * `weakIvarLayout`: 0  
  * `properties `: 属性(之后再谈,先看基础)  
  2. `ClassTest`:  
  * `isa`: 指向自己的 Meta `MetaClassTest`(关于 isa 的指向见 [其他:探究 isa 的指向](bear://x-callback-url/open-note?id=623141C8-F03C-499F-A56E-961B5076B01A-477-00006B5900239E7D) )  
  * `superclass`: 指向父类的 Class `Class_NSObject`  
  * `or`: 指向自己的 or `ClassTest_or `  
  
最后所有上面定义的结构体对应的对象, 都归入 `struct _class_t OBJC_CLASS_$_Test`   
ps.实际操作中, 分为两步: **初始化** **建立关系**  
```c  
// 给 _class_ro_t 类型的结构体,建一个变量, 然后赋值,   
// 变量名: _OBJC_METACLASS_RO_$_Test  (后简称 MetaClass_OR_Test)  
// name: "Test"  
static struct _class_ro_t _OBJC_METACLASS_RO_$_Test __attribute__ ((used, section ("__DATA,__objc_const"))) = {  
  1, sizeof(struct _class_t), sizeof(struct _class_t),   
  (unsigned int)0,   
  0,   
  "Test",  
  (const struct _method_list_t *)&_OBJC_$_CLASS_METHODS_Test,  
  0,   
  0,   
  0,   
  0,   
};  
  
// 给 _class_ro_t 类型的结构体,建一个变量, 然后赋值,  
// 变量名: _OBJC_CLASS_RO_$_Test (后简称 Class_OR_Test)  
// name: "Test"  
// baseMethods: 将上面的 Test_Method 赋值过来  
// ivars: 将上面 Test_Var 赋值过来  
static struct _class_ro_t _OBJC_CLASS_RO_$_Test __attribute__ ((used, section ("__DATA,__objc_const"))) = {  
  0, __OFFSETOFIVAR__(struct Test, testProperty1), sizeof(struct Test_IMPL),   
  (unsigned int)0,   
  0,   
  "Test",  
  (const struct _method_list_t *)&_OBJC_$_INSTANCE_METHODS_Test,  
  0,   
  (const struct _ivar_list_t *)&_OBJC_$_INSTANCE_VARIABLES_Test,  
  0,   
  0,   
};  
  
// 给 _class_t 类型的结构体,建一个变量, 然后赋值,  
// 变量名: OBJC_METACLASS_$_Test (后简称 META_CLASS_Test)  
// ro 赋值为上面的  METACLASS_RO_Test  
extern "C" __declspec(dllexport) struct _class_t OBJC_METACLASS_$_Test __attribute__ ((used, section ("__DATA,__objc_data"))) = {  
  0, // &OBJC_METACLASS_$_NSObject,  
  0, // &OBJC_METACLASS_$_NSObject,  
  0, // (void *)&_objc_empty_cache,  
  0, // unused, was (void *)&_objc_empty_vtable,  
  &_OBJC_METACLASS_RO_$_Test,  
};  
  
extern "C" __declspec(dllimport) struct _class_t OBJC_CLASS_$_NSObject;  
// 给 _class_t 类型的结构体,建一个变量, 然后赋值,  
// 变量名: OBJC_CLASS_$_Test (后简称 CLASS_Test)  
// ro 赋值为上面的  CLASS_RO_Test  
extern "C" __declspec(dllexport) struct _class_t OBJC_CLASS_$_Test __attribute__ ((used, section ("__DATA,__objc_data"))) = {  
  0, // &OBJC_METACLASS_$_Test,  
  0, // &OBJC_CLASS_$_NSObject,  
  0, // (void *)&_objc_empty_cache,  
  0, // unused, was (void *)&_objc_empty_vtable,  
  &_OBJC_CLASS_RO_$_Test,  
};  
  
// 建立联系  
// META_Class_Test.isa 与 NSObject 的 meta 建立联系  
// META_Class_Test.superclass 也与 OBJC_METACLASS_$_NSObject 建立联系  
// METACLASS_$_Test.cache 给空  
// OBJC_CLASS_$_Test.isa 与 METACLASS 建立联系  
// OBJC_CLASS_$_Test.superclass 与OBJC_CLASS_$_NSObject; 建立联系  
// OBJC_CLASS_$_Test.cache 与 objc_empty_cache 建立联系  
static void OBJC_CLASS_SETUP_$_Test(void ) {  
  OBJC_METACLASS_$_Test.isa = &OBJC_METACLASS_$_NSObject;  
  OBJC_METACLASS_$_Test.superclass = &OBJC_METACLASS_$_NSObject;  
  OBJC_METACLASS_$_Test.cache = &_objc_empty_cache;  
  OBJC_CLASS_$_Test.isa = &OBJC_METACLASS_$_Test;  
  OBJC_CLASS_$_Test.superclass = &OBJC_CLASS_$_NSObject;  
  OBJC_CLASS_$_Test.cache = &_objc_empty_cache;  
}  
```  
  
## 临门一脚, “对象” 是怎么和 _class_t 产生关系的  
我们有了通过 `struct _class_t` 创建的变量 `OBJC_CLASS_$_Test`  
这个变量通过 `OBJC_CLASS_SETUP_$_Test` 函数, 将类的信息都归入其中  
  
那么, OC 中的对象, 最终怎么跟描述他类的 `OBJC_CLASS_$_Test` 产生关系?  
<a href='/assets/images/源码解析/runtime//main.cpp'>main.cpp</a>  
  
### OC “对象”的实质:  
```c++  
// 编译前  
Test *test = [[Test alloc] init];  
//编译后  
typedef struct objc_object Test;  
Test *test = xxx  
```  
* OC 的“对象”, 就是 C 中 `struct objc_object` 的指针变量  
* *test 的本质就是指向 <mark>只有一个`isa` 字段的结构体</mark> 的指针  
* 所有 OC 中的类名, 包括 NSObject 在编译后, 都会变成 `struct objc_object` 的别名, 当用这些类名声明一个指针时, 其本质都一摸一样, 是一个 `objc_object` 的指针  
  
所以乍一看 “对象” 和 “类” 没有关系  
那么 “对象” 怎么和成员变量, 以及成员函数产生关联?, 如果成员函数中使用了成员变量呢?  
  
### “对象” 不与其 类的 ”成员变量” 有从属关联  
这里的不产生关联, 指的是 所有权 上不会有依赖关系.(编译后, “对象” 不会真的有指针指向某个成员变量)  
(“对象”的成员变量, 编译后不是”对象”的, 但能通过 offset 找到)  
实际上如果对象要调用其成员变量, 都是通过直接找到那个成员变量的地址来实现的  
```c++  
// 先定义了一系列通过 "变量", 和属性, 找到 offset 的宏  
#define __OFFSETOFIVAR__(TYPE, MEMBER) ((long long) &((TYPE *)0)->MEMBER)  
  
// 通过这个宏,算出偏移量  
extern "C" unsigned long int OBJC_IVAR_$_Test$testProperty1 __attribute__ ((used, section ("__DATA,__objc_ivar"))) = __OFFSETOFIVAR__(struct Test, testProperty1);  
extern "C" unsigned long int OBJC_IVAR_$_Test$testProper __attribute__ ((used, section ("__DATA,__objc_ivar"))) = __OFFSETOFIVAR__(struct Test, testProper);  
extern "C" unsigned long int OBJC_IVAR_$_Test$testProperty3 __attribute__ ((used, section ("__DATA,__objc_ivar"))) = __OFFSETOFIVAR__(struct Test, testProperty3);  
  
// 具体在调用时, 用"对象"的地址 + 一定 offset  
// OC 部分  
test->testProperty1 = XXXX;  
// 编译后  
(*(NSNumber **)((char *)test + OBJC_IVAR_$_Test$testProperty1)) = XXX;  
// 省略类型转换后  
test->testProperty1 在编译后就是 test + OBJC_IVAR_$_Test$testProperty1  
```  
  
所以, 从代码实现上可以理解为, 某个 ”对象” 的 “成员变量”  
* 是被放在某个位置(应该是全局)定义的变量  
* 这个变量本身和”对象”没有直接关系  
* 代码中提供了使用 “对象” 地址 + 偏移量, 找到这个”成员变量” 的办法  
  
思考一个问题?  
变量是通过 offset 计算出来的, 假设, 苹果扩充了 NSObject. 那么是否子类的变量可能与父类重叠?  
这里涉及 Non Fragile ivars, 暂不在此处赘述.  
[Hamster Emporium: objc explain: Non-fragile ivars](http://www.sealiesoftware.com/blog/archive/2009/01/27/objc_explain_Non-fragile_ivars.html)  
  
### “对象” 通过 objc_msgSend 与 其类的”函数” 产生关联  
看着代码很复杂, 本质上 `Test *test = [Test alloc]` 只做了一件事  
* 调用 `objc_msgSend` 函数, 第一个入参是 `objc_getClass("Test")`, 第二个入参是 `sel_registerName("alloc")`, 返回结果转换为 Test 类型(其他都是类型转换, 给编译器用, 可以忽略)  
* 这里通过 `objc_getClass` 拿到了其 “类” 结构体, 然后通过 `sel_registerName` 拿到了其调用函数的 SEL  
* `objc_msgSend` 不在这里叙述, 专门开篇讲  

```c++  
// 一个输入 char* 返回 objc_class* 的函数  
struct objc_class *objc_getClass(const char *);  
// 一个输入 char* 返回 SEL 的函数  
SEL _Nonnull sel_registerName(const char * _Nonnull str)  
  
int main(int argc, const char * argv[]) {  
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool;   
    Test *test =   
			 ((Test *(*)(id, SEL)) (void *)objc_msgSend )  
          ((id)objc_getClass("Test"), sel_registerName("alloc"));  
    }  
    return 0;  
}  
```  
这里忽略”消息传递”的过程(另有专题)  
再看, 函数本身被实现成什么样:  
* 成员函数(类函数同样)被实现为文件中全局函数  
* 全局函数多了两个入参 `Test * self`, `SEL _cmd`  
由此, 我们可知, 当通过消息传递找到函数后:  
* 函数的入参中会带有对象自身, 这是函数中能调用 self 自身, 以及使用 self 自身变量的原因  

```c++  
//OC 中代码  
- (void)testFunction:(int)value {  
    printf("TestFunction\n %d",[self->testProperty1 intValue]);  
}  
  
// 编译后代码  
static void _I_Test_testFunction_(Test * self, SEL _cmd, int value) {  
    printf("TestFunction\n %d",((int (*)(id, SEL))(void *)objc_msgSend)((id)(*(NSNumber **)((char *)self + OBJC_IVAR_$_Test$testProperty1)), sel_registerName("intValue")));  
}  
  
```  
  
## 其他  
### SEL 的探索  
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
  
  