# Start Here For Codex / 给 Codex 先读

## Language / 语言

用户英语水平是大学英语四级。默认使用中文，英文只用于 Roblox、Rojo、API、文件名、类名等必须保留的技术术语。

## Role / 你的角色

You are Codex. The user has received a Roblox project and provided this workflow package to help you read it.

你是 Codex。用户刚接手一个 Roblox 项目，并把这个工作流包提供给你，用来让你快速读懂项目。

Goal / 目标：

```text
Export the Roblox project into text files that Codex can read and analyze.
把 Roblox 项目导出成 Codex 可读取、可分析、可接手的文本资料。
```

Do not start feature work, refactoring, or gameplay changes before the export is complete.

导出完成前，不要开始功能开发、重构或玩法修改。

## Workflow Identity / 工作流识别

The workflow folder name is arbitrary.

工作流文件夹名可以是任意名称。

Do not identify this workflow by folder name. Identify it by these files:

不要通过文件夹名识别工作流。只能通过以下文件识别：

```text
WORKFLOW_MANIFEST.json
00_Start_Here_For_Codex_给Codex先读.md
Tools/Bootstrap_RobloxProjectAuditWorkspace.ps1
```

## What Codex Must Do First / Codex 必须先做什么

Codex must prepare local files before asking the user to operate Roblox Studio.

在要求用户操作 Roblox Studio 前，Codex 必须先准备本地文件。

Steps:

```text
1. Locate this workflow package.
   找到当前工作流包。

2. Confirm the Roblox project root.
   确认 Roblox 项目根目录。

3. Run Bootstrap_RobloxProjectAuditWorkspace.ps1.
   运行 Bootstrap_RobloxProjectAuditWorkspace.ps1。

4. Create Project_Analysis_Package/.
   创建 Project_Analysis_Package/。

5. Create all empty Audit_*.md and analysis md files.
   创建所有空的 Audit_*.md 和分析输出 md。

6. Copy generic RobloxStudio_*.luau exporters into the project Tools/.
   把通用 RobloxStudio_*.luau 导出脚本复制到项目 Tools/。

7. Create `Project_Analysis_Package/STATUS.md`.
   创建进度状态文件，后续每一轮都更新“当前阶段、完成标准、下一步”。

8. Tell the user the first Studio action.
   告诉用户第一步 Studio 操作。
```

## How To Locate Project Root / 如何判断项目根目录

### Case A: Workflow Package Is A Child Folder / 工作流包是项目子目录

Example:

```text
ProjectRoot/
├─ <any workflow folder name>/
│  ├─ WORKFLOW_MANIFEST.json
│  ├─ 00_Start_Here_For_Codex_给Codex先读.md
│  └─ Tools/
```

Run from `ProjectRoot`:

```powershell
powershell -ExecutionPolicy Bypass -File ".\<any workflow folder name>\Tools\Bootstrap_RobloxProjectAuditWorkspace.ps1" -TargetRoot "." -SourceToolsDir ".\<any workflow folder name>\Tools" -CopyExporters
```

### Case B: Workflow Files Are Merged Into Project Root / 工作流内容已合并到项目根目录

Example:

```text
ProjectRoot/
├─ Tools/
│  └─ Bootstrap_RobloxProjectAuditWorkspace.ps1
├─ WORKFLOW_MANIFEST.json
└─ README.md
```

Run from `ProjectRoot`:

```powershell
powershell -ExecutionPolicy Bypass -File ".\Tools\Bootstrap_RobloxProjectAuditWorkspace.ps1" -TargetRoot "." -SourceToolsDir ".\Tools" -CopyExporters
```

### Case C: Current Directory Is The Workflow Package / 当前目录本身是工作流包

If the current directory contains:

```text
WORKFLOW_MANIFEST.json
00_Start_Here_For_Codex_给Codex先读.md
Tools/Bootstrap_RobloxProjectAuditWorkspace.ps1
```

then the current directory is the workflow package, not necessarily the Roblox project root.

如果当前目录包含以上文件，那么当前目录是工作流包，不一定是 Roblox 项目根目录。

Prefer the parent directory as project root only if it looks like a Roblox project:

只有父目录像 Roblox 项目时，才优先把父目录当项目根目录：

```text
.rbxl / .rbxlx
default.project.json
src/
ReplicatedStorage/
ServerScriptService/
StarterPlayer/
```

If unsure, ask the user for the project root.

如果无法判断，向用户确认项目根目录。

## Expected Files After Bootstrap / 初始化后应出现的文件

Project root should contain:

项目根目录应出现：

```text
Project_Analysis_Package/
Tools/
```

`Project_Analysis_Package/` should contain:

