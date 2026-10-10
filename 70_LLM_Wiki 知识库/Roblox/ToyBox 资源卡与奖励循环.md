---
type: concept
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# ToyBox 资源卡与奖励循环

## 一句话说明

ToyBox 的资源系统服务于“打怪捡零件 -> 拼装发条玩具 -> 玩具进入长期用途”的循环；资源不是单纯货币，而是拼装台的输入材料和玩家长期目标的载体。

## 当前资源卡

| 资源 | 当前用途 | 当前来源 / 状态 |
|---|---|---|
| `SmallGear` | 动力槽材料，002 训练怪掉落，FirstLoop 教学资源 | `M001 -> SmallGear x1` |
| `WoodBody` | 身体槽材料，第一次拼装的核心材料之一 | `M002 -> WoodBody x1`，006 已验收 |
| `BubbleCore` | 核心槽材料，第一次拼装泡泡小兵倾向 | `M003 -> BubbleCore x1`，006 已验收 |
| `Spring` | 后续速度 / 弹簧类倾向材料 | HUD 已预留并置灰 |
| `MagnetSheet` | 后续磁力 / 吸取类倾向材料 | HUD 已预留并置灰 |
| `ClockworkCore` | 后续高价值发条核心 / Boss 材料 | HUD 已预留并置灰 |
| `ToyFragments` | 重复玩具转碎片、升星或合成输入 | HUD 已预留并置灰 |

## 当前实现链路

```text
CombatService 判定敌人死亡
-> TrainingEnemyService 更新敌人状态
-> LootDropService 按 enemyId 查 LootTableConfig
-> DataService.UpdateProfile 写入 Resources / Progression
-> Server 发送 Progression.ExpGranted
-> Server 发送 Loot.PrivateDropPicked
-> LootDropController / PlayerHUDController 接收
-> RewardFeedback 显示 +Exp / +Resource
-> PlayerHUDPresentation 刷新资源数字
```

## 当前掉落表口径

| 来源 | 奖励 |
|---|---|
| `M001` | `SmallGear x1`，`Exp +4` |
| `M002` | `WoodBody x1`，`Exp +4` |
| `M003` | `BubbleCore x1`，`Exp +5` |

当前 `M002 / M003` 的目标不是做新战斗系统，而是让拼装台前的材料资源在 HUD 中可见增长。

## 资源显示口径

`HUDConfig.ResourceOrder` 当前顺序：

```text
SmallGear
WoodBody
BubbleCore
Spring
MagnetSheet
ClockworkCore
ToyFragments
```

首轮 HUD 规则：

- `SmallGear / WoodBody / BubbleCore` 正常显示。
- `Spring / MagnetSheet / ClockworkCore / ToyFragments` 置灰锁定。
- 所有数字来自 `Resource.GetSnapshot` 或 Server 事件 payload。
- Client 不自行计算资源增减。

## 奖励反馈拆分

| 奖励 | 触发时机 | 表现 |
|---|---|---|
| Exp | 击杀结算后，Server 写入 `Progression.Exp` | `Progression.ExpGranted`，显示 `+4 Exp` 或 `+5 Exp` |
| Resource | 拾取成功后，Server 写入 `Resources.<ResourceId>` | `Loot.PrivateDropPicked`，显示 `+1 SmallGear / WoodBody / BubbleCore` |

这个拆分避免用拾取事件承担经验反馈，也避免 Client 从总经验反推本次经验增量。

## 设计原则

- 资源必须服务拼装台，不要只做成金币。
- 新手前三种资源要直接支持第一次拼装。
- 后四种资源可以预留，但首轮不要抢玩家注意力。
- 掉落物要可识别，不能只有日志或抽象球。
- 资源变化要同时满足“Server 可信”和“玩家看得见”。
- 低品质或重复玩具不能变成废物，后续通过碎片、升星、收藏承接。

## 不做事项

| 不做项 | 后续归属 |
|---|---|
| 拼装计算和玩具结果 | [[发条拼装台 UI]] / ToyAssembly |
| 完整 ToyInventory | ToyInventory Feature |
| 重复转碎片和升星 | ToyFragments / Upgrade / Star 系统 |
| Boss 材料掉落 | [[BossEncounter 与 BossRewardUI]] / [[EliteEnemies 与 RareMaterials 稀有材料]] |
| ProfileStore 持久化 | Persistence Feature |
| Tarmac 批量资产管线 | 素材规模扩大后再评估 |

## 来源

- [[../../10_Projects 项目/Roblox/玩具/玩具箱守卫者_发条拼装核心特色策划方案]]
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\006_BasicMaterialEnemies.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\tdd\006_BasicMaterialEnemies_TDD.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\003_PlayerHUD_玩家HUD.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ReplicatedStorage\Game\Shared\Config\HUDConfig.lua`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ReplicatedStorage\Game\Shared\Config\LootTableConfig.lua`

## 相关链接

- [[CombatTrainingEnemy 训练怪玩法闭环]]
- [[PlayerHUD 玩家 HUD]]
- [[发条拼装台 UI]]
- [[DataService 与 DataSchema 边界]]
