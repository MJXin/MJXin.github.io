---
title: 附录-CodeReview：(团队共同关注的)代码逻辑 | 内容问题 211 条
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
picture_frame: shadow
tags: 工程专题 CodeReview 附录
coding: UTF-8
---
由于多进程的原因，这里的sInstance的赋值应该不止一次。

这个函数名看不出来是做的什么事情啊

"测试代码，建议放在同级目录中，以Test结尾。
另外，不是说测试代码就可以不要求规范，这里的测试代码应该是为了给后续的使用做demo。
所以还是尽量规范写法，包括log的tag，尽量便于track。"

"video 重复配置了吧，第六行也有相同的内容
我记得涛哥配过 develop 的 video 引用的"

"VIDEO" 还需要在 package.json的 jest 里配一下，否则某个 component 使用了 video 路径会引起 npm test 跑不起来

这的cache我可以理解为异步变同步处理，我的疑惑是：在调用get之前并没有调用init来初始化cache

这里是不是应该是 delete

这里是不是多了一个 return

FlatList加个keyExtractor属性， 不然会提示missing keys for items。

第一次点击，state应为true

"这里没测试进度条？
现在进度条的写法：
(this.props.itemObj.currentSize / this.props.itemObj.totalSize)
除数比被除数大或者其中一个为零或负数都有可能导致界面异常的"

"Component 内部要保证自己的正确性，对异常数据应该做过滤或者特殊处理。
而不是依靠外部数据的正确来保证自己正确。
另外这里缺的是两个：

进度条没有处理边缘情况。
进度条没有写测试。"

"Props 设计出来不是这样使用的
看这篇文章的最下面
props的只读性
这种写法会使得数据流向混乱，导致子控件和父控件相互影响的逻辑，这里逻辑比较简单还好，在一些复杂的 component 里采用这样的写法会使得任何一个值的改变造成影响都不可控。
另外在 component 内部修改 props 也不会触发重新渲染
还是建议用 callback 或 redux 实现"

"这里的接口AlertActionType只在AlertAction定义时用到了，
属性也在AlertAction里重新声明了一次，
后面的引用也使用的是实现类AlertAction，
那么这里这个接口AlertActionType的用意是什么呢？"

这个函数名字不太合适，看起来是通过 Date 获取 medias。 查询某个日期的所有 medias 的意思。

这里 style 改变的时候应该也是需要重新渲染的吧？

"看起来是一个 <View> 下面渲染了这个时间段的所有 cell。
那么如果一个时间点下面包含 1000 条数据， 因为这里的写法会全部渲染出来，是不是有可能会导致爆内存"

这个数据类型应该是一个枚举吧？

以上这些checkPermission可以放到 componentWillMount 去执行？

这儿还需要再裹一层view？给TouchableOpacity 设置style应该就可以了吧

"ConnectGuideTypeView 这个 Component 应该不属于需要判断的流程中的 Component， 连接飞机前的检测流程是从这个 Component 之后开始的
看起来没有继承 ConnectBaseComponent 的必要"

"上面这一批 render 函数，在 return 的 component 已经被封装起来的情况下看起来是有点多余的。
直接在 renderConnectPage 中将各自封装好的 component 返回就好了。
除非这些 render 函数以后还会需要在函数内部加入其它逻辑？"

NodeRequire? 替换成更具体的类型如：ImageURISource、ImageRequireSource

"key 属性是用于 render 返回一个数组时避免 React 警告用的。（因为 react 会自动给每个 component 加一个 key 用于标识 component，当有时候将一批 Component 放在数组中的时候  React 没法自动做这件事。所以需要人为传一个 key。）
这里没必要用 key 这个属性。"

key 和 testID ，复制代码时注意检查一下，把无用的内容去掉

"LoadingComponent 和 LoadingImage 都应该放在 根目录的 components 中
一个全局用到的组件内部实现却是一个局部的组件逻辑上也很奇怪。"

哈哈，这儿看起来又是多余的view了

和上面一样的问题，复制代码时注意检查一下，无用的内容删掉

