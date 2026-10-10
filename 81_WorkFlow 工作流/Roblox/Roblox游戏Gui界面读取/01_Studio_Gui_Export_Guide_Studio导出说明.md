# Studio GUI 导出说明

## 使用场景

当 Codex 需要读懂 Roblox UI，或者需要知道你在 Studio 里手动改了哪些 UI 属性时，用这个导出流程。

## 导出模式

### 1. 总览导出：新项目先用

当你只是说“先读一下项目 / 先读一下文件”，Codex 应默认让你先运行：

```text
Tools/RobloxStudio_GuiOverviewExporter.luau
```

它只输出候选 GUI 根节点、类数量、简化树结构。它不负责精确属性同步。

### 2. HTTP 分段快照：正式读取默认用

正式读取 GUI 时，不论目标大还是小，默认使用 HTTP 分段模式。这个模式不会把完整 JSON 打到 Studio Output，而是把每一段发给 Codex 本机开的接收器。

Codex 先启动接收器：

```powershell
powershell -ExecutionPolicy Bypass -File "<WorkflowDir>\Tools\Start-GuiSnapshotReceiver.ps1" `
  -OutDir "<ProjectDir>\Project_Analysis_Package\GuiSnapshots" `
  -Name "<GuiName>_Current_Http"
```

然后 Codex 填写并让用户运行：

```text
Tools/RobloxStudio_GuiHttpSnapshotExporter.luau
```

脚本顶部只改项目参数：

```lua
local POST_URL = "http://127.0.0.1:18765/gui-snapshot"
local TARGET_JOBS = {
	{ name = "Root", path = "StarterGui/<ScreenGuiName>", maxDepth = 2 },
	{ name = "PageName", path = "StarterGui/<ScreenGuiName>/<PageName>" },
}
```

运行成功后，接收器会生成：

```text
<Name>.combined.json
<Name>.summary.md
<Name>_<SegmentName>.json
```

如果 Studio 报 HTTP 相关错误，先检查 `Game Settings > Security > Allow HTTP Requests` 是否开启。不能开启时，退回聚焦快照或 Output 分段快照。

### 3. Output 聚焦快照：备用

确认目标界面后运行：

```text
Tools/RobloxStudio_GuiSnapshotExporter.luau
```

脚本顶部有：

```lua
local TARGET_PATHS = {
	-- "StarterGui/<ScreenGuiName>/<PageOrPanelName>",
}
```

先运行总览导出器，再把候选路径填到这里。只导出一个页面、一个面板、一个弹窗、或一个模板。

通用例子：

```lua
local TARGET_PATHS = {
	"StarterGui/<ScreenGuiName>/<PageName>",
}
```

如果只同步某一块 UI，优先导出更小范围：

```lua
local TARGET_PATHS = {
	"StarterGui/<ScreenGuiName>/<PageName>/<PanelName>",
	"StarterGui/<ScreenGuiName>/<PopupName>",
}
```

如果 UI 模板在资源目录：

```lua
local TARGET_PATHS = {
	"ReplicatedStorage/Resource/ui/<GuiTemplateName>",
}
```

## 操作步骤

1. 打开 Roblox Studio，并打开目标项目。
2. 打开 `View > Output` 和 `View > Command Bar`。
3. 默认由 Codex 启动 HTTP 接收器，并修改 HTTP 导出脚本的 `TARGET_JOBS`。
4. 用户把 Codex 准备好的脚本粘贴到 Studio 的 Command Bar，按 Enter 运行。
5. 如果使用 HTTP 模式，Output 里只看状态信息，不需要复制完整 JSON。
6. 如果使用 Output 备用模式，才从 Output 复制导出内容，保存到：

```text
Project_Analysis_Package/GuiSnapshots/<有意义的名字>.md
```

HTTP 模式下，Codex 直接读取接收器生成的 `.combined.json` 和 `.summary.md`。

推荐命名：

```text
Gui_Overview.md
<GuiName>_<PageName>_After.md
<PanelName>_AfterManualEdit.md
<PopupName>_AfterFix.md
```

## 判断是否导出成功

聚焦快照里必须有这两个标记：

```text
## BEGIN_ROBLOX_GUI_SNAPSHOT_JSON
## END_ROBLOX_GUI_SNAPSHOT_JSON
```

如果 Output 被截断，通常会看到：

```text
[trimmed]
```

处理方式：

```text
1. 缩小 TARGET_PATHS，只导出一个页面、一个面板、或一个模板。
2. 不要一次导出整个 game，也不要默认导出整个 ScreenGui。
3. 重新运行并保存。
```

只有 `BEGIN` 没有 `END` 的快照，不能用于精确同步生成脚本。

HTTP 分段快照的成功标准：

```text
1. 接收器日志里出现 [done]。
2. summary 里 Missing Jobs = none。
3. 每个 segment 的 trimmed = False。
```
