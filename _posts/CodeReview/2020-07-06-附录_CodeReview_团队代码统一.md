---
title: 附录-CodeReview：(团队共同关注的)团队代码统一性问题 46 条
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
lightbox: true
pageview: true
tags: 工程专题 CodeReview 附录
coding: UTF-8
---

* 建议将 Camera 地址配置进 `..babelrc``tsconfig.json`，并仿照其他模块的写法
* 提交的代码中不建议包含测试代码，页面测试需要可以只留在本地不提交 (这个修改会给其他人带来冲突）
* 像这种根据其他变量改变的 style，定义一个变量写在 render 中，然后此处直接用变量赋值是否会好一些？ 这么做的目的是让 component 中的代码看起来更简洁。防止在 style 比较长的情况下，影响代码阅读
* 可以直接写成onTouchEnd=this.touchEnd的
* 非模块的文件夹名字默认用小写（如api、utils等），文件名开头默认用大写
* style统一写在外面const里会不会好些
* 路径改成定义好的 'SETTING/XXX'吧，之后 Setting 可能会修改。写成相对路径每个文件都需要修改
* 建议将 「地图初始化」 和 「地图初始化1」 squash 在一起，
* 加入了自己的 logger 库以后，NSLog 就不要用了
* "建议所有接口都不用 pathType，而使用 string 类型的 path 来做入参。有两点原因：
* 在函数调用的时候需要先去生成一个 pathTpye 很不方便， iOS 和 Android 的 path 是肯定不同一的，如果要添加一个path，需要同时添加 iOS 和 Android的，再例如 iOS 是没有 crash这个 path 的，这样以来这个函数的调用成本就会很高，最后会变成所有的文件操作都会调过这个接口直接调用 RNFetchBlob 的接口。
* 另外我觉得比较好的时候 iOS 和 Android 会各自维护一个 path, 可以这样调用："
* 调试代码不要提交
* 枚举首字母大写
* 代码中不要留多余空行，有需要分割的地方空一行就好了
* 缩进
* 直接写为onTouchStart={this.resetInterval} 就好了
* """测试代码，建议放在同级目录中，以Test结尾。
另外，不是说测试代码就可以不要求规范，这里的测试代码应该是为了给后续的使用做demo。
所以还是尽量规范写法，包括log的tag，尽量便于track。"""
* 为了测试方便以后 Component 的 Porps 可以继承一下 View 的 Props: ViewProperties。 其内部提供了style和testID`
* Welcome 的路径配置一下，不同模块间引用避免相对路径，因为不利于以后维护
* 定义放到文件最上面吧。。方便查看（放在实现代码最上面一眼就看到了。。放在中间很难知道要翻多少行）
* 样式统一封装在 styles 中
* 无用的代码删掉吧
* 我们将所有导航栏统一命名？
* 图片的require命名可不可以考虑用imgXXX的形式？当前的命名方式不是很容易做到见名知意。
* PermissionView 这个文件作为一个多个模块用到的公用 component 建议放在根目录的 components 文件夹（这个目录放所有公用的 component）下。
* 临时代码建议在注释上写为 //TODO: 之后改的时候全局搜索 TODO 可以知道哪些是没完成的。写成普通注释容易遗漏
* 变量名首字母大写很容易引起歧义。
* "界面的重排序不应该是各个子界面的点击事件触发的吗？
  为什么会是主页面接收到Props的时候？
  而且这里的Props是空的。"
* "这个换行建议改为
```tsx
<Text testID={'topCountdown'}style={styles.timeTopStyle}>  
  {TimeFormatter.secondFormat(this.countdownNumber)}
</Text>"
```

* 建议重新命名，onWifiConnectionPress ?
* 默认值建议提成常量摆在文件最上面
* 既然已经定义了style的常量值，把这里固定的style样式也移到下面统一放一起吧
* "约定俗称的 TODO 注释方法： //TODO:这么写大部分编译器都会做高亮处理"
* ActionType 默认使用全大写
* MapCovertUtils 可以放在 Camera/utils 文件夹中
* 地址包装为一个可接受入参的函数常量然后放在文件最上面会比较好一些，方便维护
* "PlaybackPage 放在根目录与 CameraPage 吧，我们统一把每个模块的 page 放在根目录。
* 另外回放页似乎没有使用 redux，使用的是逐层传值的方式做状态管理？"
* 捎带手格式化下把老哥，😂
* currentListIsEmpty hoverIsConnected 布尔值以 is 开头
* editEnable => isEditable
* 这里的 style 没有用到临时变量，统一封装在 styles 中。 下面的 style 也是。
* 看起来是 Android 专享？是的话加个过滤，并在 iOS 调用是打个 error，不然之后其他人维护就不知道了
* 类中函数建议分类写好，render 函数放一块，功能性函数放一块，回调放一块， 公有私有静态和成员函数等都组织好，避免互相掺杂
* 统一一下格式
* "我在这个模块的代码里看到很多种不同风格的 log 了。。
* 建议如果是作为正式 log，就把模块名和具体内容带上，风格统一一下，如果是 debug 用的就去掉吧"
* 为了让别人知道这个currentAppState 是干嘛的，建议写出准确的数据类型
* ”代码里建议统一用 react-redux 的 connect 函数
（ps.直接 dispatch 在代码上 ok，主要是之前都用的 connect 统一一种对其他人维护开发比较好）"