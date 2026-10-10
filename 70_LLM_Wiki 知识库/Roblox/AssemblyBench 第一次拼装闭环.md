---
type: project
domain: roblox
status: processing
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# AssemblyBench 第一次拼装闭环

## 一句话说明

`007_AssemblyBench` 是 ToyBox 的第一次玩具产出闭环：玩家投入材料，Server 决定拼装结果，首次教学拼装固定产出 `T001` 泡泡小兵，并把玩具写入玩家数据。

## 当前状态

当前状态：`Design / planned / runtime not implemented`。

CodeGraph 当前没有定位到正式 `ToyAssemblyService`、`ToyAssemblyController` 或 `ToyAssembly.Assemble` runtime 实现；现有依据主要来自 Demo 设计文档、旧 `04_ToyAssembly` Feature Card、UI/UX 规范和 GDD v2.4 实施顺序。

## 目标链路

```text
玩家收集 SmallGear / WoodBody / BubbleCore
-> 靠近发条拼装台
-> 打开 AssemblyBenchUI
-> 选择或确认 3 个材料槽
-> Client 调用 ToyAssembly.Assemble
-> Server 校验 Profile / 材料 / 配方 / 冷却
-> 首次教学拼装固定获得 T001
-> Server 扣除材料，写入 Toys / Collection / TutorialFlags
-> Server 返回最新资源和玩具快照
-> ToyResultUI 展示结果
```

## 007 范围

| 内容 | 规则 |
|---|---|
| Feature | `007_AssemblyBench` |
| Remote | `ToyAssembly.Assemble` |
| Server Service | `ToyAssemblyService` |
| Client Controller | `ToyAssemblyController` |
| UI | `AssemblyBenchUI`、`ToyResultUI` |
| 首次结果 | 固定 `T001`，品质 `Good` / 良好 |
| 首次目标 | 新玩家 1-3 分钟内完成第一次教学拼装 |

## 数据写入

| 字段 | 用途 |
|---|---|
| `Resources.SmallGear` | 首次拼装材料之一 |
| `Resources.WoodBody` | 首次拼装材料之一 |
| `Resources.BubbleCore` | 首次拼装材料之一 |
| `Toys.Owned` / `Toys.OwnedToyIds` | 记录已拥有玩具 |
| `Collection.CollectedToyIds` | 记录收藏进度 |
| `Progression.TutorialFlags.FirstAssemblyCompleted` | 标记首次拼装完成 |
| `Resources.ToyFragments` | 重复玩具转碎片的后续规则 |

## Server / Client 边界

Client 可以发送：

- 选择的材料 id。
- 拼装意图。
- 请求 id 或交互上下文。

Client 不能发送：

- 最终玩具 id。
- 品质。
- 属性数值。
- 材料是否扣除成功。
- 是否首次拼装完成。

Server 必须决定：

- Profile 是否可用。
- 材料是否足够。
- 配方是否合法。
- 结果玩具与品质。
- 是否扣除材料。
- 是否写入玩具、收藏和教学标记。

## AssemblyBenchUI 首轮要求

| UI 元素 | 说明 |
|---|---|
| `MaterialSlotBody` | 身体槽，首次强调 `WoodBody` |
| `MaterialSlotDrive` | 动力槽，首次强调 `SmallGear` |
| `MaterialSlotFeature` | 特性槽，首次强调 `BubbleCore` |
| `AssembleButton` | 主按钮，点击后进入短暂等待状态 |
| 缺材料提示 | 明确显示缺什么、当前有多少 |
| 结果入口 | Server 成功后再打开 `ToyResultUI` |

## 不做事项

| 不做项 | 后续归属 |
|---|---|
| 完整 6 个玩具战斗 AI | Toy deploy / Toy AI Feature |
| `ToyLoadout.Deploy` | [[ToyInventory 与 ToyListUI 玩具库存]] |
| `ToyLoadout.UpgradeStar` | [[ToyInventory 与 ToyListUI 玩具库存]] |
| ToyListUI | [[ToyInventory 与 ToyListUI 玩具库存]] |
| 装备 PowerScore 贡献 | [[EquipmentService 玩具装备服务]] |
| Boss / 重启 / 长期成长 | 后续 Feature |

## 验收口径

- 新玩家 1-3 分钟内能完成第一次教学拼装。
- 首次拼装固定获得 `T001` 泡泡小兵。
- 首次品质为 `Good` / 良好。
- 材料不足时不扣材料、不写玩具、不播放成功动画。
- Server 返回后才打开 `ToyResultUI`。
- 重复玩具进入 `ToyFragments` 规则，不重复污染收藏路径。

## 来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\04_ToyAssembly.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\IMPLEMENTATION_PLAN_GDD_v2_4.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\SCREEN_LIST.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\UX_SPEC.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\UI_ASSET_WORKFLOW.md`

## 相关链接

- [[发条拼装台 UI]]
- [[ToyResultUI 拼装结果弹窗]]
- [[ToyInventory 与 ToyListUI 玩具库存]]
- [[BasicMaterialEnemies 基础材料怪]]
- [[EquipmentService 玩具装备服务]]