这里定义的State好像没有用到

"这里加key的目的是区分多个按钮？
但是好像当前几个文件里使用到ZButton的key都传为0，那它能起到预期的作用吗？"

同上，当前的子界面的所有点击事件都没有主动触发Container传入的callback，那它与Container之间无法形成UI交互。

模拟延迟用setTimeOut的应该就好了，不用加一个定时器。

switch里所有的case都没有break

不留无用代码

不用的函数删了吧

同上，已经使用了props的callback，把各个子类Component之前定义的无用函数都删了吧

TimeOut的clear函数好像是 clearTimeout(timeoutId: NodeJS.Timer)

media 是 reaml 的对象，直接开放给外部修改会导致 crash 的

"Object.assign(mockMedia, {mediaID: tmpMediaID})
这么写会导致 mockMedia 这个对象地址上存放的值被改变的。然后其他这个文件里所有用到 mockMedia 的地方数据都是被这个地方修改过的值。
如果是要传另一个对象，应该写为 Object.assign({}, mockMedia, {mediaID: tmpMediaID}) 或者{...mockMedia, {mediaID: tmpMediaID}}"

这个文件里多处将不希望被修改的 mockMedia 通过 Object.assign 的方式修改了

"这么传值，前面的，会被 后面 mockMedia 的对应属性给覆盖的
{
      type: MediaType.video,
      state: MediaState.thumbnail
}"

这个变量后面好像没用到了

log 可以删掉

这两个 expect 是不是重复了

new Date(new Date().getTime())

"TouchableWithoutFeedback 不应该写在缩略图上，应该是一个独立的控件。
并且盖在 video 其他图层的上面，和 进度条同层级，或者比进度条低一个层级"

看起来 styles.centerBtnStyle 是一个只指定的高宽的绝对定位，加上后面的 bottom 也只定位了一个纵轴坐标，不定义横轴坐标没有导致界面排版出问题吗？

"renderCircleBtn里包含ProgressBar这样的处理方式是不是不太好。
直观的看上去应该有两种可能性：

布局放错位置了。
函数命名有歧义"

"这里建议直接使用expect(wrapper.instance().props.touchStart).toBeCalled.
因为代码逻辑的回调是回调到Props，这里先定义了一个mock函数的常量，赋值给Props-callback之后，断言直接使用了这个常量，但是存在常量被其他地方引用而导致当前单元测试存在隐患。"

这里变量backBtnIsPress应该只会在当前类操作而且也只与当前类有关，所以我不太理解定义成static的原因。

"reset 应该是一个PhotoViewComponent内部函数提供给外界调用，而不是 props。
类似 react-native-video 中 seek
this.player.seek(0)
因为 reset 对于 photo 是一个具体功能，而非一种状态描述。"

这个方法的作用是？忘了删..测试用的

这有两行一样的代码

一样的问题pressBack should be called when mock onPressBack function和pressCallback should be called when mock onPressNext function这俩测试，除了title不一样，测试内容是一样的

isShowLoading: true 和  isShowLoading: false 应该都被测试覆盖到

测试内容和测试描述不符

"测试描述是 when the props was changed
但测试的内容中，并没有 props 的修改"

克制 => 控制 ？？

ComponentProperties 内有个 style，这里又给一个 viewStyle 字段的原因是？

"按钮在 this.props.isDisable = true 的情况下应该修改 TouchableOpacity 的透明度。
没必要给 Image 两个不同透明度的 icon 和额外改 Text 的透明度"

AlbumDownload类的移动，忘了删除源文件

pause函数里的这句this.downloadTask = undefined，在cancel是不是也得有？

这儿的subscription.remove()只是针对上传成功/失败的时候remove掉了，是不是需要考虑下其它情况，譬如当前task执行到一半时意外中断这种情况？

这个类型报错,可以看一下

这个是render哪个页面的,好像没有被调用到~

这个expect用快照的话感觉不太好,可以用props去断言一哈子

title 用的应该是被处理过的 media.date, 而不是 media.name

this.props.media.type 存在为空的情况吗？

