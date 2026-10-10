---
type: project
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# CombatTrainingEnemy 训练怪玩法闭环

## 一句话说明

`CombatTrainingEnemy` 是 ToyBox 里第一个真正面向玩家的玩法闭环：玩家攻击训练怪，Server 判定伤害和死亡，生成私有掉落，玩家拾取后获得资源和经验，并在画面上看到反馈。

## 当前状态

- `002_CombatTrainingEnemy` 是父级 Feature Card，不再作为直接运行实现依据。
- `002A TrainingEnemyWorldStub` 已完成 Studio Play 验收。
- `002B CombatAttackAndDamage` 已完成 Studio Play 验收。
- `002C TrainingEnemyDropPickup` 技术实现已完成，但玩家可见质量由 `002.1` 补强组承接。
- `002.1A / 002.1B / 002.1C / 002.1D` 均已完成 Studio Play 验收。

## 玩家链路

```text
玩家看到 R15 训练积木兵
-> 玩家点击攻击
-> Client 只发送攻击意图
-> Server 校验距离、角度、冷却、目标存活
-> Server 扣训练怪血量
-> 训练怪死亡
-> Server 发放击杀 Exp
-> Server 生成玩家私有 SmallGear 掉落
-> 玩家靠近拾取
-> Server 写入 Resources.SmallGear
-> Client 显示血条、掉落、吸走和奖励反馈
```

## 拆分结构

| 切片 | 目标 | 验收重点 |
|---|---|---|
| `002A` | 场景中出现 R15 训练怪 | `Workspace/GameRuntime/Enemies/M001_TrainingDummy_001` 存在，头顶血量可见 |
| `002B` | 攻击与扣血 | `20 -> 10 -> 0`，拒绝码包含 `TOO_FAR`、`COOLDOWN`、`TARGET_DEAD` |
| `002C` | 私有掉落与拾取 | `SmallGear +1`、`Exp +4` 由 Server 写入，其他玩家不能抢 |
| `002.1A` | 世界血条表现 | 填充条、数字、Dead 状态可见 |
| `002.1B` | 掉落物模型与落地 | SmallGear 是可识别模型，先落地再可拾取 |
| `002.1C` | 模块化拾取吸走 | Client 只播表现，Server 决定拾取成功 |
| `002.1D` | 奖励临时反馈 | 击杀显示 `+4 Exp`，拾取显示 `+1 SmallGear` |

## Server / Client 边界

Server 负责：

- 攻击合法性判断。
- 伤害、血量、死亡状态。
- 掉落归属、拾取半径、过期清理。
- `Resources`、`Progression`、`TutorialFlags` 写入。
- 发送可信 payload 给 Client。

Client 负责：

- 发送攻击意图。
- 显示训练怪血条。
- 显示掉落物、落地、待机、吸走。
- 显示奖励浮字或临时 Toast。
- 不计算伤害、掉落、奖励和经验。

## 关键配置

| 配置 | 当前口径 |
|---|---|
| M001 血量 | `20` |
| 攻击伤害 | `10` |
| 攻击距离 | 当前验收调参为 `16 studs` |
| SmallGear 掉落 | `M001 -> SmallGear x1` |
| 击杀经验 | `M001 -> Exp +4` |
| 拾取半径 | `8 studs` |
| 掉落 TTL | 当前验收调参为 `60s` |
| 拾取延迟 | 当前验收调参为 `0.8s` |

## 不做事项

| 不做项 | 后续归属 |
|---|---|
| 正式玩家 HUD / ResourceBar | [[PlayerHUD 玩家 HUD]] |
| 完整升级曲线 | `005_ExpLevelProgression` |
| 普通材料怪和 WoodBody / BubbleCore | [[ToyBox 资源卡与奖励循环]] |
| 拼装台 | [[发条拼装台 UI]] |
| 玩具 AI 参与战斗 | Toy deploy / Toy AI Feature |
| Boss、ProfileStore | 后续独立 Feature |

## 来源

- [[../../10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/02_CombatTrainingEnemy/000大纲]]
- [[../../10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/02_CombatTrainingEnemy/002.1 大纲]]
- [[../../10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/02_CombatTrainingEnemy/002.2]]
- [[../../10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/02_CombatTrainingEnemy/002.3]]
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\002_CombatTrainingEnemy.md`
- `D:\AI\Codex\ToyBox\TOYBOX_CURRENT_STATE.md`

## 相关链接

- [[Client Server Remote 请求链路]]
- [[DataService 与 DataSchema 边界]]
- [[Feature Pack 与 Feature Card]]
- [[ToyBox 项目索引]]
