---
title: 附录-CodeReview：(团队共同关注的)代码设计优化 232 条
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
lightbox: true
pageview: true
tags: 工程专题 CodeReview 附录
coding: UTF-8
---
settingItem switch , message , arrow 三种 item 建议来继承同一个父类来实现，在 content 数组中使用一字段来指定哪一种。这样的好处是不用维护选择的逻辑，降低三种item之间的耦合。例如 arrow 样式更新了不会影响到其他的种类

建议单独写个获取cache-size的方法。

建议自定义Closeable的接口实现，将流的关闭统一封装。避免之后的每次I/O流操作都要写close的try...catch...

"1.下载状态不应该由ProgressListener来控制。
2.对于不需要关心下载进度只需要关心是否下载成功的业务来说，这个

下载工具类不具备此功能。
建议将下载状态和下载进度的回调进行拆分，另外下载进度的回调与否设置成外部可配置。"

"这种写法倒是可以不必手动close，但是结构不好看。
不过我上面的comment是指对Closeable的单独封装，还是有finally，只不过close的try...catch...被统一封装在了自定义实现类里。"

"对于base-url相同的是不是可以建立统一的Builder？
建议加一层封装，对于调用者来说，不需要每次都关心OkhttpClient的创建。
只需要传入对应的已封装的params。"

函数命名有歧义。isxxx的返回应该是个boolean值，为什么还要跟0比较大小。

"这里对该标签值的存储，目前没有被调用。
我理解的是，为了之后Settings-AppUpdater的ui提示预留的。
这种预留功能建议加注释说明，它与当前review时的功能无关，会给其他review的同事带来困惑。"

这里有很多include，写一起是否会更好点呀

是指单独提出文件管理include吗？ 但是settings.gradle本身就是对include的封装，而且它也只做include项目管理这一件事，感觉没必要再给它封装一层。 build.gradle里把dependencies单独拿出来封装，是因为dependencies本身太多，而且它只是build.gralde的一个子功能。

建议添加 exist, mkdir 

为了方便管理，项目内部的module依赖会写在一起，项目外部的module一般单独声明文件目录和导入。

有没有办法把 progress 封装在接口中，不用 Emitter 来实现，例如 这个库 的类似这样的接口：

建议尝试用callback代替Promise+Emitter

这里是不是一定要用可变参数函数

something 是指什么？

"ios和android的文件所在目录不一样 这个看起来使用一个叫 path 就可以实现，没有必要使用可变参数。
另外 AliyunOSS:NativeModules.RNAliyunOSS 作为一个桥接原生的类的接口，在 iOS 这边来实现的话，我怎么知道 args 的个数和每一个是是什么意思呢？"

这儿的exception判空处理逻辑不太合适吧？并且这么多log除了debug外没什么意义

因为NativeEventEmitter同时支持Android和iOS的事件传递，所以之后我们尽量统一使用NativeEventEmitter吧，避免过多的if...else...的操作平台判断。

这个类里有好多字符串的直接引用，建议声明成常量，避免写错踩坑，同时提高代码的可读性和维护的便利。

函数名建议是描述这个函数做了什么事情，而不是一个看起来像一个名词。所以函数 ossUploadManager 建议改名，例如改为 ossUploadFile这样。另外类名或者是文件名最好是名词而不是动词，例如：Upload.ts 是动词，最好改成名词，例如改为 OSSUploader 这样。

"NativeEventEmitter尽量指定要监听的具体的NativeModule，比如这里已经声明了
const AliyunOSS = NativeModules.RNAliyunOSS，
那么直接在 NativeEventEmitter 的构造里传入 AliyunOSS 即可。"

这里circleMarginLeft是个常量，建议极限值也写成常量吧，避免每次执行都要获取和计算。

video 控件内部不应该管理全局的 StatusBar

这部分代码重复了两次，描述的其实是一个进度条的控件，可以考虑抽出来，多写一个 render 方法或者独立 component 都行。

"不太理解为什么用这个逻辑判断横竖屏,并且不是写在 state 中，即使宽度改变了也不会导致界面重新渲染。
我觉得用一个枚举或者布尔值之类的暴露出去，由外界根据具体情况设置 videoplay 的横竖屏样式可能更好。
videoplay 本身能展示不同的样式即可。什么时机展示什么样的样式不太需要关心，可以交给外面设置。"

HomeNavigator 建议在同一个目录新建一个HomeNavigator.tsx,然后把相关的引用和逻辑都移过去

这里可不可以区分一下 Release 和 Debug 模式，或者有没有办法 guard 一下避免后面忘记替换这个视频了

这里的返回值改为string | undefined 含义比较准确一下

进度条可以单独封装为一个 Component

这里改 props 了，props 定义是外界传入的参数。 这里的修改不太合适，如果是需要修改数据源，可以考虑用 callback 回调给上层进行数据修改。也可以用 redux 发送消息全局修改数据。

不建议采用 index 的方式找 Component，之后界面稍微改一点导致 Component位置变了，这个测试就要修改。
react 有给所有的 Component 一个属性叫 testID，可以使用那个

同上，建议用 testID 找 Component。
这个断言太不可靠了，这个 Component 以后要是需要加一个TouchableOpacity就会导致这个测试不通过。

写代码时尽量避免太多层级嵌套，容易造成阅读困难，写成这样是不是更好一点？

ShareResult 看起来作用是写在回调中给外界使用的。（应该是 react-native-hc-share 内部使用的类？） 但这里的 'fail' 50011等外界都无法直接处理。 能否再封装一层，或者简化一下（比如将错误码封成 enum，'fail'改为 boolean）然后再扔出去给外面？

"上面这一串按钮不太适合维护和拓展
举个例子：

上一代的需求中有需要根据不同国家变更分享按钮顺序的。
不同的内容需要显示的分享平台可能不同（视频显示youtube，图片不显示）

用上面的实现方式需要把所有可能情况都用 HTML 描述出来。
建议使用 SharePlatform[] 维护 ShareView 的按钮显示。
不同的需求对应不同的 SharePlatform[]。
然后在 ShareView 中提供 SharePlatform -> Icon, SharePlatform -> PlatformTitle 等功能。
之后用遍历 SharePlatform[] 的方式生成不同的 ShareButton
renderShareButtons =() => {
  return sharePlatform.map(platform => <ShareButton icon={icon(platform)} onclick={() => this.shareSingleRes(platform)}>)
}
 可能还需要给每个 button 加个 key，不然会报警告"

这部分代码重复了两次，描述的其实是一个进度条的控件，可以考虑抽出来，多写一个 render 方法或者独立 component 都行。

"我觉得底层实现的灵活性和可定制性很高，没什么问题。
可是对于横向定高的Alert来讲，最多存在两个Button。
现在从调用者的角度看，却需要关注Actions数组和数组内部对象字段的构成以及编写传入。
个人感觉当前对外的接口暴露形式不是很友好。
建议在底层实现和调用者之间加一层接口调用，单独封装「单按钮」和「双按钮」的实现，调用者只需要传入Button的title和handler，内部数据的包装由接口层来实现。"

"看起来是在对一个 media 做 copy？
可以试试 Object.assign({}, media) 或者别的复制对象的方法"

"建议不要写成一个类，如果需要调用时有个命名空间有两种方式：
直接 export default {secondToString, secondFormat}
用一个namespace 包住 {secondToString, secondFormat}"

`<Text >` 是可以接受点击事件的，TouchableText 可能不太必要

"这种对象比较的方式不太好。相当于把对象的属性拆出来一个个比较。
问题在于，如果以后 props 字段增加了，就需要在这里再维护一次，并且这两者间没有东西可以保障。很可能会出现 props 字段增加了，这里忘记添加的情况。
应该有更好的对象值相等判断方法"

