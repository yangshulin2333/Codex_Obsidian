---
type: project-note
domain: roblox
status: needs-triage
source: self
tags:
  - roblox/gui
  - project/svn
  - status/needs-triage
created: 2026-06-06
updated: 2026-06-26
---

# BagPageGui 结构与 SVN 卡顿待处理

## GUI 结构记录

StarterGui_界面根服务
└─ BagPageGui_背包界面
   └─ Root_根容器
      ├─ DimBackdrop_全屏暗色遮罩
      └─ BagWindow_背包主窗口
         └─ WindowFrame_窗口内容承载层
            ├─ BackgroundLayer_整窗背景层
            │  ├─ FrameSkin_整窗背景框图片，tc_dk1
            │  └─ HeaderDivider_Header底部分割线，tc_fgx1
            │
            ├─ Header_顶部栏
            │  ├─ HeaderBg_Header背景图片，tc_dk2
            │  ├─ TitleText_标题文字，显示“背包”
            │  ├─ SellButton_出售按钮
            │  ├─ HeaderFilterGroup_Header筛选组
            │  ├─ SearchBox_搜索框
            │  └─ CloseButton_关闭按钮
            │
            ├─ CategoryTabs_一级分类按钮栏
            │  ├─ PotionTab_药水分类按钮
            │  ├─ MaterialTab_材料分类按钮
            │  ├─ EquipmentTab_装备分类按钮
            │  ├─ BroomTab_扫帚分类按钮
            │  ├─ CauldronTab_炼药锅分类按钮
            │  └─ SpecialTab_特殊道具分类按钮
            │
            ├─ Content_内容区
            │  ├─ PotionPage_药水页面
            │  ├─ MaterialPage_材料页面
            │  ├─ EquipmentPage_装备页面
            │  ├─ BroomPage_扫帚页面  --
            │  ├─ CauldronPage_炼药锅页面  --
            │  └─ SpecialPage_特殊道具页面
            │
            └─ Templates_运行时克隆模板层












EquipCard_装备卡片
├─ CardBg_卡片背景框，tc_wbk2
├─ TitleText_装备名称
├─ QualityText_品质文本
├─ EquippedIcon_是否装备图标，ty_icon_xz
├─ PreviewArea_模型展示区
│  ├─ QualityGlow_品质光效，ty_dj_bg_guang4 等
│  ├─ IconFrame_模型底框，ty_dj_icon_dk
│  └─ ItemViewport_装备模型视口
├─ StatBlock_属性框，tc_wbk1 或透明框+描边
├─ CardDivider_分割线，tc_fgx3
└─ DescText_描述文本


测试宏
测试宏123
测试红123
33
测试红123

我感觉SVN这个项目太卡了，我需要做一次

所以你推荐的正常流程应该是什么样的呢？
