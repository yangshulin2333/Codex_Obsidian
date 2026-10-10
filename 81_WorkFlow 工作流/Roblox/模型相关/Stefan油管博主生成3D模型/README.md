---
type: workflow
domain: roblox
status: active
owner: mixed
source: youtube
created: 2026-07-16
updated: 2026-07-16
---

# Stefan 3D AI：游戏道具图生 3D 知识笔记

## 这个目录解决什么

这里记录 Stefan 3D AI 的视频中，对 Roblox 和其他游戏道具最有复用价值的方法。它不是某个工具的操作手册，而是补充当前道具工作流的两段关键能力：

1. 在图生 3D 之前，如何把复杂概念拆成可控的模型部件。
2. 在图生 3D 之后，如何把 AI 网格推进到可用的游戏资产。

## 阅读顺序

| 顺序 | 笔记 | 解决的问题 | 适用阶段 |
| --- | --- | --- | --- |
| 1 | [[01_复杂道具拆件与引擎组装]] | 一张复杂概念图不能稳定生成可近看模型时，怎样拆件、去背景、分别生成、再组装。 | 概念图确认到图生 3D |
| 2 | [[02_AI网格到游戏资产清理管线]] | 生成出基础网格后，怎样处理结构、拓扑、UV、烘焙、贴图和引擎导入。 | 图生 3D 到游戏资产 |
| 补充 | [[参考_Stefan图生3D生产级参考图四步法]] | 怎样把“好看的概念图”变成信息足够且一致的 3D 参考图。 | 参考图准备 |

## 本目录的核心结论

复杂道具不要期待一次图生 3D 完成。应先锁定同一份设计母版，再根据结构风险拆成主体和附件；每个部件独立生成、清理并复核，最后在 Blender 或引擎中装配。生成到的网格也不是最终交付物，仍需经过几何、拓扑、UV、贴图和性能检查。

## Roblox 使用边界

- 视频一的目标是 8K 电影镜头和 Unreal Engine 画面，不能直接照搬其高面数目标到 Roblox。
- 视频二含角色自动绑骨和 UE5 骨骼导入；静态 Roblox 道具通常在贴图与静态导入检查处结束，不进入绑骨环节。
- 视频中出现的模型、收费、免费额度、界面和效果属于时间敏感信息；使用前必须重新核验。
- 当前执行入口仍是 [[../Roblox 通用游戏素材道具制作工作流/README|Roblox 通用游戏素材道具制作工作流]]。本目录只提供拆件和后处理的知识补充，不替代其中的资产锁、多视图、归一化和交付检查。

## 统一决策问题

在提交给图生 3D 前先问：

1. 这一件是否能以单一主体、清晰轮廓和完整厚度关系稳定生成？
2. 是否有绳带、扣具、内腔、异材质附件、遮挡面或不对称机关，会让一次生成产生歧义？
3. 若生成失败，应该补视图，还是应把失败部分拆成独立资产？
4. 目标是 Roblox 运行时资产，还是宣传渲染图？两者的面数和贴图要求不同。

只要第 2 或第 3 个问题的答案为“是”，优先采用拆件方案，而不是反复让模型重做整件道具。

## 来源

- [From AI to Unreal Engine - Crafting a Cinematic 3D Prop in 8K](https://www.youtube.com/watch?v=XwJ1K2GCJDs)
- [My Complete FREE AI 3D Workflow — Characters & Props Pipeline](https://www.youtube.com/watch?v=MjsQhbaonDc)
- [4-Step System for Production-Ready 3D References](https://www.youtube.com/watch?v=cHC6s3dCMHI)

