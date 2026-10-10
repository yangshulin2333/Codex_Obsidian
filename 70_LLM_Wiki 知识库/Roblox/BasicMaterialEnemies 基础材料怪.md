---
type: project
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# BasicMaterialEnemies 基础材料怪

## 一句话说明

`006_BasicMaterialEnemies` 把 `M002 / M003` 接入已有战斗、经验、掉落和 HUD 链路，让玩家在拼装台前能稳定获得 `WoodBody` 与 `BubbleCore`。

## 当前状态

当前状态：`Accepted / Studio Play verified`。

这个 Feature 已完成 Studio Play 验收，可作为拼装台前置材料来源的稳定事实。

## 玩家链路

```text
玩家击败 M002 / M003
-> CombatService 判定死亡
-> TrainingEnemyService 更新敌人状态
-> LootDropService 按 enemyId 查 LootTableConfig
-> DataService 写入 Resources.WoodBody / BubbleCore
-> Progression.ExpGranted 继续发经验
-> Loot.PrivateDropPicked 发送资源拾取事件
-> HUD 显示 WoodBody / BubbleCore 增长
```

## 本卡目标

| 敌人 | 掉落 | 经验 |
|---|---|---|
| `M002` | `WoodBody x1` | `Exp +4` |
| `M003` | `BubbleCore x1` | `Exp +5` |

它不是新战斗系统，也不是拼装台实现；它只让基础材料进入已经验证过的掉落与 HUD 链路。

## 关键模块

| 模块 | 职责 |
|---|---|
| `EnemyConfig.lua` | 配置 / 识别 `M002`、`M003` |
| `LootTableConfig.lua` | 增加 `M002 -> WoodBody`、`M003 -> BubbleCore` |
| `LootDropService.lua` | 按 enemyId 解析掉落并写资源 |
| `ResourceConfig.lua` | 确保 `WoodBody / BubbleCore` 有容量和默认口径 |
| `LootDropController.lua` | 接收拾取事件，不计算资源 |
| `PlayerHUDPresentation.lua` | 显示资源变化 |

## 边界

Server 负责：

- 敌人死亡上下文。
- 掉落表解析。
- 资源写入。
- 经验结算。
- 私有掉落事件。

Client 负责：

- 展示掉落结果。
- 刷新 HUD。
- 不决定掉落资源、不决定经验、不写数据。

## 为什么重要

`CombatTrainingEnemy` 只验证了 `SmallGear`；`BasicMaterialEnemies` 让第一次拼装需要的 `WoodBody` 和 `BubbleCore` 也进入可见循环：

```text
打怪
-> 捡 SmallGear / WoodBody / BubbleCore
-> HUD 看见材料增长
-> 进入发条拼装台
```

## 不做事项

| 不做项 | 后续归属 |
|---|---|
| 强化台 | [[UpgradeBench 强化台闭环]] |
| 拼装台 | [[发条拼装台 UI]] |
| ToyInventory | 后续 ToyInventory Feature |
| EliteEnemies / Boss | [[EliteEnemies 与 RareMaterials 稀有材料]] 和 [[BossEncounter 与 BossRewardUI]] |
| 新 UI / 新 VFX / 新模型素材 | 后续素材小闭环 |
| 改 005 升级公式 | 不在本卡内 |

## 来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\006_BasicMaterialEnemies.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\tdd\006_BasicMaterialEnemies_TDD.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ReplicatedStorage\Game\Shared\Config\LootTableConfig.lua`

## 相关链接

- [[ToyBox 资源卡与奖励循环]]
- [[CombatTrainingEnemy 训练怪玩法闭环]]
- [[PlayerHUD 玩家 HUD]]
- [[发条拼装台 UI]]
