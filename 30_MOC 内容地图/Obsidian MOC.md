---
type: moc
status: evergreen
source: self
tags:
  - type/moc
  - status/evergreen
created: 2026-05-12
updated: 2026-08-26
---

# Obsidian MOC


这篇笔记是 Obsidian 主题的内容地图，用来集中放入口、规则、资料和我自己的整理方法。

一句话原则：

```text
文件夹负责位置，属性负责状态，双向链接负责关系，MOC 负责入口。
```

---

## 快速入口

- [[笔记导览]]
- [[70_LLM_Wiki 知识库/index|LLM Wiki 知识库总入口]]
- [[70_LLM_Wiki 知识库/Vault/Git 远端同步前审计与资产边界|Git 远端同步前审计与资产边界]]

---

## 入门基础

适合先建立整体认识，再开始动手配置。

- [[笔记导览]]：整个仓库的使用说明，定义文件夹、属性、链接、MOC 的职责分工
- 

---

## 核心概念

这些概念决定这个库以后会不会越记越乱。

- Obsidian：本地 Markdown 笔记库，而不是封闭平台
- MOC：主题入口页，用来集中挂载相关笔记
- 双向链接：用链接表达知识关系，而不是把主题全塞进标签
- Markdown：Obsidian 笔记的底层格式
- `type / status / source`：每篇笔记顶部的最小属性
- `00_Inbox / 10_Projects / 20_Areas / 30_MOC / 40_Resources / 50_Notes / 60_Templates / 90_Archive / Assets`：当前仓库的一级结构

---

## 常用方法

这些是可以重复执行的固定动作。

- 新笔记最小流程：先写下来，放进大概正确的文件夹，补 `type / status / source`，加 1-3 个双向链接，再决定要不要挂到 MOC
- 资料笔记处理流程：先进 `00_Inbox` 或 `40_Resources`，整理后再挂到对应 MOC
- 挂到 MOC：不是移动文件，只是在主题入口页里增加链接
- 每周整理一次 `00_Inbox 收集箱`
- 每周回看一次常用 MOC，把最近重要笔记补进去

相关笔记：

- [[笔记导览]]
- 

---

## 同步与附件

这部分是 Obsidian 工作流里最容易反复用到的操作。

- Obsidian：记录了 `.gitignore`、Git 云同步、附件位置、Pandoc、代理配置
- [[70_LLM_Wiki 知识库/Vault/Git 远端同步前审计与资产边界|Git 远端同步前审计与资产边界]]：记录当前远端缺失、大文件历史和上传前门禁

重点规则：

```text
1. 用 Git 做同步和备份
2. 忽略 .obsidian/workspace.json 和 .obsidian/workspace-mobile.json
3. 附件统一放到 Assets 或按笔记名分子目录
4. 图片链接尽量使用标准 Markdown 相对路径
```

---

## AI 工作流

Obsidian 适合和本地 AI 工具配合，因为笔记本质上就是 Markdown 文件。

- Obsidian

适合交给 AI 做的事：

- 批量整理 Inbox
- 统一属性和命名
- 把资料笔记提炼成永久笔记
- 根据已有笔记补 MOC 和双向链接

---

## 外部资料

主要是别人产出的内容，先作为资料吸收，再决定要不要沉淀成永久笔记。

- Obsidian
- [Obsidian 官方帮助中文文档](https://publish.obsidian.md/help-zh/%E7%94%B1%E6%AD%A4%E5%BC%80%E5%A7%8B)
- [[40_Resources 资料/Obsidian/Obsidian 初始配置与免费同步 YouTube|Obsidian 初始配置与免费同步 YouTube]]
- [[40_Resources 资料/Obsidian/Obsidian Git 同步与 AI 笔记工作流（豆包总结）|Obsidian Git 同步与 AI 笔记工作流（豆包总结）]]

---

## 我的总结

已经更接近我自己的长期规则，而不是单次教程摘录。

- [[笔记导览]]
- Obsidian

---

## 问题与解决

目前已经明确的高频问题点：

- Git 同步冲突：多端不要同时编辑同一篇笔记
- 工作区文件冲突：忽略 `.obsidian/workspace.json` 和 `.obsidian/workspace-mobile.json`
- 图片预览不统一：关闭 Wiki Links，尽量改成标准 Markdown 相对路径
- 移动端同步限制：移动端优先使用 HTTPS，而不是 SSH
- 网络问题：需要时配置 Git 代理

相关入口：

- Obsidian

---

## 待整理

- [x] 后续新增的 Obsidian 资料统一挂到这个 MOC
- [ ] 把 `Obsidian` 里的配置内容继续整理成更稳定的长期笔记
- [ ] 定期回看 `[[笔记导览]]`，确保新笔记仍按这套结构在放

---

## 相关 MOC

- 暂无
