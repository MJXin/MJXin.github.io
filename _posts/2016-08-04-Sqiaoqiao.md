---
layout: post
title: 综合性项目
categories: 项目展示
description: 苏泊尔
keywords: WiFi
---
- 苏泊尔智能厨电IOT项目
- 伊莱特智能厨电。


# 苏巧巧
苏巧巧是[苏泊尔](http://www.supor.com.cn/)公司的智能厨电平台的APP端。APP关联三款苏泊尔智能设备（电饭锅，电压力锅，空气炸锅），在展示菜谱的基础上，可根据菜谱关联的设备自动设置参数，并预约设备进行烹饪。
 
APP功能分为三个模块：  

1. 食谱展示  
2. 设备控制  
3. 个人管理  
  
>AppStore地址: [苏巧巧](https://itunes.apple.com/cn/app/su-qiao-qiao/id1108847591?mt=8)  
APP-设备通讯: WiFi(机智云定制SDK)  
项目参与人员: 2人合作   
项目开发历时：一期开发6个月（15.11~16.05），截止离职前（8月），项目仍在添加功能  
本人负责内容: APP中除设备控制、系统推送、第三方分享外的其他内容    
（ps.本人在参与伊莱特项目时负责设备控制模块）

<br/>
<br/>

## 食谱模块

<center>


<video autoplay="autoplay" height="500" width="280" id="video" controls="" preload="none" poster="{{ site.imageurl }}/su_recipe.png">

<!--<source id="mp4" src="http://github.com/MJXIN/MJXIN.GITHUB.IO/raw/master/RESOURCES/applewatch.mp4" type="video/mp4">-->
<source id="mp4" src="{{ site.url_SuRecipe }}" type="video/mp4">
</video>
</center>  

食谱模块用于展示菜谱，不同菜谱有不同分类并关联不同设备，菜谱可被搜索，收藏，分享；菜谱详情中有用户作品发布及评论模块，并可播放演示视频；横屏时有语音播报当前步骤，并可用语音控制操作。
演示内容：

1. "吃什么"推荐、"大师菜"、用户个人收藏，分类等不同形式的**食谱列表**；
2. 食谱列表之后展示的内容是**食谱搜索**，分为搜索前的关键词推荐，搜索中的搜索联想及搜索结果筛选等内容；
3. 最后演示内容是**食谱详情**，除了菜谱步骤包含较为丰富的界面元素与较复杂的业务逻辑外。还有用户作品处理及评论两块内容。
（横屏模式，包含语音控制，语音播报功能。由于录制软件横屏失效，未能录制）

> 本人负责此模块所有内容

<br/>
<br/>

## 个人信息模块

<center><video style="max-width:280px;"  width="100%" id="video" controls="" preload="none" poster="{{ site.imageurl }}/su_Me.png">
<source id="mp4" src="{{ site.url_SuMe }}" type="video/mp4">
</video></center>

个人信息模块用于展示及管理个人资料，包含以下内容：

- 个人成长记录（积分系统）展示；商家推广、评论，作品等推送内容；
- 购物清单管理；
- 个人资料、个人设备管理；
- 售后服务及其他；

> 本人负责此模块除设备管理与推送外其他内容

<br/>
<br/>

## 设备控制模块

<center><video style="max-width:500px;"  width="100%" id="video" controls="" preload="none" poster="{{ site.imageurl }}/su_device.png">
<source id="mp4" src="{{ site.url_SuDevice }}" type="video/mp4">
</video></center>

设备控制模块主要负责管理APP与设备之间的通讯  

- 设备控制方面：设置控制参数、发送指令，显示设备上报数据等；
- 设备管理方面：寻找并配置设备，多种类设备管理等；

<br/>
视频中演示了设备操作基本流程

1. 选择设备型号并配置设备。  
2. 打开菜谱使用预定参数（特定菜谱对应特定参数）控制设备。    
（ps.中间插入了一段菜谱视频播放演示）  
3. 使用自定义设置（在设备控制界面单独设置时长、米种等参数）控制设备。  

<br/>
<br/>

# 伊莱特智能厨电系列APP
<center>
<img src="{{ site.imageurl }}/e_0.jpg" width="33%" height="33%" />
<img src="{{ site.imageurl }}/e_1.jpg" width="33%" height="33%" />
</center>


  [伊莱特](http://www.enaiter.com/)系列APP类似苏巧巧，同样是将智能设备（四款电饭锅）依托于菜谱平台。APP中除了菜谱的表现形式及部分业务逻辑不同外，其他功能基本一致。

>伊莱特2.0  （2.0是全新App）
Appstore地址: [伊美味](https://itunes.apple.com/cn/app/yi-mei-wei/id954975977?mt=8)  
APP-设备通讯: WiFi(机智云定制SDK)  
项目参与人员: 2人合作   
项目开发历时：控制模块开发1个月  
本人负责内容: 设备控制模块

<br/>

>伊莱特1.0  
App名称：妙厨宝（已下架）  
负责内容: 机智云SDK换代
