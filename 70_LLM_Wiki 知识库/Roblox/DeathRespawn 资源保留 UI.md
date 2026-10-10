---
type: project
domain: roblox
status: processing
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# DeathRespawn 资源保留 UI

## 一句话说明

`DeathRespawnUI` 用来解释玩家死亡后的短暂停顿和资源保留规则：玩家知道自己会复活，并且资源、玩具、收藏不会丢。

## 当前状态

当前状态：`Planned / UI requirement / player death runtime not implemented`。

当前代码事实：

- 已有敌人死亡和刷新逻辑，不等于玩家死亡系统。
- `PlayerHUD` 已有 Health / MaxHealth 展示入口。
- `SCREEN_LIST.md` 将 `DeathRespawnUI` 定为 P1 UI。
- 尚未定位到正式玩家死亡、复活倒计时或 `DeathRespawnGui` runtime 实现。

## 目标链路

```text
玩家 Health <= 0
-> Server 判定死亡
-> Client 打开 DeathRespawnGui
-> 显示 Countdown
-> 显示 KeepItemsText
-> 3 秒后复活
-> Health 恢复
-> 资源 / 玩具 / 收藏保持不变
```

## UI 字段

| 字段 | 说明 |
|---|---|
| `Countdown` | 复活倒计时 |
| `KeepItemsText` | 明确资源和玩具不会丢 |
| `RespawnFrame` | Boss 或死亡场景中的复活提示 |
| HealthBar | 受伤、死亡、复活后状态正确 |

## Server / Client 边界

Server 负责：

- 判断玩家是否死亡。
- 判断何时复活。
- 恢复 Health。
- 保证资源、玩具、收藏不被死亡流程清空。

Client 负责：

- 显示倒计时。
- 显示保留资产提示。
- 播放轻量 UI 反馈。
- 不自行决定死亡或复活成功。

## 不做事项

| 不做项 | 后续归属 |
|---|---|
| Boss 战死亡规则 | [[BossEncounter 与 BossRewardUI]] |
| 真实持久化保存 | [[ProfileStore 持久化边界]] |
| 惩罚经济 | 后续平衡 Feature |
| 复杂复活选择 | 后续 UI / 商业化系统 |

## 验收口径

- 玩家死亡时能看到倒计时。
- UI 明确告诉玩家资源和玩具不会丢。
- 复活后 Health 状态正确。
- 死亡流程不清空 `Resources`、`Toys`、`Collection`。
- Client 不能伪造复活或绕过 Server 状态。

## 来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\SCREEN_LIST.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\UI_ASSET_WORKFLOW.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_PLAN_GDD_v2_4.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\003_PlayerHUD_玩家HUD.md`

## 相关链接

- [[PlayerHUD 玩家 HUD]]
- [[BossEncounter 与 BossRewardUI]]
- [[ProfileStore 持久化边界]]
- [[DataService 与 DataSchema 边界]]
