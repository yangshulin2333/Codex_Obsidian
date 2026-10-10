# New Chat Prompt / 新对话启动提示词

在新项目根目录打开 Codex 后，直接粘贴：

```text
这是一个新的 Roblox 项目。
我已经把 Roblox 项目读取工作流提供给你，或者复制到了当前项目根目录。
我的英语水平只有大学英语四级，请默认用中文沟通，技术名词可以保留英文。

请先读取工作流里的：
1. README.md
2. WORKFLOW_MANIFEST.json
3. 00_Start_Here_For_Codex_给Codex先读.md
4. 04_Status_And_Stop_Rules_状态与收口规则.md

当前目标只有一个：
把这个 Roblox 项目的结构、脚本、Remote、素材、动画音效和关键源码导出成 Codex 可读资料。

请先不要分析玩法，不要改游戏代码，不要重构。

请你先自动完成：
1. 判断工作流文件夹在哪里，不能依赖文件夹名称。
2. 判断当前工作目录是否其实是工作流目录；如果是，优先把父目录当项目根目录候选。
3. 运行 Bootstrap_RobloxProjectAuditWorkspace.ps1。
4. 创建 Project_Analysis_Package/。
5. 创建所有空的 Audit_*.md 和分析输出 md。
6. 把通用 RobloxStudio_*.luau 导出脚本复制到项目根目录的 Tools/。
7. 创建并维护 Project_Analysis_Package/STATUS.md，告诉我当前阶段、完成标准、下一步。

完成后，请明确告诉我：
1. 你已经创建了哪些文件。
2. 我现在需要在 Roblox Studio 里运行哪个脚本。
3. 我应该把 Output 全部粘贴到哪个 md 文件。
4. 这一轮导出的完成标准是什么，比如是否必须看到 ## End。
```

如果工作流没有复制到项目根目录，而是在别的位置，再补充：

```text
工作流路径：<工作流文件夹路径>
```
