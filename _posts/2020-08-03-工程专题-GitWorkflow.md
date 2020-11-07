---
title: 【负责 APP 组时】Git Workflow 执行方案 (工作流程)
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
lightbox: true
pageview: true
tags: 工程专题
coding: UTF-8
--- 
![](/assets/images/工程专题/gitworkflow.png)  
<!--more-->
## 分支策略  
### 发布分支 - `master`:  
对应线上版本，只允许 `to_test` 分支在完成测试后, **由测试人员通过 CI 合并**, **不允许其他任何方式修改**。  
CI 会 Track 发布分支, 当发布分支有更新的时候, CI 会按照发布配置重新编译, 并且发布到对应的平台如(App Store 和 Google Play).  
  
### 开发分支 - `develop`:  
项目主分支，功能开发的起点。 **所有新功能, 都只能基于此分支创建**。  
功能分支的代码，需要通过提交 Merge Request 的方式, 在审核,测试后合并。  
**不允许直接提交未经审核的代码**。  
  
### 测试/预发布分支 - `to_test`:  
每次准备发布, 当前发布版本的固定提测分支。 承担提测, 修复功能 bug 及 master(线上版本) hotfix 职能。  
准备上线时，会同步 develop 最新代码.  
  
QE 测试过程中，本次版本需要修复的 bug 应该 **只从 to_test** 切出(`git checkout -b fix/xxx`)后进行修复。  
QE 测试完毕后，合并入 `master` 用于打包上线发布。同时合并入 `develop` 便于将所有的 bug fix 更新进开发分支 。  
CI 会 Track 测试分支, 按照测试的配置进行编译，发布到测试平台进行测试。  
`develop` 可以根据需要, 经常同步 `to_test` 分支的代码, 但是 `to_test` 不允许 merge `develop` 代码。  
  
### feature/分支：  
用于开发新功能， 避免个人名字命名, **仅允许**从 `develop` 创建, 命名方式为 `feature/xxxx`  
`git checkout -b feature/xxx`  
  
feature 分支建议每日同步一次 develop 代码, 在功能开发完毕, 并经过**审核,测试后** 才能合入 develop  
  
### fix/分支:  
改 bug 时创建的分支, 可根据需要从 `develop` 或 `to_test` 创建.  
  
  
## 开发流程  
  
* 不建议用自己的名字作为分支名, 我们不宣誓代码的主权, 一个功能分支应该在需要的时候, 允许其他人修改代码  

### develop  

1. 从 develop 分支创建新 feature 分支（`git checkout -b feature/xxx`），用于功能开发  
2. 在 feature 分支中提交当前 feature 的 commit， 标题和描述中要求阐述当前 commit 具体做了什么  
3. 功能开发完毕后，在 gitlab 上创建 merge request， 要求 Description 中描述新增的内容  
4. 代码涉及到的所有相关人员做 review， review 通过后 comment 👍  
5. 测试人员基于 feature 分支验证功能完善性， 验证完毕后 comment 👍  
6. 功能开发者在解决所有 comment 后，执行 `git rebase develop/git merge develop` 解决与主线的冲突  
7. 处理完冲突后点击 merge 按钮  
  
  
### to_test  
1. 需要提测时从 develop 分支创建新的 to_test 分支  
2. to_test 分支原则上**不允许**添加新功能  
3. 测试基于 to_test 全面测试 bug  
4. 开发人员从 to_test 创建新的 fix 分支（`git checkout -b fix/xxx`）用于 bug fix  
5. bug 修改完后，在 gitlab 上创建 merge request， 要求 Description 中描述修改的内容  
6. 代码涉及到的所有相关人员做 review， review 通过后 comment 👍  
7. 根据情况, 与测试组协商合并后整体测试或者测完再合并; 无特殊说明情况下, 需要测试人员 comment 👍  
8. 功能开发者在解决所有 comment 后，执行 `git rebase to_test/git merge to_test` 解决与主线的冲突  
9. 处理完冲突后点击 merge 按钮  
10. to_test 分支在回归测试完毕后，develop 分支需要同步 to_test 代码  
  
ps1. 测试人员每日使用最新的 to_test 测试  
ps2. develop 需要定期同步 to_test 代码，保持两边代码同步；to_test 不允许合并 develop 代码， 避免在提测分支中引入新功能  
  
  
### master  
1. to_test 分支回归测试完毕后由机器 master  
2. 线上版本遇到问题，需要 hotfix，则需要从 master 中创建 to_test 分支。  
  
