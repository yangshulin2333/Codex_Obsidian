---
type: workflow
domain: roblox
status: active
owner: mixed
source: codex
created: 2026-07-13
updated: 2026-07-14
---

# 工作流注册表

## 主路径

| Workflow | Trigger | Actor | Evidence |
|---|---|---|---|
| 源图接入与资产锁 | 用户提供卡面 / 概念图 | Codex | `资产锁_ASSET_LOCK.md` |
| 低模正视图 | 资产锁完成 | 图像生成 + 用户 | approved front |
| 侧向可见性确认 | front 已确认、准备扩侧视 | 用户 + Codex | left/right 可见性合同 |
| 多视图扩展 | 侧向可见性已确认 | 图像生成 + 获授权时本地镜像 | Accepted 完整视图集 |
| 归一化与联系表 | Accepted 齐全 | Finalize 脚本 | report + manifest + `FILES_READY` |
| 联系表审批 | 用户确认联系表 | 用户 + Approve 脚本 | `CONTACT_SHEET_APPROVED` |
| 3D 反馈 | 上传混元 / Tripo 后 | 用户 + Codex | `3D_RESULT_REVIEWED` |

## 最小状态图

```text
INTAKE
  -> FRONT_CANDIDATE
  -> FRONT_APPROVED
  -> ASSET_LOCKED
  -> ACCEPTED_VIEWS_READY
  -> FILES_READY
  -> CONTACT_SHEET_APPROVED
  -> 3D_RESULT_REVIEWED
```

失败视图只回到 `VIEW_REJECTED -> REPAIR_ONLY_FAILED_VIEW`，不重做整套。

## 组件

| Component | File | 用途 |
|---|---|---|
| 快速执行入口 | `快速执行卡_QUICK_START.md` | 每次任务先读 |
| 主规格 | `README.md` | 目标、边界和目录 |
| 提示词 | `PROMPT_TEMPLATES.md` | 生图时按需读 |
| 运行模板 | `RUN_TEMPLATES.md` | 建立最小三文档 |
| 归一化合同 | `NORMALIZATION_CONTRACT.md` | 比例或背景问题时读 |
| 失败代码 | `FAILURE_CODES.md` | 失败恢复时读 |
| Finalize | `scripts/Finalize-PropMultiview.ps1` | 归一化、待审核目录、联系表 |
| Approve | `scripts/Approve-PropMultiview.ps1` | 人工审批后正式发布 |
| Tests | `tests/Test-PropMultiviewWorkflow.ps1` | 新旧文档兼容与发布门回归 |

## 人工 / 自动边界

| 环节 | 自动 | 人工 |
|---|---|---|
| 低模方案初稿 | Codex 写资产锁 | 用户通过正视图确认设计 |
| 侧向合同 | Codex 主动提问并复述 | 用户确认每个观察方向的显示 / 隐藏结构 |
| 多视图生成 | 独特视图生成、获授权图才镜像 | 联系表总审 |
| 比例与文件 | 脚本测量、归一化、清单 | 超过阈值时判断是否重生 |
| 正式发布 | Approve 脚本 | 用户明确批准联系表 |
| Roblox 尺度 | 字段检查 | 项目 / Studio 决定 Studs |

## Handoff Contracts

### 用户 -> Codex

- 输入：源图、用途、是否继续使用默认 Six。
- 输出：低模正视图候选和运行目录。
- 人工门：正视图未确认前不扩图。

### Codex -> 图像生成

- 输入：approved front、资产锁、当前视图。
- 约束：同一物品、同一低模复杂度、只改变水平旋转。
- 超时：45 秒内状态更新；90 秒无新结果报告 `GENERATION_STALLED`。

### Accepted -> Finalize

- 新运行文档：资产锁、运行状态、归一化配置。
- 旧运行兼容：完整 v1.2 资产简报 + 身份锁 + 结构锁。
- 成功：`FILES_READY`、联系表、报告和 SHA-256 清单。

### 用户确认 -> Approve

- 输入：`CONTACT_SHEET_APPROVED`。
- 成功：正式上传目录和人工审批记录。
- 失败：保留待审核目录，不留下半套正式文件。

## Workflow Check

- Missing gate：无；正视图、完整视图集、联系表和 3D 反馈仍保留。
- Removed redundancy：资产简报、身份锁、结构锁合并为资产锁；提示词日志改为可选。
- Handoff impact：下一对话只读快速执行卡、交接文档和当前资产锁。