"onEnd 看起来是 Videoplayer 结束时的状态回调。而 Videoplayer 的控制方法。
主动调用应该是起不到停止视频播放的作用的。"

closeWifi 这个方法应该是不需要的。另外考虑到健壮性建议在使用WifiManager之前判空处理下，还有getPreConfiguration方法也处理下？

"有个疑问，如果
mWifiManager.getWifiState() == WifiManager.WIFI_STATE_ENABLING
这种情况(即wifi 处于 enabled & disable 临界点）是否需要处理下？"

这里 iOS 的权限声明应该是重复了的。。我在同一个文件里看到有几个权限被声明了两次

在openWifi() 之前是不是需要获取当前wlan的状态然后根据状态再处理？上面state中的connectState直接赋值ConnectState.NORMAL，我觉得connectState初始化的时候应该是获取到的wifi state。

".then((response) => {
        return response
      })这段代码的用意是？？这里已经返回了一个 response，然后这个 response 没有使用，又reture 给下一个 .then 了"

.catch 不是这样使用的， promise 只有一个.catch, 作用就是把流程中的所有错误归纳到一个地方

接口接收一个 media 对象即可

fs 中已经封装了 RNFetchBlob 的这些文件基本操作，建议直接调用当前类中的实现。

为什么AlbumState被注释掉了？不用了吗？还是之后要改？

看起来是漏删了测试代码？

hoverMedia.ctime -> new Date(hoverMedia.ctime*1000),飞机给的是时间戳

*'->'x',飞机的是'x'

AlbumDataManager 172行 删除单个media应该是缺少了删除DB的操作

MediaDownloadTask 114行FileType.Download 应该是漏改了

没有处理被除数(Math.abs(offset))为 0 的情况

JoystickTest 的作用是？有需要提交到项目代码中吗？

老哥，上面这些解析方法怎么都没在setCameraParam 中调用呢？另外当构建一个参数的时候需要调用 build()来完成构建。譬如下面

这个是测试代码还是？setUp() 不应该在这儿调用吧。

有个疑问，所有参数设置方法都加了id这个参数，其目的是？🤔️我觉得不需要吧，可以另开一个setCameraID的方法？

"setIso => setISO, 名词缩写保持统一，都大写或者都小写,
Promise<undefined> Promise 如果没有返回值可以写为 Promise<void>,
这个指令我记得是有返回值的，那个返回值是一个错误码"

eval => Number

"export function getIndexByEv(ev: number): number {
  EVParams.forEach((item, index) => {
    if (ev === item)
      return index
  })
  return 15
}
return index 是 (item, index) => {if (ev === item)return index} 这个函数的返回值。
这个返回值不会中断EVParams 的遍历。对 function getIndexByEv(ev: number): number 这个函数来说返回值永远是15"

"这个方法名称上看起来是拿照片分辨率的
但是返回的却是一个 名叫PhotoSizeOptions，实际上代表长宽比例的 enum。
名字和实际的返回值不匹配，比例和分辨率和尺寸不是同一个东西"

PhotoSizeOptions 不适合用于表示图片宽高比 Aspect ratio 更适合

这个函数的转换关系有点奇怪，从宽高的比例直接得出了分辨率

这儿直接 invoke（rc）是不合理的，原因不能跟RN层匹配。需要以map的形式传送，这是我的锅，我已修改。

"这里用 Object.assign({}, element) 的用意是？
之前应该是 Media 对象无法修改才需要 copy 一下， HoverMedia 看起来是没有必要的"

同上，直接将 element 放进数组即可

这里嵌了两个 reject，应该是我写错了

这个注释要取消掉

临时代码不要提交

调试 log 不要提交

RTPView 的 isStart 这个属性看起来没有任何作用，android端实现是根据这个值来开启预览流的，但实际上每次都是true，所以讨论下是否需要这个isStart

下载失败了页面中不需要做什么处理吗？

isDownloading 不是用来表示下载状态的吗？开始下载了为何被标为 false ？

