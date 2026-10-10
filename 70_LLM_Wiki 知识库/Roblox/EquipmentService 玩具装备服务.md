---
type: project
domain: roblox
status: processing
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# EquipmentService 玩具装备服务

## 一句话说明

`008A_EquipmentService` 是 ToyInventory 的最小 Server 权威切片：玩家装备一个已拥有的玩具，Server 写入 `Toys.EquippedToyId`，并让装备贡献进入 `PowerScore`。

## 当前状态

当前状态：`Implemented / automated verification passed / Studio Play pending`。

这表示运行代码已实现，自动验证已通过；但成功路径仍需要 Studio Play 中通过临时 seed 或未来拼装台产出 `T001` 后验收。

## 目标链路

```text
Client 发起 ToyLoadout.Equip
-> Server 校验 Profile / payload / toyId
-> Server 校验 ToyConfig 是否存在该玩具
-> Server 校验玩家是否拥有该玩具
-> DataService:UpdateProfile 写入 Toys.EquippedToyId
-> ProgressionConfig.CalculatePowerScore 重算 PowerScore
-> Server 返回 toys / equippedToy / progression 快照
```

## 本卡范围

| 内容 | 规则 |
|---|---|
| Service | `EquipmentService.lua` |
| RemoteFunction | `ToyLoadout.Equip` |
| ToyConfig | 首版至少包含 `T001` |
| 写入字段 | `Toys.EquippedToyId` |
| 只读字段 | `Toys.OwnedToyIds`、`Toys.StarsByToyId` |
| 派生字段 | `Progression.PowerScore` |

## ToyConfig 当前口径

当前 `T001`：

```text
ToyId: T001
DisplayName: Bubble Buddy
Quality: Good
FlatAttackBonus: 1
ToyPower: 6
MaxStars: 5
```

`ToyConfig` 还负责：

- 判断玩具是否存在。
- 判断玩家是否拥有玩具。
- 兼容 `OwnedToyIds` 的历史 array 形态和目标 map 形态。
- 构造 `Resource.GetSnapshot` 里的 toys 快照。
- 计算当前装备玩具对 `PowerScore` 的贡献。

## 失败码

| Code | 含义 |
|---|---|
| `PROFILE_NOT_READY` | Profile 未加载 |
| `INVALID_REQUEST` | payload / requestId / toyId 不合法 |
| `UNKNOWN_TOY` | `toyId` 不在 `ToyConfig` |
| `NOT_OWNED` | 玩家未拥有该玩具 |
| `COOLDOWN` | 请求过快 |
| `SERVER_ERROR` | 写入或返回结构异常 |

## Server / Client 边界

Server 负责：

- 确认玩具配置存在。
- 确认玩家拥有玩具。
- 写入当前装备玩具。
- 重算战力。
- 返回可信快照。

Client 负责：

- 表达“想装备哪个 toyId”。
- 展示成功 / 失败结果。
- 不直接写 `Toys` 或 `Progression`。

## 不做事项

| 不做项 | 后续归属 |
|---|---|
| ToyLoadout.Deploy | [[ToyLoadout Deploy 与 UpgradeStar 边界]] |
| ToyLoadout.UpgradeStar | [[ToyLoadout Deploy 与 UpgradeStar 边界]] |
| ToyListUI / ToyCard / EquipButton | 008 UI 切片 |
| AssemblyBench 产出玩具 | [[发条拼装台 UI]] / AssemblyBench |
| 玩具跟随、AI、攻击协助、VFX | 后续上阵玩具表现切片 |
| ProfileStore | [[ProfileStore 持久化边界]] |
| AssetId / 模型 / 图标 | 后续资产小闭环 |

## 验收口径

自动验证已通过：

- `stylua --check src`
- `selene src`
- `rojo build default.project.json --output build.rbxlx`
- `Invoke-ToyBoxCheck.ps1 -Mode Completion`

Studio Play 待验收：

- 未拥有 `T001` 时调用 `ToyLoadout.Equip` 返回 `NOT_OWNED`。
- 临时 seed `Toys.OwnedToyIds.T001 = true` 后调用成功。
- 成功后 `Resource.GetSnapshot` 能看到 `Toys.EquippedToyId = "T001"`。
- 成功后 `Progression.PowerScore` 包含 `ToyConfig.T001` 贡献。

## 来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\008A_EquipmentService_玩具装备服务.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\tdd\008A_EquipmentService_玩具装备服务_TDD.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ServerScriptService\Server\Game\Services\EquipmentService.lua`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ReplicatedStorage\Game\Shared\Config\ToyConfig.lua`

## 相关链接

- [[ExpLevelProgression 经验等级成长]]
- [[发条拼装台 UI]]
- [[ToyLoadout Deploy 与 UpgradeStar 边界]]
- [[ProfileStore 持久化边界]]
- [[PlayerHUD 玩家 HUD]]
- [[DataService 与 DataSchema 边界]]
