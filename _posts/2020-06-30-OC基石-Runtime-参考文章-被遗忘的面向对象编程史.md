---
title: 附录-OC源码-Runtime：被遗忘的面向对象编程史  
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
lightbox: true
pageview: true
tags: 源码解析 OC基石
coding: UTF-8
---  
> 原文: [The Forgotten History of OOP. Most of the programming paradigms we… | by Eric Elliott | JavaScript Scene | Medium](https://medium.com/javascript-scene/the-forgotten-history-of-oop-88d71b9b2d9f)    
> 原文译文: [译 被遗忘的面向对象编程史（软件编写）（第十六部分） - 掘金](https://juejin.im/post/6844903743167660039)    
  
  
## 面向对象来源  
* “面向对象编程”（OOP）是 Alan Kay(艾伦·凯) 在 1966 年或 1967 年读研究生时创造的。  
* 提出于 1965 年的 `simula` 语言，是第一个被广泛认可的“面向对象”的编程语言。与 Sketchpad 一样，Simula 使用了对象，甚至还引入了类，类继承，子类和虚方法。  
* “面向对象编程”（OOP）这个想法是想在软件中使用封装好的微型计算机，通过消息传递而不是直接的数据共享，以此来防止将程序分裂为单独的“数据结构“和“程序”。  
  
## 面向对象当初的指代  
> “我很抱歉，我很久以前为这个话题创造了“对象”一词，而因为它让很多人专注于细枝末节。实际上真正重要的是消息传递。”    
> “OOP 对我来说意味着消息传递，对状态进程的本地保留保护和隐藏，以及对所有事物的动态绑定。”    
> ~ Alan Kay    
  
根据 Alan Kay 的说法，OOP 的基本要素是：  
* 消息传递  
* 封装  
* 动态绑定  

<br/>		   

消息传递和封装的结合有一些重要的目的：  
  * **避免共享可变状态**  
    通过封装状态并将其他对象与本地状态更改隔离开来。影响另一个对象状态的唯一方法是通过发送消息来请求（而不是命令）该对象来更改它。状态变化由局部控制，，而不是暴露于共享访问。  
  * **解耦**  
    通过消息传递 API，消息发送者与消息接收者松散耦合。  
  * **适应变化**  
    通过动态绑定在运行时适应变化  
  
## 为什么会有这样的面向对象  
* Alan Kay 的生物学背景  
	想象软件运行在巨大的分布式计算机（互联网）上，个人计算机就像生物细胞一样，在自己的孤立状态下独立运行，并通过消息传递进行通信。  
* “ 我意识到, 将细胞与整个计算机类比, 能摆脱 data  
	 _“I realized that the cell_whole-computer metaphor would get rid of data[…]”  
	~ Alan Kay/  
  
* 通过 `rid of data` Alan Kay 意识到::共享可变状态导致的问题和耦合问题::, 原因在于共享的数据  
```  
By “get rid of data”, Alan Kay was surely aware of shared mutable state problems and tight coupling caused by shared data — common themes today.  
此处原文应该翻译错了, /shared data/ 指的应该是 /shared mutable state problems/ + /tight coupling/  
```  
	* 这两个问题仍然是今天的普遍问题  
  
* [ARPA 程序员对在程序编写之前选择数据模型的需求感到沮丧](https://www.rand.org/content/dam/rand/pubs/research_memoranda/2007/RM5290.pdf)  
	这篇论文指出,  程序与特定数据结构高度耦合导致程序没有变化修改空间  
```  
Procedures that were too tightly coupled to particular data structures were not resilient to change.  
此处原文我也倾向于翻译的不准确,  `使得程序无法适应变化` 的翻译太过抽象, 指的应该是程序在外界需求变化后, 难以修改维护  
```  
	  
  
## 封装  
* 对象可以被抽象出来并隐藏数据结构的实现方法  
* 对象的内部实现可以在不破坏软件系统其他部分的情况下进行更改  
	↓  
	通过迟约束，完全不同的计算机系统可以接管对象的功能，并且软件可以继续工作  
	与此同时，对象可以公开一个标准接口，该接口可以处理对象在内部使用的任何数据结构  
  
```  
我目前尚未能了解当时遇到的问题, 所以无法知道 OOP 被提出所要解决的问题  
但能知道的是, OOP 这个概念被提出来时, 目的是不做数据共享, 而是通过消息传递的方式  
```  
  
## 对象的代数特性  
* Alan Kay 还将对象视为代数结构，这些结构可以通过数学来证明它们的行为：  
	_“我的数学背景使我意识到每个对象可能有几个与之相关的代数式，可能有代数式族，而这些将会非常有用。” ~ Alan Kay_  
* 允许对象提供公式化验证，确定性行为和改进的可测试性，因为代数本质上是遵循方程式规则的操作。  
* 在程序员术语中，代数就像是由函数(操作)组成的抽象，这些函数必须通过单元测试强制执行的特定规则(公理/方程式)。  
  
  
## 联系到 JS  
* JavaScript 是针对世界对面向对象编程的误解的一种反击  
* Smalltalk 和 JavaScript 都支持：  
	* 对象  
	* 主类函数和闭包  
	* 动态类型  
	* 迟绑定（函数/方法在运行时可更改）  
	* 不支持类继承的面向对象语言  
  
## 引申出前文两个概念  
什么是面向对象编程的必要特性(根据 Alan Kay 的说法)？  
* 封装  
* 消息传递  
* 动态绑定（程序在运行时进化/适应的能力）  
  
什么是非必要的特性？  
* 类  
* 类继承  
* 对象_函数_数据的特殊处理  
* new关键字  
* 多态性  
* 静态类型  
* 将类识别为“类型”  
  
* Java 或 C# 的开发者，您可能会认为静态类型和多态性是必不可少的成分  
* 但Alan Kay 倾向于以代数形式处理共性行为  
`多态是用于描述程序共性的, 特别是强类型,静态类型语言中,  Alan Kay 认为, 共性应该由代数式描述`  
例如: fmap :: (a -> b) -> f a -> f b, 用映射来替代多态  
  
```js  
// isEven = Number => Boolean   
const isEven = n => n % 2 === 0;   
const nums = [1, 2, 3, 4, 5, 6];   
// map takes a function`a => b` and an array of `a`s (via `this`)   
// and returns an array of `b`s.   
// in this case, `a` is `Number` and `b` is `Boolean`   
const results = nums.map(isEven);   
console.log(results); // [false, true, false, true, false, true]  
  
```  
* 大多数类型系统有太多的限制，无法自由表达动态和函数想法  
  
## 什么是对象  
* 多年来，对象已经被赋予大量的含义  
* JavaScript 中称之为“对象”的只是复合数据类型  
* 可以通过并且通常都会支持给 JS 的对象增加封装, 消息传递，通过方法进行行为共享，甚至子类多态, 但所有这些都是选择加入的行为。  
  
* 我们现在认为对象只是一个复合数据结构，并不需要其他更多的含义。  
* 但这样的定义, 并不会比函数式编程 更加 “”面向对象”  
  
### 作者认为  
* 现代编程语言中的“对象”意味的比 Alan Kay 设想的要少得多  
* 这里作者用 `组件` 这个词来指代 Alan Kay  所表达的对象  
* 作者认为: 在 JavaScript 中操作 `objects` 或使用 `class inheritance` 并不意味着在“面向对象”  
* 真正的面向对象的含义：  
* 使用`组件`编程（就是 Alan Kay 所说的“对象”）  
* 必须封装`组件`状态  
* 使用消息传递进行对象间通信  
* 组件可以在运行时被创建_更改_替换  
* 这么去使用组件, 意味着面向对象  
  
`然后作者遵循流行用法, 将这种重新取名(因为现在的面向对象已经脱离原本意义, 但又占有了面向对象这个词)`  
* 所以也许我们应该放弃面向对象并将其称为“面向消息的编程（MOP）”而不是“面向对象的编程（OOP）”  
* 好的 MOP 意味着系统是通过消息调度与其他组件通信，不是各个系统去直接操纵彼此的状态。  
  
* 用户操作按钮 -> 调动保存消息 -> 状态组件解析 -> 转发到状态更新处理程序 -> 向界面组件发送”状态更新”消息 -> 界面组件解析状态协调更新  
  
* 这些系统不需要知道系统其他部分的细节。只需要关注自身的模块化问题  
* 系统组件是可分解和可重新组合的。  
* 它们实现标准化接口，以便它们能够相互操作  
* 同一个软件系统的组件甚至都不需要位于同一台机器上。系统可以是分布式的  
  
## 结论:  
现在是时候让软件世界放弃失败的类继承实验了，转而接受最初定义面向对象时所秉承的数学和科学精髓。  
现在是时候开始构建更灵活，更具弹性，更容易组合的软件了，让 MOP 和函数编程协调工作。  