这个属性看起来是不必要的，不显示的 page 不 render 即可。不走 Unmount 证明这个 Component 没有被正常释放存在内存泄漏

state 的数据需要从 props 转换而来，那看起来在 componentWillReceivedNextProps 中也需要做一样的转换

看起来 _zoomLevel 和 _rotation 都是可读可写的并且对外暴露的，这里写为 private 然后暴露 get，set 的目的在于？

this.props.deleteButtonVisible ? DeleteIcon : require('') 这种处理方式不会出现虽然没有 icon ，但是按钮仍然可以点击情况吗？

模块通用的常量定义写在其他文件中吧，index 中写这些常量容易引起循环引用

这里为什么将返回首页改为又跳转一个首页？这会导致栈里被压入多个首页的吧？

"key= ""Notification""  value=""Hover""
这个内容写入数据库看不出含义是什么。key 和 value 的内容都不适合，需要修改。
另外这个应该有办法通过是否获取过权限来判断。似乎不需要专门自己记录一份在数据库中。"

"key= ""Notification""  value=""Hover""
这个内容写入数据库看不出含义是什么。key 和 value 的内容都不适合，需要修改。
另外这个应该有办法通过是否获取过权限来判断。似乎不需要专门自己记录一份在数据库中。"

这儿的import看起来没用到？

上面已经写过一次 batteryInfo ，不需要再写一遍了哦

"这里要加系统判断，iOS 拿不到 wifi 强度。不会实现这个 module。
但是这里引用时若是找不到，会导致 iOS crash 的"

销毁呢？

"这里要加系统判断，iOS 拿不到 wifi 强度。不会实现这个 module。
但是这里引用时若是找不到，会导致 iOS crash 的"

测试数据？

"这一步不是很理解，监听的是数据库的插入事件（而非更新），那么对一个 media 来说。插入应该只会执行一次。
但是后面却又有这个判断，只有当前 task 是在更新数据库时才 addMobileMedias
if (state.stepType === MediaPipelineStepType.UpdateDataBaseMedia) {
    this.props.addMobileMedias([new MobileMediaModel(false, media)])
}
那么我理解的是，是否永远没办法执行？"

subscribe 时不将 error 和 complete 处理了，在报错和完成时不会出错吗？

"!(JSON.parse(JSON.stringify(this.props)) === (JSON.parse(JSON.stringify(nextProps))))
同样，不理解这个操作。先转为 json 字符串，再解析为对象。然后等式左右两边其实是两不同的对象，看起来是没有相等的情况的"

序列化又反序列化的用意是？最终是期望用什么结果进行比较？另外涛哥应该有提供过一个用于对象内部属性值比较的方法

这里的疑问和上面一样， 下载事件放在外面处理了，下载进度呢？如果是在里面。那么一部分放在外面一部分放在里面的用意是？ 创建下载任务的时候是可以直接拿到 task 用于使用的

什么场景会存在多次订阅呢？应该是只有一次订阅，即进入预览流subscribe退出unsubscribe ？。

这个setState没用吧

"这个『描述所有滤镜ID』的文件是不是可以不需要了？
RN 使用应该需要在 ts 里单独定义一份，
原生 View 使用可以直接用 aar 里的 FilterType.java"

这个countDownTimer是interval, 是不是应该得使用clearInterval

这个Adapter没有关联xml

为什么是定值呢？

调试的log都清一下呗

这儿应该需要的是Context吧

咦，怎么是个定值呢？

咦，怎么是个定值呢？

咦，怎么是个定值呢？

这个函数命名跟props有出入？

咦，怎么是个定值呢？

这儿需要判空处理下，如果没有调用setVideoCropRangeChangedListener会crash的。另外TimeLineSlider中还有些调试log顺手删下吧。

"有个问题讨论下。
我看获取缩略图有条件过滤，当前设置的videoID以及thumbSize<1时return掉这个逻辑没什么问题。因为有裁剪下一段视频这个需求，可能是VideoCropComponent不销毁，而是直接更改props也就是再给个videoId， 此时你已经把isFetchingThumb置为true了，所以就有可能在下个videoId进来后获取不到新的缩略图，是不是有问题了呢？
具体参考下图。
@MJXin 如果iOS裁剪组件不销毁只是更改videoId,会获取到新的缩略图么？"

