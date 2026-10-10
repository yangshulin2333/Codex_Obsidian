---
type: project
domain: roblox
status: processing
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# EliteEnemies 与 RareMaterials 稀有材料

## 一句话说明

`009_EliteEnemiesAndRareMaterials` 是普通材料怪之后的材料经济扩展：用精英怪提供 `Spring`、`MagnetSheet`、`ToyFragments` 等更高价值材料。

## 当前状态

当前状态：`Planned / existing enemy foundation / runtime not implemented`。

当前代码已有训练怪基础：

- `TrainingEnemyService` 能按 `EnemyConfig` 生成敌人。
- `ApplyDamage` 能扣血、设置 `Dead` 状态，并按 `RespawnSeconds` 刷新。
- `EnemyHealthBillboard` 能显示敌人血条。

但没有定位到正式 `EliteEnemies`、精英怪 AI、稀有材料掉落资格或多人奖励资格 runtime 实现。

## 目标链路

```text
玩家进入精英怪区域
-> Monster spawn 生成精英怪
-> 精英怪执行 Idle / Chase / Attack / Return / Dead
-> 玩家参与战斗
-> Server 判定伤害、死亡、奖励资格
-> 生成私有掉落物
-> 掉落 Spring / MagnetSheet / ToyFragments
-> DataService 写入 Resources 和 Progression.Exp
-> HUD / RewardFeedback 刷新
```

## 稀有材料定位

| 资源 | 用途 |
|---|---|
| `Spring` | 后续拼装材料 / 弹簧主题玩具来源 |
| `MagnetSheet` | 后续拼装材料 / 磁铁主题玩具来源 |
| `ToyFragments` | 重复玩具转化、升星和合成输入 |
| `BubbleCore` | 可扩展为高价值来源，但基础来源已在材料怪中验证 |

## 精英怪系统范围

| 内容 | 首轮规则 |
|---|---|
| Spawn | 明确区域、实例 ID、刷新规则 |
| AI | `Idle`、`Chase`、`Attack`、`Return`、`Dead` |
| 掉落 | 私有掉落物，避免玩家互抢 |
| 资格 | 多人同怪时由 Server 判定奖励资格 |
| 过期 | 掉落物超时消失 |
| HUD | 资源快照和奖励反馈沿用现有链路 |

## Server 必须判定

- 怪物不会跨区追击玩家。
- 精英怪奖励不由 Client 决定。
- 掉落资格不由 Client 决定。
- 掉落物过期后消失。
- 多人同怪时奖励资格由 Server 判定。

## 不做事项

| 不做项 | 后续归属 |
|---|---|
| Boss 首通核心奖励 | [[BossEncounter 与 BossRewardUI]] |
| 完整 Toy AI | 玩具上阵表现 Feature |
| 真实持久化 | [[ProfileStore 持久化边界]] |
| 正式第二区域 | 后续区域 Feature |

## 验收口径

- 精英怪不会追出自己的区域。
- 精英怪死亡后掉落由 Server 决定。
- `Spring / MagnetSheet / ToyFragments` 写入 `DataService`。
- 掉落物过期后消失。
- 多人参与时奖励资格可解释、可复测。

## 来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_PLAN_GDD_v2_4.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_TODO.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\gdd-assessments\ToyboxGuardiansDemo_GDD_ASSESSMENT.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ServerScriptService\Server\Game\Services\TrainingEnemyService.lua`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ServerScriptService\Server\Game\Presentation\EnemyHealthBillboard.lua`

## 相关链接

- [[BasicMaterialEnemies 基础材料怪]]
- [[ToyBox 资源卡与奖励循环]]
- [[BossEncounter 与 BossRewardUI]]
- [[DataService 与 DataSchema 边界]]
- [[PlayerHUD 玩家 HUD]]
