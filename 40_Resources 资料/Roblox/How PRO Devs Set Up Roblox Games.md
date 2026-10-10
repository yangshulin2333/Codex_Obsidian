---
type: resource
domain: roblox
status: studied
source_type: youtube
title: How PRO Devs Set Up Roblox Games
source: https://www.youtube.com/watch?v=F3ASTJuO82A&t=8s
author: Leif
published: 2025-08-29
updated: 2026-06-26
tags:
  - Roblox
  - GameDev
  - Luau
  - Architecture
  - Obsidian
---

# How PRO Devs Set Up Roblox Games

## 一句话总结

这个视频讲的是：Roblox 项目变复杂后，真正让项目崩掉的往往不是某一段代码，而是项目结构混乱。专业开发者会提前把项目拆成服务、模块、类、UI、资源和 packages，让代码可维护、可扩展、可复用。

## 核心原则

- 游戏逻辑按“服务”拆分，每个服务负责游戏中的一个领域。
- 客户端逻辑、服务端逻辑、共享逻辑要分开放。
- 服务端代码必须放在不会复制给客户端的容器里，避免被利用者下载。
- RemoteEvent / RemoteFunction 不建议手动散落创建，最好通过代码或网络库统一管理。
- 可复用逻辑放进 packages，不和具体游戏业务绑定。
- UI 要模块化，避免所有界面逻辑堆在一起。
- 越早组织项目结构，后期越不容易失控。

## 推荐项目结构

```text
ReplicatedStorage
├── Shared
│   ├── Services
│   │   └── BuildService
│   │       ├── BuildServiceClient
│   │       └── BuildServiceUtil
│   ├── Classes
│   ├── Modules
│   │   ├── Core
│   │   ├── Game
│   │   ├── Math
│   │   └── Platform
│   ├── UI
│   │   ├── UIInit
│   │   ├── Menus
│   │   └── HUD
│   ├── Packages
│   └── Assets
│       ├── Models
│       ├── VFX
│       └── UI
│
ServerScriptService
├── Services
│   └── BuildService
│       └── BuildServiceServer
├── Classes
└── Server
    └── ServerStartup
│
StarterPlayer
└── StarterPlayerScripts
    └── Client
```

## 1. Services：把游戏逻辑拆成服务

服务是游戏逻辑的主要组织单位。每个服务负责一个清晰的领域。

例子：

- `BuildService`：处理玩家建造、放置零件。
- `EnemyService`：处理敌人生成、追踪、状态。
- `InventoryService`：处理背包、物品、装备。
- `PartService`：如果只需要共享逻辑，可能不需要客户端和服务端各一份。

一个服务通常会拆成：

- Client 版本：客户端表现、输入、UI 调用。
- Server 版本：权威逻辑、校验、数据修改。
- Utility 模块：客户端和服务端都能复用的工具逻辑或共享数据。

重点：服务端版本必须放在 `ServerScriptService` 下，避免客户端拿到敏感逻辑。

## 2. Service 是 Singleton

视频推荐把每个 service 当成 singleton 使用。

也就是说：

- 不要 `BuildService.new()`。
- 模块本身就是唯一实例。
- 一个游戏里只有一个 `BuildService`、一个 `InventoryService`。

常见结构：

```lua
local BuildServiceClient = {}

function BuildServiceClient.Init(self)
    -- 创建对象、绑定事件、初始化非阻塞逻辑
end

function BuildServiceClient.Build(self, cframe)
    -- 建造逻辑
end

return BuildServiceClient
```

服务一般会有 `Init` 函数，用来做启动时初始化。作者强调：这里适合放创建对象或非 yield 的启动逻辑。

## 3. Luau 类型写法注意点

当前 Luau 类型检查器对 `self` 的推断不总是理想。作者建议在需要强类型和 IntelliSense 的场景下，少用冒号语法，改成显式传入 `self`。

思路是：

```lua
type BuildServiceClient = {
    Parts: Model,
    Init: (self: BuildServiceClient) -> (),
    Build: (self: BuildServiceClient, cframe: CFrame) -> (),
}

local BuildServiceClient = {} :: BuildServiceClient
```

这样做的好处：

- `self` 类型更清楚。
- 成员变量可以被类型系统识别。
- 其他脚本 require 这个 service 时，自动补全更好。

## 4. Client / Server 启动脚本

客户端需要一个统一入口，例如放在：

```text
StarterPlayerScripts/Client
```

这个脚本负责启动客户端服务：

```lua
local BuildServiceClient = require(...)

BuildServiceClient.Init(BuildServiceClient)
```

如果初始化顺序重要，就手动一个个初始化。  
如果顺序不重要，可以循环 services 文件夹，对每个识别到的 service 调用 `Init`。

服务端也一样，需要在 `ServerScriptService` 下有一个 server startup script，用来初始化服务端 services。

## 5. 网络通信：不要让客户端直接“命令”服务端

客户端和服务端通信必须通过 RemoteEvent / RemoteFunction，但作者不建议手动创建一堆 Remote 实例。

原因：

- 层级树会变乱。
- 依赖名字字符串，容易写错。
- 版本 diff 难管理。
- 项目大了以后维护困难。

更好的做法：

- 通过代码创建 remotes。
- 用 networking wrapper 或现成库统一管理。
- 可用方案包括 `ByteNet`、`Blink`、`Zap`。
- 作者自己也有一个 networking solution，放在 GitHub。

关键安全思想：

客户端不应该告诉服务端：“我已经在这里建造了。”  
客户端应该问服务端：“我可以在这里建造吗？”

然后服务端负责：