"感觉上面这段阅读起来有些困难， 分成几个独立的 render 函数会不会更好些
类似于
```tsx
<View>
  {renderImageBackground()}
  {renderText()}
  {renderImage()}
</View>"
```

"list 不建议直接拿屏幕宽度。
list 的上一层容器是 page，其 size 由 page 控制。逻辑上和屏幕大小没有直接关系，也不直接接触最外层屏幕
建议通过 onlayout 拿到 list 的 frame，使用里面的宽度在这里进行计算。"

这个函数看起来和成员变量没有关系。 可以定义为类方法

"这里可否定义一个公用的基类Props？
eg：type BasicProps = ViewProperties & StoreProps
之后的每个ContainerProps继承BasicProps，
不用每次都手动加入store?: Store，也不会因为加入单元测试代码而影响当前代码阅读"

"那看上去也不用继承ViewProperties里面的一大堆可选属性了。
如果大家觉得这种Props的基类定义可行的话，
那改完之后我们统一修改下已提交的Component-Props定义(或者只修改显示声明了「testID」和「style」的Component)，
然后各自分支merge一下develop分支，尽量保证风格统一。"

"[赞]
style的泛型建议写成StyleProp`<ViewStyle>`，以便接受一个数组作为入参。"

这里的Props也继承之前定义的基类Props吧

"这里控制消失的时长可否对外暴露？
参照一代App业务举例：
普通的Toast一般展示1s，
有的需要用户特别注意到的Toast信息需要3s。
可以考虑作为可选参数传入，也可以对外暴露两个不同时长的调用函数。"

"我觉得这个toast的表现形式不是特别合适。😹
Toast是一种轻量级的反馈提示方式，我看到实现方式是在屏幕中间显示，可以理解为一个没有action可自动消失的Alert，这样功能性有所重叠。我认为应该暴漏一个 ‘gravity’，这个gravity 有 ‘center’、‘bottom’ 可选来确定Toast位置，像style就不需要暴漏了。或者说直接使用ToastAndroid ？"

上次家欣应该是加了Component和Container的Props基类，如果有用到styles或者testID的属性，可以直接继承。当前继承系统的ViewProperties会有很多用不到的可选属性。

上面几个权限申请按钮： 相册访问权限，相机访问权限，位置访问权限，蓝牙访问权限看起来是一模一样的Component，可以考虑封装起来

"文字的样式应该都是统一的，有权限的时候 'rgba(255,255,255,0.32)' 无权限的时候 '#FFE100'。这段 ui 上的逻辑交给 PermissionsTextItem 内部管理会比较好。  
而希望把这个 component 封装起来的其中一个原因，也是因为这些文本是一类具有相似行为的 text。  
1.第一次写的时候这些文本有共性： (点击后处理类似事件，有权限和无权限都要显示不同的文本和颜色)  
2.是以后维护上，需求修改具有统一性（位置权限的文本样式修改了，一般其他的权限样式也会做相同修改）  

基于上面的原因，文字颜色根据不同状态做不同的修改，应该由 PermissionsTextItem 内部管理会更好，甚至 text 也可以这么做。 外面的容器不处理什么状态显示什么文本，只将文本传进去。不同状态的不同文本，不同状态的不同颜色由 component 控制（当然，这个细节太小，在这里怎么写都可以）"

"尽量避免这种 commit messageeb245281 - 修改mr,discussions
commit message 应该写的是代码做了什么修改，主要描述代码上的变动，而非为了什么而做的修改。
这样的 commit message 是没法看出代码改了啥的"

这可能会是一个之后 app 中通用性比较高的 component，可以考虑抽出来放在最外层的 components 目录下

"我觉得wifi连接可以脱离业务来做，wifi的数据类型建议明确下。
拿android来说连接wifi需要wifi的SSID还有psw，而不是单申明wifiName。"

"AlertControlView 主要用于处理弹窗显示逻辑。
warningAlertInfo 转 warningAlertTitle,warningMessage,btnTitle,imageSrc的逻辑与 AlertControlView本身无关，没有用其成员变量储存和作为成员函数的必要。
建议写为独立函数，不要作为 AlertControlView 的函数
类似这种形式

```tsc
function warningInfo(warningAlertInfo: WarningAlertInfo) {
    switch (warningAlertInfo.warningType) {
      case WarningType.connectFailed:
        return {title : ""连接失败"", message: ""重启飞机或联系客服"", btnTitle: ""知道了"", icon: errorImg}
      case WarningType.connectingUSB:
        break
    }
  }"

```
"可否考虑加个类的注释，这块涉及UI界面较多，且之后需要拓展补充，
类似ConnectImageItem这种命名，很难做到看见名字就能对应到相应的UI界面上。"

还是上面那个问题，求加类的注释，这里好多Page啊，但又好像不止一个基类，没法很清楚地看到层级关系

"这里几乎每个子界面都有个带有关闭按钮的导航栏。
既然有父类供子界面继承，是不是可以考虑将导航栏的UI和点击事件封装到基类中，子类在需要的时候调用。
eg:render{ {renderNavigationBar} }"

"这里的点击下一步如果由于缺少飞机状态无法进行，建议写一下TODO，并且回调到ConnectPage的pressCallback中。
至少保证完成UI跳转交互的基本回路。
当前的完成覆盖状况后期很难维护。"

"类名ConnectUSBStepTwo可否考虑命名成ConnectUSBSecondStep😅😅
xxxOne、xxxTwo的命名怪怪的。"

Props传递每个Prop手动换行一下吧，这样四个一行另一个单独一行的代码排版不太好看

"这个函数名没看懂。。。Invert 这个词好像不是这么用的吧。
另外这里只是用到了 WarningType, WarningAlertInfo 作为入参不太合适
方法名这样写感觉会比较好一点alertInfo(waringType: WarningType)/alertParams(waringType: WarningType)"

这个我觉得应该定义成非必选，当前需求是在竖屏状态下关心这个player的touch事件，但在横屏状态下外部是不关心的。另外建议重新命名，比如onPlayerClick?  onPlayerTap?

可以写成onPress={this.playBtnStateChange}


```tsc
<Text testID={""verticalProgressTime""}
       style={styles.timeBottomStyle}>

<Text testID={""verticalTotalTime""} style={styles.timeBottomStyle}>

```

"为什么会在NavigationBar里直接操作ConnectPage的属性？
这样的话当前几个界面的跳转控制耦合太严重了，尽量放在Controller里去完成。
既然ConnectPage可以传递props到NavigationBar，可以考虑用回调解决。"

"跟某一块业务相关的Props，写成BaseProps的命名是不是不太好。
如果想让它的命名跟业务相关联的话，考虑一下ConnectBaseProps"

这里的最大位移应该是个常量

这里建议把『原宽度』以常量形式在外部声明

以上这几个文件，PreviewBtnComponent的onPress事件所触发的业务逻辑是不是应该放到外部处理比较合适呢？

"这里新加的两个函数，
getMediaPath内部主要做了是否存在目录的判断，然后调用mediaPath获取路径。
但是这里的两个函数的命名不是很能区分它们当前的职责和功能。"

"强迫症上线...
MediaDownloaderTask是对Media的DownloadTask的封装，可不可以改成MediaDownloadTask"

"Media的下载应该有很多个状态或者功能，
类似 init、start、pause、resume、stop、error、finish。
现在看来 init_start_error 都期望在构造函数中通过Promise触发并执行，
stop提供了一个cancel的function，
finish是判断progress == 100?
从业务上来看，缺少了pause/resume功能。
还是我们期望在每次暂停和继续下载时做一次DownloadTask的销毁和重新创建的过程？"

函数名可不可以给个动词😅

"CameraModeSwitchButton.tsx这个文件里的常量名、变量名、函数名可否按功能或业务重新规整一下？
现在很多类似photoImg、tenImg、getCameraSrc、getPhotoSrc这种命名，很难从命名上知道它们对应的职责。个人觉得在『见名知意』和『命名长度』上取舍的话，前者更利于代码阅读和后期维护。"

