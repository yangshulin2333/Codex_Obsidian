---
type: project
domain: roblox
status: processing
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# ToyInventory 与 ToyListUI 玩具库存

## 一句话说明

`008_ToyInventory` 是玩具系统的玩家管理层：查看已拥有玩具，上阵 1 个玩具，装配 1 个玩具，使用碎片升星，并把收藏状态写入长期数据。

## 当前状态

当前状态：`Planned / partial server slice exists`。

完整 `008_ToyInventory` 尚未实现。`008A_EquipmentService` 已提前落地了最小 `ToyLoadout.Equip` Server 切片，但还没有 `Deploy`、`UpgradeStar`、`ToyListUI` 或 `AssemblyBench` 产出玩具的成功路径。

## 目标链路

```text
AssemblyBench 产出玩具
-> Server 写入 Toys / Collection
-> ToyListUI 展示拥有玩具
-> 玩家选择上阵或装备
-> Server 校验玩家是否拥有玩具
-> Server 写入 DeployedToyId / EquippedToyId
-> 升星时消耗 ToyFragments
-> UI 刷新玩具卡、星级、上阵状态、装配状态
```

## 008 范围

| 内容 | 规则 |
|---|---|
| Feature | `008_ToyInventory` |
| UI | `ToyListUI`、`ToyCardTemplate` |
| Remotes | `ToyLoadout.Deploy`、`ToyLoadout.Equip`、`ToyLoadout.UpgradeStar` |
| 当前已落地 | `ToyLoadout.Equip` Server 权威切片 |
| 当前未落地 | `Deploy`、`UpgradeStar`、ToyListUI、玩具跟随表现 |

## 数据字段

| 字段 | 用途 |
|---|---|
| `Toys.Owned` / `Toys.OwnedToyIds` | 已拥有玩具 |
| `Toys.DeployedToyId` | 当前上阵玩具 |
| `Toys.EquippedToyId` | 当前装配玩具 |
| `Toys.Stars` / `Toys.StarsByToyId` | 玩具星级 |
| `Collection.CollectedToyIds` | 收藏进度 |
| `Resources.ToyFragments` | 升星和重复转化资源 |

实际实现时要保持历史字段兼容，不要直接假设 `Owned`、`OwnedToyIds`、`Stars`、`StarsByToyId` 已统一。

## ToyListUI 首轮字段

| UI 元素 | 说明 |
|---|---|
| `ToyListGui` | HUD ToyButton 或 ToyResultUI 打开 |
| `ToyCardTemplate` | 单个玩具卡模板 |
| 玩具头像 | 与 ToyResultUI 共用 |
| 星级 | 显示当前星级 |
| 碎片数 | 显示可升星进度 |
| `DeployButton` | 上阵按钮，只能上阵 1 个 |
| `EquipButton` | 装备按钮，只能装备 1 个 |
| `UpgradeStarButton` | 升星按钮，资源不足时禁用或提示 |
| `CollectionStateText` | 已收藏 / 未获得 / 已上阵等状态 |

## Server / Client 边界

Server 负责：

- 校验玩具是否存在。
- 校验玩家是否拥有玩具。
- 校验碎片是否足够。
- 写入上阵、装备、升星和收藏状态。
- 返回可信玩具快照。

Client 负责：

- 展示列表、按钮状态和错误提示。
- 发送玩家意图，例如 deploy / equip / upgrade。
- 不直接写 `Toys`、`Collection` 或 `Resources`。

## 与 008A 的关系

`008A_EquipmentService` 是完整 008 的提前落地切片：

- 已实现：`ToyLoadout.Equip`。
- 已写入：`Toys.EquippedToyId`。
- 已影响：`Progression.PowerScore`。
- 未实现：`ToyLoadout.Deploy`、`ToyLoadout.UpgradeStar`、ToyListUI、AssemblyBench 产出玩具。

因此，ToyInventory Wiki 必须把“完整 008 设计”和“008A 已实现事实”分开写。

## 验收口径

- 未拥有玩具不能上阵、装备或升星。
- 上阵玩具同时只能有 1 个。
- 装备玩具同时只能有 1 个。
- 升星必须消耗 `ToyFragments`。
- 重复收藏路径只使用 `Collection.CollectedToyIds`。
- ToyListUI 中拥有、未拥有、已上阵、已装备状态清楚。

## 来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_PLAN_GDD_v2_4.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\008A_EquipmentService_玩具装备服务.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\tdd\008A_EquipmentService_玩具装备服务_TDD.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\SCREEN_LIST.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\UI_ASSET_WORKFLOW.md`

## 相关链接

- [[EquipmentService 玩具装备服务]]
- [[ToyLoadout Deploy 与 UpgradeStar 边界]]
- [[ProfileStore 持久化边界]]
- [[AssemblyBench 第一次拼装闭环]]
- [[ToyResultUI 拼装结果弹窗]]
- [[ExpLevelProgression 经验等级成长]]
- [[ToyBox 资源卡与奖励循环]]
