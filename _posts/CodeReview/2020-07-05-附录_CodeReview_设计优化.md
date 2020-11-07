---
title: 附录-CodeReview：(我关注的)代码设计优化 76 图
key: test
excerpt_separator: <!--more-->
excerpt_type: html # text (default), html
lightbox: true
pageview: true
tags: 工程专题 CodeReview 附录
coding: UTF-8
---

## 对重复或独立的逻辑做封装
![](/assets/images/附录/90878DD5-7EA2-42B3-A482-C321F08C2F22.png)
![](/assets/images/附录/C6FDA928-D6C1-482C-9D24-89EAAB18F61D.png)
![](/assets/images/附录/F517AD9E-EFAD-4C5D-A2C8-EBC91EDFD01B.png)
![](/assets/images/附录/48853DE1-1558-4A3B-847E-0541E8752E93.png)
![](/assets/images/附录/789D23F0-FA0B-4AAD-AA81-12A7B08B856B.png)
![](/assets/images/附录/20DF0E05-1554-4EF7-81BF-0E527C3C17A5.png)
![](/assets/images/附录/95AF44A3-663B-4265-B27F-E6B05767203B.png)
![](/assets/images/附录/C39396BF-043B-4618-9FE9-A3425C247F30.png)
![](/assets/images/附录/244BDC44-F7E5-4875-8BD4-826CA703FC2F.png)
![](/assets/images/附录/FA825397-87E8-4768-ADC4-C04233F539D4.png)


## 做的抽象不合适
![](/assets/images/附录/E12CF57C-F790-4DFB-8340-2CDEC0403406.png)
![](/assets/images/附录/D7E6DD5D-F6A0-4BB3-B6D3-CEA565FA8AF0.png)
![](/assets/images/附录/125FEE20-6E8B-4CBE-AED4-B0DC28BEE0A1.png)
![](/assets/images/附录/9BE3C916-BEDA-49C9-AB8E-667E70766983.png)
![](/assets/images/附录/EBF46C47-7D81-4F94-AE73-F749534CC56D.png)
![](/assets/images/附录/3986CB51-B1A0-46E9-9B29-EC4FF9F90803.png)
![](/assets/images/附录/C2B2A332-F5BD-4F2F-8082-C77F15B0747A.png)
![](/assets/images/附录/7936FC3E-0C62-4929-8102-3BEA293AEF10.png)
![](/assets/images/附录/F66305AE-2D9B-434E-BFCB-8A1838CE111C.png)
![](/assets/images/附录/F55FBAAF-DC5C-4ABA-ACDC-81EB17D5A312.png)
![](/assets/images/附录/B025D053-7CFC-4458-BAAC-281D5BB2214F.png)
![](/assets/images/附录/549D5FE7-37F6-4070-8FEF-9B69CB01866A.png)
![](/assets/images/附录/C8BB726E-C8C8-40BF-8F8D-1B64CC3A27D7.png)


## ”实体”(类/文件/函数等)
实现了超出其定义的逻辑/影响到不归他控制的逻辑
![](/assets/images/附录/5DAA0D86-9DB3-4B43-93BE-580B0A499D51.png)
![](/assets/images/附录/B8BBBC65-F40C-4E29-AD2F-0E94D3B55C90.png)
![](/assets/images/附录/BE0F4F69-1794-45EB-B1F8-6C3E679AB657.png)
![](/assets/images/附录/248BAC4A-298F-4CAB-853B-197930F21FC6.png)
![](/assets/images/附录/C2F45436-5C2F-4E85-B647-AA6ED9CB716E.png)
![](/assets/images/附录/5AF42750-B241-4FF7-921B-9694132A9040.png)
![](/assets/images/附录/F8499407-8C3B-4EEE-9B55-B6157AECD48C.png)
![](/assets/images/附录/4B73FF01-E694-4612-B4DD-0C087F01DBF7.png)
![](/assets/images/附录/3192057C-73DD-4C82-961C-FA5A587CB059.png)
![](/assets/images/附录/5146F52A-5BDF-47BC-B584-7303D72F4A95.png)
![](/assets/images/附录/C012EAE1-285F-42F0-9F0D-E59D7743958A.png)
![](/assets/images/附录/67A3CFE2-475E-401E-A266-AD8927363B95.png)
![](/assets/images/附录/8C1D34CB-0972-4C55-9774-C30B3F2D6504.png)


## 实体间的关系没理清(层级关系, 封装混乱)