"跟拍、手动、大片三种模式，除了图片和文字之外，其他的样式、状态及onPress回调都一致。
现在是有一个ModeBaseItem有三个模式各自的Component继承ModeBaseItem。
可否使用枚举的形式直接给ModeBaseItem传入props来做UI展示？
会更简练和易维护一些，也能去除很多多余的文件。"

"这个函数有可能出现被外界多次调用，创建了多个subscription，然后因为只持有了一个subscription，之前被覆盖掉的subscription永远无法释放。
另外函数名不太合适，addProgressListener这个函数理论上的返回值应该是成功和失败表示是否监听成功。这里其实想要的是让外界拿到进度。


addListener 这个行为可以内部管理，没必要由外部调用。
给外界的实际内容是什么，接口就应该叫什么。"

这个component好几个地方都用到了 Dimensions.get('window').width 提取出来是不是好一点

上面这个两个类型加一下注释或者名字改一下吧，看不出来是干嘛的。

"建议不要将屏幕的宽度(Dimensions.get('window').width)和每个 item 的宽度耦合在一起，这两个值只是刚好相等，逻辑上没有直接关系。
可以提供一个 listItemWidth 的变量，所有与 item 宽度有关的地方都使用这个变量。
之后若是宽度有变， 修改这个 listItemWidth 具体值即可。"

"建议将 FlatList 和他内部的render item 等内容全部拿出来单独封装一个文件。
后期可预期的 DetailPage 会有很多其他业务逻辑，这些逻辑和 FlatList 的各种事件控制逻辑放在一起会导致代码庞大而且很乱。"

"shouldComponentUpdate 会在 props 改变和 state 改变的时候调用。
看起来这里 component 的更新会因为 this.props 与 nextProps 相同而被直接拒绝。
那么如果存在一种情况： state 被修改了需要更新界面，而  this.props == nextProps 是不是就会导致界面无法正确更新"

"WifiInfoManager 这块的内容看起来是提供一些 iOS 和 Android 的 WiFi 操作基本方法，更适合放进 utils 中。
Manager 的取名也不太合适。这个文件中并没有作为一个什么东西的管理器，而是在提供一些功能。建议直接扔进 utils 中就叫 wifi 就好了。"

"遍历一个数组，使用 forEach 比 map 更合适。
map 比较适用于，需要将一个数组中的每个元素 A 都通过某种转换规则转为 B 并且返回一个新数组的情况"

这个类也不太应该采用 manager 的命名。PermissionManager 看起来是实现了一些权限的操作方法，但没有作为一个 Manager 具体管理了什么业务逻辑。

建议取名为 deleteMedias

'file://' 这个字段的拼接在 FileManager 内部实现会比较好

`static getMediaPath(type: PathType, media: Media): Promise<string>`
`static getAlbumMediaPath(type: PathType): Promise<string>`
这两个函数是有歧义的，而且看起来两个函数内部实现的内容基本一致。
那么新增的 getAlbumMediaPath的目的是？
这个目的是否能通过修改 getMediaPath 来实现呢？"

"Quit，GoAlbum，Default，GoSetting等，在页面内容由调用 navigation 的 dispatch 即可。（react-navigation 其实有  route Action 描述当前处于哪个页面）
另外，action 是触发行为的描述，而非一个动作的回调：
ModeChecked,PhotoSizeChanged,PhotoFormatChanged,HDRChanged 此类命名通常用于描述某件事情改变后的回调，此处用UpdateXXX更为合适。"

"记录在 redux 中状态，对应某个 component 的数组的序号不太合适。
用当前 ISO，shutter，EV 的具体值会比较好一些。
Camera 这个 State 的状态， 我理解应该是对应着飞机相机当前的各种参数的。
这几个值不单用于滚轮显示某个具体值，在设置相机参数和收到相机状态时也要用到。
Redux 中的 state 建议不要具体的处理某个 component 的业务。而应该让 component 根据当前的 state 处理自己的业务。
（比如 ISOIndex = 10， 让 ISO 的 component 通过 state.ISO 自己找具体序号会更合适）"

这里的移动的文件名是临时文件,后缀名要处理一下,或者是可以加个TODO

对外的参数可以封装起来，比如这个接口 FlightControlLandingCommand 其实是一个空对象。接口不需要让外界填参数

这几个飞控对外的接口都建议改一下参数，直接把需要的参数暴露让外界输入即可，内部拼成 grpc 的对象

"SnapshotFileFormatEnum，AutoExposureModeEnum
FileFormat、Mode 等名词其实已经可以表明这个类型是一个 Enum 了，再加一个 Enum 结尾没啥必要
(ps.因为有些 enum 结尾加了enum，后面代码很多 enum 又是直接命名的。。觉得有点奇怪，倒不是啥问题。)"

```tsc
this.props.options.forEach((value) => {
  if (value === this.props.checkedOption)
    this.tempList.push({isChecked: true, option: value})
  else
    this.tempList.push({isChecked: false, option: value})
})

```
↓

```tsc
this.tempList = this.props.options.map(value => value === this.props.checkedOption ? {isChecked: true, option: value} : {isChecked: false, option: value} )

```
看起来这里是要实现将一个数组的数据都转为另一种数据然后生成一个数组的需求。用 map 就可以了。"

"这里 eval 的目的如果是转为 number 的话，用 Number 更为合适
https://stackoverflow.com/questions/86513/why-is-using-the-javascript-eval-function-a-bad-idea"

"getIndexByISO， getISObyIndex
这么写的用意是？？看起来目的看起来是找到对应的 ISO 在 ISOParams 中的 index，但用一个 enum 来维护很奇怪，因为这会使得维护成本很高。比如 ISOParams 中间新增了某个值，就得维护两个地方，而且这个 enum 要改很多的返回值。"

"像这种需要默认值的参数，可以将函数名写为
setSnapshotMode(mode: SnapshotModeEnum = SnapshotModeEnum.NORMAL, num_pics: number = 0, id: ID = ID.FRONT)"

"看起来这里的目的是找到 value.mediaID === media.mediaID 的 media 然后给 cellIndex 和 cellName赋值。那使用 find 更合适？
数组的很多方法都有遍历功能，确实大部分都可以满足这里找出一个元素需求。
但这些方法的语义各不相同，适用于不同的情况。用合适的方法能让人一眼看出这里的逻辑，不然就跟函数名和内部实现不一致依然容易造成混淆。"

"(type AlbumMedia = Media & HoverMedia） 这里相当于把两个 model 掺在一起了
会导致多出很多不必要的 if else。更好的处理方式是如果两个类的相似度很高，不如在 AlbumListCell里给一个新的AlbumListCellModel 专门用于显示 AlbumListCell 的数据。然后两个类通过转换函数转过来。
并且可预见的，飞机页面和相册页面的 cell，显示的逻辑在之后会变得不同。两个不同的业务逻辑的 cell 写在一起，会多出很多额外的业务判断。
所以 copy 一份分成两个吧"

每渲染一个 cell 就遍历一次整个数组来查找是否是被选中的元素。这个时间复杂度是 n*n，相当于100个元素在最坏的情况下要做10000次操作才能完成赋值

"listCell:onPress  => Action: updateSelected => AlbumPage: componentwillreceiveNextProps => AlbumPage: setState.isSelectAll
Redux 使用上面的调用流程会比现在下面这种实现更好一些:
listCell:onPress  => list:cellonPress => AlbumPage: albumPress => AlbumPage: setState.isSelectAll
当前的实现还是避免不了跨多页面做消息传递。"

"tempSelectedCells.findIndex((obj) => obj.name == media.name)
上面这个函数已经找到 index 了，可以拿个变量接一下
避免又tempSelectedCells.indexOf(media) 找一次"

