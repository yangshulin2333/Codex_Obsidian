# Studio 手动改动后，同步回生成脚本

当用户在 Roblox Studio 里手动调整了 UI，Codex 想准确知道改动并同步回生成脚本时，走这个流程。

## 输入参数

这个模板是通用的，不绑定任何项目名称。

```text
<WorkflowDir>：Roblox游戏Gui界面读取 工作流目录
<ProjectDir>：当前 Roblox 项目目录
<TargetPath>：要读取的 GUI 节点路径
<BeforeSnapshot>：改动前快照，可选
<AfterSnapshot>：改动后快照，必需
<TemplateNode>：需要同步的模板节点，可选
```

## 日常协作流程

这是正常流程，不是调试流程。用户只负责在 Studio 里做视觉调整，以及运行 Codex 已经改好的导出脚本。

```text
1. 用户在 Studio 里改 UI。
2. 用户告诉 Codex：改了哪个界面、哪个区域、想让 Codex 知道还是同步回脚本。
3. Codex 根据当前项目结构，用 `Start-GuiSnapshotReceiver.ps1` 启动 HTTP 接收器，并把 HTTP 导出器的 TARGET_JOBS 改成合理范围。
4. 用户只需要复制导出脚本到 Studio Command Bar 运行，不需要复制完整 Output。
5. Codex 读取接收器生成的 `.combined.json` / `.summary.md` / 分段 JSON。
6. 如果只是“让 Codex 知道”，Codex 更新理解和说明即可。
7. 如果需要“同步回脚本”，Codex 修改生成脚本或模块代码。
8. 如果涉及素材表，Codex 先运行 `Test-UiAssetMap.py`，直接读取用户指定的 `.xlsx` 或 `.csv`，确认 AssetId 可用后再改脚本。
9. Codex 跑格式检查和项目可生成性检查。
```

## 用户怎么说最省事

用户不需要描述一堆属性值，只要说清楚范围和目的：

```text
我改了 MainPage 的任务列表，帮我同步模板。
我改了 KeyTipPanel 的样式，先让你掌握，不用改脚本。
我改了某个按钮位置，帮我同步回生成脚本。
我不确定改了哪里，你先按当前界面读一下。
```

如果用户已经知道具体区域，Codex 不应该让用户手动编辑导出脚本；应该由 Codex 修改 `TARGET_JOBS` 或备用导出器的 `TARGET_PATHS`，用户只负责在 Studio 执行脚本。

如果 Codex 发现疑点，例如素材表里没读到 AssetId、快照缺节点、或者截图和磁盘文件不一致：

```text
1. Codex 必须先说清楚自己读的是哪个文件。
2. Codex 必须准备一个检查报告或待确认清单。
3. 能打开的文件由 Codex 打开，不能把“你自己去找表格”当成默认流程。
4. 如果用户看到的表格有内容而 Codex 读取为空，优先判断为“表格未保存或不是同一文件”，不要直接说素材缺失。
```

如果用户说“改了几处”“还有一些细微修改”，但没有逐项列清：

```text
1. Codex 必须先确认所有被改动的区域，或者把 TARGET_JOBS 扩大到当前页面/当前 HUD 的合理范围。
2. Codex 不能只根据已导出的局部快照判断整个界面已经掌握。
3. 未导出的区域不能沿用旧生成脚本状态后再声称已同步最新 Studio 状态。
4. 如果某个区域没有导出，但用户明确指出了改动，Codex 可以按用户说明直接修正生成脚本，并说明该区域不是从快照反推的。
```

## 最少需要一份 After 快照

如果只有一份改动后的快照，Codex 可以确认当前状态，并按当前状态改模板。

HTTP 模式推荐输出为：

```text
<ProjectDir>/Project_Analysis_Package/GuiSnapshots/<GuiName>_<Scope>_After_Http.combined.json
<ProjectDir>/Project_Analysis_Package/GuiSnapshots/<GuiName>_<Scope>_After_Http.summary.md
```

## 精确知道改动，需要 Before + After

如果要精确回答“用户改了哪些属性”，需要两份快照：

```text
<ProjectDir>/Project_Analysis_Package/GuiSnapshots/<GuiName>_<Scope>_Before.md
<ProjectDir>/Project_Analysis_Package/GuiSnapshots/<GuiName>_<Scope>_After.md
```

然后运行：

```powershell
powershell -ExecutionPolicy Bypass -File "<WorkflowDir>\Tools\Compare-GuiSnapshots.ps1" -Before "<BeforeSnapshot>" -After "<AfterSnapshot>"
```

## 选择 TargetPath 的原则

HTTP 模式可以导出完整 GUI，但后续分析仍优先按功能分段读取。`TARGET_JOBS` 选择原则：

```text
1. 只改一个模板：导出这个模板节点。
2. 只改一个列表：导出这个列表所在面板。
3. 只改一个弹窗：导出这个弹窗。
4. 不知道路径：先运行 GuiOverviewExporter，再从候选路径里选。
```

路径格式示例：

```text
StarterGui/<ScreenGuiName>/<PageName>/<PanelName>
StarterGui/<ScreenGuiName>/<PopupName>
ReplicatedStorage/Resource/ui/<GuiTemplateName>
```

## 解析 After 快照

HTTP 模式不需要再运行 `Parse-GuiSnapshot.ps1`。接收器会直接生成：

```text
<AfterSnapshot>.combined.json
<AfterSnapshot>.summary.md
```

如果使用 Output 备用模式，再运行：

```powershell
powershell -ExecutionPolicy Bypass -File "<WorkflowDir>\Tools\Parse-GuiSnapshot.ps1" -InputPath "<AfterSnapshot>"
```

重点查看：

```text
## Visible / Page State
## ScrollingFrame
## Template Nodes
## Buttons And Tab Targets
## Slice Images
## TextScaled False Or Missing
```

## Codex 同步原则

```text
1. 先同步模板节点，再同步普通实例的生成逻辑。
2. 不要只改某一个 clone 出来的普通实例。
3. 用户新增的子节点层级，模板也要补齐。
4. 用户改了 UIListLayout、CanvasSize、AutomaticCanvasSize，生成脚本也要跟着改。
5. 用户改了字体、TextScaled、描边、对齐方式，生成脚本也要跟着改。
6. 同步后跑格式检查和项目可生成性检查。
```

## 快照不完整时

如果解析脚本提示找不到 `END_ROBLOX_GUI_SNAPSHOT_JSON`，或者源文件里有 `[trimmed]`：

```text
1. 不能按这份文件做精确同步。
2. 优先改用 HTTP 模式。
3. 如果不能用 HTTP，再重新导出更小的 TARGET_PATHS。
4. 如果仍然太大，就把一个面板拆成多个子节点分别导出。
```
