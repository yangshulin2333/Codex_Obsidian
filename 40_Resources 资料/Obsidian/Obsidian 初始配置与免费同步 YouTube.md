---
type: resource
domain: knowledge-management
status: collected
source: youtube
tags:
  - obsidian
  - workflow/git-sync
  - ai/notes
  - status/collected
created: 2026-05-14
updated: 2026-06-26
---

# Obsidian 初始配置与免费同步 YouTube

视频：[Obsidian邪修用法，免费云同步，AI，手机端，还有进阶技巧](https://www.youtube.com/watch?v=IlNOhNeWGgY)

#### **视频知识点总结**

这期视频的核心思路是：把 Obsidian 当成本地 Markdown 知识库，再用 GitHub 做免费云同步，用 AI 工具处理本地笔记，用插件解决图片、导出、手机端同步等问题。

作者选择 Obsidian 的三个理由：

1. **数据安全**  
   Obsidian 的笔记本质是本地 `.md` 文件，不是被锁在某个云笔记平台里。即使 Obsidian 不用了，也可以用 VS Code、Typora、其他 Markdown 编辑器继续打开。

2. **速度快，不卡顿**  
   相比一些云笔记软件，Obsidian 本地文件操作很快，切换笔记、打开窗口、编辑内容都更顺滑，不容易打断心流。

3. **适合 AI 工具处理**  
   AI 编程工具擅长读写本地文件，而 Obsidian 笔记就是 Markdown 文件，所以很适合让 AI 帮你整理、搜索、改写、生成大纲、批量建文件夹。

**GitHub 免费同步方案**

视频推荐用 GitHub 做云同步和备份：

- 注册 GitHub
- 创建一个新的 Repository
- 一定要选 `Private` 私有仓库，避免笔记公开
- 安装 GitHub Desktop
- 把 GitHub 仓库 clone 到本地
- 用 Obsidian 打开这个本地文件夹作为 vault
- 每一篇笔记就是仓库里的一个 Markdown 文件

需要注意 `.obsidian` 里的工作区文件：

```gitignore
.obsidian/workspace.json
.obsidian/workspace-mobile.json
```

这类文件记录当前打开了哪些标签页、布局状态，经常变化，上传到 GitHub 容易造成冲突。

**Obsidian Git 插件**

为了不用每次手动 commit / push，视频推荐安装社区插件：

```text
Obsidian Git
```

关键设置：

```text
Auto commit-and-sync after stopping file edits
```

意思是停止编辑一段时间后自动提交并同步。

视频里设置成：

```text
1 分钟
```

还建议开启：

```text
Pull on startup
```

这样每次打开 Obsidian 时，先从 GitHub 拉取最新内容，减少多设备不同步的问题。

**AI 玩法**

视频提到两种 AI 接入方式：

```text
Plan A：Obsidian 社区 AI 插件
Plan B：AI 编程工具，例如 Claude Code / Gemini CLI
```

作者更推荐 Plan B，因为 AI 编程工具本来就擅长操作本地文件。

典型玩法：

- 让 AI 读取过去的文章、脚本、笔记
- 总结你的写作风格
- 根据已有内容生成新选题
- 批量创建文件夹和大纲文件
- 根据网页文章写视频脚本
- 整理 Obsidian 文件结构
- 修改不满意时，用 Git 回滚

这里的关键点是：**Git 让 AI 操作文件更安全**。  
如果 AI 把文件改乱了，可以通过 GitHub Desktop 的 `Discard changes` 或 Git 历史回退。

**Markdown 基础语法**

视频复习了 Obsidian 最常用的 Markdown：

```markdown
# 一级标题
## 二级标题

**加粗**
~~删除线~~
==高亮==

> 引用

- 无序列表
1. 有序列表

```js
console.log("代码块")
```
```

表格、分隔线、数学公式块可以通过右键插入。

作者认为掌握这些就够用 Obsidian 80% 的功能。

**图片与附件管理**

视频认为 Obsidian 默认图片管理有两个问题：

- 图片容易散落在笔记同级目录，文件夹变乱
- 默认的 `![[图片.png]]` 是 Obsidian Wikilink 格式，不是标准 Markdown，GitHub / VS Code 可能无法正常预览

推荐插件：

```text
Custom Attachment Location
```

配合 Obsidian 设置：

```text
Settings → Files and Links
关闭 Use Wikilinks
New link format 选择 Relative path to file
```

推荐目标：

- 图片统一进 `assets` 或 `Assets`
- 每篇笔记有自己的附件子文件夹
- 图片链接使用标准 Markdown 格式
- 重命名笔记时，附件文件夹和链接也能跟着更新

**手机端同步**

视频演示的是 Android：

1. 用数据线把电脑上的 Obsidian vault 复制到手机 `Documents` 文件夹
2. 手机 Obsidian 选择 `Open folder as vault`
3. 安装 / 配置 Git 插件
4. 填 GitHub 用户名、邮箱、Personal Access Token
5. 手机端新建笔记后，可以自动同步到 GitHub
6. 电脑端 Obsidian 再拉取回来

注意事项：

```text
不要手机和电脑同时编辑同一个文件
```

否则 Git 可能产生冲突，需要手动解决。

**导出 Word / HTML**

视频推荐插件：

```text
Enhancing Export
```

它依赖格式转换工具：

```text
Pandoc
```

配置好 Pandoc 路径后，可以把 Obsidian 笔记导出为：

- Word
- HTML
- 其他格式

并且图片也能正常带过去。

**双向链接与知识图谱**

Obsidian 的核心能力之一是双向链接：

```markdown
[[另一篇笔记]]
```

可以在一篇笔记里引用另一篇笔记。  
两个笔记建立链接后，会在关系图谱里形成连线。

用途：

- 建立知识之间的关系
- 发现隐藏关联
- 让笔记从“文件堆”变成“知识网络”

---

下面是我建议你把这条视频笔记放进 Obsidian 的具体做法。

**Folders：文件夹怎么建**

你的文件夹不要按“知识主题”细分太深。文件夹只负责放置，不负责表达所有关系。

建议结构：

```text
00 Inbox
10 Projects
20 Areas
30 MOCs
40 Resources
50 Notes
90 Archive
Assets
```

含义：

```text
00 Inbox：临时收集，没整理的东西
10 Projects：有明确目标和结束时间的项目
20 Areas：长期关注领域，比如 Roblox、Unity、技术美术
30 MOCs：内容地图
40 Resources：外部资料、视频、文章、教程
50 Notes：你自己沉淀出来的长期笔记
90 Archive：归档
Assets：附件、图片、PDF
```

这条 YouTube 视频建议放这里：

```text
40 Resources/YouTube/Obsidian邪修用法 免费云同步 AI 手机端.md
```

不要放进“开发文档”或“工具教程”这种容易纠结的父子文件夹。它可以通过链接同时属于多个主题。

**Tags：标签怎么打**

标签只用来表达“状态”和“类型”，不要拿标签当复杂分类。

这篇视频笔记可以这样写：

```yaml
---
type: video-note
source: youtube
status: summarized
topic:
  - Obsidian
  - GitHub
  - AI
created: 2026-05-12
---
```

正文里也可以加少量标签：

```markdown
#type/video-note #source/youtube #status/summarized
```

推荐标签体系：

```text
#type/video-note
#type/concept
#type/project
#type/tutorial
#type/checklist

#status/inbox
#status/processing
#status/summarized
#status/evergreen

#source/youtube
#source/article
#source/book
```

不要这样滥用：

```text
#Obsidian #GitHub #AI #同步 #手机端 #Markdown #知识管理
```

这些更适合用双链。

**Links：双向链接怎么用**

这篇笔记里第一次出现关键概念时，直接加双链：

```markdown
Obsidian 的笔记本质是本地 [[Markdown]] 文件，可以通过 [[GitHub]] 和 [[Obsidian Git]] 做免费同步。

视频还提到用 [[Gemini CLI]]、[[Claude Code]] 这类 [[AI 编程工具]] 处理本地笔记。

图片管理可以通过 [[Custom Attachment Location]] 插件解决，导出 Word 可以用 [[Pandoc]] 和 [[Enhancing Export]]。
```

建议你为这些概念建独立笔记：

```text
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

每个概念笔记不用一开始写很多。哪怕只有一句定义也行。

例如 `Obsidian Git.md`：

```markdown
---
type: concept
status: seed
---

# Obsidian Git

Obsidian 的社区插件，用来把 vault 自动 commit、pull、push 到 Git 仓库。

## 相关
- [[GitHub]]
- [[Git]]
- [[Obsidian]]
- [[免费云同步]]
```

#### **MOC：内容地图怎么建**

你至少建这几个 MOC：

```text
30 MOCs/Obsidian MOC.md
30 MOCs/知识管理 MOC.md
30 MOCs/同步与备份 MOC.md
30 MOCs/AI 辅助笔记 MOC.md
```

`Obsidian MOC.md` 可以这样写：

```markdown
# Obsidian MOC

## 入门与基础
- [[Obsidian]]
- [[Markdown]]
- [[双向链接]]
- [[MOC]]

## 同步与备份
- [[GitHub]]
- [[Git]]
- [[Obsidian Git]]
- [[免费云同步]]

## 附件与图片
- [[Custom Attachment Location]]
- [[Assets 附件管理]]

## AI 工作流
- [[AI 编程工具]]
- [[Gemini CLI]]
- [[Claude Code]]

## 视频资料
- [[Obsidian邪修用法 免费云同步 AI 手机端]]
```

`同步与备份 MOC.md`：

```markdown
# 同步与备份 MOC

## GitHub 方案
- [[GitHub]]
- [[Git]]
- [[GitHub Desktop]]
- [[Obsidian Git]]

## 注意事项
- [[Git 冲突]]
- [[workspace.json]]
- [[Personal Access Token]]

## 相关资料
- [[Obsidian邪修用法 免费云同步 AI 手机端]]
```

`AI 辅助笔记 MOC.md`：

```markdown
# AI 辅助笔记 MOC

## 工具
- [[Gemini CLI]]
- [[Claude Code]]
- [[AI 编程工具]]

## 用法
- [[AI 整理 Obsidian 笔记]]
- [[AI 生成选题]]
- [[AI 批量处理 Markdown 文件]]

## 风险控制
- [[Git 回滚]]
- [[AI 修改文件前备份]]
```

#### **你实际操作的顺序**

按这个顺序来，不容易乱：

1. 在 Obsidian 里建基础文件夹：

```text
00 Inbox
10 Projects
20 Areas
30 MOCs
40 Resources
50 Notes
90 Archive
Assets
```

2. 在 `40 Resources/YouTube/` 下新建视频笔记：

```text
Obsidian邪修用法 免费云同步 AI 手机端.md
```

3. 把我上面的视频总结放进去。

4. 在这篇视频笔记里，把关键概念改成双链：

```markdown
[[Obsidian]]
[[GitHub]]
[[Obsidian Git]]
[[Markdown]]
[[Custom Attachment Location]]
[[Gemini CLI]]
[[Pandoc]]
```

5. 点开这些尚未创建的链接，每个补一句话，先变成“种子笔记”。

6. 建 `Obsidian MOC`，把这篇视频笔记和相关概念都挂进去。

7. 以后你看到新的 Obsidian 教程，不要再纠结放哪个文件夹，统一放：

```text
40 Resources/YouTube/
```

然后通过链接挂到：

```text
[[Obsidian MOC]]
[[同步与备份 MOC]]
[[AI 辅助笔记 MOC]]
```

一句话原则：

```text
文件夹负责位置，标签负责状态，链接负责关系，MOC负责主题入口。
```

这条视频笔记最适合变成你的 `Obsidian MOC` 第一条资料。它不是单纯“插件教程”，而是一套“本地 Markdown + GitHub + AI + 附件 + 手机端”的 Obsidian 工作流。