"Cell 是一个 UI 层面的名词，不适合用于数据模型命名。
建议使用 HoverMediaCellModel，我们尽量保证见名知意，HoverMediaCell这个名字第一眼看到以为是扔了个 component 进来。"

时间异常的情况下给个默认的时间显示会比 '时间未知' 要好一些。

"这里看起来 UpdateList 的 Action 把更新飞机数据和更新手机本地数据的事情都处理了。
建议还是分开比较好，这两个事件本身没有关联，但是只要触发了 action 就会导致两边都数据被修改。
当前可以这样做是因为业务上，这两种操作不会同时发生。但是因为“两件事情不会同时发生”而把两边的更新逻辑写在一起感觉上是不太合理的。"

"reducer 为了保证 state 和 action 对应（state + active 可以得到一个确定的 newState），要求 reducer 内部是存函数的，就是不会有参数以外的外界因素引起 return 的结果与预期不一致。
此处 AlbumDataManager.queryProductData()，AlbumDataManager.queryAllLocalMedia() 不建议在 reducer 内部处理。可以写在 dispatch 之前，并把结果放在 action 的 payload 中，也可以放在 actioncreator 中（这种方式比较好）。"

"这看起来是拿 find 函数做了一个 foreach 的操作
如果要找 index 的话 this.props.currentMobileData.findIndex(value=>value.media.mediaID === media.media.mediaID)可以找到 Index
要取名字的话 this.props.currentMobileData[index].media.name 即可
另外入参 media 本身没有 name？并且不是 this.props.currentMobileData 的对象吗？使用 mediaID 进行比较的原因是什么？"

看起来每次渲染都要重新 revertData，那把revertData操作放在 this.props.currentMobileData 更新的时候比如 componentWillReceivedProps 更适合

"AlbumDataManager.deleteMedias(this.props.selectedMobileCells.map((media) => {
        return media.media
      }))

↓

AlbumDataManager.deleteMedias(this.props.selectedMobileCells.map(media=>media.media)）"

UpdateMobileListLabel 这个名称无法表示含义，最重要的信息 Label是干什么的 被遗漏了。

"上面两个更新方法处理的都不太好，比较好的方式是所有MobileMediaModel都获取后组成一个数组。
然后界面用这个数组更新，而不是在遍历中不断的刷新数据"

这个方法和上面的getLocalMediaPath都是获取Media资源的，可以封装一下内部再做photo\video & ios\android 区分是否需要加uri。另外MobileMediaModel 对ios做了区分，我觉得在调用getLocalMediaPath时根据传入的media创建一个MobileMediaModel也是可以的。


非UI style所需要用到数字建议定义一个常量加以解释。单看 92 & 20并不理解其含义。

"有个问题。当横屏是视频的宽度计算，我觉得现在计算方式是不合理的。视频高度固定为屏幕高度。
宽度 = this.props.videoWidth * (Screen.get('window').height / this.props.videoHeight)
这样是否更合理？当然这可以弄个feature来单独适配视频播放的问题。"

"{this.state.mapModeList.map((value, index) => this.renderButton(value, index))}
↓
{this.state.mapModeList.map(this.renderButton)}"

"建议在 Camera/index.ts 中 export PlaybackPage
之后导入时直接使用 Camera/PlaybackPage, 这样模块内部的修改不会影响到模块外部的引用"

"一样的问题，这种多个 tab 每个代表不同 enum 值并且有选中与非选中状态的 component。
直接用 for 循环生成，然后写一个数组对应 enum 的顺序，icon，selectedIcon。用 index 代表当前选中的 tab。
会不会更好一些？"

"{
      isFirstChecked: this.props.checkedTabs === SettingTabOptions.Shot,
      isSecondChecked: this.props.checkedTabs === SettingTabOptions.Camera
}
这种用两个 boolean 表示当前选中 tab 的方式很。。奇怪。即使不考虑维护，一个 boolean 判断当前模式即可。考虑维护方便的话每多一个选项都要加一个 boolean，并且这些 boolean 从定义上没有相互约束关系（忽略人为维护的赋值的话，逻辑上完全可以同时为 false 或者同时为 true，不如 enum 天然的代表单选的逻辑）。
更好的方式还是直接用 this.props.checkedTabs == XXX"

"上面的回调方法需要多做一层判断 this.props.xxx && this.props.xx
onXXX = (xx: xxxx) => {
    this.props.xxx && this.props.xxx(xx)
 }
而不直接在调用时使用 this.props.xxx 的原因是？"

"这种类型的函数不如写成 key-value？ 读起来会舒服很多
{
[SceneMode.Follow]: followSceneIcon,
[SceneMode.Manual]: manualSceneIcon
}"

这个命名有点儿。。类名已经申明了该枚举是干嘛的，建议FirstStep，SecondStep...下同

"boolean enable = mWifiManager.enableNetwork(netId, true);
if (enable) promise.resolve(true);
else promise.resolve(false);
👇
promise.resolve(mWifiManager.enableNetwork(netId, true))"

这个类内部不能直接使用 this.props.xxx吗？这里先赋值给成员变量的原因是？

"现在 render 里既包含了 WiFi 模式要显示的页面，也包含了 USB 模式要显示的页面，页面已经比较多了。
将每个 component 是否显示的逻辑放在他们单独的 render 中，会使得什么状态下应该渲染什么页面变得不太直观。
建议重构一下，在 render 函数中按 wifi 和 usb 划分渲染的内容（将是否显示的判断放在render 这一层）"

"render 函数中间不要插入其他回调函数，不同功能的函数放在一起会使得代码比较清晰。
看上面的  MARK: - Render 就是用来区分函数作用的"

"我这样理解这个逻辑对不对？
return this.props.connectMode === ConnectMode.WiFi || this.state.shouldShowFullMap"

