---
type: workflow
domain: vault
status: processing
owner: mixed
source: mixed
created: 2026-10-10
updated: 2026-10-10
---

# Obsidian Git 每 30 分钟同步说明

用户已选择公开 GitHub 仓库，并要求整个笔记库每 30 分钟同步。公开仓库已创建：[yangshulin2333/Codex_Obsidian](https://github.com/yangshulin2333/Codex_Obsidian)。**上传范围已确认，首次上传与启用定时同步正在处理**；完成后以本页验收结果为准。

## 已确认的公开范围

全部普通笔记、脚本及小附件参与同步，包括钱包、支付、Finance_Life 和个人理财 MOC。仅排除大资产（视频、压缩包、模型/场景文件）、运行二进制、依赖/构建缓存、凭据文件和本地配置；未删除原始文件。

原有 6 个提交已保留在 Vault 外的 `D:\AI\Codex_Obsidian_GitHistoryBackup_20261010_101250\.git`，同目录保存原状态、原 `.gitignore` 和原插件设置。新仓库使用干净 `main` 历史；嵌套项目的 Git 元数据保持原位，普通源码作为普通文件同步。备份保存了旧历史，不会出现在公开仓库中。

## 当前检查结果（2026-10-10）

- Vault：`D:\AI\Codex_Obsidian`。
- Obsidian Git 2.38.3 已启用；Git 2.53.0 可用，正常凭据助手能验证 GitHub 账号。
- 原分支 `main`，原仓库没有 remote 或 upstream。
- 原设置 `autoSaveInterval=0`、`disablePush=true`，因此没有定时上传。
- 原历史只有 6 个提交，却包含 10 个超过 100 MiB 的大文件；只加 `.gitignore` 无法消除历史中的大文件。
- 已存在未提交修改、删除项和未跟踪内容，不自动恢复用户已有删除项。

GitHub 普通 Git 阻止超过 100 MiB 的单文件。需要按 [[../../../70_LLM_Wiki 知识库/Vault/Git 远端同步前审计与资产边界|现有资产边界记录]] 先确认处理方式：[GitHub 官方大文件说明](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github)。

## 准备采用的插件设置

以下是待完成上传边界与首次推送后应用的设置，不是已经生效的运行状态：

```json
{
  "autoSaveInterval": 30,
  "differentIntervalCommitAndPush": false,
  "autoPushInterval": 0,
  "autoPullInterval": 0,
  "disablePush": false,
  "pullBeforePush": true,
  "autoCommitOnlyStaged": false,
  "autoBackupAfterFileChange": false,
  "setLastSaveToLastCommit": false,
  "autoPullOnBoot": true
}
```

在本机插件版本中，`autoSaveInterval` 的单位是分钟。提交和推送共用一个周期：每轮提交允许同步的改动、拉取，然后推送；独立推送/拉取周期为 0 表示不额外建立另一个计时器。保留现有通知、界面和状态栏偏好。

定时任务要求 Obsidian 正在运行且自动操作没有暂停；关闭应用时不会继续。网络故障、认证失效或合并冲突都可能阻断上传，应检查 Obsidian Git 状态。新电脑必须安装 Git 并登录自己的 GitHub 凭据；公开仓库的下载权限不代表推送权限。

## 完成后的验收条件

- [x] 上传范围、旧历史保留位置和忽略规则已确认。
- [x] 正常 Git 凭据身份与目标 GitHub 所有者一致。
- [ ] 本地 `main` 跟踪 `origin/main`，首次推送完成。
- [ ] GitHub 仓库公开，远端 HEAD 与本地 HEAD 一致。
- [ ] 插件设置实际加载，30 分钟周期生效且没有暂停。
- [ ] 同步说明更新为实际结果，并记录旧历史恢复位置。

插件官方入口：[Obsidian Git](https://github.com/Vinzent03/obsidian-git)。返回 [[README|Xeno 工作流入口]]。
