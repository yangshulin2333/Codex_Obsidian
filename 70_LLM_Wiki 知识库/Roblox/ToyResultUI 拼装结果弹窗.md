---
type: project
domain: roblox
status: processing
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# ToyResultUI 拼装结果弹窗

## 一句话说明

`ToyResultUI` 是第一次拼装后的奖励确认界面：它要让玩家立刻看懂“我获得了什么玩具、它能做什么、下一步应该上阵”。

## 当前状态

当前状态：`Design / P0 UI requirement / runtime pending`。

它属于第一次拼装完成率的 P0 UI 素材，但当前 runtime 没有定位到正式 `ToyResultGui` 或 `ToyResultUI` 控制逻辑。Wiki 只沉淀交互目标、字段和验收口径。

## 出现时机

```text
ToyAssembly.Assemble 成功
-> Server 返回 toyId / quality / star / effect / resources / toys
-> Client 刷新本地 UI 快照
-> 打开 ToyResultUI
-> 玩家点击上阵或关闭
-> UI 不遮挡泡泡小兵第一次攻击太久
```

失败时不能打开成功弹窗，也不能播放成功动画。

## 首轮字段

| 字段 | 首轮口径 |
|---|---|
| `ToyName` | 泡泡小兵 |
| `Quality` | 第一次教学拼装可固定良好 |
| `Star` | 默认 1 星 |
| `Effect` | 短句，例如“发射泡泡，减速怪物” |
| `ToyPreviewViewport` | 显示 T001 模型或清楚的占位模型 |
| `DeployButton` | 主按钮，文案“上阵” |
| `EquipButton` | 次按钮，未开放时隐藏或置灰 |

## UX 原则

- 弹窗要强化“获得新东西”的反馈。
- 不能遮挡玩具喷出和第一次攻击太久。
- 主按钮只做一个明确下一步，首轮优先“上阵”。
- 展示文案要短，避免长规则说明。
- 所有结果字段来自 Server 返回，不由 Client 猜测。

## 与上阵/装备的关系

| 动作 | 当前归属 |
|---|---|
| `DeployButton` 上阵 | 后续 `ToyLoadout.Deploy`，完整 008 范围 |
| `EquipButton` 装备 | [[EquipmentService 玩具装备服务]] 已有最小 Server 切片，但 UI 未实现 |
| 重复转碎片提示 | [[ToyInventory 与 ToyListUI 玩具库存]] |
| 玩具预览 | 资产和 UI 模板切片 |

`ToyResultUI` 本身不直接决定玩家是否拥有玩具；拥有状态必须由 `AssemblyBench` 的 Server 成功结果写入。

## 资产要求

| 资产 | 要求 |
|---|---|
| 玩具头像 | 建议 512 x 512，和 ToyListUI 复用 |
| 奖励弹窗背景 | 可用 1024 x 768 做风格参考，Roblox 内可切片 |
| `ToyPreviewViewport` | 只用于关键预览，不做大规模列表渲染 |
| T001 模型/图标 | 与场景跟随外观保持一致 |
| 成功音效/VFX | 短反馈，不做长时间全屏特效 |

## 验收口径

- 玩家一眼知道拼出了什么。
- 玩家知道它能帮自己做什么。
- 玩家知道下一步应该上阵或继续战斗。
- 弹窗不会盖住核心场景太久。
- 失败路径不会显示成功奖励。
- 移动端主按钮触控区域足够清楚。

## 来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\SCREEN_LIST.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\UX_SPEC.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\UI_ASSET_WORKFLOW.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\art\ASSET_REQUIREMENTS.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_PLAN_GDD_v2_4.md`

## 相关链接

- [[AssemblyBench 第一次拼装闭环]]
- [[发条拼装台 UI]]
- [[ToyInventory 与 ToyListUI 玩具库存]]
- [[EquipmentService 玩具装备服务]]
- [[PlayerHUD 玩家 HUD]]
