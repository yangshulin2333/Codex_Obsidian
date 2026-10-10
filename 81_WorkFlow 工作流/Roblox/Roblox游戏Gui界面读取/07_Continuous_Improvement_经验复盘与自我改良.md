# 经验复盘与自我改良

这个文件约束 Codex 如何吸取教训，持续优化本工作流。

## 基本原则

```text
1. 用户指出流程别扭、重复劳动、误判、遗漏细节时，不能只在聊天里解释，要判断是否应该更新工作流。
2. 如果一个问题可能在下次 Roblox GUI 读取里再次出现，就应该沉淀为规则、工具或检查项。
3. 优先把改良做成低耦合能力，不写死当前项目名、GUI 名、页面名。
4. 能由 Codex 操作的事，不推给用户操作。
5. 每次改良后要跑最小验证，确认工具和文档没有互相打架。
```

## 必须吸取的已知教训

```text
1. Studio Output 容易截断，所以正式快照默认走 HTTP，不论 GUI 大小。
2. 用户不应该手动改导出脚本；Codex 负责填 TARGET_JOBS / TARGET_PATHS。
3. 用户不应该自己找表格；Codex 负责读取、检查、必要时打开素材表。
4. 不能因为脚本没读到 AssetId 就说素材没有。必须说明读取的是哪个表，支持 rbxassetid://数字。
5. 用户在 Studio 手动改过 UI 后，必须重新读快照，不能拿旧生成脚本状态冒充当前状态。
6. 快照当前状态和生成脚本默认预览状态要分开说清楚。
7. 如果只拿到 after 快照，只能确认当前状态，不能严格声称知道用户刚改了哪些。
8. 工作流文档不能保留过时说法，例如“只有大型界面才需要 HTTP”。
9. 工具目录不保留运行缓存，例如 __pycache__。
10. 最终交付前要搜索旧脚本名、旧流程名、项目硬编码，避免残留。
```

## 触发改良的情况

只要出现以下情况，Codex 就应该考虑更新本工作流：

```text
1. 用户指出“这一步应该你来做”。
2. 用户指出“你没有拿到完整数据”。
3. 用户指出“你又把我删掉的东西加回来了”。
4. 用户指出“素材其实有，是你没识别到”。
5. Studio Output 被截断。
6. 工具命令太长，用户执行成本高。
7. 文档里有旧流程、旧脚本名、旧默认行为。
8. 一个工具只能支持旧格式，不能支持当前默认格式。
9. 新对话接手时需要从聊天里猜上下文。
```

## 改良动作

遇到上面的情况，Codex 按这个顺序处理：

```text
1. 先判断是文档问题、工具问题、流程问题，还是项目专用问题。
2. 文档问题：更新 README、00~07 中对应文件。
3. 工具问题：优先补通用工具，不写死项目参数。
4. 流程问题：把默认路径改成用户最省事、Codex 最稳定的方案。
5. 项目专用问题：只写入项目交接文档或项目脚本，不写进通用规则。
6. 更新 WORKFLOW_MANIFEST.json。
7. 删除临时缓存和明显废弃文件。
8. 跑最小验证。
```

## 最小验证清单

每次整理工作流后，至少检查：

```powershell
stylua --check "<WorkflowDir>\Tools\RobloxStudio_GuiHttpSnapshotExporter.luau"
python -m py_compile "<WorkflowDir>\Tools\Receive-GuiSnapshotHttp.py"
$script = Get-Content -Raw -Encoding UTF8 "<WorkflowDir>\Tools\Start-GuiSnapshotReceiver.ps1"; [scriptblock]::Create($script) | Out-Null
```

还要搜索旧说法和缓存：

```powershell
rg -n "Parse-MainGui|MainGuiChunked|__pycache__|写死" "<WorkflowDir>"
```

如果是 PowerShell 工具，至少做语法检查：

```powershell
$script = Get-Content -Raw -Encoding UTF8 "<ToolPath>"; [scriptblock]::Create($script) | Out-Null
```

## 版本记录规则

```text
1. 只要新增工具或改变默认流程，就提升 WORKFLOW_MANIFEST.json 的 workflow_version。
2. 小文案修正可以不升版本。
3. 版本说明写在 manifest 的 description 或本文件的最近改良记录里。
```

## 最近改良记录

```text
v1.4：
- 正式快照不论大小默认走 HTTP。
- 新增 Start-GuiSnapshotReceiver.ps1，封装接收器启动命令。
- Compare-GuiSnapshots.ps1 支持 HTTP 单段 JSON 和 combined JSON。
- 新增 Tools/README.md。
- 删除 Tools/__pycache__。
- 新增本复盘文件，后续把用户纠错和流程摩擦沉淀为规则。
```
