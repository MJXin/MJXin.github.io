---
title: 附录-CodeReview：(团队共同关注的)共享经验 7 条
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
lightbox: true
pageview: true
tags: 工程专题 CodeReview 附录
coding: UTF-8
---

* 安卓的 <Image> 有严重的性能问题，不建议使用。

* 建议尽量不要使用 null, 可以查一下 null 和 undefined 的区别
ps.一篇文章供参考Null and Undefined

* ~有空可以了解一下 git 如何提交部分文件 Commit only part of a file in Git~

* 了解一下 realm 对 write 的描述realm-write
> Note that write transactions have a non-negligible overhead; you should try to minimize the number of write blocks within your code.
realm 出于性能及安全性等考虑，对数据库的处理其实是在内存中维护了一份数据库的映射。
所有 realm 的数据库操作其实都没有直接操作数据库而是修改的内存。
这些数据会在用户将所有操作执行完，并向 realm 提交时才会真正执行。
write 函数就是 js 中的提交操作， 里面可能会涉及开辟线程，数据加锁，I/O 等行为（realm 没有具体描述 write会做什么，但他指出了这个操作存在不可忽视的性能开销）。
这里比较好的写法是：
```tsx
static deleteMultiMedias(mediaArray:Array<Media>) {
 realm.write(() => {
    mediaArray.forEach((media)=>{
      realm.create(Media.name, {mediaID: mediaID, isDeleted: true}, true)
    })
  }
}
```
而非频繁的调用 write

* 这里单纯使用 mkdir 可能无法保证文件被正确创建。
两个原因：
如果是嵌套目录，mkdir 并不能满足需求，需要使用 mkdirs；
这里的 savePath 可能没表述清楚，应该是 xxx/xxx/xxx.mp4，所以在 mkdirs 之后仍然需要加上 createFile.
上次你提醒我event.getNotify()里面实现肯定非空的,下面的非空判断没意义,应使用event.hasNotify()判断 =_=
不如试试 getDerivedStateFromProps
UNSAFE_componentWillReceiveProps 被 React 标记为准备废弃的接口，之后应该是会去掉的，可以学下新的生命周期用法
