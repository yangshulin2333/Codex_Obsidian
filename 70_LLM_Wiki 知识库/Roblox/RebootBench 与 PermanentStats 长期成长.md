---
type: project
domain: roblox
status: processing
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# RebootBench 与 PermanentStats 长期成长

## 一句话说明

`010_RebootBench` 是 ToyBox 的长期成长入口：玩家达到条件后进行发条重启，等级和经验回到起点，但获得永久属性点，并解锁当前区域能力。

## 当前状态

当前状态：`Planned / schema partially reserved / runtime not implemented`。

当前代码事实：

- `DataSchema` 已有 `Progression.RegionRebootDone`。
- `DataSchema` 已有 `PermanentStats.Unspent / Attack / Health / ToyMultiplier`。
- `ProgressionConfig.GetMaxHealth` 已读取 `PermanentStats.Health`。
- `ProgressionConfig.CalculatePowerScore` 已读取 `PermanentStats.Attack` 和 `PermanentStats.ToyMultiplier`。
- 尚未定位到 `Progression.Reboot` 或 `Progression.AssignPoint` runtime 实现。

## 目标链路

```text
玩家达到 Level 20 / UpgradeLevel 5 / PowerScore 100 / 拥有玩具
-> 靠近 RebootBench
-> 打开 RebootBenchUI
-> Server 校验重启条件
-> Progression.Level = 1
-> Progression.Exp = 0
-> PermanentStats.Unspent 增加 20
-> Progression.RegionRebootDone = true
-> 解锁当前区域二段跳能力
-> UI 展示属性点和能力解锁
```

## 重启条件

| 条件 | 说明 |
|---|---|
| `Level = 20` | 到达等级上限 |
| `UpgradeLevel = 5` | 强化台达到首轮上限 |
| `PowerScore >= 100` | 综合战力达到门槛 |
| 至少拥有 1 个玩具 | 证明玩家完成拼装主闭环 |
| `TutorialCompleted = true` | 防止跳过新手主线 |

## 数据写入

| 字段 | 规则 |
|---|---|
| `Progression.Level` | 成功后回到 1 |
| `Progression.Exp` | 成功后回到 0 |
| `Progression.RegionRebootDone` | 标记当前区域已重启 |
| `PermanentStats.Unspent` | 成功后增加 20 |
| `PermanentStats.Attack` | 后续属性点分配目标 |
| `PermanentStats.Health` | 后续属性点分配目标 |
| `PermanentStats.ToyMultiplier` | 后续属性点分配目标 |
| `AreaAbilities` | 解锁当前区域能力 |

玩具、资源、收藏和 `ClockworkCore` 这类长期资产不应该在重启时丢失。

## Server / Client 边界

Server 负责：

- 判断是否满足重启条件。
- 决定永久点数量。
- 重置 Level / Exp。
- 写入 `PermanentStats`。
- 解锁区域能力。
- 返回可信 progression 快照。

Client 负责：

- 展示条件列表。
- 展示未满足项。
- 展示成功后的属性点和能力提示。
- 不直接发送最终等级、永久点数量或二段跳解锁状态。

## 旧文档字段差异

旧 `ProgressionAreaAbility` Feature Card 提到：

- `Progression.RebootCount`
- `Progression.PermanentPoints`
- `Progression.AssignedPoints`
- `AreaAbilities.ToyboxDevelopment.DoubleJump`

当前 `DataSchema` 已采用更集中的 `PermanentStats` 字段。正式实现前需要统一字段命名，避免同一概念在 `Progression` 和 `PermanentStats` 两边重复存储。

## 验收口径

- 条件不足时 UI 显示具体未满足项。
- 成功后 Level 回 1，Exp 回 0。
- 永久属性点增加 20。
- 已有玩具、资源、收藏、`ClockworkCore` 不丢。
- `PowerScore` 能体现已分配永久属性。
- 未实现真实 ProfileStore 前，只承诺当前 session 内数据一致。

## 来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_PLAN_GDD_v2_4.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\05_ProgressionAreaAbility.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_TODO.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ReplicatedStorage\Game\Shared\Config\DataSchema.lua`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ReplicatedStorage\Game\Shared\Config\ProgressionConfig.lua`

## 相关链接

- [[ExpLevelProgression 经验等级成长]]
- [[ProfileStore 持久化边界]]
- [[AreaAbility 二段跳与区域解锁]]
- [[BossEncounter 与 BossRewardUI]]
- [[DataService 与 DataSchema 边界]]
