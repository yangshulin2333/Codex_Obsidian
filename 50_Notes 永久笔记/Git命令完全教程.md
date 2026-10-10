---
created: 2026-05-12
source: web
type: note
status: summarized
tags:
  - status/summarized
---
# 绑定身份
```
git config --global user.email "yangshulin2333@gmail.com"

git config --global user.name "yangshulin2333"
```

---

## **1️⃣ `git init` - 初始化仓库**

### **作用：**
在当前文件夹创建一个Git仓库（把普通文件夹变成Git可以管理的文件夹）

### **语法：**
```bash
rm -rf .git //清除提交信息
git init
```

### **发生了什么：**
- 创建了一个隐藏文件夹 `.git/`
- 这个文件夹里存储所有版本历史记录
- 文件夹现在可以被Git追踪了

### **类比理解：**
就像给你的文件夹装了一个"监控摄像头"，可以记录所有变化

### **实际执行：**
```bash
Admin@DESKTOP-EH0PKQN MINGW64 /d/Yanzo/yanzo_note (main)
$ git init
Reinitialized existing Git repository in D:/Yanzo/yanzo_note/.git/
```

---

## **2️⃣ `git add .` - 添加文件到暂存区**

### **作用：**
告诉Git："我要把这些文件的当前状态记录下来"
### **语法：**
```bash
git add .              # 添加当前目录所有文件
git add 文件名.txt     # 添加指定文件
git add *.md           # 添加所有.md文件
git add 文件夹名/      # 添加整个文件夹
```

### **工作流程：**

```
工作区               暂存区              仓库
(你的文件)     →    (准备提交的)    →    (正式记录)
Working Dir         Staging Area        Repository

修改文件     git add .    等待提交    git commit    永久保存
```

### **类比理解：**
- **工作区** = 你的书桌（正在写作业）
- **暂存区** = 整理好的作业本（准备交给老师）
- **仓库** = 老师的档案柜（永久保存）

`git add .` 就是把书桌上所有作业整理到作业本里

### **`.` 是什么意思？**
- `.` 代表"当前目录"
- `..` 代表"上一级目录"

### **实际执行：**
```bash
$ git add .
warning: in the working copy of '.obsidian/core-plugins.json', 
LF will be replaced by CRLF the next time Git touches it
```

**警告解释：**
- LF = Linux换行符（`\n`）
- CRLF = Windows换行符（`\r\n`）
- Git会自动转换换行符，这不是错误

---

## **3️⃣ `git commit -m "message"` - 提交到仓库**

### **作用：**
把暂存区的内容正式保存到Git仓库，并附上说明

### **语法：**
```bash
git commit -m "首次提交"
git commit -m "修复了bug"
git commit -m "添加了新功能"
```

### **参数说明：**
- `-m` = message（消息）
- 引号内是提交说明（必须写）

### **提交信息规范：**

```bash
# ✅ 好的提交信息
git commit -m "添加用户登录功能"
git commit -m "修复首页加载慢的问题"
git commit -m "更新README文档"

# ❌ 不好的提交信息
git commit -m "修改"
git commit -m "update"
git commit -m "aaa"
```

### **提交信息模板：**

```bash
# 格式：动词 + 具体内容

添加：git commit -m "添加用户注册页面"
修复：git commit -m "修复登录失败的bug"
更新：git commit -m "更新配置文件"
删除：git commit -m "删除无用的代码"
重构：git commit -m "重构数据库连接模块"
```

### **实际执行：**
```bash
$ git commit -m "首次提交- 上传笔记"
[main (root-commit) db29a53] 首次提交- 上传笔记
 5 files changed, 38 insertions(+)
 create mode 100644 .gitignore
 create mode 100644 .obsidian/app.json
 create mode 100644 .obsidian/appearance.json
 create mode 100644 .obsidian/core-plugins.json
 create mode 100644 "笔记文件.md"
```

**输出解释：**
- `[main db29a53]` = 在main分支，提交ID是db29a53
- `5 files changed` = 5个文件被修改
- `38 insertions(+)` = 新增了38行内容
- `create mode 100644` = 创建文件（100644是文件权限）

---

## **4️⃣ `git remote -v` - 查看远程仓库**

### **作用：**
查看当前配置了哪些远程仓库

### **语法：**
```bash
git remote -v          # 查看详细信息
git remote             # 只显示名字
```

### **参数说明：**
- `-v` = verbose（详细信息）

### **实际执行：**
```bash
$ git remote -v
origin  git@github.com:yangshulin2333/yanzo_note.git (fetch)
origin  git@github.com:yangshulin2333/yanzo_note.git (push)
```

**输出解释：**
- `origin` = 远程仓库的默认名字
- `fetch` = 拉取地址（从GitHub下载）
- `push` = 推送地址（上传到GitHub）

### **远程仓库操作：**

```bash
# 添加远程仓库
git remote add origin https://github.com/用户名/仓库名.git

# 删除远程仓库
git remote remove origin

# 修改远程仓库地址
git remote set-url origin 新地址

# 重命名远程仓库
git remote rename origin github
```

