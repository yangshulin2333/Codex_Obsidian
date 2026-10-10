---
type: concept
domain: roblox
status: evergreen
owner: codex
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# Feature Pack 与 Feature Card

## 一句话说明

Feature Pack 是一个具体玩法的交付单位，Feature Card 是这个功能包的说明书和验收单。

## Feature Pack 是什么

Feature Pack 不是单纯文件夹，也不一定能脱离框架独立运行。

它更准确地表示：

```text
围绕一个具体玩法目标，整理出来的一组代码、配置、UI、数据字段、Remote 合同、素材合同、验收规则。
```

它应该能回答：

- 玩家看到什么？
- Client 做什么？
- Server 做什么？
- 用哪些 Remote？
- 读写哪些数据？
- 用哪些 UI？
- 用哪些素材？
- 怎么验收？
- 哪些内容明确不做？

## Feature Card 是什么

Feature Card 是 Feature Pack 的设计说明和验收清单。

它给人看，也给 Codex 看：

- 人看：知道功能目标、边界和验收标准。
- Codex 看：知道应该改哪些文件、遵守哪些合同、不做哪些范围外内容。

## 框架和 Feature Pack 的关系

```text
框架 = 提供通用能力
Feature Pack = 使用这些通用能力完成某个玩法
Feature Card = 把这个玩法说清楚
```

常见框架能力：

- ServiceRegistry
- ControllerRegistry
- NetService
- NetClient
- DataService
- UIController
- Logger
- DataSchema

## FirstLoop 为什么算最小 Feature Pack

FirstLoop 不是正式玩法，但它跑通了：

```text
UI -> Client -> Remote -> Server -> DataService -> 返回 -> UI刷新
```

它具备：

- 功能目标：验证第一个可信数据闭环。
- Client 入口：`FirstLoopController`。
- Server 入口：`FirstLoopService`。
- Remote 合同：`FirstLoop.GetSnapshot` / `FirstLoop.GrantSmallGear`。
- Data 字段：`Resources.SmallGear` / `TutorialFlags.GainedSmallGear`。
- UI Contract：按钮、数量文本、错误文本。
- 验收规则：能点击、能返回、能刷新、能处理错误。
- 明确不做：不做正式战斗、不做正式 HUD、不接完整持久化。

所以它是“最小调试版 Feature Pack”。

## 标准实现顺序

```text
1. 从 GDD 或项目目标拆出一个 Feature Pack
2. 写 Feature Card
3. 明确 UI Contract / Asset Contract / Data 字段 / Remote 合同
4. 用户确认 UI 效果或 Studio 草稿
5. Codex 实现代码
6. Rojo 同步到 Studio
7. Studio Play 验收
8. 记录问题和修复
9. 更新 Feature Card 和交接文档
10. 再进入下一个 Feature Pack
```

## 来源

- [[../../10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/FirstLoop/第 7 课：为什么 FirstLoop 算一个最小 Feature Pack]]
- [[../../10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/FirstLoop/第 3 课 RemoteFunction 怎么从 Client 到 Server]]
- [[../../10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/FirstLoop/第 5 课：DataService  DataSchema 在 FirstLoop 里怎么配合]]

## 相关链接

- [[Client Server Remote 请求链路]]
- [[DataService 与 DataSchema 边界]]
- [[Roblox 项目架构职责边界]]