"现在这种页面分类方式是比较有歧义的，上面其他渲染的内容是
{this.renderSwitchTrackView()}
{this.renderSwitchModeView()}
render 某个一个特定的view，但是中间却插入了 renderusbmode(),渲染某个模式下的 view，不但只渲染了一部分，还打乱了原先 view 之间的图层关系。
之前所指的按不同模式渲染，是类似以下的方式
render() {
  if(mode == wifi) {
    {renderComponentA()}
    {renderComponentB()}
    {renderComponentC()}
  } else if(mode == usb){
    {renderComponentA()}
    {renderComponentF()}
    {renderComponentc()}
  }
}
将 wifi 和 usb 区分，可能直观的看到不同模式下需要渲染的内容。而在每个 component 渲染函数中判断。
但并非说，在多个 1renderComponent()插入一个函数叫renderUSB()`"

封装成一个方法出来吧，在 componentDidMount 里嵌套太多层了

this.updateCurrentListIsEmpty(this.props) 内部其实也是在更新 state，为何不一次把 state 更新完呢？

updateCurrentListIsEmpty 。。。这个名字，护额。。跪

"建议  AlbumList 单独封装一个 List，原因在于 renderAlbumItem getItemLayout onScrollEnd等内容不属于 Page 需要处理的业务范围，而是 List 本身自己的内部逻辑。
我们尽量将逻辑分层， Page 处理页面全局的业务逻辑， 至于怎么渲染一个 list，怎么给 layout，list 的滚动事件等，这些 list 自身的逻辑不是 page 需要处理的。
举例来说，首页中，Page 要处理的内容是：

当前要展示精选还是发现的内容
这两个列表的网络数据及缓存获取
当前网络状态的处理

List要处理的内容是：

每个 item 如何渲染
当前滑动到哪一个 item，是否需要播放视频
当前是否滑动到底部，是否需要对外请求数据"

单独抽个函数处理 Joystick 的 combine？

抽个函数拿出来吧，不要都放在 componentDidMount 中， componentDidMount 这一层只需要处理 component 显示后需要做什么就可以了。摇杆怎么计算的放在单独函数中比较好

"editEnable
editOption
isUsedAutoEnhance
photoScaleType
这几个属性应该没有作为全局状态的必要？每个 media 的这几个属性都是独立的。除了编辑的 DetailListItem 外看起来也不需要给外界传值"

"状态的归属不应该以是否易于初始化作为依据的。这里的方式就类似于，把一个子对象的所有属性都定义在父对象中。
状态还原，不论是在 reducer 中实现，还是在componnet 中实现，应该都是要做的。component 内部加一个 reset 方法和调用一个 reset 的 action 看起来也没有什么特别的不同"

"加一个 isChecked 看起来是让数据处理多了一层，但又没什么必要性。
现在通过 props 可以拿到 checkedScaleType， 然后 scaleData 中包含了不同 type 的数据，通过 PhotoCutScaleConfig 的类型是否等于 checkedScaleType 就可以判断当前选中的类型。
多一个 boolean 看起来除了多一层转换关系外，并没有带来什么益处。"

"内部看起来没有管理 selectEditOptions 的必要，EditBottomBar 不处理业务，是一纯展示的控件。
现在的情况是，外面有一个 EditOptions， EditBottomBar内部也有 EditOptions，这两个之间没有建立关系。
EditBottomBar 内部自己默认初始化选中 EditOptions.FILTER_SELECT，然后自己管理 EditOptions 的状态，点击时把修改事件发出去。
看起来，直接让外界通过 props 传入 EditOptions，然后每次对外返回 callback，让外界修改 EditOptions 即可。
因为现在这样状态内外脱节有个很明显的 bug， 假设 media1 切换到了 EditOptionsB，然后列表切到 media2， 要求 bottombar 重置回 EditOptionsA 呢？
EditBottomBar 并不接收外界的 EditOptions，无法和外界状态同步。"

"这个 Container 的层级很奇怪，是和 DetailList 同级的。但是对某张图片或者视频的具体编辑内容应该是 DetailListItem 内部处理的内容。
像对某张图片的裁剪尺寸，给当前视频做裁剪等。 不应该是一层和 DetailList 同层级的东西啊。
比如说，如果现在需要 一键美化按钮紧贴着 Image 的底部怎么做呢？不是应该在 DetailList 中处理 iamge 和 button 的关系吗？"

"editEnable detail 列表中，当前显示的 media 是否应该可以编辑。
Page 这一层不需要知道，比较好的处理方式是：

如果滤镜条（其他编辑控件同理）是和 detailList 同级的，那么 detailList 判断当前 media 是否可编辑，detailList 负责处理是否要显示滤镜条（或其他编辑控件）
如果滤镜条（其他编辑控件同理） 是在 detailListItem_Cell 内部的， 那么 detailListItem_Cell 负责判断 media 是否可编辑，detailListItem/Cell 负责处理是否要显示滤镜条（或其他编辑控件）
但一个与 page 无关的属性，要 page 这一层来控制是不合理的"

"这个依赖加到 fileTree 里按后缀找会不会好一些？
implementation fileTree(dir: ""libs"", include: [""**.jar"", ""**.aar""])
因为这个 aar 的名字只是暂时的，后面变了还要记着回来改。"

"倒计时比起和 click 事件绑定，更适合的应该是和播放事件绑定。
触发视频播放的不止用户点击事件，还可能有别的外部调用。
        this.props.onStart()
        this.countDownTimer = setInterval(() => {
          this.counter++
          if (this.counter >= 3 && this.state.status !== PlayStatus.Pausing) {
            this.setState({
              showPlayBtn: false
            })
          }
        }, 1000)
不写在 onclick 而是一个独立函数中比较好"

"onBindViewHolder的回调太频繁了，当前这样的写法会导致内存抖动，
如果 jvm gc 不及时，有一定几率 OOM。
我记得之前做滤镜列表的时候讨论过这个问题的"

"😢原来你的ThemedReactContext是干这个事儿的呀。
我觉得这样是不合理的，包括这个listener
对于这个VideoCropView，按我理解是应该脱离RN桥接这个逻辑的，所以不应该接收ThemedReactContext。另外这个setRangeListener建议在桥接的manager内实现。
我觉得比较合理的是方式是在桥接manager内获取缩略图等等，且实现RangeChangeListener。"

"还是刚才那个RangeChangedListener问题，给RN层回调什么事件、以什么方式回调等应该是由这个Manager来决定的而不是自定义view内部实现。
建议在createViewInstance的时候创建监听。"

Props中有isChecked,State里也有isChecked,isChecked状态交给props去管理会不会更好点呢,现在item中的点击事件改变了isChecked状态,然后nextProps又setState一次

"    Modes.forEach((value, index) => {
      this.tempList.push({
        mode: value,
        background: ModesBg[value],
        isChecked: false,
        scaleRatio: index === this.defaultIndex ? 0 : -this.parallax
      })
    })
 Modes.forEach((value, index) => {
      if (index === 0)
        sum = this.props.width / 2
      else
        sum += this.itemWidth
      offsets.push(sum)
    })
 this.tempList.map((value, index) => {
          if (centerItemIndex === index)
            value.scaleRatio = deltaX
        })
 this.tempList.map(value => {
        value.isChecked = value.mode === mode
      })
看到上面这几段代码，感觉应该是数组函数的语义用错了。
map 函数是将数组中的元素拿出来，通过一个转换规则转为另一个对象后组成新数组。返回值是 Array
forEach 是遍历这个数组，返回值是 void
虽然结果没错，但从语义上讲（告诉看代码的人这段代码在干嘛），上面的函数中用 foreach 的地更适合用 map，用 map 的地方更适合用 foreach"

手机相册已有的media不下载 这个逻辑看起来更适合在选择的时候过滤，不允许下载的视频应该放不进 selectedDroneCells

这个函数定义出现在很多地方，能否封装？

是不是相册中大部分地方错误处理逻辑都是类似的？ 获取一个错误码，然后转成弹窗。看看能否把不同地方同性质的错误处理统一在一个地方（AlbumErrorManager 之类的）。

这几个参数我们不如给个初始值吧， 其实基本数据类型 number boolean 这些都可以直接给个默认值 0 ,false。

确定不用的代码可以删一下


```typescript
data.sort((media1, media2) => {
    return media1.media.date < media2.media.date ? 1 : -1
})

