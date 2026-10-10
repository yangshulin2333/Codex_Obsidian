---
type: concept
domain: vault
status: active
owner: mixed
source: self
created: 2026-06-26
updated: 2026-06-26
---

# LLM Wiki Schema

这个文件定义 Codex 整理本库时使用的最小规则。

## 页面类型

| type | 用途 |
|---|---|
| `index` | 领域总入口或系统入口 |
| `moc` | 人类阅读的主题地图 |
| `source` | 原始资料说明或资料索引 |
| `concept` | 长期概念、方法、知识点 |
| `project` | 项目经验、项目复盘、项目状态 |
| `workflow` | 可重复执行的流程、清单、脚本说明 |
| `decision` | 重要判断、选择、取舍和复盘 |
| `resource-card` | GitHub 仓库、工具、网站、课程、资料卡 |
| `log` | 整理记录 |

## 领域值

| domain | 范围 |
|---|---|
| `roblox` | Roblox 开发、Rojo、Luau、UI、资产、项目经验 |
| `finance-life` | 个人理财、人生规划、决策记录、长期复盘 |
| `english` | 英语表达、词句积累、商务英语、写作模板 |
| `ai-programming-product` | AI 工具、编程、产品思路、Codex 工作流 |
| `github-resources` | GitHub 仓库、资源卡、工具收藏、长期资料 |
| `vault` | Obsidian 库自身的结构、规则和维护流程 |

## 状态值

| status | 含义 |
|---|---|
| `inbox` | 刚收进来，还没有整理 |
| `processing` | 已开始整理，但还不稳定 |
| `evergreen` | 已沉淀，可长期复用 |
| `active` | 正在使用或持续维护 |
| `archived` | 暂不维护，但保留 |

## 所有者

| owner | 含义 |
|---|---|
| `human` | 用户直接写作或判断为主 |
| `codex` | Codex 编译、索引、整理为主 |
| `mixed` | 用户和 Codex 共同维护 |

## 新页面模板

```markdown
---
type:
domain:
status:
owner:
source:
created:
updated:
---

# 标题

## 一句话说明

## 为什么重要

## 核心内容

## 来源

## 相关链接

## 待确认
```

## 整理规则

1. 优先整理入口和索引，再整理具体内容。
2. 不覆盖原始笔记，不删除附件。
3. 对项目经验，优先沉淀“可复用的方法”和“下次怎么做”。
4. 对资源链接，必须写明用途、适用场景、风险和关联项目。
5. 对理财、政策、工具价格、法律、税务、账户、汇率等内容，必须标记时间敏感。
6. 每次非 trivial 整理都更新 [[log]]。

## 文件命名建议

- 使用中文标题时，保持清楚、短、可搜索。
- 同一个概念不要重复建多个入口。
- GitHub 仓库资源卡建议使用：`owner_repo.md`。
- 工作流建议使用：`动作对象_工作流.md`。
- 决策记录建议使用：`YYYY-MM-DD_决策主题.md`。

