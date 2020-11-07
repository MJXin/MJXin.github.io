---
title: 【负责 APP 组时】Code Review 执行方案
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
lightbox: true
pageview: true
tags: 工程专题
coding: UTF-8
---
要合并至 develop 的代码，需先发起 code review，review 通过之后再进行合并。  
在 GitLab 中，以 Merge Request 发起。并在 MR 中先详细描述此次合并的意图，以及任何你觉得需要说明的事情，如果需要也可以给出图例。  
  
## 审核流程  
1. requester 发起 Marge Request，并将 MR assign 给合适的人作为 reviewer  
2. 每次发起 MR，在群里同步发消息告知 assignee 及其他人，所有组内成员均可提出 issue  
3. assignee 收到 MR 第一时间 review ，以防耽误 requester 工作  
4. requester 有义务解释并解决所有 issue 及代码冲突  
5. assignee 在确认没问题后给出 👍  
6. 若没有其他 issue，assignee 的 👍 可以视为 允许合并  
  
  
## 评定标准  
* 没接触过相关业务的人能脱离业务读懂代码  
* 代码和逻辑组织能满足现有规范  
* 不影响其他模块  
  
为了以后及其他人维护方便，不推荐深奥复杂的代码，函数的细分力度尽可能做到函数名等同函数中的实现，达到其他人能在不运行程序的情况下直接理解。  
若 requester 不能脱离程序理解代码意图，可以直接提出 issue。  
  
  
## 评论准则  
Code review 难免会产生分歧或否定的评价，我们在评论中，应坚持以下准则（参考  [Thoughtbot Code Review](https://github.com/thoughtbot/guides/tree/master/code-review) ）：  
  
  
### 所有人  
* 接受许多开发中的决定都是基于个人观点的，面对选择的时候，应根据自己的偏好，讨论利弊，尽快得出解决方案  
* 使用提问语气，而非要求，如「你认为 :user_id 的命名怎样？」  
* 对于模棱两可的描述，要求对方明确，如「我不是很理解，你能再明确一些么？」  
* 不声明代码所有权，如「这是我写的」、「这不是我写的」、「这是你写的」等  
* 不使用指代个人特征的语句，如「愚蠢」、「傻 X」等。  
* 明确表达自己观点，需要记住在线上，不是所有人都能理解你潜在的意图  
* 不使用夸张、过度的语句，如「总是」、「绝对不」、「没完没了」、「什么也没有」等  
* 不挖苦、嘲笑  
* 最后要对讨论的结果进行总结。  
  
  
### 代码被审核  
* 不要个人感情用事，审核的对象是代码，而非人  
* 解释代码存在的原因，如「这些代码是因为 XXX，如果我把它命名为 XXX 是不是更清晰一些？」  
* 将一些代码的改动抽取出来，重构以便今后复用  
* 把审核的链接贴出来，如「请 review 代码： [https://github.com/organization/project/pull/1](https://github.com/organization/project/pull/1) 」  
* 在提交审核后，针对早先的反馈提交的代码，不要使用 rebase 、squash commits 将旧 commit 覆盖，应以单独的 commit 提交。  
* 回应所有需要回应的评论  
* 单元测试通过后再进行合并  
  
  
### 审核代码  
要理解这些代码改动的原因，如修复错误、提高用户体验、重构等，然后：  
  
* 尽可能去理解作者的观点  
* 只讲出你强烈想要说出来的意见  
* 确定代码功能完善并思考代码是否有优化空间  
* 如果讨论转变为过于学术，将讨论移至线下的技术讨论会。同时，让作者在众多方案中做出决定  
* 提供可选的实现方案，但预设作者已经考虑过这个方案，如「你觉得这里使用一个自定义的验证器如何？」  
* 审核结束，以 「👍」 或「准备合并」的评论结尾  
  
如果你对这份规范有不同的意见，请另起 issue 来讨论。同时，请遵循这份规范。  
  
  
参考：  
 [早期实施 review 规范](http://git.zerozero.cn/RN/Hover#code-review)   
 [Hover 开发中的 code review 建议](http://git.zerozero.cn/RN/WiKi/issues/7)   
  