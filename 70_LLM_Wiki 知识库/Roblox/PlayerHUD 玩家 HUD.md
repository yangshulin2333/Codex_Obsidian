---
type: project
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# PlayerHUD 玩家 HUD

## 一句话说明

`003_PlayerHUD` 是 ToyBox 的第一个正式玩家界面 Feature，用来把资源、生命、等级、经验和战力从 Server 快照显示到常驻 HUD。

## 当前状态

- 当前状态：`Accepted / Studio Play verified`。
- 最小 fallback HUD 已落地。
- 7 个资源图标已写入全项目统一 AssetId Map，并同步到 `AssetCatalog.lua`。
- 用户已在 Studio 手调 `StarterGui > HUDGui`，并通过 Command Bar 回收到 Rojo `HUDGui.model.json`。

## 玩家链路

```text
玩家进入游戏
-> HUD 自动显示
-> Client 请求 Resource.GetSnapshot
-> Server 返回 Resources / Progression / Toys / Collection 快照
-> HUD 刷新资源、生命、等级经验、战力
-> 玩家击杀训练怪或拾取材料
-> Loot / Progression 事件到达
-> HUD 局部刷新
-> 失败时 Toast 显示中文错误
```

## HUD 显示内容

| 区域 | 内容 | 规则 |
|---|---|---|
| ResourceBar | `SmallGear`、`WoodBody`、`BubbleCore`、`Spring`、`MagnetSheet`、`ClockworkCore`、`ToyFragments` | 前三项正常显示，后四项首轮置灰 |
| HealthBar | `Health / MaxHealth` | 当前基于角色 `Humanoid` 显示 |
| LevelExpBar | `Level`、`Exp`、`ExpToNext`、`PowerScore` | 只显示 Server 返回值 |
| ToastLayer | `PROFILE_NOT_READY`、`COOLDOWN`、`SERVER_ERROR` 等中文提示 | 不改当前可信数字 |

## 运行时模块

| 层 | 文件 / 模块 | 职责 |
|---|---|---|
| Server | `ResourceService.lua` | 注册 `Resource.GetSnapshot`，只读 DataService 快照 |
| Shared | `HUDConfig.lua` | 资源顺序、锁定资源、Toast 文案 |
| Shared | `AssetCatalog.lua` | 资源图标 AssetId |
| Client | `PlayerHUDController.lua` | 挂载 HUD、请求快照、监听事件 |
| Client | `PlayerHUDPresentation.lua` | 纯 UI 更新函数 |
| UI | `HUDGui.model.json` | Rojo 固化后的 HUD 模板 |

## 数据边界

HUD 可以读：

- `Resources`
- `Progression`
- `Toys`
- `Collection`

HUD 不写：

- 资源数量。
- 经验。
- 等级。
- 战力。
- 玩具拥有状态。
- 收藏状态。

Client 不能自行计算可信 `PowerScore`、`Level` 或资源增减；这些都必须来自 Server 快照或 Server 事件 payload。

## 不做事项

| 不做项 | 后续归属 |
|---|---|
| 完整 LevelUp 规则 | `005_ExpLevelProgression` |
| 拼装台 UI | [[发条拼装台 UI]] |
| ToyResultUI / ToyListUI | ToyInventory / Toy 相关 Feature |
| UpgradeBenchUI | `004_UpgradeBench` |
| BossRewardUI | [[BossEncounter 与 BossRewardUI]] |
| 玩家受伤 / 死亡完整系统 | [[DeathRespawn 资源保留 UI]] |
| Tarmac 批量资产管线 | 资源规模上来后再评估 |

## 设计原则

- HUD 不抢画面中心。
- 首屏不能遮挡训练怪、掉落物、后续拼装台和泡泡小兵出现。
- 资源变化用轻量数字刷新和短反馈，不做大弹窗。
- 错误提示必须短、中文、可恢复。

## 来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\003_PlayerHUD_玩家HUD.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\tdd\003_PlayerHUD_玩家HUD_TDD.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\003_PlayerHUD_UIBrief_玩家HUD.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\SCREEN_LIST.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\UX_SPEC.md`

## 相关链接

- [[CombatTrainingEnemy 训练怪玩法闭环]]
- [[ToyBox 资源卡与奖励循环]]
- [[Roblox GUI 读取工作流]]
- [[Client Server Remote 请求链路]]
