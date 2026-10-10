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

公开仓库：[yangshulin2333/Codex_Obsidian](https://github.com/yangshulin2333/Codex_Obsidian)。**首次上传已成功，30 分钟同步配置已保存，但自动运行尚未验证通过。** 本页保留未完成状态，不能当作定时上传已正常工作的证明。

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

## 已保存的插件设置

以下字段已保存到本机插件 `data.json`；保留原有通知和界面偏好。配置值与实际定时器运行状态需要分别验证：

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
- [x] 本地 `main` 跟踪 `origin/main`，首次推送完成。
- [x] GitHub 仓库公开，远端 HEAD 与本地 HEAD 已核对。
- [ ] 插件设置实际加载，30 分钟周期生效且没有暂停。
- [x] 同步说明记录实际结果与旧历史恢复位置。

插件官方入口：[Obsidian Git](https://github.com/Vinzent03/obsidian-git)。返回 [[README|Xeno 工作流入口]]。

## 自动同步实际验证（2026-10-10）

首次推送的提交为 `f979e52b884bee197b9c0b587835d1fe083bd762`。在 10:30:27–10:32:08 期间，通过文件配置暂用 1 分钟周期，并修改本页作为待同步内容；100 秒内未检测到插件自动生成提交。结束后已恢复 30 分钟配置和原自动提交消息偏好，测试改动由正常 Git 命令提交和推送。

用户按 Esc 停止 Computer Use 后，本轮没有再进行界面操作。插件源码和 Obsidian 配置事件链支持修改文件后自动重载，但这只是静态依据。暂停状态存储在 Obsidian LocalStorage，当前未实测；也未证明定时器已创建，不能从 JSON 数值为 30 推断自动同步已运行。

后续需要在 Obsidian 中核对 Git 插件是否已初始化、自动操作是否暂停、实际 Git 可执行路径及错误信息，再完成一次自动提交/推送测试。原错误通知偏好仍保持关闭。新电脑需要独立配置 Git 登录和本地定时设置；插件本地配置文件不参与公开同步。

本机证据：`C:\Users\long001\Documents\ChatGPT\Codex_X\obsidian-auto-sync-verification-20261010.json`。已有首次上传与手动同步能力不受这项待验证结论影响。