---

## **5️⃣ `git push -u origin main` - 推送到远程**

### **作用：**
把本地仓库的内容上传到GitHub

### **语法：**
```bash
git push -u origin main    # 第一次推送
git push                   # 之后推送
```

### **参数详解：**

```bash
git push -u origin main
│    │  │      │    └─ 分支名（main）
│    │  │      └────── 远程仓库名（origin）
│    │  └───────────── 设置上游分支
│    └──────────────── push命令
└───────────────────── git命令
```

- `push` = 推送（上传）
- `-u` = `--set-upstream`（设置上游分支）
- `origin` = 远程仓库名字
- `main` = 分支名

### **`-u` 的作用：**

```bash
# 第一次推送（需要-u）
git push -u origin main

# 之后推送（不需要-u，直接git push）
git push
```

**设置上游后，Git会记住：**
- 本地的main分支对应远程的origin/main
- 以后直接 `git push` 就知道推送到哪里

### **实际执行：**
```bash
$ git push origin main
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 16 threads
Compressing objects: 100% (5/5), done.
Writing objects: 100% (7/7), 756 bytes | 756.00 KiB/s, done.
Total 7 (delta 0), reused 0 (delta 0), pack-reused 0
To github.com:yangshulin2333/yanzo_note.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
```

**输出详解：**
1. `Enumerating objects: 7` - 枚举7个对象（文件）
2. `Counting objects: 100% (7/7)` - 统计对象（进度100%）
3. `Delta compression` - 压缩（节省上传大小）
4. `Writing objects: 100% (7/7)` - 上传对象
5. `756 bytes | 756.00 KiB/s` - 文件大小和传输速度
6. `[new branch] main -> main` - 创建新分支main
7. `branch 'main' set up to track 'origin/main'` - 设置追踪关系

---

## **🎯 完整工作流程图**

```
┌──────────────────────────────────────────────────────────┐
│                     Git工作流程                          │
└──────────────────────────────────────────────────────────┘

1. 初始化仓库
   ┌─────────────┐
   │  git init   │
   └─────────────┘
         ↓
   创建 .git/ 文件夹

2. 修改文件
   ┌─────────────────┐
   │  编辑 note.md   │
   └─────────────────┘
         ↓
   文件在工作区（Working Directory）

3. 添加到暂存区
   ┌─────────────┐
   │  git add .  │
   └─────────────┘
         ↓
   文件在暂存区（Staging Area）

4. 提交到本地仓库
   ┌────────────────────────────┐
   │  git commit -m "更新笔记"  │
   └────────────────────────────┘
         ↓
   文件在本地仓库（Local Repository）

5. 推送到远程仓库
   ┌────────────────────────┐
   │  git push origin main  │
   └────────────────────────┘
         ↓
   文件在GitHub（Remote Repository）
```

---

## **🔍 Git三个区域详解**

### **1. 工作区（Working Directory）**
- 你的文件夹（能看到的文件）
- 正在编辑的文件

```bash
D:/Yanzo/yanzo_note/
├── note.md          ← 工作区文件
├── image.png        ← 工作区文件
└── .git/            ← Git仓库（隐藏）
```

### **2. 暂存区（Staging Area / Index）**
- 临时存储区
- 准备提交的文件

```bash
git add note.md      # note.md进入暂存区
git add image.png    # image.png进入暂存区
```

### **3. 本地仓库（Local Repository）**
- `.git/` 文件夹
- 正式的版本历史

```bash
git commit -m "提交"  # 暂存区内容进入仓库
```

### **流程演示：**

```bash
# 场景：修改了note.md文件

# 步骤1：查看状态
$ git status
Changes not staged for commit:
  modified:   note.md        ← 文件在工作区，已修改

# 步骤2：添加到暂存区
$ git add note.md

# 再次查看状态
$ git status
Changes to be committed:
  modified:   note.md        ← 文件在暂存区，等待提交

# 步骤3：提交到仓库
$ git commit -m "更新笔记内容"

# 再次查看状态
$ git status
nothing to commit, working tree clean  ← 工作区干净
```

---

## **📝 常用命令组合**

### **场景1：第一次上传项目**

```bash
# 1. 初始化
git init

# 2. 添加所有文件
git add .

# 3. 提交
git commit -m "首次提交"

# 4. 关联远程仓库
git remote add origin https://github.com/用户名/仓库名.git

# 5. 推送
git push -u origin master
```

---

### **场景2：日常更新**

```bash
# 1. 查看修改了什么
git status

# 2. 添加修改
git add .

# 3. 提交
git commit -m "更新内容"

# 4. 推送
git push
```

---

### **场景3：查看历史**

```bash
# 查看提交历史
git log

# 简洁查看
git log --oneline

# 查看最近3次提交
git log -3

# 查看某个文件的历史
git log note.md
```

---

### **场景4：撤销操作**

