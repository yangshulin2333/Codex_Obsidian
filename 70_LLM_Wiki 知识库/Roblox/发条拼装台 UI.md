---
type: project
domain: roblox
status: processing
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# 发条拼装台 UI

## 一句话说明

发条拼装台 UI 是 ToyBox 的核心特色界面：玩家把零件放入三个槽位，完成轻量拧发条操作，获得一个有用途的发条玩具。

## 核心定位

项目核心记忆点是：

```text
打怪捡零件，亲手拼出能战斗、能装配、能成长的发条玩具。
```

UI 的目标不是展示复杂概率，而是让玩家在 1-3 分钟内完成第一次拼装，并理解“材料会影响方向，拧发条会影响品质，拼出来的玩具都有用途”。

## 第一次拼装流程

```text
玩家击败训练区敌人
-> 获得 SmallGear / WoodBody / BubbleCore
-> 系统引导靠近发条拼装台
-> 打开 AssemblyBenchUI
-> 三个槽位同时可见
-> 第一次高亮有效材料
-> 玩家点击“拼装”或完成拧发条
-> Server 返回拼装结果
-> ToyResultUI 展示泡泡小兵
-> 玩家点击“上阵”
-> 泡泡小兵立刻帮助打怪
```

## UI 必须包含

| 区域 | 作用 |
|---|---|
| 核心槽 | 决定玩具类型倾向，例如泡泡核心、磁铁片、发条核心 |
| 身体槽 | 决定外形和基础属性，例如木块身体 |
| 动力槽 | 决定行为倾向，例如小齿轮、弹簧、发条 |
| 预测倾向 | 用文字说明“泡泡类概率提高”等方向 |
| 拧发条按钮 | 触发轻量 timing 操作 |
| 材料数量 | 直接显示当前拥有和消耗 |
| 资源不足提示 | 说明缺什么，不播放成功动画 |
| 结果展示 | 显示 ToyName、Quality、Star、Effect、ToyPreview 和上阵按钮 |

## 不建议首轮显示

- 精确复杂概率。
- 十连抽式表现。
- 复杂筛选和批量拼装。
- 商店、交易、付费抽取。
- 大段说明文字。

## Server / Client 边界

Client 可以发送：

- 选择的材料 id。
- 拼装意图。

Client 不能发送：

- 最终玩具 id。
- 品质。
- 属性数值。
- 是否消耗成功。

Server 必须决定：

- 材料是否足够。
- 配方是否合法。
- 玩具结果。
- 品质。
- 消耗材料。
- 最新资源 / 玩具快照。

## ToyAssembly 运行入口

| 层 | 建议模块 |
|---|---|
| Client Controller | `ToyAssemblyController` |
| Server Service | `ToyAssemblyService` |
| 后续服务 | `ToyService` |
| RemoteFunction | `ToyAssembly.Assemble` |
| Config | `ToyConfig`、`AssemblyRecipeConfig`、`CraftQualityConfig` |

## 验收口径

- 第一次拼装能直接看懂三槽材料。
- 材料不足时，UI 直接说明缺少资源和当前数量。
- 点击拼装后按钮进入短暂等待状态。
- Server 返回后再播放拼装结果，不提前假成功。
- ToyResultUI 能让玩家一眼认出泡泡小兵。
- ToyResultUI 有明确“上阵”主按钮。
- UI 不遮挡泡泡小兵第一次出现和攻击。

## 后续归属

| 内容 | 归属 |
|---|---|
| AssemblyBenchUI | 本页主题 / [[AssemblyBench 第一次拼装闭环]] |
| ToyResultUI | [[ToyResultUI 拼装结果弹窗]] |
| ToyListUI | [[ToyInventory 与 ToyListUI 玩具库存]] |
| 重复转碎片 | [[ToyInventory 与 ToyListUI 玩具库存]] |
| 装配玩具 | Equipment / ToyLoadout |
| 玩具 AI 参战 | Toy deploy / Toy AI Feature |

## 来源

- [[../../10_Projects 项目/Roblox/玩具/玩具箱守卫者_发条拼装核心特色策划方案]]
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\SCREEN_LIST.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\UX_SPEC.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\feature-cards\04_ToyAssembly.md`

## 相关链接

- [[ToyBox 项目索引]]
- [[PlayerHUD 玩家 HUD]]
- [[ToyBox 资源卡与奖励循环]]
- [[AssemblyBench 第一次拼装闭环]]
- [[ToyResultUI 拼装结果弹窗]]
- [[ToyInventory 与 ToyListUI 玩具库存]]