```
这里面的排序规则建议细究一下，是根据飞机中图片生成的时间排序，还是根据下载源图还是下载缩率图的时间排序。   
比如从飞机中下载一张几个月前的照片，是应该放在列表最前面还是中间某个位置？  
如果是以下载时间排序，现在的 media.date 是什么时间（我记得应该是下载缩略图的时间，需要确认下）。
刚才看到 `reducer` 在 `addaction` 中有调用 sort 函数。但是如果本身是以下载时间排序，直接插数组第一位就好了。"

"其他地方都挺好，revertData 和 sort 不建议写在一个函数：
一是因为这里 revertData 这个函数名做了两件事。而这两件事都有独立的规则
二是 sort 建议把排序规则抽象出来，现在以什么属性排序是单独写死在多个类的不同函数中。建议把排序依据改为页面的常量。方便以后维护"

这个 MediaModels.ts  用来装一堆枚举值而不是一写 model 感觉怪怪的，直接放到 Media 文件里如何

"这里面 this.onSensorCalibratePress 的弹窗逻辑建议放在 GeneralSettingContainer 里处理， CameraContainer 更多的是处理预览流上各个页面之间的关系。某个 container 的事件回调，不会影响到其他 container 显示的，内部处理掉就好了。
校准页面 SensorCalibrateContainer 在校准时并不需要预览流页面还在工作。和 CameraPage 之间相互独立。抽成一个单独的 page 比盖在预览流上由 CameraContainer 管理更适合。"

"reducer 中只根据对应的 State 做状态改变，不执行别的事件的。
UpdateBurstShot 如果有需要要和 takeSnapshot() | stopSnapshot() 绑定在一起，在业务层处理会比较好。"

这里添加一个 undefined 并且把 photoMode 改为可选值的用意是？

"看起来 updateCountdown 目的是修改飞机上的倒计时，传入的入参我在调用的地方看到也是直接使用的this.prop.isHDROpen 也即是当前 store 中的 isHDROpen。并没有做赋值或者修改的操作。可以理解为，当前的 store HDR 中是什么样的，这个 Action 执行后还是什么样的。
那这个入参看起来是没什么必要的"

"两个问题，一个是业务逻辑层不要直接知道用 hoverCommunication， 这个是专用于 wifi 的，考虑到我们还有 usb 的通讯情况，应该使用的是抽象过的 CameraControlCommunicator。
另一个是建议和 StartVideoRecord TakeASnapShot 等统一，改为Action 实现"

"SyncStorage 作为一个 APP 的基础函数，需要依赖 CAMERA/PreviewParams 的数据感觉不是很合理。（这同时意味着所有使用 SyncStorage 的模块都需要导入 camera 模块）
看起来 getSavedSceneMode 是 CameraPage 对 SyncStorage 的页面业务封装，归属于 CameraPage 看起来更好一些。"

"但是这个函数不是专用于“飞机列表”这个页面下载的，这是个下载 media 源资源用的通用函数。
预览流拍的照片也会用到，视频也会用到。
“从飞机列表下载的连拍照片不在连拍列表中展示,需把groupID改为-1” 这个业务在这个函数里实现会影响到其他地方的"

"这个函数存在两个问题：

函数内部没有做排序， 取名为 sort 不合适
遍历 listData 时还调用 hasBurstShootPhoto 遍历 tempListData， 假设 listData 的长度为 n， 这个函数最糟糕的情况会执行接近 n! 次。"

"* `listData.filter` 遍历过程中， 每次都会将整个数组 map 一次 `arr.map` 再在map 后的数组中再遍历一次做查找 `mapArr.indexOf`  
简化过来这里执行的就是：
  

```tsx
// 一次遍历
arr.filter(()=>{
// 二次遍历
  let arr2 = arr.map()
// 三次遍历
  arr2.indexOf()
})

```

*  filter 函数中有两种返回值，`obj` 和 `boolean`  


```tsx
(obj, index, arr) => {
    if (obj.photoGroupID === 0)
      return obj
    else
      return arr.map(mapObj => mapObj.photoGroupID).indexOf(obj.photoGroupID) === index
  }


```

这里的数据集是整个数据库， 回放页监听整个数据库不太合适。整个数据库只要有任何一点数据修改就会执行下面的代码，对回放页来说负担太重了。

"这个类感觉不合理，专为 mediaserver 设计了一个同时存放 media 和 id 的类显得多余了
现在的问题应该是我们有一个 media，要更新 media 的某个属性，但是因为 media 无法直接修改。所以我们需要专为 mediaInfo， 但是 mediaInfo 又没有 mediaID 导致的。
现在更新存在一个这样的流程 media -> mediaInfo -> media，调用上看起来很繁琐。之后改的时候我们一起看看怎么优化一下这样的更新逻辑。"

"APP 状态的监听现在在 store 里有一个 appstate 的状态。
因为 rn AppState 的设计问题，他的移除监听会把所有的监听对象都移除掉。所以 AppState只能用作单例。不然此处的 removeEventListener 会影响全局。
此处建议使用 store 里的状态"

上面的函数里有 10 个 if， 判断条件多，不太好读，我们能否抽成几个步骤或者分不同类型，封装在不同函数里以函数名表示这一步在做什么？

这个监听如果在 CameraContainer 的 touchview 内再实现一个，由那个 touchview 独立管理内部逻辑是否允许点击。是不是更好一些

"AlbumUtils 这个文件的定位我看着有点模糊，需要说明一下。
我的理解是这个文件里封装了一些对相册列表数据的操作， 比如排序，比如过滤重组数据， 这些看起来没问题。
但是这里又将 deleteAlbumMedias resetMediaGroupID 这种业务性的功能加入，感觉就不太合适了。
首先一点， Utils 的内容使用纯函数最好， 意思就是输入确定，输出的结果就确定。纯粹的实现一个功能，无关上下文，不包含其他逻辑。
比如：GpsUtil 中 getDistance 计算两个入参的距离， TimeFormatter 中 secondFormat 将秒转为指定格式时间。 ViewGeometry 中isPointInFrame 用于判断一个点是否在一个矩形中。
另一点, MediaHelper 定位是用来操作相册业务的角色。在他上层再提供一个文件封装他，这个文件的定位就有点奇怪。
看起来更像是有多个页面都用到的功能，就都往同一个文件里面放。"

AlbumBlockBusterlist 和 AlbumMobileList 感觉是添加了相同的一样的代码在不同的两个 list 中。建议将逻辑控制想办法抽出来，避免以后维护困难

"当前的主要问题是：控制逻辑代码在后期如果要维护势必要维护两次，如果是其他的同事来维护，容易遗漏和产生错误，并且维护繁复。
现在确实是只看到这两个 list 中有与 this.shouldUpdateList 相关的相同的代码。如果有其他的逻辑相同的代码，都不应该存在两份相同的。
你提到 但也不是完全一样 ，封装出去的逻辑只涉及相同的部分，不同的部分可以用传参数，传 callback 函数来灵活区分，当前相同的部分应该就是计时一秒的逻辑。
多添加一个或者多几个 销毁函数 的代价都远小于后期维护的代价，我觉得这个代价的权衡希望你能够再重新思考一下。"

"不建议写这样的代码， 之前写的也不好。一个 view 本身定义了其在父控件的位置。这种写法相当于把这个 component 固定死在这个坐标上，无论怎么调用。
比较合理的是，component 的定位和大小由父控件控制，自己只负责内部的样式，不负责在外部合理位置。"

"这两步看起来是不必要的， 现在在切换模式时有参数重设的逻辑，会根据当前选择的模式，将所有的相机参数进行初始化（ 不同模式初始化需要的参数描述在 `Constant` 中）  
在 `CameraSettingContainer` 初始化时再设置一次参数的逻辑说不通。  
这个限制不同模式下不同参数的需求，我觉得比较好的做法是有一个专门的数据结构，在页面以外的，用于描述不同模式下支持的参数。  

我的思路是在 `Constant`（当前这个文件专用于管理 CameraPage 的各项参数）。 写一个类似 Key-Value 的数据结构进行描述这个模式支持哪些参数
比如

```typescript
{'SceneMode.Follow': {
   photoFileFormat: [PhotoFormatOptions.JPEG],
   snapshotResolution: [SnapResolution.720, SnapResolution.1080, SnapResolution.2.7]
   
}}

```

"这个地方通过控制 isExposureMode 而不是通过 SceneMode 更合理。
这里的区别可以这么理解： 非手动模式，不允许进入调整曝光的模式  而不是  非手动模式，能调整曝光，但是调整了不响应"

"如前面一条评论所说，不建议在 component 做这样业务规则判断， 而是 component 根据其他地方写好的业务规则做对应的页面渲染。
比如此处

```tsx
const resolutionOptions = [VideoResolutionOption.Low, VideoResolutionOption.Mid, VideoResolutionOption.High2_7K, VideoResolutionOption.High4K]
const fpsOptions = [FpsOption.Low, FpsOption.Mid, FpsOption.High]

