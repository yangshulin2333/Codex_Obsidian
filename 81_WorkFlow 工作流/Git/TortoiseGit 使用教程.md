---
type: workflow
status: evergreen
source: self
tags:
  - type/workflow
  - status/evergreen
---

# TortoiseGit 使用教程

适用场景：想像 TortoiseSVN 一样，用 Windows 资源管理器右键菜单管理 Git 项目。

## 1. Git 和 SVN 操作对应关系

| 你想做的事 | SVN 习惯 | Git / TortoiseGit 对应操作 |
|---|---|---|
| 从远端拿项目 | Checkout | Git Clone |
| 查看文件改动 | SVN 状态 | Check for Modifications |
| 更新别人提交的内容 | Update | Pull |
| 本地保存一次版本 | Commit | Commit |
| 把本地提交发到远端 | Commit 后自动到服务器 | Push |
| 更新并推送 | 不太需要分开 | Git Sync |

关键差别：

- Git 的 Commit 默认只提交到本机。
- 还要执行 Push，远端仓库才会收到。
- 所以日常要记住：Commit 是本地保存，Push 是上传远端。

## 2. 第一次打开项目

进入 Git 项目文件夹，在空白处右键，应该能看到：

```text
TortoiseGit
Git Commit -> "main"...
Git Sync...
```

如果没有看到：

1. 重启资源管理器或重启电脑。
2. 确认目录里有 `.git` 文件夹。
3. 打开开始菜单搜索 `TortoiseGit Settings` 检查安装状态。

## 3. 日常推荐流程

每次开始工作前：

```text
右键项目空白处 -> TortoiseGit -> Pull
```

每次完成一个小目标后：

```text
右键项目空白处 -> Git Commit -> "main"...
```

提交窗口里：

1. 勾选本次要提交的文件。
2. 写提交说明。
3. 点击 `Commit`。
4. 提交完成后点击 `Push`。

提交说明建议写中文短句：

```text
优化启动日志
补充 TortoiseGit 使用教程
修复 StorageService 日志等级
```

## 4. 更接近 SVN 的一站式入口

```text
右键项目空白处 -> TortoiseGit -> Git Sync...
```

推荐顺序：

1. 点击 `Pull`，先更新远端内容。
2. 如果没有冲突，再点击 `Push`，推送自己的提交。

注意：

- Git Sync 不等于自动提交。
- 仍然要先 Commit，再 Push。
- 如果本地有未提交改动，Pull 可能失败。

## 5. 查看当前有哪些改动

```text
右键项目空白处 -> TortoiseGit -> Check for Modifications
```

常见状态：

| 状态 | 含义 | 建议 |
|---|---|---|
| Modified | 文件已修改 | 确认后提交 |
| Added | 新文件 | 需要提交就勾选 |
| Deleted | 文件被删除 | 确认不是误删 |
| Unversioned | Git 还没跟踪 | 需要就 Add，不需要就忽略 |
| Conflicted | 有冲突 | 先解决冲突，不要直接提交 |

## 6. 提交时怎么选文件

建议：

- 只勾选和本次目标相关的文件。
- 不确定的文件先不要提交。
- 临时文件、构建产物、下载文件不要提交。

通常可以提交：

```text
src/
docs/
scripts/
README.md
default.project.json
```

通常不要提交：

```text
*.rbxl
*.rbxlx
*.tmp
.codex/
.agents/
```

## 7. Pull 更新代码

执行：

```text
右键项目空白处 -> TortoiseGit -> Pull
```

适合场景：

- 开始一天工作前。
- 准备提交前。
- 远端有别人或另一台电脑推送的新内容。

如果 Pull 失败，常见原因是：

- 本地有未提交改动。
- 远端和本地改了同一段代码。
- 网络或账号权限有问题。

不要盲目强制覆盖。先保留错误信息，再判断。

## 8. Push 推送代码

执行：

```text
右键项目空白处 -> TortoiseGit -> Push
```

适合场景：

- 已经 Commit。
- 想把本地提交同步到 GitHub / Gitee / 远端仓库。

如果 Push 被拒绝，通常是远端比本地更新。

处理顺序：

1. 先 Pull。
2. 如果有冲突，解决冲突。
3. 再 Push。

## 9. 冲突处理

冲突通常发生在：

- 你和远端都改了同一个文件的同一段。
- Pull 时 Git 无法自动合并。

处理建议：

1. 右键冲突文件。
2. 选择 `Edit conflicts`。
3. 用 TortoiseGitMerge 选择保留哪一边，或手动合并。
4. 保存后标记为已解决。
5. 再 Commit。

如果不确定哪边正确，不要随便选 `Use mine` 或 `Use theirs`。

## 10. 撤销本地改动

只适合明确知道要丢弃本地修改时使用。

```text
右键文件 -> TortoiseGit -> Revert
```

风险：

- Revert 会丢弃未提交改动。
- 丢弃后不一定能恢复。
- 不确定时先复制文件或询问 Codex。

## 11. 初期分支策略

当前阶段可以先保持简单，只用：

```text
main
```

等项目变复杂后，再考虑：

| 分支 | 用途 |
|---|---|
| main | 稳定版本 |
| feature/xxx | 新功能 |
| fix/xxx | 修 bug |

初期不要频繁切分支，先把 Pull / Commit / Push 练熟。

## 12. 最简口诀

日常只记 4 个动作：

```text
Pull     先更新
Check    看改动
Commit   本地保存
Push     上传远端
```

如果想更接近 SVN：

```text
Git Sync = 集中做 Pull / Push
```

但仍然要记住：

```text
Commit 只是保存到本机，Push 才是上传远端。
```
