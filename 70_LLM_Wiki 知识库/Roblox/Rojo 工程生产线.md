---
type: workflow
domain: roblox
status: evergreen
owner: codex
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# Rojo 工程生产线

## 一句话说明

Rojo 不是单个插件，而是一条 Roblox 工程生产线：VS Code 写代码，Git 管版本，Rojo 同步到 Studio，Studio 负责运行、调试、摆场景和发布。

## 开发边界

| 内容 | 推荐位置 |
|---|---|
| 本地源码 | VS Code + Git |
| 场景、美术摆放、资源预制体 | Roblox Studio |
| 服务端逻辑 | `ServerScriptService` |
| 客户端逻辑 | `StarterPlayerScripts` / `StarterGui` |
| 共享配置 | `ReplicatedStorage/Shared` |
| 同步映射 | `default.project.json` |

## 标准启动流程

```text
1. 创建或检查 Rojo 项目骨架
2. 配置 default.project.json
3. 运行 rojo serve
4. 打开 Roblox Studio
5. Studio 里用 Rojo 插件 Connect
6. 检查文件是否进入正确服务
7. Play 测试一次最小闭环
8. 必要时 rojo build 生成 rbxlx
```

## 最小项目骨架

```text
src/
  ReplicatedStorage/
    Shared/
  ServerScriptService/
    Services/
  StarterPlayer/
    StarterPlayerScripts/
      ClientModules/
default.project.json
README.md
.gitignore
```

## 关键经验

- `.server.lua` 会变成 Script。
- `.client.lua` 会变成 LocalScript。
- 普通 `.lua` / `.luau` 通常变成 ModuleScript。
- `default.project.json` 的 `$path` 决定本地目录映射到 Roblox DataModel 的位置。
- 不要用空白 Baseplate 直接连接依赖场景资源的旧项目，否则容易缺 `Resource`、`Stage`、UI、模型、特效。
- 接手旧项目时，Rojo 只能代表源码侧，真实运行还依赖 Studio 场景和资源。

## 新项目不要默认做什么

- 不默认生成 UI 奖励玩法。
- 不默认接 DataStore。
- 不默认接 Robux 商品。
- 不一次性引入大型框架。
- 不跳过 Studio 连接和 Play 验证说明。

## 来源

- [[20_Areas 领域/Roblox/Rojo/Rojo 新项目前置准备]]
- [[81_WorkFlow 工作流/Roblox/Roblox新项目环境搭建工作流/使用手册]]
- [[10_Projects 项目/Roblox/精灵/PROJECT_TAKEOVER_DEVELOPMENT_GUIDE]]

## 相关链接

- [[Roblox 项目架构职责边界]]
- [[Roblox 项目接手工作流]]

