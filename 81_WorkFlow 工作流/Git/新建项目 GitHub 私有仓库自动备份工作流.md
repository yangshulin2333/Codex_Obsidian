---
type: workflow
domain: github-resources
status: evergreen
owner: mixed
source: self
created: 2026-07-29
updated: 2026-07-29
tags:
  - type/workflow
  - git
  - github
  - backup
---

# 新建项目 GitHub 私有仓库自动备份工作流

## 一句话说明

当用户说“给这个项目新建 Git 备份”“新建项目备份”或“自动创建对应项目的仓库并备份”时，Codex 默认根据项目文件夹名创建同名 GitHub **私有仓库**，保存当前完整项目快照，推送后再验证本地和远端提交一致。

## 默认约定

| 项目 | 默认规则 |
| --- | --- |
| 仓库名称 | 使用项目根目录名称；只有重名或名称非法时才调整 |
| 可见性 | `Private`，除非用户明确要求公开 |
| 默认分支 | `main` |
| 远端名称 | `origin` |
| 初次快照提交 | `chore: checkpoint current project baseline` |
| 备份范围 | 当前项目中应长期保存的代码、配置、文档和资产源文件 |
| GitHub 账号 | 使用 `gh auth status` 当前确认的账号，不猜测账号 |
| 框架边界 | 只处理用户指定项目，不顺带修改相邻框架或其他仓库 |

## 自动执行入口

用户只需要提供或明确当前项目路径，例如：

```text
给 D:\Work\MyGame 新建 GitHub 私有备份。
```

Codex 应自动完成路径确认、预检、建仓、提交、推送和验证。以下情况才暂停：

- 项目根目录不明确；
- 已存在 `origin`，但指向另一个仓库；
- 扫描到疑似密钥、令牌、账号或隐私文件；
- 存在 GitHub 单文件限制附近的大文件；
- GitHub 未登录或当前账号无法确认；
- 当前变更明显包含项目目录之外的内容。

## 阶段一：只读预检

### 1. 确认项目归属

```powershell
$projectRoot = 'D:\Work\MyGame'
Get-Item -LiteralPath $projectRoot
Get-ChildItem -LiteralPath $projectRoot -Force
```

读取项目内的 `AGENTS.md`、`README.md`、交接文档和 `.gitignore`。如果存在 `.codegraph/`，理解代码时先使用 CodeGraph。

### 2. 检查 Git 状态

```powershell
git -C $projectRoot status --short
git -C $projectRoot branch --show-current
git -C $projectRoot log -3 --oneline
git -C $projectRoot remote -v
```

判断分支：

- 没有 `.git/`：初始化新仓库；
- 已有本地历史但没有远端：保留历史，创建远端；
- 已有正确远端：不重复建仓，改为创建新快照并推送；
- 已有错误或不明确远端：停止并报告，不擅自覆盖。

### 3. 敏感信息扫描

至少检查：

- 文件名：`.env`、私钥、证书、凭据、账号导出、Cookie、数据库备份；
- 文本内容：API Key、Token、Password、Private Key；
- VS Code、Codex、Studio 配置中是否写入个人令牌；
- 临时日志、崩溃转储和本地缓存。

扫描只报告路径和风险类型，不在对话中打印真实密钥。

### 4. 大文件与资产扫描

GitHub 普通 Git 单文件上限是 100 MB。预检时建议把 90 MB 作为人工检查线。

需要区分：

- 应备份：项目原创图片、`.glb`、正式 `.rbxm/.rbxmx`、配置表、设计文档；
- 通常忽略：构建产物、缓存、依赖目录、临时导出、日志；
- 超大资产：评估 Git LFS，不能直接静默遗漏。

Roblox 项目不能机械地忽略所有 `.rbxm/.rbxmx`。如果它们是 Rojo 正式资源或唯一 Studio 源文件，应通过 `.gitignore` 例外规则纳入备份，例如：

```gitignore
*.rbxm
*.rbxmx

!art/StudioExports/**/*.rbxm
!art/StudioExports/**/*.rbxmx
!src/**/*.rbxm
!src/**/*.rbxmx
```

### 5. 记录备份前健康状态

运行项目已有的低风险验证命令，例如：

- 单元测试或结构测试；
- 格式检查和静态检查；
- Rojo build；
- 配置导出一致性检查。

检查失败不等于不能备份。若用户要保存“当前现场”，应明确标记为**现状基线快照**，不要在备份过程中顺手重构代码。

