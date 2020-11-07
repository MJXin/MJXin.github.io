---
title: 附录-OC源码-Runloop： Mach 是什么   
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
picture_frame: shadow
tags: 源码解析 OC基石
coding: UTF-8
--- 
在 Runloop 中经常会看到 Mach, 这里简单过一下 Mach 是什么.  
<mark>Mach 可以理解为一个系统内核中的微型操作系统, 仅处理最核心任务</mark>  
其处理的内容包括:  
* 进程和线程抽象  
* 任务调度  
* 进程间通讯和消息传递  
* 虚拟内存管理  
  
更细的内容不做深入研究,太多陌生名词, 留待之后时机合适再做研究  
  
下图可以看到很多熟悉的名词, 而最下一层的 Kernel Mach 既上面提到的 Mach, 具体看可看官方文档  
[Kernel Architecture Overview](https://developer.apple.com/library/archive/documentation/Darwin/Conceptual/KernelProgramming/Architecture/Architecture.html#//apple_ref/doc/uid/TP30000905-CH1g-CACDCAGC)  
![](/assets/images/源码解析/runloop/276994-20200706000435369-424414892.jpg.png)  
(图取自: [iOS&mac 系统内核 - 七夜i - 博客园](https://www.cnblogs.com/qiyer/p/13252630.html))  
  
有一本书叫 《深入解析Mac OS X & iOS操作系统》(有,但没看进去)  
里面专门讲解这方面知识  
[《深入解析Mac OS X & iOS操作系统》读书笔记 - okeyang’s blog](http://blog.okeyang.com/blog/2015/07/24/shen-ru-jie-xi-mac-os-x-and-ioscao-zuo-xi-tong--du-shu-bi-ji/)  
![](/assets/images/源码解析/runloop/darwin_architecture.png)  
  
