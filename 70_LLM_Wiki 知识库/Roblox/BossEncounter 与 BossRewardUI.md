---
type: project
domain: roblox
status: processing
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# BossEncounter 与 BossRewardUI

## 一句话说明

`012_BossEncounter` 是 ToyBox 第一阶段的中期目标：玩家用区域能力到达 Boss 区，Server 判定 Boss 战斗、首通奖励和下一区域入口解锁。

## 当前状态

当前状态：`Planned / runtime not implemented`。

当前没有定位到正式 Boss Service、Boss Controller、`Boss.Start`、`Boss.GetState` 或 Boss reward state runtime 实现。现阶段只沉淀 GDD 目标、Server 边界、奖励数据和 UI 验收。

## 目标链路

```text
玩家完成 RebootBench
-> 当前区域二段跳解锁
-> 玩家到达 Boss 高台
-> Client 请求 Boss.Start
-> Server 校验入口范围 / 区域状态 / 参与资格
-> Boss 战开始
-> Boss 有血条、阶段、技能预警
-> 伤害和奖励由 Server 判定
-> 首通发 ClockworkCore
-> Server 打开下一区域入口
-> BossRewardUI 区分首通和重复挑战奖励
```

## 运行态合同待补

正式实现前需要先补 Boss 运行态合同：

- Boss 实例 ID。
- Phase / 阶段状态。
- Participants / 参与者。
- CanRetryAt / 重试冷却。
- RewardState / 首通与重复奖励状态。
- Boss 状态同步频率。
- 死亡、复活和退出 Boss 区规则。

这部分不能靠 UI 猜测，必须由 Server 状态驱动。

## Remote 与数据

| 类型 | 内容 |
|---|---|
| Remote | `Boss.Start`、`Boss.GetState` |
| Combat | `Combat.Attack` 可复用或扩展到 Boss |
| Resources | `ClockworkCore`、`SmallGear`、`ToyFragments` |
| Progression | `Exp` |
| AreaUnlocks | `ToyboxWorkshop_NextGate` |
| Reward | Boss reward state，区分首通和重复挑战 |

## UI / 表现

| UI / 资产 | 用途 |
|---|---|
| `BossHealthBar` | 展示 Boss 血量和阶段 |
| `BossWarningTelegraph` | 技能预警 |
| `BossRewardUI` | 首通 / 重复奖励 |
| `RespawnFrame` | [[DeathRespawn 资源保留 UI]] |
| Boss 模型 | `TBG_Boss_B001_OldToyGuardian_Model` |
| Boss VFX / Music | 技能表现和战斗气氛 |

`BossRewardUI` 是 P2 UI，不应该抢占第一次拼装和 P0 UI 的制作优先级。

## Server 必须判定

- `Boss.Start` 只能在入口范围内触发。
- 未解锁区域能力或区域门时不能开始 Boss。
- Boss 伤害、死亡、奖励都由 Server 决定。
- 首通只发 1 次 `ClockworkCore`。
- 重复挑战发重复奖励，不再发首通核心。
- 玩家死亡后资源和玩具不丢。

## 验收口径

- Boss 有清楚血条、阶段和技能预警。
- Boss.Start 不能远程随便触发。
- 玩家死亡后 3 秒复活。
- 首通奖励与重复奖励区分清楚。
- 首通后下一区域入口打开。
- 未击败 Boss 时下一区域入口关闭。

## 来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_PLAN_GDD_v2_4.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_TODO.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\SCREEN_LIST.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\gdd-assessments\ToyboxGuardiansDemo_GDD_ASSESSMENT.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\art\ASSET_REQUIREMENTS.md`

## 相关链接

- [[AreaAbility 二段跳与区域解锁]]
- [[RebootBench 与 PermanentStats 长期成长]]
- [[DeathRespawn 资源保留 UI]]
- [[ToyBox 资产需求与风格规范]]
- [[ToyBox 资源卡与奖励循环]]
- [[PlayerHUD 玩家 HUD]]
- [[ProfileStore 持久化边界]]
