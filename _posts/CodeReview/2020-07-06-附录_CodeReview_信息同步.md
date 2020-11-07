---
title: 附录-CodeReview：(团队共同关注的)信息同步 46 条
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
lightbox: true
pageview: true
tags: 工程专题 CodeReview 附录
coding: UTF-8
---
## “实现过” 信息同步
* 这两个常量在 ViewGeometry 中有，并且也不适合放在 PlatformUtil 中
* ScreenWidth 从公共类中拿吧，我记得上午海波合并的分支里已经写好了
* 。。尝试一下 ZButton 吧，我在 Camerapage 看到很多重新封装但其实渲染内容基本一致的按钮，其实都是可以直接使用现有控件解决的。
* 同上。。。这种重复封装的按钮在 CamerPage 中出现的比较多。都是价值不大的工作量。建议SceneSelectButton内部直接用 Zbutton
* 这个不是已经定义过了么？ ConnectMode
* MobileLocal 被我移除了，getLocale() 函数合并到 DeviceInfo 类。这个类是专门用来桥接设备信息接口的。需要 Android 改一下
* "AlbumPage 中已经实现了 connect 函数，用于 AlbumPage 函数与 dispatch 之间做映射。
这里的 store.dispatch, 建议改为 mapDispatchToProps"
* 这个proto已经提供了获取enum的方法,不用判断,WifiFreqMode的forNumer应该可以实现
* 我记得之前有个现成的 loading component
* "我在这个分支中 cherry-pick 一个 usb 分支的修改。 修改内容是将 ev 值处理成字符串，避免因为浮点数精度异常导致无法对应值的问题。
* 现在 ev 值可以正常的显示"
* 我记得赵昭有提供过一个一摸一样功能的东西，对比固件版本用的
* 我记得 Android 两个 view 已经同步成一个了
---
## 信息
* 这个值设大一些吧。 我昨天视频进度更新频率做了验证， 10ms 的视频进度更新，对 CPU 压力很大
* 我之前引入的design包里应该是有rv的，可以不用重复依赖的哦
* 滤镜列表receiveEvent有问题，这个裁剪框也会有同样的问题嘛？
* 里面有 battery 相关的状态和 reducer，之后合并时会和通用设置分支冲突，因为通用设置中需要所有电池信息，会涵盖这种情况。使用通用设置分支的修改就好了。
* "个人认为到现阶段RN的性能已经严重影响艾普的体验了。
类似于这种条件过滤目的是避免执行不必要的渲染(可能不渲染但我理解的是会遍历相应的view节点)所以在代码层过滤我觉得是有必要的。"
* "我之前遇到过一个 bug，是离开预览流后没有重置预览流状态导致的。
这里做个假设，如果我在锁定人的时候，点了返回首页，再进来， 这个值是 true 的话会不会异常？"
* 需要测试一下 iOS，在 iOS 中 onScroll 和 onMomentumScrollEnd，onScrollEndDrag是有不同职能的。 onScroll 每次都触发，但 onMomentumScrollEnd 只在有加速度的时候， onScrollEndDrag 只在手指松开后触发
* "alert 是系统弹窗，此处如果不是作为调试代码，可以使用 modalController/index.ts 中的 addSingleButtonAlert。
这里面管理了弹窗图层和队列逻辑，会让弹窗按队列顺序弹窗，"
* 关掉的原因是？这个关掉会让最后差一些像素时直接跳一下到对应位置而不是顺滑的移动过去
* "这个逻辑其实相当于用户没有摸摇杆时会一直给 Native 发消息。 之前的逻辑是用户松手后就 unsubscribeJoystick。不再一直发消息。
感觉现在的处理会比之前调用率高很多，rn 的 js 线程其实挺影响性能的"
* "考虑 usb 协议，业务层不直接使用 hoverCommunicator， 而是调用 wifi 和 usb 之上的封装层
现在应该有个现成的叫 HoverCommunication"
* "因为我们的通信方式既有 USB 又有 RPC， 封装接口时需要在 USB，RPC 之上再封装一层。  业务中中不直接使用hoverCommunicator&usbCommunicator
GES 对应的接口放在现有的 HoverCommunication 中比较合适
ps. hoverCommunicator 是早期的命名，之后会改成 grpcCommunicator，暂时不用纠结与 HoverCommunication太过相似的问题"
* 此处同下面对 hoverCommunicator 的评论， 业务中建议使用上层封装 HoverCommunication。 隐藏 RPC 和 USB 的具体通信细节
* "CameraServices.services().dealWithVideoAction() 中有对 isRecording 的判断逻辑。
CameraServices 处理了相机相关的业务， 这个点戳在 CameraServices 中感觉比戳在页面中合理些"
* 考虑存在在预览流中切换连接模式的情况，willReveiveNextProps 中也要做处理
* iOS 下载到沙盒可以不用申请权限，如果 Android 也不需要的话可以不申请。
* trackableTargets trackingTargets 没记错的话其实一直在跳变，感觉可能增加了 json 序列化的耗时，并且每次数据还都不一样
---
## 产品
* 有个问题需要同步下，当前实现的AlertControlView 基于Modal，当view弹出时附带会显示StatusBar，这应该和UI设计是有出入的。。
* 新跳转的页面需要监听下Android 物理返回键事件。
* 这个功能需要加个判断， 在 Falcon 下禁用

## 合作交流
* 关于这个状态定义，Android对应这样的状态，那iOS的状态是否对应？
* 这个需求是有明确要区分 android 和 iOS 吗？。。看起来 android 实现了长按而把 iOS 过滤了
* "有几个问题补充下。
1、在大小地图切换后，此时预览流的状态是怎样的？比如Android的TextureView，更改了style后surface怎么变换？TextureView渲染是否正常(MediaCodec按1280*720解析的)？是否需要给TextureView重设Matrix？总之，我觉得这个切换动作不仅仅是更改style
2、LeftButtonContainer里的逻辑有点儿乱，帮忙理下你的需求，我来改一把。
3、地图mock的经纬度数据可以改成系统定位的经纬度么？我觉得这样比较合理，后续也不需要更改这个mock数据了。"
* 下面的Orientation.unlockAllOrientations()按我的理解是不需要的，你顺手删了
* 我回放页写个这个东西了，你copy一下
* 昨天更新了上面四个接口的返回值(void -> bool)，麻烦把iOS的补充下，RN的我来
* "这个 mr 中我还实现了一个 NativeUtils， 通过 filename 和 filteType 获取包文件中存放的东西。
Android 的没看到有相关代码，看需不需要补充一下"
* 这个duration我们应该怎么约定呢？ 是以秒为单位还是那鸟？
* "对了，有个问题还需要确认下。
裁剪框下面的缩略图list是否能滑动？显示多少张？每张宽度怎么定义？等。
看当前你实现的方式应该是能滑动的，我记着之前家欣有说不能滑动，需要你们同步下哦。"
* 对于异常的两种错误归纳，建议和刘瑞那边的其他错误归纳等，采用同一个规则。 这些判断不要写在 container 中。应该有个专门的规则转换或者配置类处理
* "问问刘森能不能加一下 usb.proto， 把 usb 的接口一块做了吧。
现在 usb 模块在主线，做接口时得考虑下 usb 的实现"
* 这里我写死了connect type 为frp,是否需要根据某些条件去设置type?
* "考虑之后处理源视频外其他文件也会写入系统相册的原因（比如编辑过的视频）
这里还是把 MediaHelper 中 isiOSSystemAlbumMedia 函数开出来，放这里用吧。
不然加入了其他放系统相册的资源又会出现弹两个窗的问题"
