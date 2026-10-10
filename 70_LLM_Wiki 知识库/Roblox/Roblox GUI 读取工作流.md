---
type: workflow
domain: roblox
status: evergreen
owner: codex
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# Roblox GUI 读取工作流

## 一句话说明

GUI 读取工作流用于从 Roblox Studio 导出真实 UI 节点和属性，避免 Codex 只靠截图猜 UI 结构。

## 解决的问题

- 不靠截图猜 ScreenGui / Frame / ImageLabel / TextLabel 层级。
- 导出 Position、Size、AnchorPoint、Visible、ZIndex、Image、ScaleType、SliceCenter、TextScaled、CanvasSize 等关键属性。
- 对比 before / after，判断用户在 Studio 里手动改了什么。
- 输出中文 UI 读懂报告，方便后续继续接脚本、数据绑定和素材表。

## 常用流程

```text
1. Codex 先读工作流 Start Here 文档
2. 用户在 Studio 打开目标项目
3. 新项目先运行 GuiOverviewExporter 找候选 GUI 根节点
4. 正式快照默认走 HTTP 分段模式
5. Codex 启动 Start-GuiSnapshotReceiver.ps1
6. Codex 填 TARGET_JOBS
7. 用户在 Studio Command Bar 运行导出脚本
8. Codex 读取 combined.json 和 summary.md
9. 需要比较手动改动时，导出 before / after 并运行 Compare-GuiSnapshots.ps1
```

## 关键规则

- 正式 GUI 快照默认使用 HTTP 分段模式。
- 不默认把整个 ScreenGui JSON 打到 Studio Output。
- Output 备用快照必须有 BEGIN 和 END 标记。
- 如果 Output 出现 trimmed，这份快照不能用于精确同步模板。
- 工作流不绑定某个项目的 GUI 名、页面名或面板名。
- 涉及 UI 图片素材表时，先运行 `Test-UiAssetMap.py` 验证 AssetId。

## 什么时候使用

- 用户在 Studio 里手动搭了 UI，需要 Codex 读懂结构。
- 需要把 UI 接到 Controller / DataService / Remote 链路。
- 需要排查按钮、文本、图片、滚动区域、层级或比例问题。
- 需要比较 UI 修改前后的差异。
- 需要确认素材表里 AssetId 是否可用。

## 来源

- [[81_WorkFlow 工作流/Roblox/Roblox游戏Gui界面读取/README]]

## 相关链接

- [[Roblox 项目接手工作流]]
- [[Client Server Remote 请求链路]]
- [[Feature Pack 与 Feature Card]]

