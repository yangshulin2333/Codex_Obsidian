---
type: project
domain: roblox
status: processing
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# UpgradeBench 强化台闭环

## 一句话说明

`004_UpgradeBench` 负责把 `SmallGear` 变成可见成长：玩家靠近强化台，消耗小齿轮提升 `UpgradeLevel`，Server 重算 `PowerScore`，HUD 显示结果。

## 当前状态

当前状态：`Draft / Decisions confirmed, ready for execution`。

这页只沉淀 Feature Card / TDD 的设计口径；不要把它写成已完成运行验收。

## 目标链路

```text
玩家靠近强化台
-> Client 点击 Apply
-> Client 请求 Upgrade.ApplyAttack
-> UpgradeService 校验 Profile / 距离 / 资源 / 上限
-> DataService:UpdateProfile 扣 SmallGear 并提升 UpgradeLevel
-> ProgressionConfig.CalculatePowerScore 重算 PowerScore
-> Server 返回资源、强化、成长快照
-> HUD / Toast 刷新成功或错误反馈
```

## 本卡范围

| 内容 | 规则 |
|---|---|
| Remote | `Upgrade.ApplyAttack` |
| 消耗资源 | `Resources.SmallGear` |
| 成长字段 | `Upgrade.UpgradeLevel` |
| 等级范围 | `0 -> 5` |
| 默认消耗 | `SmallGearCost = 1` |
| 派生结果 | `Progression.PowerScore` |

## 失败码

| Code | 含义 |
|---|---|
| `PROFILE_NOT_READY` | Profile 未加载 |
| `INVALID_REQUEST` | payload / requestId 不合法 |
| `OUT_OF_RANGE` | 玩家不在强化台交互范围内 |
| `NOT_ENOUGH_RESOURCE` | SmallGear 不足 |
| `MAX_LEVEL` | 已到强化上限 |
| `SERVER_ERROR` | DataService 或返回结构异常 |

## Server / Client 边界

Server 负责：

- 校验交互范围。
- 校验资源是否足够。
- 校验是否到上限。
- 扣除 `SmallGear`。
- 写入 `Upgrade.UpgradeLevel`。
- 重算 `Progression.PowerScore`。

Client 负责：

- 展示强化台 UI。
- 发起升级意图。
- 显示成功 / 失败。
- 不直接写资源、强化等级或战力。

## 与其他系统关系

| 系统 | 关系 |
|---|---|
| [[PlayerHUD 玩家 HUD]] | 显示 `SmallGear`、`UpgradeLevel` 和 `PowerScore` |
| [[ExpLevelProgression 经验等级成长]] | 提供统一 `PowerScore` 计算函数 |
| [[ToyBox 资源卡与奖励循环]] | `SmallGear` 是强化消耗来源 |
| [[发条拼装台 UI]] | 不属于本卡，不做拼装主流程 |
| [[EquipmentService 玩具装备服务]] | 后续装备玩具也会进入 PowerScore |

## 不做事项

| 不做项 | 后续归属 |
|---|---|
| 拼装台主流程 | [[发条拼装台 UI]] / AssemblyBench |
| ToyInventory / ToyResultUI | ToyInventory Feature |
| Boss / ProfileStore | 后续独立 Feature |
| 完整强化台美术、音效、VFX | UI / Asset / Polish 小闭环 |
| 改动 003 HUD 与 005 经验升级行为 | 不在本卡内 |

## 验收口径

- SmallGear 足够时，升级成功并 `UpgradeLevel +1`。
- SmallGear 不足时返回 `NOT_ENOUGH_RESOURCE`，不扣资源。
- 到 5 级后返回 `MAX_LEVEL`，不继续扣资源。
- 成功后 `PowerScore` 可见变化。
- 失败时 UI 不播放成功动画。

## 来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\004_UpgradeBench.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\tdd\004_UpgradeBench_TDD.md`
- `D:\AI\Codex\ToyBox\TOYBOX_CURRENT_STATE.md`

## 相关链接

- [[ExpLevelProgression 经验等级成长]]
- [[ToyBox 资源卡与奖励循环]]
- [[PlayerHUD 玩家 HUD]]
- [[DataService 与 DataSchema 边界]]
