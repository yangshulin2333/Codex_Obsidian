---
type: concept
domain: roblox
status: evergreen
owner: codex
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# RobloxGameFramework 启动链路

## 一句话说明

RobloxGameFramework 是一个通用工程骨架，核心是显式启动服务端 Service、客户端 Controller，并用 NetService / NetClient 统一通信。

## 它已经解决什么

- Rojo 文件映射。
- 服务端启动顺序。
- 客户端启动顺序。
- Server / Client 职责分离。
- Remote 统一创建和调用。
- 数据入口统一走 DataService。
- 玩法以 Feature Pack 方式接入。

它还不是完整 RPG 框架，不包含正式战斗、背包、怪物 AI、掉落、Boss、ProfileStore、正式 UI。

## 服务端启动线

```text
Main.server.lua
-> ServiceRegistry.new()
-> registry:Init()
-> registry:Start()
-> ServiceList 里的每个 Service
```

核心理解：

- `Main.server.lua` 只启动 `ServiceRegistry`。
- `ServiceList` 是启动名单，数组顺序有意义。
- `Init(context)` 用来准备引用。
- `Start()` 才真正连接事件和开始运行。
- 新服务不要直接写进 `Main.server.lua`，而是加进 `ServiceList`。

## 客户端启动线

```text
Main.client.lua
-> ControllerRegistry.new()
-> registry:Init()
-> registry:Start()
-> ControllerList 里的每个 Controller
```

Controller 只能负责：

- 输入。
- UI。
- 镜头。
- 音效。
- VFX。
- 向 Server 发请求。

不能负责：

- 发奖励。
- 改存档。
- 决定伤害。
- 决定掉落。
- 决定货币变化。

## Context 工具包

服务端 Service 常见 context：

```text
Logger
Services
```

客户端 Controller 常见 context：

```text
Logger
Net
Controllers
```

这叫依赖注入。模块不自己创建其他系统，而是从框架传进来的 context 里拿。

## 网络线

```text
Client Controller
-> NetClient.Request()
-> RemoteFunction
-> NetService:RegisterRequest()
-> Server handler
-> NetResult.Ok / NetResult.Err
-> Client UI 展示
```

## 新功能接入路线

新增一个服务端玩法：

```text
创建 XxxService.lua
-> 写 Name / Init / Start
-> 在 Start 里注册 Remote handler
-> 加进 ServiceList.lua
```

新增一个客户端玩法：

```text
创建 XxxController.lua
-> 写 Name / Init / Start
-> 从 context.Net 发请求
-> 从 context.Controllers 拿其他 Controller
-> 加进 ControllerList.lua
```

## 来源

- [[20_Areas 领域/Roblox/框架/RobloxGameFramework/通用 Roblox 工程骨架]]
- [[20_Areas 领域/Roblox/框架/RobloxGameFramework/第2课：服务端启动链路]]
- [[20_Areas 领域/Roblox/框架/RobloxGameFramework/第3课：客户端启动链路]]
- [[20_Areas 领域/Roblox/框架/RobloxGameFramework/第4课：网络通信：NetService  NetClient  NetResult]]

## 相关链接

- [[Feature Pack 与 Feature Card]]
- [[Client Server Remote 请求链路]]
- [[DataService 与 DataSchema 边界]]

