---
type: project
domain: roblox
status: processing
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# AreaAbility 二段跳与区域解锁

## 一句话说明

`011_DoubleJumpAbility` 和 `013_AreaUnlockGate` 管理区域能力与区域门：玩家发条重启后在当前区域获得二段跳，用它到达 Boss 高台，Boss 首通后打开下一区域入口。

## 当前状态

当前状态：`Planned / schema reserved / runtime not implemented`。

当前代码事实：

- `DataSchema` 已有 `AreaAbilities.SecondJumpUnlocked`。
- `DataSchema` 已有 `AreaUnlocks.UnlockedAreaIds.Starter = true`。
- GDD v2.4 的目标字段写法是 `AreaAbilities.ToyboxWorkshop_DoubleJump` 和 `AreaUnlocks.ToyboxWorkshop_NextGate`。
- 尚未定位到 `AreaAbilityService`、`AreaAbility.GetState` 或区域门 runtime 实现。

正式实现前需要统一字段命名：是用通用 `SecondJumpUnlocked`，还是用区域化 `ToyboxWorkshop_DoubleJump`。

## 二段跳目标链路

```text
RebootBench 成功
-> Server 写入 AreaAbilities 当前区域二段跳状态
-> Client 调用 AreaAbility.GetState 或收到能力快照
-> 二段跳图标亮起
-> 本地启用二段跳手感和 VFX
-> 玩家到达 Boss 高台
-> Boss.Start 前 Server 再校验能力和区域状态
```

## 区域入口目标链路

```text
Boss 首通成功
-> Server 发放 ClockworkCore
-> Server 写入 AreaUnlocks.ToyboxWorkshop_NextGate
-> AreaGatePrompt 显示入口已开启
-> NextAreaPreview 展示后续内容
-> Demo 第一版不进入正式第二区域
```

## Server / Client 分工

| 层 | 职责 |
|---|---|
| Server | 判断能力是否已解锁，Boss.Start 前校验区域状态，写入区域门状态 |
| Client | 处理二段跳手感、VFX、能力图标、入口提示 |
| UI | `DoubleJumpUnlockToast`、`AreaGatePrompt`、`NextAreaPreview` |
| Data | `AreaAbilities`、`AreaUnlocks` |

Client 可以做跳跃手感，但不能决定自己是否已经解锁能力，也不能绕过 Boss 入口条件。

## 不做事项

| 不做项 | 后续归属 |
|---|---|
| 发条重启条件和永久点 | [[RebootBench 与 PermanentStats 长期成长]] |
| Boss 战斗和首通奖励 | [[BossEncounter 与 BossRewardUI]] |
| 正式第二区域内容 | 后续区域 Feature |
| 全局二段跳 | 当前区域能力切片之外 |

## 验收口径

- 未解锁时不能到达 Boss 高台，或不能开始 Boss。
- 解锁后可到达 14 studs 高台。
- 死亡后当前区域二段跳仍可用。
- 离开当前区域后不能变成全局二段跳。
- Boss 首通前下一区域入口关闭。
- Boss 首通后当前 session 内入口打开。

## 来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_PLAN_GDD_v2_4.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\05_ProgressionAreaAbility.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\gdd-assessments\ToyboxGuardiansDemo_GDD_ASSESSMENT.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ReplicatedStorage\Game\Shared\Config\DataSchema.lua`

## 相关链接

- [[RebootBench 与 PermanentStats 长期成长]]
- [[BossEncounter 与 BossRewardUI]]
- [[ProfileStore 持久化边界]]
- [[DataService 与 DataSchema 边界]]
- [[PlayerHUD 玩家 HUD]]
