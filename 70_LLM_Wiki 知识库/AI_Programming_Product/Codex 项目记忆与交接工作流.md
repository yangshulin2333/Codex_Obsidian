---
type: workflow
domain: ai-programming-product
status: evergreen
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# Codex 项目记忆与交接工作流

## 一句话说明

Codex 长期项目的核心不是让聊天记录保存全部历史，而是把项目真相写进项目文件：规则、状态、下一步、验证方法和重要决策。

## 核心原则

```text
不要把项目真相放在聊天记录里，要放在项目文件里。
```

聊天适合推进当前任务；项目文件负责保存可交接、可验证、可延续的事实。

## 最小文件组合

| 文件 | 用途 |
|---|---|
| `README.md` | 给人看的项目说明：项目是什么、怎么运行、主要目录 |
| `AGENTS.md` | 给 Codex 的项目规则：先读什么、能改什么、测试命令、禁止事项 |
| `CURRENT_STATE.md` | 当前已验证状态、最近改动、未验证内容、当前风险 |
| `NEXT_STEPS.md` | 最近 3-5 个下一步，按 P0 / P1 / P2 排序 |

复杂项目再加：

| 文件 | 用途 |
|---|---|
| `TESTING.md` | 自动测试、手动验证、通过标准、常见失败 |
| `DECISIONS.md` | 重要架构/产品决策，不反复讨论同一问题 |

## 新项目第一轮

不要一上来让 Codex 写代码。第一轮先做项目地图：

```text
1. 这个项目是什么
2. 主要目录分别干什么
3. 哪些文件是入口
4. 哪些文件是核心逻辑
5. 如何运行 / 构建 / 测试
6. 当前最大的风险是什么
7. 下一步最小安全动作是什么
```

然后再创建或补齐 `README.md`、`AGENTS.md`、`CURRENT_STATE.md`、`NEXT_STEPS.md`。

## 每个功能的推进顺序

```text
1. 明确本轮目标
2. 明确不做什么
3. 找到要改的文件
4. 小范围实现
5. 运行测试
6. 修复问题
7. 更新 CURRENT_STATE.md
8. 更新 NEXT_STEPS.md
9. 必要时更新 TESTING.md / DECISIONS.md
```

每轮只做一个清楚的功能。不要一轮里同时重构、加功能、改 UI、改数据结构。

## 新对话接手提示词

```text
请接手这个项目，但先不要改代码。

请先读取：
1. README.md
2. AGENTS.md
3. CURRENT_STATE.md
4. NEXT_STEPS.md
5. TESTING.md，如果存在
6. DECISIONS.md，如果存在
7. 当前 git status / git diff，如果项目使用 Git

然后先回答：
1. 当前项目做到哪了？
2. 当前已验证的基线是什么？
3. 当前有没有未验证改动？
4. 下一步最小安全动作是什么？
5. 哪些文件或系统边界不能碰？

等我确认后，再开始实现。
```

## 什么时候换新对话

适合换新对话：

- 一个功能已经完成。
- 测试结果已经记录。
- `CURRENT_STATE.md` 已更新。
- `NEXT_STEPS.md` 已更新。
- 下一轮是新功能。

不适合换新对话：

- 功能做到一半。
- bug 还没修完。
- 测试失败原因还在排查。
- 刚发了截图或报错，还没处理完。

## 来源

- `20_Areas 领域/AI/Codex/通用Codex新项目工作流_Obsidian版.md`
- `20_Areas 领域/AI/Codex/项目工作流.md`

## 相关链接

- [[Codex 工具能力与使用边界]]
- [[Feature Pack 与 Feature Card]]
- [[Roblox 项目接手工作流]]
- [[AI 工具卡模板]]