## 阶段二：创建本地快照

### 1. 没有 Git 时初始化

```powershell
git -C $projectRoot init -b main
```

不要随意覆盖全局 Git 用户名和邮箱。提交身份缺失时先报告。

### 2. 核对 `.gitignore`

先确认正式资产没有被误排除：

```powershell
git -C $projectRoot check-ignore -v -- path\to\important-asset.rbxm
```

暂存后还要通过文件清单再次确认，不能只依赖 `check-ignore` 的退出码。

### 3. 暂存完整项目

只有完成敏感信息、大文件和范围预检后，才执行：

```powershell
git -C $projectRoot add -A
git -C $projectRoot status --short
git -C $projectRoot diff --cached --stat
```

重点核对：

- 删除是否属于当前项目真实状态；
- 正式模型、贴图和配置是否已进入暂存区；
- 是否误纳入依赖、缓存、密钥或其他项目文件；
- 暂存文件数量和体积是否合理。

### 4. 创建快照提交

```powershell
git -C $projectRoot commit -m "chore: checkpoint current project baseline"
```

这是“备份当前现场”的提交，不应伪装成已经全部测试通过的功能发布。

## 阶段三：创建 GitHub 私有仓库

### 推荐：GitHub CLI

先确认账号：

```powershell
gh auth status
```

创建同名私有仓库并绑定当前项目：

```powershell
gh repo create <账号>/<项目文件夹名> --private --source $projectRoot --remote origin
```

如果用户明确要求使用已经登录的应用内浏览器，可以在 GitHub 页面创建私有空仓库，再执行：

```powershell
git -C $projectRoot remote add origin https://github.com/<账号>/<仓库名>.git
```

不要同时创建 README、`.gitignore` 或 License，以免空仓库产生额外提交并导致第一次推送冲突。

## 阶段四：推送和双重验证

```powershell
git -C $projectRoot push -u origin main
```

推送后必须验证：

```powershell
git -C $projectRoot status -sb
git -C $projectRoot rev-parse HEAD
git -C $projectRoot ls-remote --heads origin main
gh repo view <账号>/<仓库名> --json nameWithOwner,visibility,defaultBranchRef,url
```

验收标准：

- 工作区没有漏掉的项目变更；
- `main` 正在跟踪 `origin/main`；
- 本地 `HEAD` 与远端 `main` SHA 完全一致；
- 仓库可见性确认为 `PRIVATE`；
- GitHub 页面能够看到代码、文档和应备份资产。

## 输出报告模板

```markdown
Git 备份已完成。

- 项目：
- 私有仓库：
- 默认分支：main
- 提交 SHA：
- 提交说明：
- 备份文件数量：
- 重要资产：
- 自动检查：
- 已知基线问题：
- 本地与远端是否一致：
```

## 风险与处理原则

### 远端已存在

不要执行 `remote set-url` 覆盖未知仓库。先报告当前 URL 和准备使用的 URL。

### 推送被拒绝

不要使用 `--force`。先检查远端是否已经有提交，再决定拉取、合并或建立新分支。

### 误提交密钥

立即停止继续推送。即使从 Git 删除，密钥也应视为已经泄露并进行吊销或轮换；不要只做普通提交删除。

### 文件超过 100 MB

停止普通推送，评估 Git LFS、拆分资产包或外部资产存储。不要静默漏备份。

### 备份后需要回滚项目修改

优先查看快照，不使用破坏性命令：

```powershell
git show --stat <快照SHA>
git diff <快照SHA>..HEAD
```

已经推送的提交需要撤销时，优先使用新的 `git revert` 提交。`reset --hard`、强推和删除仓库必须获得用户明确授权。

## 已验证案例

2026-07-29 在 `RobloxFarmGame` 上验证：

- 保留原有两条本地 Git 历史；
- 创建 `yangshulin2333/RobloxFarmGame` 私有仓库；
- 将代码、配置、文档、UI、GLB 和正式 Studio `.rbxm` 源文件纳入快照；
- 236 个文件提交为 `3b350fc`；
- 本地 `main` 与远端 `origin/main` SHA 一致；
- 项目级 4 个 PowerShell 验证脚本通过；
- StyLua 的既有解析问题被记录为基线问题，没有在备份过程中擅自修复。

## 相关笔记

- [[Git 与 TortoiseGit Windows 标准安装流程]]
- [[TortoiseGit 使用教程]]