```
建议在外面定义一个描述不同模式下，支持不同相机参数的数据结构。然后这个 component 根据外界传入的数据进行显示。而不是内部做这个逻辑。"

"额，这就是前面的评论想说的问题。 `不同模式下，能设置不同的相机参数` 这个需求。  
现在被分别描述在了多个不同的 component 中， 每个 component 自己都在做独立的判断。  
我觉得 component 不应该处理这样的业务，只需要根据外面提供的数据做对应的显示即可。另一个是同一个逻辑（例如：`Composition` 支持的相机参数）被描述在了多个不同的 component 中， 维护是很困难的。  
最好就是有个地方统一维护， View 只根据外界数据做对应显示

```
ModeA： {
  ParamA：[A.A1, A.A2],
  ParamB：[B.B1, B.B2, B.b3],
},
ModeB： {
  ParamA：[A.A3, A.A5],
  ParamB：[B.B2, B.B4, B.b5],
},

```

```tsc
let params = ModeParams[this.props.currentMode]
<ComponentA params={params.ParamA}/>

```

看到好几个页面是如果没有权限，要优先确认权限的。这种情况直接调到一个单独的权限设置页面感觉会比在某个页面内部盖一个 AlbumPermissionView 更合理一些。 现在权限的确认逻辑分散在了每个页面中，但其实都是一样的事情，放在 AlbumPermissionPage之类的内部更合适一些

"我看了一些页面，都是页面内部带了检测权限和申请权限的逻辑，需要页面内部自己处理调用的顺序。
这些检测或者申请的逻辑能否在一个管理器中统一处理？
有两种可能：

如果检测是否有权限不会引发系统自动弹窗的话， 可以有一个管理器，在开 APP 后默默的把所有权限都检查一遍，当某个页面需要时，传进来一个权限组成的数组【Permisssion.1,Premission.2】由这个管理器依据数组顺序申请权限，并且根据需要 callback 时候跳转 PermissionPage。这个东西负责把检查权限，申请权限， 权限监听都做了。
如果检测权限会引发系统弹窗， 那这个管理器无法默默的提前遍历所有权限， 就需要不同的页面在需要权限时调用这个管理器。

这么看起来比之于每个页面都要处理检查权限和申请权限要好些。
至于 PremissionPage， navigate 和 if-render 之间表现上是一样的，不同的是逻辑组织上，是每个页面都有一样的逻辑，还是集中处理的区别。"

同 AlbumPage，一个页面中有两套不同的 redux 的处理逻辑

ShareContainer 的优先级没有 Toast 和 Alert 高，图层不应该在这两者上面

上面的 ifelse 太夸张了。。

NotificationName 建议抽成常量

包名建议使用api获取

建议将所有字符串标识的权限单独用枚举管理，方便使用和管理

既然已经定义了绝对路径，为什么不使用它呢？

"绝对路径需要在三个地方添加：
babelrc - js 编译路径、
tsconfig - ts 编译路径、
package.json - jest单元测试路径。
这里应该是漏掉了第三个。"

"AlbumList 的封装感觉不是特别合理。
这个类是用于封装 相册页面的 list 组件的。 定义上讲，他应该包含 ”用哪个 list 实现 AlbumLiost“， “这个 list 的属性，回调管理， 这里 list 本身自己的业务逻辑”
但现在这里面包含了很多与 list 无关的逻辑（比如顶部的切换栏，底部的按钮）。 看起来很多业务逻辑都是上一层应该管理的内容。
我去看了一下 AlbumPage， 里面的很多逻辑都被删除了。
现在从代码上看， 之前的 AlbumList 已经被 ScrollableTabView 替代了， 并且这个 ScrollableTabView 逻辑简单，没有需要我们在上面再放一层来实现的必要。 那将原先的 AlbumList 去掉会比较好一些。"

权限设置目前有没有多语言可以补充？

延时 5s 后关闭竖屏锁定 目的是啥， 这些异常逻辑还是得描述下作用的，不然下一个维护代码的人就会像我现在这样，一脸懵逼

这里每种类型的Exception构建样式都是一样的，可以提取一个通用的方法来统一生成

针对业务逻辑的数据输出，不要放在config文件里面去做。建议可以提到AbilityConvert里面去做，根据对应的Ability，输出业务逻辑所需要的数据

可以写成 HoverCommunicator.getHoverInfo(mode).then(this.updateSDCardInfo)

"内容较多并且没有对 Camerapage 的依赖（不涉及 CameraPage 内部修改）
建议抽个 StorageManager 专门处理这个业务，可以参照 CameraServices.ts
只要持有 store ，StorageManager是有能力判断当前状态的
另外如果不依赖预览流， 这个类拿出去也没关系"

"其实感觉这个文件有些奇怪，不是类或对象但是却叫 manager，然后处理了一些业务逻辑。
但是本身里面封装的只是一些函数，纯函数要依赖外部对象来处理逻辑很奇怪， 我不太能理解这个文件在代码中的定位。
很像 OC 中 category 或者 Swift 中 extension 的作用（用来给某个类增加一些额外的功能扩展）。但又与那个类无关。
这个文件写成一个类然后有一个实例访问当前 store 获取 SDInfo， 并且监听 camerevent 会不会更好一些？"

是不是因为 SD 卡没做好 SDCardState_MOUNT 的逻辑

"在 TS/JS 中调用 this，需要使用 ()=> {} 箭头函数，或者调用 bind  

```ts
hollywoodSuspendTasks = (suspend: boolean, callback: (suspend: boolean) => void) => {
...
}

```

上面prepareThemesInfos的修改可以避免这里多层嵌套

"可否把这个转成 Promise 的回调，这样就可以避免后面嵌套调用了


```ts
private prepareThemesInfos = () => new Promise((resolve, reject)=>{
        let logoPath = FileManager.getDirPath(DirType.LogoOfTheme)
        let musicPath = FileManager.getDirPath(DirType.MusicOfTheme)
        let jsonPath = FileManager.getDirPath(DirType.JsonOfTheme)
        this.bridge.hollywoodPrepareThemesInfo(jsonPath, musicPath, logoPath, (success)=>{
            success ? resolve() : rejecet()
        })
})

```

56 写成一个 const value 吧，之后要做 UI 适配方便修改

"提个建议，写成 

```ts
if (!isConnected()) return Promise.reject(MediaServerErrorCode.HAVE_NO_CONNECT)
return isWifi() ？ HTTPMediaServer.deleteMedias(mediaNames) ： usbMediaServer.deleteMedias(mediaNames)

