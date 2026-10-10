---
type: index
domain: roblox
status: active
owner: mixed
source: self
created: 2026-06-30
updated: 2026-07-02
---

# Roblox 知识卡

这个文件夹放 Roblox 开发里可以反复复用的“小功能知识卡”。

这里的知识卡第一目标不是讲深原理，而是让人能快速照着做出功能：

```text
先说这张卡要实现什么
-> 直接开始一步一步操作
-> 每一步写清楚创建什么对象、放在哪里、改什么属性
-> 代码块带中文注释
-> 知识点、必坑点、常见问题放到后面
```

## 现在先看哪张

如果你要做“角色穿戴类道具”，按这个顺序看：

```text
1. 先把模型做成能穿戴的 Accessory
2. 再把 Accessory 做成场景里漂浮、靠近按 E 穿戴的道具
```

对应知识卡：

| 你要解决的问题 | 先看这张卡 | 结果 |
|---|---|---|
| 模型还不能穿到角色身上 | [[Accessory挂到角色身体部位知识卡]] | 做出能挂到手、脚、头、背等身体部位的 `Accessory` |
| `Accessory` 已经能穿戴，想做成地上拾取道具 | [[ProximityPrompt漂浮道具穿戴知识卡]] | 做出漂浮旋转、靠近按 `E` 穿戴的交互道具 |

## 当前知识卡

### [[Accessory挂到角色身体部位知识卡]]

用途：

```text
把导入的模型做成 Roblox Accessory，并挂到角色指定身体部位。
```

适合：

```text
武器挂手上
鞋子挂脚上
帽子挂头上
披风挂背上
光环挂身体上
```

核心内容：

```text
R15 参考角色
Accessory
Handle
Attachment
WorldCFrame 对齐
Humanoid:AddAccessory 测试
```

### [[ProximityPrompt漂浮道具穿戴知识卡]]

用途：

```text
把已经能穿戴的 Accessory，做成场景里漂浮旋转、靠近按 E 穿戴的道具。
```

适合：

```text
地上鞋子拾取
帽子拾取
披风拾取
武器拾取
光环拾取
```

核心内容：

```text
Workspace 交互点
Hitbox
ProximityPrompt
Visual 展示模型
ServerScriptService 穿戴脚本
StarterPlayerScripts 漂浮动画
```

## 知识卡统一写法

以后新增 Roblox 知识卡，尽量保持这个顺序：

```text
## 这个功能要做什么
## 第 0 步：前置确认
## 第 1 步：创建对象
## 第 2 步：设置属性
## 第 3 步：创建脚本
## 第 4 步：Play 测试
## 最终对象结构
## 怎么换成其他道具 / 其他场景
## 知识点
## 必坑点
## 常见问题
## 最小原则
```

写操作步骤时，必须尽量说清楚：

```text
在哪个服务下创建
右键哪个对象
Insert Object 选择什么类型
对象改成什么名字
关键属性怎么设置
脚本放在哪里
Play 后应该看到什么
失败时先检查哪里
```

## 什么时候放到这里

适合放到这里：

```text
一个小功能
一个容易忘的 Roblox 规则
一个可以独立复用的操作方法
一个常见坑的稳定解决步骤
```

不适合放到这里：

```text
完整项目交接
大型系统设计
资产生产全流程
还没验证过的想法
只属于某个项目的一次性记录
```

对应放法：

| 内容类型 | 推荐位置 |
|---|---|
| 小功能知识卡 | `70_LLM_Wiki 知识库/Roblox/知识卡` |
| 完整可重复生产流程 | `81_WorkFlow 工作流/Roblox` |
| 项目交付记录 | `10_Projects 项目/Roblox` |
| 长期 Roblox 概念 | `70_LLM_Wiki 知识库/Roblox` |
| 人类阅读入口 | `30_MOC 内容地图/Roblox MOC.md` |

## 最小原则

```text
知识卡不是聊天记录。
知识卡不是长篇理论。
知识卡要让下次照着做的人少踩坑。
先能做出来，再解释为什么。
```
