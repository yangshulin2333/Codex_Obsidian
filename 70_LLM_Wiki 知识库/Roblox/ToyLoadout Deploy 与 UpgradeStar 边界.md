---
type: project
domain: roblox
status: processing
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# ToyLoadout Deploy 与 UpgradeStar 边界

## 一句话说明

`ToyLoadout.Deploy` 和 `ToyLoadout.UpgradeStar` 是完整 `008_ToyInventory` 的后续切片：前者让一个玩具上阵参战，后者消耗 `ToyFragments` 提升玩具星级。

## 当前状态

当前状态：`Planned / schema reserved / runtime not implemented`。

当前 `src` 中没有定位到 `ToyLoadout.Deploy` 或 `ToyLoadout.UpgradeStar` 的正式 Remote 实现。已存在的事实是：

- `DataSchema` 预留了 `Toys.DeployedToyId`、`Toys.DeployedToyIds`、`Toys.StarsByToyId`。
- `ToyConfig` 快照口径已能携带 `DeployedToyId` / `DeployedToyIds`。
- `008A_EquipmentService` 已实现 `ToyLoadout.Equip`，但它只负责装备贡献，不负责上阵跟随或升星。

## 三个动作的区别

| 动作 | 含义 | 数据字段 | 当前状态 |
|---|---|---|---|
| `ToyLoadout.Deploy` | 让一个玩具进入场景跟随或辅助战斗 | `Toys.DeployedToyId` | 未实现 |
| `ToyLoadout.Equip` | 装备一个玩具，让其属性贡献进入 `PowerScore` | `Toys.EquippedToyId` | 已有 008A 最小 Server 切片 |
| `ToyLoadout.UpgradeStar` | 消耗碎片提升玩具星级 | `Toys.StarsByToyId`、`Resources.ToyFragments` | 未实现 |

不要把“上阵”和“装备”混成一个概念。上阵偏场景表现和战斗辅助；装备偏属性/战力贡献。

## Deploy 目标链路

```text
ToyListUI 点击上阵
-> Client 调用 ToyLoadout.Deploy
-> Server 校验 Profile / toyId / ownership
-> Server 写入 Toys.DeployedToyId
-> Server 返回 toys 快照
-> Client 生成或切换跟随玩具表现
```

首轮只允许同时上阵 1 个玩具。

## UpgradeStar 目标链路

```text
ToyListUI 点击升星
-> Client 调用 ToyLoadout.UpgradeStar
-> Server 校验 Profile / toyId / ownership / stars / ToyFragments
-> Server 扣除 Resources.ToyFragments
-> Server 写入 Toys.StarsByToyId[toyId]
-> Server 重算相关数值
-> UI 刷新星级、碎片数和战力反馈
```

升星必须由 Server 扣碎片和写星级，Client 不能自行推断成功。

## Server 必须校验

| 检查 | 说明 |
|---|---|
| Profile ready | 数据未加载时返回 `PROFILE_NOT_READY` |
| toyId 合法 | 不存在于 `ToyConfig` 的玩具拒绝 |
| ownership | 未拥有玩具不能上阵、装备或升星 |
| 星级上限 | 不允许超过 `ToyConfig.MaxStars` |
| 碎片数量 | `ToyFragments` 不足时不扣资源、不改星级 |
| 冷却/频率 | 防止按钮连点造成重复写入 |

## 失败码建议

| Code | 含义 |
|---|---|
| `PROFILE_NOT_READY` | 玩家数据未加载 |
| `INVALID_REQUEST` | payload、requestId 或 toyId 不合法 |
| `UNKNOWN_TOY` | `ToyConfig` 中没有该玩具 |
| `NOT_OWNED` | 玩家未拥有该玩具 |
| `MAX_STAR` | 已达到最高星级 |
| `NOT_ENOUGH_FRAGMENT` | 玩具碎片不足 |
| `COOLDOWN` | 请求过快 |
| `SERVER_ERROR` | 写入失败或返回结构异常 |

## 不做事项

| 不做项 | 后续归属 |
|---|---|
| 首次获得玩具 | [[AssemblyBench 第一次拼装闭环]] |
| 结果弹窗 | [[ToyResultUI 拼装结果弹窗]] |
| 玩具列表 UI | [[ToyInventory 与 ToyListUI 玩具库存]] |
| 装备 PowerScore 最小切片 | [[EquipmentService 玩具装备服务]] |
| 真实持久化 | [[ProfileStore 持久化边界]] |
| 完整 Toy AI / 跟随动画 / 攻击 VFX | Toy deploy 表现 Feature |

## 验收口径

- 未拥有玩具不能上阵或升星。
- 同时只能有 1 个 `DeployedToyId`。
- 升星消耗 `ToyFragments`，失败不扣资源。
- 达到最高星级时返回明确失败。
- Deploy 和 Equip 可以分别显示，不互相覆盖字段。
- 快照能让 ToyListUI 正确显示已上阵、已装备、星级和碎片状态。

## 来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_PLAN_GDD_v2_4.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\008A_EquipmentService_玩具装备服务.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\tdd\008A_EquipmentService_玩具装备服务_TDD.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ReplicatedStorage\Game\Shared\Config\DataSchema.lua`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansGame\src\ReplicatedStorage\Game\Shared\Config\ToyConfig.lua`

## 相关链接

- [[ToyInventory 与 ToyListUI 玩具库存]]
- [[EquipmentService 玩具装备服务]]
- [[AssemblyBench 第一次拼装闭环]]
- [[ProfileStore 持久化边界]]
- [[ExpLevelProgression 经验等级成长]]
