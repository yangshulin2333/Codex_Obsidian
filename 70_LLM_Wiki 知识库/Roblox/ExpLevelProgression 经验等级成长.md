---
type: project
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# ExpLevelProgression 经验等级成长

## 一句话说明

`005_ExpLevelProgression` 是 ToyBox 的成长中枢：玩家击败训练怪获得经验，Server 负责升级、封顶、PowerScore 重算，Client 只显示 Server 给出的结果。

## 当前状态

当前状态：`Accepted / Studio Play verified`。

这说明经验升级、Level 20 封顶、HUD 刷新和 `PowerScore` 派生已经通过 Studio Play 验收。

## 玩家链路

```text
玩家击败训练怪
-> Server 读取 LootTableConfig 的 Exp
-> LootDropService 调用 ProgressionConfig.ApplyExp
-> DataService:UpdateProfile 写入 Progression.Level / Exp / PowerScore
-> Server 发送 Progression.ExpGranted
-> PlayerHUDController 刷新 Level / Exp / PowerScore
-> RewardFeedbackController 显示 +Exp / Level Up
```

## 核心规则

| 项目 | 规则 |
|---|---|
| 等级范围 | `Level 1 -> Level 20` |
| 升级经验 | `12 + 当前 Level * 4` |
| 跨级 | 一次奖励可以循环升级多级 |
| Level 20 | `Exp = 0`，继续击杀不再累积经验 |
| PowerScore | 每次经验结算后由 Server 重算 |

## 关键模块

| 模块 | 职责 |
|---|---|
| `ProgressionConfig.lua` | Level 上限、ExpToNext、升级循环、PowerScore 计算 |
| `LootDropService.lua` | 击杀结算后调用 `ApplyExp` 并发送经验事件 |
| `ResourceService.lua` | `Resource.GetSnapshot` 返回 progression 快照 |
| `HUDConfig.lua` | HUD 的 `GetExpToNext` 委托给 `ProgressionConfig` |
| `PlayerHUDController.lua` | 用 Server payload 更新 HUD，不计算可信等级 |
| `RewardFeedbackController.lua` | 显示 `+Exp` 和 `Level Up` |

## PowerScore 结构

当前 `ProgressionConfig.CalculatePowerScore(data)` 已把多个长期成长来源放在同一公式中：

```text
最终攻击
+ floor(最大生命 / 10)
+ 当前装备玩具 ToyPower
+ 强化熟练度奖励
+ 收藏战力奖励
+ ToyMultiplier 属性点
```

这让 `005` 成为后续系统的汇合点：

- `004_UpgradeBench` 增加 `Upgrade.UpgradeLevel`。
- `008A_EquipmentService` 增加装备玩具贡献。
- 后续收藏系统增加 `Collection.CollectedToyIds` 贡献。
- 后续重启 / 属性点系统增加 `PermanentStats` 贡献。

## Server / Client 边界

Server 负责：

- 读取当前 Level / Exp。
- 奖励经验。
- 循环升级。
- Level 20 封顶。
- 重算 PowerScore。
- 发送可信 `Progression.ExpGranted`。

Client 负责：

- 展示 `+Exp`、`Level Up`。
- 刷新 HUD 里的 Level / Exp / PowerScore。
- 不写入 `Progression.Level`、`Progression.Exp` 或 `PowerScore`。

## 不做事项

| 不做项 | 后续归属 |
|---|---|
| 强化台交互 | [[UpgradeBench 强化台闭环]] |
| 玩具装备 / 玩具贡献 | [[EquipmentService 玩具装备服务]] |
| 拼装台产出玩具 | [[发条拼装台 UI]] |
| 发条重启 / 属性点 | [[RebootBench 与 PermanentStats 长期成长]] |
| Client 发起成长写入 | 不允许 |

## 来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\005_ExpLevelProgression.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\tdd\005_ExpLevelProgression_TDD.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ReplicatedStorage\Game\Shared\Config\ProgressionConfig.lua`

## 相关链接

- [[CombatTrainingEnemy 训练怪玩法闭环]]
- [[PlayerHUD 玩家 HUD]]
- [[ToyBox 资源卡与奖励循环]]
- [[UpgradeBench 强化台闭环]]
- [[EquipmentService 玩具装备服务]]