- 验证位置是否合法。
- 检查冷却时间。
- 检查玩家权限、资源、距离等。
- 决定是否真的执行。

视频示例里，客户端调用服务端的 `AttemptBuild`，服务端用 5 秒 cooldown 做校验。

## 6. Classes：可复用对象用面向对象组织

除了 services，专业项目还会用 classes 管理可复用游戏对象。

例子：`Spike` 类。

原本 `BuildService` 可能只是创建一个普通 Part；改成 class 后，它创建的是一个 `Spike` 对象。这个对象可以封装：

- 模型创建。
- 碰撞检测。
- 玩家触碰后扣血。
- 清理逻辑。
- 状态管理。

classes 也要遵守 client / server 分离原则：

```text
ReplicatedStorage/Shared/Classes
ServerScriptService/Classes
```

如果类里有服务端敏感逻辑，就放服务端。

##### 举个超级简单的例子

```lua
local Spike = {}
Spike.__index = Spike  -- 意思：我的方法都存在 Spike 这个表里，找不到就去那里查。

function Spike:Attack()  -- 这个方法存在 Spike 里
    print("攻击")
end
```
然后你创建对象：
```lua
local spike = Spike.new()
spike:Attack()
```
执行过程：
1. `spike` 自己身上没有 `Attack` 方法
2. 因为写了 `__index = Spike`
3. 自动去 `Spike` 这个类里找 `Attack`
4. 找到了，执行成功
## 7. Assets：模型、特效和实例资源统一管理

自定义模型、VFX、UI 资源等，建议放在：

```text
ReplicatedStorage/Assets
```

例如：

```text
Assets
├── Models
│   └── Spike
├── VFX
└── UI
```

视频中 `Spike` 类从 `Assets` 里读取自定义 spike mesh，而不是直接创建普通 Part。这样资源和逻辑分离，后续替换模型也更方便。

## 8. Modules：共享功能要小而清晰

Modules 用于放通用功能、共享数据、工具函数。

作者建议继续区分 shared 和 server，并进一步按类别分组：

- `Core`：核心基础能力。
- `Game`：游戏相关工具。
- `Math`：数学、空间、向量计算。
- `Platform`：平台适配、设备判断等。

原则：

- 一个 module 只做一类事。
- 不要把所有 helper 都塞进一个巨大的工具文件。
- 让别人看到路径就知道它大概负责什么。

## 9. UI：界面最容易变乱，必须模块化

Roblox 项目里 UI 很容易失控。专业团队会把 UI 做成模块化结构。

高级方案：

- React
- Fusion
- Vide

作者目前用 React，也做过 Fusion 生产项目。

但如果还不想进入声明式 UI 工作流，可以用中间方案：

```text
ReplicatedStorage/Shared/UI
├── UIInit
├── Menus
│   └── InventoryMenu
└── HUD
    └── LeftSidebar
```

每个 UI feature 有自己的 ModuleScript，并暴露：

- `Init`
- 显示 / 隐藏方法
- 更新数据方法
- 事件绑定方法

顶层 `UIInit` 负责初始化这些 UI 模块，最后在 `Client` 启动脚本里调用 UI initializer。

好处：保留熟悉的 Roblox UI 工作流，同时获得更好的可扩展性。

## 10. Packages：把可复用工具和游戏业务分离

Packages 是不依赖具体游戏逻辑的可复用脚本。  
它们应该可以被直接复制到其他项目继续用。

作者常用 packages：

- `Signal`：纯代码版 BindableEvent 替代方案，更轻、更好管理。
- `Charm`：原子化状态管理，适合搭配声明式 UI。
- `Sift`：表工具库，提供大量 table 操作函数。
- `DataService`：持久化数据方案，支持客户端同步和 observable values。
- `Janitor`：清理连接、实例、事件绑定，避免内存泄漏。
- Networking package：统一处理客户端和服务端通信。

如果使用 VS Code 工作流，作者推荐用 `Wally` 管理 packages，方便版本控制和更新。

## 实战检查清单

- [ ] 是否按领域拆分了 services？
- [ ] 服务端代码是否都放在 `ServerScriptService`？
- [ ] 客户端是否只负责输入、表现和请求？
- [ ] 服务端是否负责最终校验和权威状态？
- [ ] Remote 是否通过代码或网络库统一创建？
- [ ] 是否有统一的 client startup 和 server startup？
- [ ] 可复用对象是否抽成 classes？
- [ ] 模型、VFX、UI 资源是否放进 `Assets`？
- [ ] 工具函数是否按类别放进 modules？
- [ ] UI 是否按 feature 拆分？
- [ ] 通用能力是否抽成 packages？
- [ ] 是否避免了一个脚本承担太多职责？

## 我自己的理解

这套结构的重点不是“文件夹看起来专业”，而是控制复杂度。

Roblox 小项目可以随便写，但项目一旦多人协作、功能变多、UI 变复杂，如果没有明确边界，就会出现这些问题：

- 不知道代码该放哪里。
- 客户端和服务端职责混在一起。
- Remote 到处散落。
- UI 互相引用，越改越乱。
- 工具函数重复写。
- 后期很难重构。

视频推荐的结构，本质上是在项目早期就建立边界：

- Services 管业务系统。
- Classes 管可复用对象。
- Modules 管工具和数据。
- UI 管界面功能。
- Assets 管资源。
- Packages 管跨项目复用能力。
- ServerScriptService 管服务端权威逻辑。
- ReplicatedStorage 管客户端可见的共享内容。

## 最重要的结论

Roblox 专业项目的核心不是某个框架，而是提前建立可扩展结构。  
先把 services、modules、classes、UI、assets、packages 分清楚，后面项目变大时才不会混乱。
