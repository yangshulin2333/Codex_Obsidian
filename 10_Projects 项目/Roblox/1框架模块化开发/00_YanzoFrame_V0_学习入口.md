---
type: project
domain: roblox
status: active
owner: mixed
source: self
created: 2026-06-30
updated: 2026-07-08
---

# YanzoFrame_V0 学习入口

## 定位

`YanzoFrame_V0` 是 Roblox 可复用模块开发底座。

它不是完整游戏，也不是某个具体玩法项目。它的目标是：

```text
先把一个功能模块单独做懂、做稳，再接入别的 Roblox 项目。
```

## 边界

这里记录：

- 框架学习笔记
- 模块化开发规则
- Server / Client / Remote / Storage 边界
- 复制框架开发新模块的规则
- 个人易错点

这里不放：

- ToyBox 具体玩法实现
- 老板可见交接材料
- 素材上传台账
- 大而全的商城、背包、敌人系统实现

## 快速入口

1. [[01_框架总览|框架总览]]
2. [[02_启动链路_Main与Registry|启动链路 Main 与 Registry]]
3. [[03_Service与Controller规则|Service 与 Controller 规则]]
4. [[04_Net网络层|Net 网络层]]
5. [[05_Storage最小存储边界|Storage 最小存储边界]]
6. [[06_复制框架做新模块规则|复制框架做新模块规则]]
7. [[99_易错点与错题|易错点与错题]]

## 学习顺序

```text
Rojo 映射
-> Main.server.lua / Main.client.lua
-> ServiceRegistry / ControllerRegistry
-> Logger / Lifecycle
-> NetService / NetClient
-> StorageConfig / MemoryStorage / StorageService
-> StartupSmokeTest
-> 复制框架做新模块
```

## 当前原则

1. 先学懂底座，再做正式模块。
2. 每次只做一个模块。
3. 代码只生成必要内容。
4. 配置写表里，不把数值散落在逻辑里。
5. Server 决定真实数据，Client 只负责请求和显示。
6. Studio 管手工 UI 和 Workspace 位置，代码只管运行时行为。

## 后续模块方向

未来可以单独做：

- StorageModule
- EnemyModule
- Shop / CommerceCore
- InventoryModule
- HUDModule

但这些都不属于 `YanzoFrame_V0` 本体。
