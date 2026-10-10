# v0.13.0 发布前检查清单

## 当前状态

```text
Demo 项目：Demo01
参考项目：吃东西测试服
当前版本：Eat Demo v0.13.0
真实 DataStore：已测试通过
Rojo 源码目录：D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_RojoKnit\src
```

## 已通过内容

```text
进入游戏
UI 显示
吃食物
Muscle / Money / FoodCore 增加
2x Speed
2x Size
Auto Collect
Bag / FoodCore 使用
Reward 领取和冷却
DataStore 保存
DataStore 读取
```

## 当前仍是 Demo 配置

这些配置现在适合测试，不一定适合正式游戏：

| 配置 | 当前值 | 说明 |
|---|---:|---|
| `RewardCooldown` | 30 | 现在是 30 秒测试冷却，不是每日奖励 |
| `AutoCollectDuration` | 60 | 自动收集测试时长 |
| `AutoCollectCost` | 250 | 临时 Money 价格 |
| `DropCount` | 12 | Demo 食物数量 |
| `DataStoreName` | `EatDemoReplica_v1` | 当前 Demo 存档名 |

## 后续正式化前要决定

| 问题 | 建议 |
|---|---|
| Reward 是否改成每日奖励 | 正式版应改成 24 小时冷却 |
| Auto Collect 是否继续用 Money 购买 | 可保留；Robux 版本应走 Developer Product |
| DataStoreName 是否继续用当前名字 | Demo 阶段可以；正式上线前建议换正式存档名 |
| 是否清空测试存档 | 正式上线前建议换 DataStoreName，而不是直接清空 |
| 是否接入 Robux 购买 | 下一阶段单独做 Developer Product |

## 不要做的事

```text
不要把当前 Rojo 项目连接到参考项目“吃东西测试服”
不要在 Studio 里直接改映射脚本
不要开启 Rojo Two-Way Sync
不要用旧项目无权限 AssetId 直接替换当前占位资源
不要把 RewardCooldown = 30 当成正式每日奖励
```

## 下一步建议

优先级从高到低：

```text
1. v0.14.0：把 Reward 从 30 秒测试奖励改成正式每日奖励结构，但保留测试开关
2. v0.15.0：接 Developer Product 框架，先做 Robux 购买 Muscle 的最小闭环
3. v0.16.0：整理 UI 风格，让 Demo 更接近参考项目
4. v0.17.0：规划 Workspace 地图和可收集物生成区域
```