![](/assets/images/附录/521D1C2F-855C-4440-AB9C-7B87E7740709.png)
![](/assets/images/附录/4071D213-B74D-40B6-AA57-5E3C1A87D4E7.png)
![](/assets/images/附录/9DFF6464-0FDE-429D-8242-DA4D3C4262FE.png)
![](/assets/images/附录/9907AC13-BE64-49D1-8833-8E026993AF32.png)
![](/assets/images/附录/83E58FBD-3103-48C5-BA83-509AE3011325.png)
![](/assets/images/附录/D8BC4142-7D1F-41B2-BF2B-CEEE1AF2633E.png)
![](/assets/images/附录/EDF0847C-324A-4C1F-B17E-CEE12C6B17DC.png)
![](/assets/images/附录/5F089E0B-1CE4-4235-9849-BBD9789829BB.png)
![](/assets/images/附录/8811D263-1C33-4CCC-B5FF-BA4FF0128D36.png)


- - - -

## 对设计好的各部分职责不理解, 错误使用其职能
![](/assets/images/附录/BDC74C18-3E10-4C1B-98F4-1FB89DA7A78E.png)
![](/assets/images/附录/E8B0D2DB-8BA3-4799-9066-104E0199DAB5.png)
![](/assets/images/附录/26006A7A-8036-4F13-BF09-0D7CA5D1E239.png)
![](/assets/images/附录/E3B301AA-CF02-45A6-B178-8EA7ACAE5F0E.png)
![](/assets/images/附录/89F27D4E-72D1-4BFD-B4ED-7AAF10DD42F3.png)
![](/assets/images/附录/0BBB0469-10DF-464E-A8A9-0E4CEAE0384C.png)
![](/assets/images/附录/B34160CD-56B8-48EF-919A-7CD26CB7DF6D.png)
![](/assets/images/附录/6DFFF370-4D5D-4117-83C1-A15A1EB7BF57.png)
![](/assets/images/附录/C1EE935B-5127-4937-9725-73B3387FE13F.png)
![](/assets/images/附录/7DB715E3-A105-4BE8-AD0B-063887A874BE.png)
![](/assets/images/附录/18293B43-4BF5-4871-845F-DBF4ABC5E1D7.png)



## 实现逻辑不统一(一样内容多种不同实现, 一个实体的功能被两个实体控制实现)

![](/assets/images/附录/F588A29F-4E0C-4301-AD3A-0CF2B2B6065D.png)
![](/assets/images/附录/746D5C4A-A199-4CE8-A710-6E22E06C450F.png)
![](/assets/images/附录/CBE880AE-6853-4151-8C1B-7E4EBF1CC40D.png)
![](/assets/images/附录/866784AF-6CC8-463A-AC95-F5144BD18CCC.png)
![](/assets/images/附录/47AB80AC-2257-45CC-812C-EDEA35D4B008.png)
![](/assets/images/附录/DB7602AA-6608-4EA4-9986-8B37C6B8A7F4.png)
![](/assets/images/附录/CBC66467-1B7F-4AA4-BAE4-849AC77EAC54.png)



- - - -

## 对主要的问题点没抓清楚,用了间接手段解决问题
![](/assets/images/附录/0445DFF5-E1EB-4F3E-A605-343492A0941F.png)


- - - -

## 代码逻辑里包含潜规则
![](/assets/images/附录/D8D6A23B-C296-4064-9DB8-932DC501E348.png)
![](/assets/images/附录/52131208-7F2A-44CE-B207-B956DBC7D1AA.png)
![](/assets/images/附录/39FE256B-F898-4A4A-AAD2-AF4B3C8359F1.png)
![](/assets/images/附录/61161005-5B7E-45FA-958E-48940FD480E5.png)
![](/assets/images/附录/846CD9B4-E9ED-464E-991F-B2E24D1A1060.png)

- - - -

## 代码只考虑当前可行(写了只适用特定对象的代码)

![](/assets/images/附录/BF57EDA4-48DF-47AA-A11E-205B1620A312.png)


- - - -

## 多层 if-else 嵌套逻辑
![](/assets/images/附录/A95A4C99-6018-4FF8-9BD4-3BBF6A9B14BC.png)
![](/assets/images/附录/7BC1E0B0-F108-40FB-9C56-40FDD531CEF9.png)
![](/assets/images/附录/FD2D1F9F-8226-4546-92C9-B47853D5AD41.png)
![](/assets/images/附录/7BC1E0B0-F108-40FB-9C56-40FDD531CEF9%202.png)


- - - -

## 未正确使用语言提供的类型
![](/assets/images/附录/691FC2A2-DAB6-4792-9CF4-EEF833A726F1.png)
![](/assets/images/附录/FB37AB70-A47F-4E7C-9694-78A4B6D17BAB.png)

