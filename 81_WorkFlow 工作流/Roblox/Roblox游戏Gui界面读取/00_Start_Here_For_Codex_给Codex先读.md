# 给 Codex 先读：Roblox 游戏 GUI 界面读取

## 语言规则

用户英语水平是大学英语四级。默认中文说明，英文只保留 Roblox 类名、属性名、脚本名、文件名、API 名。

## 目标

本工作流的目标不是写玩法，也不是重构代码，而是先把 Roblox GUI 读懂。

要读懂的内容包括：

```text
1. GUI 树结构：ScreenGui、Frame、ImageLabel、ImageButton、TextLabel、ScrollingFrame 等。
2. 页面分层：共用层、页面层、左面板、右面板、弹窗、按钮、列表。
3. 当前显示状态：Visible、选中 Tab、当前页面 Attribute。
4. 布局方式：Position、Size、AnchorPoint、Scale / Offset、是否居中。
5. 素材使用：Image AssetId、SourceAsset、NormalImage、SelectedImage。
6. 九宫格切片：ScaleType = Slice、SliceCenter、SliceScale。
7. 滚动区域：ScrollingFrame、CanvasSize、AutomaticCanvasSize、ScrollBar。
8. 文字设置：TextScaled、TextXAlignment、TextYAlignment、TextStroke。
9. 用户手动改动：通过 before / after 两份快照对比，不靠截图猜。
10. 素材表状态：本地 PNG 是否存在、AssetId 是否为空、AssetId 格式是否可被 Roblox 使用。
```

## Codex 先做什么

```text
1. 找到本工作流目录。
2. 读取 WORKFLOW_MANIFEST.json 和本文件。
3. 如果用户只说“读一下项目 / 读一下文件”，默认先做 GUI 总览。
4. 从总览结果里挑一个目标 GUI 路径。
5. 默认启动 HTTP 接收器，并把目标路径填进 HTTP 导出器的 TARGET_JOBS。
6. 让用户在 Studio Command Bar 运行 HTTP 导出脚本。
7. 解析接收器生成的 `.combined.json` 和 `.summary.md`。
8. 输出 UI 读懂报告。
```

## 素材表读取规则

如果当前工作涉及 ImageLabel、ImageButton、按钮底图、卡片图、物品框图案，Codex 必须把“素材文件存在”和“AssetId 可用”分开判断。

合法 AssetId 格式包括：

```text
123456789
rbxassetid://123456789
https://www.roblox.com/library/123456789/xxx
```

如果 Codex 认为某行缺 AssetId，不能只在聊天里说“没找到”。必须先准备证据：

```powershell
python "<WorkflowDir>\Tools\Test-UiAssetMap.py" `
  --table "<ProjectDir>\Project_Analysis_Package\UI_AssetId_Map_For_UI_Build.xlsx" `
  --asset-root "<ProjectDir>\切图_正确解压" `
  --out "<ProjectDir>\Project_Analysis_Package\UI_AssetId_Map_Check_Report.md"
```

然后告诉用户：

```text
1. 我读取的是哪个表格文件。
2. 哪些 rel_path 行需要确认。
3. 这些行是“本地 PNG 不存在”、“AssetId 为空”，还是“AssetId 格式不合法”。
4. 如果用户表格窗口里有 ID，但报告里为空，先让用户保存表格，再重新运行检查。
5. 如果 `.xlsx` 和 `.csv` 结果不一致，以用户明确指定的表格源文件为准。
```

需要用户确认时，Codex 应该把能准备的东西先准备好：生成检查报告，必要时用 `-OpenCsv` 打开表格，而不是让用户自己找文件。

## 两段式导出

### 第一步：总览导出

新接手项目、用户没有说明具体 UI 路径时，先让用户在 Studio Command Bar 运行：

```text
Tools/RobloxStudio_GuiOverviewExporter.luau
```

总览只负责找候选 GUI 根节点，不导出大量属性，避免 Output 被截断。

### 第二步：正式快照默认用 HTTP

确认要读的界面后，默认走 HTTP 分段快照，不论目标大还是小。这样用户不用判断 Studio Output 会不会截断。

Codex 先在本机启动 HTTP 接收器：

```powershell
powershell -ExecutionPolicy Bypass -File "<WorkflowDir>\Tools\Start-GuiSnapshotReceiver.ps1" `
  -OutDir "<ProjectDir>\Project_Analysis_Package\GuiSnapshots" `
  -Name "<GuiName>_Current_Http"