这里的逻辑实现最好是明确在 fetch currentData 之后，而非估算一个时间，然后用延迟实现。

我也比较疑惑这个延时操作，为什么需要延时操作？ 延时100合适还是200合适还是其它值呢？

"this.state.showPlayer 用true``false控制 <Video> 和 <FastImage>。会不会存在缩略图隐藏后，视频还没加载出来的短暂黑屏情况？
之前写 DiscoverPlayer（网络视频） 时为了避免这个黑屏情况，在 <Video> 的 onLoad 被调用后才把 FastImage 隐藏起来。本地视频我不确定是否需要类似的处理"

"这里通过 onLayout 的方式获取当前界面的宽高会不会是好一些的方式。
style 并不具备对 width 和 height 的强约束，外面可填可不填（需要关注内部注释），并且会限制外界能采取的布局方式（只能用传入宽高数值的方式布局（flex等自适应方式不适用））。
用 onlayout 的好处是，不依赖外界传值(内部自己可以得出渲染后的宽高)，也不再隐性的需要外界必须通过设置宽高具体值的方式。"

usb 需要在进入连接页后就开始监听

componentwillUnMount 需要取消订阅

这种不需要的代码可以删掉

警告黄框提交的时候可以删除掉

this.connectSubscription 看起来在不需要执行 hover.connectState.subscribe 后也没用了，可以删掉

isHoverConnected 和 hoverConnectState目前看来是不需要再维护的,直接使用hover里的连接状态即可

HoverActionCreator 还在 Camera 模块中

"hover 被放入 store 后， network 模块不需要再自己维护 hover 的状态。
NetworkState 中 hoverConnectState 和 Action.HoverConnectStateChange, ActionCreator.hoverStateChange 和 reducer 中对应处理看起来都是可以去掉。然后使用 Hover 中对应状态的。"

"这里的业务要求应该是有对应的权限才可以进入预览流页面。
这句代码是测试时添加的漏删了吗？"

这里改了引用路径名字，但是文件夹名字还是appstate

在 HTLM 代码里这样的注释应该是会报错的

if 内的语句删除了，if 还留着

这里也是 if 内语句删了，if 还在

建议使用let代替var

debug 代码不要提交，主线编了会白屏的

这个页面里写了三个 console.disableYellowBox = true

正常使用情况是存在调用 recover 时，asset 已经被删除的情况的。

直接主线程发不合适吧。

socket建连异常不处理？

"咦，忘记quit这个thread了么？
正常来说start、stop是共存的
我理解的是进入预览流用户并不一定触发手动操控，即用户有触摸摇杆时才创建这个线程来负责发送消息比较合理，而不是线程创建好一直等着接收消息(创建好线程知道第一次收到消息这个时间段资源就浪费了)。当退出预览流要及时的stop这个线程节省资源。"

上面的代码要是不用了就去掉吧，代码里注释文件会影响阅读代码的。不建议代码里留一堆”可能“用的上的注释。

debug log

不留无用代码。。不过这里为啥把顶部导航栏去掉了

这个 loading 是为数据还未加载出来准备的，不一定是断网。改成这个文案在第一次开 app 时即使有网也会闪过一下

这可能是之前漏删的 log，一块去了吧

GCDWebServer 被注释掉了，主线还是要的

这里又把测试开关提上去了， 会打包流程出问题的，commit 前先 review 一下代码=。=

"jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@""index"" fallbackResource:nil];
被注释掉了，打包会无法运行"

GCDWebServer 被注释掉了，主线还是要的

此处存在类型错误

调试 log 不要保留，如果是要作为正式日志使用的需要在 log 内容中写清楚 log 的是什么

这里请求位置权限的执行方法有误 this.requestPhotoPermission看起来是请求相册权限的

代码中的所有文案需要用多语言实现，之后代码中不再用固定文案做占位符，所有页面开发时都要考虑多语言问题

