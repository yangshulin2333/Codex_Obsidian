---
type: workflow
domain: ai-programming-product
status: evergreen
owner: mixed
source: chatgpt
created: 2026-07-09
updated: 2026-07-09
---

# Git 与 TortoiseGit Windows 标准安装规则

## 一句话说明

新 Windows 设备安装 Git 时，默认同时安装 [[Git]]、[[TortoiseGit]] 和简体中文语言包，让 Git 具备接近 TortoiseSVN 的右键菜单体验。

## 为什么重要

用户明确偏好 SVN 式简单操作。单独安装 Git 会让日常流程偏命令行；TortoiseGit 可以把 Clone、Pull、Commit、Push、Diff、Merge 集成到 Windows 资源管理器右键菜单，降低 Git 使用摩擦。

## Codex 后续执行规则

当用户说以下任一意图时：

- “安装 Git”
- “新设备配置 Git”
- “Git 像 SVN 一样操作”
- “装一个 Git 图形工具”
- “Git 右键菜单”

默认检查并安装：

1. Git for Windows。
2. TortoiseGit。
3. TortoiseGit 简体中文语言包。
4. 当前用户 TortoiseGit 语言值：`HKCU:\Software\TortoiseGit\LanguageID = 2052`。

除非用户明确只要命令行 Git，否则不要只装 Git。

## 已验证安装事实

验证日期：2026-07-09

| 项目 | 结果 |
|---|---|
| Git 路径 | `C:\Program Files\Git\cmd\git.exe` |
| Git 版本 | `2.54.0.windows.1` |
| TortoiseGit winget ID | `TortoiseGit.TortoiseGit` |
| TortoiseGit 主程序版本 | `2.19.1.0` |
| TortoiseGit 主程序 | `C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe` |
| 简体中文语言 DLL | `C:\Program Files\TortoiseGit\Languages\TortoiseProc2052.dll` |
| 用户语言设置 | `LanguageID = 2052` |
| 下载与日志目录 | `D:\Work\TortoiseGit` |

## 标准验证命令

```powershell
git --version
where.exe git
winget list -e --id TortoiseGit.TortoiseGit --accept-source-agreements
Get-Item 'C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe'
Get-Item 'C:\Program Files\TortoiseGit\Languages\TortoiseProc2052.dll'
Get-ItemProperty -Path 'HKCU:\Software\TortoiseGit' | Select-Object LanguageID,SSH,TortoiseGit,TortoiseMerge,TortoiseGitBlame,TortoiseIDiff
```

## 风险与边界

- TortoiseGit 语言包需要写入 `C:\Program Files\TortoiseGit\Languages`，通常需要管理员权限。
- 普通权限静默安装语言包可能返回 `1603`，日志中会出现权限不足。
- 安装完成后，资源管理器右键菜单可能需要重启资源管理器或重启电脑后才显示。
- 工具版本和官方下载 URL 具有时间敏感性；下次安装前应先用 winget 或官方页面重新核验最新版。

## 来源

- 本机安装与验证记录，2026-07-09。
- `D:\Work\TortoiseGit\TortoiseGit-LanguagePack-zh_CN-install-admin.log`
- [[81_WorkFlow 工作流/Git/Git 与 TortoiseGit Windows 标准安装流程]]
- [[81_WorkFlow 工作流/Git/TortoiseGit 使用教程]]

## 相关链接

- [[70_LLM_Wiki 知识库/AI_Programming_Product/index|AI 编程与产品 Wiki]]
- [[30_MOC 内容地图/AI 编程与产品 MOC]]