```
简洁一些，小细节不改也行"

"感觉现在 CameraContainer 的逻辑就是靠一堆 if-else 撑着。。
得找个机会整理下这块的业务"

"NativeUtils 是个独立的功能接口， 不要作外部引用。
一方面是会让 NativeUtiles 依赖 DataBase
另一方面是很可能出现循环引用。"

为啥不封装成 enum

"Promise 不要这么写（😓）直接把下一个 promise 当返回值传出去，然后 then 中就是 promise 执行的结果  
其实 Promise 被设计出来，有个目的就是解决多层嵌套的”嵌套地狱“
写成

```tsx
let filePath
return FileManager.getDownloadOTAPath(hoverVersionInfo.hoverVersion)
 .then(path => {
  filePath = path
  FileManager.isFileExistAtPath(path)
 }.then(() => FileManager.infoFromPath(filePath))
 .then(info => {
   if (hoverVersionInfo.hoverVersion !== info.filename)
      throw(OTAFileError.FileVersionMismatched)
   else 
      return FileManager.getFileHash(path, 'md5')
}).then(fileMd5=>{
 if (hoverVersionInfo.md5 !== fileMd5) throw(OTAFileError.FileMD5Mismatched)
})

```

"同上，可以写成

```tsx
FileManager.getDownloadOTAPath(version).then(FileManager.infoFromPath）

```

"可以不用在 Promise 外部再包一层 Promise

```tsx
return fetchBlobTask.then((result) => {
 if (!result.json().result) return Promise.reject() // 或者 throw error
}) 

```

"在下面看到一些需要返回 Promise 的写法是 return new Promise，然后内部在多层级的嵌套 Promise。  
其实对 Promise 来说，设计的目的是将多层嵌套的调用形式改为通过.then .catch 进行链式调用  
可以理解为下面这种形式

```tsx
{
  {
    {
    }
  }
}

↓

aa
.then()
.then()
.then()
.catch

```

前者的弊端在于不利于理解和组织代码，因为有明显的层级关系，不断先一层层往深处执行代码，然后返回结果时再一层层往上回调。在内部有复杂的逻辑比如if-else 不同分支，然后每个分支有各自报错时很难维护。  
而后者将一段异步的代码组织到了.then()中，层级关系被转为链式关系，然后所有错误组织一个 catch 里。   
所以就不要在用 promise 时再层层写嵌套了
下面代码可以改为

```tsx
if (this.task) return Promise.resolve(tempPath)
this.task = new OTADownloadTask(version, url)
return FileManager.isEnoughStorageForMedia(otaNormalSize)
.then(isEnough => {
  if(isEnough) return this.task!!.start()
  else throw OTADownloadError.StorageNoEnoughSpace
}

```

这里的处理方式，让 server 接口加字段 优于 APP 自己写个假定值

"同下面某条对 promise 的 comment，嵌套式的写法，再加上if-else，需要先从父层级进子层级看代码，再根据子层级的返回值看父层级的逻辑。对理解代码的来讲，比链式难度大很多。
如果有时间的话建议改下"

"还可以进一步写为：
`FileManager.getDownloadOTAPath(version).then(FileManager.infoFromPath)`
.then() 可以被理解为需要一个参数， 这个参数是 入参为 string 返回值为 `promise<info>` 的函数
而 FileManager.infoFromPath 正是这个函数, 等同于 path => {return FileManager.infoFromPath(path)}
ps.一个小提示，不算 issue，可以不用修改"

这里成功的话不 return result 或者 result.json啥的吗？但是入参又定义StatefulPromise`<FetchBlobResponse>`是有具体返回值的

"IconAndMessageAlert 感觉放在 Components 中比较合适些， AlertController 是个独立的控制器，这里依赖 Camera 模块不好。
ps.上面的 DroneFlyAlert 也不合适，但这种与业务强相关的弹窗，我们之后再看怎么引用较好"

"上面这部分代码，把每步骤的逻辑做成一个独立函数， 通过 promise 的 resolve， reject 返回结果。然后在主函数中按步骤调用是不是好一些？
目前一个函数内部嵌套很多判断逻辑， 然后每个判断逻辑内部又有异步函数，会成功和失败，我自己感觉不太好理清楚这个函数运行的结果是什么"

"""外层的 promise 嵌套其实没用， 可以写为， 另外这个 promise 有两种返回结果，1 是fetchedMeta， 2 是 void。因为 status ！==200 的情况没有处理，运行到函数尾部直接 return 了

```tsx
 private fetchDataSourceMeta = (): Promise<NoFlyZoneDataSourceMeta> => {
        return RNFetchBlob.fetch('GET', DataSourceAPI)
                .then((res) => {
                    let status = res.info().status;
                    if (status == 200) {
                        let json = res.json()
                        let fetchedMeta = json.meta
                        if (fetchedMeta) {
                            return fetchedMeta!
                        } else {
                            throw ({ code: status, message: """"Fly restriction data fetch failed"""" })
                        }
                    }
                })
                .catch((error) => {
                    reject(error)
                })
   }


```""

"呃，这上面好多外层嵌套 new Promise（）的做法， 都是直接 return 即可， 因为调用的函数本身就是 promise  

```tsx
private checkDownloadFileMd5(path: string, srcMd5: string): Promise<boolean> {
        return FileManager.getFileHash(path, 'md5').then(md5 => md5 === srcMd5)
    }


```

跟上面戳点类似， 因为业务在  CameraServices 中处理了， 所以在那里面戳一个点就好。不需要在多个 view 中戳点

"
这是个业务类，桥接接口不放这里。 这个类是用来处理添加删除 media，调用写入数据库接口和写入相册接口的，完全是对应 media 的业务封装。
之前做视频编辑不是有个类放了一些视频处理函数吗， 另外还有个 nativeutils。"

应用启动的时候就会创建这个资源，但好像并不需要这个MediaPlayer生命周期伴随着整个App，所以没必要在构函里创建好备用。。建议在调用相应功能的时候再创建用完后并销毁。

我理解的是调用频繁跟申请不必要的资源是两回事儿吧？不能因为频繁调用提前申请好内存创建好线程等待后续有可能进行的任务(只有下载视频时用到)。另外在我们这中桥接类的构函里创建越多对象App启动速度也会相应变慢吧？

ZZVideoUtils放到NativeUtils里不合适吧？这个文件对应的是原生层的NativeUtils.m & .java的桥接类，并不是所有RN层桥接工具类的集合。。另外getVideoDuration这个功能完全可以写到NativeUtils.m文件内不用单独新建桥接文件了吧？还有上面的HapticsFeedBack同样并不是一个独立且较大的功能模块，建议小功能都放大NativeUtils中去。

"使用 setInterval 强制修改为 1s 恢复一个相册资源，这样是不是不合理：

恢复的时间会大大加长，之前1秒可能能恢复30个，现在强制加长时间，这个时候如果用户进入相册，同时做一些操作，问题会更加复杂
比较好的办法是在原生层开启一个并发队列 （因为不会有先后同步的问题），限制最大并发数，这样既可以速度很快并且不会造成内存等资源瞬间暴涨的问题"

"可以使用指针来强操作一段内存，不用 memory copy


```C
+ (NSDictionary *)rcMsgDataToDict:(NSData *)data {
  NSMutableDictionary *dict = [NSMutableDictionary new];
//  usb_msg_t *msg = malloc(sizeof(usb_msg_t));
//  memset(msg, 0, sizeof(data.length));
//  memcpy(msg, data.bytes, data.length);

  usb_msg_t *msg = (usb_msg_t *)data.bytes;    // 可以直接用指针强转
  dict[@""usb_msg_type""] = @(msg->usb_msg_type);
  switch (msg->usb_msg_type) {
    case ADC_VALUE_PERCENTAGE:
      dict[@""usb_msg""] = @{@""ack2app"": [self rocker_calibration_ack2app_tToDict:&msg->usb_msg.ack2app]};
      break;
    default:
      NSLog(@""<%@> %s: 异常，收到无需解析 APP 解析或者 CMD 类型数据: type = %d"", NSStringFromClass([self class]), __func__, msg->usb_msg_type);
      break;
  }
//  free(msg);
  return dict;
}


```

这个< 1.0 是怎么得出的呢。。如果用户反复拖拽 iOS 的设置会不会有啥问题

"有一种省略的写法

```tsx
 this.state = {
                ...this.props,
                disConnectedTime: -1,
                phoneLocation: new Coordinate(0, 0),
                isShowConnectedTip: true,
                isShowReturnPoint: false,
                isShowMoreInfo: false
            }


```

"this.props.onChangeReturnPoint 这个逻辑也可以交由 captainServices 处理
。。。
感觉上面整套断连逻辑都可以放在 CaptainServices 中， CaptainServices dispatch action，这边界面同步 props"


```ts
 return RNFetchBlob.fs.mkdir(dirPath)
      .then(() => dirPath)
      .catch(() => {
        return this.existAtPath(dirPath).then(isExisted => {
          if (isExisted) return Promise.resolve(dirPath)
          else throw ""mkDir failed""
        })


```
↓写 promise 尽量避免嵌套

```ts
 return RNFetchBlob.fs.mkdir(dirPath)
      .then(() => dirPath)
      .catch(() =>this.existAtPath(dirPath))
      .then(isExisted => {
          if (isExisted) return dirPath
          else throw ""mkDir failed""
      })

```

reducer 里不要做改变状态外的任何操作。。。 这不是放业务逻辑的地方