```bash
# 撤销工作区的修改（还没add）
git checkout -- note.md

# 撤销暂存区的文件（已add但未commit）
git reset HEAD note.md

# 撤销最后一次提交（保留修改）
git reset --soft HEAD^

# 撤销最后一次提交（删除修改）
git reset --hard HEAD^
```

---

## **🌿 分支（Branch）概念**

### **什么是分支？**

```
main分支（主分支）
  │
  ├─ commit1: 初始提交
  ├─ commit2: 添加功能A
  ├─ commit3: 修复bug
  └─ commit4: 更新文档

dev分支（开发分支）
  │
  ├─ commit1: 初始提交
  ├─ commit2: 开发新功能
  └─ commit3: 测试新功能
```

### **分支命令：**

```bash
# 查看所有分支
git branch

# 创建新分支
git branch dev

# 切换分支
git checkout dev

# 创建并切换（简写）
git checkout -b dev

# 合并分支
git merge dev

# 删除分支
git branch -d dev
```

---

## **🔄 拉取（Pull）和推送（Push）**

### **推送（Push）- 上传**

```bash
git push origin main    # 推送main分支到origin
git push                # 推送当前分支（设置上游后）
git push --all          # 推送所有分支
```

### **拉取（Pull）- 下载**

```bash
git pull origin main    # 从origin拉取main分支
git pull                # 拉取当前分支
```

### **Pull = Fetch + Merge**

```bash
# git pull 等价于：
git fetch origin        # 下载远程内容
git merge origin/main   # 合并到本地
```

---

## **⚙️ 配置（Config）**

### **查看配置：**

```bash
# 查看所有配置
git config --list

# 查看用户名
git config user.name

# 查看邮箱
git config user.email
```

### **设置配置：**

```bash
# 设置用户名（全局）
git config --global user.name "yangshulin2333"

# 设置邮箱（全局）
git config --global user.email "your-email@example.com"

# 设置用户名（仅当前仓库）
git config user.name "yangshulin2333"

# 设置默认编辑器
git config --global core.editor "code"  # VSCode

# 设置换行符处理
git config --global core.autocrlf true  # Windows
git config --global core.autocrlf input # Mac/Linux
```

### **配置级别：**

```bash
--system    # 系统级别（所有用户）
--global    # 用户级别（当前用户所有仓库）
--local     # 仓库级别（仅当前仓库）
```

---

## **📊 `git status` - 查看状态**

### **作用：**
查看当前工作区和暂存区的状态

### **可能的输出：**

```bash
# 情况1：工作区干净
$ git status
On branch main
nothing to commit, working tree clean

# 情况2：有未跟踪的文件
$ git status
Untracked files:
  new-file.md          ← 新文件，Git还不知道

# 情况3：有修改但未添加
$ git status
Changes not staged for commit:
  modified:   note.md  ← 已修改，但未git add

# 情况4：已添加但未提交
$ git status
Changes to be committed:
  modified:   note.md  ← 已git add，等待commit
```

---

## **🎓 练习题**

### **练习1：理解工作流程**

```bash
# 1. 创建测试文件夹
mkdir git-practice
cd git-practice

# 2. 初始化仓库
git init

# 3. 创建文件
echo "Hello Git" > test.txt

# 4. 查看状态
git status              # 看到什么？

# 5. 添加到暂存区
git add test.txt

# 6. 再次查看状态
git status              # 看到什么变化？

# 7. 提交
git commit -m "添加test.txt"

# 8. 再次查看状态
git status              # 现在是什么状态？
```

---

### **练习2：修改和提交**

```bash
# 1. 修改文件
echo "Git is awesome" >> test.txt

# 2. 查看修改内容
git diff test.txt

# 3. 添加并提交
git add test.txt
git commit -m "更新test.txt"

# 4. 查看历史
git log --oneline
```

---

## **🚀 速查表（保存到文件）**

```bash
┌─────────────────────────────────────────────┐
│              Git 速查表                     │
└─────────────────────────────────────────────┘

📋 基础命令
  git init                  初始化仓库
  git status                查看状态
  git add .                 添加所有文件
  git commit -m "msg"       提交
  git push                  推送
  git pull                  拉取

🔍 查看命令
  git log                   查看历史
  git log --oneline         简洁历史
  git diff                  查看修改
  git show                  查看最后一次提交

🌿 分支命令
  git branch                查看分支
  git branch name           创建分支
  git checkout name         切换分支
  git checkout -b name      创建并切换
  git merge name            合并分支

🔄 远程命令
  git remote -v             查看远程仓库
  git remote add origin url 添加远程仓库
  git push origin main      推送到远程
  git pull origin main      从远程拉取

↩️ 撤销命令
  git checkout -- file      撤销工作区修改
  git reset HEAD file       撤销暂存区
  git reset --hard HEAD^    撤销提交

⚙️ 配置命令
  git config --list         查看配置
  git config user.name      查看用户名
  git config --global user.name "name"  设置用户名
```

---

后续：
- 分支的详细用法
- 如何回退到之前的版本
- 如何解决冲突
- `.gitignore` 的详细规则
- Git工作原理

