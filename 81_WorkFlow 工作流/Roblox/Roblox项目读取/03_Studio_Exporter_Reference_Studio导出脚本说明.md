# Studio Exporter Reference / Studio 导出脚本说明

These scripts are read-only exporters for the Roblox project currently open in Studio.

这些脚本只读取当前 Studio 打开的 Roblox 项目，用来导出结构、脚本、Remote、素材、动画和音效。

## Codex Entry / Codex 入口

Codex should read first:

```text
WORKFLOW_MANIFEST.json
00_Start_Here_For_Codex_给Codex先读.md
```

This file is only a script reference.

本文件只是脚本用途速查，不是主入口。

## User Actions In Studio / 用户在 Studio 中必须做的事

```text
1. Open the Roblox project in Roblox Studio.
   用 Roblox Studio 打开项目。

2. Open View -> Output.
   打开 View -> Output。

3. Open View -> Command Bar.
   打开 View -> Command Bar。

4. Copy the whole target Tools/*.luau file.
   复制目标 Tools/*.luau 的全部内容。

5. Paste it into Command Bar and press Enter.
   粘贴到 Command Bar 并按 Enter。

6. Copy all Output from this run.
   复制本次运行后的全部 Output。

7. Paste it into the md file that Codex prepared.
   粘贴到 Codex 已创建好的对应 md 文件。
```

## Exporter Map / 导出脚本表

| Script | Output File | Purpose |
|---|---|---|
| `RobloxStudio_QuickFocusedAuditExporter.luau` | `Audit_Quick_Focused_Output.md` | Structure, scripts, Remote/Bindable, basic assets / 结构、脚本、Remote、基础素材 |
| `RobloxStudio_ProjectOnlyAssetExporter.luau` | `Audit_Project_Assets_Output.md` | Project asset references / 项目服务内素材引用 |
| `RobloxStudio_AnimationSoundExporter.luau` | `Audit_Animation_Sound_Output.md` | Animation and Sound objects / 动画和音效对象 |
| `RobloxStudio_SourceAssetSearchExporter.luau` | `Audit_SourceAssetSearch_Output.md` | Asset IDs and asset keywords inside script source / 源码里的 AssetId 和资源关键词 |
| `RobloxStudio_TargetSourceExporter.luau` | `Audit_TargetSource_Output.md` | Full source for selected scripts / 指定脚本完整源码 |
| `RobloxStudio_TargetExplorerExporter.luau` | `Audit_TargetExplorer_Output.md` | Selected Explorer/resource trees / 指定资源树结构 |
| `RobloxStudio_TargetExplorerCompactExporter.luau` | `Audit_TargetExplorer_Compact_Output.md` | Compact fallback when Output is trimmed / Output 截断时的紧凑补充 |
| `RobloxStudio_AuditExporter.luau` | `Audit_Raw_Output.md` | Broad fallback export / 更宽的兜底导出 |

## TargetSourceExporter Note / 关键源码导出说明

`RobloxStudio_TargetSourceExporter.luau` starts with an empty `TARGET_PATHS`.

`RobloxStudio_TargetSourceExporter.luau` 默认不带任何旧项目路径。

First run:

```text
It prints available script paths.
第一次运行会输出可选脚本路径。
```

Second run:

```text
After Codex fills TARGET_PATHS, it exports full source for those scripts.
Codex 填好 TARGET_PATHS 后，第二次运行才会导出完整源码。
```

## Explorer Exporter Note / 资源树导出说明

`RobloxStudio_TargetExplorerExporter.luau` 适合导出关键资源树，例如 `Stage/stage1`、`skill`、`ui`、`Potion`。

如果 Output 很长，Studio 会截断。判断方法：

```text
完整：文件末尾有 ## End。
截断：文件末尾没有 ## End，或出现 [trimmed]。
```

截断时不要继续扩大目标范围，改用：

```text
RobloxStudio_TargetExplorerCompactExporter.luau
```

它只导出直接子节点、类型统计和关键后代，目的是让资源导入尽快收口。
