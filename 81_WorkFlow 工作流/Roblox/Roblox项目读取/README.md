# Roblox Project Intake Workflow / Roblox 项目读取工作流

版本：v1.1  
语言：中文优先，必要英文保留为 Roblox / Rojo / API 术语。

Purpose / 用途：

```text
Prepare a newly received Roblox project so Codex can read it through exported text.
把新接收的 Roblox 项目导出成 Codex 可读取、可分析、可接手的文本资料。
```

Read order / 阅读顺序：

```text
1. WORKFLOW_MANIFEST.json
2. 00_Start_Here_For_Codex_给Codex先读.md
3. 01_New_Chat_Prompt_新对话启动提示词.md
4. 02_Full_Export_Guide_完整导出清单.md
5. 03_Studio_Exporter_Reference_Studio导出脚本说明.md
6. 04_Status_And_Stop_Rules_状态与收口规则.md
7. 05_Final_Report_Template_总接管报告模板.md
```

Key rule / 关键规则：

```text
The workflow folder name is arbitrary.
工作流文件夹可以叫任意名字，不要依赖文件夹名识别。

Identify this workflow by:
只通过以下文件识别工作流：

WORKFLOW_MANIFEST.json
00_Start_Here_For_Codex_给Codex先读.md
Tools/Bootstrap_RobloxProjectAuditWorkspace.ps1
```

Do not start feature work first. Finish project export and analysis first.

不要一上来做功能开发。先完成项目导出和项目理解。

Stop rule / 收口规则：

```text
不是无限导入。
当脚本、Remote、AssetId、目标源码、关键资源树都已经完成，并且最后一轮资源树导出有 ## End 时，
Codex 应停止继续导入，进入总接管报告和第一阶段目标决策。
```
