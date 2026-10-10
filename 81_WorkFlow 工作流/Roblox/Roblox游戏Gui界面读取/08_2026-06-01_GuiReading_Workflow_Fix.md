# 2026-06-01 GUI 读取工作流修复记录

## 这次暴露的问题

用户在 Studio 里修改了 `RewardTitleGroup/RightLine.Rotation`，新快照已经读到了 `Rotation = 180`，但分析时没有被报告出来。

根因不是 Studio 导出失败，而是工作流的对比层不够严格：

```text
1. Compare-GuiSnapshots.ps1 的关键字段列表没有包含 props.Rotation。
2. 旧整包 MainGui 和新拆分 PageGui 的根路径不同，直接按完整 path 对比会把同一节点误判成新增/删除。
3. 只拿 after 快照时，只能说明当前状态，不能严格回答“用户刚才改了什么”。
4. HTTP 保存成功时不应该把大 JSON 打到 Studio Output；Output 只能输出简短状态。
```

## 已固化的新规则

### 1. 回答“用户改了什么”必须基于 before / after

如果用户问“我刚才改了哪些 UI”，Codex 必须先确认是否有两份快照：

```text
Before: 修改前
After: 修改后
```

只有 after 时，只能回答：

```text
我能确认当前 UI 状态，但不能严格证明哪些是你刚才改的。
```

### 2. 对比不同根路径时必须传入根路径归一化参数

旧整包和新拆分页的路径可能不同，例如：

```text
BeforeRoot = StarterGui/MainGui/Root/Pages/MainPage
AfterRoot  = StarterGui/MainPageGui/Root/MainPage
```

这种情况下运行：

```powershell
powershell -ExecutionPolicy Bypass -File ".\Tools\Compare-GuiSnapshots.ps1" `
  -Before "<BeforeMainPage.json>" `
  -After "<AfterMainPage.json>" `
  -BeforeRoot "StarterGui/MainGui/Root/Pages/MainPage" `
  -AfterRoot "StarterGui/MainPageGui/Root/MainPage"
```

这样 `WindowLayer/TaskWindow/RewardTitleGroup/RightLine` 会被识别为同一个相对节点。

### 3. 关键 UI 属性必须覆盖旋转和布局

对比报告必须覆盖这些高风险字段：

```text
Rotation
Position
Size
AnchorPoint
Visible
ZIndex
LayoutOrder
Image
ImageColor3
ImageTransparency
ScaleType
SliceCenter
SliceScale
Text
TextColor3
TextStrokeColor3
TextStrokeTransparency
TextXAlignment
TextYAlignment
BackgroundColor3
BackgroundTransparency
CanvasSize
AutomaticCanvasSize
UIListLayout / UIGridLayout / UIPadding 相关属性
```

### 4. HTTP 导出器必须默认不刷大 JSON 到 Output

正式 GUI 快照走本地 HTTP 保存，Studio Output 只允许输出简短状态，例如：

```text
[GuiHttpSnapshotExporter] POSTED ...
[GuiHttpSnapshotExporter] DONE
```

HTTP 失败时只 warning，不把完整 JSON 打到 Output。

### 5. TARGET_JOBS 为空时允许自动发现 GUI 根节点

为了减少用户操作，`RobloxStudio_GuiHttpSnapshotExporter.luau` 在 `TARGET_JOBS` 为空时会自动发现：

```text
StarterGui 下的 ScreenGui
ReplicatedStorage/Resource/ui 下的 ScreenGui 或 GuiObject
Play 运行时 PlayerGui 下的 ScreenGui
```

如果项目很大，Codex 仍然可以手动填写 `TARGET_JOBS` 做精确分段。

## 本次工具更新

```text
Tools/RobloxStudio_GuiHttpSnapshotExporter.luau
- 新增自动发现 StarterGui / Resource.ui / PlayerGui 的 GUI 根节点。
- 新增 HTTP POST 失败保护：失败只 warning，不输出完整 JSON。
- 保留手动 TARGET_JOBS；手动填写时优先使用手动分段。

Tools/Compare-GuiSnapshots.ps1
- 新增 -BeforeRoot / -AfterRoot，用于不同根路径快照的相对路径对比。
- 关键字段加入 props.Rotation，并去掉容易因导出器版本不同产生噪声的 props.AbsoluteRotation。
- 补充 ImageColor3、BackgroundColor3、文字描边、Padding、Grid/ListLayout 等字段。
- 不再整体比较 attributes 对象，改为比较 SourceAsset、IsTemplate、DesignW 等常用属性，避免 JSON 字段顺序导致误报。
```

## 验证要求

每次更新本工作流后至少运行：

```powershell
stylua --check "<WorkflowDir>\Tools\RobloxStudio_GuiHttpSnapshotExporter.luau"
$script = Get-Content -Raw -Encoding UTF8 "<WorkflowDir>\Tools\Compare-GuiSnapshots.ps1"; [scriptblock]::Create($script) | Out-Null
python -m py_compile "<WorkflowDir>\Tools\Receive-GuiSnapshotHttp.py"
```

如果手上有 before / after 快照，还要用 `Compare-GuiSnapshots.ps1` 实测能否报告 `Rotation` 变化。
