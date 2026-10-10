# Full Export Guide / 完整导出清单

Codex should read first:

```text
WORKFLOW_MANIFEST.json
00_Start_Here_For_Codex_给Codex先读.md
04_Status_And_Stop_Rules_状态与收口规则.md
```

This file is the human-readable checklist.

本文件是人类可读的导出清单，不是 Codex 主入口。

## Goal / 目标

```text
Export a received Roblox project into text files Codex can read.
把新接收的 Roblox 项目导出成 Codex 可读取的文本资料。
```

## Step 0: Bootstrap / 第 0 步：初始化

Codex should run the bootstrap script first.

Codex 应先运行初始化脚本。

If the workflow package is already inside the project root:

如果工作流包已在项目根目录内：

```powershell
powershell -ExecutionPolicy Bypass -File ".\<workflow folder>\Tools\Bootstrap_RobloxProjectAuditWorkspace.ps1" -TargetRoot "." -SourceToolsDir ".\<workflow folder>\Tools" -CopyExporters
```

If workflow files are merged into the project root:

如果工作流文件已合并到项目根目录：

```powershell
powershell -ExecutionPolicy Bypass -File ".\Tools\Bootstrap_RobloxProjectAuditWorkspace.ps1" -TargetRoot "." -SourceToolsDir ".\Tools" -CopyExporters
```

The script creates:

脚本会创建：

```text
Project_Analysis_Package/
Tools/
```

and all empty output files.

以及所有空的输出文件。

## Studio Operation / Studio 操作方式

Every exporter is run in the same way:

每个导出脚本都这样运行：

```text
1. Open the project in Roblox Studio.
   在 Roblox Studio 打开项目。

2. Open View -> Output.
   打开 View -> Output。

3. Open View -> Command Bar.
   打开 View -> Command Bar。

4. Copy the whole Tools/*.luau file.
   复制对应 Tools/*.luau 全部内容。

5. Paste into Command Bar and press Enter.
   粘贴到 Command Bar 并按 Enter。

6. Copy all Output from this run.
   复制本次运行后的全部 Output。

7. Paste into the prepared md file.
   粘贴到已准备好的对应 md 文件。
```

## Required Exports / 必导内容

### 1. Structure, Scripts, Remotes / 结构、脚本、Remote

```text
Tools/RobloxStudio_QuickFocusedAuditExporter.luau
-> Project_Analysis_Package/Audit_Quick_Focused_Output.md
```

Exports:

```text
GameId / PlaceId / Creator
Script / LocalScript / ModuleScript list
RemoteEvent / RemoteFunction / Bindable list
Basic asset references
```

### 2. Project Asset References / 项目素材引用

```text
Tools/RobloxStudio_ProjectOnlyAssetExporter.luau
-> Project_Analysis_Package/Audit_Project_Assets_Output.md
```

Scans:

```text
Workspace
ReplicatedStorage
ServerScriptService
ServerStorage
StarterGui
StarterPlayer
StarterPack
ReplicatedFirst
Lighting
SoundService
```

Exports:

```text
Image
Texture
Mesh
Sound
Animation
Particle / Trail / Beam texture references
```

### 3. Animation And Sound / 动画和音效

```text
Tools/RobloxStudio_AnimationSoundExporter.luau
-> Project_Analysis_Package/Audit_Animation_Sound_Output.md
```

Exports:

```text
Animation objects
Sound objects
AnimationId
SoundId
```

### 4. Asset IDs In Source / 源码里的资源 ID

```text
Tools/RobloxStudio_SourceAssetSearchExporter.luau
-> Project_Analysis_Package/Audit_SourceAssetSearch_Output.md
```

Exports asset references found in script source:

导出脚本源码里的资源引用：

```text
rbxassetid://...
asset?id=...
AnimationId
SoundId
MeshId
TextureId
Image
MarketplaceService / InsertService references
```

### 5. Target Source / 关键源码

First run:

第一次运行：

```text
Tools/RobloxStudio_TargetSourceExporter.luau
-> Project_Analysis_Package/Audit_TargetSource_Output.md
```

Purpose:

```text
List all available script paths.
列出可选脚本路径。
```

Then Codex fills `TARGET_PATHS` in:

然后由 Codex 修改：

```text
Tools/RobloxStudio_TargetSourceExporter.luau
```

Second run:

第二次运行：

```text
Tools/RobloxStudio_TargetSourceExporter.luau
-> Project_Analysis_Package/Audit_TargetSource_Output.md
```

Purpose:

```text
Export selected Script / LocalScript / ModuleScript full source.
导出选定 Script / LocalScript / ModuleScript 的完整源码。
```

建议按功能分多轮保存，避免单个 Output 过长：

```text
Audit_TargetSource_Output.md
Audit_TargetSource_Pass2_Output.md
Audit_TargetSource_Pass3_Output.md
```

每轮由 Codex 修改 `TARGET_PATHS`，用户只负责在 Studio 运行并保存 Output。

### 6. Target Explorer / 关键资源树

当源码已经指向某些资源树，例如：

```text
ReplicatedStorage/Resource/Stage/stage1
ReplicatedStorage/Resource/skill
ReplicatedStorage/Resource/pfb
ReplicatedStorage/Resource/ui
ReplicatedStorage/Resource/Potion
```

运行：

```text
Tools/RobloxStudio_TargetExplorerExporter.luau
-> Project_Analysis_Package/Audit_TargetExplorer_Output.md
```

作用：

```text
导出选定资源树的直接子节点、类型统计、关键属性和有限深度树结构。
```

如果输出缺少 `## End` 或出现 `[trimmed]`，不要继续扩大范围，改用紧凑导出：

```text
Tools/RobloxStudio_TargetExplorerCompactExporter.luau
-> Project_Analysis_Package/Audit_TargetExplorer_Compact_Output.md
```

紧凑导出只打印直接子节点、类型统计和关键后代，适合补 `pfb/ui/Potion` 等细节。

## Optional Broad Export / 可选综合导出

```text
Tools/RobloxStudio_AuditExporter.luau
-> Project_Analysis_Package/Audit_Raw_Output.md
```

Use only when useful. If Output is too long, skip it and use the focused exporters above.

按需使用。如果 Output 太长，就跳过它，使用上面的分步导出。

## Final Codex Analysis / 最终让 Codex 输出

After `Audit_*.md` files are filled, ask Codex to write:

当 `Audit_*.md` 有内容后，让 Codex 写入：

```text
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

## Stop Rule / 收口规则

当 `Next_Steps.md` 已经写明“当前不需要继续导入”，并且最后一轮关键导出有 `## End`，Codex 应停止继续要求用户运行导出脚本。下一步是总接管报告和第一阶段目标选择。

## Minimal Version / 最小版

If short on time:

时间不够时只跑：

```text
1. RobloxStudio_QuickFocusedAuditExporter.luau
2. RobloxStudio_TargetSourceExporter.luau
```

One exports the map. The other exports key source after Codex selects paths.

一个导项目地图，一个在 Codex 选路径后导关键源码。
