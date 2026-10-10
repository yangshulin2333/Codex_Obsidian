---
type: concept
domain: roblox
status: processing
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# ProfileStore 持久化边界

## 一句话说明

`ProfileStore` 是未来真实存档层；当前 ToyBox Demo 仍使用 `DataService` 的内存 profile 和 adapter 边界，不在第一版 Demo 闭环中接真实持久化。

## 当前状态

当前状态：`Reserved / not connected / v0.2 candidate`。

当前 `DataService` 已预留 adapter：

```text
DataService:RegisterAdapter(adapter)
adapter.LoadProfile(player)
adapter.SaveProfile(player, profile, reason)
adapter.ReleaseProfile(player, profile)
```

但没有真实 `ProfileStore` adapter 接入。没有 adapter 时，`DataService` 创建内存 profile，并标记：

```text
IsEphemeral = true
```

这表示当前数据用于 Demo session 验证，不承诺跨服或下次登录保留。

## 为什么第一版 Demo 不接

Demo 第一版的目标是先证明核心玩法闭环：

```text
战斗 -> 掉落 -> 资源 -> HUD -> 强化 -> 经验等级 -> 拼装 -> 玩具
```

真实持久化会额外引入：

- Session lock。
- 数据迁移。
- Save / Load 失败降级。
- Studio 与线上测试差异。
- 多服务器一致性和退出保存风险。

如果在核心闭环稳定前接入，排查问题时很难区分是玩法 bug、数据 schema bug，还是持久化层 bug。

## 接入前置条件

| 条件 | 说明 |
|---|---|
| `DataSchema` 稳定 | 字段和默认值不能频繁大改 |
| 资源字段已验证 | `Resources` 的增减、上限和快照已跑通 |
| 成长字段已验证 | `Progression` 的等级、经验、PowerScore 已跑通 |
| 玩具字段已验证 | `Toys`、`Collection`、`ToyFragments` 已有稳定读写口径 |
| 迁移策略明确 | 旧字段、缺失字段、版本号都能补齐 |
| 测试环境区分 | Studio 测试与线上测试分离，不污染真实数据 |

## 必须单独成卡

接入真实 `ProfileStore` 时应该单独建 Feature Card / TDD，不要混在玩法 Feature 里。

该卡至少要写清楚：

- `ProfileStore` 读写流程。
- Session lock 策略。
- `DataSchema.Version` 和迁移策略。
- 默认值补齐逻辑。
- Load 失败时的玩家处理。
- Save 失败时的日志和重试策略。
- PlayerRemoving / BindToClose 的释放策略。
- Studio 与线上环境的数据命名隔离。

## 业务代码边界

业务 Service 不应该直接 require 或调用 `ProfileStore`。

正确边界是：

```text
玩法 Service
-> DataService:IsProfileReady
-> DataService:UpdateProfile(reason, updater)
-> DataService adapter
-> ProfileStore / DataStore
```

这样以后替换底层存档实现时，`CombatService`、`LootDropService`、`UpgradeService`、`EquipmentService` 不需要重写。

## 当前 ToyBox DataSchema 关键字段

| 区域 | 字段 |
|---|---|
| Meta | `SchemaVersion`、`CreatedAt`、`LastLoginAt` |
| Resources | `SmallGear`、`WoodBody`、`Spring`、`BubbleCore`、`MagnetSheet`、`ClockworkCore`、`ToyFragments` |
| Progression | `Level`、`Exp`、`TutorialFlags`、`PowerScore`、`RegionRebootDone` |
| Toys | `OwnedToyIds`、`DeployedToyId`、`EquippedToyId`、`DeployedToyIds`、`StarsByToyId` |
| Collection | `CollectedToyIds` |
| Upgrade | `UpgradeLevel` |
| AreaUnlocks | `UnlockedAreaIds` |
| AreaAbilities | `SecondJumpUnlocked` |
| PermanentStats | `Unspent`、`Attack`、`Health`、`ToyMultiplier` |

## 验收口径

- 新玩家能从默认值创建完整 profile。
- 老玩家缺失字段能按 `DataSchema` 补齐。
- 同一账号不能被两个服务器同时写坏。
- Save 失败有日志和可恢复策略。
- 玩法 Service 仍只依赖 `DataService`，不直接依赖 `ProfileStore`。
- Studio 测试不会污染线上真实数据。

## 来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_PLAN_GDD_v2_4.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ServerScriptService\Server\Framework\Services\DataService.lua`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ReplicatedStorage\Game\Shared\Config\DataSchema.lua`
- `D:\AI\Codex\ToyBox\RobloxGameFramework\src\ServerScriptService\Server\Framework\Services\DataService.lua`

## 相关链接

- [[DataService 与 DataSchema 边界]]
- [[ToyInventory 与 ToyListUI 玩具库存]]
- [[ExpLevelProgression 经验等级成长]]
- [[ToyBox 资源卡与奖励循环]]
- [[Feature Pack 与 Feature Card]]
