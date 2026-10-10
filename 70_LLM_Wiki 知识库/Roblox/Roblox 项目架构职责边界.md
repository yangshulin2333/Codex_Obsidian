---
type: concept
domain: roblox
status: evergreen
owner: codex
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# Roblox 项目架构职责边界

## 一句话说明

Roblox 项目要长期可维护，核心不是文件夹名字，而是把 Client、Server、Shared、Assets、Services、Config 的职责分清楚。

## 为什么重要

新手项目最容易变乱的地方是：

- 所有代码塞进一个服务。
- UI 逻辑到处写 LocalScript。
- RemoteEvent 手动乱建。
- 客户端直接决定游戏结果。
- 配置、数据、UI、服务端规则混在一起。

一旦项目变大，这些问题会让功能难改、Bug 难查、交接困难。

## 推荐边界

| 层 | 职责 | 不应该做什么 |
|---|---|---|
| Shared | 客户端和服务端都能用的配置、常量、类型、工具 | 放服务端核心规则或敏感逻辑 |
| Client | 输入、UI、镜头、本地视觉反馈 | 直接修改真实数据或决定奖励结果 |
| Server | 数据、安全验证、核心游戏规则 | 相信客户端传来的结果 |
| Services | 按系统拆分游戏能力，如背包、商店、敌人、数据 | 一个 Service 管所有功能 |
| Config | 物品表、价格表、奖励表、资源上限 | 散落在 UI 或服务里写死 |
| Assets | 模型、动画、VFX、SFX、UI 模板 | 和运行时代码混放 |

## 最小闭环

当前阶段最适合用这个链路学习和开发：

```text
配置定义
-> UI / Client 发起请求
-> Remote
-> Server Service 验证
-> DataService 写入
-> Server 返回结果
-> Client 刷新 UI
-> 测试检查
```

## 核心规则

- 客户端负责体验，服务端负责规则。
- UI 只发请求和显示结果，不直接改玩家真实数据。
- Remote 名称和创建方式要集中管理。
- DataService 只管数据读写入口，不写具体玩法规则。
- Config 是多个系统共享同一份规则的地方。
- 启动脚本要薄，只负责启动模块，不写复杂业务。

## 适合当前阶段的结构

```text
ReplicatedStorage
├─ Shared
│  ├─ Configs
│  ├─ Remotes
│  └─ Modules
│
ServerScriptService
├─ Server
├─ Services
└─ Data

StarterPlayer
└─ StarterPlayerScripts
   └─ Client

StarterGui
└─ UI
```

## 来源

- [[20_Areas 领域/Roblox/框架/项目框架]]

## 相关链接

- [[Rojo 工程生产线]]
- [[Client Server Remote 请求链路]]
- [[DataService 与 DataSchema 边界]]
- [[Feature Pack 与 Feature Card]]

