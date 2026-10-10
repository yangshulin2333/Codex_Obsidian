---
type: resource
domain: knowledge-management
status: collected
source: generated
tags:
  - obsidian
  - workflow/git-sync
  - ai/notes
  - status/collected
created: 2026-05-14
updated: 2026-06-26
---

# Obsidian Git 同步与 AI 笔记工作流（豆包总结）

## 一、先把软件装齐（Windows / Mac）

1. **Obsidian**：官网下载安装
    
    [https://obsidian.md/](https://obsidian.md/)
2. **Git**：安装并一路默认
    
    [https://git-scm.com/](https://git-scm.com/)
3. **GitHub Desktop（推荐新手）**
    
    [https://desktop.github.com/](https://desktop.github.com/)
4. **GitHub 账号**：注册并登录，**一定要记住密码**。

---

## 二、GitHub 建私有仓库（关键：私有！）

1. 右上角「+」→ New repository
2. 填写：
    
    - Repository name：`obsidian-vault`（随便）
    - Description：可不填
    - ✅ **Private（私有）**
    - ❌ 不要勾选 Add README
    
3. 点 Create repository。

---

## 三、本地建 Vault，并关联 GitHub

1. 找个干净目录，比如：
    
    plaintext
    
    ```
    D:\Obsidian\MyVault
    ```
    
2. 打开 GitHub Desktop → File → Clone repository
    
    - URL：粘贴你 GitHub 仓库地址
        
        `https://github.com/你的名字/obsidian-vault.git`
    - Local path：选上面那个目录
    
3. 点 Clone（此时本地有了一个带 `.git` 的空仓库）。
    
4. **用 Obsidian 打开这个文件夹**
    
    - 打开 Obsidian →「打开仓库」→「打开本地仓库文件夹」
    - 选中 `D:\Obsidian\MyVault`
    - 进来后，你就有了一个**受 Git 版本控制的笔记库**。
    

---

## 四、设置 `.gitignore`（避免同步冲突）

在 Vault 根目录新建文件：

`.gitignore`，内容：

plaintext

```
# Obsidian 工作区（窗口布局、打开标签）
.obsidian/workspace.json
.obsidian/workspace-mobile.json

# 系统文件
.DS_Store
Thumbs.db

# 回收站、缓存
.trash/
*.tmp
```

保存，以后这些东西**不会上传 GitHub，避免冲突**。

---

## 五、安装 Obsidian Git（自动同步核心）

1. Obsidian 左下角 ⚙️「设置」→「第三方插件」
2. **关闭安全模式**
3. 浏览 → 搜索 `Git` → 安装 **Vinzent** 写的「Obsidian Git」→ 启用。
![450](assets/豆包总结Obsidian/file-20260512130307428.png)
### 插件设置（照着填）

- **Pull on startup**：开启（打开 Obsidian 自动拉最新）
- **Auto commit-and-sync**：开启
- **Delay（分钟）**：1（停笔 1 分钟自动提交推送）
- **Auto pull interval**：5（每 5 分钟拉一次）
- Commit message：`vault backup: {{date}}`

设置完，你**写笔记会自动同步到 GitHub，不用敲命令**。

---

## 六、文件夹结构（直接照搬）

在 Vault 里一次性建好：

plaintext

```
00 Inbox
10 Projects
20 Areas
30 MOCs
40 Resources
50 Notes
90 Archive
Assets
```

- **00 Inbox**：随手记、临时想法
- **10 Projects**：项目（有起止时间）
- **20 Areas**：长期领域（学习、工作、健康）
- **30 MOCs**：知识地图（重点！）
- **40 Resources**：视频、文章、教程笔记
- **50 Notes**：永久笔记
- **90 Archive**：归档
- **Assets**：图片 / 附件统一放这

---

## 七、处理图片（标准 Markdown，GitHub 可预览）

![](assets/豆包总结Obsidian/file-20260512130307429%201.png)

![](assets/豆包总结Obsidian/file-20260512130307429.png)

1. 设置 → Files and Links
    
    - ❌ 关闭「Use Wikilinks」
    - New link format：选「Relative path to file」
    
2. 安装插件：`Custom Attachment Location`
3. 设置：附件默认保存到 `Assets`，自动子文件夹。

以后插图：

```markdown
![图名](Assets/xxx/图片.png)
```

**GitHub、VS Code、所有 Markdown 编辑器都能正常显示**。

---

## 八、手机端同步（Android，免费）

### 方案：Termux + Git + Obsidian（免费稳）

1. 安卓安装：
    
    - Obsidian（手机版）
    - Termux（应用商店）
    
2. Termux 执行：
    
    bash
    
    运行
    
    ```
    pkg install git
    cd /storage/emulated/0/Documents
    git clone https://github.com/你的名字/obsidian-vault.git
    ```
    
3. 手机 Obsidian → 打开 `/storage/emulated/0/Documents/obsidian-vault`
4. 每次要同步：
    
    bash
    
    运行
    
    ```
    cd /storage/emulated/0/Documents/obsidian-vault
    git pull
    git add .
    git commit -m "mobile update"
    git push
    ```
    

（视频里是这个路子，免费、无订阅）

---

## 九、AI 玩法（视频主推：AI 直接读写本地 md）

### 推荐：Claude Code / Gemini CLI（命令行 AI）

你在 Vault 目录直接让 AI：

- 总结风格、批量建文件夹
- 生成大纲、整理结构
- 改写、润色、生成视频脚本

**安全关键点：全程 Git**

- AI 改错了：GitHub Desktop → Discard changes 或回退历史
- 不怕误删、不怕乱改

示例（命令行）：

bash

运行

```
# 把所有 Inbox 笔记整理成 5 个主题
claude "整理 00 Inbox 下所有 md，按主题归类到 10 Projects"
```

---

## 十、按视频要求，先建这些「概念笔记」

在 `30 MOCs` 或 `50 Notes` 里建：

plaintext

```
[[Obsidian]]
[[Markdown]]
[[GitHub]]
[[Git]]
[[Obsidian Git]]
[[Custom Attachment Location]]
[[Pandoc]]
[[Gemini CLI]]
[[Claude Code]]
[[AI 编程工具]]
[[双向链接]]
[[MOC]]
```

每个文件只写一句定义即可（种子笔记）。

示例：`Obsidian Git.md`

markdown

```
---
type: concept
status: seed
---

# Obsidian Git
Obsidian 社区插件，用于自动提交、拉取、推送笔记到 Git 仓库。
```

---

## 十一、建 4 个核心 MOC（知识地图入口）

plaintext

```
30 MOCs/Obsidian MOC.md
30 MOCs/知识管理 MOC.md
30 MOCs/同步与备份 MOC.md
30 MOCs/AI 辅助笔记 MOC.md
```

### Obsidian MOC.md

markdown

```
# Obsidian MOC

## 入门
- [[Obsidian]]
- [[Markdown]]
- [[双向链接]]
- [[MOC]]

## 同步
- [[GitHub]]
- [[Git]]
- [[Obsidian Git]]

## 附件
- [[Custom Attachment Location]]
- [[Assets 附件管理]]

## AI
- [[AI 编程工具]]
- [[Claude Code]]
- [[Gemini CLI]]
```

另外三个 MOC 同理，把相关概念双链挂进去。

---

## 十二、你接下来的第一天操作清单（照顺序）

1. 安装软件并登录 GitHub
2. 建私有仓库 → 本地克隆 → Obsidian 打开
3. 建好 `.gitignore`
4. 安装并配置 Obsidian Git
5. 建好 9 个一级文件夹 + Assets
6. 把这份视频总结存为：
    
    `40 Resources/YouTube/Obsidian邪修用法 免费云同步 AI 手机端.md`
7. 在这篇笔记里把关键词改成双链
8. 点开红链，批量建种子笔记
9. 建 4 个 MOC，把笔记挂进去
10. 随便写一条测试笔记，看是否**自动提交并同步到 GitHub**