```text
Startup_Record.md
Audit_Quick_Focused_Output.md
Audit_Project_Assets_Output.md
Audit_Animation_Sound_Output.md
Audit_SourceAssetSearch_Output.md
Audit_TargetSource_Output.md
Audit_TargetSource_Pass2_Output.md
Audit_TargetSource_Pass3_Output.md
Audit_TargetExplorer_Output.md
Audit_TargetExplorer_Compact_Output.md
Audit_Raw_Output.md
STATUS.md
Explorer_Tree.md
Script_Index.md
RemoteEvent_Map.md
Asset_Audit.md
Animation_Sound_Index.md
Source_Asset_Search_Index.md
Target_Source_Index.md
Gameplay_Flow.md
Replacement_Plan.md
Project_Understanding_Report.md
Next_Steps.md
Project_Takeover_Final_Report.md
```

`Tools/` should contain:

```text
RobloxStudio_QuickFocusedAuditExporter.luau
RobloxStudio_ProjectOnlyAssetExporter.luau
RobloxStudio_AnimationSoundExporter.luau
RobloxStudio_SourceAssetSearchExporter.luau
RobloxStudio_TargetSourceExporter.luau
RobloxStudio_TargetExplorerExporter.luau
RobloxStudio_TargetExplorerCompactExporter.luau
RobloxStudio_AuditExporter.luau
```

## First Message To User / 初始化后告诉用户

After bootstrap, tell the user:

```text
现在请你在 Roblox Studio 做第一步：

1. 打开当前 Roblox 项目。
2. 打开 View -> Output。
3. 打开 View -> Command Bar。
4. 打开项目根目录下的 Tools/RobloxStudio_QuickFocusedAuditExporter.luau。
5. 复制这个 luau 文件全部内容。
6. 粘贴到 Studio Command Bar。
7. 按 Enter。
8. 把这次 Output 全部复制。
9. 粘贴到 Project_Analysis_Package/Audit_Quick_Focused_Output.md。

完成后告诉我。
```

Do not ask the user to create folders or empty md files.

不要让用户创建目录或空 md 文件。

## Export Order / 导出顺序

```text
1. RobloxStudio_QuickFocusedAuditExporter.luau
   -> Audit_Quick_Focused_Output.md

2. RobloxStudio_ProjectOnlyAssetExporter.luau
   -> Audit_Project_Assets_Output.md

3. RobloxStudio_AnimationSoundExporter.luau
   -> Audit_Animation_Sound_Output.md

4. RobloxStudio_SourceAssetSearchExporter.luau
   -> Audit_SourceAssetSearch_Output.md

5. RobloxStudio_TargetSourceExporter.luau, selected runs
   -> Audit_TargetSource_Output.md
   -> Audit_TargetSource_Pass2_Output.md
   -> Audit_TargetSource_Pass3_Output.md
   Purpose: export selected full source.
   作用：导出关键功能源码。Codex 按项目需要分多轮配置 TARGET_PATHS。

6. RobloxStudio_TargetExplorerExporter.luau
   -> Audit_TargetExplorer_Output.md
   Purpose: export selected Explorer/resource trees.
   作用：导出关键资源树，例如 Stage、skill、ui、Potion。

7. If output is trimmed, run RobloxStudio_TargetExplorerCompactExporter.luau
   -> Audit_TargetExplorer_Compact_Output.md
   Purpose: compact fallback for pfb/ui/Potion or missing tree details.
   作用：当 Studio Output 截断时，用紧凑导出补齐资源细节。
```

## Stop Condition / 什么时候停止导入

当以下条件满足时，停止继续让用户跑 Studio 导出：

```text
1. QuickFocused 已完成：脚本数、Remote/Bindable 已掌握。
2. SourceAssetSearch 已完成：源码 AssetId 已掌握。
3. TargetSource 至少覆盖核心玩法链路和主要风险模块。
4. TargetExplorer 或 CompactExplorer 已覆盖关键资源树。
5. 最后一轮关键导出存在 ## End，没有 [trimmed]。
6. Next_Steps.md 写明“当前不需要继续导入”。
```

停止后进入：

```text
Project_Takeover_Final_Report.md
第一阶段目标选择
修原项目 / 最小复刻 / 学习接管
```

## Final Analysis Outputs / 最终分析输出

After enough `Audit_*.md` files are filled, Codex should write:

等 `Audit_*.md` 基本齐全后，Codex 应写入：

```text
Explorer_Tree.md
Script_Index.md
RemoteEvent_Map.md
Asset_Audit.md
Animation_Sound_Index.md
Source_Asset_Search_Index.md
Target_Source_Index.md
Project_Understanding_Report.md
Next_Steps.md
```

## Rules / 禁止事项

```text
1. Do not depend on folder name.
   不依赖文件夹名。

2. Do not treat .rbxl as directly readable source.
   不假装能直接读取 .rbxl 二进制源码。

3. Do not ask the user to create empty files.
   不让用户手动创建空文件。

4. Do not modify game code before export analysis.
   导出分析前不改游戏代码。

5. Ask the user to copy the whole Output from each run.
   让用户复制每次运行后的全部 Output。
```
