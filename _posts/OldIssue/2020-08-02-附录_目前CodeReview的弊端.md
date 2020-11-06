---
title: 附录-工程专题：(旧)目前 Code Review 的弊端  
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
picture_frame: shadow
tags: 工程专题 附录
coding: UTF-8
--- 
> 这是一个旧的 issue，被我从 Hover 项目 issue 中移植过来，留档保存。    
> 2018 年由 GeorgeWu 提出    
  
关于 MR Code Review，之前制定的规则是集齐每个人的赞即可合并。实践中发现有以下弊端  
* 对于一些小的改动，无法快速合并。  
* 开发节奏加快时，每个人的 MR 次数会增加。如果严格执行集赞要求，每个人每天需要 review n * m 次 （n 为开发者人数，m 为每天人均 MR 发起次数）。成倍增长的 review 次数会造成打断开发思路、过度 review、影响心情等。  
* 由于想到还会有其他人来 review，容易导致 review 变成走过场。  
所以建议  
* 每个 MR assign 给 requester 认为最合适的一个人作为 reviewer。发起 MR 时选择这个人为 assignee。  
* Assignee 有义务按相关要求 review MR。  
* 如果没有其它 issue，assignee 的赞视为可以合并的标志。  
* MR 发起者有义务向 assignee 解释代码逻辑，以方便 reviewer 快速理解代码逻辑。  
* 每次发起 request，在群里发消息，其它没有被 assign 的开发者也可同时 review，提出的 issue 同等对待。  
现在从某种程度上来说，我们已经在这么做了。顺应时代潮流，书面化一下这一 [非正式制度](https://en.wikipedia.org/wiki/Institution#Informal_Institutions)   

- - - -  

> From **MJXin**:    
上述情况有一个局限是，有一个最适合的 reviewer，在没有最适合的 reviewer 的情况下，上述提到的几点弊端如何避免呢？ 比如一个功能仅由一个人开发，并且暂时不涉及其他模块  

- - - -  

> From **GeorgeWu**:    
我们都朝代码简洁、可读不断努力吧。每人代码的框架设计、业务逻辑，尽量做到很容易被一个没有参与开发的同事读懂。开发者如果能讲解一些设计思路，基本上 review 是完全没有问题的。  

- - - -  

> From **ChenYuanfu**:    
我同意Code review 的新建议，现在在 ‘hover’ 项目中也是这么做的，毕竟我们 mr (merge request) 的次数很多。家欣提出的局限性我觉得确实是有，比如在hover中以外的模块中，很多时候是没有进行review，新代码直接合入主分支了，在 ‘hover’ 中的 mr 其实也只是Podfile 和Podfile.lock 的 diff 。我们应该怎么在独立的模块中进行有效的code review? 在独立的模块中进行review，有很多问题，mr 不知道可以assign给谁？一个 mr 发起了很长时间没有人去 review， 这个时候是继续等还是直接合？  

- - - -  

> From **GeorgeWu**:    
@cyfChenYuanfu 按照之前的约定，出于开发敏捷性的考虑如果是足够小的 hot fix，或者足够独立的小型 update （改个 UI 色值什么的），我们可以直接合并。前提是：改动小；开发者对自己作出对改变有足够信心；不会影响到其它部分。  
其它问题我们在实践中不断摸索更好的处理方式吧。  
  