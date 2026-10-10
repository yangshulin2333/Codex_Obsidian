---
type: concept
domain: roblox
status: evergreen
owner: codex
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# DataService 与 DataSchema 边界

## 一句话说明

`DataSchema` 定义玩家数据结构，`DataService` 提供读写入口，具体玩法 Service 决定规则。

## 三者分工

| 模块 | 职责 | 不应该做什么 |
|---|---|---|
| DataSchema | 定义默认数据结构 | 写玩法规则 |
| DataService | 创建、读取、更新玩家 profile | 判断某个玩法该加多少奖励 |
| 玩法 Service | 校验玩法规则并决定如何改数据 | 绕过 DataService 直接乱改底层数据 |

## 关键心智模型

```text
DataSchema 是模板。
profile.Data 才是玩家当前数据。
```

玩家进入游戏后：

```text
DataSchema.Defaults
-> deepCopy
-> DataService 创建玩家自己的 profile.Data
-> DataService._profiles[player] = profile
```

点击玩法按钮后：

```text
FirstLoopService
-> DataService:IsProfileReady(player)
-> DataService:UpdateProfile(player, reason, updater)
-> updater(data)
-> 修改 profile.Data
-> 返回结果
```

## 为什么要 deepCopy

如果直接复用 `DataSchema.Defaults`，多个玩家可能共享同一张表。

这会导致：

- 玩家 A 修改资源，玩家 B 也可能受影响。
- 嵌套表如 `Flags`、`OwnedToyIds` 更容易出现共享引用问题。
- Bug 很隐蔽，后期难查。

## 读取和写入边界

| 方法 | 用途 |
|---|---|
| `GetDataSnapshot` | 返回数据副本，适合 UI 显示和安全读取 |
| `UpdateProfile` | 正式写入入口，适合服务端规则更新数据 |

不要用快照改数据。

## 当前 ToyBox 数据结构主干

| 区域 | 当前用途 |
|---|---|
| `Resources` | `SmallGear`、`WoodBody`、`BubbleCore`、`ToyFragments` 等资源 |
| `Progression` | `Level`、`Exp`、`PowerScore`、教学标记和区域重启状态 |
| `Toys` | 已拥有、上阵、装备、星级等玩具状态 |
| `Collection` | 已收藏玩具 id |
| `Upgrade` | 强化等级 |
| `AreaUnlocks` / `AreaAbilities` | 区域和能力解锁 |
| `PermanentStats` | 重启或长期成长后的永久属性 |

这些字段现在先服务内存 session 验证；真实跨 session 保存归属 [[ProfileStore 持久化边界]]。

## ProfileStore Adapter 边界

当前 `DataService` 已经预留 adapter：

```text
RegisterAdapter
LoadProfile
SaveProfile
ReleaseProfile
```

但是 ToyBox Demo 第一版不接真实 `ProfileStore`。业务代码仍然只能依赖 `DataService`，不能直接 require 底层存档库。

## 配置边界

在 FirstLoop 里，边界可以这样理解：

```text
DataSchema：默认有 SmallGear，默认值是 0
ResourceConfig：SmallGear 最大值是多少
FirstLoopConfig：这次点击增加多少，冷却多久
FirstLoopService：这次请求是否允许执行
DataService：把允许后的修改写入 profile
```

## 来源

- [[../../10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/FirstLoop/第 5 课：DataService  DataSchema 在 FirstLoop 里怎么配合]]
- [[20_Areas 领域/Roblox/框架/项目框架]]

## 相关链接

- [[Client Server Remote 请求链路]]
- [[Feature Pack 与 Feature Card]]
- [[Roblox 项目架构职责边界]]
- [[ProfileStore 持久化边界]]
