---
title: 附录-OC源码-Runtime：The Deep Insights of Alan Kay (艾伦凯的深刻见解)       
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
lightbox: true
pageview: true
tags: 源码解析 OC基石
coding: UTF-8
---  
[The Deep Insights of Alan Kay - mythz blog](http://mythz.servicestack.net/blog/2013/02/27/the-deep-insights-of-alan-kay/)  
[艾伦·凯（Alan Kay）的深刻见解_闲云孤鹤-CSDN博客_alan kay](https://blog.csdn.net/robertsong2004/article/details/50651003)  
  
> 伯乐在线注：2月28日我们在微博推荐了《 [The Deep Insights of Alan Kay](http://mythz.servicestack.net/blog/2013/02/27/the-deep-insights-of-alan-kay/) 》这篇文章，感谢 [@老码农的自留地](http://weibo.com/ned11) 的热心翻译（ [链接](http://ned11.iteye.com/blog/1828088) ）+ 投稿。    
  
如果你还没听说过 [Alan Kay](http://en.wikipedia.org/wiki/Alan_Kay) （艾伦·凯）这个名字，你也很可能听说过他的诸多 [名言](http://en.wikiquote.org/wiki/Alan_Kay) 中的一句，最流行的是他在1971年的这句金玉良言：  
> 预测未来的最佳方式就是去创造它。    
  
给不了解他的人们介绍一下，Alan取得了计算机科学领域最杰出的专业成就之一：他因为在面向对象编程（OOP）领域的工作获得了京都奖（号称日本 的诺贝尔奖）和图灵奖。同时他也是个人计算（PC)，图形用户界面(GUI)， 面向对象编程(OOP)的先驱者之一，和有史以来最具影响力的语言之一 [Smalltalk](http://en.wikipedia.org/wiki/Smalltalk) 的发明者。  
  
Alan Kay写的很多文章（ [链接1](http://www.mprove.de/diplom/referencesKay.html) 、 [链接2](http://www.viewpointsresearch.org/html/writings.php) ）中都犀利地观察到 [思路延伸的力量](http://www.vpri.org/pdf/m2004001_power.pdf) ，对此他回顾了当时独辟蹊径的 [Xerox PARC](http://en.wikipedia.org/wiki/PARC_%28company%29) 和 [ARPA](http://en.wikipedia.org/wiki/Advanced_Research_Projects_Agency) 研发环境，在那里的收获是“愿景重于目标”和“投资于人而不是项目”，结果吸引了一些杰出人才在一起培育不同的观点，而这些不同的观点是取得进展所必需的。对此他认为：  
> 一个观点就值 IQ 80分    
  
回顾过去，他认为：  
> ARPA/PARC的历史表明，愿景、适当的资金、精妙的思路和流程的组合几乎可以魔幻般地使新技术破茧而出，这些新技术不仅可以扩大人类文明，也能给社会产生巨大的财富。    
  
这些杰出人才在PARC确实发明了成为当今很多个人计算和编程领域基石的 [一系列不同凡响的技术](http://www.parc.com/about/) ，包括：  
* 激光打印机  
* 面向对象编程（OOP）/ Smalltalk  
* 个人计算机  
* 以太网（Ethernet）/ 分布式计算  
* 图形用户界面（GUI）/ 鼠标 / 所见即所得（WYSIWYG）  
而在ARPA则产生了 [ARPANET](http://en.wikipedia.org/wiki/ARPANET) 这一神作，也就是我们现在说的互联网（Internet）的鼻祖。  
  
## 关于软件工程  
有意思的是Alan现在还认为 [计算机革命并未真正发生](http://www.viewpointsresearch.org/pdf/m2007007a_revolution.pdf) ，软件工程正在向和摩尔定律相反的方向发展，当硬件容量逐年递增的时候，软件则在无谓地持续膨胀，他认为这很可能  
> 归因于虚弱而难于扩展的思路和工具、懒惰和缺少知识，等等    
  
这个发展形势在一首 [搞笑单行诗](http://www.forbes.com/2005/04/19/cz_rk_0419karlgaard.html) 里表现的淋漓尽致：  
> Andy给予的一切，都被Bill夺走    
  
指当时Intel的CEO Andy Grove每推出一款性能更高的芯片，当时微软的CEO Bill Gates都会通过升级软件使新硬件带来的更高性能消失于无形。  
为了改善当前软件开发的窘境，Alan领导了 [向着彻底改造编程技术的STEP研究课题](http://www.vpri.org/pdf/tr2007008_steps.pdf) ，目标是实现摩尔定律在软件代码表达效率上的飞跃，途径是  
> 把开发系统所需要编写的代码量减少到原先的百分之一，千分之一，万分之一甚至更少。    
  
他在2011年关于 [编程和扩展](http://www.tele-task.de/de/archive/lecture/overview/5819/) 的 一席发人深省的讲话中再次提到了这个问题，指出软件工程已陷入停滞，成为了迷失的学科，无法跟上硬件和其他科学技术领域发展的步伐。巨大的代码库已经类似 于一个垃圾场，大到任何人都无法看懂产生Vista或者Word的1亿行源代码，而本来只需要一小部分代码就够了。他给出的既能产生深远影响又最小化代码 量的优雅软件典型包括了Internet, TCP/IP，LISP解释器，  [Nile（矢量图的数学DSL）和OMeta（面向对象的PEG )](http://www.vpri.org/pdf/rn2010001_programm.pdf) 。  
  
他指出Internet（TCP/IP）是为数不多的几个设计得当的大规模软件项目之一，实现了其灵活性和复杂度之间的平衡，虽然只有不到2万行代码，却产生了一个能管理数以十亿计个节点的灵活、动态的系统，自从它在1969年9月被启动以来从来没有停止过。 [这是如此罕见](http://www.drdobbs.com/architecture-and-design/interview-with-alan-kay/240003442) 以至于人们不觉得Internet是通常意义上人类开发的软件：  
> Internet是如此之优秀，大部分人把它当做一种和太平洋一样的自然资源而不是人造的东西。上一次出现有如此规模而又能如此容错的技术是什么时候？Web和它比就是一个笑话。Web是一堆业余爱好者捣鼓出来的东西。    
  
Nile/OMeta DSL是他的另一个例证，展示了如何从头开始只用几千行而不是在商业化版本中数以百万计的代码来建造一个系统，实现同样的功能。  
我有兴趣进一步了解，关于我们如何改善现有软件开发水平以及现有语言、方法和工具有哪些缺失，Alan是否有更深远的见解。  
  
## 关于面向对象编程  
我一开始对Alan的研究重点是探索他原创的 [面向对象编程的愿景](http://www.purl.org/stefan_ram/pub/doc_kay_oop_en) 中蕴含的思考，这些思考也受到了他作为微生物学家背景的影响：  
> 我把对象想象成生物细胞或者和网络上的单个计算机，它们之间只能通过消息进行通讯。    
  
也有他作为数学家背景的影响：  
> 我的数学背景使我意识到每个对象可以有多个代数与之关联，这些代数关系可以构成家族，而这些概念会非常非常有用。    
  
他在研究Lisp语言后，被其极致的后期绑定（late-binding）和强大的元（meta)能力所影响：  
> 第二个阶段就是完全理解LISP，并利用这种理解做出更好、更小、更强大和更延迟绑定的基础架构。    
  
从那时起他就成为了用于 [未来软件工程](http://squab.no-ip.com/collab/uploads/61/IsSoftwareEngineeringAnOxymoron.pdf) 的动态语言的坚定倡导者：  
> 直到真正的软件工程实现之前，下一个最佳实践就是在各个方面都采用具备极致端迟绑定的动态系统进行开发。    
  
主要是因为动态系统更容易适应变化：  
> 延迟绑定使得在项目开发过程后期中产生的想法能被植入项目，和传统的早期绑定系统（如C, C++, JAVA等）相比，它所需的工作量是成指数级减少的。    
  
如果系统具备了增量式直接修改和更快的迭代时间的潜力：  
> 一个关键的思路是在测试乃至修改的时候还保持系统运行。即便是主要的修改也应该是增量式的，只需要几秒钟时间就可以生效。    
  
这就是现在 [静态类型语言的不足](http://queue.acm.org/detail.cfmid=1039523) ：  
> 如果你在和大部分人一样用着早期绑定的编程语言，而不是延迟绑定的，那么你你真的开始被你已经做完的东西绑住了。你无法那么轻松地重构你做的东西。    
  
奇怪的是，他对于OOP的思想竟然局限在这么狭隘的范围：  
> OOP对我来说只意味着消息机制(messaging）、本地存留(local retention)，保护机制（protection）和隐藏状态过程，以及极端延迟绑定一切东西。Smalltalk和LISP都能做到这一点。 可能也有别的系统能做到这些，但我没有注意到它们。    
  
就是说OOP居然不需要继承关系，这可不是 [我们今天所理解的概念](http://lists.squeakfoundation.org/pipermail/squeak-dev/1998-October/017019.html) ：  
> 很抱歉我很久之前给这个主题打上了“对象”的烙印，因为这样让很多人关注了更小的想法。    
> 而在主流OO语言中真正缺少的大概念是：真正的大概念是“消息机制”    
  
他提倡应该关注消息机制和模块间的松耦合和交互，而不是模块内部的对象组成：  
> 做出非凡和可成长的系统的重中之重是设计好模块之间如何通讯，而不是模块应具有什么样的内部属性和行为方法。    
  
而静态类型系统很蹩脚：  
> 我不是反对类，但我没听说过哪个类的系统不是一塌糊涂，所以我还是喜欢动态类。    
其他一些流行的编程语言采用了Smalltalk的消息传递机制和延迟绑定，并实现了自己的基于消息的构造方法，包括： [Objective-C](http://en.wikipedia.org/wiki/Objective-C) 的 [forwardInvocation](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtForwarding.html) , [Ruby](http://en.wikipedia.org/wiki/Ruby_%28programming_language%29) 的 [method_missing](http://www.ruby-doc.org/docs/ProgrammingRuby/html/ref_c_object.html#Object.method_missing) ，和最近Google [Dart](http://en.wikipedia.org/wiki/Dart_%28programming_language%29) 的 [noSuchMethod](http://www.dartlang.org/articles/emulating-functions/#interactions-with-nosuchmethod) .  
  
## 破旧立新  
关于发展计算机科学最好的方法，Alan 有个有趣的理论：  
> 我相信科学计算唯一能够存在的类型类似于修建桥梁的科学。一些人负责修桥，其他人负责拆桥并提出更好的理论，人们必须持续不断地修建桥梁。    
  
他认为每隔几个月就推倒重来是有好处的，并且看得出来他想消灭他自己的Smalltalk并重新开始：  
> 众所周知，70年代末我试图消灭Smalltalk。在那之前有几年它是世界上最棒的东西。它以一种比以 前做的任何工具都更紧凑更优雅的方式顺应了当时的需求。但时过境迁了。当我们学会更多，对我们想做的事情有更大的雄心，我们就会意识到Smalltalk 里有各种各样的东西无法按应有的方式扩展。例如里边的反射。它是第一个真正能看到自己的编程语言，但现在我们知道如何更好地实现各种级别的反射，所以我们 必须实现它。    
  
## 关于消息机制  
作为对于远程服务 [消息机制](https://github.com/ServiceStack/ServiceStack/wiki/What-is-a-message-based-web-service%3F) 的长期拥护者，我已经受益于 [基于消息的服务](https://github.com/ServiceStack/ServiceStack/wiki/Advantages-of-message-based-web-services) 一段时间了。所以我对 [Alan关于这个主题](http://www.computerworld.com.au/article/352182/z_programming_languages_smalltalk-80/) 的思考特别感兴趣：  
> 我可以看到通过全方位思考高效率的仅通过消息进行的虚拟机通讯，我们可以构建一个更全面的基础系统。它能够提供扩展性，成为我现在所在研究机构ARPA-IPTO正在研究的大规模网络体系的虚拟版本，并且拥有强大的“代数”属性（例如多态性）。    
  
对于Internet — 在他看来”可能是能够正常运转的唯一的真正的面向对象的系统“， 他想说的是：  
> 对于我来说，关于真实对象的语义上最棒的一件事是，它们才是“归根结底的计算机（RCATWD）”。这个 概念总是保持着代表任何事物的能力。而旧的认识方式很快归结到两样不是计算机的事物 — 数据和流程 –上，那么突然之间这种对象的概念失去了实现优化和改善行为的决策的能力。 换句话说，如果总是和真正的对象打交道，就可以总是保持模拟任何你想要的东西的能力，并且可以把对象送到任何地方去……RCATWD也对传送的双 方向提供了完美的保护。我们可以在Internet（可能是能够正常运转的唯一的真正的面向对象的系统）的硬件模型中看到这一点。你只要遵从消息表单的传 统，就可以几乎完全自由地获得编程语言的扩展性。我在70年代的想法是我们当时在做的Internet加上个人计算是一个真正好的可扩展设计，并且我们可 以做出一个虚拟机的虚拟Internet，它可以由硬件机器提供缓存。这个想法没有实现真是太糟了。如果“真正的对象”是RCATWD的，那么每个对象都 可以用最适合其内在特性的编程语言来实现，这将对“多语言编程”这个概念产生全新的诠释。    
  
如果把所有东西当成对象，通过消息机制就可以让互操作性的水平提高到一个史无前例的水平，减少代码间不必要的摩擦，使不同编程语言之间的无缝通讯成为可能，这将产生一个全新的多语言世界，在那里你可以随意地选择实现每个域（domain）最适合的编程语言。  
关于远程过程调用（RPC）以及它是如何在架构设计和系统构建过程中扭曲开发者的思路的，他提到：  
> 从非数据角度去看待对象的人数量很少，包括我自己、Carl Hewitt, Dave Reed 和其他一些人， 基本上这拨人都曾经是ARPA社区的，不同程度地参加过ARPAnet到Internet的设计，在这个设计中计算的基本单元就是一整台计算机。但是人们 可以看到一个观念可以僵化到什么程度：从七十到八十年代都有很多人试图用“远程过程调用”应付，而不是从对象和消息的角度去考虑问题。 [世界的辉煌就如此擦肩而过了](http://en.wikipedia.org/wiki/Sic_transit_gloria_mundi) 。    
  
 [Carl Hewitt](http://en.wikipedia.org/wiki/Carl_Hewitt) 是 [Actor Model](http://en.wikipedia.org/wiki/Actor_model) 的发明者， [Dave Reed](http://en.wikipedia.org/wiki/David_P._Reed)  参与了TCP/IP 的早期开发和 UDP的设计。  
  
## 关于LISP  
他 [对于LISP的高度评价](http://www.openp2p.com/pub/a/p2p/2003/04/03/alan_kay.html) 反复出现在他的论文和访谈中，他说LISP给予了他见过的 [最深刻的见解之一](http://www.vpri.org/pdf/m2004001_power.pdf) ，所以他认为LISP是  
> 人类设计出来的最棒的一个编程语言    
  
他认为 [所有计算机科学专业的学生都必须学会它](http://www.windley.com/archives/2006/02/alan_kay_is_com.shtml) ：  
> 大部分从计算机科学专业毕业的人都不懂LISP的重要性。 LISP是计算机科学里最重要的idea，没有之一。    
  
令人伤感的是，我的大学里没有开设这门课。不过因为学习新的编程范例并且探索不同的观点是提高开发技能很好的方法，我打算开始去学一学LISP！  
  
## Alan Kay 不为人知的一面  
我想以一些不为人知的故事结束这篇文章，这些故事是关于Alan所在的神奇研究团队背后的推动力，从大约40年前开始，他们在计算机科学前沿奋斗不止的目标是：  
> 为了帮助儿童–由此而到整个人类社会–学习和吸收“全面的科学知识”。    
  
这个目标要回顾远到1968年，当他第一次遇见 [Seymour Papert](http://en.wikipedia.org/wiki/Seymour_Papert) ，Logo语言（一种面向教育领域进行了优化的语言）的作者。  
那就是，看待如何运用技术来增强孩子们学习的能力。一种方法是教他们如何在软件里建造和模拟他们自己的真实世界模型，并让他们实验、修补、评价和观察这些模型的行为特征。  
一个目标是改变儿童接受教育的传统方式，不再给他们灌输事实，而是鼓励他们自己去观察真实世界的特征，让教师 [按看待有自己权利的物种的方式去看待孩子](http://www.donhopkins.com/drupal/node/140) ，  
> 而不是把孩子看作 ”必须通过教育来挽救的有缺陷的成年人“。    
  
这种有效的学习方法被称为 [建构主义者学习法](http://en.wikipedia.org/wiki/Constructionism_%28learning_theory%29) ， 由Papert在他1987年建构主义的出版物” [小学科学教育的一个新机会](http://nsf.gov/awardsearch/showAwardAWD_ID=8751190) “中定义。  
Alan在1968年就设想了 [Dynabook](http://en.wikipedia.org/wiki/Dynabook) 的概念，并在1972年一篇名为” [适合各年龄段儿童的个人计算机](http://www.mprove.de/diplom/gui/kay72.html) “的论文中发表了这个概念。这个项目早在1972年就引发了图形用户界面和Smalltalk的研究项目。  
在1995年他帮助建立了 [Etoys计算环境](http://en.wikipedia.org/wiki/Etoys_%28programming_language%29) ，这是一个富媒体创作环境（构建于Squeak / Smalltalk之上），用于帮助孩子们通过构建过程学习一些强有力的想法（powerful ideas）。  
在2001年他成立了观点研究院（the Viewpoints Research Institute），这是一个非盈利公众福利机构，致力于为全世界的儿童改善强有力的想法的教育（powerful ideas education）。  
在2006 — 2007年间， [给每个孩子一个笔记本](http://en.wikipedia.org/wiki/One_Laptop_per_Child) 项目为所有OLPC XO-1教育机器 [预装了Squeak Etoys多媒体创作系统](http://wiki.laptop.org/images/2/28/OLPCEtoys.pdf) 。  