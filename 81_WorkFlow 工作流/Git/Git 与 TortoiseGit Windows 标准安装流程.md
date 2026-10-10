---
type: workflow
status: evergreen
source: self
tags:
  - type/workflow
  - status/evergreen
---

# Git 与 TortoiseGit Windows 标准安装流程

## 一句话说明

以后在新 Windows 设备上安装 Git 时，默认把 [[Git]]、[[TortoiseGit]] 和简体中文语言包作为一套开发环境一起安装。

## 为什么要绑定安装

用户习惯接近 SVN 的右键菜单式操作。单独安装 Git 只能提供命令行能力；安装 TortoiseGit 后，可以在 Windows 资源管理器里通过右键菜单完成 Clone、Pull、Commit、Push、Diff、Merge 等操作，更接近 TortoiseSVN。

## 标准安装目标

| 项目 | 标准 |
|---|---|
| Git | Git for Windows |
| Git 图形外壳 | TortoiseGit |
| 语言 | 简体中文 |
| 右键菜单 | 启用 |
| 下载暂存 | `D:\Work\TortoiseGit` |
| 安装验证 | 可执行文件、语言 DLL、注册表语言值、Git 路径 |

## 已验证安装记录

记录时间：2026-07-09

本机验证结果：

| 项目 | 路径或结果 |
|---|---|
| Git | `C:\Program Files\Git\cmd\git.exe` |
| Git 版本 | `git version 2.54.0.windows.1` |
| TortoiseGit 主程序 | `C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe` |
| TortoiseGit 版本 | `2.19.1.0` |
| 中文语言 DLL | `C:\Program Files\TortoiseGit\Languages\TortoiseProc2052.dll` |
| 用户语言设置 | `HKCU:\Software\TortoiseGit\LanguageID = 2052` |
| 语言包安装日志 | `D:\Work\TortoiseGit\TortoiseGit-LanguagePack-zh_CN-install-admin.log` |

注意：这次官方主程序包是 `2.19.1.0`，可用简体中文语言包文件是 `2.19.0.0`。安装后中文 DLL 版本为 `2.19.0.0`，可正常作为简体中文资源使用。

## 标准安装步骤

### 1. 检查 Git

```powershell
git --version
where.exe git
```

如果没有 Git，优先用 winget 安装：

```powershell
winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements
```

### 2. 安装 TortoiseGit

```powershell
winget install -e --id TortoiseGit.TortoiseGit --accept-package-agreements --accept-source-agreements
```

验证：

```powershell
winget list -e --id TortoiseGit.TortoiseGit --accept-source-agreements
Get-Item 'C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe'
```

### 3. 下载简体中文语言包

下载目录：

```text
D:\Work\TortoiseGit
```

官方下载地址：

```text
https://download.tortoisegit.org/tgit/2.19.0.0/TortoiseGit-LanguagePack-2.19.0.0-64bit-zh_CN.msi
```

下载命令：

```powershell
$dir = 'D:\Work\TortoiseGit'
New-Item -ItemType Directory -Path $dir -Force | Out-Null
$url = 'https://download.tortoisegit.org/tgit/2.19.0.0/TortoiseGit-LanguagePack-2.19.0.0-64bit-zh_CN.msi'
$msi = Join-Path $dir 'TortoiseGit-LanguagePack-2.19.0.0-64bit-zh_CN.msi'
Invoke-WebRequest -Uri $url -OutFile $msi -UseBasicParsing
```

### 4. 以管理员权限安装语言包

语言包要写入：

```text
C:\Program Files\TortoiseGit\Languages
```

普通权限可能失败，日志会出现：

```text
错误 1925。您没有足够的权限为这台计算机的所有用户完成此安装。
安装成功或错误状态: 1603
```

管理员安装命令：

```powershell
$msi = 'D:\Work\TortoiseGit\TortoiseGit-LanguagePack-2.19.0.0-64bit-zh_CN.msi'
$log = 'D:\Work\TortoiseGit\TortoiseGit-LanguagePack-zh_CN-install-admin.log'
$arguments = @('/i', $msi, '/qn', '/norestart', '/L*v', $log)
Start-Process -FilePath 'msiexec.exe' -ArgumentList $arguments -Verb RunAs -Wait
```

弹出 UAC 时，用户需要点“是”。

### 5. 设置 TortoiseGit 为简体中文

简体中文 LCID 是 `2052`。

```powershell
New-Item -Path 'HKCU:\Software\TortoiseGit' -Force | Out-Null
New-ItemProperty -Path 'HKCU:\Software\TortoiseGit' -Name 'LanguageID' -PropertyType DWord -Value 2052 -Force
```

如果用户注册表中的 TortoiseGit 工具名为空，恢复这些值：

```powershell
Set-ItemProperty -Path 'HKCU:\Software\TortoiseGit' -Name 'SSH' -Value 'C:\Program Files\TortoiseGit\bin\TortoiseGitPlink.exe' -Type String
Set-ItemProperty -Path 'HKCU:\Software\TortoiseGit' -Name 'TortoiseGit' -Value 'TortoiseGit' -Type String
Set-ItemProperty -Path 'HKCU:\Software\TortoiseGit' -Name 'TortoiseMerge' -Value 'TortoiseGitMerge' -Type String
Set-ItemProperty -Path 'HKCU:\Software\TortoiseGit' -Name 'TortoiseGitBlame' -Value 'TortoiseGitBlame' -Type String
Set-ItemProperty -Path 'HKCU:\Software\TortoiseGit' -Name 'TortoiseIDiff' -Value 'TortoiseGitIDiff' -Type String
```

### 6. 验证安装

```powershell
git --version
where.exe git
winget list -e --id TortoiseGit.TortoiseGit --accept-source-agreements
Get-Item 'C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe'
Get-Item 'C:\Program Files\TortoiseGit\Languages\TortoiseProc2052.dll'
Get-ItemProperty -Path 'HKCU:\Software\TortoiseGit' | Select-Object LanguageID,SSH,TortoiseGit,TortoiseMerge,TortoiseGitBlame,TortoiseIDiff
```

通过标准：

- `git --version` 能输出版本。
- `TortoiseGitProc.exe` 存在。
- `TortoiseProc2052.dll` 存在。
- `LanguageID` 是 `2052`。
- Windows 资源管理器右键菜单能看到 TortoiseGit / Git Commit / Git Sync。

## 使用提醒

安装完成后，右键菜单可能不会立刻刷新。优先让用户重启 Windows 资源管理器；如果仍未出现，重启电脑。

## 下次 Codex 执行规则

当用户说“安装 Git”“新设备配置 Git”“像 SVN 一样用 Git”“帮我装 Git 开发环境”时，默认检查并安装：

1. Git for Windows。
2. TortoiseGit。
3. TortoiseGit 简体中文语言包。
4. `HKCU:\Software\TortoiseGit\LanguageID = 2052`。

除非用户明确只要命令行 Git，否则不要只安装 Git。

## 相关链接

- [[TortoiseGit 使用教程]]
- [[70_LLM_Wiki 知识库/AI_Programming_Product/Git 与 TortoiseGit Windows 标准安装规则]]
