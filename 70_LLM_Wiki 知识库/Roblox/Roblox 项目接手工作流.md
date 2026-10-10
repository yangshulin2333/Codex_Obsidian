---
type: workflow
domain: roblox
status: evergreen
owner: codex
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# Roblox 项目接手工作流

## 一句话说明

接手 Roblox 旧项目时，不要直接改功能。先把源码、Studio 场景、配置、Remote、资源和最小玩法链路读清楚。

## 接手第一原则

```text
不要只看 Lua，也不要只看 Studio。
真实项目状态 = 源码 + 配置 + Studio 资源 + 运行验证。
```

## 最小接手流程

```text
1. 确认项目来源和当前目标
2. 检查本地环境和 Rojo 状态
3. 读取 default.project.json 和 src 结构
4. 确认 Studio place 文件和 Resource 是否存在
5. 导出脚本、Remote、AssetId、Explorer 树、关键资源树
6. 追一条最小玩法链路
7. 列出风险点和断点
8. 写总接管报告
9. 决定第一阶段只修哪个最小闭环
```

## 旧项目常见风险

- `default.project.json` 只同步源码，但资源在 `.rbxl` 场景文件里。
- Rojo 版本和项目声明版本不一致。
- Studio 里有 `Resource`、`Stage`、`ui`、怪物模型等非源码资源。
- UIList 里没有安装某些代码引用的 UI。
- 旧项目残留引用还在代码里，但实际资源已经不存在。
- Remote 安全校验被注释或缺失。
- Git / SVN / 临时复制目录之间的版本来源不清楚。

## 必须在 Studio 中确认的内容

- `ReplicatedStorage.Resource` 是否存在。
- `Resource.Stage.stage1` 结构是否和代码一致。
- `Resource.monster` 是否包含配置表里引用的模型。
- `Resource.ui.HudGui` 和 `Resource.ui.BagGui` 层级是否和代码一致。
- `workspace.Stage` 是否存在。
- Rojo 插件能否连接。
- Play 后是否能进入最小主流程。

## Codex 可读导出包

如果 Codex 无法直接读取 `.rbxl`，要用导出脚本把 Studio 信息转成文本：

- Explorer 树
- 脚本源码
- Remote 列表
- AssetId 列表
- 关键资源树
- GUI 快照
- 最终接管报告

项目导出不要无限扩张。当关键脚本、Remote、AssetId、目标源码、关键资源树已经完成，且最后一轮资源树有结束标记时，应停止导入，进入总报告和第一阶段目标决策。

## 第一阶段目标

先跑通最小闭环，不要先修所有问题。

推荐优先级：

```text
能启动
-> 能连接 Rojo
-> 能进入主场景
-> 能触发一条核心玩法
-> 能看到 UI 或状态反馈
-> 再修资源、UI、动画、特效、音效
```

## 来源

- [[10_Projects 项目/Roblox/精灵/PROJECT_TAKEOVER_DEVELOPMENT_GUIDE]]
- [[81_WorkFlow 工作流/Roblox/Roblox项目读取/README]]

## 相关链接

- [[Rojo 工程生产线]]
- [[Roblox GUI 读取工作流]]
- [[Roblox 项目架构职责边界]]