这只是 APP 的状态改了，没改飞机的配置

"这个是需求确认过的吗？
另外不要这样做判断，在监听的地方判断"

这句可以不用了

tempTotalOffset = 是漏写了，还是等于下面的 singleSectionCount

"这里是 shouldComponentUpdate， 并且从判断条件来看 cell.offset.y < list.offset.y 时就不允许渲染了。
那是不意味着被滑到上面的， 如果之前加载了图片， 就没办法通过重新渲染图移除掉图片。无法达到动态区域渲染的目的。
下面的 renderThumb 限制可能因为 这里禁止更新而无法执行"

"感觉这个 list 的渲染频次好高。每次 setState 所有 cell 都会调用，然后又是 100ms 一次。。
不过一时半会想不到怎么搞比较好"

"既有 HorizontalScreenHeight 又有 HorizontalScreenWidth，是写错了吧。
另外这个其实没解决之前 issue 提到的问题  shouldComponentUpdate 返回 false 后， DroneListCell 就没机会将
FastImage 隐藏起来了，因为这里不让调用 render"

"timeoutIntervalForRequest 15 秒会不会太短了，建议 30 或者 60 秒
maxRetryCount也建议稍微调大一点"

APP 的版本目前有一个 getVersion 函数可以获取。 反而 package.json 里的版本号不会更新

这一行的条件是不是会让 cell 在 list滑动速度 > 10 时一直 render？

为什么要 scrollView 嵌套一个 SectionList，SectionList本身就是一个 scrollview

return secondsDiff > threshold

Debug log?

"而且不建议直接代码里引用原生 module，而是用桥接类开出接口实现。
一方面是 naive 与 ts 对应不上，没有接口提示。
另外业务类直接引用也会导致一旦 HapticsFeedBack 需要修改或者处理问题，很难维护"

这两我没看到有销毁

"CameraSettingContainer 在预览流期间应该是不销毁的
这个情况下要把 this.needRestartVideoRecord 改回来，不然下一次打开他又重启录像了"

这里根据sim卡所在地区判断语言会不会不太好,根据手机的系统语言来显示会不会好点呢

多语言

多语言

多语言

这看起来应该返回 task？（比如说 task 其实还没结束，但是这里直接返回路径就相当于告诉外界 downloadHC2OtaPkg 直接结束了）

"看下面的逻辑，我理解是如果

不存在 task 则创建一个新的，然后判断空间，执行start，之后 resolve(info.filePath)。 这个流程正常。
如果已经存在一个 task， 会再一次new 一个 proimise， 再一次判断空间， 再一次 start。再次resolve(info.filePath) 这个逻辑感觉有问题。

我没看全局调用，但这个类中，如果外界可能调用多次的话，会有这些隐患：

外界可能持有多个 promise
task 可能 start 多次（得看下内容 start 会干什么，才能知道影响）
外界可能.then() 多次

会不会出问题取决于外界怎么用，以及 task.start 怎么实现"

这行代码目的是？感觉会有问题啊。。如果没心跳时动了摇杆

debug 代码

这多了个 string 类型

Debug log？

函数内部加一个平台区分吧，不然这个函数一调用 iOS 就 crash 了

"需要考虑中途离开页面的情况， 得有个中断标志。
另外还有可能重复触发 retryFetchMemoryInfo"

Debug

"这个 Falcon 下是否也直接用 this.props.connectMode， 这样类型也是正确的。
并且昨天接到个奇葩的需求， 有考虑给特殊用户提供 4G 版 Falcon"

离开页面，这个监听需要取消吗

经纬度存在负数的吧

会不会越界？

"上面的实现能否一块修改一下， 之前是因为底层没有计算，所以在这里用定时器处理了更新问题。
现在底层加上后，上面的这些代码就没必要了， 写 log 也可以改成收到通知时写入"

可以直接绑 LeftButtonContainer 里

debug log？

catch 内调用了 return 会自动走到下一步 then 的，这里有可能导致 startDroneThumbDownload 被调用两次导致出现两重递归