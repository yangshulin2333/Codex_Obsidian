---
type: project
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# ToyBox 项目索引

## 一句话说明

ToyBox 当前的核心方向是“打怪捡零件，拼出永远有用的发条玩具”，技术上先用 FirstLoop 验证 UI 到 Server 到 DataService 的可信闭环。

## 核心策划方向

核心特色：

```text
发条拼装台：打怪捡零件，拼出永远有用的发条玩具。
```

核心循环：

```text
打怪掉零件
-> 选择零件
-> 拧发条小游戏
-> 拼出发条玩具
-> 进入玩具箱
-> 上阵 / 装配 / 升星 / 收藏
```

核心原则：

- 不是单纯宠物。
- 不是单纯武器模块。
- 拼出来的玩具要永远有用。
- 重复玩具自动转碎片。
- 低品质也能升星、合成、收藏、派遣或新手过渡。

## 技术学习入口

FirstLoop 是第一个可信数据闭环：

```text
Client UI
-> Remote 请求
-> Server 校验
-> DataService 写数据
-> Server 返回结果
-> Client 刷新 UI
```

FirstLoop 涉及：

- Server 入口：`Main.server.lua`
- Service 启动：`ServiceRegistry` / `ServiceList`
- Client 入口：`Main.client.lua`
- Controller 启动：`ControllerRegistry` / `ControllerList`
- 通信：`NetClient` / `NetService` / `NetResult`
- 数据：`DataService` / `DataSchema`
- UI：`FirstLoopDebugGui` / `FirstLoopController`

## 当前 Wiki 相关页

- [[Feature Pack 与 Feature Card]]
- [[Client Server Remote 请求链路]]
- [[DataService 与 DataSchema 边界]]
- [[RobloxGameFramework 启动链路]]
- [[Luau 语法最小掌握]]

## 项目交付备份

- [[../../10_Projects 项目/Roblox/玩具/ToyboxGuardiansDemo/GDD备份/玩具箱守卫者 GDD v2.5 Word 备份|玩具箱守卫者 GDD v2.5 Word 备份]]：给同事传阅的 `Work v2.5` Word 策划案备份。

## 后续应整理的 ToyBox 主题

- CombatTrainingEnemy Feature Pack。
- PlayerHUD。
- 发条拼装台 UI 流程。
- 6 个发条玩具详细卡。
- 拼装概率和保底规则。
- 玩具箱 / 上阵 / 装配 / 升星 / 收藏。

## 来源

- [[../../10_Projects 项目/Roblox/玩具/玩具箱守卫者_发条拼装核心特色策划方案]]
- [[../../10_Projects 项目/Roblox/玩具/ToyboxGuardiansDemo/GDD备份/玩具箱守卫者 GDD v2.5 Word 备份]]
- [[../../10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/FirstLoop/1 FirstLoop 文件地图]]
- [[20_Areas 领域/Roblox/框架/RobloxGameFramework/第6课：用 001_FirstLoop 串成完整闭环]]

## 待确认

- 当前运行项目和 spec hub 的最新状态仍需从 `D:\AI\Codex\ToyBox` 当前文档确认。
- 这里是 Obsidian 知识索引，不替代 ToyBox runtime 项目 handoff。