```

然后由 Codex 打开并按当前项目填写：

```text
Tools/RobloxStudio_GuiHttpSnapshotExporter.luau
```

修改脚本顶部的 `TARGET_JOBS`，可以导出一个页面、一个面板、一个弹窗、一个模板，也可以按 Root + 多个 Page 分段导出。

路径格式示例：

```text
StarterGui/<ScreenGuiName>
StarterGui/<ScreenGuiName>/<PageName>
StarterGui/<ScreenGuiName>/<PageName>/<PanelName>
ReplicatedStorage/Resource/ui/<GuiTemplateName>
PlayerGui/<运行时 GUI>，仅在 Play 模式需要时使用
```

HTTP 模式下可以导出整棵 GUI，也可以分段导出：

```text
StarterGui/<ScreenGuiName>
```

为了后续维护，推荐按功能分段，例如 Root、PageA、PopupA。这样 Codex 后续只读取相关 segment，不会把整个大 JSON 都塞进上下文。

### 第三步：Output 只做备用

如果当前项目不能开启 HTTP Requests，才退回 Output 聚焦快照：

```text
Tools/RobloxStudio_GuiSnapshotExporter.luau
```

Output 模式必须缩小 `TARGET_PATHS`，只导出一个页面、面板、弹窗或模板。

HTTP 成功后 Codex 读取：

```text
<GuiName>_Current_Http.combined.json
<GuiName>_Current_Http.summary.md
```

HTTP 模式仍然是通用工作流。`TARGET_JOBS` 里的具体 GUI 名、页面名只能来自当前项目，不能写成工作流固定规则。

## 完整性判断

Output 备用快照必须同时包含：

```text
## BEGIN_ROBLOX_GUI_SNAPSHOT_JSON
## END_ROBLOX_GUI_SNAPSHOT_JSON
```

如果只有 `BEGIN` 没有 `END`，或者末尾出现 `[trimmed]`，这份快照不能用于精确同步模板。应缩小 `TARGET_PATHS` 重新导出。

如果走 HTTP 模式，则以 `<Name>.summary.md` 为完整性依据：

```text
Missing Jobs 必须为 none。
每个 segment 的 trimmed 必须为 False。
```

## 重要规则

如果只有一份导出快照，只能说“当前状态是什么”，不能武断说“用户改了什么”。

本工作流必须低耦合：

```text
1. 不内置某个项目的 ScreenGui 名字。
2. 不内置某个页面名、面板名、模板名。
3. 目标路径必须来自总览导出、用户说明、或当前项目文档。
4. 当前项目示例只能放在报告或示例区，不能变成工作流规则。
5. 用户指出的误判、流程摩擦、重复操作，要按 `07_Continuous_Improvement_经验复盘与自我改良.md` 评估是否沉淀。
```

如果要准确知道用户改动，必须有两份快照：

```text
Before：改动前
After：改动后
```

然后运行：

```powershell
powershell -ExecutionPolicy Bypass -File ".\Tools\Compare-GuiSnapshots.ps1" -Before "<before.md>" -After "<after.md>"
```

## 推荐输出文件

项目根目录下建议放：

```text
Project_Analysis_Package/
└─ GuiSnapshots/
   ├─ <GuiName>_<Scope>_After_Http.combined.json
   ├─ <GuiName>_<Scope>_After_Http.summary.md
   ├─ <GuiName>_<Scope>_Before.md
   ├─ <GuiName>_<Scope>_After.md
   └─ <GuiName>_<Scope>_Before_vs_After.diff.md
```

最终报告建议放：

```text
Project_Analysis_Package/Gui_Understanding_Report.md
```
